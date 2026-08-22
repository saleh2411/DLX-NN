// softmax_subenv — wrapper: softmax_ctrl_fsm + softmax_dma
//
// Top-level softmax block instantiated by ActivationEngine.
// Authoritative done = dma_done (fires after last write commits, not when
// FSM done fires, which is one cycle earlier than the final memory write).
//
// active: held high from start pulse until dma_done pulse.
// Used by mem_arbiter to route memory bus to softmax DMA.

`timescale 1ns/1ps

module softmax_subenv (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,

    // Instruction-decoded operands (R-type)
    input  wire [31:0] base_addr,   // rs1 register value — input vector byte base
    input  wire [31:0] out_addr,    // rs2 register value — output vector byte base
    input  wire [10:0] vec_len,     // instr[10:0] — vector length (max 2047)

    // Memory interface (to mem_arbiter / SRAM)
    output wire [31:0] mem_addr,
    output wire [31:0] mem_data_out,
    input  wire [31:0] mem_data_in,
    output wire        mem_rd,
    output wire        mem_wr,
    input  wire        mem_busy,

    // Status
    output wire        done,        // pulses 1 cycle when all writes committed
    output reg         active,      // high while softmax is running

    // Debug
    output wire [31:0] dbg_max,
    output wire [31:0] dbg_denom,
    output wire [10:0] dbg_idx
);

    // ----------------------------------------------------------------
    // Internal handshake wires (FSM <-> DMA)
    // ----------------------------------------------------------------
    wire        engine_req_next;
    wire [31:0] engine_data_in;
    wire        engine_valid;
    wire [31:0] engine_result_out;
    wire        engine_result_valid;
    wire        engine_result_ack;
    wire        pass;
    wire        fsm_done;    // FSM internal done (not exported)
    wire        dma_done;

    // ----------------------------------------------------------------
    // active flag: set on start, clear on dma_done
    // ----------------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            active <= 1'b0;
        else if (start)
            active <= 1'b1;
        else if (dma_done)
            active <= 1'b0;
    end

    assign done = dma_done;

    // ----------------------------------------------------------------
    // softmax_ctrl_fsm
    // ----------------------------------------------------------------
    softmax_ctrl_fsm u_fsm (
        .clk                (clk),
        .rst                (rst),
        .start              (start),
        .vec_len            (vec_len),

        .engine_data_in     (engine_data_in),
        .engine_valid       (engine_valid),
        .engine_req_next    (engine_req_next),
        .engine_result_out  (engine_result_out),
        .engine_result_valid(engine_result_valid),
        .engine_result_ack  (engine_result_ack),
        .pass               (pass),
        .done               (fsm_done),

        .dbg_max            (dbg_max),
        .dbg_denom          (dbg_denom),
        .dbg_idx            (dbg_idx)
    );

    // ----------------------------------------------------------------
    // softmax_dma
    // ----------------------------------------------------------------
    softmax_dma u_dma (
        .clk                (clk),
        .rst                (rst),
        .start              (start),
        .base_addr          (base_addr),
        .out_addr           (out_addr),
        .vec_len            (vec_len),

        .mem_addr           (mem_addr),
        .mem_data_out       (mem_data_out),
        .mem_data_in        (mem_data_in),
        .mem_rd             (mem_rd),
        .mem_wr             (mem_wr),
        .mem_busy           (mem_busy),

        .engine_req_next    (engine_req_next),
        .engine_data_in     (engine_data_in),
        .engine_valid       (engine_valid),
        .engine_result_out  (engine_result_out),
        .engine_result_valid(engine_result_valid),
        .engine_result_ack  (engine_result_ack),
        .pass               (pass),

        .dma_done           (dma_done)
    );

endmodule
