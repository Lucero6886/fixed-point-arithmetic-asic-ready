# ============================================================
# OpenLane configuration for sc_f_unit_top
# Project 2: SC f Unit RTL-to-GDSII
# ============================================================

set ::env(DESIGN_NAME) sc_f_unit_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 160 160"

set ::env(PL_TARGET_DENSITY) 0.45