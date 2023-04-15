#!/bin/bash

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

export SYSTEMC_LIBDIR=$SYSTEMC/lib-linux64/
export SYSTEMC_INCLUDE=$SYSTEMC/include/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC/lib-linux64/

cp $BASEDIR/py/*.txt $BASEDIR/sim/work/

cd $BASEDIR/sim/work

start=`date +%s`
if [ "$WAVE" = 'on' ]
then
  $VERILATOR --sc -Wno-UNOPTFLAT --trace -trace-max-array 128 --trace-structs -f $BASEDIR/sim/files.f --top-module sha_tb --exe $BASEDIR/rtl/sha_tb.cpp -I$BASEDIR/rtl 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsha_tb.mk Vsha_tb 2>&1 > /dev/null
  obj_dir/Vsha_tb $MAXTIME sha
else
  $VERILATOR --sc -Wno-UNOPTFLAT -f $BASEDIR/sim/files.f --top-module sha_tb --exe $BASEDIR/rtl/sha_tb.cpp -I$BASEDIR/rtl 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsha_tb.mk Vsha_tb 2>&1 > /dev/null
  obj_dir/Vsha_tb $MAXTIME
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
