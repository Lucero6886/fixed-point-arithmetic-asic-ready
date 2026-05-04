# Project 6.4: SC Decoder N=8 OpenLane Clean Baseline

## 1. Project Objective

Project 6.4 implements the combinational SC Decoder N=8 baseline through the OpenLane RTL-to-GDSII flow.

The main objective is to verify whether the functionally correct and synthesized SC Decoder N=8 from Projects 6.2 and 6.3 can be physically implemented with clean signoff.

The target physical signoff conditions are:

```text
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing clean
GDSII generated
```

At the end of this project, the learner should understand:

```text
how to move from verified RTL to OpenLane physical implementation
how to configure an OpenLane run for a larger combinational decoder
how to read OpenLane metrics
how to distinguish DRC, LVS, antenna, and timing results
why the combinational SC Decoder N=8 needs a relaxed clock
why this baseline motivates scheduled and resource-shared architectures
```

---

## 2. Why This Project Is Important

Project 6.2 verified that the SC Decoder N=8 RTL is functionally correct.

Project 6.3 showed that the flattened N=8 decoder has:

```text
1475 Yosys generic logic cells
```

However, synthesis-level correctness and complexity are not enough.

For ASIC-ready design, we must also check whether the design can pass physical implementation.

Physical implementation may fail due to:

```text
routing congestion
timing violation
DRC violation
LVS mismatch
antenna violation
floorplan issue
placement-density issue
clock constraint issue
missing wrapper or missing source file
```

Therefore, Project 6.4 answers the question:

```text
Can the combinational SC Decoder N=8 be implemented through OpenLane to clean GDSII?
```

This project is also important because it establishes the physical baseline that will later be compared with the scheduled and resource-shared architectures in Project 7.

---

## 3. Position In The Roadmap

The Project 6 sequence is:

```text
Project 6.1: SC Decoder N=8 golden model
Project 6.2: SC Decoder N=8 RTL baseline
Project 6.3: SC Decoder N=8 synthesis and complexity study
Project 6.4: SC Decoder N=8 OpenLane clean baseline
```

Project 6.4 completes the baseline N=8 flow:

```text
Python golden model
→ RTL verification
→ Yosys synthesis
→ OpenLane physical implementation
→ clean GDSII
```

After Project 6.4, the roadmap moves to Project 7:

```text
scheduled N=8 decoder
resource-shared N=8 decoder
architecture comparison
```

---

## 4. Input Files

The main input files are:

```text
rtl/sc_decoder_n4.v
rtl/sc_decoder_n8.v
rtl/sc_decoder_n8_top.v
OpenLane design folder: sc_decoder_n8_top
OpenLane config file
```

The wrapper `sc_decoder_n8_top.v` is important because the combinational decoder core needs a stable top-level design for OpenLane.

A typical OpenLane source folder should contain:

```text
sc_decoder_n4.v
sc_decoder_n8.v
sc_decoder_n8_top.v
```

Depending on the RTL organization, additional primitive files may also be required.

---

## 5. Output Files

The main OpenLane output files are located inside the run directory:

```text
runs/RUN_2026.05.03_12.25.25/
```

Important files include:

```text
results/final/gds/sc_decoder_n8_top.gds
reports/signoff/drc.rpt
logs/signoff/*lvs*.log
logs/signoff/*arc*.log
reports/metrics.csv
```

The final GDSII file is:

```text
runs/RUN_2026.05.03_12.25.25/results/final/gds/sc_decoder_n8_top.gds
```

---

## 6. Design Under Test

The design under test is:

```text
sc_decoder_n8_top
```

The core decoder is:

```text
sc_decoder_n8
```

The core implements a combinational SC Decoder N=8.

The top-level wrapper is used to make the design suitable for physical implementation and timing analysis.

A typical wrapper may include:

```text
input registers
combinational SC Decoder N=8 core
output registers
```

This gives OpenLane a register-to-register timing path.

---

## 7. Architecture Summary

The combinational SC Decoder N=8 architecture performs the full N=8 SC decoding operation in one combinational core.

The high-level schedule is:

```text
1. Compute top-level left LLRs using f:
   left_i = f(L_i, L_{i+4}), i = 0..3

2. Decode the left N=4 branch.

3. Compute N=4 partial sums from the left decoded bits.

4. Compute top-level right LLRs using g:
   right_i = g(L_i, L_{i+4}, partial_i), i = 0..3

5. Decode the right N=4 branch.

6. Concatenate left and right decoded bits.
```

This design is straightforward and useful as a baseline, but it creates a long combinational path.

