import sha_const::*;

module sha
(
  input logic rst,
  input logic clk,
  input sha_in_type sha_in,
  output sha_out_type sha_out
);
  timeunit 1ns;
  timeprecision 1ps;

endmodule
