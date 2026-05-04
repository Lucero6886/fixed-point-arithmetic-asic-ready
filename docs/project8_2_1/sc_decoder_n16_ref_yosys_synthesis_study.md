# Project 8.2.1: Yosys Synthesis Study For SC Decoder N=16 Reference RTL

## 1. Project Objective

Project 8.2.1 performs Yosys synthesis for the SC Decoder N=16 reference RTL baseline.

The target RTL file is:

```text
rtl/sc_decoder_n16_ref.v
```

The top module is:

```text
sc_decoder_n16_ref
```

The main objective is to obtain a synthesis-level complexity baseline for the functionally verified N=16 reference decoder.

Project 8.2 verified that the N=16 reference RTL matches the Python golden model using:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

Project 8.2.1 now answers the next question:

```text
How large is the SC Decoder N=16 reference RTL after flattened Yosys synthesis?
```

This project is not yet an optimized architecture project.

It is a synthesis-baseline project.

---

## 2. Why Project 8.2.1 Is Important

Functional verification proves that the RTL produces the correct decoded output.

However, functional correctness alone does not tell us:

```text
how many logic cells are required
how many wires are generated
which cell types dominate the design
how much larger N=16 is compared with N=8
whether the reference RTL is purely combinational
how useful the reference RTL is as a baseline for resource sharing
```

Project 8.2.1 is important because it converts the verified N=16 RTL into measurable synthesis metrics.

These metrics will later be used to compare against:

```text
Project 8.3:
    Resource-shared scheduled SC Decoder N=16

Project 8.4:
    N=16 architecture comparison using Yosys and OpenLane
```

Without Project 8.2.1, future resource-shared results would lack a fair reference baseline.

---

## 3. Position In The Roadmap

The roadmap around Project 8 is:

```text
Project 8.1:
    SC Decoder N=16 golden model and schedule analysis.

Project 8.2:
    SC Decoder N=16 reference RTL baseline.

Project 8.2.1:
    Yosys synthesis study for SC Decoder N=16 reference RTL.

Project 8.3:
    Resource-shared scheduled SC Decoder N=16.

Project 8.4:
    N=16 architecture comparison and physical implementation study.
```

Project 8.2.1 is the synthesis-level bridge between the reference RTL and future optimized architecture.

---

## 4. What Project 8.2.1 Is Not

Project 8.2.1 is not:

```text
a new RTL design
a resource-shared decoder
an OpenLane physical implementation
a timing-closure study
a final optimized architecture
```

Project 8.2.1 is:

```text
a Yosys synthesis characterization of the N=16 reference RTL
```

The result should be interpreted as a baseline, not as the final architecture.

---

## 5. Input Files

The main input files are:

```text
rtl/sc_decoder_n16_ref.v
synth/sc_decoder_n16_ref_flat.ys
synth/run_sc_decoder_n16_ref_yosys.sh
scripts/extract_sc_decoder_n16_ref_yosys_summary.py
```

The RTL was verified in Project 8.2 against:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

Therefore, Project 8.2.1 assumes the RTL is already functionally correct.

---

## 6. Output Files

The expected output files are:

```text
synth/reports/sc_decoder_n16_ref_flat_yosys.log
results/summary/sc_decoder_n16_ref_yosys_summary.csv
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

The full Yosys log is stored in:

```text
synth/reports/sc_decoder_n16_ref_flat_yosys.log
```

The extracted summary files are:

```text
results/summary/sc_decoder_n16_ref_yosys_summary.csv
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

These summary files should be committed because they are compact and useful for later comparison.

---

## 7. Yosys Script

The synthesis script is:

```text
synth/sc_decoder_n16_ref_flat.ys
```

The intended Yosys flow is:

```tcl
read_verilog -sv rtl/sc_decoder_n16_ref.v

hierarchy -check -top sc_decoder_n16_ref

proc
opt
flatten
opt

techmap
opt

abc
opt
clean

stat
```

The key command is:

```text
flatten
```

Flattening is required because `sc_decoder_n16_ref.v` contains internal hierarchical reference modules such as:

