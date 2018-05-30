module insn_mem_16x256 (
  input  wire        clk, 
  input  wire        rst, 
  input  wire [7:0]  ra, 
  output reg  [15:0] rd
  );
  
  reg [15:0] ram [0:254];

  always @ (posedge clk) begin
    if (rst) begin
      $readmemb("program.archel", ram, 0, 254);
      rd <= 16'h0000;
    end
    else
      rd <= ram[ra];
  end
endmodule // insn_mem_16x256