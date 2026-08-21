#!/usr/bin/env python3
"""
build_asm.py -- build self-contained DLX assembly programs for the
handwritten-digit MLP, from the trained weights exported by py-nn.

Emits a matched pair per image:  a "sw" program using the baseline DLX ISA only
(software multiply `mulq16` + software tanh), and a "hw" program using the
custom mult/tanh/softmax opcodes.

The hand-authored code (matrix-vector loops, the exact Q16.16 software multiply
`mulq16`, argmax, and the software tanh subroutine) lives in the string
templates below; only the large weight/sample data tables are filled in from
py-nn's quantized model, so the two sides can never drift.

Network:  256 (16x16) -> H -> 10 ; classification = argmax of the 10 output logits
(argmax(softmax(z)) == argmax(z)).  The hw program additionally runs the
`softmax` engine to produce the probability vector, then argmaxes it.

All arithmetic is Q16.16.  Memory is word-addressed (stride 1).

Library module: image_to_asm.py calls build(target, act) to emit
the per-image programs in generated/.
"""

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "py-nn"))
from quantize import quantize_weights, choose_sample          # noqa: E402
from nn_common import INPUT_SHIFT, N_INPUTS, GRID, RES, PIXEL_MAX   # noqa: E402
from dlx_emu import Program                                    # noqa: E402


def w(v):
    return f"0x{v & 0xFFFFFFFF:08X}"


def rep(instr, n):
    return [instr] * n


def data_section(qw, sample):
    """Emit the shared data section: sample image + this variant's weights."""
    H = qw["H"]
    px = sample["pixels"]
    L = []
    L.append("* ----------------- DATA (word-addressed, stride 1) -----------------")
    # Input image, Q16.16-encoded (pixel << INPUT_SHIFT == pixel/PIXEL_MAX).
    grid = "\n".join("*   " + " ".join(f"{px[r*GRID+c]:2d}" for c in range(GRID))
                     for r in range(GRID))
    L.append(f"* sample: optdigits-orig {RES} test #{sample['index']}, "
             f"label={sample['label']}")
    L.append(f"* raw {RES} pixel grid (0..{PIXEL_MAX}):")
    L.append(grid)
    first = px[0] << INPUT_SHIFT
    L.append(f"IMG:     dc {w(first)}    * pixel[0]={px[0]}  (Q16.16 = pixel<<{INPUT_SHIFT})")
    for i in range(1, N_INPUTS):
        L.append(f"         dc {w(px[i] << INPUT_SHIFT)}    * pixel[{i}]={px[i]}")
    # W1 row-major (h,i)
    W1 = qw["W1q"]
    L.append(f"W1DATA:  dc {w(int(W1[0][0]))}    * W1[0][0]  ({H}x{N_INPUTS} row-major)")
    for h in range(H):
        for i in range(N_INPUTS):
            if h == 0 and i == 0:
                continue
            tag = f"    * W1[{h}][0]" if i == 0 else ""
            L.append(f"         dc {w(int(W1[h][i]))}{tag}")
    b1 = qw["b1q"]
    L.append(f"B1DATA:  dc {w(int(b1[0]))}    * b1[0]")
    for h in range(1, H):
        L.append(f"         dc {w(int(b1[h]))}    * b1[{h}]")
    W2 = qw["W2q"]
    L.append(f"W2DATA:  dc {w(int(W2[0][0]))}    * W2[0][0]  (10x{H} row-major)")
    for k in range(10):
        for h in range(H):
            if k == 0 and h == 0:
                continue
            tag = f"    * W2[{k}][0]" if h == 0 else ""
            L.append(f"         dc {w(int(W2[k][h]))}{tag}")
    b2 = qw["b2q"]
    L.append(f"B2DATA:  dc {w(int(b2[0]))}    * b2[0]")
    for k in range(1, 10):
        L.append(f"         dc {w(int(b2[k]))}    * b2[{k}]")
    # scratch + results
    L.append(f"A1:      ds {H}                * hidden activations")
    L.append("Z2:      ds 10                * output logits")
    L.append("PROB:    ds 10                * softmax probabilities (hw)")
    L.append("PRED:    ds 1                 * <-- predicted digit lands here")
    L.append("cFFFF:   dc 0x0000FFFF        * low-16 mask (needs a reg; imm would sign-extend)")
    return L, H


