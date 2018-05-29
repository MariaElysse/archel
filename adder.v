module adder (
  input  wire a, // input a
  input  wire b, // input b
  input  wire ci, // input carry in
  output wire s, // output sum
  output wire co, // output carry out
  );

  assign s = (a^b)^ci;
  assign co = ((a^b)&ci)|(a&b);
  
endmodule
