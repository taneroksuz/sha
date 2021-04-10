import sha_const::*;

module sha_1
(
  input logic rst,
  input logic clk,
  input logic [511:0] Data,
  input logic [0:0] Enable,
  output logic [159:0] Hash,
  output logic [0:0] Enable
);
  timeunit 1ns;
  timeprecision 1ps;

  function [31:0] K;
    input integer t;
    begin
      if (t<=19) begin
        K = 32'h5a827999;
      end else if (t<=39) begin
        K = 32'h6ed9eba1;
      end else if (t<=59) begin
        K = 32'h8f1bbcdc;
      end else begin
        K = 32'hca62c1d6;
      end
    end
  endfunction

  logic [31 : 0] H [0:4];

  initial begin

    H[0]=32'h67452301; H[1]=32'hefcdab89; H[2]=32'h98badcfe; H[3]=32'h10325476; H[4]=32'hc3d2e1f0;

  end

  always_comb begin

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin

    end else begin

    end
  end

endmodule
