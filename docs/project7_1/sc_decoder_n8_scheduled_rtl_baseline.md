# Project 7.1: Scheduled / Multi-Cycle SC Decoder N=8 RTL Baseline

## 1. Objective

This project implements a scheduled, multi-cycle RTL baseline for the SC Decoder N=8.

Unlike the one-cycle combinational decoder from Project 6.2–6.4, this architecture computes the SC decoding schedule over multiple clock cycles using an FSM and internal registers.

---

## 2. Motivation

The combinational SC Decoder N=8 baseline achieved a signoff-clean OpenLane implementation at a relaxed 80 ns clock period. However, the large combinational logic path suggests that a more scalable architecture should be explored.

The scheduled decoder aims to trade latency for a shorter combinational path and better scalability.

---

## 3. Design Files

```text
rtl/sc_decoder_n8_scheduled.v
tb/tb_sc_decoder_n8_scheduled_vectors.v
sim/run_sc_decoder_n8_scheduled_vectors.sh