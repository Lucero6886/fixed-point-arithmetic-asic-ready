#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p synth/reports synth/netlist

echo "Running Yosys synthesis for min_comparator..."

yosys -s synth/min_comparator.ys | tee synth/reports/min_comparator_yosys.log

if [ $? -ne 0 ]; then
    echo "Yosys synthesis failed."
    exit 1
fi

echo "Yosys synthesis completed."
echo "Netlist: synth/netlist/min_comparator_synth.v"
echo "Report : synth/reports/min_comparator_yosys.log"