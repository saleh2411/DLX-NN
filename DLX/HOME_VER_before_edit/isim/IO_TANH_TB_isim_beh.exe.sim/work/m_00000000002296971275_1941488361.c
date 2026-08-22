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
static const char *ng0 = "C:/Users/administrator.CLS-210-PC/Desktop/saed/saleh/Week7/HOME_VER_before_edit/IO_TANH_TB.v";
static unsigned int ng1[] = {0U, 0U};
static unsigned int ng2[] = {1U, 0U};
static int ng3[] = {0, 0};
static unsigned int ng4[] = {19U, 0U};
static int ng5[] = {100, 0};
static int ng6[] = {1, 0};
static const char *ng7 = "--------------------------------------------------";
static const char *ng8 = "Instructions stepped = %0d";
static const char *ng9 = "Final control state  = %b";
static const char *ng10 = "Input  [word 4]      = %h";
static int ng11[] = {4, 0};
static const char *ng12 = "Result [word 5]      = %h";
static int ng13[] = {5, 0};
static const char *ng14 = "Expected result      = 0000e000";
static const char *ng15 = "TANH FAIL: processor did not reach HALT";
static unsigned int ng16[] = {98304U, 0U};
static const char *ng17 = "TANH FAIL: input word is not 1.5 in Q16.16";
static unsigned int ng18[] = {57344U, 0U};
static const char *ng19 = "TANH PASS: result is 0.875 in Q16.16";
static const char *ng20 = "TANH FAIL: wrong result";



static void Always_28_0(char *t0)
{
    char t3[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    char *t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    char *t24;

LAB0:    t1 = (t0 + 3008U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(28, ng0);
    t2 = (t0 + 2816);
    xsi_process_wait(t2, 50000LL);
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(28, ng0);
    t4 = (t0 + 1608);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    memset(t3, 0, 8);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t7);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 & 1U);
    if (t12 != 0)
        goto LAB8;

LAB6:    if (*((unsigned int *)t7) == 0)
        goto LAB5;

LAB7:    t13 = (t3 + 4);
    *((unsigned int *)t3) = 1;
    *((unsigned int *)t13) = 1;

LAB8:    t14 = (t3 + 4);
    t15 = (t6 + 4);
    t16 = *((unsigned int *)t6);
    t17 = (~(t16));
    *((unsigned int *)t3) = t17;
    *((unsigned int *)t14) = 0;
    if (*((unsigned int *)t15) != 0)
        goto LAB10;

LAB9:    t22 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t22 & 1U);
    t23 = *((unsigned int *)t14);
    *((unsigned int *)t14) = (t23 & 1U);
    t24 = (t0 + 1608);
    xsi_vlogvar_assign_value(t24, t3, 0, 0, 1);
    goto LAB2;

LAB5:    *((unsigned int *)t3) = 1;
    goto LAB8;

LAB10:    t18 = *((unsigned int *)t3);
    t19 = *((unsigned int *)t15);
    *((unsigned int *)t3) = (t18 | t19);
    t20 = *((unsigned int *)t14);
    t21 = *((unsigned int *)t15);
    *((unsigned int *)t14) = (t20 | t21);
    goto LAB9;

}

static void Initial_30_1(char *t0)
{
    char t4[8];
    char t7[8];
    char t23[8];
    char t24[8];
    char t32[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    char *t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    char *t31;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t36;
    char *t37;
    char *t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    char *t46;
    char *t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    unsigned int t55;
    int t56;
    int t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    char *t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    char *t70;

LAB0:    t1 = (t0 + 3256U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(30, ng0);

LAB4:    xsi_set_current_line(31, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 1608);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 1);
    xsi_set_current_line(32, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 1768);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 1);
    xsi_set_current_line(33, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 1928);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 1);
    xsi_set_current_line(34, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 2088);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);
    xsi_set_current_line(37, ng0);
    t2 = (t0 + 3576);
    *((int *)t2) = 1;
    t3 = (t0 + 3288);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB5;

LAB1:    return;
LAB5:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 3064);
    xsi_process_wait(t2, 5000LL);
    *((char **)t1) = &&LAB6;
    goto LAB1;

LAB6:    xsi_set_current_line(39, ng0);
    t2 = (t0 + 3064);
    xsi_process_wait(t2, 200000LL);
    *((char **)t1) = &&LAB7;
    goto LAB1;

