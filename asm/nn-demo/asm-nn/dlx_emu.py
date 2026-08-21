#!/usr/bin/env python3
"""
dlx_emu.py -- a tiny DLX assembler + emulator for VALIDATING the digit-network
assembly in this directory before it is run on RESA / the FPGA.

Scope: exactly the instruction subset the digit programs use (base ISA) plus
the project activation/mult/softmax extensions.  Memory is word-addressed
(consecutive words differ by 1).  The activation/mult/softmax extensions are
modelled with the SAME Q16.16 golden approximations the FPGA implements
(imported from py-nn) -- unlike RESA's built-in simulator, which does not model
the activation math.  So a program that classifies correctly here is expected
to classify identically on the FPGA.

This is a verification aid, not the deliverable; the .s files are.

Usage:
    python3 dlx_emu.py path/to/program.s [--max-steps N] [--dump-label PRED]
"""

import argparse
import re
import sys
from pathlib import Path

# Reuse the exact golden approximations + Q16.16 helpers from py-nn.
_PYNN = Path(__file__).resolve().parents[0].parent / "py-nn"
sys.path.insert(0, str(_PYNN))
from nn_common import relu_q, tanh0_q, sigmoid0_q16_16, from_q, to_q   # noqa: E402
from quantize import qmul32                                            # noqa: E402
from softmax_golden import softmax_algo3                               # noqa: E402


def wrap32(v):
    v &= 0xFFFFFFFF
    return v - 0x1_0000_0000 if (v & 0x8000_0000) else v


def sext16(v):
    v &= 0xFFFF
    return v - 0x1_0000 if (v & 0x8000) else v


REG_RE = re.compile(r"^R(\d{1,2})$")


class Program:
    def __init__(self, source):
        """source: a path to a .s file, OR a list/tuple of source lines
        (used by build_asm.py to resolve label addresses before writing)."""
        self.labels = {}
        self.items = []          # list of dicts: {addr, kind, ...}
        self.origin = 0
        if isinstance(source, (list, tuple)):
            lines = list(source)
        else:
            lines = Path(source).read_text().splitlines()
        self._assemble(lines)

    def _assemble(self, lines):
        pending = []             # (label, kind, payload) before address assign
        for raw in lines:
            line = raw.split("*", 1)[0].strip()      # drop comment
            if not line:
                continue
            m = re.match(r"^pc\s*=\s*(0x[0-9a-fA-F]+|\d+)", line)
            if m:
                self.origin = int(m.group(1), 0)
                continue
            label = None
            m = re.match(r"^([A-Za-z_]\w*):\s*(.*)$", line)
            if m:
                label = m.group(1)
                line = m.group(2).strip()
            if not line:
                # bare label (RESA-illegal, but tolerate as a nop)
                pending.append((label, "instr", ("special-nop", [])))
                continue
            toks = line.replace(",", " ").split()
            mnem = toks[0]
            args = toks[1:]
            if mnem == "dc":
                pending.append((label, "dc", int(args[0], 0)))
            elif mnem == "ds":
                pending.append((label, "ds", int(args[0], 0)))
            else:
                pending.append((label, "instr", (mnem, args)))

        # pass 1: assign addresses (word-addressed)
        addr = self.origin
        for label, kind, payload in pending:
            if label:
                self.labels[label] = addr
            if kind == "ds":
                item = {"addr": addr, "kind": "ds", "n": payload}
                addr += payload
            else:
                item = {"addr": addr, "kind": kind, "payload": payload}
                addr += 1
            self.items.append(item)
        self.end_addr = addr

    def build_memory(self):
        mem = {}
        code = {}
        for it in self.items:
            a = it["addr"]
            if it["kind"] == "dc":
                mem[a] = wrap32(it["payload"])
                code[a] = ("word", wrap32(it["payload"]))
            elif it["kind"] == "ds":
                for i in range(it["n"]):
                    mem[a + i] = 0
            else:  # instr
                mem[a] = 0
                code[a] = ("instr", it["payload"])
        return mem, code


