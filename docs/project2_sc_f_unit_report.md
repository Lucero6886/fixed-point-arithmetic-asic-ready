# Project 2: SC f Unit

## 1. Project Objective

Project 2 implements and verifies the SC f unit used in successive cancellation Polar decoding.

The SC f unit computes the left-branch LLR update in the SC decoding tree.

Using the min-sum approximation, the f operation is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

In hardware-friendly form:

```text
magnitude = min(|a|, |b|)
sign      = sign(a) XOR sign(b)

if sign = 0:
    y = +magnitude
else:
    y = -magnitude
```

The main objective of this project is to combine the previously verified arithmetic primitives into the first algorithm-specific Polar decoder unit.

At the end of this project, the learner should understand:

```text
what the SC f operation means
why f is used for the left branch of the SC decoding tree
how abs_unit and min_comparator support f operation
how sign logic is combined with magnitude logic
how to verify the f unit against a mathematical reference
how this unit becomes a core building block for SC Decoder N=4 and N=8
```

---

## 2. Why This Project Is Important

Project 2 is the transition point from generic arithmetic primitives to Polar decoder-specific hardware.

Projects 1.1 to 1.5 built the arithmetic foundation:

```text
signed_adder
signed_subtractor
abs_unit
min_comparator
abs_min_unit
```

Project 2 uses these foundations to implement the first core SC decoding operation.

In the SC decoding tree:

```text
f operation is used to compute LLRs for the left child node
g operation is used to compute LLRs for the right child node
```

Therefore, the f unit is essential for every SC decoder architecture, including:

```text
SC Decoder N=4
SC Decoder N=8
scheduled SC Decoder N=8
resource-shared SC Decoder N=8
future N=16/N=32 architectures
```

The central question of this project is:

```text
Can we implement the min-sum SC f operation as a reusable, verified, ASIC-ready hardware block?
```

---

## 3. Relationship With Previous Projects

The previous projects built the required primitive blocks.

Project 1.3 implemented:

```text
abs_unit:
|x|
```

Project 1.4 implemented:

```text
min_comparator:
min(a,b)
```

Project 1.5 implemented:

```text
abs_min_unit:
min(|a|, |b|)
```

Project 2 now adds sign processing:

```text
sign(a) XOR sign(b)
```

and produces the final signed f output:

```text
f(a,b)
```

The dependency chain is:

```text
abs_unit
→ min_comparator
→ abs_min_unit
→ sign logic
→ sc_f_unit
```

---

## 4. Technical Background

### 4.1 Role Of f Operation In SC Decoding

In successive cancellation decoding, a codeword is decoded through a recursive binary tree.

At each internal node, the decoder first computes the LLRs for the left child.

The left-child LLRs are computed using the f operation.

For two input LLRs `a` and `b`, the f operation estimates the reliability of the combined left branch.

The f operation is used before the decoder has made decisions for the corresponding right branch.

---

### 4.2 Exact f Function And Min-Sum Approximation

The exact f function in LLR domain is nonlinear and may involve hyperbolic tangent operations.

For hardware implementation, a min-sum approximation is commonly used:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

This approximation is hardware-friendly because it requires only:

```text
sign extraction
absolute value
minimum comparison
conditional sign application
```

No multiplier or complex nonlinear function is needed.

---

### 4.3 Sign Logic

The sign of the f output is determined by the signs of the two input LLRs.

If `a` and `b` have the same sign:

```text
f(a,b) is positive
```

If `a` and `b` have opposite signs:

```text
f(a,b) is negative
```

This can be implemented using XOR:

```text
negative_output = a_sign XOR b_sign
```

where:

```text
a_sign = a[W-1]
b_sign = b[W-1]
```

---

### 4.4 Magnitude Logic

The magnitude of the f output is:

```text
min(|a|, |b|)
```

This is exactly what Project 1.5 provides through `abs_min_unit`.

Therefore, the f unit can be viewed as:

```text
magnitude path:
    abs_min_unit

sign path:
    a[W-1] XOR b[W-1]

final output:
    signed magnitude with selected sign
```

---

## 5. Design Under Test

The design under test is a parameterized SC f unit.

A typical interface is:

```verilog
module sc_f_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire signed [W:0]   y
);
```

The function is:

```text
y = f(a,b)
```

where:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

The output has W+1 bits because the magnitude may require W+1 bits.

For W = 6:

```text
input range  = -32 to 31
max magnitude = 32
output width = 7 bits
```

This is a combinational design.

It has:

```text
no clock
no reset
no internal state
```

A registered wrapper may be used for OpenLane timing analysis.

---

## 6. Expected File Structure

The expected file structure for Project 2 is:

