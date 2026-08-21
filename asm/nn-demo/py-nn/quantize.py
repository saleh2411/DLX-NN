#!/usr/bin/env python3
"""
quantize.py -- Q16.16 quantization + bit-exact fixed-point inference.

Single source of truth for turning the float64 weights (from train.py) into
Q16.16 integer weights, and for the integer forward pass that the DLX assembly
must reproduce exactly.  Every arithmetic op here mirrors the hardware:

    * weight/bias/pixel  -> Q16.16 signed 32-bit int
    * multiply           -> q_mul(a,b) = (a*b) >> 16     (py/Softmax/q16_16.py)
    * hidden activation  -> tanh0_q                      (golden approximation)
    * output            -> raw Q16.16 logits; class = argmax
                            (argmax(softmax(z)) == argmax(z), so the class does
                             not depend on the softmax stage)

The forward pass is pure-Python-int so it is byte-for-byte the value the DLX
mult / accumulate datapath produces -- this is what makes the asm testbench
checkable against the model.
"""

from pathlib import Path

import numpy as np

from nn_common import (
    SCALE, from_q, q_mul,
    tanh0_q, pixel_to_q, N_INPUTS,
    softmax_algo3,
)

HERE = Path(__file__).resolve().parent


def quantize_weights(act):
    """Load float weights/{act}.npz and round every parameter to Q16.16 int."""
    z = np.load(HERE / "weights" / f"{act}.npz")
    def Q(a):
        return np.round(np.asarray(a, dtype=np.float64) * SCALE).astype(np.int64)
    return {
        "act": act,
        "H":   int(z["H"]),
        "W1q": Q(z["W1"]),          # (H, 64)
        "b1q": Q(z["b1"]),          # (H,)
        "W2q": Q(z["W2"]),          # (10, H)
        "b2q": Q(z["b2"]),          # (10,)
    }


def hidden_act_q(act):
    return tanh0_q


def wrap32(v):
    """Truncate to signed 32-bit two's complement (models the DLX datapath)."""
    v &= 0xFFFFFFFF
    return v - 0x1_0000_0000 if (v & 0x8000_0000) else v


def qmul32(a, b):
    """Q16.16 multiply with 32-bit result truncation (hardware `mult`)."""
    return wrap32(q_mul(a, b))          # q_mul = (a*b)>>16 (arith shift)


def forward_q(qw, pixels):
    """
    Bit-exact Q16.16 forward pass for one 16x16 image (256 pixels in [0,4]).

    Every multiply and accumulate is truncated to signed 32-bit, so the result
    is byte-for-byte what the DLX mult/accumulate datapath (SW multiply routine
    or the `mult` opcode) produces.  Returns (z2_q, pred): the 10 Q16.16 output
    logits and the argmax class.
    """
    act = qw["act"]; H = qw["H"]
    W1q = qw["W1q"]; b1q = qw["b1q"]; W2q = qw["W2q"]; b2q = qw["b2q"]
    afun = hidden_act_q(act)

    x_q = [pixel_to_q(int(p)) for p in pixels]            # N_INPUTS Q16.16 inputs

    a1_q = [0] * H
    for h in range(H):
        acc = wrap32(int(b1q[h]))
        w = W1q[h]
        for i in range(N_INPUTS):
            acc = wrap32(acc + qmul32(int(w[i]), x_q[i]))
        a1_q[h] = afun(acc)

    z2_q = [0] * 10
    for k in range(10):
        acc = wrap32(int(b2q[k]))
        w = W2q[k]
        for h in range(H):
            acc = wrap32(acc + qmul32(int(w[h]), a1_q[h]))
        z2_q[k] = acc

    pred = max(range(10), key=lambda k: z2_q[k])
    return z2_q, pred


def evaluate(qw, X, y):
    """Fixed-point test accuracy over dataset (X pixels int, y labels)."""
    correct = 0
    for n in range(X.shape[0]):
        _, pred = forward_q(qw, X[n])
        correct += int(pred == y[n])
    return correct / X.shape[0]


def choose_sample():
    """
    Deterministically pick one test image used as the known-answer for the
    assembly programs: the first optdigits test sample that BOTH variants
    classify correctly and agree on.  Returns a dict with the index, the 64
    integer pixels, the true label, and each variant's (logits, pred).
    """
    from nn_common import load_dataset
    Xte, yte = load_dataset("test")
    qw_t = quantize_weights("tanh")
    for n in range(Xte.shape[0]):
        zt, pt = forward_q(qw_t, Xte[n])
        if pt == int(yte[n]):
            return {
                "index":  n,
                "pixels": [int(v) for v in Xte[n]],
                "label":  int(yte[n]),
                "tanh":   {"logits": zt, "pred": pt},
            }
    raise RuntimeError("no sample classified correctly")


if __name__ == "__main__":
    from nn_common import load_dataset
    Xte, yte = load_dataset("test")
    qw = quantize_weights("tanh")
    acc = evaluate(qw, Xte, yte)
    print(f"[tanh] Q16.16 fixed-point test accuracy = {acc*100:.2f}%")
    s = choose_sample()
    print(f"sample: test #{s['index']}  label={s['label']}  "
          f"tanh_pred={s['tanh']['pred']}")
