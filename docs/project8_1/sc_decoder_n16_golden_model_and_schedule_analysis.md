# Project 8.1: SC Decoder N=16 Golden Model And Schedule Analysis

## 1. Project Objective

Project 8.1 starts the transition from SC Decoder N=8 to SC Decoder N=16.

The main objective is not to write RTL immediately.

The main objective is to build a correct foundation for N=16 by preparing:

```text
1. Python golden model for SC Decoder N=16
2. Golden-vector generation flow
3. Recursive SC schedule analysis
4. f/g operation count
5. partial-sum mapping
6. latency estimate for resource-shared architecture
7. storage and register requirement analysis
8. readiness checklist before RTL implementation
```

This project answers the question:

```text
Before writing SC Decoder N=16 RTL, do we fully understand the schedule, data dependency, partial sums, and verification flow?
```

The correct answer must be yes before moving to Project 8.2.

---

## 2. Why Project 8.1 Is Important

Project 7.7 concluded that the current best N=8 architecture is:

```text
resource-shared scheduled SC Decoder N=8
```

The final N=8 OpenLane timing-push result was:

```text
Design: sc_decoder_n8_shared_top
CLOCK_PERIOD = 15 ns
DIEAREA = 0.36 mm²
synth_cell_count = 1045
critical_path = 8.62 ns
DRC = 0
LVS clean
Antenna = 0
```

However, N=8 is still small.

To move toward a stronger research direction, the roadmap must scale to:

```text
N=16
N=32
possibly N=64
```

The danger is that manually writing N=16 RTL too early can create many errors:

```text
wrong f/g schedule
wrong partial-sum mapping
wrong bit ordering
wrong frozen-mask indexing
wrong register writeback
wrong resource-sharing sequence
wrong latency assumption
```

Therefore, Project 8.1 focuses on the N=16 golden model and schedule analysis first.

---

## 3. Position In The Roadmap

The roadmap transition is:

```text
Project 7.7:
    Consolidate SC Decoder N=8 architecture exploration.

Project 8.1:
    Build SC Decoder N=16 golden model and schedule analysis.

Project 8.2:
    Implement combinational or reference RTL SC Decoder N=16.

Project 8.3:
    Implement scheduled/resource-shared SC Decoder N=16.

Project 8.4:
    Yosys and OpenLane comparison for N=16.
```

Project 8.1 is the required planning and verification foundation before N=16 RTL.

---

## 4. What Project 8.1 Is Not

Project 8.1 is not:

```text
a final RTL implementation
a physical implementation
an OpenLane project
a timing-closure project
a final research result
```

Project 8.1 is:

```text
a golden-model project
a schedule-analysis project
a correctness-foundation project
a preparation step for scalable RTL design
```

This distinction is important.

---

## 5. Core Conventions Preserved From N=8

Project 8.1 must preserve all conventions used in the N=8 roadmap.

### 5.1 LLR Width

```text
W = 6
```

Signed LLR range:

```text
-32 to 31
```

Intermediate f/g outputs may require:

```text
W+1 or larger
```

For early N=16 modeling, Python can use integer arithmetic without overflow.

RTL width-growth policy must be decided carefully before hardware implementation.

---

### 5.2 Hard Decision

```text
LLR < 0  → decoded bit = 1
LLR >= 0 → decoded bit = 0
```

---

### 5.3 Frozen Mask

```text
frozen_mask[i] = 1 → frozen bit, force u_i = 0
frozen_mask[i] = 0 → information bit, use hard decision
```

---

### 5.4 Bit Ordering

The project uses LSB-first convention:

```text
u_hat[0] = u0
u_hat[1] = u1
...
u_hat[15] = u15
```

Integer packing:

```text
u_hat_int = u0*2^0 + u1*2^1 + ... + u15*2^15
```

This convention must be used consistently in:

```text
Python golden model
CSV vectors
Verilog testbench
future RTL
documentation
```

---

## 6. SC f And g Functions

The N=16 decoder uses the same f/g functions as N=8.

### 6.1 f Function

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Python form:

```text
mag = min(abs(a), abs(b))

if (a < 0) XOR (b < 0):
    y = -mag
else:
    y = mag
```

---

### 6.2 g Function

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

The subtraction order remains:

```text
b - a
```

not:

```text
a - b
```

---

## 7. Recursive SC Decoder N=16 Structure

An N=16 SC decoder can be understood recursively.

Given:

```text
LLR[0:15]
frozen_mask[0:15]
```

the top-level split is:

```text
left branch:  indices 0..7
right branch: indices 8..15
```

