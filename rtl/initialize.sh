#!/bin/bash

if [[ "$KEY_LENGTH" = "0" ]];
then
  NK=160
  NB=512
  NM=64
  NW=32
elif [[ "$KEY_LENGTH" = "1" ]];
then
  NK=256
  NB=512
  NM=64
  NW=32
elif [[ "$KEY_LENGTH" = "2" ]];
then
  NK=512
  NB=1024
  NM=128
  NW=64
fi

echo "package sha_const;" > $BASEDIR/rtl/sha_const.sv
echo "  timeunit 1ns;" >> $BASEDIR/rtl/sha_const.sv
echo "  timeprecision 1ps;" >> $BASEDIR/rtl/sha_const.sv
echo "" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nk = $NK; // Massage Digest Size" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nl = $MSG_LENGTH; // Massage Length" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nd = $CASE_NUMBER; // Massage Depth" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nb = $NB; // Block Size" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nm = $NM; // Massage Size" >> $BASEDIR/rtl/sha_const.sv
echo "  parameter Nw = $NW; // Word Size" >> $BASEDIR/rtl/sha_const.sv
echo "" >> $BASEDIR/rtl/sha_const.sv
echo "endpackage" >> $BASEDIR/rtl/sha_const.sv
