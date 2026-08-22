// Verilog test fixture created from schematic E:\adlx\HOME_Problem\HOME_VER\ex_top_sch.sch - Mon Mar 24 15:31:11 2025

`timescale 1ns / 1ps

module ex_top_sch_ex_top_sch_sch_tb();

// Inputs
   reg reset;
   reg clock;
   reg ce_reg1;
   reg ce_reg2;
   reg [15:0] data_in1;
   reg [15:0] data_in2;
   reg mux_sel;
   reg buf_en1;
   reg buf_en2;

// Output
   wire [15:0] data_mux_out;
   wire [15:0] data_buf_out;

// Bidirs

// Instantiate the UUT
   ex_top_sch UUT (
		.reset(reset), 
		.clock(clock), 
		.ce_reg1(ce_reg1), 
		.ce_reg2(ce_reg2), 
		.data_in1(data_in1), 
		.data_in2(data_in2), 
		.mux_sel(mux_sel), 
		.buf_en1(buf_en1), 
		.buf_en2(buf_en2), 
		.data_mux_out(data_mux_out), 
		.data_buf_out(data_buf_out)
   );
	   initial  
   	clock = 0;
     always 	 #10 clock = ~clock;
	 
	 
	
	
	
// Initialize Inputs
       initial 
		 
		 begin
		reset = 0;
		ce_reg1 = 0;
		ce_reg2 = 0;
		data_in1 = 16'h0;
		data_in2 = 16'h0;
		mux_sel = 0;
		buf_en1 = 0;
		buf_en2 = 0;


		// Wait 101 ns for global reset to start
		#52;
		reset = 1;
		#40; 
      reset = 0;
	   #60;		


// write register 1
		 data_in1 = 16'h1234;
		 #40;
		 ce_reg1 = 1;
       #20;
		 ce_reg1 = 0;
	   #60;
// write register 2		
		 data_in2 = 16'hABCD;
		 #40;
		 ce_reg2 = 1;
       #20;
		 ce_reg2 = 0;
	   #60;		

// mux sel		 
		 #20;
		 mux_sel = 1;
		 #60;
		 mux_sel = 0;
		 
		 
// enable buffer 1 

		 #60;
		 buf_en1 = 1;
		 #100;
		 buf_en1 = 0;
		 #100;
	
// enable buffer 2 

		 buf_en2 = 1;
		 #100;
		 buf_en2 = 0;
	
// enable buffer 1 and 2 together  

		 #100;
		 buf_en1 = 1;
		 buf_en2 = 1;
		 #100;
		 buf_en1 = 0;
		 buf_en2 = 0;
		 #200;
	
	  end
	  

	
		
		
endmodule
