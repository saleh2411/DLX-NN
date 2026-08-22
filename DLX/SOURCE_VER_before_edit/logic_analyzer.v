`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:27:05 11/23/2025 
// Design Name: 
// Module Name:    logic_analyzer 
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
module logic_analyzer(
    input clk,
    input [31:0] DIN,
    input [4:0] AI,
    input step_en,
    input in_init,
    input stop_n,
    output [7:0] STS,
    output [31:0] DOUT
    );
	 
	 
	//Rregs
	wire la_run;
	wire cnt_rst;
	wire [4:0] cnt;
	wire sts_ce;
	wire cnt_ce;
	wire [4:0] mux_out;
	wire stop_flag;
	//Wires
	reg [4:0] status_reg = 4'h0;
	reg sts_ce_reg = 0;
	reg in_int_reg = 0;
	reg run_flag = 0;
	//reg init_stop = 0;
	
	//instances
	CNT5 counter(.CLK(clk),.RST(cnt_rst),.CE(cnt_ce),.CNT(cnt));
	MUX5bit mux5(.A(AI),.B(cnt),.sel(la_we),.O(mux_out));
	RAM32x32 ram(.CLK(clk),.ADDR(mux_out),.WE(la_we),.DI(DIN),.DO(DOUT));
	
	//logic assigns
	assign la_run = (run_flag | step_en); 
	assign la_we = la_run & stop_n;
	assign sts_ce = sts_ce_reg & ~la_run; 
	assign cnt_rst = sts_ce;
	assign cnt_ce = la_we;
	assign STS [4:0] = status_reg;
	assign STS[7:5] = 3'h000;
	assign stop_flag = in_init & (~in_int_reg);

	//always block
	always @(posedge clk) begin
	   //init_stop <= ~(in_init & ~(in_int_n));
		run_flag <= (run_flag | step_en) & (~stop_flag);
		in_int_reg <= in_init;
		sts_ce_reg <= la_run;
		
		//status logic
		if (sts_ce == 1) begin
			status_reg <= cnt;
		end else begin
			status_reg <= status_reg;
			
		end
		
		
	end
	
endmodule
