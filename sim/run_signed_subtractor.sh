#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling signed_subtractor..."

iverilog -g2012 -o sim/signed_subtractor_sim \
    rtl/signed_subtractor.v \
    tb/tb_signed_subtractor.v

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Running simulation..."

vvp sim/signed_subtractor_sim

if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

echo "Simulation completed."
echo "Waveform: sim/waveforms/signed_subtractor.vcd"