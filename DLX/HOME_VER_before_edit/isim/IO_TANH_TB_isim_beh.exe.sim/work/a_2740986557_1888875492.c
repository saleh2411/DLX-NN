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
static const char *ng0 = "C:/Users/administrator.CLS-210-PC/Desktop/saed/saleh/Week7/HOME_VER_before_edit/ADD16.vhf";
extern char *IEEE_P_3499444699;
extern char *IEEE_P_3620187407;
extern char *IEEE_P_2592010699;

unsigned char ieee_p_2592010699_sub_1605435078_503743352(char *, unsigned char , unsigned char );
unsigned char ieee_p_2592010699_sub_1690584930_503743352(char *, unsigned char );
unsigned char ieee_p_2592010699_sub_2545490612_503743352(char *, unsigned char , unsigned char );
char *ieee_p_3499444699_sub_2213602152_3536714472(char *, char *, int , int );
int ieee_p_3620187407_sub_514432868_3965413181(char *, char *, char *);


static void work_a_2740986557_1888875492_p_0(char *t0)
{
    char t5[16];
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t6;
    int t7;
    char *t8;
    char *t9;
    int t10;
    int t11;
    char *t12;
    char *t13;
    unsigned char t14;
    int t15;
    int t16;
    char *t17;
    char *t18;
    char *t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned char t29;
    unsigned char t30;
    unsigned char t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned char t35;
    unsigned char t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    unsigned char t40;
    unsigned char t41;
    unsigned char t42;
    char *t43;
    char *t44;
    int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned char t49;
    unsigned char t50;
    unsigned char t51;
    char *t52;
    char *t53;
    char *t54;
    char *t55;
    char *t56;

LAB0:    xsi_set_current_line(47, ng0);
    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(50, ng0);
    t1 = (t0 + 1512U);
    t2 = *((char **)t1);
    t1 = (t0 + 6188U);
    t7 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t2, t1);
    t6 = (t0 + 1992U);
    t8 = *((char **)t6);
    t3 = *((unsigned char *)t8);
    t4 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t3);
    t10 = ieee_std_logic_arith_conv_integer_ulogic(IEEE_P_3499444699, t4);
    t11 = (t7 - t10);
    t6 = (t0 + 1832U);
    t9 = *((char **)t6);
    t6 = (t0 + 6204U);
    t15 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t9, t6);
    t16 = (t11 - t15);
    t12 = ieee_p_3499444699_sub_2213602152_3536714472(IEEE_P_3499444699, t5, t16, 17);
    t13 = (t0 + 2288U);
    t17 = *((char **)t13);
    t13 = (t17 + 0);
    t18 = (t5 + 12U);
    t20 = *((unsigned int *)t18);
    t20 = (t20 * 1U);
    memcpy(t13, t12, t20);

LAB3:    xsi_set_current_line(53, ng0);
    t1 = (t0 + 2288U);
    t2 = *((char **)t1);
    t20 = (16 - 15);
    t21 = (t20 * 1U);
    t22 = (0 + t21);
    t1 = (t2 + t22);
    t6 = (t0 + 3672);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    t12 = (t9 + 56U);
    t13 = *((char **)t12);
    memcpy(t13, t1, 16U);
    xsi_driver_first_trans_fast_port(t6);
    xsi_set_current_line(55, ng0);
    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB5;

LAB7:    xsi_set_current_line(59, ng0);
    t1 = (t0 + 2288U);
    t2 = *((char **)t1);
    t7 = (16 - 16);
    t20 = (t7 * -1);
    t21 = (1U * t20);
    t22 = (0 + t21);
    t1 = (t2 + t22);
    t3 = *((unsigned char *)t1);
    t4 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t3);
    t6 = (t0 + 3736);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    t12 = (t9 + 56U);
    t13 = *((char **)t12);
    *((unsigned char *)t13) = t4;
    xsi_driver_first_trans_fast_port(t6);
    xsi_set_current_line(60, ng0);
    t1 = (t0 + 1512U);
    t2 = *((char **)t1);
    t7 = (15 - 15);
    t20 = (t7 * -1);
    t21 = (1U * t20);
    t22 = (0 + t21);
    t1 = (t2 + t22);
    t3 = *((unsigned char *)t1);
    t6 = (t0 + 1832U);
    t8 = *((char **)t6);
    t10 = (15 - 15);
    t23 = (t10 * -1);
    t24 = (1U * t23);
    t25 = (0 + t24);
    t6 = (t8 + t25);
    t4 = *((unsigned char *)t6);
    t14 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t4);
    t29 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t3, t14);
    t9 = (t0 + 2288U);
    t12 = *((char **)t9);
    t11 = (15 - 16);
    t26 = (t11 * -1);
    t27 = (1U * t26);
    t28 = (0 + t27);
    t9 = (t12 + t28);
    t30 = *((unsigned char *)t9);
    t31 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t30);
    t35 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t29, t31);
    t13 = (t0 + 1512U);
    t17 = *((char **)t13);
    t15 = (15 - 15);
    t32 = (t15 * -1);
    t33 = (1U * t32);
    t34 = (0 + t33);
    t13 = (t17 + t34);
    t36 = *((unsigned char *)t13);
    t40 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t36);
    t18 = (t0 + 1832U);
    t19 = *((char **)t18);
    t16 = (15 - 15);
    t37 = (t16 * -1);
    t38 = (1U * t37);
    t39 = (0 + t38);
    t18 = (t19 + t39);
    t41 = *((unsigned char *)t18);
    t42 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t40, t41);
    t43 = (t0 + 2288U);
    t44 = *((char **)t43);
    t45 = (15 - 16);
    t46 = (t45 * -1);
    t47 = (1U * t46);
    t48 = (0 + t47);
    t43 = (t44 + t48);
    t49 = *((unsigned char *)t43);
    t50 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t42, t49);
    t51 = ieee_p_2592010699_sub_2545490612_503743352(IEEE_P_2592010699, t35, t50);
    t52 = (t0 + 3800);
    t53 = (t52 + 56U);
    t54 = *((char **)t53);
    t55 = (t54 + 56U);
    t56 = *((char **)t55);
    *((unsigned char *)t56) = t51;
    xsi_driver_first_trans_fast_port(t52);

