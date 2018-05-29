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
// Additional Comments: enabled pixels will be green r:0,b:0,g:3'b111. disabled pixels black(0/0/0)
//
//////////////////////////////////////////////////////////////////////////////////
module vga(
	input wire dclk, //pixel clk 25mhz
	input wire rst,  //async reset (may not be necessary)
	input wire [639:0] line, 
	output wire hsync, //horizontal sync
	output wire vsync, //vertical sync 
	output reg [2:0] red, //red value for pixel
	output reg [2:0] grn, //pixel green value
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

parameter v_backporch = 31;
parameter v_backporch = 511; 

//vram 
//which position are we at? (h/v)
reg [9:0] horiz_px;
reg [9:0] verti_ln;
reg [18:0] px;

//sync pulses 
assign hsync = (hc < hpulse)? 0:1;
assign vsync = (vc < vpulse)? 0:1;

//access to the ram

always @(posedge dclk, posedge clr) begin 
if (clr) begin 
	hc <= 0;
	vc <= 0; 
	px <= 0;
end //(clr)
else begin
	if (
		vc >= v_backporch && vc < v_frontporch &&
		hc >= h_backporch && hc < h_frontporch
	) begin 
		red = 3'b000;
		blue = 2'b00;
		if (line[hc-1] == 1'b1) begin 
			green = 3'b111;
		end 
		else begin 
			green = 3'b000;
		end;
	end
	else begin  //outside the display range
		red = 3'b000;
		green = 3'b000;
		blue = 2'b00;
	end 	
end //else clr
end //always
endmodule
