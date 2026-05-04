# Project 3: SC g Unit

## 1. Project Objective

Project 3 implements and verifies the SC g unit used in successive cancellation Polar decoding.

The SC g unit computes the right-branch LLR update in the SC decoding tree.

The g operation is defined as:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

where:

```text
a and b are signed LLR inputs
u is a previously decoded bit or partial-sum bit
y is the updated signed LLR output
```

The main objective of this project is to implement a reliable conditional add/subtract unit for SC decoding.

At the end of this project, the learner should understand:

```text
what the SC g operation means
why g depends on previous decoded bits
how g differs from f
how signed addition/subtraction is used in SC decoding
how to verify g operation exhaustively
how this unit becomes a core building block for SC Decoder N=4 and N=8
```

---

## 2. Why This Project Is Important

In SC Polar decoding, the decoder first goes to the left branch using the f operation.

After decoding the left branch, the decoder computes partial sums from the already decoded bits. These partial sums are then used by the g operation to compute the LLRs of the right branch.

Therefore, unlike the f operation, the g operation depends on previous decisions.

The f operation is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

The g operation is:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

This means the g unit is essential for the sequential nature of SC decoding.

The central question of this project is:

```text
Can we implement the conditional add/subtract operation required by SC right-branch LLR updates?
```

---

## 3. Relationship With Previous Projects

The previous projects built the required arithmetic foundation.

Project 1.1 implemented:

```text
signed_adder:
y = a + b
```

Project 1.2 implemented:

```text
signed_subtractor:
y = a - b
```

Project 2 implemented:

```text
SC f unit:
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Project 3 now implements:

```text
SC g unit:
g(a,b,u) = b + a or b - a depending on u
```

Together, Project 2 and Project 3 provide the two core LLR-update operations required by SC decoding:

```text
left branch  → f operation
right branch → g operation
```

---

## 4. Technical Background

### 4.1 Role Of g Operation In SC Decoding

In the SC decoding tree, each internal node is processed in two major steps:

```text
1. Compute left-child LLRs using f.
2. Decode the left child.
3. Compute partial sums from left-child decisions.
4. Compute right-child LLRs using g.
5. Decode the right child.
```

The g operation cannot be computed correctly until the corresponding decision bit or partial sum is known.

This creates an important dependency:

```text
right-branch computation depends on left-branch decisions
```

This is one reason why SC decoding is naturally sequential.

---

### 4.2 Mathematical Form Of g Operation

The g function is:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

This can also be written as:

```text
g(a,b,u) = b + (1 - 2u)a
```

If:

```text
u = 0
```

then:

```text
1 - 2u = 1
g = b + a
```

If:

```text
u = 1
```

then:

```text
1 - 2u = -1
g = b - a
```

This form shows that g is a conditional sign operation applied to `a`, followed by addition with `b`.

---

### 4.3 Hardware Interpretation

The hardware interpretation is simple:

```text
if u = 0:
    output = b + a

if u = 1:
    output = b - a
```

Thus, the g unit can be implemented using:

```text
signed adder
signed subtractor
2-to-1 multiplexer
```

or directly using conditional arithmetic.

A direct implementation is:

```verilog
assign y = (u == 1'b0) ? (b + a) : (b - a);
```

However, the output width must be chosen carefully to avoid overflow.

---

## 5. Width Convention

The g operation adds or subtracts signed LLR values.

If the input width is W, each input represents:

```text
-2^(W-1) to 2^(W-1)-1
```

For W = 6:

```text
input range = -32 to 31
```

The result of addition or subtraction may require one extra bit.

Examples:

```text
31 + 31 = 62
-32 + -32 = -64
31 - (-32) = 63
-32 - 31 = -63
```

Therefore, the output should use:

```text
W+1 bits
```

For W = 6:

```text
output width = 7 bits
```

A safe interface is:

```verilog
output wire signed [W:0] y
```

---

## 6. Design Under Test

The design under test is a parameterized SC g unit.

A typical interface is:

```verilog
module sc_g_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    input  wire                u,
    output wire signed [W:0]   y
);
```

The function is:

```text
if u = 0:
    y = b + a

if u = 1:
    y = b - a
```

This is a combinational design.

It has:

```text
no clock
no reset
no internal state
```

A registered wrapper may be used later for OpenLane timing analysis.

---

## 7. Expected File Structure

The expected file structure for Project 3 is:

```text
rtl/
  signed_adder.v
  signed_subtractor.v
  sc_g_unit.v
  sc_g_unit_top.v

tb/
  tb_sc_g_unit.v
  tb_sc_g_unit_top.v

sim/
  run_sc_g_unit.sh
  run_sc_g_unit_top.sh
  waveforms/
    sc_g_unit.vcd
    sc_g_unit_top.vcd

