# Project 1.1: Signed Adder

## 1. Project Objective

Project 1.1 implements and verifies a signed fixed-point adder in Verilog.

The main objective is to build a small but important arithmetic primitive that will later be reused in SC Polar decoder hardware.

The signed adder computes:

```text
y = a + b
```

where `a` and `b` are signed fixed-width inputs.

This project is part of the arithmetic foundation for later decoder modules such as:

```text
SC g unit
LLR update logic
resource-shared f/g datapath
scheduled SC decoder architecture
```

At the end of this project, the learner should understand:

```text
how signed numbers are represented in Verilog
how signed addition is synthesized into logic gates
how to verify signed arithmetic exhaustively
how a small arithmetic block fits into a larger decoder roadmap
```

---

## 2. Why This Project Is Important

SC Polar decoding operates on LLR values.

LLR stands for Log-Likelihood Ratio. In hardware, LLRs are usually represented as signed fixed-point numbers.

For example:

```text
positive LLR  → bit is more likely to be 0
negative LLR  → bit is more likely to be 1
```

Because LLRs are signed, all arithmetic units used in the decoder must correctly handle signed values.

The signed adder is especially important because the SC g operation uses addition:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

Therefore, before implementing the SC g unit, we need a reliable signed adder.

The central question of this project is:

```text
Can we design, verify, synthesize, and physically implement a small signed adder that can be reused later in the SC decoder datapath?
```

---

## 3. Technical Background

### 3.1 Signed Numbers In Digital Hardware

Most signed integers in digital hardware use two's-complement representation.

For a W-bit signed number:

```text
range = -2^(W-1) to 2^(W-1)-1
```

For example, with W = 6:

```text
minimum value = -32
maximum value = 31
```

Some examples:

```text
000000 = 0
000001 = 1
011111 = 31
111111 = -1
100000 = -32
```

---

### 3.2 Why Signed Declaration Matters In Verilog

In Verilog, arithmetic interpretation depends on whether a signal is declared as signed or unsigned.

Example:

```verilog
input  signed [W-1:0] a;
input  signed [W-1:0] b;
output signed [W:0]   y;
```

If `a` and `b` are not declared as signed, Verilog may treat them as unsigned values.

That can produce wrong arithmetic behavior for negative numbers.

Therefore, this project emphasizes correct signed declarations.

---

### 3.3 Output Width Consideration

If two W-bit signed numbers are added, the result may require W+1 bits to avoid overflow.

For example, with W = 6:

```text
31 + 31 = 62
-32 + -32 = -64
```

These values cannot be fully represented in 6-bit signed format, whose range is:

```text
-32 to 31
```

Therefore, a safer adder output width is:

```text
W+1 bits
```

This project may use:

```verilog
output signed [W:0] y;
```

so that the result has one extra bit.

---

## 4. Design Under Test

The design under test is a parameterized signed adder.

A typical interface is:

```verilog
module signed_adder #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire signed [W:0]   y
);
```

The function is:

```text
y = a + b
```

The design is combinational because the output depends only on current inputs.

There is no clock and no register in the basic signed adder.

---

## 5. Expected File Structure

The expected file structure for Project 1.1 is:

```text
rtl/
  signed_adder.v

tb/
  tb_signed_adder.v

sim/
  run_signed_adder.sh
  waveforms/
    signed_adder.vcd

synth/
  signed_adder.ys
  reports/
    signed_adder_yosys.log
  netlist/
    signed_adder_synth.v

asic_openlane/
  signed_adder_top/
    config/
    reports/
    results/
```

Depending on the repository version, some filenames may be slightly different.

The important files are:

```text
RTL signed adder
testbench
simulation script
Yosys synthesis script
OpenLane wrapper/config/result
```

---

## 6. RTL Design Explanation

The signed adder is simple at the RTL level.

The core expression is:

```verilog
assign y = a + b;
```

However, to make the design safe, both operands should be sign-extended to the output width before addition.

A robust implementation style is:

```verilog
assign y = {a[W-1], a} + {b[W-1], b};
```

This manually extends each W-bit signed input to W+1 bits.

For example, if W = 6:

```text
a[5:0] becomes {a[5], a[5:0]} = 7-bit signed value
b[5:0] becomes {b[5], b[5:0]} = 7-bit signed value
```

This helps preserve sign information and avoids truncating the result.

---

## 7. Example RTL Code

A typical implementation is:

```verilog
`timescale 1ns/1ps

module signed_adder #(
    parameter W = 6
)(
    input  wire signed [W-1:0] a,
    input  wire signed [W-1:0] b,
    output wire signed [W:0]   y
);

    assign y = {a[W-1], a} + {b[W-1], b};