```text
rtl/
  abs_unit.v
  min_comparator.v
  abs_min_unit.v
  sc_f_unit.v
  sc_f_unit_top.v

tb/
  tb_sc_f_unit.v
  tb_sc_f_unit_top.v

sim/
  run_sc_f_unit.sh
  run_sc_f_unit_top.sh
  waveforms/
    sc_f_unit.vcd
    sc_f_unit_top.vcd

synth/
  sc_f_unit.ys
  sc_f_unit_top.ys
  reports/
    sc_f_unit_yosys.log
    sc_f_unit_top_yosys.log
  netlist/
    sc_f_unit_synth.v
    sc_f_unit_top_synth.v

asic_openlane/
  sc_f_unit_top/
    config/
    reports/
    results/
```

Depending on the actual repository version, some file names may be slightly different.

---

## 7. RTL Architecture

The SC f unit has two main paths:

```text
1. Magnitude path
2. Sign path
```

The magnitude path computes:

```text
mag = min(|a|, |b|)
```

The sign path computes:

```text
neg = a[W-1] XOR b[W-1]
```

Then the final output is:

```text
if neg = 0:
    y = +mag
else:
    y = -mag
```

Architecture diagram:

```text
         a ---------------------> sign bit -----
          \                                      \
           \                                      XOR ---- neg
            \                                    /
             ----> abs_unit ---- abs_a ----     /
                                      |     \
                                      v      \
                                min_comparator ---> mag ---> sign apply ---> y
                                      ^
                                      |
             ----> abs_unit ---- abs_b
            /
           /
         b ---------------------> sign bit
```

---

## 8. Example RTL Code

A typical hierarchical implementation is:

```verilog
`timescale 1ns/1ps

module sc_f_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire signed [W:0]   y
);

    wire [W:0] mag;
    wire       neg;

    abs_min_unit #(
        .W(W)
    ) u_abs_min (
        .a(a),
        .b(b),
        .y(mag)
    );

    assign neg = a[W-1] ^ b[W-1];

    assign y = neg ? -$signed(mag) : $signed(mag);

endmodule
```

Important points:

```text
a and b are signed LLR inputs.
mag is an unsigned magnitude.
neg determines whether the result should be negative.
y is signed and has W+1 bits.
```

---

## 9. Alternative Direct Implementation

The f unit may also be implemented directly without instantiating `abs_min_unit`.

Example:

```verilog
function signed [W:0] f_func;
    input signed [W-1:0] a;
    input signed [W-1:0] b;
    reg [W:0] abs_a;
    reg [W:0] abs_b;
    reg [W:0] mag;
    begin
        abs_a = (a < 0) ? -$signed({a[W-1], a}) : {a[W-1], a};
        abs_b = (b < 0) ? -$signed({b[W-1], b}) : {b[W-1], b};

        mag = (abs_a <= abs_b) ? abs_a : abs_b;

        if (a[W-1] ^ b[W-1])
            f_func = -$signed(mag);
        else
            f_func = $signed(mag);
    end
endfunction
```

The hierarchical version is better for learning because it reuses verified modules.

The direct version may be useful later in resource-shared decoder datapaths.

---

## 10. Testbench Objective

The testbench should verify:

```text
y = sign(a) sign(b) min(|a|, |b|)
```

for all possible signed input combinations.

For W = 6:

```text
a ranges from -32 to 31
b ranges from -32 to 31
```

Total number of input combinations:

```text
64 × 64 = 4096
```

For each input pair `(a,b)`, the testbench should compute the expected f result using a software reference expression and compare it with the RTL output.

---

## 11. Important Test Cases

Although exhaustive testing covers all cases, these cases are especially important:

```text
a = 0,    b = 0    → y = 0
a = 1,    b = 1    → y = 1
a = -1,   b = 1    → y = -1
a = 1,    b = -1   → y = -1
a = -1,   b = -1   → y = 1
a = 31,   b = -32  → y = -31
a = -32,  b = 31   → y = -31
a = -32,  b = -32  → y = 32
a = 12,   b = 5    → y = 5
a = -12,  b = 5    → y = -5
```

These cases check:

```text
zero behavior
same sign inputs
opposite sign inputs
equal magnitude
different magnitude
maximum positive input
minimum negative input
most negative corner case
```

---

## 12. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/sc_f_unit_sim \
    rtl/abs_unit.v \
    rtl/min_comparator.v \
    rtl/abs_min_unit.v \
    rtl/sc_f_unit.v \
    tb/tb_sc_f_unit.v

vvp sim/sc_f_unit_sim
```

If a project script exists, use:

```bash
./sim/run_sc_f_unit.sh
```

Expected result:

```text
Total tests  = 4096
Total errors = 0
ALL TESTS PASSED
```

---

## 13. Suggested Testbench Structure

