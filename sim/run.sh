#!/bin/bash

DIR=${1}

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

rm -rf $DIR/sim/work/*

VERILATOR=${2}
SYSTEMC=${3}

export SYSTEMC_LIBDIR=$SYSTEMC/lib-linux64/
export SYSTEMC_INCLUDE=$SYSTEMC/include/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC/lib-linux64/

if [[ "$4" = [0-9]* ]];
then
  CYCLES="$4"
else
  CYCLES=10000000000
fi

cp ${DIR}/py/*.txt ${DIR}/sim/work/

cd ${DIR}/sim/work

start=`date +%s`
if [ "$5" = 'wave' ]
then
  ${VERILATOR} --sc -Wno-UNOPTFLAT --trace -trace-max-array 128 --trace-structs -f ${DIR}/sim/files.f --top-module sha_tb --exe ${DIR}/rtl/sha_tb.cpp -I${DIR}/rtl
  make -s -j -C obj_dir/ -f Vsha_tb.mk Vsha_tb
  obj_dir/Vsha_tb $CYCLES sha 2> /dev/null
else
  ${VERILATOR} --sc -Wno-UNOPTFLAT -f ${DIR}/sim/files.f --top-module sha_tb --exe ${DIR}/rtl/sha_tb.cpp -I${DIR}/rtl
  make -s -j -C obj_dir/ -f Vsha_tb.mk Vsha_tb
  obj_dir/Vsha_tb $CYCLES 2> /dev/null
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
