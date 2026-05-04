# Project 1.5: Absolute-Minimum Unit

## 1. Project Objective

Project 1.5 implements and verifies the absolute-minimum unit.

The absolute-minimum unit combines two previously verified primitive blocks:

```text
Project 1.3: abs_unit
Project 1.4: min_comparator
```

The main function of this unit is:

```text
y = min(|a|, |b|)
```

where `a` and `b` are signed fixed-point LLR inputs.

This block is the magnitude-processing core of the SC f operation.

The SC f operation is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Project 1.5 focuses on the magnitude part:

```text
min(|a|, |b|)
```

At the end of this project, the learner should understand:

```text
how to combine verified primitive modules into a larger datapath
how absolute value and minimum comparison form the magnitude path of SC f
how to verify a composed arithmetic block
how hierarchical RTL design supports scalable hardware construction
how this unit prepares the implementation of the SC f unit
```

---

## 2. Why This Project Is Important

The SC f operation is one of the two fundamental operations in successive cancellation Polar decoding.

The f operation can be decomposed into two parts:

```text
1. Magnitude path:
   min(|a|, |b|)

2. Sign path:
   sign(a) XOR sign(b)
```

Project 1.5 builds the magnitude path.

This is important because the decoder cannot compute the f operation correctly without first selecting the smaller magnitude of the two input LLRs.

The absolute-minimum unit will be reused in:

```text
SC f unit
SC Decoder N=4
SC Decoder N=8
scheduled SC decoder
resource-shared SC decoder datapath
```

The central question of this project is:

```text
Can we combine the absolute-value and minimum-comparator primitives into a reusable magnitude-selection block for SC decoding?
```

---

## 3. Relationship With Previous Projects

The previous primitive projects are:

```text
Project 1.1: signed_adder
Project 1.2: signed_subtractor
Project 1.3: abs_unit
Project 1.4: min_comparator
```

Project 1.5 combines:

```text
abs_unit + min_comparator
```

to create:

```text
abs_min_unit
```

The design path is:

```text
signed LLR inputs
→ absolute value units
→ unsigned magnitudes
→ minimum comparator
→ selected minimum magnitude
```

This block is not yet the complete f unit because it does not apply the final sign. That will be done in Project 2.

---

## 4. Technical Background

### 4.1 LLR Magnitude

LLR values are signed.

For a signed input `a`, its magnitude is:

```text
|a|
```

For two LLR inputs `a` and `b`, the f operation needs:

```text
min(|a|, |b|)
```

This operation selects the less reliable magnitude between the two LLRs.

---

### 4.2 Why The Minimum Magnitude Is Used

In the min-sum approximation of SC decoding, the f operation is approximated as:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

The magnitude of the output is determined by the smaller magnitude of the two inputs.

Intuitively:

```text
If one input is unreliable, the combined reliability should not be stronger than the weaker input.
```

Therefore, the minimum magnitude is used.

---

### 4.3 Width Convention

If the input LLR width is W, then each input has range:

```text
-2^(W-1) to 2^(W-1)-1
```

For W = 6:

```text
input range = -32 to 31
```

The maximum absolute value is:

```text
|-32| = 32
```

Therefore, the absolute value output requires:

```text
W+1 bits
```

For W = 6:

```text
magnitude width = 7 bits
```

Thus, the absolute-minimum unit should output a magnitude with width:

```text
W+1
```

---

## 5. Design Under Test

The design under test is a parameterized absolute-minimum unit.

A typical interface is:

```verilog
module abs_min_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire        [W:0]   y
);
```

The function is:

```text
y = min(|a|, |b|)
```

This is a combinational design.

It has:

```text
no clock
no reset
no internal state
```

A top-level wrapper may be used for registered testing or OpenLane implementation.

---

## 6. Expected File Structure

The expected file structure for Project 1.5 is:

```text
rtl/
  abs_unit.v
  min_comparator.v
  abs_min_unit.v
  abs_min_unit_top.v

tb/
  tb_abs_min_unit.v
  tb_abs_min_unit_top.v

sim/
  run_abs_min_unit.sh
  run_abs_min_unit_top.sh
  waveforms/
    abs_min_unit.vcd
    abs_min_unit_top.vcd

synth/
  abs_min_unit.ys
  abs_min_unit_top.ys
  reports/
    abs_min_unit_yosys.log
    abs_min_unit_top_yosys.log
  netlist/
    abs_min_unit_synth.v
    abs_min_unit_top_synth.v

asic_openlane/
  abs_min_unit_top/
    config/
    reports/
    results/
```

Depending on the actual repository version, some filenames may differ.

---

## 7. RTL Architecture

The absolute-minimum unit consists of three main sub-blocks:

```text
1. abs_unit for input a
2. abs_unit for input b
3. min_comparator for the two magnitudes
```

The architecture is:

```text
        a ----------------> abs_unit -------- abs_a -----
                                                        |
                                                        v
                                                  min_comparator ----> y
                                                        ^
                                                        |
        b ----------------> abs_unit -------- abs_b -----
```

The output is:

```text
y = min(abs_a, abs_b)
```

where:

```text
abs_a = |a|
abs_b = |b|
```

---

## 8. Example RTL Code

A typical hierarchical implementation is:

```verilog
`timescale 1ns/1ps

module abs_min_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire        [W:0]   y
);

    wire [W:0] abs_a;
    wire [W:0] abs_b;

    abs_unit #(
        .W(W)
    ) u_abs_a (
        .x(a),
        .y(abs_a)
    );

    abs_unit #(
        .W(W)
    ) u_abs_b (
        .x(b),
        .y(abs_b)
    );

    min_comparator #(
        .W(W+1)
    ) u_min (
        .a(abs_a),
        .b(abs_b),
        .y(y)
    );

endmodule
```

Important points:

```text
The inputs a and b are signed.
The absolute values are unsigned magnitudes.
The min comparator width is W+1.
The output y is an unsigned magnitude.
```

---

## 9. Testbench Objective

The testbench should verify:

```text
y = min(|a|, |b|)
```

for all possible signed input combinations.

For W = 6:

```text
a ranges from -32 to 31
b ranges from -32 to 31
```

The total number of input combinations is:

```text
64 × 64 = 4096
```

For each pair `(a,b)`, the testbench should compute:

```text
expected = min(abs(a), abs(b))
```

and compare it against the RTL output.

---

## 10. Important Test Cases

Although exhaustive testing covers all cases, the following cases are especially important:

```text
a = 0,    b = 0    → y = 0
a = 1,    b = -1   → y = 1
a = 15,   b = -15  → y = 15
a = 31,   b = -32  → y = 31
a = -32,  b = 31   → y = 31
a = -32,  b = -32  → y = 32
a = 5,    b = -12  → y = 5
a = -20,  b = 7    → y = 7
```

The most important boundary cases are:

```text
a = -32
b = -32
```

because the magnitude 32 requires W+1 bits.

---

## 11. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/abs_min_unit_sim \
    rtl/abs_unit.v \
    rtl/min_comparator.v \
    rtl/abs_min_unit.v \
    tb/tb_abs_min_unit.v

vvp sim/abs_min_unit_sim
```

If a project script exists, use:

```bash
./sim/run_abs_min_unit.sh
```

Expected result:

```text
Total tests  = 4096
Total errors = 0
ALL TESTS PASSED
```

---

## 12. Suggested Testbench Structure

The testbench should:

```text
1. Loop over all possible signed values of a.
2. Loop over all possible signed values of b.
3. Apply inputs to the DUT.
4. Wait for combinational propagation.
5. Compute abs_a = abs(a).
6. Compute abs_b = abs(b).
7. Compute expected = min(abs_a, abs_b).
8. Compare y with expected.
9. Count errors.
```

A simplified checking pattern is:

```verilog
for (ia = -32; ia <= 31; ia = ia + 1) begin
    for (ib = -32; ib <= 31; ib = ib + 1) begin
        a = ia;
        b = ib;
        #1;

        abs_a = (ia < 0) ? -ia : ia;
        abs_b = (ib < 0) ? -ib : ib;
        expected = (abs_a <= abs_b) ? abs_a : abs_b;

        if (y !== expected) begin
            error_count = error_count + 1;
        end

        test_count = test_count + 1;
    end
end
```

---

## 13. Expected Simulation Result

Project 1.5 is considered functionally correct if the simulation reports:

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

## 14. What To Check In The Waveform

If a waveform is generated, open it using:

```bash
gtkwave sim/waveforms/abs_min_unit.vcd
```

Signals to inspect:

```text
a
b
abs_a
abs_b
y
expected
error_count
```

Useful waveform points:

```text
a = 31,   b = -32 → y = 31
a = -32,  b = 31  → y = 31
a = -32,  b = -32 → y = 32
a = -20,  b = 7   → y = 7
```

Waveform inspection is especially useful for understanding the internal connection between `abs_unit` and `min_comparator`.

---

## 15. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/abs_unit.v
read_verilog rtl/min_comparator.v
read_verilog rtl/abs_min_unit.v

hierarchy -check -top abs_min_unit

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/abs_min_unit_synth.v
```

For a top-level wrapper:

```tcl
read_verilog rtl/abs_unit.v
read_verilog rtl/min_comparator.v
read_verilog rtl/abs_min_unit.v
read_verilog rtl/abs_min_unit_top.v

hierarchy -check -top abs_min_unit_top

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/abs_min_unit_top_synth.v
```

Run synthesis:

```bash
yosys -s synth/abs_min_unit.ys | tee synth/reports/abs_min_unit_yosys.log
```

or:

```bash
yosys -s synth/abs_min_unit_top.ys | tee synth/reports/abs_min_unit_top_yosys.log
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
AND/NAND/OR/NOR cells
DFF cells if using a registered wrapper
```

The basic `abs_min_unit` is combinational and should not contain flip-flops.

If a registered top wrapper is used, DFF cells may appear.

---

## 17. Interpretation Of The Yosys Result

The absolute-minimum unit is expected to synthesize into logic for:

```text
two absolute value computations
one unsigned magnitude comparison
one selected output path
```

Therefore, compared with `abs_unit` alone or `min_comparator` alone, the `abs_min_unit` should be more complex.

The synthesis result shows how hierarchical RTL is flattened or preserved during logic synthesis.

Important interpretation:

```text
This project demonstrates how small verified primitives can be composed into a larger reusable datapath block.
```

---

## 18. OpenLane Top-Level Wrapper

For OpenLane, a fixed-parameter top wrapper may be used.

A simple combinational wrapper could be:

```verilog
module abs_min_unit_top (
    input  wire signed [5:0] a,
    input  wire signed [5:0] b,
    output wire        [6:0] y
);

    abs_min_unit #(
        .W(6)
    ) u_abs_min (
        .a(a),
        .b(b),
        .y(y)
    );

endmodule
```

A registered wrapper may also be used to create clear timing paths:

```text
input registers
abs_min_unit combinational core
output register
```

The actual wrapper should be documented based on the repository implementation.

---

## 19. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/abs_min_unit_top/
  config.tcl
  src/
    abs_unit.v
    min_comparator.v
    abs_min_unit.v
    abs_min_unit_top.v
```

A typical OpenLane configuration may include:

```tcl
set ::env(DESIGN_NAME) abs_min_unit_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute

set ::env(DIE_AREA) "0 0 140 140"

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
./flow.tcl -design abs_min_unit_top
```

After completion:

```bash
exit
```

Check result:

```bash
cd ~/OpenLane/designs/abs_min_unit_top

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

If the OpenLane run is clean, it confirms that the absolute-minimum unit can be physically implemented.

The key physical validation points are:

```text
the layout follows design rules
the layout matches the synthesized netlist
antenna violations are resolved
the design satisfies the selected timing configuration
```

This matters because the absolute-minimum unit will be reused inside the SC f unit.

---

## 24. Difference Between abs_unit, min_comparator, And abs_min_unit

The `abs_unit` computes:

```text
|x|
```

The `min_comparator` computes:

```text
min(a, b)
```

The `abs_min_unit` computes:

```text
min(|a|, |b|)
```

So the relationship is:

```text
abs_unit + min_comparator = abs_min_unit
```

This is a good example of hierarchical hardware construction.

---

## 25. Connection To SC f Operation

The SC f operation is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

The `abs_min_unit` provides:

```text
min(|a|, |b|)
```

The complete f unit still needs the sign path:

```text
sign = sign(a) XOR sign(b)
```

Then:

```text
if sign is positive:
    f = +min_abs
else:
    f = -min_abs
```

Therefore, Project 1.5 prepares the magnitude part of Project 2.

---

## 26. Common Problems And Debugging

### Problem 1: Width Mismatch Between abs_unit And min_comparator

If `abs_unit` outputs W+1 bits, then `min_comparator` must also use W+1-bit inputs.

For W = 6:

```text
abs output width = 7
min comparator width = 7
```

Fix:

```verilog
min_comparator #(
    .W(W+1)
) u_min (...);
```

---

### Problem 2: Signed Magnitudes

The outputs of `abs_unit` are magnitudes and should be treated as unsigned values.

The minimum comparator inputs should be unsigned.

---

### Problem 3: Wrong Boundary Result For -32

For W = 6:

```text
a = -32
|a| = 32
```

If the output width is too small, this case may fail.

Fix:

```text
use W+1 bits for absolute values and min output
```

---

### Problem 4: Incorrect Module Instantiation

Possible causes:

```text
wrong parameter value
wrong port name
missing source file during compilation
```

Fix:

```text
check abs_unit instantiation
check min_comparator instantiation
check simulation compile command
```

---

### Problem 5: OpenLane Missing Source Files

Because `abs_min_unit` depends on `abs_unit` and `min_comparator`, all source files must be included in the OpenLane `src` folder.

Check:

```bash
ls ~/OpenLane/designs/abs_min_unit_top/src
```

The folder should include:

```text
abs_unit.v
min_comparator.v
abs_min_unit.v
abs_min_unit_top.v
```

---

## 27. Lessons Learned

Project 1.5 teaches the following key lessons:

```text
1. Hierarchical RTL design allows verified primitives to be reused.
2. The magnitude path of SC f is built from abs_unit and min_comparator.
3. Width consistency is critical when composing arithmetic blocks.
4. The most negative signed input must be handled carefully.
5. The abs_min_unit is not yet the complete f unit, but it is the key magnitude block.
6. This block prepares the transition from primitive arithmetic to algorithm-specific SC decoder hardware.
```

---

## 28. Role Of This Project In The Full Roadmap

Project 1.5 belongs to the arithmetic primitive layer and acts as the final preparation before implementing the SC f unit.

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

The absolute-minimum unit will be reused in:

```text
SC f unit
SC Decoder N=4
SC Decoder N=8
resource-shared SC decoder datapath
```

---

## 29. What This Project Is Not

Project 1.5 is not a standalone research contribution.

It should not be presented as:

```text
a novel absolute-minimum architecture
an optimized arithmetic circuit
a standalone publication result
```

Instead, it should be presented as:

```text
a verified composed arithmetic primitive
a training milestone
a reusable building block for the SC f operation
```

---

## 30. Conclusion

Project 1.5 implements and verifies the absolute-minimum unit:

```text
y = min(|a|, |b|)
```

This block combines the absolute value unit and the minimum comparator into a reusable magnitude-selection datapath.

It is the final primitive needed before implementing the complete SC f operation.

The next step is Project 2: SC f Unit.