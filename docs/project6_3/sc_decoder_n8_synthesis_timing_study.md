# Project 6.3: SC Decoder N=8 Synthesis And Complexity Study

## 1. Project Objective

Project 6.3 performs synthesis and complexity analysis for the combinational SC Decoder N=8 baseline.

The main objective is to understand how much hardware logic is required when the N=8 SC decoder is synthesized.

Project 6.2 already confirmed that the RTL SC Decoder N=8 is functionally correct by passing 1000 Python-generated golden vectors.

Project 6.3 now answers the next question:

```text
How large is the SC Decoder N=8 after logic synthesis?
```

At the end of this project, the learner should understand:

```text
how to synthesize the SC Decoder N=8 using Yosys
why flattened synthesis is needed for architecture comparison
how N=8 complexity compares with N=4
which cell types dominate the decoder
why the combinational N=8 decoder motivates later scheduled/resource-shared architectures
```

---

## 2. Why This Project Is Important

RTL simulation only proves functional correctness.

It does not tell us:

```text
how much logic the design uses
how many gates are needed
whether the design is simple or complex
which cell types dominate the implementation
how the design scales from N=4 to N=8
```

For hardware research and ASIC-ready design, functional correctness is not enough.

We also need synthesis-level analysis.

Project 6.3 is important because it converts the verified RTL baseline into a measurable hardware structure.

The central question is:

```text
After synthesis, how much larger is SC Decoder N=8 compared with SC Decoder N=4?
```

---

## 3. Position In The Roadmap

The Project 6 sequence is:

```text
Project 6.1: SC Decoder N=8 golden model
Project 6.2: SC Decoder N=8 RTL baseline
Project 6.3: SC Decoder N=8 synthesis and complexity study
Project 6.4: SC Decoder N=8 OpenLane clean baseline
```

Project 6.3 sits between RTL verification and physical implementation.

It provides the logic-complexity evidence needed before moving to OpenLane.

---

## 4. Input Files

The main input files are:

```text
rtl/sc_decoder_n4.v
rtl/sc_decoder_n8.v
synth/sc_decoder_n4_flat.ys
synth/sc_decoder_n8_flat.ys
synth/sc_decoder_n8.ys
synth/run_sc_decoder_n8_yosys.sh
scripts/extract_yosys_summary.py
```

The exact repository version may include additional scripts or report files.

The key point is that Project 6.3 synthesizes:

```text
SC Decoder N=4
SC Decoder N=8
```

and compares their flattened gate-level complexity.

---

## 5. Output Files

Expected output files include:

```text
synth/reports/sc_decoder_n4_flat_yosys.log
synth/reports/sc_decoder_n8_flat_yosys.log
synth/reports/sc_decoder_n8_yosys.log

results/summary/sc_decoder_n4_n8_flat_yosys_comparison.csv
results/summary/sc_decoder_n4_n8_flat_yosys_comparison.md
```

Depending on the script version, file names may vary.

The important outputs are:

```text
Yosys synthesis reports
cell-count summaries
N=4 vs N=8 comparison table
```

---

## 6. Why Yosys Is Used

Yosys is used to synthesize the Verilog RTL into lower-level logic.

For this project, Yosys helps answer:

```text
How many wires are generated?
How many wire bits are generated?
How many logic cells are used?
How many XOR/XNOR cells are used?
How many MUX cells are used?
How much larger is N=8 compared with N=4?
```

Yosys synthesis is not the same as full physical implementation.

It is an early-stage logic complexity analysis before OpenLane.

---

## 7. Hierarchical Versus Flattened Synthesis

A key issue in this project is the difference between hierarchical and flattened synthesis.

### 7.1 Hierarchical Synthesis

In hierarchical synthesis, Yosys may report submodule instances instead of expanding all internal logic.

For example, the hierarchical N=8 report may show:

```text
=== sc_decoder_n8 ===

Number of cells: 14
  $_XNOR_ 2
  $_XOR_  2
  sc_decoder_n4 instances
  sc_f_unit instances
  sc_g_unit instances
```

