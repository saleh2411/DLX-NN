// -----------------------------------------------------------------------------
// ActivationEngine.v — Unified Activation Function Engine
//
// Supports: Sigmoid, Tanh, GELU, ReLU (combinational)
//           Softmax (multi-cycle with DMA)
//
// For Sigmoid/Tanh/GELU/ReLU: Single-cycle, result on data_out immediately
// For Softmax: Multi-cycle, requires memory access via softmax interface
// -----------------------------------------------------------------------------

module ActivationEngine(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] data_in,
    input  wire [5:0]  opcode,          // Function selector
    
    // Combinational outputs (Sigmoid/Tanh/GELU/ReLU)
    output wire        act_done,        // Always 1 for combinational functions
    output wire [31:0] data_out,
    input wire         ACTIVATION_sel,
    input  wire        activation_en,
    output wire        sigmoid_ready,
    
    // Softmax control interface (R-type: rs1=base, rs2=out, instr[10:0]=vec_len)
    input  wire        softmax_start,   // Start softmax operation
    input  wire [31:0] softmax_base_addr,  // Input vector base address (rs1 value)
    input  wire [31:0] softmax_out_addr,   // Output vector base address (rs2 value)
    input  wire [10:0] softmax_vec_len,    // Vector length (instr[10:0])
    output wire        softmax_done,    // Softmax complete
    output wire        softmax_active,  // Softmax is running (for mem arbiter)

    // Softmax memory interface (directly to mem_arbiter)
    output wire [31:0] softmax_mem_addr,
    output wire [31:0] softmax_mem_data_out,
    input  wire [31:0] softmax_mem_data_in,
    output wire        softmax_mem_rd,
    output wire        softmax_mem_wr,
    input  wire        softmax_mem_busy,

    // Debug outputs
    output wire [31:0] softmax_dbg_max,
    output wire [31:0] softmax_dbg_denom,
    output wire [10:0] softmax_dbg_idx
);

    // =========================================================================
    // Function encoding (opcode[2:0])
    // =========================================================================
    localparam [2:0] SIGMOID = 3'd0;
    localparam [2:0] TANH    = 3'd1;
    localparam [2:0] GELU    = 3'd2;
    localparam [2:0] RELU    = 3'd3;
    localparam [2:0] SOFTMAX = 3'd7;
    
    wire [2:0] func_sel = opcode[2:0];
    
    // =========================================================================
    // Sigmoid/Tanh/GELU (shared sigmoid core)
    // =========================================================================
    wire [31:0] sigmoid_out;
    
    sigmoid_subenv u_sigmoid (
        .clk(clk),
        .en(activation_en),
        .x(data_in),
        .opcode(opcode[1:0]),  // 00=sigmoid, 01=tanh, 10=GELU
        .y(sigmoid_out),
        .ready(sigmoid_ready)
    );
    
    // =========================================================================
    // ReLU (simple max(0, x))
    // =========================================================================
    wire [31:0] relu_out;
    
    ReLU u_relu (
        .x(data_in),
        .y(relu_out)
    );
    
    // =========================================================================
    // Softmax (multi-cycle with DMA)
    // =========================================================================
    softmax_subenv u_softmax (
        .clk            (clk),
        .rst            (reset),
        .start          (softmax_start),
        .base_addr      (softmax_base_addr),
        .out_addr       (softmax_out_addr),
        .vec_len        (softmax_vec_len),
        .done           (softmax_done),
        .active         (softmax_active),
        .mem_addr       (softmax_mem_addr),
        .mem_data_out   (softmax_mem_data_out),
        .mem_data_in    (softmax_mem_data_in),
        .mem_rd         (softmax_mem_rd),
        .mem_wr         (softmax_mem_wr),
        .mem_busy       (softmax_mem_busy),
        .dbg_max        (softmax_dbg_max),
        .dbg_denom      (softmax_dbg_denom),
        .dbg_idx        (softmax_dbg_idx)
    );
    
    // =========================================================================
    // Output mux (for combinational functions)
    // =========================================================================
    reg [31:0] data_out_mux;

    // always @(*) begin
    //     case (func_sel)
    //         SIGMOID: data_out_mux = sigmoid_out;
    //         TANH:    data_out_mux = sigmoid_out;
    //         GELU:    data_out_mux = sigmoid_out;
    //         RELU:    data_out_mux = relu_out;
    //         default: data_out_mux = 32'b0;
    //     endcase
    // end
    

    assign data_out = (ACTIVATION_sel == 1'b0) ? sigmoid_out : relu_out;
    
    // Combinational functions are always "done" in 1 cycle
    // Softmax done is handled separately via softmax_done output
    assign act_done = (func_sel != SOFTMAX) ? 1'b1 : softmax_done;

endmodule