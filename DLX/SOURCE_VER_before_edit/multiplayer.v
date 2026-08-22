`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// multiplier — Q16.16 signed multiply for the MULT instruction
//
//   C = (A * B) >> 16   (exact: bits [47:16] of the 64-bit signed product)
//
// Two register stages so the DSP48 cascade never sits in one long path;
// XST absorbs them into the DSP pipeline registers.
//
// Handshake: same as sigmoid_subenv — control holds `en` in S_MULT,
// `ready` rises on the 3rd cycle when C is stable.
// -----------------------------------------------------------------------------
module multiplier(
    input  wire clk,
    input  wire en, // high while control sits in S_MULT
    input  wire [31:0] A, // Q16.16 signed (S1 = R(RS1))
    input  wire [31:0] B, // Q16.16 signed (S2 = R(RS2))
    output wire [31:0] C, // Q16.16 signed product
    output wire ready
);

    reg signed [63:0] prod, prod_r;
    reg [1:0] cnt;

    always @(posedge clk) begin
        prod <= $signed(A) * $signed(B);
        prod_r <= prod;
    end
    
    always @(posedge clk)
        if (!en) cnt <= 2'd0;
        else if (cnt != 2'd2) cnt <= cnt + 2'd1;
    assign ready = (cnt == 2'd2);

    assign C = prod_r[47:16];

endmodule
