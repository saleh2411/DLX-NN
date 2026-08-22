`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:31:19 12/07/2025 
// Design Name: 
// Module Name:    write_machine 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module write_machine(
    input clk,
    input step_en,
    input ack_n,
	input reset,
    output wr_n,
    output as_n,
    output stop_n,
    output in_init,
    output [31:0] D_OUT,
    output [31:0] ADD_OUT,
	 output [1:0] state
    );

    // State defenitions
    parameter [1:0] WAIT = 2'b00;
    parameter [1:0] STORE = 2'b01;
    parameter [1:0] WAIT4ACK = 2'b10;
    parameter [1:0] TERMINATE = 2'b11;

    // state register
    reg [1:0] current_state;
    
    //store prev stop_n value
    reg prev_stop_n;

    // address counter register
    reg [31:0] address_counter;

    // state machine
    always @(posedge clk) begin
        if (reset) begin
            current_state <= WAIT;
            address_counter <= 32'b0;
        end else begin
            case (current_state)
                WAIT: begin
                    if (step_en) begin
                        current_state <= STORE;
                    end
                end

                STORE: begin
                    current_state <= WAIT4ACK;
                end

                WAIT4ACK: begin
                    if (ack_n == 1'b0) begin
                        current_state <= TERMINATE;
                        address_counter <= address_counter + 1;

                    end
                end

                TERMINATE: begin
                    current_state <= WAIT;
                end

                default: begin
                    current_state <= WAIT;
                end
            endcase
        end
    end

//store prev stop_n value
always @(posedge clk) begin
    if (current_state == WAIT4ACK & stop_n == 1'b1) begin 
        prev_stop_n <= 1'b0;
    end else begin
        prev_stop_n <= stop_n;
    end
end

//output logic
assign in_init = (current_state == WAIT) ? 1'b1 : 1'b0;
assign wr_n = (current_state == STORE | current_state == WAIT4ACK) ? 1'b0 : 1'b1;
assign as_n = (current_state == STORE | current_state == WAIT4ACK) ? 1'b0 : 1'b1;
assign stop_n = (current_state == WAIT4ACK) ? (prev_stop_n | ~ack_n) : 1'b1;

//assign outputs
assign ADD_OUT = address_counter;
assign D_OUT = 32'hCAFECAFE;
assign state = current_state;

endmodule
