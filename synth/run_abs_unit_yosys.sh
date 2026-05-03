#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p synth/reports synth/netlist

echo "Running Yosys synthesis for abs_unit..."

yosys -s synth/abs_unit.ys | tee synth/reports/abs_unit_yosys.log

if [ $? -ne 0 ]; then
    echo "Yosys synthesis failed."
    exit 1
fi

echo "Yosys synthesis completed."
echo "Netlist: synth/netlist/abs_unit_synth.v"
echo "Report : synth/reports/abs_unit_yosys.log"