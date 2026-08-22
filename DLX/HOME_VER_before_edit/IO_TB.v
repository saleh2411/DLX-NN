`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:58:33 01/11/2026
// Design Name:   IO
// Module Name:   E:/adlx/B1/Week7/HOME_VER/IO_TB.v
// Project Name:  HOME_VER
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: IO
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module IO_TB;

	// Inputs
	reg clk_in;
	reg rst;
	reg pc_step_en;

	// Outputs
	wire busy;
	wire wr_n;
	wire as_n;
	wire [1:0] mac_state;
	wire MR;
	wire MW;
	wire GPR_WE;
	wire [4:0] control_state;
	wire IRCE;
	wire PCCE;
	wire ACE;
	wire BCE;
	wire CCE;
	wire MDRCE;
	wire [1:0] S1SEL;
	wire [1:0] S2SEL;
	wire DINTSEL;
	wire MDRSEL;
	wire ASEL;
	wire ADD;
	wire TEST;
	wire SHIFT;
	wire TYPE;
	wire JLINK;
	wire MARCE;
	wire RIGHT;
	wire in_init;
	wire [31:0] AO;
	wire [31:0] DO;
	wire [31:0] D_OUT_GPR;

	// Instantiate the Unit Under Test (UUT)
	IO uut (
		.clk_in(clk_in), 
		.rst(rst), 
		.pc_step_en(pc_step_en), 
		.busy(busy), 
		.wr_n(wr_n), 
		.as_n(as_n), 
		.mac_state(mac_state), 
		.MR(MR), 
		.MW(MW), 
		.GPR_WE(GPR_WE), 
		.control_state(control_state), 
		.IRCE(IRCE), 
		.PCCE(PCCE), 
		.ACE(ACE), 
		.BCE(BCE), 
		.CCE(CCE), 
		.MDRCE(MDRCE), 
		.S1SEL(S1SEL), 
		.S2SEL(S2SEL), 
		.DINTSEL(DINTSEL), 
		.MDRSEL(MDRSEL), 
		.ASEL(ASEL), 
		.ADD(ADD), 
		.TEST(TEST), 
		.SHIFT(SHIFT), 
		.TYPE(TYPE), 
		.JLINK(JLINK), 
		.MARCE(MARCE), 
		.RIGHT(RIGHT), 
		.in_init(in_init),  
		.D_OUT_GPR(D_OUT_GPR)
	);

	always #50 clk_in = ~clk_in;
	integer i;
	integer addr;
	integer regi;

	initial begin
		// Initialize Inputs
		clk_in = 0;
		rst = 1;
		pc_step_en = 0;
		i = 0;

		// Wait 100 ns for global reset to finish
		@(posedge clk_in);
		#5;
		#200;
		rst = 0;

		#3000;
		$display("saed123");

        
		// simulation sequence 1
		repeat (100) begin
			#500;
      	pc_step_en = 1;
  	    #100;
		$display("i = %d, clk_in = %d, pc_step_en = %d, busy = %d, wr_n = %d, as_n = %d, mac_state = %b, MR = %d, MW = %d, GPR_WE = %d, control_state = %b, IRCE = %d, PCCE = %d, ACE = %d, BCE = %d, CCE = %d, MDRCE = %d, S1SEL = %b, S2SEL = %b, DINTSEL = %d, MDRSEL = %d, ASEL = %d, ADD = %d, TEST = %d, SHIFT = %d, TYPE = %d, JLINK = %d, MARCE = %d, RIGHT = %d, in_init = %d", 
		i, clk_in, pc_step_en, busy, wr_n, as_n, mac_state, MR, MW, GPR_WE, control_state, IRCE, PCCE, ACE, BCE, CCE, MDRCE, S1SEL, S2SEL,DINTSEL,MDRSEL ,ASEL ,ADD ,TEST ,SHIFT ,TYPE ,JLINK ,MARCE ,RIGHT ,in_init);
  	      pc_step_en = 0;
     	 #3000;
		$display("EXEC : IR = %h (opcode %b)  next PC = %h",
			uut.dlx.u_data_path.IR_OUT,
			uut.dlx.u_data_path.IR_OUT[31:26],
			uut.dlx.u_data_path.PC);
		$display("REGS :");
		for (regi = 0; regi < 32; regi = regi + 1) begin
			$display("  R%0d = %h", regi, uut.dlx.u_data_path.gpr_inst.RAM_A_INST.memory_array[regi]);
		end
			$display("SRAM : addr 0x00-0x20");
			for (addr = 0; addr <= 32; addr = addr + 1) begin
				$display("  [0x%0h] = %h", addr, uut.io_sim.EXTERNAL_RAM.memory_array[addr]);
			end
		 i = i + 1;
		end
		$finish;
		

	end
      
endmodule