---

## 8. Why A Top-Level Wrapper Is Needed

The decoder core itself is combinational.

A purely combinational block can be synthesized and placed, but timing analysis is clearer when the design has a proper top-level timing boundary.

The wrapper can provide:

```text
clock
reset
input registers
output registers
stable top-level ports
clear timing paths
```

This allows OpenLane to evaluate timing from input registers through the combinational decoder to output registers.

Without a wrapper, timing interpretation may be less meaningful.

---

## 9. OpenLane Design Setup

A typical OpenLane design folder is:

```text
/openlane/designs/sc_decoder_n8_top/
  config.tcl
  src/
    sc_decoder_n4.v
    sc_decoder_n8.v
    sc_decoder_n8_top.v
```

A representative configuration includes:

```tcl
set ::env(DESIGN_NAME) sc_decoder_n8_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "80"

set ::env(FP_CORE_UTIL) 50

set ::env(PL_TARGET_DENSITY) 0.30

set ::env(GRT_REPAIR_ANTENNAS) 1

set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1

set ::env(SYNTH_STRATEGY) "AREA 0"
```

The key point is that the final clean run used a relaxed clock period of:

```text
CLOCK_PERIOD = 80 ns
```

This was necessary for clean timing closure of the combinational N=8 baseline.

---

## 10. Why CLOCK_PERIOD = 80 ns Was Used

The combinational N=8 decoder has a long logic path because the full SC decoding operation is computed within one combinational structure.

The critical path includes many dependent operations such as:

```text
f operation
hard decision
g operation
partial-sum generation
nested N=4 decoding paths
frozen-mask selection
output generation
```

Therefore, the combinational N=8 baseline cannot be expected to close timing at a very aggressive clock period.

The final clean run used:

```text
CLOCK_PERIOD = 80 ns
```

This corresponds to:

```text
suggested frequency = 12.5 MHz
```

This is slow, but it is acceptable for a baseline implementation.

The goal of Project 6.4 is not performance optimization. The goal is to establish a clean physical baseline.

---

## 11. OpenLane Run Command

From the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the container:

```bash
./flow.tcl -design sc_decoder_n8_top
```

After the run:

```bash
exit
```

To check the latest run:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final/gds -name "*.gds"
```

---

## 12. Final Clean Run

The final clean run was:

```text
runs/RUN_2026.05.03_12.25.25
```

The final GDSII file was:

```text
runs/RUN_2026.05.03_12.25.25/results/final/gds/sc_decoder_n8_top.gds
```

The design name was:

```text
sc_decoder_n8_top
```

The run directory was:

```text
/openlane/designs/sc_decoder_n8_top/runs/RUN_2026.05.03_12.25.25
```

---

## 13. Final Signoff Result

The final signoff summary was:

```text
Design Name: sc_decoder_n8_top
Run Directory: /openlane/designs/sc_decoder_n8_top/runs/RUN_2026.05.03_12.25.25

Magic DRC Summary:
Total Magic DRC violations is 0

LVS Summary:
Number of nets: 1513 | Number of nets: 1513
Design is LVS clean.

