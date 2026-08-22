`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:51:21 11/23/2025 
// Design Name: 
// Module Name:    monitor_top 
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
module monitor_salve(
    input clk,
    input in_init,
    input step_en,
    input stop_n,
    input [9:0] AI,
    input [31:0] D_IN,
    input [31:0] A_IN,
    input [31:0] B_IN,
    input CARD_SEL,
    input WR_IN_N,
    output SACK_N,
    output [31:0] SDO,
    output [4:0] REG_ADDR
    );
	
	wire [8:0] ID_OUT;
	wire [7:0] STS;
	wire [31:0] DOUT;
	
	
	logic_analyzer LA(.clk(clk),.DIN(D_IN),.AI(AI[4:0]),.step_en(step_en),.in_init(in_init),.stop_n(stop_n),.STS(STS),.DOUT(DOUT));
	id_module ID(.ID_out(ID_OUT));
	salve_top slave(.clk(clk),.card_sel(CARD_SEL),.AI(AI),.wr_in_n(WR_IN_N),.sack_n(SACK_N),.SDO(SDO),.A(DOUT),.B({ID_OUT,16'b0,STS}),.C(A_IN),.D(B_IN),.Reg_addr(REG_ADDR));


endmodule