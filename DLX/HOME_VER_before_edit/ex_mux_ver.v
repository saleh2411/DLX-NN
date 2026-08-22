`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:04:16 11/05/2024 
// Design Name: 
// Module Name:    ex_mux_ver 
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
module ex_mux_ver(
    input [15:0] mux_in_a,
    input [15:0] mux_in_b,
    input mux_sel,
    output [15:0] mux_out
    );


assign mux_out = (mux_sel ==1) ? mux_in_a : mux_in_b;



endmodule
