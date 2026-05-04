# Project 8.3: Resource-Shared Scheduled SC Decoder N=16

## 1. Project Objective

Project 8.3 implements a resource-shared scheduled SC Decoder N=16.

This project extends the N=8 resource-shared architecture from Project 7.3–7.6 to N=16.

The main objective is to design an N=16 SC decoder that reuses a shared f/g datapath over multiple clock cycles instead of computing the full SC decoding tree combinationally.

The target architecture is:

```text
SC Decoder N=16
→ scheduled operation sequence
→ shared f/g datapath
→ FSM / controller
→ internal LLR storage
→ partial-sum storage
→ decoded-bit storage
→ start/busy/done interface
```

The main question of Project 8.3 is:

```text
Can the SC Decoder N=16 be implemented as a resource-shared scheduled RTL architecture using the golden model and schedule analysis from Project 8.1?
```

The expected functional verification target is:

```text
1000 N=16 golden vectors
0 errors
ALL TESTS PASSED
```

---

## 2. Why Project 8.3 Is Important

Project 8.1 established the N=16 golden model and schedule analysis.

Project 8.2 implemented a reference RTL baseline for SC Decoder N=16.

Project 8.2.1 synthesizes the reference RTL to obtain a baseline complexity result.

However, the reference RTL is combinational and correctness-oriented.

It is not optimized for:

```text
area
critical path
resource reuse
timing closure
scalability
```

Project 8.3 introduces the architecture that made the N=8 design successful:

```text
explicit resource sharing
```

The goal is not merely to write another N=16 decoder.

The goal is to build an architecture that can later scale toward:

```text
N=32
N=64
schedule-generated Polar decoder architecture
```

---

## 3. Position In The Roadmap

The roadmap around Project 8 is:

```text
Project 8.1:
    SC Decoder N=16 golden model and schedule analysis.

Project 8.2:
    SC Decoder N=16 reference RTL baseline.

Project 8.2.1:
    Yosys synthesis study for SC Decoder N=16 reference RTL.

Project 8.3:
    Resource-shared scheduled SC Decoder N=16.

Project 8.4:
    N=16 architecture comparison using Yosys and OpenLane.
```

Project 8.3 is the optimized architecture step.

---

## 4. What Project 8.3 Is Not

Project 8.3 is not:

```text
a combinational reference decoder
a purely academic schedule document
an OpenLane physical implementation
a final timing-pushed implementation
a final journal-level architecture by itself
```

Project 8.3 is:

```text
a functional resource-shared scheduled RTL architecture for SC Decoder N=16
```

Physical implementation and timing closure should be handled later.

---

## 5. Input Dependencies From Earlier Projects

Project 8.3 depends on the following previous outputs.

### From Project 8.1

```text
model/sc_decoder_n16_golden.py
tests/golden_vectors/sc_decoder_n16_vectors.csv
tests/golden_vectors/sc_decoder_n16_summary.txt
model/sc_schedule_generator.py
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

### From Project 8.2

```text
rtl/sc_decoder_n16_ref.v
tb/tb_sc_decoder_n16_ref_vectors.v
sim/run_sc_decoder_n16_ref_vectors.sh
```

### From Project 8.2.1

```text
synth/reports/sc_decoder_n16_ref_flat_yosys.log
results/summary/sc_decoder_n16_ref_yosys_summary.csv
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

Project 8.3 should use the same golden-vector file:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

so that the reference RTL and resource-shared RTL are verified against the same input/output dataset.

---

## 6. Core Design Philosophy

The Project 8.3 architecture should follow the lesson from Project 7.2–7.4:

```text
Scheduling alone is not enough.
Explicit resource sharing is required.
```

For N=16, a naive scheduled decoder may still be large if it duplicates f/g logic.

Therefore, Project 8.3 should use:

```text
one shared f/g datapath
one operation controller
internal storage
state-based operand selection
state-based writeback
start/busy/done handshake
```

This creates an area-latency trade-off:

```text
less duplicated combinational logic
shorter per-cycle critical path
more clock cycles per decoded vector
more controller complexity
```

---

## 7. Preserved Conventions

Project 8.3 must preserve all conventions from Projects 8.1 and 8.2.

### 7.1 LLR Convention

```text
W_IN = 6
W_INT = 10
```

