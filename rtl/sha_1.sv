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
  logic [31 : 0] T;

  logic [31 : 0] H_1 [0:4];

  logic [31 : 0] D [0:15];

  integer i;

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam END  = 2'h2;

  typedef struct packed{
    logic [6 : 0] iter;
    logic [1 : 0] state;
    logic [0 : 0] ready;
  } reg_type;

  reg_type init_reg = '{
    iter : 0,
    state : IDLE,
    ready : 0
  };

  reg_type r,rin;
  reg_type v;

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

    v = r;

    if (r.state == IDLE) begin

      if (Enable == 1) begin

        if (Index == 0) begin
          H = H_1;
        end

        for (i=0; i<16; i=i+1) begin
          D[i] = Data[i*32 +: 32];
        end

        v.iter = 0;
        v.state = INIT;

      end

      v.ready = 0;

    end else if (r.state == INIT) begin

      if (v.iter < 16) begin
        W[v.iter] = D[v.iter[3:0]];
      end else begin
        W[v.iter] = ROTL((W[v.iter-3] ^ W[v.iter-8] ^ W[v.iter-14] ^ W[v.iter-16]),1);
      end

      if (v.iter == 79) begin

        for (i=0; i<5; i=i+1) begin
          R[i] = H[i];
        end

        v.iter = 0;
        v.state = END;

      end else begin

        v.iter = v.iter + 1;

      end

      v.ready = 0;

    end else if (r.state == END) begin

      T = ROTL(R[0],5) + F(R[1],R[2],R[3],v.iter) + R[4] + K(v.iter) + W[v.iter];
      R[4] = R[3];
      R[3] = R[2];
      R[2] = ROTL(R[1],30);
      R[1] = R[0];
      R[0] = T;

      if (v.iter == 79) begin

        for (i=0; i<5; i=i+1) begin
          H[i] = R[i] + H[i];
        end

        v.iter = 0;
        v.state = IDLE;
        v.ready = 1;

      end else begin

        v.iter = v.iter + 1;
        v.ready = 0;

      end

    end

    Hash = {H[0],H[1],H[2],H[3],H[4]};
    Ready = v.ready;

    rin = v;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
