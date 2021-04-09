package sha_wire;
  timeunit 1ns;
  timeprecision 1ps;

  import sha_const::*;

  typedef struct packed{
    logic [(Nb-1):0] data;
    logic [0 : 0] enable;
  } sha_in_type;

  typedef struct packed{
    logic [(Nk-1):0] hash;
    logic [0 : 0] ready;
  } sha_out_type;

endpackage
