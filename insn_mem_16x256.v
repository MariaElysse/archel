/** Single-port ROM */
module insn_mem_16x256 (
  // input  wire        clk, 
  // input  wire        rst, 
  input  wire [7:0]  ra, 
  output wire [15:0] rd
  );

  reg [15:0] ram [255:0];

  initial begin
    $readmemb("program.archel", ram, 0, 255);
  end // initial

  assign rd = ram[ra];

endmodule // insn_mem_16x256
