default: all

export VERILATOR ?= /opt/verilator/bin/verilator
export SYSTEMC ?= /opt/systemc
export BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export KEY_LENGTH ?= 0# 0 -> SHA1, 1 -> SHA2-256, 1 -> SHA2-512
export MSG_LENGTH ?= 1024

export CASE_NUMBER ?= 1

export MAXTIME ?= 1000000000
export DUMP ?= 0# 1 -> enable, 0 -> disable

compile:
	g++ -O3 ${BASEDIR}/cpp/sha.cpp ${BASEDIR}/cpp/main.cpp -o ${BASEDIR}/cpp/main

run:
	cp -r ${BASEDIR}/py/*.txt ${BASEDIR}/cpp/; \
	cd ${BASEDIR}/cpp; \
	./main ${KEY_LENGTH} ${MSG_LENGTH} ${CASE_NUMBER}

simulate:
	${BASEDIR}/rtl/initialize.sh; \
	${BASEDIR}/sim/run.sh

generate:
	cd ${BASEDIR}/py; \
	./generate.py -k ${KEY_LENGTH} -d ${MSG_LENGTH} -w ${CASE_NUMBER};

all: generate compile run simulate
