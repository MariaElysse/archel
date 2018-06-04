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

  // Register file output (continuous scan), updates every posedge CLK
  wire [3:0]  cpuout_regfile_ra;
  wire [15:0] cpuout_regfile_rd;

  // Pipeline PC & instructions state
  wire [7:0]  cpuout_PC;
  wire [15:0] cpuout_IF_insn;
  wire [15:0] cpuout_ID_insn;
  wire [15:0] cpuout_EX_insn;
  wire [15:0] cpuout_MEM_insn;
  wire [15:0] cpuout_WB_insn;

  // Most recent memory write (reach goal)
  wire        cpuout_memupdate;
  wire [7:0]  cpuout_memaddr;
  wire [15:0] cpuout_memdata;

  cpu cpu_(.CLK(CLK),
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
  
  wire [1279:0]   shared_vram_data_write_bus;
  wire [17:0]     shared_vram_addr_bus;
  wire [1279:0]   shared_vram_data_read_bus;
  wire [1:0]      shared_write_active_bus;
  wire [1:0]      activator_onehot;
  
  // TO MIKE: PLS DO NOT USE UNPACKED ARRAYS
  // THEYRE A PAIN IN THE ASS AND THIS SHIT DOESNT COMPILE
  // basically if u want to have an array [15:0][15:0] u have to make [255:0] and them mux on that
  // pls i would love to be proven wrong but it seems that's what we have to deal with
  write_register w_regs_(
		.clk(CLK),
		.regnum(cpuout_regfile_ra), //i mean it's weird but it works as a test value
		.regdat(cpuout_regfile_rd),
		.instr_ptr(cpuout_PC),
		.vram_in(shared_vram_data_read_bus[639:0]), //0
		.vram_addr(shared_vram_addr_bus[8:0]),
		.vram_out(shared_vram_data_write_bus[639:0]),
		.vram_turn(activator_onehot[0]),
		.activate_write(shared_write_active_bus[0])
  );
  write_pipeline w_pl_(
		.clk(CLK),
		.if_insn(cpuout_IF_insn),
		.id_insn(cpuout_ID_insn),
		.ex_insn(cpuout_EX_insn),
		.mem_insn(cpuout_MEM_insn),
		.wb_insn(cpuout_WB_insn),
		
		.read_vram(shared_vram_data_read_bus[1279:640]), //1
		.vram_turn(activator_onehot[1]),
		.write_vram(shared_vram_data_write_bus[1279:640]),
		.activate_write(shared_write_active_bus[1]),
		.vram_addr(shared_vram_addr_bus[17:9])
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
		.web(1'b0),
		.addrb(agp_addr),
		.dinb(640'b0),
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
