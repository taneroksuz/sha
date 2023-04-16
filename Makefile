default: none

export VERILATOR ?= /opt/verilator/bin/verilator
export SYSTEMC ?= /opt/systemc
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export MAXTIME ?= 1000000000
export KLENGTH ?= 512
export NLENGTH ?= 1024
export NDEPTH ?= 1
export WAVE ?= "off" #on off

compile:
	g++ -O3 ${BASEDIR}/cpp/sha.cpp ${BASEDIR}/cpp/main.cpp -o ${BASEDIR}/cpp/main

run:
	cp -r ${BASEDIR}/py/*.txt ${BASEDIR}/cpp/; \
	cd ${BASEDIR}/cpp; \
	./main ${KLENGTH} ${NLENGTH} ${NDEPTH}

simulate:
	${BASEDIR}/rtl/initialize.sh; \
	${BASEDIR}/sim/run.sh

generate:
	cd ${BASEDIR}/py; \
	./generate.py -k ${KLENGTH} -d ${NLENGTH} -w ${NDEPTH};

all: generate compile run simulate
