default: none

VERILATOR ?= /opt/verilator/bin/verilator
SYSTEMC ?= /opt/systemc
BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CYCLES ?= 1000000000
KLENGTH ?= 512
DLENGTH ?= 64
NWORDS ?= 1
WAVE ?= "" # "wave" for saving dump file

compile:
	g++ -O3 ${BASEDIR}/cpp/sha.cpp ${BASEDIR}/cpp/main.cpp -o ${BASEDIR}/cpp/main.o

run:
	cp -r ${BASEDIR}/py/*.txt ${BASEDIR}/cpp/; \
	cd ${BASEDIR}/cpp; \
	./main.o ${KLENGTH} ${DLENGTH} ${NWORDS}

generate:
	cd ${BASEDIR}/py; \
	./generate.py -k ${KLENGTH} -d ${DLENGTH} -w ${NWORDS};

all: generate simulate
