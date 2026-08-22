`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:15:22 01/11/2026 
// Design Name: 
// Module Name:    IO 
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
module IO(
    input clk_in,
    input rst,
    input pc_step_en,

    // --- DEBUG ---

    //outputs from mac
    output busy,
    output wr_n,
    output as_n,
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
    output TYPE,
    output JLINK,
    output MARCE,
    output RIGHT,
    output in_init,
    //output from data path

    output [31:0] D_OUT_GPR
    );


    // DLX to IO
    wire AS_N;
    wire WR_N;
    wire [31:0] MAO;
    wire [31:0] MDO;

    // IO to DLX
    wire io_step_en;
    wire io_reset;
    wire io_clk;
    wire io_ack_n;
    wire [31:0] IO_DO;

    DLX dlx(
    .clk(io_clk),
    .reset(io_reset),
    .D_in(IO_DO),
    .step_en(io_step_en),
    .ack_n(io_ack_n),
    .Daddr(),
    //outputs from mac
    .busy(busy),
    .wr_n_new(WR_N), // to IO
    .as_n_new(AS_N), // to IO
    .mac_state(mac_state),
    //outputs from dlx_control
    .MR(MR),
    .MW(MW),
    .GPR_WE(GPR_WE),
    .control_state(control_state),
    .IRCE(IRCE),
    .PCCE(PCCE),
    .ACE(ACE),
    .BCE(BCE),
    .CCE(CCE),
    .MDRCE(MDRCE),
    .S1SEL(S1SEL),
    .S2SEL(S2SEL),
    .DINTSEL(DINTSEL),
    .MDRSEL(MDRSEL),
    .ASEL(ASEL),
    .ADD(ADD),
    .TEST(TEST),
    .SHIFT(SHIFT),
    .ITYPE(TYPE),
    .JLINK(JLINK),
    .MARCE(MARCE),
    .RIGHT(RIGHT),
    .in_init(in_init),
    //output from data path
    .AO_new(MAO),
    .DO_new(MDO),    //data?
    .D_OUT_GPR(D_OUT_GPR) // data?
    );


IO_SIM io_sim(
        // --- external input ports ---
        .CLK_IN(clk_in),
        .RST_IN(rst),
        .STEP_IN(pc_step_en),
        // --- internal input ports ---
        .AS_N(AS_N),
        .WR_N(WR_N),
        .MAO(MAO),
        .MDO(MDO),
        // --- output ports ---
        .CLK(io_clk),
        .RST(io_reset),
        .STEP(io_step_en),
        .ACK_N(io_ack_n),
        .DO(IO_DO)
);

    assign wr_n = WR_N;
    assign as_n = AS_N;
endmodule