Input LLRs are 6-bit signed values.

Internal LLR values should use 10-bit signed values to avoid mismatch with the Python golden model.

### 7.2 Frozen-Mask Convention

```text
frozen_mask[i] = 1 → u_i is frozen and forced to 0
frozen_mask[i] = 0 → u_i is information and decoded by hard decision
```

### 7.3 Hard-Decision Convention

```text
LLR < 0  → decoded bit = 1
LLR >= 0 → decoded bit = 0
```

### 7.4 Bit-Ordering Convention

```text
u_hat[0]  = u0
u_hat[1]  = u1
...
u_hat[15] = u15
```

### 7.5 g Function Convention

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

The subtraction order must be:

```text
b - a
```

not:

```text
a - b
```

---

## 8. Target RTL Files

Project 8.3 should create:

```text
rtl/sc_decoder_n16_shared.v
tb/tb_sc_decoder_n16_shared_vectors.v
sim/run_sc_decoder_n16_shared_vectors.sh
docs/project8_3/sc_decoder_n16_resource_shared_scheduled.md
```

Later, synthesis files may include:

```text
synth/sc_decoder_n16_shared.ys
synth/run_sc_decoder_n16_shared_yosys.sh
results/summary/sc_decoder_n16_shared_yosys_summary.md
```

But the first milestone is functional RTL verification.

---

## 9. Proposed Top-Level Interface

The proposed top-level interface is sequential.

```verilog
module sc_decoder_n16_shared #(
    parameter W_IN  = 6,
    parameter W_INT = 10
)(
    input  wire clk,
    input  wire rst_n,
    input  wire start,

    input  wire signed [W_IN-1:0] llr0,
    input  wire signed [W_IN-1:0] llr1,
    input  wire signed [W_IN-1:0] llr2,
    input  wire signed [W_IN-1:0] llr3,
    input  wire signed [W_IN-1:0] llr4,
    input  wire signed [W_IN-1:0] llr5,
    input  wire signed [W_IN-1:0] llr6,
    input  wire signed [W_IN-1:0] llr7,
    input  wire signed [W_IN-1:0] llr8,
    input  wire signed [W_IN-1:0] llr9,
    input  wire signed [W_IN-1:0] llr10,
    input  wire signed [W_IN-1:0] llr11,
    input  wire signed [W_IN-1:0] llr12,
    input  wire signed [W_IN-1:0] llr13,
    input  wire signed [W_IN-1:0] llr14,
    input  wire signed [W_IN-1:0] llr15,

    input  wire [15:0] frozen_mask,

    output reg  [15:0] u_hat,
    output reg         busy,
    output reg         done
);
```

This interface follows the sequential resource-shared style from Project 7.

---

## 10. Handshake Protocol

The intended protocol is:

```text
1. When busy = 0, apply input LLRs and frozen_mask.
2. Pulse start = 1 for one clock cycle.
3. Decoder captures inputs and asserts busy = 1.
4. FSM executes the SC schedule.
5. Decoder writes final u_hat.
6. Decoder asserts done = 1 for at least one cycle.
7. Testbench checks u_hat when done = 1.
8. Decoder returns to idle or waits for next start.
```

The testbench must not check `u_hat` before `done`.

---

## 11. Architecture Overview

The architecture contains two main blocks:

```text
1. Controller
2. Datapath
```

### Controller

The controller is responsible for:

```text
FSM state
start/busy/done protocol
operation type selection
operand selection
destination selection
write-enable generation
decoded-bit update
partial-sum update
```

### Datapath

The datapath contains:

```text
input LLR registers
intermediate LLR registers
shared f/g unit
decoded-bit registers
partial-sum registers
temporary result register
u_hat output register
```

High-level structure:

```text
                  +----------------------+
start, clk, rst ->| FSM Controller       |
                  +----------+-----------+
                             |
                             | control
                             v
+--------------------------------------------------+
| Register Storage                                 |
| LLRs, intermediate LLRs, decoded bits, partials  |
+----------------------+---------------------------+
                       |
                       | operand selection
                       v
              +-------------------+
              | Shared f/g unit   |
              +---------+---------+
                        |
                        | result writeback
                        v
+--------------------------------------------------+
| Destination Registers / u_hat                    |
+--------------------------------------------------+
```

