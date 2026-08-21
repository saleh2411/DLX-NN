#!/usr/bin/env python3
"""
Piecewise-linear 1/x golden model (paper eq. 2) in Q16.16.

    1/x ~= a[seg]*x + b[seg]

Eight power-of-two segments from [1,2) to [128,256), picked by a priority
encoder on the integer part; d < 1 clamps to seg 0, d >= 256 to seg 7.
Coefficients come from a least-squares fit per segment and are burned into
the hardware aLUT / bLUT.

Usage: python3 pwl_reciprocal.py [-x VALUE] [-v]
"""

import argparse
from pathlib import Path

from q16_16 import Q, SCALE, MASK, to_q, from_q, to_hex, q_mul, q_sat

# numpy + matplotlib are only used by the plotting branch of main().
# They're imported lazily there so `-v` (and the basic sweep) work in
# environments without them.

# ---------------------------------------------------------------------------
# Segment boundaries (power-of-two breakpoints)
# ---------------------------------------------------------------------------
NUM_SEGMENTS  = 8
SEG_BOUNDS    = [(1, 2), (2, 4), (4, 8), (8, 16),
                 (16, 32), (32, 64), (64, 128), (128, 256)]

# ---------------------------------------------------------------------------
# Coefficient computation — least-squares fit per segment
# ---------------------------------------------------------------------------

def _lsq_fit(xs, ys):
    """
    Plain ordinary-least-squares for y = a*x + b.

    Pure Python so the module loads without numpy.  The closed-form
    solution is identical (within FP rounding) to np.linalg.lstsq for a
    well-conditioned [x, 1] design matrix.
    """
    n   = len(xs)
    sx  = sum(xs)
    sy  = sum(ys)
    sxx = sum(x * x for x in xs)
    sxy = sum(x * y for x, y in zip(xs, ys))
    denom = n * sxx - sx * sx
    a = (n * sxy - sx * sy) / denom
    b = (sy - a * sx) / n
    return a, b


def _compute_coefficients():
    """
    Compute (a_q, b_q) for each segment by least-squares fit of 1/x
    over the segment interval at fine resolution.

    Returns
    -------
    list of (a_q, b_q) tuples in Q16.16 format (8 segments).
    """
    coeffs = []
    for lo, hi in SEG_BOUNDS:
        # Sample many points in [lo, hi).  Match the previous numpy-based
        # version: linspace(lo, hi, n_pts, endpoint=False).
        n_pts = max(2000, (hi - lo) * 256)
        step  = (hi - lo) / n_pts
        xs    = [lo + i * step for i in range(n_pts)]
        ys    = [1.0 / x       for x in xs]

        a_float, b_float = _lsq_fit(xs, ys)

        a_q = to_q(a_float)
        b_q = to_q(b_float)
        coeffs.append((a_q, b_q))
    return coeffs


# Precompute at module load time
COEFFICIENTS = _compute_coefficients()

# ---------------------------------------------------------------------------
# Segment selection (priority encoder on integer part)
# ---------------------------------------------------------------------------

def segment_index_from_q(d_q: int) -> int:
    """
    Return the segment index given d in Q16.16.
    Uses the integer part (bits [31:16]) — same logic the hardware uses.
    """
    int_part = d_q >> Q                            # signed integer part
    if int_part < 1:
        return 0
    if int_part >= 256:
        return 7
    if int_part >= 128:
        return 7
    if int_part >= 64:
        return 6
    if int_part >= 32:
        return 5
    if int_part >= 16:
        return 4
    if int_part >= 8:
        return 3
    if int_part >= 4:
        return 2
    if int_part >= 2:
        return 1
    return 0

# ---------------------------------------------------------------------------
# PWL reciprocal in Q16.16
# ---------------------------------------------------------------------------

def pwl_recip_q(d_q: int) -> int:
    """
    Approximate 1/d using the 8-segment PWL in Q16.16.

    Parameters
    ----------
    d_q : int
        Denominator in Q16.16.  In the softmax datapath d ≥ 1.0 always.

    Returns
    -------
    int
        Approximation of 1/d in Q16.16.

    Notes
    -----
    Hardware mapping:
        seg   = priority_encode(d_q[31:16])
        result = a_LUT[seg] * d_q  + b_LUT[seg]
    The multiply is a Q16.16 × Q16.16 → 64-bit → >>16 extraction.
    """
    seg = segment_index_from_q(d_q)
    a_q, b_q = COEFFICIENTS[seg]
    result = q_mul(a_q, d_q) + b_q
    return q_sat(result)