This is useful for understanding module structure, but it is not enough for true logic-complexity comparison.

It hides the internal logic of submodules.

---

### 7.2 Flattened Synthesis

In flattened synthesis, submodules are expanded into primitive logic cells.

This gives a more meaningful estimate of total logic.

For architecture comparison, the flattened result is more useful because it answers:

```text
How many primitive logic cells are really needed after expanding the design?
```

Therefore, Project 6.3 focuses on flattened synthesis results.

---

## 8. Why Compare N=4 And N=8?

SC Decoder N=4 is the first complete decoder.

SC Decoder N=8 is built recursively from N=4.

Comparing N=4 and N=8 helps answer:

```text
Does complexity simply double from N=4 to N=8?
Or does it grow faster because of additional f/g stages and routing?
```

This comparison is important because the roadmap later aims to scale toward:

```text
N=16
N=32
larger resource-shared architectures
```

Understanding N=4 to N=8 growth helps predict future scaling problems.

---

## 9. SC Decoder N=4 Flattened Synthesis Result

The flattened Yosys result for SC Decoder N=4 was:

```text
=== sc_decoder_n4 ===

Number of wires:                580
Number of wire bits:           1302
Number of public wires:         144
Number of public wire bits:     866
Number of memories:               0
Number of memory bits:            0
Number of processes:              0
Number of cells:                440

  $_ANDNOT_                      20
  $_AND_                         79
  $_MUX_                         25
  $_NAND_                       141
  $_NOR_                         17
  $_NOT_                          4
  $_ORNOT_                       62
  $_OR_                          41
  $_XNOR_                        40
  $_XOR_                         11
```

This is the baseline complete decoder complexity for N=4.

---

## 10. SC Decoder N=8 Flattened Synthesis Result

The flattened Yosys result for SC Decoder N=8 was:

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

This is the synthesized logic complexity of the combinational N=8 baseline.

---

## 11. N=4 Versus N=8 Summary Table

| Metric | SC Decoder N=4 | SC Decoder N=8 | Ratio N=8/N=4 |
|---|---:|---:|---:|
| Wires | 580 | 1760 | 3.03× |
| Wire bits | 1302 | 3279 | 2.52× |
| Public wires | 144 | 293 | 2.03× |
| Public wire bits | 866 | 1812 | 2.09× |
| Total cells | 440 | 1475 | 3.35× |
| MUX cells | 25 | 101 | 4.04× |
| NAND cells | 141 | 443 | 3.14× |
| XOR cells | 11 | 61 | 5.55× |
| XNOR cells | 40 | 133 | 3.33× |

The total cell count grows from:

```text
440 cells
```

to:

```text
1475 cells
```

This is approximately:

```text
3.35× larger
```

---

## 12. Cell Breakdown Comparison

| Cell Type | N=4 Count | N=8 Count | Ratio |
|---|---:|---:|---:|
| ANDNOT | 20 | 87 | 4.35× |
| AND | 79 | 236 | 2.99× |
| MUX | 25 | 101 | 4.04× |
| NAND | 141 | 443 | 3.14× |
| NOR | 17 | 43 | 2.53× |
| NOT | 4 | 12 | 3.00× |
| ORNOT | 62 | 212 | 3.42× |
| OR | 41 | 147 | 3.59× |
| XNOR | 40 | 133 | 3.33× |
| XOR | 11 | 61 | 5.55× |

Important observation:

```text
MUX and XOR-related logic grow strongly from N=4 to N=8.
```

This is expected because N=8 introduces:

```text
larger partial-sum network
more f/g operations
more selection logic
larger internal routing structure
```

---

## 13. Interpretation Of Total Cell Growth

The N=8 decoder is not merely twice as large as the N=4 decoder.

Although N doubles from 4 to 8, the flattened total cell count increases by approximately:

```text
3.35×
```

This happens because N=8 includes:

```text
two N=4 decoding branches
additional top-level f operations
additional top-level g operations
N=4 partial-sum generation
larger frozen-mask handling
larger output construction
more internal wiring and selection logic
```

Therefore, recursive decoder scaling is more complex than simple duplication.

