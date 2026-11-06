set Company 		"NSYSU2025ALU"
set Designer 		"Student"

#設定ADFP(16nm)製程路徑
set search_path      "/cad/CBDK/ADFP/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/CCS/  $search_path"
set target_library   "N16ADFP_StdCellss0p72vm40c_ccs.db N16ADFP_StdCellff0p88v125c_ccs.db"

set link_library     "* $target_library dw_foundation.sldb"
set symbol_library   "tsmc040.sdb generic.sdb"
set synthetic_library "dw_foundation.sldb"
set hdlin_translate_off_skip_text "TRUE"
set edifout_netlist_only "TRUE"
set verilogout_no_tri true
set hdlin_enable_presto_for_vhdl "TRUE"
set sh_enable_line_editing true
set sh_line_editing_mode emacs
history keep 100
alias h history

set Path_Top		"/MasterClass/M133040086_ALU/HW4/RTL/multiply_op.v"
set Path_Syn		"/MasterClass/M133040086_ALU/HW4/Gate_Level_SYN/op/Delay/"
set Dump_file_name  "multiply_op_8x16"
set Top				"multiply_op"
set Clk_pin			"clk"
set Clk_period		"0.2"

# [ Read Design File ]
analyze -format verilog {
    /MasterClass/M133040086_ALU/HW4/RTL/multiply_op.v
}
elaborate $Top
current_design $Top
#檢查是否讀取成功
link


# [ Setting Clock Constraints, Combinational Circurt USED ]
set_max_delay $Clk_period  -from [all_inputs] -to [all_outputs]
create_clock -name $Clk_pin -period $Clk_period

# [ Setting Clock Constraints ]
#create_clock -name $Clk_pin -period $Clk_period [get_ports $Clk_pin]
#set_fix_hold									[get_clocks $Clk_pin]
#set_dont_touch_network						    [get_clocks $Clk_pin]
#set_ideal_network								[get_ports $Clk_pin]

#Setting Input / Output Delay
set_input_delay    	0    -clock $Clk_pin [remove_from_collection [all_inputs] [get_ports $Clk_pin]]
set_output_delay   	0    -clock $Clk_pin [all_outputs]

# [ Setting Design Environment ]
set_operating_conditions    -min_library N16ADFP_StdCellff0p88v125c_ccs -min ff0p88v125c \
                            -max_library N16ADFP_StdCellss0p72vm40c_ccs -max ss0p72vm40c



set_wire_load_model -name ZeroWireload -library N16ADFP_StdCellss0p72vm40c_ccs                         
set_wire_load_mode top

# Area Optimization
set_max_area 0

compile

#Change Naming Rule
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "A-Z a-z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "A-Z a-z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*""cell"}} 
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule
remove_unconnected_ports -blast_buses [get_cells -hierarchical *]

report_timing -significant_digits 6 -sort_by group

#Report
report_timing -path full -delay max -significant_digits 6 -sort_by group > $Path_Syn/1.timing_report_${Dump_file_name}.txt
report_area -hier -nosplit > $Path_Syn/2.area_report_${Dump_file_name}.txt
report_power -analysis_effort low > $Path_Syn/3.power_report_${Dump_file_name}.txt

# #Each Pipeline Delay 
# uplevel #0 { report_timing  -through { m1/* } -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } > $Path_Syn/timing_report_stage1.txt
# uplevel #0 { report_timing  -through { m2/* } -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } > $Path_Syn/timing_report_stage2.txt
# uplevel #0 { report_timing  -through { m3/* } -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } > $Path_Syn/timing_report_stage3.txt
# uplevel #0 { report_timing  -through { m4/* } -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } > $Path_Syn/timing_report_stage4.txt
# uplevel #0 { report_timing  -through { m5/* } -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } > $Path_Syn/timing_report_stage5.txt
# uplevel #0 { report_timing  -through { m6/* } -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } > $Path_Syn/timing_report_stage6.txt
# uplevel #0 { report_timing  -through { m7/* } -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group } > $Path_Syn/timing_report_stage7.txt

#Write out
write -hierarchy -format ddc -output $Path_Syn/${Dump_file_name}.ddc
write -format verilog -hierarchy -output $Path_Syn/${Dump_file_name}.v
write_sdf -version 2.1 -context verilog $Path_Syn/${Dump_file_name}.sdf
write_sdc $Path_Syn/${Dump_file_name}.sdc

# report_clock_gating -gating_elements
exit
