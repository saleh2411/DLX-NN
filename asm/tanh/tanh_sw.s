pc = 0x0                        * address of the program in main memory

* ============================================================
* tanh_sw.s  -  tanh via piecewise-linear approximation
*            on the conventional (integer-only) simple DLX.
*
* Mirrors tanh0_from_sigmoid0_q16_16() from py/sigmoid/tanh.py,
* which builds tanh out of the SAME 5-segment sigmoid used in
* asm/sigmoid/sigmoid_sw.s, via the identity:
*
*        tanh(x) = 2*sigma(2x) - 1
*
*   Proof:  2*sigma(2x) - 1 = 2/(1+e^-2x) - 1
*                           = (1 - e^-2x)/(1 + e^-2x)
*                           = tanh(x).
*
* So tanh needs NO new approximation tables: double the input,
* run the existing sigmoid, double the output, subtract one.
*
* FIXED-POINT CONVENTION  (Q16.16):
*   The DLX has integers only, so a real number r is represented
*   as the integer  round(r * 2^16).  SCALE = 65536 = 0x10000.
*     - put the input  x as  round(x * 65536)
*     - read the output y as  result / 65536      (y is in [-1, 1])
*
* SLOPE MULTIPLIES USE THE NEW mult INSTRUCTION:
*   mult computes (src1*src2)>>16 -- exactly the Q16.16 product
*   q_mul(slope,z).  RESA syntax: 'mult SRC2 SRC1 imm' with
*   imm = DEST reg * 0x800, so 'mult R6 R1 0x1000' is R2 = R1*R6.
*   Each segment is now ONE mult with the
*   slope constant instead of a chain of srli instructions:
*     slope 1/32 = 0x0800 : mult == z >> 5
*     slope 1/8  = 0x2000 : mult == z >> 3
*     slope 1/4  = 0x4000 : mult == z >> 2
*   (z >= 0 inside the segments, so mult is bit-identical to the
*   old srli chains.  The x2 doublings stay as single slli.)
*
* SIGMOID SEGMENTS (for z >= 0, all values in Q16.16):
*   z >= 5.0                 -> 1.0                       (saturate)
*   2.375 <= z < 5.0         -> (z>>5) + 0.84375
*   1.125 <= z < 2.375       -> (z>>3) + 0.625
*   0.875 <= z < 1.125       -> (z>>3) + 0.6060586   (Taylor repair)
*   0.0   <= z < 0.875       -> (z>>2) + 0.5
*   z < 0                    -> 1.0 - sigma(-z)       (odd symmetry)
*   (negative z is handled inside the sigmoid subroutine, so the
*    same routine serves negative x with no extra work.)
*
* I/O:  input x at label 'input', result written to label 'result'.
*
* SANITY CHECK:  x = 1.5  (input = 0x00018000)
*   z = 3.0 -> sigma0(3.0) = 0.9375 -> 2*0.9375 - 1 = 0.875
*   result = 0x0000E000  (0.875 in Q16.16).  Exact tanh(1.5)=0.9051.
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
input:  dc 0x18000              * x = 1.5  in Q16.16 (1.5*65536). EDIT ME.
result: ds 1                    * tanh(x) output, Q16.16

