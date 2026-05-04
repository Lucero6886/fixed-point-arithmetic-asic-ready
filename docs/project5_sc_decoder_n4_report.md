# Project 5: SC Decoder N=4

## 1. Project Objective

Project 5 implements and verifies a complete Successive Cancellation Decoder with code length N=4.

The main objective is to move from individual SC primitive blocks to the first complete Polar SC decoder.

Previous projects implemented:

```text
Project 2: SC f unit
Project 3: SC g unit
Project 4: Polar Encoder N=8 / partial-sum concept
```

Project 5 combines the essential SC decoding operations:

```text
f operation
g operation
hard decision
frozen-bit handling
partial-sum generation
u_hat output construction
```

At the end of this project, the learner should understand:

```text
how a complete SC decoder works for a small code length
how f and g operations are connected in a decoding tree
how frozen bits affect hard decisions
how partial sums control the right-branch g operation
how to verify a complete decoder exhaustively
how to push a complete decoder through OpenLane
```

---

## 2. Why This Project Is Important

Project 5 is the first complete decoder project.

Before this project, the roadmap only had isolated building blocks:

```text
signed arithmetic primitives
absolute value
minimum comparator
SC f unit
SC g unit
Polar encoder
```

A complete SC decoder is more difficult because it requires correct coordination among these blocks.

For N=4, the decoder is still small enough to analyze manually, but it already contains the essential structure of SC decoding.

The central question of this project is:

```text
Can we build a complete SC Decoder N=4 from f/g operations, frozen-bit decisions, and partial sums, then verify and physically implement it?
```

This project is the bridge between primitive blocks and the larger SC Decoder N=8 architecture.

---

## 3. Relationship With Previous Projects

Project 2 implemented:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Project 3 implemented:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

Project 4 clarified the Polar transform and partial-sum concept.

Project 5 uses these ideas to build:

```text
SC Decoder N=4
```

The dependency chain is:

```text
SC f unit
SC g unit
partial-sum XOR logic
hard decision logic
frozen-mask logic
→ SC Decoder N=4
```

---

## 4. Technical Background

## 4.1 What Is SC Decoding?

Successive Cancellation decoding estimates the source bit vector:

```text
u_hat[0], u_hat[1], ..., u_hat[N-1]
```

one bit at a time.

The word “successive” means:

```text
the decoder makes decisions sequentially
later decisions may depend on earlier decisions
```

For each bit:

```text
if the bit is frozen:
    u_hat[i] = 0
else:
    u_hat[i] = hard_decision(LLR)
```

The hard decision rule is:

```text
if LLR < 0:
    decoded bit = 1
else:
    decoded bit = 0
```

---

## 4.2 SC Decoding Tree For N=4

For N=4, the input LLR vector is:

```text
L0, L1, L2, L3
```

The decoder first computes left-branch LLRs using f:

```text
left0 = f(L0, L2)
left1 = f(L1, L3)
```

Then it decodes the left N=2 branch.

After decoding the left branch, it computes partial sums and uses g operations for the right branch:

```text
right0 = g(L0, L2, partial0)
right1 = g(L1, L3, partial1)
```

Finally, the decoder outputs:

```text
u_hat[0], u_hat[1], u_hat[2], u_hat[3]
```

---

## 4.3 Frozen-Bit Handling

The frozen mask determines whether a bit is frozen or information.

This roadmap uses the convention:

```text
frozen_mask[i] = 1 → u_i is frozen and forced to 0
frozen_mask[i] = 0 → u_i is information and decided by hard decision
```

For a leaf decision:

```text
if frozen_mask[i] = 1:
    u_hat[i] = 0
else:
    u_hat[i] = (LLR < 0) ? 1 : 0
```

This convention must remain consistent across:

```text
Python golden model
RTL decoder
testbench
larger N=8/N=16 decoders
```

---

## 4.4 Partial Sums For N=4

Partial sums are required for the g operation.

For the left N=2 branch, after decoding:

```text
u0
u1
```

the partial sums used for the right branch are:

```text
partial0 = u0 ^ u1
partial1 = u1
```

These follow the Polar encoding transform for N=2.

Therefore, for N=4:

```text
right0 = g(L0, L2, u0 ^ u1)
right1 = g(L1, L3, u1)
```

This is one of the most important concepts in SC decoding.

---

## 5. Design Under Test

The design under test is a combinational SC Decoder N=4.

A typical interface is:

```verilog
module sc_decoder_n4 #(
    parameter W = 6
)(
    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire        [3:0]   frozen_mask,
    output wire        [3:0]   u_hat
);
```

The decoder computes:

