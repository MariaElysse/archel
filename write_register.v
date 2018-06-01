`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:40:17 05/31/2018 
// Design Name: 
// Module Name:    write_register 
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
module write_register(
	input wire clk,
	
	input wire turn,
	input wire [639:0] lfrom_vram,
	output wire [8:0] vram_addr,
	input wire [9:0] x_pos,
	input wire [8:0] y_pos,
	output wire activate_write,

	input wire vram_turn,
	input wire [3:0] regnum,
	input wire [15:0] regdat,
	output wire reg_done
    );
	reg [3:0] letter_n_of_string; //which letter we're writing R_. FFFF
	reg [5:0] letter; //which letter we're writing (abcdef...)
	reg let_done;
	write_letter w_let(
		.clk(clk),
		.let(letter),
		
		.x_pos(x_pos + letter_n_of_string * 7),
		.y_pos(y_pos),
		.line_from_vram(lfrom_vram),
		.line_addr(vram_addr),
		.activate_write(activate_write),
		
		.let_done(let_done)
	);
	
	always @(
endmodule