LAB7:    xsi_set_current_line(40, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 1768);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 1);
    xsi_set_current_line(41, ng0);
    t2 = (t0 + 3064);
    xsi_process_wait(t2, 3000000LL);
    *((char **)t1) = &&LAB8;
    goto LAB1;

LAB8:    xsi_set_current_line(45, ng0);

LAB9:    t2 = (t0 + 1208U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng4)));
    memset(t4, 0, 8);
    if (*((unsigned int *)t3) != *((unsigned int *)t2))
        goto LAB11;

LAB10:    t5 = (t3 + 4);
    t6 = (t2 + 4);
    if (*((unsigned int *)t5) != *((unsigned int *)t6))
        goto LAB11;

LAB12:    memset(t7, 0, 8);
    t8 = (t4 + 4);
    t9 = *((unsigned int *)t8);
    t10 = (~(t9));
    t11 = *((unsigned int *)t4);
    t12 = (t11 & t10);
    t13 = (t12 & 1U);
    if (t13 != 0)
        goto LAB13;

LAB14:    if (*((unsigned int *)t8) != 0)
        goto LAB15;

LAB16:    t15 = (t7 + 4);
    t16 = *((unsigned int *)t7);
    t17 = *((unsigned int *)t15);
    t18 = (t16 || t17);
    if (t18 > 0)
        goto LAB17;

LAB18:    memcpy(t32, t7, 8);

LAB19:    t64 = (t32 + 4);
    t65 = *((unsigned int *)t64);
    t66 = (~(t65));
    t67 = *((unsigned int *)t32);
    t68 = (t67 & t66);
    t69 = (t68 != 0);
    if (t69 > 0)
        goto LAB27;

LAB28:    xsi_set_current_line(55, ng0);
    t2 = (t0 + 3064);
    xsi_process_wait(t2, 100000LL);
    *((char **)t1) = &&LAB33;
    goto LAB1;

LAB11:    *((unsigned int *)t4) = 1;
    goto LAB12;

LAB13:    *((unsigned int *)t7) = 1;
    goto LAB16;

LAB15:    t14 = (t7 + 4);
    *((unsigned int *)t7) = 1;
    *((unsigned int *)t14) = 1;
    goto LAB16;

LAB17:    t19 = (t0 + 2088);
    t20 = (t19 + 56U);
    t21 = *((char **)t20);
    t22 = ((char*)((ng5)));
    memset(t23, 0, 8);
    xsi_vlog_signed_less(t23, 32, t21, 32, t22, 32);
    memset(t24, 0, 8);
    t25 = (t23 + 4);
    t26 = *((unsigned int *)t25);
    t27 = (~(t26));
    t28 = *((unsigned int *)t23);
    t29 = (t28 & t27);
    t30 = (t29 & 1U);
    if (t30 != 0)
        goto LAB20;

LAB21:    if (*((unsigned int *)t25) != 0)
        goto LAB22;

LAB23:    t33 = *((unsigned int *)t7);
    t34 = *((unsigned int *)t24);
    t35 = (t33 & t34);
    *((unsigned int *)t32) = t35;
    t36 = (t7 + 4);
    t37 = (t24 + 4);
    t38 = (t32 + 4);
    t39 = *((unsigned int *)t36);
    t40 = *((unsigned int *)t37);
    t41 = (t39 | t40);
    *((unsigned int *)t38) = t41;
    t42 = *((unsigned int *)t38);
    t43 = (t42 != 0);
    if (t43 == 1)
        goto LAB24;

LAB25:
LAB26:    goto LAB19;

LAB20:    *((unsigned int *)t24) = 1;
    goto LAB23;

LAB22:    t31 = (t24 + 4);
    *((unsigned int *)t24) = 1;
    *((unsigned int *)t31) = 1;
    goto LAB23;

LAB24:    t44 = *((unsigned int *)t32);
    t45 = *((unsigned int *)t38);
    *((unsigned int *)t32) = (t44 | t45);
    t46 = (t7 + 4);
    t47 = (t24 + 4);
    t48 = *((unsigned int *)t7);
    t49 = (~(t48));
    t50 = *((unsigned int *)t46);
    t51 = (~(t50));
    t52 = *((unsigned int *)t24);
    t53 = (~(t52));
    t54 = *((unsigned int *)t47);
    t55 = (~(t54));
    t56 = (t49 & t51);
    t57 = (t53 & t55);
    t58 = (~(t56));
    t59 = (~(t57));
    t60 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t60 & t58);
    t61 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t61 & t59);
    t62 = *((unsigned int *)t32);
    *((unsigned int *)t32) = (t62 & t58);
    t63 = *((unsigned int *)t32);
    *((unsigned int *)t32) = (t63 & t59);
    goto LAB26;

