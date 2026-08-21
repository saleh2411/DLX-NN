pc = 0x0                        * address of the program in main memory

* ============================================================
* tanh_hw.s  -  tanh via the HARDWARE activation unit
*                  (the project's new "tanh" instruction).
*
* Contrast with tanh_sw.s (software: 2*sigma(2x)-1 built from the
* piecewise-linear sigmoid, ~40 instr): here the whole activation
* collapses into ONE instruction that the Activation Unit executes
* in a single cycle. No 2x scaling, no segments, no clamp -- the
* engine returns tanh(R(RS1)) directly.
*
* THE INSTRUCTION  (project extension, defined in RESA commands.xml):
*   tanh RD RS1 imm        R(RD) = tanh(R(RS1))
*   (always write the imm as 0x0 - the assembler needs the full
*    lw-style operand list; the hardware ignores the field)
*
*   Encoding (I-type): opcode[31:26]=111001 | RS1[25:21] | RD[20:16] | imm[15:0]=0
*   Decoded by dlx_control: opcode pattern 1110?? -> activation state -> S_WBI.
*   ActivationEngine selects the mode from opcode[1:0]:
*       111000 = sigmoid    111001 = tanh    111010 = gelu
*   Engine input  = R(RS1) (the A/S1 datapath), output written to R(RD).
*   The immediate field is unused by the hardware.
*   Hand-encoded equivalent:  tanh R2 R1 0x0  ==  dc 0xE4220000
*   For other registers RD,RS1:  word = E4000000 | (RS1<<21) | (RD<<16).
*
* FIXED-POINT CONVENTION  (Q16.16), identical to the software version:
*   represent real r as  round(r * 2^16).  SCALE = 65536 = 0x10000.
*     - input  x : write round(x * 65536) into 'input'
*     - output y : read  result / 65536      (y is in [-1, 1])
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
input:  dc 0x18000              * x = 1.5 in Q16.16 (1.5*65536). EDIT ME.
result: ds 1                    * tanh(x) output, Q16.16

* ============================================================
* MAIN
* ============================================================
main:   lw   R1 R0 input        * R1 = x_q  (Q16.16 input)
        tanh R2 R1 0x0          * R2 = tanh(R1)   <-- HW activation unit
        sw   R2 R0 result       * result = y_q  (Q16.16 output)
        halt
