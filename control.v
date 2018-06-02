module control (
  input  wire [3:0] opcode,
  output reg        ctl_alusrc,
  output reg        ctl_memsrc,
  output reg  [4:0] ctl_aluop,
  output reg        ctl_regdst,
  output reg        ctl_memwrite,
  output reg        ctl_regwrite,
  output reg        ctl_memtoreg,
  output reg        ctl_brop
  );

  always @ (*) begin
    case (opcode)
      4'b0000 : begin // NOP
        ctl_alusrc <=   1'bx;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'bxxxxx;
        ctl_regdst <=   1'bx;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b0;
        ctl_memtoreg <= 1'bx;
        ctl_brop <=     1'b0;
      end
      4'b0001 : begin // ADD
        ctl_alusrc <=   1'b0;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'b00010;
        ctl_regdst <=   1'b1;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b1;
        ctl_memtoreg <= 1'b0;
        ctl_brop <=     1'b0;
      end
      4'b0010 : begin // ADDI
        ctl_alusrc <=   1'b1;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'b00010;
        ctl_regdst <=   1'b0;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b1;
        ctl_memtoreg <= 1'b0;
        ctl_brop <=     1'b0;
      end
      4'b0011 : begin // SUB
        ctl_alusrc <=   1'b0;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'b01110;
        ctl_regdst <=   1'b1;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b1;
        ctl_memtoreg <= 1'b0;
        ctl_brop <=     1'b0;
      end
      4'b0100 : begin // AND
        ctl_alusrc <=   1'b0;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'b00000;
        ctl_regdst <=   1'b1;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b1;
        ctl_memtoreg <= 1'b0;
        ctl_brop <=     1'b0;
      end
      4'b0101 : begin // OR
        ctl_alusrc <=   1'b0;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'b00001;
        ctl_regdst <=   1'b1;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b1;
        ctl_memtoreg <= 1'b0;
        ctl_brop <=     1'b0;
      end
      4'b0110 : begin // SLT
        ctl_alusrc <=   1'b0;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'b01111;
        ctl_regdst <=   1'b1;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b1;
        ctl_memtoreg <= 1'b0;
        ctl_brop <=     1'b0;
      end
      4'b1000 : begin // LW
        ctl_alusrc <=   1'bx;
        ctl_memsrc <=   1'b0;
        ctl_aluop <=    5'bxxxxx;
        ctl_regdst <=   1'b1;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b1;
        ctl_memtoreg <= 1'b1;
        ctl_brop <=     1'b0;
      end
      4'b1001 : begin // SW
        ctl_alusrc <=   1'bx;
        ctl_memsrc <=   1'b0;
        ctl_aluop <=    5'bxxxxx;
        ctl_regdst <=   1'bx;
        ctl_memwrite <= 1'b1;
        ctl_regwrite <= 1'b0;
        ctl_memtoreg <= 1'bx;
        ctl_brop <=     1'b0;
      end
      4'b1010 : begin // SWI
        ctl_alusrc <=   1'bx;
        ctl_memsrc <=   1'b1;
        ctl_aluop <=    5'bxxxxx;
        ctl_regdst <=   1'bx;
        ctl_memwrite <= 1'b1;
        ctl_regwrite <= 1'b0;
        ctl_memtoreg <= 1'bx;
        ctl_brop <=     1'b0;
      end
      4'b1100 : begin // BEZ
        ctl_alusrc <=   1'bx;
        ctl_memsrc <=   1'bx;
        ctl_aluop <=    5'bxxxxx;
        ctl_regdst <=   1'bx;
        ctl_memwrite <= 1'b0;
        ctl_regwrite <= 1'b0;
        ctl_memtoreg <= 1'bx;
        ctl_brop <=     1'b1;
      end
    endcase
  end
endmodule
