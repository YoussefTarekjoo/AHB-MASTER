vlib work
vlog AHP_master_PKG.sv AHP_master.sv AHP_ALU.v AHP_master_tb.sv +cover -covercells
vsim -voptargs=+acc work.AHP_master_tb 
add wave *
run -all