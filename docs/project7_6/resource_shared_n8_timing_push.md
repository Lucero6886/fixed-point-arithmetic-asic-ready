# Project 7.6: Timing Push For Resource-Shared SC Decoder N=8

## 1. Project Objective

Project 7.6 pushes the timing constraint of the resource-shared SC Decoder N=8 after the clean OpenLane implementation in Project 7.5.

Project 7.5 already proved that the resource-shared decoder can be implemented cleanly at:

```text
CLOCK_PERIOD = 30 ns
```

Project 7.6 asks a stronger question:

```text
Can the resource-shared SC Decoder N=8 still pass OpenLane signoff under a tighter 15 ns clock constraint?
```

The final result confirms that the design is clean at:

```text
CLOCK_PERIOD = 15 ns
```

with:

```text
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing clean
GDSII generated
```

This project is important because it shows that the resource-shared architecture is not only smaller than the combinational baseline, but also much more timing-friendly.

---

## 2. Why This Project Is Important

Project 6.4 showed that the combinational SC Decoder N=8 baseline could be implemented cleanly only with a relaxed timing constraint:

```text
CLOCK_PERIOD = 80 ns
```

Project 7.5 showed that the resource-shared SC Decoder N=8 could be implemented cleanly at:

```text
CLOCK_PERIOD = 30 ns
```

Project 7.6 pushes the clock further to:

```text
CLOCK_PERIOD = 15 ns
```

This is a major improvement over the combinational baseline.

The central question is:

```text
Does the resource-shared architecture still remain DRC-clean, LVS-clean, antenna-clean, and timing-clean at 15 ns?
```

The answer is yes.

---

## 3. Position In The Roadmap

The roadmap around Project 7 is:

```text
Project 6.4: Combinational N=8 OpenLane clean baseline at 80 ns
Project 7.1: Scheduled / multi-cycle N=8 RTL baseline
Project 7.2: Yosys comparison of combinational vs scheduled N=8
Project 7.3: Resource-shared scheduled N=8 RTL
Project 7.4: Three-architecture Yosys comparison
Project 7.5: Resource-shared N=8 OpenLane implementation at 30 ns
Project 7.6: Timing push for resource-shared N=8 at 15 ns
```

Project 7.6 is the timing-closure milestone for the resource-shared architecture.

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

This architecture uses:

```text
FSM control
start/busy/done protocol
internal LLR registers
partial-sum registers
decoded-bit registers
shared f/g datapath
operand-selection logic
writeback logic
```

The design performs SC decoding over multiple cycles.

It trades:

```text
higher cycle latency
```

for:

```text
shorter critical path
lower duplicated combinational logic
smaller physical area
better timing closure
```

---

## 5. Timing-Push Strategy

The timing-push strategy is simple:

```text
Use the same resource-shared decoder architecture,
but reduce CLOCK_PERIOD from 30 ns to 15 ns.
```

The key OpenLane constraint is:

```tcl
set ::env(CLOCK_PERIOD) "15"
```

The same design must still pass:

```text
synthesis
floorplanning
placement
clock tree synthesis
routing
DRC
LVS
antenna check
timing analysis
GDSII generation
```

---

## 6. OpenLane Configuration Summary

The final clean run used:

```text
DESIGN_NAME = sc_decoder_n8_shared_top
CLOCK_PERIOD = 15 ns
FP_CORE_UTIL = 50
PL_TARGET_DENSITY = 0.30
STD_CELL_LIBRARY = sky130_fd_sc_hd
SYNTH_STRATEGY = AREA 0
GRT_REPAIR_ANTENNAS = 1
RUN_HEURISTIC_DIODE_INSERTION = 1
```

Important physical-design configuration values:

```text
FP_ASPECT_RATIO = 1
FP_CORE_UTIL = 50
FP_PDN_HPITCH = 153.18
FP_PDN_VPITCH = 153.6
GRT_ADJUSTMENT = 0.3
MAX_FANOUT_CONSTRAINT = 10
PL_TARGET_DENSITY = 0.30
```

---

## 7. OpenLane Run Command

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

To inspect the final run:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_shared_top

RUN_DIR=runs/RUN_2026.05.03_15.45.12
echo $RUN_DIR