synth/
  sc_g_unit.ys
  sc_g_unit_top.ys
  reports/
    sc_g_unit_yosys.log
    sc_g_unit_top_yosys.log
  netlist/
    sc_g_unit_synth.v
    sc_g_unit_top_synth.v

asic_openlane/
  sc_g_unit_top/
    config/
    reports/
    results/
```

Depending on the actual repository version, some file names may be slightly different.

---

## 8. RTL Architecture

The g unit can be understood as a conditional add/subtract datapath.

Architecture:

```text
                 u
                 |
                 v
        +-----------------+
a ----> |                 |
        | conditional     | ----> y
b ----> | add/subtract    |
        |                 |
        +-----------------+
```

More explicitly:

```text
a, b
→ signed addition path:     b + a
→ signed subtraction path:  b - a
→ mux controlled by u
→ output y
```

If implemented using separate submodules:

```text
signed_adder computes b + a
signed_subtractor computes b - a
u selects between the two results
```

If implemented directly:

```text
conditional operator selects addition or subtraction in one expression
```

Both are valid. The hierarchical version is better for learning. The direct version may be more compact.

---

## 9. Example RTL Code — Direct Implementation

A direct implementation is:

```verilog
`timescale 1ns/1ps

module sc_g_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    input  wire                u,
    output wire signed [W:0]   y
);

    wire signed [W:0] a_ext;
    wire signed [W:0] b_ext;

    assign a_ext = {a[W-1], a};
    assign b_ext = {b[W-1], b};

    assign y = (u == 1'b0) ? (b_ext + a_ext) : (b_ext - a_ext);

endmodule
```

Important points:

```text
a and b are sign-extended before arithmetic.
u selects add or subtract.
y has W+1 bits.
the design is purely combinational.
```

---

## 10. Example RTL Code — Hierarchical Implementation

A hierarchical implementation can reuse `signed_adder` and `signed_subtractor`.

```verilog
`timescale 1ns/1ps

