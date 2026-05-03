# ============================================================
# OpenLane configuration for sc_decoder_n8_top
# Project 6.4: SC Decoder N=8 antenna-clean attempt 3
# ============================================================

set ::env(DESIGN_NAME) sc_decoder_n8_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

# Keep relaxed timing.
set ::env(CLOCK_PERIOD) "80"

# Return to the better area/density from Run 1.
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 800 800"

set ::env(PL_TARGET_DENSITY) 0.25

# Antenna repair.
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1

# Try stronger diode insertion if supported by this OpenLane version.
set ::env(DIODE_INSERTION_STRATEGY) 4

set ::env(SYNTH_STRATEGY) "AREA 0"