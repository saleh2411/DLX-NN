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
static const char *ng0 = "C:/Users/administrator.CLS-210-PC/Desktop/saed/simple_DLX/Week7/HOME_VER_before_edit/pwl_reciprocal.v";
static unsigned int ng1[] = {0U, 0U};
static unsigned int ng2[] = {7U, 0U};
static unsigned int ng3[] = {128U, 127U};
static unsigned int ng4[] = {64U, 63U};
static unsigned int ng5[] = {6U, 0U};
static unsigned int ng6[] = {32U, 31U};
static unsigned int ng7[] = {5U, 0U};
static unsigned int ng8[] = {16U, 15U};
static unsigned int ng9[] = {4U, 0U};
static unsigned int ng10[] = {8U, 7U};
static unsigned int ng11[] = {3U, 0U};
static unsigned int ng12[] = {4U, 3U};
static unsigned int ng13[] = {2U, 0U};
static unsigned int ng14[] = {2U, 1U};
static unsigned int ng15[] = {1U, 0U};
static unsigned int ng16[] = {4294936047U, 0U};
static unsigned int ng17[] = {92300U, 0U};
static unsigned int ng18[] = {4294959484U, 0U};
static unsigned int ng19[] = {46150U, 0U};
static unsigned int ng20[] = {4294965343U, 0U};
static unsigned int ng21[] = {23075U, 0U};
static unsigned int ng22[] = {4294966808U, 0U};
static unsigned int ng23[] = {11537U, 0U};
static unsigned int ng24[] = {4294967174U, 0U};
static unsigned int ng25[] = {5768U, 0U};
static unsigned int ng26[] = {4294967265U, 0U};
static unsigned int ng27[] = {2884U, 0U};
static unsigned int ng28[] = {4294967288U, 0U};
static unsigned int ng29[] = {1442U, 0U};
static unsigned int ng30[] = {4294967294U, 0U};
static unsigned int ng31[] = {721U, 0U};



static void Cont_7_0(char *t0)
{
    char t3[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;

LAB0:    t1 = (t0 + 3328U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(7, ng0);
    t2 = (t0 + 1048U);
    t4 = *((char **)t2);
    memset(t3, 0, 8);
    t2 = (t3 + 4);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 16);
    *((unsigned int *)t3) = t7;
    t8 = *((unsigned int *)t5);
    t9 = (t8 >> 16);
    *((unsigned int *)t2) = t9;
    t10 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t10 & 65535U);
    t11 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t11 & 65535U);
    t12 = (t0 + 5048);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memset(t16, 0, 8);
    t17 = 65535U;
    t18 = t17;
    t19 = (t3 + 4);
    t20 = *((unsigned int *)t3);
    t17 = (t17 & t20);
    t21 = *((unsigned int *)t19);
    t18 = (t18 & t21);
    t22 = (t16 + 4);
    t23 = *((unsigned int *)t16);
    *((unsigned int *)t16) = (t23 | t17);
    t24 = *((unsigned int *)t22);
    *((unsigned int *)t22) = (t24 | t18);
    xsi_driver_vfirst_trans(t12, 0, 15);
    t25 = (t0 + 4888);
    *((int *)t25) = 1;

LAB1:    return;
}

