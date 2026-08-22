`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:56:27 11/05/2024 
// Design Name: 
// Module Name:    ex_reg_ver 
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
module ex_reg_ver(
    input reset,
    input clock,
    input ce_reg,
    input [15:0] data_in,
    output [15:0] data_out
    );


reg [15:0] data_out_reg;

// register  with active high  reset
    always @(posedge clock)

    if (reset ==1)
	     data_out_reg <=   16'h0000;
	
	 else if (ce_reg ==1)
	      data_out_reg <=   data_in;
			
	 else 
	      data_out_reg <=  data_out_reg;
	
assign  data_out = data_out_reg;



endmodule
