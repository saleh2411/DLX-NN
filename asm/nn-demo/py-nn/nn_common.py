#!/usr/bin/env python3
"""
nn_common.py -- shared plumbing for the DLX-NN handwritten-digit classifier.

This module is the single point where the py-nn model reuses the project's
existing Q16.16 activation *approximations* (the golden models under ../../py).
Nothing here re-implements the activation math -- sigmoid0 / tanh0 / softmax are
imported (or thinly wrapped) from py/, exactly as required by the project:
the hardware activation path and this Python model must share one source of
truth for the approximation.

Provides:
  * Q16.16 helpers (from py/Softmax/q16_16.py):   to_q, from_q, q_mul, SCALE, ONE
  * relu_q(x_q)                                    exact max(0, x)  (relu is exact)
  * tanh0_q(x_q)                                   tanh via sigmoid0 (shift-only PWL)
  * sigmoid0_q16_16(x_q)                           5-segment PWL sigmoid
  * softmax_algo3 / softmax_exact                  Algorithm-3 online softmax
  * load_dataset('train'|'test')                   16x16 optdigits-orig loader
  * PIXEL_MAX, INPUT_SHIFT                          input-scaling constants

Environment: pure-numpy, no new dependencies.  Runs on /usr/bin/python3 (3.9).
"""

import sys
from pathlib import Path

import numpy as np

# ---------------------------------------------------------------------------
# Wire in the existing golden-model approximations from ../../py
# ---------------------------------------------------------------------------
# Walk up to the repo root rather than hardcoding a depth -- this file has
# moved twice and a fixed parents[N] silently breaks the whole toolchain.
def _find_repo_root(start: Path) -> Path:
    for d in (start, *start.parents):
        if (d / "py" / "sigmoid").is_dir() and (d / "py" / "Softmax").is_dir():
            return d
    raise SystemExit(
        "error: cannot locate the golden models -- expected py/sigmoid and "
        f"py/Softmax in a parent of {start}")

_REPO_ROOT = _find_repo_root(Path(__file__).resolve().parent)
_PY_SIG    = _REPO_ROOT / "py" / "sigmoid"
_PY_SMAX   = _REPO_ROOT / "py" / "Softmax"

for _p in (_PY_SIG, _PY_SMAX):
    if str(_p) not in sys.path:
        sys.path.insert(0, str(_p))

# sigmoid.py imports matplotlib only lazily (inside main()), so this is safe.
from sigmoid import (                       # noqa: E402
    sigmoid0_q16_16,
    SCALE as _SCALE_SIG,
    ONE as _ONE_SIG,
)

# Softmax stack imports cleanly (numpy is lazy in pwl_reciprocal; no matplotlib).
from q16_16 import SCALE, ONE, to_q, from_q, q_mul   # noqa: E402
from softmax_golden import softmax_algo3, softmax_exact        # noqa: E402

# Sanity: both Q16.16 copies must agree on the scale factor.
assert SCALE == _SCALE_SIG == 65536, "Q16.16 SCALE mismatch between py/ modules"
assert ONE == _ONE_SIG == 0x10000

# ---------------------------------------------------------------------------
# tanh0  --  tanh(x) = 2*sigmoid0(2x) - 1   (copied from py/sigmoid/tanh.py
# so we do NOT import tanh.py, which pulls in matplotlib at module top level).
# Bit-identical to tanh0_from_sigmoid0_q16_16.
# ---------------------------------------------------------------------------

def _clamp_q(x_q, lo_q, hi_q):
    if x_q < lo_q:
        return lo_q
    if x_q > hi_q:
        return hi_q
    return x_q


def tanh0_q(x_q: int) -> int:
    """tanh0(x) in Q16.16 via the shift-only sigmoid0 (no multiplier)."""
    z_q = 2 * x_q
    if z_q >= 0:
        s0_q = sigmoid0_q16_16(z_q)
    else:
        s0_q = ONE - sigmoid0_q16_16(-z_q)
    return _clamp_q(2 * s0_q - ONE, -ONE, ONE)


def relu_q(x_q: int) -> int:
    """ReLU in Q16.16 -- exact max(0, x) (matches ReLU.v, no approximation)."""
    return x_q if x_q > 0 else 0


