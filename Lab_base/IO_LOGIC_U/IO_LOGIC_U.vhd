--------------------------------------------------------------------------------
-- Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 13.4
--  \   \         Application : sch2hdl
--  /   /         Filename : IO_LOGIC_U.vhf
-- /___/   /\     Timestamp : 05/22/2014 15:02:40
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: D:\Xilinx_13.4\ISE_DS\ISE\bin\nt\unwrapped\sch2hdl.exe -intstyle ise -family spartan6 -flat -suppress -vhdl IO_LOGIC_U.vhf -w D:/Study/Project/Test/Memory_test_60MHZ_12_5_wo_sch/Memory_test_12_5/IO_LOGIC_U.sch
--Design Name: mem_test
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

entity Sync_U is
   port ( clk_i      : in    std_logic; 
          ctrlInR_i  : in    std_logic; 
          ctrlInW_i  : in    std_logic; 
          doneIn_i   : in    std_logic; 
          drck_i     : in    std_logic; 
          opBegun_i  : in    std_logic; 
          ctrlOutR_o : out   std_logic; 
          ctrlOutW_o : out   std_logic; 
          done_o     : out   std_logic);
end Sync_U;

architecture BEHAVIORAL of Sync_U is
   attribute BOX_TYPE   : string ;
   signal doneOut_o0 : std_logic;
   signal doneOut_o1 : std_logic;
   component RamCtrlSync
      port ( drck_i    : in    std_logic; 
             clk_i     : in    std_logic; 
             ctrlIn_i  : in    std_logic; 
             opBegun_i : in    std_logic; 
             doneIn_i  : in    std_logic; 
             ctrlOut_o : out   std_logic; 
             doneOut_o : out   std_logic);
   end component;
   
   component OR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of OR2 : component is "BLACK_BOX";
   
begin
   u0 : RamCtrlSync
      port map (clk_i=>clk_i,
                ctrlIn_i=>ctrlInR_i,
                doneIn_i=>doneIn_i,
                drck_i=>drck_i,
                opBegun_i=>opBegun_i,
                ctrlOut_o=>ctrlOutR_o,
                doneOut_o=>doneOut_o0);
   
   u1 : RamCtrlSync
      port map (clk_i=>clk_i,
                ctrlIn_i=>ctrlInW_i,
                doneIn_i=>doneIn_i,
                drck_i=>drck_i,
                opBegun_i=>opBegun_i,
                ctrlOut_o=>ctrlOutW_o,
                doneOut_o=>doneOut_o1);
   
   u2 : OR2
      port map (I0=>doneOut_o1,
                I1=>doneOut_o0,
                O=>done_o);
   
end BEHAVIORAL;



library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity IO_LOGIC_U is
   port ( AS_N_i    : in    std_logic; 
          fpgaClk_i : in    std_logic; 
          in_init_i : in    std_logic; 
          MA_i      : in    std_logic_vector (31 downto 0); 
          MD_i      : in    std_logic_vector (31 downto 0); 
          RACK_N_i  : in    std_logic; 
          RD_i      : in    std_logic_vector (31 downto 0); 
          SACK_N_i  : in    std_logic; 
          sdClkFb_i : in    std_logic; 
          SD_i      : in    std_logic_vector (31 downto 0); 
          WR_N_i    : in    std_logic; 
          A_o       : out   std_logic_vector (9 downto 0); 
          CLK       : out   std_logic; 
          DO        : out   std_logic_vector (31 downto 0); 
          MACK_N_o  : out   std_logic; 
          RESET     : out   std_logic; 
          Rsel_o    : out   std_logic; 
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
          Ssel_o    : out   std_logic; 
          step_en_o : out   std_logic; 
          WR_N_o    : out   std_logic; 
          sdData_io : inout std_logic_vector (15 downto 0));
end IO_LOGIC_U;

