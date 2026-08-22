--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : Top_Level.vhf
-- /___/   /\     Timestamp : 06/27/2026 12:01:08
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -intstyle ise -family spartan6 -flat -suppress -vhdl C:/Users/administrator.CLS-210-PC/Desktop/saed/final_simple_DLX/Week7/SOURCE_VER_before_edit/Top_Level.vhf -w C:/Users/administrator.CLS-210-PC/Desktop/saed/final_simple_DLX/Week7/SOURCE_VER_before_edit/Top_Level.sch
--Design Name: Top_Level
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

entity Top_Level is
   port ( fpgaClk_i : in    std_logic; 
          sdClkFb_i : in    std_logic; 
          sdAddr_o  : out   std_logic_vector (12 downto 0); 
          sdBs_o    : out   std_logic_vector (1 downto 0); 
          sdCas_bo  : out   std_logic; 
          sdCe_bo   : out   std_logic; 
          sdCke_o   : out   std_logic; 
          sdClk_o   : out   std_logic; 
          sdDqmh_o  : out   std_logic; 
          sdDqml_o  : out   std_logic; 
          sdRas_bo  : out   std_logic; 
          sdWe_bo   : out   std_logic; 
          sdData_io : inout std_logic_vector (15 downto 0));
end Top_Level;