# ---------------------------------------------------------------------------
# Test-vector sweep — for shift_exp-style SV verification of the PWL DUT
# ---------------------------------------------------------------------------
#
# Same pattern as py/Softmax/shift_exp.py:  the sweep is emitted to two
# parallel `.mem` files (in / out) plus a `\include`-able SV header so the
# *same* golden vectors can be checked in:
#   - the unit tb           (pwl_reciprocal_tb.sv)
#   - higher-level / top tb (any tb that `\includes` the header).
#
# Range:
#   d ∈ [TB_D_MIN, TB_D_MAX].  Operating range of the PWL — covers all 8
#   power-of-two segments, matching the segment table SEG_BOUNDS above.
#
# Step:
#   TB_D_STEP_LSB Q16.16 LSBs.  Default = 16  →  step ≈ 2^-12.  This matches
#   the existing error-analysis fine sweep below ("step = 2^-12 for tractable
#   runtime") and yields ~1.04 M vectors → ~9 MB per .mem file.
#
#   Drop to 1 for full Q16.16 (2^-16) coverage — but be aware the resulting
#   pair is ~287 MB on disk (≈25× the shift_exp footprint, since PWL spans
#   25× the input range), and iverilog has to mmap a ~134 MB array on load.
TB_D_MIN      = 1.0
TB_D_MAX      = 256.0
TB_D_STEP_LSB = 16        # Q16.16 LSBs per step (16 = 2^-12)