static void Always_10_1(char *t0)
{
    char t4[8];
    char t15[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t16;
    char *t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    char *t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    char *t37;
    char *t38;
    int t39;

LAB0:    t1 = (t0 + 3576U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(10, ng0);
    t2 = (t0 + 4904);
    *((int *)t2) = 1;
    t3 = (t0 + 3608);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(10, ng0);

LAB5:    xsi_set_current_line(11, ng0);
    t5 = (t0 + 1368U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t5 = (t4 + 4);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t6);
    t9 = (t8 >> 8);
    *((unsigned int *)t4) = t9;
    t10 = *((unsigned int *)t7);
    t11 = (t10 >> 8);
    *((unsigned int *)t5) = t11;
    t12 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t12 & 255U);
    t13 = *((unsigned int *)t5);
    *((unsigned int *)t5) = (t13 & 255U);
    t14 = ((char*)((ng1)));
    memset(t15, 0, 8);
    t16 = (t4 + 4);
    t17 = (t14 + 4);
    t18 = *((unsigned int *)t4);
    t19 = *((unsigned int *)t14);
    t20 = (t18 ^ t19);
    t21 = *((unsigned int *)t16);
    t22 = *((unsigned int *)t17);
    t23 = (t21 ^ t22);
    t24 = (t20 | t23);
    t25 = *((unsigned int *)t16);
    t26 = *((unsigned int *)t17);
    t27 = (t25 | t26);
    t28 = (~(t27));
    t29 = (t24 & t28);
    if (t29 != 0)
        goto LAB7;

LAB6:    if (t27 != 0)
        goto LAB8;

LAB9:    t31 = (t15 + 4);
    t32 = *((unsigned int *)t31);
    t33 = (~(t32));
    t34 = *((unsigned int *)t15);
    t35 = (t34 & t33);
    t36 = (t35 != 0);
    if (t36 > 0)
        goto LAB10;

LAB11:    xsi_set_current_line(13, ng0);
    t2 = (t0 + 1368U);
    t3 = *((char **)t2);
    memset(t4, 0, 8);
    t2 = (t4 + 4);
    t5 = (t3 + 4);
    t8 = *((unsigned int *)t3);
    t9 = (t8 >> 0);
    *((unsigned int *)t4) = t9;
    t10 = *((unsigned int *)t5);
    t11 = (t10 >> 0);
    *((unsigned int *)t2) = t11;
    t12 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t12 & 255U);
    t13 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t13 & 255U);

LAB13:    t6 = ((char*)((ng3)));
    t39 = xsi_vlog_unsigned_case_zcompare(t4, 8, t6, 8);
    if (t39 == 1)
        goto LAB14;

LAB15:    t2 = ((char*)((ng4)));
    t39 = xsi_vlog_unsigned_case_zcompare(t4, 8, t2, 8);
    if (t39 == 1)
        goto LAB16;

LAB17:    t2 = ((char*)((ng6)));
    t39 = xsi_vlog_unsigned_case_zcompare(t4, 8, t2, 8);
    if (t39 == 1)
        goto LAB18;

LAB19:    t2 = ((char*)((ng8)));
    t39 = xsi_vlog_unsigned_case_zcompare(t4, 8, t2, 8);
    if (t39 == 1)
        goto LAB20;

LAB21:    t2 = ((char*)((ng10)));
    t39 = xsi_vlog_unsigned_case_zcompare(t4, 8, t2, 8);
    if (t39 == 1)
        goto LAB22;

LAB23:    t2 = ((char*)((ng12)));
    t39 = xsi_vlog_unsigned_case_zcompare(t4, 8, t2, 8);
    if (t39 == 1)
        goto LAB24;

LAB25:    t2 = ((char*)((ng14)));
    t39 = xsi_vlog_unsigned_case_zcompare(t4, 8, t2, 8);
    if (t39 == 1)
        goto LAB26;

LAB27:
LAB29:
LAB28:    xsi_set_current_line(21, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 2088);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 3);

LAB30:
LAB12:    goto LAB2;

LAB7:    *((unsigned int *)t15) = 1;
    goto LAB9;

LAB8:    t30 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t30) = 1;
    goto LAB9;

LAB10:    xsi_set_current_line(12, ng0);
    t37 = ((char*)((ng2)));
    t38 = (t0 + 2088);
    xsi_vlogvar_assign_value(t38, t37, 0, 0, 3);
    goto LAB12;

LAB14:    xsi_set_current_line(14, ng0);
    t7 = ((char*)((ng2)));
    t14 = (t0 + 2088);
    xsi_vlogvar_assign_value(t14, t7, 0, 0, 3);
    goto LAB30;

LAB16:    xsi_set_current_line(15, ng0);
    t3 = ((char*)((ng5)));
    t5 = (t0 + 2088);
    xsi_vlogvar_assign_value(t5, t3, 0, 0, 3);
    goto LAB30;

LAB18:    xsi_set_current_line(16, ng0);
    t3 = ((char*)((ng7)));
    t5 = (t0 + 2088);
    xsi_vlogvar_assign_value(t5, t3, 0, 0, 3);
    goto LAB30;

