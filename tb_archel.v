`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:37:02 05/29/2018
// Design Name:   archel
// Module Name:   C:/Users/Mike/archel/tb_archel.v
// Project Name:  archel
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: archel
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_archel;

	// Inputs
	reg CLK;
	reg PAUSE;
	reg RST;
	reg STEP;

	// Outputs
	wire [6:0] VGA;

	// Instantiate the Unit Under Test (UUT)
	archel uut (
		.CLK(CLK), 
		.PAUSE(PAUSE), 
		.RST(RST), 
		.STEP(STEP), 
		.VGA(VGA)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		PAUSE = 0;
		RST = 0;
		STEP = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

