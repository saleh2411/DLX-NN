`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:35:09 12/28/2025 
// Design Name: 
// Module Name:    control 
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
module control(
    //--- inputs ---
    input clk,
    input step_en,
    input reset,
    input ack_n,
    input [5:0] op_code,
    input [5:0] funct,
    input aeqz,
    input softmax_done,
    //--- outputs - mac_FSM ---
    output busy,
    output wr_n,
    output as_n,
    output [1:0] mac_state,
    // --- outputs - control_dlx ---
    output MR,
    output IRce,
    output Ace,
    output Bce,
    output [0:1] S2sel,
    output PCce,
    output add,
    output [0:1] S1sel,
    output Cce,
    output test,
    output Itype,
    output DINTsel,
    output Shift,
    output MDRce,
    output Asel1,
    output MW,
    output GPR_WE,
    output Jlink,
    output MARce,
    output right,
    output in_init,
	 output MDRsel,
    // state output
    output [4:0] control_state,
    //activation function control
    output softmax_start,
    output [1:0] sigmoid,
    output ACTIVATION_sel,
    output softmax_active,
    output act_en,
    input sigmoid_ready,
    output mult_en,
    input mult_ready
    );


    wire mr;
    wire mw;


    dlx_control ctrl(
        //--- inputs ---
        .opcode(op_code),
        .funct(funct),
        .clk(clk),
        .reset(reset),
        .step_en(step_en),
        .aeqz(aeqz),
        .busy(busy),
        .softmax_done(softmax_done),
        //--- outputs ---
        .MR(mr),
        .IRce(IRce),
        .Ace(Ace),
        .Bce(Bce),
        .S2sel(S2sel),
        .PCce(PCce),
        .add(add),
        .S1sel(S1sel),
        .Cce(Cce),
        .test(test),
        .Itype(Itype),
        .DINTsel(DINTsel),
        .Shift(Shift),
        .MDRce(MDRce),
        .Asel1(Asel1),
        .MW(mw),
        .GPR_WE(GPR_WE),
        .Jlink(Jlink),
        .MARce(MARce),
        .right(right),
        .in_init(in_init),
		.MDRsel(MDRsel),
        // state output
        .control_state(control_state),
        //activation function control
        .softmax_start(softmax_start),
        .sigmoid(sigmoid),
        .ACTIVATION_sel(ACTIVATION_sel),
        .act_en(act_en),
        .sigmoid_ready(sigmoid_ready),
        .mult_en(mult_en),
        .mult_ready(mult_ready)
    );

    mac_fsm mac(
        //--- inputs ---
        .clk(clk),
        .ack_n(ack_n),
        .reset(reset),
        .mr(mr),
        .mw(mw),
        //--- outputs ---
        .busy(busy),
        .wr_n(wr_n),
        .as_n(as_n),
        .mac_state(mac_state)
    );

    assign MW = mw;
	 assign MR = mr;

endmodule
