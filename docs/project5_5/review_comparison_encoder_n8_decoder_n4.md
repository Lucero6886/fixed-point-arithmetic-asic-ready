# Project 5.5: Review And Comparison Of Polar Encoder N=8 And SC Decoder N=4

## 1. Project Objective

Project 5.5 reviews and compares two important baseline designs in the roadmap:

```text
Project 4: Polar Encoder N=8
Project 5: SC Decoder N=4
```

The objective is not to create new RTL, but to consolidate understanding before moving to SC Decoder N=8.

This review clarifies:

```text
how the Polar encoder differs from the SC decoder
why the decoder is more complex than the encoder
how partial sums connect encoding and decoding
why Project 5 is a necessary bridge toward Project 6
what concepts must be mastered before implementing SC Decoder N=8
```

At the end of this review, the learner should understand the architectural difference between:

```text
an XOR-based Polar encoder
and
an LLR-based SC decoder
```

---

## 2. Why This Review Is Important

After completing Project 4 and Project 5, it is tempting to immediately move to SC Decoder N=8.

However, this review step is important because the encoder and decoder may appear related but are fundamentally different in hardware complexity.

The Polar Encoder N=8 is mainly:

```text
a regular XOR network
```

The SC Decoder N=4 is:

```text
a decision-dependent LLR-processing architecture
```

The decoder contains:

```text
signed arithmetic
f operation
g operation
hard decision
frozen-mask control
partial-sum logic
bit-order convention
```

If these differences are not clear, later projects such as SC Decoder N=8, scheduled decoder, and resource-shared decoder will be difficult to follow.

The central question of this review is:

```text
What did we learn from comparing a simple Polar Encoder N=8 with a complete SC Decoder N=4?
```

---

## 3. Position In The Roadmap

The roadmap up to this point is:

```text
Project 0: RTL-to-GDSII counter baseline
Project 1.1: signed adder
Project 1.2: signed subtractor
Project 1.3: absolute value unit
Project 1.4: minimum comparator
Project 1.5: absolute-minimum unit
Project 2: SC f unit
Project 3: SC g unit
Project 4: Polar Encoder N=8
Project 5: SC Decoder N=4
Project 5.5: Review and comparison
```

Project 5.5 acts as a consolidation checkpoint.

It prepares the transition to:

```text
Project 6: SC Decoder N=8 baseline
```

---

## 4. Summary Of Project 4: Polar Encoder N=8

Project 4 implemented a Polar Encoder with code length N=8.

The encoder maps:

```text
u[0:7] → x[0:7]
```

using the Polar transform.

The core operation is XOR over GF(2).

The encoder can be implemented as a regular XOR butterfly network.

Important characteristics:

```text
input type: binary bits
output type: binary bits
main operation: XOR
no signed arithmetic
no LLR values
no frozen-mask decision
no hard decision
no f/g operation
no sequential dependency
```

The encoder is structurally regular.

---

## 5. Summary Of Project 5: SC Decoder N=4

Project 5 implemented a complete SC Decoder with code length N=4.

The decoder maps:

```text
LLR[0:3], frozen_mask[0:3] → u_hat[0:3]
```

The decoder uses:

```text
f operation
g operation
hard decision
frozen-mask control
partial sums
```

Confirmed Project 5 simulation result:

```text
Total tests  = 104976
Total errors = 0
ALL TESTS PASSED
```

Confirmed OpenLane clean result:

```text
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing clean at 20 ns
```

Important OpenLane metrics:

```text
Die area = 0.1156 mm²
Synth cell count = 343
Critical path = 10.81 ns
Clock period = 20 ns
```

Project 5 is the first complete decoder milestone in the roadmap.

---

## 6. Main Conceptual Difference

The key difference is:

```text
The encoder transforms known input bits into encoded bits.
The decoder estimates unknown source bits from noisy/reliability information.
```

The encoder input is already known:

```text
u bits are given
```

The decoder input is not the original bits, but reliability values:

