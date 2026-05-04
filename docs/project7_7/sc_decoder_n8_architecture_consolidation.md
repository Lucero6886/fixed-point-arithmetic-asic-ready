# Project 7.7: SC Decoder N=8 Architecture Consolidation

## 1. Project Objective

Project 7.7 consolidates the complete N=8 SC Polar decoder architecture exploration.

This document focuses only on the N=8 decoder architecture path, especially the comparison among:

```text
1. Combinational SC Decoder N=8
2. Scheduled / Multi-Cycle SC Decoder N=8
3. Resource-Shared Scheduled SC Decoder N=8
```

The objective is to produce a single architecture-level consolidation report after completing Projects 6.1–7.6.

This document answers:

```text
1. What N=8 architectures were designed?
2. Which architecture is functionally correct?
3. Which architecture is better at Yosys synthesis level?
4. Which architecture is better at OpenLane physical implementation level?
5. What is the main architecture lesson?
6. What limitations remain before moving to N=16?
```

This project is not a new RTL implementation.

It is a focused architecture-consolidation report.

---

## 2. Why Project 7.7 Is Needed

The N=8 decoder work has produced many intermediate reports:

```text
Project 6.1: golden model
Project 6.2: combinational RTL baseline
Project 6.3: synthesis study
Project 6.4: OpenLane baseline
Project 7.1: scheduled RTL
Project 7.2: combinational vs scheduled comparison
Project 7.3: resource-shared RTL
Project 7.4: three-architecture Yosys comparison
Project 7.5: resource-shared OpenLane implementation
Project 7.6: resource-shared timing push
```

Each report captures one step.

Project 7.7 consolidates them into one architecture-level understanding.

Without Project 7.7, the roadmap contains many results but no single document that explains:

```text
why the resource-shared architecture is currently the best N=8 direction
why scheduled design alone was not enough
why OpenLane results support the Yosys conclusion
what should be done before scaling to N=16
```

---

## 3. Position In The Roadmap

Project 7.7 comes after:

```text
Project 7.6: Timing Push For Resource-Shared SC Decoder N=8
```

and before:

```text
Project 8.1: SC Decoder N=16 Golden Model And Schedule Analysis
```

The roadmap position is:

```text
Project 6:
    Build and validate combinational SC Decoder N=8 baseline.

Project 7:
    Explore scheduled and resource-shared architectures for N=8.

Project 7.7:
    Consolidate N=8 architecture lessons.

Project 8:
    Extend toward N=16 using a more systematic schedule-analysis approach.
```

---

## 4. Scope Of This Consolidation

This document covers:

```text
SC Decoder N=8 golden model
Combinational N=8 RTL baseline
Combinational N=8 Yosys and OpenLane results
Scheduled N=8 RTL baseline
Scheduled N=8 Yosys result
Resource-shared N=8 RTL
Three-architecture Yosys comparison
Resource-shared N=8 OpenLane implementation
Resource-shared N=8 timing push
Architecture lessons and limitations
```

This document does not cover primitive projects in detail.

Those are already reviewed in the Master Review.

---

## 5. Key Technical Conventions

The N=8 decoder architecture uses the following conventions.

### 5.1 LLR Width

```text
W = 6
```

Signed LLR range:

```text
-32 to 31
```

Many intermediate outputs use:

```text
W+1 = 7 bits
```

because f/g operations may produce larger magnitudes.

### 5.2 Hard Decision

```text
LLR < 0  → decoded bit = 1
LLR >= 0 → decoded bit = 0
```

### 5.3 Frozen Mask

```text
frozen_mask[i] = 1 → frozen bit, force u_i = 0
frozen_mask[i] = 0 → information bit, use hard decision
```

### 5.4 Bit Ordering

```text
u_hat[0] = u0
u_hat[1] = u1
...
u_hat[7] = u7
```

Integer packing is LSB-first:

```text
u_hat_int = u0*2^0 + u1*2^1 + ... + u7*2^7
```

### 5.5 SC f Function

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

### 5.6 SC g Function

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

The subtraction order is:

```text
b - a
```

not:

```text
a - b
```

---

## 6. N=8 SC Decoding Schedule

