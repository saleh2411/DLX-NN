#!/usr/bin/env python3
"""
Full Algorithm 3 softmax golden model (ICECS 2025, Hirayae et al.) in Q16.16.

Two-pass online softmax built on shift_exp and pwl_reciprocal:
    Pass 1  m = max(m, x_i);  d = d*shift_exp(m_prev - m) + shift_exp(x_i - m)
    Pass 2  y_j = shift_exp(x_j - m) * pwl_reciprocal(d)

Test vectors come in two groups: hand-crafted deterministic cases covering
dimension / value-bin / dispersion, and random ones. Error is MSE against
exact float64 softmax.

Usage: python3 softmax_golden.py [-d] [-v] [-x V1 V2 ...]
"""

import math
import argparse
import random
from pathlib import Path

from q16_16 import MASK, INT32_MIN, to_q, from_q, to_hex, q_mul, q_sat
from shift_exp import shift_exp_q
from pwl_reciprocal import pwl_recip_q

# numpy was the only heavy dep — it's been replaced with pure Python +
# `random` so this module loads in environments without numpy installed.

# ---------------------------------------------------------------------------
# Exact softmax reference (float64)
# ---------------------------------------------------------------------------

def softmax_exact(x_vec: list[float]) -> list[float]:
    """
    Numerically stable softmax in float64.
    Uses the log-sum-exp trick to avoid overflow.
    """
    m = max(x_vec)
    e = [math.exp(x - m) for x in x_vec]
    s = sum(e)
    return [ei / s for ei in e]

# ---------------------------------------------------------------------------
# Algorithm 3 — Q16.16 golden model
# ---------------------------------------------------------------------------

def softmax_algo3(x_vec: list[float], verbose: bool = False) -> tuple[list[float], list[str]]:
    """
    Full Algorithm 3 in Q16.16 fixed-point.

    Parameters
    ----------
    x_vec : list[float]
        Input logit vector (float).
    verbose : bool
        If True, print intermediate values.

    Returns
    -------
    y_float : list[float]
        Output probabilities converted back to float.
    y_hex : list[str]
        Output probabilities as Q16.16 hex strings.
    """
    N = len(x_vec)

    # Convert inputs to Q16.16
    x_q = [to_q(x) for x in x_vec]

    if verbose:
        print(f"  Input (Q16.16): {[to_hex(xq) for xq in x_q]}")

    # ------------------------------------------------------------------
    # Pass 1: Pre-Norm — find max and accumulate denominator
    # ------------------------------------------------------------------
    m_reg = INT32_MIN                              # m₀ = -∞ = 0x8000_0000
    d_reg = 0                                      # d₀ = 0

    for i in range(N):
        m_prev = m_reg

        # IntMax: full 32-bit signed compare
        if x_q[i] > m_reg:
            m_reg = x_q[i]

        # a = d_prev * shift-exp(m_prev - m_new)
        diff_m = q_sat(m_prev - m_reg)
        se_rescale = shift_exp_q(diff_m)
        a = q_mul(d_reg, se_rescale)

        # b = shift-exp(x_i - m_new)
        diff_x = q_sat(x_q[i] - m_reg)
        b = shift_exp_q(diff_x)

        # d = a + b
        d_reg = q_sat(a + b)

        if verbose:
            print(f"  Pass1[{i}]: m={to_hex(m_reg)} d={to_hex(d_reg)}"
                  f"  se_rescale={to_hex(se_rescale)} a={to_hex(a)} b={to_hex(b)}")

    # ------------------------------------------------------------------
    # Pass 2: Normalization — compute outputs
    # ------------------------------------------------------------------
    recip_d = pwl_recip_q(d_reg)

    if verbose:
        print(f"  After Pass1: m_final={to_hex(m_reg)}"
              f"  d_final={to_hex(d_reg)} ({from_q(d_reg):.6f})"
              f"  recip_d={to_hex(recip_d)} ({from_q(recip_d):.6f})")

    y_q = []
    for j in range(N):
        diff = q_sat(x_q[j] - m_reg)
        fj   = shift_exp_q(diff)
        yj   = q_mul(fj, recip_d)
        y_q.append(yj)

        if verbose:
            print(f"  Pass2[{j}]: diff={to_hex(diff)} f={to_hex(fj)}"
                  f"  y={to_hex(yj)} ({from_q(yj):.6f})")

    y_float = [from_q(yq) for yq in y_q]
    y_hex   = [to_hex(yq) for yq in y_q]

    return y_float, y_hex

