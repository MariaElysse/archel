`timescale 1ns / 1ps

module debouncer(
  input wire clk;
  input wire btn;
  output wire btn_state;
  output wire btn_down; // pulse 1cy
  output wire btn_up; // pulse 1cy
  );
  
  reg [63:0] db_counter;
  
  always @ (posedge clk) begin
    if (btn == 0) db_counter <= 0;
    else begin
      db_counter <= db_counter + 1;
      if (&db_counter) btn_state <= ~btn_state;
    end
  end
  
  assign btn_down = btn & (&db_counter) & (~btn_state);
  assign btn_up   = btn & (&db_counter) & btn_state;
  
endmodule
