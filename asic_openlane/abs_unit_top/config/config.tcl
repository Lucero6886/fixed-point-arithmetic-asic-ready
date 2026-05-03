# ============================================================
# OpenLane configuration for abs_unit_top
# Project 1.3: Absolute Value Unit RTL-to-GDSII
# ============================================================

set ::env(DESIGN_NAME) abs_unit_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 120 120"

set ::env(PL_TARGET_DENSITY) 0.45