def emit_vectors_sv(sv_path: Path, in_mem_path: Path, out_mem_path: Path) -> None:
    """
    Emit three files that together form the SV side of `d → pwl_recip(d)`:

        sv_path        — `\\\`include`-able header.  Declares the storage
                          (PWL_RECIP_D, PWL_RECIP_R), the loader task, and
                          the lookup functions pwl_recip_d_at(i) /
                          pwl_recip_expected(d).

        in_mem_path    — `$readmemh`-loadable hex table of input d-values,
                          one Q16.16 word per line.

        out_mem_path   — `$readmemh`-loadable hex table of expected
                          reciprocal values.  Row i of *_out.mem is the
                          golden output for row i of *_in.mem.

    Layout matches the tcXX_in.mem / tcXX_out.mem convention used by
    softmax_tb.sv and the shift_exp emitter.

    Coverage: d ∈ [TB_D_MIN, TB_D_MAX] at step = TB_D_STEP_LSB Q16.16 LSBs.

    Typical use in a tb (.mem files are read relative to sim cwd):

        `include "pwl_reciprocal_vectors.sv"
        ...
        initial begin
            pwl_recip_load_vectors();   // 2× $readmemh
            for (int i = 0; i < PWL_RECIP_NUM; i++) begin
                d = pwl_recip_d_at(i); #1;
                if (recip !== pwl_recip_expected(d)) $fatal;
            end
        end
    """
    d_min_q = to_q(TB_D_MIN)
    d_max_q = to_q(TB_D_MAX)
    step_q  = TB_D_STEP_LSB

    # Number of vectors: floor((max - min) / step) + 1, inclusive of both ends
    if (d_max_q - d_min_q) % step_q != 0:
        # Make sure d_max is exactly on a step boundary, otherwise the SV
        # range check + index math become inconsistent at the upper edge.
        raise ValueError(
            f"TB_D_STEP_LSB={step_q} does not evenly divide the range "
            f"[{TB_D_MIN}, {TB_D_MAX}] (diff={d_max_q - d_min_q} LSBs)."
        )
    n = (d_max_q - d_min_q) // step_q + 1

    # ---- Compute the input + expected-reciprocal tables -----------------
    d_words = [(d_min_q + i * step_q) & MASK              for i in range(n)]
    r_words = [pwl_recip_q(d_min_q + i * step_q) & MASK   for i in range(n)]

    # ---- Write the two .mem files (one 32-bit hex word per line) --------
    for path, words, label in (
        (in_mem_path,  d_words, "in "),
        (out_mem_path, r_words, "out"),
    ):
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8") as fp:
            fp.writelines(f"{w:08X}\n" for w in words)
        size_mb = path.stat().st_size / (1024 * 1024)
        print(f"  [mem {label}] {path}  ({n} words, {size_mb:.2f} MB)")

    # ---- Write the .sv header -------------------------------------------
    rel_in_mem  = f"vectors/{in_mem_path.name}"
    rel_out_mem = f"vectors/{out_mem_path.name}"
    step_float  = step_q / SCALE          # human-readable step

    lines = [
        "// Auto-generated — do not edit.",
        "// Source: py/Softmax/pwl_reciprocal.py -v",
        "// Format: Q16.16 signed 32-bit fixed-point, paper eq. 2",
        "//",
        f"// Mapping  d  →  pwl_recip(d)  for d ∈ [{TB_D_MIN:.3f}, {TB_D_MAX:.3f}]",
        f"// at step = {step_q} Q16.16 LSBs (≈ {step_float:.6f}).  {n} vectors.",
        "//",
        "// Inputs and expected outputs live in two parallel `.mem` files,",
        "// matching the tcXX_in.mem / tcXX_out.mem convention used by",
        "// softmax_tb.sv.  Row i of *_out.mem is the golden output for row i",
        "// of *_in.mem.",
        "//",
        "// `\\`include`-able from inside any tb module so the same golden",
        "// table is available at the unit, sub-env, and top-model level.",
        "//",
        "// Provides:",
        "//   localparam int          PWL_RECIP_NUM",
        "//   localparam logic        PWL_RECIP_D_MIN_Q / _MAX_Q / _STEP_Q",
        "//   reg [31:0]              PWL_RECIP_D [0:PWL_RECIP_NUM-1]",
        "//   reg [31:0]              PWL_RECIP_R [0:PWL_RECIP_NUM-1]",
        "//   task                    pwl_recip_load_vectors()",
        "//   function                pwl_recip_d_at(int i)         // → [31:0]",
        "//   function                pwl_recip_expected([31:0] d)  // → [31:0]",
        "//",
        "// Example use (inside an `initial` block of any tb):",
        "//",
        "//   pwl_recip_load_vectors();",
        "//   for (int i = 0; i < PWL_RECIP_NUM; i++) begin",
        "//       d = pwl_recip_d_at(i); #1;",
        "//       if (recip !== pwl_recip_expected(d)) $fatal;",
        "//   end",
        "//",
        f"// .mem files: {rel_in_mem}",
        f"//             {rel_out_mem}",
        "// (paths relative to sim cwd, matching softmax_tb.sv)",
        "",
        f"localparam int          PWL_RECIP_NUM      = {n};",
        f"localparam logic [31:0] PWL_RECIP_D_MIN_Q  = 32'h{d_min_q & MASK:08X};  // {TB_D_MIN:.3f}",
        f"localparam logic [31:0] PWL_RECIP_D_MAX_Q  = 32'h{d_max_q & MASK:08X};  // {TB_D_MAX:.3f}",
        f"localparam logic [31:0] PWL_RECIP_D_STEP_Q = 32'h{step_q & MASK:08X};  // {step_q} LSB",
        "",
        "// Parallel input / expected-output tables.  Row i of PWL_RECIP_R is",
        "// the golden reciprocal for row i of PWL_RECIP_D.",
        "reg [31:0] PWL_RECIP_D [0:PWL_RECIP_NUM-1];",
        "reg [31:0] PWL_RECIP_R [0:PWL_RECIP_NUM-1];",
        "",
        "// Load the golden tables from disk.  Call once in `initial`.",
        "task automatic pwl_recip_load_vectors;",
        "begin",
        f"    $readmemh(\"{rel_in_mem}\",  PWL_RECIP_D);",
        f"    $readmemh(\"{rel_out_mem}\", PWL_RECIP_R);",
        "end",
        "endtask",
        "",
        "// Returns the i-th input d in the sweep (0 ≤ i < PWL_RECIP_NUM).",
        "// Reads from PWL_RECIP_D so it works for any vector layout the .mem",
        "// files happen to contain (contiguous or not).",
        "function automatic [31:0] pwl_recip_d_at(input int i);",
        "begin",
        "    pwl_recip_d_at = PWL_RECIP_D[i];",
        "end",
        "endfunction",
        "",
        "// Golden mapping  d → pwl_recip(d).",
        "// O(1) lookup against the contiguous sweep:  idx = (d - D_MIN) / STEP.",
        "// Returns 32'hx if d is outside [D_MIN, D_MAX] or not on a step",
        "// boundary, so any out-of-coverage check surfaces as a clear mismatch",
        "// instead of a silent rounded read.",
        "function automatic [31:0] pwl_recip_expected(input [31:0] d);",
        "    int diff;",
        "    int idx;",
        "begin",
        "    if (d < PWL_RECIP_D_MIN_Q || d > PWL_RECIP_D_MAX_Q)",
        "        pwl_recip_expected = 32'hxxxxxxxx;",
        "    else begin",
        "        diff = d - PWL_RECIP_D_MIN_Q;",
        "        if ((diff % PWL_RECIP_D_STEP_Q) != 0)",
        "            pwl_recip_expected = 32'hxxxxxxxx;  // not on a sweep tick",
        "        else begin",
        "            idx = diff / PWL_RECIP_D_STEP_Q;",
        "            pwl_recip_expected = PWL_RECIP_R[idx];",
        "        end",
        "    end",
        "end",
        "endfunction",
        "",
    ]

    sv_path.parent.mkdir(parents=True, exist_ok=True)
    sv_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"  [SV]  {sv_path}  ({n} vectors)")


