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
`include "includes.v"
module write_register(
		input wire clk,
		input wire [15:0] registers [0:15], 
		input wire [15:0] instr_ptr,
		input wire [639:0] vram_in,
		output wire [8:0] vram_addr,
		output wire [639:0] vram_out,
		input wire vram_turn,
		output wire activate_write
    );
	 
	 parameter regs_col_1 = 330; //x
	 parameter regs_row_1 = 250; //y 
	 
	 reg [5:0] letter; //the letter number we want written
	 reg [4:0] which_string; //there's 18 strings to write
	 reg [3:0] which_letter; //REGISTERS. has 10 letters 
	 reg [3:0] which_register;
	 wire done;
	 
	 write_letter w_let_(
		.clk(clk),
		.let(letter), //@ the verilog compiler: die bitch
		.x_pos(((which_string >= 9) ? 1:0)*80 + which_letter*7 + regs_col_1), //(which column [0/1])*(col_length=80) + (which_letter)*letter_width=7
		.y_pos(which_row*12 + regs_row_1), //(which row [0-9])*(row_width)
		.line_from_vram(vram_in),
		.vram_turn(vram_turn),
		.line_addr(vram_addr),
		.activate_write(activate_write),
		.line_to_vram(vram_out),
		.let_done(done)
	 );
// There's 9x2 = 18 things we need to write: 
// Each of these is 11 letters long
// REGISTERS. IP. FFFF 0 9 
// R0. FFFF   R8. FFFF 1 a
// R1. FFFF   R9. FFFF 2 b
// R2. FFFF   RA. FFFF 3 c
// R3. FFFF   RB. FFFF 4 d
// R4. FFFF   RC. FFFF 5 e
// R5. FFFF   RD. FFFF 6 f
// R6. FFFF   RE. FFFF 7 10
// R7. FFFF   RF. FFFF 8 11

always @ (*) begin 
	case (which_string)
		0: which_register <= 0;
		1: which_register <= 0;
		2: which_register <= 1;
		3: which_register <= 2;
		4: which_register <= 3;
		5: which_register <= 4;
		6: which_register <= 5;
		7: which_register <= 6;
		8: which_register <= 7;
		9: which_register <= 7;
		10: which_register <= 8;
		11: which_register <= 9;
		12: which_register <= 10;
		13: which_register <= 11;
		14: which_register <= 12;
		15: which_register <= 13;
		16: which_register <= 14;
		17: which_register <= 15;
	endcase
end
always @(posedge vram_turn) begin
	if (letter >= 9) begin
		letter <= 0;
		if (which_string >= 18) begin 
			which_string <= 0;
		end //if which_...
		else begin
			which_string <= which_string + 1;
		end //else which...
	end //if letter >= 9
	else begin 
		letter <= letter + 1;
	end //else letter >= 9
end

always @(posedge vram_turn) begin 
	if (done) begin 
		if (which_string == 0) begin 
		case (which_letter) //REGISTERS.
			0: letter <= AN_R;
			1: letter <= AN_E;
			2: letter <= AN_G;
			3: letter <= AN_I;
			4: letter <= AN_S;
			5: letter <= AN_T;
			6: letter <= AN_E;
			7: letter <= AN_R;
			8: letter <= AN_S;
			9: letter <= AN_PT;
			default: letter <= AN_X;
		endcase
	end //which_string
	else if (which_string == 9) begin
		case (which_letter) // IP. FFFF
			0: letter <= AN_I;
			1: letter <= AN_P;
			2: letter <= AN_PT;
			3: letter <= AN_SP;
			4: letter <= instr_ptr[15:12];
			5: letter <= instr_ptr[11:8];
			6: letter <= instr_ptr[7:4];
			7: letter <= instr_ptr[3:0];
			8: letter <= AN_SP;
			9: letter <= AN_SP;
			default: letter <= AN_X;
		endcase 
	end //which_string else if
	else begin // the gp registers RF. FFFF
		case (which_letter)
			0: letter <= AN_R;
			1: letter <= which_register;
			2: letter <= AN_PT;
			3: letter <= AN_SP;
			4: letter <= registers[which_register][15:12];
			5: letter <= registers[which_register][11:8];
			6: letter <= registers[which_register][7:4];
			7: letter <= registers[which_register][3:0];
			8: letter <= AN_SP;
			9: letter <= AN_SP;
			default: letter <= AN_X;
		endcase
	end //which_string else 
end
end
endmodule
