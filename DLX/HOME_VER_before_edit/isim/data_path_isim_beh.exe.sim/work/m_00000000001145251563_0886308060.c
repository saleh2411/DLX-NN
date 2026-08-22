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
static const char *ng0 = "C:/Users/administrator.CLS-210-PC/Desktop/saed/simple_DLX/Week7/HOME_VER_before_edit/ALU.v";
static unsigned int ng1[] = {3U, 0U};
static unsigned int ng2[] = {0U, 0U};



static void Cont_82_0(char *t0)
{
    char t3[8];
    char t4[8];
    char *t1;
    char *t2;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    char *t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    unsigned int t27;
    unsigned int t28;
    char *t29;
    unsigned int t30;
    unsigned int t31;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    char *t35;

LAB0:    t1 = (t0 + 5088U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(82, ng0);
    t2 = (t0 + 1688U);
    t5 = *((char **)t2);
    memset(t4, 0, 8);
    t2 = (t5 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB4;

LAB5:    if (*((unsigned int *)t2) != 0)
        goto LAB6;

LAB7:    t12 = (t4 + 4);
    t13 = *((unsigned int *)t4);
    t14 = *((unsigned int *)t12);
    t15 = (t13 || t14);
    if (t15 > 0)
        goto LAB8;

LAB9:    t17 = *((unsigned int *)t4);
    t18 = (~(t17));
    t19 = *((unsigned int *)t12);
    t20 = (t18 || t19);
    if (t20 > 0)
        goto LAB10;

LAB11:    if (*((unsigned int *)t12) > 0)
        goto LAB12;

LAB13:    if (*((unsigned int *)t4) > 0)
        goto LAB14;

LAB15:    memcpy(t3, t22, 8);

LAB16:    t21 = (t0 + 6016);
    t23 = (t21 + 56U);
    t24 = *((char **)t23);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    memset(t26, 0, 8);
    t27 = 7U;
    t28 = t27;
    t29 = (t3 + 4);
    t30 = *((unsigned int *)t3);
    t27 = (t27 & t30);
    t31 = *((unsigned int *)t29);
    t28 = (t28 & t31);
    t32 = (t26 + 4);
    t33 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t33 | t27);
    t34 = *((unsigned int *)t32);
    *((unsigned int *)t32) = (t34 | t28);
    xsi_driver_vfirst_trans(t21, 0, 2);
    t35 = (t0 + 5904);
    *((int *)t35) = 1;

LAB1:    return;
LAB4:    *((unsigned int *)t4) = 1;
    goto LAB7;

LAB6:    t11 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t11) = 1;
    goto LAB7;

LAB8:    t16 = ((char*)((ng1)));
    goto LAB9;

LAB10:    t21 = (t0 + 1368U);
    t22 = *((char **)t21);
    goto LAB11;

LAB12:    xsi_vlog_unsigned_bit_combine(t3, 3, t16, 3, t22, 3);
    goto LAB16;

LAB14:    memcpy(t3, t16, 8);
    goto LAB16;

}

