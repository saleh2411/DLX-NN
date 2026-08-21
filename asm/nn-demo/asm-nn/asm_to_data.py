#!/usr/bin/env python3
"""asm_to_data.py -- assemble a generated DLX-NN .s program into a .data image.

Produces the same hex-word-per-line format the RESA compiler emits, so the
result drops straight into final_simple_DLX/.../ next to sram_softmax_test.data
and is read by REG_sram's $readmemh.

    python3 asm_to_data.py ../asm-nn/generated/four_hw_16x16.s -o out.data

Encodings come from RESA_ENV/commands.xml (the table the RESA assembler itself
reads), and the output is byte-for-byte checkable against a RESA-produced image
with --check.

    I-type : opcode[31:26] rs1[25:21] rd[20:16] imm[15:0]      "mnem RD RS1 imm"
    R-type : 000000 rs1[25:21] rs2[20:16] rd[15:11] funct[10:0]  "mnem RD RS1 RS2"
    branch : rs1[25:21], rd field = 31, imm = target - pc - 1
"""
import argparse, re
from pathlib import Path

I_TYPE = {                       # mnemonic -> opcode
    "lw": 0b100011, "sw": 0b101011, "addi": 0b001011, "sgei": 0b011011,
    "slti": 0b011100, "slei": 0b011110, "beqz": 0b000100, "bnez": 0b000101,
    "jr": 0b010110, "jalr": 0b010111, "special-nop": 0b110000,
    "halt": 0b111111, "sigmoid": 0b111000, "tanh": 0b111001,
    "gelu": 0b111010, "relu": 0b111100, "softmax": 0b111101, "mult": 0b111110,
    "seqi": 0b011010, "snei": 0b011101,
}
ONE_REG = {"jr", "jalr"}                            # mnem RS1
R_TYPE = {"add": 0b100011, "sub": 0b100010, "and": 0b100110,
          "or": 0b100101, "xor": 0b100100}         # RD RS1 RS2
R_SHIFT = {"slli": 0b000000, "srli": 0b000010}     # RD RS1 (one bit per instr)
BRANCH = {"beqz", "bnez"}
NO_OPERAND = {"halt", "special-nop"}

def reg(tok):
    m = re.fullmatch(r"[Rr](\d+)", tok)
    if not m:
        raise ValueError(f"not a register: {tok}")
    return int(m.group(1))

def parse(src):
    """-> list of (addr, kind, payload) plus the label table"""
    items, labels, pc = [], {}, 0
    for lineno, raw in enumerate(src.splitlines(), 1):
        line = raw.split("*")[0].rstrip()          # '*' starts a comment
        if not line.strip():
            continue
        m = re.match(r"\s*pc\s*=\s*(0x[0-9A-Fa-f]+|\d+)", line)
        if m:
            pc = int(m.group(1), 0)
            continue
        m = re.match(r"\s*([A-Za-z_][A-Za-z_0-9]*)\s*:\s*(.*)$", line)
        if m:                                      # label, maybe with code after
            labels[m.group(1)] = pc
            line = m.group(2)
            if not line.strip():
                continue
        toks = line.replace(",", " ").split()
        if toks[0] == "dc":
            items.append((pc, "word", int(toks[1], 0), lineno, raw))
            pc += 1
        elif toks[0] == "ds":
            n = int(toks[1], 0)
            for k in range(n):
                items.append((pc + k, "word", 0, lineno, raw))
            pc += n
        else:
            items.append((pc, "instr", toks, lineno, raw))
            pc += 1
    return items, labels

