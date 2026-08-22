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
static const char *ng0 = "C:/Users/administrator.CLS-210-PC/Desktop/saed/saleh/Week7/HOME_VER_before_edit/sigmoid.v";
static unsigned int ng1[] = {1U, 0U};
static unsigned int ng2[] = {327680U, 0U};
static unsigned int ng3[] = {65536U, 0U};
static unsigned int ng4[] = {155648U, 0U};
static int ng5[] = {5, 0};
static unsigned int ng6[] = {55296U, 0U};
static unsigned int ng7[] = {73728U, 0U};
static int ng8[] = {3, 0};
static unsigned int ng9[] = {40960U, 0U};
static unsigned int ng10[] = {57344U, 0U};
static unsigned int ng11[] = {39719U, 0U};
static unsigned int ng12[] = {0U, 0U};
static int ng13[] = {2, 0};
static unsigned int ng14[] = {32768U, 0U};



static void Always_42_0(char *t0)
{
    char t6[8];
    char t15[8];
    char t18[8];
    char t31[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    unsigned int t16;
    unsigned int t17;
    char *t19;
    char *t20;
    char *t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t36;
    char *t37;
    char *t38;
    char *t39;

LAB0:    t1 = (t0 + 4208U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(42, ng0);
    t2 = (t0 + 4528);
    *((int *)t2) = 1;
    t3 = (t0 + 4240);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(42, ng0);

LAB5:    xsi_set_current_line(44, ng0);
    t4 = (t0 + 2408U);
    t5 = *((char **)t4);
    memset(t6, 0, 8);
    t4 = (t6 + 4);
    t7 = (t5 + 4);
    t8 = *((unsigned int *)t5);
    t9 = (t8 >> 31);
    t10 = (t9 & 1);
    *((unsigned int *)t6) = t10;
    t11 = *((unsigned int *)t7);
    t12 = (t11 >> 31);
    t13 = (t12 & 1);
    *((unsigned int *)t4) = t13;
    t14 = (t0 + 2968);
    xsi_vlogvar_assign_value(t14, t6, 0, 0, 1);
    xsi_set_current_line(45, ng0);
    t2 = (t0 + 2968);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t15, 0, 8);
    t5 = (t4 + 4);
    t8 = *((unsigned int *)t5);
    t9 = (~(t8));
    t10 = *((unsigned int *)t4);
    t11 = (t10 & t9);
    t12 = (t11 & 1U);
    if (t12 != 0)
        goto LAB6;

LAB7:    if (*((unsigned int *)t5) != 0)
        goto LAB8;

LAB9:    t14 = (t15 + 4);
    t13 = *((unsigned int *)t15);
    t16 = *((unsigned int *)t14);
    t17 = (t13 || t16);
    if (t17 > 0)
        goto LAB10;

LAB11:    t32 = *((unsigned int *)t15);
    t33 = (~(t32));
    t34 = *((unsigned int *)t14);
    t35 = (t33 || t34);
    if (t35 > 0)
        goto LAB12;

LAB13:    if (*((unsigned int *)t14) > 0)
        goto LAB14;

LAB15:    if (*((unsigned int *)t15) > 0)
        goto LAB16;

LAB17:    memcpy(t6, t37, 8);

LAB18:    t36 = (t0 + 3128);
    xsi_vlogvar_assign_value(t36, t6, 0, 0, 32);
    xsi_set_current_line(48, ng0);
    t2 = (t0 + 3128);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng2)));
    memset(t6, 0, 8);
    t7 = (t4 + 4);
    if (*((unsigned int *)t7) != 0)
        goto LAB22;

LAB21:    t14 = (t5 + 4);
    if (*((unsigned int *)t14) != 0)
        goto LAB22;

LAB25:    if (*((unsigned int *)t4) < *((unsigned int *)t5))
        goto LAB24;

LAB23:    *((unsigned int *)t6) = 1;

LAB24:    t20 = (t6 + 4);
    t8 = *((unsigned int *)t20);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 != 0);
    if (t12 > 0)
        goto LAB26;

LAB27:    xsi_set_current_line(50, ng0);
    t2 = (t0 + 3128);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng4)));
    memset(t6, 0, 8);
    t7 = (t4 + 4);
    if (*((unsigned int *)t7) != 0)
        goto LAB31;

LAB30:    t14 = (t5 + 4);
    if (*((unsigned int *)t14) != 0)
        goto LAB31;

LAB34:    if (*((unsigned int *)t4) < *((unsigned int *)t5))
        goto LAB33;

