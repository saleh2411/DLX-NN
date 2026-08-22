// softmax_coverage — functional coverage for the softmax sub-env.
//
// Coverage points (sampled per softmax_msg the checker dequeues), mapped
// to the 4 attributes from the vector spec:
//   * vector_dimension        — cov_hits_size[N]                       (spec #2)
//   * value_bin_distribution  — 6 bins x { per-vector, per-element }   (spec #3)
//        negative_extreme: [-max, -201]
//        negative_high   : [-200, -11]
//        negative_low    : [-10, 0]
//        positive_low    : [0, 10]
//        positive_high   : [11, 200]
//        positive_extreme: [201, +max]
//   * value_dispersion        — LOW / HIGH (spread proxy, 10.0 threshold) (spec #4)
//   * sign mix / spread       — legacy sub-classifications retained
//
// Note: element_values (spec #1) is the raw input itself, not a coverage
// dimension — the per-bin histogram counts cov_elems_* give the global view.
//
// Two coverage mechanisms live in the same class:
//
//   1. Manual hit counters (always on).  Iverilog 13 doesn't allow
//      unpacked arrays inside class properties, so the counters
//      live at module scope (softmax_subenv_tb.cov_hits_size, ...)
//      and this class's methods reach them through hierarchical
//      references.
//
//   2. SystemVerilog covergroup, gated by `define COVERGROUP_OK.
//      Available with Questa / VCS / Xcelium.  Verilator 5.x parses
//      the syntax but silently ignores `bins`.

class softmax_coverage;

    // Per-sample state (scalars only — class properties).
    int unsigned vec_size;
    int          min_x;
    int          max_x;
    int          spread;
    bit          all_equal;
    bit          all_positive;
    bit          all_negative;

    // Spec value_bin_distribution: per-vector "any element in this bin" flags.
    bit          any_bin_neg_extreme;
    bit          any_bin_neg_high;
    bit          any_bin_neg_low;
    bit          any_bin_pos_low;
    bit          any_bin_pos_high;
    bit          any_bin_pos_extreme;

    // Spec value_dispersion: 1 = HIGH_VARIANCE, 0 = LOW_VARIANCE.
    bit          dispersion_high;

`ifdef COVERGROUP_OK
    covergroup softmax_cg;
        option.per_instance = 1;

        cp_size: coverpoint vec_size {
            bins n2     = {2};
            bins n3_4   = {[3:4]};
            bins n5_8   = {[5:8]};
            bins n9_16  = {[9:16]};
        }

        cp_minx: coverpoint min_x {
            bins very_neg     = {[-32'sh7FFF_FFFF : -32'sh0008_0000]};
            bins moderate_neg = {[-32'sh0007_FFFF : -32'sh0001_0001]};
            bins small_neg    = {[-32'sh0001_0000 :          -1     ]};
            bins zero         = {0};
            bins small_pos    = {[          1     :  32'sh0000_FFFF]};
            bins moderate_pos = {[ 32'sh0001_0000 :  32'sh0007_FFFF]};
            bins very_pos     = {[ 32'sh0008_0000 :  32'sh7FFF_FFFF]};
        }

        cp_maxx: coverpoint max_x {
            bins very_neg     = {[-32'sh7FFF_FFFF : -32'sh0008_0000]};
            bins moderate_neg = {[-32'sh0007_FFFF : -32'sh0001_0001]};
            bins small_neg    = {[-32'sh0001_0000 :          -1     ]};
            bins zero         = {0};
            bins small_pos    = {[          1     :  32'sh0000_FFFF]};
            bins moderate_pos = {[ 32'sh0001_0000 :  32'sh0007_FFFF]};
            bins very_pos     = {[ 32'sh0008_0000 :  32'sh7FFF_FFFF]};
        }

        cp_spread: coverpoint spread {
            bins identical = {0};
            bins close     = {[1                : 32'sh0000_4000]};
            bins moderate  = {[32'sh0000_4001   : 32'sh0004_0000]};
            bins wide      = {[32'sh0004_0001   : 32'sh000F_FFFF]};
            bins extreme   = {[32'sh0010_0000   : 32'sh7FFF_FFFF]};
        }

        cp_equal:  coverpoint all_equal;
        cp_allpos: coverpoint all_positive;
        cp_allneg: coverpoint all_negative;

        // Spec value_bin_distribution coverpoints
        cp_bin_neg_extreme: coverpoint any_bin_neg_extreme;
        cp_bin_neg_high:    coverpoint any_bin_neg_high;
        cp_bin_neg_low:     coverpoint any_bin_neg_low;
        cp_bin_pos_low:     coverpoint any_bin_pos_low;
        cp_bin_pos_high:    coverpoint any_bin_pos_high;
        cp_bin_pos_extreme: coverpoint any_bin_pos_extreme;

        // Spec value_dispersion coverpoint
        cp_dispersion: coverpoint dispersion_high {
            bins LOW  = {0};
            bins HIGH = {1};
        }

        cross_size_spread:      cross cp_size, cp_spread;
        cross_size_sign:        cross cp_size, cp_allpos, cp_allneg;
        cross_size_dispersion:  cross cp_size, cp_dispersion;
    endgroup
`endif

    function new();
