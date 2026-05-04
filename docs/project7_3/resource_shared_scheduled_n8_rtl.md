# Project 7.3: Resource-Shared Scheduled SC Decoder N=8

## 1. Project Objective

Project 7.3 implements a resource-shared scheduled SC Decoder N=8.

The main objective is to improve the scheduled decoder architecture from Project 7.1 by explicitly sharing hardware resources.

Project 7.1 showed that a multi-cycle scheduled decoder can be functionally correct.

Project 7.2 showed that scheduling alone does not automatically reduce hardware complexity.

The key result from Project 7.2 was:

```text
Combinational N=8 total cells = 1475
Scheduled N=8 total cells     = 2527
Scheduled / combinational ratio ≈ 1.71×
```

Therefore, Project 7.3 introduces an explicitly shared datapath.

The goal is to move from:

```text
FSM-scheduled computation
```

to:

```text
FSM-scheduled computation + shared f/g datapath
```

At the end of this project, the learner should understand:

```text
what resource sharing means
why scheduling alone is not enough
how to design a shared f/g datapath
how an FSM controls operand selection and writeback
how to verify a resource-shared decoder using golden vectors
how this architecture prepares scalable N=16/N=32 decoder development
```

---

## 2. Why This Project Is Important

Project 7.2 revealed a key issue:

```text
The scheduled decoder was larger than the combinational decoder.
```

This happened because the RTL scheduled the algorithm over multiple cycles, but it did not sufficiently force the hardware to reuse the same datapath.

A synthesis tool does not always infer resource sharing automatically.

If the RTL describes multiple independent arithmetic expressions, the tool may create multiple pieces of hardware and then add mux/control logic around them.

Therefore, Project 7.3 explicitly designs one shared computation datapath.

The central question is:

```text
Can we reduce duplicated f/g logic by using a shared datapath controlled by an FSM?
```

This project is the real beginning of architecture optimization.

---

## 3. Position In The Roadmap

The roadmap around Project 7 is:

```text
Project 6.4: Combinational N=8 OpenLane clean baseline
Project 7.1: Scheduled / multi-cycle N=8 RTL baseline
Project 7.2: Yosys comparison — combinational vs scheduled N=8
Project 7.3: Resource-shared scheduled N=8 RTL
Project 7.4: Three-architecture Yosys comparison
Project 7.5: OpenLane implementation of resource-shared N=8
Project 7.6: Timing push for resource-shared N=8
```

Project 7.3 is the architectural correction after Project 7.2.

Project 7.2 showed the problem.

Project 7.3 proposes the solution.

---

## 4. Main Architectural Idea

The main idea is:

```text
Instead of instantiating or inferring many f/g logic blocks,
use one shared f/g datapath and reuse it over multiple cycles.
```

The shared datapath receives operands:

```text
fu_a
fu_b
fu_is_g
fu_g_bit
```

and produces:

```text
fu_y
```

If:

```text
fu_is_g = 0
```

then the datapath computes:

```text
fu_y = f(fu_a, fu_b)
```

If:

```text
fu_is_g = 1
```

then the datapath computes:

```text
fu_y = g(fu_a, fu_b, fu_g_bit)
```

This datapath is reused by the FSM for different SC decoding steps.

---

## 5. Resource Sharing Definition

Resource sharing means:

```text
The same hardware block is reused to perform multiple operations at different time steps.
```

For this project, the shared resource is:

```text
one f/g computation datapath
```

Instead of having:

```text
f0, f1, f2, f3, g0, g1, g2, g3, ...
```

the decoder uses:

```text
shared_f_g_unit
```

and changes the input operands every cycle.

This saves combinational logic at the cost of more cycles and some control/register overhead.

---

## 6. Difference Between Scheduled And Resource-Shared

A scheduled decoder means:

```text
operations are assigned to different cycles
```

A resource-shared decoder means:

```text
the same hardware is reused across those cycles
```

These are not the same.

Project 7.1 was scheduled.

Project 7.3 is scheduled and resource-shared.

Comparison:

| Feature | Scheduled N=8 | Resource-Shared Scheduled N=8 |
|---|---|---|
| Multi-cycle | yes | yes |
| FSM control | yes | yes |
| Internal registers | yes | yes |
| Explicit shared f/g datapath | not necessarily | yes |
| Goal | correct scheduled behavior | reduce duplicated datapath logic |
| Expected area trend | may increase | should reduce logic count |

---

## 7. Input Files

