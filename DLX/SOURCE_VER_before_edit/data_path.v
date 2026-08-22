`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:34:55 12/28/2025 
// Design Name: 
// Module Name:    data_path 
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
module data_path(
    input clk,
    input reset,
    input [31:0] D_in,
    input [4:0] Daddr,
    input IRCE,
    input PCCE,
    input ACE,
    input BCE,
    input CCE,
    input MARCE,
    input MDRCE,
    input GPR_WE,
    input [1:0] S1SEL,
    input [1:0] S2SEL,
    input DINTSEL,
    input MDRSEL,
    input ASEL,
    input ADD,
    input TEST,
    input SHIFT,
    input RIGHT,
    input TYPE,
    input JLINK,
    //inputs to activation engine
    input ACTIVATION_sel,
    input softmax_start,
    input  act_en,
    output sigmoid_ready,
    input  mult_en,
    output mult_ready,
    output softmax_done,
    output wire [31:0] softmax_mem_addr,
    output wire [31:0] softmax_mem_data_out,
    input  wire [31:0] softmax_mem_data_in,
    output wire        softmax_mem_rd,
    output wire        softmax_mem_wr,
    input  wire        softmax_mem_busy,   
    output wire        softmax_active,

    output [31:0] AO,
    output [31:0] DO,
    output [5:0] opcode,
    output [5:0] funct,
    output AEQZ_out,
    output [31:0] D_OUT_GPR
    );

    //wires and regs
    wire [31:0] C_OUT;
    wire [31:0] A_OUT_GPR;
    wire [31:0] B_OUT_GPR;
    wire [31:0] A_OUT;
    wire [31:0] B_OUT;
    wire [31:0] S1;
    wire [31:0] S1_shifted;
    wire [31:0] S2;
    wire [31:0] DINT;
    wire [31:0] MAR_OUT;
    wire [31:0] MDR_OUT;
    wire [31:0] PC;
    wire [4:0] RD;
    wire [4:0] RS1;
    wire [4:0] RS2;
    wire [31:0] imm;
    wire [31:0] MDRMUX_OUT;
    wire [31:0] IR_OUT;
    wire [31:0] ALU_OUT;
	wire [2:0] ALUF;
	wire [31:0] AMUX_out;
    wire [31:0] activation_out;
    wire [31:0] DINT_0_IN;
    wire [31:0] mult_out;

    //modules instantiation

    REG32CE A_REG (
        .CLK(clk), .CE(ACE), .DI(A_OUT_GPR), .DO(A_OUT) //  fix_me [saed] there is not reset for this reg32
    ); // done all inputs outputs

    REG32CE B_REG (
        .CLK(clk), .CE(BCE), .DI(B_OUT_GPR), .DO(B_OUT)
    ); // done all inputs and outputs

    REG32CE C_REG (
        .CLK(clk), .CE(CCE), .DI(DINT), .DO(C_OUT)
    ); //done all inputs and outputs

    REG32CE MAR (
        .CLK(clk), .CE(MARCE), .DI(DINT), .DO(MAR_OUT)
    ); //done all inputs and outputs

    REG32CE MDR (
        .CLK(clk), .CE(MDRCE), .DI(MDRMUX_OUT), .DO(MDR_OUT)
    );// done all inputs and outputs

    GPR gpr_inst (
        .clk(clk), .GPR_WE(GPR_WE), .C_REG(C_OUT), .CADR(RD), .AADR(RS1), .BADR(RS2), .DADR(Daddr), .B(B_OUT_GPR), .D(D_OUT_GPR), .A(A_OUT_GPR), .AEQZ_out(AEQZ_out)
    );

    MUX4to1 S1MUX ( 
        .a0(PC), .a1(A_OUT), .a2(B_OUT), .a3(MDR_OUT), .sel(S1SEL), .O(S1)
    ); //done all inputs output

    MUX4to1 S2MUX (
        .a0(B_OUT), .a1(imm), .a2(32'b0), .a3({31'b0,1'b1}), .sel(S2SEL), .O(S2)
    ); //done all inputs and outputs

    REG32RST PC_env (
        .CLK(clk), .CE(PCCE), .RST(reset),  .DI(DINT), .DO(PC)
    ); //done all inputs and outputs

    MUX2to1 MDRMUX (
        .a0(DINT), .a1(D_in), .sel(MDRSEL), .O(MDRMUX_OUT)
    ); //done all inputs and outputs

    MUX2to1 DINTMUX (
        .a0(DINT_0_IN), .a1(S1_shifted), .sel(DINTSEL), .O(DINT)
    ); //waiting for the ALU output to connect to a0

    MUX2to1 AMUX (
        .a0(PC), .a1(MAR_OUT), .sel(ASEL), .O(AMUX_out)
    ); //done all inputs and outputs

    SHIFT_ENV shift_env(
        .D_IN(S1), .right(RIGHT), .shift(SHIFT), .D_OUT(S1_shifted)
    ); //done all inputs and outputs

    IR_ENV ir_env_inst (
        .clk(clk), .reset(reset), .D_IN(D_in), .ir_ce(IRCE), .type(TYPE), .JLINK(JLINK), .IR(IR_OUT),
        .opcode(opcode), .rs1(RS1), .rs2(RS2), .rd(RD), .funct(funct), .immediate(imm), .ALUF(ALUF)
    ); // done all inputs and outputs

    ALU alu_inst(
        .A(S1), .B(S2), .ALUF(ALUF), .test(TEST), .ADD(ADD), .ALU_OUT(ALU_OUT)
    );

    ActivationEngine activation_engine_inst (
        .clk(clk), .reset(reset), .data_in(S1), .opcode(opcode),
        .activation_en(act_en), .sigmoid_ready(sigmoid_ready),
        .act_done(), .data_out(activation_out), .ACTIVATION_sel(ACTIVATION_sel),
        .softmax_start(softmax_start), .softmax_base_addr(S1), .softmax_out_addr(S2), .softmax_vec_len(IR_OUT[10:0]),
        .softmax_done(softmax_done), .softmax_active(softmax_active),
        .softmax_mem_addr(softmax_mem_addr), .softmax_mem_data_out(softmax_mem_data_out), .softmax_mem_data_in(softmax_mem_data_in), .softmax_mem_rd(softmax_mem_rd), 
        .softmax_mem_wr(softmax_mem_wr), .softmax_mem_busy(softmax_mem_busy),
        .softmax_dbg_max(), .softmax_dbg_denom(), .softmax_dbg_idx()
        );
    
    multiplier mult(
        .clk(clk), 
        .en(mult_en), 
        .A(S1), 
        .B(S2), 
        .C(mult_out), 
        .ready(mult_ready)
    );

    assign DINT_0_IN = (mult_en)                       ? mult_out
                     : (opcode[5:3] == 3'b111 && TYPE) ? activation_out
                     :                                   ALU_OUT;
    assign DO = MDR_OUT;
	assign AO = {8'b0, AMUX_out[23:0]};
endmodule