---

## 14. Why MUX Count Increases

MUX cells are associated with selection logic.

In the SC decoder, selection logic appears in:

```text
frozen-bit handling
conditional output selection
g-function mode selection
internal synthesized arithmetic logic
partial-sum and branch selection effects after optimization
```

The MUX count increases from:

```text
25 in N=4
```

to:

```text
101 in N=8
```

This is about:

```text
4.04×
```

This is one reason why later resource-sharing and scheduling become important.

---

## 15. Why XOR/XNOR Logic Increases

XOR and XNOR cells are important in the SC decoder because they appear in:

```text
sign logic of f operation
partial-sum generation
two's-complement arithmetic
adder/subtractor logic
bit-comparison logic after synthesis
```

The combined XOR/XNOR count is:

```text
N=4: 51
N=8: 194
```

This is about:

```text
3.80×
```

This reflects the increased arithmetic and partial-sum complexity of N=8.

---

## 16. Why NAND Cells Are Dominant

NAND cells are often heavily used after logic optimization because NAND is a universal gate and appears frequently in mapped combinational logic.

The NAND count is:

```text
N=4: 141
N=8: 443
```

This is about:

```text
3.14×
```

This shows that a large portion of the decoder is mapped into basic combinational logic.

---

## 17. No Memories And No Processes

Both flattened reports show:

```text
Number of memories: 0
Number of memory bits: 0
Number of processes: 0
```

This means:

```text
the design has no inferred memory
all always/process blocks were converted
the flattened result is purely structural logic
```

This is expected for a combinational decoder core.

---

## 18. No DFF Cells In The Decoder Core

The flattened N=4 and N=8 decoder cores do not report DFF cells.

This means the baseline decoder core is combinational.

Important interpretation:

```text
Project 6.3 analyzes the combinational RTL core, not a registered pipeline.
```

In Project 6.4, a top-level wrapper may add registers for OpenLane timing analysis.

---

## 19. Difference Between Logic Synthesis And Timing Closure

Project 6.3 performs Yosys logic synthesis and complexity analysis.

It does not yet prove physical timing closure.

Yosys generic cell count tells us:

```text
logic complexity
relative area trend
dominant cell types
structural growth
```

OpenLane timing closure tells us:

```text
actual routed timing
critical path
wire delay
placement/routing impact
DRC/LVS/Antenna status
```

Therefore:

```text
Project 6.3 = synthesis-level complexity
Project 6.4 = physical implementation and timing baseline
```

---

## 20. Recommended Yosys Commands

A typical command for N=8 flattened synthesis is:

```bash
yosys -s synth/sc_decoder_n8_flat.ys | tee synth/reports/sc_decoder_n8_flat_yosys.log
```

For N=4 flattened synthesis:

```bash
yosys -s synth/sc_decoder_n4_flat.ys | tee synth/reports/sc_decoder_n4_flat_yosys.log
```

If a project script exists, use:

```bash
./synth/run_sc_decoder_n8_yosys.sh
```

---

## 21. Recommended Yosys Script Structure

A flattened Yosys script should include a flatten step.

Example:

```tcl
read_verilog rtl/sc_decoder_n4.v
read_verilog rtl/sc_decoder_n8.v

hierarchy -check -top sc_decoder_n8

proc
opt

flatten

techmap
opt
abc
opt
clean

stat
```

The exact script depends on whether `sc_decoder_n4.v` contains all internal functions directly or depends on additional RTL files.

---

## 22. Why Flatten Must Be Used Carefully

Flattening is useful for complexity comparison, but it removes module boundaries.

This means after flattening, the report no longer clearly shows:

```text
which cells belong to left N=4 branch
which cells belong to right N=4 branch
which cells belong to top-level f/g stage
```

Therefore, for learning, both views are useful:

```text
hierarchical view → understand structure
flattened view    → compare real logic complexity
```

Project 6.3 uses flattened synthesis for numerical comparison.

---

## 23. Suggested Report Extraction Flow

A useful workflow is:

