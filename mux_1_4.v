module mux_1_4 (
  input  wire in_a,
  input  wire in_b,
  input  wire in_c,
  input  wire in_d,
  input  wire [1:0] sel,
  input  wire out
  );

  wire ab;
  wire cd;
  
  assign ab = sel == 0 ? in_a : in_b;
  assign cd = sel == 2 ? in_c : in_d;
  assign out = (sel == 0 || sel == 1) ? ab : cd;
  
endmodule