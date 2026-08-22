`timescale 1ns / 1ps

// Self-checking testbench for the software Q16.16 tanh program in sram.data.
//
// Word-addressable SRAM layout used by asm/tanh.s:
//   memory_array[4] = input  (0x00018000 = 1.5 in Q16.16)
//   memory_array[5] = result (expected 0x0000E000 = 0.875)
module IO_TANH_TB;

    reg clk_in;
    reg rst;
    reg pc_step_en;

    wire busy;
    wire [4:0] control_state;

    integer instruction_count;

    // Unneeded IO outputs are intentionally left unconnected.
    IO uut (
        .clk_in(clk_in),
        .rst(rst),
        .pc_step_en(pc_step_en),
        .busy(busy),
        .control_state(control_state)
    );

    always #50 clk_in = ~clk_in;

    initial begin
        clk_in = 1'b0;
        rst = 1'b1;
        pc_step_en = 1'b0;
        instruction_count = 0;

        // Match the reset and instruction-step timing used by IO_TB.v.
        @(posedge clk_in);
        #5;
        #200;
        rst = 1'b0;
        #3000;

        // S_HALT is control state 19 (5'b10011). Limit the loop so a broken
        // program cannot make the simulation run forever.
        while ((control_state !== 5'd19) &&
               (instruction_count < 100)) begin
            #500;
            pc_step_en = 1'b1;
            #100;
            pc_step_en = 1'b0;
            #3000;
            instruction_count = instruction_count + 1;
        end

        #100;
        $display("--------------------------------------------------");
        $display("Instructions stepped = %0d", instruction_count);
        $display("Final control state  = %b", control_state);
        $display("Input  [word 4]      = %h",
                 uut.io_sim.EXTERNAL_RAM.memory_array[4]);
        $display("Result [word 5]      = %h",
                 uut.io_sim.EXTERNAL_RAM.memory_array[5]);
        $display("Expected result      = 0000e000");

        if (control_state !== 5'd19) begin
            $display("TANH FAIL: processor did not reach HALT");
        end else if (uut.io_sim.EXTERNAL_RAM.memory_array[4]
                     !== 32'h00018000) begin
            $display("TANH FAIL: input word is not 1.5 in Q16.16");
        end else if (uut.io_sim.EXTERNAL_RAM.memory_array[5]
                     === 32'h0000E000) begin
            $display("TANH PASS: result is 0.875 in Q16.16");
        end else begin
            $display("TANH FAIL: wrong result");
        end

        $display("--------------------------------------------------");
        $finish;
    end

endmodule
