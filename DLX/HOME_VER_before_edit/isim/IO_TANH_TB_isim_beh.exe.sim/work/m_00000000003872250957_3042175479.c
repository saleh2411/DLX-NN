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
static const char *ng0 = "C:/Users/administrator.CLS-210-PC/Desktop/saed/saleh/Week7/HOME_VER_before_edit/softmax_dma.v";
static unsigned int ng1[] = {0U, 0U};
static unsigned int ng2[] = {1U, 0U};
static unsigned int ng3[] = {2U, 0U};
static unsigned int ng4[] = {3U, 0U};
static unsigned int ng5[] = {4U, 0U};
static unsigned int ng6[] = {6U, 0U};
static unsigned int ng7[] = {5U, 0U};
static unsigned int ng8[] = {7U, 0U};



static void NetDecl_72_0(char *t0)
{
    char t5[8];
    char t11[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;

LAB0:    t1 = (t0 + 7776U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(72, ng0);
    t2 = (t0 + 6696);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t6 = ((char*)((ng1)));
    t7 = (t0 + 6056);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    t10 = ((char*)((ng1)));
    xsi_vlogtype_concat(t5, 32, 32, 3U, t10, 19, t9, 11, t6, 2);
    memset(t11, 0, 8);
    xsi_vlog_unsigned_add(t11, 32, t4, 32, t5, 32);
    t12 = (t0 + 8704);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memcpy(t16, t11, 8);
    xsi_driver_vfirst_trans(t12, 0, 31U);
    t17 = (t0 + 8592);
    *((int *)t17) = 1;

LAB1:    return;
}

static void NetDecl_73_1(char *t0)
{
    char t5[8];
    char t11[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;

LAB0:    t1 = (t0 + 8024U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(73, ng0);
    t2 = (t0 + 6856);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t6 = ((char*)((ng1)));
    t7 = (t0 + 6056);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    t10 = ((char*)((ng1)));
    xsi_vlogtype_concat(t5, 32, 32, 3U, t10, 19, t9, 11, t6, 2);
    memset(t11, 0, 8);
    xsi_vlog_unsigned_add(t11, 32, t4, 32, t5, 32);
    t12 = (t0 + 8768);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memcpy(t16, t11, 8);
    xsi_driver_vfirst_trans(t12, 0, 31U);
    t17 = (t0 + 8608);
    *((int *)t17) = 1;

LAB1:    return;
}

static void Always_75_2(char *t0)
{
    char t16[8];
    char t23[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    int t13;
    char *t14;
    char *t15;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    unsigned int t24;
    unsigned int t25;
    char *t26;
    char *t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    char *t33;
    char *t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    char *t40;
    char *t41;

LAB0:    t1 = (t0 + 8272U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(75, ng0);
    t2 = (t0 + 8624);
    *((int *)t2) = 1;
    t3 = (t0 + 8304);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(75, ng0);

LAB5:    xsi_set_current_line(76, ng0);
    t4 = (t0 + 2296U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(92, ng0);

LAB10:    xsi_set_current_line(94, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 4936);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(95, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5096);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(96, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5416);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(97, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5576);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(98, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5736);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(100, ng0);
    t2 = (t0 + 5896);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);

LAB11:    t5 = ((char*)((ng1)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t5, 3);
    if (t13 == 1)
        goto LAB12;

LAB13:    t2 = ((char*)((ng2)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t13 == 1)
        goto LAB14;

LAB15:    t2 = ((char*)((ng3)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t13 == 1)
        goto LAB16;

LAB17:    t2 = ((char*)((ng4)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t13 == 1)
        goto LAB18;

LAB19:    t2 = ((char*)((ng5)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t13 == 1)
        goto LAB20;

LAB21:    t2 = ((char*)((ng7)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t13 == 1)
        goto LAB22;

LAB23:    t2 = ((char*)((ng6)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t13 == 1)
        goto LAB24;

LAB25:    t2 = ((char*)((ng8)));
    t13 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t13 == 1)
        goto LAB26;

LAB27:
LAB29:
LAB28:    xsi_set_current_line(195, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);

LAB30:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(76, ng0);

LAB9:    xsi_set_current_line(77, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 3, 0LL);
    xsi_set_current_line(78, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6056);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 11, 0LL);
    xsi_set_current_line(79, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6216);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    xsi_set_current_line(80, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6376);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    xsi_set_current_line(81, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6696);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    xsi_set_current_line(82, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6856);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    xsi_set_current_line(83, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6536);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(84, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 4616);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    xsi_set_current_line(85, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 4776);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    xsi_set_current_line(86, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 4936);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(87, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5096);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(88, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5256);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    xsi_set_current_line(89, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5416);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(90, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5576);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(91, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5736);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB8;

LAB12:    xsi_set_current_line(103, ng0);

LAB31:    xsi_set_current_line(104, ng0);
    t11 = (t0 + 2456U);
    t12 = *((char **)t11);
    t11 = (t12 + 4);
    t6 = *((unsigned int *)t11);
    t7 = (~(t6));
    t8 = *((unsigned int *)t12);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB32;

LAB33:
LAB34:    goto LAB30;

LAB14:    xsi_set_current_line(115, ng0);

LAB36:    xsi_set_current_line(116, ng0);
    t3 = (t0 + 3416U);
    t5 = *((char **)t3);
    t3 = (t5 + 4);
    t6 = *((unsigned int *)t3);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB37;

LAB38:
LAB39:    goto LAB30;

LAB16:    xsi_set_current_line(123, ng0);

LAB40:    xsi_set_current_line(124, ng0);
    t3 = ((char*)((ng2)));
    t5 = (t0 + 4936);
    xsi_vlogvar_wait_assign_value(t5, t3, 0, 0, 1, 0LL);
    xsi_set_current_line(125, ng0);
    t2 = (t0 + 4056U);
    t3 = *((char **)t2);
    t2 = (t0 + 4616);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 32, 0LL);
    xsi_set_current_line(126, ng0);
    t2 = (t0 + 6536);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    memset(t16, 0, 8);
    t11 = (t5 + 4);
    t6 = *((unsigned int *)t11);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB44;

LAB42:    if (*((unsigned int *)t11) == 0)
        goto LAB41;

LAB43:    t12 = (t16 + 4);
    *((unsigned int *)t16) = 1;
    *((unsigned int *)t12) = 1;

LAB44:    t14 = (t16 + 4);
    t17 = *((unsigned int *)t14);
    t18 = (~(t17));
    t19 = *((unsigned int *)t16);
    t20 = (t19 & t18);
    t21 = (t20 != 0);
    if (t21 > 0)
        goto LAB45;

LAB46:    xsi_set_current_line(128, ng0);
    t2 = (t0 + 3256U);
    t3 = *((char **)t2);
    memset(t16, 0, 8);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB52;

LAB50:    if (*((unsigned int *)t2) == 0)
        goto LAB49;

LAB51:    t5 = (t16 + 4);
    *((unsigned int *)t16) = 1;
    *((unsigned int *)t5) = 1;

LAB52:    t11 = (t16 + 4);
    t17 = *((unsigned int *)t11);
    t18 = (~(t17));
    t19 = *((unsigned int *)t16);
    t20 = (t19 & t18);
    t21 = (t20 != 0);
    if (t21 > 0)
        goto LAB53;

LAB54:
LAB55:
LAB47:    goto LAB30;

LAB18:    xsi_set_current_line(138, ng0);

LAB57:    xsi_set_current_line(139, ng0);
    t3 = ((char*)((ng2)));
    t5 = (t0 + 5416);
    xsi_vlogvar_wait_assign_value(t5, t3, 0, 0, 1, 0LL);
    xsi_set_current_line(140, ng0);
    t2 = (t0 + 6216);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t11 = (t0 + 5256);
    xsi_vlogvar_wait_assign_value(t11, t5, 0, 0, 32, 0LL);
    xsi_set_current_line(141, ng0);
    t2 = (t0 + 3416U);
    t3 = *((char **)t2);
    memset(t16, 0, 8);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB61;

LAB59:    if (*((unsigned int *)t2) == 0)
        goto LAB58;

LAB60:    t5 = (t16 + 4);
    *((unsigned int *)t16) = 1;
    *((unsigned int *)t5) = 1;

LAB61:    t11 = (t16 + 4);
    t17 = *((unsigned int *)t11);
    t18 = (~(t17));
    t19 = *((unsigned int *)t16);
    t20 = (t19 & t18);
    t21 = (t20 != 0);
    if (t21 > 0)
        goto LAB62;

LAB63:
LAB64:    goto LAB30;

LAB20:    xsi_set_current_line(150, ng0);

LAB79:    xsi_set_current_line(151, ng0);
    t3 = (t0 + 3736U);
    t5 = *((char **)t3);
    t3 = (t5 + 4);
    t6 = *((unsigned int *)t3);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB80;

LAB81:
LAB82:    goto LAB30;

LAB22:    xsi_set_current_line(160, ng0);

LAB84:    xsi_set_current_line(161, ng0);
    t3 = ((char*)((ng2)));
    t5 = (t0 + 5096);
    xsi_vlogvar_wait_assign_value(t5, t3, 0, 0, 1, 0LL);
    xsi_set_current_line(162, ng0);
    t2 = (t0 + 4216U);
    t3 = *((char **)t2);
    t2 = (t0 + 4616);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 32, 0LL);
    xsi_set_current_line(163, ng0);
    t2 = (t0 + 6376);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t11 = (t0 + 4776);
    xsi_vlogvar_wait_assign_value(t11, t5, 0, 0, 32, 0LL);
    xsi_set_current_line(164, ng0);
    t2 = (t0 + 6536);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    memset(t16, 0, 8);
    t11 = (t5 + 4);
    t6 = *((unsigned int *)t11);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB88;

LAB86:    if (*((unsigned int *)t11) == 0)
        goto LAB85;

LAB87:    t12 = (t16 + 4);
    *((unsigned int *)t16) = 1;
    *((unsigned int *)t12) = 1;

LAB88:    t14 = (t16 + 4);
    t17 = *((unsigned int *)t14);
    t18 = (~(t17));
    t19 = *((unsigned int *)t16);
    t20 = (t19 & t18);
    t21 = (t20 != 0);
    if (t21 > 0)
        goto LAB89;

LAB90:    xsi_set_current_line(166, ng0);
    t2 = (t0 + 3256U);
    t3 = *((char **)t2);
    memset(t16, 0, 8);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB96;

LAB94:    if (*((unsigned int *)t2) == 0)
        goto LAB93;

LAB95:    t5 = (t16 + 4);
    *((unsigned int *)t16) = 1;
    *((unsigned int *)t5) = 1;

LAB96:    t11 = (t16 + 4);
    t17 = *((unsigned int *)t11);
    t18 = (~(t17));
    t19 = *((unsigned int *)t16);
    t20 = (t19 & t18);
    t21 = (t20 != 0);
    if (t21 > 0)
        goto LAB97;

LAB98:
LAB99:
LAB91:    goto LAB30;

LAB24:    xsi_set_current_line(175, ng0);

LAB101:    xsi_set_current_line(176, ng0);
    t3 = (t0 + 6056);
    t5 = (t3 + 56U);
    t11 = *((char **)t5);
    t12 = (t0 + 2936U);
    t14 = *((char **)t12);
    t12 = ((char*)((ng2)));
    memset(t16, 0, 8);
    xsi_vlog_unsigned_minus(t16, 11, t14, 11, t12, 11);
    memset(t23, 0, 8);
    t15 = (t11 + 4);
    t22 = (t16 + 4);
    t6 = *((unsigned int *)t11);
    t7 = *((unsigned int *)t16);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t15);
    t10 = *((unsigned int *)t22);
    t17 = (t9 ^ t10);
    t18 = (t8 | t17);
    t19 = *((unsigned int *)t15);
    t20 = *((unsigned int *)t22);
    t21 = (t19 | t20);
    t24 = (~(t21));
    t25 = (t18 & t24);
    if (t25 != 0)
        goto LAB105;

LAB102:    if (t21 != 0)
        goto LAB104;

LAB103:    *((unsigned int *)t23) = 1;

LAB105:    t27 = (t23 + 4);
    t28 = *((unsigned int *)t27);
    t29 = (~(t28));
    t30 = *((unsigned int *)t23);
    t31 = (t30 & t29);
    t32 = (t31 != 0);
    if (t32 > 0)
        goto LAB106;

LAB107:    xsi_set_current_line(183, ng0);

LAB115:    xsi_set_current_line(184, ng0);
    t2 = (t0 + 6056);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t11 = ((char*)((ng2)));
    memset(t16, 0, 8);
    xsi_vlog_unsigned_add(t16, 11, t5, 11, t11, 11);
    t12 = (t0 + 6056);
    xsi_vlogvar_wait_assign_value(t12, t16, 0, 0, 11, 0LL);
    xsi_set_current_line(185, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);

LAB108:    goto LAB30;

LAB26:    xsi_set_current_line(190, ng0);

LAB116:    xsi_set_current_line(191, ng0);
    t3 = ((char*)((ng2)));
    t5 = (t0 + 5736);
    xsi_vlogvar_wait_assign_value(t5, t3, 0, 0, 1, 0LL);
    xsi_set_current_line(192, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);
    goto LAB30;

LAB32:    xsi_set_current_line(104, ng0);

LAB35:    xsi_set_current_line(105, ng0);
    t14 = ((char*)((ng1)));
    t15 = (t0 + 6056);
    xsi_vlogvar_wait_assign_value(t15, t14, 0, 0, 11, 0LL);
    xsi_set_current_line(106, ng0);
    t2 = (t0 + 2616U);
    t3 = *((char **)t2);
    t2 = (t0 + 6696);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 32, 0LL);
    xsi_set_current_line(107, ng0);
    t2 = (t0 + 2776U);
    t3 = *((char **)t2);
    t2 = (t0 + 6856);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 32, 0LL);
    xsi_set_current_line(108, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6536);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(109, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);
    goto LAB34;

LAB37:    xsi_set_current_line(117, ng0);
    t11 = ((char*)((ng3)));
    t12 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 3, 0LL);
    goto LAB39;

LAB41:    *((unsigned int *)t16) = 1;
    goto LAB44;

LAB45:    xsi_set_current_line(126, ng0);

LAB48:    xsi_set_current_line(127, ng0);
    t15 = ((char*)((ng2)));
    t22 = (t0 + 6536);
    xsi_vlogvar_wait_assign_value(t22, t15, 0, 0, 1, 0LL);
    goto LAB47;

LAB49:    *((unsigned int *)t16) = 1;
    goto LAB52;

LAB53:    xsi_set_current_line(128, ng0);

LAB56:    xsi_set_current_line(129, ng0);
    t12 = (t0 + 3096U);
    t14 = *((char **)t12);
    t12 = (t0 + 6216);
    xsi_vlogvar_wait_assign_value(t12, t14, 0, 0, 32, 0LL);
    xsi_set_current_line(130, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6536);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(131, ng0);
    t2 = ((char*)((ng4)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);
    goto LAB55;

LAB58:    *((unsigned int *)t16) = 1;
    goto LAB61;

LAB62:    xsi_set_current_line(141, ng0);

LAB65:    xsi_set_current_line(142, ng0);
    t12 = ((char*)((ng1)));
    t14 = (t0 + 5416);
    xsi_vlogvar_wait_assign_value(t14, t12, 0, 0, 1, 0LL);
    xsi_set_current_line(143, ng0);
    t2 = (t0 + 3896U);
    t3 = *((char **)t2);
    memset(t23, 0, 8);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB66;

LAB67:    if (*((unsigned int *)t2) != 0)
        goto LAB68;

LAB69:    t11 = (t23 + 4);
    t17 = *((unsigned int *)t23);
    t18 = *((unsigned int *)t11);
    t19 = (t17 || t18);
    if (t19 > 0)
        goto LAB70;

LAB71:    t20 = *((unsigned int *)t23);
    t21 = (~(t20));
    t24 = *((unsigned int *)t11);
    t25 = (t21 || t24);
    if (t25 > 0)
        goto LAB72;

LAB73:    if (*((unsigned int *)t11) > 0)
        goto LAB74;

LAB75:    if (*((unsigned int *)t23) > 0)
        goto LAB76;

LAB77:    memcpy(t16, t14, 8);

LAB78:    t15 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t15, t16, 0, 0, 3, 0LL);
    goto LAB64;

LAB66:    *((unsigned int *)t23) = 1;
    goto LAB69;

LAB68:    t5 = (t23 + 4);
    *((unsigned int *)t23) = 1;
    *((unsigned int *)t5) = 1;
    goto LAB69;

LAB70:    t12 = ((char*)((ng5)));
    goto LAB71;

LAB72:    t14 = ((char*)((ng6)));
    goto LAB73;

LAB74:    xsi_vlog_unsigned_bit_combine(t16, 3, t12, 3, t14, 3);
    goto LAB78;

LAB76:    memcpy(t16, t12, 8);
    goto LAB78;

LAB80:    xsi_set_current_line(151, ng0);

LAB83:    xsi_set_current_line(152, ng0);
    t11 = (t0 + 3576U);
    t12 = *((char **)t11);
    t11 = (t0 + 6376);
    xsi_vlogvar_wait_assign_value(t11, t12, 0, 0, 32, 0LL);
    xsi_set_current_line(153, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 5576);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(154, ng0);
    t2 = ((char*)((ng7)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);
    goto LAB82;

LAB85:    *((unsigned int *)t16) = 1;
    goto LAB88;

LAB89:    xsi_set_current_line(164, ng0);

LAB92:    xsi_set_current_line(165, ng0);
    t15 = ((char*)((ng2)));
    t22 = (t0 + 6536);
    xsi_vlogvar_wait_assign_value(t22, t15, 0, 0, 1, 0LL);
    goto LAB91;

LAB93:    *((unsigned int *)t16) = 1;
    goto LAB96;

LAB97:    xsi_set_current_line(166, ng0);

LAB100:    xsi_set_current_line(167, ng0);
    t12 = ((char*)((ng1)));
    t14 = (t0 + 6536);
    xsi_vlogvar_wait_assign_value(t14, t12, 0, 0, 1, 0LL);
    xsi_set_current_line(168, ng0);
    t2 = ((char*)((ng6)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);
    goto LAB99;

LAB104:    t26 = (t23 + 4);
    *((unsigned int *)t23) = 1;
    *((unsigned int *)t26) = 1;
    goto LAB105;

LAB106:    xsi_set_current_line(176, ng0);

LAB109:    xsi_set_current_line(177, ng0);
    t33 = (t0 + 3896U);
    t34 = *((char **)t33);
    t33 = (t34 + 4);
    t35 = *((unsigned int *)t33);
    t36 = (~(t35));
    t37 = *((unsigned int *)t34);
    t38 = (t37 & t36);
    t39 = (t38 != 0);
    if (t39 > 0)
        goto LAB110;

LAB111:    xsi_set_current_line(179, ng0);

LAB114:    xsi_set_current_line(180, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 6056);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 11, 0LL);
    xsi_set_current_line(181, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 3, 0LL);

LAB112:    goto LAB108;

LAB110:    xsi_set_current_line(177, ng0);

LAB113:    xsi_set_current_line(178, ng0);
    t40 = ((char*)((ng8)));
    t41 = (t0 + 5896);
    xsi_vlogvar_wait_assign_value(t41, t40, 0, 0, 3, 0LL);
    goto LAB112;

}


extern void work_m_00000000003872250957_3042175479_init()
{
	static char *pe[] = {(void *)NetDecl_72_0,(void *)NetDecl_73_1,(void *)Always_75_2};
	xsi_register_didat("work_m_00000000003872250957_3042175479", "isim/IO_TANH_TB_isim_beh.exe.sim/work/m_00000000003872250957_3042175479.didat");
	xsi_register_executes(pe);
}
