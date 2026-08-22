`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:37:38 01/11/2026 
// Design Name: 
// Module Name:    ADD_SUB 
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
module ADD_SUB(
    input [31:0] A,
    input [31:0] B,
    input sub,
    output [31:0] S,
    output neg,
    output ovf
);

//wires and regs
wire [15:0] S_1;
wire OFL_1;
wire CO_1;
wire [15:0] S_2;
wire OFL_2;
wire CO_2;
wire [15:0] S_3;
wire OFL_3;
wire CO_3;


//instances

ADD16 ADD16_inst1(
    .A(A[15:0]), .B(B[15:0] ^ {16{sub}}), .ci(sub), .ADD(1'b1), .S(S_1), .OFL(OFL_1), .CO(CO_1)
);

ADD16 ADD16_inst2(
    .A(A[31:16]), .B(B[31:16] ^ {16{sub}}), .ci(1'b0), .ADD(1'b1), .S(S_2), .OFL(OFL_2), .CO(CO_2)
);

ADD16 ADD16_inst3(
    .A(A[31:16]), .B(B[31:16] ^ {16{sub}}), .ci(1'b1), .ADD(1'b1), .S(S_3), .OFL(OFL_3), .CO(CO_3)
);


assign ovf = (OFL_1)? OFL_3 : OFL_2;
assign S = {(CO_1 ? S_3 : S_2), S_1};
assign neg = S[31] ^ ovf;


endmodule
