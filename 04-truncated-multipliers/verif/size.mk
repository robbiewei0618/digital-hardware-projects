# one operand size of the project 04 testbench (called from Makefile)
SHELL  := /bin/bash
COMMON := $(abspath ../../common)
N_W    ?= 8
SRCS   := $(wildcard ../rtl/*.v) tb_top.sv
BUILD  := build_$(N_W)
RUN_NAME := n$(N_W)
EXTRA_VFLAGS := +define+N_W=$(N_W)
include $(COMMON)/mk/verilator.mk
