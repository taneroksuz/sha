module sha256 (
    input logic rst,
    input logic clk,
    input logic [511:0] Data,
    input logic [63:0] Index,
    input logic [0:0] Enable,
    output logic [255:0] Hash,
    output logic [0:0] Ready
);
  timeunit 1ns; timeprecision 1ps;

  logic [31 : 0] D_d[0:63];
  logic [31 : 0] H_d[ 0:7];

  logic [31 : 0] D_q[0:63];
  logic [31 : 0] H_q[ 0:7];

  localparam logic [31 : 0] K[0:63] = '{
      32'H428A2F98,
      32'H71374491,
      32'HB5C0FBCF,
      32'HE9B5DBA5,
      32'H3956C25B,
      32'H59F111F1,
      32'H923F82A4,
      32'HAB1C5ED5,
      32'HD807AA98,
      32'H12835B01,
      32'H243185BE,
      32'H550C7DC3,
      32'H72BE5D74,
      32'H80DEB1FE,
      32'H9BDC06A7,
      32'HC19BF174,
      32'HE49B69C1,
      32'HEFBE4786,
      32'H0FC19DC6,
      32'H240CA1CC,
      32'H2DE92C6F,
      32'H4A7484AA,
      32'H5CB0A9DC,
      32'H76F988DA,
      32'H983E5152,
      32'HA831C66D,
      32'HB00327C8,
      32'HBF597FC7,
      32'HC6E00BF3,
      32'HD5A79147,
      32'H06CA6351,
      32'H14292967,
      32'H27B70A85,
      32'H2E1B2138,
      32'H4D2C6DFC,
      32'H53380D13,
      32'H650A7354,
      32'H766A0ABB,
      32'H81C2C92E,
      32'H92722C85,
      32'HA2BFE8A1,
      32'HA81A664B,
      32'HC24B8B70,
      32'HC76C51A3,
      32'HD192E819,
      32'HD6990624,
      32'HF40E3585,
      32'H106AA070,
      32'H19A4C116,
      32'H1E376C08,
      32'H2748774C,
      32'H34B0BCB5,
      32'H391C0CB3,
      32'H4ED8AA4A,
      32'H5B9CCA4F,
      32'H682E6FF3,
      32'H748F82EE,
      32'H78A5636F,
      32'H84C87814,
      32'H8CC70208,
      32'H90BEFFFA,
      32'HA4506CEB,
      32'HBEF9A3F7,
      32'HC67178F2
  };

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam STOP = 2'h2;

  typedef struct packed {
    logic [5 : 0]  iter;
    logic [1 : 0]  state;
    logic [0 : 0]  ready;
    logic [31 : 0] swap;
    logic [31 : 0] swap1;
    logic [31 : 0] swap0;
    logic [31 : 0] a;
    logic [31 : 0] b;
    logic [31 : 0] c;
    logic [31 : 0] d;
    logic [31 : 0] e;
    logic [31 : 0] f;
    logic [31 : 0] g;
    logic [31 : 0] h;
  } reg_type;

  reg_type init_reg = '{
      iter : 0,
      state : IDLE,
      ready : 0,
      swap : 0,
      swap1 : 0,
      swap0 : 0,
      a : 0,
      b : 0,
      c : 0,
      d : 0,
      e : 0,
      f : 0,
      g : 0,
      h : 0
  };

  reg_type r, rin;
  reg_type v;

  function [31:0] ROTR;
    input logic [31:0] x;
    input logic [4:0] n;
    begin
      ROTR = (x >> n) | (x << (32 - n));
    end
  endfunction

  function [31:0] SHR;
    input logic [31:0] x;
    input logic [4:0] n;
    begin
      SHR = x >> n;
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

  function [31:0] BIGSIGMA;
    input logic [31:0] x;
    input logic [0:0] t;
    begin
      if (t == 0) begin
        BIGSIGMA = ROTR(x, 2) ^ ROTR(x, 13) ^ ROTR(x, 22);
      end else begin
        BIGSIGMA = ROTR(x, 6) ^ ROTR(x, 11) ^ ROTR(x, 25);
      end
    end
  endfunction

  function [31:0] SMALLSIGMA;
    input logic [31:0] x;
    input logic [0:0] t;
    begin
      if (t == 0) begin
        SMALLSIGMA = ROTR(x, 7) ^ ROTR(x, 18) ^ SHR(x, 3);
      end else begin
        SMALLSIGMA = ROTR(x, 17) ^ ROTR(x, 19) ^ SHR(x, 10);
      end
    end
  endfunction

  always_comb begin

    v   = r;

    D_d = D_q;
    H_d = H_q;

    if (r.state == IDLE) begin

      if (Enable == 1) begin

        if (Index == 1) begin
          v.a = 32'H6A09E667;
          v.b = 32'HBB67AE85;
          v.c = 32'H3C6EF372;
          v.d = 32'HA54FF53A;
          v.e = 32'H510E527F;
          v.f = 32'H9B05688C;
          v.g = 32'H1F83D9AB;
          v.h = 32'H5BE0CD19;
        end

        H_d[0] = v.a;
        H_d[1] = v.b;
        H_d[2] = v.c;
        H_d[3] = v.d;
        H_d[4] = v.e;
        H_d[5] = v.f;
        H_d[6] = v.g;
        H_d[7] = v.h;

        for (int i = 0; i < 16; i = i + 1) begin
          D_d[i] = Data[i*32+:32];
        end

        v.iter  = 0;
        v.state = INIT;

      end

      v.ready = 0;

    end else if (r.state == INIT) begin

      if (v.iter < 16) begin
        v.swap = D_d[v.iter];
      end else begin
        v.swap = SMALLSIGMA(D_d[v.iter-2], 1) + D_d[v.iter-7] + SMALLSIGMA(D_d[v.iter-15], 0) + D_d[v.iter-16];
      end

      v.swap0 = v.h + BIGSIGMA(v.e, 1) + CH(v.e, v.f, v.g) + K[v.iter] + v.swap;
      v.swap1 = BIGSIGMA(v.a, 0) + MAJ(v.a, v.b, v.c);

      v.h = v.g;
      v.g = v.f;
      v.f = v.e;
      v.e = v.d + v.swap0;
      v.d = v.c;
      v.c = v.b;
      v.b = v.a;
      v.a = v.swap0 + v.swap1;

      D_d[v.iter] = v.swap;

      if (v.iter == 63) begin

        v.a = v.a + H_d[0];
        v.b = v.b + H_d[1];
        v.c = v.c + H_d[2];
        v.d = v.d + H_d[3];
        v.e = v.e + H_d[4];
        v.f = v.f + H_d[5];
        v.g = v.g + H_d[6];
        v.h = v.h + H_d[7];

        v.iter = 0;
        v.state = STOP;

      end else begin

        v.iter = v.iter + 1;

      end

      v.ready = 0;

    end else if (r.state == STOP) begin

      v.state = IDLE;
      v.ready = 1;

    end

    Hash  = {v.a, v.b, v.c, v.d, v.e, v.f, v.g, v.h};
    Ready = v.ready;

    rin   = v;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

  always_ff @(posedge clk) begin
    D_q <= D_d;
    H_q <= H_d;
  end

endmodule
