# Project 1.3: Absolute Value Unit RTL-To-GDSII

## 1. Objective

This project designs, verifies, synthesizes, and physically implements an absolute value unit, referred to as `abs_unit`, as a fixed-point arithmetic primitive for ASIC-ready digital design.

The `abs_unit` block is an important building block for the SC f processing unit in a Polar decoder. In the min-sum approximation of SC decoding, the f function requires the magnitudes of two signed LLR inputs:

```text
abs_alpha = |alpha|
abs_beta  = |beta|