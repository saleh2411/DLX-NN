// -----------------------------------------------------------------------------
// shift_exp_tb.sv — Unit testbench for shift_exp (paper eq. 1)
//
// Combinational DUT. Vectors computed by py/Softmax/shift_exp.py.
// Range: x ∈ [-10, 0], step 0.5. All arithmetic Q16.16 signed.
// Expected: bit-exact match against Python golden model.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module shift_exp_tb;

    `include "shift_exp_vectors.sv"

    reg  signed [31:0] x;
    wire        [31:0] out;

    shift_exp dut (
        .x  (x),
        .out(out)
    );

    integer error_count;
    integer test_count;
    reg [31:0] expected;

    task check_result(input [31:0] x_in, input [31:0] exp_out);
    begin
        x        = x_in;
        expected = exp_out;
        #10;
        test_count = test_count + 1;
        if (out !== expected) begin
            error_count = error_count + 1;
            $display("[FAIL] x=0x%08h  got=0x%08h  exp=0x%08h", x_in, out, exp_out);
        end else begin
            $display("[PASS] x=0x%08h  out=0x%08h", x_in, out);
        end
    end
    endtask

    // ---------------------------------------------------------------
    // full_test
    //   Sweep every Q16.16 input in [-10, 0] (655 361 vectors) and
    //   bit-exact-compare the DUT against the golden table loaded from
    //   vectors/shift_exp_in.mem + vectors/shift_exp_out.mem.
    //
    //   Only FAILs are printed (a PASS line per vector would generate
    //   ~655 k lines of log).  Progress is reported every 10 % and a
    //   pass/fail tally is emitted at the end.
    // ---------------------------------------------------------------
    task full_test();
        integer i;
        integer progress_step;
        reg [31:0] x_q;
        reg [31:0] expected_q;
    begin
        $display("[full_test] loading vectors from vectors/shift_exp_in.mem + vectors/shift_exp_out.mem ...");
        shift_exp_load_vectors();
        $display("[full_test] %0d vectors loaded — beginning sweep over x in [-10.0, 0.0] @ step 2^-16",
                 SHIFT_EXP_NUM);

        progress_step = SHIFT_EXP_NUM / 10;
        if (progress_step == 0) progress_step = 1;

        for (i = 0; i < SHIFT_EXP_NUM; i = i + 1) begin
            x_q        = shift_exp_x_at(i);
            expected_q = shift_exp_expected(x_q);
            x          = x_q;
            #10;
            test_count = test_count + 1;
            if (out !== expected_q) begin
                error_count = error_count + 1;
                $display("[FAIL] i=%0d x=0x%08h  got=0x%08h  exp=0x%08h",
                         i, x_q, out, expected_q);
            end
            if (((i + 1) % progress_step) == 0) begin
                $display("[full_test] progress: %0d / %0d  (%0d%%)  errors=%0d",
                         i + 1, SHIFT_EXP_NUM,
                         ((i + 1) * 100) / SHIFT_EXP_NUM,
                         error_count);
            end
        end

        $display("[full_test] sweep complete — %0d checks, %0d errors",
                 test_count, error_count);
    end
    endtask

    initial begin
        if ($test$plusargs("WAVE")) begin
            $dumpfile("shift_exp_tb");
            $dumpvars(0, shift_exp_tb);
        end

        error_count = 0;
        test_count  = 0;

        $display("===========================================");
        $display("shift_exp Testbench — x in [-10, 0]");
        $display("===========================================");

        if($test$plusargs("FAST")) begin

        // x = -10.0 to 0.0, step 0.5  (Python golden)
        check_result(32'hFFF60000, 32'h00000002); // x=-10.00  y=0.000031
        check_result(32'hFFF68000, 32'h00000002); // x=-9.50   y=0.000031
        check_result(32'hFFF70000, 32'h00000005); // x=-9.00   y=0.000076
        check_result(32'hFFF78000, 32'h00000009); // x=-8.50   y=0.000137
        check_result(32'hFFF80000, 32'h00000010); // x=-8.00   y=0.000244
        check_result(32'hFFF88000, 32'h00000016); // x=-7.50   y=0.000336
        check_result(32'hFFF90000, 32'h00000028); // x=-7.00   y=0.000610
        check_result(32'hFFF98000, 32'h00000048); // x=-6.50   y=0.001099
        check_result(32'hFFFA0000, 32'h00000080); // x=-6.00   y=0.001953
        check_result(32'hFFFA8000, 32'h000000B0); // x=-5.50   y=0.002686
        check_result(32'hFFFB0000, 32'h00000140); // x=-5.00   y=0.004883
        check_result(32'hFFFB8000, 32'h00000240); // x=-4.50   y=0.008789
        check_result(32'hFFFC0000, 32'h00000400); // x=-4.00   y=0.015625
        check_result(32'hFFFC8000, 32'h00000580); // x=-3.50   y=0.021484
        check_result(32'hFFFD0000, 32'h00000A00); // x=-3.00   y=0.039062
        check_result(32'hFFFD8000, 32'h00001200); // x=-2.50   y=0.070312
        check_result(32'hFFFE0000, 32'h00002000); // x=-2.00   y=0.125000
        check_result(32'hFFFE8000, 32'h00002C00); // x=-1.50   y=0.171875
        check_result(32'hFFFF0000, 32'h00005000); // x=-1.00   y=0.312500
        check_result(32'hFFFF8000, 32'h00009000); // x=-0.50   y=0.562500
        check_result(32'h00000000, 32'h00010000); // x= 0.00   y=1.000000

        // Underflow guard: |v_int| > 31 → result must be 0
        // x=-22 → v = -33 → abs_v_int = 33 > 31
        check_result(32'hFFEA0000, 32'h00000000); // x=-22.00  underflow→0

        end else begin
            full_test();
        end

        $display("===========================================");
        $display("Results: %0d/%0d passed", test_count - error_count, test_count);
        if (error_count > 0)
            $display("FAILED with %0d errors", error_count);
        else
            $display("ALL TESTS PASSED");
        $display("===========================================");

        $finish;
    end

endmodule
