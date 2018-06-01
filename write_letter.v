`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:37:19 05/31/2018 
// Design Name: 
// Module Name:    write_letter 
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
// consider: clocking weirdness (might have to @ posedge clock as well and have turn be 2 clocks long
module write_letter(
	input wire clk,
	input wire [5:0] let, //which letter (0-38)
	
	input wire [9:0] x_pos, //0-639 screen and letters indexed from top left downward
	input wire [8:0] y_pos, //0-479
	
	input wire [639:0] line_from_vram, //actual pixel data
	input wire vram_turn, //is it our turn to r/w from the vram?
	output wire[8:0] line_addr, //output: which line are we reading from vram
	output reg activate_write, //output: are we writing to the vram?
	output wire [639:0] line_to_vram,
	output wire let_done //output: are we done writing this letter to the vram?
    );

reg  [639:0] updated_line; 
reg  [639:0] line_mask;
reg  [3:0] let_line = 0; 
wire [8:0] let_addr;
wire [6:0] let_data ;
assign line_to_vram = updated_line; //idk why this isnt just a register output
assign line_addr = y_pos;
assign let_done = let_line > 9; //consider changing to > 10
assign let_addr = let + let_line * 39; //which specific letter line we want

letters lets_(
	.clka(clk),
	.addra(let_addr),
	.douta(let_data)
	);
	
always @ (posedge vram_turn) begin //which line of the letter do you need today sir
	if (let_line == 9) begin         //letters are 7-wide, 10-high (10x, 7y)
		let_line <= 0;
	end
	else begin 
		let_line <= let_line + 1; 
	end 
end 

always @ (posedge vram_turn) begin //read the vram and letter, then change the updated_line register
	activate_write = 0;
	line_mask = 0;
	line_mask = ~(7'b1111111 << (x_pos - 639)); //it's a mask, everywhere is 1 except the place i want to clear. consider problem from below (shifting fill)
	updated_line = line_from_vram & line_mask; //clear the current vram data from the spot we want to write to
	updated_line = 0;
	updated_line = let_data ; //apparently it "may" fill the rest of the larger register with zeroes. MAY? fuckin shit
	updated_line = updated_line << (x_pos - 639); //just make it two operations instead i guess, would have been nicer to have it be one
	updated_line = line_from_vram | updated_line; //write to the space made by the above mask; 
	activate_write = 1;
end
endmodule
