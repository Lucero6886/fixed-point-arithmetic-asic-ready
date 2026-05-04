# Project 1.3: Absolute Value Unit

## 1. Project Objective

Project 1.3 implements and verifies an absolute value unit for signed fixed-point numbers.

The main objective is to build a reliable arithmetic primitive that computes the magnitude of a signed input:

```text
y = |x|
```

This block is required for the SC Polar decoder f operation.

The SC f operation uses the min-sum approximation:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Therefore, before implementing the complete f unit, the decoder must be able to compute:

```text
|a|
|b|
```

At the end of this project, the learner should understand:

```text
how signed magnitude is computed in two's-complement hardware
why the output width may need one extra bit
how to verify absolute value logic exhaustively
how this block supports the SC f operation
how a small arithmetic primitive is taken through simulation, synthesis, and OpenLane
```

---

## 2. Why This Project Is Important

SC Polar decoding operates on LLR values.

LLR values are signed. The sign indicates the likely decoded bit, while the magnitude indicates reliability.

For the min-sum f operation, the decoder needs to compare magnitudes:

```text
min(|a|, |b|)
```

This means the decoder must first compute absolute values.

The absolute value unit is therefore a direct building block for:

```text
abs_min_unit
SC f unit
resource-shared f/g datapath
SC decoder N=4
SC decoder N=8
larger scheduled SC decoder architectures
```

The central question of this project is:

```text
Can we design, verify, synthesize, and physically implement an absolute value unit that correctly handles signed LLR inputs?
```

---

## 3. Relationship With Previous Projects

Project 1.1 implemented:

```text
signed addition
```

Project 1.2 implemented:

```text
signed subtraction
```

Project 1.3 now implements:

```text
signed absolute value
```

Together, these projects build the fixed-point arithmetic foundation for SC decoder hardware.

The progression is:

```text
signed_adder
→ signed_subtractor
→ abs_unit
→ min_comparator
→ abs_min_unit
→ sc_f_unit
→ sc_g_unit
```

The absolute value unit is especially important for the left-branch SC f computation.

---

## 4. Technical Background

### 4.1 Two's-Complement Signed Range

For a W-bit signed number, the representable range is:

```text
-2^(W-1) to 2^(W-1)-1
```

For W = 6:

```text
minimum value = -32
maximum value = 31
```

Examples:

```text
000000 = 0
000001 = 1
011111 = 31
111111 = -1
100000 = -32
```

---

### 4.2 Absolute Value In Two's Complement

The absolute value function is:

```text
if x >= 0:
    |x| = x

if x < 0:
    |x| = -x
```

In hardware, this can be implemented as:

```text
check sign bit
if sign bit = 0, output x
if sign bit = 1, output two's-complement negation of x
```

The sign bit of a W-bit signed number is:

```text
x[W-1]
```

---

### 4.3 Why Output Width Should Be W+1

The most important corner case is the most negative input.

For W = 6:

```text
x = -32
```

The absolute value is:

```text
|x| = 32
```

But a 6-bit signed number can only represent:

```text
-32 to 31
```

Therefore, the magnitude 32 cannot be represented as a positive 6-bit signed number.

To safely represent all magnitudes, the output should have:

```text
W+1 bits
```

For W = 6:

```text
input  range: -32 to 31
output range needed: 0 to 32
```

Thus, a safe output is:

```verilog
output wire [W:0] y;
```

---

## 5. Design Under Test

The design under test is a parameterized absolute value unit.

A typical interface is:

```verilog
module abs_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] x,
    output wire        [W:0]   y
);
```

The function is:

```text
y = |x|
```

This is a combinational design.

It has:

```text
no clock
no reset
no internal register
```

A registered wrapper may be used later for OpenLane timing analysis.

---

## 6. Expected File Structure

The expected file structure for Project 1.3 is:

```text
rtl/
  abs_unit.v
  abs_unit_top.v

tb/
  tb_abs_unit.v
  tb_abs_unit_top.v

sim/
  run_abs_unit.sh
  run_abs_unit_top.sh
  waveforms/
    abs_unit.vcd
    abs_unit_top.vcd

synth/
  abs_unit.ys
  abs_unit_top.ys
  reports/
    abs_unit_yosys.log
    abs_unit_top_yosys.log
  netlist/
    abs_unit_synth.v
    abs_unit_top_synth.v

asic_openlane/
  abs_unit_top/
    config/
    reports/
    results/
```

