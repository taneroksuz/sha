default: all

export VERILATOR ?= /usr/local/bin/verilator
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export PLAINTEXT_BYTES ?= 1024

export MAXTIME ?= 1000000000
export DUMP ?= 0# 1 -> enable, 0 -> disable

compile:
	g++ -O3 ${BASEDIR}/cpp/sha.cpp ${BASEDIR}/cpp/main.cpp -o ${BASEDIR}/out/main

run:
	${BASEDIR}/out/main ${PLAINTEXT_BYTES}

simulate:
	${BASEDIR}/sim/run.sh

generate:
	${BASEDIR}/sh/generate.sh ${PLAINTEXT_BYTES};

all: generate compile run simulate
