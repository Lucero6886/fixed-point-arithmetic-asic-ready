# Project 4: Polar Encoder N=8

## 1. Project Objective

Project 4 implements and verifies a Polar Encoder with code length N=8.

The main objective is to understand how Polar encoding works at the RTL level and how the encoder relates to partial-sum generation in SC Polar decoding.

The Polar Encoder N=8 maps an input bit vector:

```text
u[0:7]
```

to an encoded codeword:

```text
x[0:7]
```

using the Arikan polar transform.

At the end of this project, the learner should understand:

```text
what Polar encoding means
how the XOR butterfly network implements the polar transform
why the encoder is much more regular than the decoder
how to verify all 2^8 input vectors
how the encoder is later reused conceptually for partial sums in SC decoding
```

---

## 2. Why This Project Is Important

Before building a complete SC decoder, it is necessary to understand the Polar encoder.

The encoder is important for two reasons.

First, it defines the code structure:

```text
u → x
```

where:

```text
u = source/frozen/information bit vector
x = encoded codeword
```

Second, the same XOR structure appears inside the SC decoder when computing partial sums.

In SC decoding, after the left branch is decoded, the decoder needs partial sums to compute the right-branch LLRs using g operations.

Therefore, understanding the encoder helps clarify:

```text
how partial sums are generated
why XOR relationships appear in SC decoding
how decoded bits from the left branch influence the right branch
```

The central question of this project is:

```text
Can we implement and verify a small Polar Encoder N=8 as a clean, reusable hardware block?
```

---

## 3. Relationship With Previous Projects

The previous projects built arithmetic and SC primitive blocks:

```text
Project 1.1: signed_adder
Project 1.2: signed_subtractor
Project 1.3: abs_unit
Project 1.4: min_comparator
Project 1.5: abs_min_unit
Project 2: SC f unit
Project 3: SC g unit
```

Project 4 is different from Projects 1–3.

Projects 1–3 operate mainly on signed LLR values.

Project 4 operates on binary bits.

The encoder is composed mainly of XOR logic, not signed arithmetic.

This makes it simpler and more regular than the decoder.

---

## 4. Technical Background

### 4.1 Polar Code Encoding

A Polar code uses the generator matrix:

```text
G_N = F^{⊗n}
```

where:

```text
N = 2^n
```

and:

```text
F = [1 0
     1 1]
```

For N=8:

```text
N = 8
n = log2(8) = 3
G_8 = F^{⊗3}
```

The encoded codeword is:

```text
x = u G_8
```

where all operations are over GF(2), meaning addition is XOR.

---

### 4.2 XOR-Based Hardware

Because Polar encoding is performed over GF(2), hardware implementation is based on XOR gates.

There are:

```text
no signed values
no adders for arithmetic addition
no subtractors
no comparators
no LLRs
```

Only bit-level XOR operations are needed.

This makes the encoder structurally regular and hardware-friendly.

---

### 4.3 Non-Bit-Reversed Convention

In this roadmap, the encoder convention follows the recursive non-bit-reversed Arikan transform used consistently with the SC decoder partial-sum convention.

For N=4, the transform is:

```text
x0 = u0 ^ u1 ^ u2 ^ u3
x1 = u1 ^ u3
x2 = u2 ^ u3
x3 = u3
```

For N=8, the same recursive structure is extended.

It is important to keep this convention consistent across:

```text
Python golden model
RTL encoder
SC decoder partial sums
testbench reference
```

---

## 5. Design Under Test

The design under test is a combinational Polar Encoder N=8.

A typical interface is:

```verilog
module polar_encoder_n8 (
    input  wire [7:0] u,
    output wire [7:0] x
);
```

The function is:

```text
x = polar_encode_N8(u)
```

The design is combinational.

It has:

```text
no clock
no reset
no internal state
```

A registered wrapper may be used later for OpenLane timing analysis.

---

## 6. Expected File Structure

The expected file structure for Project 4 is:

```text
rtl/
  polar_encoder_n8.v
  polar_encoder_n8_top.v

tb/
  tb_polar_encoder_n8.v
  tb_polar_encoder_n8_top.v

sim/
  run_polar_encoder_n8.sh
  run_polar_encoder_n8_top.sh
  waveforms/
    polar_encoder_n8.vcd
    polar_encoder_n8_top.vcd

synth/
  polar_encoder_n8.ys
  polar_encoder_n8_top.ys
  reports/
    polar_encoder_n8_yosys.log
    polar_encoder_n8_top_yosys.log
  netlist/
    polar_encoder_n8_synth.v
    polar_encoder_n8_top_synth.v

asic_openlane/
  polar_encoder_n8_top/
    config/
    reports/
    results/
```

Depending on the repository version, some filenames may be slightly different.

---

## 7. Polar Encoder N=8 Architecture

The Polar Encoder N=8 can be implemented as an XOR butterfly network.

The transform can be understood recursively:

```text
u[0:7]
→ combine pairs
→ combine groups of 4
→ combine groups of 8
→ x[0:7]
```

A common XOR network can be described in three stages.

### Stage 1: Distance-1 XORs

```text
s1[0] = u0 ^ u1
s1[1] = u1
s1[2] = u2 ^ u3
s1[3] = u3
s1[4] = u4 ^ u5
s1[5] = u5
s1[6] = u6 ^ u7
s1[7] = u7
```

### Stage 2: Distance-2 XORs

```text
s2[0] = s1[0] ^ s1[2]
s2[1] = s1[1] ^ s1[3]
s2[2] = s1[2]
s2[3] = s1[3]

s2[4] = s1[4] ^ s1[6]
s2[5] = s1[5] ^ s1[7]
s2[6] = s1[6]
s2[7] = s1[7]
```

### Stage 3: Distance-4 XORs

```text
x0 = s2[0] ^ s2[4]
x1 = s2[1] ^ s2[5]
x2 = s2[2] ^ s2[6]
x3 = s2[3] ^ s2[7]
x4 = s2[4]
x5 = s2[5]
x6 = s2[6]
x7 = s2[7]
```

This gives the final encoded output.

---

## 8. Expanded Boolean Equations

Using the recursive convention, the N=8 encoder can be written as:

```text
x0 = u0 ^ u1 ^ u2 ^ u3 ^ u4 ^ u5 ^ u6 ^ u7
x1 = u1 ^ u3 ^ u5 ^ u7
x2 = u2 ^ u3 ^ u6 ^ u7
x3 = u3 ^ u7
x4 = u4 ^ u5 ^ u6 ^ u7
x5 = u5 ^ u7
x6 = u6 ^ u7
x7 = u7
```

These equations are useful for:

```text
manual checking
testbench reference
debugging waveform
explaining partial sums later
```

---

## 9. Example RTL Code

A typical implementation using staged XORs is:

```verilog
`timescale 1ns/1ps

module polar_encoder_n8 (
    input  wire [7:0] u,
    output wire [7:0] x
);

    wire [7:0] s1;
    wire [7:0] s2;

    assign s1[0] = u[0] ^ u[1];
    assign s1[1] = u[1];
    assign s1[2] = u[2] ^ u[3];
    assign s1[3] = u[3];
    assign s1[4] = u[4] ^ u[5];
    assign s1[5] = u[5];
    assign s1[6] = u[6] ^ u[7];
    assign s1[7] = u[7];

    assign s2[0] = s1[0] ^ s1[2];
    assign s2[1] = s1[1] ^ s1[3];
    assign s2[2] = s1[2];
    assign s2[3] = s1[3];
    assign s2[4] = s1[4] ^ s1[6];
    assign s2[5] = s1[5] ^ s1[7];
    assign s2[6] = s1[6];
    assign s2[7] = s1[7];

    assign x[0] = s2[0] ^ s2[4];
    assign x[1] = s2[1] ^ s2[5];
    assign x[2] = s2[2] ^ s2[6];
    assign x[3] = s2[3] ^ s2[7];
    assign x[4] = s2[4];
    assign x[5] = s2[5];
    assign x[6] = s2[6];
    assign x[7] = s2[7];

