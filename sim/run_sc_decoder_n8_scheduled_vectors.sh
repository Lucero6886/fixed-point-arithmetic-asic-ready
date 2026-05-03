#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling scheduled SC Decoder N=8..."

iverilog -g2012 -o sim/sc_decoder_n8_scheduled_vectors_sim \
    rtl/sc_decoder_n8_scheduled.v \
    tb/tb_sc_decoder_n8_scheduled_vectors.v

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Running simulation..."

vvp sim/sc_decoder_n8_scheduled_vectors_sim

if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

echo "Simulation completed."
echo "Waveform: sim/waveforms/sc_decoder_n8_scheduled_vectors.vcd"