The testbench should:

```text
1. Loop over all possible signed values of a.
2. Loop over all possible signed values of b.
3. Apply a and b to the DUT.
4. Wait for combinational propagation.
5. Compute abs_a = abs(a).
6. Compute abs_b = abs(b).
7. Compute mag = min(abs_a, abs_b).
8. Determine sign = sign(a) XOR sign(b).
9. Compute expected f output.
10. Compare y with expected.
11. Count errors.
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
        mag   = (abs_a <= abs_b) ? abs_a : abs_b;

        if ((ia < 0) ^ (ib < 0))
            expected = -mag;
        else
            expected = mag;

        if (y !== expected) begin
            error_count = error_count + 1;
        end

        test_count = test_count + 1;
    end
end
```

---

## 14. Expected Simulation Result

Project 2 is considered functionally correct if the simulation reports:

```text
Total errors = 0
ALL TESTS PASSED
```

Record the actual simulation result here:

```text
Actual simulation result:
Total tests  =
Total errors =
Status       =
```

If the repository already contains the final simulation log, paste the exact result in this section.

---

## 15. What To Check In The Waveform

If a waveform is generated, open it using:

```bash
gtkwave sim/waveforms/sc_f_unit.vcd
```

Signals to inspect:

```text
a
b
mag
neg
y
expected
error_count
```

Useful waveform points:

```text
a = 31,   b = -32 → y = -31
a = -32,  b = 31  → y = -31
a = -32,  b = -32 → y = 32
a = -12,  b = 5   → y = -5
a = 12,   b = 5   → y = 5
```

Waveform inspection is useful for understanding how sign and magnitude combine.

---

## 16. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/abs_unit.v
read_verilog rtl/min_comparator.v
read_verilog rtl/abs_min_unit.v
read_verilog rtl/sc_f_unit.v

hierarchy -check -top sc_f_unit

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/sc_f_unit_synth.v
```

For a top-level wrapper:

```tcl
read_verilog rtl/abs_unit.v
read_verilog rtl/min_comparator.v
read_verilog rtl/abs_min_unit.v
read_verilog rtl/sc_f_unit.v
read_verilog rtl/sc_f_unit_top.v

hierarchy -check -top sc_f_unit_top

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/sc_f_unit_top_synth.v
```

Run synthesis:

```bash
yosys -s synth/sc_f_unit.ys | tee synth/reports/sc_f_unit_yosys.log
```

or:

```bash
yosys -s synth/sc_f_unit_top.ys | tee synth/reports/sc_f_unit_top_yosys.log
```

---

## 17. What To Check In The Yosys Report

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

The basic `sc_f_unit` is combinational and should not contain flip-flops.

If a registered top wrapper is used, DFF cells may appear.

---

## 18. Interpretation Of The Yosys Result

The f unit is expected to synthesize into logic for:

```text
absolute value computation
minimum comparison
sign XOR
conditional negation
output selection
```

Compared with `abs_min_unit`, the f unit adds sign processing and signed output generation.

Therefore, its cell count should generally be higher than the `abs_min_unit` alone.

Important interpretation:

```text
The f unit is the first algorithm-specific SC decoder block.
```

---

## 19. OpenLane Top-Level Wrapper

For OpenLane, a fixed-parameter wrapper may be used.

A simple combinational wrapper could be:

```verilog
module sc_f_unit_top (
    input  wire signed [5:0] a,
    input  wire signed [5:0] b,
    output wire signed [6:0] y
);

    sc_f_unit #(
        .W(6)
    ) u_f (
        .a(a),
        .b(b),
        .y(y)
    );

endmodule
```

A registered wrapper may also be used to create clear timing paths:

```text
input registers
sc_f_unit combinational core
output register
```

The actual project wrapper should be documented based on the repository implementation.

---

## 20. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/sc_f_unit_top/
  config.tcl
  src/
    abs_unit.v
    min_comparator.v
    abs_min_unit.v
    sc_f_unit.v
    sc_f_unit_top.v
```

A typical OpenLane configuration may include:

```tcl
set ::env(DESIGN_NAME) sc_f_unit_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute

set ::env(DIE_AREA) "0 0 160 160"

set ::env(PL_TARGET_DENSITY) 0.45

set ::env(GRT_REPAIR_ANTENNAS) 1

set ::env(RUN_HEURISTIC_DIODE_INSERTION) 1

set ::env(SYNTH_STRATEGY) "AREA 0"
```

If the wrapper is purely combinational, the clock settings may differ.

The actual configuration should be recorded from the real run.

---

## 21. OpenLane Flow

Run OpenLane from the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the container:

```bash
./flow.tcl -design sc_f_unit_top
```

After completion:

```bash
exit
```

Check result:

