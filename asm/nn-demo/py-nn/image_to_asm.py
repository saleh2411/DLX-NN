#!/usr/bin/env python3
"""
image_to_asm.py -- turn ANY photo of a handwritten digit into ready-to-run DLX
assembly for the DLX-NN digit classifier.

Given one input image (an iPhone photo of a digit on paper, a scan, a screenshot
of a paint program...) it produces **three** files:

    <stem>_input16x16.png       the preprocessed image at the network's exact
                                input resolution (16x16 grayscale, values 0..4)
    <stem>_sw_16x16.s           software-only (baseline DLX ISA)
    <stem>_hw_16x16.s           hardware-accelerated (custom opcodes)

Every .s file is **self-contained**: this image's 64 pixels are baked into the
`IMG` data section, next to the weights and the inference code.  Copy one file
into the RESA compiler, compile, run to `halt`, read the word at `PRED`.


NETWORK VARIANT  (<-- adjust here if the network ever changes)
------------------------------------------------------------
Task 1 (../asm-nn) ships the 'tanh' variant: 64 -> 16 -> 10, one hidden
layer, hidden activation tanh, output softmax.  Named without a variant
qualifier.  The constant `ACT` below records it.


INPUT FORMAT (matches ../asm-nn exactly -- see py-nn/README.md)
---------------------------------------------------------------
    resolution   16x16 grayscale
    pixel range  integers 0..4    (ink = HIGH, background = 0)
    encoding     Q16.16 word = pixel << 14   (== pixel/4, so IMG in [0,1])
    memory       word-addressed, IMG[0..255] row-major, stride 1

The 0..4 range is not arbitrary: the training set is UCI *optdigits-orig*, the
original 32x32 NIST bitmaps.  A 16x16 sample is built by counting the set pixels
in each non-overlapping 2x2 block (0..4 per block).  (The classic 8x8 optdigits
is the same construction with 4x4 blocks -> 0..16.)  This script reproduces that
pipeline, so a photo lands in the same distribution the weights were trained on:

    EXIF-orient -> grayscale -> background flatten (BoxBlur) -> polarity detect
    -> Otsu binarise -> crop to ink bbox -> scale into a 32x32 canvas
    -> 2x2 block count -> 16x16 values in 0..4

CALIBRATION (why SPAN / CENTER / no blob filter are what they are)
------------------------------------------------------------------
Measured over the 1797-image optdigits test set, every sample's ink occupies
all 8 rows and (median) columns 1..6.  Because that bbox is quantised to whole
*cells*, the continuous stroke actually spans about 30/32 rows and 18/32
columns -- so scaling a photo's ink bbox to fill the full 32x32 canvas
misplaces it by up to half a cell.  `SPAN` below is that measured target.

The values were chosen by a round-trip experiment (optdigits 8x8 -> synthetic
photo with uneven lighting, sensor noise and +-6 deg rotation -> this pipeline
-> classify), sweeping span, centering and stage on/off:

    span 18x30, center-of-mass, no blob filter   ~71 %   <-- chosen
    span 32x32 (fill the canvas), no blob filter  ~57 %
    + "keep largest ink blob" enabled             ~53 %   (splits 4/5/7 apart)
    clean re-binarise ceiling for that harness     83 %
    classifying the original 8x8 directly          96 %

The blob filter therefore defaults OFF (it discards the detached strokes of
4, 5 and 7); enable it with --largest-blob only for photos with clutter in
frame.  The remaining gap to 83 % is an artifact of the harness re-binarising
an upscaled 8x8 -- it does not apply to a genuine photograph, whose strokes
are continuous to begin with.

POLARITY is decided from the high-passed image (a - BoxBlur(a)): the stroke is
whichever tail of that difference is larger.  It is NOT decided by comparing
the border's median brightness to the image's -- on a clean scan or screenshot
both medians saturate at 255, the comparison ties, and every digit is read
inverted: the high-pass then keeps only the bright halo *around* each stroke,
so the network sees hollow outlines and predicts nonsense.  Measured on the ten
drawings in photos/, that bug scored 1/20 (relu 0/10, tanh 1/10); with the
high-pass test it is 9/10 on both variants, auto-detected, and unchanged when
every photo is colour-inverted.

Nothing here is reimplemented from Task 1: the weights, the data-table layout,
the matrix-vector loops, the software `mulq16` multiply, the activation
subroutines and the custom-opcode words all come from `../asm-nn/build_asm.py`,
which is imported and driven with this image's pixels substituted for its
built-in optdigits sample.

Dependencies: numpy + pillow only (both already used by Task 1).

Usage
-----
    python image_to_asm.py photo.jpg
    python image_to_asm.py photo.jpg -o ../asm-nn/generated --name my_seven
    python image_to_asm.py photo.jpg --invert yes --span 20x30 --no-verify
    python image_to_asm.py photo.jpg --preview      # + a 6th, upscaled PNG
"""

