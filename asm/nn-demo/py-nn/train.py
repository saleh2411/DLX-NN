#!/usr/bin/env python3
"""
train.py -- train the tiny digit-classifier MLP in float64 (numpy only).

Architecture (fixed, chosen for DLX-assembly feasibility):
    256 inputs (16x16) -> H hidden -> 10 outputs (softmax)

Two variants are trained and saved, differing only in the hidden activation:
    * tanh  : hidden = tanh     (Xavier init)
Both use a softmax output layer with cross-entropy loss.

Training uses *exact* float activations -- the Q16.16 approximation is applied
later at inference time (infer_q16.py) so we can measure the quantization gap.

Outputs (float weights, consumed by infer_q16.py / export_weights.py):
    weights/tanh.npz
Each holds W1 (H,64), b1 (H,), W2 (10,H), b2 (10,), plus meta (H, activation).

Usage:
    python3 train.py                 # train both variants, H=16
    python3 train.py --hidden 12     # override hidden width
"""

import argparse
from pathlib import Path

import numpy as np

from nn_common import load_dataset, PIXEL_MAX, N_INPUTS, RES

HERE = Path(__file__).resolve().parent

# numpy 2.0 on macOS/Accelerate emits spurious "divide by zero / overflow /
# invalid value encountered in matmul" RuntimeWarnings; the results are exact.
np.seterr(all="ignore")


def one_hot(y, n=10):
    o = np.zeros((y.shape[0], n))
    o[np.arange(y.shape[0]), y] = 1.0
    return o


def softmax_rows(z):
    z = z - z.max(axis=1, keepdims=True)
    e = np.exp(z)
    return e / e.sum(axis=1, keepdims=True)


def forward(params, X, act):
    W1, b1, W2, b2 = params
    z1 = X @ W1.T + b1
    a1 = np.tanh(z1)
    z2 = a1 @ W2.T + b2
    p = softmax_rows(z2)
    return z1, a1, z2, p


def accuracy(params, X, y, act):
    _, _, _, p = forward(params, X, act)
    return float((p.argmax(axis=1) == y).mean())


def train_variant(act, Xtr, ytr, Xte, yte, H, epochs, batch, lr, seed=0):
    rng = np.random.default_rng(seed)
    D, C = N_INPUTS, 10
    # Init: Xavier (tanh).
    s1 = np.sqrt(1.0 / D)
    s2 = np.sqrt(1.0 / H)
    W1 = rng.standard_normal((H, D)) * s1
    b1 = np.zeros(H)
    W2 = rng.standard_normal((C, H)) * s2
    b2 = np.zeros(C)

    Ytr = one_hot(ytr, C)
    N = Xtr.shape[0]
    # SGD + momentum.
    vW1 = np.zeros_like(W1); vb1 = np.zeros_like(b1)
    vW2 = np.zeros_like(W2); vb2 = np.zeros_like(b2)
    mom = 0.9

    for _ in range(epochs):
        idx = rng.permutation(N)
        for s in range(0, N, batch):
            bi = idx[s:s + batch]
            X = Xtr[bi]; Y = Ytr[bi]
            params = (W1, b1, W2, b2)
            z1, a1, _, p = forward(params, X, act)
            m = X.shape[0]
            # dL/dz2 for softmax + cross-entropy
            dz2 = (p - Y) / m
            gW2 = dz2.T @ a1
            gb2 = dz2.sum(axis=0)
            da1 = dz2 @ W2
            dz1 = da1 * (1.0 - a1 * a1)
            gW1 = dz1.T @ X
            gb1 = dz1.sum(axis=0)
            # momentum update
            vW1 = mom * vW1 - lr * gW1; W1 += vW1
            vb1 = mom * vb1 - lr * gb1; b1 += vb1
            vW2 = mom * vW2 - lr * gW2; W2 += vW2
            vb2 = mom * vb2 - lr * gb2; b2 += vb2

    params = (W1, b1, W2, b2)
    tr_acc = accuracy(params, Xtr, ytr, act)
    te_acc = accuracy(params, Xte, yte, act)
    return params, tr_acc, te_acc


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--hidden", type=int, default=16)
    ap.add_argument("--epochs", type=int, default=400)
    ap.add_argument("--batch", type=int, default=32)
    ap.add_argument("--lr", type=float, default=0.05)   # 256 inputs need a
    args = ap.parse_args()

    Xtr_i, ytr = load_dataset("train")
    Xte_i, yte = load_dataset("test")
    # Same /PIXEL_MAX normalization the fixed-point path uses (pixel<<INPUT_SHIFT).
    Xtr = Xtr_i.astype(np.float64) / PIXEL_MAX
    Xte = Xte_i.astype(np.float64) / PIXEL_MAX

    (HERE / "weights").mkdir(exist_ok=True)
    print(f"optdigits-orig {RES}: train={Xtr.shape[0]}  test={Xte.shape[0]}  "
          f"inputs={N_INPUTS}  H={args.hidden}")
    print("=" * 60)
    for act in ("tanh",):
        params, tr, te = train_variant(
            act, Xtr, ytr, Xte, yte,
            H=args.hidden, epochs=args.epochs, batch=args.batch, lr=args.lr)
        W1, b1, W2, b2 = params
        out = HERE / "weights" / f"{act}.npz"
        np.savez(out, W1=W1, b1=b1, W2=W2, b2=b2,
                 H=args.hidden, activation=act)
        print(f"[{act:4s}] train acc = {tr*100:6.2f}%   test acc = {te*100:6.2f}%"
              f"   -> {out.relative_to(HERE)}")


if __name__ == "__main__":
    main()
