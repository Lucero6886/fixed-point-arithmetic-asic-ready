# Project 4: Polar Encoder N=8 RTL-To-GDSII

## 1. Objective

This project designs and verifies a Polar Encoder with code length N=8 using Verilog HDL and implements it through an ASIC-ready RTL-to-GDSII flow.

## 2. Background

Polar encoding is based on the transformation:

```text
x = u · F^{⊗n}