architecture BEHAVIORAL of Top_Level is
   attribute BOX_TYPE   : string ;
   signal ACK_N     : std_logic;
   signal AI        : std_logic_vector (9 downto 0);
   signal AS_N      : std_logic;
   signal Card_Sel  : std_logic;
   signal CLK       : std_logic;
   signal DO        : std_logic_vector (31 downto 0);
   signal D_IN      : std_logic_vector (31 downto 0);
   signal D_RAM_OUT : std_logic_vector (31 downto 0);
   signal IN_INIT   : std_logic;
   signal MAO       : std_logic_vector (31 downto 0);
   signal MDO       : std_logic_vector (31 downto 0);
   signal RACK_N    : std_logic;
   signal reg_addr  : std_logic_vector (4 downto 0);
   signal RESET     : std_logic;
   signal Rsel      : std_logic;
   signal R_DO      : std_logic_vector (31 downto 0);
   signal SACK_N    : std_logic;
   signal SDO       : std_logic_vector (31 downto 0);
   signal STEP_EN   : std_logic;
   signal STOP_N    : std_logic;
   signal WR_IN_N   : std_logic;
   signal WR_OUT_N  : std_logic;
   signal XLXN_1    : std_logic;
   signal XLXN_2    : std_logic;
   signal XLXN_76   : std_logic;
   signal XLXN_77   : std_logic;
   component IO_LOGIC_U
      port ( AS_N_i    : in    std_logic; 
             fpgaClk_i : in    std_logic; 
             in_init_i : in    std_logic; 
             RACK_N_i  : in    std_logic; 
             SACK_N_i  : in    std_logic; 
             sdClkFb_i : in    std_logic; 
             WR_N_i    : in    std_logic; 
             MA_i      : in    std_logic_vector (31 downto 0); 
             MD_i      : in    std_logic_vector (31 downto 0); 
             RD_i      : in    std_logic_vector (31 downto 0); 
             SD_i      : in    std_logic_vector (31 downto 0); 
             CLK       : out   std_logic; 
             MACK_N_o  : out   std_logic; 
             RESET     : out   std_logic; 
             Rsel_o    : out   std_logic; 
             sdCas_bo  : out   std_logic; 
             sdCe_bo   : out   std_logic; 
             sdCke_o   : out   std_logic; 
             sdClk_o   : out   std_logic; 
             sdDqmh_o  : out   std_logic; 
             sdDqml_o  : out   std_logic; 
             sdRas_bo  : out   std_logic; 
             sdWe_bo   : out   std_logic; 
             Ssel_o    : out   std_logic; 
             step_en_o : out   std_logic; 
             WR_N_o    : out   std_logic; 
             A_o       : out   std_logic_vector (9 downto 0); 
             DO        : out   std_logic_vector (31 downto 0); 
             sdAddr_o  : out   std_logic_vector (12 downto 0); 
             sdBs_o    : out   std_logic_vector (1 downto 0); 
             sdData_io : inout std_logic_vector (15 downto 0));
   end component;
   
   component monitor_salve
      port ( clk      : in    std_logic; 
             in_init  : in    std_logic; 
             step_en  : in    std_logic; 
             stop_n   : in    std_logic; 
             CARD_SEL : in    std_logic; 
             WR_IN_N  : in    std_logic; 
             AI       : in    std_logic_vector (9 downto 0); 
             D_IN     : in    std_logic_vector (31 downto 0); 
             A_IN     : in    std_logic_vector (31 downto 0); 
             B_IN     : in    std_logic_vector (31 downto 0); 
             SACK_N   : out   std_logic; 
             SDO      : out   std_logic_vector (31 downto 0); 
             REG_ADDR : out   std_logic_vector (4 downto 0));
   end component;
   
   component FD
      generic( INIT : bit :=  '0');
      port ( C : in    std_logic; 
             D : in    std_logic; 
             Q : out   std_logic);
   end component;
   attribute BOX_TYPE of FD : component is "BLACK_BOX";
   
   component OR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of OR2 : component is "BLACK_BOX";
   
   component OR2B1
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of OR2B1 : component is "BLACK_BOX";
   
   component DLX
      port ( clk           : in    std_logic; 
             reset         : in    std_logic; 
             step_en       : in    std_logic; 
             ack_n         : in    std_logic; 
             D_in          : in    std_logic_vector (31 downto 0); 
             Daddr         : in    std_logic_vector (4 downto 0); 
             busy          : out   std_logic; 
             MR            : out   std_logic; 
             MW            : out   std_logic; 
             GPR_WE        : out   std_logic; 
             IRCE          : out   std_logic; 
             PCCE          : out   std_logic; 
             ACE           : out   std_logic; 
             BCE           : out   std_logic; 
             CCE           : out   std_logic; 
             MDRCE         : out   std_logic; 
             DINTSEL       : out   std_logic; 
             MDRSEL        : out   std_logic; 
             ASEL          : out   std_logic; 
             ADD           : out   std_logic; 
             TEST          : out   std_logic; 
             SHIFT         : out   std_logic; 
             ITYPE         : out   std_logic; 
             JLINK         : out   std_logic; 
             MARCE         : out   std_logic; 
             RIGHT         : out   std_logic; 
             in_init       : out   std_logic; 
             mac_state     : out   std_logic_vector (1 downto 0); 
             control_state : out   std_logic_vector (4 downto 0); 
             S1SEL         : out   std_logic_vector (1 downto 0); 
             S2SEL         : out   std_logic_vector (1 downto 0); 
             D_OUT_GPR     : out   std_logic_vector (31 downto 0); 
             wr_n_new      : out   std_logic; 
             as_n_new      : out   std_logic; 
             AO_new        : out   std_logic_vector (31 downto 0); 
             DO_new        : out   std_logic_vector (31 downto 0));
   end component;
   
   component BUF
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
   attribute BOX_TYPE of BUF : component is "BLACK_BOX";
   
