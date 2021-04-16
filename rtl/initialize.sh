#!/bin/bash

DIR=${1}
NK=${2}
NL=${3}
ND=${4}

if [[ "$NK" = "160" ]];
then
  NB=512
  NM=64
  NW=32
elif [[ "$NK" = "224" ]];
then
  NB=512
  NM=64
  NW=32
elif [[ "$NK" = "256" ]];
then
  NB=512
  NM=64
  NW=32
elif [[ "$NK" = "384" ]];
then
  NB=1024
  NM=128
  NW=64
elif [[ "$NK" = "512" ]];
then
  NB=1024
  NM=128
  NW=64
else
  NB=512
  NM=64
  NW=32
fi

echo "package sha_const;" > $DIR/rtl/sha_const.sv
echo "  timeunit 1ns;" >> $DIR/rtl/sha_const.sv
echo "  timeprecision 1ps;" >> $DIR/rtl/sha_const.sv
echo "" >> $DIR/rtl/sha_const.sv
echo "  parameter Nk = $NK; // Massage Digest Size" >> $DIR/rtl/sha_const.sv
echo "  parameter Nl = $NL; // Massage Length" >> $DIR/rtl/sha_const.sv
echo "  parameter Nd = $ND; // Massage Depth" >> $DIR/rtl/sha_const.sv
echo "  parameter Nb = $NB; // Block Size" >> $DIR/rtl/sha_const.sv
echo "  parameter Nm = $NM; // Massage Size" >> $DIR/rtl/sha_const.sv
echo "  parameter Nw = $NW; // Word Size" >> $DIR/rtl/sha_const.sv
echo "" >> $DIR/rtl/sha_const.sv
echo "endpackage" >> $DIR/rtl/sha_const.sv
