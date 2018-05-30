module register_file_16x16 (
  input  wire        clk, 
  input  wire        rst, 
  input  wire [3:0]  ra1, 
  input  wire [3:0]  ra2, 
  output reg  [15:0] rd1, 
  output reg  [15:0] rd2, 
  input  wire        we, 
  input  wire [3:0]  wa, 
  input  wire [15:0] wd
  );
  
  reg [15:0] ram [0:15];

  always @ (posedge clk) begin
    if (rst) begin
      ram[15] <= 16'h0000;
      ram[14] <= 16'h0000;
      ram[13] <= 16'h0000;
      ram[12] <= 16'h0000;
      ram[11] <= 16'h0000;
      ram[10] <= 16'h0000;
      ram[9] <= 16'h0000;
      ram[8] <= 16'h0000;
      ram[7] <= 16'h0000;
      ram[6] <= 16'h0000;
      ram[5] <= 16'h0000;
      ram[4] <= 16'h0000;
      ram[3] <= 16'h0000;
      ram[2] <= 16'h0000;
      ram[1] <= 16'h0000;
      ram[0] <= 16'h0000;
      rd1 <= 16'h0000;
      rd2 <= 16'h0000;
    end // if (rst)
    else begin
      if (we)
        ram[wa] <= wd;
      rd1 <= ram[ra1];
      rd2 <= ram[ra2];
    end // else
  end
endmodule // register_file_16x16