The N=8 decoder follows the recursive SC decoding structure.

Given input LLRs:

```text
L0, L1, L2, L3, L4, L5, L6, L7
```

the top-level schedule is:

```text
1. Compute left LLRs:
   left0 = f(L0, L4)
   left1 = f(L1, L5)
   left2 = f(L2, L6)
   left3 = f(L3, L7)

2. Decode left N=4 branch:
   u0, u1, u2, u3

3. Generate partial sums:
   p0 = u0 ^ u1 ^ u2 ^ u3
   p1 = u1 ^ u3
   p2 = u2 ^ u3
   p3 = u3

4. Compute right LLRs:
   right0 = g(L0, L4, p0)
   right1 = g(L1, L5, p1)
   right2 = g(L2, L6, p2)
   right3 = g(L3, L7, p3)

5. Decode right N=4 branch:
   u4, u5, u6, u7

6. Output:
   u_hat[0:7]
```

This same schedule must be respected by all three N=8 architectures.

---

## 7. Architecture 1: Combinational SC Decoder N=8

The first N=8 architecture is the combinational baseline.

It computes the entire N=8 SC decoding result in one large combinational core.

### 7.1 Main Characteristics

```text
No FSM
No start/done protocol
No internal multi-cycle schedule
No explicit resource sharing
Full decoding tree computed combinationally
Low cycle latency
Long critical path
```

### 7.2 Strengths

```text
simple to understand
simple to verify against golden vectors
useful as a correctness baseline
useful as a physical implementation baseline
```

### 7.3 Weaknesses

```text
long combinational path
larger die area
poor timing scalability
not suitable for larger N without architectural improvement
```

---

## 8. Combinational N=8 Verification Result

The combinational RTL was verified against Python-generated golden vectors.

Final simulation result:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED
```

This confirms that the combinational N=8 RTL matches the Python golden model for the tested vector set.

---

## 9. Combinational N=8 Yosys Result

The flattened Yosys result for the combinational N=8 decoder was:

```text
Number of wires:      1760
Number of wire bits:  3279
Total cells:          1475
MUX cells:            101
XOR/XNOR cells:       194
NAND cells:           443
DFF/DFFE cells:       0
```

Interpretation:

```text
The combinational baseline has no sequential storage but uses a large amount of combinational logic.
```

---

## 10. Combinational N=8 OpenLane Result

The final clean OpenLane run for the combinational N=8 baseline was:

```text
RUN_2026.05.03_12.25.25
```

Main metrics:

```text
Design: sc_decoder_n8_top
CLOCK_PERIOD = 80 ns
DIEAREA_mm^2 = 0.64
synth_cell_count = 1361
critical_path_ns = 29.01
wire_length = 80198
vias = 13546
Magic DRC violations = 0
LVS = clean
Pin antenna violations = 0
Net antenna violations = 0
GDSII = generated
```

Interpretation:

```text
The combinational N=8 baseline is physically feasible, but it requires a relaxed 80 ns clock constraint.
```

---

## 11. Architecture 2: Scheduled / Multi-Cycle SC Decoder N=8

The second architecture is the scheduled decoder.

It executes the SC decoding process over multiple cycles using an FSM.

### 11.1 Main Characteristics

```text
FSM controller
start/busy/done handshake
internal registers
multi-cycle operation
same SC decoding schedule
not necessarily resource-shared
```

### 11.2 Strengths

```text
introduces sequential SC decoding control
prepares the design for resource sharing
supports start/done verification style
closer to practical sequential decoder thinking
```

### 11.3 Weaknesses

```text
adds FSM overhead
adds registers
adds mux/control logic
does not automatically reduce duplicated f/g logic
can be larger than the combinational baseline
```

---

## 12. Scheduled N=8 Verification Result

The first version of the scheduled testbench failed because it checked output before respecting the multi-cycle done protocol.

Initial result:

```text
Total errors = 1000
TEST FAILED
```

After correcting the testbench to wait for `done`, the scheduled decoder passed:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED
```

This confirms that the scheduled N=8 RTL is functionally correct.

---

## 13. Scheduled N=8 Yosys Result