`ifdef COVERGROUP_OK
        softmax_cg = new();
`endif
    endfunction

    // sample_msg — called by the checker each time it dequeues a
    // softmax_msg.  Reads the input vector through a hierarchical
    // reference into the tb module, computes per-vector statistics,
    // and bumps the module-level hit counters.
    function void sample_msg(softmax_msg msg);
        int        v;
        int        first_val;
        int        sgn_pos;
        int        sgn_neg;
        int        eq_first;
        reg [31:0] tmp;
        int        idx;

        idx       = msg.test_idx;
        sgn_pos   = 0;
        sgn_neg   = 0;
        eq_first  = 1;
        tmp       = softmax_subenv_tb.MSG_X_IN[idx][0];
        first_val = $signed(tmp);
        min_x     = first_val;
        max_x     = first_val;

        any_bin_neg_extreme = 0;
        any_bin_neg_high    = 0;
        any_bin_neg_low     = 0;
        any_bin_pos_low     = 0;
        any_bin_pos_high    = 0;
        any_bin_pos_extreme = 0;

        for (int i = 0; i < msg.vector_size; i++) begin
            tmp = softmax_subenv_tb.MSG_X_IN[idx][i];
            v   = $signed(tmp);
            if (v < min_x)      min_x = v;
            if (v > max_x)      max_x = v;
            if (v > 0)          sgn_pos = 1;
            if (v < 0)          sgn_neg = 1;
            if (v != first_val) eq_first = 0;

            // Spec bin classification (Q16.16 thresholds):
            //   201 << 16 = 0x00C9_0000     200 << 16 = 0x00C8_0000
            //    11 << 16 = 0x000B_0000      10 << 16 = 0x000A_0000
            //  0 is shared by neg_low and pos_low per spec.
            if (v <= -32'sh00C9_0000) begin
                any_bin_neg_extreme = 1;
                softmax_subenv_tb.cov_elems_bin_neg_extreme =
                    softmax_subenv_tb.cov_elems_bin_neg_extreme + 1;
            end
            if (v >= -32'sh00C8_0000 && v <= -32'sh000B_0000) begin
                any_bin_neg_high = 1;
                softmax_subenv_tb.cov_elems_bin_neg_high =
                    softmax_subenv_tb.cov_elems_bin_neg_high + 1;
            end
            if (v >= -32'sh000A_0000 && v <= 0) begin
                any_bin_neg_low = 1;
                softmax_subenv_tb.cov_elems_bin_neg_low =
                    softmax_subenv_tb.cov_elems_bin_neg_low + 1;
            end
            if (v >= 0 && v <= 32'sh000A_0000) begin
                any_bin_pos_low = 1;
                softmax_subenv_tb.cov_elems_bin_pos_low =
                    softmax_subenv_tb.cov_elems_bin_pos_low + 1;
            end
            if (v >= 32'sh000B_0000 && v <= 32'sh00C8_0000) begin
                any_bin_pos_high = 1;
                softmax_subenv_tb.cov_elems_bin_pos_high =
                    softmax_subenv_tb.cov_elems_bin_pos_high + 1;
            end
            if (v >= 32'sh00C9_0000) begin
                any_bin_pos_extreme = 1;
                softmax_subenv_tb.cov_elems_bin_pos_extreme =
                    softmax_subenv_tb.cov_elems_bin_pos_extreme + 1;
            end
        end

        vec_size      = msg.vector_size;
        spread        = max_x - min_x;
        all_equal     = eq_first[0];
        all_positive  = (sgn_pos & ~sgn_neg);
        all_negative  = (sgn_neg & ~sgn_pos);

        // Spec value_dispersion (binary): LOW if spread<=10.0, HIGH otherwise.
        // Spread is in Q16.16; 10.0 = 0x000A_0000.
        dispersion_high = (spread > 32'sh000A_0000);

        // Manual counters (live in the tb module to dodge iverilog's
        // restriction on unpacked arrays inside class properties).
        if (vec_size <= softmax_subenv_tb.MAX_MSG_N)
            softmax_subenv_tb.cov_hits_size[vec_size]
                = softmax_subenv_tb.cov_hits_size[vec_size] + 1;
        if (all_equal)
            softmax_subenv_tb.cov_hits_equal =
                softmax_subenv_tb.cov_hits_equal + 1;
        if (all_positive)
            softmax_subenv_tb.cov_hits_allpos =
                softmax_subenv_tb.cov_hits_allpos + 1;
        if (all_negative)
            softmax_subenv_tb.cov_hits_allneg =
                softmax_subenv_tb.cov_hits_allneg + 1;
        if (sgn_pos && sgn_neg)
            softmax_subenv_tb.cov_hits_mixed =
                softmax_subenv_tb.cov_hits_mixed + 1;
        if (spread > 32'sh0010_0000)
            softmax_subenv_tb.cov_hits_extreme_spread =
                softmax_subenv_tb.cov_hits_extreme_spread + 1;
        if (spread < 32'sh0000_4000 && spread != 0)
            softmax_subenv_tb.cov_hits_close_values =
                softmax_subenv_tb.cov_hits_close_values + 1;

        // Spec value_bin_distribution (per-vector flags)
        if (any_bin_neg_extreme)
            softmax_subenv_tb.cov_hits_bin_neg_extreme =
                softmax_subenv_tb.cov_hits_bin_neg_extreme + 1;
        if (any_bin_neg_high)
            softmax_subenv_tb.cov_hits_bin_neg_high =
                softmax_subenv_tb.cov_hits_bin_neg_high + 1;
        if (any_bin_neg_low)
            softmax_subenv_tb.cov_hits_bin_neg_low =
                softmax_subenv_tb.cov_hits_bin_neg_low + 1;
        if (any_bin_pos_low)
            softmax_subenv_tb.cov_hits_bin_pos_low =
                softmax_subenv_tb.cov_hits_bin_pos_low + 1;
        if (any_bin_pos_high)
            softmax_subenv_tb.cov_hits_bin_pos_high =
                softmax_subenv_tb.cov_hits_bin_pos_high + 1;
        if (any_bin_pos_extreme)
            softmax_subenv_tb.cov_hits_bin_pos_extreme =
                softmax_subenv_tb.cov_hits_bin_pos_extreme + 1;

        // Spec value_dispersion
        if (dispersion_high)
            softmax_subenv_tb.cov_hits_high_variance =
                softmax_subenv_tb.cov_hits_high_variance + 1;
        else
            softmax_subenv_tb.cov_hits_low_variance =
                softmax_subenv_tb.cov_hits_low_variance + 1;

        softmax_subenv_tb.cov_total_samples =
            softmax_subenv_tb.cov_total_samples + 1;

`ifdef COVERGROUP_OK
        softmax_cg.sample();
`endif
    endfunction

    function void report();
        int t;
        int fd_txt;
        int fd_html;

        // ---- Console output ------------------------------------------------
        $display("------------------------------------------------------------");
        $display("[COV] softmax functional coverage  (samples=%0d)",
                 softmax_subenv_tb.cov_total_samples);
        $display("[COV]   sizes seen 2..%0d :", softmax_subenv_tb.MAX_MSG_N);
        for (int i = 2; i <= softmax_subenv_tb.MAX_MSG_N; i++) begin
            t = softmax_subenv_tb.cov_hits_size[i];
            if (t > 0)
                $display("[COV]     N=%2d : %0d hits", i, t);
        end
        $display("[COV]   all-equal       : %0d",
                 softmax_subenv_tb.cov_hits_equal);
        $display("[COV]   all-positive    : %0d",
                 softmax_subenv_tb.cov_hits_allpos);
        $display("[COV]   all-negative    : %0d",
                 softmax_subenv_tb.cov_hits_allneg);
        $display("[COV]   mixed signs     : %0d",
                 softmax_subenv_tb.cov_hits_mixed);
        $display("[COV]   extreme spread  : %0d  (>16.0)",
                 softmax_subenv_tb.cov_hits_extreme_spread);
        $display("[COV]   close values    : %0d  (<0.25, non-zero)",
                 softmax_subenv_tb.cov_hits_close_values);
        $display("[COV]   value_bin_distribution (per-vector / per-element):");
        $display("[COV]     negative_extreme [-max,-201] : %0d vec  %0d elems",
                 softmax_subenv_tb.cov_hits_bin_neg_extreme,
                 softmax_subenv_tb.cov_elems_bin_neg_extreme);
        $display("[COV]     negative_high    [-200,-11]  : %0d vec  %0d elems",
                 softmax_subenv_tb.cov_hits_bin_neg_high,
                 softmax_subenv_tb.cov_elems_bin_neg_high);
        $display("[COV]     negative_low     [-10,0]     : %0d vec  %0d elems",
                 softmax_subenv_tb.cov_hits_bin_neg_low,
                 softmax_subenv_tb.cov_elems_bin_neg_low);
        $display("[COV]     positive_low     [0,10]      : %0d vec  %0d elems",
                 softmax_subenv_tb.cov_hits_bin_pos_low,
                 softmax_subenv_tb.cov_elems_bin_pos_low);
        $display("[COV]     positive_high    [11,200]    : %0d vec  %0d elems",
                 softmax_subenv_tb.cov_hits_bin_pos_high,
                 softmax_subenv_tb.cov_elems_bin_pos_high);
        $display("[COV]     positive_extreme [201,+max]  : %0d vec  %0d elems",
                 softmax_subenv_tb.cov_hits_bin_pos_extreme,
                 softmax_subenv_tb.cov_elems_bin_pos_extreme);
        $display("[COV]   value_dispersion  LOW=%0d  HIGH=%0d  (threshold spread=10.0)",
                 softmax_subenv_tb.cov_hits_low_variance,
                 softmax_subenv_tb.cov_hits_high_variance);
`ifdef COVERGROUP_OK
        $display("[COV]   covergroup pct  : %0.2f%%",
                 softmax_cg.get_inst_coverage());
`else
        $display("[COV]   covergroup      : disabled (rebuild with +define+COVERGROUP_OK)");
`endif
        $display("------------------------------------------------------------");

        // ---- Plain-text dump (softmax_coverage.txt) ------------------------
        fd_txt = $fopen("softmax_coverage.txt", "w");
        if (fd_txt != 0) begin
            $fdisplay(fd_txt, "softmax functional coverage report");
            $fdisplay(fd_txt, "===================================");
            $fdisplay(fd_txt, "samples : %0d",
                      softmax_subenv_tb.cov_total_samples);
            $fdisplay(fd_txt, "");
            $fdisplay(fd_txt, "vector size distribution:");
            for (int i = 2; i <= softmax_subenv_tb.MAX_MSG_N; i++) begin
                t = softmax_subenv_tb.cov_hits_size[i];
                $fdisplay(fd_txt, "  N=%2d : %0d hits", i, t);
            end
            $fdisplay(fd_txt, "");
            $fdisplay(fd_txt, "flavour buckets:");
            $fdisplay(fd_txt, "  all-equal      : %0d",
                      softmax_subenv_tb.cov_hits_equal);
            $fdisplay(fd_txt, "  all-positive   : %0d",
                      softmax_subenv_tb.cov_hits_allpos);
            $fdisplay(fd_txt, "  all-negative   : %0d",
                      softmax_subenv_tb.cov_hits_allneg);
            $fdisplay(fd_txt, "  mixed signs    : %0d",
                      softmax_subenv_tb.cov_hits_mixed);
            $fdisplay(fd_txt, "  extreme spread : %0d  (>16.0)",
                      softmax_subenv_tb.cov_hits_extreme_spread);
            $fdisplay(fd_txt, "  close values   : %0d  (<0.25, non-zero)",
                      softmax_subenv_tb.cov_hits_close_values);
            $fdisplay(fd_txt, "");
            $fdisplay(fd_txt, "value_bin_distribution (vector / element):");
            $fdisplay(fd_txt, "  negative_extreme [-max, -201] : %0d / %0d",
                      softmax_subenv_tb.cov_hits_bin_neg_extreme,
                      softmax_subenv_tb.cov_elems_bin_neg_extreme);
            $fdisplay(fd_txt, "  negative_high    [-200, -11]  : %0d / %0d",
                      softmax_subenv_tb.cov_hits_bin_neg_high,
                      softmax_subenv_tb.cov_elems_bin_neg_high);
            $fdisplay(fd_txt, "  negative_low     [-10, 0]     : %0d / %0d",
                      softmax_subenv_tb.cov_hits_bin_neg_low,
                      softmax_subenv_tb.cov_elems_bin_neg_low);
            $fdisplay(fd_txt, "  positive_low     [0, 10]      : %0d / %0d",
                      softmax_subenv_tb.cov_hits_bin_pos_low,
                      softmax_subenv_tb.cov_elems_bin_pos_low);
            $fdisplay(fd_txt, "  positive_high    [11, 200]    : %0d / %0d",
                      softmax_subenv_tb.cov_hits_bin_pos_high,
                      softmax_subenv_tb.cov_elems_bin_pos_high);
            $fdisplay(fd_txt, "  positive_extreme [201, +max]  : %0d / %0d",
                      softmax_subenv_tb.cov_hits_bin_pos_extreme,
                      softmax_subenv_tb.cov_elems_bin_pos_extreme);
            $fdisplay(fd_txt, "");
            $fdisplay(fd_txt, "value_dispersion (spread proxy, threshold=10.0):");
            $fdisplay(fd_txt, "  LOW_VARIANCE  : %0d",
                      softmax_subenv_tb.cov_hits_low_variance);
            $fdisplay(fd_txt, "  HIGH_VARIANCE : %0d",
                      softmax_subenv_tb.cov_hits_high_variance);
`ifdef COVERGROUP_OK
            $fdisplay(fd_txt, "");
            $fdisplay(fd_txt, "covergroup pct : %0.2f%%",
                      softmax_cg.get_inst_coverage());
`else
            $fdisplay(fd_txt, "");
            $fdisplay(fd_txt, "covergroup     : disabled (rebuild with +define+COVERGROUP_OK)");
`endif
            $fclose(fd_txt);
            $display("[COV] wrote softmax_coverage.txt");
        end

        // ---- HTML dump (softmax_coverage.html) -----------------------------
        // %% in format strings emits a literal '%' (needed for CSS width:100%).
        fd_html = $fopen("softmax_coverage.html", "w");
        if (fd_html != 0) begin
            $fdisplay(fd_html, "<!doctype html><html><head><meta charset=\"utf-8\">");
            $fdisplay(fd_html, "<title>softmax coverage</title><style>");
            $fdisplay(fd_html, "body{font-family:system-ui,sans-serif;max-width:760px;margin:2em auto;color:#222}");
            $fdisplay(fd_html, "table{border-collapse:collapse;margin:1em 0;width:100%%}");
            $fdisplay(fd_html, "th,td{padding:.4em .8em;border:1px solid #ccc;text-align:left}");
            $fdisplay(fd_html, "th{background:#f4f4f4}h1{margin-bottom:.2em}h2{margin-top:1.4em}");
            $fdisplay(fd_html, ".zero{color:#a00}</style></head><body>");
            $fdisplay(fd_html, "<h1>softmax functional coverage</h1>");
            $fdisplay(fd_html, "<p>samples: <b>%0d</b></p>",
                      softmax_subenv_tb.cov_total_samples);

            $fdisplay(fd_html, "<h2>vector size</h2><table><tr><th>N</th><th>hits</th></tr>");
            for (int i = 2; i <= softmax_subenv_tb.MAX_MSG_N; i++) begin
                t = softmax_subenv_tb.cov_hits_size[i];
                if (t == 0)
                    $fdisplay(fd_html, "<tr><td>%0d</td><td class=\"zero\">0</td></tr>", i);
                else
                    $fdisplay(fd_html, "<tr><td>%0d</td><td>%0d</td></tr>", i, t);
            end
            $fdisplay(fd_html, "</table>");

            $fdisplay(fd_html, "<h2>flavour buckets</h2><table><tr><th>bucket</th><th>hits</th></tr>");
            $fdisplay(fd_html, "<tr><td>all-equal</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_equal);
            $fdisplay(fd_html, "<tr><td>all-positive</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_allpos);
            $fdisplay(fd_html, "<tr><td>all-negative</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_allneg);
            $fdisplay(fd_html, "<tr><td>mixed signs</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_mixed);
            $fdisplay(fd_html, "<tr><td>extreme spread (&gt;16.0)</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_extreme_spread);
            $fdisplay(fd_html, "<tr><td>close values (&lt;0.25, non-zero)</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_close_values);
            $fdisplay(fd_html, "</table>");

            // ---- Spec value_bin_distribution -------------------------------
            $fdisplay(fd_html, "<h2>value_bin_distribution</h2>");
            $fdisplay(fd_html, "<table><tr><th>bin</th><th>range</th><th>vectors hit</th><th>elements</th></tr>");
            $fdisplay(fd_html, "<tr><td>negative_extreme</td><td>[-max, -201]</td><td>%0d</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_bin_neg_extreme,
                      softmax_subenv_tb.cov_elems_bin_neg_extreme);
            $fdisplay(fd_html, "<tr><td>negative_high</td><td>[-200, -11]</td><td>%0d</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_bin_neg_high,
                      softmax_subenv_tb.cov_elems_bin_neg_high);
            $fdisplay(fd_html, "<tr><td>negative_low</td><td>[-10, 0]</td><td>%0d</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_bin_neg_low,
                      softmax_subenv_tb.cov_elems_bin_neg_low);
            $fdisplay(fd_html, "<tr><td>positive_low</td><td>[0, 10]</td><td>%0d</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_bin_pos_low,
                      softmax_subenv_tb.cov_elems_bin_pos_low);
            $fdisplay(fd_html, "<tr><td>positive_high</td><td>[11, 200]</td><td>%0d</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_bin_pos_high,
                      softmax_subenv_tb.cov_elems_bin_pos_high);
            $fdisplay(fd_html, "<tr><td>positive_extreme</td><td>[201, +max]</td><td>%0d</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_bin_pos_extreme,
                      softmax_subenv_tb.cov_elems_bin_pos_extreme);
            $fdisplay(fd_html, "</table>");

            // ---- Spec value_dispersion -------------------------------------
            $fdisplay(fd_html, "<h2>value_dispersion</h2>");
            $fdisplay(fd_html, "<p>Binary classification via (max-min) spread; threshold = 10.0.</p>");
            $fdisplay(fd_html, "<table><tr><th>class</th><th>hits</th></tr>");
            $fdisplay(fd_html, "<tr><td>LOW_VARIANCE  (spread &le; 10.0)</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_low_variance);
            $fdisplay(fd_html, "<tr><td>HIGH_VARIANCE (spread &gt; 10.0)</td><td>%0d</td></tr>",
                      softmax_subenv_tb.cov_hits_high_variance);
            $fdisplay(fd_html, "</table>");

`ifdef COVERGROUP_OK
            $fdisplay(fd_html, "<h2>covergroup</h2><p>instance coverage: <b>%0.2f%%</b></p>",
                      softmax_cg.get_inst_coverage());
`else
            $fdisplay(fd_html, "<h2>covergroup</h2><p><i>disabled</i> &mdash; rebuild with <code>+define+COVERGROUP_OK</code> on a covergroup-capable simulator (Verilator 5+, Questa, VCS, Xcelium).</p>");
`endif
            $fdisplay(fd_html, "</body></html>");
            $fclose(fd_html);
            $display("[COV] wrote softmax_coverage.html");
        end
    endfunction

endclass
