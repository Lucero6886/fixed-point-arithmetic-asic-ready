# Project 1.4: Minimum Comparator

## 1. Project Objective

Project 1.4 implements and verifies a minimum comparator for unsigned magnitude values.

The main objective is to build a small combinational hardware block that selects the smaller value between two input magnitudes:

```text
y = min(a, b)
```

This block is required for the SC Polar decoder f operation.

The SC f operation using min-sum approximation is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Project 1.3 already implemented:

```text
|x|
```

Project 1.4 now implements:

```text
min(|a|, |b|)
```

At the end of this project, the learner should understand:

```text
how magnitude comparison is implemented in hardware
why the comparator operates on unsigned values
how the minimum comparator supports the SC f operation
how to verify comparator behavior exhaustively
how this block fits into the larger SC decoder datapath
```

---

## 2. Why This Project Is Important

The SC f operation needs to compute the smaller magnitude of two LLR values.

Given two signed LLRs:

```text
a
b
```

the f operation first computes:

```text
abs_a = |a|
abs_b = |b|
```

Then it selects:

```text
min_abs = min(abs_a, abs_b)
```

This selected magnitude is then combined with the sign logic:

```text
sign = sign(a) XOR sign(b)
```

Therefore, the minimum comparator is a direct building block for:

```text
abs_min_unit
SC f unit
SC Decoder N=4
SC Decoder N=8
resource-shared f/g datapath
```

The central question of this project is:

```text
Can we design, verify, synthesize, and physically implement a comparator that correctly selects the smaller of two magnitude values?
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

Project 1.3 implemented:

```text
absolute value
```

Project 1.4 now implements:

```text
minimum magnitude selection
```

The roadmap toward the SC f unit is:

```text
abs_unit
→ min_comparator
→ abs_min_unit
→ sc_f_unit
```

The minimum comparator does not operate directly on signed LLRs. It operates on magnitudes, which are non-negative.

Therefore, its inputs are treated as unsigned numbers.

---

## 4. Technical Background

### 4.1 Magnitude Values

After taking the absolute value of a signed W-bit input, the magnitude may require W+1 bits.

For example, if W = 6:

```text
input signed range = -32 to 31
maximum magnitude = 32
```

So the magnitude width should be:

```text
MAGW = W + 1 = 7
```

The minimum comparator should therefore compare unsigned values such as:

```text
abs_a[6:0]
abs_b[6:0]
```

---

### 4.2 Minimum Selection

The minimum operation is:

```text
if a <= b:
    y = a
else:
    y = b
```

A stable deterministic tie rule is useful.

For example, when:

```text
a = b
```

we can choose:

```text
y = a
```

This does not change the mathematical result because both values are equal, but it makes the RTL behavior deterministic.

---

### 4.3 Comparator In Hardware

A comparator is synthesized into combinational logic.

For an unsigned comparator, the hardware checks the bits from most significant to least significant.

Conceptually:

```text
compare MSB first
if one value is smaller, select it
if equal, compare the next bit
```

In Verilog, this can be written simply as:

```verilog
assign y = (a <= b) ? a : b;
```

The synthesis tool maps this expression into gates and multiplexers.

---

## 5. Design Under Test

The design under test is a parameterized unsigned minimum comparator.

A typical interface is:

```verilog
module min_comparator #(
    parameter W = 7
)(
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    output wire [W-1:0] y
);
```

The function is:

```text
y = min(a, b)
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

The expected file structure for Project 1.4 is:

```text
rtl/
  min_comparator.v
  min_comparator_top.v

tb/
  tb_min_comparator.v
  tb_min_comparator_top.v

sim/
  run_min_comparator.sh
  run_min_comparator_top.sh
  waveforms/
    min_comparator.vcd
    min_comparator_top.vcd

synth/
  min_comparator.ys
  min_comparator_top.ys
  reports/
    min_comparator_yosys.log
    min_comparator_top_yosys.log
  netlist/
    min_comparator_synth.v
    min_comparator_top_synth.v

asic_openlane/
  min_comparator_top/
    config/
    reports/
    results/
```