The main input files for Project 7.3 are expected to be:

```text
rtl/sc_decoder_n8_shared.v
tb/tb_sc_decoder_n8_shared_vectors.v
sim/run_sc_decoder_n8_shared_vectors.sh
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

The golden vector file is reused from Project 6.1:

```text
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

This ensures that all N=8 architectures are verified against the same reference.

---

## 8. Output Files

Expected output files include:

```text
sim/sc_decoder_n8_shared_vectors_sim
sim/waveforms/sc_decoder_n8_shared_vectors.vcd
simulation console output
```

The expected verification target is:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED
```

If the exact final simulation log differs, paste the actual log in the result section.

---

## 9. Expected File Structure

The expected file structure for Project 7.3 is:

```text
rtl/
  sc_decoder_n8_shared.v

tb/
  tb_sc_decoder_n8_shared_vectors.v

sim/
  run_sc_decoder_n8_shared_vectors.sh
  waveforms/
    sc_decoder_n8_shared_vectors.vcd

tests/
  golden_vectors/
    sc_decoder_n8_vectors.csv

docs/
  project7_3/
    resource_shared_scheduled_n8_rtl.md
```

---

## 10. High-Level Architecture

The resource-shared SC Decoder N=8 consists of two main parts:

```text
1. Control path
2. Datapath
```

The control path contains:

```text
FSM state register
next-state logic
start/busy/done control
write-enable control
operand-selection control
destination-selection control
```

The datapath contains:

```text
LLR registers
intermediate registers
decoded-bit registers
partial-sum registers
shared f/g computation unit
writeback path
```

High-level diagram:

```text
                    +------------------+
start, clk, rst --->| FSM Controller   |
                    +--------+---------+
                             |
                             | control signals
                             v
+--------------------------------------------------+
| Register File / Internal Storage                 |
| L0..L7, left0..left3, right0..right3, u0..u7     |
+----------------------+---------------------------+
                       |
                       | operand select
                       v
              +-------------------+
              | Shared f/g unit   |
              |                   |
              | if is_g=0: f      |
              | if is_g=1: g      |
              +---------+---------+
                        |
                        | writeback
                        v
+--------------------------------------------------+
| Destination Registers / u_hat Output             |
+--------------------------------------------------+
```

---

## 11. Shared f/g Datapath

The shared datapath computes either f or g.

The input signals are:

```text
fu_a
fu_b
fu_is_g
fu_g_bit
```

The output signal is:

```text
fu_y
```

Functional behavior:

```text
if fu_is_g = 0:
    fu_y = f(fu_a, fu_b)

if fu_is_g = 1:
    fu_y = g(fu_a, fu_b, fu_g_bit)
```

where:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

and:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

---

## 12. Why Combine f And g In One Datapath?

The f and g operations are different, but they both operate on LLR values.

They share common hardware themes:

```text
signed input handling
sign/magnitude manipulation
conditional arithmetic
signed output generation
```

Combining them into one shared datapath allows the FSM to reuse the same arithmetic structure across the SC schedule.

This is especially useful for larger N, where the number of f/g operations grows quickly.

---

## 13. SC Decoder N=8 Schedule

The resource-shared decoder must still follow the same SC schedule as the golden model.

The schedule is:

```text
1. Load LLRs and frozen mask.

2. Compute top-level left LLRs:
   left0 = f(L0, L4)
   left1 = f(L1, L5)
   left2 = f(L2, L6)
   left3 = f(L3, L7)

3. Decode left N=4 branch.

4. Generate top-level partial sums:
   p0 = u0 ^ u1 ^ u2 ^ u3
   p1 = u1 ^ u3
   p2 = u2 ^ u3
   p3 = u3

5. Compute top-level right LLRs:
   right0 = g(L0, L4, p0)
   right1 = g(L1, L5, p1)
   right2 = g(L2, L6, p2)
   right3 = g(L3, L7, p3)

6. Decode right N=4 branch.

7. Output u_hat and assert done.
```

The difference from the combinational decoder is that these operations are performed over time using the shared datapath.

---

## 14. Example Datapath Control Signals

A resource-shared implementation may use signals such as:

```text
fu_a_sel
fu_b_sel
fu_is_g
fu_g_bit_sel
fu_y
write_enable
write_destination
```

Example meaning:

```text
fu_a_sel:
    selects first operand source

fu_b_sel:
    selects second operand source

fu_is_g:
    selects f mode or g mode

