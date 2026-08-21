pc = 0x0                        * address of the program in main memory

* ============================================================
* gelu_sw.s  -  GELU in SOFTWARE on the simple DLX,
*            using the new mult instruction (Q16.16).
*
* Mirrors gelu0_q16_16() from py/sigmoid/GELU.py and the
* hardware gelu path in sigmoid_subenv.v:
*
*        gelu(x) = x * sigma(k*x)
*
* where k ~ 1.702 is realized EXACTLY like the hardware - as the
* shift-add   kx = x + x>>1 + x>>3 + x>>4 + x>>6 + x>>8
* (= 1.70703125*x, multiplier-free), computed on |x| and re-signed
* so the srli shifts never see a negative number.
*
* sigma() is the same 5-segment PWL sigmoid as sigmoid_sw.s/tanh_sw.s
* (segments + intercepts identical, slopes via mult).
*
* mult SYNTAX NOTE: hardware word = F8000000|RS1<<21|RS2<<16|RD<<11.
* Per repo convention the products are raw dc words with the
* meaning in the comment (RESA's mnemonic form hides the dest).
*
* FIXED-POINT CONVENTION  (Q16.16):
*   represent real r as  round(r * 2^16).  SCALE = 65536 = 0x10000.
*
* I/O:  input x at label 'input', result written to label 'result'.
*
* SANITY CHECK:  x = 1.5  (input = 0x00018000)
*   kx = 1.70703125*1.5 = 2.5605 (0x00028F80)
*   sigma0(2.5605) = 2.5605/32 + 0.84375 = 0.92377   (0x0000EC7C)
*   result = 1.5 * 0.92377 = 1.38565  ->  0x000162BA
*   Exact gelu(1.5) = 1.3998.
* ============================================================

start:  addi R1 R0 main         * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
input:  dc 0x18000              * x = 1.5  in Q16.16 (1.5*65536). EDIT ME.
result: ds 1                    * gelu(x) output, Q16.16

* ------------------------------------------------------------
* CONSTANTS  (Q16.16) -- too big for a 16-bit immediate, so dc+lw
* ------------------------------------------------------------
cONE:   dc 0x10000              * +1.0
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
* MAIN  -  load x, kx = 1.707*x (shift-add), sigma = PWL(kx),
*          y = x*sigma, store, halt
*   R9 = x (preserved), R8 = sign flag, R4 = |x|, R5 = shifter
* ============================================================
main:   lw   R9 R0 input        * R9 = x_q  (kept for the final product)

* ---- |x| and sign (srli is a LOGICAL shift - needs x >= 0) ----
        add  R4 R9 R0           * R4 = x
        slti R8 R4 0x0000       * R8 = 1 if x < 0
        beqz R8 gabs            * x >= 0 -> R4 already |x|
        sub  R4 R0 R4           * R4 = -x = |x|

* ---- kax = ax + ax>>1 + ax>>3 + ax>>4 + ax>>6 + ax>>8 ----
gabs:   add  R1 R4 R0           * R1 = ax
        srli R5 R4              * ax>>1
        add  R1 R1 R5           * + ax>>1
        srli R5 R5              * ax>>2
        srli R5 R5              * ax>>3
        add  R1 R1 R5           * + ax>>3
        srli R5 R5              * ax>>4
        add  R1 R1 R5           * + ax>>4
        srli R5 R5              * ax>>5
        srli R5 R5              * ax>>6
        add  R1 R1 R5           * + ax>>6
        srli R5 R5              * ax>>7
        srli R5 R5              * ax>>8
        add  R1 R1 R5           * + ax>>8   => R1 = kax = 1.707*|x|

* ---- kx = sign ? -kax : +kax   (sigmoid input) ----
        beqz R8 gsig
        sub  R1 R0 R1           * kx = -kax
gsig:   addi R7 R0 sigsub       * R7 = address of sigmoid subroutine
        jalr R7                 * R2 = sigma(kx),  R31 = return

* ---- y = x * sigma  (signed Q16.16 product, 3-cycle mult) ----
        dc 0xF9221000           * mult: R2 = R9 * R2
        sw   R2 R0 result       * result = y_q
        halt

* ============================================================
* sigsub  -  R2 = sigmoid0(R1), Q16.16   (same PWL as tanh_sw.s)
*   in : R1 = z_q (signed)   out: R2 = sigma_q
*   uses R3 (sign), R5 (compare temp), R6 (constant temp)
*   no nested calls, so R31 is safe to return through.
* ============================================================
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
        dc 0xF8261000           * mult: R2 = R1 * R6  = z>>5
        lw   R6 R0 cB2732       * R6 = 0.84375
        add  R2 R2 R6           * y = (z>>5) + 0.84375
        beqz R0 sigsign

* ---- segment 3:  1.125 <= z < 2.375  -> y = (z>>3) + 0.625 ----
sigseg3: lw  R6 R0 cX1125       * R6 = 1.125
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if z < 1.125
        bnez R5 sigseg4
        lw   R6 R0 cS8          * R6 = 1/8
        dc 0xF8261000           * mult: R2 = R1 * R6  = z>>3
        lw   R6 R0 cB58         * R6 = 0.625
        add  R2 R2 R6           * y = (z>>3) + 0.625
        beqz R0 sigsign

* ---- segment 4:  0.875 <= z < 1.125  -> y = (z>>3) + 0.6060586 ----
sigseg4: lw  R6 R0 cX0875       * R6 = 0.875
        sub  R5 R1 R6
        slti R5 R5 0x0000       * R5 = 1 if z < 0.875
        bnez R5 sigseg5
        lw   R6 R0 cS8          * R6 = 1/8
        dc 0xF8261000           * mult: R2 = R1 * R6  = z>>3
        lw   R6 R0 cBTAY        * R6 = 0.6060586 (Taylor repair @ z=1)
        add  R2 R2 R6           * y = (z>>3) + 0.6060586
        beqz R0 sigsign

* ---- segment 5:  0.0 <= z < 0.875  -> y = (z>>2) + 0.5 ----
sigseg5: lw  R6 R0 cS4          * R6 = 1/4
        dc 0xF8261000           * mult: R2 = R1 * R6  = z>>2
        lw   R6 R0 cB12         * R6 = 0.5
        add  R2 R2 R6           * y = (z>>2) + 0.5

* ---- if z was negative:  y = 1.0 - y ----
sigsign: beqz R3 sigret         * sign == 0 -> done
        lw   R6 R0 cONE         * R6 = 1.0
        sub  R2 R6 R2           * y = 1.0 - y

sigret: jr   R31                * return to caller
