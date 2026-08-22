# RESA Instruction Set — Opcode Table

Generated from [`commands.xml`](commands.xml) (the RESA compiler's instruction
table). Keep this file in sync with `commands.xml` — the XML is the source of
truth the compiler actually reads.

Encoding fields:

- **I-type**: `opcode[31:26] | RS1[25:21] | RD[20:16] | imm[15:0]`
- **R-type**: `opcode[31:26]=000000 | RS1[25:21] | RS2[20:16] | RD[15:11] | ... | function[5:0]`
- **softmax (R-format)**: `opcode[31:26]=111101 | RS1[25:21] | RS2[20:16] | RD[15:11]=0 | vector_size[10:0]`

## Base instructions

| Instruction | Type | Opcode (binary) | Function (binary) | Operands |
|---|---|---|---|---|
| `lw` | I | `100011` | — | `RD RS1 imm` |
| `sw` | I | `101011` | — | `RD RS1 imm` |
| `addi` | I | `001011` | — | `RD RS1 imm` |
| `sgti` | I | `011001` | — | `RD RS1 imm` |
| `seqi` | I | `011010` | — | `RD RS1 imm` |
| `sgei` | I | `011011` | — | `RD RS1 imm` |
| `slti` | I | `011100` | — | `RD RS1 imm` |
| `snei` | I | `011101` | — | `RD RS1 imm` |
| `slei` | I | `011110` | — | `RD RS1 imm` |
| `beqz` | I | `000100` | — | `RS1 imm` (branch) |
| `bnez` | I | `000101` | — | `RS1 imm` (branch) |
| `jr` | I | `010110` | — | `RS1` |
| `jalr` | I | `010111` | — | `RS1` |
| `special-nop` | I | `110000` | — | — |
| `halt` | I | `111111` | — | — |
| `slli` | R | `000000` | `000000` | `RD RS1` |
| `srli` | R | `000000` | `000010` | `RD RS1` |
| `add` | R | `000000` | `100011` | `RD RS1 RS2` |
| `sub` | R | `000000` | `100010` | `RD RS1 RS2` |
| `and` | R | `000000` | `100110` | `RD RS1 RS2` |
| `or` | R | `000000` | `100101` | `RD RS1 RS2` |
| `xor` | R | `000000` | `100100` | `RD RS1 RS2` |

## Stack extension (earlier lab add-on)

| Instruction | Type | Opcode (binary) | Function (binary) | Operands |
|---|---|---|---|---|
| `popr` | R | `000000` | `111000` | `RD` |
| `pushr` | R | `000000` | `111001` | `RS1` |
| `pushp` | R | `000000` | `111010` | — |
| `clrs` | R | `000000` | `111011` | — |
| `topr` | R | `000000` | `111100` | `RD` |
| `popp` | R | `000000` | `111101` | — |

`pushi` (I-type, opcode `111001`) was **removed**: its opcode now belongs to `tanh`.

## Activation engine (final-project add-on)

All I-type. The trailing `imm` operand is **mandatory in the assembly syntax**
(RESA parses 2-operand I-types as `RS1 imm`); write `0x0` for everything except
`softmax`, where it is the vector length. Values are Q16.16 fixed-point.

| Instruction | Type | Opcode (binary) | Operands | Semantics |
|---|---|---|---|---|
| `sigmoid` | I | `111000` | `RD RS1 0x0` | `R(RD) = sigmoid(R(RS1))` |
| `tanh` | I | `111001` | `RD RS1 0x0` | `R(RD) = tanh(R(RS1))` |
| `gelu` | I | `111010` | `RD RS1 0x0` | `R(RD) = gelu(R(RS1))` |
| `relu` | I | `111100` | `RD RS1 0x0` | `R(RD) = max(0, R(RS1))` |
| `softmax` | R-format* | `111101` | `Rout Rin len` | softmax of `len`-long vector at `M(R(Rin))`, written to `M(R(Rout))`; `len <= 2047` |
| `mult` | I* | `111110` | `RS2 RS1 imm` (imm = RD×0x800, see note) | `R(RD) = (R(RS1)*R(RS2)) >> 16` — Q16.16 product, 3 cycles |

Notes:

- *`softmax` is an **R-format** instruction in the hardware:
  `opcode 111101 | RS1[25:21]=input base | RS2[20:16]=output base | RD[15:11]=0 | vector_size[10:0]`.
  In `commands.xml` it is declared as `<type>I</type>` **on purpose**: the
  I-type encoding emits the identical bit pattern when the length is ≤ 2047
  (the output register operand lands in [20:16] = the RS2 slot, and
  `imm[10:0]` = vector_size with `imm[15:11]` = 0). RESA's own R-type cannot
  express this format — it would force the fixed function code into bits
  [5:0], in the middle of vector_size. Do not exceed length 2047, or the
  excess bits corrupt the [15:11] field.
- `softmax` was moved from `111111` to `111101` to avoid clashing with `halt`;
  `D10_SOFTMAX` in `dlx_control.v` must be `12'b111101_??????` to match.
- *`mult` (opcode `111110`, the free slot before `halt`) is **R-format in
  hardware** (`opcode | RS1[25:21] | RS2[20:16] | RD[15:11] | 0`) but
  declared `<type>I</type>` in `commands.xml`, exactly like softmax: RESA's
  R-type encoder hardcodes opcode[31:26] to `000000` and silently ignores
  the entry's `<opcode>` (verified 2026-07: a type-R mult entry assembled
  `mult R2 R1 R6` to `0x00261000`, which the CPU decodes as a shift). The
  I-type encoding (`opcode | RS1<<21 | RD<<16 | imm`) emits the exact
  hardware word with the syntax **`mult SRC2 SRC1 imm`, `imm` = DEST
  register × 0x800** (= RD<<11). Example: "R2 = R1 × R6" is written
  `mult R6 R1 0x1000` and emits `0xF8261000` (R3→`0x1800`, R4→`0x2000`, …
  R31→`0xF800`). Note the operand order — first operand is the *second
  source*; the destination rides in the immediate. Writing three registers
  fails loudly instead of miscompiling. The hardware decode (`D14_MULT =
  12'b111110_??????`) ignores bits [10:0]. Semantics are Q16.16: the result
  is bits [47:16] of the 64-bit signed product. For plain integer products,
  pre-scale one operand by 2^16 first.
- Hand-encoding: `sigmoid R2 R1 0x0` == `E0220000`
  (`word = opcode<<26 | RS1<<21 | RD<<16 | imm`);
  `mult R3 R1 R2` == `F8221800`
  (`word = opcode<<26 | RS1<<21 | RS2<<16 | RD<<11`).
- RESA's built-in simulator does not model the activation math (sigmoid/tanh/
  gelu copy `RS1`→`RD`, softmax and mult are nops; relu is exact). Real
  results come from the FPGA.
