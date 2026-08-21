pc = 0x0                        * address of the program in main memory

* ============================================================
* softmax_sw.s  -  softmax in SOFTWARE on the simple DLX,
*               using the new mult instruction (Q16.16).
*
* Contrast with softmax_hw.s (one softmax instruction + DMA):
* here the same algorithm the hardware runs (shift_exp + PWL
* reciprocal, tables identical to pwl_reciprocal.v) is done by
* the CPU one step at a time:
*
*   pass A:  m = max(x_i)
*   pass B:  f_i = sexp(x_i - m)  stored into outvec,
*            d   = sum of f_i
*   recip :  1/d  by 8-segment PWL:  recip = mult(a_q, d) + b_q
*   pass C:  y_i = mult(f_i, recip)  overwrites outvec
*
* sexp(u) mirrors shift_exp.v for u <= 0 (the only case here):
*   v = 1.5*u ;  e^u ~ (1 + frac(v)/2) >> |int(v)|
* mult does the two real products; everything else is shifts/adds.
*
* FIXED-POINT CONVENTION (Q16.16): real r = integer round(r*65536).
*   mult computes (src1*src2)>>16 = Q16.16 product.  RESA syntax:
*   'mult SRC2 SRC1 imm' with imm = DEST reg * 0x800 (see skill/OPCODES.md).
*
* I/O:  N at 'cN' (max 16 with outvec ds 16), inputs at 'invec',
*       results at 'outvec' (y_i in [0,1], roughly summing to 1).
*
* SANITY CHECK for invec = [1.0, 2.0, 3.0, 4.0]:
*   f = [0x0A00, 0x2000, 0x5000, 0x10000], d = 0x17A00 (1.477)
*   recip = 0xB44E (0.7043, PWL approx of 1/d)
*   y = [0x070B, 0x1689, 0x3858, 0xB44E] = [0.028, 0.088, 0.220, 0.704]
*   (sum ~ 1.04: the PWL reciprocal overshoots, same as the hardware)
* ============================================================

start:  addi R1 R0 maincode     * R1 = address of main
        jr   R1                 * jump to main
        special-nop
        special-nop

* ------------------------------------------------------------
* DATA
* ------------------------------------------------------------
cN:     dc 0x4                  * vector length N (<= 16). EDIT ME.
invec:  dc 0x10000              * x0 = 1.0  in Q16.16. EDIT ME.
        dc 0x20000              * x1 = 2.0
        dc 0x30000              * x2 = 3.0
        dc 0x40000              * x3 = 4.0
        ds 12                   * room up to N = 16

* ------------------------------------------------------------
* CONSTANTS
* ------------------------------------------------------------
cONE:   dc 0x10000              * 1.0 in Q16.16
cMASK:  dc 0xffff               * low-16-bit mask

* PWL reciprocal tables -- SAME values as pwl_reciprocal.v.
* segment s covers 2^s <= int(d) < 2^(s+1)  (seg 0 = d in [1,2))
cAtab:  dc 0xffff85ef           * a_q seg 0  (slope, negative)
        dc 0xffffe17c           * a_q seg 1
        dc 0xfffff85f           * a_q seg 2
        dc 0xfffffe18           * a_q seg 3
        dc 0xffffff86           * a_q seg 4
        dc 0xffffffe1           * a_q seg 5
        dc 0xfffffff8           * a_q seg 6
        dc 0xfffffffe           * a_q seg 7
cBtab:  dc 0x1688c              * b_q seg 0  (intercept)
        dc 0xb446               * b_q seg 1
        dc 0x5a23               * b_q seg 2
        dc 0x2d11               * b_q seg 3
        dc 0x1688               * b_q seg 4
        dc 0xb44                * b_q seg 5
        dc 0x5a2                * b_q seg 6
        dc 0x2d1                * b_q seg 7

* ============================================================
* MAIN
*   R10 = i     R11 = N      R12 = m (max)   R13 = d
*   R14 = recip R7 = sexpsub addr
*   sexpsub clobbers R1..R6, returns in R2
* ============================================================
maincode: lw R11 R0 cN          * R11 = N

* ---- pass A:  m = max(x_i)  (init with x0, scan from i=1) ----
        lw   R12 R0 invec       * m = x0
        addi R10 R0 0x1         * i = 1
maxloop: sub R5 R11 R10         * N - i
        beqz R5 maxdone         * i == N -> done
        addi R6 R0 invec
        add  R6 R6 R10          * &invec[i]  (word addressing: base + i)
        lw   R1 R6 0x0          * R1 = x_i
        sub  R5 R12 R1          * m - x_i
        slti R5 R5 0x0000       * 1 if m < x_i
        beqz R5 maxnext
        addi R12 R1 0x0         * m = x_i
maxnext: addi R10 R10 0x1
        beqz R0 maxloop

* ---- pass B:  f_i = sexp(x_i - m) -> outvec[i],  d = sum f_i ----
maxdone: addi R10 R0 0x0        * i = 0
        add  R13 R0 R0          * d = 0
        addi R7 R0 sexpsub
floop:  sub  R5 R11 R10
        beqz R5 fdone
        addi R6 R0 invec
        add  R6 R6 R10
        lw   R1 R6 0x0          * R1 = x_i
        sub  R1 R1 R12          * u = x_i - m   (<= 0)
        jalr R7                 * R2 = sexp(u)
        addi R6 R0 outvec
        add  R6 R6 R10
        sw   R2 R6 0x0          * outvec[i] = f_i (scratch)
        add  R13 R13 R2         * d += f_i
        addi R10 R10 0x1
        beqz R0 floop

