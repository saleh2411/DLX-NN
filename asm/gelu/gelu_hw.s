pc = 0x0                        * address of the program in main memory

* ============================================================
* gelu_hw.s  -  GELU via the HARDWARE activation unit
*                  (the project's new "gelu" instruction).
*
* Contrast with gelu_sw.s (software: x * sigma(1.707x) built from
* shifts + the PWL sigmoid, ~60 instr): here the whole activation
* collapses into ONE instruction that the Activation Unit executes.
* The engine computes  gelu(x) = x * sigmoid(1.702x)  where the
* 1.702 scaling is shift-add (1.70703125) - multiplier-free.
*
* THE INSTRUCTION  (project extension, defined in RESA commands.xml):
*   gelu RD RS1 imm        R(RD) = gelu(R(RS1))
*   (always write the imm as 0x0 - the assembler needs the full
*    lw-style operand list; the hardware ignores the field)
*
*   Encoding (I-type): opcode[31:26]=111010 | RS1[25:21] | RD[20:16] | imm[15:0]=0
*   Decoded by dlx_control: opcode pattern 1110?? -> activation state -> S_WBI.
*   ActivationEngine selects the mode from opcode[1:0]:
*       111000 = sigmoid    111001 = tanh    111010 = gelu
*   Hand-encoded equivalent:  gelu R2 R1 0x0  ==  dc 0xE8220000
*   For other registers RD,RS1:  word = E8000000 | (RS1<<21) | (RD<<16).
*
* FIXED-POINT CONVENTION  (Q16.16):
*   represent real r as  round(r * 2^16).  SCALE = 65536 = 0x10000.
*
* SANITY CHECK:  x = 1.5  (input = 0x00018000)
*   z = 1.707*1.5 = 2.5605 -> sigma0 = z/32 + 0.84375 = 0.9238
*   result ~ 0x000162BA (1.3857).  Exact gelu(1.5) = 1.3998.
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
input:  dc 0x18000              * x = 1.5 in Q16.16 (1.5*65536). EDIT ME.
result: ds 1                    * gelu(x) output, Q16.16

* ============================================================
* MAIN
* ============================================================
main:   lw   R1 R0 input        * R1 = x_q  (Q16.16 input)
        gelu R2 R1 0x0          * R2 = gelu(R1)   <-- HW activation unit
        sw   R2 R0 result       * result = y_q  (Q16.16 output)
        halt
