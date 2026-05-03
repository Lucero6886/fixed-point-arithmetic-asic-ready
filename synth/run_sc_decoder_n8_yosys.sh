#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p synth/reports synth/netlist

echo "Running Yosys synthesis for sc_decoder_n8..."

yosys -s synth/sc_decoder_n8.ys | tee synth/reports/sc_decoder_n8_yosys.log

if [ $? -ne 0 ]; then
    echo "Yosys synthesis failed."
    exit 1
fi

echo "Yosys synthesis completed."
echo "Netlist: synth/netlist/sc_decoder_n8_synth.v"
echo "Report : synth/reports/sc_decoder_n8_yosys.log"