```text
u_hat[0:3]
```

from:

```text
input LLRs
frozen mask
SC f/g schedule
```

This design is combinational at the decoder-core level.

A registered top wrapper is used for OpenLane physical implementation.

---

## 6. Expected File Structure

The expected file structure for Project 5 is:

```text
rtl/
  sc_f_unit.v
  sc_g_unit.v
  sc_decoder_n4.v
  sc_decoder_n4_top.v

tb/
  tb_sc_decoder_n4.v
  tb_sc_decoder_n4_top.v

sim/
  run_sc_decoder_n4.sh
  waveforms/
    sc_decoder_n4.vcd

synth/
  sc_decoder_n4.ys
  sc_decoder_n4_top.ys
  reports/
    sc_decoder_n4_yosys.log
    sc_decoder_n4_top_yosys.log
  netlist/
    sc_decoder_n4_synth.v
    sc_decoder_n4_top_synth.v

asic_openlane/
  sc_decoder_n4_top/
    config/
    reports/
    results/
```

Depending on the actual repository version, some file names may be slightly different.

---

## 7. N=4 SC Decoder Schedule

The N=4 schedule can be described step by step.

### Step 1: Compute First-Level Left LLRs

```text
l0 = f(llr0, llr2)
l1 = f(llr1, llr3)
```

### Step 2: Decode u0

For the left N=2 branch:

```text
llr_u0 = f(l0, l1)
```

Then:

```text
if frozen_mask[0] = 1:
    u0 = 0
else:
    u0 = hard_decision(llr_u0)
```

### Step 3: Decode u1

Compute:

```text
llr_u1 = g(l0, l1, u0)
```

Then:

```text
if frozen_mask[1] = 1:
    u1 = 0
else:
    u1 = hard_decision(llr_u1)
```

### Step 4: Generate Partial Sums For Right Branch

```text
p0 = u0 ^ u1
p1 = u1
```

### Step 5: Compute Right-Branch LLRs

```text
r0 = g(llr0, llr2, p0)
r1 = g(llr1, llr3, p1)
```

### Step 6: Decode u2

```text
llr_u2 = f(r0, r1)
```

Then:

```text
if frozen_mask[2] = 1:
    u2 = 0
else:
    u2 = hard_decision(llr_u2)
```

### Step 7: Decode u3

```text
llr_u3 = g(r0, r1, u2)
```

Then:

```text
if frozen_mask[3] = 1:
    u3 = 0
else:
    u3 = hard_decision(llr_u3)
```

### Step 8: Output

```text
u_hat = {u3, u2, u1, u0}
```

or equivalently, under bit-index convention:

```text
u_hat[0] = u0
u_hat[1] = u1
u_hat[2] = u2
u_hat[3] = u3
```

The exact packed-vector display must be consistent with the RTL and testbench convention.

---

## 8. RTL Architecture

The SC Decoder N=4 core contains:

```text
f units
g units
hard decision logic
frozen-mask mux logic
partial-sum XOR logic
output assignment
```

High-level architecture:

```text
Input LLRs
   |
   v
First-level f operations
   |
   v
Left N=2 decoding
   |
   v
Partial-sum generation
   |
   v
Right-branch g operations
   |
   v
Right N=2 decoding
   |
   v
u_hat[0:3]
```

The key idea is:

```text
f computes left LLRs
g computes right LLRs after partial decisions are available
```

---

## 9. Hard Decision Logic

The hard decision rule is:

```text
hard_decision(LLR) = 1 if LLR < 0
hard_decision(LLR) = 0 if LLR >= 0
```

In Verilog, for signed LLR:

```verilog
assign bit_decision = (llr_value < 0) ? 1'b1 : 1'b0;
```

With frozen-bit handling:

```verilog
assign u_i = frozen_mask[i] ? 1'b0 : hard_decision_i;
```

This pattern is repeated for each decoded bit.

---

## 10. Example RTL Structure

A simplified RTL structure is:

```verilog
// first-level left LLRs
sc_f_unit u_f0 (.a(llr0), .b(llr2), .y(l0));
sc_f_unit u_f1 (.a(llr1), .b(llr3), .y(l1));

// decode u0
sc_f_unit u_f_u0 (.a(l0), .b(l1), .y(llr_u0));
assign u0_hd = (llr_u0 < 0);
assign u0 = frozen_mask[0] ? 1'b0 : u0_hd;

// decode u1
sc_g_unit u_g_u1 (.a(l0), .b(l1), .u(u0), .y(llr_u1));
assign u1_hd = (llr_u1 < 0);
assign u1 = frozen_mask[1] ? 1'b0 : u1_hd;

// partial sums
assign p0 = u0 ^ u1;
assign p1 = u1;

// right branch
sc_g_unit u_g0 (.a(llr0), .b(llr2), .u(p0), .y(r0));
sc_g_unit u_g1 (.a(llr1), .b(llr3), .u(p1), .y(r1));
```

