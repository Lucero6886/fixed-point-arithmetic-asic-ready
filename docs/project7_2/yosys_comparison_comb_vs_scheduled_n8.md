# Project 7.2: Yosys Comparison — Combinational N=8 vs Scheduled N=8

## 1. Project Objective

Project 7.2 compares two RTL architectures of the SC Decoder N=8 using Yosys synthesis reports:

```text
1. Combinational SC Decoder N=8
2. Scheduled / Multi-Cycle SC Decoder N=8
```

The main objective is to determine whether converting the decoder from a one-cycle combinational architecture into a multi-cycle scheduled architecture automatically reduces logic complexity.

The key question is:

```text
Does scheduling the SC Decoder N=8 over multiple cycles reduce synthesized cell count?
```

The answer from this project is:

```text
No. Scheduling alone does not automatically reduce area or cell count.
```

This project is important because it reveals a critical architectural lesson:

```text
A scheduled FSM design is not necessarily a resource-shared design.
```

---

## 2. Why This Project Is Important

Project 6 implemented the combinational SC Decoder N=8 baseline.

Project 7.1 implemented the scheduled / multi-cycle SC Decoder N=8 and verified that it passed 1000 golden vectors.

At this point, both architectures are functionally correct.

However, functional correctness alone is not enough. We must compare their hardware cost.

This project answers:

```text
Which architecture uses more synthesized logic?
How much control/register overhead does the scheduled design introduce?
Does a multi-cycle FSM automatically reduce combinational logic?
Why do we still need an explicitly resource-shared architecture?
```

The result of this project directly motivates Project 7.3:

```text
Resource-Shared Scheduled SC Decoder N=8
```

---

## 3. Position In The Roadmap

The roadmap around Project 7 is:

```text
Project 6.4: Combinational N=8 OpenLane clean baseline
Project 7.1: Scheduled / multi-cycle N=8 RTL baseline
Project 7.2: Yosys comparison of combinational vs scheduled N=8
Project 7.3: Resource-shared scheduled N=8 RTL
Project 7.4: Yosys comparison of three architectures
Project 7.5: OpenLane implementation of resource-shared N=8
Project 7.6: Timing push for resource-shared N=8
```

Project 7.2 is the first architecture comparison point.

---

## 4. Architectures Compared

### 4.1 Combinational SC Decoder N=8

The combinational decoder computes the full SC decoding result in one combinational core.

It performs:

```text
top-level f operations
left N=4 decoding
partial-sum generation
top-level g operations
right N=4 decoding
u_hat output generation
```

The design is simple to understand and easy to verify, but it creates a long combinational path.

This design was verified in Project 6.2 and physically implemented in Project 6.4.

---

### 4.2 Scheduled SC Decoder N=8

The scheduled decoder performs the SC decoding operation over multiple cycles using:

```text
FSM controller
internal registers
intermediate LLR storage
partial-sum storage
start/busy/done handshake
```

This design was verified in Project 7.1.

It passed:

```text
1000 golden vectors
0 errors
ALL TESTS PASSED
```

However, Project 7.2 investigates whether this scheduled form is smaller than the combinational baseline.

---

## 5. Important Conceptual Distinction

The most important concept in this project is:

```text
Scheduling is not the same as resource sharing.
```

A scheduled decoder means:

```text
The algorithm is divided into multiple time steps.
```

A resource-shared decoder means:

```text
The same hardware datapath is reused for multiple operations.
```

A design can be scheduled but still contain duplicated logic.

Therefore:

```text
Project 7.1 = scheduled RTL baseline
Project 7.3 = explicitly resource-shared scheduled RTL
```

Project 7.2 proves why this distinction matters.

---

## 6. Input Files

Typical input files for Project 7.2 are:

```text
rtl/sc_decoder_n8.v
rtl/sc_decoder_n8_scheduled.v

synth/sc_decoder_n8_flat.ys
synth/sc_decoder_n8_scheduled.ys

scripts/extract_yosys_summary.py
scripts/compare_n8_comb_vs_scheduled_yosys.py
```

