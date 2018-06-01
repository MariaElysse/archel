module archel (
  input  wire        CLK, // 100MHz on-board clk
  input  wire        PAUSE, // switch input
  input  wire        RST, // button input
  input  wire        STEP, // button input
  output wire [2:0]  RED,
  output wire [2:0]  GRN,
  output wire [1:0]  BLU,
  output wire HSYNC,
  output wire VSYNC
  );

  // ===========================================================================
  // CPU Pipeline
  // ===========================================================================

  // Register file querying for VGA module display
  wire        cpuin_regfile_request; // assert to request, then...
  wire [3:0]  cpuin_regfile_ra;
  wire        cpuout_regfile_grant; // ...check for posedge
  wire [15:0] cpuout_regfile_rd;

  // Pipeline PC & instructions state
  wire [7:0]  cpuout_PC;
  wire [15:0] cpuout_IF_insn;
  wire [15:0] cpuout_ID_insn;
  wire [15:0] cpuout_EX_insn;
  wire [15:0] cpuout_MEM_insn;
  wire [15:0] cpuout_WB_insn;

  // Most recent memory write
  wire        cpuout_memupdate; // check for posedge
  wire [7:0]  cpuout_memaddr;
  wire [15:0] cpuout_memdata;

  cpu cpu_(.CLK(CLK),
           .PAUSE(PAUSE),
           .RST(RST),
           .STEP(STEP),
           .cpuin_regfile_request(cpuin_regfile_request),
           .cpuin_regfile_ra(cpuin_regfile_ra),
           .cpuout_regfile_grant(cpuout_regfile_grant),
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
  
  // ===========================================================================
  // Clock Divider
  // ===========================================================================
  
  wire DCLK;
  clockdiv clk_div(.clk(CLK),
                   .rst(RST),
                   .dclk(DCLK)
  );

  // ===========================================================================
  // VGA Output
  // ===========================================================================
  wire [639:0]   agp_data; // accelerated graphics port.
  wire [8:0]     agp_addr; // or the other thing - for those who know
  wire [8:0]     vram_rw_addr;
  wire [639:0]   vram_read;
  wire [639:0]   vram_write;
  wire           vram_write_enable;
  
  wire [639:0]   shared_vram_data_write_bus[7:0];
  wire [8:0]     shared_vram_addr_bus[7:0];
  wire [639:0]   shared_vram_data_read_bus[7:0];
  wire [7:0]          shared_write_active_bus;
  wire [7:0]          activator_onehot;
  
  // TO MIKE: PLS DO NOT USE UNPACKED ARRAYS
  // THEYRE A PAIN IN THE ASS AND THIS SHIT DOESNT COMPILE
  // basically if u want to have an array [15:0][15:0] u have to make [255:0] and them mux on that
  // pls i would love to be proven wrong but it seems that's what we have to deal with
  write_register w_regs_(
		.clk(CLK),
		.registers({16{16'b1010101010101010}}), //i mean it's weird but it works as a test value
		.instr_ptr(16'b0000000110100100),
		.vram_in(shared_vram_data_read_bus[0]), //0-7, only 8 "simultaneous" r/w allowed
		.vram_addr(shared_vram_addr_bus[0]),
		.vram_out(shared_vram_data_write_bus[0]),
		.vram_turn(activator_onehot[0]),
		.activate_write(shared_write_active_bus[0])
  );
  
  vram_muxer vram_muxer_( //fackin christ
		.clk(CLK),
		.rst(RST),
		.vram_addr(shared_vram_addr_bus),
		.write_vram(shared_vram_data_write_bus),
		.read_vram(shared_vram_data_read_bus),
		.write_active(shared_write_active_bus),
		.active_writer(activator_onehot),
		.to_vram_write(vram_write),
		.from_vram_read(vram_read),
		.to_vram_addr(vram_rw_addr),
		.to_vram_wea(vram_write_enable)
  );
  
  vram vram_( //might also need to be true dual for multi-writes. but i dont want to block rendering ever so it should get its own port
		.clka(CLK),
		.wea(vram_write_enable),
		.addra(vram_rw_addr),
		.dina(vram_write),
		.douta(vram_read),
		.clkb(CLK),
		.web('b0),
		.addrb(agp_addr),
		.dinb('b0),
		.doutb(agp_data)
		//enable writes for b: no, never 
		//enable writes for a: yes, always
  );
  
  vga vga_(
		.dclk(DCLK),
		.rst(RST),
		.line(agp_data),
		.vram_read_addr(agp_addr),
		.hsync(HSYNC),
		.vsync(VSYNC),
		.red(RED),
		.grn(GRN),
		.blu(BLU)
  );
//	Todo: 
//	* Write the word REGISTERS on the screen via the VRAM
//	-> Write the letters line by line
//	* Write the register contents on the screen via vram 
//	-> Write RX._FFFF_ (same length as string REGISTERS)
//	(concatenation and shifting should b an easy way to do this one)
// Consider: different data port aspect ratios? how many letters can we draw before the 
// rendering becomes too slow? If 1/10 of a letter takes 1/100mhz (10 clocks per letter)
//and the screen is redrawn every 1/60hz how many letters can we draw? THOUSANDS. So it should be fine to do it slowly
  
endmodule // nexys3
