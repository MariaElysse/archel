/** Dual-port RAM */
module register_file_16x16 (
  input  wire        clk, 
  input  wire        rst, 
  input  wire [3:0]  rwa1,
  input  wire [3:0]  ra2,
  output wire [15:0] rd1,
  output wire [15:0] rd2,
  input  wire        we,
  input  wire [15:0] wd
  );
  
  reg [15:0] ram [15:0];
  wire clkrst = clk | rst;

  always @ (clkrst) begin
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
    end // if (rst)
    else begin
      if (we)
        ram[rwa1] <= wd;
    end // else
  end

  assign rd1 = ram[rwa1];
  assign rd2 = ram[ra2];

endmodule // register_file_16x16