The actual repository may use slightly different script names.

The essential requirement is that both designs must be synthesized with comparable Yosys settings.

---

## 7. Output Files

Expected output files include:

```text
synth/reports/sc_decoder_n8_flat_yosys.log
synth/reports/sc_decoder_n8_scheduled_yosys.log

results/summary/sc_decoder_n8_comb_vs_scheduled_yosys_comparison.csv
results/summary/sc_decoder_n8_comb_vs_scheduled_yosys_comparison.md
```

The key output is a comparison table showing:

```text
wire count
wire-bit count
total cell count
DFF/DFFE count
estimated combinational cell count
MUX count
XOR/XNOR count
NAND count
```

---

## 8. Yosys Synthesis Methodology

Both designs should be synthesized using Yosys.

For a fair comparison, the same synthesis style should be used as much as possible.

Recommended flow:

```text
read Verilog files
set top module
process RTL
optimize
flatten if needed
technology map
ABC mapping
optimize
print statistics
```

The combinational design should be synthesized as:

```text
top = sc_decoder_n8
```

The scheduled design should be synthesized as:

```text
top = sc_decoder_n8_scheduled
```

---

## 9. Why Flattened Comparison Matters

For the combinational decoder, Project 6.3 already showed that hierarchical reporting may hide submodule complexity.

Therefore, the comparison should focus on flattened or fully mapped results.

If the report only shows submodule instances, the result is not suitable for total complexity comparison.

A good comparison should answer:

```text
How many primitive logic cells are actually inferred?
How many sequential cells are added by the scheduled design?
How much combinational logic remains?
```

---

## 10. Combinational N=8 Yosys Result

The flattened Yosys result for the combinational N=8 decoder was:

```text
=== sc_decoder_n8 ===

Number of wires:               1760
Number of wire bits:           3279
Number of public wires:         293
Number of public wire bits:    1812
Number of memories:               0
Number of memory bits:            0
Number of processes:              0
Number of cells:               1475

  $_ANDNOT_                      87
  $_AND_                        236
  $_MUX_                        101
  $_NAND_                       443
  $_NOR_                         43
  $_NOT_                         12
  $_ORNOT_                      212
  $_OR_                         147
  $_XNOR_                       133
  $_XOR_                         61
```

This is the reference combinational baseline.

---

## 11. Scheduled N=8 Yosys Result

The Yosys result for the scheduled N=8 decoder was:

```text
=== sc_decoder_n8_scheduled ===

Cell type breakdown:

  $_ANDNOT_                      112
  $_AND_                         409
  $_DFFE_PN0N_                    40
  $_DFFE_PN0P_                   137
  $_DFF_PN0_                       1
  $_MUX_                         124
  $_NAND_                        840
  $_NOR_                          41
  $_NOT_                          15
  $_ORNOT_                       377
  $_OR_                          198
  $_XNOR_                        130
  $_XOR_                         103
```

The total cell count is:

```text
2527 cells
```

The raw sequential-cell entries are:

```text
$_DFFE_PN0N_ = 40
$_DFFE_PN0P_ = 137
$_DFF_PN0_   = 1
```

Raw sequential cell instances:

```text
40 + 137 + 1 = 178
```

Depending on the summary script convention, DFF/DFFE may also be reported differently. The raw Yosys cell breakdown above should be kept as the source of truth.

---

## 12. Main Comparison Table

| Metric | Combinational N=8 | Scheduled N=8 |
|---|---:|---:|
| Total cells | 1475 | 2527 |
| MUX cells | 101 | 124 |
| NAND cells | 443 | 840 |
| XOR cells | 61 | 103 |
| XNOR cells | 133 | 130 |
| XOR + XNOR | 194 | 233 |
| Raw DFF/DFFE cells | 0 | 178 |

The scheduled design uses significantly more total cells than the combinational baseline.

Total-cell ratio:

```text
2527 / 1475 ≈ 1.71×
```

Therefore:

```text
The scheduled N=8 design is about 71% larger in total Yosys cell count than the combinational N=8 baseline.
```

---

