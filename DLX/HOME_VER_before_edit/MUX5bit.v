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
module MUX5bit(
    input  [4:0] A,
    input  [4:0] B,
    input  sel,
    output [4:0] O
    );

assign O = (sel) ? B:A;

endmodule
