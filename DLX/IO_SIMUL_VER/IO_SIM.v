`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2020 01:38:12 PM
// Design Name: 
// Module Name: IO_SIM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IO_SIM #(parameter ADDR_WIDTH = 10)// active addres, bits part of the full bus address(32 bits)
   (
     input wire CLK_IN,
     input wire RST_IN,
     input wire STEP_IN,
     input wire AS_N,
     input wire WR_N,
     input wire [31:0] MAO,
     input wire [31:0] MDO,
     output wire CLK,
     output wire RST,
     output wire STEP,
     output wire ACK_N,
     output wire [31:0] DO
    );
    
    reg [3:0] s_reg; //4 bits shift register
	 reg on_write;
    wire [31:0] do_a;
    wire [31:0] mdo_a;
    wire we;
    wire we_s;
    
    assign CLK=CLK_IN;
    assign RST=RST_IN;
    assign STEP=STEP_IN;
    assign ACK_N=~s_reg[3];
    assign DO= (ACK_N==0&WR_N==1)? do_a: 32'hxxxxxxxx;
    assign mdo_a= (we==1) ? MDO: 32'hxxxxxxxx;
    assign we= ~(ACK_N|WR_N);
	 assign we_s =WR_N&~on_write;
    
    always @ (posedge CLK_IN)
	 
     begin
        if(AS_N | we_s)
            s_reg <= 4'b0001;
        else 
            s_reg<= s_reg<<1;
           // end
		on_write<=WR_N;
         end
         
         
    REG_sram #(ADDR_WIDTH) EXTERNAL_RAM
   (
    .i_clk(CLK),
    .i_addr(MAO[ADDR_WIDTH-1:0]), 
    .i_write(we),
    .i_data(mdo_a),
    .o_data(do_a) 
    );
    
endmodule