find $RUN_DIR/results/final/gds -name "sc_decoder_n8_shared_top.gds"
```

---

## 8. Final Clean Run

The final clean timing-push run is:

```text
runs/RUN_2026.05.03_15.45.12
```

The final GDSII file is:

```text
runs/RUN_2026.05.03_15.45.12/results/final/gds/sc_decoder_n8_shared_top.gds
```

The design name is:

```text
sc_decoder_n8_shared_top
```

The run directory is:

```text
/openlane/designs/sc_decoder_n8_shared_top/runs/RUN_2026.05.03_15.45.12
```

---

## 9. Final Signoff Result

The final signoff result is:

```text
Design Name: sc_decoder_n8_shared_top
Run Directory: /openlane/designs/sc_decoder_n8_shared_top/runs/RUN_2026.05.03_15.45.12
```

Magic DRC result:

```text
Total Magic DRC violations is 0
```

LVS result:

```text
Number of nets: 1343 | Number of nets: 1343
Design is LVS clean.
```

Antenna result:

```text
Pin violations: 0
Net violations: 0
```

Therefore, the resource-shared SC Decoder N=8 passed physical signoff at 15 ns.

---

## 10. Final Metrics Summary

Important metrics from the final clean 15 ns run:

```text
flow_status = flow completed
total_runtime = 0h2m27s0ms
routed_runtime = 0h1m36s0ms
DIEAREA_mm^2 = 0.36
synth_cell_count = 1045
tritonRoute_violations = 0
Magic_violations = 0
pin_antenna_violations = 0
net_antenna_violations = 0
lvs_total_errors = 0
wire_length = 70864
vias = 11705
wns = 0.0
tns = 0.0
critical_path_ns = 8.62
suggested_clock_period = 15.0
suggested_clock_frequency = 66.666 MHz
CLOCK_PERIOD = 15 ns
STD_CELL_LIBRARY = sky130_fd_sc_hd
SYNTH_STRATEGY = AREA 0
```

The most important result is:

```text
Resource-shared SC Decoder N=8:
clean at 15 ns
die area = 0.36 mm²
critical path = 8.62 ns
synth cell count = 1045
DRC = 0
LVS clean
Antenna = 0
```

---

## 11. Physical Cell Summary

OpenLane reported:

```text
wires_count = 863
wire_bits = 1257
public_wires_count = 71
public_wire_bits = 461
memories_count = 0
memory_bits = 0
processes_count = 0
cells_pre_abc = 1005
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

Physical/support cells:

```text
DecapCells = 23466
WelltapCells = 4815
DiodeCells = 1861
FillCells = 6215
NonPhysCells = 1282
TotalCells = 37639
CoreArea_um^2 = 339525.632
```

These physical/support cells are normal in OpenLane implementation and should not be confused with pure RTL/Yosys logic cells.

---

## 12. Power Metrics

The final 15 ns run reported typical power components:

```text
power_typical_internal_uW = 0.00344
power_typical_switching_uW = 0.00489
power_typical_leakage_uW = 2.48e-08
```

These values are useful as preliminary OpenLane-reported estimates.

They should be interpreted cautiously because accurate power comparison requires:

```text
consistent activity factors
same clock constraint
same workload
same extraction conditions
same reporting corner
```

For this project, timing and signoff are the main focus.

---

## 13. Comparison With Project 7.5

Project 7.5 clean run:

```text
RUN_2026.05.03_13.42.04
CLOCK_PERIOD = 30 ns
critical_path_ns = 8.83 ns
DIEAREA_mm^2 = 0.36
synth_cell_count = 1045
wire_length = 70267
vias = 11718
DRC = 0
LVS clean
Antenna = 0
```

Project 7.6 clean run:

```text
RUN_2026.05.03_15.45.12
CLOCK_PERIOD = 15 ns
critical_path_ns = 8.62 ns
DIEAREA_mm^2 = 0.36
synth_cell_count = 1045
wire_length = 70864
vias = 11705
DRC = 0
LVS clean
Antenna = 0
```

The important conclusion is:

```text
The same resource-shared architecture remains clean when the clock constraint is tightened from 30 ns to 15 ns.
```

---

## 14. Project 7.5 Versus Project 7.6 Table