# ---------------------------------------------------------------------------
# Error metrics
# ---------------------------------------------------------------------------

def compute_errors(y_hw: list[float], y_ref: list[float]) -> dict:
    """Compute MSE, MAE, max absolute error between hw and reference outputs."""
    diff   = [h - r for h, r in zip(y_hw, y_ref)]
    n      = len(diff) if diff else 1
    mse    = sum(d * d  for d in diff) / n
    mae    = sum(abs(d) for d in diff) / n
    max_ae = max((abs(d) for d in diff), default=0.0)
    return {
        "mse":     mse,
        "mae":     mae,
        "max_ae":  max_ae,
        "sum_hw":  sum(y_hw),
        "sum_ref": sum(y_ref),
    }

# ---------------------------------------------------------------------------
# Test vectors
# ---------------------------------------------------------------------------

# Spec-defined value bins (used to name / classify Group 1 vectors):
#   negative_extreme: [-max, -201]
#   negative_high   : [-200, -11]
#   negative_low    : [-10, 0]
#   positive_low    : [0, 10]
#   positive_high   : [11, 200]
#   positive_extreme: [201, +max]
# Q16.16 safe range is roughly ±32767, so "max" is taken as 32000 in practice.

GROUP2_RANDOM_COUNT = 1000


def build_group1_hardcoded() -> list[dict]:
    """
    Group 1 — Deterministic, hand-crafted tests covering the spec attributes:

      * vector_dimension       — N spans {1, 2, 4, 8, 16, 32, 64}
      * value_bin_distribution — each of the 6 bins exercised alone, plus
                                  multi-bin combinations and bin boundaries
      * value_dispersion       — LOW (tight cluster) and HIGH (wide spread)
                                  variants for every bin

    Capped at 50 tests.
    """
    v = []

    def add(name, x):
        v.append({"name": name, "x": list(x)})

    # ---- 1A: each bin alone, LOW dispersion (tight cluster) ----
    add("bin neg_extreme  N=8  LOW",  [-500.0 + 0.5 * i for i in range(8)])
    add("bin neg_high     N=8  LOW",  [-100.0 + 0.2 * i for i in range(8)])
    add("bin neg_low      N=8  LOW",  [  -5.0 + 0.1 * i for i in range(8)])
    add("bin pos_low      N=8  LOW",  [   5.0 + 0.1 * i for i in range(8)])
    add("bin pos_high     N=8  LOW",  [ 100.0 + 0.2 * i for i in range(8)])
    add("bin pos_extreme  N=8  LOW",  [ 500.0 + 0.5 * i for i in range(8)])

    # ---- 1B: each bin alone, HIGH dispersion (span the bin) ----
    add("bin neg_extreme  N=8  HIGH", [-32000, -10000, -5000, -2000,
                                       -1000,  -500,  -300,   -202])
    add("bin neg_high     N=8  HIGH", [-200, -150, -100, -60, -40, -25, -15, -11])
    add("bin neg_low      N=8  HIGH", [ -10,  -8,  -6,  -4,  -3,  -2,  -1,   0])
    add("bin pos_low      N=8  HIGH", [   0,   1,   2,   3,   4,   6,   8,  10])
    add("bin pos_high     N=8  HIGH", [  11,  15,  25,  40,  60, 100, 150, 200])
    add("bin pos_extreme  N=8  HIGH", [ 202,  300,  500, 1000,
                                        2000, 5000, 10000, 32000])

    # ---- 1C: multi-bin distributions ----
    add("all 6 bins symmetric  N=6", [-500, -100, -5, 5, 100, 500])
    add("bimodal extremes      N=8", [-500, -500, -500, -500, 500, 500, 500, 500])
    add("bin boundaries        N=9", [-201, -200, -11, -10, 0, 10, 11, 200, 201])
    add("neg dominant          N=7", [-500, -100, -50, -10, -5, 0, 1])
    add("pos dominant          N=7", [ -1, 0, 5, 10, 50, 100, 500])
    add("half neg / half pos   N=8", [-5, -5, -5, -5, 5, 5, 5, 5])
    add("step across bins      N=12",[-250, -150, -50, -20, -5, -1,
                                        1,    5,  20,  50, 150, 250])
    add("alt extremes          N=8", [-500, 500, -500, 500, -500, 500, -500, 500])
    add("alt highs             N=8", [-100, 100, -100, 100, -100, 100, -100, 100])
    add("alt lows              N=8", [  -5,   5,   -5,   5,   -5,   5,   -5,   5])
    add("zeros + one extreme   N=8", [0, 0, 0, 0, 0, 0, 0,  500])
    add("zeros + one neg_extr  N=8", [0, 0, 0, 0, 0, 0, 0, -500])

    # ---- 1D: dispersion-focused (variance extremes) ----
    add("zero variance        N=8",  [0.0]   * 8)
    add("equal pos            N=8",  [5.0]   * 8)
    add("equal neg            N=8",  [-5.0]  * 8)
    add("tight 100 ±0.01      N=8",  [100.0 + 0.01 * (i - 4) for i in range(8)])
    add("wide -300..400       N=8",  [-300.0 + 100.0 * i for i in range(8)])
    add("very wide -32k..32k  N=4",  [-32000.0, -1.0, 1.0, 32000.0])

    # ---- 1E: vector-dimension sweep ----
    add("N=1  single positive",            [3.5])
    add("N=2  cross bins",                 [-100.0, 100.0])
    add("N=4  across all bin signs",       [-500.0, -10.0, 10.0, 500.0])
    add("N=16 wide cross-bin sweep",       [-300.0 + 40.0 * i for i in range(16)])
    add("N=32 ascending across bins",      [-100.0 + 6.5  * i for i in range(32)])
    add("N=64 alternating extremes",       [200.0 if i % 2 else -200.0
                                            for i in range(64)])

    # ---- 1F: classic / edge cases ----
    add("one_hot start            N=8",    [500.0] + [0.0] * 7)
    add("one_hot end              N=8",    [0.0] * 7 + [500.0])
    add("one_hot middle           N=16",   [0.0] * 8 + [500.0] + [0.0] * 7)
    add("ascending                N=8",    [i - 3.5 for i in range(8)])
    add("descending               N=8",    [3.5 - i for i in range(8)])
    add("uniform                  N=8",    [2.0] * 8)
    add("near uniform             N=8",    [2.0, 2.001, 1.999, 2.005,
                                            1.995, 2.003, 1.997, 2.0])
    add("boundary -201            N=4",    [-201.0] * 4)
    add("boundary +201            N=4",    [ 201.0] * 4)
    add("boundary -11 / -10",              [-11.0, -10.0, -11.0, -10.0])
    add("boundary +10 / +11",              [ 10.0,  11.0,  10.0,  11.0])
    add("Q16.16 range edges       N=2",    [32000.0, -32000.0])
    add("alt low                  N=16",   [3.0 if i % 2 else -3.0
                                            for i in range(16)])
    add("alt high                 N=16",   [150.0 if i % 2 else -150.0
                                            for i in range(16)])

    return v[:50]   # enforce the 50-test cap from the spec


