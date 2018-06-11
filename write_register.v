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
		input wire [3:0] regnum,
		input wire [15:0] regdat,
		input wire [7:0] instr_ptr, //for some reason short as fuck lmao
		input wire [639:0] vram_in,
		output wire [8:0] vram_addr,
		output wire [639:0] vram_out,
		input wire vram_turn,
		output wire activate_write
    );
	 
	   parameter AN_0 = 0;
  parameter AN_1 = 1;
  parameter AN_2 = 2;
  parameter AN_3 = 3;  
  parameter AN_4 = 4;
  parameter AN_5 = 5;  
  parameter AN_6 = 6;
  parameter AN_7 = 7;
  parameter AN_8 = 8;
  parameter AN_9 = 9;
  parameter AN_A = 10;
  parameter AN_B = 11;
  parameter AN_C = 12;
  parameter AN_D = 13;
  parameter AN_E = 14;
  parameter AN_F = 15;
  parameter AN_G = 16;
  parameter AN_H = 17;
  parameter AN_I = 18;
  parameter AN_J = 19;
  parameter AN_K = 20;
  parameter AN_L = 20;
  parameter AN_M = 22;
  parameter AN_N = 23;
  parameter AN_O = 24;
  parameter AN_P = 25;
  parameter AN_Q = 26;
  parameter AN_R = 27;
  parameter AN_S = 28;
  parameter AN_T = 29;
  parameter AN_U = 30;
  parameter AN_V = 31;
  parameter AN_W = 32;
  parameter AN_X = 33;
  parameter AN_Y = 34;
  parameter AN_Z = 35;
  parameter AN_DS= 36;
  parameter AN_PT= 37;
  parameter AN_SP= 38;
	 
	 
	 parameter regs_col_1 = 420; //x
	 parameter regs_row_1 = 340; //y 
	 
	 reg [5:0] letter = 0; //the letter number we want written
	 reg [4:0] which_string = 0; //there's 18 strings to write
	 reg [3:0] which_letter = 0; //REGISTERS. has 10 letters 
	 reg [3:0] which_register = 0;
	 reg [7:0] i_p;
	 //wire which_row;
	 assign which_col = (which_string > 8)? 1'b1: 1'b0; 

	 wire done;
	 
	 reg [15:0] registers [0:15];
	 //initial registers = '{15{0}};
	 always @ (posedge clk) begin 
			registers[regnum] <= regdat; //that should work, i guess
			i_p <= instr_ptr;
	 end
	 wire [9:0] x_ps = (which_col == 1'b1)? 90 + 400 + which_letter*8: 400 + which_letter*8;
	 wire [8:0] y_ps = (which_col == 1'b1)? regs_row_1 + (which_string-9)*12: which_string*12 + regs_row_1;
	 write_letter w_let_(
		.clk(clk),
		.let(letter), //@ the verilog compiler: die bitch
		.x_pos(x_ps), //(which column [0/1])*(col_length=80) + (which_letter)*letter_width=7
		//Size mismatch in connection of port <x_pos>. Formal port size is 10-bit while actual signal size is 32-bit.
		.y_pos(y_ps), //(which row [0-9])*(row_width)
		.line_from_vram(vram_in),
		.vram_turn(vram_turn),
		.line_addr(vram_addr),
		.activate_write(activate_write),
		.line_to_vram(vram_out),
		.let_done(done)
	 );
// There's 9x2 = 18 things we need to write: 
// Each of these is 11 letters long
// REGISTERS. IP. 00FF 0 9 
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
		default: which_register <= 0;
	endcase
end
always @(posedge vram_turn) begin
	if (done && vram_turn) begin
	if (which_letter < 9) begin
			which_letter <= which_letter + 1;
			

	end //if letter >= 9
	else begin 
		if (which_string < 17) begin 
			which_string <= which_string + 1;
		end //if which_...
		else begin
				which_string <= 0;
		end //else which...
			
			which_letter <= 0;		

	end //else letter >= 9
	end
end

always @(posedge vram_turn) begin 
	//if (done) begin 
		if (which_string == 0) begin //commented for testing.letters are all garbled 
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
	end //which_string //commented for testing
	else if (which_string == 9) begin
		case (which_letter) // IP. FFFF
			0: letter <= AN_I;
			1: letter <= AN_P;
			2: letter <= AN_PT;
			3: letter <= AN_SP;
			4: letter <= AN_0;
			5: letter <= AN_0;
			6: letter <= i_p[7:4];
			7: letter <= i_p[3:0];
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
//end
endmodule
