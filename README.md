# DLX-NN

A 32-bit multi-cycle DLX processor extended with a hardware neural-network activation
engine. Sigmoid, tanh, GELU, ReLU and softmax each execute as a single custom
instruction instead of a software routine.

Final project 3372, School of Electrical Engineering, Tel Aviv University.
Saed Abu Fool and Saleh Khalil, supervised by Oren Ganon.

Full details are in [the project book](Documents/project_book.pdf). This page is the
overview.

---

## Why

The baseline DLX is about as small as a working RISC gets. It has 32-bit integers,
add/sub/shift/compare/logic, and nothing else: no multiplier, no way to evaluate `e^x`,
and no way to even represent a fraction. Every activation function therefore turns into
a long instruction sequence. Our software sigmoid runs 28 instructions to produce one
value, and the software softmax over a short vector runs 558.

Activations are also unusually good candidates for cheap approximation. They feed layers
that are themselves noisy, so a small error is tolerable, and a piecewise-linear fit with
power-of-two slopes needs no multiplier at all. The engine is built entirely around that.

## What was built

Everything is signed Q16.16 fixed point, so the existing 32-bit integer datapath carries
fractional values with no floating-point hardware.

Sigmoid is a five-segment piecewise-linear fit with power-of-two slopes, so each segment
is one arithmetic shift plus one add. Tanh and GELU reuse that same core through
`tanh(x) = 2σ(2x) - 1` and `GELU(x) ≈ x·σ(1.702x)`, so three instructions share one
evaluator and the two derived functions cost little more than muxes. ReLU is a sign-bit
test, exact by construction.

Softmax is different in kind, because every output depends on every input. It runs a
two-pass online algorithm with a shift-based exponent and a piecewise-linear reciprocal,
neither of which needs a real `exp()` or a divider. Because it works on a vector in
memory rather than a register, it is a DMA engine that takes over the SRAM bus through a
new 2:1 arbiter while the CPU waits.

On the processor side, the control FSM grew from 21 to 26 states and the instruction set
gained six opcodes.

| Instruction | Opcode `[31:26]` | Assembly | Operation |
|---|---|---|---|
| `sigmoid` | `111000` | `sigmoid RD RS1 0x0` | `R(RD) = σ(R(RS1))` |
| `tanh` | `111001` | `tanh RD RS1 0x0` | `R(RD) = tanh(R(RS1))` |
| `gelu` | `111010` | `gelu RD RS1 0x0` | `R(RD) = GELU(R(RS1))` |
| `relu` | `111100` | `relu RD RS1 0x0` | `R(RD) = max(0, R(RS1))` |
| `softmax` | `111101` | `softmax Rout Rin len` | `M(R(Rout)..) = softmax(M(R(Rin)..))`, `len ≤ 2047` |
| `mult` | `111110` | `mult SRC2 SRC1 imm` | `R(RD) = (R(RS1)·R(RS2)) >> 16` |

Encoding details and the operand-order quirks of `softmax` and `mult` are in
[RESA_ENV/RESA_ENV_MULT/OPCODES.md](RESA_ENV/RESA_ENV_MULT/OPCODES.md).

## Results

Three targets were set at the start. Two were met, one was not.

**Accuracy**, required MSE ≤ 0.025 against exact float64:

| Function | Sweep | MSE |
|---|---|---|
| Sigmoid | [-10, 10] | 4.70e-5 |
| Tanh | [-4, 4] | 2.35e-4 |
| GELU | [-5, 5] | 4.92e-4 |
| ReLU | [-8, 8] | 0 |
| Softmax | 1,050 vectors, N ≤ 500 | 1.03e-4 |


**Latency**, required ≥ 30 % fewer clock cycles than the software version. Measured on
the matched program pairs in `asm/`, whole program, first fetch to halt:

| Function | SW cycles | HW cycles | Reduction |
|---|---|---|---|
| Sigmoid | 249 | 57 | 77.1 % |
| Tanh | 347 | 57 | 83.6 % |
| GELU | 387 | 58 | 85.0 % |
| ReLU | 72 | 57 | 20.8 % |
| Softmax | 4,675 | 163 | 96.5 % |
| **All five** | **5,730** | **392** | **93.2 %** |

ReLU misses the bar and always was going to. Its software version is eight instructions,
so there is almost nothing for hardware to remove. The saving scales with how expensive
the function was to emulate, which is why softmax gains the most.

