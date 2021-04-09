import sha_const::*;
import sha_wire::*;

module sha_tb_vivado;

  timeunit 1ns;
  timeprecision 1ps;

  logic rst;
  logic clk;

  initial begin
    clk = 1;
  end

  always begin
    #5;
    clk = !clk;
  end

  initial begin
    rst = 0;
    #100;
    rst = 1;
  end

  sha_tb sha_tb_comp
  (
    .rst (rst),
    .clk (clk)
  );

endmodule