Antenna Summary:
Pin violations: 0
Net violations: 0
```

This confirms that the design achieved clean physical signoff.

---

## 14. Final Metrics Summary

Important metrics from the clean run:

```text
flow_status = flow completed
total_runtime = 0h3m0s0ms
routed_runtime = 0h1m51s0ms
DIEAREA_mm^2 = 0.64
synth_cell_count = 1361
tritonRoute_violations = 0
Magic_violations = 0
pin_antenna_violations = 0
net_antenna_violations = 0
lvs_total_errors = 0
wire_length = 80198
vias = 13546
wns = 0.0
tns = 0.0
critical_path_ns = 29.01
suggested_clock_period = 80.0
suggested_clock_frequency = 12.5 MHz
CLOCK_PERIOD = 80 ns
FP_CORE_UTIL = 50
PL_TARGET_DENSITY = 0.30
STD_CELL_LIBRARY = sky130_fd_sc_hd
SYNTH_STRATEGY = AREA 0
```

The most important summary is:

```text
Combinational SC Decoder N=8:
clean at 80 ns
die area = 0.64 mm²
critical path = 29.01 ns
synth cell count = 1361
DRC = 0
LVS clean
Antenna = 0
```

---

## 15. Physical Cell Summary

OpenLane reported:

```text
wires_count = 2187
wire_bits = 3126
public_wires_count = 196
public_wire_bits = 1135
cells_pre_abc = 2063
TotalCells = 66291
CoreArea_um^2 = 613701.088
```

Selected logic cell counts:

```text
AND = 22
DFF = 0
NAND = 139
NOR = 48
OR = 117
XOR = 376
XNOR = 81
MUX = 364
```

Physical/support cell counts:

```text
DecapCells = 43280
WelltapCells = 8784
DiodeCells = 2252
FillCells = 10523
NonPhysCells = 1452
```

The high number of decap, welltap, diode, and fill cells is normal in physical implementation and should not be confused with the synthesized logic cell count.

---

## 16. Difference Between synth_cell_count And TotalCells

OpenLane reported:

```text
synth_cell_count = 1361
TotalCells = 66291
```

These two values have different meanings.

`synth_cell_count` refers to the synthesized design logic cells.

`TotalCells` includes many physical implementation cells such as:

```text
standard logic cells
decap cells
welltap cells
fill cells
antenna diodes
other physical support cells
```

Therefore, for logic comparison, use:

```text
synth_cell_count
```

For physical layout density and implementation statistics, use:

```text
TotalCells
```

Do not directly compare `TotalCells` with Yosys generic cell count.

---

## 17. Difference Between Yosys Cells And OpenLane synth_cell_count

Project 6.3 reported the flattened Yosys generic cell count:

```text
1475 cells
```

Project 6.4 reported OpenLane `synth_cell_count`:

```text
1361 cells
```

These are close but not identical.

Reason:

```text
Yosys generic synthesis and OpenLane technology mapping are not the same reporting stage.
Different optimization passes may be used.
Cell libraries and mapping rules differ.
Some logic may be optimized differently.
```

Therefore:

```text
Yosys cell count is useful for architecture-level comparison.
OpenLane synth_cell_count is useful for physical-flow comparison.
```

---

## 18. Timing Interpretation

The final clean run reports:

```text
CLOCK_PERIOD = 80 ns
critical_path_ns = 29.01 ns
WNS = 0.0
TNS = 0.0
suggested_clock_period = 80.0 ns
suggested_clock_frequency = 12.5 MHz
```

The most important practical result is:

```text
timing is clean under the 80 ns constraint
```

The critical path of:

```text
29.01 ns
```

indicates that the internal combinational logic is long, but still below the relaxed 80 ns timing constraint.

The reported suggested clock period should be interpreted cautiously because OpenLane reports depend on the configuration and timing analysis stage. The key design-level conclusion is:

```text
The combinational N=8 baseline requires a relaxed clock and is not timing-efficient.
```

---

## 19. Why The Critical Path Is Long

The critical path is long because the combinational decoder computes many dependent operations in one cycle.

The path may include:

```text
top-level f operation
nested N=4 left decoding
hard decision
partial-sum XOR
top-level g operation
nested N=4 right decoding
final hard decision
frozen-mask logic
output register
```

This creates a deep chain of logic.

This is expected for a one-cycle combinational SC decoder.

It motivates later architecture exploration:

```text
multi-cycle scheduling
resource sharing
pipeline/register insertion
schedule-generated decoder control
```

---

## 20. DRC Interpretation

The final DRC result is:

```text
Total Magic DRC violations is 0
```

This means the layout satisfies the design rules checked by Magic under the selected Sky130/OpenLane flow.

A DRC-clean result is required before considering a layout physically valid under the flow.

---

## 21. LVS Interpretation

The final LVS result is:

```text
Number of nets: 1513 | Number of nets: 1513
Design is LVS clean.
```

This means the extracted layout netlist matches the intended synthesized netlist.

LVS clean is essential because a layout with DRC clean but LVS mismatch may not implement the intended circuit.

---

## 22. Antenna Interpretation

The final antenna result is:

```text
Pin violations = 0
Net violations = 0
```

This means antenna violations were repaired or avoided.

This matters because earlier exploratory runs had antenna violations.

A final clean result must satisfy:

```text
DRC = 0
LVS clean
Antenna = 0
```

not only DRC and LVS.

---

## 23. Earlier Exploratory Runs

Before the final clean run, there were exploratory runs with antenna violations.

Examples:

```text
RUN_2026.05.03_11.33.42:
Pin violations = 1
Net violations = 1

RUN_2026.05.03_11.40.23:
Pin violations = 2
Net violations = 2

