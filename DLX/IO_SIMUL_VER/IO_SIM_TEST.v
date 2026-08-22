`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2020 11:07:12 AM
// Design Name: 
// Module Name: IO_SIM_TEST
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


module IO_SIM_TEST;
   
      reg CLK_IN;
      reg RST_IN;
      reg STEP_IN;
      reg AS_N;
      reg WR_N;
      reg [31:0] MAO;
      reg [31:0] MDO;
      wire CLK;
      wire RST;
      wire STEP;
      wire ACK_N;
      wire [31:0] DO;
      
      
      initial begin
      CLK_IN = 1;
      RST_IN=1;
      STEP_IN=0;
      AS_N=1;
      WR_N=1;
      MAO=32'h00000004;
      MDO=32'h12345678;
      
      
      #100.1  	 RST_IN=0;
					// One cycle STEP_EN
      #100  	 STEP_IN=1;
      #100  	 STEP_IN=0;
					// Read transaction 
      #100 	    AS_N=0;
      #400 		 AS_N=1;
					//Write transaction (Read afer Write)
      #100 		 AS_N=0;
					 WR_N=0;
		#400 		 AS_N=1;
					 WR_N=1;
					// Read transaction (Read afer Write)
      #100		 AS_N=0;    
      #400		 AS_N=1;
      end
      
      
      
      always begin
        #50 CLK_IN = ~CLK_IN;  // timescale is 1ns so #5 provides 100MHz clock
    end
      
      
      IO_SIM #( 10) uut
      (
      .CLK_IN(CLK_IN),
      .RST_IN(RST_IN),
      .STEP_IN(STEP_IN),
      .AS_N(AS_N),
      .WR_N(WR_N),
      .MAO(MAO),
      .MDO(MDO),
      .CLK(CLK),
      .RST(RST),
      .STEP(STEP),
       .ACK_N(ACK_N),
       .DO(DO)
       );  
endmodule
