#!/bin/tcsh

vcs -R -debug_access+all \
/MasterClass/M133040086_ALU/HW1/pre_sim/ALU_HW1_testbench.v \
/MasterClass/M133040086_ALU/HW1/RTL/FLP_adder/FLP_adder.v \
/MasterClass/M133040086_ALU/HW1/RTL/FLP_adder_4/FLP_adder_4.v \
/MasterClass/M133040086_ALU/HW1/RTL/FLP_adder_7/FLP_adder_7.v \
+full64 \
+access+r +vcs+fsdbon +fsdb+mda +fsdbfile+FLP.fsdb +v2k
