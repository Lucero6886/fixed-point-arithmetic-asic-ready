# Project 1.2: Signed Subtractor

## 1. Project Objective

Project 1.2 implements and verifies a signed fixed-point subtractor in Verilog.

The main objective is to build a reliable signed subtraction primitive that can later be reused in the SC Polar decoder datapath.

The signed subtractor computes:

```text
y = a - b
```

where `a` and `b` are signed fixed-width inputs.

This project extends Project 1.1, where the signed adder was implemented and verified.

At the end of this project, the learner should understand:

```text
how signed subtraction works in two's-complement arithmetic
how to avoid output overflow by using a wider output
how to verify all possible signed input combinations
how signed subtraction supports the SC g operation
how a small arithmetic primitive fits into a larger decoder architecture
```

---

## 2. Why This Project Is Important

The SC Polar decoder operates on signed LLR values.

The SC g operation is defined as:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

Therefore, signed subtraction is required when the previous decision bit is:

```text
u = 1
```

In other words, the subtractor is not an isolated arithmetic exercise. It is a direct building block for the SC g unit and for later scheduled/resource-shared decoder architectures.

The central question of this project is:

```text
Can we design, verify, synthesize, and physically implement a signed subtractor that can be reused later in SC decoding hardware?
```

---

## 3. Relationship With Project 1.1

Project 1.1 implemented:

```text
signed addition:
y = a + b
```

Project 1.2 implements:

```text
signed subtraction:
y = a - b
```

Both projects are basic signed arithmetic primitives.

Together, they prepare the arithmetic foundation for:

```text
SC g unit
conditional LLR update
shared f/g datapath
multi-cycle SC decoder
resource-shared SC decoder
```

The signed adder and subtractor should use the same width convention so that later modules remain consistent.

---

## 4. Technical Background

### 4.1 Two's-Complement Subtraction

In two's-complement arithmetic, subtraction can be understood as addition with a negated operand:

```text
a - b = a + (-b)
```

The value `-b` is represented in two's complement as:

```text
invert b and add 1
```

At the RTL level, Verilog can perform signed subtraction directly:

```verilog
assign y = a - b;
```

However, the designer must still handle:

```text
signed declarations
output width
sign extension
overflow behavior
```

---

### 4.2 Signed Range

For a W-bit signed number:

```text
minimum value = -2^(W-1)
maximum value =  2^(W-1)-1
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

### 4.3 Why Output Width Should Be W+1

If two W-bit signed numbers are subtracted, the result may need W+1 bits.

For W = 6:

```text
31 - (-32) = 63
-32 - 31 = -63
```

A 6-bit signed number can only represent:

```text
-32 to 31
```

Therefore, to represent the full subtraction result safely, the output should use:

```text
W+1 bits
```

A safe interface is:

```verilog
output signed [W:0] y
```

---

## 5. Design Under Test

The design under test is a parameterized signed subtractor.

A typical interface is:

```verilog
module signed_subtractor #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire signed [W:0]   y
);
```

The function is:

```text
y = a - b
```

This is a combinational design.

It has:

```text
no clock
no reset
no internal register
```

---

## 6. Expected File Structure

The expected file structure for Project 1.2 is:

```text
rtl/
  signed_subtractor.v

tb/
  tb_signed_subtractor.v

sim/
  run_signed_subtractor.sh
  waveforms/
    signed_subtractor.vcd

synth/
  signed_subtractor.ys
  reports/
    signed_subtractor_yosys.log
  netlist/
    signed_subtractor_synth.v

asic_openlane/
  signed_subtractor_top/
    config/
    reports/
    results/
```

Depending on the actual repository version, file names may be slightly different.

The important project components are:

```text
RTL signed subtractor
testbench
simulation script
Yosys synthesis script
OpenLane wrapper/configuration
documentation report
```

---

## 7. RTL Design Explanation

The signed subtractor can be written using Verilog's signed subtraction operator:

```verilog
assign y = a - b;
```

However, for safer handling of signed values and output width, it is better to sign-extend both operands before subtraction:

```verilog
assign y = {a[W-1], a} - {b[W-1], b};
```

This converts each W-bit input into a W+1-bit signed value.

For W = 6:

```text
a[5:0] becomes {a[5], a[5:0]}
b[5:0] becomes {b[5], b[5:0]}
```

This preserves the sign and allows the result to use one extra bit.

---

## 8. Example RTL Code

A typical implementation is:

```verilog
`timescale 1ns/1ps

module signed_subtractor #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire signed [W:0]   y
);

    assign y = {a[W-1], a} - {b[W-1], b};

endmodule
```

