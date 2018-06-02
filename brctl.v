module brctl (
  input  wire [2:0] ctl_brop,
  input  wire       zero,
  output wire [1:0] pc_next,
  output wire       flush
  );
  
  wire do_branch = ctl_brop[2] & ((~ctl_brop[0] & zero) | (ctl_brop[0] & ~zero));
  assign flush = do_branch;

  // 00: PC+1, 10: imm, 11: reg
  assign pc_next = do_branch ? { 1'b1, ctl_brop[1] } : 2'b00;

endmodule // brctl
