--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : master_ver.vhf
-- /___/   /\     Timestamp : 12/06/2025 12:49:02
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -intstyle ise -family spartan6 -flat -suppress -vhdl E:/adlx/B1/WEEK_4/SOURCE_VER/master_ver.vhf -w E:/adlx/B1/WEEK_4/SOURCE_VER/master_ver.sch
--Design Name: master_ver
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

entity master_ver is
   port ( CLK       : in    std_logic; 
          reg_adr   : in    std_logic_vector (4 downto 0); 
          RESET     : in    std_logic; 
          STEP_EN   : in    std_logic; 
          in_init   : out   std_logic; 
          reg_out   : out   std_logic_vector (31 downto 0); 
          reg_write : out   std_logic_vector (4 downto 0); 
          state     : out   std_logic_vector (3 downto 0); 
          step_num  : out   std_logic_vector (4 downto 0));
end master_ver;

architecture BEHAVIORAL of master_ver is
   attribute BOX_TYPE   : string ;
   signal Data        : std_logic_vector (4 downto 0);
   signal wide        : std_logic_vector (31 downto 0);
   signal XLXN_9      : std_logic;
   signal state_DUMMY : std_logic_vector (3 downto 0);
   component BROJA
      port ( clk     : in    std_logic; 
             step    : in    std_logic; 
             reset   : in    std_logic; 
             in_init : out   std_logic; 
             cnt     : out   std_logic_vector (31 downto 0); 
             state   : out   std_logic_vector (3 downto 0));
   end component;
   
   component INV
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
   attribute BOX_TYPE of INV : component is "BLACK_BOX";
   
   component RAM32x32
      port ( CLK  : in    std_logic; 
             WE   : in    std_logic; 
             ADDR : in    std_logic_vector (4 downto 0); 
             DI   : in    std_logic_vector (31 downto 0); 
             DO   : out   std_logic_vector (31 downto 0));
   end component;
   
   component Step_CNT5
      port ( CLK : in    std_logic; 
             RST : in    std_logic; 
             CE  : in    std_logic; 
             CNT : out   std_logic_vector (4 downto 0));
   end component;
   
   component MUX5bit
      port ( sel : in    std_logic; 
             A   : in    std_logic_vector (4 downto 0); 
             B   : in    std_logic_vector (4 downto 0); 
             O   : out   std_logic_vector (4 downto 0));
   end component;
   
   component BUF5
      port ( I : in    std_logic_vector (4 downto 0); 
             O : out   std_logic_vector (4 downto 0));
   end component;
   
begin
   state(3 downto 0) <= state_DUMMY(3 downto 0);
   XLXI_1 : BROJA
      port map (clk=>CLK,
                reset=>RESET,
                step=>STEP_EN,
                cnt(31 downto 0)=>wide(31 downto 0),
                in_init=>in_init,
                state(3 downto 0)=>state_DUMMY(3 downto 0));
   
   XLXI_2 : INV
      port map (I=>state_DUMMY(3),
                O=>XLXN_9);
   
   XLXI_9 : RAM32x32
      port map (ADDR(4 downto 0)=>Data(4 downto 0),
                CLK=>CLK,
                DI(31 downto 0)=>wide(31 downto 0),
                WE=>XLXN_9,
                DO(31 downto 0)=>reg_out(31 downto 0));
   
   XLXI_10 : Step_CNT5
      port map (CE=>STEP_EN,
                CLK=>CLK,
                RST=>RESET,
                CNT(4 downto 0)=>step_num(4 downto 0));
   
   XLXI_12 : MUX5bit
      port map (A(4 downto 0)=>wide(4 downto 0),
                B(4 downto 0)=>reg_adr(4 downto 0),
                sel=>state_DUMMY(3),
                O(4 downto 0)=>Data(4 downto 0));
   
   XLXI_13 : BUF5
      port map (I(4 downto 0)=>wide(4 downto 0),
                O(4 downto 0)=>reg_write(4 downto 0));
   
end BEHAVIORAL;


