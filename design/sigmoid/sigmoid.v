// -----------------------------------------------------------------------------
// Sigmoid approximation for 32-bit signed Q16.16 fixed-point
//
// Implements the piecewise-linear approximation (for x >= 0):
//   y = 1                          , x >= 5.0
//   y = (1/32)x + 27/32            , 2.375 <= x < 5.0
//   y = (1/8)x  + 5/8              , 1.125 <= x < 2.375
//   y = (1/8)x  + 0.60606          , 0.875 <= x < 1.125
//   y = (1/4)x  + 1/2              , 0     <= x < 0.875
//
// For x < 0, uses symmetry: sigmoid(x) = 1 - sigmoid(|x|)
//
// Input : x  (signed Q16.16)
// Output: y  (unsigned range [0,1] but kept as signed 32-bit in Q16.16)
// -----------------------------------------------------------------------------
module sigmoid(
    input  wire  [31:0] x,
    output reg   [31:0] y
);

    // Constants in Q16.16 - b in y = ax + b
    localparam B_0 = 32'h0001_0000; // 1.0
    localparam B_1 = 32'h0000_D800; // 0.84375 = 27/32
    localparam B_2 = 32'h0000_A000; // 0.625 = 5/8
    localparam B_3 = 32'h0000_9B27; // 0.60606
    localparam B_4 = 32'h0000_8000; // 0.5 = 1/2

    // Thresholds
    localparam X_0 = 32'h0005_0000; // 5.0
    localparam X_1 = 32'h0002_6000; // 2.375 = 19/8
    localparam X_2 = 32'h0001_2000; // 1.125 = 9/8
    localparam X_3 = 32'h0000_E000; // 0.875 = 7/8
    localparam X_4 = 32'h0000_0000; // 0.0


    // Internal signals
    reg        x_neg;
    reg [31:0] ax;      // |x|
    reg [31:0] y_pos;   // sigmoid(|x|) approx (for non-negative)


    always @* begin
        // Sign and absolute value (beware: x = -2^31 edge; not expected in NN ranges)
        x_neg = x[31];
        ax = x_neg ? (~x + 32'h0000_0001) : x;
        
        // Piecewise compute y_pos for ax >= 0
        if (ax >= X_0) begin
            y_pos = B_0; // y = 1
        end else if (ax >= X_1) begin
            y_pos = (ax >>> 5) + B_1; // y = (1/32)x + 0.84375
        end else if (ax >= X_2) begin
            y_pos = (ax >>> 3) + B_2; // y = (1/8)x + 0.625
        end else if (ax >= X_3) begin
            y_pos = (ax >>> 3) + B_3; // y = (1/8)x + 0.60606
        end else if (ax >= X_4) begin
            y_pos = (ax >>> 2) + B_4; // y = (1/4)x + 0.5
        end else begin
            y_pos = 32'h0000_0000; // Should not occur for non-negative x
        end


        if  (x_neg) y = B_0 - y_pos; //sigmoid(x) = 1 - sigmoid(|x|)
        else   y      = y_pos;
        
        // // Optional safety clamp to [0,1] in Q16.16
        // if (y < X_0) y = X_0;
        // if (y > B_1) y = B_1;
    end

endmodule