RUN_2026.05.03_11.49.11:
Pin violations = 1
Net violations = 1
```

These runs were useful because they showed that:

```text
the design could pass DRC and LVS
but still needed antenna cleanup
```

The final clean run fixed this:

```text
RUN_2026.05.03_12.25.25:
Pin violations = 0
Net violations = 0
```

---

## 24. Why Earlier Runs Should Be Kept As Learning Records

The earlier runs should not be considered failures only.

They are useful learning records because they show the physical-design debugging process.

Important lesson:

```text
A design may be functionally correct, synthesized, routed, DRC-clean, and LVS-clean, but still not antenna-clean.
```

Therefore, final signoff must include all checks:

```text
simulation
synthesis
routing
DRC
LVS
antenna
timing
```

---

## 25. Recommended Commands To Inspect Final Run

Use the following commands inside the OpenLane design directory:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_top

RUN_DIR=runs/RUN_2026.05.03_12.25.25

find $RUN_DIR/results/final/gds -name "*.gds"

cat $RUN_DIR/reports/signoff/drc.rpt

grep -i "Design is LVS clean" $RUN_DIR/logs/signoff/*lvs*.log

grep -i "violations" $RUN_DIR/logs/signoff/*arc*.log

cat $RUN_DIR/reports/metrics.csv
```

If the repository stores copied summaries, use the repository-level paths instead.

---

## 26. Recommended Repository Archiving

The final result should be copied or summarized into the project repository.

Recommended archived items:

```text
docs/project6_4/sc_decoder_n8_openlane_clean_baseline.md
results/openlane/sc_decoder_n8_top/metrics.csv
results/openlane/sc_decoder_n8_top/drc.rpt
results/openlane/sc_decoder_n8_top/lvs_summary.txt
results/openlane/sc_decoder_n8_top/antenna_summary.txt
results/openlane/sc_decoder_n8_top/final_gds_path.txt
```

Do not necessarily commit very large generated folders unless the repository policy allows it.

At minimum, commit:

```text
documentation
selected metrics
summary reports
scripts/configs required to reproduce the run
```

---

## 27. Result Summary Table

| Metric | Combinational SC Decoder N=8 |
|---|---:|
| Final clean run | RUN_2026.05.03_12.25.25 |
| Flow status | completed |
| GDSII | generated |
| Clock period | 80 ns |
| Suggested frequency | 12.5 MHz |
| Die area | 0.64 mm² |
| Synth cell count | 1361 |
| Wire length | 80198 |
| Vias | 13546 |
| Critical path | 29.01 ns |
| WNS | 0.0 |
| TNS | 0.0 |
| Magic DRC violations | 0 |
| LVS | clean |
| Pin antenna violations | 0 |
| Net antenna violations | 0 |
| Standard cell library | sky130_fd_sc_hd |

---

## 28. Interpretation Of The Result Summary

The combinational N=8 decoder is physically feasible.

This is the positive result.

However, it is not efficient in timing.

The main limitation is:

```text
clean timing requires a relaxed 80 ns clock period
```

This indicates that computing the entire SC decoding operation in one combinational path is not scalable.

Therefore, Project 6.4 is both:

```text
a success
```

and:

```text
a motivation for architectural improvement
```

---

## 29. Difference Between Project 6.3 And Project 6.4

Project 6.3 answered:

```text
How many logic cells does SC Decoder N=8 require after synthesis?
```

Project 6.4 answered:

```text
Can this decoder be physically implemented to clean GDSII?
```

Project 6.3 used:

```text
Yosys synthesis reports
```

Project 6.4 used:

```text
OpenLane physical implementation reports
```

Both are necessary.

---

## 30. Difference Between Project 6.4 And Project 7

Project 6.4 implements the combinational baseline.

Project 7 explores improved architectures.

Project 6.4 shows:

```text
baseline is correct and physically clean
but timing is relaxed and area is relatively large
```

Project 7 asks:

```text
Can scheduling or resource sharing improve the architecture?
```

Therefore, Project 6.4 is the baseline against which Project 7 will be compared.

---

## 31. Why This Baseline Is Important For Research

Even if the combinational baseline is not the final architecture, it is still important.

A research or engineering comparison needs a baseline.

Project 6.4 provides:

```text
functional baseline
synthesis baseline
physical implementation baseline
timing baseline
area baseline
```

Later improvements should be compared against this baseline.

For example, Project 7 will compare:

```text
combinational N=8
scheduled N=8
resource-shared N=8
```

Without Project 6.4, the resource-shared result would not have a meaningful physical reference.

---

## 32. Common Problems And Debugging

### Problem 1: Antenna Violations Remain

Earlier runs had:

```text
Pin violations > 0
Net violations > 0
```

Possible fixes:

```tcl
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
set ::env(DIODE_INSERTION_STRATEGY) 4
```

Also consider adjusting:

```text
placement density
floorplan size
routing settings
```

---

### Problem 2: Timing Fails At Aggressive Clock

If a smaller clock such as 10 ns or 20 ns fails, this is expected for the combinational N=8 baseline.

Fix:

```text
relax CLOCK_PERIOD
use a registered wrapper
move to scheduled/resource-shared architecture
```

For the clean baseline, the final clock was:

```text
80 ns
```

---

### Problem 3: Missing Source Files

The N=8 top may depend on N=4 RTL.

Make sure the OpenLane `src` folder includes all required files:

```text
sc_decoder_n4.v
sc_decoder_n8.v
sc_decoder_n8_top.v
```

Check:

```bash
ls /openlane/designs/sc_decoder_n8_top/src
```

---

### Problem 4: Top Module Mismatch

If `DESIGN_NAME` does not match the RTL top module, synthesis will fail or synthesize the wrong module.

Check:

```tcl
set ::env(DESIGN_NAME) sc_decoder_n8_top
```

and confirm the Verilog module:

```verilog
module sc_decoder_n8_top (...);
```

---

### Problem 5: Misinterpreting Flow Status

A run may say:

```text
flow completed
```

but still have antenna violations.

Therefore, always check:

```text
DRC
LVS
Antenna
Timing
```

Do not rely only on flow status.

---

## 33. Validation Checklist

Project 6.4 is complete if:

```text
OpenLane run exists
GDSII file exists
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing is clean under selected CLOCK_PERIOD
metrics.csv is archived or summarized
final run path is documented
baseline metrics are recorded
```

Recommended check commands:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_top

RUN_DIR=runs/RUN_2026.05.03_12.25.25

find $RUN_DIR/results/final/gds -name "sc_decoder_n8_top.gds"
cat $RUN_DIR/reports/signoff/drc.rpt
grep -i "Design is LVS clean" $RUN_DIR/logs/signoff/*lvs*.log
grep -i "Pin violations" $RUN_DIR/logs/signoff/*arc*.log
grep -i "Net violations" $RUN_DIR/logs/signoff/*arc*.log
cat $RUN_DIR/reports/metrics.csv
```

---

## 34. Lessons Learned

Project 6.4 teaches the following key lessons:

```text
1. A functionally correct RTL decoder still needs physical signoff.
2. The combinational N=8 decoder can be implemented to clean GDSII.
3. DRC, LVS, antenna, and timing must all be checked.
4. Antenna violations may remain even when DRC and LVS are clean.
5. The combinational N=8 decoder requires a relaxed 80 ns clock.
6. The long critical path motivates multi-cycle and resource-shared architectures.
7. OpenLane metrics must be interpreted carefully.
8. Project 6.4 provides the physical baseline for Project 7 comparisons.
```

---

## 35. Role Of This Project In The Full Roadmap

Project 6.4 completes the combinational SC Decoder N=8 baseline flow.

The roadmap progression is:

```text
Project 6.1: N=8 golden model
Project 6.2: N=8 RTL baseline
Project 6.3: N=8 synthesis study
Project 6.4: N=8 OpenLane clean baseline
Project 7.1: scheduled N=8 decoder
Project 7.2: combinational vs scheduled comparison
Project 7.3: resource-shared scheduled N=8 decoder
Project 7.4: three-architecture Yosys comparison
Project 7.5: resource-shared N=8 OpenLane implementation
Project 7.6: timing push for resource-shared N=8
```

Project 6.4 is the reference physical baseline for all Project 7 improvements.

---

## 36. What This Project Is Not

Project 6.4 is not an optimized architecture.

It should not be presented as:

```text
the final decoder architecture
a scalable SC decoder solution
a high-throughput implementation
a resource-shared design
```

Instead, it should be presented as:

```text
a clean combinational baseline
a physical implementation reference
a necessary baseline before architecture optimization
```

---

## 37. Conclusion

Project 6.4 successfully implements the combinational SC Decoder N=8 baseline through OpenLane.

The final clean run is:

```text
RUN_2026.05.03_12.25.25
```

The final result is:

```text
GDSII generated
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing clean at CLOCK_PERIOD = 80 ns
Die area = 0.64 mm²
Synth cell count = 1361
Critical path = 29.01 ns
```

This establishes the first OpenLane-clean physical baseline for SC Decoder N=8.

The result also shows that the combinational architecture is not timing-efficient, motivating Project 7:

```text
Scheduled / Multi-Cycle SC Decoder N=8
Resource-Shared Scheduled SC Decoder N=8
Architecture comparison and timing improvement
```