def build_group2_random(n_tests: int = GROUP2_RANDOM_COUNT) -> list[dict]:
    """
    Group 2 — Fully non-deterministic random tests.

    Uses random.SystemRandom() (OS entropy); each invocation produces
    different vectors.  The Python golden output for these vectors is
    re-emitted into the .mem / .sv files on every `-v` run.

    Each vector:
      * N         ~ uniform[1, 500]
      * center    ~ uniform[-500, 500]
      * width     ~ uniform[0, 1000]
      * element   ~ uniform within [center-width/2, center+width/2]
                    (clamped to Q16.16 safe range)
    """
    rng = random.SystemRandom()
    vectors = []
    for k in range(n_tests):
        N      = rng.randint(1, 500)
        center = rng.uniform(-500.0, 500.0)
        width  = rng.uniform(0.0, 1000.0)
        lo     = max(center - width / 2.0, -32000.0)
        hi     = min(center + width / 2.0,  32000.0)
        if hi < lo:
            lo, hi = hi, lo
        x = [rng.uniform(lo, hi) for _ in range(N)]
        vectors.append({"name": f"rand-{k:03d} N={N:2d}", "x": x})
    return vectors


def build_test_vectors() -> list[dict]:
    """Group 1 (hardcoded, ≤50) followed by Group 2 (truly random)."""
    return build_group1_hardcoded() + build_group2_random()


# ---------------------------------------------------------------------------
# SV / .mem emission — `-v` flag, mirrors shift_exp / pwl_reciprocal pattern
# ---------------------------------------------------------------------------

