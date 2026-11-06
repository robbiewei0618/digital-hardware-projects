delete_empty_hinsts

write_netlist outputs/FMA_pipe_pr.v
set TAP_CELL_LIST [get_db [get_db base_cells TAP_*] .name]
set BOUNDARY_CELL_LIST [get_db [get_db base_cells BOUNDARY_*] .name]
set DECAP_CELL_LIST [get_db [get_db base_cells DCAP_*] .name]
set PVDD_CELL_LIST [get_db [get_db base_cells PVDD*] .name]
set FILLER_CELL_LIST [get_db [get_db base_cells FILL*] .name]
set PFILLER_CELL_LIST [get_db [get_db base_cells PFILL*] .name]
set PCORNER_CELL_LIST [get_db [get_db base_cells PCORNER*] .name]
write_netlist -include_pg_ports  -include_phys_cells "$TAP_CELL_LIST $BOUNDARY_CELL_LIST $DECAP_CELL_LIST $PVDD_CELL_LIST $FILLER_CELL_LIST $PFILLER_CELL_LIST $PCORNER_CELL_LIST" outputs/FMA_pipe_pg.v

