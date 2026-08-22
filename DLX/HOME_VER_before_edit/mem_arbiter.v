// mem_arbiter.v — 2:1 memory bus arbiter: DLX vs Softmax DMA
//
// Sits between mac_fsm and IO_SIM.
// softmax_active=1: DMA owns bus; dlx_ack_n held 1 (mac_fsm stalls in WAIT4ACK).
// softmax_active=0: DLX owns bus; smx_busy=0.
// Pure combinational — no state.
//
// DLX side  : uses mac_fsm active-low protocol (as_n, wr_n, ack_n).
// DMA side  : uses active-high protocol (rd, wr, busy).
// SRAM side : matches IO_SIM.v active-low protocol (AS_N, WR_N, ACK_N).
// in_init   : goes only to monitor_slave, not memory bus — not needed here.

`timescale 1ns/1ps

module mem_arbiter (
    // DLX side — connects to mac_fsm outputs and data_path
    input  wire [31:0] dlx_addr,        // MAO from data_path
    input  wire [31:0] dlx_data_out,    // MDO from data_path
    output wire [31:0] dlx_data_in,     // D_in to data_path
    input  wire        dlx_as_n,        // mac_fsm.as_n  (active low strobe)
    input  wire        dlx_wr_n,        // mac_fsm.wr_n  (active low write)
    output wire        dlx_ack_n,       // → mac_fsm.ack_n (low = done)

    // Softmax DMA side — active-high protocol
    input  wire [31:0] smx_addr,
    input  wire [31:0] smx_data_out,    // DMA → SRAM
    output wire [31:0] smx_data_in,     // SRAM → DMA
    input  wire        smx_rd,
    input  wire        smx_wr,
    output wire        smx_busy,        // mem_ack_n when DMA owns bus

    // Arbiter select (from softmax_subenv.active)
    input  wire        softmax_active,

    // SRAM side — matches IO_SIM.v
    output wire [31:0] mem_addr,
    output wire [31:0] mem_data_out,
    input  wire [31:0] mem_data_in,     // DO from IO_SIM
    output wire        mem_as_n,        // AS_N: low when transaction active
    output wire        mem_wr_n,        // WR_N: low when writing
    input  wire        mem_ack_n        // ACK_N from IO_SIM: low = done
);

    // DMA active-high → active-low for SRAM boundary
    wire smx_as_n = ~(smx_rd | smx_wr);
    wire smx_wr_n = ~smx_wr;

    // Mux active master → SRAM
    assign mem_addr     = softmax_active ? smx_addr     : dlx_addr;
    assign mem_data_out = softmax_active ? smx_data_out : dlx_data_out;
    assign mem_as_n     = softmax_active ? smx_as_n     : dlx_as_n;
    assign mem_wr_n     = softmax_active ? smx_wr_n     : dlx_wr_n;

    // Read data broadcast — only active master consumes it
    assign smx_data_in = mem_data_in;
    assign dlx_data_in = mem_data_in;

    // Busy/ack feedback — mem_ack_n=1: processing, mem_ack_n=0: done
    assign smx_busy  = softmax_active ? mem_ack_n : 1'b0;
    assign dlx_ack_n = softmax_active ? 1'b1      : mem_ack_n;

endmodule
