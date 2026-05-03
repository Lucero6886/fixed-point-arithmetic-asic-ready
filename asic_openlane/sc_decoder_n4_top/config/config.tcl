# ============================================================
# OpenLane configuration for sc_decoder_n4_top
# Project 5: SC Decoder N=4 RTL-to-GDSII
# Clean baseline attempt: relaxed timing and routing
# ============================================================

set ::env(DESIGN_NAME) sc_decoder_n4_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

# More relaxed clock for signoff-clean baseline
set ::env(CLOCK_PERIOD) "20"

# Larger die area for easier placement/routing/antenna fixing
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 340 340"

# Lower density to reduce congestion
set ::env(PL_TARGET_DENSITY) 0.30

# Antenna repair
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1