
file mkdir fm/reports
# 1. Biblioteca de células — a mesma target_library do synth.tcl
read_db libs/saed32rvt_tt1p05v25c.db


set synopsys_auto_setup true
# 2. Carrega o SVF gerado pelo Design Compiler (Etapa 1) como guidance.
set_svf synth/reports/default.svf

# 3. ESSENCIAL: habilita o modo de setup automático baseado no SVF


read_sverilog -r {
	rtl/vending_pkg.sv
	rtl/comparator.sv
	rtl/control_unit.sv
	rtl/memory.sv
	rtl/credit_reg.sv
	rtl/subtrator.sv
	rtl/vending_top.sv
}
set_top r:/WORK/vending_top

# 5. Design revisado — netlist gerada pelo Design Compiler
read_verilog -i synth/vending_top_netlist.v
set_top i:/WORK/vending_top


# 6. Casamento de pontos entre golden e revised, usando o guidance do SVF
match
# Verifica quais operações do SVF foram usadas com sucesso como guidance
# e quais foram rejeitadas (precisam de investigação manual)
report_svf_operation -status accepted > fm/reports/formality_svf_accepted.rpt
report_svf_operation -status rejected > fm/reports/formality_svf_rejected.rpt
# Inspecione o resultado do casamento antes de seguir para verify
report_matched_points > fm/reports/formality_matched.rpt
report_unmatched_points > fm/reports/formality_unmatched.rpt


# 7. Prova de equivalência ponto a ponto
verify
# 8. Relatórios de sign-off
report_status > fm/reports/formality_status.rpt
report_passing_points > fm/reports/formality_passing.rpt
report_failing_points > fm/reports/formality_failing.rpt
report_unmatched_points > fm/reports/formality_unmatched.rpt
exit