`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:35:32 12/28/2025 
// Design Name: 
// Module Name:    dlx_control 
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
`define START_OVER(_step)  ((_step) ? S_FETCH : S_INIT)
module dlx_control(
    //--- inputs ---
    input [5:0] opcode,
    input [5:0] funct,
    input clk,
    input reset,
    input step_en,
    input busy,
    input aeqz,
    input softmax_done,
    input sigmoid_ready,
    input mult_ready,
    //--- outputs ---
    output MR,
    output IRce,
    output Ace,
    output Bce,
    output [1:0] S2sel,
    output PCce,
    output add,
    output [1:0] S1sel,
    output Cce,
    output test,
    output Itype,
    output DINTsel,
    output Shift,
    output MDRce,
    output Asel1,
    output MW,
    output GPR_WE,
    output Jlink,
    output MARce,
    output right,
    output in_init,
	output MDRsel,
    // control signals for activation functions
    output [1:0] sigmoid,
    output ACTIVATION_sel,
    output softmax_start,
    output act_en,
    output mult_en,
    // state output
    output [4:0] control_state
    );

    // State Encoding
    localparam [4:0] S_INIT        = 5'd0;   // Initialize
    localparam [4:0] S_FETCH       = 5'd1;   // Fetch instruction
    localparam [4:0] S_DECODE      = 5'd2;   // Decode instruction, read registers, PC+1
    localparam [4:0] S_ALU         = 5'd3;   // R-type ALU operation
    localparam [4:0] S_ALUI        = 5'd4;   // I-type ALU operation (addi)
    localparam [4:0] S_SHIFT       = 5'd5;   // Shift operation
    localparam [4:0] S_TESTI       = 5'd6;   // Test immediate (set instructions)
    localparam [4:0] S_ADDRESSCMP  = 5'd7;   // Address computation for Load/Store
    localparam [4:0] S_LOAD        = 5'd8;   // Load from memory
    localparam [4:0] S_STORE       = 5'd9;   // Store to memory
    localparam [4:0] S_COPYMDR2C   = 5'd10;  // Copy MDR to C register
    localparam [4:0] S_COPYGPR2MDR = 5'd11; // Copy GPR to MDR register
    localparam [4:0] S_WBR         = 5'd12;  // Write Back to Register (R-type)
    localparam [4:0] S_WBI         = 5'd13;  // Write Back to Register (I-type)
    localparam [4:0] S_BRANCH      = 5'd14;  // Branch evaluation
    localparam [4:0] S_BTAKEN      = 5'd15;  // Branch taken
    localparam [4:0] S_JR          = 5'd16;  // Jump Register
    localparam [4:0] S_JALR        = 5'd17;  // Jump and Link Register
    localparam [4:0] S_SAVEPC      = 5'd18;  // Save PC for JALR
    localparam [4:0] S_HALT        = 5'd19;  // Halt state
	localparam [4:0] AFTER_STORE   = 5'd20;  //add delay after store
    // New states for activation functions
    localparam [4:0] S_SIGMOID     = 5'd21;  // sigmoid block
    localparam [4:0] S_SOFTMAX_START = 5'd22;  // Softmax operation start
    localparam [4:0] S_RELU        = 5'd23;  // ReLU operation
    localparam [4:0] S_SOFTMAX_RUN = 5'd24;  // Softmax operation ongoing
    localparam [4:0] S_MULT        = 5'd25;  // Q16.16 multiply (R-type, 3-cycle unit)
		


    // path parameters
    localparam [11:0] D1_INIT_FETCH = 12'b110???_??????;
    localparam [11:0] D2_ALU        = 12'b0000??_1?????;
    localparam [11:0] D3_SIGMOID    = 12'b1110??_??????;
    localparam [11:0] D4_SHIFT      = 12'b0000??_0?????;
    localparam [11:0] D5_ALUI       = 12'b001???_??????;
    localparam [11:0] D6_TESTI      = 12'b011???_??????;
    localparam [11:0] D7_ADR_COMP   = 12'b10????_??????;
    localparam [11:0] D8_JR         = 12'b010??0_??????;
    localparam [11:0] D9_SAVEPC     = 12'b010??1_??????;
    localparam [11:0] D10_SOFTMAX   = 12'b111101_??????;
    localparam [11:0] D11_RELU      = 12'b111100_??????;
    localparam [11:0] D12_BRANCH    = 12'b0001??_??????;
    localparam [11:0] D14_MULT      = 12'b111110_??????;



    // State Registers
    reg [4:0] current_state;

    // Wire Declarations
    wire D13_SL; // choose between load/store
    wire BT; // branch taken?

    // State Machine
    always @(posedge clk) begin
        if (reset) begin
            current_state <= S_INIT;
        end else begin
            case(current_state)
                S_INIT: begin
                    if (step_en) current_state <= S_FETCH;
                end
                S_FETCH: begin
                    if (~busy) current_state <= S_DECODE;
                end
                S_DECODE: begin
                    casez({opcode,funct})
                        D1_INIT_FETCH: current_state <= `START_OVER(step_en);
                        D2_ALU       : current_state <= S_ALU;
                        D3_SIGMOID   : current_state <= S_SIGMOID;
                        D4_SHIFT     : current_state <= S_SHIFT;
                        D5_ALUI      : current_state <= S_ALUI;
                        D6_TESTI     : current_state <= S_TESTI;
                        D7_ADR_COMP  : current_state <= S_ADDRESSCMP;
                        D8_JR        : current_state <= S_JR;
                        D9_SAVEPC    : current_state <= S_SAVEPC;
                        D10_SOFTMAX  : current_state <= S_SOFTMAX_START;
                        D11_RELU     : current_state <= S_RELU;
                        D12_BRANCH   : current_state <= S_BRANCH;
                        D14_MULT     : current_state <= S_MULT;
								default: current_state <= S_HALT;
                    endcase
                end
                S_ALU  : current_state <= S_WBR;
                S_ALUI : current_state <= S_WBI;
                S_SHIFT: current_state <= S_WBR;
                S_TESTI: current_state <= S_WBI;
                S_ADDRESSCMP: current_state <= D13_SL ? S_COPYGPR2MDR : S_LOAD;
                S_LOAD: if(~busy) current_state <= S_COPYMDR2C;
                S_STORE: if(~busy) current_state <= AFTER_STORE;
                S_COPYMDR2C: current_state <= S_WBI;
                S_COPYGPR2MDR: current_state <= S_STORE;
                S_WBR: current_state <= `START_OVER(step_en);
                S_WBI: current_state <= `START_OVER(step_en);
                S_BRANCH: current_state <= BT? S_BTAKEN : `START_OVER(step_en);
                S_BTAKEN: current_state <= `START_OVER(step_en);
                S_JR: current_state <= `START_OVER(step_en);
                S_JALR: current_state <= `START_OVER(step_en);
                S_SAVEPC: current_state <= S_JALR;
                S_HALT: current_state <= S_HALT;
				AFTER_STORE: current_state <= `START_OVER(step_en);
                S_SIGMOID: current_state <= sigmoid_ready ? S_WBI : S_SIGMOID;
                S_RELU: current_state <= S_WBI;
                S_MULT: current_state <= mult_ready ? S_WBR : S_MULT;
                S_SOFTMAX_START: current_state <= S_SOFTMAX_RUN;
                S_SOFTMAX_RUN: current_state <= softmax_done? `START_OVER(step_en): S_SOFTMAX_RUN;
                default: current_state <= S_HALT; // Default transition
            endcase
        end
    end

    // internal assignments
    // Handle D13, BT
    assign D13_SL = opcode[3];
    assign BT = aeqz ^ opcode[0];

    // Output assignments
    assign MR = (current_state == S_FETCH || current_state == S_LOAD)? 1'b1 : 1'b0;
    assign IRce = (current_state == S_FETCH)? 1'b1 : 1'b0;
    assign Ace = (current_state == S_DECODE)? 1'b1 : 1'b0;
    assign Bce = (current_state == S_DECODE)? 1'b1 : 1'b0;
    assign S2sel[0] = (current_state == S_DECODE 
                    || current_state == S_TESTI
                    || current_state == S_ALUI
                    || current_state == S_SIGMOID
                    || current_state == S_RELU
                    || current_state == S_ADDRESSCMP
                    || current_state == S_BTAKEN)? 1'b1 : 1'b0;
    assign S2sel[1] = (current_state == S_DECODE
                    || current_state == S_COPYGPR2MDR
                    || current_state == S_COPYMDR2C
                    || current_state == S_JR
                    || current_state == S_JALR
                    || current_state == S_SAVEPC)? 1'b1 : 1'b0;
    assign PCce = (current_state == S_DECODE
                    || current_state == S_BTAKEN
                    || current_state == S_JR
                    || current_state == S_JALR)? 1'b1 : 1'b0;
    assign add = (current_state == S_DECODE
                    || current_state == S_ALUI
                    || current_state == S_SIGMOID
                    || current_state == S_RELU
                    || current_state == S_ADDRESSCMP
                    || current_state == S_BTAKEN
                    || current_state == S_JR
                    || current_state == S_SAVEPC
                    || current_state == S_JALR)? 1'b1 : 1'b0;
    assign S1sel[0] = (current_state == S_ALU
                    || current_state == S_SOFTMAX_START
                    || current_state == S_TESTI
                    || current_state == S_ALUI
                    || current_state == S_SIGMOID
                    || current_state == S_RELU
                    || current_state == S_MULT
                    || current_state == S_SHIFT
                    || current_state == S_ADDRESSCMP
                    || current_state == S_COPYMDR2C
                    || current_state == S_JR
                    || current_state == S_JALR)? 1'b1 : 1'b0;
    assign S1sel[1] = (current_state == S_COPYGPR2MDR
                    || current_state == S_COPYMDR2C)? 1'b1 : 1'b0; 
    assign Cce = (current_state == S_ALU
                    || current_state == S_SHIFT
                    || current_state == S_TESTI
                    || current_state == S_ALUI
                    || (current_state == S_SIGMOID && sigmoid_ready)
                    || (current_state == S_MULT && mult_ready)
                    || current_state == S_RELU
                    || current_state == S_SAVEPC
                    || current_state == S_COPYMDR2C)? 1'b1 : 1'b0;
    assign test = (current_state == S_TESTI)? 1'b1 : 1'b0;
    assign Itype = (current_state == S_TESTI
                    || current_state == S_ALUI
                    || current_state == S_SIGMOID
                    || current_state == S_RELU
                    || current_state == S_WBI)? 1'b1 : 1'b0;
    assign DINTsel = (current_state == S_SHIFT 
                    || current_state == S_COPYGPR2MDR
                    || current_state == S_COPYMDR2C)? 1'b1 : 1'b0;
    assign Shift = (current_state == S_SHIFT)? 1'b1 : 1'b0;
    assign MDRce = (current_state == S_LOAD || current_state == S_COPYGPR2MDR)? 1'b1 : 1'b0;
    assign Asel1 = (current_state == S_LOAD || current_state == S_STORE)? 1'b1 : 1'b0; //fix_me rename
    assign MW = (current_state == S_STORE)? 1'b1 : 1'b0;
    assign GPR_WE = (current_state == S_WBR 
                  || current_state == S_WBI
                  || current_state == S_JALR)? 1'b1 : 1'b0;
    assign Jlink = (current_state == S_JALR)? 1'b1 : 1'b0;
    assign control_state = current_state;
    assign MARce = (current_state == S_ADDRESSCMP)? 1'b1 : 1'b0;
    assign right = (current_state == S_SHIFT)? funct[1] : 1'b0;
    assign in_init = (current_state == S_INIT|| current_state == S_HALT) ? 1'b1 : 1'b0; 
	assign MDRsel = (current_state == S_LOAD)? 1'b1 : 1'b0;
    // control signals for activation functions
    assign softmax_start = (current_state == S_SOFTMAX_START);
    assign sigmoid = (current_state == S_SIGMOID) ? opcode[1:0] : 2'b0;
    assign ACTIVATION_sel = (current_state == S_SIGMOID)? 1'b0 : (current_state == S_RELU)? 1'b1 : 1'b0;
    assign act_en = (current_state == S_SIGMOID);
    assign mult_en = (current_state == S_MULT);

endmodule