Depending on the actual repository version, some file names may be slightly different.

---

## 7. RTL Design Explanation

The minimum comparator selects the smaller of two unsigned values.

The core expression is:

```verilog
assign y = (a <= b) ? a : b;
```

This means:

```text
if a is less than or equal to b:
    output a
else:
    output b
```

The tie case uses `a`:

```text
if a = b:
    y = a
```

Since `a` and `b` are magnitudes, they should be declared as unsigned vectors.

---

## 8. Example RTL Code

A typical implementation is:

```verilog
`timescale 1ns/1ps

module min_comparator #(
    parameter W = 7
)(
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    output wire [W-1:0] y
);

    assign y = (a <= b) ? a : b;

endmodule
```

Important points:

```text
a and b are unsigned magnitudes.
y is also an unsigned magnitude.
The comparator is purely combinational.
The tie case selects a.
```

---

## 9. Testbench Objective

The testbench should verify the comparator for all possible input combinations.

For W = 7:

```text
a ranges from 0 to 127
b ranges from 0 to 127
```

The total number of input combinations is:

```text
128 × 128 = 16384
```

If the project uses a smaller width, the test count should be adjusted accordingly.

For each pair `(a,b)`, the testbench should compute:

```text
expected = (a <= b) ? a : b
```

and compare it against the RTL output.

---

## 10. Important Test Cases

Although exhaustive testing covers all cases, the following cases are especially important:

```text
a = 0,   b = 0   → y = 0
a = 0,   b = 5   → y = 0
a = 5,   b = 0   → y = 0
a = 7,   b = 7   → y = 7
a = 31,  b = 32  → y = 31
a = 32,  b = 31  → y = 31
a = 127, b = 0   → y = 0
a = 0,   b = 127 → y = 0
```

These cases verify:

```text
zero behavior
a < b
a > b
a = b
maximum value
tie behavior
```

---

## 11. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/min_comparator_sim \
    rtl/min_comparator.v \
    tb/tb_min_comparator.v

vvp sim/min_comparator_sim
```

If a project script exists, use:

```bash
./sim/run_min_comparator.sh
```

Expected result for W = 7:

```text
Total tests  = 16384
Total errors = 0
ALL TESTS PASSED
```

If the design uses another width, record the actual number of tests in the result section.

---

## 12. Suggested Testbench Structure

A typical exhaustive testbench should:

```text
1. Loop through all values of a.
2. Loop through all values of b.
3. Apply a and b to the DUT.
4. Wait for combinational propagation.
5. Compute expected = min(a,b).
6. Compare y with expected.
7. Count errors.
```

A simplified checking pattern is:

```verilog
for (ia = 0; ia < (1 << W); ia = ia + 1) begin
    for (ib = 0; ib < (1 << W); ib = ib + 1) begin
        a = ia[W-1:0];
        b = ib[W-1:0];
        #1;

        expected = (ia <= ib) ? ia : ib;

        if (y !== expected[W-1:0]) begin
            error_count = error_count + 1;
        end

        test_count = test_count + 1;
    end
end
```

---

## 13. What To Check In The Waveform

If a waveform is generated, open it using:

```bash
gtkwave sim/waveforms/min_comparator.vcd
```

Signals to inspect:

```text
a
b
y
expected
test_count
error_count
```

Useful waveform points:

```text
a = 0,  b = 5  → y = 0
a = 5,  b = 0  → y = 0
a = 7,  b = 7  → y = 7
a = 32, b = 31 → y = 31
```

Because the testbench should be exhaustive, waveform inspection is mainly useful for debugging and teaching.

---

## 14. Expected Simulation Result

Project 1.4 is considered functionally correct if the simulation reports:

```text
Total errors = 0
ALL TESTS PASSED
```

Record the actual result here:

```text
Actual simulation result:
Total tests  =
Total errors =
Status       =
```