```text
sc_dec_ref_n8
sc_dec_ref_n4
sc_dec_ref_n2
```

A hierarchical report would hide the full logic complexity inside these submodules.

A flattened report exposes the primitive-level logic count.

---

## 8. Why Flattened Synthesis Is Used

The N=16 reference RTL is structurally hierarchical.

It is built from smaller recursive decoder blocks:

```text
N=16 top
→ N=8 left decoder
→ N=8 right decoder
→ N=4 sub-decoders
→ N=2 leaf decoders
```

If Yosys reports only module instances, the result is not a fair total-complexity estimate.

Flattened synthesis answers:

```text
How many primitive logic cells are actually inferred after expanding the full reference decoder?
```

Therefore, flattened synthesis is the correct approach for this baseline study.

---

## 9. Yosys Methodology

The synthesis flow is:

```text
1. Read Verilog RTL.
2. Check hierarchy and top module.
3. Convert processes.
4. Optimize RTL.
5. Flatten hierarchy.
6. Technology map.
7. Optimize again.
8. Run ABC mapping.
9. Clean unused logic.
10. Print statistics.
```

The purpose is not to obtain final physical area.

The purpose is to obtain a synthesis-level logic baseline.

---

## 10. How To Run

Use:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

./synth/run_sc_decoder_n16_ref_yosys.sh
```

This script should:

```text
1. Run Yosys.
2. Save the full Yosys log.
3. Parse the Yosys statistics block.
4. Generate CSV summary.
5. Generate Markdown summary.
6. Print the summary to terminal.
```

---

## 11. Expected Successful Run

A successful run should generate:

```text
synth/reports/sc_decoder_n16_ref_flat_yosys.log
results/summary/sc_decoder_n16_ref_yosys_summary.csv
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

The script should finish without Yosys errors.

The expected terminal message should include:

```text
[OK] Parsed synth/reports/sc_decoder_n16_ref_flat_yosys.log
[OK] Wrote results/summary/sc_decoder_n16_ref_yosys_summary.csv
[OK] Wrote results/summary/sc_decoder_n16_ref_yosys_summary.md
```

---

## 12. Metrics To Extract

The most important metrics are:

```text
number of wires
number of wire bits
number of public wires
number of public wire bits
number of memories
number of memory bits
number of processes
number of total cells
raw DFF/DFFE cell count
estimated combinational cell count
MUX cell count
XOR cell count
XNOR cell count
XOR + XNOR cell count
NAND cell count
```

These metrics are useful because they allow future comparison with the resource-shared N=16 architecture.

---

## 13. Main Metrics Table

After running Yosys, the generated file should contain a table like this:

```text
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

The key table should include:

| Metric | Value |
|---|---:|
| Design | sc_decoder_n16_ref |
| Wires | To Be Filled From Yosys |
| Wire bits | To Be Filled From Yosys |
| Public wires | To Be Filled From Yosys |
| Public wire bits | To Be Filled From Yosys |
| Memories | To Be Filled From Yosys |
| Memory bits | To Be Filled From Yosys |
| Processes | To Be Filled From Yosys |
| Total cells | To Be Filled From Yosys |
| Raw DFF/DFFE cells | To Be Filled From Yosys |
| Estimated combinational cells | To Be Filled From Yosys |
| MUX cells | To Be Filled From Yosys |
| XOR cells | To Be Filled From Yosys |
| XNOR cells | To Be Filled From Yosys |
| XOR + XNOR cells | To Be Filled From Yosys |
| NAND cells | To Be Filled From Yosys |

The actual values should come from:

```text
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

This document should be updated later if exact numeric values need to be embedded directly into the Project 8.2.1 report.

---

## 14. Important Interpretation Of DFF/DFFE Cells

The SC Decoder N=16 reference RTL is intended to be combinational.

Therefore, the expected raw DFF/DFFE count should be:

```text
0
```

If DFF/DFFE cells appear, it may indicate:

```text
unintended sequential logic
incorrect coding style
unexpected inferred registers
incomplete assignments
```

For this reference RTL, a clean result should show:

