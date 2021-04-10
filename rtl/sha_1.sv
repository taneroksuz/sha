import sha_const::*;

module sha_1
(
  input logic rst,
  input logic clk,
  input logic [511:0] Data,
  input logic [63:0] Index,
  input logic [0:0] Enable,
  output logic [159:0] Hash,
  output logic [0:0] Ready
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] W [0:79];
  logic [31 : 0] R [0:4];
  logic [31 : 0] H [0:4];

  logic [31 : 0] H_1 [0:4];

  function [31:0] K;
    input logic [6:0] t;
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

  function [31:0] ROTL;
    input logic [31:0] x;
    input logic [4:0] n;
    begin
      ROTL = (x << n) | (x >> (32-n));
    end
  endfunction

  function [31:0] CH;
    input logic [31:0] x;
    input logic [31:0] y;
    input logic [31:0] z;
    begin
      CH = (x & y) ^ ((~x) & z);
    end
  endfunction

  function [31:0] MAJ;
    input logic [31:0] x;
    input logic [31:0] y;
    input logic [31:0] z;
    begin
      MAJ = (x & y) ^ (x & z) ^ (y & z);
    end
  endfunction

  function [31:0] PARITY;
    input logic [31:0] x;
    input logic [31:0] y;
    input logic [31:0] z;
    begin
      PARITY = x ^ y ^ z;
    end
  endfunction

  function [31:0] F;
    input logic [31:0] x;
    input logic [31:0] y;
    input logic [31:0] z;
    input logic [6:0] t;
    begin
      if (t<=19) begin
        F = CH(x,y,z);
      end else if (t<=39) begin
        F = PARITY(x,y,z);
      end else if (t<=59) begin
        F = MAJ(x,y,z);
      end else begin
        F = PARITY(x,y,z);
      end
    end
  endfunction

  initial begin

    H_1[0]=32'h67452301; H_1[1]=32'hefcdab89; H_1[2]=32'h98badcfe; H_1[3]=32'h10325476; H_1[4]=32'hc3d2e1f0;

  end

  always_comb begin

    if (Enable == 1) begin
      if (Index == 0) begin
        H = H_1;
      end
    end

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin

    end else begin

    end
  end

endmodule