# --- exact Q16.16 software multiply: R3 = (R1*R2)>>16, all logical shifts ----
def mulq16_sub():
    def umul(dst, x, m, lbl):
        # dst = (x * m) & 0xFFFFFFFF via shift-add over m's bits (m,tmpx destroyed)
        return [
            f"        add  {dst} R0 R0        * {lbl}: acc = 0",
            f"        add  R6 {x} R0          * tmpx = multiplicand",
            f"        add  R11 {m} R0         * m = multiplier (copy)",
            f"{lbl}:   beqz R11 {lbl}d        * while m != 0",
            "        and  R13 R11 R17        * bit = m & 1",
            f"        beqz R13 {lbl}s",
            f"        add  {dst} {dst} R6     * acc += tmpx",
            f"{lbl}s:  slli R6 R6             * tmpx <<= 1",
            "        srli R11 R11           * m >>= 1",
            f"        beqz R0 {lbl}          * loop",
            f"{lbl}d:   addi R0 R0 0x0        * umul done (landing pad)",
        ]
    L = []
    L += [
        "* ============================================================",
        "* mulq16 - EXACT Q16.16 signed multiply, baseline ISA only.",
        "*   in : R1 = A, R2 = B      out: R3 = (A*B) >> 16",
        "*   result = bits [47:16] of the 64-bit signed product, matching",
        "*   the hardware `mult` opcode bit-for-bit (verified in Python).",
        "*   Method (all shifts are logical srli/slli):",
        "*     sign-magnitude; a=|A|,b=|B|; split into 16-bit halves",
        "*     ah:al, bh:bl;  (a*b)>>16 = (ah*bh<<16)+ah*bl+al*bh+(al*bl>>16)",
        "*     then floor-correct for a negative result and re-apply sign.",
        "*   reserved regs: R17 = 1, R19 = 0x0000FFFF.  ret via R31.",
        "*   clobbers R1,R2,R4,R5,R6,R9-R16.  Leaves R17,R19,R20-R26 intact.",
        "* ============================================================",
        "mulq16:  addi R12 R0 0x0        * R12 = count of negative operands",
        "        slti R6 R1 0x0000",
        "        beqz R6 mqa",
        "        sub  R1 R0 R1          * a = |A|",
        "        addi R12 R12 0x1",
        "mqa:     slti R6 R2 0x0000",
        "        beqz R6 mqb",
        "        sub  R2 R0 R2          * b = |B|",
        "        addi R12 R12 0x1",
        "mqb:     and  R5 R1 R19         * al = a & 0xFFFF",
        "        and  R10 R2 R19        * bl = b & 0xFFFF",
        "        add  R4 R1 R0          * R4 = a",
    ]
    L += rep("        srli R4 R4             * (x16) ah = a >> 16", 16)
    L += ["        add  R9 R2 R0          * R9 = b"]
    L += rep("        srli R9 R9             * (x16) bh = b >> 16", 16)
    L += ["* four unsigned 16x16 partial products"]
    L += umul("R14", "R4", "R9", "uhh")     # hh   = ah*bh
    L += umul("R15", "R4", "R10", "uab")    # ahbl = ah*bl
    L += umul("R16", "R5", "R9", "ualh")    # albh = al*bh
    L += umul("R3", "R5", "R10", "uabl")    # albl = al*bl -> R3
    L += [
        "* combine:  R9 = rem (low 16 of albl), then t = hh<<16 + ahbl + albh + albl>>16",
        "        and  R9 R3 R19         * rem = albl & 0xFFFF (for floor correction)",
    ]
    L += rep("        srli R3 R3             * (x16) albl >> 16", 16)
    L += rep("        slli R14 R14           * (x16) hh << 16", 16)
    L += [
        "        add  R14 R14 R15       * + ahbl",
        "        add  R14 R14 R16       * + albh",
        "        add  R3 R14 R3         * R3 = |t| (truncated magnitude)",
        "        seqi R6 R12 0x1        * exactly one negative operand?",
        "        beqz R6 mqret          * positive result -> done",
        "        beqz R9 mqneg          * rem == 0 -> no floor correction",
        "        addi R3 R3 0x1         * floor(neg) = -(t+1) when remainder",
        "mqneg:   sub  R3 R0 R3          * apply sign: R3 = -t",
        "mqret:   jr   R31",
    ]
    return L



