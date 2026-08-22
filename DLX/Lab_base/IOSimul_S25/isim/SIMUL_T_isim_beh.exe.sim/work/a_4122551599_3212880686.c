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
static const char *ng0 = "E:/a_dlx_S25/student2/IOSimul_S25/SRAM.VHD";
extern char *WORK_P_0614985750;
extern char *IEEE_P_3620187407;
extern char *IEEE_P_2592010699;

unsigned char ieee_p_2592010699_sub_1690584930_503743352(char *, unsigned char );
unsigned char ieee_p_3620187407_sub_2599119909_3965413181(char *, int , char *, char *);


static void work_a_4122551599_3212880686_p_0(char *t0)
{
    char t39[16];
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    int t5;
    char *t6;
    int t7;
    int t8;
    char *t9;
    char *t10;
    char *t11;
    int t12;
    int t13;
    unsigned char t14;
    char *t15;
    int t16;
    int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t22;
    int t23;
    int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;
    char *t29;
    char *t30;
    char *t31;
    char *t32;
    unsigned char t33;
    unsigned char t34;
    unsigned char t35;
    unsigned char t36;
    unsigned char t37;
    unsigned char t38;
    unsigned char t40;
    unsigned char t41;
    unsigned char t42;
    char *t43;
    char *t44;
    char *t45;
    char *t46;

LAB0:    xsi_set_current_line(42, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB2;

LAB4:    t1 = (t0 + 1152U);
    t4 = xsi_signal_has_event(t1);
    if (t4 == 1)
        goto LAB15;

LAB16:    t3 = (unsigned char)0;

LAB17:    if (t3 != 0)
        goto LAB13;

LAB14:
LAB3:    t1 = (t0 + 5696);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(45, ng0);
    t5 = (1024 - 1);
    t1 = (t0 + 42135);
    *((int *)t1) = 0;
    t6 = (t0 + 42139);
    *((int *)t6) = t5;
    t7 = 0;
    t8 = t5;

LAB5:    if (t7 <= t8)
        goto LAB6;

LAB8:    goto LAB3;

LAB6:    xsi_set_current_line(46, ng0);
    t9 = (t0 + 42135);
    t10 = ((WORK_P_0614985750) + 1168U);
    t11 = *((char **)t10);
    t12 = *((int *)t11);
    t13 = *((int *)t9);
    t14 = (t13 < t12);
    if (t14 != 0)
        goto LAB9;

LAB11:    xsi_set_current_line(49, ng0);
    t1 = (t0 + 3648U);
    t2 = *((char **)t1);
    t1 = (t0 + 42135);
    t5 = *((int *)t1);
    t12 = (t5 - 1023);
    t18 = (t12 * -1);
    t19 = (32U * t18);
    t20 = (0U + t19);
    t6 = (t0 + 5824);
    t9 = (t6 + 56U);
    t10 = *((char **)t9);
    t11 = (t10 + 56U);
    t15 = *((char **)t11);
    memcpy(t15, t2, 32U);
    xsi_driver_first_trans_delta(t6, t20, 32U, 0LL);

LAB10:
LAB7:    t1 = (t0 + 42135);
    t7 = *((int *)t1);
    t2 = (t0 + 42139);
    t8 = *((int *)t2);
    if (t7 == t8)
        goto LAB8;

LAB12:    t5 = (t7 + 1);
    t7 = t5;
    t6 = (t0 + 42135);
    *((int *)t6) = t7;
    goto LAB5;

LAB9:    xsi_set_current_line(47, ng0);
    t10 = ((WORK_P_0614985750) + 1288U);
    t15 = *((char **)t10);
    t10 = (t0 + 42135);
    t16 = *((int *)t10);
    t17 = (t16 - 0);
    t18 = (t17 * 1);
    xsi_vhdl_check_range_of_index(0, 37, 1, *((int *)t10));
    t19 = (32U * t18);
    t20 = (0 + t19);
    t21 = (t15 + t20);
    t22 = (t0 + 42135);
    t23 = *((int *)t22);
    t24 = (t23 - 1023);
    t25 = (t24 * -1);
    t26 = (32U * t25);
    t27 = (0U + t26);
    t28 = (t0 + 5824);
    t29 = (t28 + 56U);
    t30 = *((char **)t29);
    t31 = (t30 + 56U);
    t32 = *((char **)t31);
    memcpy(t32, t21, 32U);
    xsi_driver_first_trans_delta(t28, t27, 32U, 0LL);
    goto LAB10;

LAB13:    xsi_set_current_line(55, ng0);
    t2 = (t0 + 1832U);
    t9 = *((char **)t2);
    t35 = *((unsigned char *)t9);
    t36 = (t35 == (unsigned char)2);
    if (t36 == 1)
        goto LAB21;

LAB22:    t34 = (unsigned char)0;

LAB23:    if (t34 != 0)
        goto LAB18;

LAB20:
LAB19:    goto LAB3;

LAB15:    t2 = (t0 + 1192U);
    t6 = *((char **)t2);
    t14 = *((unsigned char *)t6);
    t33 = (t14 == (unsigned char)3);
    t3 = t33;
    goto LAB17;

LAB18:    xsi_set_current_line(57, ng0);
    t5 = (1024 - 1);
    t2 = (t0 + 42143);
    *((int *)t2) = 0;
    t11 = (t0 + 42147);
    *((int *)t11) = t5;
    t7 = 0;
    t8 = t5;

LAB24:    if (t7 <= t8)
        goto LAB25;

LAB27:    goto LAB19;

LAB21:    t2 = (t0 + 2792U);
    t10 = *((char **)t2);
    t37 = *((unsigned char *)t10);
    t38 = (t37 == (unsigned char)3);
    t34 = t38;
    goto LAB23;

LAB25:    xsi_set_current_line(59, ng0);
    t15 = (t0 + 42143);
    t21 = (t0 + 1672U);
    t22 = *((char **)t21);
    t12 = (10 - 1);
    t18 = (20 - t12);
    t19 = (t18 * 1U);
    t20 = (0 + t19);
    t21 = (t22 + t20);
    t28 = (t39 + 0U);
    t29 = (t28 + 0U);
    *((int *)t29) = 9;
    t29 = (t28 + 4U);
    *((int *)t29) = 0;
    t29 = (t28 + 8U);
    *((int *)t29) = -1;
    t13 = (0 - 9);
    t25 = (t13 * -1);
    t25 = (t25 + 1);
    t29 = (t28 + 12U);
    *((unsigned int *)t29) = t25;
    t40 = ieee_p_3620187407_sub_2599119909_3965413181(IEEE_P_3620187407, *((int *)t15), t21, t39);
    if (t40 != 0)
        goto LAB28;

LAB30:
LAB29:
LAB26:    t1 = (t0 + 42143);
    t7 = *((int *)t1);
    t2 = (t0 + 42147);
    t8 = *((int *)t2);
    if (t7 == t8)
        goto LAB27;

LAB34:    t5 = (t7 + 1);
    t7 = t5;
    t6 = (t0 + 42143);
    *((int *)t6) = t7;
    goto LAB24;

LAB28:    xsi_set_current_line(61, ng0);
    t29 = (t0 + 1352U);
    t30 = *((char **)t29);
    t41 = *((unsigned char *)t30);
    t42 = (t41 == (unsigned char)3);
    if (t42 != 0)
        goto LAB31;

LAB33:    xsi_set_current_line(64, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 42143);
    t5 = *((int *)t1);
    t12 = (t5 - 1023);
    t18 = (t12 * -1);
    xsi_vhdl_check_range_of_index(1023, 0, -1, *((int *)t1));
    t19 = (32U * t18);
    t20 = (0 + t19);
    t6 = (t2 + t20);
    t9 = (t0 + 5888);
    t10 = (t9 + 56U);
    t11 = *((char **)t10);
    t15 = (t11 + 56U);
    t21 = *((char **)t15);
    memcpy(t21, t6, 32U);
    xsi_driver_first_trans_fast(t9);

LAB32:    goto LAB29;

LAB31:    xsi_set_current_line(62, ng0);
    t29 = (t0 + 1512U);
    t31 = *((char **)t29);
    t29 = (t0 + 42143);
    t16 = *((int *)t29);
    t17 = (t16 - 1023);
    t25 = (t17 * -1);
    t26 = (32U * t25);
    t27 = (0U + t26);
    t32 = (t0 + 5824);
    t43 = (t32 + 56U);
    t44 = *((char **)t43);
    t45 = (t44 + 56U);
    t46 = *((char **)t45);
    memcpy(t46, t31, 32U);
    xsi_driver_first_trans_delta(t32, t27, 32U, 0LL);
    goto LAB32;

}

static void work_a_4122551599_3212880686_p_1(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    unsigned char t11;
    unsigned char t12;
    char *t13;
    char *t14;
    unsigned char t15;

LAB0:    xsi_set_current_line(79, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB2;

LAB4:    t1 = (t0 + 1152U);
    t4 = xsi_signal_has_event(t1);
    if (t4 == 1)
        goto LAB7;

LAB8:    t3 = (unsigned char)0;

LAB9:    if (t3 != 0)
        goto LAB5;

LAB6:
LAB3:    t1 = (t0 + 5712);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(80, ng0);
    t1 = (t0 + 5952);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((unsigned char *)t8) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(81, ng0);
    t1 = (t0 + 6016);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(82, ng0);
    t1 = (t0 + 6080);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);
    goto LAB3;

LAB5:    xsi_set_current_line(85, ng0);
    t2 = (t0 + 1832U);
    t6 = *((char **)t2);
    t11 = *((unsigned char *)t6);
    t12 = (t11 == (unsigned char)2);
    if (t12 != 0)
        goto LAB10;

LAB12:    xsi_set_current_line(89, ng0);
    t1 = (t0 + 5952);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(90, ng0);
    t1 = (t0 + 6016);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);

LAB11:    xsi_set_current_line(94, ng0);
    t1 = (t0 + 1832U);
    t2 = *((char **)t1);
    t4 = *((unsigned char *)t2);
    t9 = (t4 == (unsigned char)2);
    if (t9 == 1)
        goto LAB16;

LAB17:    t3 = (unsigned char)0;

LAB18:    if (t3 != 0)
        goto LAB13;

LAB15:    t1 = (t0 + 1832U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB19;

LAB20:
LAB14:    goto LAB3;

LAB7:    t2 = (t0 + 1192U);
    t5 = *((char **)t2);
    t9 = *((unsigned char *)t5);
    t10 = (t9 == (unsigned char)3);
    t3 = t10;
    goto LAB9;

LAB10:    xsi_set_current_line(86, ng0);
    t2 = (t0 + 5952);
    t7 = (t2 + 56U);
    t8 = *((char **)t7);
    t13 = (t8 + 56U);
    t14 = *((char **)t13);
    *((unsigned char *)t14) = (unsigned char)3;
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(87, ng0);
    t1 = (t0 + 2632U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t1 = (t0 + 6016);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((unsigned char *)t8) = t3;
    xsi_driver_first_trans_fast(t1);
    goto LAB11;

LAB13:    xsi_set_current_line(95, ng0);
    t1 = (t0 + 2952U);
    t6 = *((char **)t1);
    t12 = *((unsigned char *)t6);
    t15 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t12);
    t1 = (t0 + 6080);
    t7 = (t1 + 56U);
    t8 = *((char **)t7);
    t13 = (t8 + 56U);
    t14 = *((char **)t13);
    *((unsigned char *)t14) = t15;
    xsi_driver_first_trans_fast(t1);
    goto LAB14;

LAB16:    t1 = (t0 + 2792U);
    t5 = *((char **)t1);
    t10 = *((unsigned char *)t5);
    t11 = (t10 == (unsigned char)3);
    t3 = t11;
    goto LAB18;

LAB19:    xsi_set_current_line(97, ng0);
    t1 = (t0 + 6080);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((unsigned char *)t8) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);
    goto LAB14;

}

