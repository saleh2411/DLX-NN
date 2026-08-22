--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : ADD16.vhf
-- /___/   /\     Timestamp : 07/18/2026 23:37:52
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -intstyle ise -family spartan6 -flat -suppress -vhdl C:/Users/administrator.CLS-210-PC/Desktop/saed/saleh/Week7/HOME_VER_before_edit/ADD16.vhf -w C:/Users/administrator.CLS-210-PC/Desktop/saed/saleh/Week7/HOME_VER_before_edit/ADD16.sch
--Design Name: ADD16
--Device: spartan6
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--
----- CELL ADSU16_HXILINX_ADD16 -----
  
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ADSU16_HXILINX_ADD16 is
port(
    CO   : out std_logic;
    OFL  : out std_logic;
    S    : out std_logic_vector(15 downto 0);

    A    : in std_logic_vector(15 downto 0);
    ADD  : in std_logic;
    B    : in std_logic_vector(15 downto 0);
    CI   : in std_logic
  );
end ADSU16_HXILINX_ADD16;

architecture ADSU16_HXILINX_ADD16_V of ADSU16_HXILINX_ADD16 is

begin
  adsu_p : process (A, ADD, B, CI)
    variable adsu_tmp : std_logic_vector(16 downto 0);
  begin
    if(ADD = '1') then
     adsu_tmp := conv_std_logic_vector((conv_integer(A) + conv_integer(B) + conv_integer(CI)),17);
    else
     adsu_tmp := conv_std_logic_vector((conv_integer(A) - conv_integer(not CI) - conv_integer(B)),17);
  end if;
      
  S   <= adsu_tmp(15 downto 0);
   
  if (ADD='1') then
    CO <= adsu_tmp(16);
    OFL <=  ( A(15) and B(15) and (not adsu_tmp(15)) ) or ( (not A(15)) and (not B(15)) and adsu_tmp(15) );  
  else
    CO <= not adsu_tmp(16);
    OFL <=  ( A(15) and (not B(15)) and (not adsu_tmp(15)) ) or ( (not A(15)) and B(15) and adsu_tmp(15) );  
  end if;
 
  end process;
  
end ADSU16_HXILINX_ADD16_V;

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity ADD16 is
   port ( A   : in    std_logic_vector (15 downto 0); 
          ADD : in    std_logic; 
          B   : in    std_logic_vector (15 downto 0); 
          ci  : in    std_logic; 
          CO  : out   std_logic; 
          OFL : out   std_logic; 
          S   : out   std_logic_vector (15 downto 0));
end ADD16;

architecture BEHAVIORAL of ADD16 is
   attribute HU_SET     : string ;
   component ADSU16_HXILINX_ADD16
      port ( A   : in    std_logic_vector (15 downto 0); 
             ADD : in    std_logic; 
             B   : in    std_logic_vector (15 downto 0); 
             CI  : in    std_logic; 
             CO  : out   std_logic; 
             OFL : out   std_logic; 
             S   : out   std_logic_vector (15 downto 0));
   end component;
   
   attribute HU_SET of XLXI_1 : label is "XLXI_1_0";
begin
   XLXI_1 : ADSU16_HXILINX_ADD16
      port map (A(15 downto 0)=>A(15 downto 0),
                ADD=>ADD,
                B(15 downto 0)=>B(15 downto 0),
                CI=>ci,
                CO=>CO,
                OFL=>OFL,
                S(15 downto 0)=>S(15 downto 0));
   
end BEHAVIORAL;