import argparse
import sys
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter, ImageOps

HERE = Path(__file__).resolve().parent
ASM_NN = HERE.parent / "asm-nn"
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(ASM_NN))

from nn_common import PIXEL_MAX, GRID, BLOCK, BITS, RES   # noqa: E402
from quantize import quantize_weights, forward_q      # noqa: E402

# --- the only place the emitted network variant is defined -----------------
ACT = "tanh"            # 256 -> 16 -> 10, hidden = tanh, output = softmax
# GRID (16), BLOCK (2) and BITS (32) come from nn_common so this pipeline and
# the network always agree on the resolution.  BITS = GRID*BLOCK = 32 is the
# NIST bitmap side and is unchanged by the 8x8->16x16 switch (only BLOCK does:
# 4x4 blocks -> 0..16 became 2x2 blocks -> 0..4), so the 32x32-canvas framing
# and SPAN below stay valid.
SPAN = (18, 30)          # ink bbox target inside the 32x32 canvas, bitmap px (w, h)
WORK_MAX = 256           # photos are downscaled to this before thresholding


# ===========================================================================
# Image preprocessing
# ===========================================================================
def _otsu_threshold(a):
    """Otsu's between-class-variance threshold for a uint8 array."""
    hist = np.bincount(a.ravel(), minlength=256).astype(np.float64)
    p = hist / max(hist.sum(), 1.0)
    omega = np.cumsum(p)
    mu = np.cumsum(p * np.arange(256))
    mu_t = mu[-1]
    denom = omega * (1.0 - omega)
    with np.errstate(divide="ignore", invalid="ignore"):
        sigma_b = np.where(denom > 0, (mu_t * omega - mu) ** 2 / denom, 0.0)
    return int(np.argmax(sigma_b))