The Yosys result for the scheduled decoder was:

```text
Total cells:          2527
Estimated comb cells: 2172
MUX cells:            124
XOR/XNOR cells:       233
NAND cells:           840
DFF/DFFE metric:      355
```

Raw sequential cell rows included:

```text
$_DFFE_PN0N_ = 40
$_DFFE_PN0P_ = 137
$_DFF_PN0_   = 1
```

Interpretation:

```text
The scheduled decoder is functionally correct but larger than the combinational decoder at synthesis level.
```

---

## 14. Main Lesson From Scheduled N=8

The key lesson is:

```text
Scheduling alone is not resource sharing.
```

A scheduled decoder means:

```text
operations are distributed across cycles
```

A resource-shared decoder means:

```text
the same datapath hardware is reused across those cycles
```

The scheduled decoder added control and registers, but it did not sufficiently reduce duplicated datapath logic.

Therefore, it became larger than the combinational baseline.

---

## 15. Architecture 3: Resource-Shared Scheduled SC Decoder N=8

The third architecture is the resource-shared scheduled decoder.

This is currently the best N=8 architecture in the roadmap.

### 15.1 Main Characteristics

```text
FSM controller
start/busy/done handshake
internal registers
shared f/g datapath
operand-selection logic
writeback control
multi-cycle operation
```

### 15.2 Main Idea

Instead of building many f/g operation blocks, the decoder uses one shared datapath:

```text
if mode = f:
    fu_y = f(fu_a, fu_b)

if mode = g:
    fu_y = g(fu_a, fu_b, fu_g_bit)
```

The FSM selects operands and destinations across cycles.

### 15.3 Strengths

```text
reduces duplicated combinational logic
reduces Yosys total cell count
reduces OpenLane die area
shortens critical path
closes timing at tighter clock constraint
```

### 15.4 Weaknesses

```text
multi-cycle latency
more complex FSM control
requires careful operand selection
requires careful writeback control
latency/throughput must be measured separately
```

---

## 16. Resource-Shared N=8 Verification Status

The resource-shared RTL is part of the Project 7 architecture path and is used for Yosys and OpenLane comparison.

The architecture is expected to be verified against the same golden-vector flow:

```text
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

The expected passing result is:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED
```

If the exact final resource-shared simulation log is available, it should be pasted into the Project 7.3 document.

For architecture consolidation, the important point is:

```text
the resource-shared design is treated as the verified architecture used in Projects 7.4–7.6.
```

---

## 17. Resource-Shared N=8 Yosys Result

The Yosys result for the resource-shared decoder was:

```text
Wires:                826
Wire bits:            1282
Total cells:          967
DFF/DFFE metric:      397
Estimated comb cells: 570
MUX cells:            20
XOR/XNOR cells:       24
NAND cells:           309
```

Interpretation:

```text
The resource-shared design significantly reduces duplicated combinational logic.
```

---

## 18. Three-Architecture Yosys Comparison

The main Project 7.4 comparison table is:

| Design | Wires | Wire bits | Total cells | DFF/DFFE | Est. comb cells | MUX | XOR/XNOR | NAND |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| combinational_n8 | 1760 | 3279 | 1475 | 0 | 1475 | 101 | 194 | 443 |
| scheduled_n8 | 2449 | 3931 | 2527 | 355 | 2172 | 124 | 233 | 840 |
| resource_shared_n8 | 826 | 1282 | 967 | 397 | 570 | 20 | 24 | 309 |

The main conclusion is:

```text
The resource-shared architecture has the lowest total cells and the lowest estimated combinational cells.
```

---

## 19. Ratios Relative To Combinational Baseline

| Design | Total cells ratio | Est. comb cells ratio | MUX ratio | DFF/DFFE cells |
|---|---:|---:|---:|---:|
| combinational_n8 | 1.00× | 1.00× | 1.00× | 0 |
| scheduled_n8 | 1.71× | 1.47× | 1.23× | 355 |
| resource_shared_n8 | 0.66× | 0.39× | 0.20× | 397 |

Interpretation:

