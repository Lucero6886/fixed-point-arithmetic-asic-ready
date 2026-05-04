# Project 7.4: Yosys Comparison Of Three SC Decoder N=8 Architectures

## 1. Project Objective

Project 7.4 compares three SC Decoder N=8 architectures using Yosys synthesis results:

```text
1. Combinational SC Decoder N=8
2. Scheduled / Multi-Cycle SC Decoder N=8
3. Resource-Shared Scheduled SC Decoder N=8
```

The main objective is to quantify how architecture choices affect synthesized hardware complexity.

This project answers the question:

```text
Which N=8 SC decoder architecture is the most hardware-efficient at the synthesis level?
```

The key result is:

```text
The resource-shared scheduled N=8 decoder has the lowest total cell count and the lowest estimated combinational cell count among the three architectures.
```

---

## 2. Why This Project Is Important

Project 6.4 showed that the combinational N=8 decoder can be implemented cleanly through OpenLane, but it required a relaxed clock period.

Project 7.1 showed that a scheduled N=8 decoder can be functionally correct.

Project 7.2 showed that scheduling alone can increase logic complexity.

Project 7.3 introduced an explicitly resource-shared scheduled architecture.

Project 7.4 now compares all three architectures quantitatively.

This comparison is important because it provides evidence for the central design lesson:

```text
Scheduling alone is not enough.
Explicit resource sharing is needed to reduce duplicated hardware.
```

---

## 3. Position In The Roadmap

The roadmap around Project 7 is:

```text
Project 6.4: Combinational N=8 OpenLane clean baseline
Project 7.1: Scheduled / multi-cycle N=8 RTL baseline
Project 7.2: Yosys comparison of combinational vs scheduled N=8
Project 7.3: Resource-shared scheduled N=8 RTL
Project 7.4: Yosys comparison of three N=8 architectures
Project 7.5: OpenLane implementation of resource-shared N=8
Project 7.6: Timing push for resource-shared N=8
```

Project 7.4 is the synthesis-level architecture comparison milestone.

---

## 4. Architectures Compared

### 4.1 Combinational N=8

The combinational decoder computes the full SC decoding result in one combinational path.

Characteristics:

```text
no FSM
no start/done protocol
no internal operation schedule
low cycle latency
long combinational path
duplicated f/g logic
```

This is the baseline from Project 6.

---

### 4.2 Scheduled N=8

The scheduled decoder executes the SC decoding process over multiple cycles using an FSM.

Characteristics:

```text
FSM controller
start/busy/done handshake
internal registers
multi-cycle operation
not necessarily resource-shared
higher control overhead
```

This is the baseline scheduled architecture from Project 7.1.

Project 7.2 showed that this design can be larger than the combinational baseline.

---

### 4.3 Resource-Shared N=8

The resource-shared decoder also uses an FSM, but it explicitly reuses a shared f/g datapath.

Characteristics:

```text
FSM controller
start/busy/done handshake
shared f/g datapath
operand selection
writeback control
multi-cycle operation
lower duplicated combinational logic
```

This is the architecture introduced in Project 7.3.

---

## 5. Core Hypothesis

The expected architecture trend is:

```text
Combinational N=8:
    simple but large combinational datapath

Scheduled N=8:
    multi-cycle but may add control/register overhead

Resource-shared N=8:
    multi-cycle and explicitly reduces duplicated datapath logic
```

Therefore, the hypothesis is:

```text
The resource-shared architecture should reduce combinational logic compared with both the combinational and naive scheduled architectures.
```

Project 7.4 tests this hypothesis using Yosys synthesis metrics.

---

## 6. Input Files

Typical input files for this project include:

```text
rtl/sc_decoder_n8.v
rtl/sc_decoder_n8_scheduled.v
rtl/sc_decoder_n8_shared.v

synth/sc_decoder_n8_flat.ys
synth/sc_decoder_n8_scheduled.ys
synth/sc_decoder_n8_shared.ys

scripts/compare_sc_decoder_n8_three_arch_yosys.py
```

The actual repository may use slightly different script names.

The essential requirement is that all three designs are synthesized with comparable Yosys settings.

---

## 7. Output Files

The generated output files were:

```text
results/summary/sc_decoder_n8_three_arch_yosys_comparison.csv
results/summary/sc_decoder_n8_three_arch_yosys_comparison.md
```

The comparison includes:

