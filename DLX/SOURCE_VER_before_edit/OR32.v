`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:44 04/09/2024 
// Design Name: 
// Module Name:    AND32 
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
module OR32(
    input [31:0] A,
    input [31:0] B,
    output [31:0] O
    );

assign O = A | B;

endmodule
