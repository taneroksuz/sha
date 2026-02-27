`timescale 1ns / 1ps

module sha_tb;

  localparam CLK_PERIOD = 10;
  localparam WATCHDOG = 1_000_000;

  logic clk = 0;
  always #(CLK_PERIOD / 2) clk = ~clk;

  logic          rst;

  logic [ 511:0] sha256_data;
  logic [  63:0] sha256_index;
  logic [   1:0] sha256_op;
  logic          sha256_enable;
  logic [ 255:0] sha256_hash;
  logic          sha256_ready;

  logic [1023:0] sha512_data;
  logic [ 127:0] sha512_index;
  logic [   1:0] sha512_op;
  logic          sha512_enable;
  logic [ 511:0] sha512_hash;
  logic          sha512_ready;

  sha256 u_sha256 (
      .rst(rst),
      .clk(clk),
      .Data(sha256_data),
      .Index(sha256_index),
      .Operation(sha256_op),
      .Enable(sha256_enable),
      .Hash(sha256_hash),
      .Ready(sha256_ready)
  );

  sha512 u_sha512 (
      .rst(rst),
      .clk(clk),
      .Data(sha512_data),
      .Index(sha512_index),
      .Operation(sha512_op),
      .Enable(sha512_enable),
      .Hash(sha512_hash),
      .Ready(sha512_ready)
  );

  integer errors;
  integer pt_bytes;
  integer sha256_padded, sha512_padded;
  integer sha256_blocks, sha512_blocks;

  reg [7:0] sha256_exp[];
  reg [7:0] sha512_exp[];
  reg [7:0] sha256_res[];
  reg [7:0] sha512_res[];

  reg [7:0] raw       [];
  reg [7:0] data      [];
  reg [7:0] data512   [];

  function automatic reg [7:0] hex_char(input reg [7:0] c);
    if (c <= 8'h39 && c >= 8'h30) return c - 8'h30;
    if (c <= 8'h66 && c >= 8'h61) return c - 8'h57;
    if (c <= 8'h46 && c >= 8'h41) return c - 8'h37;
    return 8'hFF;
  endfunction

  task automatic get_bytes(input string path, ref reg [7:0] out[], input integer num);
    integer f;
    reg [7:0] c, hv, hi;
    integer nv;
    out = new[num];
    nv  = 0;
    hi  = 0;
    f   = $fopen(path, "r");
    while (!$feof(
        f
    ) && nv < num * 2) begin
      $fread(c, f);
      hv = hex_char(c);
      if (hv != 8'hFF) begin
        if (nv[0] == 0) hi = hv;
        else out[nv/2] = (hi << 4) | hv;
        nv++;
      end
    end
    $fclose(f);
  endtask

  task automatic pad_sha256(input integer msg_len, input integer padded_len);
    longint bit_len;
    data = new[padded_len];
    for (int i = 0; i < msg_len; i++) data[i] = raw[i];
    data[msg_len] = 8'h80;
    for (int i = msg_len + 1; i < padded_len - 8; i++) data[i] = 8'h00;
    bit_len = longint'(msg_len) * 8;
    for (int i = 0; i < 8; i++) data[padded_len-8+i] = 8'((bit_len >> (56 - i * 8)) & 8'hFF);
  endtask

  task automatic pad_sha512(input integer msg_len, input integer padded_len);
    longint bit_len;
    data512 = new[padded_len];
    for (int i = 0; i < msg_len; i++) data512[i] = raw[i];
    data512[msg_len] = 8'h80;
    for (int i = msg_len + 1; i < padded_len - 16; i++) data512[i] = 8'h00;
    for (int i = 0; i < 8; i++) data512[padded_len-16+i] = 8'h00;
    bit_len = longint'(msg_len) * 8;
    for (int i = 0; i < 8; i++) data512[padded_len-8+i] = 8'((bit_len >> (56 - i * 8)) & 8'hFF);
  endtask

  task automatic compare32(input string label);
    reg match;
    match = 1;
    for (int i = 0; i < 32; i++)
      if (sha256_res[i] !== sha256_exp[i]) begin
        match = 0;
        break;
      end
    $write("%s HASH: ", label);
    for (int i = 0; i < 32; i++) $write("%02h", sha256_res[i]);
    $write("\n%s ORIG: ", label);
    for (int i = 0; i < 32; i++) $write("%02h", sha256_exp[i]);
    $write("\n");
    if (match) $display("%s TEST SUCCEEDED", label);
    else $display("%s TEST FAILED", label);
    if (!match) errors++;
  endtask

  task automatic compare64(input string label);
    reg match;
    match = 1;
    for (int i = 0; i < 64; i++)
      if (sha512_res[i] !== sha512_exp[i]) begin
        match = 0;
        break;
      end
    $write("%s HASH: ", label);
    for (int i = 0; i < 64; i++) $write("%02h", sha512_res[i]);
    $write("\n%s ORIG: ", label);
    for (int i = 0; i < 64; i++) $write("%02h", sha512_exp[i]);
    $write("\n");
    if (match) $display("%s TEST SUCCEEDED", label);
    else $display("%s TEST FAILED", label);
    if (!match) errors++;
  endtask

  task automatic feed_sha256(input integer blocks);
    integer blk, timeout;
    sha256_op = 2'd1;
    for (blk = 0; blk < blocks; blk++) begin
      @(posedge clk);
      sha256_data = {
        data[blk*64+60],
        data[blk*64+61],
        data[blk*64+62],
        data[blk*64+63],
        data[blk*64+56],
        data[blk*64+57],
        data[blk*64+58],
        data[blk*64+59],
        data[blk*64+52],
        data[blk*64+53],
        data[blk*64+54],
        data[blk*64+55],
        data[blk*64+48],
        data[blk*64+49],
        data[blk*64+50],
        data[blk*64+51],
        data[blk*64+44],
        data[blk*64+45],
        data[blk*64+46],
        data[blk*64+47],
        data[blk*64+40],
        data[blk*64+41],
        data[blk*64+42],
        data[blk*64+43],
        data[blk*64+36],
        data[blk*64+37],
        data[blk*64+38],
        data[blk*64+39],
        data[blk*64+32],
        data[blk*64+33],
        data[blk*64+34],
        data[blk*64+35],
        data[blk*64+28],
        data[blk*64+29],
        data[blk*64+30],
        data[blk*64+31],
        data[blk*64+24],
        data[blk*64+25],
        data[blk*64+26],
        data[blk*64+27],
        data[blk*64+20],
        data[blk*64+21],
        data[blk*64+22],
        data[blk*64+23],
        data[blk*64+16],
        data[blk*64+17],
        data[blk*64+18],
        data[blk*64+19],
        data[blk*64+12],
        data[blk*64+13],
        data[blk*64+14],
        data[blk*64+15],
        data[blk*64+8],
        data[blk*64+9],
        data[blk*64+10],
        data[blk*64+11],
        data[blk*64+4],
        data[blk*64+5],
        data[blk*64+6],
        data[blk*64+7],
        data[blk*64+0],
        data[blk*64+1],
        data[blk*64+2],
        data[blk*64+3]
      };
      sha256_index = 64'(blk) + 1;
      sha256_enable = 1;
      @(posedge clk);
      sha256_enable = 0;
      timeout = 0;
      while (!sha256_ready) begin
        @(posedge clk);
        if (++timeout >= WATCHDOG) begin
          $display("[SHA256] WATCHDOG timeout at block %0d", blk);
          $finish;
        end
      end
    end
  endtask

  task automatic feed_sha512(input integer blocks);
    integer blk, timeout;
    sha512_op = 2'd3;
    for (blk = 0; blk < blocks; blk++) begin
      @(posedge clk);
      sha512_data = {
        data512[blk*128+120],
        data512[blk*128+121],
        data512[blk*128+122],
        data512[blk*128+123],
        data512[blk*128+124],
        data512[blk*128+125],
        data512[blk*128+126],
        data512[blk*128+127],
        data512[blk*128+112],
        data512[blk*128+113],
        data512[blk*128+114],
        data512[blk*128+115],
        data512[blk*128+116],
        data512[blk*128+117],
        data512[blk*128+118],
        data512[blk*128+119],
        data512[blk*128+104],
        data512[blk*128+105],
        data512[blk*128+106],
        data512[blk*128+107],
        data512[blk*128+108],
        data512[blk*128+109],
        data512[blk*128+110],
        data512[blk*128+111],
        data512[blk*128+96],
        data512[blk*128+97],
        data512[blk*128+98],
        data512[blk*128+99],
        data512[blk*128+100],
        data512[blk*128+101],
        data512[blk*128+102],
        data512[blk*128+103],
        data512[blk*128+88],
        data512[blk*128+89],
        data512[blk*128+90],
        data512[blk*128+91],
        data512[blk*128+92],
        data512[blk*128+93],
        data512[blk*128+94],
        data512[blk*128+95],
        data512[blk*128+80],
        data512[blk*128+81],
        data512[blk*128+82],
        data512[blk*128+83],
        data512[blk*128+84],
        data512[blk*128+85],
        data512[blk*128+86],
        data512[blk*128+87],
        data512[blk*128+72],
        data512[blk*128+73],
        data512[blk*128+74],
        data512[blk*128+75],
        data512[blk*128+76],
        data512[blk*128+77],
        data512[blk*128+78],
        data512[blk*128+79],
        data512[blk*128+64],
        data512[blk*128+65],
        data512[blk*128+66],
        data512[blk*128+67],
        data512[blk*128+68],
        data512[blk*128+69],
        data512[blk*128+70],
        data512[blk*128+71],
        data512[blk*128+56],
        data512[blk*128+57],
        data512[blk*128+58],
        data512[blk*128+59],
        data512[blk*128+60],
        data512[blk*128+61],
        data512[blk*128+62],
        data512[blk*128+63],
        data512[blk*128+48],
        data512[blk*128+49],
        data512[blk*128+50],
        data512[blk*128+51],
        data512[blk*128+52],
        data512[blk*128+53],
        data512[blk*128+54],
        data512[blk*128+55],
        data512[blk*128+40],
        data512[blk*128+41],
        data512[blk*128+42],
        data512[blk*128+43],
        data512[blk*128+44],
        data512[blk*128+45],
        data512[blk*128+46],
        data512[blk*128+47],
        data512[blk*128+32],
        data512[blk*128+33],
        data512[blk*128+34],
        data512[blk*128+35],
        data512[blk*128+36],
        data512[blk*128+37],
        data512[blk*128+38],
        data512[blk*128+39],
        data512[blk*128+24],
        data512[blk*128+25],
        data512[blk*128+26],
        data512[blk*128+27],
        data512[blk*128+28],
        data512[blk*128+29],
        data512[blk*128+30],
        data512[blk*128+31],
        data512[blk*128+16],
        data512[blk*128+17],
        data512[blk*128+18],
        data512[blk*128+19],
        data512[blk*128+20],
        data512[blk*128+21],
        data512[blk*128+22],
        data512[blk*128+23],
        data512[blk*128+8],
        data512[blk*128+9],
        data512[blk*128+10],
        data512[blk*128+11],
        data512[blk*128+12],
        data512[blk*128+13],
        data512[blk*128+14],
        data512[blk*128+15],
        data512[blk*128+0],
        data512[blk*128+1],
        data512[blk*128+2],
        data512[blk*128+3],
        data512[blk*128+4],
        data512[blk*128+5],
        data512[blk*128+6],
        data512[blk*128+7]
      };
      sha512_index = 128'(blk) + 1;
      sha512_enable = 1;
      @(posedge clk);
      sha512_enable = 0;
      timeout = 0;
      while (!sha512_ready) begin
        @(posedge clk);
        if (++timeout >= WATCHDOG) begin
          $display("[SHA512] WATCHDOG timeout at block %0d", blk);
          $finish;
        end
      end
    end
  endtask

  initial begin
    if (!$value$plusargs("PLAINTEXT_BYTES=%d", pt_bytes)) begin
      $display("ERROR: +PLAINTEXT_BYTES=<n> required");
      $finish;
    end

    sha256_padded = ((pt_bytes + 9 + 63) / 64) * 64;
    sha512_padded = ((pt_bytes + 17 + 127) / 128) * 128;
    sha256_blocks = sha256_padded / 64;
    sha512_blocks = sha512_padded / 128;

    get_bytes("plaintext.hex", raw, pt_bytes);
    sha256_exp = new[32];
    sha512_exp = new[64];
    get_bytes("sha256.hex", sha256_exp, 32);
    get_bytes("sha512.hex", sha512_exp, 64);

    pad_sha256(pt_bytes, sha256_padded);
    pad_sha512(pt_bytes, sha512_padded);

    $display("[TB] plaintext: %0d bytes -> SHA256 blocks: %0d, SHA512 blocks: %0d", pt_bytes,
             sha256_blocks, sha512_blocks);

    errors        = 0;
    sha256_enable = 0;
    sha512_enable = 0;
    rst           = 0;
    repeat (4) @(posedge clk);
    rst = 1;
    repeat (2) @(posedge clk);

    sha256_res = new[32];
    feed_sha256(sha256_blocks);
    for (int i = 0; i < 32; i++) sha256_res[i] = sha256_hash[255-i*8-:8];
    compare32("[SHA256]");

    sha512_res = new[64];
    feed_sha512(sha512_blocks);
    for (int i = 0; i < 64; i++) sha512_res[i] = sha512_hash[511-i*8-:8];
    compare64("[SHA512]");

    if (errors == 0) $display("All tests PASSED.");
    else $display("%0d test(s) FAILED.", errors);

    $finish;
  end

  initial begin
    $dumpfile("sha_tb.vcd");
    $dumpvars(0, sha_tb);
  end

endmodule
