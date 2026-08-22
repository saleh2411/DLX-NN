----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:05:10 01/03/2014 
-- Design Name: 
-- Module Name:    Interface_Ctrl_U - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Interface_Ctrl_U is
    Port ( clk_i : in STD_LOGIC;
				-- The signal is '1' when data in the input_i is ready.
			  Ready_clk_i : in STD_LOGIC;
			  -- R/W done signal from sdram controller.
			  done_i : in STD_LOGIC;
			  -- Address comes first and then the data with appropriate control values.
			  input_i : in  STD_LOGIC_VECTOR (39 downto 0);
			  -- Data to the sdram adapter.
           Data_o_mem : out  STD_LOGIC_VECTOR (31 downto 0);
			  -- Address to the sdram adapter.
           Addr_o_mem : out  STD_LOGIC_VECTOR (20 downto 0);
			  -- AS_N to the sdram adapter.
           as_n_mem : out  STD_LOGIC;
			  -- WE_N to the sdram adapter.
           wen_mem : out  STD_LOGIC;
			  -- RESET signal.
           RESET : out  STD_LOGIC;
			  -- Data to the Host.
			  Data_o : out  STD_LOGIC_VECTOR (39 downto 0);
			  -- Data from sdram adapter.
			  Data_i_mem	:	in STD_LOGIC_VECTOR (31 downto 0);
			  -- in_init_i IN_INIT from DLX.
			  in_init_i : in STD_LOGIC;
			  -- Master signals.
			  -- step_en output.
			  step_en_o : out STD_LOGIC;
			  MD_i : in STD_LOGIC_VECTOR (31 downto 0);
			  MA_i : in STD_LOGIC_VECTOR (31 downto 0);
			  WR_N_i : in STD_LOGIC;
			  MACK_N_o : out STD_LOGIC;
			  AS_N_i : in STD_LOGIC;
			  -- Slave signals.
			  SD_i : in STD_LOGIC_VECTOR (31 downto 0);
			  SACK_N_i : in STD_LOGIC;
			  Ssel_o : out STD_LOGIC;
			  -- Shared output between slave and registers.
			  WR_N_o : out STD_LOGIC;
			  A_o : out STD_LOGIC_VECTOR (9 downto 0);
			  -- Registers signals.
			  RD_i : in STD_LOGIC_VECTOR (31 downto 0);
			  RACK_N_i : in STD_LOGIC;
			  Rsel_o : out STD_LOGIC;
			  -- Shared output between master, slave and registers.
			  DO : out STD_LOGIC_VECTOR (31 downto 0);
			  --For debugging.
			  curr_state_o : out  STD_LOGIC_VECTOR (2 downto 0);
			  --For debugging.
			  debug_i_sa : in STD_LOGIC_VECTOR (2 downto 0);
			  debug_i_sc : in STD_LOGIC_VECTOR (3 downto 0)
			  );
end Interface_Ctrl_U;

architecture Behavioral of Interface_Ctrl_U is

	signal clk_s	:	std_logic;
	signal reset_s	:	std_logic 	:= '1';
	-- '1' when r/w operation on sdram is done.
	signal done_s	:	std_logic	:= '0';
	-- Holds address from Host.
	signal address_in_s	:	std_logic_vector (31 downto 0) := x"00000000";
	-- Holds data from Host.
	signal data_in_s		:	std_logic_vector (31 downto 0) := x"00000000";
	-- Data to Host.
	signal data_out_s		:	std_logic_vector (31 downto 0);
	-- Indicator is '1' if operation performed for register and '0' otherwise.
	signal is_not_sdram	: std_logic;
	-- State variable.
	signal curr_state	: std_logic_vector (2 downto 0) 	:= "000";
	-- State variable that holds previous state.
	signal prev_state	: std_logic_vector (2 downto 0) 	:= "000";
	-- Ready_clk_i register.
	signal Ready_clk_i_s : std_logic := '0';
	-- Feedback (read/write done).
	signal feedback_done : std_logic_vector (1 downto 0) := "00";
	-- Step_en_sh register.
	signal step_en_sh_s : std_logic := '0';
	-- Step_en_l register.
	signal step_en_l_s : std_logic := '0';
	-- in_init register.
	signal in_init_s : std_logic := '1';
	-- in_init stateregister.
	signal in_init_st_s : std_logic_vector (1 downto 0) := "00";
	-- as_n register.
	signal as_n_mem_s : std_logic;
	-- sdram address register.
	signal Addr_o_mem_s : std_logic_vector (20 downto 0);
	-- sdram wen_mem register.
	signal wen_mem_s : std_logic;
	-- WR_N register.
	signal WR_N_s : std_logic;
	-- sdram data register.
	signal Data_o_mem_s : std_logic_vector (31 downto 0);
	-- ack_n register.
	signal MACK_N_i_s : std_logic := '1';
	-- '1' if we work with slave and '0' in calse of regiisters.
	signal is_monitor : std_logic;
	-- DO register.
	signal DO_s : std_logic_vector (31 downto 0);
	-- Data from HostIoToDut to slave or registers.
	signal Data_o_sr : std_logic_vector (31 downto 0);
	
	signal counter : std_logic_vector (3 downto 0) := "0000";
	
	-- States.
	constant IDLE	:	std_logic_vector (2 downto 0) := "000";
	constant ADDR_STORE	:	std_logic_vector (2 downto 0) := "001";
	constant DATA_STORE	:	std_logic_vector (2 downto 0) := "010";
	constant WRITE_OP	:	std_logic_vector (2 downto 0) := "011";
	constant READ_OP	:	std_logic_vector (2 downto 0) := "100";
	-- Is_write bit.
	alias	 is_write	:	std_logic is input_i(32);
	-- Data/Address bit ('0' in the case of address, '1' - data).
	alias	 is_data	:	std_logic is input_i(33);
	-- Reset state machine bit.
	alias  rst_int	:	std_logic is input_i(34);
	-- Reset bus bit.
	alias  rst_bus	:	std_logic is input_i(35);
	-- step_en short
	alias step_en_sh : std_logic is input_i(36);
	-- step_en long
	alias step_en_l : std_logic is input_i(37);
	