```text
1. Run Yosys for N=4 flat.
2. Run Yosys for N=8 flat.
3. Extract number of wires, wire bits, and cell counts.
4. Build CSV summary.
5. Build Markdown summary.
6. Commit reports and summary.
```

If using a Python extraction script:

```bash
python3 scripts/extract_yosys_summary.py
```

The script should parse the Yosys logs and generate a clean table.

---

## 24. Result Summary

Final Project 6.3 result:

```text
SC Decoder N=4 flattened cells = 440
SC Decoder N=8 flattened cells = 1475
N=8/N=4 cell ratio ≈ 3.35×

SC Decoder N=4 wires = 580
SC Decoder N=8 wires = 1760
N=8/N=4 wire ratio ≈ 3.03×

SC Decoder N=4 wire bits = 1302
SC Decoder N=8 wire bits = 3279
N=8/N=4 wire-bit ratio ≈ 2.52×
```

The N=8 decoder is substantially larger than the N=4 decoder.

---

## 25. What This Result Means Architecturally

The result shows that the combinational N=8 decoder is correct but relatively large.

This motivates the next architecture questions:

```text
Can we reduce duplicated combinational logic?
Can we schedule operations over multiple cycles?
Can we share f/g datapath resources?
Can we improve timing by avoiding a long combinational decoding path?
```

These questions lead directly to Project 7.

---

## 26. Why Project 6.3 Motivates Project 6.4

Before exploring new architectures, the combinational N=8 baseline should be physically implemented.

Therefore, after synthesis analysis, the next step is:

```text
Project 6.4: OpenLane exploratory and clean baseline run for SC Decoder N=8
```

Project 6.4 will answer:

```text
Can the combinational N=8 decoder be implemented to clean GDSII?
What clock period is needed?
What is the physical die area?
What is the critical path?
Are there antenna violations?
```

---

## 27. Why Project 6.3 Motivates Project 7

Project 6.3 also motivates Project 7.

The high flattened cell count and expected long combinational path suggest that the one-cycle combinational N=8 architecture may not scale well.

Project 7 will investigate:

```text
scheduled N=8 decoder
resource-shared scheduled N=8 decoder
architecture comparison
OpenLane implementation of resource-shared decoder
```

The key architectural hypothesis is:

```text
Explicit resource sharing can reduce duplicated logic and improve area/timing trade-off.
```

---

## 28. Common Problems And Debugging

### Problem 1: Yosys Only Shows Submodule Instances

If the report shows only a few cells such as:

```text
sc_decoder_n4 instances
sc_f_unit instances
sc_g_unit instances
```

then the design was not flattened.

Fix:

```text
Add flatten in the Yosys script before final stat.
```

---

### Problem 2: Missing RTL Dependency

If Yosys cannot find a module, it may report an error such as:

```text
Module sc_decoder_n4 not found
```

Fix:

```text
Add all required RTL files to the Yosys script.
```

Check:

```bash
ls -lh rtl/sc_decoder_n4.v
ls -lh rtl/sc_decoder_n8.v
```

---

### Problem 3: Wrong Top Module

If the top module is wrong, Yosys may synthesize the wrong design.

Fix:

```tcl
hierarchy -check -top sc_decoder_n8
```

For N=4:

```tcl
hierarchy -check -top sc_decoder_n4
```

---

### Problem 4: Comparing Hierarchical N=8 With Flattened N=4

This comparison is not fair.

Use the same synthesis style for both designs:

```text
N=4 flattened vs N=8 flattened
```

or:

```text
N=4 hierarchical vs N=8 hierarchical
```

For complexity comparison, use flattened reports.

---

### Problem 5: Misinterpreting Yosys Cell Count As Physical Area

Yosys generic cell count is not the same as final physical area.

Physical area depends on:

```text
standard cell mapping
placement
routing
utilization
buffers
tie cells
fill cells
diodes
floorplan
```

Use OpenLane metrics for physical area.

Use Yosys metrics for early logic comparison.

---

## 29. Validation Checklist

Project 6.3 is complete if:

