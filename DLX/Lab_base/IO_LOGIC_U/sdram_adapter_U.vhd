library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sdram_adapter_U is
    Port ( bufclk : in std_logic;
           opBegun : in std_logic;
           XSA_done : in std_logic;
           rdDone : in std_logic;
           hDo : in std_logic_vector(15 downto 0);
           WEN : in std_logic;
           ADDR : in std_logic_vector(20 downto 0);
           DIN : in std_logic_vector(31 downto 0);
           AS_N : in std_logic;
           RESET : in std_logic;
			  earlyOpBegun : in std_logic;
			  rdPending : in std_logic;
			  lock : out std_logic;
           rst : out std_logic;
           rd : out std_logic;
           wr : out std_logic;
           hAddr : out std_logic_vector(23 downto 0);
           hDin : out std_logic_vector(15 downto 0);
           done : out std_logic;
		 	  DO : out std_logic_vector(31 downto 0);
           CLK : out std_logic;
			  state : out std_logic_vector(2 downto 0);
		 	  sdram_done : out std_logic; -- for verification purposes
			  earlyOpBegun_o : out std_logic -- for synchronization
			  );
end sdram_adapter_U;

architecture Behavioral of sdram_adapter_U is

-- Internal signals
signal start_op 	: std_logic;
signal as_d 		: std_logic;
signal busy			: std_logic;

-- Output signals
signal int_DO 		: std_logic_vector(31 downto 0);
signal int_wr 		: std_logic;
signal int_rd 		: std_logic;
signal int_done  	: std_logic;
signal done_d	 	: std_logic;
signal op_enable 	: std_logic;

signal XSA_done_deasserted : std_logic := '1';

-- State definitions
signal curr_state : std_logic_vector(1 downto 0);
constant IDLE 		: std_logic_vector(1 downto 0) := "00";
constant W4RDY		: std_logic_vector(1 downto 0) := "01";
constant OP1  		: std_logic_vector(1 downto 0) := "11";
constant OP2  		: std_logic_vector(1 downto 0) := "10";

begin

-- Derive start of operation request from controller
AS : process(bufclk, reset)
begin
	if (reset = '1') then
		as_d <= '0';
	elsif ((bufclk'event) and (bufclk = '1')) then
		as_d <= not(as_n);
	end if;
end process AS;
start_op <= not(as_d) and not(as_n);

-- Main SM
-- busy <= earlyOpBegun or opBegun;
sm: process(bufclk, reset)
begin
	if (reset = '1') then
		curr_state <= IDLE;
	elsif ((bufclk'event) and (bufclk = '1')) then
		case (curr_state) is
			when IDLE =>
				if (start_op = '1') then
					curr_state <= W4RDY;
				else
					curr_state <= curr_state;
				end if;
			when W4RDY =>
				--if (busy = '1') then
				--	curr_state <= curr_state;
				--else
					curr_state <= OP1;					
				--end if;
			when OP1 =>
				if (XSA_done = '1') then
					curr_state <= OP2;
					XSA_done_deasserted <= '0';
				else
					curr_state <= curr_state;
				end if;
			when OP2 =>
				if(XSA_done = '0') then
					XSA_done_deasserted <= '1';
				end if;
				if (XSA_done = '1' and XSA_done_deasserted = '1') then
					curr_state <= IDLE;
				else
					curr_state <= curr_state;
				end if;
			when others => null;
		end case;
	end if;
end process sm;

-- Define operation pending for SDRAM
op_enable <= '1' when (((curr_state = OP1) or (curr_state = OP2)) and 																							 
							  (XSA_done = '0')) else '0';
int_wr <= op_enable and wen;
int_rd <= op_enable and not(wen);

wr <= int_wr;
rd <= int_rd;

-- Output done signal when moving TO IDLE state
int_done <= '1' when (curr_state = IDLE) else '0';
done_ff: process(bufclk, reset)
begin
	if (reset = '1') then
		done_d <= '0';
	elsif ((bufclk'event) and (bufclk = '1')) then
		done_d <= int_done;
	end if;
end process done_ff;

done <= not(done_d) and int_done;

-- Data sampling for 16 --> 32 bit adapter
data: process(bufclk, reset)
begin
	if (reset = '1') then
		int_DO <= X"a5a5a5a5";
	elsif ((bufclk'event) and (bufclk = '1')) then
		if (rdDone = '1') then 
			int_DO(31 downto 16) <= int_DO(15 downto 0);
			int_DO(15 downto 0) <= hDo;
		else
			int_DO <= int_DO;
		end if;
	end if;
end process data;
DO <= int_DO;

-- Output clock and reset
rst <= reset;
CLK <= bufclk;

-- Decide which data to send for write
hDin <= Din(15 downto 0) when (curr_state = OP2) else Din(31 downto 16);

-- Address decoder
hAddr(21 downto 1) <= addr(20 downto 0);
hAddr(22) <= '0';
hAddr(23) <= '0';
hAddr(0) <= '1' when (curr_state = OP2) else '0';


sdram_done <= XSA_done;
state <= '0' & curr_state;

lock <= '1';
earlyOpBegun_o <= earlyOpBegun;

end Behavioral;