begin
   XLXI_23 : IO_LOGIC_U
      port map (AS_N_i=>AS_N,
                fpgaClk_i=>fpgaClk_i,
                in_init_i=>IN_INIT,
                MA_i(31 downto 0)=>MAO(31 downto 0),
                MD_i(31 downto 0)=>MDO(31 downto 0),
                RACK_N_i=>RACK_N,
                RD_i(31 downto 0)=>R_DO(31 downto 0),
                SACK_N_i=>SACK_N,
                sdClkFb_i=>sdClkFb_i,
                SD_i(31 downto 0)=>SDO(31 downto 0),
                WR_N_i=>WR_OUT_N,
                A_o(9 downto 0)=>AI(9 downto 0),
                CLK=>CLK,
                DO(31 downto 0)=>DO(31 downto 0),
                MACK_N_o=>ACK_N,
                RESET=>RESET,
                Rsel_o=>Rsel,
                sdAddr_o(12 downto 0)=>sdAddr_o(12 downto 0),
                sdBs_o(1 downto 0)=>sdBs_o(1 downto 0),
                sdCas_bo=>sdCas_bo,
                sdCe_bo=>sdCe_bo,
                sdCke_o=>sdCke_o,
                sdClk_o=>sdClk_o,
                sdDqmh_o=>sdDqmh_o,
                sdDqml_o=>sdDqml_o,
                sdRas_bo=>sdRas_bo,
                sdWe_bo=>sdWe_bo,
                Ssel_o=>Card_Sel,
                step_en_o=>STEP_EN,
                WR_N_o=>WR_IN_N,
                sdData_io(15 downto 0)=>sdData_io(15 downto 0));
   
   XLXI_30 : monitor_salve
      port map (AI(9 downto 0)=>AI(9 downto 0),
                A_IN(31 downto 0)=>D_RAM_OUT(31 downto 0),
                B_IN(31 downto 0)=>MAO(31 downto 0),
                CARD_SEL=>Card_Sel,
                clk=>CLK,
                D_IN(31 downto 0)=>D_IN(31 downto 0),
                in_init=>IN_INIT,
                step_en=>STEP_EN,
                stop_n=>STOP_N,
                WR_IN_N=>WR_IN_N,
                REG_ADDR(4 downto 0)=>reg_addr(4 downto 0),
                SACK_N=>SACK_N,
                SDO(31 downto 0)=>SDO(31 downto 0));
   
   XLXI_46 : FD
      port map (C=>CLK,
                D=>AS_N,
                Q=>XLXN_1);
   
   XLXI_47 : OR2
      port map (I0=>XLXN_1,
                I1=>AS_N,
                O=>XLXN_2);
   
   XLXI_48 : OR2B1
      port map (I0=>ACK_N,
                I1=>XLXN_2,
                O=>STOP_N);
   
   XLXI_50 : DLX
      port map (ack_n=>ACK_N,
                clk=>CLK,
                Daddr(4 downto 0)=>reg_addr(4 downto 0),
                D_in(31 downto 0)=>DO(31 downto 0),
                reset=>RESET,
                step_en=>STEP_EN,
                ACE=>D_IN(6),
                ADD=>D_IN(13),
                AO_new(31 downto 0)=>MAO(31 downto 0),
                ASEL=>D_IN(12),
                as_n_new=>AS_N,
                BCE=>D_IN(7),
                busy=>D_IN(0),
                CCE=>D_IN(8),
                control_state(4 downto 0)=>D_IN(29 downto 25),
                DINTSEL=>D_IN(10),
                DO_new(31 downto 0)=>MDO(31 downto 0),
                D_OUT_GPR(31 downto 0)=>D_RAM_OUT(31 downto 0),
                GPR_WE=>D_IN(3),
                in_init=>IN_INIT,
                IRCE=>D_IN(4),
                ITYPE=>D_IN(19),
                JLINK=>D_IN(16),
                mac_state(1 downto 0)=>D_IN(24 downto 23),
                MARCE=>D_IN(17),
                MDRCE=>D_IN(9),
                MDRSEL=>D_IN(11),
                MR=>XLXN_76,
                MW=>XLXN_77,
                PCCE=>D_IN(5),
                RIGHT=>D_IN(18),
                SHIFT=>D_IN(15),
                S1SEL(1 downto 0)=>D_IN(31 downto 30),
                S2SEL(1 downto 0)=>D_IN(2 downto 1),
                TEST=>D_IN(14),
                wr_n_new=>WR_OUT_N);
   
   XLXI_51 : BUF
      port map (I=>AS_N,
                O=>D_IN(20));
   
   XLXI_52 : BUF
      port map (I=>WR_OUT_N,
                O=>D_IN(21));
   
   XLXI_53 : BUF
      port map (I=>IN_INIT,
                O=>D_IN(22));
   
end BEHAVIORAL;


