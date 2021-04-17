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

  logic [7:0] data [0:(Nl-1)];
  logic [0:0] enable;
  logic [(Nk-1):0] hash;
  logic [0:0] ready;

  initial begin
    data_file = $fopen("data.txt", "rb");
    $readmemh("hash.txt", hash_block);
  end

  sha sha_comp
  (
    .rst (rst),
    .clk (clk),
    .Data (data),
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
        $fgets(line,data_file);
        $write("Data: ");
        for (j=0; j<Nl; j=j+1) begin
          data_block[i][j] = line[j];
          $write("%c",data_block[i][j]);
        end
        $display();
        state <= 1;
      end else if (state==1) begin
        data = data_block[i];
        $write("HEX: ");
        for (j=0; j<Nl; j=j+1) begin
          $write("%x",data[j]);
        end
        $display();
        enable <= 1;
        state <= 2;
      end else if (state==2) begin
        enable <= 0;
        if (ready==1) begin
          $display("Result: %x",hash);
          $display("Correct: %x",hash_block[i]);
          if (|(hash ^ hash_block[i]) == 0) begin
            $display("Test success!");
          end else begin
            $display("Test failed!");
          end
          if (i==(Nd-1)) begin
            $fclose(data_file);
            $finish;
          end else begin
            i <= i+1;
            state <= 1;
          end
        end
      end
    end
  end

endmodule
