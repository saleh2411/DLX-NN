#!/usr/bin/env python3
"""
Shift-exp golden model (paper eq. 1) in Q16.16.

    v = 1.5*x;  base = 1 + 0.5*frac(v);  result = base << floor(v)
    (right-shift when floor(v) < 0, which is always the case in softmax
     since x <= 0 after subtracting the max)

Usage: python3 shift_exp.py [-x VALUE] [-v]
"""

import math
import argparse
from pathlib import Path

from q16_16 import Q, ONE, MASK, to_q, from_q, to_hex, q_sat

# ---------------------------------------------------------------------------
# shift_exp in Q16.16 (paper eq. 1)
# ---------------------------------------------------------------------------

def shift_exp_q(x_q: int) -> int:
    """
    Compute shift-exp(x) in Q16.16.

    Parameters
    ----------
    x_q : int
        Input in Q16.16 format.  In the softmax datapath this is always ≤ 0.

    Returns
    -------
    int
        Approximation of exp(x) in Q16.16 format.

    Notes
    -----
    Hardware mapping:
        v = x + (x >>> 1)                     # signed arith shift (×1.5)
        v_int  = v[31:16]                      # sign-extended integer part
        v_frac = {16'b0, v[15:0]}              # unsigned fractional part (≥0)
        base   = 0x0001_0000 + (v_frac >> 1)   # 1.0 + 0.5*v_frac
        shift  = |v_int|
        result = base >> shift    (v_int < 0)
               = base << shift    (v_int ≥ 0)
               = 0                (shift > 31, underflow guard)
    """
    # v = 1.5 * x  (signed arithmetic right shift to compute x + x>>1)
    # Python ints are arbitrary-precision; emulate 32-bit sign extension
    v = x_q + (x_q >> 1)                          # x_q is already signed int

    # Split into integer and fractional parts (Q16.16 layout)
    # v_int is the signed integer part (bits [31:16], sign-extended).
    # In Python, arithmetic right-shift by 16 achieves this.
    v_int = v >> Q                                 # signed floor(v)

    # v_frac is the *unsigned* fractional part (bits [15:0]).
    # Masking with 0xFFFF gives the lower 16 bits (always ≥ 0).
    v_frac = v & 0xFFFF

    # base = 1.0 + 0.5 * v_frac  (in Q16.16)
    base = ONE + (v_frac >> 1)

    # Barrel shift
    shift_amt = abs(v_int)
    if shift_amt > 31:
        return 0                                   # underflow guard

    if v_int < 0:
        result = base >> shift_amt                 # right-shift (always this path in softmax)
    else:
        result = base << shift_amt                 # left-shift  (only when x > 0)

    return q_sat(result)


# ---------------------------------------------------------------------------
# Test-vector sweep — full Q16.16 resolution over the softmax operating range
# ---------------------------------------------------------------------------
#
# The same sweep that the error-analysis runs over (step = 2^-16, one Q16.16
# LSB) is emitted to a .mem file so the *same* 100% coverage is available to:
#   - the unit tb           (shift_exp_tb.sv),
#   - higher-level / top tb (any tb that `\include`s shift_exp_vectors.sv).
#
# x  ∈ [TB_X_MIN, TB_X_MAX], step = 2^-16.
# Number of vectors = (X_MAX_Q - X_MIN_Q) + 1 = 655361 over [-10, 0].
#
# Inputs are derivable from a base/step pair, so only the expected-y table
# is written to disk (≈ 5.6 MB).  shift_exp_expected(x) is then an O(1)
# range check + index lookup — no 655k-entry case statement.
TB_X_MIN = -10.0
TB_X_MAX =   0.0


