module shift_exp (
    input  wire signed [31:0] x,     // Q16.16, <= 0 in softmax context
    output wire        [31:0] out
);
    localparam ONE_Q16 = 32'h0001_0000;

    wire signed [31:0] v;
    assign v = $signed(x) + ($signed(x) >>> 1);

    wire signed [15:0] v_int;
    wire        [15:0] v_frac;
    assign v_int  = v[31:16];   
    assign v_frac = v[15:0];    

    wire [31:0] base;
    assign base = ONE_Q16 + {16'h0, (v_frac >> 1)};


    wire [15:0] abs_v_int;
    assign abs_v_int = ($signed(v_int) >= 0) ? v_int : (~v_int + 1'b1);

    wire underflow;
    assign underflow = (abs_v_int > 16'd31);

    assign out = underflow            ? 32'h0 :
                 (v_int[15]) ? (base >> abs_v_int[4:0]) :
                                        (base << abs_v_int[4:0]);

endmodule
