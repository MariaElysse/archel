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
		
		input wire  [17:0] vram_addr , //from the module that wants to do the write
		input wire  [1279:0] write_vram,
		input wire  [1:0] write_active,
		output wire [1:0] active_writer, //to the module wanting to do the write (wait ur turn lol)
		output wire [1279:0] read_vram,
		output wire [639:0] to_vram_write,
		input wire  [639:0] from_vram_read,
		output wire [8:0] to_vram_addr,
		output wire to_vram_wea
   );
	reg active_writer_n = 0;
	
	assign active_writer = (active_writer_n)? 2'b10 : 2'b01; //if 1, else 
	assign to_vram_write = (active_writer_n)? write_vram[1279:640]: write_vram[639:0];
	assign to_vram_addr = (active_writer_n)? vram_addr[17:9]: vram_addr[8:0];
	assign to_vram_wea = write_active[active_writer_n];
	assign read_vram = (active_writer_n)? {from_vram_read, {640{1'b0}}} : {{640{1'b0}}, from_vram_read};
	always @ (posedge clk) begin 
		active_writer_n <= ~active_writer_n;
	end
endmodule
