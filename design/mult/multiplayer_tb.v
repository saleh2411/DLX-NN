`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// multiplayer_tb — self-checking TB for the Q16.16 signed multiplier
//
//   expected C = bits [47:16] of the exact 64-bit signed product A*B
//
// Drives the same en/ready handshake control uses in S_MULT: hold en high,
// wait for ready, sample C, then drop en so the counter clears before the
// next operand pair. Latency to ready is checked (2 clocks after en).
//
// Run:  ivsim -o mult_tb multiplayer_tb.v multiplayer.v
// -----------------------------------------------------------------------------
module multiplayer_tb;

    reg         clk;
    reg         en;
    reg  [31:0] A, B;
    wire [31:0] C;
    wire        ready;

    integer n_tests, n_errors;
    integer i;

    multiplier dut (
        .clk   (clk),
        .en    (en),
        .A     (A),
        .B     (B),
        .C     (C),
        .ready (ready)
    );

    // 100 MHz clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Q16.16 range bounds of the activation functions (see py/ golden models)
    localparam signed [31:0] Q_ONE      = 32'h0001_0000; //  1.0  tanh/sigmoid/softmax max
    localparam signed [31:0] Q_MONE     = 32'hFFFF_0000; // -1.0  tanh min
    localparam signed [31:0] Q_1P5      = 32'h0001_8000; //  1.5  shift_exp max (paper eq. 1)
    localparam signed [31:0] Q_FIVE     = 32'h0005_0000; //  5.0  GELU sweep bound
    localparam signed [31:0] Q_MFIVE    = 32'hFFFB_0000; // -5.0
    localparam signed [31:0] Q_TEN      = 32'h000A_0000; // 10.0  sigmoid/tanh sweep bound
    localparam signed [31:0] Q_MTEN     = 32'hFFF6_0000; // -10.0

    // random Q16.16 value uniform in [lo, hi]
    function [31:0] rand_q;
        input signed [31:0] lo, hi;
        reg [31:0] span, r;
        begin
            span   = hi - lo + 1;
            r      = $random;
            rand_q = lo + (r % span);
        end
    endfunction

    // golden model: exact 64-bit signed product, Q16.16 slice [47:16]
    function [31:0] golden;
        input [31:0] a, b;
        reg signed [63:0] p;
        begin
            p = $signed(a) * $signed(b);
            golden = p[47:16];
        end
    endfunction

    // Q16.16 word as a real number, for readable logs
    function real q16r;
        input [31:0] x;
        begin
            q16r = $itor($signed(x)) / 65536.0;
        end
    endfunction

    // one handshake: drive operands, raise en, wait for ready, compare C
    task check_result;
        input [31:0] a, b;
        reg [31:0] exp;
        integer lat;
        begin
            @(negedge clk);
            A  = a;
            B  = b;
            en = 1'b1;
            lat = 0;
            while (!ready && lat < 10) begin
                @(negedge clk);
                lat = lat + 1;
            end
            n_tests = n_tests + 1;
            exp = golden(a, b);
            if (!ready) begin
                n_errors = n_errors + 1;
                $display("FAIL: ready never rose for A=%h B=%h", a, b);
            end
            else if (lat != 2) begin
                n_errors = n_errors + 1;
                $display("FAIL: ready after %0d cycles (expected 2) A=%h B=%h",
                         lat, a, b);
            end
            else if (C !== exp) begin
                n_errors = n_errors + 1;
                $display("FAIL: %f * %f  A=%h B=%h  C=%h expected=%h",
                         q16r(a), q16r(b), a, b, C, exp);
            end
            else begin
                $display("PASS: %f * %f = %f  (C=%h)",
                         q16r(a), q16r(b), q16r(C), C);
            end
            en = 1'b0;
            @(negedge clk);
            if (ready !== 1'b0) begin
                n_errors = n_errors + 1;
                $display("FAIL: ready stuck high after en dropped");
            end
        end
    endtask

    initial begin
        $dumpfile("multiplayer_tb.vcd");
        $dumpvars(0, multiplayer_tb);

        en = 1'b0;
        A  = 32'h0;
        B  = 32'h0;
        n_tests  = 0;
        n_errors = 0;
        repeat (3) @(negedge clk);

        // ---- directed tests -------------------------------------------------
        check_result(32'h0000_0000, 32'h0000_0000);  //  0.0  *  0.0
        check_result(32'h0001_0000, 32'h0001_0000);  //  1.0  *  1.0  =  1.0
        check_result(32'h0001_0000, 32'hFFFF_0000);  //  1.0  * -1.0  = -1.0
        check_result(32'hFFFF_0000, 32'hFFFF_0000);  // -1.0  * -1.0  =  1.0
        check_result(32'h0000_8000, 32'h0000_8000);  //  0.5  *  0.5  =  0.25
        check_result(32'hFFFE_8000, 32'h0002_0000);  // -1.5  *  2.0  = -3.0
        check_result(32'h0003_0000, 32'h0002_8000);  //  3.0  *  2.5  =  7.5
        check_result(32'h0000_0001, 32'h0000_0001);  //  2^-16 * 2^-16 -> 0 (underflow)
        check_result(32'hFFFF_FFFF, 32'h0000_0001);  // -2^-16 * 2^-16 (floor trunc)
        check_result(32'h7FFF_FFFF, 32'h0001_0000);  //  max  *  1.0  =  max
        check_result(32'h8000_0000, 32'h0001_0000);  //  min  *  1.0  =  min
        check_result(32'h7FFF_FFFF, 32'h7FFF_FFFF);  //  max  *  max  (wrap in slice)
        check_result(32'h8000_0000, 32'h8000_0000);  //  min  *  min  (wrap in slice)
        check_result(32'h0064_0000, 32'h0000_028F);  //  100  *  ~0.01
        check_result(32'h0003_243F, 32'h0003_243F);  //  pi   *  pi

        // ---- activation-range random tests ----------------------------------
        $display("--- tanh out x tanh out: [-1,1] x [-1,1]");
        for (i = 0; i < 10; i = i + 1)
            check_result(rand_q(Q_MONE, Q_ONE), rand_q(Q_MONE, Q_ONE));

        $display("--- sigmoid/softmax out x activation input: [0,1] x [-10,10]");
        for (i = 0; i < 10; i = i + 1)
            check_result(rand_q(32'h0, Q_ONE), rand_q(Q_MTEN, Q_TEN));

        $display("--- softmax pass 2: shift_exp (0,1.5] x pwl_reciprocal (0,1]");
        for (i = 0; i < 10; i = i + 1)
            check_result(rand_q(32'h1, Q_1P5), rand_q(32'h1, Q_ONE));

        $display("--- GELU sweep inputs: [-5,5] x [-5,5]");
        for (i = 0; i < 10; i = i + 1)
            check_result(rand_q(Q_MFIVE, Q_FIVE), rand_q(Q_MFIVE, Q_FIVE));

        // ---- full-range random tests ----------------------------------------
        $display("--- full-range random (overflow wraps in slice)");
        for (i = 0; i < 20; i = i + 1)
            check_result($random, $random);

        // ---- summary --------------------------------------------------------
        if (n_errors == 0)
            $display("ALL %0d TESTS PASSED", n_tests);
        else
            $display("%0d / %0d TESTS FAILED", n_errors, n_tests);
        $finish;
    end

endmodule
