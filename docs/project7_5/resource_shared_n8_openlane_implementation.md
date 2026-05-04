# Project 7.5: OpenLane Implementation Of Resource-Shared SC Decoder N=8

## 1. Project Objective

Project 7.5 implements the resource-shared scheduled SC Decoder N=8 through the OpenLane RTL-to-GDSII flow.

The main objective is to verify whether the resource-shared architecture from Project 7.3 and Project 7.4 can be physically implemented with clean signoff.

The target signoff conditions are:

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
how to move a resource-shared sequential decoder from RTL to GDSII
how to compare synthesis-level improvement with physical implementation results
how to read OpenLane metrics for the shared decoder
how to interpret area, timing, routing, and signoff results
why resource sharing improves the N=8 decoder architecture
how this result prepares the timing-push study in Project 7.6
```

---

## 2. Why This Project Is Important

Project 7.4 showed that the resource-shared SC Decoder N=8 is the best of the three architectures at the Yosys synthesis level.

The key Yosys comparison was:

```text
combinational_n8 total cells      = 1475
scheduled_n8 total cells          = 2527
resource_shared_n8 total cells    = 967
```

The resource-shared design reduced total cell count to:

```text
0.66× of the combinational baseline
```

and estimated combinational cell count to:

```text
0.39× of the combinational baseline
```

However, Yosys synthesis is not enough.

A design that looks good in synthesis must still pass physical implementation.

Project 7.5 answers the question:

```text
Can the resource-shared SC Decoder N=8 be implemented through OpenLane with clean DRC, LVS, antenna, and timing?
```

This project is the physical validation of the resource-shared architecture.

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

Project 7.5 is the physical implementation milestone for the resource-shared architecture.

It checks whether the synthesis-level advantage from Project 7.4 survives the RTL-to-GDSII flow.

---

## 4. Design Under Test

The design under test is:

```text
sc_decoder_n8_shared_top
```

The core decoder is:

```text
sc_decoder_n8_shared
```

This design is a resource-shared scheduled SC Decoder N=8.

It uses:

```text
FSM control
start/busy/done protocol
internal registers
shared f/g datapath
operand selection
writeback control
u_hat output register
```

Unlike the combinational baseline, this design does not compute the full SC decoding tree in one long combinational path.

Instead, it executes the decoding schedule over multiple cycles.

---

## 5. Input Files

The main OpenLane input files are expected to be:

```text
rtl/sc_decoder_n8_shared.v
rtl/sc_decoder_n8_shared_top.v
OpenLane design folder: sc_decoder_n8_shared_top
OpenLane config file
```

The OpenLane source folder should contain the top wrapper and any required RTL dependencies.

A typical source folder is:

```text
/openlane/designs/sc_decoder_n8_shared_top/src/
  sc_decoder_n8_shared.v
  sc_decoder_n8_shared_top.v
