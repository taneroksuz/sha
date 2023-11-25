import sha_const::*;

module sha_tb(
  input logic rst,
  input logic clk
);

  timeunit 1ns;
  timeprecision 1ps;

  parameter enable_pipeline = 0;

  integer i,j;

  integer data_file;

  string line;

  logic [7:0] data_block [0:(Nd-1)][0:(Nl-1)];
  logic [(Nk-1):0] hash_block [0:(Nd-1)];

  logic [1:0] state;

  logic [0:0] enable;
  logic [(Nk-1):0] hash;
  logic [0:0] ready;

  initial begin
    data_file = $fopen("data.txt", "rb");
    for (i=0; i<Nd; i=i+1) begin
      $fgets(line,data_file);
      for (j=0; j<Nl; j=j+1) begin
        data_block[i][j] = line[j];
      end
    end
    $fclose(data_file);
    $readmemh("hash.txt", hash_block);
  end

  sha sha_comp
  (
    .rst (rst),
    .clk (clk),
    .Data (data_block[i]),
    .Enable (enable),
    .Hash (hash),
    .Ready (ready)
  );

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      enable <= 0;
      state <= 0;
      i <= 0;
    end else begin
      if (state==0) begin
        enable <= 1;
        state <= 1;
      end else if (state==1) begin
        enable <= 0;
        if (ready==1) begin
          $write("%c[1;34m",8'h1B);
          $write("DATA: ");
          $write("%c[0m",8'h1B);
          for (j=0; j<Nl; j=j+1) begin
            $write("%c",data_block[i][j]);
          end
          $display();
          $write("%c[1;34m",8'h1B);
          $write("HEX: ");
          $write("%c[0m",8'h1B);
          for (j=0; j<Nl; j=j+1) begin
            $write("%x",data_block[i][j]);
          end
          $display();
          $write("%c[1;34m",8'h1B);
          $write("HASH: ");
          $write("%c[0m",8'h1B);
          $display("%x",hash);
          $write("%c[1;34m",8'h1B);
          $write("ORIG: ");
          $write("%c[0m",8'h1B);
          $display("%x",hash_block[i]);
          if (|(hash ^ hash_block[i]) == 0) begin
            $write("%c[1;32m",8'h1B);
            $display("TEST SUCCEEDED");
            $write("%c[0m",8'h1B);
          end else begin
            $write("%c[1;31m",8'h1B);
            $display("TEST FAILED");
            $write("%c[0m",8'h1B);
          end
          if (i==(Nd-1)) begin
            $finish;
          end else begin
            i <= i+1;
            state <= 0;
          end
        end
      end
    end
  end

endmodule
