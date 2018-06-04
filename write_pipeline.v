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
	parameter insns_col_width = 128; //comfortably: 16 letters wide
	parameter insts_row_1 = 300;
	parameter insts_col_1 = 4;
	parameter print_if = 0;
	parameter print_id = 1;
	parameter print_ex = 2;
	parameter print_mem = 3;
	parameter print_wb = 4;
	
	reg [15:0] curr_instr;
	reg [2:0] which_print = 0; // ordered by the order they're written to the screen
	reg [3:0] which_letter = 0;
	reg [5:0] letter;
	wire letter_done;
	
	write_letter w_let_(
		.clk(clk),
		.let(letter),
		.x_pos((insts_col_1+which_letter*7)*which_print*insns_col_width),
		.y_pos((which_letter<4)? insts_row_1: insts_row_1 + 12),
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
	
	always @(posedge vram_turn) begin
		case (which_print) //which pipeline item are we printing?
			print_if:
				curr_instr <= if_insn;
			print_id:
				curr_instr <= id_insn;
			print_ex:
				curr_instr <= ex_insn;
			print_mem:
				curr_instr <= mem_insn;
			print_wb:
				curr_instr <= wb_insn;
			default:
				curr_instr <= 0;
		endcase		
	end
	
	always @(posedge vram_turn) begin 
		case (curr_instr[15:12])
		4'b0000: //nop
			case (which_letter)
				0: letter <= includes.AN_N;
				1: letter <= includes.AN_O;
				2: letter <= includes.AN_P;
				default: letter <= includes.AN_SP;
			endcase
		4'b0001: //add
			case (which_letter)
				0: letter <= includes.AN_A;
				1: letter <= includes.AN_D;
				2: letter <= includes.AN_D;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				12: letter <= includes.AN_R;
				13: letter <= curr_instr[3:0];
				14: letter <= includes.AN_PT;
				15: letter <= includes.AN_SP;
			endcase
		4'b0010: //addi
			case (which_letter)
				0: letter <= includes.AN_A;
				1: letter <= includes.AN_D;
				2: letter <= includes.AN_D;
				3: letter <= includes.AN_I;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_DS;
				9: letter <= curr_instr[7:4];
				10: letter <= curr_instr[3:0];
				default: letter <= includes.AN_SP;
			endcase
		4'b0011: //sub
			case (which_letter)
				0: letter <= includes.AN_S;
				1: letter <= includes.AN_U;
				2: letter <= includes.AN_B;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				12: letter <= includes.AN_R;
				13: letter <= curr_instr[3:0];
				14: letter <= includes.AN_PT;
				15: letter <= includes.AN_SP;
			endcase	
		4'b0100: //and
			case (which_letter)
				0: letter <= includes.AN_A;
				1: letter <= includes.AN_N;
				2: letter <= includes.AN_D;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				12: letter <= includes.AN_R;
				13: letter <= curr_instr[3:0];
				14: letter <= includes.AN_PT;
				15: letter <= includes.AN_SP;
		endcase
		4'b0101: //or
			case (which_letter)
				0: letter <= includes.AN_O;
				1: letter <= includes.AN_R;
				2: letter <= includes.AN_SP;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				12: letter <= includes.AN_R;
				13: letter <= curr_instr[3:0];
				14: letter <= includes.AN_PT;
				15: letter <= includes.AN_SP;
			endcase
		4'b0110: //slt
			case (which_letter)
				0: letter <= includes.AN_S;
				1: letter <= includes.AN_L;
				2: letter <= includes.AN_T;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				12: letter <= includes.AN_R;
				13: letter <= curr_instr[3:0];
				14: letter <= includes.AN_PT;
				15: letter <= includes.AN_SP;
			endcase
		4'b0111: //no instruction
			letter <= includes.AN_X;
		
		4'b1000: //lw
			case (which_letter)
				0: letter <= includes.AN_L;
				1: letter <= includes.AN_W;
				2: letter <= includes.AN_SP;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[7:4];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[3:0];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				default: letter <= includes.AN_SP;
			endcase
		4'b1001: //sw
			case (which_letter)
				0: letter <= includes.AN_S;
				1: letter <= includes.AN_W;
				2: letter <= includes.AN_SP;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				default: letter <= includes.AN_SP;
			endcase
		4'b1010: //swi	
			case (which_letter)
				0: letter <= includes.AN_S;
				1: letter <= includes.AN_W;
				2: letter <= includes.AN_I;
				3: letter <= includes.AN_SP;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_DS;
				9: letter <= curr_instr[7:4];
				10: letter <= curr_instr[3:0];
				default: letter <= includes.AN_SP;
			endcase	
		4'b1011: //no instruction 
			letter <= includes.AN_X;
		4'b1100: //bezi
			case (which_letter)
				0: letter <= includes.AN_B;
				1: letter <= includes.AN_E;
				2: letter <= includes.AN_Z;
				3: letter <= includes.AN_I;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_DS;
				9: letter <= curr_instr[7:4];
				10: letter <= curr_instr[3:0];
				default: letter <= includes.AN_SP;
			endcase
		4'b1101: //bnzi
			case (which_letter)
				0: letter <= includes.AN_B;
				1: letter <= includes.AN_N;
				2: letter <= includes.AN_Z;
				3: letter <= includes.AN_I;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_DS;
				9: letter <= curr_instr[7:4];
				10: letter <= curr_instr[3:0];
				default: letter <= includes.AN_SP;
			endcase
	4'b1110: //bezr
			case (which_letter)
				0: letter <= includes.AN_B;
				1: letter <= includes.AN_E;
				2: letter <= includes.AN_Z;
				3: letter <= includes.AN_R;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				default: letter <= includes.AN_SP;
			endcase
	4'b1111: //bnzr
			case (which_letter)
				0: letter <= includes.AN_B;
				1: letter <= includes.AN_N;
				2: letter <= includes.AN_Z;
				3: letter <= includes.AN_R;
				4: letter <= includes.AN_R;
				5: letter <= curr_instr[11:8];
				6: letter <= includes.AN_PT;
				7: letter <= includes.AN_SP;
				8: letter <= includes.AN_R;
				9: letter <= curr_instr[7:4];
				10: letter <= includes.AN_PT;
				11: letter <= includes.AN_SP;
				default: letter <= includes.AN_SP;
			endcase
		endcase
	end
	
	always @(posedge vram_turn) begin 
		if (letter_done) begin
			if (which_letter >= 15) begin 
				if (which_print >= 5) begin 
					which_print <= 0;
				end
				else begin 
					which_print <= which_print + 1;
				end
				which_letter <= 0;
			end 
			else begin 
				which_letter <= which_letter + 1;
			end
		end
	end


endmodule