The decoder executes:

```text
1. Compute 8 left LLRs using f.
2. Decode left N=8 branch.
3. Generate 8 partial sums from decoded left bits.
4. Compute 8 right LLRs using g.
5. Decode right N=8 branch.
6. Concatenate u_left and u_right.
```

This mirrors the N=8 decoder, but with N=8 sub-decoders instead of N=4 sub-decoders.

---

## 8. Top-Level N=16 Schedule

Input LLRs:

```text
L0, L1, L2, L3, L4, L5, L6, L7,
L8, L9, L10, L11, L12, L13, L14, L15
```

### Step 1: Compute Top-Level Left LLRs

```text
left0 = f(L0, L8)
left1 = f(L1, L9)
left2 = f(L2, L10)
left3 = f(L3, L11)
left4 = f(L4, L12)
left5 = f(L5, L13)
left6 = f(L6, L14)
left7 = f(L7, L15)
```

### Step 2: Decode Left N=8 Branch

```text
u0, u1, u2, u3, u4, u5, u6, u7
=
SC_Decode_N8(left0..left7, frozen_mask[0:7])
```

### Step 3: Generate Top-Level N=8 Partial Sums

The partial sums are:

```text
partial = Polar_Encode_N8(u0..u7)
```

Expanded:

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

### Step 4: Compute Top-Level Right LLRs

```text
right0 = g(L0, L8,  p0)
right1 = g(L1, L9,  p1)
right2 = g(L2, L10, p2)
right3 = g(L3, L11, p3)
right4 = g(L4, L12, p4)
right5 = g(L5, L13, p5)
right6 = g(L6, L14, p6)
right7 = g(L7, L15, p7)
```

### Step 5: Decode Right N=8 Branch

```text
u8, u9, u10, u11, u12, u13, u14, u15
=
SC_Decode_N8(right0..right7, frozen_mask[8:15])
```

### Step 6: Output

```text
u_hat[0:15] =
[u0,u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15]
```

---

## 9. Recursive Golden Model Algorithm

The Python golden model should use a recursive implementation.

Pseudocode:

```text
SC_Decode(llrs, frozen_mask):

    N = length(llrs)

    if N == 1:
        if frozen_mask[0] == 1:
            return [0]
        else:
            return [1 if llrs[0] < 0 else 0]

    half = N / 2

    left_llrs[i] = f(llrs[i], llrs[i+half])

    u_left = SC_Decode(left_llrs, frozen_mask[0:half])

    partial = Polar_Encode(u_left)

    right_llrs[i] = g(llrs[i], llrs[i+half], partial[i])

    u_right = SC_Decode(right_llrs, frozen_mask[half:N])

    return u_left + u_right
```

This same function should support:

```text
N=2
N=4
N=8
N=16
N=32
```

as long as N is a power of two.

---

## 10. Polar Encode Function For Partial Sums

The partial sums should be generated using recursive Polar encoding.

Pseudocode:

```text
Polar_Encode(u):

    N = length(u)

    if N == 1:
        return u

    half = N / 2

    upper = []
    lower = []

    for i in 0..half-1:
        upper[i] = u[i] XOR u[i+half]
        lower[i] = u[i+half]

    return Polar_Encode(upper) + Polar_Encode(lower)
```

This must match the N=8 convention already used in previous projects.

---

## 11. Operation Count For SC Decoder N=16

For SC decoding with N = 16:

```text
log2(N) = 4
```

At each level, the total number of f operations is:

```text
N/2 = 8
```

There are:

```text
log2(N) = 4 levels
```

Therefore:

```text
total f operations = (N/2) * log2(N)
                   = 8 * 4
                   = 32
```

Similarly:

```text
total g operations = 32
```

The number of hard decisions is:

```text
N = 16
```

Therefore, the basic operation count is:

```text
f operations      = 32
g operations      = 32
hard decisions    = 16
```

Total core SC operations:

```text
32 + 32 + 16 = 80
```

This is a lower-bound schedule count if one shared f/g datapath computes one f or g operation per cycle and hard decisions are handled separately or in nearby states.

---

## 12. Partial-Sum Operation Count

Partial sums are needed before g operations at every internal node.

For N=16, partial-sum generation occurs at multiple node sizes.

Top-level partial sums:

```text
Polar_Encode_N8
```

requires approximately:

```text
(8/2) * log2(8) = 4 * 3 = 12 XOR operations
```

Two N=8 subtrees require N=4 partial sums:

```text
2 × [(4/2) * log2(4)] = 2 × 4 = 8 XOR operations
```