fu_g_bit_sel:
    selects the u/partial bit used by g

write_destination:
    selects where fu_y is stored
```

This makes the hardware structure explicit.

---

## 15. Example FSM State Organization

A possible FSM state organization is:

```text
S_IDLE
S_LOAD

S_F_TOP0
S_F_TOP1
S_F_TOP2
S_F_TOP3

S_L_F0
S_L_DEC_U0
S_L_G0
S_L_DEC_U1
S_L_PARTIAL
S_L_F1
S_L_DEC_U2
S_L_G1
S_L_DEC_U3

S_TOP_PARTIAL

S_G_TOP0
S_G_TOP1
S_G_TOP2
S_G_TOP3

S_R_F0
S_R_DEC_U4
S_R_G0
S_R_DEC_U5
S_R_PARTIAL
S_R_F1
S_R_DEC_U6
S_R_G1
S_R_DEC_U7

S_DONE
```

The exact state names may differ.

The key requirement is that the state order respects SC decoding dependencies.

---

## 16. Register Storage

The design should store:

```text
input LLRs:
L0..L7

top-level left LLRs:
left0..left3

top-level right LLRs:
right0..right3

intermediate N=2 LLRs:
temporary f/g results inside left and right N=4 branches

decoded bits:
u0..u7

partial sums:
p0..p3

control:
state, busy, done
```

These registers allow the shared datapath output to be reused over multiple cycles.

---

## 17. Hard Decision Logic

For each decoded bit:

```text
if frozen_mask[i] = 1:
    u_i = 0
else:
    u_i = hard_decision(LLR)
```

The hard decision rule is:

```text
LLR < 0 → 1
LLR >= 0 → 0
```

This logic can be implemented directly in the FSM states that decode each bit.

Example:

```verilog
u0_reg <= frozen_mask_reg[0] ? 1'b0 : (llr_u0 < 0);
```

---

## 18. Partial-Sum Logic

Top-level N=8 partial sums are:

```text
p0 = u0 ^ u1 ^ u2 ^ u3
p1 = u1 ^ u3
p2 = u2 ^ u3
p3 = u3
```

These are used for the top-level right-branch g operations:

```text
right0 = g(L0, L4, p0)
right1 = g(L1, L5, p1)
right2 = g(L2, L6, p2)
right3 = g(L3, L7, p3)
```

Wrong partial sums will cause the right branch to fail.

---

## 19. Interface

A typical interface is:

```verilog
module sc_decoder_n8_shared #(
    parameter W = 6
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              start,

    input  wire signed [W-1:0] llr0,
    input  wire signed [W-1:0] llr1,
    input  wire signed [W-1:0] llr2,
    input  wire signed [W-1:0] llr3,
    input  wire signed [W-1:0] llr4,
    input  wire signed [W-1:0] llr5,
    input  wire signed [W-1:0] llr6,
    input  wire signed [W-1:0] llr7,

    input  wire        [7:0] frozen_mask,

    output reg         [7:0] u_hat,
    output reg               busy,
    output reg               done
);
```

The exact RTL may differ, but it should support a sequential start/done protocol.

---

## 20. Handshake Protocol

The expected handshake protocol is:

```text
1. When decoder is idle, apply input LLRs and frozen mask.
2. Pulse start for one clock cycle.
3. Decoder asserts busy.
4. Decoder runs through FSM schedule.
5. Decoder asserts done when u_hat is valid.
6. Testbench checks u_hat.
7. Decoder returns to idle or waits for next start.
```

The testbench must not check `u_hat` before `done`.

---

## 21. Verification Flow

The resource-shared RTL should be verified using the same golden vectors as previous N=8 architectures.

Verification flow:

```text
Python golden model
→ sc_decoder_n8_vectors.csv
→ Verilog testbench
→ resource-shared RTL
→ compare u_hat
→ pass/fail
```

The testbench should:

```text
read each CSV row
apply LLRs and frozen mask
pulse start
wait for done
compare u_hat
count errors
```

---

## 22. Simulation Command

Run simulation using:

```bash
./sim/run_sc_decoder_n8_shared_vectors.sh
```

A direct command may look like:

```bash
iverilog -g2012 -o sim/sc_decoder_n8_shared_vectors_sim \
    rtl/sc_decoder_n8_shared.v \
    tb/tb_sc_decoder_n8_shared_vectors.v