```

If the shared decoder uses external helper modules, those files must also be copied into the OpenLane source folder.

---

## 6. Output Files

The final OpenLane run produced:

```text
runs/RUN_2026.05.03_13.42.04
```

The final GDSII file was:

```text
runs/RUN_2026.05.03_13.42.04/results/final/gds/sc_decoder_n8_shared_top.gds
```

Important OpenLane output files include:

```text
reports/signoff/drc.rpt
logs/signoff/*lvs*.log
logs/signoff/*arc*.log
reports/metrics.csv
results/final/gds/sc_decoder_n8_shared_top.gds
```

---

## 7. Resource-Shared Architecture Summary

The resource-shared decoder is based on the following idea:

```text
Use one shared f/g datapath and reuse it across multiple SC decoding steps.
```

Instead of duplicating many f and g units, the decoder uses:

```text
shared computation unit
FSM-controlled operand selection
FSM-controlled writeback
intermediate registers
partial-sum registers
decoded-bit registers
```

The high-level architecture is:

```text
Input LLR registers
        |
        v
FSM-controlled operand selection
        |
        v
Shared f/g datapath
        |
        v
FSM-controlled writeback
        |
        v
Decoded bits and u_hat output
```

This design trades higher cycle latency for lower combinational logic and improved timing potential.

---

## 8. Why OpenLane Is Needed After Yosys

Yosys synthesis gives early logic-complexity information.

However, it does not fully answer:

```text
Can the design be placed?
Can it be routed?
Does it pass DRC?
Does layout match netlist?
Are there antenna violations?
What is the routed critical path?
What is the physical die area?
How many vias and wires are generated?
```

OpenLane answers these physical implementation questions.

Therefore, Project 7.5 is required before making strong claims about the resource-shared architecture.

---

## 9. OpenLane Design Setup

A typical OpenLane folder is:

```text
/openlane/designs/sc_decoder_n8_shared_top/
  config.tcl
  src/
    sc_decoder_n8_shared.v
    sc_decoder_n8_shared_top.v
```

A representative configuration is:

```tcl
set ::env(DESIGN_NAME) sc_decoder_n8_shared_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "30"

set ::env(FP_CORE_UTIL) 50

set ::env(PL_TARGET_DENSITY) 0.30

set ::env(GRT_REPAIR_ANTENNAS) 1

set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1

set ::env(SYNTH_STRATEGY) "AREA 0"
```

The confirmed Project 7.5 run used:

```text
CLOCK_PERIOD = 30 ns
```

This is already much faster than the combinational baseline from Project 6.4, which used:

```text
CLOCK_PERIOD = 80 ns
```

---

## 10. OpenLane Run Command

From the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the OpenLane container:

```bash
./flow.tcl -design sc_decoder_n8_shared_top
```

After the run finishes:

```bash
exit
```

To inspect the latest run:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_shared_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final/gds -name "*.gds"
```

---

## 11. Final OpenLane Run

The confirmed Project 7.5 run was:

```text
runs/RUN_2026.05.03_13.42.04
```

The final GDSII file was:

```text
runs/RUN_2026.05.03_13.42.04/results/final/gds/sc_decoder_n8_shared_top.gds
```

The design name was:

```text
sc_decoder_n8_shared_top
```

The run directory was:

```text
/openlane/designs/sc_decoder_n8_shared_top/runs/RUN_2026.05.03_13.42.04
```

---

## 12. Final Signoff Result

The final signoff summary was:

```text
Design Name: sc_decoder_n8_shared_top
Run Directory: /openlane/designs/sc_decoder_n8_shared_top/runs/RUN_2026.05.03_13.42.04
```

Magic DRC result:

```text
Total Magic DRC violations is 0
```

LVS result:

```text
Number of nets: 1364 | Number of nets: 1364
Design is LVS clean.
```

Antenna result:

```text
Pin violations: 0
Net violations: 0
```

Therefore, the resource-shared SC Decoder N=8 achieved clean physical signoff.

---

## 13. Final Metrics Summary

Important metrics from the Project 7.5 OpenLane run:

```text
flow_status = flow completed
total_runtime = 0h2m39s0ms
routed_runtime = 0h1m43s0ms
DIEAREA_mm^2 = 0.36
synth_cell_count = 1045
tritonRoute_violations = 0
Magic_violations = 0
pin_antenna_violations = 0
net_antenna_violations = 0
lvs_total_errors = 0
wire_length = 70267
vias = 11718
wns = 0.0
tns = 0.0
critical_path_ns = 8.83
suggested_clock_period = 30.0
suggested_clock_frequency = 33.333 MHz
CLOCK_PERIOD = 30 ns
FP_CORE_UTIL = 50
PL_TARGET_DENSITY = 0.30
STD_CELL_LIBRARY = sky130_fd_sc_hd
SYNTH_STRATEGY = AREA 0
```

The most important result is:

```text
Resource-shared SC Decoder N=8:
clean at 30 ns
die area = 0.36 mm²
critical path = 8.83 ns
synth cell count = 1045
DRC = 0
LVS clean
Antenna = 0
```

---

## 14. Physical Cell Summary

OpenLane reported the following physical cell-related metrics:

```text
wires_count = 863
wire_bits = 1257
public_wires_count = 71
public_wire_bits = 461
cells_pre_abc = 1005
TotalCells = 37597
CoreArea_um^2 = 339525.632
```

Selected logic cell counts:

```text
AND = 18
DFF = 1
NAND = 18
NOR = 52
OR = 198
XOR = 38
XNOR = 22
MUX = 59
```

Physical/support cell counts:

```text
DecapCells = 23473
WelltapCells = 4815
DiodeCells = 1822
FillCells = 6184
NonPhysCells = 1303
```

The physical/support cells are expected in OpenLane implementation and should not be confused with pure logic cells.

---

## 15. Comparison With Combinational N=8 OpenLane Baseline

Project 6.4 implemented the combinational N=8 baseline.

Project 7.5 implements the resource-shared N=8 architecture.

Key comparison:

| Metric | Combinational N=8 | Resource-Shared N=8 |
|---|---:|---:|
| Clean run | RUN_2026.05.03_12.25.25 | RUN_2026.05.03_13.42.04 |
| Clock period | 80 ns | 30 ns |
| Suggested frequency | 12.5 MHz | 33.333 MHz |
| Die area | 0.64 mm² | 0.36 mm² |
| Synth cell count | 1361 | 1045 |
| Wire length | 80198 | 70267 |
| Vias | 13546 | 11718 |
| Critical path | 29.01 ns | 8.83 ns |
| Magic DRC | 0 | 0 |
| LVS | clean | clean |
| Pin antenna | 0 | 0 |
| Net antenna | 0 | 0 |

This comparison shows that the resource-shared design is better in both area and timing baseline metrics.

---

## 16. Area Improvement

The die area changes from:

```text
Combinational N=8 die area = 0.64 mm²
Resource-shared N=8 die area = 0.36 mm²
```

The area ratio is:

```text
0.36 / 0.64 = 0.5625
```

This means the resource-shared design uses about:

```text
56.25% of the combinational baseline die area
```

or equivalently, it reduces die area by about:

```text
43.75%
```

This is a strong physical implementation result.

---

## 17. Synth Cell Count Improvement

OpenLane synth cell count changes from:

```text
Combinational N=8 synth_cell_count = 1361
Resource-shared N=8 synth_cell_count = 1045
```

The ratio is:

```text
1045 / 1361 ≈ 0.768
```

This means the resource-shared design uses about:

```text
76.8% of the combinational baseline synthesized cell count
```

or about:

```text
23.2% lower synth cell count
```

This is consistent with the Yosys trend from Project 7.4, although the exact ratio differs because OpenLane mapping and Yosys generic synthesis are not identical.

---

## 18. Critical Path Improvement

The critical path changes from:

```text
Combinational N=8 critical path = 29.01 ns
Resource-shared N=8 critical path = 8.83 ns
```

The ratio is:

```text
8.83 / 29.01 ≈ 0.304
```

This means the resource-shared design has about:

```text
30.4% of the combinational baseline critical path
```

or about:

```text
69.6% shorter critical path
```

This is one of the strongest results of Project 7.5.

---

## 19. Clock Period Improvement

The clean baseline clock period changes from:

```text
Combinational N=8: 80 ns
Resource-shared N=8: 30 ns
```

The corresponding frequency changes from:

```text
12.5 MHz
```

to:

```text
33.333 MHz
```

This means the resource-shared design can be implemented with a significantly faster clock constraint in OpenLane.

However, the resource-shared design is multi-cycle, so overall throughput must also consider latency cycles.

Clock speed alone is not the full performance story.

---

## 20. Wire And Via Improvement

Wire length changes from:

```text
Combinational N=8 wire_length = 80198
Resource-shared N=8 wire_length = 70267
```

Via count changes from:

```text
Combinational N=8 vias = 13546
Resource-shared N=8 vias = 11718
```

This indicates that resource sharing also reduces physical routing burden.

This is expected because the shared architecture has fewer duplicated combinational structures and fewer internal wires.

---

## 21. Why Resource Sharing Helps Physical Implementation

Resource sharing helps because it reduces duplicated logic.

Instead of building many f/g operation paths in parallel, the design uses:

```text
one shared f/g datapath
sequential control
writeback registers
operand-selection logic
```

This reduces:

```text
combinational logic depth
duplicated arithmetic logic
routing complexity
critical path
die area
```

The cost is:

```text
more cycles per decoded vector
more control sequencing
internal state/register management
```

This is the classic area-latency trade-off.

---

## 22. Timing Interpretation

The Project 7.5 run reports:

```text
CLOCK_PERIOD = 30 ns
critical_path_ns = 8.83 ns
WNS = 0.0
TNS = 0.0
```

The important interpretation is:

```text
The design closes timing under the 30 ns OpenLane constraint.
```

The critical path is much shorter than the combinational baseline because each cycle performs a smaller amount of work.

This validates the architectural motivation for multi-cycle resource sharing.

---

## 23. DRC Interpretation

The final DRC result is:

```text
Total Magic DRC violations is 0
```

This means the layout satisfies the design rules checked by the Magic DRC flow.

DRC-clean layout is required for physical validity.

---

## 24. LVS Interpretation

The final LVS result is:

```text
Number of nets: 1364 | Number of nets: 1364
Design is LVS clean.
```

This means the layout-extracted netlist matches the intended synthesized netlist.

This confirms that the physical layout implements the correct circuit structure.

---

## 25. Antenna Interpretation

The final antenna result is:

```text
Pin violations = 0
Net violations = 0
```

This means antenna effects were successfully avoided or repaired.

This is important because earlier combinational N=8 OpenLane runs had antenna issues before the final clean run.

For Project 7.5, the resource-shared design achieved antenna-clean signoff in the confirmed run.

---

## 26. Why Project 7.5 Is Stronger Than Project 7.4

Project 7.4 showed that the resource-shared design is better at the Yosys synthesis level.

Project 7.5 shows that the design is also better after physical implementation.

Project 7.4 result:

```text
resource_shared_n8 has lowest total cells and estimated combinational cells
```

Project 7.5 result:

```text
resource_shared_n8_shared_top has clean OpenLane implementation,
smaller die area,
shorter critical path,
and faster clock constraint than combinational baseline.
```

Together, these results strongly support the resource-shared architecture.

---

## 27. Latency Must Still Be Considered

The resource-shared design improves area and critical path, but it is multi-cycle.

Therefore, a complete architecture comparison should eventually include:

```text
clock period
latency cycles
throughput
area
area-latency product
energy or power if available
```

Project 7.5 mainly confirms:

```text
physical implementability
area improvement
critical-path improvement
clean signoff
```

It does not yet fully analyze throughput.

That can be added in future work.

---

## 28. Recommended Latency Documentation

The testbench should record the number of cycles from:

```text
start
```

to:

```text
done
```

Recommended metric:

```text
latency_cycles
```

Then the effective decoding time can be estimated as:

```text
decode_time = latency_cycles × clock_period
```

For example, if latency is 28 cycles and clock period is 30 ns:

```text
decode_time = 28 × 30 ns = 840 ns
```

The exact latency should be measured from the actual RTL/testbench.

This is important for fair comparison with the combinational decoder.

---

## 29. Recommended Commands To Inspect Final Run

Use:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_shared_top

RUN_DIR=runs/RUN_2026.05.03_13.42.04

find $RUN_DIR/results/final/gds -name "sc_decoder_n8_shared_top.gds"

cat $RUN_DIR/reports/signoff/drc.rpt

grep -i "Design is LVS clean" $RUN_DIR/logs/signoff/*lvs*.log

grep -i "Pin violations" $RUN_DIR/logs/signoff/*arc*.log

grep -i "Net violations" $RUN_DIR/logs/signoff/*arc*.log

cat $RUN_DIR/reports/metrics.csv
```

These commands verify:

```text
GDSII exists
DRC is clean
LVS is clean
antenna is clean
metrics are available
```

---

## 30. Recommended Repository Archiving

Recommended files to archive or summarize in the repository:

```text
docs/project7_5/resource_shared_n8_openlane_implementation.md
results/openlane/sc_decoder_n8_shared_top/metrics.csv
results/openlane/sc_decoder_n8_shared_top/drc.rpt
results/openlane/sc_decoder_n8_shared_top/lvs_summary.txt
results/openlane/sc_decoder_n8_shared_top/antenna_summary.txt
results/openlane/sc_decoder_n8_shared_top/final_gds_path.txt
```

It is usually not necessary to commit the entire OpenLane run directory unless the repository policy allows large generated files.

At minimum, commit:

```text
OpenLane config
reproduction scripts
summary metrics
signoff summaries
documentation
```

---

## 31. Result Summary Table

| Metric | Resource-Shared SC Decoder N=8 |
|---|---:|
| Final clean run | RUN_2026.05.03_13.42.04 |
| Flow status | completed |
| GDSII | generated |
| Clock period | 30 ns |
| Suggested frequency | 33.333 MHz |
| Die area | 0.36 mm² |
| Synth cell count | 1045 |
| Wire length | 70267 |
| Vias | 11718 |
| Critical path | 8.83 ns |
| WNS | 0.0 |
| TNS | 0.0 |
| Magic DRC violations | 0 |
| LVS | clean |
| Pin antenna violations | 0 |
| Net antenna violations | 0 |
| Standard cell library | sky130_fd_sc_hd |

---

## 32. Comparison Summary Table

| Metric | Combinational N=8 | Resource-Shared N=8 | Improvement |
|---|---:|---:|---:|
| Clock period | 80 ns | 30 ns | faster constraint |
| Suggested frequency | 12.5 MHz | 33.333 MHz | 2.67× higher |
| Die area | 0.64 mm² | 0.36 mm² | 43.75% lower |
| Synth cell count | 1361 | 1045 | 23.2% lower |
| Wire length | 80198 | 70267 | lower |
| Vias | 13546 | 11718 | lower |
| Critical path | 29.01 ns | 8.83 ns | 69.6% shorter |
| DRC | 0 | 0 | both clean |
| LVS | clean | clean | both clean |
| Antenna | 0/0 | 0/0 | both clean |

This table shows the main physical-level advantage of the resource-shared design.

---

## 33. Important Interpretation Of The Comparison

The resource-shared design improves physical metrics because it avoids a long one-cycle decoding path.

However, the comparison must be interpreted fairly.

The combinational decoder has:

```text
very low cycle latency
long clock period
larger area
```

The resource-shared decoder has:

```text
multi-cycle latency
shorter clock period
smaller area
shorter critical path
```

Therefore, the correct architectural statement is:

```text
The resource-shared decoder improves area and clock timing at the cost of multi-cycle latency.
```

This is stronger and more accurate than simply saying the resource-shared decoder is always faster.

---

## 34. Common Problems And Debugging

### Problem 1: Missing Top Wrapper

OpenLane needs a valid top module.

Check:

```text
DESIGN_NAME = sc_decoder_n8_shared_top
```

and RTL:

```verilog
module sc_decoder_n8_shared_top (...);
```

---

### Problem 2: Missing Source Files

If OpenLane cannot elaborate the design, check the source folder:

```bash
ls /openlane/designs/sc_decoder_n8_shared_top/src
```

It should include all required RTL files.

---

### Problem 3: Timing Fails At Aggressive Clock

If the design fails at a smaller clock period, this is expected during timing exploration.

Project 7.5 confirms clean implementation at:

```text
30 ns
```

Project 7.6 later pushes timing further.

---

### Problem 4: Antenna Violations

If antenna violations appear, enable or check:

```tcl
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
```

Also inspect:

```text
logs/signoff/*arc*.log
reports/signoff/*antenna*
```

---

### Problem 5: Misreading TotalCells

OpenLane `TotalCells` includes physical support cells such as:

```text
fill cells
decap cells
welltap cells
antenna diodes
```

Do not compare `TotalCells` directly with Yosys cell count.

Use:

```text
synth_cell_count
```

for logic-level OpenLane comparison.

---

### Problem 6: Claiming Throughput Without Latency

The resource-shared design is multi-cycle.

Do not claim throughput improvement using clock frequency alone.

Always include:

```text
latency cycles
clock period
effective decoding time
```

when doing full performance analysis.

---

## 35. Validation Checklist

Project 7.5 is complete if:

```text
OpenLane run exists
GDSII file exists
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing is clean at 30 ns
metrics.csv is available
resource-shared metrics are compared with combinational baseline
limitations about multi-cycle latency are documented
```

Recommended checks:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_shared_top

RUN_DIR=runs/RUN_2026.05.03_13.42.04

find $RUN_DIR/results/final/gds -name "sc_decoder_n8_shared_top.gds"
cat $RUN_DIR/reports/signoff/drc.rpt
grep -i "Design is LVS clean" $RUN_DIR/logs/signoff/*lvs*.log
grep -i "Pin violations" $RUN_DIR/logs/signoff/*arc*.log
grep -i "Net violations" $RUN_DIR/logs/signoff/*arc*.log
cat $RUN_DIR/reports/metrics.csv
```

---

## 36. Lessons Learned

Project 7.5 teaches the following key lessons:

```text
1. Yosys-level architecture improvement must be validated physically.
2. The resource-shared SC Decoder N=8 can be implemented cleanly with OpenLane.
3. The resource-shared design achieves DRC = 0, LVS clean, and antenna = 0.
4. Compared with the combinational baseline, it reduces die area and critical path.
5. The design closes at 30 ns, compared with 80 ns for the combinational baseline.
6. The improvement comes from trading one-cycle combinational depth for multi-cycle resource reuse.
7. Throughput must still be evaluated using latency cycles.
8. Project 7.5 provides the physical evidence needed before timing push in Project 7.6.
```

---

## 37. Role Of This Project In The Full Roadmap

Project 7.5 is the physical implementation validation of the resource-shared N=8 architecture.

The roadmap progression is:

```text
Project 7.1:
    scheduled N=8 RTL baseline

Project 7.2:
    scheduled design shown to be larger than combinational baseline

Project 7.3:
    resource-shared scheduled N=8 RTL

Project 7.4:
    three-architecture Yosys comparison

Project 7.5:
    OpenLane implementation of resource-shared N=8

Project 7.6:
    timing push for resource-shared N=8
```

Project 7.5 confirms that the best synthesis-level architecture from Project 7.4 also works well in physical implementation.

---

## 38. What This Project Is Not

Project 7.5 is not the final timing-optimized implementation.

It should not be presented as:

```text
the maximum-frequency implementation
the final optimized decoder
a full throughput comparison
a complete scalable N=16/N=32 framework
```

Instead, it should be presented as:

```text
a clean physical implementation of the resource-shared N=8 decoder
a physical validation of the resource-sharing architecture
a baseline for timing push and future scalability studies
```

---

## 39. Conclusion

Project 7.5 successfully implements the resource-shared SC Decoder N=8 through OpenLane.

The final clean run is:

```text
RUN_2026.05.03_13.42.04
```

The final result is:

```text
GDSII generated
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing clean at CLOCK_PERIOD = 30 ns
Die area = 0.36 mm²
Synth cell count = 1045
Critical path = 8.83 ns
```

Compared with the combinational N=8 baseline, the resource-shared design achieves:

```text
43.75% lower die area
23.2% lower OpenLane synth cell count
69.6% shorter critical path
clean timing at 30 ns instead of 80 ns
```

The key conclusion is:

```text
The resource-shared scheduled architecture improves physical area and timing metrics at the cost of multi-cycle latency.
```

The next step is Project 7.6:

```text
Timing Push For Resource-Shared SC Decoder N=8
```