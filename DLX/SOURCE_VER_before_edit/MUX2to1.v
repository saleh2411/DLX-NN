`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:46 12/25/2025 
// Design Name: 
// Module Name:    MUX2to1 
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


module MUX2to1(
    input  [31:0] a0,
    input  [31:0] a1,
    input  sel,
    output reg [31:0] O
    );

    always@(*) begin
        case(sel)
            1'b0: O <= a0;
            1'b1: O <= a1;
            default: O <= 32'b0;
        endcase
    end
endmodule