Depending on the actual repository version, some file names may be slightly different.

---

## 7. RTL Design Explanation

The absolute value unit checks the sign bit.

For a W-bit signed input `x`:

```text
sign bit = x[W-1]
```

If the sign bit is 0:

```text
x is non-negative
y = x
```

If the sign bit is 1:

```text
x is negative
y = -x
```

Because the output has W+1 bits, the input should be sign-extended before negation.

A robust implementation style is:

```verilog
wire signed [W:0] x_ext;

assign x_ext = {x[W-1], x};

assign y = (x < 0) ? -x_ext : x_ext;
```

The output `y` is usually treated as an unsigned magnitude.

---

## 8. Example RTL Code

A typical implementation is:

```verilog
`timescale 1ns/1ps

module abs_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] x,
    output wire        [W:0]   y
);

    wire signed [W:0] x_ext;

    assign x_ext = {x[W-1], x};

    assign y = (x < 0) ? -x_ext : x_ext;

endmodule
```

Important points:

```text
x is signed.
x_ext has W+1 bits.
negative values are converted by two's-complement negation.
y is a magnitude and does not need to be signed.
```

---

## 9. Testbench Objective

The testbench should verify the absolute value for all possible input values.

For W = 6:

```text
x ranges from -32 to 31
```

The total number of test cases is:

```text
64
```

For each input value, the testbench should compute:

```text
expected = |x|
```

and compare the DUT output with the expected value.

---

## 10. Important Test Cases

Although exhaustive testing covers all cases, these cases are especially important:

```text
x = 0    → y = 0
x = 1    → y = 1
x = -1   → y = 1
x = 15   → y = 15
x = -15  → y = 15
x = 31   → y = 31
x = -32  → y = 32
```

The most important corner case is:

```text
x = -32 → y = 32
```

This verifies that the output width is sufficient.

---

## 11. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/abs_unit_sim \
    rtl/abs_unit.v \
    tb/tb_abs_unit.v

vvp sim/abs_unit_sim
```

If a project script exists, use:

```bash
./sim/run_abs_unit.sh
```

Expected result:

```text
Total tests  = 64
Total errors = 0
ALL TESTS PASSED
```

---

## 12. Confirmed Simulation Result

Project 1.3 achieved exhaustive functional verification.

Confirmed result:

```text
VCD info: dumpfile sim/waveforms/abs_unit.vcd opened for output.
====================================
Total tests  = 64
Total errors = 0
ALL TESTS PASSED.
====================================
tb/tb_abs_unit.v:66: $finish called at 64000 (1ps)
```

This means all 64 possible 6-bit signed input values were tested and passed.

---

## 13. Top-Level Wrapper Test

A top-level wrapper was also verified.

Confirmed result:

```text
VCD info: dumpfile sim/waveforms/abs_unit_top.vcd opened for output.
PASS at time 26000: x=0 y=0
PASS at time 36000: x=1 y=1
PASS at time 46000: x=-1 y=1
PASS at time 56000: x=15 y=15
PASS at time 66000: x=-15 y=15
PASS at time 76000: x=31 y=31
PASS at time 86000: x=-32 y=32
PASS hold test: y holds value 32
====================================
ALL TESTS PASSED.
====================================
tb/tb_abs_unit_top.v:102: $finish called at 96000 (1ps)
```

This confirms not only combinational correctness, but also correct behavior of the top-level wrapper used for physical implementation.

---

## 14. What To Check In The Waveform

Open the waveform using:

```bash
gtkwave sim/waveforms/abs_unit.vcd
```

or:

```bash
gtkwave sim/waveforms/abs_unit_top.vcd
```

Signals to inspect:

```text
x
y
expected
error_count
```

Important waveform points:

```text
x = -1  → y = 1
x = -15 → y = 15
x = -32 → y = 32
x = 31  → y = 31
```

The case `x = -32` is the most important because it checks whether the output width is large enough.

---

## 15. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/abs_unit.v

hierarchy -check -top abs_unit

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/abs_unit_synth.v
```

For the top wrapper:

```tcl
read_verilog rtl/abs_unit.v
read_verilog rtl/abs_unit_top.v

