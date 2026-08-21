#!/usr/bin/env python3
"""
export_weights.py -- emit the trained model in an asm-consumable Q16.16 form.

Writes, under py-nn/export/ :

  tanh_weights.s          DLX data block (dc words, Q16.16 hex), in the exact
                          memory order the assembly reads:  W1 (row-major h,i)
                          | B1 | W2 (row-major k,h) | B2.  Literally DLX `.s`
                          data -- directly consumable by asm-nn.

  expected_outputs.txt    Expected 10 output logits (hex+float) and argmax
                          class for the sample -- what the asm must reproduce.

  manifest.json           H, sample index, layout, expected pred (read by
                          asm-nn/build_asm.py so it uses the identical sample).
"""

import json
from pathlib import Path

from nn_common import from_q, INPUT_SHIFT, PIXEL_MAX, N_INPUTS, GRID, RES
from quantize import quantize_weights, choose_sample

HERE = Path(__file__).resolve().parent
EXPORT = HERE / "export"


def q_word(v):
    """Signed Q16.16 int -> 'dc 0x........' DLX data word."""
    return f"dc 0x{v & 0xFFFFFFFF:08X}"


def emit_weights_s(act, qw):
    H = qw["H"]
    W1 = qw["W1q"]; b1 = qw["b1q"]; W2 = qw["W2q"]; b2 = qw["b2q"]
    L = []
    L.append(f"* {act}_weights.s -- Q16.16 weights for the {act}+softmax digit MLP")
    L.append(f"* Architecture: {N_INPUTS} ({RES}) -> {H} -> 10   "
             f"(hidden = {act}, output = softmax)")
    L.append("* All words are signed Q16.16 (value = word / 65536).")
    L.append("* Memory order (read sequentially by the inference loop):")
    L.append(f"*   W1DATA : {H}*{N_INPUTS} words, row-major  W1[h][i]  (h outer, i inner)")
    L.append(f"*   B1DATA : {H} words   b1[h]")
    L.append(f"*   W2DATA : 10*{H} words, row-major  W2[k][h]  (k outer, h inner)")
    L.append("*   B2DATA : 10 words  b2[k]")
    L.append("*")
    L.append(f"W1DATA:  {q_word(int(W1[0][0]))}    * W1[0][0]")
    for h in range(H):
        for i in range(N_INPUTS):
            if h == 0 and i == 0:
                continue
            tag = f"    * W1[{h}][{i}]" if i == 0 else ""
            L.append(f"         {q_word(int(W1[h][i]))}{tag}")
    L.append(f"B1DATA:  {q_word(int(b1[0]))}    * b1[0]")
    for h in range(1, H):
        L.append(f"         {q_word(int(b1[h]))}    * b1[{h}]")
    L.append(f"W2DATA:  {q_word(int(W2[0][0]))}    * W2[0][0]")
    for k in range(10):
        for h in range(H):
            if k == 0 and h == 0:
                continue
            tag = f"    * W2[{k}][{h}]" if h == 0 else ""
            L.append(f"         {q_word(int(W2[k][h]))}{tag}")
    L.append(f"B2DATA:  {q_word(int(b2[0]))}    * b2[0]")
    for k in range(1, 10):
        L.append(f"         {q_word(int(b2[k]))}    * b2[{k}]")
    (EXPORT / f"{act}_weights.s").write_text("\n".join(L) + "\n", encoding="utf-8")



def emit_expected(sample):
    L = []
    L.append("Expected outputs for the sample digit (what the asm must reproduce)")
    L.append("=" * 66)
    L.append(f"optdigits test index : {sample['index']}")
    L.append(f"true label           : {sample['label']}")
    L.append("")
    for act in ("tanh",):
        logits = sample[act]["logits"]; pred = sample[act]["pred"]
        L.append(f"[{act}+softmax]  predicted class = {pred}   "
                 f"(argmax of the 10 output logits)")
        L.append(f"  {'class':>5s}  {'logit(hex)':>12s}  {'logit(float)':>14s}")
        for k in range(10):
            mark = "  <-- argmax" if k == pred else ""
            L.append(f"  {k:5d}  0x{logits[k] & 0xFFFFFFFF:08X}  "
                     f"{from_q(logits[k]):14.6f}{mark}")
        L.append("")
    (EXPORT / "expected_outputs.txt").write_text("\n".join(L) + "\n", encoding="utf-8")



def main():
    EXPORT.mkdir(exist_ok=True)
    sample = choose_sample()
    manifest = {"H": None, "resolution": RES, "n_inputs": N_INPUTS,
                "sample_index": sample["index"],
                "label": sample["label"], "input_shift": INPUT_SHIFT,
                "pixel_max": PIXEL_MAX,
                "layout": [f"W1DATA[H*{N_INPUTS}]", "B1DATA[H]",
                           "W2DATA[10*H]", "B2DATA[10]"],
                "preds": {"tanh": sample["tanh"]["pred"]}}
    for act in ("tanh",):
        qw = quantize_weights(act)
        manifest["H"] = qw["H"]
        emit_weights_s(act, qw)
        print(f"  wrote export/{act}_weights.s  "
              f"(H={qw['H']}, {qw['H']*N_INPUTS}+{qw['H']}+{10*qw['H']}+10 words)")
    emit_expected(sample)
    (EXPORT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n",
                                          encoding="utf-8")
    print("  wrote export/expected_outputs.txt, manifest.json")
    print(f"  sample: test #{sample['index']}  label={sample['label']}  "
          f"pred tanh={sample['tanh']['pred']}")


if __name__ == "__main__":
    main()
