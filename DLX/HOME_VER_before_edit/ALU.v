`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:53 01/11/2026 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUF,
    input test,
    input ADD,
    output [31:0] ALU_OUT
);

//wires and regs
wire [2:0] F;
wire [31:0] S;
wire neg;
wire ovf;
wire COMP_OUT;
wire [31:0] OR_OUT;
wire [31:0] AND_OUT;
wire [31:0] XOR_OUT;
wire [31:0] F0_MUX_OUT;
wire [31:0] F1_MUX_OUT;
wire [31:0] F2_MUX_OUT;



//modules instance
OR32 OR32_inst(
    .A(A), .B(B), .O(OR_OUT)
);

AND32 AND32_inst(
    .A(A), .B(B), .O(AND_OUT)
);

XOR32 XOR32_inst(
    .A(A), .B(B), .O(XOR_OUT)
);

MUX2to1 F0_MUX(
    .a0(XOR_OUT), .a1(OR_OUT), .sel(F[0]), .O(F0_MUX_OUT)
);

MUX2to1 F1_MUX(
    .a0(F0_MUX_OUT), .a1(AND_OUT), .sel(F[1]), .O(F1_MUX_OUT)
);

MUX2to1 F2_MUX(
    .a0(S), .a1(F1_MUX_OUT), .sel(F[2]), .O(F2_MUX_OUT)
);

COMPERATOR COMPARATOR_inst(
    .S(S), .neg(neg), .F(F), .COMP_OUT(COMP_OUT)
);

ADD_SUB ADD_SUB_inst(
    .A(A), .B(B), .sub(test | ~F[0]), .S(S), .neg(neg), .ovf(ovf)
);

MUX2to1 OUT_MUX(
    .a0(F2_MUX_OUT), .a1({31'b0, COMP_OUT}), .sel(test), .O(ALU_OUT)
);

assign F = (ADD)? 3'b011: ALUF; //forcing add

endmodule
