import sha_const::*;

module sha_block
(
  input logic rst,
  input logic clk,
  input logic [7:0] Data_Block [0:(Nl-1)],
  input logic [0:0] Enable,
  input logic [0:0] Function,
  output logic [(Nb-1):0] Data,
  output logic [(Nw-1):0] Index,
  output logic [0:0] Ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam IDLE = 2'h0;
  localparam INIT = 2'h1;
  localparam END  = 2'h2;

  typedef struct packed{
    logic [(Nw-1) : 0] index;
    logic [(Nm-1) : 0] size;
    logic [(Nb-1) : 0] data;
    logic [1 : 0] state;
    logic [0 : 0] ready;
  } reg_type;

  reg_type init_reg = '{
    index : 0,
    size : 0,
    data : 0,
    state : IDLE,
    ready : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    if (r.state == IDLE) begin

      if (Enable == 1) begin
        if (Function == 0) begin
          v.index = 0;
        end
        v.state = INIT;
      end

      v.ready = 0;

    end else if  (r.state == INIT) begin

      v.state = END;

      v.ready = 0;

    end else if  (r.state == END) begin

      v.state = INIT;

      v.ready = 0;

    end

    Data = v.data;
    Index = v.index;
    Ready = v.ready;

    rin <= v;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