endmodule
```

Important points:

```text
The encoder is purely combinational.
The operation is XOR-based.
No arithmetic signed operations are used.
The output convention must match the decoder partial-sum convention.
```

---

## 10. Alternative Direct Equation Implementation

The encoder may also be implemented directly using expanded equations:

```verilog
assign x[0] = u[0] ^ u[1] ^ u[2] ^ u[3] ^ u[4] ^ u[5] ^ u[6] ^ u[7];
assign x[1] = u[1] ^ u[3] ^ u[5] ^ u[7];
assign x[2] = u[2] ^ u[3] ^ u[6] ^ u[7];
assign x[3] = u[3] ^ u[7];
assign x[4] = u[4] ^ u[5] ^ u[6] ^ u[7];
assign x[5] = u[5] ^ u[7];
assign x[6] = u[6] ^ u[7];
assign x[7] = u[7];
```

This implementation is compact, but the staged implementation is usually better for teaching because it shows the butterfly structure.

---

## 11. Testbench Objective

The testbench should verify all possible 8-bit inputs.

Since the input vector has 8 bits:

```text
number of possible inputs = 2^8 = 256
```

For each input `u`, the testbench should compute the expected encoded vector `x_expected` using either:

```text
reference equations
recursive encoder function
known Python golden model
```

Then it should compare:

```text
DUT output x
against
expected output x_expected
```

The encoder passes if all 256 cases match.

---

## 12. Important Test Cases

Although exhaustive testing covers all cases, the following cases are useful for manual understanding:

```text
u = 00000000 → x = 00000000
u = 00000001 → only u0 active
u = 00000010 → only u1 active
u = 10000000 → only u7 active
u = 11111111 → all bits active
u = 10101010 → alternating pattern
u = 01010101 → alternating pattern
```

Because XOR operations are over GF(2), repeated XOR of ones may cancel depending on the number of active bits.

---

## 13. RTL Simulation Flow

Run simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim/polar_encoder_n8_sim \
    rtl/polar_encoder_n8.v \
    tb/tb_polar_encoder_n8.v

vvp sim/polar_encoder_n8_sim
```

If a project script exists, use:

```bash
./sim/run_polar_encoder_n8.sh
```

Expected result:

```text
Total tests  = 256
Total errors = 0
ALL TESTS PASSED
```

---

## 14. Suggested Testbench Structure

A typical exhaustive testbench should:

```text
1. Loop through all values of u from 0 to 255.
2. Apply u to the DUT.
3. Wait for combinational propagation.
4. Compute expected x.
5. Compare DUT output with expected.
6. Count errors.
```

A simplified checking pattern is:

```verilog
for (i = 0; i < 256; i = i + 1) begin
    u = i[7:0];
    #1;

    expected[0] = u[0] ^ u[1] ^ u[2] ^ u[3] ^ u[4] ^ u[5] ^ u[6] ^ u[7];
    expected[1] = u[1] ^ u[3] ^ u[5] ^ u[7];
    expected[2] = u[2] ^ u[3] ^ u[6] ^ u[7];
    expected[3] = u[3] ^ u[7];
    expected[4] = u[4] ^ u[5] ^ u[6] ^ u[7];
    expected[5] = u[5] ^ u[7];
    expected[6] = u[6] ^ u[7];
    expected[7] = u[7];

    if (x !== expected) begin
        error_count = error_count + 1;
    end

    test_count = test_count + 1;
end
```

---

## 15. Expected Simulation Result

Project 4 is considered functionally correct if the simulation reports:

```text
Total tests  = 256
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
gtkwave sim/waveforms/polar_encoder_n8.vcd
```

Signals to inspect:

```text
u
x
expected
error_count
```

Useful waveform checks:

```text
u = 00000000 → x = 00000000
u = 11111111 → check XOR parity-based output
u = 00000001 → check contribution of u0
u = 10000000 → check contribution of u7
```

Waveform inspection helps learners see how input bits propagate through the XOR network.

---

## 17. Yosys Synthesis Flow

A typical Yosys script is:

```tcl
read_verilog rtl/polar_encoder_n8.v

hierarchy -check -top polar_encoder_n8

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/polar_encoder_n8_synth.v
```

For a top-level wrapper:

```tcl
read_verilog rtl/polar_encoder_n8.v
read_verilog rtl/polar_encoder_n8_top.v

hierarchy -check -top polar_encoder_n8_top

proc
opt
techmap
opt
abc
opt
clean

stat

write_verilog synth/netlist/polar_encoder_n8_top_synth.v
```

Run synthesis:

```bash
yosys -s synth/polar_encoder_n8.ys | tee synth/reports/polar_encoder_n8_yosys.log
```

or:

```bash
yosys -s synth/polar_encoder_n8_top.ys | tee synth/reports/polar_encoder_n8_top_yosys.log
```

---

## 18. What To Check In The Yosys Report

Important fields:

```text
Number of wires
Number of wire bits
Number of cells
XOR/XNOR cells
DFF cells if using a registered wrapper
```

The basic Polar Encoder N=8 should mainly synthesize into XOR/XNOR logic.

If the implementation is purely combinational, it should not contain DFF cells.

If a registered top wrapper is used, DFF cells may appear.

---

## 19. Interpretation Of The Yosys Result

The Polar Encoder N=8 is expected to synthesize into a small XOR network.

Compared with SC f/g units, the encoder is simpler because it does not use:

```text
signed arithmetic
absolute value
minimum comparison
hard decisions
frozen-mask handling
```

Important interpretation:

```text
The encoder is structurally regular and hardware-friendly.
```

This is very different from the SC decoder, which is recursive and decision-dependent.

---

## 20. OpenLane Top-Level Wrapper

For OpenLane, a fixed top-level wrapper may be used.

A simple combinational wrapper could be:

```verilog
module polar_encoder_n8_top (
    input  wire [7:0] u,
    output wire [7:0] x
);

    polar_encoder_n8 u_enc (
        .u(u),
        .x(x)
    );

endmodule
```

A registered wrapper may also be used to create clear timing paths:

```text
input register
polar_encoder_n8 combinational core
output register
```

The actual wrapper should be documented based on the repository implementation.

---

## 21. OpenLane Design Setup

A typical OpenLane design folder is:

```text
~/OpenLane/designs/polar_encoder_n8_top/
  config.tcl
  src/
    polar_encoder_n8.v
    polar_encoder_n8_top.v
```

A typical OpenLane configuration may include:

```tcl
set ::env(DESIGN_NAME) polar_encoder_n8_top

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
./flow.tcl -design polar_encoder_n8_top
```

After completion:

```bash
exit
```

Check result:

```bash
cd ~/OpenLane/designs/polar_encoder_n8_top

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

If the OpenLane run is clean, it confirms that the Polar Encoder N=8 can be physically implemented.

This result is useful because it validates the XOR network through the physical design flow.

A clean result means:

```text
the layout follows design rules
the layout matches the synthesized netlist
antenna violations are resolved
timing is satisfied under the selected configuration
GDSII was generated successfully
```

---

## 26. Difference Between Encoder And Decoder

The Polar Encoder N=8 is much simpler than the SC decoder.

| Feature | Polar Encoder N=8 | SC Decoder |
|---|---|---|
| Data type | bits | signed LLRs |
| Main operation | XOR | f/g LLR update |
| Sequential dependency | no | yes |
| Frozen mask | no | yes |
| Hard decision | no | yes |
| Partial sums | implicit XOR network | explicitly required |
| Architecture | regular | recursive and decision-dependent |

This comparison is important because learners often underestimate the decoder complexity after seeing the encoder.

---

## 27. Connection To Partial Sums

Partial sums in SC decoding follow the same XOR structure as Polar encoding.

For example, when a left branch is decoded, the decoder may need encoded combinations of those decoded bits to compute right-branch g operations.

For N=4:

```text
partial0 = u0 ^ u1
partial1 = u1
```

For larger branches, the partial-sum structure follows the same polar transform.

Thus, Project 4 helps explain why the encoder is not only useful for transmission, but also conceptually important inside the decoder.

---

## 28. Connection To SC Decoder N=4 And N=8

In SC Decoder N=4 and N=8, partial sums are used in g operations.

For example, in an N=8 decoder:

```text
decode left N=4 branch
compute partial sums from u_left
use partial sums in g operations
decode right N=4 branch
```

Therefore, understanding the encoder structure helps avoid mistakes in:

```text
partial-sum generation
g-operation control bit selection
u_hat bit ordering
left/right branch convention
```

---

## 29. Common Problems And Debugging

### Problem 1: Bit Ordering Mismatch

Polar encoding is very sensitive to bit ordering.

Possible mismatch:

```text
u[0] interpreted as MSB in one file
u[0] interpreted as LSB in another file
```

Fix:

```text
Document the bit convention clearly.
Use the same convention in RTL, testbench, and Python model.
```

---

### Problem 2: Wrong Transform Convention

Some references use bit-reversal or different generator matrix ordering.

This roadmap uses the recursive convention consistent with the SC decoder partial-sum model.

Fix:

```text
Do not mix transform conventions.
Compare with the project golden model, not only with external formula tables.
```

---

### Problem 3: Missing XOR Term

Expanded equations can easily miss one XOR term.

Fix:

```text
Use staged butterfly implementation.
Use exhaustive 256-vector testbench.
```

---

### Problem 4: Testbench Reference Uses Different Convention

If the testbench uses a different encoder convention, the RTL may appear wrong even if it is internally consistent.

Fix:

```text
Make the testbench reference match the chosen project convention.
```

---

### Problem 5: OpenLane Top Module Mismatch

Possible causes:

```text
DESIGN_NAME does not match top module
wrapper file missing
source file not copied to OpenLane src folder
```

Fix:

```text
check config.tcl
check src folder
check RTL module name
check synthesis log
```

---

## 30. Lessons Learned

Project 4 teaches the following key lessons:

```text
1. Polar encoding is an XOR-based transform over GF(2).
2. The encoder is structurally regular and easier than the decoder.
3. Bit-order convention must be fixed and documented.
4. Exhaustive testing is feasible for N=8 because there are only 256 input vectors.
5. The encoder structure is closely related to partial-sum generation in SC decoding.
6. Understanding the encoder helps prevent errors in later SC decoder design.
```

---

## 31. Role Of This Project In The Full Roadmap

Project 4 belongs to the baseline Polar hardware layer.

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

The Polar Encoder N=8 supports later understanding of:

```text
partial sums
recursive transform
decoder bit ordering
SC g-operation control
```

---

## 32. What This Project Is Not

Project 4 is not a standalone publication-level contribution.

It should not be presented as:

```text
a novel Polar encoder architecture
a complete decoder
a full communication system
a standalone Q1-level contribution
```

Instead, it should be presented as:

```text
a verified baseline Polar encoder
a training milestone
a foundation for understanding partial sums and SC decoding
```

---

## 33. Conclusion

Project 4 implements and verifies a Polar Encoder N=8.

The encoder is an XOR-based combinational network that maps:

```text
u[0:7] → x[0:7]
```

using the selected recursive Polar transform convention.

This project is important because the same XOR structure appears later in SC decoder partial-sum generation.

Project 4 provides the conceptual bridge from SC primitive operations to complete Polar encoder/decoder systems.

The next step is Project 5: SC Decoder N=4.