Four N=4 subtrees require N=2 partial sums:

```text
4 × [(2/2) * log2(2)] = 4 × 1 = 4 XOR operations
```

N=2 subtrees require N=1 partials, which are direct wires:

```text
0 XOR operations
```

Estimated total partial-sum XOR operations:

```text
12 + 8 + 4 = 24 XOR operations
```

This count is useful for schedule and hardware planning.

---

## 13. Operation Count Summary

| Operation Type | Count For N=16 |
|---|---:|
| f operations | 32 |
| g operations | 32 |
| hard decisions | 16 |
| partial-sum XOR operations | about 24 |
| core f/g operations total | 64 |
| f/g + hard decisions | 80 |

This is the first important quantitative result of Project 8.1.

---

## 14. Lower-Bound Latency Estimate

For a fully resource-shared datapath that computes one f or g operation per cycle:

```text
f/g cycles = 32 + 32 = 64 cycles
```

If hard decisions are one cycle each:

```text
hard-decision cycles = 16 cycles
```

Then:

```text
basic latency lower bound = 64 + 16 = 80 cycles
```

If partial-sum computation is done in additional cycles, add approximately:

```text
partial-sum cycles = 24 cycles
```

Then a conservative estimate is:

```text
80 to 104 cycles
```

Therefore, an early expected latency range for N=16 resource-shared decoder is:

```text
about 80–104 cycles
```

depending on whether hard decision and partial-sum logic are combined with other states.

---

## 15. Why Latency Estimate Matters

N=8 showed that resource sharing improves area and timing, but increases multi-cycle latency.

For N=16, latency becomes even more important.

A fair comparison must include:

```text
clock period
latency cycles
decode time
throughput
area
area-latency product
```

Before RTL, Project 8.1 should estimate the latency.

After RTL, the testbench should measure it.

---

## 16. Effective Decode Time Formula

If the final N=16 shared decoder has:

```text
latency_cycles = L
clock_period_ns = T
```

then:

```text
decode_time_ns = L × T
```

Throughput:

```text
throughput_vectors_per_second = 1 / (decode_time_ns × 1e-9)
```

Example:

```text
If L = 100 cycles
and T = 15 ns

decode_time = 1500 ns
throughput ≈ 666,666 vectors/s
```

This is only an example. Actual values must be measured after RTL.

---

## 17. Storage Requirement Analysis

A resource-shared N=16 decoder needs internal storage for:

```text
input LLRs
intermediate left/right LLRs
decoded bits
partial sums
temporary f/g results
frozen mask
FSM state
busy/done control
```

At minimum, storage includes:

```text
16 input LLR registers
16 frozen-mask bits
16 decoded-bit registers
intermediate LLR storage at multiple tree levels
partial-sum registers
state register
```

A careful storage map should be created before RTL.

---

## 18. Suggested Internal Storage For N=16

A practical manually written design may use named registers such as:

```text
L0..L15

level1_left0..level1_left7
level1_right0..level1_right7

level2 temporary LLRs for N=8 branches

level3 temporary LLRs for N=4 branches

u0..u15

partial_top0..partial_top7
partial_sub0..partial_sub3
partial_pair0..partial_pair1

state
busy
done
```

However, this manual naming becomes difficult.

For scalability, a better approach is to use arrays in SystemVerilog or a generated Verilog style.

If using pure Verilog-2001 for compatibility, flattened register naming may be required.

---

## 19. Schedule Table Requirement

Before writing N=16 RTL, create a schedule table.

Each row should include:

```text
step_id
node_id
node_size
operation type
operand A source
operand B source
g control bit source
destination
dependency
comment
```

Example:

| Step | Node | Size | Operation | Operand A | Operand B | g bit | Destination |
|---:|---|---:|---|---|---|---|---|
| 0 | root | 16 | f | L0 | L8 | - | left0 |
| 1 | root | 16 | f | L1 | L9 | - | left1 |
| 2 | root | 16 | f | L2 | L10 | - | left2 |
| 8 | left | 8 | f | left0 | left4 | - | left_left0 |
| ... | ... | ... | ... | ... | ... | ... | ... |

This schedule table should be generated by Python if possible.

---

## 20. Why Schedule Generation Is Better Than Manual RTL

Manual RTL worked for N=8.

For N=16, manual RTL becomes harder.

For N=32 or N=64, manual RTL becomes unsafe.

A schedule generator can produce:

```text
operation list
dependency list
latency estimate
testbench reference
possibly RTL control table
documentation table
```