```text
wires
wire bits
total cells
DFF/DFFE metric
estimated combinational cells
MUX count
XOR/XNOR count
NAND count
cell breakdown
relative ratios
```

---

## 8. Yosys Comparison Methodology

The comparison uses Yosys synthesis results to estimate relative hardware complexity.

Important metrics:

```text
Number of wires
Number of wire bits
Total cell count
Sequential-cell metric
Estimated combinational cell count
MUX count
XOR/XNOR count
NAND count
```

The goal is not to obtain final routed area.

The goal is to compare architecture-level logic complexity before physical implementation.

Physical implementation is handled later in Project 7.5.

---

## 9. Summary Table

The generated summary table was:

| Design | Wires | Wire bits | Total cells | DFF/DFFE | Est. comb cells | MUX | XOR/XNOR | NAND |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| combinational_n8 | 1760 | 3279 | 1475 | 0 | 1475 | 101 | 194 | 443 |
| scheduled_n8 | 2449 | 3931 | 2527 | 355 | 2172 | 124 | 233 | 840 |
| resource_shared_n8 | 826 | 1282 | 967 | 397 | 570 | 20 | 24 | 309 |

This is the central result of Project 7.4.

---

## 10. Ratios Relative To Combinational Baseline

The generated ratio table was:

| Design | Total cells ratio | Est. comb cells ratio | MUX ratio | DFF/DFFE cells |
|---|---:|---:|---:|---:|
| combinational_n8 | 1.00× | 1.00× | 1.00× | 0 |
| scheduled_n8 | 1.71× | 1.47× | 1.23× | 355 |
| resource_shared_n8 | 0.66× | 0.39× | 0.20× | 397 |

The most important result is:

```text
resource_shared_n8 total cells ratio = 0.66×
resource_shared_n8 estimated combinational cells ratio = 0.39×
resource_shared_n8 MUX ratio = 0.20×
```

This means the resource-shared architecture uses much less combinational logic than the combinational baseline.

---

## 11. Main Result

The total cell counts are:

```text
combinational_n8      = 1475 cells
scheduled_n8          = 2527 cells
resource_shared_n8    = 967 cells
```

The resource-shared design reduces total cell count compared with the combinational baseline:

```text
967 / 1475 ≈ 0.66×
```

This corresponds to about:

```text
34% lower total cell count
```

relative to the combinational baseline.

Compared with the scheduled decoder:

```text
967 / 2527 ≈ 0.38×
```

This corresponds to about:

```text
62% lower total cell count
```

relative to the naive scheduled design.

---

## 12. Estimated Combinational Cell Result

The estimated combinational cell counts are:

```text
combinational_n8      = 1475
scheduled_n8          = 2172
resource_shared_n8    = 570
```

The resource-shared architecture reduces estimated combinational logic to:

```text
570 / 1475 ≈ 0.39×
```

This means:

```text
about 61% lower estimated combinational cell count
```

relative to the combinational baseline.

This is the strongest synthesis-level evidence supporting explicit resource sharing.

---

## 13. MUX Count Result

MUX counts are:

```text
combinational_n8      = 101
scheduled_n8          = 124
resource_shared_n8    = 20
```

The resource-shared architecture reduces MUX count to:

```text
20 / 101 ≈ 0.20×
```

This means:

```text
about 80% lower MUX count
```

relative to the combinational baseline.

This result is important because MUX logic is often associated with selection, routing, and control complexity.

---

## 14. XOR/XNOR Count Result

XOR/XNOR counts are:

```text
combinational_n8      = 194
scheduled_n8          = 233
resource_shared_n8    = 24
```

The resource-shared architecture dramatically reduces XOR/XNOR logic.

This reduction is expected because a shared datapath avoids duplicating many arithmetic and partial-sum related logic structures.

However, this result should be interpreted at the synthesis level.

Later physical implementation still needs OpenLane confirmation.

---

## 15. NAND Count Result

NAND counts are:

```text
combinational_n8      = 443
scheduled_n8          = 840
resource_shared_n8    = 309
```

The scheduled decoder has the largest NAND count.

This reflects its high control and datapath overhead.

The resource-shared decoder reduces NAND count compared with both other designs.

This confirms that resource sharing reduces duplicated combinational logic.

---

## 16. Wire And Wire-Bit Comparison

Wire counts:

```text
combinational_n8      = 1760
scheduled_n8          = 2449
resource_shared_n8    = 826
```

