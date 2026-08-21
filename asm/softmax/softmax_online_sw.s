pc = 0x0                        * address of the program in main memory

* ============================================================
* softmax_online_sw.s  -  softmax in SOFTWARE, BIT-EXACT with the
*                      HARDWARE softmax instruction.
*
* Three softmax programs live in this folder:
*
*   softmax_sw.s         two-pass SW  (m = max first, then d = sum f_i)
*                        -> MORE accurate than the HW, does NOT match it
*   softmax_hw.s         one 'softmax' instruction, HW engine + DMA
*   softmax_online_sw.s  (this file) SW replica of the HW datapath
*                        -> bit-identical to softmax_hw.s
*
* WHY softmax_sw.s DOES NOT MATCH THE HARDWARE
* -----------------------------------------
* Both use the same sexp (shift_exp.v) and the same 8-segment PWL
* reciprocal tables.  The only difference is how d is accumulated:
*
*   softmax_sw.s   : two-pass.  m = max(x) is known before any sexp,
*                 so d = sum sexp(x_i - m) is an exact integer sum.
*   hardware    : Algorithm 3 "online" pass 1 (softmax_crtl_fsm.v).
*                 m and d are built in ONE pass; every time the max
*                 grows, the running d is rescaled
*                     d = ((d * sexp(m_old - m_new)) >> 16) + sexp(x - m_new)
*                 and that >>16 TRUNCATES.  Truncation error compounds
*                 once per max update.
*
*   invec = [1.0, 2.0, 3.0, 4.0]:  two-pass d = 0x17A00 (1.4766, exact)
*                                  online   d = 0x170D0 (1.4407, 2.4% low)
*   -> different reciprocal -> different outputs.
*
* THIS FILE reproduces the online recurrence exactly, so its output
* matches softmax_hw.s word for word.  Use it to debug the HW on
* the RESA simulator (which nops the real softmax instruction).
*
* THE ONLINE PASS 1 (mirrors softmax_crtl_fsm.v states P1_A/B/C)
* -------------------------------------------------------------
*   m = -inf (0x80000000) ;  d = 0
*   for each x:
*       m_new   = max(x, m)
*       rescale = sexp(m - m_new)            <- state P1_COMPUTE_A
*       a       = (d * rescale) >> 16        <- state P1_COMPUTE_B
*       b       = sexp(x - m_new)            <- state P1_COMPUTE_B
*       d       = a + b                      <- state P1_COMPUTE_C
*       m       = m_new
*
* ELEMENT 0 IS UNROLLED AWAY.  On the first element d = 0, so
* a = (0 * rescale) >> 16 = 0 no matter what rescale is, and
* m_new = x0 makes b = sexp(0) = 1.0.  Hence after element 0 the
* hardware always holds  m = x0, d = 0x10000.  Starting the loop at
* i = 1 with those values is bit-exact AND avoids having to emulate
* sexp() of the 0x80000000 - x0 wraparound (sexpsub below assumes
* u <= 0, which every later call satisfies since m_new >= m_old).
*
* PASS 2 (mirrors P2_COMPUTE_A/B): recip = pwl(d) computed ONCE,
* then y_i = (sexp(x_i - m) * recip) >> 16.  Like the hardware, f_i
* is recomputed rather than stored.
*
* FIXED-POINT CONVENTION (Q16.16): real r = integer round(r*65536).
*   mult computes (src1*src2)>>16 = bits [47:16] of the 64-bit signed
*   product, same truncation as the RTL.  Per repo convention mult is
*   written as a raw word, never as a mnemonic:
*     word = 0xF8000000 | RS1<<21 | RS2<<16 | RD<<11
*   (RESA's R-type encoder zeroes the opcode, and the I-type mnemonic
*   hides the destination in the immediate -- see RESA_ENV/OPCODES.md.)
*
* I/O:  N at 'cN' (max 16 with outvec ds 16), inputs at 'invec',
*       results at 'outvec'.
*
* SANITY CHECK for invec = [1.0, 2.0, 3.0, 4.0]:
*   pass 1 walk:  i=0  m=0x10000  d=0x10000
*                 i=1  m=0x20000  a=0x05000  b=0x10000  d=0x15000
*                 i=2  m=0x30000  a=0x06900  b=0x10000  d=0x16900
*                 i=3  m=0x40000  a=0x070D0  b=0x10000  d=0x170D0
*   recip = 0xB8B0 (0.7214, seg 0)
*   y = [0x0736, 0x1716, 0x39B7, 0xB8B0]
*     = [0.02817, 0.09018, 0.22545, 0.72144]   (sum ~ 1.065)
*   Compare softmax_sw.s on the same input: [0x070B, 0x1689, 0x3858, 0xB44E]
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
*   R10 = i      R11 = N       R12 = m (running max)   R13 = d
*   R14 = recip  R15 = x_i     R9  = mult destination  R8 = m_new
*   R7  = sexpsub address
*   sexpsub clobbers R1..R6 and R31, returns in R2.
*   R7..R15 are preserved across the call.
* ============================================================
maincode: lw R11 R0 cN          * R11 = N
        addi R7 R0 sexpsub      * R7 = &sexpsub

