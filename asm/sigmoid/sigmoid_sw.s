pc = 0x0                        * address of the program in main memory

* ============================================================
* sigmoid_sw.s  -  Sigmoid via piecewise-linear approximation
*               on the conventional (integer-only) simple DLX.
*
* Mirrors sigmoid0_q16_16() from py/sigmoid/sigmoid.py:
*   sigma(x) = 1 / (1 + e^-x)   approximated by 5 line segments.
*
* FIXED-POINT CONVENTION  (Q16.16):
*   The DLX has integers only, so a real number r is represented
*   as the integer  round(r * 2^16).  SCALE = 65536 = 0x10000.
*     - put the input  x as  round(x * 65536)
*     - read the output y as  result / 65536
*
* WHY NO MULTIPLY IS NEEDED:
*   q_mul(a,b) = (a*b) >> 16. Every segment slope here is a
*   negative power of two, so q_mul(slope,x) becomes a pure shift:
*     slope 1/4  (16384=2^14): (2^14 * x)>>16 = x >> 2
*     slope 1/8  ( 8192=2^13): x >> 3
*     slope 1/32 ( 2048=2^11): x >> 5
*   The DLX shifts one bit per srli, so we chain srli instructions.
*
* SEGMENTS (for x >= 0, all values in Q16.16):
*   x >= 5.0                 -> 1.0                       (saturate)
*   2.375 <= x < 5.0         -> (x>>5) + 0.84375
*   1.125 <= x < 2.375       -> (x>>3) + 0.625
*   0.875 <= x < 1.125       -> (x>>3) + 0.6060586   (Taylor repair)
*   0.0   <= x < 0.875       -> (x>>2) + 0.5
*   x < 0                    -> 1.0 - sigma(-x)       (odd symmetry)
*
* I/O:  input x at label 'input', result written to label 'result'.
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
input:  dc 0x28000              * x = 2.5  in Q16.16 (2.5*65536). EDIT ME.
result: ds 1                    * sigmoid(x) output, Q16.16

* ------------------------------------------------------------
* CONSTANTS  (Q16.16) -- too big for a 16-bit immediate, so dc+lw
* ------------------------------------------------------------
cONE:   dc 0x10000              * 1.0
cX5:    dc 0x50000              * 5.0       segment threshold
cX2375: dc 0x26000              * 2.375     segment threshold
cX1125: dc 0x12000              * 1.125     segment threshold
cX0875: dc 0xe000               * 0.875     segment threshold
cB2732: dc 0xd800               * 0.84375   intercept (27/32)
cB58:   dc 0xa000               * 0.625     intercept (5/8)
cBTAY:  dc 0x9b27               * 0.6060586 intercept (Taylor repair @ x=1)
cB12:   dc 0x8000               * 0.5       intercept (1/2)

* ============================================================
* MAIN  -  load x, call sigmoid subroutine, store y, halt
* ============================================================
main:   lw   R1 R0 input        * R1 = x_q   (subroutine argument)
        addi R7 R0 sigsub       * R7 = address of sigmoid subroutine
        jalr R7                 * call: R2 = sigmoid(R1), R31 = return
        sw   R2 R0 result       * result = y_q
        halt

* ============================================================
* sigsub  -  R2 = sigmoid0(R1), Q16.16
*   (named 'sigsub', NOT 'sigmoid': that is now an instruction)
*   in : R1 = x_q (signed)
*   out: R2 = y_q
*   uses R3 (sign), R5 (compare temp), R6 (constant temp)
*   no nested calls, so R31 is safe to return through.
* ============================================================
* ---- handle negative x via  sigma(x) = 1 - sigma(-x) ----
sigsub: addi R3 R0 0x0000       * sign = 0
        slti R5 R1 0x0000       * R5 = 1 if x < 0
        beqz R5 sigpos          * x >= 0 -> no mirror
        sub  R1 R0 R1           * x = -x   (now x >= 0)
        addi R3 R0 0x0001       * sign = 1

* ---- segment 1:  x >= 5.0  -> y = 1.0 ----
sigpos: lw   R6 R0 cX5          * R6 = 5.0
        sub  R5 R1 R6           * R5 = x - 5.0
        slti R5 R5 0x0000       * R5 = 1 if x < 5.0
        bnez R5 sigseg2         * x < 5.0 -> next segment
        lw   R2 R0 cONE         * y = 1.0
        beqz R0 sigsign         * apply sign, return

* ---- segment 2:  2.375 <= x < 5.0  -> y = (x>>5) + 0.84375 ----
sigseg2: lw  R6 R0 cX2375       * R6 = 2.375
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if x < 2.375
        bnez R5 sigseg3
        srli R2 R1              * x >> 1
        srli R2 R2              * x >> 2
        srli R2 R2              * x >> 3
        srli R2 R2              * x >> 4
        srli R2 R2              * x >> 5   (= x * 1/32)
        lw   R6 R0 cB2732       * R6 = 0.84375
        add  R2 R2 R6           * y = (x>>5) + 0.84375
        beqz R0 sigsign

* ---- segment 3:  1.125 <= x < 2.375  -> y = (x>>3) + 0.625 ----
sigseg3: lw  R6 R0 cX1125       * R6 = 1.125
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if x < 1.125
        bnez R5 sigseg4
        srli R2 R1              * x >> 1
        srli R2 R2              * x >> 2
        srli R2 R2              * x >> 3   (= x * 1/8)
        lw   R6 R0 cB58         * R6 = 0.625
        add  R2 R2 R6           * y = (x>>3) + 0.625
        beqz R0 sigsign

* ---- segment 4:  0.875 <= x < 1.125  -> y = (x>>3) + 0.6060586 ----
sigseg4: lw  R6 R0 cX0875       * R6 = 0.875
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if x < 0.875
        bnez R5 sigseg5
        srli R2 R1              * x >> 1
        srli R2 R2              * x >> 2
        srli R2 R2              * x >> 3   (= x * 1/8)
        lw   R6 R0 cBTAY        * R6 = 0.6060586 (Taylor repair @ x=1)
        add  R2 R2 R6           * y = (x>>3) + 0.6060586
        beqz R0 sigsign

* ---- segment 5:  0.0 <= x < 0.875  -> y = (x>>2) + 0.5 ----
sigseg5: srli R2 R1             * x >> 1
        srli R2 R2              * x >> 2   (= x * 1/4)
        lw   R6 R0 cB12         * R6 = 0.5
        add  R2 R2 R6           * y = (x>>2) + 0.5

* ---- if x was negative:  y = 1.0 - y ----
sigsign: beqz R3 sigret         * sign == 0 -> done
        lw   R6 R0 cONE         * R6 = 1.0
        sub  R2 R6 R2           * y = 1.0 - y

sigret: jr   R31                * return to caller