LAB27:    xsi_set_current_line(46, ng0);

LAB29:    xsi_set_current_line(47, ng0);
    t70 = (t0 + 3064);
    xsi_process_wait(t70, 500000LL);
    *((char **)t1) = &&LAB30;
    goto LAB1;

LAB30:    xsi_set_current_line(48, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 1928);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 1);
    xsi_set_current_line(49, ng0);
    t2 = (t0 + 3064);
    xsi_process_wait(t2, 100000LL);
    *((char **)t1) = &&LAB31;
    goto LAB1;

LAB31:    xsi_set_current_line(50, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 1928);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 1);
    xsi_set_current_line(51, ng0);
    t2 = (t0 + 3064);
    xsi_process_wait(t2, 3000000LL);
    *((char **)t1) = &&LAB32;
    goto LAB1;

LAB32:    xsi_set_current_line(52, ng0);
    t2 = (t0 + 2088);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng6)));
    memset(t4, 0, 8);
    xsi_vlog_signed_add(t4, 32, t5, 32, t6, 32);
    t8 = (t0 + 2088);
    xsi_vlogvar_assign_value(t8, t4, 0, 0, 32);
    goto LAB9;

LAB33:    xsi_set_current_line(56, ng0);
    xsi_vlogfile_write(1, 0, 0, ng7, 1, t0);
    xsi_set_current_line(57, ng0);
    t2 = (t0 + 2088);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    xsi_vlogfile_write(1, 0, 0, ng8, 2, t0, (char)119, t5, 32);
    xsi_set_current_line(58, ng0);
    t2 = (t0 + 1208U);
    t3 = *((char **)t2);
    xsi_vlogfile_write(1, 0, 0, ng9, 2, t0, (char)118, t3, 5);
    xsi_set_current_line(59, ng0);
    t2 = (t0 + 5412);
    t3 = *((char **)t2);
    t5 = ((((char*)(t3))) + 56U);
    t6 = *((char **)t5);
    t8 = (t0 + 5460);
    t14 = *((char **)t8);
    t15 = ((((char*)(t14))) + 72U);
    t19 = *((char **)t15);
    t20 = (t0 + 5508);
    t21 = *((char **)t20);
    t22 = ((((char*)(t21))) + 64U);
    t25 = *((char **)t22);
    t31 = ((char*)((ng11)));
    xsi_vlog_generic_get_array_select_value(t4, 32, t6, t19, t25, 2, 1, t31, 32, 1);
    xsi_vlogfile_write(1, 0, 0, ng10, 2, t0, (char)118, t4, 32);
    xsi_set_current_line(61, ng0);
    t2 = (t0 + 5556);
    t3 = *((char **)t2);
    t5 = ((((char*)(t3))) + 56U);
    t6 = *((char **)t5);
    t8 = (t0 + 5604);
    t14 = *((char **)t8);
    t15 = ((((char*)(t14))) + 72U);
    t19 = *((char **)t15);
    t20 = (t0 + 5652);
    t21 = *((char **)t20);
    t22 = ((((char*)(t21))) + 64U);
    t25 = *((char **)t22);
    t31 = ((char*)((ng13)));
    xsi_vlog_generic_get_array_select_value(t4, 32, t6, t19, t25, 2, 1, t31, 32, 1);
    xsi_vlogfile_write(1, 0, 0, ng12, 2, t0, (char)118, t4, 32);
    xsi_set_current_line(63, ng0);
    xsi_vlogfile_write(1, 0, 0, ng14, 1, t0);
    xsi_set_current_line(65, ng0);
    t2 = (t0 + 1208U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng4)));
    memset(t4, 0, 8);
    if (*((unsigned int *)t3) != *((unsigned int *)t2))
        goto LAB35;

LAB34:    t5 = (t3 + 4);
    t6 = (t2 + 4);
    if (*((unsigned int *)t5) != *((unsigned int *)t6))
        goto LAB35;

LAB36:    t8 = (t4 + 4);
    t9 = *((unsigned int *)t8);
    t10 = (~(t9));
    t11 = *((unsigned int *)t4);
    t12 = (t11 & t10);
    t13 = (t12 != 0);
    if (t13 > 0)
        goto LAB37;

