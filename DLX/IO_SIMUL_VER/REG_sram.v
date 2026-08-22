`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:19:16 08/02/2020 
// Design Name: 
// Module Name:    REG_sram 
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
module REG_sram #(parameter ADDR_WIDTH = 8)
   (
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr, 
    input wire i_write,
    input wire [31:0] i_data,
    output wire [31:0] o_data 
    );

    reg [31:0] memory_array [0:2**ADDR_WIDTH-1]; 
    
    initial begin
    $readmemh("sram.data", memory_array);
    end

    always @ (posedge i_clk)
    begin
        if(i_write) begin
            memory_array[i_addr] <= i_data;
        end
       
    end
	 
	 assign o_data = memory_array[i_addr];
endmodule


