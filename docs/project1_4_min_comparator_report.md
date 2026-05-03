# Project 1.4: Minimum Comparator

## 1. Objective

This project designs and verifies a parameterized minimum comparator as a fixed-point arithmetic primitive for ASIC-ready digital design.

## 2. Design Specification

- Module: min_comparator
- Parameter: W = 6
- Inputs: unsigned a[W-1:0], unsigned b[W-1:0]
- Output: unsigned y[W-1:0]
- Function: y = min(a, b)

## 3. RTL Design

The design compares two unsigned magnitudes and selects the smaller value using a comparator and a multiplexer.

## 4. Verification

The self-checking testbench exhaustively verifies all input combinations for W = 6.

Expected number of tests:

64 × 64 = 4096

Result:

ALL TESTS PASSED.

## 5. Yosys Synthesis

Yosys was used to synthesize the min_comparator core.

Key synthesis observations:

[Điền kết quả từ Yosys report]

## 6. OpenLane Implementation

A registered wrapper min_comparator_top was used for OpenLane implementation to provide a clocked top module and enable timing analysis.

OpenLane result:

- Flow status: [Điền]
- GDSII: generated
- DRC: [Điền]
- LVS: [Điền]
- Antenna: [Điền]

## 7. Connection to SC f Unit

The SC f function is approximately:

f(alpha, beta) ≈ sign(alpha) sign(beta) min(|alpha|, |beta|)

The min_comparator block is used to compute min(|alpha|, |beta|) after alpha and beta are converted to magnitudes using abs_unit.