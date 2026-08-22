`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:28:56 01/11/2026
// Design Name:   control
// Module Name:   E:/adlx/B1/Week7/HOME_VER/control_tb.v
// Project Name:  HOME_VER
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: control
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module control_tb;

	// Inputs
	reg clk;
	reg step_en;
	reg reset;
	reg ack_n;
	reg [5:0] op_code;
	reg [5:0] funct;
	reg aeqz;

	// Outputs
	wire busy;
	wire wr_n;
	wire as_n;
	wire [1:0] mac_state;
	wire MR;
	wire IRce;
	wire Ace;
	wire Bce;
	wire [0:1] S2sel;
	wire PCce;
	wire add;
	wire [0:1] S1sel;
	wire Cce;
	wire test;
	wire Itype;
	wire DINTsel;
	wire Shift;
	wire MDRce;
	wire Asel1;
	wire MW;
	wire GPR_WE;
	wire Jlink;
	wire [4:0] control_state;
	wire MARce;
	wire right;
	wire MDRse1;
	wire in_init;

	integer i;
	//integer bt;
	//integer D13;
	

	// path parameters
    localparam [11:0] D1_INIT_FETCH = 12'b110???_??????;
    localparam [11:0] D2_ALU        = 12'b0000??_1?????;
    localparam [11:0] D4_SHIFT      = 12'b0000??_0???1?;
    localparam [11:0] D5_ALUI       = 12'b001???_??????;
    localparam [11:0] D6_TESTI      = 12'b011???_????1?;
    localparam [11:0] D7_ADR_COMP   = 12'b101???_??????;
    localparam [11:0] D8_JR         = 12'b010??0_??????;
    localparam [11:0] D9_SAVEPC     = 12'b010??1_??????;
    localparam [11:0] D12_BRANCH    = 12'b0001?0_??????;


	// Instantiate the Unit Under Test (UUT)
	control uut (
		.clk(clk), 
		.step_en(step_en), 
		.reset(reset), 
		.ack_n(ack_n), 
		.op_code(op_code), 
		.funct(funct), 
		.aeqz(aeqz), 
		.busy(busy), 
		.wr_n(wr_n), 
		.as_n(as_n), 
		.mac_state(mac_state), 
		.MR(MR), 
		.IRce(IRce), 
		.Ace(Ace), 
		.Bce(Bce), 
		.S2sel(S2sel), 
		.PCce(PCce), 
		.add(add), 
		.S1sel(S1sel), 
		.Cce(Cce), 
		.test(test), 
		.Itype(Itype), 
		.DINTsel(DINTsel), 
		.Shift(Shift), 
		.MDRce(MDRce), 
		.MARce(MARce),
		.Asel1(Asel1), 
		.MW(MW), 
		.GPR_WE(GPR_WE), 
		.right(right),
		.in_init(in_init),
		.Jlink(Jlink), 
		.MDRsel(MDRsel),
		.control_state(control_state)
	);
	
	// --- DEBUG ---
	wire D13, BT;
	assign D13 = uut.ctrl.D13_SL;
	assign BT = uut.ctrl.BT;
	


	always #50 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		step_en = 0;
		reset = 0;
		ack_n = 1;
		op_code = 0;
		funct = 0;
		aeqz = 0;

		// Wait 100 ns for global reset to finish
		@(posedge clk);
		#3;
		reset = 1;
		#100;
		reset = 0;
		#100;

		// simulation squence

		for(i = 0; i < 12; i = i + 1) begin
		   #100;
			casez(i) 
				0: begin op_code = D1_INIT_FETCH[11:6]; funct = D1_INIT_FETCH[5:0]; end
				1: begin op_code = D2_ALU[11:6]; funct = D2_ALU[5:0]; end
				2: begin op_code = D4_SHIFT[11:6]; funct = D4_SHIFT[5:0]; end
				3: begin op_code = D5_ALUI[11:6]; funct = D5_ALUI[5:0]; end
				4: begin op_code = D6_TESTI[11:6]; funct = D6_TESTI[5:0]; end
				5: begin op_code = D7_ADR_COMP[11:6]; funct = D7_ADR_COMP[5:0]; end // D13 = 1 - STORE
				6: begin op_code = D8_JR[11:6]; funct = D8_JR[5:0]; end
				7: begin op_code = D9_SAVEPC[11:6]; funct = D9_SAVEPC[5:0]; end
				8: begin op_code = D12_BRANCH[11:6]; funct = D12_BRANCH[5:0]; aeqz = 1'b1; end // branch taken
				9: begin op_code = 6'b100???; funct = D7_ADR_COMP[5:0]; end // D13 = 0 - LOAD
				10: begin op_code = D12_BRANCH[11:6]; funct = D12_BRANCH[5:0]; aeqz = 1'b0; end // Branch not taken
				default: begin op_code = 6'b000000; funct = 6'b000000; end
			endcase
			#100;
			step_en = 1;
			#100;
			step_en = 0;
			#500;
			ack_n = 0;
			#100;
			ack_n = 1;
			if (i == 5 || i == 9) begin #600; ack_n = 0; #100; ack_n = 1; #300; end // 2 ack_n for load/store
			else #1000;
		end
        
		#300;
		$finish;

	end
      
endmodule