LAB32:    *((unsigned int *)t6) = 1;

LAB33:    t20 = (t6 + 4);
    t8 = *((unsigned int *)t20);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 != 0);
    if (t12 > 0)
        goto LAB35;

LAB36:    xsi_set_current_line(52, ng0);
    t2 = (t0 + 3128);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng7)));
    memset(t6, 0, 8);
    t7 = (t4 + 4);
    if (*((unsigned int *)t7) != 0)
        goto LAB40;

LAB39:    t14 = (t5 + 4);
    if (*((unsigned int *)t14) != 0)
        goto LAB40;

LAB43:    if (*((unsigned int *)t4) < *((unsigned int *)t5))
        goto LAB42;

LAB41:    *((unsigned int *)t6) = 1;

LAB42:    t20 = (t6 + 4);
    t8 = *((unsigned int *)t20);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 != 0);
    if (t12 > 0)
        goto LAB44;

LAB45:    xsi_set_current_line(54, ng0);
    t2 = (t0 + 3128);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng10)));
    memset(t6, 0, 8);
    t7 = (t4 + 4);
    if (*((unsigned int *)t7) != 0)
        goto LAB49;

LAB48:    t14 = (t5 + 4);
    if (*((unsigned int *)t14) != 0)
        goto LAB49;

LAB52:    if (*((unsigned int *)t4) < *((unsigned int *)t5))
        goto LAB51;

LAB50:    *((unsigned int *)t6) = 1;

LAB51:    t20 = (t6 + 4);
    t8 = *((unsigned int *)t20);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 != 0);
    if (t12 > 0)
        goto LAB53;

LAB54:    xsi_set_current_line(56, ng0);
    t2 = (t0 + 3128);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng12)));
    memset(t6, 0, 8);
    t7 = (t4 + 4);
    if (*((unsigned int *)t7) != 0)
        goto LAB58;

LAB57:    t14 = (t5 + 4);
    if (*((unsigned int *)t14) != 0)
        goto LAB58;

LAB61:    if (*((unsigned int *)t4) < *((unsigned int *)t5))
        goto LAB60;

LAB59:    *((unsigned int *)t6) = 1;

LAB60:    t20 = (t6 + 4);
    t8 = *((unsigned int *)t20);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 != 0);
    if (t12 > 0)
        goto LAB62;

LAB63:    xsi_set_current_line(58, ng0);

LAB66:    xsi_set_current_line(59, ng0);
    t2 = ((char*)((ng12)));
    t3 = (t0 + 3288);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 32);

LAB64:
LAB55:
LAB46:
LAB37:
LAB28:    xsi_set_current_line(63, ng0);
    t2 = (t0 + 2968);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 4);
    t8 = *((unsigned int *)t5);
    t9 = (~(t8));
    t10 = *((unsigned int *)t4);
    t11 = (t10 & t9);
    t12 = (t11 != 0);
    if (t12 > 0)
        goto LAB67;

LAB68:    xsi_set_current_line(64, ng0);
    t2 = (t0 + 3288);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 2808);
    xsi_vlogvar_assign_value(t5, t4, 0, 0, 32);

LAB69:    goto LAB2;

LAB6:    *((unsigned int *)t15) = 1;
    goto LAB9;

LAB8:    t7 = (t15 + 4);
    *((unsigned int *)t15) = 1;
    *((unsigned int *)t7) = 1;
    goto LAB9;

LAB10:    t19 = (t0 + 2408U);
    t20 = *((char **)t19);
    memset(t18, 0, 8);
    t19 = (t18 + 4);
    t21 = (t20 + 4);
    t22 = *((unsigned int *)t20);
    t23 = (~(t22));
    *((unsigned int *)t18) = t23;
    *((unsigned int *)t19) = 0;
    if (*((unsigned int *)t21) != 0)
        goto LAB20;

LAB19:    t28 = *((unsigned int *)t18);
    *((unsigned int *)t18) = (t28 & 4294967295U);
    t29 = *((unsigned int *)t19);
    *((unsigned int *)t19) = (t29 & 4294967295U);
    t30 = ((char*)((ng1)));
    memset(t31, 0, 8);
    xsi_vlog_unsigned_add(t31, 32, t18, 32, t30, 32);
    goto LAB11;

LAB12:    t36 = (t0 + 2408U);
    t37 = *((char **)t36);
    goto LAB13;

LAB14:    xsi_vlog_unsigned_bit_combine(t6, 32, t31, 32, t37, 32);
    goto LAB18;

