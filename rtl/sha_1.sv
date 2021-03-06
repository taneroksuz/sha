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
    logic [31 : 0] a;
    logic [31 : 0] b;
    logic [31 : 0] c;
    logic [31 : 0] d;
    logic [31 : 0] e;
  } reg_type;

  reg_type init_reg = '{
    iter : 0,
    state : IDLE,
    ready : 0,
    a : 0,
    b : 0,
    c : 0,
    d : 0,
    e : 0
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

  always_latch begin

    v = r;

    if (r.state == IDLE) begin

      if (Enable == 1) begin

        if (Index == 1) begin
          H = H_1;
        end else begin
          H[0] = v.a;
          H[1] = v.b;
          H[2] = v.c;
          H[3] = v.d;
          H[4] = v.e;
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

        v.a = H[0];
        v.b = H[1];
        v.c = H[2];
        v.d = H[3];
        v.e = H[4];

        v.iter = 0;
        v.state = END;

      end else begin

        v.iter = v.iter + 1;

      end

      v.ready = 0;

    end else if (r.state == END) begin

      T = ROTL(v.a,5) + F(v.b,v.c,v.d,v.iter) + v.e + K(v.iter) + W[v.iter];
      v.e = v.d;
      v.d = v.c;
      v.c = ROTL(v.b,30);
      v.b = v.a;
      v.a = T;

      if (v.iter == 79) begin

        v.a = v.a + H[0];
        v.b = v.b + H[1];
        v.c = v.c + H[2];
        v.d = v.d + H[3];
        v.e = v.e + H[4];

        v.iter = 0;
        v.state = IDLE;
        v.ready = 1;

      end else begin

        v.iter = v.iter + 1;
        v.ready = 0;

      end

    end

    Hash = {v.a,v.b,v.c,v.d,v.e};
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
