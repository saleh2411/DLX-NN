#!/usr/bin/env python3
"""
Sigmoid in Q16.16 fixed-point, in two forms:
  sigmoid0 — 5-segment piecewise linear, shift-and-add only (no multiplier)
  sigmoid  — refinement 2*s0 - s0^2*(1 + e^-x), with an L=4 exp(-x) LUT

Sweeps x in [-10,10] and writes error plots + sigmoid.txt.
Also exports the Q16.16 helpers used by tanh.py and GELU.py.

Usage: python sigmoid.py [-x VALUE] [-v]
"""

import math
import numpy as np
from pathlib import Path
import argparse

# ============================================================
# 0) Autogen tb
# ============================================================

def tb_vectors(x_q, y_q16_16_value, tb):
    """
    Generate a test vector line for the SystemVerilog testbench.
    Tests exact match between DUT output and sigmoid0_q16_16 expected value.
    
    Args:
        x_q: Input x in Q16.16 format (integer)
        y_q16_16_value: Expected output y in Q16.16 format (integer) from sigmoid0_q16_16
        tb: File handle to write to
    """
    if tb is None:
        return
    
    # Format as 32-bit hex values
    x_hex = x_q & 0xFFFFFFFF
    y_hex = y_q16_16_value & 0xFFFFFFFF
    
    tb.write(f"check_result(32'h{x_hex:08X}, 32'h{y_hex:08X});\n")




# ============================================================
# 1) Reference sigmoid using Python built-in math library
# ============================================================
def sigmoid_ref(x: float) -> float:
    return 1.0 / (1.0 + math.exp(-x))

# ============================================================
# 2) Q16.16 fixed-point utilities
# ============================================================
Q = 16
SCALE = 1 << Q

def float_to_q16_16(x: float) -> int:
    return int(round(x * SCALE))

def q_mul(a: int, b: int) -> int:
    return (a * b) >> Q

ONE = float_to_q16_16(1.0)

# ============================================================
# 3) sigmoid_0(x) (piecewise linear) in Q16.16
# ============================================================
SLOPE_1_4   = float_to_q16_16(0.25)
B_1_2       = float_to_q16_16(0.5)

SLOPE_1_8   = float_to_q16_16(0.125)
B_5_8       = float_to_q16_16(0.625)

SLOPE_1_32  = float_to_q16_16(0.03125)
B_27_32     = float_to_q16_16(0.84375)

X_7_8   = float_to_q16_16(0.875)   # 7/8
X_9_8   = float_to_q16_16(1.125)   # 9/8
X_2_375 = float_to_q16_16(2.375)
X_5     = float_to_q16_16(5.0)

# Taylor repair segment around x0 = 1 with slope 1/8 (shift-only):
#   y = (1/8)*x + b, where b = sigmoid(1) - 1/8 ≈ 0.6060586
# In Q16.16: b ≈ 39719
B_TAYLOR_1 = 39719

def sigmoid0_q16_16(x_q: int) -> int:
    if x_q >= X_5:
        return ONE
    elif x_q >= X_2_375:
        return q_mul(SLOPE_1_32, x_q) + B_27_32
    elif x_q >= X_9_8:
        return q_mul(SLOPE_1_8, x_q) + B_5_8
    elif x_q >= X_7_8:
        # y = (1/8)*x + b -> shift-only for the slope
        return (x_q >> 3) + B_TAYLOR_1
    elif x_q >= 0:
        return q_mul(SLOPE_1_4, x_q) + B_1_2
    else:
        # If ever called with negative x, mirror with σ(-x)=1-σ(x)
        return ONE - sigmoid0_q16_16(-x_q)


# ============================================================
# 4) exp(-x) approximation (paper, L=4) with LUT dictionary
# ============================================================
LN2 = math.log(2.0)

# LUT: 2^(-j/16) stored in a dictionary (Q16.16)
lut_2neg_j_over_16_q = {j: float_to_q16_16(2.0 ** (-j / 16.0)) for j in range(16)}

def decompose_x_L4(x: float):
    """
    Quantize (x/ln2) to nearest 1/16:
      x = (m + j/16)*ln2 + r
    """
    y = x / LN2
    yq = round(y * 16.0) / 16.0
    m = int(math.floor(yq))
    j = int(round((yq - m) * 16.0))
    if j == 16:  # rounding edge-case
        m += 1
        j = 0
    r = x - (m + j / 16.0) * LN2
    return m, j, r

def exp_neg_q16_16(x_q: int) -> int:
    """
    e^(-x) ≈ 2^(-m) * 2^(-j/16) * (1 - r)
    """
    x = x_q / SCALE
    m, j, r = decompose_x_L4(x)

    pow2_minus_m_q = (ONE >> m) if m >= 0 else (ONE << (-m))
    pow2_minus_j16_q = lut_2neg_j_over_16_q[j]

    r_q = float_to_q16_16(r)
    one_minus_r_q = ONE - r_q

    t_q = q_mul(pow2_minus_m_q, pow2_minus_j16_q)
    e_neg_q = q_mul(t_q, one_minus_r_q)

    # clamp to [0, 1]
    if e_neg_q < 0:
        e_neg_q = 0
    elif e_neg_q > ONE:
        e_neg_q = ONE
    return e_neg_q

