#!/bin/bash

if [[ "$KLENGTH" = "160" ]];
then
  NB=512
  NM=64
  NW=32
elif [[ "$KLENGTH" = "224" ]];
then
  NB=512
  NM=64
  NW=32
elif [[ "$KLENGTH" = "256" ]];
then
  NB=512
  NM=64
  NW=32
elif [[ "$KLENGTH" = "384" ]];
then
  NB=1024
  NM=128
  NW=64
elif [[ "$KLENGTH" = "512" ]];
then
  NB=1024
  NM=128
  NW=64
else
  NB=512
  NM=64
  NW=32
fi

echo "package sha_const;" > $BASEDIR/rtl/sha_const.sv
echo "  timeunit 1ns;" >> $BASEDIR/rtl/sha_const.sv
echo "  timeprecision 1ps;" >> $BASEDIR/rtl/sha_const.sv
echo "" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nk = $KLENGTH; // Massage Digest Size" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nl = $NLENGTH; // Massage Length" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nd = $NDEPTH; // Massage Depth" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nb = $NB; // Block Size" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nm = $NM; // Massage Size" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nw = $NW; // Word Size" >> $BASEDIR/rtl/sha_const.sv
echo "" >> $BASEDIR/rtl/sha_const.sv
echo "endpackage" >> $BASEDIR/rtl/sha_const.sv