The actual RTL may be structured differently, but the schedule must remain equivalent.

---

## 11. Testbench Objective

The testbench should verify all relevant combinations of:

```text
input LLRs
frozen masks
expected u_hat
```

For a small N=4 decoder, exhaustive-style testing is feasible.

The testbench should compare RTL output against a reference SC decoding model.

Important verification goals:

```text
correct f operation usage
correct g operation usage
correct frozen-bit handling
correct hard decision
correct partial-sum generation
correct bit ordering
```

---

## 12. Confirmed Simulation Result

Project 5 achieved a strong simulation result.

Confirmed output:

```text
Compiling sc_decoder_n4...
Running simulation...
VCD info: dumpfile sim/waveforms/sc_decoder_n4.vcd opened for output.
====================================
Total tests  = 104976
Total errors = 0
ALL TESTS PASSED.
====================================
tb/tb_sc_decoder_n4.v:208: $finish called at 104976000 (1ps)
Simulation completed.
Waveform: sim/waveforms/sc_decoder_n4.vcd
```

This confirms that the RTL SC Decoder N=4 matches the reference model for all tested cases.

---

## 13. RTL Simulation Flow

Run simulation using the project script:

```bash
./sim/run_sc_decoder_n4.sh
```

A direct Icarus Verilog command may look like:

```bash
iverilog -g2012 -o sim/sc_decoder_n4_sim \
    rtl/abs_unit.v \
    rtl/min_comparator.v \
    rtl/abs_min_unit.v \
    rtl/sc_f_unit.v \
    rtl/sc_g_unit.v \
    rtl/sc_decoder_n4.v \
    tb/tb_sc_decoder_n4.v

vvp sim/sc_decoder_n4_sim
```

The exact file list depends on whether `sc_f_unit` and `sc_g_unit` are implemented directly or hierarchically.

---

## 14. What To Check In The Waveform

Open waveform:

```bash
gtkwave sim/waveforms/sc_decoder_n4.vcd
```

Important signals to inspect:

```text
llr0
llr1
llr2
llr3
frozen_mask
u_hat
intermediate f outputs
intermediate g outputs
partial sums
expected output
error_count
```

Important behavior:

```text
frozen bits must force u_i = 0
information bits must follow hard decision
right-branch LLRs must use correct partial sums
u_hat must match expected bit ordering
```

Waveform inspection is especially helpful for understanding the decoding tree.

---

## 15. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/abs_unit.v
read_verilog rtl/min_comparator.v
read_verilog rtl/abs_min_unit.v
read_verilog rtl/sc_f_unit.v
read_verilog rtl/sc_g_unit.v
read_verilog rtl/sc_decoder_n4.v

hierarchy -check -top sc_decoder_n4

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/sc_decoder_n4_synth.v
```

For top-level OpenLane wrapper:

```tcl
read_verilog rtl/sc_decoder_n4.v
read_verilog rtl/sc_decoder_n4_top.v

hierarchy -check -top sc_decoder_n4_top
...
```

Run synthesis:

```bash
yosys -s synth/sc_decoder_n4.ys | tee synth/reports/sc_decoder_n4_yosys.log
```

---

## 16. What To Check In The Yosys Report

Important fields:

```text
Number of wires
Number of wire bits
Number of cells
AND/NAND/OR/NOR count
XOR/XNOR count
MUX count
DFF count if using registered wrapper
```

For the decoder core, logic complexity is expected to be significantly higher than the standalone f or g unit.

Reason:

```text
multiple f operations
multiple g operations
partial-sum XORs
frozen-mask mux logic
hard-decision logic
routing between stages
```

---

## 17. Interpretation Of Synthesis Result

The SC Decoder N=4 is the first design where several algorithmic components are connected together.

Compared with primitive blocks, synthesis will show:

```text
more cells
more wires
more muxing
more XOR logic
more routing complexity
```

This is expected.

A successful synthesis result means that the complete SC decoder structure is synthesizable and ready for physical implementation.

---

## 18. OpenLane Top-Level Wrapper

For OpenLane, a registered top-level wrapper is useful.

The wrapper may include:

```text
input registers
combinational sc_decoder_n4 core
output register
```

This creates a register-to-register timing path and makes timing analysis clearer.

A typical wrapper may include:

```verilog
module sc_decoder_n4_top (
    input  wire              clk,
    input  wire              rst_n,
    input  wire signed [5:0] llr0,
    input  wire signed [5:0] llr1,
    input  wire signed [5:0] llr2,
    input  wire signed [5:0] llr3,
    input  wire        [3:0] frozen_mask,
    output reg         [3:0] u_hat
);
```

The actual wrapper should be documented according to the repository implementation.

---

## 19. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/sc_decoder_n4_top/
  config.tcl
  src/
    sc_decoder_n4.v
    sc_decoder_n4_top.v
```

