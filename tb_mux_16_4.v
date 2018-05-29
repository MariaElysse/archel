module tb;
  reg [1:0] sel;
  wire [15:0] out;
  
  mux_16_4 mux(.a(16'b1111111100000000),
               .b(16'b1111000011110000),
               .c(16'b1100110011001100),
               .d(16'b1010101010101010),
               .sel(sel),
               .o(out));
  
  initial begin
    sel = 0;
    #1;
    sel = 1;
    #1;
    sel = 2;
    #1;
    sel = 3;
    #1;
  end
endmodule