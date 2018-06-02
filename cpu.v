module cpu (
  input  wire        CLK, // 100MHz on-board clk
  input  wire        PAUSE, // switch input
  input  wire        RST, // button input
  input  wire        STEP, // button input

  // will constantly cycle through all the registers
  output wire [3:0]  cpuout_regfile_ra,
  output wire [15:0] cpuout_regfile_rd,

  output wire [7:0]  cpuout_PC,
  output reg [15:0]  cpuout_IF_insn,
  output reg  [15:0] cpuout_ID_insn,
  output reg  [15:0] cpuout_EX_insn,
  output reg  [15:0] cpuout_MEM_insn,
  output reg  [15:0] cpuout_WB_insn,

  // reach goal
  output wire        cpuout_memupdate,
  output wire [7:0]  cpuout_memaddr,
  output wire [15:0] cpuout_memdata
  );
  
  // ===========================================================================
  // Clock Divider
  // ===========================================================================
  
  reg [5:0] counter = 6'b000000;
  always @ (posedge CLK) begin
    if (PAUSE) counter <= 0;
    else counter <= counter + 1;
  end // always @ (posedge CLK)
  wire PCLK = &counter; // Pipeline clock

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
  // Globals
  // ===========================================================================
  
  reg [1:0] advance_pipeline;
  always @ (posedge CLK) begin
    advance_pipeline[0] <= ((~PAUSE) && PCLK) || (PAUSE && step_btn_down);
    advance_pipeline[1] <= advance_pipeline[0];
  end
  reg [3:0] scanreg_next = 4'h0;
  always @ (posedge CLK) scanreg_next <= scanreg_next + 1;

  // ===========================================================================
  // Forward Declarations
  // ===========================================================================
  
  // ID : Instruction Decode / Register Fetch

  wire       ID_branch = ID_RD1_zero & ID_brop;
  wire [7:0] ID_braddr;

  // WB : Writeback

  wire        WB_CTL_regwrite = MEMWB_CTL_WB_regwrite;
  wire [3:0]  WB_writeaddr = MEMWB_wa;
  wire [15:0] WB_writedata = MEMWB_CTL_WB_memtoreg ? MEMWB_wd_mem : MEMWB_wd_reg;

  // ===========================================================================
  // IF : Instruction Fetch
  // ===========================================================================
  
  // (Forward declared)
  // wire       ID_branch = ID_RD1_zero & ID_brop;
  // wire [7:0] ID_braddr;

  reg [7:0] PC = 8'b00000000;
  wire [15:0] IF_insn;

  insn_mem_16x256 insn_mem(.ra(PC),
                           .rd(IF_insn));
  
  // IF/ID

  reg [15:0] IFID_insn;

  always @ (posedge advance_pipeline[1] or posedge RST) begin
    if (RST) begin
      IFID_insn <= 16'h0000;
      PC <= 8'h00;
    end
    else if (ID_branch) begin
      IFID_insn <= 16'h0000; // flush to NOP bubble
      PC <= ID_braddr;
    end
    else begin
      IFID_insn <= IF_insn;
      PC <= PC + 1; // mem is insn addressable
    end
  end
  
  // ===========================================================================
  // ID : Instruction Decode / Register Fetch
  // ===========================================================================
  
  // Control

  wire       ID_alusrc;
  wire       ID_memsrc;
  wire [4:0] ID_aluop;
  wire       ID_regdst;
  wire       ID_memwrite;
  wire       ID_regwrite;
  wire       ID_memtoreg;
  wire       ID_brop;

  control control(.opcode(IFID_insn[15:12]),
                  .ctl_alusrc(ID_alusrc),
                  .ctl_memsrc(ID_memsrc),
                  .ctl_aluop(ID_aluop),
                  .ctl_regdst(ID_regdst),
                  .ctl_memwrite(ID_memwrite),
                  .ctl_regwrite(ID_regwrite),
                  .ctl_memtoreg(ID_memtoreg),
                  .ctl_brop(ID_brop));

  // Register file access

  wire [3:0]  ID_rs = IFID_insn[11:8];
  wire [3:0]  ID_rt = IFID_insn[7:4];
  wire [15:0] ID_RD1;
  wire [15:0] ID_RD2;
  
  reg ID_writewindow;
  always @ (posedge CLK) begin
    if (advance_pipeline[1]) ID_writewindow <= 1;
    else ID_writewindow <= 0;
  end
  wire WB_regwrite = WB_CTL_regwrite & ID_writewindow;
  wire [3:0] ID_rwa1 = WB_regwrite ? WB_writeaddr : ID_rs;
  wire [3:0] ID_rwa1_or_scanreg = (|advance_pipeline | ID_writewindow) ? ID_rwa1 : scanreg_next;
  register_file_16x16 regfile(.clk(CLK),
                              .rst(RST),
                              
                              .rwa1(ID_rwa1_or_scanreg), // rs (read) / WA (write)
                              .ra2(ID_rt), // rt (read)
                              .rd1(ID_RD1),
                              .rd2(ID_RD2),

                              .we(WB_regwrite), // write enable
                              .wd(WB_writedata));

  // Branch logic

  wire ID_RD1_zero = ~(|ID_RD1);
  // (Forward declared)
  // wire       ID_branch = ID_RD1_zero & ID_brop;
  // wire [7:0] ID_braddr;
  assign ID_braddr = IFID_insn[7:0];

  // ID/EX

  reg        IDEX_CTL_EX_alusrc;
  reg        IDEX_CTL_EX_memsrc;
  reg [4:0]  IDEX_CTL_EX_aluop;
  reg        IDEX_CTL_EX_regdst;
  reg        IDEX_CTL_MEM_memwrite;
  reg        IDEX_CTL_WB_regwrite;
  reg        IDEX_CTL_WB_memtoreg;
  reg [15:0] IDEX_RD1;
  reg [15:0] IDEX_RD2;
  reg [7:0]  IDEX_imm;
  reg [3:0]  IDEX_rs; // R dest for I-type insns
  reg [3:0]  IDEX_rd; // R dest for R-type insns

  always @ (posedge advance_pipeline[1] or posedge RST) begin
    if (RST) begin
      IDEX_CTL_EX_alusrc <= 0;
      IDEX_CTL_EX_memsrc <= 0;
      IDEX_CTL_EX_aluop <= 0;
      IDEX_CTL_EX_regdst <= 0;
      IDEX_CTL_MEM_memwrite <= 0;
      IDEX_CTL_WB_regwrite <= 0;
      IDEX_CTL_WB_memtoreg <= 0;
      IDEX_RD1 <= 0;
      IDEX_RD2 <= 0;
      IDEX_imm <= 0;
      IDEX_rs <= 0;
      IDEX_rd <= 0;
    end
    else begin
      IDEX_CTL_EX_alusrc <= ID_alusrc;
      IDEX_CTL_EX_memsrc <= ID_memsrc;
      IDEX_CTL_EX_aluop <= ID_aluop;
      IDEX_CTL_EX_regdst <= ID_regdst;
      IDEX_CTL_MEM_memwrite <= ID_memwrite;
      IDEX_CTL_WB_regwrite <= ID_regwrite;
      IDEX_CTL_WB_memtoreg <= ID_memtoreg;
      IDEX_RD1 <= ID_RD1;
      IDEX_RD2 <= ID_RD2;
      IDEX_imm <= IFID_insn[7:0];
      IDEX_rs <= IFID_insn[11:8];
      IDEX_rd <= IFID_insn[3:0];
    end
  end

  // ===========================================================================
  // EX : Execution
  // ===========================================================================
  
  // wire [15:0] EX_aluin_a = IDEX_CTL_EX_alusrc_a == 0 ? IDEX_RD1 : 16'h0000;
  wire [15:0] EX_sext_imm = { {8{IDEX_imm[7]}}, IDEX_imm[7:0] };
  wire [15:0] EX_aluin_b = IDEX_CTL_EX_alusrc == 0 ? IDEX_RD2 : EX_sext_imm;
  wire [15:0] EX_aluout;

  alu_16 alu(.aluop(IDEX_CTL_EX_aluop),
             .a(IDEX_RD1),
             .b(EX_aluin_b),
             .result(EX_aluout),
             .ovf());

  // EX/MEM

  reg        EXMEM_CTL_MEM_memwrite;
  reg        EXMEM_CTL_WB_regwrite;
  reg        EXMEM_CTL_WB_memtoreg;
  reg [15:0] EXMEM_aluout;
  reg [15:0] EXMEM_mem_wd;
  reg [7:0]  EXMEM_mem_rwa;
  reg [15:0] EXMEM_reg_wa;

  always @ (posedge advance_pipeline[1] or posedge RST) begin
    if (RST) begin
      EXMEM_CTL_MEM_memwrite <= 0;
      EXMEM_CTL_WB_regwrite <= 0;
      EXMEM_CTL_WB_memtoreg <= 0;
      EXMEM_aluout <= 0;
      EXMEM_mem_wd <= 0;
      EXMEM_mem_rwa <= 0;
      EXMEM_reg_wa <= 0;
    end
    else begin
      EXMEM_CTL_MEM_memwrite <= IDEX_CTL_MEM_memwrite;
      EXMEM_CTL_WB_regwrite <= IDEX_CTL_WB_regwrite;
      EXMEM_CTL_WB_memtoreg <= IDEX_CTL_WB_memtoreg;
      EXMEM_aluout <= EX_aluout;
      EXMEM_mem_wd <= IDEX_RD1;
      EXMEM_mem_rwa <= IDEX_CTL_EX_memsrc ? IDEX_imm : IDEX_RD2;
      EXMEM_reg_wa <= IDEX_CTL_EX_regdst ? IDEX_rd : IDEX_rs;
    end
  end

  // ===========================================================================
  // MEM : Memory Access
  // ===========================================================================
  
  wire [15:0] MEM_data;
  wire MEM_memwrite = EXMEM_CTL_MEM_memwrite & advance_pipeline[1];

  data_mem_16x256 data_mem(.clk(CLK),
                           .rwa(EXMEM_mem_rwa),
                           .rd(MEM_data),
                           .we(MEM_memwrite),
                           .wd(EXMEM_mem_wd));

  // MEM/WB

  reg        MEMWB_CTL_WB_regwrite;
  reg        MEMWB_CTL_WB_memtoreg;
  reg [15:0] MEMWB_wd_mem;
  reg [15:0] MEMWB_wd_reg;
  reg [3:0]  MEMWB_wa;

  always @ (posedge advance_pipeline[1] or posedge RST) begin
    if (RST) begin
      MEMWB_CTL_WB_regwrite <= 0;
      MEMWB_CTL_WB_memtoreg <= 0;
      MEMWB_wd_mem <= 0;
      MEMWB_wd_reg <= 0;
      MEMWB_wa <= 0;
    end
    else begin
      MEMWB_CTL_WB_regwrite <= EXMEM_CTL_WB_regwrite;
      MEMWB_CTL_WB_memtoreg <= EXMEM_CTL_WB_memtoreg;
      MEMWB_wd_mem <= MEM_data;
      MEMWB_wd_reg <= EXMEM_aluout;
      MEMWB_wa <= EXMEM_reg_wa;
    end
  end
  
  // ===========================================================================
  // WB : Writeback
  // ===========================================================================

  // (Forward declared)
  // wire        WB_CTL_regwrite = MEMWB_CTL_WB_regwrite;
  // wire [3:0]  WB_writeaddr = MEMWB_wa;
  // wire [15:0] WB_writedata = MEMWB_CTL_WB_memtoreg ? MEMWB_wd_mem : MEMWB_wd_reg;
  
  // ===========================================================================
  // cpuout exports
  // ===========================================================================

  assign cpuout_PC = PC;
  always @ (posedge advance_pipeline[1] or posedge RST) begin
    if (RST) begin
      cpuout_IF_insn <= 0;
      cpuout_ID_insn <= 0;
      cpuout_EX_insn <= 0;
      cpuout_MEM_insn <= 0;
      cpuout_WB_insn <= 0;
    end
    else begin
      cpuout_IF_insn <= ID_branch ? 16'h0000 : IF_insn;
      cpuout_ID_insn <= cpuout_IF_insn;
      cpuout_EX_insn <= cpuout_ID_insn;
      cpuout_MEM_insn <= cpuout_EX_insn;
      cpuout_WB_insn <= cpuout_MEM_insn;
    end
  end

  assign cpuout_regfile_ra = advance_pipeline[1] ? 4'hx : scanreg_next;
  assign cpuout_regfile_rd = advance_pipeline[1] ? 16'hxxxx : ID_RD1;

endmodule // cpu