def tanh_sub():
    # tanh(x) = clamp(2*sigma0(2x) - 1); sigma0 = the 5-segment PWL sigmoid,
    # inlined (self-contained).  Bit-identical to py tanh0_q / the tanh opcode.
    return [
        "* ============================================================",
        "* tanhsub - R2 = tanh(R1) = clamp(2*sigma0(2*R1) - 1), Q16.16.",
        "*   sigma0 is the shift-only 5-segment PWL sigmoid, inlined.",
        "*   ret R31; clobbers R1,R3,R5,R6.  Matches the tanh opcode exactly.",
        "* ============================================================",
        "tanhsub: slli R1 R1             * z = 2*x",
        "        addi R3 R0 0x0000      * sign = 0",
        "        slti R5 R1 0x0000",
        "        beqz R5 thpos",
        "        sub  R1 R0 R1          * z = -z",
        "        addi R3 R0 0x0001      * sign = 1",
        "thpos:   lw   R6 R0 cX5",
        "        sub  R5 R1 R6",
        "        slti R5 R5 0x0000      * z < 5.0 ?",
        "        bnez R5 thseg2",
        "        lw   R2 R0 cONE        * sigma = 1.0",
        "        beqz R0 thsign",
        "thseg2:  lw   R6 R0 cX2375",
        "        sub  R5 R1 R6",
        "        slti R5 R5 0x0000      * z < 2.375 ?",
        "        bnez R5 thseg3",
        "        srli R2 R1",
        "        srli R2 R2",
        "        srli R2 R2",
        "        srli R2 R2",
        "        srli R2 R2             * z >> 5",
        "        lw   R6 R0 cB2732",
        "        add  R2 R2 R6          * + 0.84375",
        "        beqz R0 thsign",
        "thseg3:  lw   R6 R0 cX1125",
        "        sub  R5 R1 R6",
        "        slti R5 R5 0x0000      * z < 1.125 ?",
        "        bnez R5 thseg4",
        "        srli R2 R1",
        "        srli R2 R2",
        "        srli R2 R2             * z >> 3",
        "        lw   R6 R0 cB58",
        "        add  R2 R2 R6          * + 0.625",
        "        beqz R0 thsign",
        "thseg4:  lw   R6 R0 cX0875",
        "        sub  R5 R1 R6",
        "        slti R5 R5 0x0000      * z < 0.875 ?",
        "        bnez R5 thseg5",
        "        srli R2 R1",
        "        srli R2 R2",
        "        srli R2 R2             * z >> 3",
        "        lw   R6 R0 cBTAY",
        "        add  R2 R2 R6          * + 0.6060586",
        "        beqz R0 thsign",
        "thseg5:  srli R2 R1",
        "        srli R2 R2             * z >> 2",
        "        lw   R6 R0 cB12",
        "        add  R2 R2 R6          * + 0.5",
        "thsign:  beqz R3 thpost",
        "        lw   R6 R0 cONE",
        "        sub  R2 R6 R2          * sigma = 1 - sigma",
        "thpost:  slli R2 R2             * 2*sigma",
        "        lw   R6 R0 cONE",
        "        sub  R2 R2 R6          * 2*sigma - 1",
        "        lw   R6 R0 cONE",
        "        sub  R5 R2 R6",
        "        slei R5 R5 0x0000      * out <= 1.0 ?",
        "        bnez R5 thclo",
        "        lw   R2 R0 cONE        * clamp +1",
        "        beqz R0 thret",
        "thclo:   lw   R6 R0 cNEG1",
        "        sub  R5 R2 R6",
        "        sgei R5 R5 0x0000      * out >= -1.0 ?",
        "        bnez R5 thret",
        "        lw   R2 R0 cNEG1       * clamp -1",
        "thret:   jr   R31",
    ]


def tanh_consts():
    return [
        "cONE:    dc 0x00010000        * +1.0",
        "cNEG1:   dc 0xFFFF0000        * -1.0",
        "cX5:     dc 0x00050000        * 5.0",
        "cX2375:  dc 0x00026000        * 2.375",
        "cX1125:  dc 0x00012000        * 1.125",
        "cX0875:  dc 0x0000E000        * 0.875",
        "cB2732:  dc 0x0000D800        * 0.84375",
        "cB58:    dc 0x0000A000        * 0.625",
        "cBTAY:   dc 0x00009B27        * 0.6060586",
        "cB12:    dc 0x00008000        * 0.5",
    ]


