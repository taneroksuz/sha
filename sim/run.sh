#!/bin/bash

if [ ! -d "$BASEDIR/sim/work" ]; then
  mkdir $BASEDIR/sim/work
fi

rm -rf $BASEDIR/sim/work/*

cp $BASEDIR/py/*.txt $BASEDIR/sim/work/

cd $BASEDIR/sim/work

start=`date +%s`
if [ "$WAVE" = 'on' ]
then
  $VERILATOR --cc -Wno-UNOPTFLAT --trace -trace-max-array 128 --trace-structs -f $BASEDIR/sim/files.f --top-module sha_tb --exe $BASEDIR/sim/run.cpp -I$BASEDIR/rtl 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsha_tb.mk Vsha_tb 2>&1 > /dev/null
  obj_dir/Vsha_tb $MAXTIME
else
  $VERILATOR --cc -Wno-UNOPTFLAT -f $BASEDIR/sim/files.f --top-module sha_tb --exe $BASEDIR/sim/run.cpp -I$BASEDIR/rtl 2>&1 > /dev/null
  make -s -j -C obj_dir/ -f Vsha_tb.mk Vsha_tb 2>&1 > /dev/null
  obj_dir/Vsha_tb $MAXTIME
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
