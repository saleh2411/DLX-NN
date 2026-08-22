`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:59:34 01/02/2026 
// Design Name: 
// Module Name:    GPR 
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
module GPR(
    input clk,
    input [31:0] C_REG,
    input GPR_WE,
    input [4:0] CADR,
    input [4:0] AADR,
    input [4:0] BADR,
    input [4:0] DADR,
    output [31:0] B,
    output [31:0] D,
    output AEQZ_out,
    output [31:0] A
);

//wires
wire [4:0] address_a;
wire [4:0] address_b;
wire [4:0] address_d;
wire [31:0] RAM_A_OUT;
wire [31:0] RAM_B_OUT;
wire [31:0] RAM_D_OUT;


//external modules instance
RAM32x32 RAM_A_INST(.CLK(clk), .WE(GPR_WE), .ADDR(address_a), .DI(C_REG), .DO(RAM_A_OUT)); //ram for A
RAM32x32 RAM_B_INST(.CLK(clk), .WE(GPR_WE), .ADDR(address_b), .DI(C_REG), .DO(RAM_B_OUT)); //ram for B
RAM32x32 RAM_D_INST(.CLK(clk), .WE(GPR_WE), .ADDR(address_d), .DI(C_REG), .DO(RAM_D_OUT)); //ram for D
AEQZ AEQZ_INST(.DI(A), .A_eqz(AEQZ_out)); //AEQZ instance

//address logic
assign address_a = (GPR_WE == 1) ? CADR : AADR;
assign address_b = (GPR_WE == 1) ? CADR : BADR;
assign address_d = (GPR_WE == 1) ? CADR : DADR;

//output logic to prevent writing to zero, we chose option 1
assign A = (address_a == 5'b00000)? 32'b0 : RAM_A_OUT;
assign B = (address_b == 5'b00000)? 32'b0 : RAM_B_OUT; 
assign D = (address_d == 5'b00000)? 32'b0 : RAM_D_OUT; 

endmodule
