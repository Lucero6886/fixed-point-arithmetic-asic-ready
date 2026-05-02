#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p synth/reports synth/netlist

echo "Running Yosys synthesis for signed_adder..."

yosys -s synth/signed_adder.ys | tee synth/reports/signed_adder_yosys.log

if [ $? -ne 0 ]; then
    echo "Yosys synthesis failed."
    exit 1
fi

echo "Yosys synthesis completed."
echo "Netlist: synth/netlist/signed_adder_synth.v"
echo "Report : synth/reports/signed_adder_yosys.log"