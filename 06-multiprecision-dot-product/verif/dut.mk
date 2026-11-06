# one DUT build of the project 06 testbench (called from Makefile)
SHELL  := /bin/bash
COMMON := $(abspath ../../common)
DUT    ?= comb
SRCS   := $(COMMON)/verif/fp_dv_pkg.sv $(RTL) tb_top.sv
CSRCS  := $(COMMON)/fpref/fpref.c
BUILD  := build_$(DUT)
TOP    := tb_top
EXTRA_VFLAGS := +define+DUT_$(shell echo $(DUT) | tr a-z A-Z)
RUN_NAME := $(DUT)
include $(COMMON)/mk/verilator.mk
