#!/bin/tcsh
vcs -R -error=noMPD -debug_access+all \
/MasterClass/M133040086_ALU/HW3/Post/CG/F16/DP4_testbench_post.v \
/MasterClass/M133040086_ALU/HW3/Gate_Level/Clock-gated/Delay/DP4_pipeline_CG.v \
/cad/CBDK/ADFP/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/VERILOG/N16ADFP_StdCell.v \
+full64 \
+access+r +vcs+fsdbon +fsdb+mda +fsdbfile+DP4_pipeline_CG.fsdb +neg_tchk
