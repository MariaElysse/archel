module archel (
  input  wire        CLK, // 100MHz on-board clk
  input  wire        PAUSE, // switch input
  input  wire        RST, // button input
  input  wire        STEP, // button input
  output wire [6:0]  VGA // VGA output
  );
  
  // ===========================================================================
  // VGA Output
  // ===========================================================================
  wire [639:0]   agp_data;
  wire [8:0]     agp_addr;
  wire [8:0]     vram_rw_addr;
  wire [639:0]   vram_read;
  wire [639:0]   vram_write;
  
  vram vram_( //might also need to be true dual for multi-writes. but i dont want to block rendering ever so it should get its own port
		.clka(CLK),
		.wea('b1),
		.addra(vram_rw_addr),
		.dina(vram_write),
		.douta(vram_read),
		.clkb(CLK),
		.addrb(agp_addr),
		.doutb(agp_data),
		.dinb('b0),
		//enable writes for b: no, never 
		//enable writes for a: yes, always
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
  // ===========================================================================
  // Clock Divider
  // ===========================================================================
  
  wire PCLK;
  clockdiv clk_div(.clk(CLK),
                   .rst(RST),
                   .pclk(PCLK));

  // ===========================================================================
  // Step Button Debouncing
  // ===========================================================================
  
  wire step_btn_state;
  wire step_btn_down;
  wire step_btn_up;
  
  debouncer debouncer(.clk(CLK),
                      .rst(RST),
                      .btn(STEP),
                      .btn_state(step_btn_state),
                      .btn_down(step_btn_down),
                      .btn_up(step_btn_up));

  // ===========================================================================
  // Forward Declarations
  // ===========================================================================
  
  // ID : Instruction Decode / Register Fetch

  wire       ID_RD1_zero;
  wire       ID_brop;
  wire       ID_branch = ID_RD1_zero & ID_brop;
  wire [7:0] ID_braddr;

  // WB : Writeback

  wire        WB_CTL_regwrite = MEMWB_CTL_WB_regwrite;
  wire [3:0]  WB_writeaddr = MEMWB_WA;
  wire [15:0] WB_writedata = MEMWB_CTL_WB_memtoreg ? MEMWB_WD_mem : MEMWB_WD_reg;

  // ===========================================================================
  // IF : Instruction Fetch
  // ===========================================================================
  
  reg [15:0] IFID_insn;

  reg [7:0] PC = 8'b00000000;
  wire [15:0] IF_insn;

  // insn_mem insn_mem(.addr(PC), .data(IF_insn));
  insn_mem_16x256 insn_mem(.clk(CLK),
                           .rst(RST),
                           .ra(PC),
                           .rd(IF_insn));

  always @ (posedge PCLK) begin
    if (RST) begin
      IFID_insn <= 0;
      PC <= 0;
    end
    else if (~PAUSE || (PAUSE & step_btn_down)) begin
      IFID_insn <= IF_insn;
      PC <= ID_branch ? ID_braddr : PC + 1; // mem is insn addressable
    end
  end
  
  // ===========================================================================
  // ID : Instruction Decode / Register Fetch
  // ===========================================================================
  
  reg        IDEX_CTL_EX_alusrc;
  reg [4:0]  IDEX_CTL_EX_aluop;
  reg        IDEX_CTL_EX_regdst;
  reg        IDEX_CTL_MEM_memread;
  reg        IDEX_CTL_MEM_memwrite;
  reg        IDEX_CTL_WB_regwrite;
  reg        IDEX_CTL_WB_memtoreg;
  reg [15:0] IDEX_R1;
  reg [15:0] IDEX_R2;
  reg [15:0] IDEX_sext_imm;
  reg [3:0]  IDEX_rs; // R dest for I-type insns
  reg [3:0]  IDEX_rd; // R dest for R-type insns

  wire       ID_alusrc;
  wire [4:0] ID_aluop;
  wire       ID_regdst;
  wire       ID_memread;
  wire       ID_memwrite;
  wire       ID_regwrite;
  wire       ID_memtoreg;
  assign     ID_braddr = IFID_insn[7:0];

  control control(.opcode(IFID_insn[15:12]),
                  .ctl_alusrc(ID_alusrc),
                  .ctl_aluop(ID_aluop),
                  .ctl_regdst(ID_regdst),
                  .ctl_memread(ID_memread),
                  .ctl_memwrite(ID_memwrite),
                  .ctl_regwrite(ID_regwrite),
                  .ctl_memtoreg(ID_memtoreg),
                  .ctl_brop(ID_brop));

  wire [15:0] ID_RD1;
  wire [15:0] ID_RD2;
  assign ID_RD1_zero = ~(|ID_RD1);
  
  // DO NOT read and write in the same cycle
  // a: read_1 and write
  // b: read_2
  register_file_16x16 regfile(.clk(CLK),
                              .rst(RST),
                              
                              .ra1(IFID_insn[11:8]), // rs (read) / WA (write)
                              .ra2(IFID_insn[7:4]), // rt (read)
                              .rd1(ID_RD1),
                              .rd2(ID_RD2),

                              .we(WB_CTL_regwrite), // write enable
                              .wa(WB_writeaddr),
                              .wd(WB_writedata));

  always @ (posedge PCLK) begin
    if (RST) begin
      IDEX_CTL_EX_alusrc <= 0;
      IDEX_CTL_EX_aluop <= 0;
      IDEX_CTL_EX_regdst <= 0;
      IDEX_CTL_MEM_memread <= 0;
      IDEX_CTL_MEM_memwrite <= 0;
      IDEX_CTL_WB_regwrite <= 0;
      IDEX_CTL_WB_memtoreg <= 0;
      IDEX_R1 <= 0;
      IDEX_R2 <= 0;
      IDEX_sext_imm <= 0;
      IDEX_rs <= 0;
      IDEX_rd <= 0;
    end
    else if (~PAUSE || (PAUSE & step_btn_down)) begin
      IDEX_CTL_EX_alusrc <= ID_alusrc;
      IDEX_CTL_EX_aluop <= ID_aluop;
      IDEX_CTL_EX_regdst <= ID_regdst;
      IDEX_CTL_MEM_memread <= ID_memread;
      IDEX_CTL_MEM_memwrite <= ID_memwrite;
      IDEX_CTL_WB_regwrite <= ID_regwrite;
      IDEX_CTL_WB_memtoreg <= ID_memtoreg;
      IDEX_R1 <= ID_RD1;
      IDEX_R2 <= ID_RD2;
      IDEX_sext_imm <= { {8{IFID_insn[7]}}, IFID_insn[7:0] };
      IDEX_rs <= IFID_insn[11:8];
      IDEX_rd <= IFID_insn[3:0];
    end
  end

  // ===========================================================================
  // EX : Execution
  // ===========================================================================
  
  reg        EXMEM_CTL_MEM_memread;
  reg        EXMEM_CTL_MEM_memwrite;
  reg        EXMEM_CTL_WB_regwrite;
  reg        EXMEM_CTL_WB_memtoreg;
  reg [15:0] EXMEM_aluout;
  reg [15:0] EXMEM_R2;
  reg [3:0]  EXMEM_WA;

  wire [15:0] EX_alub = IDEX_CTL_EX_alusrc ? IDEX_sext_imm : IDEX_R2;
  wire [15:0] EX_aluout;

  alu_16 alu(.aluop(IDEX_CTL_EX_aluop),
             .a(IDEX_R1),
             .b(EX_alub),
             .result(EX_aluout),
             .ovf());

  always @ (posedge PCLK) begin
    if (RST) begin
      EXMEM_CTL_MEM_memread <= 0;
      EXMEM_CTL_MEM_memwrite <= 0;
      EXMEM_CTL_WB_regwrite <= 0;
      EXMEM_CTL_WB_memtoreg <= 0;
      EXMEM_aluout <= 0;
      EXMEM_R2 <= 0;
      EXMEM_WA <= 0;
    end
    else if (~PAUSE || (PAUSE & step_btn_down)) begin
      EXMEM_CTL_MEM_memread <= IDEX_CTL_MEM_memread;
      EXMEM_CTL_MEM_memwrite <= IDEX_CTL_MEM_memwrite;
      EXMEM_CTL_WB_regwrite <= IDEX_CTL_WB_regwrite;
      EXMEM_CTL_WB_memtoreg <= IDEX_CTL_WB_memtoreg;
      EXMEM_aluout <= EX_aluout;
      EXMEM_R2 <= IDEX_R2;
      EXMEM_WA <= IDEX_CTL_EX_regdst ? IDEX_rd : IDEX_rs;
    end
  end

  // ===========================================================================
  // MEM : Memory Access
  // ===========================================================================
  
  reg        MEMWB_CTL_WB_regwrite;
  reg        MEMWB_CTL_WB_memtoreg;
  reg [15:0] MEMWB_WD_mem;
  reg [15:0] MEMWB_WD_reg;
  reg [3:0]  MEMWB_WA;

  wire [15:0] MEM_data;

  data_mem_16x256 data_mem(.clk(CLK),
                           .rst(RST),
                           .rwa(EXMEM_aluout),
                           .rd(MEM_data),
                           .we(EXMEM_CTL_MEM_memwrite),
                           .wd(EXMEM_R2));

  always @ (posedge PCLK) begin
    if (RST) begin
      MEMWB_CTL_WB_regwrite <= 0;
      MEMWB_CTL_WB_memtoreg <= 0;
      MEMWB_WD_mem <= 0;
      MEMWB_WD_reg <= 0;
      MEMWB_WA <= 0;
    end
    if (~PAUSE || (PAUSE & step_btn_down)) begin
      MEMWB_CTL_WB_regwrite <= EXMEM_CTL_WB_regwrite;
      MEMWB_CTL_WB_memtoreg <= EXMEM_CTL_WB_memtoreg;
      MEMWB_WD_mem <= MEM_data;
      MEMWB_WD_reg <= EXMEM_aluout;
      MEMWB_WA <= EXMEM_WA;
    end
  end
  
  // ===========================================================================
  // WB : Writeback
  // ===========================================================================

  // wires implicitly declared earlier


  
endmodule // nexys3
