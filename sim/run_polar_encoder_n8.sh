#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling polar_encoder_n8..."

iverilog -g2012 -o sim/polar_encoder_n8_sim \
    rtl/polar_encoder_n8.v \
    tb/tb_polar_encoder_n8.v

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Running simulation..."

vvp sim/polar_encoder_n8_sim

if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

echo "Simulation completed."
echo "Waveform: sim/waveforms/polar_encoder_n8.vcd"