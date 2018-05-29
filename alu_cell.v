module alu_cell (
  input  wire a_invert, // invert a
  input  wire b_invert, // invert b
  input  wire ci,       // carry in
  input  wire [1:0] op, // operation (and|or|adder|less)
  input  wire a,        // input a
  input  wire b,        // input b
  input  wire less,     // for slt
  output wire result,   // result
  output wire co        // carry out
  );

  wire ainv = a_invert ? ~a : a;
  wire binv = b_invert ? ~b : b;
  wire sum;

  adder adder(.a(ainv), .b(binv), .ci(ci), .s(sum), .co(co));

  mux_16_4 mux(.in_1(ainv & binv),
               .in_2(ainv | binv),
               .in_3(sum),
               .in_4(less),
               .sel(op),
               .out(result));]
  
endmodule
