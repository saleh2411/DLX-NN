`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:39:43 11/16/2025 
// Design Name: 
// Module Name:    salve_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module salve_top(
    input clk,
    input card_sel,
    input [9:0] AI,
    input wr_in_n,
    output sack_n, // 
    output [31:0] SDO, //
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    input [31:0] D,
    output [4:0] Reg_addr // 
    );
	
	reg x1=0,x2=0,x3=0;
	wire set_block;
	
	MUX4_32bit mux4(.A(A),.B(B),.C(C),.D(D),.O(SDO),.sel(AI[6:5]));
	assign set_block = card_sel & wr_in_n & AI[9] & AI[8] & AI[7];
	assign sack_n = ~(x2 & ~(x3));
	assign Reg_addr = AI[4:0];
	
	always @(posedge clk) begin
	x1 <= set_block;
	x2 <= x1;
	x3 <= x2;
		

	
	end
	
endmodule