Important points:

```text
a and b are signed inputs.
y has W+1 bits.
manual sign extension is used.
the design is purely combinational.
```

---

## 9. Testbench Objective

The testbench should verify all possible input combinations for the selected width.

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
expected = a - b
```

and compare it against the RTL output.

---

## 10. Important Test Cases

Although the exhaustive test covers all cases, the following cases are especially important:

```text
0 - 0 = 0
1 - 1 = 0
1 - (-1) = 2
-1 - 1 = -2
31 - 31 = 0
31 - (-32) = 63
-32 - 31 = -63
-32 - (-32) = 0
```

These cases verify:

```text
positive subtraction
negative subtraction
mixed-sign subtraction
zero behavior
maximum positive result
maximum negative result
output width correctness
```

---

## 11. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/signed_subtractor_sim \
    rtl/signed_subtractor.v \
    tb/tb_signed_subtractor.v

vvp sim/signed_subtractor_sim
```

If a project script exists, use:

```bash
./sim/run_signed_subtractor.sh
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
1. Loop over all possible values of a.
2. Loop over all possible values of b.
3. Apply a and b to the DUT.
4. Wait for combinational propagation.
5. Compute expected = a - b.
6. Compare DUT output with expected.
7. Count errors.
```

A simplified checking pattern is:

```verilog
for (ia = -32; ia <= 31; ia = ia + 1) begin
    for (ib = -32; ib <= 31; ib = ib + 1) begin
        a = ia;
        b = ib;
        #1;
        expected = ia - ib;

        if (y !== expected) begin
            error_count = error_count + 1;
        end

        test_count = test_count + 1;
    end
end
```

The actual testbench may use parameters instead of fixed values.

---

## 13. What To Check In The Waveform

If a waveform is generated, open it using:

```bash
gtkwave sim/waveforms/signed_subtractor.vcd
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

Useful waveform checks:

```text
a = 31,  b = -32 → y = 63
a = -32, b = 31  → y = -63
a = -1,  b = 1   → y = -2
a = 1,   b = -1  → y = 2
```

Because the testbench is exhaustive, waveform inspection is mainly useful for learning and debugging.

---

## 14. Expected Simulation Result

Project 1.2 is considered functionally correct if the simulation reports:

```text
Total tests  = 4096
Total errors = 0
ALL TESTS PASSED
```

If the actual repository has a confirmed simulation log, record it here:

```text
Actual simulation result:
Total tests  =
Total errors =
Status       =
```

---

## 15. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/signed_subtractor.v

hierarchy -check -top signed_subtractor

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/signed_subtractor_synth.v
```

Run synthesis:

```bash
yosys -s synth/signed_subtractor.ys | tee synth/reports/signed_subtractor_yosys.log
```

---

## 16. What To Check In The Yosys Report

Important fields:

```text
Number of wires
Number of wire bits
Number of public wires
Number of public wire bits
Number of cells
logic gate breakdown
```

Because the subtractor is combinational, it should not contain:

```text
DFF cells
memory cells
processes after synthesis
```

Expected logic components include:

```text
XOR/XNOR gates
AND/NAND gates
OR/NOR gates
carry/borrow logic
```

---

## 17. Interpretation Of The Yosys Result

The signed subtractor is expected to synthesize into a small combinational circuit.

The exact cell count depends on:

```text
bit width
synthesis strategy
optimization passes
target library
whether the subtractor is mapped as adder plus negation
```

The important point is not the exact number alone, but that:

```text
the design synthesizes successfully
the design is combinational
the cell count is reasonable for a small arithmetic primitive
```

---

## 18. OpenLane Top-Level Wrapper

For OpenLane, a fixed-parameter top module may be used.

A possible wrapper is:

```verilog
module signed_subtractor_top (
    input  wire signed [5:0] a,
    input  wire signed [5:0] b,
    output wire signed [6:0] y
);

    signed_subtractor #(
        .W(6)
    ) u_subtractor (
        .a(a),
        .b(b),
        .y(y)
    );

endmodule
```

The wrapper fixes:

```text
W = 6
```

and provides a stable top-level module for synthesis and physical implementation.

---

## 19. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/signed_subtractor_top/
  config.tcl
  src/
    signed_subtractor.v
    signed_subtractor_top.v