---

## 12. Shared f/g Datapath

The shared datapath computes either f or g.

Inputs:

```text
fu_a
fu_b
fu_is_g
fu_g_bit
```

Output:

```text
fu_y
```

Behavior:

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

This datapath should be reused across all f and g operations in the N=16 schedule.

---

## 13. N=16 Operation Count

From Project 8.1:

```text
N = 16
levels = 4
f_ops = 32
g_ops = 32
hard_decisions = 16
partial_xors_est = 24
fg_ops_total = 64
fg_plus_hard_decisions = 80
latency_lower_bound_cycles = 80
latency_conservative_est_cycles = 104
```

The operation count means:

```text
32 f operations
32 g operations
16 hard decisions
```

If the shared datapath computes one f/g operation per cycle, at least:

```text
64 cycles
```

are needed for f/g operations alone.

With hard decisions:

```text
80 cycles
```

is the lower-bound estimate.

Partial-sum handling may increase this.

---

## 14. Schedule Generator Reference

The resource-shared decoder should be based on:

```text
results/schedules/sc_decoder_n16_schedule.csv
```

and:

```text
results/schedules/sc_decoder_n16_schedule.md
```

The expected schedule-generator result is:

```text
schedule rows = 112
partial_output_rows = 32
partial_xors_est_staged = 24
latency_lower_bound_cycles = 80
latency_if_partial_outputs_one_cycle_each = 112
latency_conservative_est_cycles = 104
```

Important interpretation:

```text
The schedule rows are architecture-control rows.
They are not necessarily final RTL cycles one-to-one.
```

In actual RTL, partial sums may be computed:

```text
combinationally
grouped into fewer states
or explicitly written in separate states
```

---

## 15. Recommended Project 8.3 Implementation Strategy

Project 8.3 should not attempt a fully automatic schedule interpreter immediately.

The recommended first implementation is:

```text
manual but schedule-guided resource-shared FSM
```

This means:

```text
use the generated schedule as a design reference
write a deterministic FSM manually
reuse one f/g unit
write intermediate values to registers
verify against golden vectors
```

After that works, future projects can move toward:

```text
table-driven schedule controller
automatic RTL generation
larger N support
```

This reduces implementation risk.

---

## 16. Storage Strategy

The design needs storage for:

```text
input LLRs
intermediate LLRs at N=16, N=8, N=4, and N=2 levels
decoded bits
partial sums
temporary f/g output
frozen mask
FSM state
```

A safe first implementation can use explicit named registers.

Example storage groups:

```text
L0..L15

root_left0..root_left7
root_right0..root_right7

left subtree temporary LLRs
right subtree temporary LLRs

u0..u15

p_root0..p_root7
p_sub0..p_sub3
p_pair0..p_pair1

state
busy
done
```

Although this is verbose, it is easier to debug than a premature compressed storage design.

---

## 17. Width Strategy

Use:

```text
W_IN = 6
W_INT = 10
```

All input LLRs should be sign-extended from 6-bit to 10-bit when captured.

All internal LLR registers should use:

```text
signed [W_INT-1:0]
```

This avoids mismatch with the Python golden model.

Later optimization may study smaller widths, truncation, saturation, or quantization.

Project 8.3 should not introduce quantization changes.

---

## 18. Partial-Sum Strategy

Partial sums must follow the recursive Polar encoding convention.

For top-level N=16 right branch:

```text
p0 = u0 ^ u1 ^ u2 ^ u3 ^ u4 ^ u5 ^ u6 ^ u7
p1 = u1 ^ u3 ^ u5 ^ u7
p2 = u2 ^ u3 ^ u6 ^ u7
p3 = u3 ^ u7
p4 = u4 ^ u5 ^ u6 ^ u7
p5 = u5 ^ u7
p6 = u6 ^ u7
p7 = u7
```

For N=8 sub-branches, use the N=4 partial-sum convention:

```text
p0 = u0 ^ u1 ^ u2 ^ u3
p1 = u1 ^ u3
p2 = u2 ^ u3
p3 = u3
```

For N=4 sub-branches, use the N=2 convention:

```text
p0 = u0 ^ u1
p1 = u1
```

Partial-sum errors are one of the most likely sources of RTL mismatch.

---