```text
LLRs are given
```

The decoder must infer the original bits through a sequence of decisions.

This makes the decoder much more complex.

---

## 7. Data Type Comparison

| Feature | Polar Encoder N=8 | SC Decoder N=4 |
|---|---|---|
| Input data | binary bits u[0:7] | signed LLRs + frozen mask |
| Output data | encoded bits x[0:7] | estimated bits u_hat[0:3] |
| Main value type | 0/1 bits | signed fixed-point LLRs |
| Arithmetic type | GF(2) XOR | signed arithmetic + logic |
| Reliability information | no | yes |
| Frozen bits | not handled | handled |
| Hard decision | no | yes |

The encoder works only with bits.

The decoder works with signed LLRs and must convert reliability information into bit decisions.

---

## 8. Operation Comparison

The Polar Encoder N=8 mainly uses:

```text
XOR operations
```

The SC Decoder N=4 uses:

```text
f operation
g operation
XOR partial sums
hard decision
frozen-bit muxing
```

Comparison:

| Operation | Polar Encoder N=8 | SC Decoder N=4 |
|---|---:|---:|
| XOR | yes | yes, for partial sums |
| signed addition | no | yes, inside g |
| signed subtraction | no | yes, inside g |
| absolute value | no | yes, inside f |
| minimum comparison | no | yes, inside f |
| hard decision | no | yes |
| frozen-mask control | no | yes |

This shows why the decoder is much more complex.

---

## 9. Structural Comparison

### 9.1 Encoder Structure

The encoder is a feed-forward XOR network:

```text
u[0:7]
  ↓
XOR butterfly network
  ↓
x[0:7]
```

It has no decision feedback.

It does not need to wait for previous decisions.

It is regular and parallel.

---

### 9.2 Decoder Structure

The decoder follows a recursive decision tree:

```text
LLR input
  ↓
f operations for left branch
  ↓
hard decisions for left bits
  ↓
partial-sum generation
  ↓
g operations for right branch
  ↓
hard decisions for right bits
  ↓
u_hat output
```

It has decision dependency.

The right branch depends on the left branch decisions.

This is the essence of successive cancellation decoding.

---

## 10. Why The Decoder Is Sequential In Nature

In SC decoding, bits are decoded successively.

For N=4, the sequence is:

```text
decode u0
decode u1
compute partial sums
decode u2
decode u3
```

The g operation for the right branch cannot be computed before the needed previous decision or partial sum is available.

For example:

```text
right0 = g(L0, L2, u0 ^ u1)
right1 = g(L1, L3, u1)
```

This means:

```text
u0 and u1 must be known before right0 and right1 can be computed
```

Therefore, SC decoding has a natural data dependency.

This is why later scheduled and resource-shared architectures become meaningful.

---

## 11. Partial Sums As The Bridge Between Encoder And Decoder

Partial sums are the main conceptual bridge between Polar encoding and SC decoding.

In the encoder, XORs generate encoded bits from source bits.

In the decoder, XORs generate partial sums from already decoded bits.

For N=2:

```text
partial0 = u0 ^ u1
partial1 = u1
```

For N=4, this partial-sum structure appears inside the decoder.

For larger N, partial sums follow the same recursive Polar transform.

Therefore:

```text
Polar encoding explains the XOR structure of partial sums.
SC decoding uses partial sums to compute right-branch g operations.
```

This is why Project 4 is useful before Project 5 and Project 6.

---

## 12. Frozen Mask Comparison

The encoder does not directly care whether a bit is frozen or information.

It only encodes whatever input vector `u` is given.

The decoder must handle frozen bits explicitly.

The convention used in this roadmap is:

```text
frozen_mask[i] = 1 → u_i is frozen and forced to 0
frozen_mask[i] = 0 → u_i is information and decided by hard decision
```

For each bit:

```text
if frozen_mask[i] = 1:
    u_hat[i] = 0
else:
    u_hat[i] = hard_decision(LLR)
```

