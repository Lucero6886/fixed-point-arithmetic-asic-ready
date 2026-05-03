#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling abs_min_unit..."

iverilog -g2012 -o sim/abs_min_unit_sim \
    rtl/abs_unit.v \
    rtl/min_comparator.v \
    rtl/abs_min_unit.v \
    tb/tb_abs_min_unit.v

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Running simulation..."

vvp sim/abs_min_unit_sim

if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

echo "Simulation completed."
echo "Waveform: sim/waveforms/abs_min_unit.vcd"