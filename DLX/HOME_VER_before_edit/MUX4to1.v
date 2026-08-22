`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:46 12/25/2025 
// Design Name: 
// Module Name:    MUX4to1
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

module MUX4to1(
    input  [31:0] a0,
    input  [31:0] a1,
    input  [31:0] a2,
    input  [31:0] a3,
    input  [1:0]  sel,
    output reg [31:0] O
    );

    always@(*) begin
        case(sel)
            2'b00: O <= a0;
            2'b01: O <= a1;
            2'b10: O <= a2;
            2'b11: O <= a3;
            default: O <= 32'b0;
        endcase
    end

    endmodule