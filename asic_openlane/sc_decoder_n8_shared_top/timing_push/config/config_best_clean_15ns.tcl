# ============================================================
# OpenLane configuration for sc_decoder_n8_shared_top
# Project 7.6: Timing push attempt 1 - 15 ns
# ============================================================

set ::env(DESIGN_NAME) sc_decoder_n8_shared_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "15"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 600 600"

set ::env(PL_TARGET_DENSITY) 0.30

set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
set ::env(HEURISTIC_ANTENNA_THRESHOLD) 20
set ::env(DIODE_INSERTION_STRATEGY) 4

# set ::env(SYNTH_STRATEGY) "AREA 0"