This is the foundation of a stronger research direction.

The long-term direction should be:

```text
schedule-generated resource-shared SC Polar decoder
```

not simply:

```text
manually written N=16 decoder
```

---

## 21. Proposed Python Files

Project 8.1 should create or prepare:

```text
model/sc_decoder_n16_golden.py
model/sc_schedule_generator.py
```

The golden model file should generate:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
tests/golden_vectors/sc_decoder_n16_summary.txt
```

The schedule generator should generate:

```text
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

---

## 22. Expected CSV Format For Golden Vectors

The N=16 golden vector CSV should include:

```text
llr0..llr15
frozen0..frozen15
u_hat0..u_hat15
frozen_mask_int
u_hat_int
```

Header example:

```text
llr0,llr1,llr2,llr3,llr4,llr5,llr6,llr7,llr8,llr9,llr10,llr11,llr12,llr13,llr14,llr15,
frozen0,frozen1,...,frozen15,
u_hat0,u_hat1,...,u_hat15,
frozen_mask_int,u_hat_int
```

The exact CSV should be single-line header without spaces for easy Verilog parsing.

---

## 23. Recommended Number Of Golden Vectors

For early verification:

```text
1000 random vectors
```

is acceptable.

For stronger regression:

```text
5000 to 10000 vectors
```

can be generated later.

The initial Project 8.1 target should be:

```text
1000 N=16 golden vectors
```

This keeps simulation manageable.

---

## 24. Basic Test Cases For N=16 Golden Model

Before generating random vectors, the Python model should run basic tests.

Recommended basic tests:

```text
1. all LLRs zero, all frozen
2. all LLRs positive, all information
3. all LLRs negative, all information
4. alternating positive/negative LLRs
5. first half frozen, second half information
6. common polar-style mask with low-reliability bits frozen
```

These tests help detect convention errors.

---

## 25. Validation Checklist For Python Golden Model

Project 8.1 golden model is complete if:

```text
model/sc_decoder_n16_golden.py exists
recursive SC decoder supports N=16
polar_encode function works for N=1,2,4,8,16
f and g functions match N=8 convention
hard decision matches N=8 convention
frozen-mask convention is preserved
basic tests pass
CSV vectors are generated
CSV has expected header
CSV has expected number of lines
summary file is generated
```

Recommended checks:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

python3 model/sc_decoder_n16_golden.py

ls -lh tests/golden_vectors/sc_decoder_n16_vectors.csv
ls -lh tests/golden_vectors/sc_decoder_n16_summary.txt

head -3 tests/golden_vectors/sc_decoder_n16_vectors.csv
wc -l tests/golden_vectors/sc_decoder_n16_vectors.csv
```

If generating 1000 vectors:

```text
wc -l should report 1001
```

---

## 26. Validation Checklist For Schedule Analysis

Schedule analysis is complete if:

```text
operation count is generated
f operation count = 32
g operation count = 32
hard decision count = 16
partial-sum XOR estimate is documented
schedule table is generated
dependency order is valid
estimated latency range is documented
storage requirement is documented
resource-shared mapping plan is documented
```

Recommended output files:

```text
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

---

## 27. Expected File Structure

Expected Project 8.1 structure:

```text
model/
  sc_decoder_n16_golden.py
  sc_schedule_generator.py

tests/
  golden_vectors/
    sc_decoder_n16_vectors.csv
    sc_decoder_n16_summary.txt

results/
  schedules/
    sc_decoder_n16_schedule.csv
    sc_decoder_n16_schedule.md
    sc_decoder_n16_operation_count.json

docs/
  project8_1/
    sc_decoder_n16_golden_model_and_schedule_analysis.md
```

---

## 28. Proposed Development Steps

Project 8.1 should be executed in this order:

```text
Step 1:
    Write or extend recursive Python SC decoder to support N=16.

Step 2:
    Verify polar_encode for N=2,4,8,16.

Step 3:
    Run basic deterministic N=16 tests.

Step 4:
    Generate 1000 random N=16 golden vectors.

Step 5:
    Create schedule generator or manual schedule table.

Step 6:
    Count f/g/hard-decision/partial-sum operations.

Step 7:
    Estimate resource-shared latency.

Step 8:
    Document storage requirements.

Step 9:
    Commit golden model, vectors, schedule summary, and documentation.

Step 10:
    Only then move to N=16 RTL.
```

---

## 29. Risk Analysis Before RTL

Main risks:

