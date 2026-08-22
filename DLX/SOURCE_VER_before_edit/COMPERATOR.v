`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:37:10 01/11/2026 
// Design Name: 
// Module Name:    COMPERATOR 
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
module COMPERATOR(
    input [31:0] S,
    input neg,
    input [2:0] F,
    output COMP_OUT
);

//wire and regs
wire zero_compare;

//assigns
assign zero_compare = (S == 32'b0) ? 1'b1 : 1'b0;
assign COMP_OUT = ( (~zero_compare) & ( (~neg) & (F[0]) ) ) | ( ( (neg) & (F[2]) ) | ( (zero_compare) & (F[1]) ) );


endmodule