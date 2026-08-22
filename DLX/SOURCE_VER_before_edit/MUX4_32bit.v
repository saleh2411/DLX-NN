`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:22:31 04/09/2024 
// Design Name: 
// Module Name:    MUX16bit 
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
module MUX4_32bit(
    input  [31:0] A,
    input  [31:0] B,
	 input  [31:0] C,
	 input  [31:0] D,
    input  [1:0]  sel,
    output [31:0] O
    );

assign O = (sel[1]) ? (sel[0] ? D:C):(sel[0] ? B:A);

endmodule
