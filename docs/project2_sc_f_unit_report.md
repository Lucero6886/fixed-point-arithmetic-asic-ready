# Project 2: SC f Unit RTL-To-GDSII

## 1. Objective

This project designs and verifies the SC f processing unit for a Polar SC decoder using the min-sum approximation.

## 2. Function

The SC f function is approximated as:

```text
f(alpha, beta) ≈ sign(alpha) sign(beta) min(|alpha|, |beta|)