def encode(toks, pc, labels, lineno):
    mn = toks[0]
    def val(tok):
        if tok in labels:
            return labels[tok]
        return int(tok, 0)

    if mn in NO_OPERAND:
        op = I_TYPE[mn]
        # RESA emits the unused register fields as 31 for these
        return (op << 26) | (31 << 21) | (31 << 16) if mn == "special-nop" \
               else (op << 26)

    if mn in R_TYPE:                                # add/sub RD RS1 RS2
        rd, rs1, rs2 = reg(toks[1]), reg(toks[2]), reg(toks[3])
        return (rs1 << 21) | (rs2 << 16) | (rd << 11) | R_TYPE[mn]

    if mn in BRANCH:                                # bnez RS1 label
        rs1 = reg(toks[1])
        off = (val(toks[2]) - pc - 1) & 0xFFFF
        return (I_TYPE[mn] << 26) | (rs1 << 21) | (31 << 16) | off

    if mn in ONE_REG:                               # jr / jalr RS1
        return (I_TYPE[mn] << 26) | (reg(toks[1]) << 21) | (31 << 16)

    if mn in R_SHIFT:                               # slli/srli RD RS1
        rd, rs1 = reg(toks[1]), reg(toks[2])
        return (rs1 << 21) | (rd << 11) | R_SHIFT[mn]

    if mn in I_TYPE:                                # mnem RD RS1 imm
        op = I_TYPE[mn]
        rd, rs1 = reg(toks[1]), reg(toks[2])
        imm = val(toks[3]) & 0xFFFF if len(toks) > 3 else 0
        return (op << 26) | (rs1 << 21) | (rd << 16) | imm

    raise ValueError(f"line {lineno}: unknown mnemonic {mn!r}")

def assemble(path):
    items, labels = parse(Path(path).read_text())
    words = {}
    for addr, kind, payload, lineno, raw in items:
        w = payload if kind == "word" else encode(payload, addr, labels, lineno)
        words[addr] = (w & 0xFFFFFFFF, raw.rstrip())
    return words, labels

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("--check", help="RESA-produced .data to compare against")
    a = ap.parse_args()

    words, labels = assemble(a.source)
    top = max(words)
    name = Path(a.source).stem

    out = [
        "// " + "=" * 74,
        f"//   {name}.data",
        f"//   assembled from {a.source}",
        "//   16x16 handwritten-digit MLP:  256 -> 16 -> 10 -> argmax",
        "//   All values Q16.16, memory word-addressed (consecutive words differ by 1).",
        "//",
        f"//   >>> FINAL OUTPUT: PRED at word address {labels.get('PRED','?')} "
        f"(0x{labels.get('PRED',0):08X}) <<<",
        "//       PRED holds the predicted digit 0-9.",
        "//",
        "//   Other addresses worth dumping:",
    ]
    for sym in ("IMG", "A1", "Z2", "PROB", "PRED"):
        if sym in labels:
            out.append(f"//     {sym:6} @ 0x{labels[sym]:08X} ({labels[sym]:>6})")
    out += ["// " + "=" * 74]

    for addr in range(top + 1):
        w, src = words.get(addr, (0, ""))
        note = re.sub(r"\s+", " ", src.strip())[:60]
        out.append(f"{w:08X} // 0x{addr:05X} ({addr})  {note}".rstrip())

    Path(a.out).write_text("\n".join(out) + "\n")
    print(f"wrote {a.out}   {top + 1} words   PRED @ {labels.get('PRED')}")

    if a.check:
        ref = {}
        for line in Path(a.check).read_text().splitlines():
            m = re.match(r"\s*([0-9A-Fa-f]{8})\s*//\s*0x([0-9A-Fa-f]+)", line)
            if m:
                ref[int(m.group(2), 16)] = int(m.group(1), 16)
        bad = [ad for ad in sorted(set(ref) & set(words))
               if ref[ad] != words[ad][0]]
        same = len(set(ref) & set(words)) - len(bad)
        print(f"check vs {a.check}: {same} words identical, {len(bad)} differ")
        for ad in bad[:12]:
            print(f"   0x{ad:05X}  ref {ref[ad]:08X}  mine {words[ad][0]:08X}"
                  f"   {words[ad][1].strip()[:50]}")

if __name__ == "__main__":
    main()