architecture BEHAVIORAL of IO_LOGIC_U is
   signal Addr_mem     : std_logic_vector (20 downto 0);
   signal as_n_mem     : std_logic;
   signal Data         : std_logic_vector (39 downto 0);
   signal Data_i_mem   : std_logic_vector (31 downto 0);
   signal Data_o_mem   : std_logic_vector (31 downto 0);
   signal debug_sa     : std_logic_vector (2 downto 0);
   signal debug_sc     : std_logic_vector (3 downto 0);
   signal done         : std_logic;
   signal drck         : std_logic;
   signal earlyOpBegun : std_logic;
   signal hAddr        : std_logic_vector (23 downto 0);
   signal hDin         : std_logic_vector (15 downto 0);
   signal hDo          : std_logic_vector (15 downto 0);
   signal input_i      : std_logic_vector (39 downto 0);
   signal lock         : std_logic;
   signal opBegun      : std_logic;
   signal opBegun_i    : std_logic;
   signal rd           : std_logic;
   signal rdDone       : std_logic;
   signal rdPending    : std_logic;
   signal rd_i_s         : std_logic;
   signal Ready_clk    : std_logic;
   signal rst          : std_logic;
   signal sdram_done_i : std_logic;
   signal sdram_done_o : std_logic;
   signal wen_mem      : std_logic;
   signal wr           : std_logic;
   signal wr_i         : std_logic;
   signal RESET_DUMMY  : std_logic;
   signal CLK_DUMMY    : std_logic;
   component ClkGen_U
      port ( i            : in    std_logic; 
             o            : out   std_logic; 
             o_b          : out   std_logic; 
             clkToLogic_o : out   std_logic);
   end component;
   
   component HostIoToDut_U
      port ( vectorFromDut_i : in    std_logic_vector (39 downto 0); 
             clkToDut_o      : out   std_logic; 
             drck_o          : out   std_logic; 
             vectorToDut_o   : out   std_logic_vector (39 downto 0));
   end component;
   
   component Interface_Ctrl_U
      port ( clk_i        : in    std_logic; 
             Ready_clk_i  : in    std_logic; 
             done_i       : in    std_logic; 
             in_init_i    : in    std_logic; 
             WR_N_i       : in    std_logic; 
             AS_N_i       : in    std_logic; 
             SACK_N_i     : in    std_logic; 
             RACK_N_i     : in    std_logic; 
             input_i      : in    std_logic_vector (39 downto 0); 
             Data_i_mem   : in    std_logic_vector (31 downto 0); 
             MD_i         : in    std_logic_vector (31 downto 0); 
             MA_i         : in    std_logic_vector (31 downto 0); 
             SD_i         : in    std_logic_vector (31 downto 0); 
             RD_i         : in    std_logic_vector (31 downto 0); 
             debug_i_sa   : in    std_logic_vector (2 downto 0); 
             debug_i_sc   : in    std_logic_vector (3 downto 0); 
             as_n_mem     : out   std_logic; 
             wen_mem      : out   std_logic; 
             RESET        : out   std_logic; 
             step_en_o    : out   std_logic; 
             MACK_N_o     : out   std_logic; 
             Ssel_o       : out   std_logic; 
             WR_N_o       : out   std_logic; 
             Rsel_o       : out   std_logic; 
             Data_o_mem   : out   std_logic_vector (31 downto 0); 
             Addr_o_mem   : out   std_logic_vector (20 downto 0); 
             Data_o       : out   std_logic_vector (39 downto 0); 
             A_o          : out   std_logic_vector (9 downto 0); 
             DO           : out   std_logic_vector (31 downto 0); 
             curr_state_o : out   std_logic_vector (2 downto 0));
   end component;
   
   component sdram_adapter_U
      port ( bufclk         : in    std_logic; 
             opBegun        : in    std_logic; 
             XSA_done       : in    std_logic; 
             rdDone         : in    std_logic; 
             WEN            : in    std_logic; 
             AS_N           : in    std_logic; 
             RESET          : in    std_logic; 
             earlyOpBegun   : in    std_logic; 
             rdPending      : in    std_logic; 
             hDo            : in    std_logic_vector (15 downto 0); 
             ADDR           : in    std_logic_vector (20 downto 0); 
             DIN            : in    std_logic_vector (31 downto 0); 
             lock           : out   std_logic; 
             rst            : out   std_logic; 
             rd             : out   std_logic; 
             wr             : out   std_logic; 
             done           : out   std_logic; 
             CLK            : out   std_logic; 
             sdram_done     : out   std_logic; 
             hAddr          : out   std_logic_vector (23 downto 0); 
             hDin           : out   std_logic_vector (15 downto 0); 
             DO             : out   std_logic_vector (31 downto 0); 
             state          : out   std_logic_vector (2 downto 0); 
             earlyOpBegun_o : out   std_logic);
   end component;
   
   component Sync_U
      port ( clk_i      : in    std_logic; 
             ctrlInR_i  : in    std_logic; 
             ctrlInW_i  : in    std_logic; 
             doneIn_i   : in    std_logic; 
             drck_i     : in    std_logic; 
             opBegun_i  : in    std_logic; 
             done_o     : out   std_logic; 
             ctrlOutR_o : out   std_logic; 
             ctrlOutW_o : out   std_logic);
   end component;
   
   component SdramCntl_U
      port ( clk_i          : in    std_logic; 
             lock_i         : in    std_logic; 
             rst_i          : in    std_logic; 
             rd_i           : in    std_logic; 
             wr_i           : in    std_logic; 
             addr_i         : in    std_logic_vector (23 downto 0); 
             data_i         : in    std_logic_vector (15 downto 0); 
             sdData_io      : inout std_logic_vector (15 downto 0); 
             earlyOpBegun_o : out   std_logic; 
             opBegun_o      : out   std_logic; 
             rdPending_o    : out   std_logic; 
             done_o         : out   std_logic; 
             rdDone_o       : out   std_logic; 
             sdCke_o        : out   std_logic; 
             sdCe_bo        : out   std_logic; 
             sdRas_bo       : out   std_logic; 
             sdCas_bo       : out   std_logic; 
             sdWe_bo        : out   std_logic; 
             sdDqmh_o       : out   std_logic; 
             sdDqml_o       : out   std_logic; 
             data_o         : out   std_logic_vector (15 downto 0); 
             status_o       : out   std_logic_vector (3 downto 0); 
             sdBs_o         : out   std_logic_vector (1 downto 0); 
             sdAddr_o       : out   std_logic_vector (12 downto 0));
   end component;
   