Wire-bit counts:

```text
combinational_n8      = 3279
scheduled_n8          = 3931
resource_shared_n8    = 1282
```

The resource-shared architecture significantly reduces internal wiring complexity.

This is important because lower wire count may help physical implementation by reducing routing pressure.

However, actual routing must still be confirmed by OpenLane.

---

## 17. Sequential Logic Comparison

The DFF/DFFE metric in the generated summary is:

```text
combinational_n8      = 0
scheduled_n8          = 355
resource_shared_n8    = 397
```

This shows that the scheduled and resource-shared designs require sequential storage.

This is expected because multi-cycle architectures need registers to store intermediate states.

The resource-shared design has more sequential storage than the scheduled design under this metric, but it greatly reduces estimated combinational logic.

This is the classic trade-off:

```text
more registers
less duplicated combinational logic
more cycles
better area/timing potential
```

---

## 18. Important Note On DFF/DFFE Counting

The generated summary table reports a DFF/DFFE metric.

The raw Yosys cell breakdown should also be preserved because the script-derived DFF/DFFE metric may not be identical to simply summing the raw DFF/DFFE rows.

For example, the scheduled design raw sequential cell rows are:

```text
$_DFFE_PN0N_ = 40
$_DFFE_PN0P_ = 137
$_DFF_PN0_   = 1
```

The raw instance sum is:

```text
40 + 137 + 1 = 178
```

But the generated summary table reports:

```text
DFF/DFFE = 355
```

Similarly, the resource-shared design raw sequential cell rows are:

```text
$_DFFE_PN0N_ = 89
$_DFFE_PN0P_ = 109
$_DFF_PN0_   = 1
```

The raw instance sum is:

```text
89 + 109 + 1 = 199
```

But the generated summary table reports:

```text
DFF/DFFE = 397
```

Therefore, when writing a formal report, clearly specify the counting convention.

Recommended practice:

```text
Use the generated table for project-level comparison.
Also preserve the raw Yosys cell breakdown for reproducibility.
```

---

## 19. Raw Cell Breakdown: Combinational N=8

The raw cell breakdown for the combinational N=8 decoder is:

| Cell type | Count |
|---|---:|
| $_ANDNOT_ | 87 |
| $_AND_ | 236 |
| $_MUX_ | 101 |
| $_NAND_ | 443 |
| $_NOR_ | 43 |
| $_NOT_ | 12 |
| $_ORNOT_ | 212 |
| $_OR_ | 147 |
| $_XNOR_ | 133 |
| $_XOR_ | 61 |

Important observations:

```text
No DFF/DFFE cells are present.
This is a pure combinational baseline.
```

---

## 20. Raw Cell Breakdown: Scheduled N=8

The raw cell breakdown for the scheduled N=8 decoder is:

| Cell type | Count |
|---|---:|
| $_ANDNOT_ | 112 |
| $_AND_ | 409 |
| $_DFFE_PN0N_ | 40 |
| $_DFFE_PN0P_ | 137 |
| $_DFF_PN0_ | 1 |
| $_MUX_ | 124 |
| $_NAND_ | 840 |
| $_NOR_ | 41 |
| $_NOT_ | 15 |
| $_ORNOT_ | 377 |
| $_OR_ | 198 |
| $_XNOR_ | 130 |
| $_XOR_ | 103 |

Important observations:

```text
The scheduled design introduces sequential cells.
The scheduled design has the largest total cell count.
The scheduled design has the largest NAND count.
The scheduled design does not reduce combinational logic enough.
```

---

## 21. Raw Cell Breakdown: Resource-Shared N=8

The raw cell breakdown for the resource-shared N=8 decoder is:

| Cell type | Count |
|---|---:|
| $_ANDNOT_ | 33 |
| $_AND_ | 259 |
| $_DFFE_PN0N_ | 89 |
| $_DFFE_PN0P_ | 109 |
| $_DFF_PN0_ | 1 |
| $_MUX_ | 20 |
| $_NAND_ | 309 |
| $_NOR_ | 22 |
| $_NOT_ | 12 |
| $_ORNOT_ | 46 |
| $_OR_ | 43 |
| $_XNOR_ | 13 |
| $_XOR_ | 11 |

Important observations:

```text
The resource-shared design has far fewer MUX, XOR, XNOR, OR, and ORNOT cells.
It has sequential storage because it is multi-cycle.
It greatly reduces duplicated combinational datapath logic.
```