LAB16:    memcpy(t6, t31, 8);
    goto LAB18;

LAB20:    t24 = *((unsigned int *)t18);
    t25 = *((unsigned int *)t21);
    *((unsigned int *)t18) = (t24 | t25);
    t26 = *((unsigned int *)t19);
    t27 = *((unsigned int *)t21);
    *((unsigned int *)t19) = (t26 | t27);
    goto LAB19;

LAB22:    t19 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB24;

LAB26:    xsi_set_current_line(48, ng0);

LAB29:    xsi_set_current_line(49, ng0);
    t21 = ((char*)((ng3)));
    t30 = (t0 + 3288);
    xsi_vlogvar_assign_value(t30, t21, 0, 0, 32);
    goto LAB28;

LAB31:    t19 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB33;

LAB35:    xsi_set_current_line(50, ng0);

LAB38:    xsi_set_current_line(51, ng0);
    t21 = (t0 + 3128);
    t30 = (t21 + 56U);
    t36 = *((char **)t30);
    t37 = ((char*)((ng5)));
    memset(t15, 0, 8);
    xsi_vlog_unsigned_arith_rshift(t15, 32, t36, 32, t37, 32);
    t38 = ((char*)((ng6)));
    memset(t18, 0, 8);
    xsi_vlog_unsigned_add(t18, 32, t15, 32, t38, 32);
    t39 = (t0 + 3288);
    xsi_vlogvar_assign_value(t39, t18, 0, 0, 32);
    goto LAB37;

LAB40:    t19 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB42;

LAB44:    xsi_set_current_line(52, ng0);

LAB47:    xsi_set_current_line(53, ng0);
    t21 = (t0 + 3128);
    t30 = (t21 + 56U);
    t36 = *((char **)t30);
    t37 = ((char*)((ng8)));
    memset(t15, 0, 8);
    xsi_vlog_unsigned_arith_rshift(t15, 32, t36, 32, t37, 32);
    t38 = ((char*)((ng9)));
    memset(t18, 0, 8);
    xsi_vlog_unsigned_add(t18, 32, t15, 32, t38, 32);
    t39 = (t0 + 3288);
    xsi_vlogvar_assign_value(t39, t18, 0, 0, 32);
    goto LAB46;

LAB49:    t19 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB51;

LAB53:    xsi_set_current_line(54, ng0);

LAB56:    xsi_set_current_line(55, ng0);
    t21 = (t0 + 3128);
    t30 = (t21 + 56U);
    t36 = *((char **)t30);
    t37 = ((char*)((ng8)));
    memset(t15, 0, 8);
    xsi_vlog_unsigned_arith_rshift(t15, 32, t36, 32, t37, 32);
    t38 = ((char*)((ng11)));
    memset(t18, 0, 8);
    xsi_vlog_unsigned_add(t18, 32, t15, 32, t38, 32);
    t39 = (t0 + 3288);
    xsi_vlogvar_assign_value(t39, t18, 0, 0, 32);
    goto LAB55;

LAB58:    t19 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB60;

LAB62:    xsi_set_current_line(56, ng0);

LAB65:    xsi_set_current_line(57, ng0);
    t21 = (t0 + 3128);
    t30 = (t21 + 56U);
    t36 = *((char **)t30);
    t37 = ((char*)((ng13)));
    memset(t15, 0, 8);
    xsi_vlog_unsigned_arith_rshift(t15, 32, t36, 32, t37, 32);
    t38 = ((char*)((ng14)));
    memset(t18, 0, 8);
    xsi_vlog_unsigned_add(t18, 32, t15, 32, t38, 32);
    t39 = (t0 + 3288);
    xsi_vlogvar_assign_value(t39, t18, 0, 0, 32);
    goto LAB64;

LAB67:    xsi_set_current_line(63, ng0);
    t7 = ((char*)((ng3)));
    t14 = (t0 + 3288);
    t19 = (t14 + 56U);
    t20 = *((char **)t19);
    memset(t6, 0, 8);
    xsi_vlog_unsigned_minus(t6, 32, t7, 32, t20, 32);
    t21 = (t0 + 2808);
    xsi_vlogvar_assign_value(t21, t6, 0, 0, 32);
    goto LAB69;

}


extern void work_m_00000000000741242410_1760155547_init()
{
	static char *pe[] = {(void *)Always_42_0};
	xsi_register_didat("work_m_00000000000741242410_1760155547", "isim/IO_TANH_TB_isim_beh.exe.sim/work/m_00000000000741242410_1760155547.didat");
	xsi_register_executes(pe);
}