```text
The resource-shared decoder reduces total cell count to 0.66× of the combinational baseline.
It reduces estimated combinational cells to 0.39×.
It reduces MUX count to 0.20×.
```

This is strong synthesis-level evidence for explicit resource sharing.

---

## 20. Why Scheduled N=8 Was Larger

The scheduled decoder introduced:

```text
FSM state logic
start/busy/done control
intermediate registers
enable logic
state-dependent mux logic
```

but did not explicitly force one shared f/g datapath.

As a result:

```text
it paid the cost of scheduling
without fully gaining the benefit of resource sharing
```

This is the key reason it became larger than the combinational baseline.

---

## 21. Why Resource-Shared N=8 Was Smaller

The resource-shared decoder explicitly reuses a shared f/g datapath.

This reduces:

```text
duplicated arithmetic logic
duplicated sign/magnitude logic
duplicated g-operation logic
duplicated partial muxing
internal wiring complexity
```

The cost is:

```text
more cycles
more control sequencing
register storage
```

This is a classic area-latency trade-off.

---

## 22. Resource-Shared N=8 OpenLane Result At 30 ns

Project 7.5 implemented the resource-shared decoder through OpenLane.

Final clean run:

```text
RUN_2026.05.03_13.42.04
```

Main metrics:

```text
Design: sc_decoder_n8_shared_top
CLOCK_PERIOD = 30 ns
DIEAREA_mm^2 = 0.36
synth_cell_count = 1045
critical_path_ns = 8.83
wire_length = 70267
vias = 11718
Magic DRC violations = 0
LVS = clean
Pin antenna violations = 0
Net antenna violations = 0
GDSII = generated
```

Interpretation:

```text
The resource-shared architecture is physically implementable and already better than the combinational baseline at 30 ns.
```

---

## 23. Resource-Shared N=8 Timing Push At 15 ns

Project 7.6 pushed the same resource-shared design to a tighter 15 ns clock constraint.

Final clean run:

```text
RUN_2026.05.03_15.45.12
```

Main metrics:

```text
Design: sc_decoder_n8_shared_top
CLOCK_PERIOD = 15 ns
DIEAREA_mm^2 = 0.36
synth_cell_count = 1045
critical_path_ns = 8.62
wire_length = 70864
vias = 11705
Magic DRC violations = 0
LVS = clean
Pin antenna violations = 0
Net antenna violations = 0
GDSII = generated
```

Interpretation:

```text
The resource-shared architecture remains physically clean under a much tighter timing constraint.
```

---

## 24. Physical Comparison: Combinational Vs Resource-Shared

| Metric | Combinational N=8 | Resource-Shared N=8 Timing Push |
|---|---:|---:|
| Project | 6.4 | 7.6 |
| Clean run | RUN_2026.05.03_12.25.25 | RUN_2026.05.03_15.45.12 |
| Clock period | 80 ns | 15 ns |
| Suggested frequency | 12.5 MHz | 66.666 MHz |
| Die area | 0.64 mm² | 0.36 mm² |
| Synth cell count | 1361 | 1045 |
| Wire length | 80198 | 70864 |
| Vias | 13546 | 11705 |
| Critical path | 29.01 ns | 8.62 ns |
| Magic DRC | 0 | 0 |
| LVS | clean | clean |
| Pin antenna | 0 | 0 |
| Net antenna | 0 | 0 |

This is the strongest physical comparison in the N=8 roadmap.

---

## 25. Area Improvement

The die area improves from:

```text
0.64 mm²
```

to:

```text
0.36 mm²
```

Area ratio:

```text
0.36 / 0.64 = 0.5625
```

Therefore, the resource-shared design uses:

```text
56.25% of the combinational baseline area
```

or:

```text
43.75% lower die area
```

---

## 26. Critical Path Improvement

The critical path improves from:

```text
29.01 ns
```

to:

```text
8.62 ns
```

Critical path ratio:

```text
8.62 / 29.01 ≈ 0.297
```

Therefore, the resource-shared design has approximately:

```text
70.3% shorter critical path
```

than the combinational baseline.

---

## 27. Clock Constraint Improvement

The clean clock constraint improves from:

```text
80 ns
```

to:

```text
15 ns
```

