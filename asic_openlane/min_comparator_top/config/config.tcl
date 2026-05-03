# ============================================================
# OpenLane configuration for min_comparator_top
# Project 1.4: Minimum Comparator RTL-to-GDSII
# ============================================================

set ::env(DESIGN_NAME) min_comparator_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 120 120"

set ::env(PL_TARGET_DENSITY) 0.45