`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// IO_PERF_TB.v  -  cycle-accurate performance testbench for the DLX-NN.
//
// Measures, for whatever program is currently loaded in sram.data:
//
//   (1) PER-INSTRUCTION LATENCY
//       Clock cycles from the first FETCH cycle of an instruction up to (but
//       not including) the first FETCH cycle of the next one.  Aggregated per
//       opcode, so "tanh took N clks" falls straight out of the table.
//
//   (2) ENGINE-ONLY CYCLES  (accelerated instructions)
//       Cycles the FSM actually sits in the activation/mult states
//       (S_SIGMOID / S_RELU / S_MULT / S_SOFTMAX_*), i.e. the calculation
//       itself with fetch/decode/write-back preparation stripped off.
//
//   (3) CALC-WINDOW CYCLES  (software / non-accelerated programs)
//       Cycles spent between two program-counter markers.  Set them to the
//       first real arithmetic instruction and to the instruction that stores
//       the result, and you get the software activation cost without the
//       bootstrap, the input load and the result store.  Subroutine calls that
//       jump outside the [START,END] address range are still counted, because
//       the window is a latch driven by FETCH events, not an address compare.
//
//   (4) WHOLE-PROGRAM CYCLES
//       Total clocks from the first FETCH until the machine reaches S_HALT.
//
// The CPU is left FREE-RUNNING (pc_step_en held high) instead of being
// single-stepped like IO_TB.v -- single-stepping inserts idle S_INIT cycles
// between instructions and would corrupt every number above.
//
// Markers are set by the CALC_START_PC / CALC_END_PC localparams below --
// edit them to match the program you loaded into sram.data (PCs come straight
// out of the .lst file).  They are preset for asm/tanh.s.
////////////////////////////////////////////////////////////////////////////////

module IO_PERF_TB;

    // ---- control FSM state encoding (must track dlx_control.v) ----
    localparam [4:0] S_INIT          = 5'd0;
    localparam [4:0] S_FETCH         = 5'd1;
    localparam [4:0] S_DECODE        = 5'd2;
    localparam [4:0] S_HALT          = 5'd19;
    localparam [4:0] S_SIGMOID       = 5'd21;   // sigmoid / tanh / gelu
    localparam [4:0] S_SOFTMAX_START = 5'd22;
    localparam [4:0] S_RELU          = 5'd23;
    localparam [4:0] S_SOFTMAX_RUN   = 5'd24;
    localparam [4:0] S_MULT          = 5'd25;

    // ---- calc-window markers -- EDIT THESE PER PROGRAM ----
    // asm/tanh.s (software):
    //   0x14 = 'slli R1 R1', first arithmetic op after 'lw R1 R0 input'
    //   0x24 = 'tdone: sw R2 R0 result', the store that ends the computation
    // asm/tanh_accel.s (hardware):  start 0x07 (the tanh instr), end 0x08 (sw)
    localparam [31:0] CALC_START_PC = 32'h00000014;
    localparam [31:0] CALC_END_PC   = 32'h00000024;

    localparam TRACE      = 1;          // 1 = print every retired instruction
    localparam MAX_CYCLES = 2000000;     // runaway-simulation guard

    // ---- DUT hookup ----
    reg  clk_in;
    reg  rst;
    reg  pc_step_en;

    wire busy;
    wire [4:0] control_state;

    IO uut (
        .clk_in(clk_in),
        .rst(rst),
        .pc_step_en(pc_step_en),
        .busy(busy),
        .control_state(control_state)
    );

    always #50 clk_in = ~clk_in;

    // ---- measurement state ----
    reg  [4:0]  prev_state;
    reg         counting;        // between first FETCH and S_HALT
    reg         halted;
    reg         instr_active;    // an instruction is being timed
    reg         in_calc;         // inside the calc window

    integer total_cycles;
    integer total_instrs;
    integer instr_cycles;        // cycles of the instruction being timed
    integer instr_engine;        // engine-state cycles of that instruction
    integer engine_cycles;       // engine-state cycles, whole program
    integer calc_cycles;
    integer calc_instrs;

    reg  [5:0]  cur_op;
    reg  [31:0] cur_pc;

    // per-opcode accumulators
    integer op_count  [0:63];
    integer op_cycles [0:63];
    integer op_engine [0:63];
    integer op_min    [0:63];
    integer op_max    [0:63];

    integer i;
    integer avg_x100;
    reg     accel_seen;

    // ---- helpers ----
    function is_engine_state;
        input [4:0] s;
        begin
            is_engine_state = (s == S_SIGMOID)       ||
                              (s == S_RELU)          ||
                              (s == S_MULT)          ||
                              (s == S_SOFTMAX_START) ||
                              (s == S_SOFTMAX_RUN);
        end
    endfunction

    function is_accel_op;
        input [5:0] op;
        begin
            is_accel_op = (op == 6'b111000) || (op == 6'b111001) ||
                          (op == 6'b111010) || (op == 6'b111100) ||
                          (op == 6'b111101) || (op == 6'b111110);
        end
    endfunction

    // fixed 10-char names so %s prints cleanly on every simulator
    function [79:0] opname;
        input [5:0] op;
        begin
            case (op)
                6'b000000: opname = "alu/shift ";
                6'b000100: opname = "beqz      ";
                6'b000101: opname = "bnez      ";
                6'b001011: opname = "addi      ";
                6'b010110: opname = "jr        ";
                6'b010111: opname = "jalr      ";
                6'b011011: opname = "sgei      ";
                6'b011100: opname = "slti      ";
                6'b100011: opname = "lw        ";
                6'b101011: opname = "sw        ";
                6'b110000: opname = "nop       ";
                6'b111000: opname = "SIGMOID   ";
                6'b111001: opname = "TANH      ";
                6'b111010: opname = "GELU      ";
                6'b111100: opname = "RELU      ";
                6'b111101: opname = "SOFTMAX   ";
                6'b111110: opname = "MULT      ";
                6'b111111: opname = "halt      ";
                default: begin
                    if (op[5:3] == 3'b011) opname = "set-imm   ";
                    else                   opname = "unknown   ";
                end
            endcase
        end
    endfunction

    // record one finished instruction
    task retire_instr;
        begin
            total_instrs  = total_instrs + 1;
            op_count[cur_op]  = op_count[cur_op]  + 1;
            op_cycles[cur_op] = op_cycles[cur_op] + instr_cycles;
            op_engine[cur_op] = op_engine[cur_op] + instr_engine;
            if (instr_cycles < op_min[cur_op]) op_min[cur_op] = instr_cycles;
            if (instr_cycles > op_max[cur_op]) op_max[cur_op] = instr_cycles;

            if (TRACE) begin
                if (instr_engine > 0)
                    $display("  [%4d] PC=0x%08h  %s  %0d clk  (engine %0d clk)",
                             total_instrs, cur_pc, opname(cur_op),
                             instr_cycles, instr_engine);
                else
                    $display("  [%4d] PC=0x%08h  %s  %0d clk",
                             total_instrs, cur_pc, opname(cur_op), instr_cycles);
            end
        end
    endtask

    // ---- the counter itself ----
    // control_state is a non-blocking-assigned register inside dlx_control, so
    // reading it here yields the state that was active during the cycle that is
    // ending on this edge.  Same reasoning for PC and IR_OUT.
    always @(posedge clk_in) begin
        if (rst) begin
            prev_state   = S_INIT;
            counting     = 1'b0;
            halted       = 1'b0;
            instr_active = 1'b0;
        end else if (!halted) begin

            if (control_state == S_HALT) begin
                // the halt instruction never retires on a following fetch
                if (instr_active) retire_instr;
                instr_active = 1'b0;
                halted       = 1'b1;
                report_results;
                $finish;
            end else begin

                // --- instruction boundary: first FETCH cycle of a new instr ---
                if (control_state == S_FETCH && prev_state != S_FETCH) begin
                    if (instr_active) retire_instr;

                    cur_pc       = uut.dlx.u_data_path.PC;
                    instr_cycles = 0;
                    instr_engine = 0;
                    instr_active = 1'b1;
                    counting     = 1'b1;

                    // calc window is a latch driven by fetch events, so a call
                    // that leaves the [start,end] range stays inside the window
                    if (in_calc && cur_pc == CALC_END_PC)         in_calc = 1'b0;
                    else if (!in_calc && cur_pc == CALC_START_PC) in_calc = 1'b1;

                    if (in_calc) calc_instrs = calc_instrs + 1;
                end

                // IR_OUT is loaded at the edge that ends the fetch cycle, so it
                // is valid from the decode cycle onwards
                if (control_state == S_DECODE)
                    cur_op = uut.dlx.u_data_path.IR_OUT[31:26];

                // --- accounting ---
                if (counting) begin
                    total_cycles = total_cycles + 1;
                    instr_cycles = instr_cycles + 1;
                    if (in_calc) calc_cycles = calc_cycles + 1;

                    if (is_engine_state(control_state)) begin
                        instr_engine  = instr_engine  + 1;
                        engine_cycles = engine_cycles + 1;
                    end
                end

                if (total_cycles > MAX_CYCLES) begin
                    $display("");
                    $display("ERROR: %0d cycles without reaching HALT - aborting.",
                             total_cycles);
                    halted = 1'b1;
                    report_results;
                    $finish;
                end
            end

            prev_state = control_state;
        end
    end

    // ---- reporting ----
    task report_results;
        begin
            $display("");
            $display("================================================================");
            $display(" WHOLE PROGRAM");
            $display("================================================================");
            $display("  Instructions executed : %0d", total_instrs);
            $display("  TOTAL CLOCK CYCLES    : %0d", total_cycles);
            if (total_instrs > 0) begin
                avg_x100 = (total_cycles * 100) / total_instrs;
                $display("  Average CPI           : %0d.%02d",
                         avg_x100 / 100, avg_x100 % 100);
            end
            $display("  Engine (accel) cycles : %0d", engine_cycles);

            $display("");
            $display("================================================================");
            $display(" PER-OPCODE BREAKDOWN   (latency = fetch -> next fetch)");
            $display("================================================================");
            $display("  opcode  name         count   total   min   max   avg   engine");
            $display("  ----------------------------------------------------------------");
            for (i = 0; i < 64; i = i + 1) begin
                if (op_count[i] > 0) begin
                    avg_x100 = (op_cycles[i] * 100) / op_count[i];
                    $display("  %b  %s %5d  %6d  %4d  %4d  %2d.%02d  %6d",
                             i[5:0], opname(i[5:0]), op_count[i], op_cycles[i],
                             op_min[i], op_max[i], avg_x100 / 100, avg_x100 % 100,
                             op_engine[i]);
                end
            end

            $display("");
            $display("================================================================");
            $display(" ACCELERATED INSTRUCTIONS");
            $display("================================================================");
            accel_seen = 1'b0;
            for (i = 0; i < 64; i = i + 1)
                if (op_count[i] > 0 && is_accel_op(i[5:0])) accel_seen = 1'b1;

            if (!accel_seen) begin
                $display("  none executed - this is a software (non-accelerated) run.");
            end else begin
                for (i = 0; i < 64; i = i + 1) begin
                    if (op_count[i] > 0 && is_accel_op(i[5:0])) begin
                        $display("  %s x%0d", opname(i[5:0]), op_count[i]);
                        $display("      full instruction latency : %0d clk  (fetch+decode+calc+writeback)",
                                 op_cycles[i] / op_count[i]);
                        $display("      calculation only         : %0d clk  (cycles in the engine state)",
                                 op_engine[i] / op_count[i]);
                    end
                end
            end

            $display("");
            $display("================================================================");
            $display(" CALC WINDOW   PC 0x%0h .. 0x%0h", CALC_START_PC, CALC_END_PC);
            $display("================================================================");
            if (calc_instrs == 0) begin
                $display("  window never entered - set CALC_START_PC / CALC_END_PC");
                $display("  to the PCs of this program (see the .lst file).");
            end else begin
                $display("  Instructions in window : %0d", calc_instrs);
                $display("  CALC CLOCK CYCLES      : %0d", calc_cycles);
                $display("  (computation only: bootstrap, input load and result");
                $display("   store are outside the window)");
            end

            $display("");
            $display("================================================================");
            $display(" RESULT MEMORY");
            $display("================================================================");
            $display("  [0x4] input  = %h", uut.io_sim.EXTERNAL_RAM.memory_array[4]);
            $display("  [0x5] result = %h", uut.io_sim.EXTERNAL_RAM.memory_array[5]);
            $display("================================================================");
        end
    endtask

    // ---- stimulus ----
    initial begin
        clk_in     = 1'b0;
        rst        = 1'b1;
        pc_step_en = 1'b0;

        total_cycles  = 0;
        total_instrs  = 0;
        instr_cycles  = 0;
        instr_engine  = 0;
        engine_cycles = 0;
        calc_cycles   = 0;
        calc_instrs   = 0;
        in_calc       = 1'b0;
        cur_op        = 6'b0;
        cur_pc        = 32'b0;

        for (i = 0; i < 64; i = i + 1) begin
            op_count[i]  = 0;
            op_cycles[i] = 0;
            op_engine[i] = 0;
            op_min[i]    = 32'h7fffffff;
            op_max[i]    = 0;
        end

        $display("================================================================");
        $display(" DLX-NN CYCLE COUNT   (free-running, pc_step_en held high)");
        $display("================================================================");
        if (TRACE) $display(" instruction trace:");

        @(posedge clk_in);
        #5;
        #200;
        rst        = 1'b0;
        pc_step_en = 1'b1;   // free-run: no idle S_INIT cycles between instrs
    end

endmodule