endmodule
```

Important points:

```text
The input operands are signed.
The output has W+1 bits.
Manual sign extension is used.
The design is purely combinational.
```

---

## 8. Testbench Objective

The testbench should verify the signed adder over all possible input combinations for the selected width.

For W = 6:

```text
a ranges from -32 to 31
b ranges from -32 to 31
```

The number of test cases is:

```text
64 × 64 = 4096
```

The testbench should compare the RTL output against a reference expression computed inside the testbench.

The expected reference is:

```text
expected = a + b
```

---

## 9. Important Test Cases

The exhaustive test should cover all cases automatically.

Important cases include:

```text
0 + 0 = 0
1 + 1 = 2
-1 + 1 = 0
31 + 31 = 62
-32 + -32 = -64
31 + -32 = -1
-32 + 31 = -1
```

These cases check:

```text
positive addition
negative addition
mixed-sign addition
zero behavior
maximum positive value
minimum negative value
output width correctness
```

---

## 10. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/signed_adder_sim \
    rtl/signed_adder.v \
    tb/tb_signed_adder.v

vvp sim/signed_adder_sim
```

If a script exists, use:

```bash
./sim/run_signed_adder.sh
```

Expected output:

```text
Total tests  = 4096
Total errors = 0
ALL TESTS PASSED
```

---

## 11. Confirmed Simulation Result

Project 1.1 achieved exhaustive verification.

Confirmed result:

```text
Total tests  = 4096
Total errors = 0
ALL TESTS PASSED
```

This means that for W = 6, all possible input pairs were tested and the RTL output matched the expected signed arithmetic result.

---

## 12. What To Check In The Waveform

If a waveform is generated, open it using:

```bash
gtkwave sim/waveforms/signed_adder.vcd
```

Signals to inspect:

```text
a
b
y
expected
error_count
```

Useful waveform checks:

```text
When a = 31 and b = 31, y should be 62.
When a = -32 and b = -32, y should be -64.
When a = -1 and b = 1, y should be 0.
```

Because the testbench is exhaustive, the waveform is mainly used for learning and debugging, not for manual verification of every case.

---

## 13. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/signed_adder.v

hierarchy -check -top signed_adder

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/signed_adder_synth.v
```

Run synthesis:

```bash
yosys -s synth/signed_adder.ys | tee synth/reports/signed_adder_yosys.log
```

---

## 14. Confirmed Yosys Synthesis Result

Yosys reported that the signed adder was synthesized into a small number of logic gates.

Confirmed result:

```text
=== signed_adder ===

Number of wires:                 25
Number of wire bits:             53
Number of public wires:           5
Number of public wire bits:      33
Number of memories:               0
Number of memory bits:            0
Number of processes:              0
Number of cells:                 27

  $_AND_                          2
  $_NAND_                        14
  $_XNOR_                         1
  $_XOR_                         10
```

This confirms that the arithmetic expression was mapped into combinational logic.

---

## 15. Interpretation Of The Yosys Result

The signed adder contains:

```text
XOR/XNOR gates for sum computation
AND/NAND gates for carry logic
no DFF cells
no memories
no processes after synthesis
```

Because this is a combinational adder, it should not contain flip-flops.

The cell count is small, which is expected for a 6-bit signed adder with a 7-bit output.

Important interpretation:

```text
The RTL arithmetic operator '+' was converted into gate-level logic.
The design is small and suitable as a reusable primitive.
```

---

## 16. OpenLane Top-Level Wrapper

For OpenLane, the design may need a top-level wrapper.

A possible wrapper is:

```verilog
module signed_adder_top (
    input  wire signed [5:0] a,
    input  wire signed [5:0] b,
    output wire signed [6:0] y
);

    signed_adder #(
        .W(6)
    ) u_adder (
        .a(a),
        .b(b),
        .y(y)
    );

endmodule
```

The wrapper fixes the parameter W = 6 for physical implementation.

Depending on the existing repository, the wrapper may already exist.

---

## 17. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/signed_adder_top/
  config.tcl
  src/
    signed_adder.v
    signed_adder_top.v
```

A typical configuration may include:

```tcl
set ::env(DESIGN_NAME) signed_adder_top

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) ""

set ::env(FP_SIZING) absolute

set ::env(DIE_AREA) "0 0 120 120"

set ::env(PL_TARGET_DENSITY) 0.45

set ::env(SYNTH_STRATEGY) "AREA 0"
```

Because the basic signed adder is combinational, it may not require a clock. However, some OpenLane configurations may still use a wrapper or registered interface.

The actual project configuration should be documented based on the run used.

---

## 18. OpenLane Flow

Run OpenLane from the OpenLane directory:

```bash
cd ~/OpenLane
make mount
```

Inside the container:

```bash
./flow.tcl -design signed_adder_top
```

After the run:

```bash
exit
```

Check the output:

```bash
cd ~/OpenLane/designs/signed_adder_top

RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo $RUN_DIR

find $RUN_DIR/results/final -name "*.gds"
cat $RUN_DIR/reports/manufacturability.rpt
head -n 5 $RUN_DIR/reports/metrics.csv
```