# ---------------------------------------------------------------------------
# Input resolution & encoding  -- 16x16 (doubled from the original 8x8)
# ---------------------------------------------------------------------------
# The network input is a GRID x GRID image built from the UCI optdigits-orig
# 32x32 NIST bitmaps: each output pixel counts the set bits in a BLOCK x BLOCK
# block, so pixel values run 0..BLOCK^2.  (The classic 8x8 optdigits is the same
# construction with BLOCK=4 -> values 0..16; here BLOCK=2 -> values 0..4.)
RES         = "16x16"
GRID        = 16                   # GRID x GRID input image
BLOCK       = 2                    # BLOCK x BLOCK bits of the 32x32 bitmap per pixel
BITS        = GRID * BLOCK         # 32 (the original NIST bitmap side)
N_INPUTS    = GRID * GRID          # 256 network inputs
PIXEL_MAX   = BLOCK * BLOCK        # 4  (max set bits in a 2x2 block)

# Scale pixels to [0,1] by /PIXEL_MAX.  PIXEL_MAX -> 65536 in Q16.16 is an exact
# left shift:  x_q = pixel << INPUT_SHIFT  (== pixel / PIXEL_MAX), so the DLX
# assembly needs only slli -- no division, no rounding.
INPUT_SHIFT = 16 - (PIXEL_MAX.bit_length() - 1)   # 14  (65536 / 4 = 2^14)


def pixel_to_q(pixel: int) -> int:
    """Encode one pixel (0..PIXEL_MAX) as Q16.16 in [0,1] via a left shift."""
    return int(pixel) << INPUT_SHIFT


# ---------------------------------------------------------------------------
# Dataset loader -- UCI optdigits-orig 32x32 NIST bitmaps -> GRID x GRID counts
# ---------------------------------------------------------------------------

def _load_optdigits_orig_file(path):
    """
    Parse one optdigits-orig.{tra,cv,wdep,windep} file (32x32 binary bitmaps).

    Format: a ~21-line text header, then per sample 32 rows of 32 '0'/'1'
    characters followed by one line holding the class label (0..9).  Returns
    (X, y): X shape (N, N_INPUTS) with each pixel the set-bit count of a
    BLOCK x BLOCK block (0..PIXEL_MAX), y shape (N,).
    """
    lines = Path(path).read_text().splitlines()
    i = 0
    while i < len(lines) and not (len(lines[i]) == BITS
                                  and set(lines[i]) <= {"0", "1"}):
        i += 1
    X, y = [], []
    while i + BITS < len(lines):
        rows = lines[i:i + BITS]
        if not all(len(r) == BITS and set(r) <= {"0", "1"} for r in rows):
            break
        bmp = np.array([[int(c) for c in r] for r in rows], dtype=np.int64)  # 32x32
        # BLOCK x BLOCK block-count -> GRID x GRID values in 0..PIXEL_MAX
        px = bmp.reshape(GRID, BLOCK, GRID, BLOCK).sum(axis=(1, 3))
        X.append(px.reshape(-1))
        y.append(int(lines[i + BITS].strip()))
        i += BITS + 1
    return np.array(X, dtype=np.int64), np.array(y, dtype=np.int64)


# optdigits-orig splits.  optdigits (8x8) combined tra+cv+wdep as its training
# set and used windep as its test set (3823 / 1797) -- we mirror that exactly,
# so the 16x16 dataset is the same samples as the 8x8 one, just higher-res.
_DATA = Path(__file__).resolve().parent / "data"
_SPLITS = {"train": ("tra", "cv", "wdep"), "test": ("windep",)}


def load_dataset(which):
    """Load 'train' (tra+cv+wdep, 3823) or 'test' (windep, 1797) at GRID x GRID."""
    Xs, ys = [], []
    for s in _SPLITS[which]:
        X, y = _load_optdigits_orig_file(_DATA / f"optdigits-orig.{s}")
        Xs.append(X); ys.append(y)
    return np.concatenate(Xs), np.concatenate(ys)


if __name__ == "__main__":
    # Smoke test: prove the golden approximations import and run.
    print("Q16.16 SCALE =", SCALE, " ONE =", hex(ONE))
    for xf in (-2.0, -0.5, 0.0, 0.5, 2.0):
        xq = to_q(xf)
        print(f"x={xf:+.2f}  sigmoid0={from_q(sigmoid0_q16_16(xq)):.5f}  "
              f"tanh0={from_q(tanh0_q(xq)):+.5f}  relu={from_q(relu_q(xq)):+.5f}")
    yf, yh = softmax_algo3([1.0, 2.0, 3.0])
    print("softmax_algo3([1,2,3]) =", [f"{v:.4f}" for v in yf])
