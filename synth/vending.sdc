#Clock Principal

# 20ns
create_clock -name clk -period 20 [get_ports clk]

set_clock_uncertainty 0.5 [get_clocks clk]

set_clock_transition 0.1 [get_clocks clk]


#Input delay

set_input_delay 3.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]



#output delay
set_output_delay 3.0 -clock clk [all_outputs]


#
set_driving_cell -lib_cell INVX1_RVT 


set_max_fanout 8 [current_design]

set_load 0.05 [all_outputs]
