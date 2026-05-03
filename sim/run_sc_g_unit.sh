#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling sc_g_unit..."

iverilog -g2012 -o sim/sc_g_unit_sim \
    rtl/signed_adder.v \
    rtl/signed_subtractor.v \
    rtl/sc_g_unit.v \
    tb/tb_sc_g_unit.v

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Running simulation..."

vvp sim/sc_g_unit_sim

if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

echo "Simulation completed."
echo "Waveform: sim/waveforms/sc_g_unit.vcd"