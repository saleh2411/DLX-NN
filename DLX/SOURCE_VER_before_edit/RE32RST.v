`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:23:00 04/09/2024 
// Design Name: 
// Module Name:    REG32CE 
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
module REG32RST(
    input  CLK,
    input  CE,
	 input  RST,
    input  [31:0] DI,
    output [31:0] DO
    );

reg [31:0] REG;

always @ (posedge CLK)
    begin
        if (RST) REG <= 32'b0; else
		  if(CE) REG <= DI;  // Save DI to REG
    end
	 
	 assign DO = REG; // Saved Data send to output 
	 
endmodule