def emit_vectors_sv(sv_path: Path, in_mem_path: Path, out_mem_path: Path) -> None:
    """
    Emit three files that together form the SV side of `x → shift_exp(x)`:

        sv_path        — `\\\`include`-able header.  Declares the storage
                          (SHIFT_EXP_X, SHIFT_EXP_Y), the loader task, and
                          the lookup functions shift_exp_x_at(i) /
                          shift_exp_expected(x).

        in_mem_path    — `$readmemh`-loadable hex table of input x-values,
                          one Q16.16 word per line.

        out_mem_path   — `$readmemh`-loadable hex table of expected
                          y-values, one Q16.16 word per line.  Row i of
                          *_out.mem is the golden output for row i of
                          *_in.mem.

    Layout matches the existing tcXX_in.mem / tcXX_out.mem convention used
    by softmax_tb.sv, so $readmemh paths and the vectors/ directory layout
    line up across all softmax-related tbs.

    Coverage: x ∈ [TB_X_MIN, TB_X_MAX] at full Q16.16 resolution (step 2^-16).

    Typical use in a tb (the .mem files are read relative to sim cwd):

        `include "shift_exp_vectors.sv"
        ...
        initial begin
            shift_exp_load_vectors();   // 2× $readmemh
            for (int i = 0; i < SHIFT_EXP_NUM; i++) begin
                x = shift_exp_x_at(i); #1;
                if (out !== shift_exp_expected(x)) $fatal;
            end
        end
    """
    x_min_q = to_q(TB_X_MIN)
    x_max_q = to_q(TB_X_MAX)
    n       = x_max_q - x_min_q + 1                     # inclusive

    # ---- Compute the input + expected-y tables --------------------------
    x_words = [(x_min_q + i) & MASK             for i in range(n)]
    y_words = [shift_exp_q(x_min_q + i) & MASK  for i in range(n)]

    # ---- Write the two .mem files (one 32-bit hex word per line) --------
    for path, words, label in (
        (in_mem_path,  x_words, "in "),
        (out_mem_path, y_words, "out"),
    ):
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8") as fp:
            fp.writelines(f"{w:08X}\n" for w in words)
        size_mb = path.stat().st_size / (1024 * 1024)
        print(f"  [mem {label}] {path}  ({n} words, {size_mb:.2f} MB)")

    # ---- Write the .sv header -------------------------------------------
    # $readmemh paths used by tbs — relative to sim cwd, matching the
    # softmax_tb.sv convention ("vectors/tcXX_in.mem", ".../tcXX_out.mem").
    rel_in_mem  = f"vectors/{in_mem_path.name}"
    rel_out_mem = f"vectors/{out_mem_path.name}"

    lines = [
        "// Auto-generated — do not edit.",
        "// Source: py/Softmax/shift_exp.py -v",
        "// Format: Q16.16 signed 32-bit fixed-point, paper eq. 1",
        "//",
        f"// Mapping  x  →  shift_exp(x)  for x ∈ [{TB_X_MIN:.3f}, {TB_X_MAX:.3f}]",
        f"// at full Q16.16 resolution (step 2^-16).  {n} vectors → 100% coverage",
        "// of the softmax operating range, identical to the Python sweep used",
        "// for error analysis.",
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
        "//   localparam int          SHIFT_EXP_NUM",
        "//   localparam logic signed SHIFT_EXP_X_MIN_Q / _MAX_Q / _STEP_Q",
        "//   reg [31:0]              SHIFT_EXP_X [0:SHIFT_EXP_NUM-1]",
        "//   reg [31:0]              SHIFT_EXP_Y [0:SHIFT_EXP_NUM-1]",
        "//   task                    shift_exp_load_vectors()",
        "//   function                shift_exp_x_at(int i)         // → [31:0]",
        "//   function                shift_exp_expected([31:0] x)  // → [31:0]",
        "//",
        "// Example use (inside an `initial` block of any tb):",
        "//",
        "//   shift_exp_load_vectors();",
        "//   for (int i = 0; i < SHIFT_EXP_NUM; i++) begin",
        "//       x = shift_exp_x_at(i); #1;",
        "//       if (out !== shift_exp_expected(x)) $fatal;",
        "//   end",
        "//",
        f"// .mem files: {rel_in_mem}",
        f"//             {rel_out_mem}",
        "// (paths relative to sim cwd, matching softmax_tb.sv)",
        "",
        f"localparam int                 SHIFT_EXP_NUM      = {n};",
        f"localparam logic signed [31:0] SHIFT_EXP_X_MIN_Q  = 32'h{x_min_q & MASK:08X};  // {TB_X_MIN:.3f}",
        f"localparam logic signed [31:0] SHIFT_EXP_X_MAX_Q  = 32'h{x_max_q & MASK:08X};  // {TB_X_MAX:.3f}",
        "localparam logic signed [31:0] SHIFT_EXP_X_STEP_Q = 32'h00000001;  // 2^-16",
        "",
        "// Parallel input / expected-output tables.  Row i of SHIFT_EXP_Y is",
        "// the golden output for row i of SHIFT_EXP_X.",
        "reg [31:0] SHIFT_EXP_X [0:SHIFT_EXP_NUM-1];",
        "reg [31:0] SHIFT_EXP_Y [0:SHIFT_EXP_NUM-1];",
        "",
        "// Load the golden tables from disk.  Call once in `initial`.",
        "task automatic shift_exp_load_vectors;",
        "begin",
        f"    $readmemh(\"{rel_in_mem}\",  SHIFT_EXP_X);",
        f"    $readmemh(\"{rel_out_mem}\", SHIFT_EXP_Y);",
        "end",
        "endtask",
        "",
        "// Returns the i-th input x in the sweep (0 ≤ i < SHIFT_EXP_NUM).",
        "// Reads from SHIFT_EXP_X so it works for any vector layout the .mem",
        "// files happen to contain (contiguous or not).",
        "function automatic [31:0] shift_exp_x_at(input int i);",
        "begin",
        "    shift_exp_x_at = SHIFT_EXP_X[i];",
        "end",
        "endfunction",
        "",
        "// Golden mapping  x → shift_exp(x).",
        "// O(1) lookup: the sweep is contiguous at step = 2^-16, so the index",
        "// is just (x - X_MIN).  Inputs outside the swept range return 32'hx",
        "// so any out-of-coverage check surfaces as an obvious mismatch.",
        "function automatic [31:0] shift_exp_expected(input [31:0] x);",
        "    logic signed [31:0] xs;",
        "    int                 idx;",
        "begin",
        "    xs = $signed(x);",
        "    if (xs < $signed(SHIFT_EXP_X_MIN_Q) || xs > $signed(SHIFT_EXP_X_MAX_Q))",
        "        shift_exp_expected = 32'hxxxxxxxx;",
        "    else begin",
        "        idx = xs - $signed(SHIFT_EXP_X_MIN_Q);  // step = 1 LSB",
        "        shift_exp_expected = SHIFT_EXP_Y[idx];",
        "    end",
        "end",
        "endfunction",
        "",
    ]

    sv_path.parent.mkdir(parents=True, exist_ok=True)
    sv_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"  [SV]  {sv_path}  ({n} vectors)")


