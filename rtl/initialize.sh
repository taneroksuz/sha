#!/bin/bash

DIR=${1}
NK=${2}
ND=${3}
NW=${4}

if [[ "$NK" = "160" ]];
then
  NB=512
  NI=64
elif [[ "$NK" = "224" ]];
then
  NB=512
  NI=64
elif [[ "$NK" = "256" ]];
then
  NB=512
  NI=64
elif [[ "$NK" = "384" ]];
then
  NB=1024
  NI=128
elif [[ "$NK" = "512" ]];
then
  NB=1024
  NI=128
else
  NB=512
  NI=64
fi

echo "package sha_const;" > $DIR/rtl/sha_const.sv
echo "  timeunit 1ns;" >> $DIR/rtl/sha_const.sv
echo "  timeprecision 1ps;" >> $DIR/rtl/sha_const.sv
echo "" >> $DIR/rtl/sha_const.sv
echo "  parameter Nk = $NK;" >> $DIR/rtl/sha_const.sv
echo "  parameter Nb = $NB;" >> $DIR/rtl/sha_const.sv
echo "  parameter Nd = $ND;" >> $DIR/rtl/sha_const.sv
echo "  parameter Ni = $NI;" >> $DIR/rtl/sha_const.sv
echo "  parameter Nw = $NW;" >> $DIR/rtl/sha_const.sv
echo "" >> $DIR/rtl/sha_const.sv
echo "endpackage" >> $DIR/rtl/sha_const.sv
