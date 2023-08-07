#################################################
## DC Synthesis Script v3.1


remove_design -all
set sh_continue_on_error false
set start_time [clock seconds]; echo [clock format ${start_time} -gmt false]
echo [pwd]


#/* specify the libaraies */
set search_path "/mnt/HD0-v1/TSMC28HPC+/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp12t30p140_180a ./ ./src"
set target_library "tcbn28hpcplusbwp12t30p140ssg0p81vm40c_ccs.db"
set link_library "* dw_foundation.sldb tcbn28hpcplusbwp12t30p140ssg0p81vm40c_ccs.db"
set synthetic_library "dw_foundation.sldb"
set_host_options -max_cores 16
set alib_library_analysis_path "./alib-52_test/"

# read the design
set DESIGN_NAME parallel_mul_twiddle_FFT4
analyze -format sverilog -vcs "-f rtl_files.f"
elaborate $DESIGN_NAME


link

# define the design environment
report_design
set_operating_conditions -max ssg0p81vm40c
#set_operating_conditions ssg0p9v0c -lib tcbn28hpcplusbwp12t30p140ssg0p9v0c_ccs

# set design constraints
set_units -time ns -capacitance pF -current mA -voltage V
create_clock -name rclk -period 2.5 [get_ports "clk"]

set_clock_uncertainty -setup 0 [all_clocks]
set_clock_uncertainty -hold 0  [all_clocks]
set_clock_transition 0.053     [all_clocks]

set_input_transition -max 0.03 [all_inputs]
set_input_transition -max 0.01 [get_ports "clk"]
set_input_transition -min 0.001 [all_inputs]

set_max_transition 0.11 [current_design]
set_max_transition 0.055 -clock [all_clocks]

set_input_delay -clock rclk -min 0  [remove_from_collection [all_inputs] "clk"]
set_output_delay -clock rclk -min 0 [all_outputs]

set_input_delay -max 1.25 -clock rclk [remove_from_collection [all_inputs] "clk"]
set_output_delay -max 1.25 -clock rclk [all_outputs]

set_max_fanout 32 [current_design]
set_max_capacitance 0.0005 [current_design]

set_load 0.00005 [all_outputs]
set_driving_cell -lib_cell INVD9BWP12T30P140 [all_inputs]

set_fix_multiple_port_nets -feedthroughs -outputs -constants
#
set_ideal_network [get_port rst_n]
set_ideal_network [get_port clk]

# select compile strategy


# synthesize and optimize the design
uniquify
compile -map_effort high
compile -only_design_rule -incremental_mapping
compile -ungroup_all

####################################################
##change name
#####################################################
change_names -rule verilog -hierarchy
source ./dc_name_rule_reserved.tcl

# analyze and resolve design problems
report_timing -path full -delay min -max_paths 10 -significant_digits 9 -nworst 10 > ./REPORT/$DESIGN_NAME.holdtiming_min
report_timing -path full -delay max -max_paths 10 -significant_digits 9 -nworst 10 > ./REPORT/$DESIGN_NAME.setuptiming_max
##report_timing -path full -delay min -max_paths 10 -nworst 10 > ./REPORT/Design.setuptiming_min
report_area -hierarchy > ./REPORT/$DESIGN_NAME.area
report_power -hierarchy > ./REPORT/$DESIGN_NAME.power
report_resources > ./REPORT/$DESIGN_NAME.resources
report_constraint -verbose > ./REPORT/$DESIGN_NAME.constraint
report_port > ./REPORT/$DESIGN_NAME.port

check_design > ./REPORT/$DESIGN_NAME.check_design
check_design > ./REPORT/$DESIGN_NAME.check_timing

write -hierarchy -format verilog -output ./SIM/$DESIGN_NAME.v
write -hierarchy -format verilog -output ./SIM/$DESIGN_NAME.vg
write_sdf -version 2.1 -context verilog ./SIM/$DESIGN_NAME.sdf
write_sdc -version 2.1 ./SIM/$DESIGN_NAME.sdc
write_parasitics -output ./SIM/$DESIGN_NAME.spf

set end_time [clock seconds]; echo [clock format ${end_time} -gmt false]

#Total script wall clock run time
echo "Time elapsed: [format %02d [expr ( $end_time - $start_time ) / 86400 ]]d\
[clock format [expr ( $end_time - $start_time ) ] -format %Hh%Mm%Ss -gmt true]"