## 19. Hard-Decision Strategy

For each decoded bit:

```text
if frozen_mask[i] = 1:
    u_i = 0
else:
    u_i = hard_decision(current_llr)
```

where:

```text
hard_decision(llr) = 1 if llr < 0 else 0
```

The hard-decision states may be implemented without using the f/g datapath.

They can be independent FSM states that write decoded bits directly.

---

## 20. State-Machine Strategy

The FSM should include:

```text
S_IDLE
S_LOAD
many operation states
S_DONE
```

For clarity, the FSM states should follow the recursive SC schedule.

A simple first version can use one state per operation group.

Possible state categories:

```text
ROOT_F states
LEFT_N8 states
LEFT_N4 states
LEFT_N2 states
PARTIAL states
ROOT_G states
RIGHT_N8 states
RIGHT_N4 states
RIGHT_N2 states
DECISION states
DONE state
```

The exact state names can be long but should remain readable.

---

## 21. Debug-Friendly FSM Naming

Use names that show the tree position and operation.

Examples:

```text
S_ROOT_F0
S_ROOT_F1
...
S_ROOT_F7

S_LL_F0
S_LL_F1
S_LL_DEC0
...

S_ROOT_PARTIAL
S_ROOT_G0
...
S_ROOT_G7

S_DONE
```

Where:

```text
L = left branch
R = right branch
```

For example:

```text
S_LR_F0
```

can mean:

```text
left subtree, right child, f operation 0
```

Clear state naming helps waveform debugging.

---

## 22. Latency Measurement

The testbench should measure latency from:

```text
start assertion
```

to:

```text
done assertion
```

It should report:

```text
latency_cycles
minimum latency
maximum latency
average latency
```

For a deterministic FSM, all vectors should have the same latency.

Expected planning range:

```text
80–112 cycles
```

depending on how partial sums are implemented.

The final measured value must be documented.

---

## 23. Testbench Requirements

The testbench should:

```text
1. Open tests/golden_vectors/sc_decoder_n16_vectors.csv.
2. Skip the header.
3. Read one vector.
4. Apply 16 LLRs and frozen_mask.
5. Pulse start for one clock.
6. Wait for done.
7. Compare u_hat with expected u_hat.
8. Measure latency cycles.
9. Repeat for 1000 vectors.
10. Print total tests and total errors.
```

Expected final output:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED.
```

Additional useful output:

```text
Latency cycles = ...
```

---

## 24. Proposed Testbench File

The testbench file should be:

```text
tb/tb_sc_decoder_n16_shared_vectors.v
```

The waveform should be:

```text
sim/waveforms/sc_decoder_n16_shared_vectors.vcd
```

The run script should be:

```text
sim/run_sc_decoder_n16_shared_vectors.sh
```

---

## 25. Waveform Signals To Inspect

Important signals:

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
write_enable
write_destination
L0..L15 registers
intermediate LLR registers
partial-sum registers
u0..u15
u_hat
expected_u_hat
latency_counter
error_count
```

The most important debug signals are:

```text
state
fu_a
fu_b
fu_is_g
fu_g_bit
fu_y
destination
u_hat
expected_u_hat
```

---

## 26. First Implementation Milestone

The first Project 8.3 milestone should be:

```text
compile without errors
run simulation
read all 1000 vectors
report deterministic latency
0 errors
```

This milestone is more important than synthesis.

Only after functional verification should Yosys be run.

---

## 27. Common Bugs

### Bug 1: Checking Output Before done

The resource-shared decoder is multi-cycle.

The testbench must check output only after:

```text
done = 1
```

### Bug 2: Wrong g Bit

A g operation must use the correct partial sum.

Using a raw decoded bit instead of a partial sum will fail many vectors.

### Bug 3: Wrong Writeback Destination

The shared f/g datapath produces one output at a time.

Each state must write the result into the correct register.

### Bug 4: Wrong Bit Ordering

The output must be:

```text
u_hat[0] = u0
...
u_hat[15] = u15
```

### Bug 5: Insufficient Internal Width

Use:

```text
W_INT = 10
```

for the first reference shared design.

### Bug 6: Stale Registers

Each new start must overwrite all necessary internal registers.

Do not let old intermediate values affect a new vector.

---

## 28. Verification Checklist

