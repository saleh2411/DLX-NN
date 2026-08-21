#!/usr/bin/env python3
"""
Plots softmax output vs x0 for the vector [x0, 0, 1, 2.5, 0.5, -1, -3, 4],
comparing the Q16.16 Algorithm 3 model against exact float64 softmax.

Usage: python3 plot_softmax_shape.py   ->  softmax_shape_plot.png
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

from softmax_golden import softmax_algo3, softmax_exact


def main():
    out_dir = Path(__file__).resolve().parent

    x_vals = np.arange(-8.0, 8.5, 0.5)
    
    y_hw_vals = []
    y_ref_vals = []
    
    print("Generating points for vector [x0, 0, 1]...")
    for x0 in x_vals:
        vec = [float(x0), 0.0, 1.0, 2.5, 0.5, -1.0, -3.0, 4.0]
        
        # Golden model (Q16.16)
        y_hw, _ = softmax_algo3(vec, verbose=False)
        y_hw_vals.append(y_hw[0])
        
        # Exact reference (float64)
        y_ref = softmax_exact(vec)
        y_ref_vals.append(y_ref[0])
        
    plt.figure(figsize=(10, 6))
    plt.plot(x_vals, y_ref_vals, label="Original Softmax (Exact)", color='blue', linewidth=2)
    plt.plot(x_vals, y_hw_vals, label="Proposed Softmax (Q16.16)", color='red', linestyle='--', linewidth=2, marker='o', markersize=4)
    
    plt.title("Shape of Softmax Function for vector [x0, 0, 1, 2.5, 0.5, -1.0, -3.0, 4.0]")
    plt.xlabel("x0")
    plt.ylabel("Softmax Output (Probability)")
    plt.xlim(-8, 8)
    plt.ylim(0, 1.05)
    plt.grid(True, alpha=0.3)
    plt.legend()
    
    out_file = out_dir / "softmax_shape_plot.png"
    plt.tight_layout()
    plt.savefig(out_file, dpi=300)
    plt.close()
    
    print(f"Plot saved successfully to: {out_file}")

if __name__ == "__main__":
    main()
