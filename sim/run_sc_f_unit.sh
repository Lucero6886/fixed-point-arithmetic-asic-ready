#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling sc_f_unit..."

iverilog -g2012 -o sim/sc_f_unit_sim \
    rtl/abs_unit.v \
    rtl/min_comparator.v \
    rtl/abs_min_unit.v \
    rtl/sc_f_unit.v \
    tb/tb_sc_f_unit.v

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Running simulation..."

vvp sim/sc_f_unit_sim

if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

echo "Simulation completed."
echo "Waveform: sim/waveforms/sc_f_unit.vcd"