static void work_a_4122551599_3212880686_p_2(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;

LAB0:    xsi_set_current_line(104, ng0);

LAB3:    t1 = (t0 + 2952U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t1 = (t0 + 6144);
    t4 = (t1 + 56U);
    t5 = *((char **)t4);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = t3;
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t8 = (t0 + 5728);
    *((int *)t8) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_4122551599_3212880686_p_3(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t5;
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

LAB0:    xsi_set_current_line(105, ng0);
    t1 = (t0 + 2952U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB3;

LAB4:
LAB5:    t10 = (t0 + 42151);
    t12 = (t0 + 6208);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memcpy(t16, t10, 32U);
    xsi_driver_first_trans_fast_port(t12);

LAB2:    t17 = (t0 + 5744);
    *((int *)t17) = 1;

LAB1:    return;
LAB3:    t1 = (t0 + 3112U);
    t5 = *((char **)t1);
    t1 = (t0 + 6208);
    t6 = (t1 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t5, 32U);
    xsi_driver_first_trans_fast_port(t1);
    goto LAB2;

LAB6:    goto LAB2;

}


extern void work_a_4122551599_3212880686_init()
{
	static char *pe[] = {(void *)work_a_4122551599_3212880686_p_0,(void *)work_a_4122551599_3212880686_p_1,(void *)work_a_4122551599_3212880686_p_2,(void *)work_a_4122551599_3212880686_p_3};
	xsi_register_didat("work_a_4122551599_3212880686", "isim/SIMUL_T_isim_beh.exe.sim/work/a_4122551599_3212880686.didat");
	xsi_register_executes(pe);
}
