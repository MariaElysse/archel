/** Single-port RAM */
module data_mem_16x256 (
  input  wire        clk, 
  // input  wire        rst, 
  input  wire [7:0]  a, 
  output wire [15:0] rd,
  input  wire        we, 
  input  wire [15:0] wd
  );
  
  reg [15:0] ram [255:0];

  always @ (posedge clk) begin
    if (we)
      ram[a] <= wd;
  end

  assign rd = ram[a];

endmodule // insn_mem_16x256
