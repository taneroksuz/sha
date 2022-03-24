import sha_const::*;

module sha_512
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

  logic [63 : 0] K [0:79];

  logic [63 : 0] H_224 [0:7];
  logic [63 : 0] H_256 [0:7];
  logic [63 : 0] H_384 [0:7];
  logic [63 : 0] H_512 [0:7];

  integer i;

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam END  = 2'h2;

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

  initial begin

    K[0]=64'h428a2f98d728ae22; K[1]=64'h7137449123ef65cd; K[2]=64'hb5c0fbcfec4d3b2f; K[3]=64'he9b5dba58189dbbc; K[4]=64'h3956c25bf348b538;
    K[5]=64'h59f111f1b605d019; K[6]=64'h923f82a4af194f9b; K[7]=64'hab1c5ed5da6d8118; K[8]=64'hd807aa98a3030242; K[9]=64'h12835b0145706fbe;
    K[10]=64'h243185be4ee4b28c; K[11]=64'h550c7dc3d5ffb4e2; K[12]=64'h72be5d74f27b896f; K[13]=64'h80deb1fe3b1696b1; K[14]=64'h9bdc06a725c71235;
    K[15]=64'hc19bf174cf692694; K[16]=64'he49b69c19ef14ad2; K[17]=64'hefbe4786384f25e3; K[18]=64'h0fc19dc68b8cd5b5; K[19]=64'h240ca1cc77ac9c65;
    K[20]=64'h2de92c6f592b0275; K[21]=64'h4a7484aa6ea6e483; K[22]=64'h5cb0a9dcbd41fbd4; K[23]=64'h76f988da831153b5; K[24]=64'h983e5152ee66dfab;
    K[25]=64'ha831c66d2db43210; K[26]=64'hb00327c898fb213f; K[27]=64'hbf597fc7beef0ee4; K[28]=64'hc6e00bf33da88fc2; K[29]=64'hd5a79147930aa725;
    K[30]=64'h06ca6351e003826f; K[31]=64'h142929670a0e6e70; K[32]=64'h27b70a8546d22ffc; K[33]=64'h2e1b21385c26c926; K[34]=64'h4d2c6dfc5ac42aed;
    K[35]=64'h53380d139d95b3df; K[36]=64'h650a73548baf63de; K[37]=64'h766a0abb3c77b2a8; K[38]=64'h81c2c92e47edaee6; K[39]=64'h92722c851482353b;
    K[40]=64'ha2bfe8a14cf10364; K[41]=64'ha81a664bbc423001; K[42]=64'hc24b8b70d0f89791; K[43]=64'hc76c51a30654be30; K[44]=64'hd192e819d6ef5218;
    K[45]=64'hd69906245565a910; K[46]=64'hf40e35855771202a; K[47]=64'h106aa07032bbd1b8; K[48]=64'h19a4c116b8d2d0c8; K[49]=64'h1e376c085141ab53;
    K[50]=64'h2748774cdf8eeb99; K[51]=64'h34b0bcb5e19b48a8; K[52]=64'h391c0cb3c5c95a63; K[53]=64'h4ed8aa4ae3418acb; K[54]=64'h5b9cca4f7763e373;
    K[55]=64'h682e6ff3d6b2b8a3; K[56]=64'h748f82ee5defb2fc; K[57]=64'h78a5636f43172f60; K[58]=64'h84c87814a1f0ab72; K[59]=64'h8cc702081a6439ec;
    K[60]=64'h90befffa23631e28; K[61]=64'ha4506cebde82bde9; K[62]=64'hbef9a3f7b2c67915; K[63]=64'hc67178f2e372532b; K[64]=64'hca273eceea26619c;
    K[65]=64'hd186b8c721c0c207; K[66]=64'heada7dd6cde0eb1e; K[67]=64'hf57d4f7fee6ed178; K[68]=64'h06f067aa72176fba; K[69]=64'h0a637dc5a2c898a6;
    K[70]=64'h113f9804bef90dae; K[71]=64'h1b710b35131c471b; K[72]=64'h28db77f523047d84; K[73]=64'h32caab7b40c72493; K[74]=64'h3c9ebe0a15c9bebc;
    K[75]=64'h431d67c49c100d4c; K[76]=64'h4cc5d4becb3e42b6; K[77]=64'h597f299cfc657e2a; K[78]=64'h5fcb6fab3ad6faec; K[79]=64'h6c44198c4a475817;

    H_224[0]=64'h8C3D37C819544DA2; H_224[1]=64'h73E1996689DCD4D6; H_224[2]=64'h1DFAB7AE32FF9C82; H_224[3]=64'h679DD514582F9FCF; H_224[4]=64'h0F6D2B697BD44DA8; H_224[5]=64'h77E36F7304C48942; H_224[6]=64'h3F9D85A86A1D36C8; H_224[7]=64'h1112E6AD91D692A1;
    H_256[0]=64'h22312194FC2BF72C; H_256[1]=64'h9F555FA3C84C64C2; H_256[2]=64'h2393B86B6F53B151; H_256[3]=64'h963877195940EABD; H_256[4]=64'h96283EE2A88EFFE3; H_256[5]=64'hBE5E1E2553863992; H_256[6]=64'h2B0199FC2C85B8AA; H_256[7]=64'h0EB72DDC81C52CA2;
    H_384[0]=64'hcbbb9d5dc1059ed8; H_384[1]=64'h629a292a367cd507; H_384[2]=64'h9159015a3070dd17; H_384[3]=64'h152fecd8f70e5939; H_384[4]=64'h67332667ffc00b31; H_384[5]=64'h8eb44a8768581511; H_384[6]=64'hdb0c2e0d64f98fa7; H_384[7]=64'h47b5481dbefa4fa4;
    H_512[0]=64'h6a09e667f3bcc908; H_512[1]=64'hbb67ae8584caa73b; H_512[2]=64'h3c6ef372fe94f82b; H_512[3]=64'ha54ff53a5f1d36f1; H_512[4]=64'h510e527fade682d1; H_512[5]=64'h9b05688c2b3e6c1f; H_512[6]=64'h1f83d9abfb41bd6b; H_512[7]=64'h5be0cd19137e2179;

  end

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

        for (i=0; i<16; i=i+1) begin
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
        v.state = END;

      end else begin

        v.iter = v.iter + 1;

      end

      v.ready = 0;

    end else if (r.state == END) begin

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
