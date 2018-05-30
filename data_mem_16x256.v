module data_mem_16x256 (
  input  wire        clk, 
  input  wire        rst, 
  input  wire [7:0]  rwa, 
  output reg  [15:0] rd,
  input  wire        we, 
  input  wire [15:0] wd
  );
  
  reg [15:0] ram [0:254];

  always @ (posedge clk) begin
    if (rst)
      // ram[254] <= 16'h0000; ram[253] <= 16'h0000; ram[252] <= 16'h0000; ram[251] <= 16'h0000; 
      // ram[250] <= 16'h0000; ram[249] <= 16'h0000; ram[248] <= 16'h0000; ram[247] <= 16'h0000; 
      // ram[246] <= 16'h0000; ram[245] <= 16'h0000; ram[244] <= 16'h0000; ram[243] <= 16'h0000; 
      // ram[242] <= 16'h0000; ram[241] <= 16'h0000; ram[240] <= 16'h0000; ram[239] <= 16'h0000; 
      // ...nevermind
      // it doesn't matter anyway (X)
      rd <= 16'h0000;
    else begin
      if (we)
        ram[rwa] <= wd;
      rd <= ram[rwa];
    end
  end
endmodule // insn_mem_16x256