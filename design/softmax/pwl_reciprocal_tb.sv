// -----------------------------------------------------------------------------
// pwl_reciprocal_tb.sv — Unit testbench for pwl_reciprocal (paper eq. 2)
//
// Combinational DUT. Vectors computed by py/Softmax/pwl_reciprocal.py.
// Covers all 8 segments plus clamping edge cases.
// Comparison is bit-exact against the Python golden model (same LUT coefficients).
// Note: PWL approximation has inherent error vs true 1/x; what we verify is
//       hardware bit-matches the golden model, not that it equals 1/d exactly.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module pwl_reciprocal_tb;

    `include "pwl_reciprocal_vectors.sv"

    reg  [31:0] d;
    wire [31:0] recip;

    pwl_reciprocal dut (
        .d    (d),
        .recip(recip)
    );

    integer error_count;
    integer test_count;
    reg [31:0] expected;

    task check_result(input [31:0] d_in, input [31:0] exp_out);
    begin
        d        = d_in;
        expected = exp_out;
        #10;
        test_count = test_count + 1;
        if (recip !== expected) begin
            error_count = error_count + 1;
            $display("[FAIL] d=0x%08h  got=0x%08h  exp=0x%08h", d_in, recip, exp_out);
        end else begin
            $display("[PASS] d=0x%08h  recip=0x%08h", d_in, recip);
        end
    end
    endtask

    // ---------------------------------------------------------------
    // full_test
    //   Sweep every input d in [1.0, 256.0] (PWL_RECIP_NUM vectors,
    //   ~1.04 M at default step 2^-12) and bit-exact-compare the DUT
    //   against the golden table loaded from
    //   vectors/pwl_reciprocal_in.mem + vectors/pwl_reciprocal_out.mem.
    //
    //   Only FAILs are printed (a PASS line per vector would generate
    //   ~1 M lines of log).  Progress is reported every 10 % and a
    //   self-contained pass/fail summary is emitted at the end.
    // ---------------------------------------------------------------
    task full_test();
        integer i;
        integer progress_step;
        reg [31:0] d_q;
        reg [31:0] expected_q;
    begin
        $display("===========================================");
        $display("pwl_reciprocal Testbench — full sweep");
        $display("===========================================");

        $display("[full_test] loading vectors from vectors/pwl_reciprocal_in.mem + vectors/pwl_reciprocal_out.mem ...");
        pwl_recip_load_vectors();
        $display("[full_test] %0d vectors loaded — beginning sweep over d in [1.0, 256.0]",
                 PWL_RECIP_NUM);

        progress_step = PWL_RECIP_NUM / 10;
        if (progress_step == 0) progress_step = 1;

        for (i = 0; i < PWL_RECIP_NUM; i = i + 1) begin
            d_q        = pwl_recip_d_at(i);
            expected_q = pwl_recip_expected(d_q);
            d          = d_q;
            #10;
            test_count = test_count + 1;
            if (recip !== expected_q) begin
                error_count = error_count + 1;
                $display("[FAIL] i=%0d d=0x%08h  got=0x%08h  exp=0x%08h",
                         i, d_q, recip, expected_q);
            end
            if (((i + 1) % progress_step) == 0) begin
                $display("[full_test] progress: %0d / %0d  (%0d%%)  errors=%0d",
                         i + 1, PWL_RECIP_NUM,
                         ((i + 1) * 100) / PWL_RECIP_NUM,
                         error_count);
            end
        end

        $display("[full_test] sweep complete — %0d checks, %0d errors",
                 test_count, error_count);

        $display("===========================================");
        $display("Results: %0d/%0d passed", test_count - error_count, test_count);
        if (error_count > 0)
            $display("FAILED with %0d errors", error_count);
        else
            $display("ALL TESTS PASSED");
        $display("===========================================");
    end
    endtask

    initial begin
        if ($test$plusargs("WAVE")) begin
            $dumpfile("pwl_reciprocal_tb");
            $dumpvars(0, pwl_reciprocal_tb);
        end

        error_count = 0;
        test_count  = 0;

        if($test$plusargs("FAST")) begin
        

        $display("===========================================");
        $display("pwl_reciprocal Testbench — all 8 segments");
        $display("===========================================");

        // --- Segment 0: [1, 2) ---
        $display("--- Seg 0: [1, 2) ---");
        check_result(32'h00010000, 32'h0000EE7B); // d=1.000
        check_result(32'h00014000, 32'h0000CFF6); // d=1.250
        check_result(32'h00018000, 32'h0000B172); // d=1.500
        check_result(32'h0001C000, 32'h000092EE); // d=1.750

        // --- Segment 1: [2, 4) ---
        $display("--- Seg 1: [2, 4) ---");
        check_result(32'h00020000, 32'h0000773E); // d=2.000
        check_result(32'h00028000, 32'h000067FC); // d=2.500
        check_result(32'h00030000, 32'h000058BA); // d=3.000
        check_result(32'h00038000, 32'h00004978); // d=3.500

        // --- Segment 2: [4, 8) ---
        $display("--- Seg 2: [4, 8) ---");
        check_result(32'h00040000, 32'h00003B9F); // d=4.000
        check_result(32'h00050000, 32'h000033FE); // d=5.000
        check_result(32'h00060000, 32'h00002C5D); // d=6.000
        check_result(32'h00070000, 32'h000024BC); // d=7.000

        // --- Segment 3: [8, 16) ---
        $display("--- Seg 3: [8, 16) ---");
        check_result(32'h00080000, 32'h00001DD1); // d=8.000
        check_result(32'h000A0000, 32'h00001A01); // d=10.000
        check_result(32'h000C0000, 32'h00001631); // d=12.000
        check_result(32'h000E0000, 32'h00001261); // d=14.000

        // --- Segment 4: [16, 32) ---
        $display("--- Seg 4: [16, 32) ---");
        check_result(32'h00100000, 32'h00000EE8); // d=16.000
        check_result(32'h00140000, 32'h00000D00); // d=20.000
        check_result(32'h00180000, 32'h00000B18); // d=24.000
        check_result(32'h001C0000, 32'h00000930); // d=28.000

        // --- Segment 5: [32, 64) ---
        $display("--- Seg 5: [32, 64) ---");
        check_result(32'h00200000, 32'h00000764); // d=32.000
        check_result(32'h00280000, 32'h0000066C); // d=40.000
        check_result(32'h00300000, 32'h00000574); // d=48.000
        check_result(32'h00380000, 32'h0000047C); // d=56.000

        // --- Segment 6: [64, 128) ---
        $display("--- Seg 6: [64, 128) ---");
        check_result(32'h00400000, 32'h000003A2); // d=64.000
        check_result(32'h00500000, 32'h00000322); // d=80.000
        check_result(32'h00600000, 32'h000002A2); // d=96.000
        check_result(32'h00700000, 32'h00000222); // d=112.000

        // --- Segment 7: [128, 256) ---
        $display("--- Seg 7: [128, 256) ---");
        check_result(32'h00800000, 32'h000001D1); // d=128.000
        check_result(32'h00A00000, 32'h00000191); // d=160.000
        check_result(32'h00C00000, 32'h00000151); // d=192.000
        check_result(32'h00E00000, 32'h00000111); // d=224.000
        check_result(32'h00FF0000, 32'h000000D3); // d=255.000

        // --- Clamp: d < 1 → segment 0 ---
        $display("--- Clamp: d < 1 (seg 0) ---");
        check_result(32'h00008000, 32'h00012B83); // d=0.500
        check_result(32'h0000199A, 32'h00015C56); // d=0.100

        // --- Clamp: d >= 256 → segment 7 ---
        $display("--- Clamp: d >= 256 (seg 7) ---");
        check_result(32'h012C0000, 32'h00000079); // d=300.000

        $display("===========================================");
        $display("Results: %0d/%0d passed", test_count - error_count, test_count);
        if (error_count > 0)
            $display("FAILED with %0d errors", error_count);
        else
            $display("ALL TESTS PASSED");
        $display("===========================================");

        end else begin
            full_test();
        end

        $finish;
    end

endmodule