---

## 22. Why Scheduled N=8 Is Larger Than Combinational N=8

The scheduled decoder is larger because it adds:

```text
FSM state registers
busy/done control
LLR registers
intermediate registers
state-dependent write enables
control muxes
enable logic
```

But it does not sufficiently share the computation datapath.

Therefore, the design pays the cost of multi-cycle control without fully gaining the benefit of datapath reuse.

This is why Project 7.2 concluded:

```text
Scheduling alone does not guarantee area reduction.
```

Project 7.4 confirms this result in the three-way comparison.

---

## 23. Why Resource-Shared N=8 Is Smaller

The resource-shared decoder is smaller because it explicitly reuses the same f/g datapath.

Instead of generating many independent f/g operations, it uses:

```text
one shared datapath
operand selection
writeback control
FSM schedule
```

This reduces:

```text
duplicated arithmetic logic
duplicated sign/magnitude logic
duplicated g-operation logic
duplicated mux structures
internal wiring
```

The result is lower total cell count and much lower estimated combinational logic.

---

## 24. Area-Latency Trade-Off

The resource-shared design is not free.

It trades:

```text
lower logic complexity
```

for:

```text
more cycles
more sequential control
more internal registers
```

This is the classic area-latency trade-off.

Comparison:

| Architecture | Area trend | Latency trend | Main advantage | Main limitation |
|---|---|---|---|---|
| Combinational | medium/high | lowest cycle count | simple | long critical path |
| Scheduled | highest in this version | multi-cycle | shows FSM schedule | high overhead |
| Resource-shared | lowest logic count | multi-cycle | lower duplicated logic | higher latency |

---

## 25. Why This Result Matters For Scalability

For larger code lengths such as:

```text
N=16
N=32
N=64
```

duplicating the full SC decoding tree becomes increasingly expensive.

The resource-shared architecture suggests a more scalable design direction:

```text
store intermediate values
schedule f/g operations
reuse a common datapath
control operation order with FSM or generated schedule
```

This is the conceptual foundation for future schedule-generated scalable SC decoder architectures.

---

## 26. Research-Level Interpretation

At this stage, the result is a strong educational and architecture-exploration result.

However, it is not yet a complete research contribution by itself.

To become a stronger research contribution, future work should show:

```text
scalability to N=16 or larger
automatic schedule generation
latency/throughput analysis
OpenLane or FPGA implementation comparison
area/timing/power trade-off
comparison with meaningful baselines
```

Project 7.4 is an important step because it identifies the best N=8 architecture among the three tested designs.

---

## 27. Connection To Project 7.5

Project 7.4 shows that the resource-shared decoder is best at the Yosys synthesis level.

The next question is:

```text
Does the resource-shared decoder also perform well in physical implementation?
```

Project 7.5 answers this by running OpenLane for:

```text
sc_decoder_n8_shared_top
```

Project 7.5 should check:

```text
GDSII generation
DRC
LVS
antenna
clock period
critical path
die area
synth cell count
routing complexity
```

---

## 28. Connection To Project 7.6

After Project 7.5 establishes a clean OpenLane implementation, Project 7.6 pushes timing.

The goal is to determine whether the resource-shared architecture can run faster than the combinational N=8 baseline.

The key comparison will be:

```text
Combinational N=8:
    clean at 80 ns

Resource-shared N=8:
    expected to close at much smaller clock period
```

This timing comparison is one of the strongest practical results of the architecture exploration.

---

## 29. Suggested Commands

Run Yosys for the three designs:

```bash
yosys -s synth/sc_decoder_n8_flat.ys | tee synth/reports/sc_decoder_n8_flat_yosys.log
yosys -s synth/sc_decoder_n8_scheduled.ys | tee synth/reports/sc_decoder_n8_scheduled_yosys.log
yosys -s synth/sc_decoder_n8_shared.ys | tee synth/reports/sc_decoder_n8_shared_yosys.log
```

Then generate the comparison:

```bash
python3 scripts/compare_sc_decoder_n8_three_arch_yosys.py
```

If the script name is different, use the actual repository script.

Expected outputs:

```text
results/summary/sc_decoder_n8_three_arch_yosys_comparison.csv
results/summary/sc_decoder_n8_three_arch_yosys_comparison.md
```

---

## 30. Validation Checklist

