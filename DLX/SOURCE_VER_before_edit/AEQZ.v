`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:36:49 04/09/2024 
// Design Name: 
// Module Name:    AEQZ 
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
module AEQZ(
    input [31:0] DI,
    output A_eqz
    );


 assign A_eqz = (DI == 00000000) ? 1:0;

endmodule