```

A typical OpenLane configuration may include:

```tcl
set ::env(DESIGN_NAME) signed_subtractor_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(FP_SIZING) absolute

set ::env(DIE_AREA) "0 0 120 120"

set ::env(PL_TARGET_DENSITY) 0.45

set ::env(SYNTH_STRATEGY) "AREA 0"
```

If the design is purely combinational, it may not require a clock. Some flows may still use a registered wrapper depending on the project setup.

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
./flow.tcl -design signed_subtractor_top
```

After completion:

```bash
exit
```

Check results:

```bash
cd ~/OpenLane/designs/signed_subtractor_top

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

If the OpenLane run is clean, it confirms that:

```text
the signed subtractor can be physically implemented
the layout follows design rules
the layout matches the synthesized netlist
antenna violations are resolved
the primitive is suitable for reuse in later hardware modules
```

This result is important because SC decoder hardware will later reuse signed subtraction inside the g operation.

---

## 24. Difference Between Adder And Subtractor

The signed adder computes:

```text
y = a + b
```

The signed subtractor computes:

```text
y = a - b
```

At the hardware level, subtraction may be implemented as:

```text
addition with two's-complement negation
```

Therefore, subtractor logic may look similar to adder logic, but with additional inversion/carry behavior depending on synthesis.

Both units are necessary for a clear bottom-up learning flow.

---

## 25. Common Problems And Debugging

### Problem 1: Incorrect Negative Results

Possible causes:

```text
input not declared signed
output not declared signed
testbench expected value treated as unsigned
```

Fix:

```verilog
input  wire signed [W-1:0] a;
input  wire signed [W-1:0] b;
output wire signed [W:0]   y;
```

---

### Problem 2: Output Overflow

If output width is only W bits, values such as:

```text
31 - (-32) = 63
-32 - 31 = -63
```

cannot be represented correctly for W = 6.

Fix:

```text
Use W+1 output bits.
```

---

### Problem 3: Missing Sign Extension

If operands are not sign-extended before subtraction, boundary cases may fail.

Fix:

```verilog
assign y = {a[W-1], a} - {b[W-1], b};
```

---

### Problem 4: Testbench Loop Range Error

If loop variables do not cover the full signed range, exhaustive verification is incomplete.

For W = 6, the correct range is:

```text
-32 to 31
```

---

### Problem 5: OpenLane Top Module Mismatch

Possible causes:

```text
DESIGN_NAME does not match top module
wrapper file missing
wrong file copied to OpenLane src folder
```

Fix:

```text
Check config.tcl.
Check src/ folder.
Check top module name.
```

---

## 26. Lessons Learned

Project 1.2 teaches the following key lessons:

```text
1. Signed subtraction is essential for SC g operation.
2. Two's-complement subtraction must be handled carefully in RTL.
3. Output width should be W+1 to preserve the full result range.
4. Exhaustive testing is feasible and valuable for small arithmetic blocks.
5. Signed adder and subtractor together form the arithmetic foundation for LLR update logic.
6. A verified subtractor can be reused safely in larger decoder modules.
```

---

## 27. Role Of This Project In The Full Roadmap

Project 1.2 belongs to the arithmetic primitive layer of the full roadmap.

The progression is:

```text
Project 0: validate RTL-to-GDSII flow
Project 1.1: signed addition
Project 1.2: signed subtraction
Project 1.3: absolute value
Project 1.4: minimum comparator
Project 1.5: absolute-minimum unit
Project 2: SC f unit
Project 3: SC g unit
```

The signed subtractor will be reused when implementing:

```text
SC g unit
conditional LLR update
scheduled SC decoder
resource-shared f/g datapath
```

---

## 28. What This Project Is Not

Project 1.2 is not a standalone research contribution.

It should not be presented as:

```text
a novel subtractor architecture
an optimized arithmetic circuit
a publication-level contribution
```

Instead, it should be presented as:

```text
a verified signed arithmetic primitive
a training milestone
a reusable building block for SC decoder hardware
```

---

## 29. Conclusion

Project 1.2 implements and verifies a signed subtractor.

The signed subtractor is a necessary primitive for the SC g operation, where the decoder must compute either addition or subtraction depending on the previous decision bit.

This project strengthens the arithmetic foundation needed for later SC Polar decoder hardware.

The next step is Project 1.3: Absolute Value Unit.