#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

mkdir -p sim/waveforms

echo "Generating SC Decoder N=16 shared RTL from schedule..."
python3 model/sc_schedule_generator.py
python3 scripts/generate_sc_decoder_n16_shared_rtl.py

echo "Compiling SC Decoder N=16 resource-shared RTL..."
iverilog -g2012 \
    -o sim/sc_decoder_n16_shared_vectors_sim \
    rtl/sc_decoder_n16_shared.v \
    tb/tb_sc_decoder_n16_shared_vectors.v

echo "Running simulation..."
vvp sim/sc_decoder_n16_shared_vectors_sim

echo "Simulation completed."
echo "Waveform: sim/waveforms/sc_decoder_n16_shared_vectors.vcd"