LAB6:    t1 = (t0 + 3592);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(48, ng0);
    t1 = (t0 + 1512U);
    t6 = *((char **)t1);
    t1 = (t0 + 6188U);
    t7 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t6, t1);
    t8 = (t0 + 1832U);
    t9 = *((char **)t8);
    t8 = (t0 + 6204U);
    t10 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t9, t8);
    t11 = (t7 + t10);
    t12 = (t0 + 1992U);
    t13 = *((char **)t12);
    t14 = *((unsigned char *)t13);
    t15 = ieee_std_logic_arith_conv_integer_ulogic(IEEE_P_3499444699, t14);
    t16 = (t11 + t15);
    t12 = ieee_p_3499444699_sub_2213602152_3536714472(IEEE_P_3499444699, t5, t16, 17);
    t17 = (t0 + 2288U);
    t18 = *((char **)t17);
    t17 = (t18 + 0);
    t19 = (t5 + 12U);
    t20 = *((unsigned int *)t19);
    t20 = (t20 * 1U);
    memcpy(t17, t12, t20);
    goto LAB3;

LAB5:    xsi_set_current_line(56, ng0);
    t1 = (t0 + 2288U);
    t6 = *((char **)t1);
    t7 = (16 - 16);
    t20 = (t7 * -1);
    t21 = (1U * t20);
    t22 = (0 + t21);
    t1 = (t6 + t22);
    t14 = *((unsigned char *)t1);
    t8 = (t0 + 3736);
    t9 = (t8 + 56U);
    t12 = *((char **)t9);
    t13 = (t12 + 56U);
    t17 = *((char **)t13);
    *((unsigned char *)t17) = t14;
    xsi_driver_first_trans_fast_port(t8);
    xsi_set_current_line(57, ng0);
    t1 = (t0 + 1512U);
    t2 = *((char **)t1);
    t7 = (15 - 15);
    t20 = (t7 * -1);
    t21 = (1U * t20);
    t22 = (0 + t21);
    t1 = (t2 + t22);
    t3 = *((unsigned char *)t1);
    t6 = (t0 + 1832U);
    t8 = *((char **)t6);
    t10 = (15 - 15);
    t23 = (t10 * -1);
    t24 = (1U * t23);
    t25 = (0 + t24);
    t6 = (t8 + t25);
    t4 = *((unsigned char *)t6);
    t14 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t3, t4);
    t9 = (t0 + 2288U);
    t12 = *((char **)t9);
    t11 = (15 - 16);
    t26 = (t11 * -1);
    t27 = (1U * t26);
    t28 = (0 + t27);
    t9 = (t12 + t28);
    t29 = *((unsigned char *)t9);
    t30 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t29);
    t31 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t14, t30);
    t13 = (t0 + 1512U);
    t17 = *((char **)t13);
    t15 = (15 - 15);
    t32 = (t15 * -1);
    t33 = (1U * t32);
    t34 = (0 + t33);
    t13 = (t17 + t34);
    t35 = *((unsigned char *)t13);
    t36 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t35);
    t18 = (t0 + 1832U);
    t19 = *((char **)t18);
    t16 = (15 - 15);
    t37 = (t16 * -1);
    t38 = (1U * t37);
    t39 = (0 + t38);
    t18 = (t19 + t39);
    t40 = *((unsigned char *)t18);
    t41 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t40);
    t42 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t36, t41);
    t43 = (t0 + 2288U);
    t44 = *((char **)t43);
    t45 = (15 - 16);
    t46 = (t45 * -1);
    t47 = (1U * t46);
    t48 = (0 + t47);
    t43 = (t44 + t48);
    t49 = *((unsigned char *)t43);
    t50 = ieee_p_2592010699_sub_1605435078_503743352(IEEE_P_2592010699, t42, t49);
    t51 = ieee_p_2592010699_sub_2545490612_503743352(IEEE_P_2592010699, t31, t50);
    t52 = (t0 + 3800);
    t53 = (t52 + 56U);
    t54 = *((char **)t53);
    t55 = (t54 + 56U);
    t56 = *((char **)t55);
    *((unsigned char *)t56) = t51;
    xsi_driver_first_trans_fast_port(t52);
    goto LAB6;

}


extern void work_a_2740986557_1888875492_init()
{
	static char *pe[] = {(void *)work_a_2740986557_1888875492_p_0};
	xsi_register_didat("work_a_2740986557_1888875492", "isim/IO_TANH_TB_isim_beh.exe.sim/work/a_2740986557_1888875492.didat");
	xsi_register_executes(pe);
}
