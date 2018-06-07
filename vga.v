`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:08 05/24/2018 
// Design Name: 
// Module Name:    vga 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: enabled pixels will be grn r:0,b:0,g:3'b111. disabled pixels black(0/0/0)
//
//////////////////////////////////////////////////////////////////////////////////
module vga(
	input wire dclk, //pixel clk 25mhz
	input wire rst,  //async reset (may not be necessary)
	input wire [0:639] line, 
	output wire [8:0] vram_read_addr,
	output wire hsync, //horizontal sync
	output wire vsync, //vertical sync 
	output reg [2:0] red, //red value for pixel
	output reg [2:0] grn, //pixel grn value
	output reg [1:0] blu //blu 
    );

parameter hpixels = 800; //640 actual px
parameter vlines = 521;  //480 actual lines

parameter realpx = 640; 
parameter realln = 480;

parameter hpulse = 96; //length of hsync pulse 
parameter vpulse = 2;


//i dont have any idea what these mean but the vga protocol needs these
parameter h_backporch = 144; 
parameter h_frntporch = 784;

parameter v_backporch = 31; //maybe this is 35, change if it's off the screen at the top or bottom
parameter v_frntporch = 511; 

//vram 
//which position are we at? (h/v)
reg [9:0] horiz_px;
reg [9:0] verti_ln;
reg [18:0] px;
wire [9:0] actual_x; 
wire [9:0] actual_y; 

assign actual_y = (verti_ln >= v_backporch && verti_ln < v_frntporch)? (verti_ln-v_backporch) : 0;
assign actual_x = (horiz_px >= h_backporch && horiz_px < h_frntporch)? (horiz_px-h_backporch) : 0;
//sync pulses 
assign hsync = (horiz_px < hpulse)? 0:1;
assign vsync = (verti_ln < vpulse)? 0:1;
assign vram_read_addr = actual_y;
//access to the ram

always @(posedge dclk, posedge rst) begin 
if (rst) begin 
	horiz_px <= 0;
	verti_ln <= 0; 
	px <= 0;
end //(clr)
else begin
	if (horiz_px < hpixels - 1) begin 
		horiz_px <= horiz_px + 1;
	end
	else begin
		horiz_px <= 0;
		if (verti_ln < vlines - 1) begin
			verti_ln <= verti_ln + 1;
		end
		else begin 
			verti_ln <= 0;
		end
	end
	if (
		actual_x != 0 && actual_y != 0) begin 
		red <= 3'b000;
		blu <= 2'b00;
		if (line[actual_x-1] == 1'b1) begin 
			grn <= 3'b111;
		end 
		else begin 
			grn <= 3'b000;
		end;
	end
	else begin  //outside the display range
		red <= 3'b000;
		grn <= 3'b000;
		blu <= 2'b00;
	end
end //else clr
end //always
endmodule
