import sha_const::*;

module sha
(
  input logic rst,
  input logic clk,
  input logic [7 : 0] Data [0:(Nl-1)],
  input logic [0 : 0] Enable,
  output logic [(Nk-1):0] Hash,
  output logic [0 : 0] Ready
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam Nt = Nw/8;
  localparam Ndiv = Nb/8;
  localparam Ns = (Nl/Ndiv)+((Ndiv-(Nl%Ndiv) <= 2*Nt) ? 2 : 1);

  localparam IDLE = 2'h0;
  localparam BLOCK = 2'h1;
  localparam SHA = 2'h2;

  logic [(Nm-1) : 0] index_block;
  logic [(Nb-1) : 0] data_block;
  logic [(Nk-1) : 0] hash_sha;
  logic [0 : 0] enable_block;
  logic [0 : 0] enable_sha;
  logic [0 : 0] ready_block;
  logic [0 : 0] ready_sha;
  logic [0 : 0] function_block;
  logic [1 : 0] operation_sha;

  logic [(Nk-1) : 0] hash;
  logic [0 : 0] ready;

  typedef struct packed{
    logic [1 : 0] state;
  } reg_type;

  reg_type init_reg = '{
    state : IDLE
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    enable_block = 0;
    enable_sha = 0;
    function_block = 0;
    operation_sha = 0;

    hash = 0;
    ready = 0;

    if (r.state==IDLE) begin
      if (Enable==1) begin

        enable_block = 1;
        function_block = 0;

        v.state = BLOCK;

      end
    end else if (r.state==BLOCK) begin
      if (ready_block==1) begin
        v.state = SHA;
        enable_sha = 1;
        if (Nk==224) begin
          operation_sha = 0;
        end else if (Nk==256) begin
          operation_sha = 1;
        end else if (Nk==384) begin
          operation_sha = 2;
        end else if (Nk==512) begin
          operation_sha = 3;
        end
      end

    end else if (r.state==SHA) begin

      if (ready_sha==1) begin
        if (index_block == Ns) begin
          hash = hash_sha;
          ready = ready_sha;
          v.state = IDLE;
        end else begin
          enable_block = 1;
          function_block = 1;
          v.state = BLOCK;
        end
      end

    end

    Ready = ready;
    Hash = hash;

    rin = v;

  end

  sha_block sha_block_comp
  (
    .rst (rst),
    .clk (clk),
    .Data (Data),
    .Enable (enable_block),
    .Function (function_block),
    .Block (data_block),
    .Index (index_block),
    .Ready (ready_block)
  );

  generate

    if (Nk==160) begin
      sha_1 sha_1_comp
      (
        .rst (rst),
        .clk (clk),
        .Data (data_block),
        .Index (index_block),
        .Enable (enable_sha),
        .Hash (hash_sha),
        .Ready (ready_sha)
      );
    end else if (Nk==256) begin
      sha_256 sha_256_comp
      (
        .rst (rst),
        .clk (clk),
        .Data (data_block),
        .Index (index_block),
        .Operation (operation_sha),
        .Enable (enable_sha),
        .Hash (hash_sha),
        .Ready (ready_sha)
      );
    end else if (Nk==512) begin
      sha_512 sha_512_comp
      (
        .rst (rst),
        .clk (clk),
        .Data (data_block),
        .Index (index_block),
        .Operation (operation_sha),
        .Enable (enable_sha),
        .Hash (hash_sha),
        .Ready (ready_sha)
      );
    end

  endgenerate

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
