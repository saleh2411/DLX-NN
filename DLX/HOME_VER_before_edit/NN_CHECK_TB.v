`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// NN_CHECK_TB.v  -  cycle count + result check for the 16x16 digit MLP.
//
// Two jobs, nothing else:
//   1. count the clock cycles the program takes, from its first FETCH until
//      the control FSM reaches S_HALT;
//   2. read the network's output out of SRAM and say PASS or FAIL.
//
// The software and the accelerated build share one memory map, so the same
// run command serves both - only the image changes:
//
//   copy four_layerB_sw_16x16.data sram.data   then simulate  -> software
//   copy four_layerB_hw_16x16.data sram.data   then simulate  -> accelerated
//   diff nn_sw.txt nn_hw.txt        <- must be identical: same numbers, less time
//
// The program comes from sram.data, read by REG_sram.v at time 0 - this
// testbench never loads memory itself, so what runs is exactly what you copied.
//
// The expected digit defaults to 4 (EXPECT_DEFAULT below) and can be overridden
// with +EXPECT=<n> on simulators that pass plusargs. Which build actually ran is
// reported from the engine-cycle count, not from any file name, so a stale copy
// cannot be mistaken for the build you intended.
//
////////////////////////////////////////////////////////////////////////////////

module NN_CHECK_TB;

    // ---- control FSM states (must track dlx_control.v) ----
    localparam [4:0] S_FETCH         = 5'd1;
    localparam [4:0] S_HALT          = 5'd19;
    localparam [4:0] S_SIGMOID       = 5'd21;
    localparam [4:0] S_SOFTMAX_START = 5'd22;
    localparam [4:0] S_RELU          = 5'd23;
    localparam [4:0] S_SOFTMAX_RUN   = 5'd24;
    localparam [4:0] S_MULT          = 5'd25;

    // ---- memory map, from the header of nn/asm-nn/generated/*_16x16.s ----
    localparam integer A_A1   = 4542;   // 16 words, hidden activations (tanh)
    localparam integer A_Z2   = 4558;   // 10 words, output logits
    localparam integer A_PROB = 4568;   // 10 words, softmax probabilities
    localparam integer A_PRED = 4578;   //  1 word,  predicted digit

    localparam integer MAX_CYCLES = 20000000;

    // ---- WHICH PROGRAM RUNS ---------------------------------------------
    // The program is whatever REG_sram.v reads at time 0, i.e. sram.data.
    // To switch builds, copy the image over it:
    //   copy four_layerB_hw_16x16.data  sram.data     (accelerated)
    //   copy four_layerB_sw_16x16.data  sram.data     (software)
    // The build actually executed is reported below from the engine cycles,
    // which cannot be faked by a stale file copy.
    localparam EXPECT_DEFAULT = 4;
    // ---------------------------------------------------------------------

    // ---- DUT ----
    reg  clk_in, rst, pc_step_en;
    wire busy;
    wire [4:0] control_state;

    IO uut (.clk_in(clk_in), .rst(rst), .pc_step_en(pc_step_en),
            .busy(busy), .control_state(control_state));

    // the MLP reaches word 4578; the stock model is 1024 words. Simulation
    // only - no RTL file is modified, so synthesis is unaffected.
    defparam uut.io_sim.ADDR_WIDTH = 13;

    always #50 clk_in = ~clk_in;

    // ---- run-time options ----
    reg [8*128:1] out_file;
    integer       expect_pred;
    reg           have_out;

    // ---- counters ----
    integer cycles, engine_cycles, instrs;
    reg     counting, halted;
    reg [4:0] prev_state;

    // ---- checking ----
    integer i, best, fd, fails;
    reg [31:0] v, bestv, pred;

    function engine_state;
        input [4:0] s;
        begin
            engine_state = (s == S_SIGMOID) || (s == S_RELU) || (s == S_MULT) ||
                           (s == S_SOFTMAX_START) || (s == S_SOFTMAX_RUN);
        end
    endfunction

    // Q16.16 -> "-1.2345", as two integers so no real arithmetic is needed
    reg [31:0] mag;
    integer    ip, fp;
    task q16;
        input [31:0] w;
        begin
            mag = w[31] ? (~w + 1'b1) : w;
            ip  = mag >> 16;
            fp  = ((mag & 32'h0000FFFF) * 10000) >> 16;
        end
    endtask

    // ---- counting: one instruction boundary is a FETCH that follows non-FETCH
    always @(posedge clk_in) begin
        if (rst) begin
            prev_state = S_FETCH;
            halted     = 1'b0;
        end else if (!halted) begin
            if (control_state == S_HALT) begin
                halted = 1'b1;
                check_results;
                $finish;
            end else begin
                if (control_state == S_FETCH && prev_state != S_FETCH) begin
                    counting = 1'b1;
                    instrs   = instrs + 1;
                end
                if (counting || (control_state == S_FETCH)) begin
                    cycles = cycles + 1;
                    if (engine_state(control_state))
                        engine_cycles = engine_cycles + 1;
                end
                if (cycles > MAX_CYCLES) begin
                    $display("");
                    $display("FAIL: %0d cycles without reaching HALT.", cycles);
                    halted = 1'b1;
                    $finish;
                end
            end
            prev_state = control_state;
        end
    end

    // ---- the report ----
    task check_results;
        begin
            fails = 0;
            pred  = uut.io_sim.EXTERNAL_RAM.memory_array[A_PRED];

            $display("");
            $display("================================================================");
            $display(" CYCLE COUNT");
            $display("================================================================");
            $display("  program image         : sram.data (read by REG_sram)");
            $display("  instructions retired  : %0d", instrs);
            $display("  TOTAL CLOCK CYCLES    : %0d", cycles);
            $display("  of which in the engine: %0d", engine_cycles);
            if (engine_cycles == 0)
                $display("  BUILD EXECUTED        : SOFTWARE  (no activation opcode ran)");
            else
                $display("  BUILD EXECUTED        : ACCELERATED  (%0d engine cycles)",
                         engine_cycles);

            $display("");
            $display("================================================================");
            $display(" RESULT");
            $display("================================================================");
            $display("  output logits Z2 (Q16.16):");
            best = -1; bestv = 32'h80000000;
            for (i = 0; i < 10; i = i + 1) begin
                v = uut.io_sim.EXTERNAL_RAM.memory_array[A_Z2 + i];
                q16(v);
                $display("    digit %0d  0x%08h  %0s%0d.%0d%0d%0d%0d",
                         i, v, v[31] ? "-" : " ", ip,
                         (fp/1000)%10, (fp/100)%10, (fp/10)%10, fp%10);
                if ((^v !== 1'bx) && ($signed(v) >= $signed(bestv))) begin
                    bestv = v; best = i;
                end
            end
            $display("    argmax(Z2) = %0d", best);

            $display("");
            $display("  predicted digit  : %0d   [word %0d]", pred, A_PRED);
            $display("  expected         : %0d", expect_pred);

            // check 1 - the network answered what the golden model answers
            if (pred !== expect_pred[31:0]) begin
                $display("  --> FAIL: predicted %0d, expected %0d", pred, expect_pred);
                fails = fails + 1;
            end else
                $display("  --> ok: prediction matches");

            // check 2 - PRED really is the argmax of the logits it was derived
            //           from, so a stale or half-written PRED cannot pass
            if (best !== pred) begin
                $display("  --> FAIL: PRED=%0d but argmax(Z2)=%0d (inconsistent)",
                         pred, best);
                fails = fails + 1;
            end else
                $display("  --> ok: prediction is the argmax of Z2");

            // check 3 - the hidden layer actually ran
            best = 0;                       // reused: count of non-zero A1 words
            for (i = 0; i < 16; i = i + 1) begin
                v = uut.io_sim.EXTERNAL_RAM.memory_array[A_A1 + i];
                if ((^v !== 1'bx) && (v !== 32'h0)) best = best + 1;
            end
            if (best == 0) begin
                $display("  --> FAIL: hidden activations all zero - layer 1 never ran");
                fails = fails + 1;
            end else
                $display("  --> ok: hidden layer written (%0d/16 non-zero)", best);

            $display("");
            if (fails == 0)
                $display("  ***  PASS  ***   %0d cycles", cycles);
            else
                $display("  ***  FAIL  ***   %0d check(s) failed", fails);
            $display("================================================================");

            // machine-readable dump, so the two builds can simply be diffed
            if (have_out) begin
                fd = $fopen(out_file, "w");
                $fdisplay(fd, "PRED %0d", pred);
                for (i = 0; i < 10; i = i + 1)
                    $fdisplay(fd, "Z2[%0d] %08h", i,
                              uut.io_sim.EXTERNAL_RAM.memory_array[A_Z2 + i]);
                for (i = 0; i < 10; i = i + 1)
                    $fdisplay(fd, "PROB[%0d] %08h", i,
                              uut.io_sim.EXTERNAL_RAM.memory_array[A_PROB + i]);
                for (i = 0; i < 16; i = i + 1)
                    $fdisplay(fd, "A1[%0d] %08h", i,
                              uut.io_sim.EXTERNAL_RAM.memory_array[A_A1 + i]);
                $fclose(fd);
                $display("  result words written to %0s", out_file);
            end
        end
    endtask

    // ---- stimulus ----
    initial begin
        clk_in = 1'b0; rst = 1'b1; pc_step_en = 1'b0;
        cycles = 0; engine_cycles = 0; instrs = 0;
        counting = 1'b0; halted = 1'b0; prev_state = S_FETCH;

        if (!$value$plusargs("EXPECT=%d", expect_pred))
            expect_pred = EXPECT_DEFAULT;
        have_out = $value$plusargs("OUT=%s", out_file);

        $display("================================================================");
        $display(" NN_CHECK_TB   cycle count + result check");
        $display("================================================================");

        @(posedge clk_in);
        #205;
        rst        = 1'b0;
        pc_step_en = 1'b1;      // free-run: no idle S_INIT cycles between instrs
    end

endmodule
