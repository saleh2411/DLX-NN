`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:34:53 01/11/2026 
// Design Name: 
// Module Name:    SHIFT_ENV 
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
module SHIFT_ENV(
    input [31:0] D_IN,
    input shift,
    input right,
    output reg [31:0] D_OUT
    );

    always@(*) begin
        case({shift,right})
            2'b00: D_OUT = D_IN;
            2'b01: D_OUT = D_IN;
            2'b10: D_OUT = D_IN << 1;
            2'b11: D_OUT = D_IN >> 1;
            default: D_OUT = 32'b0;
        endcase
    end

endmodule
