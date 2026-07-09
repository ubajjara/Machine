#carregar config

source synth/.synopsys_dc.setup


#ler o rtl

analyze -format sverilog {
	rtl/vending_pkg.sv
	rtl/Comparador.sv
	rtl/control_unit.sv
	rtl/memory.sv
	rtl/registrador_credito.sv
	rtl/subtrator.sv
	rtl/vending_top.sv
}


elaborate vending_top
current_design vending_top

link

#contraints

read_sdc synth/vending.sdc


#Chequando o design

redirect synth/reports/check_design.rpt {
check_design
}

redirect synth/reports/area_pre.rpt {
report_area -hierarchy
}
		
redirect synth/reports/timing_pre.rpt {
report_timing -max_paths 10
}


#Inicio da síntese


compile_ultra -no_autoungroup

#relatorios

redirect synth/reports/area_pos.rpt {
report_area -hierarchy
}

redirect synth/reports/timing_relatorio.rpt {
report_timing -max_paths 10
}

redirect synth/reports/power.rpt {
report_power 
}

redirect synth/reports/setup_violations.rpt {
report_constraint -all_violators
}

#Exportar netlist

write -format verilog -hierarchy -output synth/vending_top_syn.v

write -format ddc -hierarchy -output synth/vending_top_syn.ddc

