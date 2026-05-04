cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

mkdir -p docs/project8_2

cat > docs/project8_2/sc_decoder_n16_reference_rtl_baseline.md <<'EOF'
# Project 8.2: SC Decoder N=16 Reference RTL Baseline

## 1. Project Objective

Project 8.2 implements a reference RTL baseline for SC Decoder N=16.

The main objective is to create a functionally correct RTL decoder that matches the Python golden model from Project 8.1.

This project is not yet focused on area optimization, timing optimization, or resource sharing.

The main purpose is:

```text
Python golden model N=16
→ golden vectors N=16
→ reference RTL N=16
→ Verilog testbench
→ RTL-vs-golden verification