def _to_signed32(v: int) -> int:
    """Re-interpret unsigned 32-bit as signed (two's complement)."""
    return v - 0x1_0000_0000 if v >= 0x8000_0000 else v


def _q_from_hex(h: str) -> int:
    """Parse '0xXXXXXXXX' string → signed Q16.16 int."""
    return _to_signed32(int(h, 16))


def emit_vectors_sv(sv_path: Path, mem_dir: Path) -> None:
    """
    Emit the SV side of the softmax_subenv golden vectors:

        sv_path        — `\\\`include`-able header.  Declares storage,
                          per-test metadata, and the loader/lookup tasks.

        mem_dir/tc{i:02d}_in.mem    — Q16.16 input vector for test i
        mem_dir/tc{i:02d}_out.mem   — Q16.16 expected output for test i
                                       (one 32-bit hex word per line)

    Layout matches the in/out mem-pair convention used by shift_exp /
    pwl_reciprocal, but unlike those, softmax has 15 *variable-length*
    test cases — so each test gets its own pair of files instead of a
    single concatenated table.

    Typical use in a tb (mem files read relative to sim cwd):

        `include "softmax_vectors.sv"
        ...
        initial begin
            softmax_init_meta();
            for (int i = 0; i < SOFTMAX_NUM_TESTS; i++) begin
                softmax_load_test(i);
                // stage SOFTMAX_X[0..SOFTMAX_N-1] into SRAM, drive DUT,
                // then bit-exact-compare DUT output to SOFTMAX_Y_EXP.
            end
        end
    """
    # ---- Run the golden model on every test vector ----------------------
    results = []
    for tv in build_test_vectors():
        name = tv["name"]
        x    = tv["x"]
        N    = len(x)

        x_q          = [to_q(xi) for xi in x]
        _, y_hex     = softmax_algo3(x)            # bit-exact Q16.16 output
        y_q          = [_q_from_hex(h) for h in y_hex]

        results.append({
            "name": name,
            "N":    N,
            "x_q":  x_q,
            "y_q":  y_q,
        })

    num_tests = len(results)
    max_n     = max(r["N"] for r in results)

    # ---- Write per-test .mem files --------------------------------------
    mem_dir.mkdir(parents=True, exist_ok=True)
    for i, r in enumerate(results):
        in_path  = mem_dir / f"tc{i:02d}_in.mem"
        out_path = mem_dir / f"tc{i:02d}_out.mem"
        in_path.write_text(
            "".join(f"{v & MASK:08X}\n" for v in r["x_q"]),
            encoding="utf-8")
        out_path.write_text(
            "".join(f"{v & MASK:08X}\n" for v in r["y_q"]),
            encoding="utf-8")
        print(f"  [mem] tc{i:02d}_in.mem  tc{i:02d}_out.mem  "
              f"(N={r['N']:2d})  {r['name']}")

    # ---- Write the .sv header -------------------------------------------
    # Path used by $readmemh inside softmax_load_test — relative to sim
    # cwd, matching the existing softmax_tb.sv / shift_exp / pwl convention.
    rel_mem_dir = f"vectors/{mem_dir.name}"

    lines = [
        "// Auto-generated — do not edit.",
        "// Source: py/Softmax/softmax_golden.py -v",
        "// Format: Q16.16 signed 32-bit fixed-point, Algorithm 3",
        "//",
        f"// {num_tests} test cases, MAX_N = {max_n}.  Each test is a vector of",
        "// length N (variable), stored as a parallel pair of `.mem` files",
        f"// under {rel_mem_dir}/  — one pair per test case:",
        "//   tc{idx:02d}_in.mem    Q16.16 input vector",
        "//   tc{idx:02d}_out.mem   Q16.16 expected output",
        "//",
        "// `\\`include`-able from inside any tb module so the same golden",
        "// vectors can be checked at the unit, sub-env, and top-model level.",
        "//",
        "// Provides:",
        "//   localparam int SOFTMAX_NUM_TESTS",
        "//   localparam int SOFTMAX_MAX_N",
        "//   reg [10:0]     SOFTMAX_TC_N      [0:SOFTMAX_NUM_TESTS-1]",
        "//   reg [31:0]     SOFTMAX_X         [0:SOFTMAX_MAX_N-1]",
        "//   reg [31:0]     SOFTMAX_Y_EXP     [0:SOFTMAX_MAX_N-1]",
        "//   integer        SOFTMAX_N         // length of currently-loaded test",
        "//   task           softmax_init_meta()              // populate SOFTMAX_TC_N",
        "//   task           softmax_load_test(int idx)       // $readmemh test idx",
        "//   function       softmax_test_name(int idx) → string",
        "//",
        "// Example use (inside an `initial` block of any tb):",
        "//",
        "//   softmax_init_meta();",
        "//   for (int i = 0; i < SOFTMAX_NUM_TESTS; i++) begin",
        "//       softmax_load_test(i);",
        "//       // stage SOFTMAX_X into SRAM, drive DUT, wait done",
        "//       // compare sram[OUT_BASE..] against SOFTMAX_Y_EXP[0..SOFTMAX_N-1]",
        "//   end",
        "",
        f"localparam int SOFTMAX_NUM_TESTS = {num_tests};",
        f"localparam int SOFTMAX_MAX_N     = {max_n};",
        "",
        "// Length of each test case (vector size N).  Populated by softmax_init_meta.",
        "reg [10:0] SOFTMAX_TC_N [0:SOFTMAX_NUM_TESTS-1];",
        "",
        "// Storage for the currently-loaded test case.  Filled by softmax_load_test.",
        "reg [31:0] SOFTMAX_X      [0:SOFTMAX_MAX_N-1];",
        "reg [31:0] SOFTMAX_Y_EXP  [0:SOFTMAX_MAX_N-1];",
        "integer    SOFTMAX_N;",
        "",
        "// Populate SOFTMAX_TC_N.  Call once at the top of `initial`.",
        "task automatic softmax_init_meta;",
        "begin",
    ]
    for i, r in enumerate(results):
        lines.append(
            f"    SOFTMAX_TC_N[{i:2d}] = {r['N']:2d};  // {r['name']}"
        )
    lines += [
        "end",
        "endtask",
        "",
        "// Load test idx from disk:  reads the in/out mem pair, sets SOFTMAX_N.",
        "task automatic softmax_load_test(input int idx);",
        "    string fn_in;",
        "    string fn_out;",
        "begin",
        "    SOFTMAX_N = SOFTMAX_TC_N[idx];",
        f"    $sformat(fn_in,  \"{rel_mem_dir}/tc%02d_in.mem\",  idx);",
        f"    $sformat(fn_out, \"{rel_mem_dir}/tc%02d_out.mem\", idx);",
        "    $readmemh(fn_in,  SOFTMAX_X,     0, SOFTMAX_N - 1);",
        "    $readmemh(fn_out, SOFTMAX_Y_EXP, 0, SOFTMAX_N - 1);",
        "end",
        "endtask",
        "",
        "// Human-readable test name (handy for log lines / waveform annotation).",
        "function automatic string softmax_test_name(input int idx);",
        "begin",
        "    case (idx)",
    ]
    for i, r in enumerate(results):
        safe_name = r["name"].replace('"', '\\"')
        lines.append(
            f"        {i:2d}: softmax_test_name = \"{safe_name}\";"
        )
    lines += [
        "        default: softmax_test_name = \"<unknown>\";",
        "    endcase",
        "end",
        "endfunction",
        "",
    ]

    sv_path.parent.mkdir(parents=True, exist_ok=True)
    sv_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"  [SV]  {sv_path}  ({num_tests} test cases, MAX_N={max_n})")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Softmax Algorithm 3 golden model")
    parser.add_argument("-v", "--vectors", action="store_true",
                        help="Emit design/Softmax/softmax_vectors.sv "
                             "+ vectors/softmax/tcXX_*.mem and exit")
    parser.add_argument("-d", "--detail", action="store_true",
                        help="Print per-element trace for each test vector")
    parser.add_argument("-x", "--custom", nargs="+", type=float,
                        metavar="VAL",
                        help="Run on a custom input vector, e.g. -x 1.0 2.0 3.0")
    args = parser.parse_args()

    out_dir = Path(__file__).resolve().parent

    # ---- Custom vector mode ----
    if args.custom:
        x = args.custom
        N = len(x)
        print(f"\n--- Custom vector (N={N}) ---")
        print(f"  x = {[f'{v:.4f}' for v in x]}")
        y_hw, y_hex = softmax_algo3(x, verbose=args.detail)
        y_ref = softmax_exact(x)
        errs  = compute_errors(y_hw, y_ref)
        print(f"\n  {'Element':>8s}  {'y_hw':>12s}  {'y_ref':>12s}  {'y_hex':>12s}  {'abs_err':>12s}")
        print(f"  {'-'*62}")
        for j in range(N):
            ae = abs(y_hw[j] - y_ref[j])
            print(f"  {j:8d}  {y_hw[j]:12.6f}  {y_ref[j]:12.6f}  {y_hex[j]:>12s}  {ae:12.6e}")
        print(f"\n  Sum y_hw  = {errs['sum_hw']:.6f}   (ideal = 1.0)")
        print(f"  Sum y_ref = {errs['sum_ref']:.6f}")
        print(f"  MSE     = {errs['mse']:.6e}")
        print(f"  MAE     = {errs['mae']:.6e}")
        print(f"  Max AE  = {errs['max_ae']:.6e}")
        return

    # ---- Vector-emit mode (for SV testbenches) ----
    if args.vectors:
        repo_root  = out_dir.parent.parent
        design_dir = repo_root / "design" / "Softmax"
        sv_path    = design_dir / "softmax_vectors.sv"
        mem_dir    = design_dir / "vectors" / "softmax"
        emit_vectors_sv(sv_path, mem_dir)
        return

    vectors = build_test_vectors()
    verbose = args.detail

    MSE_TARGET = 0.025

    print("=" * 90)
    print("Softmax Algorithm 3 -- Q16.16 Golden Model vs Exact Float64")
    print("=" * 90)

    all_pass    = True
    all_mse     = []
    report_lines = []

    for idx, tv in enumerate(vectors):
        name = tv["name"]
        x    = tv["x"]
        N    = len(x)

        print(f"\n--- Test {idx}: {name} (N={N}) ---")
        if verbose:
            print(f"  x = {[f'{v:.4f}' for v in x]}")

        # Golden model (Q16.16)
        y_hw, y_hex = softmax_algo3(x, verbose=verbose)

        # Exact reference (float64)
        y_ref = softmax_exact(x)

        # Error metrics
        errs = compute_errors(y_hw, y_ref)

        status = "PASS" if errs["mse"] <= MSE_TARGET else "FAIL"
        if errs["mse"] > MSE_TARGET:
            all_pass = False
        all_mse.append(errs["mse"])

        # Print results
        print(f"  {'Element':>8s}  {'y_hw':>12s}  {'y_ref':>12s}  {'y_hex':>12s}  {'abs_err':>12s}")
        print(f"  {'-'*62}")
        for j in range(N):
            ae = abs(y_hw[j] - y_ref[j])
            print(f"  {j:8d}  {y_hw[j]:12.6f}  {y_ref[j]:12.6f}  {y_hex[j]:>12s}  {ae:12.6e}")

        print(f"\n  Sum y_hw  = {errs['sum_hw']:.6f}   (ideal = 1.0)")
        print(f"  Sum y_ref = {errs['sum_ref']:.6f}")
        print(f"  MSE     = {errs['mse']:.6e}")
        print(f"  MAE     = {errs['mae']:.6e}")
        print(f"  Max AE  = {errs['max_ae']:.6e}")
        print(f"  Status  = {status}")

        report_lines.append(
            f"Test {idx:2d} | {name:30s} | N={N:2d} | "
            f"MSE={errs['mse']:.4e} | MAE={errs['mae']:.4e} | "
            f"MaxAE={errs['max_ae']:.4e} | Sum_hw={errs['sum_hw']:.4f} | {status}"
        )

    # ------------------------------------------------------------------
    # Summary
    # ------------------------------------------------------------------
    avg_mse = sum(all_mse) / len(all_mse) if all_mse else 0.0
    max_mse = max(all_mse) if all_mse else 0.0

    summary_header = (
        f"\n{'=' * 90}\n"
        f"SOFTMAX GOLDEN MODEL -- TEST SUMMARY\n"
        f"{'=' * 90}\n"
        f"MSE target  : <= {MSE_TARGET}\n"
        f"Avg MSE     : {avg_mse:.6e}\n"
        f"Max MSE     : {max_mse:.6e}\n"
        f"Overall     : {'ALL PASS' if all_pass else 'SOME FAILED'}\n"
        f"{'=' * 90}\n"
    )
    print(summary_header)
    for line in report_lines:
        print(line)
    print()

    # Save report
    report = summary_header + "\n".join(report_lines) + "\n"
    (out_dir / "softmax_golden_results.txt").write_text(report, encoding="utf-8")
    print(f"Report written to {out_dir / 'softmax_golden_results.txt'}")


if __name__ == "__main__":
    main()