```text
1. Manual schedule errors
2. Partial-sum mapping errors
3. Bit-ordering mismatch
4. Frozen-mask indexing errors
5. Verilog width-growth errors
6. Large FSM complexity
7. Register writeback mistakes
8. Latency/testbench mismatch
```

Mitigation:

```text
1. Use recursive Python golden model.
2. Generate CSV vectors automatically.
3. Generate schedule table before RTL.
4. Keep all conventions identical to N=8.
5. Start with reference combinational/scheduled model before optimizing.
6. Add latency-cycle counter in testbench.
```

---

## 30. Recommended Architecture Direction For N=16

Based on Project 7.7, the best direction is not to build only a combinational N=16 decoder.

The recommended direction is:

```text
resource-shared scheduled SC Decoder N=16
```

However, for verification, it may still be useful to have a reference combinational or recursive RTL version.

Recommended architecture sequence:

```text
1. Python golden model N=16
2. schedule table N=16
3. optional combinational/reference RTL N=16
4. resource-shared scheduled RTL N=16
5. Yosys comparison
6. OpenLane physical validation
```

---

## 31. Expected Research Contribution After N=16

After completing N=16, the work becomes stronger.

Potential contribution:

```text
A resource-shared scheduled SC Polar decoder architecture with open-source RTL-to-GDSII validation.
```

To make the contribution credible, include:

```text
N=8 and N=16 results
operation-count analysis
latency analysis
Yosys synthesis comparison
OpenLane physical comparison
area/timing trade-off
discussion of scalability
```

---

## 32. Minimum Results Needed Before A Paper Draft

Before writing a strong conference paper, aim to have:

```text
1. N=8 combinational vs resource-shared comparison
2. N=16 golden model
3. N=16 resource-shared RTL verification
4. N=16 Yosys synthesis result
5. at least one N=16 OpenLane run
6. latency-cycle measurement
7. clear area/timing/latency trade-off table
```

Before a Q1 journal, likely need:

```text
N=32 or broader scalability
more rigorous comparison
possibly FPGA or ASIC multi-corner results
power/energy estimate
better automation and schedule generation
```

---

## 33. Project 8.1 Deliverables

Project 8.1 should deliver:

```text
1. documentation file:
   docs/project8_1/sc_decoder_n16_golden_model_and_schedule_analysis.md

2. Python golden model:
   model/sc_decoder_n16_golden.py

3. golden vectors:
   tests/golden_vectors/sc_decoder_n16_vectors.csv

4. summary:
   tests/golden_vectors/sc_decoder_n16_summary.txt

5. schedule analysis:
   results/schedules/sc_decoder_n16_schedule.csv
   results/schedules/sc_decoder_n16_schedule.md
   results/schedules/sc_decoder_n16_operation_count.json
```

This documentation file is the first deliverable.

Code and generated files should be created next.

---

## 34. What To Commit At This Stage

At the documentation stage, commit:

```text
docs/project8_1/sc_decoder_n16_golden_model_and_schedule_analysis.md
```

After implementing the Python model, commit:

```text
model/sc_decoder_n16_golden.py
tests/golden_vectors/sc_decoder_n16_vectors.csv
tests/golden_vectors/sc_decoder_n16_summary.txt
```

After schedule generation, commit:

```text
model/sc_schedule_generator.py
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

---

## 35. Recommended Git Commands

For this documentation file:

```bash
git add docs/project8_1/sc_decoder_n16_golden_model_and_schedule_analysis.md
git commit -m "docs: add project8.1 SC decoder N16 golden model and schedule analysis"
git push origin main
```

After Python model and generated vectors are added, use a separate commit.

Recommended future commit:

```bash
git add model/sc_decoder_n16_golden.py tests/golden_vectors/sc_decoder_n16_vectors.csv tests/golden_vectors/sc_decoder_n16_summary.txt
git commit -m "model: add SC decoder N16 golden model and vectors"
git push origin main
```

---

## 36. Project 8.1 Conclusion

Project 8.1 begins the N=16 expansion in a controlled and academically correct way.

The main conclusion is:

```text
Do not write N=16 RTL before the golden model and schedule analysis are stable.
```

The expected N=16 operation count is:

```text
f operations   = 32
g operations   = 32
hard decisions = 16
```

The estimated resource-shared latency lower bound is:

```text
about 80 cycles
```

A conservative estimate including partial-sum scheduling is:

```text
about 80–104 cycles
```

The key next step after this documentation is:

```text
implement model/sc_decoder_n16_golden.py
generate N=16 golden vectors
generate N=16 schedule table
```

Only after that should Project 8.2 begin RTL implementation.