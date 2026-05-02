# ============================================================
# OpenLane configuration for signed_subtractor_top
# Project 1.2: Signed Subtractor RTL-to-GDSII
# ============================================================

set ::env(DESIGN_NAME) signed_subtractor_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 120 120"

set ::env(PL_TARGET_DENSITY) 0.45