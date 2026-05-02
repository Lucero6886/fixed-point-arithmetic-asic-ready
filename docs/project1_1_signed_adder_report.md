# Project 1.1: Signed Adder

## 1. Objective

This project designs and verifies a parameterized signed adder as a basic fixed-point arithmetic primitive for ASIC-ready digital design.

## 2. Design Specification

- Module: signed_adder
- Parameter: W = 6
- Inputs: signed a[W-1:0], signed b[W-1:0]
- Output: signed y[W:0]
- Function: y = a + b

## 3. RTL Design

The signed adder uses sign extension before addition to avoid overflow for W-bit inputs.

## 4. Verification

The self-checking testbench exhaustively verifies all input combinations for W = 6.

Expected number of tests:

64 × 64 = 4096

Result:

ALL TESTS PASSED.

## 5. Yosys Synthesis

Yosys was used to synthesize the signed_adder core.

Key synthesis observations:

[Điền kết quả từ Yosys report]

## 6. OpenLane Implementation

A registered wrapper signed_adder_top was used for OpenLane implementation to provide a clocked top module and enable timing analysis.

OpenLane result:

- Flow status: [Điền]
- GDSII: generated
- DRC: [Điền]
- LVS: [Điền]
- Antenna: [Điền]

## 7. Discussion

The signed adder is a fundamental arithmetic block for fixed-point hardware design. It will be reused in the SC g unit, where the computation requires beta + alpha or beta - alpha depending on the previous decision bit.

## 8. Connection to SC g Unit

The SC g function is:

g(alpha, beta, u_hat) = beta + alpha, if u_hat = 0
g(alpha, beta, u_hat) = beta - alpha, if u_hat = 1

Therefore, the signed adder is one of the key building blocks for the SC g processing unit.

Report updating!

Yosys synthesis confirms that the signed_adder RTL is synthesizable. Since the module is purely combinational, no flip-flops are inferred. The synthesized logic contains 27 cells, including NAND, XOR, XNOR, and AND gates. This is consistent with the expected hardware structure of a binary adder, where XOR/XNOR gates implement sum logic and NAND/AND networks implement carry-related logic.


Kết quả synthesis bằng Yosys cho thấy RTL của khối signed_adder có thể tổng hợp được thành logic phần cứng. Do module này là mạch tổ hợp thuần túy nên không có flip-flop nào được suy luận. Thiết kế sau tổng hợp gồm 27 cell logic, bao gồm các cổng NAND, XOR, XNOR và AND. Kết quả này phù hợp với cấu trúc phần cứng kỳ vọng của một bộ cộng nhị phân, trong đó các cổng XOR/XNOR tham gia tạo bit tổng và mạng NAND/AND tham gia vào logic carry.