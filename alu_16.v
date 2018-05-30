module alu_16 (
  // input  wire a_invert,      // invert a
  // input  wire b_invert,      // invert b
  // input  wire ci,            // carry in
  // input  wire [1:0] op,      // operation (and|or|adder|less)
  input  wire [4:0] aluop,   // [inva invb ci op op]
  input  wire [15:0] a,      // input a
  input  wire [15:0] b,      // input b
  output wire [15:0] result, // result
  output wire ovf          // overflow
  );
  
  wire a_invert = aluop[4];   // invert a
  wire b_invert = aluop[3];   // invert b
  wire ci       = aluop[2];   // carry in
  wire [1:0] op = aluop[1:0]; // operation (and|or|adder|less)

  wire c_o0_i1;
  wire c_o1_i2;
  wire c_o2_i3;
  wire c_o3_i4;
  wire c_o4_i5;
  wire c_o5_i6;
  wire c_o6_i7;
  wire c_o7_i8;
  wire c_o8_i9;
  wire c_o9_i10;
  wire c_o10_i11;
  wire c_o11_i12;
  wire c_o12_i13;
  wire c_o13_i14;
  wire c_o14_i15;

  wire c_o15;
  wire set;

  assign ovf = c_o14_i15 ^ c_o15;

  alu_cell cell_0(.ci(ci),
                  .a(a[0]),
                  .b(b[0]),
                  .result(result[0]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(set),
                  .co(c_o0_i1));
  alu_cell cell_1(.ci(c_o0_i1),
                  .a(a[1]),
                  .b(b[1]),
                  .result(result[1]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o1_i2));
  alu_cell cell_2(.ci(c_o1_i2),
                  .a(a[2]),
                  .b(b[2]),
                  .result(result[2]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o2_i3));
  alu_cell cell_3(.ci(c_o2_i3),
                  .a(a[3]),
                  .b(b[3]),
                  .result(result[3]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o3_i4));
  alu_cell cell_4(.ci(c_o3_i4),
                  .a(a[4]),
                  .b(b[4]),
                  .result(result[4]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o4_i5));
  alu_cell cell_5(.ci(c_o4_i5),
                  .a(a[5]),
                  .b(b[5]),
                  .result(result[5]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o5_i6));
  alu_cell cell_6(.ci(c_o5_i6),
                  .a(a[6]),
                  .b(b[6]),
                  .result(result[6]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o6_i7));
  alu_cell cell_7(.ci(c_o6_i7),
                  .a(a[7]),
                  .b(b[7]),
                  .result(result[7]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o7_i8));
  alu_cell cell_8(.ci(c_o7_i8),
                  .a(a[8]),
                  .b(b[8]),
                  .result(result[8]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o8_i9));
  alu_cell cell_9(.ci(c_o8_i9),
                  .a(a[9]),
                  .b(b[9]),
                  .result(result[9]),
                  .a_invert(a_invert),
                  .b_invert(b_invert),
                  .op(op),
                  .less(0),
                  .co(c_o9_i10));
  alu_cell cell_10(.ci(c_o9_i10),
                   .a(a[10]),
                   .b(b[10]),
                   .result(result[10]),
                   .a_invert(a_invert),
                   .b_invert(b_invert),
                   .op(op),
                   .less(0),
                   .co(c_o10_i11));
  alu_cell cell_11(.ci(c_o10_i11),
                   .a(a[11]),
                   .b(b[11]),
                   .result(result[11]),
                   .a_invert(a_invert),
                   .b_invert(b_invert),
                   .op(op),
                   .less(0),
                   .co(c_o11_i12));
  alu_cell cell_12(.ci(c_o11_i12),
                   .a(a[12]),
                   .b(b[12]),
                   .result(result[12]),
                   .a_invert(a_invert),
                   .b_invert(b_invert),
                   .op(op),
                   .less(0),
                   .co(c_o12_i13));
  alu_cell cell_13(.ci(c_o12_i13),
                   .a(a[13]),
                   .b(b[13]),
                   .result(result[13]),
                   .a_invert(a_invert),
                   .b_invert(b_invert),
                   .op(op),
                   .less(0),
                   .co(c_o13_i14));
  alu_cell cell_14(.ci(c_o13_i14),
                   .a(a[14]),
                   .b(b[14]),
                   .result(result[14]),
                   .a_invert(a_invert),
                   .b_invert(b_invert),
                   .op(op),
                   .less(0),
                   .co(c_o14_i15));
  alu_cell_last cell_15(.ci(c_o14_i15),
                        .a(a[15]),
                        .b(b[15]),
                        .result(result[15]),
                        .a_invert(a_invert),
                        .b_invert(b_invert),
                        .op(op),
                        .less(0),
                        .co(c_o15),
                        .set(set));
endmodule
