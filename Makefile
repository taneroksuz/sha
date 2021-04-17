default: none

VERILATOR ?= /opt/verilator/bin/verilator
SYSTEMC ?= /opt/systemc
BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CYCLES ?= 10000
KLENGTH ?= 512
NLENGTH ?= 1024
NDEPTH ?= 1
WAVE ?= "" # "wave" for saving dump file

compile:
	g++ -O3 ${BASEDIR}/cpp/sha.cpp ${BASEDIR}/cpp/main.cpp -o ${BASEDIR}/cpp/main.o

run:
	cp -r ${BASEDIR}/py/*.txt ${BASEDIR}/cpp/; \
	cd ${BASEDIR}/cpp; \
	./main.o ${KLENGTH} ${NLENGTH} ${NDEPTH}

simulate:
	${BASEDIR}/rtl/initialize.sh ${BASEDIR} ${KLENGTH} ${NLENGTH} ${NDEPTH}
	sim/run.sh ${BASEDIR} ${VERILATOR} ${SYSTEMC} ${CYCLES} ${WAVE}

generate:
	cd ${BASEDIR}/py; \
	./generate.py -k ${KLENGTH} -d ${NLENGTH} -w ${NDEPTH};

all: generate compile run
