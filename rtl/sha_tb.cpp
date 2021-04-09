#include <systemc.h>
#include <verilated.h>
#include <verilated_vcd_sc.h>

#include "Vsha_tb.h"

#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

using namespace std;

int sc_main(int argc, char* argv[])
{
  Verilated::commandArgs(argc, argv);

  long long unsigned time;
  string filename;
  char *p;
  const char *dumpfile;

  if (argc>1)
  {
    time = strtol(argv[1], &p, 10);
  }
  if (argc>2)
  {
    filename = string(argv[2]);
    filename = filename + ".vcd";
    dumpfile = filename.c_str();
  }

  sc_clock clk ("clk", 1,SC_NS, 0.5, 0.5,SC_NS, false);
  sc_signal<bool> rst;

  Vsha_tb* sha_tb = new Vsha_tb("sha_tb");

  sha_tb->clk (clk);
  sha_tb->rst (rst);

#if VM_TRACE
  Verilated::traceEverOn(true);
#endif

#if VM_TRACE
  VerilatedVcdSc* dump = new VerilatedVcdSc;
  sha_tb->trace(dump, 99);
  dump->open(dumpfile);
#endif

  while (!Verilated::gotFinish())
  {
#if VM_TRACE
    if (dump) dump->flush();
#endif
    if (VL_TIME_Q() > 0 && VL_TIME_Q() < 10)
    {
      rst = !1;
    }
    else if (VL_TIME_Q() > 0)
    {
      rst = !0;
    }
    if (VL_TIME_Q() > time)
    {
      break;
    }
    sc_start(1,SC_NS);
  }

  cout << "End of simulation is " << sc_time_stamp() << endl;

  sha_tb->final();

#if VM_TRACE
  if (dump)
  {
    dump->close();
    dump = NULL;
  }
#endif

  delete sha_tb;
  sha_tb = NULL;

  return 0;
}