Constraint ratio:

```text
80 / 15 ≈ 5.33×
```

Correct interpretation:

```text
The resource-shared design closes timing under a 5.33× tighter clock constraint.
```

Important limitation:

```text
This does not directly mean 5.33× higher throughput,
because the resource-shared decoder is multi-cycle.
```

---

## 28. Synth Cell Count Improvement

OpenLane synth cell count improves from:

```text
1361
```

to:

```text
1045
```

Cell-count ratio:

```text
1045 / 1361 ≈ 0.768
```

Therefore, the resource-shared design uses approximately:

```text
23.2% fewer OpenLane synthesized cells
```

than the combinational baseline.

---

## 29. Routing Improvement

Wire length improves from:

```text
80198
```

to:

```text
70864
```

Via count improves from:

```text
13546
```

to:

```text
11705
```

This suggests that resource sharing also reduces physical routing burden.

This is consistent with the reduction in duplicated logic and internal wiring.

---

## 30. Correct Academic Interpretation

The correct academic interpretation is:

```text
The resource-shared scheduled SC Decoder N=8 provides a better area/timing trade-off than the one-cycle combinational baseline.
```

More specifically:

```text
It reduces die area.
It reduces synthesized cell count.
It shortens the critical path.
It closes under a much tighter clock constraint.
It preserves DRC/LVS/antenna-clean physical signoff.
```

But the limitation is:

```text
It requires multiple cycles per decoded vector.
```

Therefore, the accurate conclusion is not simply:

```text
Resource-shared is faster.
```

The accurate conclusion is:

```text
Resource-shared is more timing-friendly and area-efficient, but latency-aware throughput analysis is still required.
```

---

## 31. Missing Metric: Latency Cycles

The most important missing metric is:

```text
latency_cycles
```

For the resource-shared decoder, latency should be measured from:

```text
start assertion
```

to:

```text
done assertion
```

Then effective decode time is:

```text
decode_time_ns = latency_cycles × clock_period_ns
```

For example:

```text
If latency_cycles = 28
and clock_period = 15 ns

decode_time = 28 × 15 ns = 420 ns
```

The actual latency must be measured from the RTL/testbench.

---

## 32. Recommended Latency Metrics

Future reports should include:

```text
latency_cycles
clock_period_ns
decode_time_ns
throughput_vectors_per_second
area_delay_product
area_latency_product
```

Possible formulas:

```text
decode_time_ns = latency_cycles × clock_period_ns

throughput = 1 / decode_time_seconds

area_delay = die_area × critical_path

area_latency = die_area × decode_time
```

These metrics will make the architecture comparison more complete.

---

## 33. What Project 7.7 Concludes

Project 7.7 concludes that the current best N=8 architecture is:

```text
resource-shared scheduled SC Decoder N=8
```

because it achieves:

```text
lowest Yosys total cell count among the three architectures
lowest estimated combinational cell count
successful OpenLane implementation
smaller die area than combinational baseline
shorter critical path than combinational baseline
clean timing at 15 ns
clean DRC/LVS/antenna signoff
```

The key architecture lesson is:

```text
Scheduling alone is insufficient.
Explicit datapath resource sharing is necessary to obtain area/timing benefits.
```

---

## 34. What Project 7.7 Does Not Claim

This consolidation does not claim that the N=8 result is a complete final research contribution.

It does not claim:

```text
full scalability to large N
best-known Polar decoder performance
highest throughput
complete power optimization
complete journal-ready architecture
```

The current result is best understood as:

```text
a strong N=8 proof-of-concept
a validated architecture exploration
a foundation for N=16/N=32 scalable design
```

---

## 35. Research Value Of The Current N=8 Work

The current work has research value because it demonstrates a complete open-source hardware exploration path:

```text
Python golden model
golden-vector verification
RTL baseline
scheduled RTL
resource-shared RTL
Yosys comparison
OpenLane implementation
timing push
architecture trade-off interpretation
```

This is valuable for:

```text
training students
building a reproducible research platform
preparing an ASIC-ready decoder architecture
developing a conference paper
supporting future PhD research
```

However, for a strong journal-level contribution, N=8 alone is not enough.