The source folder may also include primitive modules if the decoder is hierarchical:

```text
abs_unit.v
min_comparator.v
abs_min_unit.v
sc_f_unit.v
sc_g_unit.v
sc_decoder_n4.v
sc_decoder_n4_top.v
```

A typical OpenLane configuration may include:

```tcl
set ::env(DESIGN_NAME) sc_decoder_n4_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "20"

set ::env(FP_SIZING) absolute

set ::env(DIE_AREA) "0 0 340 340"

set ::env(PL_TARGET_DENSITY) 0.30

set ::env(GRT_REPAIR_ANTENNAS) 1

set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1

set ::env(SYNTH_STRATEGY) "AREA 0"
```

The actual successful configuration should be preserved in the repository.

---

## 20. OpenLane Flow

Run OpenLane:

```bash
cd ~/OpenLane
make mount
```

Inside the container:

```bash
./flow.tcl -design sc_decoder_n4_top
```

After completion:

```bash
exit
```

Check result:

```bash
cd ~/OpenLane/designs/sc_decoder_n4_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final -name "*.gds"
cat $RUN_DIR/reports/manufacturability.rpt
head -n 5 $RUN_DIR/reports/metrics.csv
```

---

## 21. Confirmed OpenLane Clean Result

The final clean OpenLane run was:

```text
runs/RUN_2026.05.03_09.54.13
```

Final GDSII:

```text
runs/RUN_2026.05.03_09.54.13/results/final/gds/sc_decoder_n4_top.gds
```

Signoff summary:

```text
Design Name: sc_decoder_n4_top

Magic DRC Summary:
Total Magic DRC violations is 0

LVS Summary:
Number of nets: 458 | Number of nets: 458
Design is LVS clean.

Antenna Summary:
Pin violations: 0
Net violations: 0
```

This is the clean physical implementation result for SC Decoder N=4.

---

## 22. Important OpenLane Metrics

Important metrics from the clean run:

```text
flow_status = flow completed
DIEAREA_mm^2 = 0.1156
synth_cell_count = 343
wire_length = 15846
vias = 3020
Magic_violations = 0
pin_antenna_violations = 0
net_antenna_violations = 0
lvs_total_errors = 0
critical_path_ns = 10.81
CLOCK_PERIOD = 20 ns
suggested_clock_period = 20.0 ns
suggested_clock_frequency = 50.0 MHz
STD_CELL_LIBRARY = sky130_fd_sc_hd
```

---

## 23. Interpretation Of OpenLane Result

The OpenLane result confirms that the complete SC Decoder N=4 can be physically implemented.

This is more significant than implementing only primitive blocks because the design now includes:

```text
multiple f/g units
partial-sum logic
hard decisions
frozen-mask control
decoder output generation
```

The clean signoff means:

```text
DRC = 0
LVS clean
Antenna = 0
Timing clean at 20 ns
GDSII generated
```

This establishes the first complete decoder physical baseline.

---

## 24. Why Multiple OpenLane Runs Were Needed

Earlier OpenLane runs had antenna violations:

```text
Pin violations: 2
Net violations: 2
```

Then:

```text
Pin violations: 1
Net violations: 1
```

The final clean run achieved:

```text
Pin violations: 0
Net violations: 0
```

This shows an important physical-design lesson:

```text
A design may pass DRC and LVS but still fail antenna checks.
```

Antenna-clean signoff must be verified explicitly.

---

## 25. Result Summary

Final Project 5 result:

```text
RTL simulation: passed
Total tests: 104976
Total errors: 0
Status: ALL TESTS PASSED

OpenLane flow: completed
GDSII: generated
Magic DRC violations: 0
LVS: clean
Pin antenna violations: 0
Net antenna violations: 0
Timing: clean at 20 ns
```

Key quantitative metrics:

```text
Die area = 0.1156 mm²
Synth cell count = 343
Wire length = 15846
Vias = 3020
Critical path = 10.81 ns
Clock period = 20 ns
Suggested frequency = 50 MHz
```

---

