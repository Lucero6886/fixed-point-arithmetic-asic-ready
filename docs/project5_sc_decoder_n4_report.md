# Project 5: SC Decoder N=4 RTL-To-GDSII

## 1. Objective

This project designs, verifies, synthesizes, and physically implements a small Successive Cancellation (SC) Decoder with code length N=4. The goal is to build the first complete decoder-level hardware block by reusing previously developed SC f and SC g processing units.

This project is a key milestone because it moves beyond individual arithmetic primitives and implements a mini Polar decoder architecture.

---

## 2. Background

The SC decoder estimates the source bit vector sequentially using LLR messages and frozen-bit information.

For N=4, the decoder receives four channel LLR values:

```text
llr0, llr1, llr2, llr3