def argmax_block(src):
    # PRED = argmax over src[0..9] (first index on ties, matching Python max()).
    return [
        "* ---- argmax over %s[0..9] -> PRED (first max on ties) ----" % src,
        f"        addi R25 R0 {src}",
        "        lw   R22 R25 0x0       * best = src[0]",
        "        addi R23 R0 0x0        * bestIdx = 0",
        "        addi R24 R0 0x0        * idx = 0",
        "        addi R26 R0 0xA        * count = 10",
        "amlp:    lw   R5 R25 0x0",
        "        sub  R6 R5 R22        * src[idx] - best",
        "        slei R6 R6 0x0000     * src[idx] <= best ?",
        "        bnez R6 amsk          * not strictly greater -> keep",
        "        add  R22 R5 R0        * best = src[idx]",
        "        add  R23 R24 R0       * bestIdx = idx",
        "amsk:    addi R25 R25 0x1",
        "        addi R24 R24 0x1",
        "        addi R26 R26 0xFFFF",
        "        bnez R26 amlp",
        "        addi R5 R0 PRED",
        "        sw   R23 R5 0x0       * PRED = bestIdx",
        "        halt",
    ]


def matvec_l1(H, target, act):
    L = ["* ---- Layer 1: A1[h] = act( b1[h] + sum_i W1[h][i]*IMG[i] ) ----",
         "        addi R20 R0 W1DATA    * weight ptr (row-major, runs continuously)",
         "        addi R21 R0 B1DATA    * bias ptr",
         "        addi R22 R0 A1        * output ptr",
         f"        addi R23 R0 0x{H:X}       * hidden-neuron counter",
         "l1n:     lw   R24 R21 0x0      * acc = b1[h]",
         "        addi R25 R0 IMG       * input ptr (reset per neuron)",
         f"        addi R26 R0 0x{N_INPUTS:X}      * input counter = {N_INPUTS}",
         "l1d:     lw   R1 R20 0x0       * A = W1[h][i]",
         "        lw   R2 R25 0x0       * B = IMG[i]"]
    if target == "sw":
        L.append("        jalr R7               * R3 = mulq16(A,B) = (A*B)>>16")
    else:
        L.append("        dc 0xF8221800         * mult: R3 = (R1*R2)>>16")
    L += ["        add  R24 R24 R3       * acc += product",
          "        addi R20 R20 0x1",
          "        addi R25 R25 0x1",
          "        addi R26 R26 0xFFFF",
          "        bnez R26 l1d"]
    if target == "sw":
        L += ["        add  R1 R24 R0        * arg = acc",
              "        jalr R8               * R2 = act(acc)"]
    else:
        op = "tanh"
        L += [f"        {op} R2 R24 0x0       * R2 = {op}(acc)"]
    L += ["        sw   R2 R22 0x0       * A1[h] = act(acc)",
          "        addi R21 R21 0x1",
          "        addi R22 R22 0x1",
          "        addi R23 R23 0xFFFF",
          "        bnez R23 l1n"]
    return L


def matvec_l2(H, target):
    L = ["* ---- Layer 2: Z2[k] = b2[k] + sum_h W2[k][h]*A1[h]  (no activation) ----",
         "        addi R20 R0 W2DATA",
         "        addi R21 R0 B2DATA",
         "        addi R22 R0 Z2",
         "        addi R23 R0 0xA       * 10 output neurons",
         "l2n:     lw   R24 R21 0x0      * acc = b2[k]",
         "        addi R25 R0 A1        * hidden ptr (reset per neuron)",
         f"        addi R26 R0 0x{H:X}       * hidden counter = H",
         "l2d:     lw   R1 R20 0x0       * A = W2[k][h]",
         "        lw   R2 R25 0x0       * B = A1[h]"]
    if target == "sw":
        L.append("        jalr R7               * R3 = mulq16(A,B)")
    else:
        L.append("        dc 0xF8221800         * mult: R3 = (R1*R2)>>16")
    L += ["        add  R24 R24 R3",
          "        addi R20 R20 0x1",
          "        addi R25 R25 0x1",
          "        addi R26 R26 0xFFFF",
          "        bnez R26 l2d",
          "        sw   R24 R22 0x0      * Z2[k] = acc (logit)",
          "        addi R21 R21 0x1",
          "        addi R22 R22 0x1",
          "        addi R23 R23 0xFFFF",
          "        bnez R23 l2n"]
    return L


def _addr_line(name, addr, nwords, note):
    size = "1 word " if nwords == 1 else f"{nwords} words"
    return f"*     {name:<7s} @ 0x{addr & 0xFFFFFFFF:08X} (dec {addr:5d})  {size:>9s}  {note}"


