// softmax_dma — 2-pass sequential memory controller
//
// Drives memory reads for both passes and memory writes for pass 2.
// Coordinates with softmax_ctrl_fsm via engine_* handshake signals.
//
// Memory protocol (must be respected by SRAM model):
//   Assert mem_rd/mem_wr → SRAM asserts mem_busy within 1 cycle →
//   when mem_busy deasserts, transaction complete (data valid on mem_data_in).
//
// Pass 1 per element: D_WAIT_REQ → D_MEM_READ → D_FEED → D_NEXT
// Pass 2 per element: D_WAIT_REQ → D_MEM_READ → D_FEED →
//                     D_WAIT_RESULT → D_MEM_WRITE → D_NEXT
//
// Address: word-addressed 32-bit words → addr = base + idx
// vec_len==0 is treated as a no-op (dma_done pulses immediately) — see D_IDLE.
// dma_done pulses 1 cycle after last write is committed to memory.
// Use dma_done (not FSM done) as the authoritative top-level done signal,
// since FSM done fires before the final memory write completes.

`timescale 1ns/1ps

module softmax_dma (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [31:0] base_addr,    // input vector word base (from rs1 register)
    input  wire [31:0] out_addr,     // output vector word base (from rs2 register)
    input  wire [10:0] vec_len,

    // Memory interface
    output reg  [31:0] mem_addr,
    output reg  [31:0] mem_data_out, // to SRAM (write)
    input  wire [31:0] mem_data_in,  // from SRAM (read)
    output reg         mem_rd,
    output reg         mem_wr,
    input  wire        mem_busy,

    // softmax_ctrl_fsm handshake
    input  wire        engine_req_next,   // FSM requests next element
    output reg  [31:0] engine_data_in,    // element to FSM
    output reg         engine_valid,      // element data valid
    input  wire [31:0] engine_result_out, // computed y from FSM
    input  wire        engine_result_valid,
    output reg         engine_result_ack, // DMA acked the result
    input  wire        pass,              // 0=pass1, 1=pass2

    output reg         dma_done           // pulses 1 cycle; all writes committed
);

    localparam [2:0]
        D_IDLE        = 3'd0,
        D_WAIT_REQ    = 3'd1,
        D_MEM_READ    = 3'd2,
        D_FEED        = 3'd3,
        D_WAIT_RESULT = 3'd4,
        D_MEM_WRITE   = 3'd5,
        D_NEXT        = 3'd6,
        D_DONE        = 3'd7;

    reg [2:0]  state;
    reg [10:0] idx;
    reg [31:0] data_latch;
    reg [31:0] result_latch;
    reg        mem_pending;    // set when a mem transaction is in-flight

    // base_addr/out_addr come from the datapath S1/S2 buses, which are only
    // guaranteed valid during the start pulse (S_SOFTMAX_START drives S1sel=A;
    // in S_SOFTMAX_RUN the mux reverts to PC). Latch them at start.
    reg [31:0] base_reg;
    reg [31:0] out_reg;

    // Word addresses for current element. The DLX/IO_SIM memory increments
    // consecutive 32-bit words by one, matching normal lw/sw addressing.
    wire [31:0] rd_addr = base_reg + {21'b0, idx};
    wire [31:0] wr_addr = out_reg  + {21'b0, idx};

    always @(posedge clk) begin
        if (rst) begin
            state             <= D_IDLE;
            idx               <= 11'h0;
            data_latch        <= 32'h0;
            result_latch      <= 32'h0;
            base_reg          <= 32'h0;
            out_reg           <= 32'h0;
            mem_pending       <= 1'b0;
            mem_addr          <= 32'h0;
            mem_data_out      <= 32'h0;
            mem_rd            <= 1'b0;
            mem_wr            <= 1'b0;
            engine_data_in    <= 32'h0;
            engine_valid      <= 1'b0;
            engine_result_ack <= 1'b0;
            dma_done          <= 1'b0;
        end else begin
            // defaults — overridden below as needed
            mem_rd            <= 1'b0;
            mem_wr            <= 1'b0;
            engine_valid      <= 1'b0;
            engine_result_ack <= 1'b0;
            dma_done          <= 1'b0;

            case (state)

                // --------------------------------------------------
                D_IDLE: begin
                    if (start) begin
                        idx         <= 11'h0;
                        base_reg    <= base_addr;  // S1 bus valid only now
                        out_reg     <= out_addr;   // S2 bus valid only now
                        mem_pending <= 1'b0;
                        // GUARD: vec_len==0 makes the D_NEXT compare
                        // (vec_len-1) underflow to 11'h7FF, which would run a
                        // 2048-element runaway DMA writing over live code/data
                        // while the CPU is stalled on the bus. Complete
                        // immediately instead so the CPU resumes cleanly.
                        state       <= (vec_len == 11'h0) ? D_DONE : D_WAIT_REQ;
                    end
                end

                // --------------------------------------------------
                // Wait for FSM to request next element (both passes)
                D_WAIT_REQ: begin
                    if (engine_req_next)
                        state <= D_MEM_READ;
                end

                // --------------------------------------------------
                // Hold mem_rd high; wait for SRAM to assert then
                // deassert mem_busy; latch data.
                D_MEM_READ: begin
                    mem_rd   <= 1'b1;   // hold high (overrides default 0)
                    mem_addr <= rd_addr;
                    if (!mem_pending) begin
                        mem_pending <= 1'b1;
                    end else if (!mem_busy) begin
                        data_latch  <= mem_data_in;
                        mem_pending <= 1'b0;
                        state       <= D_FEED;
                    end
                end

                // --------------------------------------------------
                // Assert engine_valid + data until FSM latches
                // (FSM deasserts engine_req_next when it latches)
                D_FEED: begin
                    engine_valid   <= 1'b1;             // [A] assert
                    engine_data_in <= data_latch;
                    if (!engine_req_next) begin
                        engine_valid <= 1'b0;           // [B] wins over [A]
                        state        <= pass ? D_WAIT_RESULT : D_NEXT;
                    end
                end

                // --------------------------------------------------
                // Pass 2 only: wait for FSM to produce y; ack it;
                // latch for the upcoming write.
                D_WAIT_RESULT: begin
                    if (engine_result_valid) begin
                        result_latch      <= engine_result_out;
                        engine_result_ack <= 1'b1;  // 1-cycle pulse
                        state             <= D_MEM_WRITE;
                    end
                end

                // --------------------------------------------------
                // Pass 2 only: write y to output memory.
                D_MEM_WRITE: begin
                    mem_wr       <= 1'b1;   // hold high
                    mem_addr     <= wr_addr;
                    mem_data_out <= result_latch;
                    if (!mem_pending) begin
                        mem_pending <= 1'b1;
                    end else if (!mem_busy) begin
                        mem_pending <= 1'b0;
                        state       <= D_NEXT;
                    end
                end

                // --------------------------------------------------
                // Advance index.  At end of pass 1: reset idx for
                // pass 2.  At end of pass 2: all done.
                // GUARD: compare with >= (not ==) so a corrupted idx that
                // skips past the last element still terminates the pass
                // instead of wrapping and re-walking memory.
                D_NEXT: begin
                    if (idx >= vec_len - 11'h1) begin
                        if (pass) begin
                            state <= D_DONE;
                        end else begin
                            idx   <= 11'h0;   // reset for pass 2
                            state <= D_WAIT_REQ;
                        end
                    end else begin
                        idx   <= idx + 11'h1;
                        state <= D_WAIT_REQ;
                    end
                end

                // --------------------------------------------------
                D_DONE: begin
                    dma_done <= 1'b1;
                    state    <= D_IDLE;
                end

                default: state <= D_IDLE;

            endcase
        end
    end

endmodule
