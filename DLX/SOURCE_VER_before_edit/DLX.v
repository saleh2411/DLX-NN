`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:50:55 01/11/2026 
// Design Name: 
// Module Name:    DLX 
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
module DLX(
    input clk,
    input reset,
    input [31:0] D_in,
    input step_en,
    input ack_n,
    input [4:0] Daddr,
    //outputs from mac
    output busy,
    output wr_n_new,
    output as_n_new,
    output [1:0] mac_state,
    //outputs from dlx_control
    output MR,
    output MW,
    output GPR_WE,
    output [4:0] control_state,
    output IRCE,
    output PCCE,
    output ACE,
    output BCE,
    output CCE,
    output MDRCE,
    output [1:0] S1SEL,
    output [1:0] S2SEL,
    output DINTSEL,
    output MDRSEL,
    output ASEL,
    output ADD,
    output TEST,
    output SHIFT,
    output ITYPE,
    output JLINK,
    output MARCE,
    output RIGHT,
    output in_init,
    //output from data path
    output [31:0] AO_new,
    output [31:0] DO_new,
    output [31:0] D_OUT_GPR
    );


//wires and regs
wire [5:0] opcode;
wire [5:0] funct;
wire AEQZ_out;
wire softmax_active;
wire ACTIVATION_sel;
wire softmax_start;
wire softmax_done;
wire [31:0] softmax_mem_addr;
wire [31:0] softmax_mem_data_out;
wire [31:0] softmax_mem_data_in;
wire softmax_mem_rd;
wire softmax_mem_wr;
wire softmax_mem_busy;
wire [31:0] AO;
wire [31:0] DO;
wire as_n;
wire wr_n;
wire [1:0] sigmoid;
wire [31:0] dlx_din_w;
wire        dlx_ack_n_w;
wire act_en;
wire sigmoid_ready;
wire mult_en;
wire mult_ready;
//data path instantiation
data_path u_data_path (
    .clk       (clk), //connected
    .reset     (reset), //connected
    .D_in      (dlx_din_w), //connected
    .Daddr     (Daddr), //connected
    .IRCE      (IRCE), //connected
    .PCCE      (PCCE), //connected
    .ACE       (ACE), //connected
    .BCE       (BCE), //connected
    .CCE       (CCE),  //connected
    .MARCE     (MARCE), //connected
    .MDRCE     (MDRCE), //connected
    .GPR_WE    (GPR_WE), //connected
    .S1SEL     (S1SEL), //connected
    .S2SEL     (S2SEL), //connected
    .DINTSEL   (DINTSEL), //connected
    .MDRSEL    (MDRSEL), //connected
    .ASEL      (ASEL), //connected
    .ADD       (ADD), //connected
    .TEST      (TEST), //connected
    .SHIFT     (SHIFT), //connected
    .RIGHT     (RIGHT), //connected
    .TYPE      (ITYPE), //connected
    .JLINK     (JLINK), //connected
    .AO        (AO), //connected
    .DO        (DO), //connected
    .opcode    (opcode), //connected
    .funct     (funct), //connected
    .AEQZ_out  (AEQZ_out), //connected
    .D_OUT_GPR (D_OUT_GPR), //connected
    .ACTIVATION_sel(ACTIVATION_sel),
    .softmax_start(softmax_start),
    .softmax_done(softmax_done),
    .softmax_mem_addr(softmax_mem_addr), //out
    .softmax_mem_data_out(softmax_mem_data_out), // out
    .softmax_mem_data_in(softmax_mem_data_in), //in
    .softmax_mem_rd(softmax_mem_rd), //out
    .softmax_mem_wr(softmax_mem_wr), //out
    .softmax_mem_busy(softmax_mem_busy), //in
    .softmax_active(softmax_active),
    .act_en(act_en),
    .sigmoid_ready(sigmoid_ready),
    .mult_en(mult_en),
    .mult_ready(mult_ready)
    );


//control unit instantiation
control u_control (
    .clk            (clk), //connected
    .step_en        (step_en), //connected
    .reset          (reset), //connected
    .ack_n          (dlx_ack_n_w), //connected
    .op_code        (opcode), //connected
    .funct          (funct), //connected
    .aeqz           (AEQZ_out), //connected
    .softmax_done   (softmax_done),

    .busy           (busy), //connected
    .wr_n           (wr_n), //connected
    .as_n           (as_n), //connected
    .mac_state      (mac_state), //connected

    .MR             (MR), //connected
    .IRce           (IRCE), //connected
    .Ace            (ACE), //connected
    .Bce            (BCE), //connected
    .S2sel          (S2SEL), //connected
    .PCce           (PCCE), //connected
    .add            (ADD), //connected
    .S1sel          (S1SEL), //connected
    .Cce            (CCE),  //connected
    .test           (TEST), //connected
    .Itype          (ITYPE), //connected
    .DINTsel        (DINTSEL), //connected
    .Shift          (SHIFT), //connected
    .MDRce          (MDRCE), //connected
    .Asel1          (ASEL), //connected
    .MW             (MW), //connected
    .GPR_WE         (GPR_WE), //connected
    .Jlink          (JLINK), //connected
    .MARce          (MARCE), //connected
    .right        (RIGHT), //connected
    .in_init       (in_init), //connected
    .control_state  (control_state), //connected
	.MDRsel(MDRSEL),
    //activation function control
    .softmax_start(softmax_start),
    .sigmoid(sigmoid),
    .ACTIVATION_sel(ACTIVATION_sel),
    .act_en(act_en),
    .sigmoid_ready(sigmoid_ready),
    .mult_en(mult_en),
    .mult_ready(mult_ready)
);

mem_arbiter mem_arbiter(
    .dlx_addr(AO),
    .dlx_data_out(DO),
    .dlx_data_in(dlx_din_w),
    .dlx_as_n(as_n),
    .dlx_wr_n(wr_n),
    .dlx_ack_n(dlx_ack_n_w),


    .smx_addr(softmax_mem_addr),
    .smx_data_out(softmax_mem_data_out),
    .smx_data_in(softmax_mem_data_in),
    .smx_rd(softmax_mem_rd),
    .smx_wr(softmax_mem_wr),
    .smx_busy(softmax_mem_busy),

    .softmax_active(softmax_active),

    .mem_addr(AO_new),
    .mem_data_out(DO_new),
    .mem_data_in(D_in),
    .mem_as_n(as_n_new),
    .mem_wr_n(wr_n_new),
    .mem_ack_n(ack_n)

);
endmodule
