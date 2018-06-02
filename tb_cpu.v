`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:28:07 06/01/2018
// Design Name:   cpu
// Module Name:   C:/Users/Mike/Dropbox/UCLA Courses/CS M152A/archel/tb_cpu.v
// Project Name:  archel
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_cpu;

  // Inputs
  reg CLK;
  reg PAUSE;
  reg RST;
  reg STEP;

  // Outputs
  wire cpuout_regfile_grant;
  wire [3:0]  cpuout_regfile_ra;
  wire [15:0] cpuout_regfile_rd;
  wire [7:0]  cpuout_PC;
  wire [15:0] cpuout_IF_insn;
  wire [15:0] cpuout_ID_insn;
  wire [15:0] cpuout_EX_insn;
  wire [15:0] cpuout_MEM_insn;
  wire [15:0] cpuout_WB_insn;
  wire cpuout_memupdate;
  wire [7:0] cpuout_memaddr;
  wire [15:0] cpuout_memdata;

  // Instantiate the Unit Under Test (UUT)
  cpu uut (
    .CLK(CLK), 
    .PAUSE(PAUSE), 
    .RST(RST), 
    .STEP(STEP), 
    .cpuout_regfile_ra(cpuout_regfile_ra), 
    .cpuout_regfile_rd(cpuout_regfile_rd), 
    .cpuout_PC(cpuout_PC), 
    .cpuout_IF_insn(cpuout_IF_insn), 
    .cpuout_ID_insn(cpuout_ID_insn), 
    .cpuout_EX_insn(cpuout_EX_insn), 
    .cpuout_MEM_insn(cpuout_MEM_insn), 
    .cpuout_WB_insn(cpuout_WB_insn), 
    .cpuout_memupdate(cpuout_memupdate), 
    .cpuout_memaddr(cpuout_memaddr), 
    .cpuout_memdata(cpuout_memdata)
  );
  
  always #5 CLK <= ~CLK;

  initial begin
    // Initialize Inputs
    CLK = 0;
    PAUSE = 0;
    RST = 0;
    STEP = 0;

    // Wait 100 ns for global reset to finish
    #100;
        
    // Add stimulus here
    
    // Reset
    RST = 1;
    #100;
    RST = 0;
    #100;

    /* Test pause and step */

    #3000;
    PAUSE = 1;
    #5000;
    STEP = 1;
    #1000;
    STEP = 0;
    #5000;
    STEP = 1;
    #1000;
    STEP = 0;
    #5000;
    PAUSE = 0;
    #3000;
	 
  end
      
endmodule

