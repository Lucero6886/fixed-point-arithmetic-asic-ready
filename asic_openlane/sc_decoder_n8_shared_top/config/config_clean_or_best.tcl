# ============================================================
# OpenLane configuration for sc_decoder_n8_shared_top
# Project 7.5: Resource-shared SC Decoder N=8 physical implementation
# ============================================================

set ::env(DESIGN_NAME) sc_decoder_n8_shared_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

# Resource-shared architecture should have a shorter critical path
# than the combinational N=8 baseline. Start with 30 ns.
set ::env(CLOCK_PERIOD) "30"

# Smaller die than combinational N=8 baseline.
# Combinational clean baseline used 800 x 800 um = 0.64 mm^2.
# Start with 600 x 600 um = 0.36 mm^2.
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 600 600"

# Moderate density.
set ::env(PL_TARGET_DENSITY) 0.30

# Antenna repair settings, inherited from the successful Project 6.4 clean run.
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
set ::env(HEURISTIC_ANTENNA_THRESHOLD) 20
set ::env(DIODE_INSERTION_STRATEGY) 4

set ::env(SYNTH_STRATEGY) "AREA 0"