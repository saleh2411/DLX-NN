`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:46 12/25/2025 
// Design Name: 
// Module Name:    mac_fsm 
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
module mac_fsm(
    input clk,
    input ack_n,
    input reset,
    input mr,
    input mw,
    output busy,
    output wr_n,
    output as_n,
    output [1:0] mac_state
    );

//states defines
parameter WAIT4REQ = 2'b00;
parameter WAIT4ACK = 2'b01;
parameter TERMINATE = 2'b10;

//state reg
reg [1:0] current_state = WAIT4REQ;

//always block to manage state transitions
always @(posedge clk) begin

    if (reset == 1) begin
        current_state <= WAIT4REQ;
    end else begin
        case (current_state)
            WAIT4REQ: begin
                if (mr == 1 || mw == 1) begin
                    current_state <= WAIT4ACK;
                end
            end
            WAIT4ACK: begin
                if (ack_n == 0) begin
                    current_state <= TERMINATE;
                end
            end
            TERMINATE: begin
                current_state <= WAIT4REQ;
            end
            default: begin
                current_state <= WAIT4REQ;
            end
        endcase
    end

end

assign busy = (current_state == WAIT4ACK || (current_state == WAIT4REQ &&(mr == 1 || mw == 1))) ? (1'b1 & ack_n) : 1'b0;
assign as_n = (current_state == WAIT4ACK) ? 1'b0 : 1'b1;
assign wr_n = (current_state == WAIT4ACK && mw == 1) ? 1'b0 : 1'b1;
assign mac_state = current_state;

endmodule