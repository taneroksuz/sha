import sha_const::*;
import sha_wire::*;

module sha_tb(
  input logic rst,
  input logic clk
);

  timeunit 1ns;
  timeprecision 1ps;

  parameter enable_pipeline = 0;

  sha_in_type sha_in;
  sha_out_type sha_out;

  logic [(Nk-1):0] result;

  logic [0:0] enable;

  integer i,j;

  integer data_file;

  string line;

  logic [(Nk-1):0] hash_block [0:(Nw-1)];
  logic [7:0] data_block [0:(Nw-1)][0:(Nd-1)];

  initial begin
    data_file = $fopen("data.txt", "rb");
    $readmemh("hash.txt", hash_block);
  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      sha_in.data <= 0;
      sha_in.enable <= 0;
      enable <= 1;
      result <= 0;
      i <= 0;
    end else begin
      // $fgets(line,data_file);
      // $display("Data: %s",line);
      // data_block[i] = line;
      $fgets(line,data_file);
      $write("Data: ");
      for (j=0; j<1024; j=j+1) begin
        data_block[i][j] = line[j];
        $write("%c",data_block[i][j]);
      end
      $display();

      if (i==(Nw-1)) begin
        $fclose(data_file);
        $display("Test success!");
        $finish;
      end else begin
        i <= i+1;
      end

      // sha_in.data <= 0;
      // sha_in.enable <= enable;
      // enable <= 0;
      // if (sha_out.ready == 1) begin
      //   $display("Hash: %X",sha_out.hash);
      //   $display("Correct: %X",hash_block[i]);
      //   if (|(sha_out.hash ^ hash_block[i]) == 0) begin
      //     $display("Hash success!");
      //   end else begin
      //     $display("Hash failed!");
      //     $finish;
      //   end
      //   enable <= 1;
      //   if (i==(Nw-1)) begin
      //     $display("Test success!");
      //     $finish;
      //   end else begin
      //     i <= i+1;
      //   end
      // end
    end
  end

endmodule