* ---- reciprocal:  recip = mult(a_q[seg], d) + b_q[seg] ----
* seg from int part of d: highest power of two <= int(d)
fdone:  addi R4 R13 0x0         * copy d
        srli R4 R4              * >> 1
        srli R4 R4              * >> 2
        srli R4 R4              * >> 3
        srli R4 R4              * >> 4
        srli R4 R4              * >> 5
        srli R4 R4              * >> 6
        srli R4 R4              * >> 7
        srli R4 R4              * >> 8
        srli R4 R4              * >> 9
        srli R4 R4              * >> 10
        srli R4 R4              * >> 11
        srli R4 R4              * >> 12
        srli R4 R4              * >> 13
        srli R4 R4              * >> 14
        srli R4 R4              * >> 15
        srli R4 R4              * >> 16 -> R4 = int(d)
        addi R3 R0 0x7          * seg = 7
        sgei R5 R4 0x0080       * int(d) >= 128 ?
        bnez R5 segdone
        addi R3 R0 0x6
        sgei R5 R4 0x0040
        bnez R5 segdone
        addi R3 R0 0x5
        sgei R5 R4 0x0020
        bnez R5 segdone
        addi R3 R0 0x4
        sgei R5 R4 0x0010
        bnez R5 segdone
        addi R3 R0 0x3
        sgei R5 R4 0x0008
        bnez R5 segdone
        addi R3 R0 0x2
        sgei R5 R4 0x0004
        bnez R5 segdone
        addi R3 R0 0x1
        sgei R5 R4 0x0002
        bnez R5 segdone
        addi R3 R0 0x0          * seg 0: d in [1,2)
segdone: addi R6 R0 cAtab
        add  R6 R6 R3
        lw   R1 R6 0x0          * R1 = a_q
        mult R13 R1 0x1000      * R2 = (a_q * d) >> 16   <-- mult #1
        addi R6 R0 cBtab
        add  R6 R6 R3
        lw   R1 R6 0x0          * R1 = b_q
        add  R14 R2 R1          * recip = a_q*d + b_q

* ---- pass C:  y_i = mult(f_i, recip) ----
        addi R10 R0 0x0
yloop:  sub  R5 R11 R10
        beqz R5 ydone
        addi R6 R0 outvec
        add  R6 R6 R10
        lw   R1 R6 0x0          * R1 = f_i
        mult R14 R1 0x1000      * y_i = (f_i * recip) >> 16   <-- mult #2
        sw   R2 R6 0x0          * outvec[i] = y_i
        addi R10 R10 0x1
        beqz R0 yloop
ydone:  halt

* ============================================================
* sexpsub  -  R2 = sexp(R1) for R1 <= 0, mirrors shift_exp.v:
*   v = u + (u >>> 1) = 1.5u ;  n = -v ;
*   out = (1.0 + frac(v)/2) >> ceil(n/65536),  0 if shift > 31
*   in : R1 = u (Q16.16, <= 0)
*   out: R2
*   uses R3 (n), R4 (shift count), R5 (frac), R6 (temp)
* ============================================================
sexpsub: sub R3 R0 R1           * w = -u          (w >= 0)
        addi R4 R3 0x1          * w + 1
        srli R4 R4              * t = (w+1)>>1    (= ceil(w/2))
        add  R3 R3 R4           * n = w + t = -1.5u   (n = -v >= 0)
* q = n >> 16  (int part of n)
        addi R4 R3 0x0
        srli R4 R4              * >> 1
        srli R4 R4              * >> 2
        srli R4 R4              * >> 3
        srli R4 R4              * >> 4
        srli R4 R4              * >> 5
        srli R4 R4              * >> 6
        srli R4 R4              * >> 7
        srli R4 R4              * >> 8
        srli R4 R4              * >> 9
        srli R4 R4              * >> 10
        srli R4 R4              * >> 11
        srli R4 R4              * >> 12
        srli R4 R4              * >> 13
        srli R4 R4              * >> 14
        srli R4 R4              * >> 15
        srli R4 R4              * >> 16 -> q
* r = n & 0xFFFF; two's-complement frac of v: frac = 0x10000 - r
        lw   R6 R0 cMASK
        and  R5 R3 R6           * r = n & 0xFFFF
        beqz R5 sxnofr          * r == 0: frac = 0, shift = q
        addi R4 R4 0x1          * shift = q + 1   (ceil)
        lw   R6 R0 cONE
        sub  R5 R6 R5           * frac = 1.0 - r
sxnofr: sgti R6 R4 0x001f       * shift > 31 ?
        beqz R6 sxshift
        add  R2 R0 R0           * underflow: out = 0
        jr   R31
sxshift: srli R5 R5             * frac/2
        lw   R6 R0 cONE
        add  R2 R5 R6           * base = 1.0 + frac/2
sxloop: beqz R4 sxret           * shift base right 'shift' times
        srli R2 R2
        addi R4 R4 -1
        beqz R0 sxloop
sxret:  jr   R31

* ------------------------------------------------------------
* OUTPUT  (after all code so ds can't shadow instructions)
* ------------------------------------------------------------
outvec: ds 16                   * y_i results, Q16.16
