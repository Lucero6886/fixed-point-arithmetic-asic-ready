# Project 1.2: Signed Subtractor

## 1. Objective

This project designs and verifies a parameterized signed subtractor as a fixed-point arithmetic primitive for ASIC-ready digital design.

## 2. Design Specification

- Module: signed_subtractor
- Parameter: W = 6
- Inputs: signed a[W-1:0], signed b[W-1:0]
- Output: signed y[W:0]
- Function: y = a - b

## 3. RTL Design

The subtractor uses sign extension before subtraction to preserve the signed numerical range.

## 4. Verification

The self-checking testbench exhaustively verifies all input combinations for W = 6.

Expected number of tests:

64 × 64 = 4096

Result:

ALL TESTS PASSED.

## 5. Yosys Synthesis

Yosys was used to synthesize the signed_subtractor core.

Key synthesis observations:

[Điền kết quả từ Yosys report]

## 6. OpenLane Implementation

A registered wrapper signed_subtractor_top was used for OpenLane implementation to provide a clocked top module and enable timing analysis.

OpenLane result:

- Flow status: [Điền]
- GDSII: generated
- DRC: [Điền]
- LVS: [Điền]
- Antenna: [Điền]

## 7. Connection to SC g Unit

The SC g function is:

g(alpha, beta, u_hat) = beta + alpha, if u_hat = 0
g(alpha, beta, u_hat) = beta - alpha, if u_hat = 1

Therefore, the signed subtractor is one of the key arithmetic primitives for the SC g processing unit.