module sc_g_unit #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    input  wire                u,
    output wire signed [W:0]   y
);

    wire signed [W:0] add_y;
    wire signed [W:0] sub_y;

    signed_adder #(
        .W(W)
    ) u_add (
        .a(b),
        .b(a),
        .y(add_y)
    );

    signed_subtractor #(
        .W(W)
    ) u_sub (
        .a(b),
        .b(a),
        .y(sub_y)
    );

    assign y = (u == 1'b0) ? add_y : sub_y;

endmodule
```

This version clearly shows the relationship with previous projects.

Important note:

```text
The subtractor input order must be b - a, not a - b.
```

This is a common source of errors.

---

## 11. Testbench Objective

The testbench should verify:

```text
y = b + a, if u = 0
y = b - a, if u = 1
```

for all possible signed input combinations and both values of `u`.

For W = 6:

```text
a ranges from -32 to 31
b ranges from -32 to 31
u ranges from 0 to 1
```

Total number of test cases:

```text
64 × 64 × 2 = 8192
```

For each input combination, the testbench should compute the reference result:

```text
if u = 0:
    expected = b + a

if u = 1:
    expected = b - a
```

and compare it against the RTL output.

---

## 12. Important Test Cases

Although exhaustive testing covers all combinations, the following cases are especially important:

```text
a = 0,    b = 0,    u = 0 → y = 0
a = 0,    b = 0,    u = 1 → y = 0

a = 1,    b = 2,    u = 0 → y = 3
a = 1,    b = 2,    u = 1 → y = 1

a = -1,   b = 2,    u = 0 → y = 1
a = -1,   b = 2,    u = 1 → y = 3

a = 31,   b = 31,   u = 0 → y = 62
a = 31,   b = 31,   u = 1 → y = 0

a = -32,  b = -32,  u = 0 → y = -64
a = -32,  b = -32,  u = 1 → y = 0

a = -32,  b = 31,   u = 0 → y = -1
a = -32,  b = 31,   u = 1 → y = 63

a = 31,   b = -32,  u = 0 → y = -1
a = 31,   b = -32,  u = 1 → y = -63
```

These cases check:

```text
zero behavior
addition mode
subtraction mode
positive and negative inputs
maximum positive value
minimum negative value
output width correctness
input-order correctness
```

---

## 13. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/sc_g_unit_sim \
    rtl/signed_adder.v \
    rtl/signed_subtractor.v \
    rtl/sc_g_unit.v \
    tb/tb_sc_g_unit.v

vvp sim/sc_g_unit_sim
```

If a project script exists, use:

```bash
./sim/run_sc_g_unit.sh
```

Expected result:

```text
Total tests  = 8192
Total errors = 0
ALL TESTS PASSED
```

---

## 14. Suggested Testbench Structure

The testbench should:

```text
1. Loop over all possible signed values of a.
2. Loop over all possible signed values of b.
3. Loop over u = 0 and u = 1.
4. Apply inputs to the DUT.
5. Wait for combinational propagation.
6. Compute expected output.
7. Compare y with expected.
8. Count errors.
```

A simplified checking pattern is:

```verilog
for (ia = -32; ia <= 31; ia = ia + 1) begin
    for (ib = -32; ib <= 31; ib = ib + 1) begin
        for (iu = 0; iu <= 1; iu = iu + 1) begin
            a = ia;
            b = ib;
            u = iu[0];
            #1;

            if (iu == 0)
                expected = ib + ia;
            else
                expected = ib - ia;

            if (y !== expected) begin
                error_count = error_count + 1;
            end

            test_count = test_count + 1;
        end
    end
end
```

---

## 15. Expected Simulation Result

Project 3 is considered functionally correct if the simulation reports:

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

## 16. What To Check In The Waveform

If a waveform is generated, open it using:

```bash
gtkwave sim/waveforms/sc_g_unit.vcd
```

Signals to inspect:

```text
a
b
u
y
expected
error_count
```

Useful waveform points:

```text
u = 0 → y = b + a
u = 1 → y = b - a

a = -32, b = 31,  u = 1 → y = 63
a = 31,  b = -32, u = 1 → y = -63
a = -32, b = -32, u = 0 → y = -64
```

Waveform inspection is useful for checking whether the subtraction order is correct.

---

## 17. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/signed_adder.v
read_verilog rtl/signed_subtractor.v
read_verilog rtl/sc_g_unit.v

hierarchy -check -top sc_g_unit

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/sc_g_unit_synth.v
```

For a top-level wrapper:

```tcl
read_verilog rtl/signed_adder.v
read_verilog rtl/signed_subtractor.v
read_verilog rtl/sc_g_unit.v
read_verilog rtl/sc_g_unit_top.v

hierarchy -check -top sc_g_unit_top

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/sc_g_unit_top_synth.v
```

Run synthesis:

```bash
yosys -s synth/sc_g_unit.ys | tee synth/reports/sc_g_unit_yosys.log
```

or:

```bash
yosys -s synth/sc_g_unit_top.ys | tee synth/reports/sc_g_unit_top_yosys.log
```

---

## 18. What To Check In The Yosys Report

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

The basic `sc_g_unit` is combinational and should not contain flip-flops.

If a registered top wrapper is used, DFF cells may appear.

The g unit may include:

```text
adder-like logic
subtractor-like logic
selection logic controlled by u
```

---

## 19. Interpretation Of The Yosys Result

The g unit is expected to synthesize into conditional add/subtract logic.

If implemented hierarchically, Yosys may optimize the adder, subtractor, and mux into a smaller combined logic network.

Therefore, the final synthesized gate structure may not visibly preserve separate adder and subtractor blocks.

This is normal.

Important interpretation:

```text
The g unit is the first SC primitive that depends on a previous decision bit.
```

This makes it different from the f unit, which depends only on two LLR inputs.

---

## 20. OpenLane Top-Level Wrapper

For OpenLane, a fixed-parameter wrapper may be used.

A simple combinational wrapper could be:

```verilog
module sc_g_unit_top (
    input  wire signed [5:0] a,
    input  wire signed [5:0] b,
    input  wire              u,
    output wire signed [6:0] y
);

    sc_g_unit #(
        .W(6)
    ) u_g (
        .a(a),
        .b(b),
        .u(u),
        .y(y)
    );

endmodule
```

A registered wrapper may also be used:

```text
input registers
sc_g_unit combinational core
output register
```

The actual project wrapper should be documented based on the repository implementation.

---

## 21. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/sc_g_unit_top/
  config.tcl
  src/
    signed_adder.v
    signed_subtractor.v
    sc_g_unit.v
    sc_g_unit_top.v
```

A typical OpenLane configuration may include:

```tcl
set ::env(DESIGN_NAME) sc_g_unit_top

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

If the wrapper is purely combinational, clock settings may differ.

The actual configuration should be recorded from the real run.

---

## 22. OpenLane Flow

Run OpenLane from the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the container:

```bash
./flow.tcl -design sc_g_unit_top
```

After completion:

```bash
exit
```

Check result:

```bash
cd ~/OpenLane/designs/sc_g_unit_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final -name "*.gds"
cat $RUN_DIR/reports/manufacturability.rpt
head -n 5 $RUN_DIR/reports/metrics.csv
```

---

## 23. Expected OpenLane Success Criteria

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

## 24. Actual OpenLane Result

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

## 25. Interpretation Of The OpenLane Result

If the OpenLane run is clean, it confirms that the SC g unit can be physically implemented.

This is important because the g unit is a core operation in every SC decoder.

A clean OpenLane result means:

```text
the layout follows design rules
the layout matches the synthesized netlist
antenna violations are resolved
timing is satisfied under the selected configuration
GDSII was generated successfully
```

---

## 26. Difference Between SC f Unit And SC g Unit

The SC f unit computes:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

The SC g unit computes:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

Main differences:

| Feature | SC f Unit | SC g Unit |
|---|---|---|
| Inputs | a, b | a, b, u |
| Depends on previous decision? | no | yes |
| Main operation | sign + min magnitude | conditional add/subtract |
| Used for | left branch | right branch |
| Sequential dependency | lower | higher |

This shows why the g operation is more directly tied to the sequential nature of SC decoding.

---

## 27. Connection To SC Decoder N=4

For N=4, after computing and decoding the left branch, the decoder uses g operations to compute right-branch LLRs.

Given input LLRs:

```text
L0, L1, L2, L3
```

after decoding left decisions and partial sums, the right LLRs are computed using:

```text
right0 = g(L0, L2, partial0)
right1 = g(L1, L3, partial1)
```

Then these right LLRs are used to decode the remaining bits.

Therefore, `sc_g_unit` is essential for completing even the smallest practical SC decoder block.

---

## 28. Connection To Resource-Shared Architecture

In later Project 7, the resource-shared SC Decoder N=8 uses a shared f/g datapath.

The g part of that shared datapath is based on the same function implemented in Project 3:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

Thus, Project 3 provides the conceptual and implementation foundation for the shared g-operation path.

---

## 29. Common Problems And Debugging

### Problem 1: Subtraction Order Is Wrong

The g operation requires:

```text
g(a,b,1) = b - a
```

A common mistake is to implement:

```text
a - b
```

instead of:

```text
b - a
```

Check carefully:

```verilog
assign y = (u == 1'b0) ? (b_ext + a_ext) : (b_ext - a_ext);
```

---

### Problem 2: Output Width Too Small

For W = 6:

```text
31 + 31 = 62
-32 + -32 = -64
31 - (-32) = 63
-32 - 31 = -63
```

A 6-bit output is not enough.

Fix:

```text
Use W+1 output bits.
```

---

### Problem 3: Missing Sign Extension

If `a` and `b` are not sign-extended before arithmetic, boundary cases may fail.

Fix:

```verilog
wire signed [W:0] a_ext;
wire signed [W:0] b_ext;

assign a_ext = {a[W-1], a};
assign b_ext = {b[W-1], b};
```

---

### Problem 4: u Control Is Inverted

If the implementation accidentally uses:

```text
u = 0 → subtract
u = 1 → add
```

then many tests will fail.

Correct behavior:

```text
u = 0 → b + a
u = 1 → b - a
```

---

### Problem 5: Testbench Expected Value Uses Wrong Order

The testbench must also use:

```text
expected = b - a
```

when `u = 1`.

If the testbench uses `a - b`, it may falsely report correct behavior for the wrong RTL or falsely fail a correct RTL.

---

### Problem 6: OpenLane Missing Source Files

If using a hierarchical implementation, all source files must be included:

```text
signed_adder.v
signed_subtractor.v
sc_g_unit.v
sc_g_unit_top.v
```

Check:

```bash
ls ~/OpenLane/designs/sc_g_unit_top/src
```

---

## 30. Lessons Learned

Project 3 teaches the following key lessons:

```text
1. The SC g operation is the right-branch LLR update in SC decoding.
2. Unlike f, g depends on a previously decoded bit or partial sum.
3. The correct formula is b + a for u = 0 and b - a for u = 1.
4. Subtraction order is critical.
5. Output width must be W+1 to preserve the full result range.
6. Signed arithmetic must be handled carefully with sign extension.
7. The g unit is essential for all complete SC decoder architectures.
```

---

## 31. Role Of This Project In The Full Roadmap

Project 3 belongs to the SC primitive layer of the roadmap.

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

The g unit will be reused in:

```text
SC Decoder N=4
SC Decoder N=8
scheduled SC decoder
resource-shared SC decoder
future N=16/N=32 decoders
```

---

## 32. What This Project Is Not

Project 3 is not a standalone publication-level contribution.

It should not be presented as:

```text
a novel g-function architecture
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

## 33. Conclusion

Project 3 implements and verifies the SC g unit:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

This unit is essential for computing the right-branch LLRs in SC Polar decoding.

Project 3 completes the two fundamental SC LLR-update primitives:

```text
Project 2: SC f unit
Project 3: SC g unit
```

Together, these two units allow the project to move from primitive arithmetic blocks to complete SC decoder architectures.

The next step is Project 4: Polar Encoder N=8.