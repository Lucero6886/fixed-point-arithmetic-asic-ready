# Project 1.5: Absolute-Minimum Unit RTL-To-GDSII

## 1. Objective

This project designs and verifies an absolute-minimum unit, `abs_min_unit`, as a fixed-point arithmetic primitive for ASIC-ready digital design. The unit computes the minimum magnitude between two signed inputs.

## 2. Design Specification

- Module: abs_min_unit
- Parameter: W = 6
- Inputs:
  - signed alpha[W-1:0]
  - signed beta[W-1:0]
- Output:
  - unsigned min_abs[W-1:0]
- Function:

```text
min_abs = min(|alpha|, |beta|)