// -----------------------------------------------------------------------------
// sigmoid_subenv – Sigmoid-based activation sub-environment
// for 32-bit signed Q16.16 fixed-point
//
// Computes sigmoid, tanh, or GELU using a SINGLE sigmoid instance
// to minimize area. The function is selected via opcode input.
//
// Mathematical relationships:
//   sigmoid(x) = sigmoid(x)
//   tanh(x)    = 2*sigmoid(2x) - 1
//   GELU(x)    = x * sigmoid(1.702*x)
//
// function_select encoding (Opcode [1:0]):
//   2'b00 : Sigmoid
//   2'b01 : Tanh
//   2'b10 : GELU
//   2'b11 : Reserved (outputs 0)
//
// Input : x      (signed Q16.16)
//         opcode (2-bit function selector)
// Output: y      (signed Q16.16)
// -----------------------------------------------------------------------------

module sigmoid_subenv (
    input  wire clk,
    input  wire [31:0] x,
    input  wire en,
    input  wire [1:0]  opcode,
    output wire  [31:0] y,
    output wire ready
);

    // ==========================================================
    // Opcode definitions
    // ==========================================================
    localparam SIGMOID = 3'd0;
    localparam TANH    = 3'd1;
    localparam GELU    = 3'd2;

    // ==========================================================
    // Constants in Q16.16
    // ==========================================================
    localparam NEG_ONE     = 32'hFFFF_0000;  // -1.0 in Q16.16

    // ==========================================================
    // Internal signals
    // ==========================================================
    //wire [1:0]  function_select; // 2-bit function selector
    wire [31:0] x_gelu; // 1.702*x for GELU
    wire [31:0] x_tanh; // 2*x for Tanh
    wire [31:0] y_tanh; // 2*sigmoid(2x) - 1 for Tanh
    wire [31:0] y_gelu; // x*sigmoid(1.702*x) for GELU
    wire [31:0] sigmoid_input;  // Muxed input to sigmoid
    wire [31:0] sigmoid_output; // Output from sigmoid
    wire is_gelu = (opcode == GELU); // Flag for GELU operation


    // ==========================================================
    // Single Sigmoid Instance (shared resource)
    // ==========================================================
    sigmoid sigmoid_core (
        .x(sigmoid_input),
        .y(sigmoid_output)
    );

    // ==========================================================
    // Muxing logic for sigmoid input based on function selection
    // ==========================================================
    // Shift-add approximation of 1.702 (no multiplier):
    //   1 + 1/2 + 1/8 + 1/16 + 1/64 + 1/256 = 1.70703125
    // $signed() forces arithmetic right-shift so negative x scales correctly.
    assign x_gelu  = $signed(x)
                   + ($signed(x) >>> 1)
                   + ($signed(x) >>> 3)
                   + ($signed(x) >>> 4)
                   + ($signed(x) >>> 6)
                   + ($signed(x) >>> 8);
    assign x_tanh  = x <<< 1;         // Multiply x by 2 for Tanh

    MUX4_32bit sigmoid_input_mux (
        .sel(opcode), // Selects which function's input goes to sigmoid
        .A(x),                 // For Sigmoid: input is x
        .B(x_tanh),            // For Tanh: input is 2*x
        .C(x_gelu),            // For GELU: input is 1.702*x
        .D(32'b0),             // Reserved (outputs 0)
        .O(sigmoid_input)      // Mux output goes to sigmoid input
    );

    // ==========================================================
    // Output logic based on function selection
    // ==========================================================

    assign y_tanh = (sigmoid_output <<< 1) + NEG_ONE; // Tanh output: 2*sigmoid(2x) - 1

    // GELU output: Q16.16 signed multiply  y = (x * sigmoid_output) >> 16
    // Widen to 64 bits so no intermediate bits are lost, then arithmetic-shift
    // back into Q16.16.
    reg [31:0] x_g1, sig_g1;
    always @(posedge clk) begin
        x_g1   <= x;
        sig_g1 <= sigmoid_output;
    end
    wire signed [63:0] y_gelu_prod = $signed(x_g1) * $signed({1'b0, sig_g1[16:0]});
    assign y_gelu = y_gelu_prod >>> 16;

    reg cnt;
    always @(posedge clk)
        if (!en) cnt <= 1'b0;
        else     cnt <= 1'b1;
    assign ready = is_gelu ? cnt : 1'b1;

    MUX4_32bit output_mux (
        .sel(opcode), // Selects which function's output is assigned to y
        .A(sigmoid_output),   // For Sigmoid: output is sigmoid(x)
        .B(y_tanh),           // For Tanh: output is 2*sigmoid(2x) - 1
        .C(y_gelu),           // For GELU: output is x*sigmoid(1.702*x)
        .D(32'b0),            // Reserved (outputs 0)
        .O(y)                 // Mux output goes to final output y
    );

endmodule