hierarchy -check -top abs_unit_top

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/abs_unit_top_synth.v
```

Run synthesis:

```bash
yosys -s synth/abs_unit.ys | tee synth/reports/abs_unit_yosys.log
```

or:

```bash
yosys -s synth/abs_unit_top.ys | tee synth/reports/abs_unit_top_yosys.log
```

---

## 16. What To Check In The Yosys Report

Important fields:

```text
Number of wires
Number of wire bits
Number of cells
MUX cells
XOR/XNOR cells
NAND/AND logic
DFF cells if using a registered wrapper
```

The basic `abs_unit` is combinational and should not contain registers.

If `abs_unit_top` includes input/output registers or hold logic, then DFF cells may appear.

---

## 17. Interpretation Of Synthesis Result

The absolute value unit is expected to synthesize into:

```text
sign detection logic
conditional negation logic
mux/select logic
XOR/carry logic for two's-complement negation
```

The design is small, but it is more complex than a simple wire assignment because negative values require two's-complement conversion.

Important interpretation:

```text
The absolute value unit converts signed LLR values into unsigned magnitudes.
It is a required sub-block for the SC f operation.
```

---

## 18. OpenLane Top-Level Wrapper

For OpenLane, a top-level wrapper may be used.

A possible wrapper interface is:

```verilog
module abs_unit_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [5:0] x,
    output reg         valid_out,
    output reg  [6:0]  y
);
```

The wrapper may register the output to create a clear timing path.

A simpler wrapper may also be used depending on the repository version.

The purpose of the wrapper is:

```text
fix the parameter width
provide a stable top-level module
make OpenLane implementation easier
support timing analysis
```

---

## 19. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/abs_unit_top/
  config.tcl
  src/
    abs_unit.v
    abs_unit_top.v
```

A typical configuration may include:

```tcl
set ::env(DESIGN_NAME) abs_unit_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute

set ::env(DIE_AREA) "0 0 120 120"

set ::env(PL_TARGET_DENSITY) 0.45

set ::env(GRT_REPAIR_ANTENNAS) 1

set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1

set ::env(SYNTH_STRATEGY) "AREA 0"
```

The actual configuration should be recorded from the real run.

---

## 20. OpenLane Flow

Run OpenLane from the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the container:

```bash
./flow.tcl -design abs_unit_top
```

After completion:

```bash
exit
```

Check result:

```bash
cd ~/OpenLane/designs/abs_unit_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final -name "*.gds"
cat $RUN_DIR/reports/manufacturability.rpt
head -n 5 $RUN_DIR/reports/metrics.csv
```

---

## 21. Confirmed OpenLane Result

Project 1.3 achieved a clean OpenLane implementation.

Confirmed run:

```text
runs/RUN_2026.05.03_07.40.22
```

Final GDSII:

```text
runs/RUN_2026.05.03_07.40.22/results/final/gds/abs_unit_top.gds
```

Signoff result:

```text
Design Name: abs_unit_top

Magic DRC Summary:
Total Magic DRC violations is 0

LVS Summary:
Number of nets: 60 | Number of nets: 60
Design is LVS clean.

Antenna Summary:
Pin violations: 0
Net violations: 0
```

Important metrics:

```text
flow_status = flow completed
DIEAREA_mm^2 = 0.0144
synth_cell_count = 27
wire_length = 1630
vias = 294
WNS = 0.0
TNS = 0.0
critical_path_ns = 1.22
CLOCK_PERIOD = 10 ns
suggested_clock_frequency = 100 MHz
STD_CELL_LIBRARY = sky130_fd_sc_hd
```

---

## 22. Interpretation Of The OpenLane Result

The OpenLane result confirms that the absolute value unit can be physically implemented.

The key clean signoff results are:

```text
Magic DRC = 0
LVS clean
Antenna = 0
Timing clean
```

This means:

```text
the generated layout follows design rules
the layout matches the synthesized netlist
there are no remaining antenna violations
the design satisfies the selected timing constraint
GDSII was generated successfully
```

The result is important because `abs_unit` will be reused in later f-operation hardware.

---

## 23. Result Summary

Final Project 1.3 result:

```text
RTL abs_unit simulation: passed
Total abs_unit tests: 64
Total abs_unit errors: 0

RTL abs_unit_top simulation: passed
Important cases:
x = 0   → y = 0
x = 1   → y = 1
x = -1  → y = 1
x = 15  → y = 15
x = -15 → y = 15
x = 31  → y = 31
x = -32 → y = 32

OpenLane flow: completed
GDSII: generated
Magic DRC violations: 0
LVS: clean
Pin antenna violations: 0
Net antenna violations: 0
Timing: clean
```

Key quantitative result:

```text
OpenLane synth cell count = 27
OpenLane die area = 0.0144 mm²
OpenLane critical path = 1.22 ns
OpenLane clock period = 10 ns
```

---

## 24. Why The Most Negative Value Matters

For W = 6, the most negative value is:

```text
-32
```

Its magnitude is:

```text
32
```

This is outside the positive range of a 6-bit signed value:

```text
maximum 6-bit signed positive value = 31
```

Therefore, if the output were only 6 bits, the result could be wrong.

This is why the output width is:

```text
W+1
```

This point is critical for later SC f operation, because wrong magnitude computation can cause wrong decoding decisions.

---

## 25. Connection To SC f Operation

The SC f operation is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

The absolute value unit provides:

```text
|a|
|b|
```

The next required block is a minimum comparator, which selects:

```text
min(|a|, |b|)
```

Then the sign logic applies:

```text
sign(a) XOR sign(b)
```

Therefore, the path toward the f unit is:

```text
abs_unit
→ min_comparator
→ abs_min_unit
→ sc_f_unit
```

---

## 26. Common Problems And Debugging

### Problem 1: Wrong Output For Most Negative Input

Example:

```text
x = -32
expected y = 32
```

Possible cause:

```text
output width is only W bits
input was negated before sign extension
```

Fix:

```text
use W+1 output bits
sign-extend before negation
```

---

### Problem 2: Output Declared As Signed Incorrectly

The output is a magnitude and can be treated as unsigned.

Recommended style:

```verilog
output wire [W:0] y;
```

---

### Problem 3: Verilog Negation Width Issue

If negation is applied directly to a W-bit value, the result may be truncated.

Safer style:

```verilog
wire signed [W:0] x_ext;
assign x_ext = {x[W-1], x};
assign y = (x < 0) ? -x_ext : x_ext;
```

---

### Problem 4: Testbench Does Not Cover Boundary Values

If the testbench only checks random values, it may miss the most important corner case.

The testbench must include:

```text
x = -32
```

for W = 6.

---

### Problem 5: OpenLane Top Module Mismatch

Possible causes:

```text
DESIGN_NAME does not match top module
wrapper file missing
src folder missing RTL file
```

Fix:

```text
check config.tcl
check OpenLane src folder
check RTL module name
```

---

## 27. Lessons Learned

Project 1.3 teaches the following key lessons:

```text
1. Absolute value is essential for LLR magnitude computation.
2. Two's-complement absolute value must handle the most negative input carefully.
3. Output width should be W+1 for safe magnitude representation.
4. Exhaustive testing is simple and powerful for small arithmetic blocks.
5. The abs unit is a direct building block for the SC f operation.
6. A small arithmetic primitive can be taken through simulation and OpenLane signoff.
```

---

## 28. Role Of This Project In The Full Roadmap

Project 1.3 belongs to the arithmetic primitive layer of the full roadmap.

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
Project 6–7: SC Decoder N=8 architecture exploration
```

The absolute value unit will be reused in:

```text
abs_min_unit
SC f unit
SC Decoder N=4
SC Decoder N=8
resource-shared SC decoder datapath
```

---

## 29. What This Project Is Not

Project 1.3 is not a standalone research contribution.

It should not be presented as:

```text
a novel absolute value architecture
an optimized arithmetic circuit
a standalone publication result
```

Instead, it should be presented as:

```text
a verified arithmetic primitive
a training milestone
a reusable building block for SC decoder hardware
```

---

## 30. Conclusion

Project 1.3 successfully implements, verifies, synthesizes, and physically validates an absolute value unit.

The design correctly handles all 6-bit signed inputs, including the most important corner case:

```text
x = -32 → y = 32
```

The OpenLane result confirms that the design can be physically implemented with:

```text
Magic DRC = 0
LVS clean
Antenna = 0
Timing clean
```

This project establishes a reliable magnitude-computation primitive for the SC f operation.

The next step is Project 1.4: Minimum Comparator.