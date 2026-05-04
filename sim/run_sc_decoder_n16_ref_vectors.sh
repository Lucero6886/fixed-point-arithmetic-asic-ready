#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Compiling SC Decoder N=16 reference RTL..."
iverilog -g2012 \
    -o sim/sc_decoder_n16_ref_vectors_sim \
    rtl/sc_decoder_n16_ref.v \
    tb/tb_sc_decoder_n16_ref_vectors.v

echo "Running simulation..."
vvp sim/sc_decoder_n16_ref_vectors_sim

echo "Simulation completed."
echo "Waveform: sim/waveforms/sc_decoder_n16_ref_vectors.vcd"