def memory_map_block(labels, target):
    """
    Build the MEMORY MAP comment block for the header: exact word addresses
    (from the just-assembled program, via dlx_emu.Program -- not hand-counted)
    for the input, the output, the weights and the scratch regions. This is
    what to read in a RESA/FPGA memory dump: IMG in, PRED (and Z2/PROB) out.
    """
    def span(a, b):
        return labels[b] - labels[a]

    L = ["*",
         "*   MEMORY MAP (word addresses -- read these in a RESA / FPGA mem dump):"]
    L.append(_addr_line("IMG", labels["IMG"], span("IMG", "W1DATA"),
                        f"<== INPUT: {RES} image pixels (Q16.16 = pixel<<{INPUT_SHIFT})"))
    L.append(_addr_line("PRED", labels["PRED"], span("PRED", "cFFFF"),
                        "<== OUTPUT: predicted digit 0-9, READ THIS"))
    L.append(_addr_line("Z2", labels["Z2"], span("Z2", "PROB"),
                        "output logits (Q16.16), pre-softmax"))
    prob_note = ("softmax probabilities (Q16.16)" if target == "hw"
                else "softmax probabilities (unused -- sw has no softmax stage)")
    L.append(_addr_line("PROB", labels["PROB"], span("PROB", "PRED"), prob_note))
    L.append(_addr_line("W1DATA", labels["W1DATA"], span("W1DATA", "B1DATA"),
                        "hidden-layer weights, row-major W1[h][i]"))
    L.append(_addr_line("B1DATA", labels["B1DATA"], span("B1DATA", "W2DATA"),
                        "hidden-layer biases"))
    L.append(_addr_line("W2DATA", labels["W2DATA"], span("W2DATA", "B2DATA"),
                        "output-layer weights, row-major W2[k][h]"))
    L.append(_addr_line("B2DATA", labels["B2DATA"], span("B2DATA", "A1"),
                        "output-layer biases"))
    L.append(_addr_line("A1", labels["A1"], span("A1", "Z2"),
                        "scratch: hidden activations"))
    L.append("*")
    return L


def build(target, act):
    qw = quantize_weights(act)
    sample = choose_sample()
    H = qw["H"]
    data, H = data_section(qw, sample)

    head = [
        "pc = 0x0                        * origin",
        "* ================================================================",
        f"* digit_{act}_{target}_{RES}.s  -  {RES} handwritten-digit MLP on DLX-NN",
        f"*   {N_INPUTS} ({RES}) -> {H} -> 10 ;  hidden = {act} ;  output = softmax ;  class = argmax",
        f"*   TARGET: {'baseline ISA only (software multiply + software ' + act + ')' if target=='sw' else 'custom mult/'+act+'/softmax opcodes'}",
        f"*   Known-answer: optdigits-orig {RES} test #{sample['index']}, "
        f"expected PRED = {sample['label']}.",
        "*   All values Q16.16; memory word-addressed (stride 1).",
        "* ================================================================",
        "start:   addi R1 R0 main        * jump over the data section",
        "        jr   R1",
        "        special-nop",
        "        special-nop",
    ]

    main = ["* ----------------------------- CODE -----------------------------",
            "main:    lw   R19 R0 cFFFF     * R19 = 0x0000FFFF (low-16 mask)",
            "        addi R17 R0 0x1       * R17 = 1 (bit test)"]
    if target == "sw":
        main.append("        addi R7 R0 mulq16     * R7 = software-multiply address")
        main.append("        addi R8 R0 tanhsub    "
                    "* R8 = activation subroutine address")
    main += matvec_l1(H, target, act)
    main += matvec_l2(H, target)

    if target == "hw":
        main += ["* ---- softmax engine over the 10 logits: PROB = softmax(Z2) ----",
                 "        addi R1 R0 Z2         * R1 = input base",
                 "        addi R2 R0 PROB       * R2 = output base",
                 "        dc 0xF422000A         * softmax: in=R1, out=R2, len=10",
                 ""]
        main += argmax_block("PROB")
    else:
        main += [""]
        main += argmax_block("Z2")

    subs = []
    if target == "sw":
        subs += [""]
        subs += mulq16_sub()
        subs += [""]
        subs += tanh_sub()

    lines = head + [""] + data
    if act == "tanh" and target == "sw":
        lines += tanh_consts()
    lines += [""] + main + subs

    # Resolve every label's real word address from the assembled program
    # itself (not hand-counted), then splice a MEMORY MAP block into the
    # header. Only comment lines are inserted, so no address shifts as a
    # result -- the addresses below are exactly what a mem dump will show.
    labels = Program(lines).labels
    insert_at = head.index("*   All values Q16.16; memory word-addressed (stride 1).") + 1
    head = head[:insert_at] + memory_map_block(labels, target) + head[insert_at:]

    lines = head + [""] + data
    if act == "tanh" and target == "sw":
        lines += tanh_consts()
    lines += [""] + main + subs
    return "\n".join(lines) + "\n", labels