# ============================================================
# 5) New function "sigmoid" (paper refinement)
#     σ~(x) = 2σ~0(x) - (σ~0(x))^2 * (1 + e^-x)
# ============================================================
def sigmoid(x_q: int) -> int:
    s0 = sigmoid0_q16_16(x_q)
    e_neg = exp_neg_q16_16(x_q)

    s0_sq = q_mul(s0, s0)
    one_plus_e = ONE + e_neg
    term = q_mul(s0_sq, one_plus_e)

    out = (2 * s0) - term

    # clamp to [0, 1]
    if out < 0:
        out = 0
    elif out > ONE:
        out = ONE
    return out

# ============================================================
# 6) Sweep, plots, and sigmoid.txt summary
# ============================================================
def main():
    parser = argparse.ArgumentParser(description="Sigmoid approximation analysis")
    parser.add_argument("-x", type=float, help="Evaluate sigmoid at specific x value")
    parser.add_argument("-v", "--vectors", action="store_true", help="Generate SystemVerilog test vectors file")
    args = parser.parse_args()
    
    # Only open tb file if -v flag is passed
    tb = None
    if args.vectors:
        tb = open("sigmoid_vectors.sv", "w")
        tb.write("// Auto-generated test vectors for sigmoid testbench (5-segment)\n")
        tb.write("// Expected values from sigmoid0_q16_16 (piecewise linear approximation)\n")
        tb.write("// Format: check_result(x_input, expected_output)\n\n")

    out_dir = Path(__file__).resolve().parent

    # If -x is provided, just compute and print the values
    if args.x is not None:
        x = args.x
        x_q = float_to_q16_16(x)
        
        y_ref = sigmoid_ref(x)
        y0 = sigmoid0_q16_16(x_q) / SCALE
        y1 = sigmoid(x_q) / SCALE
        
        print(f"\nSigmoid evaluation at x = {x}")
        print("=" * 50)
        print(f"sigmoid_ref(x)  = {y_ref:.15f}")
        print(f"sigmoid0(x)     = {y0:.15f}")
        print(f"sigmoid(x)      = {y1:.15f}")
        print(f"\nAbsolute errors:")
        print(f"  |ref - sigmoid0| = {abs(y_ref - y0):.15f}")
        print(f"  |ref - sigmoid|  = {abs(y_ref - y1):.15f}")
        print(f"\nSquared errors:")
        print(f"  (ref - sigmoid0)^2 = {(y_ref - y0)**2:.15f}")
        print(f"  (ref - sigmoid)^2  = {(y_ref - y1)**2:.15f}")
        return

    # matplotlib is only needed for the full sweep + plots below
    import matplotlib.pyplot as plt

    x_q_vals = np.arange(-10 * SCALE, 10 * SCALE + 1, dtype=np.int64)
    x_vals = x_q_vals / SCALE

    err_abs_sigmoid0 = np.empty_like(x_vals, dtype=np.float64)
    err_abs_sigmoid  = np.empty_like(x_vals, dtype=np.float64)

    err_pct_sigmoid0 = np.empty_like(x_vals, dtype=np.float64)
    err_pct_sigmoid  = np.empty_like(x_vals, dtype=np.float64)

    err_sq_sigmoid0 = np.empty_like(x_vals, dtype=np.float64)
    err_sq_sigmoid  = np.empty_like(x_vals, dtype=np.float64)

    # Safe denominator for percent error (sigmoid(x) in [0.5, ~1] here, but keep robust)
    EPS_DEN = 1e-15

    for i, x_q in enumerate(x_q_vals):
        x = x_q / SCALE
        y_ref = sigmoid_ref(x)

        y0 = sigmoid0_q16_16(int(x_q)) / SCALE
        y1 = sigmoid(int(x_q)) / SCALE

        e0 = abs(y_ref - y0)
        e1 = abs(y_ref - y1)

        # create tb entry - use sigmoid0 approximation (y0) as expected
        y0_q = sigmoid0_q16_16(int(x_q))
        tb_vectors(int(x_q), y0_q, tb)

        err_abs_sigmoid0[i] = e0
        err_abs_sigmoid[i]  = e1

        err_sq_sigmoid0[i] = e0 * e0
        err_sq_sigmoid[i]  = e1 * e1

        denom = max(abs(y_ref), EPS_DEN)
        err_pct_sigmoid0[i] = (e0 / denom) * 100.0
        err_pct_sigmoid[i]  = (e1 / denom) * 100.0

    # -------- Plot 1: Absolute error --------
    plt.figure()
    plt.plot(x_vals, err_abs_sigmoid0, label="|sigmoid_ref - sigmoid0|")
    plt.title("Absolute error on [-10,10] (step = 2^-16)")
    plt.xlabel("x")
    plt.ylabel("absolute error")
    plt.xlim(-10, 10)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "sigmoid_abs_error.png", dpi=1300)
    plt.close()

    # -------- Plot 2: Percentage error --------
    plt.figure()
    plt.plot(x_vals, err_pct_sigmoid0, label="% error vs sigmoid0")
    plt.plot(x_vals, err_pct_sigmoid,  label="% error vs sigmoid")
    plt.title("Percentage error on [-10,10] (step = 2^-16)")
    plt.xlabel("x")
    plt.ylabel("percentage error (%)")
    plt.xlim(-10, 10)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "sigmoid_pct_error.png", dpi=1300)
    plt.close()

    # -------- Plot 2b: Squared error (MSE integrand) --------
    plt.figure()
    plt.plot(x_vals, err_sq_sigmoid0, label="(sigmoid_ref - sigmoid0)^2")
    plt.title("Squared error on [-10,10] (step = 2^-16)")
    plt.xlabel("x")
    plt.ylabel("squared error")
    plt.xlim(-10, 10)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "sigmoid_mse_error.png", dpi=1300)
    plt.close()

    # -------- Plot 3: Actual function graphs --------
    y_ref_vals = np.array([sigmoid_ref(x) for x in x_vals])
    y0_vals = np.array([sigmoid0_q16_16(int(x_q)) / SCALE for x_q in x_q_vals])
    
    plt.figure()
    plt.plot(x_vals, y_ref_vals, label="sigmoid_ref (exact)", linewidth=2)
    plt.plot(x_vals, y0_vals, label="sigmoid0 (piecewise linear)", alpha=0.8)
    plt.title("Sigmoid function comparison on [-10,10]")
    plt.xlabel("x")
    plt.ylabel("sigmoid(x)")
    plt.xlim(-10, 10)
    plt.ylim(0, 1.05)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(out_dir / "sigmoid_functions.png", dpi=1300)
    plt.close()

    # -------- Text output: averages (and max, for convenience) --------
    avg_abs_0 = float(err_abs_sigmoid0.mean())
    avg_abs_1 = float(err_abs_sigmoid.mean())
    avg_pct_0 = float(err_pct_sigmoid0.mean())
    avg_pct_1 = float(err_pct_sigmoid.mean())

    max_abs_0 = float(err_abs_sigmoid0.max())
    max_abs_1 = float(err_abs_sigmoid.max())
    max_pct_0 = float(err_pct_sigmoid0.max())
    max_pct_1 = float(err_pct_sigmoid.max())

    mse_0 = float(err_sq_sigmoid0.mean())
    mse_1 = float(err_sq_sigmoid.mean())
    rmse_0 = float(np.sqrt(mse_0))
    rmse_1 = float(np.sqrt(mse_1))
    max_sq_0 = float(err_sq_sigmoid0.max())
    max_sq_1 = float(err_sq_sigmoid.max())

    x_at_max_abs_0 = float(x_vals[int(err_abs_sigmoid0.argmax())])
    x_at_max_abs_1 = float(x_vals[int(err_abs_sigmoid.argmax())])

    txt = (
        "Sigmoid approximation error summary (x in [-10,10], step = 2^-16)\n"
        "=============================================================\n\n"
        "Averages:\n"
        f"  Avg abs error (sigmoid0): {avg_abs_0:.12f}\n"
        f"  Avg abs error (sigmoid ): {avg_abs_1:.12f}\n"
        f"  Avg %   error (sigmoid0): {avg_pct_0:.12f} %\n"
        f"  Avg %   error (sigmoid ): {avg_pct_1:.12f} %\n\n"
        "Maximums:\n"
        f"  Max abs error (sigmoid0): {max_abs_0:.12f} at x={x_at_max_abs_0:.6f}\n"
        f"  Max abs error (sigmoid ): {max_abs_1:.12f} at x={x_at_max_abs_1:.6f}\n"
        f"  Max %   error (sigmoid0): {max_pct_0:.12f} %\n"
        f"  Max %   error (sigmoid ): {max_pct_1:.12f} %\n\n"
        "Mean Squared Error:\n"
        f"  MSE  (sigmoid0): {mse_0:.12e}\n"
        f"  MSE  (sigmoid ): {mse_1:.12e}\n"
        f"  RMSE (sigmoid0): {rmse_0:.12e}\n"
        f"  RMSE (sigmoid ): {rmse_1:.12e}\n"
        f"  Max sq error (sigmoid0): {max_sq_0:.12e}\n"
        f"  Max sq error (sigmoid ): {max_sq_1:.12e}\n"
    )

    (out_dir / "sigmoid.txt").write_text(txt, encoding="utf-8")
    
    # Close tb file if it was opened
    if tb is not None:
        tb.close()
        print(f"Generated sigmoid_vectors.sv with {len(x_q_vals)} test vectors")

if __name__ == "__main__":
    main()