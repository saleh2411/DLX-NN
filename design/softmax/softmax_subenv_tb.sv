// softmax_subenv_tb — class-based testbench for softmax_subenv
//
// Architecture (UVM-flavoured, no UVM dependency):
//
//   agent (base, $unit-scope)
//     |-- softmax_driver   — signs up softmax_msg into the queue
//     +-- softmax_checker  — drives DUT, bit-exact verifies, removes signups
//
// All test vectors are Python-generated golden vectors loaded from
// softmax_vectors.sv; the checker performs strict bit-exact comparison
// against MSG_Y_EXP.  There is no random-stimulus path.
//
// iverilog 13 limitations:
//   1. softmax_msg holds only SCALAR fields; the vector payload lives
//      in module-scope MSG_X_IN / MSG_Y_EXP indexed by test_idx
//      (iverilog rejects array indexing on class properties).
//   2. The signup queue and the coverage object live at module scope,
//      exposed via tasks (iverilog disallows methods on class fields).

`timescale 1ns/1ps

// softmax_msg — test transaction METADATA only.  Vector payload lives
// in MSG_X_IN / MSG_Y_EXP in the tb module, indexed by test_idx.
class softmax_msg;
    int    test_idx;
    int    vector_size;
    string test_name;

    function new(int idx, int sz, string name);
        test_idx    = idx;
        vector_size = sz;
        test_name   = name;
    endfunction
endclass

`include "agent.sv"
`include "softmax_coverage.sv"

module softmax_subenv_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------
    localparam        CLK_PERIOD = 10;     // ns
    localparam        MEM_LAT    = 2;      // SRAM busy cycles per transaction
    localparam        SRAM_WORDS = 2048;
    localparam [31:0] IN_BASE    = 32'h0000_0000;
    localparam [31:0] OUT_BASE   = 32'h0000_0400; // word address 1024
    localparam        TIMEOUT    = 50000;  // max cycles per test (N up to 500)
    localparam int    QUEUE_CAP  = 2048;   // max signups in flight

    `include "softmax_vectors.sv"
    // MAX_MSG_N is bound to SOFTMAX_MAX_N (defined in the include above)
    // so storage and coverage automatically track the Python-generated set.
    localparam int    MAX_MSG_N  = SOFTMAX_MAX_N;

    // ------------------------------------------------------------
    // DUT ports + SRAM model
    // ------------------------------------------------------------
    reg         clk = 0, rst = 1, start = 0;
    reg  [31:0] base_addr = 0, out_addr = 0;
    reg  [10:0] vec_len   = 0;

    wire [31:0] mem_addr, mem_data_out;
    wire        mem_rd, mem_wr;
    wire        done, active;
    wire [31:0] dbg_max, dbg_denom;
    wire [10:0] dbg_idx;
    wire [31:0] mem_data_in;
    wire        mem_busy;

    softmax_subenv dut (
        .clk         (clk),
        .rst         (rst),
        .start       (start),
        .base_addr   (base_addr),
        .out_addr    (out_addr),
        .vec_len     (vec_len),
        .mem_addr    (mem_addr),
        .mem_data_out(mem_data_out),
        .mem_data_in (mem_data_in),
        .mem_rd      (mem_rd),
        .mem_wr      (mem_wr),
        .mem_busy    (mem_busy),
        .done        (done),
        .active      (active),
        .dbg_max     (dbg_max),
        .dbg_denom   (dbg_denom),
        .dbg_idx     (dbg_idx)
    );

    // ----- SRAM model -----
    reg [31:0] sram [0:SRAM_WORDS-1];

    reg        busy_r   = 0;
    reg [1:0]  lat_cnt  = 0;
    reg        is_wr    = 0;
    reg        mem_rd_q = 0, mem_wr_q = 0;

    assign mem_busy    = busy_r;
    assign mem_data_in = sram[mem_addr[10:0]];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            busy_r   <= 0; lat_cnt  <= 0;
            is_wr    <= 0; mem_rd_q <= 0; mem_wr_q <= 0;
        end else begin
            mem_rd_q <= mem_rd;
            mem_wr_q <= mem_wr;
            if (!busy_r) begin
                if (mem_rd && !mem_rd_q) begin
                    busy_r <= 1; lat_cnt <= MEM_LAT - 1; is_wr <= 0;
                end else if (mem_wr && !mem_wr_q) begin
                    busy_r <= 1; lat_cnt <= MEM_LAT - 1; is_wr <= 1;
                end
            end else begin
                if (lat_cnt == 0) begin
                    busy_r <= 0;
                    if (is_wr) sram[mem_addr[10:0]] <= mem_data_out;
                end else
                    lat_cnt <= lat_cnt - 1;
            end
        end
    end

    // Clock
    always #(CLK_PERIOD/2) clk = ~clk;

    // ------------------------------------------------------------
    // Module-level message payload storage (indexed by test_idx).
    // ------------------------------------------------------------
    reg [31:0] MSG_X_IN  [0:QUEUE_CAP-1][0:MAX_MSG_N-1];
    reg [31:0] MSG_Y_EXP [0:QUEUE_CAP-1][0:MAX_MSG_N-1];

    // ------------------------------------------------------------
    // Module-level signup queue (FIFO of softmax_msg handles).
    // ------------------------------------------------------------
    softmax_msg signup_arr [0:QUEUE_CAP-1];
    int         signup_head = 0;
    int         signup_tail = 0;

    task automatic signup_put(input softmax_msg m);
        signup_arr[signup_tail] = m;
        signup_tail = signup_tail + 1;
    endtask

    function automatic softmax_msg signup_get();
        softmax_msg m;
        m = signup_arr[signup_head];
        signup_head = signup_head + 1;
        return m;
    endfunction

    function automatic int signup_num();
        return signup_tail - signup_head;
    endfunction

    // ------------------------------------------------------------
    // Coverage manual hit counters (module scope due to iverilog 13
    // restriction on unpacked arrays inside class properties).
    // ------------------------------------------------------------
    int cov_hits_size [0:MAX_MSG_N];
    int cov_hits_equal          = 0;
    int cov_hits_allpos         = 0;
    int cov_hits_allneg         = 0;
    int cov_hits_mixed          = 0;
    int cov_hits_extreme_spread = 0;
    int cov_hits_close_values   = 0;
    int cov_total_samples       = 0;

    // Spec value_bin_distribution — vectors with >=1 element in each bin.
    int cov_hits_bin_neg_extreme = 0;   // any element in [-max, -201]
    int cov_hits_bin_neg_high    = 0;   // any element in [-200, -11]
    int cov_hits_bin_neg_low     = 0;   // any element in [-10, 0]
    int cov_hits_bin_pos_low     = 0;   // any element in [0, 10]
    int cov_hits_bin_pos_high    = 0;   // any element in [11, 200]
    int cov_hits_bin_pos_extreme = 0;   // any element in [201, +max]

    // Spec value_bin_distribution — total elements that fell into each bin
    // (histogram across all sampled vectors; gives the global distribution).
    int cov_elems_bin_neg_extreme = 0;
    int cov_elems_bin_neg_high    = 0;
    int cov_elems_bin_neg_low     = 0;
    int cov_elems_bin_pos_low     = 0;
    int cov_elems_bin_pos_high    = 0;
    int cov_elems_bin_pos_extreme = 0;

    // Spec value_dispersion — binary classification via spread proxy
    // (spread = max - min; threshold = 10.0 in Q16.16).
    int cov_hits_low_variance    = 0;
    int cov_hits_high_variance   = 0;

    softmax_coverage cov = new();

    task automatic cov_sample(input softmax_msg msg);
        cov.sample_msg(msg);
    endtask

    task automatic cov_report();
        cov.report();
    endtask

    // ------------------------------------------------------------
    // softmax_driver — enqueues golden messages
    // ------------------------------------------------------------
    class softmax_driver extends agent;

        int tests_signed_up;

        function new();
            tests_signed_up = 0;
        endfunction

        virtual task notify(softmax_msg msg);
            string vec_s;
            int    sval;
            vec_s = "[";
            for (int i = 0; i < msg.vector_size; i++) begin
                sval  = $signed(MSG_X_IN[msg.test_idx][i]);
                vec_s = {vec_s, $sformatf("%s%s%7.4f",
                                          (i == 0) ? "" : ", ",
                                          (sval >= 0) ? "+" : "-",
                                          (sval <  0) ? -real'(sval) / 65536.0
                                                      :  real'(sval) / 65536.0)};
            end
            vec_s = {vec_s, "]"};
            $display("[DRIVER]  signed up tc=%3d  N=%2d  '%s'",
                     msg.test_idx, msg.vector_size, msg.test_name);
            $display("[DRIVER]            x = %s", vec_s);
        endtask

        task run_golden();
            softmax_msg m;
            softmax_init_meta();
            for (int i = 0; i < SOFTMAX_NUM_TESTS; i++) begin
                softmax_load_test(i);
                m = new(tests_signed_up, SOFTMAX_N, softmax_test_name(i));
                for (int j = 0; j < SOFTMAX_N; j++) begin
                    MSG_X_IN [tests_signed_up][j] = SOFTMAX_X    [j];
                    MSG_Y_EXP[tests_signed_up][j] = SOFTMAX_Y_EXP[j];
                end
                signup_put(m);
                notify(m);
                tests_signed_up = tests_signed_up + 1;
            end
        endtask

    endclass

    // ------------------------------------------------------------
    // softmax_checker — drives DUT, bit-exact verifies, removes
    // ------------------------------------------------------------
    class softmax_checker extends agent;

        int pass_count;
        int fail_count;

        function new();
            pass_count = 0;
            fail_count = 0;
        endfunction

        virtual task notify(softmax_msg msg);
            $display("[CHECKER] removed   tc=%3d  '%s'  (queue=%0d left)",
                     msg.test_idx, msg.test_name, signup_num());
        endtask

        task run();
            softmax_msg msg;
            while (signup_num() > 0) begin
                msg = signup_get();
                cov_sample(msg);
                verify(msg);
                notify(msg);
            end
            report_summary();
        endtask

        task verify(softmax_msg msg);
            int          n;
            int          cyc;
            reg  [31:0]  got;
            reg  [31:0]  expv;
            int          errors;
            int          idx;
            int          sval;
            string       vec_s;

            n   = msg.vector_size;
            idx = msg.test_idx;

            // Pre-run echo: show which vector the DUT is about to consume.
            vec_s = "[";
            for (int i = 0; i < n; i++) begin
                sval  = $signed(MSG_X_IN[idx][i]);
                vec_s = {vec_s, $sformatf("%s%s%7.4f",
                                          (i == 0) ? "" : ", ",
                                          (sval >= 0) ? "+" : "-",
                                          (sval <  0) ? -real'(sval) / 65536.0
                                                      :  real'(sval) / 65536.0)};
            end
            vec_s = {vec_s, "]"};
            $display("[CHECKER] running  tc=%3d  N=%2d  '%s'",
                     msg.test_idx, msg.vector_size, msg.test_name);
            $display("[CHECKER]           x = %s", vec_s);

            // 1. Stage input vector into SRAM at IN_BASE
            for (int i = 0; i < n; i++)
                sram[IN_BASE + i] = MSG_X_IN[idx][i];

            // 2. Pulse start
            @(negedge clk);
            base_addr = IN_BASE;
            out_addr  = OUT_BASE;
            vec_len   = n[10:0];
            start     = 1;
            @(negedge clk);
            start = 0;

            // 3. Wait for done (1-cycle pulse from dma_done)
            cyc = 0;
            while (!done && cyc < TIMEOUT) begin
                @(posedge clk);
                cyc = cyc + 1;
            end

            if (cyc >= TIMEOUT) begin
                $display("[CHECKER] tc=%0d TIMEOUT after %0d cycles",
                         msg.test_idx, cyc);
                fail_count = fail_count + 1;
                return;
            end

            // 4. Bit-exact compare against Python golden
            errors = 0;
            for (int i = 0; i < n; i++) begin
                got  = sram[OUT_BASE + i];
                expv = MSG_Y_EXP[idx][i];
                if (got !== expv) begin
                    $display("[CHECKER] tc=%0d MISMATCH y[%0d] got=%08h exp=%08h",
                             msg.test_idx, i, got, expv);
                    errors = errors + 1;
                end
            end

            if (errors == 0) begin
                $display("[CHECKER] tc=%0d PASS  (cycles=%0d)",
                         msg.test_idx, cyc);
                pass_count = pass_count + 1;
            end else begin
                $display("[CHECKER] tc=%0d FAIL  (%0d errors)",
                         msg.test_idx, errors);
                fail_count = fail_count + 1;
            end
        endtask

        task report_summary();
            $display("============================================================");
            $display("Results: %0d/%0d passed",
                     pass_count, pass_count + fail_count);
            cov_report();
            if (fail_count)
                $display("FAILED with %0d errors", fail_count);
            else
                $display("ALL TESTS PASSED");
            $display("============================================================");
        endtask

    endclass

    // ------------------------------------------------------------
    // Test orchestration
    // ------------------------------------------------------------
    softmax_driver  drv;
    softmax_checker chk;

    initial begin
        if ($test$plusargs("WAVE")) begin
            $dumpfile("softmax_subenv_tb");
            $dumpvars(0, softmax_subenv_tb);
        end

        for (int j = 0; j < SRAM_WORDS; j++) sram[j] = 32'hDEAD_BEEF;
        for (int j = 0; j <= MAX_MSG_N; j++) cov_hits_size[j] = 0;

        repeat(4) @(posedge clk);
        @(negedge clk); rst = 0;

        $display("============================================================");
        $display("softmax_subenv_tb - agent / driver / checker testbench");
        $display("  golden tests : %0d  (Python-generated, bit-exact)",
                 SOFTMAX_NUM_TESTS);
        $display("============================================================");

        drv = new();
        chk = new();
        drv.run_golden();

        $display("[TB] %0d messages signed up; checker draining queue ...",
                 signup_num());
        chk.run();

        $display("[TB] signup queue empty - simulation done");
        $finish;
    end

endmodule
