`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:59:23 11/16/2025
// Design Name:   salve_top
// Module Name:   E:/adlx/B1/WEEK_3/HOME_VER/top_slave_tb.v
// Project Name:  HOME_VER
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: salve_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_slave_tb;

	// Inputs
	reg clk;
	reg card_sel;
	reg [9:0] AI;
	reg wr_in_n;
	reg [31:0] A;
	reg [31:0] B;
	reg [31:0] C;
	reg [31:0] D;

	// Outputs
	wire sack_n;
	wire [31:0] SDO;
	wire [4:0] Reg_addr;

	// Instantiate the Unit Under Test (UUT)
	salve_top uut (
		.clk(clk), 
		.card_sel(card_sel), 
		.AI(AI), 
		.wr_in_n(wr_in_n), 
		.sack_n(sack_n), 
		.SDO(SDO), 
		.A(A), 
		.B(B), 
		.C(C), 
		.D(D), 
		.Reg_addr(Reg_addr)
	);
	
	
   always #50 clk = ~ clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		card_sel = 1;
		AI = 0;
		wr_in_n = 0;
		A = 0;
		B = 0;
		C = 0;
		D = 0;
		
		
		
		
		// Wait 100 ns for global reset to finish
		#150;
		AI = 10'h380;
		A = 32'h4325;
		B = 32'h1010;
		C = 32'hFFFF;
		D = 32'h0001;
		wr_in_n = 1;
		
		#100;
		A = 32'hAA;

		
		#100;
		AI = 10'h300;
		A = 32'h4325;
		B = 32'h1010;
		C = 32'hFFFF;
		D = 32'h0001;
		wr_in_n = 1;
		
		#100;
		AI = 10'h300;
		A = 32'h4325;
		B = 32'h1010;
		C = 32'hFFFF;
		D = 32'h0001;
		wr_in_n = 0;
		
		
      
		// Add stimulus here
   $finish;
	end
	
      
endmodule

