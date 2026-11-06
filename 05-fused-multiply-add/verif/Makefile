# project 05 verification (Verilator). Usage: make [SEED=n] [NUM=n]
SHELL  := /bin/bash
COMMON := $(abspath ../../common)
SRCS   := $(COMMON)/verif/fp_dv_pkg.sv $(COMMON)/verif/fp_out_sva.sv \
          $(wildcard ../rtl/*.v) tb_top.sv
CSRCS  := $(COMMON)/fpref/fpref.c
include $(COMMON)/mk/verilator.mk