| Metric | Project 7.5 | Project 7.6 |
|---|---:|---:|
| Run | RUN_2026.05.03_13.42.04 | RUN_2026.05.03_15.45.12 |
| Clock period | 30 ns | 15 ns |
| Suggested frequency | 33.333 MHz | 66.666 MHz |
| Die area | 0.36 mm² | 0.36 mm² |
| Synth cell count | 1045 | 1045 |
| Wire length | 70267 | 70864 |
| Vias | 11718 | 11705 |
| Critical path | 8.83 ns | 8.62 ns |
| Magic DRC | 0 | 0 |
| LVS | clean | clean |
| Pin antenna | 0 | 0 |
| Net antenna | 0 | 0 |

This shows that Project 7.6 successfully doubles the clock-frequency target compared with Project 7.5 while preserving clean signoff.

---

## 15. Comparison With Combinational N=8 Baseline

The combinational N=8 baseline from Project 6.4 used:

```text
CLOCK_PERIOD = 80 ns
DIEAREA_mm^2 = 0.64
synth_cell_count = 1361
critical_path_ns = 29.01
DRC = 0
LVS clean
Antenna = 0
```

The resource-shared 15 ns result from Project 7.6 uses:

```text
CLOCK_PERIOD = 15 ns
DIEAREA_mm^2 = 0.36
synth_cell_count = 1045
critical_path_ns = 8.62
DRC = 0
LVS clean
Antenna = 0
```

This is a major physical-design improvement.

---

## 16. Combinational Baseline Versus Resource-Shared Timing Push

| Metric | Combinational N=8 | Resource-Shared N=8 Timing Push |
|---|---:|---:|
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

The resource-shared design improves:

```text
clock constraint
die area
synth cell count
critical path
routing burden
```

while preserving clean signoff.

---

## 17. Clock Constraint Improvement

The clean clock period improves from:

```text
Combinational baseline: 80 ns
Resource-shared timing push: 15 ns
```

The ratio is:

```text
80 / 15 ≈ 5.33×
```

This means the resource-shared design closes timing under a clock constraint that is about:

```text
5.33× tighter
```

than the combinational baseline.

However, because the resource-shared design is multi-cycle, this does not directly mean 5.33× higher decoder throughput.

Throughput must consider latency cycles.

---

## 18. Critical Path Improvement

The critical path improves from:

```text
Combinational baseline: 29.01 ns
Resource-shared timing push: 8.62 ns
```

The ratio is:

```text
8.62 / 29.01 ≈ 0.297
```

This means the resource-shared timing-push design has about:

```text
29.7% of the combinational baseline critical path
```

or equivalently about:

```text
70.3% shorter critical path
```

This confirms that the resource-shared architecture significantly reduces the amount of logic on the critical path.

---

## 19. Die Area Improvement

The die area improves from:

```text
Combinational baseline: 0.64 mm²
Resource-shared timing push: 0.36 mm²
```

The ratio is:

```text
0.36 / 0.64 = 0.5625
```

This means the resource-shared timing-push design uses:

```text
56.25% of the combinational baseline die area
```

or equivalently:

```text
43.75% lower die area
```

This is a strong physical-area improvement.

---

## 20. Synth Cell Count Improvement

The OpenLane synth cell count improves from:

```text
Combinational baseline: 1361
Resource-shared timing push: 1045
```

The ratio is:

```text
1045 / 1361 ≈ 0.768
```

This means the resource-shared timing-push design uses about:

```text
76.8% of the combinational baseline synth cell count
```

or approximately:

```text
23.2% lower OpenLane synth cell count
```

---

## 21. Routing Improvement

Wire length improves from:

```text
Combinational baseline: 80198
Resource-shared timing push: 70864
```

Via count improves from:

```text
Combinational baseline: 13546
Resource-shared timing push: 11705
```

This suggests that the resource-shared architecture reduces routing burden.

The reason is that fewer duplicated combinational structures usually require fewer internal routes.

---

## 22. Timing Interpretation

The final 15 ns run reports:

```text
CLOCK_PERIOD = 15 ns
critical_path_ns = 8.62 ns
WNS = 0.0
TNS = 0.0
```

The important interpretation is:

```text
The design closes timing at 15 ns under the reported OpenLane timing configuration.
```

The critical path is below the target clock period.

This confirms that the resource-shared architecture is timing-friendly.

---

## 23. Why Resource Sharing Improves Timing

The combinational decoder computes a large part of the SC decoding tree in one long combinational path.

The resource-shared decoder breaks this into smaller operations across multiple cycles.

Each cycle only needs to compute a smaller operation such as:

```text
one f operation
one g operation
one hard-decision step
one writeback step
one partial-sum computation
```