class Emu:
    def __init__(self, prog, max_steps=50_000_000):
        self.p = prog
        self.mem, self.code = prog.build_memory()
        self.R = [0] * 32
        self.pc = prog.origin
        self.max_steps = max_steps
        self.steps = 0
        self.mul_calls = 0

    def _imm(self, tok):
        if REG_RE.match(tok):
            raise ValueError(f"expected imm, got reg {tok}")
        if tok in self.p.labels:
            return self.p.labels[tok]
        return int(tok, 0)

    def _reg(self, tok):
        m = REG_RE.match(tok)
        if not m:
            raise ValueError(f"expected reg, got {tok}")
        return int(m.group(1))

    def setR(self, i, val):
        if i != 0:
            self.R[i] = wrap32(val)

    def run(self):
        while True:
            self.steps += 1
            if self.steps > self.max_steps:
                raise RuntimeError(f"exceeded max_steps at pc={self.pc}")
            cell = self.code.get(self.pc)
            if cell is None:
                raise RuntimeError(f"PC ran into non-code at {self.pc}")
            kind, payload = cell
            if kind == "word":
                if self._exec_word(payload):
                    return
                continue
            mnem, args = payload
            if self._exec_instr(mnem, args):
                return                     # halt

    # ---- custom ops encoded as raw dc words in the code stream ----
    def _exec_word(self, word):
        w = word & 0xFFFFFFFF
        op = (w >> 26) & 0x3F
        rs1 = (w >> 21) & 0x1F
        rs2 = (w >> 16) & 0x1F
        rd_r = (w >> 11) & 0x1F
        if op == 0b111110:            # mult: RD = (RS1*RS2)>>16
            self.setR(rd_r, qmul32(self.R[rs1], self.R[rs2]))
        elif op == 0b111101:          # softmax Rout=RS2base? see encoding
            self._softmax(rs1, rs2, w & 0x7FF)
        elif op == 0b111100:          # relu
            self.setR(rs2, relu_q(self.R[rs1]))
        elif op == 0b111001:          # tanh
            self.setR(rs2, tanh0_q(self.R[rs1]))
        elif op == 0b111000:          # sigmoid
            self.setR(rs2, sigmoid0_q16_16(self.R[rs1]))
        else:
            raise RuntimeError(f"unknown dc-word instruction 0x{w:08X} at {self.pc}")
        self.pc += 1
        return False

    def _softmax(self, in_base_reg, out_base_reg, length):
        base_in = self.R[in_base_reg]
        base_out = self.R[out_base_reg]
        xs = [from_q(wrap32(self.mem.get(base_in + i, 0))) for i in range(length)]
        y_float, _ = softmax_algo3(xs)
        for i, yv in enumerate(y_float):
            self.mem[base_out + i] = wrap32(to_q(yv))

    def _exec_instr(self, mnem, args):
        R = self.R
        npc = self.pc + 1
        if mnem == "special-nop":
            pass
        elif mnem == "nop":
            pass
        elif mnem == "halt":
            return True
        elif mnem == "addi":
            self.setR(self._reg(args[0]), R[self._reg(args[1])] + sext16(self._imm(args[2])))
        elif mnem == "move":
            self.setR(self._reg(args[0]), R[self._reg(args[1])])
        elif mnem in ("add", "sub", "and", "or", "xor"):
            d, a, b = (self._reg(x) for x in args)
            x, y = R[a], R[b]
            self.setR(d, {"add": x + y, "sub": x - y,
                          "and": (x & 0xFFFFFFFF) & (y & 0xFFFFFFFF),
                          "or": (x & 0xFFFFFFFF) | (y & 0xFFFFFFFF),
                          "xor": (x & 0xFFFFFFFF) ^ (y & 0xFFFFFFFF)}[mnem])
        elif mnem == "slli":
            self.setR(self._reg(args[0]), (R[self._reg(args[1])] & 0xFFFFFFFF) << 1)
        elif mnem == "srli":
            self.setR(self._reg(args[0]), (R[self._reg(args[1])] & 0xFFFFFFFF) >> 1)
        elif mnem == "lw":
            d, s, imm = self._reg(args[0]), self._reg(args[1]), self._imm(args[2])
            addr = wrap32(R[s] + sext16(imm)) & 0xFFFFFF
            self.setR(d, wrap32(self.mem.get(addr, 0)))
        elif mnem == "sw":
            d, s, imm = self._reg(args[0]), self._reg(args[1]), self._imm(args[2])
            addr = wrap32(R[s] + sext16(imm)) & 0xFFFFFF
            self.mem[addr] = wrap32(R[d])
        elif mnem in ("slti", "sgti", "sgei", "slei", "seqi", "snei"):
            d, s, imm = self._reg(args[0]), self._reg(args[1]), sext16(self._imm(args[2]))
            x = R[s]
            res = {"slti": x < imm, "sgti": x > imm, "sgei": x >= imm,
                   "slei": x <= imm, "seqi": x == imm, "snei": x != imm}[mnem]
            self.setR(d, 1 if res else 0)
        elif mnem == "beqz":
            if R[self._reg(args[0])] == 0:
                npc = self._imm(args[1])
        elif mnem == "bnez":
            if R[self._reg(args[0])] != 0:
                npc = self._imm(args[1])
        elif mnem == "jr":
            npc = R[self._reg(args[0])]
        elif mnem == "jalr":
            self.setR(31, self.pc + 1)
            npc = R[self._reg(args[0])]
        elif mnem in ("relu", "tanh", "sigmoid", "gelu"):
            d, s = self._reg(args[0]), self._reg(args[1])
            fn = {"relu": relu_q, "tanh": tanh0_q,
                  "sigmoid": sigmoid0_q16_16}[mnem]
            self.setR(d, fn(R[s]))
        elif mnem == "softmax":
            # softmax Rout Rin len
            self._softmax(self._reg(args[1]), self._reg(args[0]), self._imm(args[2]))
        else:
            raise RuntimeError(f"unsupported mnemonic '{mnem}' at pc={self.pc}")
        self.pc = npc
        return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("program")
    ap.add_argument("--dump-label", default="PRED")
    ap.add_argument("--dump-n", type=int, default=1)
    ap.add_argument("--max-steps", type=int, default=50_000_000)
    args = ap.parse_args()

    prog = Program(args.program)
    emu = Emu(prog, max_steps=args.max_steps)
    emu.run()
    base = prog.labels[args.dump_label]
    vals = [wrap32(emu.mem.get(base + i, 0)) for i in range(args.dump_n)]
    print(f"steps={emu.steps}")
    for i, v in enumerate(vals):
        print(f"  {args.dump_label}[{i}] = 0x{v & 0xFFFFFFFF:08X}  ({from_q(v):.6f})  int={v}")


if __name__ == "__main__":
    main()
