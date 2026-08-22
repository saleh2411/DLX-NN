// softmax_ctrl_fsm — Algorithm 3 control FSM (paper: Hirayae et al., ICECS 2025)
//
// Implements the two-pass online softmax.  Memory I/O is handled by
// softmax_dma; this module receives one Q16.16 element at a time and
// does all arithmetic.
//
// Pass 1 (Pre-Norm): tracks running max m and rescaled denominator d.
// Pass 2 (Normalization): computes y[j] = shift_exp(x[j]-m) * pwl_recip(d).
//
// Handshake:
//   P1/P2 load  — FSM asserts engine_req_next; DMA asserts engine_valid + data.
//   P2 store    — FSM asserts engine_result_valid + result;
//                 DMA asserts engine_result_ack when write committed.
//
// Area: ONE shared shift_exp instance (muxed input); ONE pwl_reciprocal.
// S_P1_COMPUTE is split into A (rescale) and B (b-term + accumulate) so the
// single shift_exp is used on alternate cycles.  Cost: +1 cycle per pass-1 element.

`timescale 1ns/1ps

module softmax_ctrl_fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [10:0] vec_len,

    // DMA handshake
    input  wire [31:0] engine_data_in,
    input  wire        engine_valid,
    output reg         engine_req_next,
    output reg  [31:0] engine_result_out,
    output reg         engine_result_valid,
    input  wire        engine_result_ack,
    output reg         pass,               // 0=pass1, 1=pass2 (DMA uses for addr)
    output reg         done,

    // debug
    output wire [31:0] dbg_max,
    output wire [31:0] dbg_denom,
    output wire [10:0] dbg_idx
);

    // ----------------------------------------------------------------
    // State encoding
    // ----------------------------------------------------------------
    localparam [3:0]
        S_IDLE         = 4'd0,
        S_P1_LOAD      = 4'd1,
        S_P1_COMPUTE_A = 4'd2,   // cycle A: shift_exp(m_prev - m_new); update m
        S_P1_COMPUTE_B = 4'd3,   // cycle B: shift_exp(x - m_new);      update d
        S_P1_NEXT      = 4'd4,
        S_P2_LOAD      = 4'd5,
        S_P2_COMPUTE_A = 4'd6,   // register f = shift_exp(x - m_final)
        S_P2_STORE     = 4'd7,
        S_P2_NEXT      = 4'd8,
        S_DONE         = 4'd9,
        S_P2_COMPUTE_B = 4'd10,  // y = f * recip (single multiply)
        S_P1_COMPUTE_C = 4'd11;  // pass-1: d_new = a + b (isolated add)

    localparam NEG_INF = 32'h8000_0000;

    // ----------------------------------------------------------------
    // Registers
    // ----------------------------------------------------------------
    reg  [3:0]          state;
    reg signed [31:0]   m_reg;        // running max  (init: NEG_INF)
    reg        [31:0]   d_reg;        // running denom (init: 0)
    reg        [10:0]   elem_idx;
    reg signed [31:0]   x_latch;      // current element latched from DMA
    reg        [31:0]   rescale_reg;  // latches shift_exp output from cycle A
    reg        [31:0]   recip_reg;    // 1/d, computed once at pass-2 entry
    reg signed [31:0]   f_reg;        // shift_exp(x - m_final), registered
    reg signed [31:0]   a_reg;        // pass-1: d_reg * rescale_reg, registered
    reg signed [31:0]   b_reg;        // pass-1: shift_exp(x - m_new), registered

    assign dbg_max   = m_reg;
    assign dbg_denom = d_reg;
    assign dbg_idx   = elem_idx;

    // ----------------------------------------------------------------
    // Shared shift_exp — input muxed by state
    // S_P1_COMPUTE_A : m_reg - m_new   (old_max - new_max, <= 0)
    // S_P1_COMPUTE_B : x_latch - m_reg (x - new_max, m_reg already updated, <= 0)
    // S_P2_COMPUTE   : x_latch - m_reg (x - m_final, <= 0)
    // All other states: input is 0 (shift_exp(0)=1.0, output ignored)
    // ----------------------------------------------------------------

    wire signed [31:0] m_new;
    assign m_new = ($signed(x_latch) > $signed(m_reg)) ? x_latch : m_reg;

    wire signed [31:0] se_input;
    assign se_input = (state == S_P1_COMPUTE_A) ? ($signed(m_reg)   - $signed(m_new))
                                                 : ($signed(x_latch) - $signed(m_reg));

    wire [31:0] se_out;
    shift_exp u_se (.x(se_input), .out(se_out));

    // ----------------------------------------------------------------
    // Pass 1 — cycle B multiplier: a = d_reg * rescale_reg
    // ----------------------------------------------------------------
    wire signed [63:0] p1_mul;
    assign p1_mul = $signed(d_reg) * $signed(rescale_reg);
    wire signed [31:0] p1_a;
    assign p1_a = p1_mul[47:16];

    // d_new = a + b   (both registered in S_P1_COMPUTE_B, summed in _C)
    wire [31:0] p1_d_new;
    assign p1_d_new = $signed(a_reg) + $signed(b_reg);

    // ----------------------------------------------------------------
    // Pass 2 — multiplier: y = f * recip   (f = se_out in S_P2_COMPUTE)
    // ----------------------------------------------------------------
    wire [31:0] p2_recip;
    pwl_reciprocal u_recip (.d(d_reg), .recip(p2_recip));

    wire signed [63:0] p2_mul;
    assign p2_mul = $signed(f_reg) * $signed(recip_reg);
    wire signed [31:0] p2_y;
    assign p2_y = p2_mul[47:16];

    // ----------------------------------------------------------------
    // FSM
    // ----------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state               <= S_IDLE;
            m_reg               <= NEG_INF;
            d_reg               <= 32'h0;
            elem_idx            <= 11'h0;
            x_latch             <= 32'h0;
            rescale_reg         <= 32'h0;
            recip_reg           <= 32'h0;
            f_reg               <= 32'h0;
            a_reg               <= 32'h0;
            b_reg               <= 32'h0;
            engine_req_next     <= 1'b0;
            engine_result_out   <= 32'h0;
            engine_result_valid <= 1'b0;
            pass                <= 1'b0;
            done                <= 1'b0;
        end else begin
            // defaults
            engine_req_next     <= 1'b0;
            engine_result_valid <= 1'b0;
            done                <= 1'b0;

            case (state)

                // --------------------------------------------------
                S_IDLE: begin
                    if (start) begin
                        m_reg    <= NEG_INF;
                        d_reg    <= 32'h0;
                        elem_idx <= 16'h0;
                        pass     <= 1'b0;
                        state    <= S_P1_LOAD;
                    end
                end

                // --------------------------------------------------
                S_P1_LOAD: begin
                    engine_req_next <= 1'b1;
                    if (engine_valid) begin
                        x_latch         <= engine_data_in;
                        engine_req_next <= 1'b0;   // last assign wins
                        state           <= S_P1_COMPUTE_A;
                    end
                end

                // --------------------------------------------------
                // Cycle A: se_input = m_reg - m_new
                //          latch rescale; update m_reg to m_new
                S_P1_COMPUTE_A: begin
                    rescale_reg <= se_out;   // shift_exp(old_max - new_max)
                    m_reg       <= m_new;    // m_reg holds OLD value this cycle (NBA)
                    state       <= S_P1_COMPUTE_B;
                end

                // --------------------------------------------------
                // Cycle B: se_input = x_latch - m_reg (m_reg is now m_new)
                //          b = se_out; a = d_reg * rescale_reg; d_new = a + b
                S_P1_COMPUTE_B: begin
                    a_reg <= p1_a;       // d_reg * rescale_reg (d_reg still old)
                    b_reg <= se_out;     // shift_exp(x - m_new)
                    state <= S_P1_COMPUTE_C;
                end

                // --------------------------------------------------
                // Cycle C: d_new = a_reg + b_reg (isolated add)
                S_P1_COMPUTE_C: begin
                    d_reg <= p1_d_new;
                    state <= S_P1_NEXT;
                end

                // --------------------------------------------------
                S_P1_NEXT: begin
                    if (elem_idx == vec_len - 11'h1) begin
                        elem_idx  <= 11'h0;
                        pass      <= 1'b1;
                        recip_reg <= p2_recip;   // d_reg final -> 1/d computed ONCE
                        state     <= S_P2_LOAD;
                    end else begin
                        elem_idx <= elem_idx + 11'h1;
                        state    <= S_P1_LOAD;
                    end
                end

                // --------------------------------------------------
                S_P2_LOAD: begin
                    engine_req_next <= 1'b1;
                    if (engine_valid) begin
                        x_latch         <= engine_data_in;
                        engine_req_next <= 1'b0;
                        state           <= S_P2_COMPUTE_A;
                    end
                end

                // --------------------------------------------------
                // A: latch f = shift_exp(x - m_final)
                S_P2_COMPUTE_A: begin
                    f_reg <= se_out;
                    state <= S_P2_COMPUTE_B;
                end
                // B: y = f * recip  (single multiply, recip precomputed)
                S_P2_COMPUTE_B: begin
                    engine_result_out <= p2_y;
                    state             <= S_P2_STORE;
                end

                // --------------------------------------------------
                S_P2_STORE: begin
                    engine_result_valid <= 1'b1;
                    if (engine_result_ack) begin
                        state <= S_P2_NEXT;
                    end
                end

                // --------------------------------------------------
                S_P2_NEXT: begin
                    if (elem_idx == vec_len - 11'h1) begin
                        state <= S_DONE;
                    end else begin
                        elem_idx <= elem_idx + 11'h1;
                        state    <= S_P2_LOAD;
                    end
                end

                // --------------------------------------------------
                S_DONE: begin
                    done  <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;

            endcase
        end
    end

endmodule
