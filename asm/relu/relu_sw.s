pc = 0x0                        * address of the program in main memory

* ============================================================
* relu_sw.s  -  ReLU in SOFTWARE on the conventional simple DLX.
*
* Mirrors the hardware ReLU.v:  y = max(0, x).
* No approximation needed - ReLU is exact in both worlds.
*
* FIXED-POINT CONVENTION  (Q16.16):
*   represent real r as  round(r * 2^16).  SCALE = 65536 = 0x10000.
*   (sign lives in bit 31, so the integer compare below is exact)
*
* I/O:  input x at label 'input', result written to label 'result'.
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
* MAIN  -  y = (x < 0) ? 0 : x
* ============================================================
main:   lw   R1 R0 input        * R1 = x_q
        slti R5 R1 0x0000       * R5 = 1 if x < 0
        beqz R5 store           * x >= 0 -> keep y = x
        add  R1 R0 R0           * y = 0
store:  sw   R1 R0 result       * result = y_q
        halt