begin
   CLK <= CLK_DUMMY;
   RESET <= RESET_DUMMY;
   u0 : ClkGen_U
      port map (i=>fpgaClk_i,
                clkToLogic_o=>sdClk_o,
                o=>open,
                o_b=>open);
   
   u1 : HostIoToDut_U
      port map (vectorFromDut_i(39 downto 0)=>Data(39 downto 0),
                clkToDut_o=>Ready_clk,
                drck_o=>drck,
                vectorToDut_o(39 downto 0)=>input_i(39 downto 0));
   
   u2 : Interface_Ctrl_U
      port map (AS_N_i=>AS_N_i,
                clk_i=>CLK_DUMMY,
                Data_i_mem(31 downto 0)=>Data_i_mem(31 downto 0),
                debug_i_sa(2 downto 0)=>debug_sa(2 downto 0),
                debug_i_sc(3 downto 0)=>debug_sc(3 downto 0),
                done_i=>done,
                input_i(39 downto 0)=>input_i(39 downto 0),
                in_init_i=>in_init_i,
                MA_i(31 downto 0)=>MA_i(31 downto 0),
                MD_i(31 downto 0)=>MD_i(31 downto 0),
                RACK_N_i=>RACK_N_i,
                RD_i(31 downto 0)=>RD_i(31 downto 0),
                Ready_clk_i=>Ready_clk,
                SACK_N_i=>SACK_N_i,
                SD_i(31 downto 0)=>SD_i(31 downto 0),
                WR_N_i=>WR_N_i,
                Addr_o_mem(20 downto 0)=>Addr_mem(20 downto 0),
                as_n_mem=>as_n_mem,
                A_o(9 downto 0)=>A_o(9 downto 0),
                curr_state_o=>open,
                Data_o(39 downto 0)=>Data(39 downto 0),
                Data_o_mem(31 downto 0)=>Data_o_mem(31 downto 0),
                DO(31 downto 0)=>DO(31 downto 0),
                MACK_N_o=>MACK_N_o,
                RESET=>RESET_DUMMY,
                Rsel_o=>Rsel_o,
                Ssel_o=>Ssel_o,
                step_en_o=>step_en_o,
                wen_mem=>wen_mem,
                WR_N_o=>WR_N_o);
   
   u3 : sdram_adapter_U
      port map (ADDR(20 downto 0)=>Addr_mem(20 downto 0),
                AS_N=>as_n_mem,
                bufclk=>sdClkFb_i,
                DIN(31 downto 0)=>Data_o_mem(31 downto 0),
                earlyOpBegun=>earlyOpBegun,
                hDo(15 downto 0)=>hDo(15 downto 0),
                opBegun=>opBegun,
                rdDone=>rdDone,
                rdPending=>rdPending,
                RESET=>RESET_DUMMY,
                WEN=>wen_mem,
                XSA_done=>sdram_done_o,
                CLK=>CLK_DUMMY,
                DO(31 downto 0)=>Data_i_mem(31 downto 0),
                done=>done,
                earlyOpBegun_o=>opBegun_i,
                hAddr(23 downto 0)=>hAddr(23 downto 0),
                hDin(15 downto 0)=>hDin(15 downto 0),
                lock=>lock,
                rd=>rd,
                rst=>rst,
                sdram_done=>open,
                state(2 downto 0)=>debug_sa(2 downto 0),
                wr=>wr);
   
   u4 : Sync_U
      port map (clk_i=>sdClkFb_i,
                ctrlInR_i=>rd,
                ctrlInW_i=>wr,
                doneIn_i=>sdram_done_i,
                drck_i=>drck,
                opBegun_i=>opBegun_i,
                ctrlOutR_o=>rd_i_s,
                ctrlOutW_o=>wr_i,
                done_o=>sdram_done_o);
   
   u5 : SdramCntl_U
      port map (addr_i(23 downto 0)=>hAddr(23 downto 0),
                clk_i=>sdClkFb_i,
                data_i(15 downto 0)=>hDin(15 downto 0),
                lock_i=>lock,
                rd_i=>rd_i_s,
                rst_i=>rst,
                wr_i=>wr_i,
                data_o(15 downto 0)=>hDo(15 downto 0),
                done_o=>sdram_done_i,
                earlyOpBegun_o=>earlyOpBegun,
                opBegun_o=>opBegun,
                rdDone_o=>rdDone,
                rdPending_o=>rdPending,
                sdAddr_o(12 downto 0)=>sdAddr_o(12 downto 0),
                sdBs_o(1 downto 0)=>sdBs_o(1 downto 0),
                sdCas_bo=>sdCas_bo,
                sdCe_bo=>sdCe_bo,
                sdCke_o=>sdCke_o,
                sdDqmh_o=>sdDqmh_o,
                sdDqml_o=>sdDqml_o,
                sdRas_bo=>sdRas_bo,
                sdWe_bo=>sdWe_bo,
                status_o(3 downto 0)=>debug_sc(3 downto 0),
                sdData_io(15 downto 0)=>sdData_io(15 downto 0));
   
end BEHAVIORAL;