---

## 19. Confirmed OpenLane Result

Project 1.1 achieved a clean OpenLane implementation.

Confirmed result:

```text
Design Name: signed_adder_top

Magic DRC Summary:
Total Magic DRC violations is 0

LVS Summary:
Design is LVS clean.

Antenna Summary:
Pin violations: 0
Net violations: 0
```

Important metrics:

```text
Flow status: completed
GDSII generated
DIEAREA_mm^2 = 0.0144
synth_cell_count = 48
Magic_violations = 0
pin_antenna_violations = 0
net_antenna_violations = 0
lvs_total_errors = 0
critical_path_ns = 1.66
CLOCK_PERIOD = 10 ns
suggested_clock_frequency = 100 MHz
```

---

## 20. Interpretation Of The OpenLane Result

The OpenLane result confirms that the signed adder can be physically implemented.

The key clean signoff results are:

```text
Magic DRC = 0
LVS clean
Antenna = 0
Timing clean
```

This means:

```text
The layout follows design rules.
The layout matches the synthesized netlist.
No antenna violations remain.
The timing constraint is satisfied under the tested configuration.
```

This is an important milestone because it confirms that a basic signed arithmetic primitive can pass the same flow later used by larger decoder blocks.

---

## 21. Result Summary

Final Project 1.1 result:

```text
RTL simulation: passed
Exhaustive tests: 4096
Simulation errors: 0
Yosys synthesis: passed
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
Yosys cells: 27
OpenLane synth cell count: 48
OpenLane die area: 0.0144 mm²
OpenLane critical path: 1.66 ns
```

---

## 22. Why Yosys Cell Count And OpenLane Cell Count Are Different

Yosys generic synthesis reported:

```text
Number of cells = 27
```

OpenLane metrics reported:

```text
synth_cell_count = 48
```

These two numbers are not directly identical because they come from different synthesis/mapping stages.

Yosys reports generic cells such as:

```text
$_AND_
$_NAND_
$_XOR_
$_XNOR_
```

OpenLane maps logic into a technology-specific standard-cell library.

Therefore:

```text
Yosys cell count is useful for early logic comparison.
OpenLane cell count is useful for physical implementation analysis.
```

They should not be treated as the same metric.

---

## 23. Common Problems And Debugging

### Problem 1: Wrong Signed Behavior

Possible cause:

```text
inputs not declared as signed
output width too small
missing sign extension
```

Fix:

```verilog
input  wire signed [W-1:0] a;
input  wire signed [W-1:0] b;
output wire signed [W:0]   y;
```

Use sign extension:

```verilog
assign y = {a[W-1], a} + {b[W-1], b};
```

---

### Problem 2: Overflow In Output

If the output width is only W bits, results such as:

```text
31 + 31 = 62
-32 + -32 = -64
```

cannot be represented correctly for W = 6.

Fix:

```text
Use W+1 output bits.
```

---

### Problem 3: Testbench Expected Value Is Wrong

If the testbench uses unsigned variables, the reference value may be wrong.

Fix:

```text
Use signed integer reference values.
Check sign conversion carefully.
```

---

### Problem 4: OpenLane Top Module Mismatch

Possible cause:

```text
DESIGN_NAME does not match top module
wrapper file missing
source file not copied to OpenLane design folder
```

Fix:

```text
Check config.tcl.
Check src/ folder.
Check top module name.
```

---

## 24. Lessons Learned

Project 1.1 teaches the following key lessons:

```text
1. Signed arithmetic must be handled explicitly in Verilog.
2. Output width must be chosen carefully to avoid overflow.
3. Exhaustive verification is practical for small arithmetic blocks.
4. Yosys synthesis maps arithmetic RTL into gate-level logic.
5. OpenLane can physically implement a small signed arithmetic primitive.
6. Small verified blocks are the foundation for larger SC decoder architectures.
```

---

## 25. Role Of This Project In The Full Roadmap

The signed adder is used later in:

```text
SC g unit
LLR update datapath
scheduled SC decoder
resource-shared f/g datapath
```

In the full roadmap, Project 1.1 belongs to the arithmetic primitive layer.

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
```

---

## 26. What This Project Is Not

Project 1.1 is not a research contribution by itself.

It should not be presented as:

```text
a novel adder architecture
an optimized arithmetic unit
a standalone publication result
```

Instead, it should be presented as:

```text
a verified arithmetic primitive
a training milestone
a reusable building block for SC decoder hardware
```

---

## 27. Conclusion

Project 1.1 successfully implements, verifies, synthesizes, and physically validates a signed adder.

The design passed exhaustive RTL simulation, synthesized into a small combinational gate-level structure, and achieved clean OpenLane implementation.

This project establishes a reliable signed addition primitive for later SC Polar decoder hardware.

The next step is Project 1.2: Signed Subtractor.
EOF