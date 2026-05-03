# Project 7.6: Timing Push For Resource-Shared SC Decoder N=8

## 1. Objective

This project pushes the timing constraint of the resource-shared SC Decoder N=8 to identify the best clean clock period under the current OpenLane configuration.

The baseline from Project 7.5 achieved clean implementation at 30 ns. Project 7.6 further evaluates a tighter 15 ns timing constraint.

---

## 2. Baseline Architecture

The design under test is:

```text
rtl/sc_decoder_n8_shared_top.v