## 13. Why Scheduled N=8 Has More Cells

The scheduled decoder introduces additional hardware that does not exist in the combinational decoder.

This includes:

```text
FSM state registers
busy and done control registers
input LLR registers
intermediate LLR registers
partial-sum registers
u_hat registers
enable logic
next-state logic
state-dependent muxing
```

Therefore, even though the computation is divided over time, the RTL may still infer substantial logic.

If f/g operations are written separately in multiple states, the synthesis tool may not automatically share them.

This is why scheduled RTL can become larger than the combinational baseline.

---

## 14. Control Overhead

The scheduled decoder needs a controller.

The controller includes:

```text
state register
next-state logic
start detection
busy control
done control
state-dependent operation selection
```

This control logic contributes to:

```text
AND/OR/NAND logic
MUX logic
DFF/DFFE cells
```

The combinational decoder does not need this control structure.

---

## 15. Register Overhead

The scheduled decoder stores intermediate values across cycles.

Typical registers include:

```text
LLR input registers
left LLR registers
right LLR registers
decoded-bit registers
partial-sum registers
state registers
control registers
```

This explains the presence of:

```text
$_DFFE_PN0N_
$_DFFE_PN0P_
$_DFF_PN0_
```

in the scheduled design.

The combinational decoder core has no such sequential cells.

---

## 16. MUX Overhead

The MUX count increases from:

```text
Combinational N=8: 101
Scheduled N=8: 124
```

This increase is expected because scheduled RTL often contains state-dependent assignments.

For example:

```text
in state S1, write register A
in state S2, write register B
in state S3, update u_hat
```

Such conditional update behavior often synthesizes into mux and enable logic.

---

## 17. NAND Logic Increase

The NAND count increases from:

```text
Combinational N=8: 443
Scheduled N=8: 840
```

This is a large increase.

NAND cells are commonly used after optimization for general combinational logic.

The increase reflects:

```text
control logic
enable logic
state transition logic
duplicated arithmetic/control logic
register update conditions
```

This confirms that scheduling alone introduces significant overhead.

---

## 18. XOR/XNOR Comparison

The combined XOR/XNOR count is:

```text
Combinational N=8: 61 + 133 = 194
Scheduled N=8: 103 + 130 = 233
```

This indicates that the scheduled design still contains substantial arithmetic and parity/partial-sum logic.

The increase is not as dramatic as NAND, but it still shows that scheduling did not reduce the f/g-related logic automatically.

---

## 19. Estimated Combinational Logic

If raw sequential cells are subtracted from the scheduled total:

```text
scheduled estimated combinational cells
= 2527 - 178
= 2349
```

This is still larger than the combinational baseline:

```text
2349 > 1475
```

So even after removing raw DFF/DFFE cells, the scheduled design still has more combinational support logic.

This is a key result.

It means the scheduled design is not larger only because of registers; it also has more combinational control and mux logic.

---

## 20. Note On DFF/DFFE Counting Convention

Some generated summaries may report the DFF/DFFE field using a script-specific convention.

For example, a summary table may report a DFF/DFFE value different from the raw count of DFF/DFFE cell entries.

The raw Yosys breakdown for the scheduled design is:

```text
$_DFFE_PN0N_ = 40
$_DFFE_PN0P_ = 137
$_DFF_PN0_   = 1
```

The raw instance count is:

```text
178
```

When writing academic reports, clearly state which convention is used:

```text
raw sequential cell entries
or
script-derived DFF/DFFE metric
```

For reproducibility, always keep the raw Yosys cell breakdown.

---

## 21. Key Result

The key result of Project 7.2 is:

```text
Combinational N=8 total cells = 1475
Scheduled N=8 total cells     = 2527
```

Therefore:

```text
Scheduled N=8 uses approximately 1.71× more total cells than combinational N=8.
```

This result is initially counterintuitive, because one may expect a multi-cycle design to be smaller.

But the result is reasonable because the scheduled design has not yet explicitly shared a single f/g datapath.

---

## 22. Main Interpretation

The scheduled decoder is functionally correct but not area-efficient.

The reason is:

```text
The design is scheduled in time,
but the hardware resources are not sufficiently shared.
```

The FSM adds:

```text
registers
control logic
muxes
enable logic
```

If the RTL still contains many independent arithmetic expressions, the synthesis tool may generate many logic blocks.

Therefore:

```text
A scheduled architecture must be intentionally designed for resource sharing.
```

This is the main lesson of Project 7.2.

---

## 23. Why Synthesis Tool Does Not Automatically Share Everything

A common misconception is:

```text
If operations occur in different FSM states, synthesis will automatically reuse the same hardware.
```

This is not always true.

Synthesis tools infer hardware from RTL structure.

If the RTL describes different expressions or independent assignments in different states, the tool may generate separate logic and then mux the results.

To force resource sharing, the RTL should explicitly describe a shared datapath, for example:

```text
shared input muxes
one f/g arithmetic block
one output writeback path
state-controlled operand selection
```

This is exactly the motivation for Project 7.3.

---

## 24. Architectural Lesson

The main architectural lesson is:

```text
Multi-cycle scheduling is a control strategy.
Resource sharing is a datapath strategy.
```

A good area-efficient architecture usually needs both:

```text
scheduled control
explicitly shared datapath
```

Project 7.1 introduced scheduled control.

Project 7.3 introduces explicit resource sharing.

---

## 25. Educational Value Of Project 7.2

Project 7.2 is valuable because it prevents a common misunderstanding.

A learner may think:

```text
I converted the design to FSM, so it must be smaller.
```

But this project shows:

```text
FSM scheduling can increase cell count if the datapath is not shared.
```

This is a very important digital design lesson.

It applies not only to SC decoders but also to:

```text
filters
FFT blocks
cryptographic cores
neural network accelerators
matrix processors
control datapaths
```

---

## 26. Comparison With Project 6.4 Physical Baseline

Project 6.4 showed that the combinational N=8 baseline is OpenLane clean but timing-relaxed:

```text
Clock period = 80 ns
Die area = 0.64 mm²
Critical path = 29.01 ns
```

Project 7.2 does not yet provide OpenLane metrics for the scheduled design.

It only provides Yosys logic comparison.

Therefore, Project 7.2 should not claim physical area or timing improvement.

It only shows:

```text
scheduled RTL has higher synthesized cell count than combinational RTL
```

under the current implementation.

---

## 27. Why Project 7.3 Is Needed

Because Project 7.2 shows that the scheduled design is larger, the next step is not to abandon scheduling.

The next step is to improve the scheduled architecture by explicitly sharing resources.

Project 7.3 should introduce:

```text
one shared f/g datapath
operand selection logic
writeback registers
FSM-controlled operation sequence
```

Instead of duplicating f/g logic across states, the decoder should reuse a common computation unit.

Expected benefit:

```text
lower combinational logic
lower MUX count
clearer datapath/control separation
better area/timing trade-off
```

---

## 28. Suggested Commands

Run Yosys for the combinational design:

```bash
yosys -s synth/sc_decoder_n8_flat.ys | tee synth/reports/sc_decoder_n8_flat_yosys.log
```

Run Yosys for the scheduled design:

```bash
yosys -s synth/sc_decoder_n8_scheduled.ys | tee synth/reports/sc_decoder_n8_scheduled_yosys.log
```

If a script exists:

```bash
./synth/run_sc_decoder_n8_yosys.sh
```

or:

```bash
./synth/run_sc_decoder_n8_scheduled_yosys.sh
```

Then inspect:

```bash
grep -A30 "=== sc_decoder_n8 ===" synth/reports/sc_decoder_n8_flat_yosys.log
grep -A40 "=== sc_decoder_n8_scheduled ===" synth/reports/sc_decoder_n8_scheduled_yosys.log
```

---

## 29. Suggested Summary Extraction

A Python script can parse the Yosys logs and generate comparison tables.

Suggested output files:

```text
results/summary/sc_decoder_n8_comb_vs_scheduled_yosys_comparison.csv
results/summary/sc_decoder_n8_comb_vs_scheduled_yosys_comparison.md
```

