set company "VLSILAB"
set designer "OWEN"
#######################################################################
## Logical Library Settings
#######################################################################
set search_path      "/cad/CBDK/ADFP/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/CCS/  $search_path"
set target_library   "N16ADFP_StdCellss0p72vm40c_ccs.db N16ADFP_StdCellff0p88v125c_ccs.db"
# set link_library     "* $target_library dw_foundation.sldb"
set link_library     "* $target_library"
set symbol_library   "generic.sdb"
# set synthetic_library "dw_foundation.sldb"
set sh_source_uses_search_path true

######################################################################
# power analysis
######################################################################
# source saifmap.ptpx.tcl
# report_name_mapping
set Top DP_4
set power_enable_analysis true
set power_analysis_mode averaged
set power_report_leakage_breakdowns true
# gate-level .v
read_verilog /home/m133040045/back_up/m133040045/ALU/HW3_ALU/FLP_DP_4/gate/delay/DP_4_syn.v
#rtl top module name
current_design $Top
link

read_sdc /home/m133040045/back_up/m133040045/ALU/HW3_ALU/FLP_DP_4/gate/delay/DP_4_syn.sdc
read_sdf /home/m133040045/back_up/m133040045/ALU/HW3_ALU/FLP_DP_4/gate/delay/DP_4_syn.sdf
check_timing
update_timing

read_vcd -strip_path testbench/test_module /home/m133040045/back_up/m133040045/ALU/HW3_ALU/FLP_DP_4/postsim/DP_4_wave.vcd

check_power
update_power

report_power -hierarchy > report_${Top}_power_average_vcd.rpt

#quit
exit
