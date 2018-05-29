module mux_16_4 (
  input  wire [15:0] in_1,
  input  wire [15:0] in_2,
  input  wire [15:0] in_3,
  input  wire [15:0] in_4,
  input  wire [1:0] sel,
  input  wire [15:0] out
  );

  wire [15:0] ab;
  wire [15:0] cd;
  
  assign ab = sel == 0 ? in_1 : in_2;
  assign cd = sel == 2 ? in_3 : in_4;
  assign out = (sel == 0 || sel == 1) ? ab : cd;
  
endmodule