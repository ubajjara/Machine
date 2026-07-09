# ============================================================
# Clock principal
# ============================================================

# 20 ns -> 50 MHz
create_clock -name clk -period 20 [get_ports clk]

# Incerteza do clock
# A atividade pede 0.5 ns para modelar jitter/skew
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold  0.0 [get_clocks clk]

# Tempo de subida/descida do clock
set_clock_transition 0.1 [get_clocks clk]


# ============================================================
# Input delay
# ============================================================
# Esse comando define o atraso de entrada para os sinais externos
# em relação ao clock.
#
# Como o comando remove_from_collection deu erro no ambiente,
# as entradas foram listadas manualmente, excluindo o clock.
#
# Entradas do projeto:
# coin_in[1:0], sel_item[1:0], confirm, cancel, rst

set INPUT_PORTS [get_ports {coin_in* sel_item* confirm cancel rst}]

set_input_delay 3.0 -clock [get_clocks clk] $INPUT_PORTS


# ============================================================
# Driving cell das entradas
# ============================================================
# Esse comando modela a célula que dirige as entradas do circuito.
# Não deve ser aplicado ao clock, apenas às entradas de dados/controle.

set_driving_cell -lib_cell INVX1_RVT $INPUT_PORTS


# ============================================================
# Output delay
# ============================================================
# Esse comando define o atraso de saída para todos os sinais de saída
# em relação ao clock.

set_output_delay 3.0 -clock [get_clocks clk] [all_outputs]


# ============================================================
# Fanout máximo
# ============================================================
# Limita o fanout máximo das redes do design.

set_max_fanout 8 [current_design]


# ============================================================
# Carga das saídas
# ============================================================
# Esse comando define a carga de saída para todos os sinais de saída.
# A carga é definida como 0.05 pF.
#
# Usada para modelar a capacitância externa ao circuito,
# como a capacitância de entrada de outros blocos conectados às saídas.

set_load 0.05 [all_outputs]