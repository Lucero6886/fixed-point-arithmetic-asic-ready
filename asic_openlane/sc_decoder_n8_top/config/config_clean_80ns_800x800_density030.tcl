# ============================================================
# OpenLane configuration for sc_decoder_n8_top
# Project 6.4B: Antenna-clean attempt 4 - heavy diode insertion
# ============================================================

set ::env(DESIGN_NAME) sc_decoder_n8_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "80"

# Best previous baseline
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 800 800"
set ::env(PL_TARGET_DENSITY) 0.25

# Antenna repair
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1

# More aggressive heuristic diode insertion, if supported by this OpenLane version.
set ::env(HEURISTIC_ANTENNA_THRESHOLD) 20

# Stronger diode insertion strategy, if supported.
set ::env(DIODE_INSERTION_STRATEGY) 4

# More antenna repair iterations, if supported.
set ::env(GRT_ANTENNA_ITERS) 20

set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(CLOCK_PERIOD) "80"
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 800 800"
set ::env(PL_TARGET_DENSITY) 0.30
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
set ::env(HEURISTIC_ANTENNA_THRESHOLD) 20
set ::env(DIODE_INSERTION_STRATEGY) 4
set ::env(SYNTH_STRATEGY) "AREA 0"