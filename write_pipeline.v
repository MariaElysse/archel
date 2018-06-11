`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:33:48 06/04/2018 
// Design Name: 
// Module Name:    write_pipeline 
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
module write_pipeline(
			input wire clk,
			input wire [15:0] if_insn,
			input wire [15:0] id_insn,
			input wire [15:0] ex_insn,
			input wire [15:0] mem_insn,
			input wire [15:0] wb_insn,
			
			input wire [639:0] read_vram,
			input wire vram_turn,
			
			output wire [639:0] write_vram,
			output wire activate_write,
			output wire [8:0] vram_addr	
    );
	parameter insns_col_width = 120; //comfortably: 16 letters wide
	parameter insts_row_1 = 100;
	parameter insts_col_1 = 0;

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
	
	//reg [2:0] which_print = 0; // ordered by the order they're written to the screen
	reg [3:0] which_letter = 0;
	reg [2:0] which_instr = 0;
	reg [5:0] letter;
	wire letter_done;
	reg [15:0] pipeline_instrs[4:0];
	
	initial pipeline_instrs[0] = 16'b0;
	initial pipeline_instrs[1] = 16'b0;
	initial pipeline_instrs[2] = 16'b0;
	initial pipeline_instrs[3] = 16'b0;
	initial pipeline_instrs[4] = 16'b0;
	wire [9:0] x_ps = (which_letter<4)? insts_col_1+(which_letter*8) + which_instr*16*8: insts_col_1+((which_letter-4)*8) + which_instr*16*8;
	wire [8:0] y_ps = (which_letter<4)? insts_row_1: insts_row_1 + 12;
	write_letter w_let_(
		.clk(clk),
		.let(letter),
		.x_pos(x_ps),
		.y_pos(y_ps),
		.line_from_vram(read_vram),
		.vram_turn(vram_turn),
		.line_addr(vram_addr),
		.activate_write(activate_write),
		.line_to_vram(write_vram),
		.let_done(letter_done)
	);
	// 1100 0000 01100010  bezi
	// 1101 1001 10001011  bnzi
   // 1110 0000 1111 ---- bezr
   // 1111 0000 1111 ---- bnzr (assumed from pattern)	
	// 0110 1010 0110 1100 slt
	// 0001 0000 0000 0110 add
	// 0010 0110 00000000  addi
	// 0100 0000 0000 0000 and
	// 0101                or
	// 1001 1011 0111 ---- sw
	// 1000 ---- 1000 1011 lw
	// 1010 0110 00000000  swi
	// 
	
	always @(posedge clk) begin
		pipeline_instrs[0] <= if_insn;
		pipeline_instrs[1] <= id_insn;
		pipeline_instrs[2] <= ex_insn;
		pipeline_instrs[3] <= mem_insn;
		pipeline_instrs[4] <= wb_insn;
	end
	
	always @(posedge clk) begin 
		case (pipeline_instrs[which_instr][15:12])
		4'b0000: //nop
			case (which_letter)
				0: letter <= AN_N;
				1: letter <= AN_O;
				2: letter <= AN_P;
				default: letter <= AN_SP;
			endcase
		4'b0001: //add
			case (which_letter)
				0: letter <= AN_A;
				1: letter <= AN_D;
				2: letter <= AN_D;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				12: letter <= AN_R;
				13: letter <= pipeline_instrs[which_instr][3:0];
				14: letter <= AN_PT;
				15: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase
		4'b0010: //addi
			case (which_letter)
				0: letter <= AN_A;
				1: letter <= AN_D;
				2: letter <= AN_D;
				3: letter <= AN_I;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_DS;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= pipeline_instrs[which_instr][3:0];
				default: letter <= AN_SP;
			endcase
		4'b0011: //sub
			case (which_letter)
				0: letter <= AN_S;
				1: letter <= AN_U;
				2: letter <= AN_B;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				12: letter <= AN_R;
				13: letter <= pipeline_instrs[which_instr][3:0];
				14: letter <= AN_PT;
				15: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase	
		4'b0100: //and
			case (which_letter)
				0: letter <= AN_A;
				1: letter <= AN_N;
				2: letter <= AN_D;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				12: letter <= AN_R;
				13: letter <= pipeline_instrs[which_instr][3:0];
				14: letter <= AN_PT;
				15: letter <= AN_SP;
				default: letter <= AN_SP;
		endcase
		4'b0101: //or
			case (which_letter)
				0: letter <= AN_O;
				1: letter <= AN_R;
				2: letter <= AN_SP;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				12: letter <= AN_R;
				13: letter <= pipeline_instrs[which_instr][3:0];
				14: letter <= AN_PT;
				15: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase
		4'b0110: //slt
			case (which_letter)
				0: letter <= AN_S;
				1: letter <= AN_L;
				2: letter <= AN_T;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				12: letter <= AN_R;
				13: letter <= pipeline_instrs[which_instr][3:0];
				14: letter <= AN_PT;
				15: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase
		4'b0111: //no instruction
			letter <= AN_X;
		
		4'b1000: //lw
			case (which_letter)
				0: letter <= AN_L;
				1: letter <= AN_W;
				2: letter <= AN_SP;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][7:4];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][3:0];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase
		4'b1001: //sw
			case (which_letter)
				0: letter <= AN_S;
				1: letter <= AN_W;
				2: letter <= AN_SP;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase
		4'b1010: //swi	
			case (which_letter)
				0: letter <= AN_S;
				1: letter <= AN_W;
				2: letter <= AN_I;
				3: letter <= AN_SP;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_DS;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= pipeline_instrs[which_instr][3:0];
				default: letter <= AN_SP;
			endcase	
		4'b1011: //no instruction 
			letter <= AN_X;
		4'b1100: //bezi
			case (which_letter)
				0: letter <= AN_B;
				1: letter <= AN_E;
				2: letter <= AN_Z;
				3: letter <= AN_I;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_DS;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= pipeline_instrs[which_instr][3:0];
				default: letter <= AN_SP;
			endcase
		4'b1101: //bnzi
			case (which_letter)
				0: letter <= AN_B;
				1: letter <= AN_N;
				2: letter <= AN_Z;
				3: letter <= AN_I;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_DS;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= pipeline_instrs[which_instr][3:0];
				default: letter <= AN_SP;
			endcase
	4'b1110: //bezr
			case (which_letter)
				0: letter <= AN_B;
				1: letter <= AN_E;
				2: letter <= AN_Z;
				3: letter <= AN_R;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase
	4'b1111: //bnzr
			case (which_letter)
				0: letter <= AN_B;
				1: letter <= AN_N;
				2: letter <= AN_Z;
				3: letter <= AN_R;
				4: letter <= AN_R;
				5: letter <= pipeline_instrs[which_instr][11:8];
				6: letter <= AN_PT;
				7: letter <= AN_SP;
				8: letter <= AN_R;
				9: letter <= pipeline_instrs[which_instr][7:4];
				10: letter <= AN_PT;
				11: letter <= AN_SP;
				default: letter <= AN_SP;
			endcase
		endcase
	end
	
	always @(posedge vram_turn) begin 
		if (letter_done) begin
			if (which_letter < 15) begin 
				which_letter <= which_letter + 1;
			end 
			else begin
				which_letter <= 0;			
			if (which_instr < 5) begin 
					which_instr <= which_instr + 1;
				end
				else begin 
					which_instr <= 0;
				end
			end
		end
	end


endmodule
