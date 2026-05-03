#!/bin/bash

set -e

mkdir -p docs/project5_5
mkdir -p docs/project6_1
mkdir -p docs/project6_2

timestamp=$(date +"%Y%m%d_%H%M%S")

if [ -d docs ]; then
    cp -r docs "docs_backup_${timestamp}"
    echo "[BACKUP] Existing docs backed up to docs_backup_${timestamp}"
fi

if [ -f README.md ]; then
    cp README.md "README_backup_${timestamp}.md"
    echo "[BACKUP] Existing README backed up to README_backup_${timestamp}.md"
fi

cat > README.md <<'EOF'
# Fixed-Point Arithmetic And Polar Decoder ASIC-Ready Design Roadmap

This repository documents a step-by-step RTL-to-GDSII roadmap for digital IC design using open-source tools.

The main technical direction is Polar-code hardware, including arithmetic primitives, SC f/g processing units, Polar Encoder N=8, SC Decoder N=4, and SC Decoder N=8 baseline verification.

## Main Flow

```text
Specification
→ Verilog RTL
→ Self-checking testbench
→ Simulation / waveform
→ Yosys synthesis
→ OpenLane RTL-to-GDSII
→ GDSII
→ DRC / LVS / Antenna / Timing
→ Report / Git / Review


