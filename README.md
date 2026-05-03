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
