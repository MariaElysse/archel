`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:15:44 05/30/2018 
// Design Name: 
// Module Name:    vram_muxer 
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
module vram_muxer( //select one of the inputs to be activated and passed on to the vram every clk
		input clk,
		input rst,
		
		input wire [7:0] [8:0] vram_addr , //from the module that wants to do the write
		input wire [7:0] [639:0] write_vram,
		input wire [7:0] write_active,
		output wire[7:0] active_writer, //to the module wanting to do the write (wait ur turn lol)
		output wire [7:0] [639:0] read_vram,
		output wire [639:0] to_vram_write,
		input wire  [639:0] from_vram_read,
		output wire [8:0] to_vram_addr,
		output wire to_vram_wea
   );
	reg [3:0] active_writer_n = 0;
	
	assign active_writer = 1'b1 << active_writer_n;
	assign to_vram_write = write_vram[active_writer_n];
	assign to_vram_addr = vram_addr[active_writer_n];
	assign to_vram_wea = write_active[active_writer_n];
	assign from_vram_read = from_vram_read[active_writer_n];
	
	always @ (posedge clk) begin 
		active_writer_n = active_writer_n + 1;
	end
endmodule