```bash
cd ~/OpenLane/designs/sc_f_unit_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final -name "*.gds"
cat $RUN_DIR/reports/manufacturability.rpt
head -n 5 $RUN_DIR/reports/metrics.csv
```

---

## 22. Expected OpenLane Success Criteria

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

## 23. Actual OpenLane Result

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

## 24. Interpretation Of The OpenLane Result

If the OpenLane run is clean, it confirms that the SC f unit can be physically implemented.

This is more important than primitive arithmetic blocks because the f unit is the first algorithm-specific SC decoder block.

A clean OpenLane result means:

```text
the layout follows design rules
the layout matches the synthesized netlist
antenna violations are resolved
timing is satisfied under the selected configuration
GDSII was generated successfully
```

---

## 25. Difference Between abs_min_unit And sc_f_unit

The `abs_min_unit` computes only the magnitude:

```text
min(|a|, |b|)
```

The `sc_f_unit` computes the full signed f result:

```text
sign(a) sign(b) min(|a|, |b|)
```

Therefore:

```text
abs_min_unit = magnitude path
sc_f_unit    = magnitude path + sign path
```

The f unit is the complete left-branch LLR update block.

---

## 26. Connection To SC Decoder N=4

The SC Decoder N=4 uses the f unit to compute the first-level left LLRs.

For N=4, given input LLRs:

```text
L0, L1, L2, L3
```

the left-branch LLRs are:

```text
left0 = f(L0, L2)
left1 = f(L1, L3)
```

These are then used to decode the left child bits.

Therefore, `sc_f_unit` is used repeatedly in SC decoder architectures.

---

## 27. Connection To Resource-Shared Architecture

In later Project 7, the resource-shared SC Decoder N=8 uses a shared f/g datapath.

The f part of that datapath is based on the same function implemented in Project 2:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Therefore, Project 2 provides the conceptual and implementation foundation for the future shared datapath.

---

## 28. Common Problems And Debugging

### Problem 1: Wrong Sign For Opposite Signs

Example:

```text
a = -12
b = 5
expected y = -5
```

Possible cause:

```text
sign XOR logic is wrong
inputs are not declared signed
```

Fix:

```verilog
assign neg = a[W-1] ^ b[W-1];
```

---

### Problem 2: Wrong Magnitude

Example:

```text
a = 31
b = -32
expected magnitude = 31
```

Possible cause:

```text
abs_min_unit width mismatch
abs_unit output truncated
min_comparator width incorrect
```

Fix:

```text
Use W+1 bits for magnitudes.
Use min_comparator width W+1.
```

---

### Problem 3: Wrong Result For -32 And -32

For W = 6:

```text
a = -32
b = -32
expected y = +32
```

Possible cause:

```text
absolute value output width too small
sign application truncates the result
```

Fix:

```text
Use W+1 output width for f unit.
```

---

### Problem 4: Output Treated As Unsigned

The f output can be negative.

Therefore, the output should be declared as signed:

```verilog
output wire signed [W:0] y;
```

---

### Problem 5: Missing Source Files During Compilation

The f unit may depend on:

```text
abs_unit.v
min_comparator.v
abs_min_unit.v
sc_f_unit.v
```

Make sure all source files are included in simulation, synthesis, and OpenLane.

---

## 29. Lessons Learned

Project 2 teaches the following key lessons:

```text
1. The SC f operation is the first algorithm-specific Polar decoder primitive.
2. The f unit combines magnitude selection and sign processing.
3. The min-sum approximation makes f hardware-friendly.
4. Width handling is critical for the most negative LLR value.
5. Verified primitive modules can be reused to build algorithmic hardware.
6. The f unit is required in every SC decoder size.
7. This project bridges basic arithmetic and full decoder architecture.
```

---

## 30. Role Of This Project In The Full Roadmap

Project 2 belongs to the SC primitive layer of the roadmap.

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

The f unit will be reused in:

```text
SC Decoder N=4
SC Decoder N=8
scheduled SC decoder
resource-shared SC decoder
future N=16/N=32 decoders
```

---

## 31. What This Project Is Not

Project 2 is not a standalone publication-level contribution.

It should not be presented as:

```text
a novel f-function architecture
a full Polar decoder
a complete research result
```

Instead, it should be presented as:

```text
a verified SC primitive
a training milestone
a reusable building block for larger decoder architectures
```

---

## 32. Conclusion

Project 2 implements and verifies the SC f unit:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

This unit is essential for computing the left-branch LLRs in SC Polar decoding.

It combines the previously verified absolute-minimum unit with sign logic to produce a signed LLR output.

Project 2 marks the transition from general arithmetic primitives to algorithm-specific SC decoder hardware.

The next step is Project 3: SC g Unit.