begin
	clk_s <= clk_i;
	
	-- Initializes the state control register.
	Rst_proc: process(clk_s, Ready_clk_i)
		 variable resetCnt_v : natural range 0 to 15 := 5;
	  begin
		 if rising_edge(clk_s) then
			reset_s <= '1';
			if resetCnt_v = 0 then
				reset_s <= '0' or rst_int;
			else
			  resetCnt_v := resetCnt_v - 1;
			end if;
		 end if;
	 end process Rst_proc;
	 
	-- State machine.
	sm_proc: process(clk_s, reset_s)
	begin
		if reset_s = '1' then
			curr_state <= IDLE;
		elsif rising_edge(clk_s) then
			case (curr_state) is
				when IDLE =>
					if (Ready_clk_i and not Ready_clk_i_s )= '1' then
						if is_write = '1' then
							if is_data = '0' then
								curr_state <= ADDR_STORE;
							else
								curr_state <= DATA_STORE;
							end if;
						else
							curr_state <= ADDR_STORE;
						end if;
					else
						curr_state <= IDLE;
					end if;
				when ADDR_STORE =>
					if is_write = '0' then
						curr_state <= READ_OP;
					elsif ((Ready_clk_i and not Ready_clk_i_s )= '1' and is_data = '1') then
						curr_state <= DATA_STORE;
					else 
						curr_state <= ADDR_STORE;
					end if;
				when DATA_STORE =>
					curr_state <= WRITE_OP;				
				when READ_OP =>
					if done_s = '1' then
						curr_state <= IDLE;
					else
						curr_state <= READ_OP;
					end if;
				when WRITE_OP =>
				if done_s = '1' then
					curr_state <= IDLE;
				else
					curr_state <= WRITE_OP;
				end if;
				when others => null;
			end case;
		end if;
	end process sm_proc;
	
	--Samples the signals.
	Sample_proc: process(clk_s)
	begin
		if rising_edge(clk_s) then
			if is_not_sdram = '0' then
				done_s <= done_i;
			elsif is_monitor = '1' then
				done_s <= not SACK_N_i or is_write;
			elsif is_monitor = '0' then
				done_s <= not RACK_N_i;
			else
				done_s <= done_s;
			end if;
			Ready_clk_i_s <= Ready_clk_i;
			prev_state <= curr_state;
			in_init_s <= in_init_i;
		end if;
	end process Sample_proc;
	
	--Extracts values from input of the Host.
	Store_proc: process(clk_s)
	begin
		if(rising_edge(clk_s) and reset_s = '0' and
		(Ready_clk_i and not Ready_clk_i_s)= '1') then
			if is_data = '0' then
				address_in_s <= input_i(31 downto 0);
			else 
				data_in_s <= input_i(31 downto 0);
			end if;
		else
			address_in_s <= address_in_s;
			data_in_s <= data_in_s;
		end if;
	end process Store_proc;
	-- Outputs.
	is_not_sdram <= '0' when ((address_in_s(24) = '0' and in_init_i = '1') or
							(MA_i(24) = '0' and in_init_i = '0')) else '1';
	WR_N_s <= '0' when (curr_state = WRITE_OP and is_not_sdram = '1') else '1';
	Data_o_sr <= data_in_s when (curr_state = WRITE_OP and is_not_sdram = '1') else x"00000000";
	as_n_mem_s <= '0' when ((curr_state = READ_OP or curr_state = WRITE_OP) and is_not_sdram = '0') else '1';
	wen_mem_s <= '1' when (curr_state = WRITE_OP and is_not_sdram = '0') else '0';
	Data_o_mem_s <= data_in_s when (curr_state = WRITE_OP and is_not_sdram = '0') else	x"00000000";
	Addr_o_mem_s <= address_in_s (20 downto 0)
						 when ((curr_state = WRITE_OP or curr_state = READ_OP)  and is_not_sdram = '0') 
									else x"00000"&'0';
	
	wen_mem <= wen_mem_s when in_init_i = '1' else 
					(not WR_N_i) when (in_init_i = '0' and is_not_sdram = '0') else '0';
	as_n_mem <= as_n_mem_s when in_init_i = '1' else 
							AS_N_i when (in_init_i = '0' and is_not_sdram = '0') else '1';
	Data_o_mem <= Data_o_mem_s when in_init_i = '1' else MD_i;
	Addr_o_mem <= Addr_o_mem_s when in_init_i = '1' else MA_i(20 downto 0);
	WR_N_o <= WR_N_s when in_init_i = '1' else WR_N_i;
	MACK_N_o <= '0' when (in_init_i = '0' and done_s = '1') else '1';
	is_monitor <= (not MA_i(10)) when (in_init_i = '0') else (not address_in_s(10));
	Ssel_o <= '1' when ((is_monitor = '1' and is_not_sdram = '1') and 
			(curr_state = READ_OP or curr_state = WRITE_OP)) else '0';
	Rsel_o <= '1' when ((is_monitor = '0' and is_not_sdram = '1') and 
			(curr_state = READ_OP or curr_state = WRITE_OP)) else '0';
	A_o <= MA_i(9 downto 0) when (in_init_i = '0') else address_in_s(9 downto 0);
	DO_s <= Data_i_mem when (in_init_i = '0' and WR_N_i = '1' and is_not_sdram = '0' )  else
			SD_i when (in_init_i = '0' and WR_N_i = '1' and is_not_sdram = '1' and is_monitor = '1') else
			RD_i when (in_init_i = '0' and WR_N_i = '1' and is_not_sdram = '1' and is_monitor = '0') else
			MD_i when (in_init_i = '0' and WR_N_i = '0') else
			Data_o_sr when (in_init_i = '1') else DO_s;
	
	-- Sets feedback bits.
	Feedback_proc: process(clk_s)
	begin
	if rising_edge(clk_s) then
		if curr_state /= IDLE and prev_state = IDLE then
			feedback_done(0) <= not feedback_done(0);
		elsif curr_state = IDLE and prev_state /= IDLE then
			feedback_done(1) <= not feedback_done(1);
		end if;
	end if;
	end process Feedback_proc;
	
	-- Sets in_init state's bit 0.
	In_init_proc_0: process(clk_s)
	begin
		if rising_edge(clk_s) then
			if ((not in_init_i and in_init_s) = '1') then
				in_init_st_s(0) <= not in_init_st_s(0);
			end if;
		end if;
	end process In_init_proc_0;
	
	-- Sets in_init state's bit 1.
	In_init_proc_1: process(clk_s)
	begin
		if rising_edge(clk_s) then
			if ((in_init_i and not in_init_s) = '1') then
				in_init_st_s(1) <= not in_init_st_s(1);
			end if;
		end if;
	end process In_init_proc_1;
	
	-- Sets both step_en outputs.
	Step_en_l_proc: process(clk_s)
	begin
		if rising_edge(clk_s) then
		   step_en_sh_s <= step_en_sh;
			if ((Ready_clk_i and not Ready_clk_i_s) = '1') 
		      	then  step_en_l_s <= step_en_l;
			      else	step_en_l_s <= step_en_l_s;
			end if;
		end if;
	end process Step_en_l_proc;
	
	step_en_o <= step_en_l_s or (step_en_sh and not step_en_sh_s);
	
	-- Chooses data source.
	Read_proc: process(clk_s)
	begin
		if rising_edge(clk_s) then
			if (curr_state = READ_OP) then
				if is_not_sdram = '1' then 
					if is_monitor = '1' then
						Data_out_s <= SD_i;
					else
						Data_out_s <= RD_i;
					end if;
				else Data_out_s <= Data_i_mem;
				end if;
			end if;
		end if;
	end process Read_proc;
	
	--Data_out_s <= '0' & debug_i_sa & debug_i_sc & x"000000";
							
	--Data_o <= '0' & debug_i_sa & debug_i_sc & counter & curr_state & Ready_clk_i_s & Data_out_s(15 downto 0);
	-- Data output.
	Data_o(31 downto 0) <= Data_out_s;
	DO <= DO_s;
	
	-- Feeback done bits.
	Data_o(33 downto 32) <= feedback_done;
	-- In_init state bits.
	Data_o(35 downto 34) <= in_init_st_s;
	-- Reserved bits.
	Data_o(39 downto 36) <= "0000";
	
	RESET <= rst_bus;
	
	--Debug outputs.
	curr_state_o <= curr_state;
	
end Behavioral;

