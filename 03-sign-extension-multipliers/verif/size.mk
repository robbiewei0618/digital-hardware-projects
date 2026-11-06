# one operand size of the project 03 testbench (called from Makefile)
SHELL  := /bin/bash
COMMON := $(abspath ../../common)
SIZE   ?= 8x8
M_W    := $(word 1,$(subst x, ,$(SIZE)))
N_W    := $(word 2,$(subst x, ,$(SIZE)))
SRCS   := $(wildcard ../rtl/*.v) tb_top.sv
BUILD  := build_$(SIZE)
RUN_NAME := $(SIZE)
EXTRA_VFLAGS := +define+M_W=$(M_W) +define+N_W=$(N_W)
include $(COMMON)/mk/verilator.mk