vvp sim/sc_decoder_n8_shared_vectors_sim
```

The exact command depends on whether helper RTL files are instantiated or the shared f/g datapath is implemented internally.

---

## 23. Expected Simulation Result

Project 7.3 is considered functionally correct if the simulation reports:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED
```

Record the actual final simulation log here:

```text
Actual simulation result:
Total vector lines read =
Total tests             =
Total errors            =
Status                  =
Waveform                =
```

---

## 24. What To Check In The Waveform

Open waveform:

```bash
gtkwave sim/waveforms/sc_decoder_n8_shared_vectors.vcd
```

Important signals to inspect:

```text
clk
rst_n
start
busy
done
state
fu_a
fu_b
fu_is_g
fu_g_bit
fu_y
write_destination
L0..L7 registers
left0..left3 registers
right0..right3 registers
u0..u7 registers
partial sums
u_hat
expected_u_hat
error_count
```

Important waveform behavior:

```text
fu_y should be reused across different states
fu_is_g should switch between f and g operations
writeback should store fu_y into the intended register
done should assert only after all u bits are decoded
u_hat should match expected output at done
```

---

## 25. Why Project 7.3 Should Reduce Logic

The resource-shared decoder should reduce duplicated combinational logic because it avoids instantiating many independent f/g computations.

Instead of building many f/g blocks in parallel, it reuses one datapath.

Expected impact:

```text
lower total cell count than scheduled baseline
lower estimated combinational cells
lower MUX count if operand selection is controlled cleanly
more registers than combinational baseline
higher latency than combinational baseline
```

The architecture trades time for area.

---

## 26. Expected Trade-Off

The expected trade-off is:

```text
area decreases
critical combinational path may decrease
latency in cycles increases
control complexity remains
```

This is typical for resource-shared architectures.

In general:

```text
combinational decoder:
    low cycle latency
    high combinational complexity
    long critical path

scheduled decoder:
    multi-cycle
    may have high control overhead
    not necessarily smaller

resource-shared decoder:
    multi-cycle
    shared datapath
    lower duplicated logic
    better area/timing trade-off
```

---

## 27. Difference Between Project 7.1 And Project 7.3

Project 7.1 proved that a scheduled decoder can be functionally correct.

Project 7.3 improves the datapath.

Comparison:

| Feature | Project 7.1 Scheduled | Project 7.3 Resource-Shared |
|---|---|---|
| FSM | yes | yes |
| Multi-cycle | yes | yes |
| Shared f/g datapath | no or limited | yes |
| Goal | verify scheduled behavior | reduce duplicated logic |
| Main risk | handshake/testbench timing | operand/writeback control |
| Expected cells | high | lower |

---

## 28. Difference Between Project 7.3 And Project 7.4

Project 7.3 is the RTL design and functional verification of the resource-shared decoder.

Project 7.4 performs Yosys comparison among:

```text
1. combinational N=8
2. scheduled N=8
3. resource-shared N=8
```

Therefore:

```text
Project 7.3 = build and verify the resource-shared architecture
Project 7.4 = quantify the architecture improvement using synthesis reports
```

---

## 29. Common Problems And Debugging

### Problem 1: Wrong Writeback Destination

A shared datapath computes one result at a time.

Each result must be written to the correct destination register.

Possible symptom:

```text
many vectors fail
right branch incorrect
u_hat partially correct
```

Fix:

```text
check state-to-destination mapping
inspect waveform for write_destination and fu_y
```

---

### Problem 2: Wrong Operand Selection

If `fu_a` or `fu_b` is selected incorrectly, the f/g result will be wrong.

Fix:

```text
create a schedule table
map each state to expected operands
compare waveform fu_a/fu_b with schedule
```

---

### Problem 3: Wrong f/g Mode

If `fu_is_g` is wrong:

```text
f operation may be computed when g is needed
or
g operation may be computed when f is needed
```

Fix:

```text
check fu_is_g for every state
```

---

### Problem 4: Wrong g Control Bit

For g operation, the control bit must be the correct decoded bit or partial sum.

Common errors:

```text
using u_i instead of partial_i
using stale partial sum
using wrong bit index
```

Fix:

```text
check fu_g_bit in waveform
verify partial sums before g states
```

---

### Problem 5: Checking Output Before done

Because this is a multi-cycle design, the testbench must wait for `done`.

Fix:

```text
do not compare u_hat immediately after start
compare only when done is asserted
```

---

### Problem 6: Registers Not Cleared Between Vectors

If internal registers retain stale values, later vectors may fail.

Fix:

