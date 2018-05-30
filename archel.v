module archel (
  input  wire        CLK, // 100MHz on-board clk
  input  wire        PAUSE, // switch input
  input  wire        RST, // button input
  input  wire        STEP, // button input
  output wire [6:0]  VGA // VGA output
  );

  // ===========================================================================
  // WB : Writeback
  // ===========================================================================

  wire        WB_CTL_regwrite = MEMWB_CTL_WB_regwrite;
  wire [2:0]  WB_writeaddr = MEMWB_WA;
  wire [15:0] WB_writedata = MEMWB_CTL_WB_memtoreg ? MEMWB_WD_mem : MEMWB_WD_reg;

  // ===========================================================================
  // VGA Output
  // ===========================================================================
  
  // vga vga();

  // ===========================================================================
  // Step Button Debouncing
  // ===========================================================================
  
  wire step_btn_state;
  wire step_btn_down;
  wire step_btn_up;
  
  debouncer debouncer(.clk(CLK),
                      .btn(STEP),
                      .btn_state(step_btn_state),
                      .btn_down(step_btn_down),
                      .btn_up(step_btn_up));

  // ===========================================================================
  // IF : Instruction Fetch
  // ===========================================================================
  
  reg [15:0] IFID_insn;

  reg [5:0] PC = 6'b000000;
  wire [15:0] IF_insn;

  insn_mem insn_mem(.addr(PC), .data(IF_insn));

  always @ (posedge CLK) begin
    if (RST) begin
      IFID_insn <= 0;
      PC <= 0;
    end
    else if (PAUSE == 0) begin
      IFID_insn <= IF_insn;
      PC <= PC + 4;
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
  reg [2:0]  IDEX_rt;
  reg [2:0]  IDEX_rd;

  wire       ID_alusrc;
  wire [4:0] ID_aluop;
  wire       ID_regdst;
  wire       ID_memread;
  wire       ID_memwrite;
  wire       ID_regwrite;
  wire       ID_memtoreg;

  control control(.opcode(IFID_insn[15:12]),
                  .ctl_alusrc(ID_alusrc),
                  .ctl_aluop(ID_aluop),
                  .ctl_regdst(ID_regdst),
                  .ctl_memread(ID_memread),
                  .ctl_memwrite(ID_memwrite),
                  .ctl_regwrite(ID_regwrite),
                  .ctl_memtoreg(ID_memtoreg));

  wire [15:0] ID_RD1;
  wire [15:0] ID_RD2;
  wire [2:0] a_addr = WB_CTL_regwrite ? WB_writeaddr : IFID_insn[11:9];
  
  // DO NOT read and write in the same cycle
  // a: read_1 and write
  // b: read_2
  register_file_16x256 regfile(.clka(CLK),
                               .clkb(CLK),
                               .rsta(RST),
                               
                               .addra(a_addr),
                               .douta(ID_RD1),
                               .wea(WB_CTL_regwrite), // write enable
                               .dina(WB_writedata),
                               
                               .addrb(IFID_insn[8:6]),
                               .doutb(ID_RD2));
  
//  regfile regfile(.RA1(IFID_insn[11:9]),
//                  .RA2(IFID_insn[8:6]),
//                  .RD1(ID_RD1),
//                  .RD2(ID_RD2),
//                  .WA(WB_writeaddr),
//                  .WD(WB_writedata),
//                  .regwrite(WB_CTL_regwrite));

  always @ (posedge CLK) begin
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
      IDEX_rt <= 0;
      IDEX_rd <= 0;
    end
    else if (PAUSE == 0) begin
      IDEX_CTL_EX_alusrc <= ID_alusrc;
      IDEX_CTL_EX_aluop <= ID_aluop;
      IDEX_CTL_EX_regdst <= ID_regdst;
      IDEX_CTL_MEM_memread <= ID_memread;
      IDEX_CTL_MEM_memwrite <= ID_memwrite;
      IDEX_CTL_WB_regwrite <= ID_regwrite;
      IDEX_CTL_WB_memtoreg <= ID_memtoreg;
      IDEX_R1 <= ID_RD1;
      IDEX_R2 <= ID_RD2;
      IDEX_sext_imm <= { {10{IFID_insn[5]}}, IFID_insn[5:0] };
      IDEX_rt <= IFID_insn[8:6];
      IDEX_rd <= IFID_insn[5:3];
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
  reg [2:0]  EXMEM_WA;

  wire [15:0] EX_alub = IDEX_CTL_EX_alusrc ? IDEX_sext_imm : IDEX_R2;
  wire [15:0] EX_aluout;

  alu_16 alu(.aluop(IDEX_CTL_EX_aluop),
             .a(IDEX_R1),
             .b(EX_alub),
             .result(EX_aluout),
             .ovf());

  always @ (posedge CLK) begin
    if (RST) begin
      EXMEM_CTL_MEM_memread <= 0;
      EXMEM_CTL_MEM_memwrite <= 0;
      EXMEM_CTL_WB_regwrite <= 0;
      EXMEM_CTL_WB_memtoreg <= 0;
      EXMEM_aluout <= 0;
      EXMEM_R2 <= 0;
      EXMEM_WA <= 0;
    end
    else if (PAUSE == 0) begin
      EXMEM_CTL_MEM_memread <= IDEX_CTL_MEM_memread;
      EXMEM_CTL_MEM_memwrite <= IDEX_CTL_MEM_memwrite;
      EXMEM_CTL_WB_regwrite <= IDEX_CTL_WB_regwrite;
      EXMEM_CTL_WB_memtoreg <= IDEX_CTL_WB_memtoreg;
      EXMEM_aluout <= EX_aluout;
      EXMEM_R2 <= IDEX_R2;
      EXMEM_WA <= IDEX_CTL_EX_regdst ? IDEX_rd : IDEX_rt;
    end
  end

  // ===========================================================================
  // MEM : Memory Access
  // ===========================================================================
  
  reg        MEMWB_CTL_WB_regwrite;
  reg        MEMWB_CTL_WB_memtoreg;
  reg [15:0] MEMWB_WD_mem;
  reg [15:0] MEMWB_WD_reg;
  reg [2:0]  MEMWB_WA;

  wire [15:0] MEM_data;

  data_mem data_mem(.RA(EXMEM_aluout),
                    .read(EXMEM_CTL_MEM_memread),
                    .write(EXMEM_CTL_MEM_memwrite),
                    .WD(EXMEM_R2),
                    .RD(MEM_data));

  always @ (posedge CLK) begin
    if (RST) begin
      MEMWB_CTL_WB_regwrite <= 0;
      MEMWB_CTL_WB_memtoreg <= 0;
      MEMWB_WD_mem <= 0;
      MEMWB_WD_reg <= 0;
      MEMWB_WA <= 0;
    end
    if (PAUSE == 0) begin
      MEMWB_CTL_WB_regwrite <= EXMEM_CTL_WB_regwrite;
      MEMWB_CTL_WB_memtoreg <= EXMEM_CTL_WB_memtoreg;
      MEMWB_WD_mem <= MEM_data;
      MEMWB_WD_reg <= EXMEM_aluout;
      MEMWB_WA <= EXMEM_WA;
    end
  end
  


  
endmodule // nexys3
