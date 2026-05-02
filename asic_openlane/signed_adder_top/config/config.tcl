# ============================================================
# OpenLane configuration for signed_adder_top
# Project 1.1: Signed Adder RTL-to-GDSII
# ============================================================

set ::env(DESIGN_NAME) signed_adder_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10"

# Small design, but slightly larger than counter project
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 120 120"

set ::env(PL_TARGET_DENSITY) 0.45