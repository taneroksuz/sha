module sha_2_512
(
  input logic rst,
  input logic clk,
  input logic [1023:0] Data,
  input logic [127:0] Index,
  input logic [1:0] Operation,
  input logic [0:0] Enable,
  output logic [511:0] Hash,
  output logic [0:0] Ready
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [63 : 0] W_d [0:79];
  logic [63 : 0] D_d [0:15];
  logic [63 : 0] H_d [0:7];
  logic [63 : 0] T_d [0:1];

  logic [63 : 0] W_q [0:79];
  logic [63 : 0] D_q [0:15];
  logic [63 : 0] H_q [0:7];
  logic [63 : 0] T_q [0:1];

  localparam logic [63 : 0] K [0:79] = '{
    64'H428A2F98D728AE22,64'H7137449123EF65CD,64'HB5C0FBCFEC4D3B2F,64'HE9B5DBA58189DBBC,
    64'H3956C25BF348B538,64'H59F111F1B605D019,64'H923F82A4AF194F9B,64'HAB1C5ED5DA6D8118,
    64'HD807AA98A3030242,64'H12835B0145706FBE,64'H243185BE4EE4B28C,64'H550C7DC3D5FFB4E2,
    64'H72BE5D74F27B896F,64'H80DEB1FE3B1696B1,64'H9BDC06A725C71235,64'HC19BF174CF692694,
    64'HE49B69C19EF14AD2,64'HEFBE4786384F25E3,64'H0FC19DC68B8CD5B5,64'H240CA1CC77AC9C65,
    64'H2DE92C6F592B0275,64'H4A7484AA6EA6E483,64'H5CB0A9DCBD41FBD4,64'H76F988DA831153B5,
    64'H983E5152EE66DFAB,64'HA831C66D2DB43210,64'HB00327C898FB213F,64'HBF597FC7BEEF0EE4,
    64'HC6E00BF33DA88FC2,64'HD5A79147930AA725,64'H06CA6351E003826F,64'H142929670A0E6E70,
    64'H27B70A8546D22FFC,64'H2E1B21385C26C926,64'H4D2C6DFC5AC42AED,64'H53380D139D95B3DF,
    64'H650A73548BAF63DE,64'H766A0ABB3C77B2A8,64'H81C2C92E47EDAEE6,64'H92722C851482353B,
    64'HA2BFE8A14CF10364,64'HA81A664BBC423001,64'HC24B8B70D0F89791,64'HC76C51A30654BE30,
    64'HD192E819D6EF5218,64'HD69906245565A910,64'HF40E35855771202A,64'H106AA07032BBD1B8,
    64'H19A4C116B8D2D0C8,64'H1E376C085141AB53,64'H2748774CDF8EEB99,64'H34B0BCB5E19B48A8,
    64'H391C0CB3C5C95A63,64'H4ED8AA4AE3418ACB,64'H5B9CCA4F7763E373,64'H682E6FF3D6B2B8A3,
    64'H748F82EE5DEFB2FC,64'H78A5636F43172F60,64'H84C87814A1F0AB72,64'H8CC702081A6439EC,
    64'H90BEFFFA23631E28,64'HA4506CEBDE82BDE9,64'HBEF9A3F7B2C67915,64'HC67178F2E372532B,
    64'HCA273ECEEA26619C,64'HD186B8C721C0C207,64'HEADA7DD6CDE0EB1E,64'HF57D4F7FEE6ED178,
    64'H06F067AA72176FBA,64'H0A637DC5A2C898A6,64'H113F9804BEF90DAE,64'H1B710B35131C471B,
    64'H28DB77F523047D84,64'H32CAAB7B40C72493,64'H3C9EBE0A15C9BEBC,64'H431D67C49C100D4C,
    64'H4CC5D4BECB3E42B6,64'H597F299CFC657E2A,64'H5FCB6FAB3AD6FAEC,64'H6C44198C4A475817
  };

  localparam logic [63 : 0] H_224 [0:7] = '{
    64'h8C3D37C819544DA2,64'h73E1996689DCD4D6,64'h1DFAB7AE32FF9C82,64'h679DD514582F9FCF,
    64'h0F6D2B697BD44DA8,64'h77E36F7304C48942,64'h3F9D85A86A1D36C8,64'h1112E6AD91D692A1
  };

  localparam logic [63 : 0] H_256 [0:7] = '{
    64'h22312194FC2BF72C,64'h9F555FA3C84C64C2,64'h2393B86B6F53B151,64'h963877195940EABD,
    64'h96283EE2A88EFFE3,64'hBE5E1E2553863992,64'h2B0199FC2C85B8AA,64'h0EB72DDC81C52CA2
  };

  localparam logic [63 : 0] H_384 [0:7] = '{
    64'HCBBB9D5DC1059ED8,64'H629A292A367CD507,64'H9159015A3070DD17,64'H152FECD8F70E5939,
    64'H67332667FFC00B31,64'H8EB44A8768581511,64'HDB0C2E0D64F98FA7,64'H47B5481DBEFA4FA4
  };

  localparam logic [63 : 0] H_512 [0:7] = '{
    64'H6A09E667F3BCC908,64'HBB67AE8584CAA73B,64'H3C6EF372FE94F82B,64'HA54FF53A5F1D36F1,
    64'H510E527FADE682D1,64'H9B05688C2B3E6C1F,64'H1F83D9ABFB41BD6B,64'H5BE0CD19137E2179
  };

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam STOP = 2'h2;

  typedef struct packed{
    logic [6 : 0] iter;
    logic [1 : 0] state;
    logic [0 : 0] ready;
    logic [63 : 0] a;
    logic [63 : 0] b;
    logic [63 : 0] c;
    logic [63 : 0] d;
    logic [63 : 0] e;
    logic [63 : 0] f;
    logic [63 : 0] g;
    logic [63 : 0] h;
  } reg_type;

  reg_type init_reg = '{
    iter : 0,
    state : IDLE,
    ready : 0,
    a : 0,
    b : 0,
    c : 0,
    d : 0,
    e : 0,
    f : 0,
    g : 0,
    h : 0
  };

  reg_type r,rin;
  reg_type v;

  function [63:0] ROTR;
    input logic [63:0] x;
    input logic [5:0] n;
    begin
      ROTR = (x >> n) | (x << (64-n));
    end
  endfunction

  function [63:0] SHR;
    input logic [63:0] x;
    input logic [5:0] n;
    begin
      SHR = x >> n;
    end
  endfunction

  function [63:0] CH;
    input logic [63:0] x;
    input logic [63:0] y;
    input logic [63:0] z;
    begin
      CH = (x & y) ^ ((~x) & z);
    end
  endfunction

  function [63:0] MAJ;
    input logic [63:0] x;
    input logic [63:0] y;
    input logic [63:0] z;
    begin
      MAJ = (x & y) ^ (x & z) ^ (y & z);
    end
  endfunction

  function [63:0] BIGSIGMA;
    input logic [63:0] x;
    input logic [0:0] t;
    begin
      if (t==0) begin
        BIGSIGMA = ROTR(x,28) ^ ROTR(x,34) ^ ROTR(x,39);
      end else begin
        BIGSIGMA = ROTR(x,14) ^ ROTR(x,18) ^ ROTR(x,41);
      end
    end
  endfunction

  function [63:0] SMALLSIGMA;
    input logic [63:0] x;
    input logic [0:0] t;
    begin
      if (t==0) begin
        SMALLSIGMA = ROTR(x,1) ^ ROTR(x,8) ^ SHR(x,7);
      end else begin
        SMALLSIGMA = ROTR(x,19) ^ ROTR(x,61) ^ SHR(x,6);
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
          if (Operation == 0) begin
            H_d = H_224;
          end else if (Operation == 1) begin
            H_d = H_256;
          end else if (Operation == 2) begin
            H_d = H_384;
          end else if (Operation == 3) begin
            H_d = H_512;
          end
        end else begin
          H_d[0] = v.a;
          H_d[1] = v.b;
          H_d[2] = v.c;
          H_d[3] = v.d;
          H_d[4] = v.e;
          H_d[5] = v.f;
          H_d[6] = v.g;
          H_d[7] = v.h;
        end

        for (int i=0; i<16; i=i+1) begin
          D_d[i] = Data[i*64 +: 64];
        end

        v.iter = 0;
        v.state = INIT;

      end

      v.ready = 0;

    end else if (r.state == INIT) begin

      if (v.iter < 16) begin
        W_d[v.iter] = D_d[v.iter[3:0]];
      end else begin
        W_d[v.iter] = SMALLSIGMA(W_d[v.iter-2],1) + W_d[v.iter-7] + SMALLSIGMA(W_d[v.iter-15],0) + W_d[v.iter-16];
      end

      // $display("W_d[%d]: %x",v.iter,W_d[v.iter]);

      if (v.iter == 79) begin

        v.a = H_d[0];
        v.b = H_d[1];
        v.c = H_d[2];
        v.d = H_d[3];
        v.e = H_d[4];
        v.f = H_d[5];
        v.g = H_d[6];
        v.h = H_d[7];

        // $display("a: %x",v.a);
        // $display("b: %x",v.b);
        // $display("c: %x",v.c);
        // $display("d: %x",v.d);
        // $display("e: %x",v.e);
        // $display("f: %x",v.f);
        // $display("g: %x",v.g);
        // $display("h: %x",v.h);

        v.iter = 0;
        v.state = STOP;

      end else begin

        v.iter = v.iter + 1;

      end

      v.ready = 0;

    end else if (r.state == STOP) begin

      T_d[0] = v.h + BIGSIGMA(v.e,1) + CH(v.e,v.f,v.g) + K[v.iter] + W_d[v.iter];
      T_d[1] = BIGSIGMA(v.a,0) + MAJ(v.a,v.b,v.c);
      v.h = v.g;
      v.g = v.f;
      v.f = v.e;
      v.e = v.d + T_d[0];
      v.d = v.c;
      v.c = v.b;
      v.b = v.a;
      v.a = T_d[0] + T_d[1];

      // $display("a: %x",v.a);
      // $display("b: %x",v.b);
      // $display("c: %x",v.c);
      // $display("d: %x",v.d);
      // $display("e: %x",v.e);
      // $display("f: %x",v.f);
      // $display("g: %x",v.g);
      // $display("h: %x",v.h);

      if (v.iter == 79) begin

        v.a = v.a + H_d[0];
        v.b = v.b + H_d[1];
        v.c = v.c + H_d[2];
        v.d = v.d + H_d[3];
        v.e = v.e + H_d[4];
        v.f = v.f + H_d[5];
        v.g = v.g + H_d[6];
        v.h = v.h + H_d[7];

        v.iter = 0;
        v.state = IDLE;
        v.ready = 1;

      end else begin

        v.iter = v.iter + 1;
        v.ready = 0;

      end

    end

    Hash = {v.a,v.b,v.c,v.d,v.e,v.f,v.g,v.h};
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