Therefore, the critical path is shorter.

This is the main reason the design can close timing at 15 ns.

---

## 24. Area-Latency-Timing Trade-Off

The resource-shared design improves area and timing, but it is not free.

It introduces multi-cycle latency.

The correct interpretation is:

```text
Resource sharing reduces area and critical path,
but increases the number of cycles required to decode one N=8 vector.
```

Therefore, full performance evaluation should include:

```text
clock period
latency cycles
effective decoding time
throughput
area
area-latency product
```

Project 7.6 focuses on timing push and physical signoff.

Throughput analysis should be added in a later project or summary report.

---

## 25. Why Clock Frequency Alone Is Not Enough

The resource-shared design closes timing at:

```text
15 ns
```

which corresponds to:

```text
66.666 MHz
```

The combinational design closes at:

```text
80 ns
```

which corresponds to:

```text
12.5 MHz
```

However, the combinational design may produce one output per combinational evaluation or per wrapper cycle, while the resource-shared design requires multiple cycles.

Therefore, we should not claim:

```text
The resource-shared decoder is 5.33× faster in throughput.
```

unless latency cycles are included.

The correct claim is:

```text
The resource-shared decoder closes timing under a 5.33× tighter clock constraint than the combinational baseline.
```

---

## 26. Recommended Latency Measurement

The next useful metric is:

```text
latency_cycles
```

This should be measured from:

```text
start assertion
```

to:

```text
done assertion
```

Then effective decoding time is:

```text
decode_time = latency_cycles × CLOCK_PERIOD
```

For example, if latency is 28 cycles:

```text
decode_time = 28 × 15 ns = 420 ns
```

The exact latency should be measured from the actual testbench/RTL.

---

## 27. Effective Performance Metrics To Add Later

For a stronger architecture report, add:

```text
latency_cycles
decode_time_ns
throughput_vectors_per_second
area_latency_product
area_delay_product
energy estimate if power is reliable
```

Possible formulas:

```text
decode_time_ns = latency_cycles × clock_period_ns
throughput = 1 / decode_time_seconds
area_delay = die_area × critical_path
area_latency = die_area × decode_time
```

These metrics would make the architecture comparison more complete.

---

## 28. DRC Interpretation

The DRC result is:

```text
Total Magic DRC violations is 0
```

This means the layout satisfies the checked Sky130 design rules under the OpenLane/Magic flow.

This is required for a physically valid layout.

---

## 29. LVS Interpretation

The LVS result is:

```text
Number of nets: 1343 | Number of nets: 1343
Design is LVS clean.
```

This means the extracted layout netlist matches the intended synthesized netlist.

A design that is DRC clean but not LVS clean is not acceptable.

Project 7.6 is both DRC-clean and LVS-clean.

---

## 30. Antenna Interpretation

The antenna result is:

```text
Pin violations = 0
Net violations = 0
```

This means the design has no reported antenna violations in the final run.

This is important because earlier projects showed that antenna violations may remain even after DRC and LVS are clean.

The final Project 7.6 run is antenna-clean.

---

## 31. Why Project 7.6 Is A Strong Milestone

Project 7.6 is stronger than Project 7.5 because it shows that the resource-shared decoder is not only clean at 30 ns, but also clean at 15 ns.

This confirms:

```text
the resource-shared datapath has a short critical path
the FSM/register structure supports tighter timing
the physical implementation remains clean
area is preserved
antenna repair remains successful
```

This is a strong architecture-level result for the N=8 decoder roadmap.

---

## 32. Recommended Commands To Inspect Final Run

Use:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_shared_top

RUN_DIR=runs/RUN_2026.05.03_15.45.12

find $RUN_DIR/results/final/gds -name "sc_decoder_n8_shared_top.gds"

cat $RUN_DIR/reports/signoff/drc.rpt