LAB38:    xsi_set_current_line(67, ng0);
    t2 = (t0 + 5700);
    t3 = *((char **)t2);
    t5 = ((((char*)(t3))) + 56U);
    t6 = *((char **)t5);
    t8 = (t0 + 5748);
    t14 = *((char **)t8);
    t15 = ((((char*)(t14))) + 72U);
    t19 = *((char **)t15);
    t20 = (t0 + 5796);
    t21 = *((char **)t20);
    t22 = ((((char*)(t21))) + 64U);
    t25 = *((char **)t22);
    t31 = ((char*)((ng11)));
    xsi_vlog_generic_get_array_select_value(t4, 32, t6, t19, t25, 2, 1, t31, 32, 1);
    t36 = ((char*)((ng16)));
    memset(t7, 0, 8);
    if (*((unsigned int *)t4) != *((unsigned int *)t36))
        goto LAB42;

LAB41:    t37 = (t4 + 4);
    t38 = (t36 + 4);
    if (*((unsigned int *)t37) != *((unsigned int *)t38))
        goto LAB42;

LAB43:    t46 = (t7 + 4);
    t9 = *((unsigned int *)t46);
    t10 = (~(t9));
    t11 = *((unsigned int *)t7);
    t12 = (t11 & t10);
    t13 = (t12 != 0);
    if (t13 > 0)
        goto LAB44;

LAB45:    xsi_set_current_line(70, ng0);
    t2 = (t0 + 5844);
    t3 = *((char **)t2);
    t5 = ((((char*)(t3))) + 56U);
    t6 = *((char **)t5);
    t8 = (t0 + 5892);
    t14 = *((char **)t8);
    t15 = ((((char*)(t14))) + 72U);
    t19 = *((char **)t15);
    t20 = (t0 + 5940);
    t21 = *((char **)t20);
    t22 = ((((char*)(t21))) + 64U);
    t25 = *((char **)t22);
    t31 = ((char*)((ng13)));
    xsi_vlog_generic_get_array_select_value(t4, 32, t6, t19, t25, 2, 1, t31, 32, 1);
    t36 = ((char*)((ng18)));
    memset(t7, 0, 8);
    if (*((unsigned int *)t4) != *((unsigned int *)t36))
        goto LAB50;

LAB48:    t37 = (t4 + 4);
    t38 = (t36 + 4);
    if (*((unsigned int *)t37) != *((unsigned int *)t38))
        goto LAB50;

LAB49:    *((unsigned int *)t7) = 1;

LAB50:    t46 = (t7 + 4);
    t9 = *((unsigned int *)t46);
    t10 = (~(t9));
    t11 = *((unsigned int *)t7);
    t12 = (t11 & t10);
    t13 = (t12 != 0);
    if (t13 > 0)
        goto LAB51;

LAB52:    xsi_set_current_line(73, ng0);

LAB55:    xsi_set_current_line(74, ng0);
    xsi_vlogfile_write(1, 0, 0, ng20, 1, t0);

LAB53:
LAB46:
LAB39:    xsi_set_current_line(77, ng0);
    xsi_vlogfile_write(1, 0, 0, ng7, 1, t0);
    xsi_set_current_line(78, ng0);
    xsi_vlog_finish(1);
    goto LAB1;

LAB35:    *((unsigned int *)t4) = 1;
    goto LAB36;

LAB37:    xsi_set_current_line(65, ng0);

LAB40:    xsi_set_current_line(66, ng0);
    xsi_vlogfile_write(1, 0, 0, ng15, 1, t0);
    goto LAB39;

LAB42:    *((unsigned int *)t7) = 1;
    goto LAB43;

LAB44:    xsi_set_current_line(68, ng0);

LAB47:    xsi_set_current_line(69, ng0);
    xsi_vlogfile_write(1, 0, 0, ng17, 1, t0);
    goto LAB46;

LAB51:    xsi_set_current_line(71, ng0);

LAB54:    xsi_set_current_line(72, ng0);
    xsi_vlogfile_write(1, 0, 0, ng19, 1, t0);
    goto LAB53;

}


extern void work_m_00000000002296971275_1941488361_init()
{
	static char *pe[] = {(void *)Always_28_0,(void *)Initial_30_1};
	xsi_register_didat("work_m_00000000002296971275_1941488361", "isim/IO_TANH_TB_isim_beh.exe.sim/work/m_00000000002296971275_1941488361.didat");
	xsi_register_executes(pe);
}