If the repository already contains the final simulation log, paste the exact result in this section.

---

## 15. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/min_comparator.v

hierarchy -check -top min_comparator

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/min_comparator_synth.v
```

For a top-level wrapper:

```tcl
read_verilog rtl/min_comparator.v
read_verilog rtl/min_comparator_top.v

hierarchy -check -top min_comparator_top

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/min_comparator_top_synth.v
```

Run synthesis:

```bash
yosys -s synth/min_comparator.ys | tee synth/reports/min_comparator_yosys.log
```

or:

```bash
yosys -s synth/min_comparator_top.ys | tee synth/reports/min_comparator_top_yosys.log
```

---

## 16. What To Check In The Yosys Report

Important fields:

```text
Number of wires
Number of wire bits
Number of cells
MUX cells
logic gate breakdown
DFF cells if using a registered wrapper
```

The basic `min_comparator` is combinational and should not contain flip-flops.

Expected logic types may include:

```text
MUX
AND
OR
NAND
NOR
XOR/XNOR depending on optimization
```

---

## 17. Interpretation Of Synthesis Result

The minimum comparator is expected to synthesize into comparison logic and selection logic.

The selection part is equivalent to a multiplexer:

```text
if a <= b:
    y = a
else:
    y = b
```

Therefore, some mux-related cells may appear in synthesis reports.

Important interpretation:

```text
The comparator transforms a high-level relational operator into gate-level comparison and selection logic.
```

The exact cell count depends on:

```text
bit width
Yosys optimization
target mapping
whether a wrapper is used
```

---

## 18. OpenLane Top-Level Wrapper

For OpenLane, a fixed-parameter top-level wrapper may be used.

A simple combinational wrapper could be:

```verilog
module min_comparator_top (
    input  wire [6:0] a,
    input  wire [6:0] b,
    output wire [6:0] y
);

    min_comparator #(
        .W(7)
    ) u_min (
        .a(a),
        .b(b),
        .y(y)
    );

endmodule
```

A registered wrapper may also be used to create clear timing paths:

```text
input registers
combinational comparator
output register
```

The actual project wrapper should be recorded based on the repository implementation.

---

## 19. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/min_comparator_top/
  config.tcl
  src/
    min_comparator.v
    min_comparator_top.v
```

A typical OpenLane configuration may include:

