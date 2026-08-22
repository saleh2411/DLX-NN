`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2020 08:03:10 PM
// Design Name: 
// Module Name: RAM32x32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RAM32x32
   (
    input wire CLK,
    input wire [4:0]ADDR, 
    input wire WE,
    input wire [31:0] DI,
    output wire [31:0] DO 
    );

    reg [31:0] memory_array [0:31]; 
    
    initial $readmemh("sram_zero.data", memory_array);
    
    always @ (posedge CLK) if(WE==1) memory_array[ADDR] <= DI; // Save DI to REG[addr}
    	 
	 assign DO = memory_array[ADDR]; // Read REG[ADDR] to DO
	 
endmodule
