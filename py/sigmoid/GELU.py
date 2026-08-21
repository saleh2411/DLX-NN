#!/usr/bin/env python3
"""
GELU in Q16.16 fixed-point.

Approximates GELU(x) = 0.5*x*(1 + erf(x/sqrt(2))) as GELU0(x) = x * sigmoid0(1.702x),
where 1.702 is applied as a shift-add chain (no multiplier) and sigmoid0 comes
from sigmoid.py. Sweeps x in [-5,5] and writes error plots + gelu.txt.

Usage: python GELU.py [-x VALUE] [-v]
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import argparse

from sigmoid import (
    SCALE,
    float_to_q16_16,
    q_mul,
    sigmoid0_q16_16,
    tb_vectors,
)

# ============================================================
# 1) Exact GELU (erf form)
# ============================================================
def gelu_ref(x: float) -> float:
    return 0.5 * x * (1.0 + math.erf(x / math.sqrt(2.0)))

# ============================================================
# 2) GELU0(x) = x * sigmoid0(1.702x) in Q16.16
#    1.702 replaced by shift-add to match hardware (no multiplier):
#    1 + 1/2 + 1/8 + 1/16 + 1/64 + 1/256 = 1.70703125
# ============================================================
def gelu0_q16_16(x_q: int) -> int:
    # Python's >> on negative ints is arithmetic shift (matches Verilog >>>).
    kx_q = x_q + (x_q >> 1) + (x_q >> 3) + (x_q >> 4) + (x_q >> 6) + (x_q >> 8)
    s0_q = sigmoid0_q16_16(kx_q)        # Q16.16 in [0,1]
    return q_mul(x_q, s0_q)             # Q16.16


# ============================================================
# 3) Sweep + plots + summary (same style as sigmoid.py)
# ============================================================
def main():
    parser = argparse.ArgumentParser(description="GELU approximation analysis (exact GELU vs GELU0 using sigmoid0)")
    parser.add_argument("-x", type=float, help="Evaluate GELU at specific x value")
    parser.add_argument("-v", "--vectors", action="store_true", help="Generate SystemVerilog test vectors")
    args = parser.parse_args()

    # Only open tb file if -v flag is passed
    tb = None
    if args.vectors:
        tb = open("gelu_vectors.sv", "w")
        tb.write("// Auto-generated test vectors for GELU\n")
        tb.write("// Expected values from gelu0_q16_16 (x * sigmoid0(1.702x))\n")
        tb.write("// Format: check_result(x_input, expected_output)\n\n")

    out_dir = Path(__file__).resolve().parent

    # --------------------------------------------------------
    # Single-point evaluation
    # --------------------------------------------------------
    if args.x is not None:
        x = args.x
        x_q = float_to_q16_16(x)

        y_ref = gelu_ref(x)
        y0 = gelu0_q16_16(x_q) / SCALE

        print(f"\nGELU evaluation at x = {x}")
        print("=" * 50)
        print(f"gelu_ref(x) = {y_ref:.15f}")
        print(f"gelu0(x)    = {y0:.15f}")
        print(f"\nAbsolute error:")
        print(f"  |ref - gelu0| = {abs(y_ref - y0):.15f}")
        return

    # --------------------------------------------------------
    # Reasonable range for GELU: [-5,5] with step 2^-16
    # --------------------------------------------------------
    X_MIN = -5.0
    X_MAX =  5.0

    x_q_vals = np.arange(
        float_to_q16_16(X_MIN),
        float_to_q16_16(X_MAX) + 1,
        dtype=np.int64
    )
    x_vals = x_q_vals / SCALE

    # Compute exact and approx arrays
    y_ref_vals = np.array([gelu_ref(float(x)) for x in x_vals], dtype=np.float64)
    y0_vals = np.array([gelu0_q16_16(int(xq)) / SCALE for xq in x_q_vals], dtype=np.float64)

    # Errors
    err_abs = np.abs(y_ref_vals - y0_vals)

    # ---------------- FIX: use % of Full-Scale ----------------
    # Full-scale is the max magnitude of exact GELU over the sweep.
    FS = float(np.max(np.abs(y_ref_vals)))
    FS = max(FS, 1e-12)
    err_pct_fs = (err_abs / FS) * 100.0

    # Optional: a "clamped relative %" that won’t explode near 0
    DEN_CLAMP = 0.7
    err_pct_rel_clamped = (err_abs / np.maximum(np.abs(y_ref_vals), DEN_CLAMP)) * 100.0

    # --------------------------------------------------------
    # Write test vectors (expected = gelu0_q16_16)
    # --------------------------------------------------------
    if tb is not None:
        for xq in x_q_vals:
            tb_vectors(int(xq), int(gelu0_q16_16(int(xq))), tb)

    # --------------------------------------------------------
    # Plot 1: Absolute error
    # --------------------------------------------------------
    plt.figure()
    plt.plot(x_vals, err_abs)
    plt.title("GELU absolute error (GELU0 vs exact)")
    plt.xlabel("x")
    plt.ylabel("absolute error")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(out_dir / "gelu_abs_error.png", dpi=1300)
    plt.close()

    # --------------------------------------------------------
    # Plot 2: Percentage error (FIXED) = %FS
    # --------------------------------------------------------
    plt.figure()
    plt.plot(x_vals, err_pct_fs, label="%FS error")
    plt.title("GELU percentage error (% of full-scale)")
    plt.xlabel("x")
    plt.ylabel("percentage error (%FS)")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "gelu_pct_error.png", dpi=1300)
    plt.close()

    # (Optional extra plot) clamped-relative % (useful for debug)
    plt.figure()
    plt.plot(x_vals, err_pct_rel_clamped)
    plt.title(f"GELU clamped relative % error (denom clamp = {DEN_CLAMP})")
    plt.xlabel("x")
    plt.ylabel("percentage error (%)")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(out_dir / "gelu_pct_error_clamped.png", dpi=1300)
    plt.close()

    # --------------------------------------------------------
    # Plot 3: Function comparison
    # --------------------------------------------------------
    plt.figure()
    plt.plot(x_vals, y_ref_vals, label="GELU exact", linewidth=2)
    plt.plot(x_vals, y0_vals, label="GELU0 (x·sigmoid0)", alpha=0.85)
    plt.title("GELU vs GELU0")
    plt.xlabel("x")
    plt.ylabel("GELU(x)")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(out_dir / "gelu_functions.png", dpi=1300)
    plt.close()

    # --------------------------------------------------------
    # Text summary (same style as sigmoid.py)
    # --------------------------------------------------------
    avg_abs = float(err_abs.mean())
    max_abs = float(err_abs.max())
    x_at_max_abs = float(x_vals[int(err_abs.argmax())])

    avg_pct_fs = float(err_pct_fs.mean())
    max_pct_fs = float(err_pct_fs.max())
    x_at_max_pct_fs = float(x_vals[int(err_pct_fs.argmax())])

    txt = (
        "GELU approximation error summary (x in [-5,5], step = 2^-16)\n"
        "===========================================================\n\n"
        "Notes:\n"
        "  Percentage error is reported as % of full-scale (FS), not relative-to-y.\n"
        f"  FS = max(|GELU_exact(x)|) over sweep = {FS:.12f}\n\n"
        "Averages:\n"
        f"  Avg abs error (gelu0): {avg_abs:.12f}\n"
        f"  Avg %FS error (gelu0): {avg_pct_fs:.12f} %\n\n"
        "Maximums:\n"
        f"  Max abs error (gelu0): {max_abs:.12f} at x={x_at_max_abs:.6f}\n"
        f"  Max %FS error (gelu0): {max_pct_fs:.12f} % at x={x_at_max_pct_fs:.6f}\n"
    )

    (out_dir / "gelu.txt").write_text(txt, encoding="utf-8")

    if tb is not None:
        tb.close()
        print(f"Generated gelu_vectors.sv with {len(x_q_vals)} test vectors")


if __name__ == "__main__":
    main()