Project 7.4 is complete if:

```text
Yosys reports exist for all three architectures
comparison CSV exists
comparison Markdown exists
summary table is recorded
ratio table is recorded
raw cell breakdowns are preserved
resource-shared design is shown to have lowest total cells
resource-shared design is shown to have lowest estimated combinational cells
the meaning of DFF/DFFE metric is documented
the next step to OpenLane is clearly stated
```

Recommended checks:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

ls -lh results/summary/sc_decoder_n8_three_arch_yosys_comparison.csv
ls -lh results/summary/sc_decoder_n8_three_arch_yosys_comparison.md

cat results/summary/sc_decoder_n8_three_arch_yosys_comparison.md
```

---

## 31. Common Problems And Debugging

### Problem 1: Comparing Non-Equivalent Reports

Make sure all designs are synthesized using comparable settings.

Avoid comparing:

```text
flattened combinational report
against
hierarchical scheduled report
```

The comparison must be fair.

---

### Problem 2: Wrong Top Module

Correct top modules should be:

```text
sc_decoder_n8
sc_decoder_n8_scheduled
sc_decoder_n8_shared
```

or their actual repository names.

---

### Problem 3: Misinterpreting DFF/DFFE Metric

The generated DFF/DFFE metric may be script-derived.

Always preserve the raw Yosys cell breakdown.

For formal writing, specify the exact counting method.

---

### Problem 4: Treating Yosys Cell Count As Physical Area

Yosys cell count is not final physical area.

Physical area must be checked with OpenLane.

Use Project 7.4 for synthesis-level comparison.

Use Project 7.5 and Project 7.6 for physical implementation conclusions.

---

### Problem 5: Ignoring Latency

The resource-shared design reduces logic but increases cycle latency.

A fair architectural comparison should eventually include:

```text
cell count
critical path
clock period
latency cycles
throughput
area-latency product
```

Project 7.4 focuses only on synthesis-level complexity.

---

## 32. Lessons Learned

Project 7.4 teaches the following key lessons:

```text
1. Architecture choice strongly affects synthesized hardware complexity.
2. The naive scheduled decoder is larger than the combinational baseline.
3. Explicit resource sharing significantly reduces total cell count.
4. The resource-shared design has the lowest estimated combinational cell count.
5. The resource-shared design trades more sequential storage and latency for lower combinational logic.
6. Yosys comparison is useful for early architecture evaluation.
7. Physical validation still requires OpenLane.
8. This result motivates Project 7.5 and Project 7.6.
```

---

## 33. Role Of This Project In The Full Roadmap

Project 7.4 is the synthesis-level architecture comparison milestone.

The roadmap progression is:

```text
Project 7.1:
    scheduled RTL baseline

Project 7.2:
    scheduled design shown to be larger than combinational baseline

Project 7.3:
    explicit resource-shared RTL design

Project 7.4:
    three-architecture Yosys comparison

Project 7.5:
    OpenLane implementation of resource-shared design

Project 7.6:
    timing push for resource-shared design
```

Project 7.4 provides the quantitative synthesis evidence that the resource-shared architecture is the best current direction.

---

## 34. What This Project Is Not

Project 7.4 is not a physical implementation result.

It should not be presented as:

```text
final GDSII comparison
routed area comparison
post-layout timing comparison
power comparison
```

Instead, it should be presented as:

```text
synthesis-level architecture comparison
evidence for resource sharing
preparation for OpenLane implementation
```

---

## 35. Conclusion

Project 7.4 compares three SC Decoder N=8 architectures using Yosys synthesis metrics.

The key results are:

```text
Combinational N=8:
    total cells = 1475
    estimated combinational cells = 1475
    MUX = 101

Scheduled N=8:
    total cells = 2527
    estimated combinational cells = 2172
    MUX = 124

Resource-shared N=8:
    total cells = 967
    estimated combinational cells = 570
    MUX = 20
```

The main conclusion is:

```text
The resource-shared scheduled architecture is the best synthesis-level architecture among the three tested N=8 decoders.
```

It reduces total cell count to:

```text
0.66× of the combinational baseline
```

and estimated combinational cell count to:

```text
0.39× of the combinational baseline
```

This confirms the main architectural lesson:

```text
Scheduling alone is not enough; explicit resource sharing is required.
```

The next step is Project 7.5:

```text
OpenLane implementation of the resource-shared SC Decoder N=8.
```