pc = 0x0                        * address of the program in main memory

* ============================================================
* sigmoid_hw.s  -  Sigmoid via the HARDWARE activation unit
*                     (the project's new "sigmoid" instruction).
*
* Contrast with sigmoid_sw.s (software piecewise-linear, ~40 instr):
* here the whole approximation collapses into ONE instruction that
* the Activation Unit executes in a single cycle.
*
* THE INSTRUCTION  (project extension, defined in RESA commands.xml):
*   sigmoid RD RS1 imm        R(RD) = sigmoid(R(RS1))
*   (always write the imm as 0x0 - the assembler needs the full
*    lw-style operand list; the hardware ignores the field)
*
*   Encoding (I-type): opcode[31:26]=111000 | RS1[25:21] | RD[20:16] | imm[15:0]=0
*   Decoded by dlx_control: opcode pattern 1110?? -> state S_SIGMOID -> S_WBI.
*   ActivationEngine selects the mode from opcode[1:0]:
*       111000 = sigmoid    111001 = tanh    111010 = gelu
*   Engine input  = R(RS1) (the A/S1 datapath), output written to R(RD).
*   The immediate field is unused by the hardware.
*   Hand-encoded equivalent:  sigmoid R2 R1 0x0  ==  dc 0xE0220000
*   For other registers RD,RS1:  word = E0000000 | (RS1<<21) | (RD<<16).
*
* FIXED-POINT CONVENTION  (Q16.16), identical to the software version:
*   represent real r as  round(r * 2^16).  SCALE = 65536 = 0x10000.
*     - input  x : write round(x * 65536) into 'input'
*     - output y : read  result / 65536
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
input:  dc 0x28000              * x = 2.5 in Q16.16 (2.5*65536). EDIT ME.
result: ds 1                    * sigmoid(x) output, Q16.16

* ============================================================
* MAIN
* ============================================================
main:   lw      R1 R0 input     * R1 = x_q  (Q16.16 input)
        sigmoid R2 R1 0x0       * R2 = sigmoid(R1)   <-- HW activation unit
        sw      R2 R0 result    * result = y_q  (Q16.16 output)
        halt
