# ==========================================
# Diretórios
# ==========================================
RTL_DIR   = rtl
TB_DIR    = sim
SYNTH_DIR = synth

#Arquivos

PKG_FILES = $(RTL_DIR)/vending_pkg.sv

RTL_FILES = \
		 $(RTL_DIR)/comparator.sv \
		 $(RTL_DIR)/control_unit.sv \
		 $(RTL_DIR)/memory.sv \
		 $(RTL_DIR)/credit_reg.sv \
		 $(RTL_DIR)/subtrator.sv \
		 $(RTL_DIR)/vending_top.sv

TB_FILES = \
		$(TB_DIR)/tb_vending.sv

#Top do testbrench
TOP = tb_vending

#Flags
TIMESCALE = 1ns/1ps

VLOGAN_FLAGS = -full64 \
			   -sverilog \
			   -kdb \
			   +lint=all

VCS_FLAGS = -full64 \
			-timescale=$(TIMESCALE) \
			-debug_access+all \
			-kdb

#Verificar sintax
syntax:
	vlogan $(VLOGAN_FLAGS) \
		$(PKG_FILES) \
		$(RTL_FILES) \
		$(TB_FILES)

#compluação

compile: syntax
	vcs $(VCS_FLAGS) -top $(TOP)

#Simulação

run: compile
	./simv

#Abrir Waveform
wave:
	verdi -ssf waves.fsdb &

synth:
	dc_shell -f $(SYNTH_DIR)/synth.tcl


clean_sim:
	rm -rf \
		csrc \
		simv* \
		*.daidir \
		novas* \
		AN.DB \
		ucli.key \
		verdi* \
		DVEfiles \
		vfastLog \
		work.lib++ \
		.vlogan* \
		*.fsdb \
		*.log

clean_synth:
	rm -rf \
		work \
		$(SYNTH_DIR)/reports/*.rpt \
		$(SYNTH_DIR)/reports/*.ddc \
		$(SYNTH_DIR)/reports/*.db \
		$(SYNTH_DIR)/reports/*_syn.v \
		$(SYNTH_DIR)/*.ddc \
		$(SYNTH_DIR)/*.v \
		default.svf

clean: clean_sim clean_synth

.PHONY: syntax compile run wave synth clean_sim
