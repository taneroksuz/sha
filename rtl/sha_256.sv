import sha_const::*;

module sha_256
(
  input logic rst,
  input logic clk,
  input logic [511:0] Data,
  input logic [63:0] Index,
  input logic [0:0] Operation,
  input logic [0:0] Enable,
  output logic [255:0] Hash,
  output logic [0:0] Ready
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] K [0:63];
  logic [31 : 0] W [0:63];
  logic [31 : 0] R [0:7];
  logic [31 : 0] H [0:7];
  logic [31 : 0] T [0:1];

  logic [31 : 0] H_224 [0:7];
  logic [31 : 0] H_256 [0:7];

  logic [31 : 0] D [0:15];

  integer i;

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam END  = 2'h2;

  typedef struct packed{
    logic [5 : 0] iter;
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

  function [31:0] ROTR;
    input logic [31:0] x;
    input logic [4:0] n;
    begin
      ROTR = (x >> n) | (x << (32-n));
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
      if (t==0) begin
        BIGSIGMA = ROTR(x,2) ^ ROTR(x,13) ^ ROTR(x,22);
      end else begin
        BIGSIGMA = ROTR(x,6) ^ ROTR(x,11) ^ ROTR(x,25);
      end
    end
  endfunction

  function [31:0] SMALLSIGMA;
    input logic [31:0] x;
    input logic [0:0] t;
    begin
      if (t==0) begin
        SMALLSIGMA = ROTR(x,7) ^ ROTR(x,18) ^ SHR(x,3);
      end else begin
        SMALLSIGMA = ROTR(x,17) ^ ROTR(x,19) ^ SHR(x,10);
      end
    end
  endfunction

  initial begin

    K[0]=32'h428a2f98; K[1]=32'h71374491; K[2]=32'hb5c0fbcf; K[3]=32'he9b5dba5; K[4]=32'h3956c25b; K[5]=32'h59f111f1; K[6]=32'h923f82a4; K[7]=32'hab1c5ed5;
    K[8]=32'hd807aa98; K[9]=32'h12835b01; K[10]=32'h243185be; K[11]=32'h550c7dc3; K[12]=32'h72be5d74; K[13]=32'h80deb1fe; K[14]=32'h9bdc06a7; K[15]=32'hc19bf174;
    K[16]=32'he49b69c1; K[17]=32'hefbe4786; K[18]=32'h0fc19dc6; K[19]=32'h240ca1cc; K[20]=32'h2de92c6f; K[21]=32'h4a7484aa; K[22]=32'h5cb0a9dc; K[23]=32'h76f988da;
    K[24]=32'h983e5152; K[25]=32'ha831c66d; K[26]=32'hb00327c8; K[27]=32'hbf597fc7; K[28]=32'hc6e00bf3; K[29]=32'hd5a79147; K[30]=32'h06ca6351; K[31]=32'h14292967;
    K[32]=32'h27b70a85; K[33]=32'h2e1b2138; K[34]=32'h4d2c6dfc; K[35]=32'h53380d13; K[36]=32'h650a7354; K[37]=32'h766a0abb; K[38]=32'h81c2c92e; K[39]=32'h92722c85;
    K[40]=32'ha2bfe8a1; K[41]=32'ha81a664b; K[42]=32'hc24b8b70; K[43]=32'hc76c51a3; K[44]=32'hd192e819; K[45]=32'hd6990624; K[46]=32'hf40e3585; K[47]=32'h106aa070;
    K[48]=32'h19a4c116; K[49]=32'h1e376c08; K[50]=32'h2748774c; K[51]=32'h34b0bcb5; K[52]=32'h391c0cb3; K[53]=32'h4ed8aa4a; K[54]=32'h5b9cca4f; K[55]=32'h682e6ff3;
    K[56]=32'h748f82ee; K[57]=32'h78a5636f; K[58]=32'h84c87814; K[59]=32'h8cc70208; K[60]=32'h90befffa; K[61]=32'ha4506ceb; K[62]=32'hbef9a3f7; K[63]=32'hc67178f2;

    H_224[0]=32'hc1059ed8; H_224[1]=32'h367cd507; H_224[2]=32'h3070dd17; H_224[3]=32'hf70e5939; H_224[4]=32'hffc00b31; H_224[5]=32'h68581511; H_224[6]=32'h64f98fa7; H_224[7]=32'hbefa4fa4;
    H_256[0]=32'h6a09e667; H_256[1]=32'hbb67ae85; H_256[2]=32'h3c6ef372; H_256[3]=32'ha54ff53a; H_256[4]=32'h510e527f; H_256[5]=32'h9b05688c; H_256[6]=32'h1f83d9ab; H_256[7]=32'h5be0cd19;

  end

  always_comb begin

    v = r;

    if (r.state == IDLE) begin

      if (Enable == 1) begin

        if (Index == 0) begin
          if (Operation == 0) begin
            H = H_224;
          end else if (Operation == 1) begin
            H = H_256;
          end
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
        W[v.iter] = D[v.iter];
      end else begin
        W[v.iter] = SMALLSIGMA(W[v.iter-2],1) + W[v.iter-7] + SMALLSIGMA(W[v.iter-15],0) + W[v.iter-16];
      end

      if (v.iter == 63) begin

        for (i=0; i<8; i=i+1) begin
          R[i] = H[i];
        end

        v.iter = 0;
        v.state = END;

      end else begin

        v.iter = v.iter + 1;

      end

      v.ready = 0;

    end else if (r.state == END) begin

      T[0] = R[7] + BIGSIGMA(R[4],1) + CH(R[4],R[5],R[6]) + K[v.iter] + W[v.iter];
      T[1] = BIGSIGMA(R[0],0) + MAJ(R[0],R[1],R[2]);
      R[7] = R[6];
      R[6] = R[5];
      R[5] = R[4];
      R[4] = R[3] + T[0];
      R[3] = R[2];
      R[2] = R[1];
      R[1] = R[0];
      R[0] = T[0] + T[1];

      if (v.iter == 63) begin

        for (i=0; i<8; i=i+1) begin
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

    Hash = {H[0],H[1],H[2],H[3],H[4],H[5],H[6],H[7]};
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