LAB20:    xsi_set_current_line(17, ng0);
    t3 = ((char*)((ng9)));
    t5 = (t0 + 2088);
    xsi_vlogvar_assign_value(t5, t3, 0, 0, 3);
    goto LAB30;

LAB22:    xsi_set_current_line(18, ng0);
    t3 = ((char*)((ng11)));
    t5 = (t0 + 2088);
    xsi_vlogvar_assign_value(t5, t3, 0, 0, 3);
    goto LAB30;

LAB24:    xsi_set_current_line(19, ng0);
    t3 = ((char*)((ng13)));
    t5 = (t0 + 2088);
    xsi_vlogvar_assign_value(t5, t3, 0, 0, 3);
    goto LAB30;

LAB26:    xsi_set_current_line(20, ng0);
    t3 = ((char*)((ng15)));
    t5 = (t0 + 2088);
    xsi_vlogvar_assign_value(t5, t3, 0, 0, 3);
    goto LAB30;

}

static void Always_28_2(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    int t8;
    char *t9;
    char *t10;

LAB0:    t1 = (t0 + 3824U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(28, ng0);
    t2 = (t0 + 4920);
    *((int *)t2) = 1;
    t3 = (t0 + 3856);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(28, ng0);

LAB5:    xsi_set_current_line(29, ng0);
    t4 = (t0 + 2088);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);

LAB6:    t7 = ((char*)((ng1)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 3, t7, 3);
    if (t8 == 1)
        goto LAB7;

LAB8:    t2 = ((char*)((ng15)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 3, t2, 3);
    if (t8 == 1)
        goto LAB9;

LAB10:    t2 = ((char*)((ng13)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 3, t2, 3);
    if (t8 == 1)
        goto LAB11;

LAB12:    t2 = ((char*)((ng11)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 3, t2, 3);
    if (t8 == 1)
        goto LAB13;

LAB14:    t2 = ((char*)((ng9)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 3, t2, 3);
    if (t8 == 1)
        goto LAB15;

LAB16:    t2 = ((char*)((ng7)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 3, t2, 3);
    if (t8 == 1)
        goto LAB17;

LAB18:    t2 = ((char*)((ng5)));
    t8 = xsi_vlog_unsigned_case_compare(t6, 3, t2, 3);
    if (t8 == 1)
        goto LAB19;

LAB20:
LAB22:
LAB21:    xsi_set_current_line(37, ng0);

LAB31:    xsi_set_current_line(37, ng0);
    t2 = ((char*)((ng30)));
    t3 = (t0 + 2248);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    xsi_set_current_line(37, ng0);
    t2 = ((char*)((ng31)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);

LAB23:    goto LAB2;

LAB7:    xsi_set_current_line(30, ng0);

LAB24:    xsi_set_current_line(30, ng0);
    t9 = ((char*)((ng16)));
    t10 = (t0 + 2248);
    xsi_vlogvar_assign_value(t10, t9, 0, 0, 32);
    xsi_set_current_line(30, ng0);
    t2 = ((char*)((ng17)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    goto LAB23;

LAB9:    xsi_set_current_line(31, ng0);

LAB25:    xsi_set_current_line(31, ng0);
    t3 = ((char*)((ng18)));
    t4 = (t0 + 2248);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    xsi_set_current_line(31, ng0);
    t2 = ((char*)((ng19)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    goto LAB23;

LAB11:    xsi_set_current_line(32, ng0);

LAB26:    xsi_set_current_line(32, ng0);
    t3 = ((char*)((ng20)));
    t4 = (t0 + 2248);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    xsi_set_current_line(32, ng0);
    t2 = ((char*)((ng21)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    goto LAB23;

LAB13:    xsi_set_current_line(33, ng0);

LAB27:    xsi_set_current_line(33, ng0);
    t3 = ((char*)((ng22)));
    t4 = (t0 + 2248);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    xsi_set_current_line(33, ng0);
    t2 = ((char*)((ng23)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    goto LAB23;

LAB15:    xsi_set_current_line(34, ng0);

LAB28:    xsi_set_current_line(34, ng0);
    t3 = ((char*)((ng24)));
    t4 = (t0 + 2248);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    xsi_set_current_line(34, ng0);
    t2 = ((char*)((ng25)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    goto LAB23;

LAB17:    xsi_set_current_line(35, ng0);

LAB29:    xsi_set_current_line(35, ng0);
    t3 = ((char*)((ng26)));
    t4 = (t0 + 2248);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    xsi_set_current_line(35, ng0);
    t2 = ((char*)((ng27)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    goto LAB23;

LAB19:    xsi_set_current_line(36, ng0);

LAB30:    xsi_set_current_line(36, ng0);
    t3 = ((char*)((ng28)));
    t4 = (t0 + 2248);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    xsi_set_current_line(36, ng0);
    t2 = ((char*)((ng29)));
    t3 = (t0 + 2408);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    goto LAB23;

}

static void Cont_42_3(char *t0)
{
    char t3[16];
    char t6[16];
    char t9[16];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    char *t7;
    char *t8;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;

LAB0:    t1 = (t0 + 4072U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(42, ng0);
    t2 = (t0 + 2248);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    xsi_vlogtype_sign_extend(t3, 64, t5, 32);
    t7 = (t0 + 1048U);
    t8 = *((char **)t7);
    xsi_vlogtype_sign_extend(t6, 64, t8, 32);
    xsi_vlog_signed_multiply(t9, 64, t3, 64, t6, 64);
    t7 = (t0 + 5112);
    t10 = (t7 + 56U);
    t11 = *((char **)t10);
    t12 = (t11 + 56U);
    t13 = *((char **)t12);
    xsi_vlog_bit_copy(t13, 0, t9, 0, 64);
    xsi_driver_vfirst_trans(t7, 0, 63);
    t14 = (t0 + 4936);
    *((int *)t14) = 1;

LAB1:    return;
}

static void Cont_45_4(char *t0)
{
    char t3[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    char *t10;
    char *t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;

LAB0:    t1 = (t0 + 4320U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(45, ng0);
    t2 = (t0 + 1528U);
    t4 = *((char **)t2);
    memset(t3, 0, 8);
    t2 = (t3 + 4);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (t6 >> 16);
    *((unsigned int *)t3) = t7;
    t8 = *((unsigned int *)t5);
    t9 = (t8 >> 16);
    *((unsigned int *)t2) = t9;
    t10 = (t4 + 8);
    t11 = (t4 + 12);
    t12 = *((unsigned int *)t10);
    t13 = (t12 << 16);
    t14 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t14 | t13);
    t15 = *((unsigned int *)t11);
    t16 = (t15 << 16);
    t17 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t17 | t16);
    t18 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t18 & 4294967295U);
    t19 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t19 & 4294967295U);
    t20 = (t0 + 5176);
    t21 = (t20 + 56U);
    t22 = *((char **)t21);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    memcpy(t24, t3, 8);
    xsi_driver_vfirst_trans(t20, 0, 31);
    t25 = (t0 + 4952);
    *((int *)t25) = 1;

LAB1:    return;
}

static void Cont_47_5(char *t0)
{
    char t6[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;

LAB0:    t1 = (t0 + 4568U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(47, ng0);
    t2 = (t0 + 1688U);
    t3 = *((char **)t2);
    t2 = (t0 + 2408);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    memset(t6, 0, 8);
    xsi_vlog_signed_add(t6, 32, t3, 32, t5, 32);
    t7 = (t0 + 5240);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    t10 = (t9 + 56U);
    t11 = *((char **)t10);
    memcpy(t11, t6, 8);
    xsi_driver_vfirst_trans(t7, 0, 31);
    t12 = (t0 + 4968);
    *((int *)t12) = 1;

LAB1:    return;
}


extern void work_m_00000000002742667906_0493482117_init()
{
	static char *pe[] = {(void *)Cont_7_0,(void *)Always_10_1,(void *)Always_28_2,(void *)Cont_42_3,(void *)Cont_45_4,(void *)Cont_47_5};
	xsi_register_didat("work_m_00000000002742667906_0493482117", "isim/data_path_isim_beh.exe.sim/work/m_00000000002742667906_0493482117.didat");
	xsi_register_executes(pe);
}
