--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : ex_top_sch.vhf
-- /___/   /\     Timestamp : 03/18/2025 10:57:42
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -intstyle ise -family spartan6 -flat -suppress -vhdl E:/adlx/EXAMPLES_25b/HOME_VER/ex_top_sch.vhf -w E:/adlx/EXAMPLES_25b/HOME_VER/ex_top_sch.sch
--Design Name: ex_top_sch
--Device: spartan6
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity ex_top_sch is
   port ( buf_en1      : in    std_logic; 
          buf_en2      : in    std_logic; 
          ce_reg1      : in    std_logic; 
          ce_reg2      : in    std_logic; 
          clock        : in    std_logic; 
          data_in1     : in    std_logic_vector (15 downto 0); 
          data_in2     : in    std_logic_vector (15 downto 0); 
          mux_sel      : in    std_logic; 
          reset        : in    std_logic; 
          data_mux_out : out   std_logic_vector (15 downto 0); 
          data_buf_out : inout std_logic_vector (15 downto 0));
end ex_top_sch;

architecture BEHAVIORAL of ex_top_sch is
   signal data_out1    : std_logic_vector (15 downto 0);
   signal data_out2    : std_logic_vector (15 downto 0);
   component ex_reg_ver
      port ( reset    : in    std_logic; 
             clock    : in    std_logic; 
             ce_reg   : in    std_logic; 
             data_in  : in    std_logic_vector (15 downto 0); 
             data_out : out   std_logic_vector (15 downto 0));
   end component;
   
   component ex_mux_ver
      port ( mux_sel  : in    std_logic; 
             mux_in_a : in    std_logic_vector (15 downto 0); 
             mux_in_b : in    std_logic_vector (15 downto 0); 
             mux_out  : out   std_logic_vector (15 downto 0));
   end component;
   
   component ex_buf_ver
      port ( buf_en  : in    std_logic; 
             buf_in  : in    std_logic_vector (15 downto 0); 
             buf_out : inout std_logic_vector (15 downto 0));
   end component;
   
begin
   XLXI_1 : ex_reg_ver
      port map (ce_reg=>ce_reg1,
                clock=>clock,
                data_in(15 downto 0)=>data_in1(15 downto 0),
                reset=>reset,
                data_out(15 downto 0)=>data_out1(15 downto 0));
   
   XLXI_2 : ex_reg_ver
      port map (ce_reg=>ce_reg2,
                clock=>clock,
                data_in(15 downto 0)=>data_in2(15 downto 0),
                reset=>reset,
                data_out(15 downto 0)=>data_out2(15 downto 0));
   
   XLXI_3 : ex_mux_ver
      port map (mux_in_a(15 downto 0)=>data_out1(15 downto 0),
                mux_in_b(15 downto 0)=>data_out2(15 downto 0),
                mux_sel=>mux_sel,
                mux_out(15 downto 0)=>data_mux_out(15 downto 0));
   
   XLXI_4 : ex_buf_ver
      port map (buf_en=>buf_en1,
                buf_in(15 downto 0)=>data_out1(15 downto 0),
                buf_out(15 downto 0)=>data_buf_out(15 downto 0));
   
   XLXI_5 : ex_buf_ver
      port map (buf_en=>buf_en2,
                buf_in(15 downto 0)=>data_out2(15 downto 0),
                buf_out(15 downto 0)=>data_buf_out(15 downto 0));
   
end BEHAVIORAL;


