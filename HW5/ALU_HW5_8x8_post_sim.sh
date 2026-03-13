#!/bin/tcsh
vcs -R -error=noMPD -debug_access+all \
/MasterClass/M133040086_ALU/HW5/post/16x16/TB_HW5_post.v \
/MasterClass/M133040086_ALU/HW5/Gate_Level_SYN/array/Delay/mul_array_16x16.v \
/MasterClass/M133040086_ALU/HW5/Gate_Level_SYN/op/Delay/mul_operator_16x16.v \
/MasterClass/M133040086_ALU/HW5/Gate_Level_SYN/row/Delay/mul_row_16x16.v \
/MasterClass/M133040086_ALU/HW5/Gate_Level_SYN/trunc_const_row/Delay/mul_trunc_const_row_16x16.v \
/MasterClass/M133040086_ALU/HW5/Gate_Level_SYN/trunc_var_array/Delay/mul_trunc_var_array_16x16.v \
/cad/CBDK/ADFP/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/VERILOG/N16ADFP_StdCell.v \
+full64 \
+access+r +vcs+fsdbon +fsdb+mda +fsdbfile+16x16.fsdb +neg_tchk
