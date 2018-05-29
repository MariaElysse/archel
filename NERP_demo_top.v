`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
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
module NERP_demo_top(
	input wire clk,			//master clock = 50MHz
	input wire clr,			//right-most pushbutton for reset
	output wire [6:0] seg,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
	output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);

// 7-segment clock interconnect
wire segclk;

// VGA display clock interconnect
wire dclk;

// disable the 7-segment decimal points
assign dp = 1;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.segclk(segclk),
	.dclk(dclk)
	);

// 7-segment display controller
segdisplay U2(
	.segclk(segclk),
	.clr(clr),
	.seg(seg),
	.an(an)
	);

// VGA controller
//vga640x480 U3(
//	.dclk(dclk),
//	.clr(clr),
//	.hsync(hsync),
//	.vsync(vsync),
//	.red(red),
//	.green(green),
//	.blue(blue)
//	);
//actually do need to use dual-channel memory
wire [639:0] read_from_vram;
wire [8:0] vram_read_addr;
vram vram_(
	.clka(clk),
	.wea('b1), //always true? idk why this is still here
	.addra(vram_write_addr), //address in
	.dina(save_to_vram), //data in
	.clkb(clk),
	.addrb(vram_read_addr),
	.doutb(read_from_vram)
);

vga vga_(
	.dclk(dclk),
	.rst(rst), //maybe not?
	.line(read_from_vram),
	.vram_read_addr(vram_read_addr),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.grn(green),
	.blu(blue)
);
endmodule
