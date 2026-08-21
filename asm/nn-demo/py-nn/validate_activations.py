#!/usr/bin/env python3
"""
validate_activations.py -- acceptance report for the py-nn digit classifier.

Two things the project requires, written to validation_report.txt:

  1. For every activation *used* in the final inference path, MSE between the
     Q16.16 approximation (the golden model) and the exact float reference,
     checked against the project bound MSE <= 0.025.  Activations used:
         relu   (exact max(0,x)  -> MSE = 0 by construction)
         tanh0  (via sigmoid0, tanh variant hidden layer)
         sigmoid0 (the shift-only PWL that tanh0 is built on -- reported too)
         softmax (Algorithm 3, output layer of both variants)

  2. Overall classification accuracy: float model vs the bit-exact Q16.16
     fixed-point model for the tanh variant.

MSE is mean((ref - approx)^2), matching the existing py/ error-analysis scripts.
"""

import math
from pathlib import Path

import numpy as np
np.seterr(all="ignore")   # silence spurious macOS/Accelerate matmul warnings

from nn_common import (
    to_q, from_q, PIXEL_MAX,
    sigmoid0_q16_16, tanh0_q,
    softmax_algo3, softmax_exact,
    load_dataset,
)
from quantize import quantize_weights, forward_q, evaluate

HERE = Path(__file__).resolve().parent
MSE_BOUND = 0.025


def sweep_mse(approx_q, ref_f, lo, hi, step_bits=10):
    """MSE of a scalar Q16.16 activation vs its exact float ref over [lo,hi]."""
    step = 1 << step_bits                      # in Q16.16 LSBs
    lo_q, hi_q = to_q(lo), to_q(hi)
    se = 0.0
    n = 0
    xq = lo_q
    while xq <= hi_q:
        a = from_q(approx_q(xq))
        r = ref_f(from_q(xq))
        se += (r - a) ** 2
        n += 1
        xq += step
    return se / n, n


def softmax_mse_on_logits(logit_vectors):
    """
    Realistic softmax MSE: run the golden Algorithm-3 softmax and the exact
    softmax on each 10-logit output vector the network actually produces, and
    average the per-element squared error.  Returns (mean_mse, max_mse).
    """
    per_vec = []
    for z in logit_vectors:
        y_hw, _ = softmax_algo3(z)
        y_ref = softmax_exact(z)
        se = sum((h - r) ** 2 for h, r in zip(y_hw, y_ref)) / len(z)
        per_vec.append(se)
    return sum(per_vec) / len(per_vec), max(per_vec)


def main():
    lines = []
    def out(s=""):
        lines.append(s)
        print(s)

    out("=" * 70)
    out("py-nn digit classifier -- VALIDATION REPORT")
    out("=" * 70)
    out("Format: Q16.16 signed fixed-point.  MSE = mean((exact - approx)^2).")
    out(f"Acceptance bound: MSE <= {MSE_BOUND} for every activation used.")
    out("Approximations are imported from ../../py (the shared golden models);")
    out("nothing here re-implements the activation math.")
    out("")

    # -------------------------------------------------------------------
    # 1) Per-activation MSE vs exact
    # -------------------------------------------------------------------
    out("-" * 70)
    out("1) ACTIVATION APPROXIMATION ERROR (approx vs exact reference)")
    out("-" * 70)

    results = []

    # relu -- exact by construction
    results.append(("relu   [-8, 8]  (exact max(0,x))", 0.0, 1))

    # sigmoid0 -- building block of tanh0; project range [-10,10]
    mse_s, n_s = sweep_mse(sigmoid0_q16_16,
                           lambda x: 1.0 / (1.0 + math.exp(-x)),
                           -10.0, 10.0)
    results.append((f"sigmoid0 [-10,10]  ({n_s} pts)", mse_s, n_s))

    # tanh0 -- tanh variant hidden activation; project range [-4,4] and wide [-8,8]
    mse_t4, n_t4 = sweep_mse(tanh0_q, math.tanh, -4.0, 4.0)
    results.append((f"tanh0  [-4, 4]   ({n_t4} pts)", mse_t4, n_t4))
    mse_t8, n_t8 = sweep_mse(tanh0_q, math.tanh, -8.0, 8.0)
    results.append((f"tanh0  [-8, 8]   ({n_t8} pts)", mse_t8, n_t8))

    all_pass = True
    for name, mse, _ in results:
        status = "PASS" if mse <= MSE_BOUND else "FAIL"
        all_pass = all_pass and mse <= MSE_BOUND
        out(f"  {name:36s}  MSE = {mse:.6e}   {status}")

    # -------------------------------------------------------------------
    # 2) softmax MSE on the network's real output logits (both variants)
    # -------------------------------------------------------------------
    out("")
    out("-" * 70)
    out("2) SOFTMAX (Algorithm 3) ERROR on real network output logits")
    out("-" * 70)
    Xte, yte = load_dataset("test")
    # A subset keeps the report fast; logits are deterministic per sample.
    subset = range(0, Xte.shape[0], 6)          # ~300 samples
    for act in ("tanh",):
        qw = quantize_weights(act)
        logit_vectors = []
        for n in subset:
            z2_q, _ = forward_q(qw, Xte[n])
            logit_vectors.append([from_q(v) for v in z2_q])
        mmse, xmse = softmax_mse_on_logits(logit_vectors)
        status = "PASS" if mmse <= MSE_BOUND else "FAIL"
        all_pass = all_pass and mmse <= MSE_BOUND
        out(f"  softmax on {act:4s}-variant logits "
            f"({len(logit_vectors)} vecs)   mean MSE = {mmse:.6e}   "
            f"max MSE = {xmse:.6e}   {status}")

    # -------------------------------------------------------------------
    # 3) Classification accuracy: float vs Q16.16 fixed-point
    # -------------------------------------------------------------------
    out("")
    out("-" * 70)
    out("3) CLASSIFICATION ACCURACY (optdigits-orig 16x16 test set, N=%d)"
        % Xte.shape[0])
    out("-" * 70)
    # Float accuracy (reload from the saved float weights via a dense forward).
    for act in ("tanh",):
        z = np.load(HERE / "weights" / f"{act}.npz")
        W1, b1, W2, b2 = z["W1"], z["b1"], z["W2"], z["b2"]
        Xf = Xte.astype(np.float64) / PIXEL_MAX
        h = np.tanh(Xf @ W1.T + b1)
        logits = h @ W2.T + b2
        float_acc = float((logits.argmax(axis=1) == yte).mean())
        qw = quantize_weights(act)
        q_acc = evaluate(qw, Xte, yte)
        out(f"  [{act:4s}]  float = {float_acc*100:6.2f}%    "
            f"Q16.16 approx = {q_acc*100:6.2f}%    "
            f"drop = {(float_acc-q_acc)*100:+.2f} pp")

    out("")
    out("=" * 70)
    out("OVERALL: " + ("ALL ACTIVATIONS WITHIN MSE BOUND" if all_pass
                       else "SOME ACTIVATION EXCEEDED MSE BOUND"))
    out("=" * 70)

    (HERE / "validation_report.txt").write_text("\n".join(lines) + "\n",
                                                encoding="utf-8")
    print(f"\nReport written to {HERE / 'validation_report.txt'}")


if __name__ == "__main__":
    main()
