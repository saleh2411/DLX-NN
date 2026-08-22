/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/administrator.CLS-210-PC/Desktop/saed/simple_DLX/Week7/HOME_VER_before_edit/sigmoid_subenv.v";
static int ng1[] = {1, 0};
static int ng2[] = {3, 0};
static int ng3[] = {4, 0};
static int ng4[] = {6, 0};
static int ng5[] = {8, 0};
static unsigned int ng6[] = {4294901760U, 0U};
static int ng7[] = {16, 0};
static unsigned int ng8[] = {0U, 0U};



static void Cont_68_0(char *t0)
{
    char t7[8];
    char t8[8];
    char t12[8];
    char t13[8];
    char t17[8];
    char t18[8];
    char t22[8];
    char t23[8];
    char t27[8];
    char t28[8];
    char *t1;
    char *t2;
    char *t4;
    char *t6;
    char *t10;
    char *t11;
    char *t15;
    char *t16;
    char *t20;
    char *t21;
    char *t25;
    char *t26;
    char *t29;
    char *t30;
    char *t31;
    char *t32;
    char *t33;
    char *t34;

LAB0:    t1 = (t0 + 4512U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(68, ng0);
    t2 = (t0 + 1592U);
    t4 = *((char **)t2);
    t2 = (t0 + 1592U);
    t6 = *((char **)t2);
    t2 = ((char*)((ng1)));
    memset(t7, 0, 8);
    xsi_vlog_signed_arith_rshift(t7, 32, t6, 32, t2, 32);
    memset(t8, 0, 8);
    xsi_vlog_signed_add(t8, 32, t4, 32, t7, 32);
    t10 = (t0 + 1592U);
    t11 = *((char **)t10);
    t10 = ((char*)((ng2)));
    memset(t12, 0, 8);
    xsi_vlog_signed_arith_rshift(t12, 32, t11, 32, t10, 32);
    memset(t13, 0, 8);
    xsi_vlog_signed_add(t13, 32, t8, 32, t12, 32);
    t15 = (t0 + 1592U);
    t16 = *((char **)t15);
    t15 = ((char*)((ng3)));
    memset(t17, 0, 8);
    xsi_vlog_signed_arith_rshift(t17, 32, t16, 32, t15, 32);
    memset(t18, 0, 8);
    xsi_vlog_signed_add(t18, 32, t13, 32, t17, 32);
    t20 = (t0 + 1592U);
    t21 = *((char **)t20);
    t20 = ((char*)((ng4)));
    memset(t22, 0, 8);
    xsi_vlog_signed_arith_rshift(t22, 32, t21, 32, t20, 32);
    memset(t23, 0, 8);
    xsi_vlog_signed_add(t23, 32, t18, 32, t22, 32);
    t25 = (t0 + 1592U);
    t26 = *((char **)t25);
    t25 = ((char*)((ng5)));
    memset(t27, 0, 8);
    xsi_vlog_signed_arith_rshift(t27, 32, t26, 32, t25, 32);
    memset(t28, 0, 8);
    xsi_vlog_signed_add(t28, 32, t23, 32, t27, 32);
    t29 = (t0 + 6464);
    t30 = (t29 + 56U);
    t31 = *((char **)t30);
    t32 = (t31 + 56U);
    t33 = *((char **)t32);
    memcpy(t33, t28, 8);
    xsi_driver_vfirst_trans(t29, 0, 31);
    t34 = (t0 + 6320);
    *((int *)t34) = 1;

LAB1:    return;
}

static void Cont_74_1(char *t0)
{
    char t4[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;

LAB0:    t1 = (t0 + 4760U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(74, ng0);
    t2 = (t0 + 1592U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng1)));
    memset(t4, 0, 8);
    xsi_vlog_unsigned_arith_lshift(t4, 32, t3, 32, t2, 32);
    t5 = (t0 + 6528);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t4, 8);
    xsi_driver_vfirst_trans(t5, 0, 31);
    t10 = (t0 + 6336);
    *((int *)t10) = 1;

LAB1:    return;
}

static void Cont_89_2(char *t0)
{
    char t4[8];
    char t6[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;

LAB0:    t1 = (t0 + 5008U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(89, ng0);
    t2 = (t0 + 2872U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng1)));
    memset(t4, 0, 8);
    xsi_vlog_unsigned_arith_lshift(t4, 32, t3, 32, t2, 32);
    t5 = ((char*)((ng6)));
    memset(t6, 0, 8);
    xsi_vlog_unsigned_add(t6, 32, t4, 32, t5, 32);
    t7 = (t0 + 6592);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    t10 = (t9 + 56U);
    t11 = *((char **)t10);
    memcpy(t11, t6, 8);
    xsi_driver_vfirst_trans(t7, 0, 31);
    t12 = (t0 + 6352);
    *((int *)t12) = 1;

LAB1:    return;
}

static void NetDecl_94_3(char *t0)
{
    char t3[16];
    char t5[16];
    char t7[16];
    char *t1;
    char *t2;
    char *t4;
    char *t6;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;

LAB0:    t1 = (t0 + 5256U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(94, ng0);
    t2 = (t0 + 1592U);
    t4 = *((char **)t2);
    xsi_vlogtype_sign_extend(t3, 64, t4, 32);
    t2 = (t0 + 2872U);
    t6 = *((char **)t2);
    xsi_vlogtype_sign_extend(t5, 64, t6, 32);
    xsi_vlog_signed_multiply(t7, 64, t3, 64, t5, 64);
    t2 = (t0 + 6656);
    t8 = (t2 + 56U);
    t9 = *((char **)t8);
    t10 = (t9 + 56U);
    t11 = *((char **)t10);
    xsi_vlog_bit_copy(t11, 0, t7, 0, 64);
    xsi_driver_vfirst_trans(t2, 0, 63U);
    t12 = (t0 + 6368);
    *((int *)t12) = 1;

LAB1:    return;
}

static void Cont_95_4(char *t0)
{
    char t4[16];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;

LAB0:    t1 = (t0 + 5504U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(95, ng0);
    t2 = (t0 + 3032U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng7)));
    xsi_vlog_signed_arith_rshift(t4, 64, t3, 64, t2, 32);
    t5 = (t0 + 6720);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    xsi_vlog_bit_copy(t9, 0, t4, 0, 32);
    xsi_driver_vfirst_trans(t5, 0, 31);
    t10 = (t0 + 6384);
    *((int *)t10) = 1;

LAB1:    return;
}

static void implSig1_execute(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    t1 = (t0 + 5752U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = ((char*)((ng8)));
    t3 = (t0 + 6784);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    memcpy(t7, t2, 8);
    xsi_driver_vfirst_trans(t3, 0, 31);

LAB1:    return;
}

static void implSig2_execute(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    t1 = (t0 + 6000U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = ((char*)((ng8)));
    t3 = (t0 + 6848);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    memcpy(t7, t2, 8);
    xsi_driver_vfirst_trans(t3, 0, 31);

LAB1:    return;
}


extern void work_m_00000000003482152913_1673963198_init()
{
	static char *pe[] = {(void *)Cont_68_0,(void *)Cont_74_1,(void *)Cont_89_2,(void *)NetDecl_94_3,(void *)Cont_95_4,(void *)implSig1_execute,(void *)implSig2_execute};
	xsi_register_didat("work_m_00000000003482152913_1673963198", "isim/IO_TB_isim_beh.exe.sim/work/m_00000000003482152913_1673963198.didat");
	xsi_register_executes(pe);
}