Project 8.3 functional verification is complete if:

```text
rtl/sc_decoder_n16_shared.v exists
tb/tb_sc_decoder_n16_shared_vectors.v exists
sim/run_sc_decoder_n16_shared_vectors.sh exists
simulation reads 1000 vectors
simulation reports 0 errors
latency is measured
waveform is generated
```

Recommended command:

```bash
./sim/run_sc_decoder_n16_shared_vectors.sh
```

Expected result:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED.
```

---

## 29. Yosys Study After Functional Verification

After the resource-shared N=16 RTL passes functional verification, run Yosys.

Expected files:

```text
synth/sc_decoder_n16_shared.ys
synth/run_sc_decoder_n16_shared_yosys.sh
results/summary/sc_decoder_n16_shared_yosys_summary.csv
results/summary/sc_decoder_n16_shared_yosys_summary.md
```

Important metrics:

```text
total cells
DFF/DFFE cells
estimated combinational cells
MUX cells
XOR/XNOR cells
NAND cells
```

This result should be compared against:

```text
results/summary/sc_decoder_n16_ref_yosys_summary.md
```

from Project 8.2.1.

---

## 30. Expected Architecture Trade-Off

The expected trade-off is:

```text
resource-shared N=16:
    fewer combinational cells than reference N=16
    shorter critical path potential
    more sequential cells
    more latency cycles
```

The correct comparison should include:

```text
total cells
estimated combinational cells
sequential cells
latency cycles
effective decode time
area-latency product
```

Do not claim improvement based on cell count alone.

---

## 31. Relationship To OpenLane

Project 8.3 does not need OpenLane immediately.

OpenLane should come after:

```text
functional verification
Yosys comparison
architecture stabilization
```

A later project should implement:

```text
sc_decoder_n16_shared_top
```

in OpenLane and check:

```text
DRC
LVS
antenna
timing
die area
critical path
```

---

## 32. Research Interpretation

Project 8.3 is a key research step because it tests whether the resource-sharing lesson from N=8 scales to N=16.

The main hypothesis is:

```text
A resource-shared scheduled N=16 SC decoder should reduce duplicated combinational logic compared with the N=16 reference RTL, at the cost of additional cycles and sequential control.
```

If confirmed, this strengthens the research direction:

```text
schedule-generated resource-shared SC Polar decoder architecture
```

---

## 33. Minimum Success Criteria

The minimum success criteria for Project 8.3 are:

```text
1. RTL compiles.
2. Testbench reads 1000 N=16 golden vectors.
3. All vectors pass.
4. Latency cycles are measured.
5. Yosys synthesis runs.
6. Summary metrics are generated.
7. Comparison with N=16 reference RTL is possible.
```

The first milestone is functional correctness.

The second milestone is synthesis comparison.

---

## 34. What To Commit

After the first successful functional verification, commit:

```text
rtl/sc_decoder_n16_shared.v
tb/tb_sc_decoder_n16_shared_vectors.v
sim/run_sc_decoder_n16_shared_vectors.sh
docs/project8_3/sc_decoder_n16_resource_shared_scheduled.md
```

Recommended commit:

```bash
git add rtl/sc_decoder_n16_shared.v \
        tb/tb_sc_decoder_n16_shared_vectors.v \
        sim/run_sc_decoder_n16_shared_vectors.sh \
        docs/project8_3/sc_decoder_n16_resource_shared_scheduled.md

git commit -m "project8.3: add resource-shared scheduled SC decoder N16 RTL"
git push origin main
```

After Yosys synthesis, use a separate commit.

---

## 35. Project 8.3 Conclusion

Project 8.3 implements the resource-shared scheduled SC Decoder N=16.

It extends the successful N=8 resource-shared architecture to a larger decoder.

The project should be developed carefully from:

```text
Project 8.1 golden model and schedule
Project 8.2 reference RTL verification
Project 8.2.1 Yosys baseline
```

The expected output is a functionally correct multi-cycle decoder that passes:

```text
1000 N=16 golden vectors
0 errors
```

The main architectural goal is:

```text
reduce duplicated combinational logic through explicit datapath sharing
```

The next project after Project 8.3 should be:

```text
Project 8.4: N=16 Architecture Comparison Using Yosys And OpenLane
```