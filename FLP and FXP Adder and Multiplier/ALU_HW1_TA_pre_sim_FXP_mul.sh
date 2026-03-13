#!/bin/tcsh

vcs -R -debug_access+all \
/MasterClass/M133040086_ALU/HW1/pre_sim/ALU_HW1_testbench.v \
/MasterClass/M133040086_ALU/HW1/RTL/FXP_Multiplier/FXP_mul.v \
+full64 \
+access+r +vcs+fsdbon +fsdb+mda +fsdbfile+FXP_mul.fsdb +v2k
