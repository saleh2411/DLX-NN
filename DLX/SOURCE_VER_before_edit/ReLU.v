// -----------------------------------------------------------------------------
// ReLU for 32-bit signed Q16.16 fixed-point
//
// Definition:
//   y = ReLU(x) = max(0, x)
//
// Input : x  (signed Q16.16)
// Output: y  (signed Q16.16)
// Notes : If x < 0 (sign bit = 1) => y = 0, else y = x
// -----------------------------------------------------------------------------

module ReLU(
    input  [31:0] x,
    output [31:0] y
    );

    assign y = (x[31] == 1'b1) ? 32'h0000_0000 : x;          

endmodule