## 26. Difference Between Encoder N=8 And Decoder N=4

Project 4 implemented a Polar Encoder N=8.

Project 5 implements an SC Decoder N=4.

They are very different.

| Feature | Polar Encoder N=8 | SC Decoder N=4 |
|---|---|---|
| Data type | bits | signed LLRs |
| Main logic | XOR network | f/g operations |
| Frozen mask | no | yes |
| Hard decision | no | yes |
| Partial sums | implicit | explicit |
| Sequential dependency | no | yes |
| Physical complexity | lower | higher |

This comparison is important because the decoder is much more algorithmically complex than the encoder.

---

## 27. Connection To SC Decoder N=8

The SC Decoder N=4 becomes a natural building block for SC Decoder N=8.

An N=8 decoder can be viewed as:

```text
top-level f stage
left N=4 decoder
partial-sum generation
top-level g stage
right N=4 decoder
```

Therefore, Project 5 is directly reused in Project 6.

Without a correct N=4 decoder, it is risky to implement N=8.

---

## 28. Common Problems And Debugging

### Problem 1: Wrong Frozen-Mask Convention

The project convention is:

```text
frozen_mask[i] = 1 → frozen → u_i = 0
frozen_mask[i] = 0 → information → hard decision
```

If this is reversed, many tests will fail.

---

### Problem 2: Wrong Hard Decision Rule

Correct rule:

```text
LLR < 0 → bit 1
LLR >= 0 → bit 0
```

If the sign convention is reversed, decoder outputs will be wrong.

---

### Problem 3: Wrong Partial Sum

For N=4:

```text
p0 = u0 ^ u1
p1 = u1
```

If partial sums are wrong, right-branch g operations will be wrong.

---

### Problem 4: Wrong g Input Order

The g operation is:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

Using `a - b` instead of `b - a` is a common error.

---

### Problem 5: Bit Ordering Mismatch

The packed vector `u_hat[3:0]` must be interpreted consistently.

Recommended convention:

```text
u_hat[0] = u0
u_hat[1] = u1
u_hat[2] = u2
u_hat[3] = u3
```

---

### Problem 6: OpenLane Antenna Violations

A design can be:

```text
DRC clean
LVS clean
but antenna not clean
```

Fixes may include:

```tcl
set ::env(GRT_REPAIR_ANTENNAS) 1
set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1
set ::env(DIODE_INSERTION_STRATEGY) 4
```

---

## 29. Lessons Learned

Project 5 teaches the following key lessons:

```text
1. A complete SC decoder requires coordination of f, g, hard decision, frozen mask, and partial sums.
2. The g operation depends on earlier decoded bits.
3. Partial sums are essential for right-branch decoding.
4. A small N=4 decoder is the best entry point before N=8.
5. Functional simulation and physical signoff must both be checked.
6. Antenna violations are a real physical-design issue.
7. SC Decoder N=4 provides the reusable conceptual foundation for N=8.
```

---

## 30. Role Of This Project In The Full Roadmap

Project 5 belongs to the baseline decoder layer.

The roadmap progression is:

```text
Project 0: validate RTL-to-GDSII flow
Project 1.1: signed addition
Project 1.2: signed subtraction
Project 1.3: absolute value
Project 1.4: minimum comparator
Project 1.5: absolute-minimum unit
Project 2: SC f unit
Project 3: SC g unit
Project 4: Polar Encoder N=8
Project 5: SC Decoder N=4
Project 6: SC Decoder N=8 baseline
Project 7: Scheduled/resource-shared N=8 architectures
```

Project 5 is the first complete decoder milestone.

It prepares the roadmap for:

```text
SC Decoder N=8
OpenLane N=8 baseline
scheduled decoder
resource-shared decoder
future N=16 architecture
```

---

## 31. What This Project Is Not

Project 5 is not a full research contribution by itself.

It should not be presented as:

```text
a novel Polar decoder architecture
a complete scalable decoder
a Q1-level contribution
```

Instead, it should be presented as:

```text
a verified complete small SC decoder
a teaching and mentoring milestone
a reusable baseline for larger decoder architectures
```

---

## 32. Conclusion

Project 5 successfully implements, verifies, and physically validates a complete SC Decoder N=4.

The design passed:

```text
104976 simulation tests
0 simulation errors
OpenLane clean physical implementation
DRC = 0
LVS clean
Antenna = 0
Timing clean at 20 ns
```

This project is a major milestone because it is the first complete SC decoder in the roadmap.

The next step is Project 5.5: Review and Comparison of Polar Encoder N=8 and SC Decoder N=4, followed by Project 6: SC Decoder N=8.