# ---------------------------------------------------------------------------
# Reference exponential
# ---------------------------------------------------------------------------

def exp_ref(x: float) -> float:
    """Exact exp(x) via math.exp, clamped to avoid overflow."""
    try:
        return math.exp(x)
    except OverflowError:
        return float('inf')

# ---------------------------------------------------------------------------
# Unit test — sweep & error analysis
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="shift-exp golden model (paper eq.1)")
    parser.add_argument("-x", type=float, default=None,
                        help="Evaluate shift-exp at a single x value")
    parser.add_argument("-v", "--vectors", action="store_true",
                        help="Emit design/Softmax/shift_exp_vectors.sv and exit")
    args = parser.parse_args()

    out_dir = Path(__file__).resolve().parent

    # ---- Vector-emit mode (for SV testbenches) ----
    if args.vectors:
        repo_root    = out_dir.parent.parent
        design_dir   = repo_root / "design" / "Softmax"
        sv_path      = design_dir / "shift_exp_vectors.sv"
        in_mem_path  = design_dir / "vectors" / "shift_exp_in.mem"
        out_mem_path = design_dir / "vectors" / "shift_exp_out.mem"
        emit_vectors_sv(sv_path, in_mem_path, out_mem_path)
        return

    # ---- Single-point mode ----
    if args.x is not None:
        x = args.x
        x_q = to_q(x)
        y_q = shift_exp_q(x_q)
        y_ref = exp_ref(x)
        print(f"\nshift-exp evaluation at x = {x}")
        print("=" * 55)
        print(f"  x_q (hex)          = {to_hex(x_q)}")
        print(f"  shift_exp_q  (f)   = {from_q(y_q):.10f}")
        print(f"  shift_exp_q  (hex) = {to_hex(y_q)}")
        print(f"  exp_ref(x)         = {y_ref:.10f}")
        print(f"  abs error          = {abs(y_ref - from_q(y_q)):.10e}")
        return

    # ---- Sweep mode: x ∈ [-10, 0] step 0.25 ----
    print("shift-exp sweep: x in [-10.0, 0.0], step = 0.25")
    print("=" * 85)
    print(f"{'x':>8s}  {'x_q(hex)':>12s}  {'shift_exp':>12s}  {'exp_ref':>12s}"
          f"  {'abs_err':>12s}  {'rel_err%':>10s}")
    print("-" * 85)

    step = 0.25
    x = -10.0
    while x <= 0.0 + 1e-9:
        x_q  = to_q(x)
        y_q  = shift_exp_q(x_q)
        y_hw = from_q(y_q)
        y_ref = exp_ref(x)
        abs_err = abs(y_ref - y_hw)
        rel_err = (abs_err / max(abs(y_ref), 1e-15)) * 100.0
        print(f"{x:8.4f}  {to_hex(x_q):>12s}  {y_hw:12.8f}  {y_ref:12.8f}"
              f"  {abs_err:12.4e}  {rel_err:10.4f}")
        x += step

    # ---- Fine sweep for MAE calculation: step = 2^-12 over [-10, 0] ----
    STEP = 16   # every 16th Q16.16 value = step ~ 2^-12
    print(f"\nComputing MAE over x in [-10, 0], step = {STEP}/65536 ...")
    total_err = 0.0
    max_err   = 0.0
    max_err_x = 0.0
    count     = 0
    x_q_start = to_q(-10.0)
    x_q_end   = to_q(0.0)
    for x_q in range(x_q_start, x_q_end + 1, STEP):
        y_q   = shift_exp_q(x_q)
        y_hw  = from_q(y_q)
        y_ref = exp_ref(from_q(x_q))
        ae    = abs(y_ref - y_hw)
        total_err += ae
        if ae > max_err:
            max_err   = ae
            max_err_x = from_q(x_q)
        count += 1

    mae = total_err / count
    summary = (
        f"\n{'=' * 55}\n"
        f"shift-exp error summary (x in [-10, 0], step = 2^-12)\n"
        f"{'=' * 55}\n"
        f"  Points evaluated : {count}\n"
        f"  MAE              : {mae:.6e}\n"
        f"  Max abs error    : {max_err:.6e}  at x = {max_err_x:.6f}\n"
        f"  Target           : MAE < 1e-4\n"
        f"  Status           : {'PASS' if mae < 1e-4 else 'FAIL'}\n"
    )
    print(summary)

    (out_dir / "shift_exp_results.txt").write_text(summary, encoding="utf-8")
    print(f"Results written to {out_dir / 'shift_exp_results.txt'}")


if __name__ == "__main__":
    main()