This frozen-mask logic is one of the reasons the decoder is more complex than the encoder.

---

## 13. Hard Decision Comparison

The encoder has no hard decision.

It receives known bits and transforms them.

The decoder must make hard decisions from LLRs.

The hard-decision rule is:

```text
if LLR < 0:
    u_hat = 1
else:
    u_hat = 0
```

This rule converts signed reliability information into binary decisions.

Hard decision is central to SC decoding but absent from encoding.

---

## 14. Bit Ordering Convention

Both encoder and decoder are sensitive to bit ordering.

For Project 4:

```text
u[0] is the first source bit
x[0] is the first encoded output bit under the selected convention
```

For Project 5:

```text
u_hat[0] = u0
u_hat[1] = u1
u_hat[2] = u2
u_hat[3] = u3
```

The convention must remain consistent across:

```text
RTL
testbench
Python golden model
documentation
future N=8/N=16 decoders
```

Bit-order mismatch is one of the most common sources of decoder bugs.

---

## 15. Verification Comparison

### 15.1 Encoder Verification

For Polar Encoder N=8:

```text
number of possible inputs = 2^8 = 256
```

Exhaustive testing is simple.

The expected output can be computed from XOR equations.

---

### 15.2 Decoder Verification

For SC Decoder N=4, verification is more complex because the input includes:

```text
LLR values
frozen mask
decoder decisions
partial sums
```

Project 5 used a much larger verification set:

```text
Total tests = 104976
```

This reflects the greater complexity of the decoder input space.

---

## 16. Physical Implementation Comparison

The encoder is expected to be physically simpler because it is mostly XOR logic.

The decoder is physically more complex because it includes:

```text
signed f/g datapaths
hard-decision logic
frozen-mask muxes
partial-sum logic
larger routing structure
```

Project 5 confirmed that a complete SC Decoder N=4 can still be implemented cleanly with OpenLane.

This is important because it proves that the roadmap can move from primitive blocks to complete decoder blocks.

---

## 17. Educational Value Of Project 4

Project 4 is useful for teaching:

```text
Polar transform
GF(2) arithmetic
XOR butterfly network
bit-order convention
partial-sum intuition
```

It is a good project for students who are still learning:

```text
combinational logic
Verilog assign statements
exhaustive testbenches
XOR-based datapaths
```

Project 4 is relatively accessible.

---

## 18. Educational Value Of Project 5

Project 5 is more advanced.

It is useful for teaching:

```text
LLR-based decoding
signed arithmetic in hardware
SC f and g operations
hard decision
frozen-mask control
partial sums
decoder scheduling
OpenLane implementation of a complete algorithmic block
```

Project 5 is a major step toward real decoder architecture.

---

## 19. Why Project 5 Is A Milestone

Project 5 is important because it is the first point where the roadmap produces a complete decoder.

Before Project 5, the project had only:

```text
arithmetic primitives
f/g units
encoder logic
```

After Project 5, the roadmap has:

```text
a complete SC Decoder N=4
verified by simulation
implemented through OpenLane
signoff-clean physical result
```

This gives confidence to continue toward N=8.

---

## 20. Main Lessons From The Comparison

The main lessons are:

```text
1. The encoder is regular; the decoder is decision-dependent.
2. The encoder uses XORs; the decoder uses f/g operations and hard decisions.
3. The encoder has no frozen-mask control; the decoder must handle frozen bits.
4. The encoder has no LLR arithmetic; the decoder is built around signed LLRs.
5. Partial sums connect the encoder structure to the decoder structure.
6. SC decoding naturally motivates scheduled and resource-shared hardware.
```

These lessons prepare the roadmap for Project 6.

---

## 21. How This Review Prepares Project 6

Project 6 will implement SC Decoder N=8.

An N=8 decoder can be understood recursively:

```text
1. Compute four top-level f operations.
2. Decode the left N=4 branch.
3. Generate N=4 partial sums.
4. Compute four top-level g operations.
5. Decode the right N=4 branch.
6. Concatenate u_left and u_right.
```

