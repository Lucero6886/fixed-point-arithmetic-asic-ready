#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p synth/reports synth/netlist

echo "Running Yosys synthesis for sc_g_unit..."

yosys -s synth/sc_g_unit.ys | tee synth/reports/sc_g_unit_yosys.log

if [ $? -ne 0 ]; then
    echo "Yosys synthesis failed."
    exit 1
fi

echo "Yosys synthesis completed."
echo "Netlist: synth/netlist/sc_g_unit_synth.v"
echo "Report : synth/reports/sc_g_unit_yosys.log"