#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

mkdir -p synth/reports results/summary

echo "Regenerating SC Decoder N=16 schedule and shared RTL..."
python3 model/sc_schedule_generator.py
python3 scripts/generate_sc_decoder_n16_shared_rtl.py

echo
echo "Running Yosys synthesis for SC Decoder N=16 resource-shared RTL..."

yosys -s synth/sc_decoder_n16_shared_flat.ys | tee synth/reports/sc_decoder_n16_shared_flat_yosys.log

echo
echo "Extracting Yosys summary..."
python3 scripts/extract_sc_decoder_n16_shared_yosys_summary.py

echo
echo "Summary:"
cat results/summary/sc_decoder_n16_shared_yosys_summary.md