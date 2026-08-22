// -----------------------------------------------------------------------------
// Testbench for Sigmoid module (Q16.16 fixed-point)
// Uses include file for test vectors
// Tests EXACT match between DUT output and sigmoid0_q16_16 expected values
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module sigmoid_tb;

    // DUT I/O
    reg  [31:0] x;
    wire [31:0] y;

    // Instantiate DUT
    sigmoid dut (
        .x(x),
        .y(y)
    );

    // Error tracking
    integer error_count;
    integer test_count;
    
    // For calculations
    reg [31:0] expected;




    ////////////////////////////////////////////////////////////////////
    //   Never modify below this line except the included file name   //
    ////////////////////////////////////////////////////////////////////



    // Task to check result - EXACT match required
    // Arguments: x_input, expected_output (all in Q16.16 hex)
    task check_result(input [31:0] x_in, input [31:0] exp_out);
    begin
        x = x_in;
        expected = exp_out;
        #10;
        
        test_count = test_count + 1;
        
        if (y !== expected) begin
            error_count = error_count + 1;
            $display("[%0t ns] :: MISMATCH at x=0x%08h: y=0x%08h, expected=0x%08h", 
                     $time, x_in, y, exp_out);
        end else begin
            $display("[%0t ns] :: PASS at x=0x%08h: y=0x%08h", $time, x_in, y);
        end
    end
    endtask

    // Main test
    initial begin
        if ($test$plusargs("WAVE")) begin
            $dumpfile("sigmoid");        // no extension
            $dumpvars(0, sigmoid_tb); // or sigmoid_tb.dut
        end
        error_count = 0;
        test_count = 0;
        
        $display("===========================================");
        $display("Sigmoid Testbench Starting");
        $display("===========================================");
        
        // Include test vectors file
        `include "sigmoid_vectors.sv"
        `include "sigmoid_neg_vectors.sv"
        
        $display("===========================================");
        $display("Test Complete: %0d/%0d passed", test_count - error_count, test_count);
        if (error_count > 0)
            $display("FAILED with %0d errors", error_count);
        else
            $display("ALL TESTS PASSED");
        $display("===========================================");
        
        $finish;
    end

endmodule