* ------------------------------------------------------------
* CONSTANTS  (Q16.16) -- too big for a 16-bit immediate, so dc+lw
* ------------------------------------------------------------
cONE:   dc 0x10000              * +1.0
cNEG1:  dc 0xffff0000           * -1.0   (= -65536, two's complement)
cX5:    dc 0x50000              * 5.0       segment threshold
cX2375: dc 0x26000              * 2.375     segment threshold
cX1125: dc 0x12000              * 1.125     segment threshold
cX0875: dc 0xe000               * 0.875     segment threshold
cB2732: dc 0xd800               * 0.84375   intercept (27/32)
cB58:   dc 0xa000               * 0.625     intercept (5/8)
cBTAY:  dc 0x9b27               * 0.6060586 intercept (Taylor repair @ z=1)
cB12:   dc 0x8000               * 0.5       intercept (1/2)
cS32:   dc 0x800                * 1/32      slope (Q16.16) for mult
cS8:    dc 0x2000               * 1/8       slope (Q16.16) for mult
cS4:    dc 0x4000               * 1/4       slope (Q16.16) for mult

* ============================================================
* MAIN  -  load x, compute tanh = 2*sigma(2x)-1, store y, halt
* ============================================================
main:   lw   R1 R0 input        * R1 = x_q
        slli R1 R1              * R1 = 2*x = z      (one left shift = *2)
        addi R7 R0 sigsub       * R7 = address of sigmoid subroutine
        jalr R7                 * R2 = sigma(z),  R31 = return

* ---- out = 2*sigma(z) - 1.0 ----
        slli R2 R2              * R2 = 2*sigma
        lw   R6 R0 cONE         * R6 = 1.0
        sub  R2 R2 R6           * R2 = 2*sigma - 1.0   (Q16.16, in [-1,1])

* ---- clamp to +1.0 ----
        lw   R6 R0 cONE         * R6 = 1.0
        sub  R5 R2 R6           * R5 = out - 1.0
        slei R5 R5 0x0000       * R5 = 1 if out <= 1.0
        bnez R5 chklow          * in range -> skip upper clamp
        add  R2 R6 R0           * out = 1.0

* ---- clamp to -1.0 ----
chklow: lw   R6 R0 cNEG1        * R6 = -1.0
        sub  R5 R2 R6           * R5 = out - (-1.0) = out + 1.0
        sgei R5 R5 0x0000       * R5 = 1 if out >= -1.0
        bnez R5 tdone           * in range -> skip lower clamp
        add  R2 R6 R0           * out = -1.0

tdone:  sw   R2 R0 result       * result = y_q
        halt

* ============================================================
* sigsub  -  R2 = sigmoid0(R1), Q16.16   (identical to sigmoid_sw.s)
*   (named 'sigsub', NOT 'sigmoid': that is now an instruction)
*   in : R1 = z_q (signed)
*   out: R2 = sigma_q
*   uses R3 (sign), R5 (compare temp), R6 (constant temp)
*   no nested calls, so R31 is safe to return through.
* ============================================================
* ---- handle negative z via  sigma(z) = 1 - sigma(-z) ----
sigsub: addi R3 R0 0x0000       * sign = 0
        slti R5 R1 0x0000       * R5 = 1 if z < 0
        beqz R5 sigpos          * z >= 0 -> no mirror
        sub  R1 R0 R1           * z = -z   (now z >= 0)
        addi R3 R0 0x0001       * sign = 1

* ---- segment 1:  z >= 5.0  -> y = 1.0 ----
sigpos: lw   R6 R0 cX5          * R6 = 5.0
        sub  R5 R1 R6           * R5 = z - 5.0
        slti R5 R5 0x0000       * R5 = 1 if z < 5.0
        bnez R5 sigseg2         * z < 5.0 -> next segment
        lw   R2 R0 cONE         * y = 1.0
        beqz R0 sigsign         * apply sign, return

* ---- segment 2:  2.375 <= z < 5.0  -> y = (z>>5) + 0.84375 ----
sigseg2: lw  R6 R0 cX2375       * R6 = 2.375
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if z < 2.375
        bnez R5 sigseg3
        lw   R6 R0 cS32         * R6 = 1/32
        mult R6 R1 0x1000       * R2 = (z * 1/32) >> 16 = z>>5
        lw   R6 R0 cB2732       * R6 = 0.84375
        add  R2 R2 R6           * y = (z>>5) + 0.84375
        beqz R0 sigsign

* ---- segment 3:  1.125 <= z < 2.375  -> y = (z>>3) + 0.625 ----
sigseg3: lw  R6 R0 cX1125       * R6 = 1.125
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if z < 1.125
        bnez R5 sigseg4
        lw   R6 R0 cS8          * R6 = 1/8
        mult R6 R1 0x1000       * R2 = (z * 1/8) >> 16 = z>>3
        lw   R6 R0 cB58         * R6 = 0.625
        add  R2 R2 R6           * y = (z>>3) + 0.625
        beqz R0 sigsign

* ---- segment 4:  0.875 <= z < 1.125  -> y = (z>>3) + 0.6060586 ----
sigseg4: lw  R6 R0 cX0875       * R6 = 0.875
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if z < 0.875
        bnez R5 sigseg5
        lw   R6 R0 cS8          * R6 = 1/8
        mult R6 R1 0x1000       * R2 = (z * 1/8) >> 16 = z>>3
        lw   R6 R0 cBTAY        * R6 = 0.6060586 (Taylor repair @ z=1)
        add  R2 R2 R6           * y = (z>>3) + 0.6060586
        beqz R0 sigsign

* ---- segment 5:  0.0 <= z < 0.875  -> y = (z>>2) + 0.5 ----
sigseg5: lw  R6 R0 cS4          * R6 = 1/4
        mult R6 R1 0x1000       * R2 = (z * 1/4) >> 16 = z>>2
        lw   R6 R0 cB12         * R6 = 0.5
        add  R2 R2 R6           * y = (z>>2) + 0.5

* ---- if z was negative:  y = 1.0 - y ----
sigsign: beqz R3 sigret         * sign == 0 -> done
        lw   R6 R0 cONE         * R6 = 1.0
        sub  R2 R6 R2           * y = 1.0 - y

sigret: jr   R31                * return to caller