```text
Raw DFF/DFFE cells = 0
```

and:

```text
Estimated combinational cells = Total cells
```

This confirms that the reference baseline is purely combinational.

---

## 15. Expected Complexity Trend

The N=16 reference decoder is expected to be significantly larger than the N=8 reference decoder.

Project 7.4 reported for combinational N=8:

```text
Total cells = 1475
Wires = 1760
Wire bits = 3279
MUX cells = 101
XOR/XNOR cells = 194
NAND cells = 443
```

The N=16 reference decoder should be larger because it contains:

```text
two N=8 decoding branches
top-level f operations
top-level g operations
larger partial-sum network
larger frozen-mask logic
larger internal LLR network
wider internal arithmetic
```

Therefore, a large increase in total cells is expected.

This is not a failure.

It is the reason Project 8.3 must explore resource sharing.

---

## 16. Why The Reference RTL May Be Large

The reference RTL prioritizes correctness.

It uses:

```text
W_IN = 6
W_INT = 10
```

The wider internal width avoids overflow mismatch with the Python golden model.

However, this also increases synthesis cost because arithmetic and comparison logic become wider.

The reference decoder also computes many operations combinationally.

Therefore, the total cell count is expected to be high.

This is acceptable for Project 8.2.1 because the goal is to create a baseline, not an optimized design.

---

## 17. Relationship To N=8 Results

The N=8 architecture exploration showed:

```text
combinational_n8 total cells = 1475
scheduled_n8 total cells = 2527
resource_shared_n8 total cells = 967
```

The main lesson from N=8 was:

```text
Scheduling alone is not enough.
Explicit resource sharing is required to reduce duplicated combinational logic.
```

Project 8.2.1 is expected to show that the N=16 reference combinational baseline is even more expensive.

This strengthens the motivation for:

```text
Project 8.3: Resource-shared scheduled SC Decoder N=16
```

---

## 18. Relationship To Project 8.3

Project 8.3 should use the synthesis result from Project 8.2.1 as the main comparison baseline.

The expected comparison will be:

```text
N=16 reference RTL
versus
N=16 resource-shared scheduled RTL
```

Important comparison metrics will include:

```text
total cells
estimated combinational cells
MUX cells
XOR/XNOR cells
NAND cells
latency cycles
clock period after physical implementation
```

Project 8.2.1 provides the first half of this comparison.

---

## 19. Result Recording Procedure

After running:

```bash
./synth/run_sc_decoder_n16_ref_yosys.sh
```

record the generated summary:

```bash
cat results/summary/sc_decoder_n16_ref_yosys_summary.md
```

The exact values from that file should be copied into a later "Actual Results" update if needed.

At this stage, this document defines the methodology and interpretation.

---

## 20. Actual Results Section

After Yosys has been run successfully, summarize the result here.

### 20.1 Generated Output Files

```text
synth/reports/sc_decoder_n16_ref_flat_yosys.log
results/summary/sc_decoder_n16_ref_yosys_summary.csv
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

### 20.2 Actual Metrics

The actual metrics should be taken from:

```text
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

Current status:

```text
To be filled after running Yosys and confirming the generated summary.
```

### 20.3 Interpretation

The N=16 reference RTL synthesis result should be interpreted as:

```text
a correctness-oriented synthesis baseline
```

not as:

```text
an optimized resource-shared architecture
```

---

## 21. Validation Checklist

Project 8.2.1 is complete if:

```text
synth/sc_decoder_n16_ref_flat.ys exists
synth/run_sc_decoder_n16_ref_yosys.sh exists
scripts/extract_sc_decoder_n16_ref_yosys_summary.py exists
Yosys run completes without error
synth/reports/sc_decoder_n16_ref_flat_yosys.log exists
results/summary/sc_decoder_n16_ref_yosys_summary.csv exists
results/summary/sc_decoder_n16_ref_yosys_summary.md exists
summary metrics are readable
the result is committed
```

Recommended commands:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

./synth/run_sc_decoder_n16_ref_yosys.sh

