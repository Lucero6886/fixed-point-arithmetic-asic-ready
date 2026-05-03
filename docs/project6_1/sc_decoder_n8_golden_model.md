# Project 6.1: SC Decoder N=8 Behavioral/Golden Model

## 1. Objective

This project builds a behavioral golden model for an N=8 Polar Successive Cancellation (SC) decoder. The golden model is implemented in Python and will be used as a reference for verifying the future RTL implementation of `sc_decoder_n8`.

The goal of this project is not to implement RTL yet, but to define a correct and reproducible decoding schedule, bit-order convention, frozen-bit convention, and test-vector generation flow.

---

## 2. Decoder Function

The SC decoder uses the min-sum approximation for the f function:

```text
f(alpha, beta) ≈ sign(alpha) sign(beta) min(|alpha|, |beta|)