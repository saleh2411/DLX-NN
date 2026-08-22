`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:46 12/25/2025 
// Design Name: 
// Module Name:    mac_fsm 
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


module IR_ENV(
    input clk,
    input reset,
    input [31:0] D_IN,
    input ir_ce,
    input type,
    input JLINK,
    output [5:0] opcode,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [5:0] funct,
    output [31:0] immediate,
    output [31:0] IR,
    output [2:0] ALUF
    );

    parameter I_TYPE = 1'b1;
    parameter R_TYPE = 1'b0;
    //wires and regs

    REG32CE IR_ENV (
        .CLK(clk), .CE(ir_ce), .DI(D_IN), .DO(IR)
    ); //done all inputs and outputs

    assign opcode = IR[31:26]; 
    assign rs1    = IR[25:21]; 
    assign rs2    = IR[20:16]; 
    assign rd     = (JLINK)?{5{1'b1}}:((type == I_TYPE) ? IR[20:16] : IR[15:11]); 
    assign funct  = IR[5:0]; 
    assign immediate = {{16{IR[15]}}, IR[15:0]}; 
    assign ALUF = (type == I_TYPE) ? IR[28:26] : IR[2:0];

endmodule