```text
reset once before test sequence
ensure each new start overwrites all required registers
ensure done/busy return to correct state
```

---

### Problem 7: Latency Mismatch In Testbench

If the testbench assumes a fixed latency but RTL changes, errors may appear.

More robust approach:

```text
wait(done)
```

instead of hardcoding cycle count.

---

## 30. Validation Checklist

Project 7.3 is complete if:

```text
rtl/sc_decoder_n8_shared.v exists
tb/tb_sc_decoder_n8_shared_vectors.v exists
sim/run_sc_decoder_n8_shared_vectors.sh exists
golden vector file exists
simulation reads all golden vectors
simulation reports 0 errors
waveform is generated
FSM state sequence is inspectable
shared datapath signals are inspectable
u_hat matches expected output at done
```

Recommended commands:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

ls -lh rtl/sc_decoder_n8_shared.v
ls -lh tb/tb_sc_decoder_n8_shared_vectors.v
ls -lh sim/run_sc_decoder_n8_shared_vectors.sh
ls -lh tests/golden_vectors/sc_decoder_n8_vectors.csv

./sim/run_sc_decoder_n8_shared_vectors.sh
```

---

## 31. Recommended Schedule Table For Documentation

For maintainability, the RTL should be accompanied by a schedule table.

Suggested columns:

```text
State
Operation type
fu_is_g
Operand A
Operand B
g control bit
Write destination
Comment
```

Example:

| State | Operation | fu_is_g | Operand A | Operand B | g bit | Destination |
|---|---|---:|---|---|---|---|
| S_F_TOP0 | f | 0 | L0 | L4 | - | left0 |
| S_F_TOP1 | f | 0 | L1 | L5 | - | left1 |
| S_F_TOP2 | f | 0 | L2 | L6 | - | left2 |
| S_F_TOP3 | f | 0 | L3 | L7 | - | left3 |
| S_G_TOP0 | g | 1 | L0 | L4 | p0 | right0 |

A schedule table greatly reduces debugging difficulty.

---

## 32. Recommended Comments In RTL

The RTL should include comments explaining:

```text
which state computes which SC operation
which register receives fu_y
which partial sum is used for each g state
when each u_i is decoded
when done is asserted
```

This is important because resource-shared FSMs are harder to read than combinational RTL.

---

## 33. Lessons Learned

Project 7.3 teaches the following key lessons:

```text
1. Resource sharing must be explicitly designed in the datapath.
2. Scheduling alone does not guarantee area reduction.
3. A shared f/g unit can be reused across multiple SC decoding steps.
4. Operand selection and writeback control are the core challenges.
5. Multi-cycle verification must use start/done synchronization.
6. Resource sharing trades latency for lower duplicated logic.
7. This architecture is a stepping stone toward scalable N=16/N=32 decoders.
```

---

## 34. Role Of This Project In The Full Roadmap

Project 7.3 is one of the most important architecture projects in the roadmap.

It changes the design philosophy from:

```text
build the whole decoding tree directly
```

to:

```text
execute the decoding tree using a shared datapath and a schedule
```

This idea is essential for future scalable decoders.

The roadmap progression is:

```text
Project 7.1: scheduled N=8 RTL baseline
Project 7.2: scheduled design shown to be larger
Project 7.3: explicit resource-shared scheduled N=8 RTL
Project 7.4: compare three architectures
Project 7.5: implement resource-shared design with OpenLane
Project 7.6: timing push for resource-shared design
```

---

## 35. What This Project Is Not

Project 7.3 is not yet a full scalable generated decoder framework.

It should not be overstated as:

```text
a schedule-generated N-variable architecture
a complete N=16/N=32 scalable generator
a final publication-level architecture
```

Instead, it should be presented as:

```text
a manually scheduled resource-shared N=8 decoder
a proof of concept for datapath sharing
a stepping stone toward schedule-generated scalable architectures
```

This distinction is important.

---

## 36. Conclusion

Project 7.3 implements the resource-shared scheduled SC Decoder N=8.

The key architectural improvement is:

```text
one shared f/g datapath is reused across multiple SC decoding steps.
```

This addresses the lesson from Project 7.2:

```text
Scheduling alone does not guarantee resource reduction.
```

Project 7.3 prepares the design for quantitative comparison in Project 7.4.

The next step is:

```text
Project 7.4: Yosys comparison of three architectures
```

where the combinational, scheduled, and resource-shared N=8 decoders are compared using synthesis metrics.