Therefore, Project 5 is directly reused as a conceptual building block.

Project 5.5 makes this connection explicit.

---

## 22. N=8 Decoder Preview

The N=8 decoder is not just a larger N=4 decoder.

It introduces:

```text
more LLR inputs
more f/g operations
larger partial-sum structure
larger frozen mask
larger output vector
more routing
more synthesis complexity
more timing challenge
```

This is why Project 6 must begin with a golden model and careful verification.

The correct sequence should be:

```text
Project 6.1: N=8 golden model
Project 6.2: N=8 RTL baseline
Project 6.3: N=8 Yosys synthesis
Project 6.4: N=8 OpenLane baseline
```

---

## 23. Common Misunderstandings

### Misunderstanding 1: The Decoder Is Just The Inverse Encoder

This is not accurate.

The decoder estimates bits from noisy reliability information.

It is not simply an inverse XOR network.

---

### Misunderstanding 2: If The Encoder Is Easy, The Decoder Is Also Easy

This is not true.

The decoder has:

```text
signed arithmetic
decision dependency
frozen-mask control
partial sums
```

These make it much more complex.

---

### Misunderstanding 3: Partial Sums Are Optional

Partial sums are essential.

Without correct partial sums, the g operation will use wrong decision information.

---

### Misunderstanding 4: Bit Order Does Not Matter

Bit order matters greatly.

Wrong bit-order convention can make a correct algorithm appear wrong.

---

### Misunderstanding 5: Simulation Passing Means The Design Is Physically Clean

Project 5 showed that physical implementation also requires checking:

```text
DRC
LVS
Antenna
Timing
```

Simulation and physical signoff are different stages.

---

## 24. Summary Table

| Aspect | Polar Encoder N=8 | SC Decoder N=4 |
|---|---|---|
| Project | Project 4 | Project 5 |
| Main purpose | Encode bits | Decode bits from LLRs |
| Input | u[0:7] | LLR[0:3] + frozen_mask |
| Output | x[0:7] | u_hat[0:3] |
| Main operation | XOR | f/g + hard decision |
| Data type | binary | signed LLR + binary decisions |
| Partial sums | implicit | explicit |
| Frozen mask | no | yes |
| Verification size | 256 input cases | 104976 tests |
| Physical flow | optional/baseline | OpenLane clean achieved |
| Main role | understand Polar transform | first complete decoder |

---

## 25. Role Of This Review In The Full Roadmap

Project 5.5 belongs to the consolidation layer of the roadmap.

It is not a new RTL implementation project.

Its role is to:

```text
connect encoder and decoder knowledge
summarize lessons from Project 4 and Project 5
prepare the transition to SC Decoder N=8
reduce conceptual confusion before larger designs
```

The roadmap after this review is:

```text
Project 6.1: SC Decoder N=8 golden model
Project 6.2: SC Decoder N=8 RTL baseline
Project 6.3: SC Decoder N=8 synthesis study
Project 6.4: SC Decoder N=8 OpenLane baseline
```

---

## 26. What This Project Is Not

Project 5.5 is not a new design implementation.

It should not be presented as:

```text
a new decoder architecture
a new encoder design
a standalone publication result
```

Instead, it should be presented as:

```text
a review milestone
a learning checkpoint
a documentation bridge between encoder/decoder basics and N=8 decoder design
```

---

## 27. Conclusion

Project 5.5 reviews and compares Polar Encoder N=8 and SC Decoder N=4.

The most important conclusion is:

```text
The Polar encoder is a regular XOR-based transform, while the SC decoder is a decision-dependent LLR-processing architecture.
```

Project 4 helps learners understand XOR-based Polar transforms and partial-sum structure.

Project 5 demonstrates the first complete SC decoder, including f/g operations, hard decisions, frozen-mask handling, and OpenLane clean physical implementation.

This review prepares the roadmap for Project 6: SC Decoder N=8.