**Area**, budgeted at ≤ 20 % extra LUTs per function, so 100 % for all five. Measured
post-map on the Spartan-6 XC6SLX25-2:

| Resource | Baseline DLX | DLX-NN | Overhead |
|---|---|---|---|
| Slice LUTs | 1,073 | 2,282 | +112.7 % |
| Slice registers | 676 | 1,183 | +75.0 % |

This one missed, by 12.7 percentage points. Almost all of it is softmax: the four scalar
functions are combinational and share one core, while softmax needs its own DMA engine,
a sequencing FSM and storage across two passes. It is also the block that returns the
most time, so the area-delay product still improves 13.5× on softmax alone and 6.9×
across all five programs. Worth the trade, but the number is the number.

## Verification

Every unit was written twice: once as synthesisable Verilog, once as a Python model that
reproduces the hardware datapath exactly, same word format, same segment boundaries, same
truncations. The Python model is the reference the RTL is checked against, and it also
emits the test vectors the SystemVerilog testbenches read.

The scalar sweeps are exhaustive over the band where each function is non-trivial, at
full Q16.16 resolution: 1,835,024 comparisons across sigmoid, tanh and GELU, plus
655,361 for the shift-based exponent and 1,044,481 for the reciprocal. Softmax takes a
vector and cannot be covered that way, so it gets 1,050 directed and constrained-random
cases with N up to 500, driven through a behavioural SRAM the same way the DLX drives
the real engine.

## The digit demo

`asm/nn-demo/` runs a real network rather than a single activation call: a 256 → 16 → 10
MLP with a tanh hidden layer and a softmax output, trained on UCI optdigits-orig and
quantised to Q16.16, scoring 95.44 % on the test split. Python trains and exports it,
then emits it as DLX assembly in matched software and accelerated forms. Ready-to-run
programs for digits 0 through 9 are committed, and any new photo of a handwritten digit
can be turned into the same pair. Same prediction either way, about 15× fewer cycles.

## Repository layout

| Path | Contents |
|---|---|
| `py/` | Python golden models, the numerical reference for everything else. Each script sweeps its range, writes an error summary and plots, and can emit the SystemVerilog vector headers the testbenches read. |
| `design/` | Standalone activation-engine RTL and its verification environment: `ActivationEngine.v` on top, then one directory per unit, each with its testbenches, vectors and Makefile. |
| `DLX/` | The processor. `SOURCE_VER_before_edit/` is the FPGA build with constraints and bitstream, `HOME_VER_before_edit/` the simulation build with the DLX-level testbenches and SRAM images, and `IO_SIMUL_VER/` and `Lab_base/` the untouched laboratory baselines kept for the area comparison. |
| `asm/` | Matched software/hardware program pairs, one directory per activation. Both run identical math on identical inputs, so the cycle counts above compare honestly. |
| `asm/nn-demo/` | The handwritten-digit classifier: `py-nn/` trains and quantises, `asm-nn/` emits the assembly. |
| `RESA_ENV/` | The RESA monitor working set: `commands.xml` (the assembler's instruction table, source of truth), `OPCODES.md`, label files, test programs and bitstreams. |
| `Documents/` | Project book, final presentation, results workbook. |

Toolchain is Xilinx ISE 14.7 for synthesis and the FPGA, Icarus Verilog for RTL
simulation, Verilator for coverage, Python 3.9+ for the models, and the RESA lab tool
for assembling programs.

## Documents

- [Documents/project_book.pdf](Documents/project_book.pdf) — full report
- [Documents/DLX-NN_Final_Presentation.pptx](Documents/DLX-NN_Final_Presentation.pptx)
- [Documents/project_results.xlsx](Documents/project_results.xlsx) — the measurements behind the tables above

## References

1. Z. Pan et al., "A Modular Approximation Methodology for Efficient Fixed-Point
   Hardware Implementation of the Sigmoid Function," *IEEE Transactions on Industrial
   Electronics*, 2022.
2. K. Hirayae et al., "Hardware-Oriented and Precisely Approximated Online Softmax for
   Deep Learning Models," *IEEE ICECS*, 2025.
3. "Simple DLX — Laboratory Specification and Handouts," Tel Aviv University, Faculty of
   Engineering.
