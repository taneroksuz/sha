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

  logic [31 : 0] W_d [0:79];
  logic [31 : 0] D_d [0:15];
  logic [31 : 0] H_d [0:4];

  logic [31 : 0] W_q [0:79];
  logic [31 : 0] D_q [0:15];
  logic [31 : 0] H_q [0:4];

  logic [31 : 0] T_d;
  logic [31 : 0] T_q;

  localparam logic [31 : 0] H_1 [0:4] = '{
    32'H67452301,32'HEFCDAB89,32'H98BADCFE,32'H10325476,32'HC3D2E1F0
  };

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam STOP = 2'h2;

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

  always_comb begin

    v = r;

    W_d = W_q;
    D_d = D_q;
    H_d = H_q;
    T_d = T_q;

    if (r.state == IDLE) begin

      if (Enable == 1) begin

        if (Index == 1) begin
          H_d = H_1;
        end else begin
          H_d[0] = v.a;
          H_d[1] = v.b;
          H_d[2] = v.c;
          H_d[3] = v.d;
          H_d[4] = v.e;
        end

        for (int i=0; i<16; i=i+1) begin
          D_d[i] = Data[i*32 +: 32];
        end

        v.iter = 0;
        v.state = INIT;

      end

      v.ready = 0;

    end else if (r.state == INIT) begin

      if (v.iter < 16) begin
        W_d[v.iter] = D_d[v.iter[3:0]];
      end else begin
        W_d[v.iter] = ROTL((W_d[v.iter-3] ^ W_d[v.iter-8] ^ W_d[v.iter-14] ^ W_d[v.iter-16]),1);
      end

      if (v.iter == 79) begin

        v.a = H_d[0];
        v.b = H_d[1];
        v.c = H_d[2];
        v.d = H_d[3];
        v.e = H_d[4];

        v.iter = 0;
        v.state = STOP;

      end else begin

        v.iter = v.iter + 1;

      end

      v.ready = 0;

    end else if (r.state == STOP) begin

      T_d = ROTL(v.a,5) + F(v.b,v.c,v.d,v.iter) + v.e + K(v.iter) + W_d[v.iter];
      v.e = v.d;
      v.d = v.c;
      v.c = ROTL(v.b,30);
      v.b = v.a;
      v.a = T_d;

      if (v.iter == 79) begin

        v.a = v.a + H_d[0];
        v.b = v.b + H_d[1];
        v.c = v.c + H_d[2];
        v.d = v.d + H_d[3];
        v.e = v.e + H_d[4];

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

  always_ff @(posedge clk) begin
    W_q <= W_d;
    D_q <= D_d;
    H_q <= H_d;
    T_q <= T_d;
  end

endmodule