grep -i "Design is LVS clean" $RUN_DIR/logs/signoff/*lvs*.log

grep -i "Pin violations" $RUN_DIR/logs/signoff/*arc*.log

grep -i "Net violations" $RUN_DIR/logs/signoff/*arc*.log

cat $RUN_DIR/reports/metrics.csv
```

These commands check:

```text
GDSII file
DRC result
LVS result
antenna result
full metrics
```

---

## 33. Recommended Repository Archiving

Recommended files or summaries to archive:

```text
docs/project7_6/resource_shared_n8_timing_push.md
results/openlane/sc_decoder_n8_shared_top_15ns/metrics.csv
results/openlane/sc_decoder_n8_shared_top_15ns/drc.rpt
results/openlane/sc_decoder_n8_shared_top_15ns/lvs_summary.txt
results/openlane/sc_decoder_n8_shared_top_15ns/antenna_summary.txt
results/openlane/sc_decoder_n8_shared_top_15ns/final_gds_path.txt
```

The entire OpenLane run folder may be too large for normal Git tracking.

At minimum, preserve:

```text
configuration
scripts
metrics
signoff summaries
documentation
```

---

## 34. Result Summary Table

| Metric | Resource-Shared SC Decoder N=8 Timing Push |
|---|---:|
| Final clean run | RUN_2026.05.03_15.45.12 |
| Flow status | completed |
| GDSII | generated |
| Clock period | 15 ns |
| Suggested frequency | 66.666 MHz |
| Die area | 0.36 mm² |
| Synth cell count | 1045 |
| Wire length | 70864 |
| Vias | 11705 |
| Critical path | 8.62 ns |
| WNS | 0.0 |
| TNS | 0.0 |
| Magic DRC violations | 0 |
| LVS | clean |
| Pin antenna violations | 0 |
| Net antenna violations | 0 |
| Standard cell library | sky130_fd_sc_hd |

---

## 35. Final Architecture Comparison Table

| Metric | Combinational N=8 | Resource-Shared N=8 at 30 ns | Resource-Shared N=8 at 15 ns |
|---|---:|---:|---:|
| Project | 6.4 | 7.5 | 7.6 |
| Clean run | RUN_2026.05.03_12.25.25 | RUN_2026.05.03_13.42.04 | RUN_2026.05.03_15.45.12 |
| Clock period | 80 ns | 30 ns | 15 ns |
| Suggested frequency | 12.5 MHz | 33.333 MHz | 66.666 MHz |
| Die area | 0.64 mm² | 0.36 mm² | 0.36 mm² |
| Synth cell count | 1361 | 1045 | 1045 |
| Wire length | 80198 | 70267 | 70864 |
| Vias | 13546 | 11718 | 11705 |
| Critical path | 29.01 ns | 8.83 ns | 8.62 ns |
| Magic DRC | 0 | 0 | 0 |
| LVS | clean | clean | clean |
| Pin antenna | 0 | 0 | 0 |
| Net antenna | 0 | 0 | 0 |

This table summarizes the main physical-design evolution.

---

## 36. Main Conclusion From The Comparison

The resource-shared architecture improves the N=8 decoder baseline in two important ways:

```text
1. It reduces physical area.
2. It supports a much tighter clock constraint.
```

Compared with the combinational N=8 baseline:

```text
die area decreases from 0.64 mm² to 0.36 mm²
critical path decreases from 29.01 ns to 8.62 ns
clean clock constraint improves from 80 ns to 15 ns
```

The main limitation is:

```text
the resource-shared design requires multiple cycles per decoded vector
```

Therefore, the correct conclusion is:

```text
The resource-shared scheduled architecture achieves a better area/timing trade-off than the combinational baseline, at the cost of multi-cycle latency.
```

---

## 37. Common Problems And Debugging

### Problem 1: Timing Does Not Close At 15 ns

Possible causes:

```text
different OpenLane version
different configuration
placement or routing variation
different RTL version
missing optimization setting
too high placement density
```

Possible fixes:

```text
lower placement density
increase die area
check clock definition
inspect timing report
try timing-oriented synthesis strategy
verify the same RTL/config as the clean run
```

---

### Problem 2: Antenna Violations Reappear

If antenna violations appear, check:

```tcl
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
```

Then inspect:

```text
logs/signoff/*arc*.log
reports/signoff/*antenna*
```

---

### Problem 3: DRC Or LVS Fails

Check:

```text
source files
top module name
OpenLane config
generated netlist
macro-less standard-cell flow
```

Useful checks:

```bash
ls /openlane/designs/sc_decoder_n8_shared_top/src
grep DESIGN_NAME /openlane/designs/sc_decoder_n8_shared_top/config.tcl
```

---

### Problem 4: Misinterpreting Critical Path Versus Clock Period

A shorter critical path indicates better timing potential.

But for a multi-cycle design, throughput also depends on latency cycles.

Do not report clock frequency alone as total decoder throughput.

---

### Problem 5: Comparing TotalCells With Yosys Cells

OpenLane `TotalCells` includes physical cells:

```text
fill cells
decap cells
welltap cells
diodes
standard cells
```

Yosys cell count is logic-level.

Use:

```text
Yosys cell count for synthesis-level architecture comparison
OpenLane synth_cell_count for physical-flow logic comparison
OpenLane DIEAREA for physical area comparison
```

---

## 38. Validation Checklist

Project 7.6 is complete if:

```text
OpenLane run at CLOCK_PERIOD = 15 ns exists
GDSII file exists
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing is clean at 15 ns
metrics.csv is available
comparison with Project 7.5 is documented
comparison with Project 6.4 is documented
multi-cycle latency limitation is clearly stated
```

Recommended checks:

```bash
cd ~/OpenLane/designs/sc_decoder_n8_shared_top

RUN_DIR=runs/RUN_2026.05.03_15.45.12

find $RUN_DIR/results/final/gds -name "sc_decoder_n8_shared_top.gds"
cat $RUN_DIR/reports/signoff/drc.rpt
grep -i "Design is LVS clean" $RUN_DIR/logs/signoff/*lvs*.log
grep -i "Pin violations" $RUN_DIR/logs/signoff/*arc*.log
grep -i "Net violations" $RUN_DIR/logs/signoff/*arc*.log
cat $RUN_DIR/reports/metrics.csv
```

---

## 39. Lessons Learned

Project 7.6 teaches the following key lessons:

```text
1. Resource sharing improves timing by shortening the per-cycle combinational path.
2. The resource-shared SC Decoder N=8 can close timing at 15 ns in OpenLane.
3. The design remains DRC-clean, LVS-clean, and antenna-clean at the tighter constraint.
4. The resource-shared design preserves the smaller 0.36 mm² die area.
5. Compared with the combinational baseline, the clock constraint improves from 80 ns to 15 ns.
6. Critical path decreases from 29.01 ns to 8.62 ns.
7. Clock improvement must be interpreted together with multi-cycle latency.
8. Project 7.6 provides the strongest physical evidence so far for the resource-shared architecture.
```

---

## 40. Role Of This Project In The Full Roadmap

Project 7.6 completes the first major N=8 architecture exploration cycle.

The roadmap from Project 6 to Project 7 demonstrates:

```text
1. Build a correct combinational N=8 decoder.
2. Verify it against a Python golden model.
3. Synthesize it.
4. Implement it in OpenLane.
5. Build a scheduled decoder.
6. Discover that scheduling alone is not enough.
7. Build a resource-shared decoder.
8. Prove that it reduces logic in Yosys.
9. Prove that it improves area/timing in OpenLane.
10. Push timing to 15 ns cleanly.
```

This is a strong foundation for future work on:

```text
N=16 decoder
automatic schedule generation
resource-shared scalable architecture
FPGA comparison
ASIC-ready architecture report
research paper development
```

---

## 41. What This Project Is Not

Project 7.6 is not yet a complete final research contribution.

It should not be overstated as:

```text
a full scalable Polar decoder architecture
a complete N=16/N=32 implementation
a throughput-optimized decoder
a final journal-level architecture
```

Instead, it should be presented as:

```text
a timing-push validation for the resource-shared N=8 decoder
a physical evidence milestone
a foundation for scalable schedule-generated SC decoder architecture
```

---

## 42. Conclusion

Project 7.6 successfully pushes the resource-shared SC Decoder N=8 to a tighter OpenLane timing constraint.

The final clean run is:

```text
RUN_2026.05.03_15.45.12
```

The final result is:

```text
GDSII generated
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
Timing clean at CLOCK_PERIOD = 15 ns
Die area = 0.36 mm²
Synth cell count = 1045
Critical path = 8.62 ns
```

Compared with the combinational N=8 baseline, the resource-shared timing-push result achieves:

```text
43.75% lower die area
23.2% lower OpenLane synth cell count
70.3% shorter critical path
clean timing at 15 ns instead of 80 ns
```

The main architectural conclusion is:

```text
The resource-shared scheduled SC Decoder N=8 provides a better area/timing trade-off than the combinational baseline, while preserving clean physical signoff.
```

The next recommended step is to create a Project 7 summary report that consolidates:

```text
functional verification
Yosys comparison
OpenLane comparison
timing-push result
limitations
next direction toward N=16 and schedule generation
```