static void implSig1_execute(char *t0)
{
    char t4[8];
    char t6[8];
    char t31[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    char *t20;
    char *t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    char *t35;
    char *t36;
    char *t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    char *t45;
    char *t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    int t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    unsigned int t58;
    char *t59;
    char *t60;
    char *t61;
    char *t62;
    char *t63;
    unsigned int t64;
    unsigned int t65;
    char *t66;
    unsigned int t67;
    unsigned int t68;
    char *t69;
    unsigned int t70;
    unsigned int t71;
    char *t72;

LAB0:    t1 = (t0 + 5336U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = (t0 + 1528U);
    t3 = *((char **)t2);
    t2 = (t0 + 2008U);
    t5 = *((char **)t2);
    memset(t6, 0, 8);
    t2 = (t6 + 4);
    t7 = (t5 + 4);
    t8 = *((unsigned int *)t5);
    t9 = (t8 >> 0);
    t10 = (t9 & 1);
    *((unsigned int *)t6) = t10;
    t11 = *((unsigned int *)t7);
    t12 = (t11 >> 0);
    t13 = (t12 & 1);
    *((unsigned int *)t2) = t13;
    memset(t4, 0, 8);
    t14 = (t6 + 4);
    t15 = *((unsigned int *)t14);
    t16 = (~(t15));
    t17 = *((unsigned int *)t6);
    t18 = (t17 & t16);
    t19 = (t18 & 1U);
    if (t19 != 0)
        goto LAB7;

LAB5:    if (*((unsigned int *)t14) == 0)
        goto LAB4;

LAB6:    t20 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t20) = 1;

LAB7:    t21 = (t4 + 4);
    t22 = (t6 + 4);
    t23 = *((unsigned int *)t6);
    t24 = (~(t23));
    *((unsigned int *)t4) = t24;
    *((unsigned int *)t21) = 0;
    if (*((unsigned int *)t22) != 0)
        goto LAB9;

LAB8:    t29 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t29 & 1U);
    t30 = *((unsigned int *)t21);
    *((unsigned int *)t21) = (t30 & 1U);
    t32 = *((unsigned int *)t3);
    t33 = *((unsigned int *)t4);
    t34 = (t32 | t33);
    *((unsigned int *)t31) = t34;
    t35 = (t3 + 4);
    t36 = (t4 + 4);
    t37 = (t31 + 4);
    t38 = *((unsigned int *)t35);
    t39 = *((unsigned int *)t36);
    t40 = (t38 | t39);
    *((unsigned int *)t37) = t40;
    t41 = *((unsigned int *)t37);
    t42 = (t41 != 0);
    if (t42 == 1)
        goto LAB10;

LAB11:
LAB12:    t59 = (t0 + 6080);
    t60 = (t59 + 56U);
    t61 = *((char **)t60);
    t62 = (t61 + 56U);
    t63 = *((char **)t62);
    memset(t63, 0, 8);
    t64 = 1U;
    t65 = t64;
    t66 = (t31 + 4);
    t67 = *((unsigned int *)t31);
    t64 = (t64 & t67);
    t68 = *((unsigned int *)t66);
    t65 = (t65 & t68);
    t69 = (t63 + 4);
    t70 = *((unsigned int *)t63);
    *((unsigned int *)t63) = (t70 | t64);
    t71 = *((unsigned int *)t69);
    *((unsigned int *)t69) = (t71 | t65);
    xsi_driver_vfirst_trans(t59, 0, 0);
    t72 = (t0 + 5920);
    *((int *)t72) = 1;

LAB1:    return;
LAB4:    *((unsigned int *)t4) = 1;
    goto LAB7;

LAB9:    t25 = *((unsigned int *)t4);
    t26 = *((unsigned int *)t22);
    *((unsigned int *)t4) = (t25 | t26);
    t27 = *((unsigned int *)t21);
    t28 = *((unsigned int *)t22);
    *((unsigned int *)t21) = (t27 | t28);
    goto LAB8;

LAB10:    t43 = *((unsigned int *)t31);
    t44 = *((unsigned int *)t37);
    *((unsigned int *)t31) = (t43 | t44);
    t45 = (t3 + 4);
    t46 = (t4 + 4);
    t47 = *((unsigned int *)t45);
    t48 = (~(t47));
    t49 = *((unsigned int *)t3);
    t50 = (t49 & t48);
    t51 = *((unsigned int *)t46);
    t52 = (~(t51));
    t53 = *((unsigned int *)t4);
    t54 = (t53 & t52);
    t55 = (~(t50));
    t56 = (~(t54));
    t57 = *((unsigned int *)t37);
    *((unsigned int *)t37) = (t57 & t55);
    t58 = *((unsigned int *)t37);
    *((unsigned int *)t37) = (t58 & t56);
    goto LAB12;

}

static void implSig2_execute(char *t0)
{
    char t3[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;

LAB0:    t1 = (t0 + 5584U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = (t0 + 2648U);
    t4 = *((char **)t2);
    t2 = ((char*)((ng2)));
    xsi_vlogtype_concat(t3, 32, 32, 2U, t2, 31, t4, 1);
    t5 = (t0 + 6144);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t3, 8);
    xsi_driver_vfirst_trans(t5, 0, 31);
    t10 = (t0 + 5936);
    *((int *)t10) = 1;

LAB1:    return;
}


extern void work_m_00000000001145251563_0886308060_init()
{
	static char *pe[] = {(void *)Cont_82_0,(void *)implSig1_execute,(void *)implSig2_execute};
	xsi_register_didat("work_m_00000000001145251563_0886308060", "isim/data_path_isim_beh.exe.sim/work/m_00000000001145251563_0886308060.didat");
	xsi_register_executes(pe);
}
