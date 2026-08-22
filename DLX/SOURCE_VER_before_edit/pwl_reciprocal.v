module pwl_reciprocal (
    input  wire [31:0] d,
    output wire [31:0] recip
);

    wire [15:0] int_part;
    assign int_part = d[31:16];

    reg [2:0] seg;
    always @(*) begin
        if (int_part[15:8] != 8'h00)
            seg = 3'd7;
        else casez (int_part[7:0])
            8'b1???????: seg = 3'd7;
            8'b01??????: seg = 3'd6;
            8'b001?????: seg = 3'd5;
            8'b0001????: seg = 3'd4;
            8'b00001???: seg = 3'd3;
            8'b000001??: seg = 3'd2;
            8'b0000001?: seg = 3'd1;
            default:    seg = 3'd0;
        endcase
    end

    reg signed [31:0] a_q;
    reg signed [31:0] b_q;

    always @(*) begin
        case (seg)
            3'd0: begin a_q = 32'hFFFF85EF; b_q = 32'h0001688C; end
            3'd1: begin a_q = 32'hFFFFE17C; b_q = 32'h0000B446; end
            3'd2: begin a_q = 32'hFFFFF85F; b_q = 32'h00005A23; end
            3'd3: begin a_q = 32'hFFFFFE18; b_q = 32'h00002D11; end
            3'd4: begin a_q = 32'hFFFFFF86; b_q = 32'h00001688; end
            3'd5: begin a_q = 32'hFFFFFFE1; b_q = 32'h00000B44; end
            3'd6: begin a_q = 32'hFFFFFFF8; b_q = 32'h000005A2; end
            default: begin a_q = 32'hFFFFFFFE; b_q = 32'h000002D1; end
        endcase
    end

    wire signed [63:0] prod;
    assign prod = $signed(a_q) * $signed(d);

    wire signed [31:0] a_times_d;
    assign a_times_d = prod[47:16];

    assign recip = a_times_d + b_q;

endmodule
