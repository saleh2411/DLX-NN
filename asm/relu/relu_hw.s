pc = 0x0                        * address of the program in main memory

* ============================================================
* relu_hw.s  -  ReLU via the HARDWARE activation unit
*                  (the project's new "relu" instruction).
*
* Contrast with relu_sw.s (software: compare + branch, ~5 instr):
* here the whole activation collapses into ONE instruction; the
* engine returns max(0, R(RS1)) directly (combinational ReLU.v).
*
* THE INSTRUCTION  (project extension, defined in RESA commands.xml):
*   relu RD RS1 imm        R(RD) = max(0, R(RS1))
*   (always write the imm as 0x0 - the assembler needs the full
*    lw-style operand list; the hardware ignores the field)
*
*   Encoding (I-type): opcode[31:26]=111100 | RS1[25:21] | RD[20:16] | imm[15:0]=0
*   Decoded by dlx_control: D11_RELU = 111100 -> S_RELU -> S_WBI.
*   Hand-encoded equivalent:  relu R2 R1 0x0  ==  dc 0xF0220000
*   For other registers RD,RS1:  word = F0000000 | (RS1<<21) | (RD<<16).
*
* FIXED-POINT CONVENTION  (Q16.16):
*   represent real r as  round(r * 2^16).  SCALE = 65536 = 0x10000.
*
* SANITY CHECK:  x = -1.5 (0xFFFE8000) -> result = 0x00000000
*                x = +1.5 (0x00018000) -> result = 0x00018000
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
input:  dc 0xFFFE8000           * x = -1.5 in Q16.16. EDIT ME.
result: ds 1                    * relu(x) output, Q16.16

* ============================================================
* MAIN
* ============================================================
main:   lw   R1 R0 input        * R1 = x_q  (Q16.16 input)
        relu R2 R1 0x0          * R2 = max(0, R1)   <-- HW activation unit
        sw   R2 R0 result       * result = y_q  (Q16.16 output)
        halt