* ---- pass 1, element 0 unrolled: m = x0, d = 1.0 ----
        lw   R12 R0 invec       * m = x0
        lw   R13 R0 cONE        * d = 1.0   (see header: a=0, b=sexp(0))
        addi R10 R0 0x1         * i = 1

* ---- pass 1, online recurrence for i = 1 .. N-1 ----
ploop:  sub  R5 R11 R10         * N - i
        beqz R5 pdone           * i == N -> pass 1 finished
        addi R6 R0 invec
        add  R6 R6 R10          * &invec[i]  (word addressing: base + i)
        lw   R15 R6 0x0         * R15 = x_i  (survives sexpsub)

*       m_new = max(x_i, m)  ->  R8
        addi R8 R12 0x0         * m_new = m
        sub  R5 R12 R15         * m - x_i
        slti R5 R5 0x0000       * 1 if m < x_i
        beqz R5 pnomax
        addi R8 R15 0x0         * m_new = x_i

*       rescale = sexp(m_old - m_new)      (<= 0, so sexpsub is valid)
pnomax: sub  R1 R12 R8
        jalr R7                 * R2 = rescale

*       a = (d * rescale) >> 16            (mult #1)
        dc 0xF9A24800           * mult: R9 = (R13 * R2) >> 16

*       b = sexp(x_i - m_new)              (<= 0)
        sub  R1 R15 R8
        jalr R7                 * R2 = b

*       d = a + b ;  m = m_new
        add  R13 R9 R2
        addi R12 R8 0x0

        addi R10 R10 0x1
        beqz R0 ploop

* ---- reciprocal:  recip = mult(a_q[seg], d) + b_q[seg] ----
* seg from int part of d: highest power of two <= int(d)
pdone:  addi R4 R13 0x0         * copy d
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
        dc 0xF82D1000           * mult #2: R2 = (R1 * R13) >> 16 = a_q*d
        addi R6 R0 cBtab
        add  R6 R6 R3
        lw   R1 R6 0x0          * R1 = b_q
        add  R14 R2 R1          * recip = a_q*d + b_q

* ---- pass 2:  y_i = (sexp(x_i - m) * recip) >> 16 ----
* f_i is recomputed, not stored -- same as the hardware.
        addi R10 R0 0x0         * i = 0
yloop:  sub  R5 R11 R10
        beqz R5 ydone
        addi R6 R0 invec
        add  R6 R6 R10
        lw   R15 R6 0x0         * R15 = x_i
        sub  R1 R15 R12         * u = x_i - m   (<= 0)
        jalr R7                 * R2 = f_i
        dc 0xF84E4800           * mult #3: R9 = (R2 * R14) >> 16 = f_i*recip
        addi R6 R0 outvec
        add  R6 R6 R10          * R6 was clobbered by sexpsub -- rebuild
        sw   R9 R6 0x0          * outvec[i] = y_i
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
*   IDENTICAL to the routine in softmax_sw.s -- verified bit-exact
*   against shift_exp.v over the whole negative input range.
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
