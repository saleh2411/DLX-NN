library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Package for SRAM pre-initialization data
package sram_data is

	-- Size of pre instantiated data
	constant data_size: integer := 38;
	
	type pre_inst_data is array(0 to data_size-1) of std_logic_vector(31 downto 0);
	constant pre_inst_mem : pre_inst_data := ( 
	-- The actual data :
							X"8c010011", -- 0x0 R1 := Mem[0x11]
							X"8c020012", -- 0x1 R2 := Mem[0x12]
							X"8c030013", -- 0x2 R3 := Mem[0x13]
							X"8c040014", -- 0x3 R4 := Mem[0x14]
							X"ac01000d", -- 0x4 Mem[0xd]:= R1 
							X"ac02000e", -- 0x5 Mem[0xe]:= R2
							X"ac03000f", -- 0x6 Mem[0xf]:= R3
							X"ac040010", -- 0x7 Mem[0x10]:= R4
							X"ac04000d", -- 0x8 Mem[0xd]:= R4
							X"ac03000e", -- 0x9 Mem[0xe]:= R3
							X"ac02000f", -- 0xa Mem[0xf]:= R2
							X"ac010010", -- 0xb Mem[0x10]:= R1
							X"fc000000", -- 0xc halt
							X"00000000", -- 0xd  work
							X"00000000", -- 0xe  work
							X"00000000", -- 0xf  work
							X"00000000", -- 0x10 work
							X"00000001", -- 0x11 constant
							X"01234567", -- 0x12 constant
							X"fedec987", -- 0x13 constant
							X"abcdef01", -- 0x14 constant
							X"00000000", -- 0x15 N.C.
							X"00000000", -- 0x16
							X"00000000", -- 0x17
							X"00000000", -- 0x18
							X"00000000", -- 0x19
							X"00000000", -- 0x1a
							X"00000000", -- 0x1b
							X"00000000", -- 0x1c
							X"00000000", -- 0x1d
							X"00000000", -- 0x1e
							X"00000000", -- 0x1f 
							X"00000001", -- 0x20
							X"00000000", -- 0x21
							X"00000000", -- 0x22
							X"00000000", -- 0x23
							X"00000000", -- 0x24
							X"00000000" -- 0x25
							 ); 

end sram_data;

package body sram_data is

 
end sram_data;