# ---------------------------------------------------------------------------
# Unit test — sweep & error analysis
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="PWL reciprocal golden model (paper eq.2)")
    parser.add_argument("-x", type=float, default=None,
                        help="Evaluate 1/x at a single x value")
    parser.add_argument("-v", "--vectors", action="store_true",
                        help="Emit design/Softmax/pwl_reciprocal_vectors.sv "
                             "+ vectors/pwl_reciprocal_in.mem + ..._out.mem and exit")
    args = parser.parse_args()

    out_dir = Path(__file__).resolve().parent

    # ---- Vector-emit mode (for SV testbenches) ----
    if args.vectors:
        repo_root    = out_dir.parent.parent
        design_dir   = repo_root / "design" / "Softmax"
        sv_path      = design_dir / "pwl_reciprocal_vectors.sv"
        in_mem_path  = design_dir / "vectors" / "pwl_reciprocal_in.mem"
        out_mem_path = design_dir / "vectors" / "pwl_reciprocal_out.mem"
        emit_vectors_sv(sv_path, in_mem_path, out_mem_path)
        return

    # ---- Print LUT coefficients (for hardware) ----
    print("PWL Reciprocal LUT coefficients (Q16.16)")
    print("=" * 70)
    print(f"{'Seg':>3s}  {'Range':>12s}  {'a (float)':>14s}  {'a (hex)':>12s}"
          f"  {'b (float)':>14s}  {'b (hex)':>12s}")
    print("-" * 70)
    for i, ((lo, hi), (a_q, b_q)) in enumerate(zip(SEG_BOUNDS, COEFFICIENTS)):
        print(f"{i:3d}  [{lo:3d},{hi:4d})  {from_q(a_q):14.8f}  {to_hex(a_q):>12s}"
              f"  {from_q(b_q):14.8f}  {to_hex(b_q):>12s}")
    print()

    # ---- Single-point mode ----
    if args.x is not None:
        d = args.x
        d_q = to_q(d)
        r_q = pwl_recip_q(d_q)
        r_ref = 1.0 / d if d != 0 else float('inf')
        seg = segment_index_from_q(d_q)
        print(f"PWL reciprocal at d = {d}")
        print("=" * 55)
        print(f"  d_q (hex)       = {to_hex(d_q)}")
        print(f"  segment         = {seg}  range {SEG_BOUNDS[seg]}")
        print(f"  pwl_recip (f)   = {from_q(r_q):.10f}")
        print(f"  pwl_recip (hex) = {to_hex(r_q)}")
        print(f"  1/d exact       = {r_ref:.10f}")
        print(f"  abs error       = {abs(r_ref - from_q(r_q)):.10e}")
        pct_err = abs(r_ref - from_q(r_q)) / max(abs(r_ref), 1e-15) * 100
        print(f"  % error         = {pct_err:.4f}%")
        return

    # ---- Sweep mode: d ∈ [1, 256] step 0.5 ----
    print("PWL reciprocal sweep: d in [1, 256], step = 0.5")
    print("=" * 90)
    print(f"{'d':>8s}  {'seg':>3s}  {'pwl_recip':>12s}  {'1/d_exact':>12s}"
          f"  {'abs_err':>12s}  {'%_err':>10s}")
    print("-" * 90)

    max_pct = 0.0
    max_pct_d = 0.0
    d = 1.0
    while d <= 256.0 + 1e-9:
        d_q   = to_q(d)
        r_q   = pwl_recip_q(d_q)
        r_hw  = from_q(r_q)
        r_ref = 1.0 / d
        abs_err = abs(r_ref - r_hw)
        pct_err = abs_err / max(abs(r_ref), 1e-15) * 100.0
        seg = segment_index_from_q(d_q)

        if pct_err > max_pct:
            max_pct = pct_err
            max_pct_d = d

        # Print only selected points to keep output manageable
        if d <= 4.0 or d % 8 == 0 or d >= 254.0:
            print(f"{d:8.2f}  {seg:3d}  {r_hw:12.8f}  {r_ref:12.8f}"
                  f"  {abs_err:12.4e}  {pct_err:10.4f}")

        d += 0.5

    # ---- Fine sweep for statistics (step = 2^-12 for tractable runtime) ----
    STEP = 16   # every 16th Q16.16 value = step ~ 2^-12
    print(f"\nComputing statistics over d in [1, 256], step = {STEP}/65536 ...")
    total_pct = 0.0
    total_se  = 0.0
    max_pct   = 0.0
    max_pct_d = 0.0
    count     = 0
    plot_d    = []
    plot_hw   = []
    plot_ref  = []
    d_q_start = to_q(1.0)
    d_q_end   = to_q(256.0)
    for d_q in range(d_q_start, d_q_end + 1, STEP):
        r_q   = pwl_recip_q(d_q)
        r_hw  = from_q(r_q)
        d_f   = from_q(d_q)
        r_ref = 1.0 / d_f if d_f != 0 else 0.0
        pct   = abs(r_ref - r_hw) / max(abs(r_ref), 1e-15) * 100.0
        total_pct += pct
        total_se  += (r_ref - r_hw) ** 2
        if pct > max_pct:
            max_pct   = pct
            max_pct_d = d_f
        plot_d.append(d_f)
        plot_hw.append(r_hw)
        plot_ref.append(r_ref)

        count += 1

    avg_pct = total_pct / count
    mse     = total_se  / count
    summary = (
        f"\n{'=' * 55}\n"
        f"PWL reciprocal error summary (d in [1, 256], step = 2^-12)\n"
        f"{'=' * 55}\n"
        f"  Points evaluated : {count}\n"
        f"  MSE              : {mse:.6e}\n"
        f"  Avg % error      : {avg_pct:.6f}%\n"
        f"  Max % error      : {max_pct:.6f}%  at d = {max_pct_d:.6f}\n"
        f"  Target           : MSE <= 0.025\n"
        f"  Status           : {'PASS' if mse <= 0.025 else 'FAIL'}\n"
    )
    print(summary)

    (out_dir / "pwl_reciprocal_results.txt").write_text(summary, encoding="utf-8")
    print(f"Results written to {out_dir / 'pwl_reciprocal_results.txt'}")

    # ---- Plot ---------------------------------------------------------------
    # Lazy-import: only the plot path needs numpy + matplotlib, so the rest of
    # the script (including -v and the basic sweep) works without them.
    try:
        import numpy as np
        import matplotlib.pyplot as plt
    except ModuleNotFoundError as exc:
        print(f"\n[plot skipped] {exc.name} not installed — "
              f"`pip install numpy matplotlib` to enable plotting.")
        return

    plot_d   = np.array(plot_d)
    plot_hw  = np.array(plot_hw)
    plot_ref = np.array(plot_ref)

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(plot_d, plot_ref, label="Exact 1/d",  linewidth=1.5)
    ax.plot(plot_d, plot_hw,  label="PWL approx", linewidth=1.0, linestyle="--")
    ax.set_xscale("log", base=2)
    ax.set_xlabel("d")
    ax.set_ylabel("1/d")
    ax.set_title(f"PWL Reciprocal: Approximation vs Exact  (MSE = {mse:.3e})")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    plot_path = out_dir / "pwl_reciprocal_error.png"
    plt.savefig(plot_path, dpi=150)
    print(f"Plot saved to {plot_path}")
    plt.show()


if __name__ == "__main__":
    main()