---

## 36. What Is Needed For Stronger Publication

To strengthen this into a publishable architecture contribution, future work should add:

```text
1. N=16 and N=32 scaling.
2. Automatic schedule generation.
3. Operation-count analysis.
4. Latency-cycle analysis.
5. Area/timing/throughput trade-off.
6. FPGA validation or comparison.
7. OpenLane physical results for larger N.
8. Comparison against baseline decoder architectures.
9. Optional power or energy estimation under consistent activity.
```

The most important next step is:

```text
N=16 golden model and schedule analysis.
```

---

## 37. Why N=16 Should Start With Schedule Analysis

Going directly to N=16 RTL is risky.

N=16 has:

```text
more f operations
more g operations
more partial sums
more intermediate LLRs
more decoded bits
more schedule states
more writeback destinations
higher chance of bit-order errors
```

Therefore, Project 8.1 should start with:

```text
golden model
operation schedule
partial-sum analysis
resource-sharing plan
latency estimate
```

not immediate RTL coding.

---

## 38. Recommended Next Step

The next project should be:

```text
Project 8.1: SC Decoder N=16 Golden Model And Schedule Analysis
```

Recommended file:

```text
docs/project8_1/sc_decoder_n16_golden_model_and_schedule_analysis.md
```

Project 8.1 should include:

```text
N=16 recursive SC schedule
operation count
partial-sum mapping
golden vector generation
resource-shared scheduling plan
latency estimate
state/register requirement
risk analysis before RTL
```

---

## 39. Final Architecture Summary

The N=8 architecture exploration can be summarized as:

```text
Combinational N=8:
    correct and physically clean,
    but area is larger and timing is relaxed.

Scheduled N=8:
    correct,
    but larger than combinational due to FSM/control/register overhead.

Resource-shared N=8:
    correct architecture direction,
    lower synthesis complexity,
    smaller physical area,
    shorter critical path,
    clean OpenLane timing at 15 ns.
```

The main architectural conclusion is:

```text
Explicit resource sharing is the key improvement.
```

---

## 40. Validation Checklist Before Moving To Project 8.1

Before starting Project 8.1, check:

```text
1. All Project 7 docs are committed.
2. Resource-shared RTL is committed.
3. Golden vectors are available.
4. Yosys comparison files are available.
5. OpenLane metrics are documented.
6. Project 7.7 is committed.
7. Git tree is clean.
```

Recommended commands:

```bash
git status

find docs/project7_1 docs/project7_2 docs/project7_3 docs/project7_4 docs/project7_5 docs/project7_6 docs/project7_7 -type f | sort

find results/summary -type f | sort

git log --oneline --decorate -n 15
```

Expected Git status:

```text
nothing to commit, working tree clean
```

---

## 41. Suggested Commit Tag

After committing Project 7.7, it may be useful to create a tag such as:

```bash
git tag -a v7.7-n8-architecture-consolidated -m "project7.7: consolidate SC decoder N8 architecture exploration"
git push origin v7.7-n8-architecture-consolidated
```

This tag marks the end of the N=8 architecture exploration phase.

---

## 42. Project 7.7 Conclusion

Project 7.7 consolidates the full N=8 SC decoder architecture exploration.

The strongest result is the resource-shared scheduled SC Decoder N=8:

```text
OpenLane clean at 15 ns
DIEAREA = 0.36 mm²
synth_cell_count = 1045
critical_path = 8.62 ns
DRC = 0
LVS clean
Antenna = 0
```

Compared with the combinational N=8 baseline:

```text
die area decreases from 0.64 mm² to 0.36 mm²
critical path decreases from 29.01 ns to 8.62 ns
clock constraint improves from 80 ns to 15 ns
synth cell count decreases from 1361 to 1045
```

The main conclusion is:

```text
For SC Decoder N=8, explicit resource sharing provides a better area/timing trade-off than both the one-cycle combinational baseline and the naive scheduled baseline.
```

The main limitation is:

```text
multi-cycle latency must be measured and included before making throughput claims.
```

The next step is:

```text
Project 8.1: SC Decoder N=16 Golden Model And Schedule Analysis.
```