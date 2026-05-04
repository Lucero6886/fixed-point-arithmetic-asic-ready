#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

mkdir -p synth/reports results/summary

echo "Running Yosys synthesis for SC Decoder N=16 reference RTL..."

yosys -s synth/sc_decoder_n16_ref_flat.ys | tee synth/reports/sc_decoder_n16_ref_flat_yosys.log

echo
echo "Extracting Yosys summary..."
python3 scripts/extract_sc_decoder_n16_ref_yosys_summary.py

echo
echo "Summary:"
cat results/summary/sc_decoder_n16_ref_yosys_summary.md