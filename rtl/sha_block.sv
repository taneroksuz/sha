import sha_const::*;

module sha_block
(
  input logic rst,
  input logic clk,
  input logic [7:0] Data [0:(Nl-1)],
  input logic [0:0] Enable,
  input logic [0:0] Funct,
  output logic [(Nb-1):0] Block,
  output logic [(Nm-1):0] Index,
  output logic [0:0] Ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam Nt = Nw/8;
  localparam Ndiv = Nb/8;
  localparam Ns = (Nl/Ndiv)+((Ndiv-(Nl%Ndiv) <= 2*Nt) ? 2 : 1);
  localparam Nleft = 112*Nt;
  localparam Nright = $clog2(8*Nt);

  localparam IDLE  = 2'h0;
  localparam INIT  = 2'h1;
  localparam INTER = 2'h2;
  localparam STOP  = 2'h3;

  logic [7:0] data_d [0:(Nl-1)];
  logic [7:0] word_d [0:(Nt-1)];

  logic [7:0] data_q [0:(Nl-1)];
  logic [7:0] word_q [0:(Nt-1)];

  logic [(Nw-1) : 0] block_d [0:15];
  logic [(Nw-1) : 0] block_q [0:15];

  typedef struct packed{
    logic [31 : 0] index;
    logic [10 : 0] rest;
    logic [10 : 0] i;
    logic [(Nm-1) : 0] size;
    logic [(Nw-1) : 0] w;
    logic [(Nm-1) : 0] n;
    logic [1 : 0] state;
    logic [0 : 0] ready;
  } reg_type;

  reg_type init_reg = '{
    index : 0,
    rest : 0,
    i : 0,
    size : 0,
    w : 0,
    n : 0,
    state : IDLE,
    ready : 0
  };

  integer i,j;

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    data_d = data_q;
    word_d = word_q;
    block_d = block_q;

    if (r.state == IDLE) begin

      if (Enable == 1) begin
        if (Funct == 0) begin
          data_d = Data;
          v.index = 0;
          v.size = 0;
          v.n = 0;
        end
        v.state = INIT;
      end

      v.i = 0;

      v.ready = 0;

    end else if  (r.state == INIT) begin

      for (j=0; j<Nt ;j=j+1) begin
        word_d[j] = 0;
      end

      for (j=0; j<Nt ;j=j+1) begin
        if (v.index == Nl) begin
          word_d[j] = 8'h80;
        end else if (v.index < Nl) begin
          word_d[j] = data_d[v.index];
          v.size = v.size + 8;
        end else if (v.n == (Ns-1)) begin
          v.state = INTER;
        end
        v.index = v.index + 1;
      end

      for (j=0; j<Nt; j=j+1) begin
        v.w[j*8 +: 8] = word_d[(Nt-1)-j];
      end

      block_d[v.i[3:0]] = v.w;

      if (v.i == 15) begin
        v.state = STOP;
      end

      v.i = v.i + 1;

      v.ready = 0;

    end else if (r.state == INTER) begin

      v.rest = Nleft - (v.i << Nright);

      if (v.rest[10] == 1) begin
        v.w = v.size[(Nm/2-1):0];
        v.state = STOP;
      end else if (v.rest > 0) begin
        v.w = 0;
      end else if (v.rest == 0) begin
        v.w = v.size[(Nm-1):(Nm/2)];
      end

      block_d[v.i[3:0]] = v.w;

      v.i = v.i + 1;

      v.ready = 0;

    end else if (r.state == STOP) begin

      v.n = v.n + 1;

      v.state = IDLE;

      v.ready = 1;

    end

    for (i=0; i<16; i=i+1) begin
      Block[i*Nw +: Nw] = block_d[i];
    end

    Index = v.n;
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
    data_q <= data_d;
    word_q <= word_d;
    block_q <= block_d;
  end

endmodule