ls -lh synth/reports/sc_decoder_n16_ref_flat_yosys.log
ls -lh results/summary/sc_decoder_n16_ref_yosys_summary.csv
ls -lh results/summary/sc_decoder_n16_ref_yosys_summary.md

cat results/summary/sc_decoder_n16_ref_yosys_summary.md
```

---

## 22. Common Problems And Debugging

### Problem 1: Yosys Cannot Find The Top Module

Possible cause:

```text
wrong top module name
```

Fix:

```tcl
hierarchy -check -top sc_decoder_n16_ref
```

Also verify:

```bash
grep -n "module sc_decoder_n16_ref" rtl/sc_decoder_n16_ref.v
```

---

### Problem 2: Yosys Shows Only Submodules

Possible cause:

```text
flatten was not used
```

Fix:

```tcl
flatten
```

Then rerun synthesis.

---

### Problem 3: Unexpected DFF Cells Appear

The reference decoder should be combinational.

If DFF/DFFE cells appear, check for:

```text
always blocks with clock
inferred latches
incomplete assignments
unexpected sequential constructs
```

The intended reference design should have:

```text
Raw DFF/DFFE cells = 0
```

---

### Problem 4: Extract Script Cannot Find The Summary Block

Possible cause:

```text
Yosys top module name differs from sc_decoder_n16_ref
or
Yosys failed before stat
```

Check:

```bash
grep -n "=== sc_decoder_n16_ref ===" synth/reports/sc_decoder_n16_ref_flat_yosys.log
```

---

### Problem 5: Cell Count Seems Very Large

This is expected.

The reference decoder is:

```text
combinational
recursive
wider internal width
not resource-shared
```

A large cell count is not a bug by itself.

It is the baseline that motivates Project 8.3.

---

## 23. What To Commit

After running the synthesis successfully, commit:

```text
synth/sc_decoder_n16_ref_flat.ys
synth/run_sc_decoder_n16_ref_yosys.sh
scripts/extract_sc_decoder_n16_ref_yosys_summary.py
synth/reports/sc_decoder_n16_ref_flat_yosys.log
results/summary/sc_decoder_n16_ref_yosys_summary.csv
results/summary/sc_decoder_n16_ref_yosys_summary.md
docs/project8_2_1/sc_decoder_n16_ref_yosys_synthesis_study.md
```

Recommended command:

```bash
git add synth/sc_decoder_n16_ref_flat.ys \
        synth/run_sc_decoder_n16_ref_yosys.sh \
        scripts/extract_sc_decoder_n16_ref_yosys_summary.py \
        synth/reports/sc_decoder_n16_ref_flat_yosys.log \
        results/summary/sc_decoder_n16_ref_yosys_summary.csv \
        results/summary/sc_decoder_n16_ref_yosys_summary.md \
        docs/project8_2_1/sc_decoder_n16_ref_yosys_synthesis_study.md

git commit -m "project8.2.1: add N16 reference RTL Yosys synthesis study"
git push origin main
```

---

## 24. Academic Interpretation

Project 8.2.1 provides the synthesis-level reference baseline for SC Decoder N=16.

A successful result supports the statement:

```text
The functionally verified SC Decoder N=16 reference RTL has been synthesized and characterized using Yosys, producing a reproducible baseline for future resource-shared architecture comparison.
```

This is important because future optimized architectures need a clear baseline.

The project also strengthens the roadmap by showing the full progression:

```text
Python golden model
→ RTL verification
→ Yosys synthesis characterization
→ architecture optimization
```

---

## 25. Project 8.2.1 Conclusion

Project 8.2.1 establishes the Yosys synthesis baseline for the SC Decoder N=16 reference RTL.

The result should be used as the comparison point for:

```text
Project 8.3: Resource-Shared Scheduled SC Decoder N=16
```

The most important outcome is not that the reference RTL is small.

The most important outcome is that the reference RTL becomes measurable.

Once the N=16 reference baseline is measured, the roadmap can fairly evaluate whether resource sharing reduces complexity and improves area/timing trade-offs.

The next step after completing Project 8.2.1 is:

```text
Project 8.3: Resource-Shared Scheduled SC Decoder N=16
```