The Markdown report should include:

```text
summary table
cell breakdown
ratio analysis
interpretation
```

---

## 30. Validation Checklist

Project 7.2 is complete if:

```text
combinational N=8 Yosys report exists
scheduled N=8 Yosys report exists
total cell counts are extracted
cell breakdowns are documented
combinational vs scheduled ratio is computed
the reason for scheduled overhead is explained
the distinction between scheduling and resource sharing is documented
Project 7.3 motivation is clearly stated
```

Recommended checks:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

ls -lh synth/reports/sc_decoder_n8_flat_yosys.log
ls -lh synth/reports/sc_decoder_n8_scheduled_yosys.log

grep -A30 "=== sc_decoder_n8 ===" synth/reports/sc_decoder_n8_flat_yosys.log
grep -A40 "=== sc_decoder_n8_scheduled ===" synth/reports/sc_decoder_n8_scheduled_yosys.log
```

---

## 31. Common Problems And Debugging

### Problem 1: Scheduled Design Appears Smaller Because Submodules Are Not Flattened

If the scheduled report only shows high-level module instances, the comparison is not fair.

Fix:

```text
Use comparable flattened/mapped synthesis for both architectures.
```

---

### Problem 2: Wrong Top Module

Make sure Yosys uses:

```text
sc_decoder_n8
```

for the combinational design and:

```text
sc_decoder_n8_scheduled
```

for the scheduled design.

---

### Problem 3: Missing Source Files

If the scheduled RTL depends on helper modules, include all required RTL files in the Yosys script.

---

### Problem 4: Misinterpreting DFF/DFFE Count

Always check the raw Yosys cell breakdown.

If a script-derived summary reports a different DFF/DFFE number, document the counting convention.

---

### Problem 5: Claiming Physical Improvement From Yosys Only

Project 7.2 is a synthesis-level comparison.

It should not claim physical area or routed timing improvement.

Physical implementation requires OpenLane.

---

## 32. Lessons Learned

Project 7.2 teaches the following key lessons:

```text
1. Functional correctness does not imply hardware efficiency.
2. A scheduled decoder can be larger than a combinational decoder.
3. FSM control introduces register, mux, and enable overhead.
4. Scheduling alone is not resource sharing.
5. Resource sharing must be expressed explicitly in the datapath.
6. Yosys comparison is useful for early architectural evaluation.
7. The result motivates the resource-shared design in Project 7.3.
```

---

## 33. Role Of This Project In The Full Roadmap

Project 7.2 is the first architecture comparison in the N=8 exploration phase.

The roadmap progression is:

```text
Project 6.4: combinational N=8 OpenLane baseline
Project 7.1: scheduled N=8 RTL baseline
Project 7.2: combinational vs scheduled Yosys comparison
Project 7.3: resource-shared scheduled N=8 RTL
Project 7.4: three-architecture Yosys comparison
Project 7.5: resource-shared N=8 OpenLane implementation
Project 7.6: timing push for resource-shared N=8
```

Project 7.2 provides the evidence that Project 7.3 is necessary.

---

## 34. What This Project Is Not

Project 7.2 is not a new RTL design.

It should not be presented as:

```text
a new decoder architecture
a physical implementation result
a final optimized design
```

Instead, it should be presented as:

```text
a synthesis-level architecture comparison
a diagnostic study
a motivation for explicit resource sharing
```

---

## 35. Conclusion

Project 7.2 compares the combinational SC Decoder N=8 and the scheduled SC Decoder N=8 using Yosys synthesis results.

The key result is:

```text
Combinational N=8 total cells = 1475
Scheduled N=8 total cells     = 2527
Scheduled / combinational ratio ≈ 1.71×
```

Although the scheduled decoder is functionally correct, it uses more synthesized logic than the combinational baseline.

The main conclusion is:

```text
Scheduling alone does not guarantee area reduction.
```

The next step is Project 7.3:

```text
Resource-Shared Scheduled SC Decoder N=8
```

where the hardware datapath is explicitly shared across scheduled f/g operations.