```text
N=4 flattened Yosys report exists
N=8 flattened Yosys report exists
N=4 cell count is recorded
N=8 cell count is recorded
N=4 vs N=8 comparison table is created
hierarchical-vs-flattened distinction is documented
complexity growth is interpreted
motivation for Project 6.4 and Project 7 is clearly stated
```

Recommended commands:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

ls -lh synth/sc_decoder_n4_flat.ys
ls -lh synth/sc_decoder_n8_flat.ys

yosys -s synth/sc_decoder_n4_flat.ys | tee synth/reports/sc_decoder_n4_flat_yosys.log
yosys -s synth/sc_decoder_n8_flat.ys | tee synth/reports/sc_decoder_n8_flat_yosys.log
```

Then inspect:

```bash
grep -A20 "=== sc_decoder_n4 ===" synth/reports/sc_decoder_n4_flat_yosys.log
grep -A20 "=== sc_decoder_n8 ===" synth/reports/sc_decoder_n8_flat_yosys.log
```

---

## 30. Difference Between Project 6.2 And Project 6.3

Project 6.2 answers:

```text
Does the RTL SC Decoder N=8 produce correct u_hat outputs?
```

Project 6.3 answers:

```text
How much hardware logic does the RTL SC Decoder N=8 require after synthesis?
```

Both are required.

A design can be:

```text
functionally correct
but too large or too slow
```

Project 6.3 begins evaluating this hardware-cost dimension.

---

## 31. Difference Between Project 6.3 And Project 6.4

Project 6.3 uses Yosys and focuses on:

```text
logic complexity
cell count
wire count
cell-type breakdown
N=4 vs N=8 growth
```

Project 6.4 uses OpenLane and focuses on:

```text
physical implementation
GDSII generation
DRC
LVS
antenna
critical path
clock period
die area
routing
```

Therefore:

```text
Project 6.3 = logic synthesis study
Project 6.4 = physical implementation study
```

---

## 32. Lessons Learned

Project 6.3 teaches the following key lessons:

```text
1. Functional RTL verification is not enough for hardware design.
2. Yosys synthesis provides early insight into logic complexity.
3. Flattened synthesis is required for meaningful total cell-count comparison.
4. SC Decoder N=8 is much larger than SC Decoder N=4.
5. N=8/N=4 total cell ratio is about 3.35×.
6. MUX and XOR/XNOR logic grow strongly from N=4 to N=8.
7. The combinational N=8 baseline motivates physical implementation and later architecture optimization.
8. This project provides evidence for exploring scheduled and resource-shared decoders.
```

---

## 33. Role Of This Project In The Full Roadmap

Project 6.3 belongs to the SC Decoder N=8 baseline layer.

The roadmap progression is:

```text
Project 6.1: N=8 golden model
Project 6.2: N=8 RTL baseline
Project 6.3: N=8 synthesis and complexity study
Project 6.4: N=8 OpenLane clean baseline
Project 7.1: scheduled N=8 decoder
Project 7.3: resource-shared N=8 decoder
```

Project 6.3 provides the synthesis evidence that motivates later architecture exploration.

---

## 34. What This Project Is Not

Project 6.3 is not yet a physical implementation result.

It should not be presented as:

```text
a clean GDSII result
a routed timing result
a final ASIC implementation
```

Instead, it should be presented as:

```text
a synthesis-level complexity study
a baseline hardware-cost analysis
a preparation step before OpenLane physical implementation
```

---

## 35. Conclusion

Project 6.3 synthesizes the SC Decoder N=8 RTL baseline and compares its flattened complexity with SC Decoder N=4.

The main result is:

```text
SC Decoder N=4 flattened cell count = 440
SC Decoder N=8 flattened cell count = 1475
N=8/N=4 cell growth ≈ 3.35×
```

This confirms that the combinational N=8 decoder is significantly more complex than N=4.

The result motivates two next steps:

```text
Project 6.4:
OpenLane clean physical implementation of combinational N=8

Project 7:
Scheduled and resource-shared N=8 architecture exploration
```

Project 6.3 therefore provides the key synthesis-level baseline for the N=8 decoder architecture roadmap.