```tcl
set ::env(DESIGN_NAME) min_comparator_top

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

If the wrapper is purely combinational, the clock settings may differ.

The actual OpenLane configuration should be recorded from the real run.

---

## 20. OpenLane Flow

Run OpenLane from the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the container:

```bash
./flow.tcl -design min_comparator_top
```

After completion:

```bash
exit
```

Check result:

```bash
cd ~/OpenLane/designs/min_comparator_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final -name "*.gds"
cat $RUN_DIR/reports/manufacturability.rpt
head -n 5 $RUN_DIR/reports/metrics.csv
```

---

## 21. Expected OpenLane Success Criteria

The OpenLane run is considered successful if:

```text
flow_status = completed
GDSII generated
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
```

If timing is checked, also record:

```text
WNS
TNS
critical_path_ns
CLOCK_PERIOD
```

---

## 22. Actual OpenLane Result

Fill this section with the actual result from the repository/OpenLane run.

```text
Run directory:
GDSII file:
Flow status:
Magic DRC violations:
LVS:
Pin antenna violations:
Net antenna violations:
WNS:
TNS:
Critical path:
Clock period:
Die area:
Synth cell count:
Wire length:
Vias:
```

Suggested summary format:

```text
Flow completed
GDSII generated
Magic DRC violations = 0
LVS clean
Pin antenna violations = 0
Net antenna violations = 0
```

---

## 23. Interpretation Of The OpenLane Result

If the OpenLane run is clean, it confirms that the minimum comparator can be physically implemented.

The key physical validation points are:

```text
the layout follows design rules
the layout matches the synthesized netlist
antenna violations are resolved
the design satisfies the selected timing configuration
```

This matters because the comparator will later be used inside the SC f operation.

---

## 24. Difference Between Absolute Value And Minimum Comparator

The absolute value unit converts a signed value to a magnitude:

```text
x → |x|
```

The minimum comparator selects the smaller magnitude:

```text
min(|a|, |b|)
```

They solve different subproblems.

Together, they form the magnitude path of the SC f operation:

```text
a, b
→ abs_a, abs_b
→ min(abs_a, abs_b)
```

---

## 25. Connection To SC f Operation

The SC f operation is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

The minimum comparator provides:

```text
min(|a|, |b|)
```

The complete f unit also needs sign logic:

```text
sign = sign(a) XOR sign(b)
```

Therefore, the implementation path is:

```text
abs_unit
→ min_comparator
→ abs_min_unit
→ sign logic
→ sc_f_unit
```

---

## 26. Common Problems And Debugging

### Problem 1: Inputs Treated As Signed Instead Of Unsigned

The comparator should compare magnitudes.

Magnitudes are non-negative.

Recommended style:

```verilog
input wire [W-1:0] a;
input wire [W-1:0] b;
```

Avoid declaring these magnitude inputs as signed unless there is a specific reason.

---

### Problem 2: Wrong Tie Behavior

If `a = b`, the output should still equal that same value.

Using:

```verilog
assign y = (a <= b) ? a : b;
```

selects `a` when equal.

Using:

```verilog
assign y = (a < b) ? a : b;
```

selects `b` when equal.

Both are mathematically correct, but the behavior should be consistent and documented.

---

### Problem 3: Testbench Does Not Cover All Cases

For W = 7, all values are:

```text
0 to 127
```

The full test should cover:

```text
128 × 128 = 16384 input pairs
```

---

### Problem 4: Width Mismatch With abs_unit

If `abs_unit` outputs W+1 bits, the minimum comparator must use the same magnitude width.

Example:

```text
signed input width W = 6
abs output width = 7
min comparator input width = 7
```

A mismatch can cause truncation and wrong f-unit behavior.

---

### Problem 5: OpenLane Top Module Mismatch

Possible causes:

```text
DESIGN_NAME does not match top module
wrapper file missing
wrong source files copied into OpenLane src folder
```

Fix:

```text
check config.tcl
check src folder
check RTL module name
check OpenLane synthesis log
```

---

## 27. Lessons Learned

Project 1.4 teaches the following key lessons:

```text
1. The minimum comparator operates on unsigned magnitudes, not signed LLRs.
2. The comparator is essential for the min-sum SC f operation.
3. The magnitude width must match the abs_unit output width.
4. Exhaustive verification is feasible for small comparator widths.
5. A simple relational expression in Verilog is synthesized into gate-level comparison and selection logic.
6. This block is a necessary step before building abs_min_unit and sc_f_unit.
```

---

## 28. Role Of This Project In The Full Roadmap

Project 1.4 belongs to the arithmetic and comparison primitive layer.

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

The minimum comparator will be reused in:

```text
abs_min_unit
SC f unit
SC Decoder N=4
SC Decoder N=8
resource-shared SC decoder datapath
```

---

## 29. What This Project Is Not

Project 1.4 is not a standalone research contribution.

It should not be presented as:

```text
a novel comparator architecture
an optimized comparator design
a standalone publication result
```

Instead, it should be presented as:

```text
a verified comparison primitive
a training milestone
a reusable building block for SC decoder hardware
```

---

## 30. Conclusion

Project 1.4 implements and verifies a minimum comparator for unsigned magnitude values.

This block selects:

```text
min(|a|, |b|)
```

which is required by the min-sum SC f operation.

The project strengthens the arithmetic foundation needed for later SC Polar decoder hardware.

The next step is Project 1.5: Absolute-Minimum Unit, which combines the absolute value unit and the minimum comparator into a reusable magnitude-selection block.