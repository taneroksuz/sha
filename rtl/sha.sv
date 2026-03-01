module sha #(
    parameter integer VARIANT = 256
) (
    input  logic                  rst,
    input  logic                  clk,
    input  logic [BLOCK_BITS-1:0] Data,
    input  logic [INDEX_BITS-1:0] Index,
    input  logic [           0:0] Enable,
    output logic [   VARIANT-1:0] Hash,
    output logic [           0:0] Ready
);
  timeunit 1ns; timeprecision 1ps;

  localparam integer W = (VARIANT == 256) ? 32 : 64;
  localparam integer ROUNDS = (VARIANT == 256) ? 64 : 80;
  localparam integer BLOCK_BITS = (VARIANT == 256) ? 512 : 1024;
  localparam integer INDEX_BITS = (VARIANT == 256) ? 64 : 128;
  localparam integer ITER_BITS = (VARIANT == 256) ? 6 : 7;

  localparam integer BS0_R0 = (VARIANT == 256) ? 2 : 28;
  localparam integer BS0_R1 = (VARIANT == 256) ? 13 : 34;
  localparam integer BS0_R2 = (VARIANT == 256) ? 22 : 39;
  localparam integer BS1_R0 = (VARIANT == 256) ? 6 : 14;
  localparam integer BS1_R1 = (VARIANT == 256) ? 11 : 18;
  localparam integer BS1_R2 = (VARIANT == 256) ? 25 : 41;
  localparam integer SS0_R0 = (VARIANT == 256) ? 7 : 1;
  localparam integer SS0_R1 = (VARIANT == 256) ? 18 : 8;
  localparam integer SS0_S = (VARIANT == 256) ? 3 : 7;
  localparam integer SS1_R0 = (VARIANT == 256) ? 17 : 19;
  localparam integer SS1_R1 = (VARIANT == 256) ? 19 : 61;
  localparam integer SS1_S = (VARIANT == 256) ? 10 : 6;

  localparam logic [31:0] K256[0:63] = '{
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

  localparam logic [63:0] K512[0:79] = '{
      64'H428A2F98D728AE22,
      64'H7137449123EF65CD,
      64'HB5C0FBCFEC4D3B2F,
      64'HE9B5DBA58189DBBC,
      64'H3956C25BF348B538,
      64'H59F111F1B605D019,
      64'H923F82A4AF194F9B,
      64'HAB1C5ED5DA6D8118,
      64'HD807AA98A3030242,
      64'H12835B0145706FBE,
      64'H243185BE4EE4B28C,
      64'H550C7DC3D5FFB4E2,
      64'H72BE5D74F27B896F,
      64'H80DEB1FE3B1696B1,
      64'H9BDC06A725C71235,
      64'HC19BF174CF692694,
      64'HE49B69C19EF14AD2,
      64'HEFBE4786384F25E3,
      64'H0FC19DC68B8CD5B5,
      64'H240CA1CC77AC9C65,
      64'H2DE92C6F592B0275,
      64'H4A7484AA6EA6E483,
      64'H5CB0A9DCBD41FBD4,
      64'H76F988DA831153B5,
      64'H983E5152EE66DFAB,
      64'HA831C66D2DB43210,
      64'HB00327C898FB213F,
      64'HBF597FC7BEEF0EE4,
      64'HC6E00BF33DA88FC2,
      64'HD5A79147930AA725,
      64'H06CA6351E003826F,
      64'H142929670A0E6E70,
      64'H27B70A8546D22FFC,
      64'H2E1B21385C26C926,
      64'H4D2C6DFC5AC42AED,
      64'H53380D139D95B3DF,
      64'H650A73548BAF63DE,
      64'H766A0ABB3C77B2A8,
      64'H81C2C92E47EDAEE6,
      64'H92722C851482353B,
      64'HA2BFE8A14CF10364,
      64'HA81A664BBC423001,
      64'HC24B8B70D0F89791,
      64'HC76C51A30654BE30,
      64'HD192E819D6EF5218,
      64'HD69906245565A910,
      64'HF40E35855771202A,
      64'H106AA07032BBD1B8,
      64'H19A4C116B8D2D0C8,
      64'H1E376C085141AB53,
      64'H2748774CDF8EEB99,
      64'H34B0BCB5E19B48A8,
      64'H391C0CB3C5C95A63,
      64'H4ED8AA4AE3418ACB,
      64'H5B9CCA4F7763E373,
      64'H682E6FF3D6B2B8A3,
      64'H748F82EE5DEFB2FC,
      64'H78A5636F43172F60,
      64'H84C87814A1F0AB72,
      64'H8CC702081A6439EC,
      64'H90BEFFFA23631E28,
      64'HA4506CEBDE82BDE9,
      64'HBEF9A3F7B2C67915,
      64'HC67178F2E372532B,
      64'HCA273ECEEA26619C,
      64'HD186B8C721C0C207,
      64'HEADA7DD6CDE0EB1E,
      64'HF57D4F7FEE6ED178,
      64'H06F067AA72176FBA,
      64'H0A637DC5A2C898A6,
      64'H113F9804BEF90DAE,
      64'H1B710B35131C471B,
      64'H28DB77F523047D84,
      64'H32CAAB7B40C72493,
      64'H3C9EBE0A15C9BEBC,
      64'H431D67C49C100D4C,
      64'H4CC5D4BECB3E42B6,
      64'H597F299CFC657E2A,
      64'H5FCB6FAB3AD6FAEC,
      64'H6C44198C4A475817
  };

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam STOP = 2'h2;

  typedef struct packed {
    logic [ITER_BITS-1:0] iter;
    logic [1:0]           state;
    logic [0:0]           ready;
    logic [W-1:0]         swap;
    logic [W-1:0]         swap1;
    logic [W-1:0]         swap0;
    logic [W-1:0]         a;
    logic [W-1:0]         b;
    logic [W-1:0]         c;
    logic [W-1:0]         d;
    logic [W-1:0]         e;
    logic [W-1:0]         f;
    logic [W-1:0]         g;
    logic [W-1:0]         h;
  } reg_type;

  reg_type init_reg = '{
      iter  : 0,
      state : IDLE,
      ready : 0,
      swap  : 0,
      swap1 : 0,
      swap0 : 0,
      a     : 0,
      b     : 0,
      c     : 0,
      d     : 0,
      e     : 0,
      f     : 0,
      g     : 0,
      h     : 0
  };

  logic [W-1:0] D_d[0:ROUNDS-1];
  logic [W-1:0] H_d[0:7];

  logic [W-1:0] D_q[0:ROUNDS-1];
  logic [W-1:0] H_q[0:7];

  reg_type r, rin;
  reg_type v;

  function automatic [W-1:0] K_val;
    input integer i;
    begin
      K_val = (VARIANT == 256) ? W'(K256[i]) : W'(K512[i]);
    end
  endfunction

  function [W-1:0] ROTR;
    input logic [W-1:0] x;
    input logic [6:0] n;
    begin
      ROTR = (x >> n) | (x << (W[6:0] - n));
    end
  endfunction

  function [W-1:0] SHR;
    input logic [W-1:0] x;
    input logic [6:0] n;
    begin
      SHR = x >> n;
    end
  endfunction

  function [W-1:0] CH;
    input logic [W-1:0] x;
    input logic [W-1:0] y;
    input logic [W-1:0] z;
    begin
      CH = (x & y) ^ ((~x) & z);
    end
  endfunction

  function [W-1:0] MAJ;
    input logic [W-1:0] x;
    input logic [W-1:0] y;
    input logic [W-1:0] z;
    begin
      MAJ = (x & y) ^ (x & z) ^ (y & z);
    end
  endfunction

  function [W-1:0] BIGSIGMA;
    input logic [W-1:0] x;
    input logic [0:0] t;
    begin
      if (t == 0) begin
        BIGSIGMA = ROTR(x, 7'(BS0_R0)) ^ ROTR(x, 7'(BS0_R1)) ^ ROTR(x, 7'(BS0_R2));
      end else begin
        BIGSIGMA = ROTR(x, 7'(BS1_R0)) ^ ROTR(x, 7'(BS1_R1)) ^ ROTR(x, 7'(BS1_R2));
      end
    end
  endfunction

  function [W-1:0] SMALLSIGMA;
    input logic [W-1:0] x;
    input logic [0:0] t;
    begin
      if (t == 0) begin
        SMALLSIGMA = ROTR(x, 7'(SS0_R0)) ^ ROTR(x, 7'(SS0_R1)) ^ SHR(x, 7'(SS0_S));
      end else begin
        SMALLSIGMA = ROTR(x, 7'(SS1_R0)) ^ ROTR(x, 7'(SS1_R1)) ^ SHR(x, 7'(SS1_S));
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
          if (VARIANT == 256) begin
            v.a = W'(32'H6A09E667);
            v.b = W'(32'HBB67AE85);
            v.c = W'(32'H3C6EF372);
            v.d = W'(32'HA54FF53A);
            v.e = W'(32'H510E527F);
            v.f = W'(32'H9B05688C);
            v.g = W'(32'H1F83D9AB);
            v.h = W'(32'H5BE0CD19);
          end else begin
            v.a = W'(64'H6A09E667F3BCC908);
            v.b = W'(64'HBB67AE8584CAA73B);
            v.c = W'(64'H3C6EF372FE94F82B);
            v.d = W'(64'HA54FF53A5F1D36F1);
            v.e = W'(64'H510E527FADE682D1);
            v.f = W'(64'H9B05688C2B3E6C1F);
            v.g = W'(64'H1F83D9ABFB41BD6B);
            v.h = W'(64'H5BE0CD19137E2179);
          end
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
          D_d[i] = Data[i*W+:W];
        end

        v.iter  = 0;
        v.state = INIT;

      end

      v.ready = 0;

    end else if (r.state == INIT) begin

      if (v.iter < 16) begin
        v.swap = D_d[v.iter];
      end else begin
        v.swap = SMALLSIGMA(D_d[v.iter-2], 1) + D_d[v.iter-7] + SMALLSIGMA(D_d[v.iter-15], 0) +
            D_d[v.iter-16];
      end

      v.swap0 = v.h + BIGSIGMA(v.e, 1) + CH(v.e, v.f, v.g) + K_val(int'(v.iter)) + v.swap;
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

      if (v.iter == ITER_BITS'(ROUNDS - 1)) begin

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
