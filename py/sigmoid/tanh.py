#!/usr/bin/env python3
"""
tanh in Q16.16 fixed-point via the identity tanh(x) = 2*sigmoid(2x) - 1.

Two variants, both from sigmoid.py: tanh0 uses the piecewise-linear sigmoid0
(shift-only, no multiplier), tanh uses the refined sigmoid. Negative inputs use
the symmetry sigma(-z) = 1 - sigma(z). Sweeps x in [-4,4] and writes error
plots + tanh.txt.

Usage: python tanh.py [-x VALUE] [-v]
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import argparse

from sigmoid import ONE, SCALE, sigmoid, sigmoid0_q16_16, tb_vectors


def clamp_q(x_q: int, lo_q: int, hi_q: int) -> int:
    if x_q < lo_q:
        return lo_q
    if x_q > hi_q:
        return hi_q
    return x_q

def tanh_ref(x: float) -> float:
    return math.tanh(x)

# ------------------------------------------------------------
# tanh(x) using sigmoid: tanh(x) ≈ 2*sigma(2x) - 1
# handle negative via sigma(-z)=1-sigma(z)
# ------------------------------------------------------------
def tanh_from_sigmoid_q16_16(x_q: int) -> int:
    z_q = 2 * x_q  # z = 2x (still Q16.16)

    if z_q >= 0:
        s_q = sigmoid(z_q)
    else:
        s_q = ONE - sigmoid(-z_q)  # sigma(-z)=1-sigma(z)

    out_q = (2 * s_q) - ONE
    return clamp_q(out_q, -ONE, ONE)

# ------------------------------------------------------------
# tanh_0(x) using sigmoid_0: tanh_0(x) ≈ 2*sigma0(2x) - 1
# handle negative via sigma0(-z)=1-sigma0(z)
# ------------------------------------------------------------
def tanh0_from_sigmoid0_q16_16(x_q: int) -> int:
    z_q = 2 * x_q  # z = 2x (still Q16.16)

    if z_q >= 0:
        s0_q = sigmoid0_q16_16(z_q)
    else:
        s0_q = ONE - sigmoid0_q16_16(-z_q)

    out_q = (2 * s0_q) - ONE
    return clamp_q(out_q, -ONE, ONE)

def main():
    parser = argparse.ArgumentParser(description="tanh approximation analysis")
    parser.add_argument("-x", type=float, help="Evaluate tanh at specific x value")
    parser.add_argument("-v", "--vectors", action="store_true", help="Generate test vectors file")
    args = parser.parse_args()

    out_dir = Path(__file__).resolve().parent

    # Only open tb file if -v flag is passed
    tb = None
    if args.vectors:
        tb = open("tanh_vectors.sv", "w")
        tb.write("// Auto-generated test vectors for tanh testbench (5-segment)\n")


    # If -x is provided, just compute and print the values
    if args.x is not None:
        x = args.x
        x_q = int(x * SCALE)
        
        y_ref = tanh_ref(x)
        y0 = tanh0_from_sigmoid0_q16_16(x_q) / SCALE
        y1 = tanh_from_sigmoid_q16_16(x_q) / SCALE
        
        print(f"\ntanh evaluation at x = {x}")
        print("=" * 50)
        print(f"tanh_ref(x)  = {y_ref:.15f}")
        print(f"tanh0(x)     = {y0:.15f}")
        print(f"tanh(x)      = {y1:.15f}")
        print(f"\nAbsolute errors:")
        print(f"  |ref - tanh0| = {abs(y_ref - y0):.15f}")
        print(f"  |ref - tanh|  = {abs(y_ref - y1):.15f}")
        return

    # Sweep x in [-4, 4] with step 2^-16 (1 LSB in Q16.16)
    start_q = -4 * SCALE
    end_q   =  4 * SCALE
    x_q_vals = np.arange(start_q, end_q + 1, dtype=np.int64)
    x_vals = x_q_vals / SCALE

    err_abs_tanh0 = np.empty_like(x_vals, dtype=np.float64)
    err_abs_tanh  = np.empty_like(x_vals, dtype=np.float64)

    err_pct_tanh0 = np.empty_like(x_vals, dtype=np.float64)
    err_pct_tanh  = np.empty_like(x_vals, dtype=np.float64)

    EPS_REF = 0.01  # threshold: if |tanh_ref| < 0.01, use absolute error instead of %
    
    near_zero_logs = []  # collect messages for points near x=0

    for i, x_q in enumerate(x_q_vals):
        x = x_q / SCALE
        y_ref = tanh_ref(x)

        y0_q = tanh0_from_sigmoid0_q16_16(int(x_q))
        y1_q = tanh_from_sigmoid_q16_16(int(x_q))
        
        y0 = y0_q / SCALE
        y1 = y1_q / SCALE

        tb_vectors(x_q, y0_q, tb)

        e0 = abs(y_ref - y0)
        e1 = abs(y_ref - y1)

        err_abs_tanh0[i] = e0
        err_abs_tanh[i]  = e1

        # Handle percentage error: if reference is too small, percentage is meaningless
        # For |tanh(x)| < 0.01, use absolute error scaled to percentage range
        if abs(y_ref) < EPS_REF:
            # Collect diagnostic for points very close to x=0
            if abs(x) < 0.001:
                near_zero_logs.append(f"Note: x ≈ 0 detected (x={x:.10f}), tanh_ref={y_ref:.10f}")
                near_zero_logs.append(f"      Absolute errors: tanh0={e0:.10f}, tanh={e1:.10f}")
            # Use absolute error directly (scaled to look reasonable on % plot)
            err_pct_tanh0[i] = e0 * 100.0
            err_pct_tanh[i]  = e1 * 100.0
        else:
            err_pct_tanh0[i] = (e0 / abs(y_ref)) * 100.0
            err_pct_tanh[i]  = (e1 / abs(y_ref)) * 100.0

    # ---------------- Plot 1: ABS error (two curves) ----------------
    plt.figure()
    plt.plot(x_vals, err_abs_tanh0, label="|tanh_ref - tanh0 (via sigmoid0)|")
    plt.plot(x_vals, err_abs_tanh,  label="|tanh_ref - tanh  (via sigmoid )|")
    plt.title("tanh absolute error on [-4,4] (step = 2^-16)")
    plt.xlabel("x")
    plt.ylabel("absolute error")
    plt.xlim(-4, 4)
    plt.legend(loc="upper right", bbox_to_anchor=(0.99, 0.99), framealpha=0.9)
    plt.tight_layout()
    plt.savefig(out_dir / "tanh_abs_error.png", dpi=1300)
    plt.close()

    # ---------------- Plot 2: % error (two curves) ------------------
    plt.figure()
    plt.plot(x_vals, err_pct_tanh0, label="% error vs tanh0 (via sigmoid0)")
    plt.plot(x_vals, err_pct_tanh,  label="% error vs tanh  (via sigmoid )")
    plt.title("tanh percentage error on [-4,4] (step = 2^-16)")
    plt.xlabel("x")
    plt.ylabel("percentage error (%)")
    plt.xlim(-4, 4)
    plt.legend(loc="upper right", bbox_to_anchor=(0.99, 0.99), framealpha=0.9)
    plt.tight_layout()
    plt.savefig(out_dir / "tanh_pct_error.png", dpi=1300)
    plt.close()

    # ---------------- Plot 3: Actual function graphs ----------------
    y_ref_vals = np.array([tanh_ref(x) for x in x_vals])
    y0_vals = np.array([tanh0_from_sigmoid0_q16_16(int(x_q)) / SCALE for x_q in x_q_vals])
    y1_vals = np.array([tanh_from_sigmoid_q16_16(int(x_q)) / SCALE for x_q in x_q_vals])
    
    plt.figure()
    plt.plot(x_vals, y_ref_vals, label="tanh_ref (exact)", linewidth=2)
    plt.plot(x_vals, y0_vals, label="tanh0 (via sigmoid0)", alpha=0.8)
    plt.plot(x_vals, y1_vals, label="tanh (via sigmoid)", alpha=0.8)
    plt.title("tanh function comparison on [-4,4]")
    plt.xlabel("x")
    plt.ylabel("tanh(x)")
    plt.xlim(-4, 4)
    plt.ylim(-1.05, 1.05)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(out_dir / "tanh_functions.png", dpi=1300)
    plt.close()

    # ---------------- tanh.txt (same style as sigmoid.txt) ----------
    avg_abs_0 = float(err_abs_tanh0.mean())
    avg_abs_1 = float(err_abs_tanh.mean())
    avg_pct_0 = float(err_pct_tanh0.mean())
    avg_pct_1 = float(err_pct_tanh.mean())

    max_abs_0 = float(err_abs_tanh0.max())
    max_abs_1 = float(err_abs_tanh.max())
    max_pct_0 = float(err_pct_tanh0.max())
    max_pct_1 = float(err_pct_tanh.max())

    x_at_max_abs_0 = float(x_vals[int(err_abs_tanh0.argmax())])
    x_at_max_abs_1 = float(x_vals[int(err_abs_tanh.argmax())])

    txt = (
        "tanh approximation error summary (x in [-4,4], step = 2^-16)\n"
        "===========================================================\n\n"
        "Averages:\n"
        f"  Avg abs error (tanh0): {avg_abs_0:.12f}\n"
        f"  Avg abs error (tanh ): {avg_abs_1:.12f}\n"
        f"  Avg %   error (tanh0): {avg_pct_0:.12f} %\n"
        f"  Avg %   error (tanh ): {avg_pct_1:.12f} %\n\n"
        "Maximums:\n"
        f"  Max abs error (tanh0): {max_abs_0:.12f} at x={x_at_max_abs_0:.6f}\n"
        f"  Max abs error (tanh ): {max_abs_1:.12f} at x={x_at_max_abs_1:.6f}\n"
        f"  Max %   error (tanh0): {max_pct_0:.12f} %\n"
        f"  Max %   error (tanh ): {max_pct_1:.12f} %\n"
    )
    
    # Append near-zero diagnostic logs if any were collected
    if near_zero_logs:
        txt += (
            "\n"
            "===========================================================\n"
            "Near-zero region diagnostics (|x| < 0.001):\n"
            "===========================================================\n"
        )
        txt += "\n".join(near_zero_logs) + "\n"

    (out_dir / "tanh.txt").write_text(txt, encoding="utf-8")

    # Close the test vectors file if it was opened
    if tb is not None:
        tb.close()

if __name__ == "__main__":
    main()