def _largest_blob(mask):
    """Keep only the biggest 8-connected component of a boolean mask."""
    h, w = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    best = None
    best_n = 0
    for sy, sx in zip(*np.nonzero(mask)):
        if seen[sy, sx]:
            continue
        comp = []
        q = deque([(sy, sx)])
        seen[sy, sx] = True
        while q:
            y, x = q.popleft()
            comp.append((y, x))
            y0, y1 = max(0, y - 1), min(h, y + 2)
            x0, x1 = max(0, x - 1), min(w, x + 2)
            for ny in range(y0, y1):
                for nx in range(x0, x1):
                    if mask[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        q.append((ny, nx))
        if len(comp) > best_n:
            best_n, best = len(comp), comp
    out = np.zeros_like(mask)
    if best:
        ys, xs = zip(*best)
        out[list(ys), list(xs)] = True
    return out


def _ink_mask(img_l, invert, verbose):
    """Grayscale PIL image -> boolean ink mask (True = stroke)."""
    # 1. work small: photos are megapixels, the network wants 8x8.
    img = img_l.copy()
    if max(img.size) > WORK_MAX:
        s = WORK_MAX / max(img.size)
        img = img.resize((max(1, round(img.width * s)),
                          max(1, round(img.height * s))), Image.LANCZOS)
    a = np.asarray(img, dtype=np.int16)

    # 2. flatten uneven lighting / shadows: subtract a blurred background.
    radius = max(2, min(a.shape) // 8)
    bg = np.asarray(img.filter(ImageFilter.BoxBlur(radius)), dtype=np.int16)

    # 3. polarity, decided on the high-pass image itself: whichever tail of
    #    (a - bg) is larger is the stroke, because the stroke is the thing that
    #    deviates most from its own local background.  (Comparing the border's
    #    median to the whole image's median fails on a clean scan/screenshot:
    #    both medians saturate at 255, the strict `>` is False, and every digit
    #    is then read inverted -- only the bright halo *around* each stroke
    #    survives the high-pass, so the network sees hollow outlines.)
    if invert == "auto":
        d = a.astype(np.float32) - bg
        lo, hi = np.percentile(d, 0.5), np.percentile(d, 99.5)
        dark_ink = (-lo) > hi
    else:
        dark_ink = (invert == "yes")
    if verbose:
        print(f"  polarity        : ink is {'dark' if dark_ink else 'light'} "
              f"on a {'light' if dark_ink else 'dark'} background"
              f"{' (auto)' if invert == 'auto' else ''}")

    # 4. ink strength (always: high = ink), then Otsu.
    strength = (bg - a) if dark_ink else (a - bg)
    strength = np.clip(strength, 0, 255).astype(np.uint8)
    thr = _otsu_threshold(strength)
    mask = strength > thr
    if verbose:
        print(f"  otsu threshold  : {thr}   ink pixels: {int(mask.sum())}"
              f" / {mask.size}")
    return mask


def _to_canvas(mask, span, center, verbose):
    """
    Ink mask -> 8x8 counts, via the optdigits construction.

    The ink bounding box is scaled (independently in x and y -- optdigits is
    not aspect-preserving, see CALIBRATION) to `span` bitmap pixels inside the
    32x32 canvas, then each 4x4 block is summed to one 0..16 value.  Area
    averaging (Image.BOX) gives each bitmap pixel its ink *coverage*, so the
    block sum is exactly "how many of these 16 subpixels are inked".
    """
    ys, xs = np.nonzero(mask)
    crop = mask[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    bw, bh = span
    cov = np.asarray(
        Image.fromarray((crop * 255).astype(np.uint8), "L").resize((bw, bh), Image.BOX),
        dtype=np.float32) / 255.0

    canvas = np.zeros((BITS, BITS), dtype=np.float32)
    if center == "mass" and cov.sum() > 0:
        cy = float((cov.sum(1) * np.arange(bh)).sum() / cov.sum())
        cx = float((cov.sum(0) * np.arange(bw)).sum() / cov.sum())
        oy, ox = round(BITS / 2 - cy), round(BITS / 2 - cx)
    else:
        oy, ox = (BITS - bh) // 2, (BITS - bw) // 2
    oy = max(0, min(BITS - bh, oy))
    ox = max(0, min(BITS - bw, ox))
    canvas[oy:oy + bh, ox:ox + bw] = cov
    if verbose:
        print(f"  ink bbox        : {crop.shape[1]}x{crop.shape[0]} px -> "
              f"{bw}x{bh} of the {BITS}x{BITS} bitmap at (x={ox},y={oy}), "
              f"centered by {center}")

    px = canvas.reshape(GRID, BLOCK, GRID, BLOCK).sum(axis=(1, 3))
    return np.clip(np.round(px), 0, PIXEL_MAX).astype(int)


def preprocess(path, invert="auto", span=SPAN, center="mass", keep_blob=False,
               verbose=True):
    """Any image file -> 8x8 numpy array of ints in [0, PIXEL_MAX]."""
    img = ImageOps.exif_transpose(Image.open(path)).convert("L")
    if verbose:
        print(f"  source          : {img.width}x{img.height} px")

    mask = _ink_mask(img, invert, verbose)
    if not mask.any():
        raise SystemExit(f"error: no ink found in {path} -- try --invert yes/no")
    if keep_blob:
        mask = _largest_blob(mask)
    return _to_canvas(mask, span, center, verbose)


def ascii_grid(px):
    ramp = " .:-=+*#%@"
    return "\n".join(
        "".join(ramp[min(len(ramp) - 1, v * len(ramp) // (PIXEL_MAX + 1))] * 2
                for v in row) for row in px)


def save_png(px, path, scale=1):
    """Write the 8x8 grayscale PNG (values 0..16 stretched to 0..255)."""
    a = (px.astype(np.float64) * 255.0 / PIXEL_MAX).round().astype(np.uint8)
    img = Image.fromarray(a, mode="L")
    if scale > 1:
        img = img.resize((GRID * scale, GRID * scale), Image.NEAREST)
    img.save(path)
    return path


# ===========================================================================
# Assembly generation -- drives ../asm-nn/build_asm.py with our pixels
# ===========================================================================
def _sample_dict(px):
    """Same shape as quantize.choose_sample(), with our image's pixels."""
    pixels = [int(v) for v in px.reshape(-1)]
    out = {"index": -1, "pixels": pixels, "label": -1}
    z, pred = forward_q(quantize_weights(ACT), np.asarray(pixels))
    out[ACT] = {"logits": z, "pred": int(pred)}
    return out


def _retarget(text, act, target, out_name, src_image, pred, label):
    """
    Swap build_asm.py's optdigits-sample provenance comments for this image's.
    Only comment lines change -- the code and data are Task 1's, untouched.
    """
    subs = [
        (f"* digit_{act}_{target}_{RES}.s  -  {RES} handwritten-digit MLP on DLX-NN",
         f"* {out_name}  -  {RES} handwritten-digit MLP on DLX-NN\n"
         f"*   '{act}' variant of ../asm-nn"),
        (f"*   Known-answer: optdigits-orig {RES} test #-1, expected PRED = -1.",
         f"*   INPUT: user image \"{src_image}\", preprocessed to {RES} (0..{PIXEL_MAX})\n"
         f"*          and embedded below -- nothing else to load.\n"
         f"*   EXPECTED PRED = {pred}   (py-nn bit-exact Q16.16 model)"
         + (f"\n*   Stated ground truth = {label}" if label is not None else "")),
        (f"* sample: optdigits-orig {RES} test #-1, label=-1",
         f"* input: user image \"{src_image}\" (preprocessed, ink 0..{PIXEL_MAX})"),
    ]
    for old, new in subs:
        if text.count(old) != 1:
            raise SystemExit(
                "error: ../asm-nn/build_asm.py header changed; image_to_asm.py "
                f"can no longer find:\n  {old}")
        text = text.replace(old, new)
    return text


def generate_asm(px, outdir, stem, src_image, label, verbose=True):
    import build_asm                                          # noqa: E402

    sample = _sample_dict(px)
    build_asm.choose_sample = lambda: sample     # inject our image

    written = []
    pred = sample[ACT]["pred"]
    for target in ("sw", "hw"):
        name = f"{stem}_{target}_{RES}.s"
        raw_text, labels = build_asm.build(target, ACT)
        text = _retarget(raw_text, ACT, target, name, src_image, pred, label)
        path = outdir / name
        path.write_text(text, encoding="utf-8")
        written.append(path)
        if verbose:
            print(f"  wrote {path.name:<34} {ACT:4s} {target}  "
                  f"expected PRED={pred}  "
                  f"(mem: IMG@{labels['IMG']} PRED@{labels['PRED']})")
    return written, sample


def verify(paths, sample, verbose=True):
    """Assemble + run each .s in Task 1's DLX emulator; check PRED and logits."""
    from dlx_emu import Program, Emu, wrap32                   # noqa: E402
    ok = True
    for path in paths:
        want = sample[ACT]["pred"]
        want_z = [wrap32(v) for v in sample[ACT]["logits"]]
        prog = Program(str(path))
        emu = Emu(prog)
        emu.run()
        got = wrap32(emu.mem[prog.labels["PRED"]])
        got_z = [wrap32(emu.mem[prog.labels["Z2"] + i]) for i in range(10)]
        good = (got == want) and (got_z == want_z)
        ok &= good
        if verbose:
            print(f"  {path.name:<34} PRED={got} (want {want})  "
                  f"logits {'OK' if got_z == want_z else 'MISMATCH'}  "
                  f"steps={emu.steps}  {'PASS' if good else 'FAIL'}")
    return ok


# ===========================================================================
def main():
    ap = argparse.ArgumentParser(
        description="Photo of a handwritten digit -> 1 preprocessed PNG + 4 "
                    "ready-to-run DLX .s programs.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="emits the 'tanh' variant (64->16->10); "
               "see ACT in this file to switch.")
    ap.add_argument("image", help="input image (jpg/png/heic-as-png/...)")
    ap.add_argument("-o", "--outdir", default=str(ASM_NN / "generated"),
                    help="output directory for all 5 files "
                         "(default: ../asm-nn/generated)")
    ap.add_argument("--name", help="output basename (default: image file stem)")
    ap.add_argument("--invert", choices=("auto", "yes", "no"), default="auto",
                    help="'yes' = dark ink on light paper (default: auto-detect)")
    ap.add_argument("--span", default="%dx%d" % SPAN, metavar="WxH",
                    help="ink target size inside the %dx%d bitmap "
                         "(default %dx%d, measured from optdigits)"
                         % (BITS, BITS, SPAN[0], SPAN[1]))
    ap.add_argument("--center", choices=("mass", "bbox"), default="mass",
                    help="center the digit by ink center-of-mass (default) or "
                         "by its bounding box")
    ap.add_argument("--largest-blob", action="store_true",
                    help="keep only the biggest ink blob -- use for photos with "
                         "clutter in frame; OFF by default because it splits "
                         "the detached strokes of 4, 5 and 7")
    ap.add_argument("--label", type=int, choices=range(10),
                    help="the true digit, if known -- recorded in the .s header")
    ap.add_argument("--preview", action="store_true",
                    help="also write a 6th, 32x-upscaled PNG for eyeballing")
    ap.add_argument("--no-verify", action="store_true",
                    help="skip running the generated .s in Task 1's DLX emulator")
    args = ap.parse_args()

    src = Path(args.image)
    if not src.is_file():
        raise SystemExit(f"error: no such image: {src}")
    stem = args.name or src.stem
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    try:
        span = tuple(int(v) for v in args.span.lower().split("x"))
        if len(span) != 2 or not all(1 <= v <= BITS for v in span):
            raise ValueError
    except ValueError:
        raise SystemExit(f"error: --span must be WxH with 1..{BITS} each, "
                         f"got {args.span!r}")

    print(f"[1/4] preprocessing {src.name} -> {GRID}x{GRID}, 0..{PIXEL_MAX}")
    px = preprocess(src, invert=args.invert, span=span, center=args.center,
                    keep_blob=args.largest_blob)
    print(ascii_grid(px))
    print("      " + "  ".join(f"{v:2d}" for v in px[0]) + "   <- row 0")

    print(f"[2/4] writing preprocessed PNG")
    png = save_png(px, outdir / f"{stem}_input{RES}.png")
    print(f"  wrote {png.name:<34} {GRID}x{GRID} grayscale")
    if args.preview:
        save_png(px, outdir / f"{stem}_input{RES}_preview.png", scale=16)
        print(f"  wrote {stem}_input{RES}_preview.png (extra, --preview)")

    print(f"[3/4] generating DLX assembly (weights + code from ../asm-nn)")
    paths, sample = generate_asm(px, outdir, stem, src.name, args.label)

    if args.no_verify:
        print("[4/4] verification skipped (--no-verify)")
        ok = True
    else:
        print("[4/4] running each program in Task 1's DLX emulator")
        ok = verify(paths, sample)

    pred = sample[ACT]["pred"]
    print("=" * 68)
    print(f"prediction: {ACT} = {pred}")
    if args.label is not None:
        print(f"stated ground truth = {args.label}  -> "
              f"{'OK' if pred == args.label else 'WRONG'}")
    print(f"3 files in {outdir}")
    print("RESULT: " + ("ALL PROGRAMS PASS" if ok else "VERIFICATION FAILED"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
