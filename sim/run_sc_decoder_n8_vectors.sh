#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling sc_decoder_n8 with golden vector testbench..."

iverilog -g2012 -o sim/sc_decoder_n8_vectors_sim \
    rtl/abs_unit.v \
    rtl/min_comparator.v \
    rtl/abs_min_unit.v \
    rtl/sc_f_unit.v \
    rtl/signed_adder.v \
    rtl/signed_subtractor.v \
    rtl/sc_g_unit.v \
    rtl/sc_decoder_n4.v \
    rtl/sc_decoder_n8.v \
    tb/tb_sc_decoder_n8_vectors.v

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Running simulation..."

vvp sim/sc_decoder_n8_vectors_sim

if [ $? -ne 0 ]; then
    echo "Simulation failed."
    exit 1
fi

echo "Simulation completed."
echo "Waveform: sim/waveforms/sc_decoder_n8_vectors.vcd"