`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:25 11/05/2024 
// Design Name: 
// Module Name:    ex_buf_ver 
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
module ex_buf_ver(
    input [15:0] buf_in,
    input buf_en,
    output [15:0] buf_out
    );


assign buf_out = (buf_en ==1) ? buf_in : 32'hzzzzzzzz;



endmodule
