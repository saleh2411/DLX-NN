`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:32 04/09/2024 
// Design Name: 
// Module Name:    CNT5 
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
module Step_CNT5(
    input CLK,
    input RST,
    input CE,
    output[4:0] CNT
    );


reg [4:0] CNT_S;
reg CE_W1,CE_W2;

always @(posedge CLK)
    begin
         CE_W1<=CE;
         CE_W2<=CE_W1;
     if (RST == 1)
	      CNT_S <= 5'b00000;
	  else if (CE_W2 == 1) 
	      CNT_S	<= CNT_S + 5'b1;
	  else 
	      CNT_S	<= CNT_S;
end

assign CNT=CNT_S;			
endmodule
