#CREATED AT IIT GANDHINAGAR USING AUTOMATION TOOL
#cd umc65nm
set CURRENT_DIR [pwd]
# set search_path [list $CURRENT_DIR/rtl $CURRENT_DIR]
set search_path [list $CURRENT_DIR/rtl]
set target_library [list /opt/tools/Cadence/Cadence_lib/UMC65nm_PDK/STDCELLS/synopsys/ccs/uk65lscllmvbbr_120c25_tc_ccs.db ]

set link_library [concat [concat "*" $target_library] $synthetic_library] 
echo $link_library
set_host_options -max_cores 8
set myfiles [list memory.sv]
echo $myfiles
set basename memory
set fileFormat sverilog 
set myclk [list pclk] ;# The name of your clock
set virtual 0 ;# 1 if you have a COMBINATIONAL Design, 0 if real clock
set useUltra 1 ;# 1 for compile_ultra, 0 for compile 
set mapEffort1 medium ;# First pass - low, medium, or high
set mapEffort2 medium ;# second pass - low, medium, or high
set useUngroup 1 ;# 0 if no flatten, 1 if flatten

set myperiod_ns 1 
#2-1.5;# desired clock period (sets speed goal)
set myindelay_ns 0.1;# delay from clock to inputs valid
set myoutdelay_ns 0.1;# delay from clock to output valid
set myinputbuf INVM8R
#3-inv0d7 ;# name of cell driving the inputs THIS SHOULD BE A 4X inverter (.lib file)
set myloadcell uk65lscllmvbbr_120c25_tc/DFCM8RA/D
set mylibrary uk65lscllmvbbr_120c25_tc



set runname output ;# Name appended to output files
set write_v 1 ;# compiled structural Verilog file
set write_db 0 ;# compiled file in db format (obsolete)
set write_ddc 0 ;# compiled file in ddc format (XG-mode)
set write_sdf 1 ;# sdf file for back-annotated timing sim
set write_sdc 1 ;# sdc constraint file for place and route
set write_rep 1 ;# For Reporting Area, Delay and Power Report


# analyze and elaborate the files
analyze -format $fileFormat -lib work $myfiles
elaborate $basename -lib work 
current_design $basename
link
uniquify

##### -------- ------------------------------------------------ TIMING CONSTRAINT ---------------------------------------------------------------- ###############
# now you can create clocks for the design
if { $virtual == 0 } {
create_clock -period $myperiod_ns $myclk
} else {
create_clock -period $myperiod_ns -name $myclk
# create_clock "clk_virtual" -period $myperiod_ns -name $myclk
}

#set_dont_touch {alu_block processor}
#set_dont_touch_network {clk_alu clk_processor}
#create_clock -period $myperiod_ns -name myclk
set_operating_conditions -library uk65lscllmvbbr_120c25_tc 

set_driving_cell -library $mylibrary -lib_cell $myinputbuf [all_inputs]
#set_input_delay $myindelay_ns -clock $myclk 
#set_output_delay $myoutdelay_ns -clock $myclk [all_outputs]
set_load [load_of $myloadcell] [all_outputs]
#set_fix_hold $myclk
#set_clock_latency 0.09 -source [get_ports $myclk]
#set_clock_uncertainty -setup 0.15 [get_clocks $myclk]
#set_clock_uncertainty -hold 0.1 [get_clocks $myclk]
set_switching_activity  -toggle_rate  0.25 -static_probability 0.5 [all_inputs]
set_input_transition -max 0.1 [all_inputs]
set_input_transition -min 0.1 [all_inputs]
set_wire_load_mode segmented
set auto_wire_load_selection true
set_wire_load_mode segmented
set_fix_multiple_port_nets -all -buffer_constants
# -gate_clock
#set_dont_touch {top_memory_6TSRAM top_memory_DICE top_memory_DPDICE top_block_tmr top_block_gdmr top_block_gf}
#compile_ultra  -exact_map -no_boundary_optimization  -no_autoungroup -no_seq_output_inversion
if { $useUltra == 1 } {
compile_ultra  -exact_map -no_boundary_optimization  -no_autoungroup -no_seq_output_inversion
} else {
if { $useUngroup == 1 } {
compile -ungroup_all -map_effort $mapEffort1
compile -incremental_mapping -map_effort $mapEffort2
} else {
compile -map_effort $mapEffort1
compile -incremental_mapping -map_effort $mapEffort2
}
}
# Check things for errors
check_design

report_constraint -all_violators
set filebase [format "%s%s" [format "%s%s" $basename "_"] $runname]
# structural (synthesized) file as verilog
if { $write_v == 1 } {
set filename [format "%s%s" $filebase ".v"]
redirect change_names \
{ change_names -rules verilog -hierarchy -verbose }
write -format verilog -hierarchy -output $filename
}
# write out the sdf file for back-annotated verilog sim
# This file can be large!
if { $write_sdf == 1 } {
set filename [format "%s%s" $filebase ".sdf"]
write_sdf -version 1.0 $filename
}
# this is the timing constraints file generated from the
# conditions above - used in the place and route program
if { $write_sdc == 1 } {
set filename [format "%s%s" $filebase ".sdc"]
write_sdc $filename
}
# synopsys database format in case you want to read this
# synthesized result back in to synopsys later (Obsolete db format)
if { $write_db == 1 } {
set filename [format "%s%s" $filebase ".db"]
write -format db -hierarchy -o $filename
}
# synopsys database format in case you want to read this
# synthesized result back in to synopsys later in XG mode (ddc format)
if { $write_ddc == 1 } {
set filename [format "%s%s" $filebase ".ddc"]
write -format ddc -hierarchy -o $filename
}
# report on the results from synthesis
# note that > makes a new file and >> appends to a file
if { $write_rep == 1 } {
set filename [format "%s%s" $filebase ".txt"]
redirect  $filename { report_area }
redirect -append $filename { report_timing }
redirect -append $filename { report_power }
redirect -append $filename { report_design }
redirect -append $filename { report_hierarchy }
redirect -append $filename { report_reference }
redirect -append $filename { report_qor }
redirect -append $filename { report_constraint }
}

echo "*******************"
echo "*** AREA REPORT ***"
echo "*******************"
report_area
echo "*********************"
echo "*** TIMING REPORT ***"
echo "*********************"
report_timing
echo "*********************"
echo "*** POWER REPORT ***"
echo "*********************"
report_power
#read_saif -verbose -input Counter1.saif -instance_name Counter_tb/DUT -scale 1
#report_power -analysis_effort high > Power_with_saif.txt
# gui_start
# Quit
exit

