pc = 0x0                        * address of the program in main memory

* ============================================================
* softmax_hw.s  -  softmax via the HARDWARE activation unit
*                     (the project's new "softmax" instruction).
*
* Unlike sigmoid/tanh/gelu (single-cycle, register-to-register),
* softmax is multi-cycle: the engine DMAs the input vector from
* memory, computes shift-exp + PWL reciprocal, and writes the
* result vector back to memory while the CPU waits.
*
* THE INSTRUCTION  (project extension, R-format):
*   softmax Rout Rin len
*       M(R(Rout) .. R(Rout)+len-1) = softmax( M(R(Rin) .. R(Rin)+len-1) )
*
*   Encoding: opcode[31:26]=111101 | RS1[25:21]=Rin | RS2[20:16]=Rout
*             | RD[15:11]=0 | vector_size[10:0]=len
*   len must be <= 2047 (11-bit field).
*   In RESA's commands.xml this is declared as type I on purpose:
*   the I-type bit layout is identical for len <= 2047.
*   Hand-encoded equivalent:  softmax R2 R1 0x4  ==  dc 0xF4220004
*
* FIXED-POINT CONVENTION  (Q16.16):
*   inputs and outputs are round(r * 65536); the outputs are in
*   (0,1) and sum to ~1.0 (0x10000).
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA  -  input vector [1.0, 2.0, 3.0, 4.0], output 4 words
* expected ~ [0.0321, 0.0871, 0.2369, 0.6439] -> outputs around
*            [0x0837, 0x164C, 0x3CA6, 0xA4D7]  (approx, PWL hw)
* ------------------------------------------------------------
invec:  dc 0x10000              * x0 = 1.0   EDIT ME
invec1: dc 0x20000              * x1 = 2.0
invec2: dc 0x30000              * x2 = 3.0
invec3: dc 0x40000              * x3 = 4.0
outvec: ds 4                    * softmax results, Q16.16

* ============================================================
* MAIN
* ============================================================
main:   addi    R1 R0 invec     * R1 = &invec   (input vector base)
        addi    R2 R0 outvec    * R2 = &outvec  (output vector base)
        softmax R2 R1 0x4       * outvec[0..3] = softmax(invec[0..3])
        halt
