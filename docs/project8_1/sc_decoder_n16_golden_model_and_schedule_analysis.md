# Project 8.1: SC Decoder N=16 Golden Model And Schedule Analysis

## 1. Project Objective

Project 8.1 starts the transition from SC Decoder N=8 to SC Decoder N=16.

The main objective is not to write RTL immediately.

The main objective is to build a correct pre-RTL foundation for N=16 through:

```text
1. Python golden model for SC Decoder N=16
2. Golden-vector generation flow
3. Recursive SC schedule analysis
4. f/g operation-count analysis
5. partial-sum mapping
6. latency-cycle estimation
7. storage and register requirement analysis
8. resource-shared architecture planning
9. readiness checklist before RTL implementation
```

The central question of Project 8.1 is:

```text
Before writing SC Decoder N=16 RTL, do we fully understand the schedule, data dependency, partial sums, verification flow, and resource-sharing requirements?
```

The correct answer must be yes before moving to Project 8.2.

---

## 2. Why Project 8.1 Is Important

Project 7.7 concluded that the current best N=8 architecture is:

```text
Resource-shared scheduled SC Decoder N=8
```

The strongest N=8 OpenLane result was:

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

To make the work stronger academically and technically, the roadmap must scale to:

```text
N=16
N=32
possibly N=64
```

The danger is that manually writing N=16 RTL too early can introduce many errors:

```text
wrong f/g schedule
wrong partial-sum mapping
wrong bit ordering
wrong frozen-mask indexing
wrong register writeback
wrong resource-sharing sequence
wrong latency assumption
wrong Verilog width-growth policy
```

Therefore, Project 8.1 focuses on the N=16 golden model and schedule analysis first.

This is the correct academic sequence:

```text
golden model
→ golden vectors
→ schedule analysis
→ operation count
→ latency estimate
→ architecture plan
→ RTL implementation
```

---

## 3. Position In The Roadmap

The roadmap transition is:

```text
Project 7.7:
    Consolidate SC Decoder N=8 architecture exploration.

Project 8.1:
    Build SC Decoder N=16 golden model and schedule analysis.

Project 8.2:
    Implement SC Decoder N=16 reference RTL baseline.

Project 8.3:
    Implement resource-shared scheduled SC Decoder N=16.

Project 8.4:
    Perform Yosys and OpenLane comparison for N=16.
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

Project 8.1 preserves all conventions used in the N=8 roadmap.

Changing these conventions without updating all Python models, RTL files, testbenches, and documentation would break consistency.

---

## 6. LLR Width Convention

The project mainly uses:

```text
W = 6
```

A 6-bit signed LLR has range:

```text
-32 to 31
```

In the Python golden model, integer arithmetic is used, so overflow is not an issue.

In RTL, however, intermediate-width policy must be handled carefully because g operations can increase magnitude.

Examples:

```text
31 + 31 = 62
-32 + -32 = -64
31 - (-32) = 63
-32 - 31 = -63
```

Therefore, intermediate outputs may require:

```text
W+1 bits
```

or a carefully defined saturation/truncation policy in future RTL.

For Project 8.1, the Python model is used as the mathematical reference.

---

## 7. Hard-Decision Convention

The hard-decision rule is:

```text
LLR < 0  → decoded bit = 1
LLR >= 0 → decoded bit = 0
```

This convention must be preserved in:

```text
Python golden model
CSV golden vectors
Verilog RTL
Verilog testbench
future schedule-generated designs
```

---

## 8. Frozen-Mask Convention

The frozen-mask convention is:

```text
frozen_mask[i] = 1 → bit i is frozen and forced to 0
frozen_mask[i] = 0 → bit i is an information bit
```

For each leaf decision:

```text
if frozen_mask[i] = 1:
    u_hat[i] = 0
else:
    u_hat[i] = hard_decision(LLR)
```

This convention is the same as Projects 5, 6, and 7.

---

## 9. Bit-Ordering Convention

The project uses LSB-first bit indexing:

```text
u_hat[0] = u0
u_hat[1] = u1
...
u_hat[15] = u15
```

Integer packing is:

```text
u_hat_int = u0  * 2^0
          + u1  * 2^1
          + u2  * 2^2
          + ...
          + u15 * 2^15
```

Similarly:

```text
frozen_mask_int = frozen0  * 2^0
                + frozen1  * 2^1
                + ...
                + frozen15 * 2^15
```

This convention must remain consistent across:

```text
Python model
CSV file
Verilog testbench
future RTL
documentation
```

Bit-order mismatch is one of the most dangerous possible bugs.

---

## 10. SC f Function Convention

The f function uses the min-sum approximation:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

Hardware interpretation:

```text
magnitude = min(|a|, |b|)
negative  = sign(a) XOR sign(b)

if negative:
    y = -magnitude
else:
    y = magnitude
```

This is the same f function used in the N=8 roadmap.

---

## 11. SC g Function Convention

The g function is:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

The subtraction order is critical:

```text
b - a
```

not:

```text
a - b
```

This convention is preserved from Projects 3, 5, 6, and 7.

---

## 12. Recursive SC Decoder N=16 Structure

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

## 13. Top-Level N=16 Schedule

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

## 14. Recursive Golden Model Algorithm

The Python golden model uses a recursive SC decoder.

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

This recursive function supports:

```text
N=2
N=4
N=8
N=16
N=32
```

as long as N is a power of two.

---

## 15. Polar Encode Function For Partial Sums

Partial sums are generated using recursive Polar encoding.

Pseudocode:

```text
Polar_Encode(u):

    N = length(u)

    if N == 1:
        return u

    half = N / 2

    upper[i] = u[i] XOR u[i+half]
    lower[i] = u[i+half]

    return Polar_Encode(upper) + Polar_Encode(lower)
```

This must match the N=8 convention already used in previous projects.

For N=8, the expanded form is:

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

The Project 8.1 Python model checks this convention internally.

---

## 16. Actual Golden Model Implementation

The N=16 golden model has been implemented in:

```text
model/sc_decoder_n16_golden.py
```

The script provides:

```text
hard_decision()
f_func()
g_func()
polar_encode()
sc_decode()
bits_to_int_lsb_first()
operation_count()
generate_vectors()
```

It also includes self-checks for:

```text
N=8 Polar encoding convention
N=8 compatibility with previous Project 6.1 examples
N=16 deterministic examples
N=16 operation-count summary
```

This makes the N=16 model consistent with the previous N=8 roadmap.

---

## 17. Actual Golden Vector Generation Result

The golden model successfully generated:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
tests/golden_vectors/sc_decoder_n16_summary.txt
```

Actual file information:

```text
-rw-r--r-- 1 lucero lucero 114K May  4 09:03 tests/golden_vectors/sc_decoder_n16_vectors.csv
-rw-r--r-- 1 lucero lucero 742  May  4 09:03 tests/golden_vectors/sc_decoder_n16_summary.txt
```

The generated vector file has:

```text
1001 lines
```

This means:

```text
1 header line
1000 golden-vector lines
```

This confirms that the N=16 golden-vector generation flow is working correctly.

---

## 18. Golden Vector CSV Format

The CSV file has the following column groups:

```text
llr0..llr15
frozen0..frozen15
u_hat0..u_hat15
frozen_mask_int
u_hat_int
```

The header is:

```text
llr0,llr1,llr2,llr3,llr4,llr5,llr6,llr7,llr8,llr9,llr10,llr11,llr12,llr13,llr14,llr15,frozen0,frozen1,frozen2,frozen3,frozen4,frozen5,frozen6,frozen7,frozen8,frozen9,frozen10,frozen11,frozen12,frozen13,frozen14,frozen15,u_hat0,u_hat1,u_hat2,u_hat3,u_hat4,u_hat5,u_hat6,u_hat7,u_hat8,u_hat9,u_hat10,u_hat11,u_hat12,u_hat13,u_hat14,u_hat15,frozen_mask_int,u_hat_int
```

This format is suitable for a future Verilog testbench using `$fscanf`.

---

## 19. Example Generated Golden Vector

One generated vector example is:

```text
llr = [-1, -8, 4, 8, -7, -6, -3, 7, -8, -7, -7, 0, 1, -3, 6, 6]
```

Frozen mask:

```text
frozen_mask = [1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0]
```

Expected decoded output:

```text
u_hat = [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0]
```

Packed integers:

```text
frozen_mask_int = 18967
u_hat_int = 13376
```

This confirms that each vector contains:

```text
16 LLR values
16 frozen-mask bits
16 expected decoded bits
1 packed frozen-mask integer
1 packed u_hat integer
```

---

## 20. Actual N=16 Summary File Result

The generated summary file reports:

```text
N = 16
num_vectors = 1000
llr_min = -8
llr_max = 8
seed = 20260503
```

The preserved conventions are:

```text
frozen_mask[i] = 1 means frozen; force u_i = 0
frozen_mask[i] = 0 means information bit
hard decision: LLR < 0 -> 1, otherwise 0
bit packing: LSB-first
g(a,b,u): b+a if u=0, b-a if u=1
```

These conventions match the N=8 roadmap and must remain unchanged in future N=16 RTL.

---

## 21. Confirmed N=16 Operation Count

The generated summary reports:

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

This confirms the theoretical analysis.

The basic SC operation count for N=16 is:

```text
32 f operations
32 g operations
16 hard decisions
```

Therefore:

```text
f/g operations total = 64
f/g + hard decisions = 80
```

This is the minimum architectural workload before considering partial-sum scheduling.

---

## 22. Operation Count Derivation

For SC decoding with N=16:

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
total f operations = (N/2) × log2(N)
                   = 8 × 4
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

Therefore:

```text
f operations      = 32
g operations      = 32
hard decisions    = 16
```

Total f/g/hard-decision workload:

```text
32 + 32 + 16 = 80
```

---

## 23. Partial-Sum Operation Estimate

Partial sums are needed before g operations at every internal node.

For N=16, partial-sum generation occurs at multiple node sizes.

Top-level partial sums use:

```text
Polar_Encode_N8
```

Estimated XOR operations:

```text
(8/2) × log2(8) = 4 × 3 = 12
```

Two N=8 subtrees require N=4 partial sums:

```text
2 × [(4/2) × log2(4)] = 2 × 4 = 8
```

Four N=4 subtrees require N=2 partial sums:

```text
4 × [(2/2) × log2(2)] = 4 × 1 = 4
```

Total estimated staged partial-sum XOR operations:

```text
12 + 8 + 4 = 24
```

This matches the generated summary:

```text
partial_xors_est = 24
```

---

## 24. Latency Estimate

For a fully resource-shared datapath that computes one f or g operation per cycle:

```text
f/g cycles = 32 + 32 = 64 cycles
```

If hard decisions are one cycle each:

```text
hard-decision cycles = 16 cycles
```

Then the lower-bound latency is:

```text
64 + 16 = 80 cycles
```

If partial-sum XORs are scheduled as additional staged operations:

```text
partial_xors_est = 24
```

Then the conservative estimate is:

```text
80 + 24 = 104 cycles
```

Therefore, the early N=16 resource-shared latency range is:

```text
80–104 cycles
```

depending on how partial sums and hard decisions are integrated in the final RTL schedule.

---

## 25. Schedule Generator Implementation

A recursive schedule generator has been added:

```text
model/sc_schedule_generator.py
```

This script is responsible for generating a recursive SC decoding schedule for future resource-shared RTL implementation.

Expected generated files are:

```text
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

The schedule generator provides a bridge between:

```text
Python golden model
```

and:

```text
future resource-shared N=16 RTL
```

This is important because manual N=16 RTL scheduling is error-prone.

---

## 26. Schedule Generator Output

The expected output from the schedule generator is:

```text
[OK] Generated schedule for N=16
[OK] Rows: 112
```

The expected operation-count JSON is:

```json
{
  "N": 16,
  "levels": 4,
  "f_ops": 32,
  "g_ops": 32,
  "hard_decisions": 16,
  "partial_output_rows": 32,
  "partial_xors_est_staged": 24,
  "fg_ops_total": 64,
  "fg_plus_hard_decisions": 80,
  "latency_lower_bound_cycles": 80,
  "latency_if_partial_outputs_one_cycle_each": 112,
  "latency_conservative_est_cycles": 104
}
```

The difference between latency estimates is important.

```text
latency_lower_bound_cycles = 80
```

counts:

```text
f operations + g operations + hard decisions
```

The estimate:

```text
latency_if_partial_outputs_one_cycle_each = 112
```

assumes each documented partial-output row is treated as a separate explicit cycle.

The estimate:

```text
latency_conservative_est_cycles = 104
```

uses staged partial-sum XOR cost instead of one cycle per partial-output row.

---

## 27. Interpretation Of Schedule Row Count

The generated schedule contains:

```text
112 rows
```

These rows include:

```text
F operation rows
G operation rows
DECISION rows
PARTIAL rows
```

The important distinction is:

```text
Schedule rows are documentation/control steps.
They are not necessarily final RTL cycles one-to-one.
```

In actual RTL, some partial sums may be:

```text
computed combinationally
grouped into one state
or written explicitly into registers
```

Therefore, Project 8.1 should not prematurely claim final N=16 latency.

The current latency estimate should be treated as:

```text
architectural planning estimate
```

not final measured RTL latency.

---

## 28. Schedule Table Requirement For RTL

Before writing N=16 RTL, create or inspect a schedule table.

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
| 0 | ROOT | 16 | F | L0 | L8 | - | left0 |
| 1 | ROOT | 16 | F | L1 | L9 | - | left1 |
| 2 | ROOT | 16 | F | L2 | L10 | - | left2 |
| 8 | left | 8 | F | left0 | left4 | - | left_left0 |

This schedule table should become the reference for future RTL design.

---

## 29. Why Schedule Generation Is Better Than Manual RTL

Manual RTL worked for N=8.

For N=16, manual RTL becomes harder.

For N=32 or N=64, manual RTL becomes unsafe.

A schedule generator can produce:

```text
operation list
dependency list
latency estimate
testbench reference
documentation table
possibly RTL control table
```

This supports the stronger research direction:

```text
schedule-generated resource-shared SC Polar decoder
```

rather than:

```text
manually written decoder for each N
```

---

## 30. Storage Requirement Analysis

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
control registers
```

A careful storage map should be created before RTL.

---

## 31. Suggested Internal Storage For N=16

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

For scalability, a better approach is to use:

```text
arrays in SystemVerilog
or generated Verilog with flattened register names
```

If using pure Verilog-2001 for tool compatibility, flattened register naming may be required.

---

## 32. Expected Project 8.1 File Structure

Project 8.1 now has or targets the following structure:

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

This means Project 8.1 contains both:

```text
1. Correctness reference
2. Architecture schedule reference
```

These are the two foundations required before N=16 RTL.

---

## 33. Validation Checklist For Golden Model

The N=16 golden model is complete if:

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

Recommended commands:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

python3 model/sc_decoder_n16_golden.py

ls -lh tests/golden_vectors/sc_decoder_n16_vectors.csv
ls -lh tests/golden_vectors/sc_decoder_n16_summary.txt

head -3 tests/golden_vectors/sc_decoder_n16_vectors.csv
wc -l tests/golden_vectors/sc_decoder_n16_vectors.csv

cat tests/golden_vectors/sc_decoder_n16_summary.txt
```

Expected key check:

```text
1001 tests/golden_vectors/sc_decoder_n16_vectors.csv
```

---

## 34. Validation Checklist For Schedule Analysis

The schedule analysis is complete if:

```text
model/sc_schedule_generator.py exists
results/schedules/sc_decoder_n16_schedule.csv exists
results/schedules/sc_decoder_n16_schedule.md exists
results/schedules/sc_decoder_n16_operation_count.json exists
f operation count = 32
g operation count = 32
hard decision count = 16
partial output rows = 32
staged partial XOR estimate = 24
schedule rows = 112
latency estimates are documented
```

Recommended commands:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

python3 model/sc_schedule_generator.py

ls -lh results/schedules/sc_decoder_n16_schedule.csv
ls -lh results/schedules/sc_decoder_n16_schedule.md
ls -lh results/schedules/sc_decoder_n16_operation_count.json

head -5 results/schedules/sc_decoder_n16_schedule.csv
cat results/schedules/sc_decoder_n16_operation_count.json
```

---

## 35. Risk Analysis Before N=16 RTL

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
5. Start with a reference RTL baseline before optimizing heavily.
6. Add latency-cycle counter in testbench.
7. Compare RTL against golden vectors.
```

---

## 36. Recommended Architecture Direction For N=16

Based on Project 7.7, the best direction is:

```text
resource-shared scheduled SC Decoder N=16
```

However, for verification and learning, it is still useful to have a reference baseline.

Recommended architecture sequence:

```text
1. Python golden model N=16
2. schedule table N=16
3. reference RTL baseline N=16
4. resource-shared scheduled RTL N=16
5. Yosys comparison
6. OpenLane physical validation
```

---

## 37. Recommended Project 8.2 Direction

Project 8.2 should be:

```text
SC Decoder N=16 Reference RTL Baseline
```

Possible options:

```text
Option A:
    combinational/reference RTL N=16 for correctness baseline

Option B:
    schedule-driven multi-cycle RTL N=16 using generated schedule

Option C:
    directly implement resource-shared N=16 based on generated schedule
```

The safest academic route is:

```text
Project 8.2:
    reference RTL baseline

Project 8.3:
    resource-shared scheduled RTL
```

This avoids mixing correctness validation and architecture optimization too early.

---

## 38. Minimum Results Needed Before Paper Draft

Before writing a strong conference paper, aim to have:

```text
1. N=8 combinational vs resource-shared comparison
2. N=16 golden model
3. N=16 reference RTL verification
4. N=16 resource-shared RTL verification
5. N=16 Yosys synthesis result
6. at least one N=16 OpenLane run
7. latency-cycle measurement
8. clear area/timing/latency trade-off table
```

Before a Q1 journal, likely need:

```text
N=32 or broader scalability
more rigorous comparison
possibly FPGA validation
possibly ASIC multi-corner results
power/energy estimate under consistent activity
better automation and schedule generation
```

---

## 39. Updated Project 8.1 Deliverables

Project 8.1 deliverables are:

### Documentation

```text
docs/project8_1/sc_decoder_n16_golden_model_and_schedule_analysis.md
```

### Golden Model

```text
model/sc_decoder_n16_golden.py
```

### Golden Vectors

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
tests/golden_vectors/sc_decoder_n16_summary.txt
```

### Schedule Generator

```text
model/sc_schedule_generator.py
```

### Schedule Outputs

```text
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

---

## 40. What To Commit

At this stage, commit:

```text
docs/project8_1/sc_decoder_n16_golden_model_and_schedule_analysis.md
model/sc_decoder_n16_golden.py
tests/golden_vectors/sc_decoder_n16_vectors.csv
tests/golden_vectors/sc_decoder_n16_summary.txt
model/sc_schedule_generator.py
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

Recommended commits:

```bash
git add model/sc_decoder_n16_golden.py \
        tests/golden_vectors/sc_decoder_n16_vectors.csv \
        tests/golden_vectors/sc_decoder_n16_summary.txt

git commit -m "model: add SC decoder N16 golden model and vectors"

git add model/sc_schedule_generator.py \
        results/schedules/sc_decoder_n16_schedule.csv \
        results/schedules/sc_decoder_n16_schedule.md \
        results/schedules/sc_decoder_n16_operation_count.json

git commit -m "model: add SC decoder N16 schedule generator and schedule analysis"

git add docs/project8_1/sc_decoder_n16_golden_model_and_schedule_analysis.md

git commit -m "docs: rewrite project8.1 N16 golden model and schedule analysis"
```

---

## 41. Readiness Checklist Before Project 8.2

Before moving to Project 8.2, verify:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

git status

python3 model/sc_decoder_n16_golden.py
python3 model/sc_schedule_generator.py

wc -l tests/golden_vectors/sc_decoder_n16_vectors.csv
cat tests/golden_vectors/sc_decoder_n16_summary.txt
cat results/schedules/sc_decoder_n16_operation_count.json

find docs/project8_1 model tests/golden_vectors results/schedules -maxdepth 2 -type f | sort
```

Expected key results:

```text
working tree clean after commit
sc_decoder_n16_vectors.csv has 1001 lines
f_ops = 32
g_ops = 32
hard_decisions = 16
latency_lower_bound_cycles = 80
latency_conservative_est_cycles = 104
schedule rows = 112
```

---

## 42. Academic Interpretation

Project 8.1 is a proper pre-RTL architecture preparation project.

It provides:

```text
a working recursive golden model
a generated golden-vector dataset
a reproducible operation-count summary
a schedule generator
a schedule table for resource-shared planning
```

This is academically stronger than jumping directly into RTL.

The current Project 8.1 result supports the following statement:

```text
The N=16 decoder expansion is grounded in a verified recursive golden model and an explicit SC operation schedule, reducing the risk of RTL-level indexing, partial-sum, and dependency errors.
```

---

## 43. Project 8.1 Conclusion

Project 8.1 successfully establishes the pre-RTL foundation for SC Decoder N=16.

The project now includes:

```text
Python golden model
1000 golden vectors
operation-count summary
schedule generator
generated schedule table
latency estimates
```

Confirmed golden-model results:

```text
N = 16
num_vectors = 1000
CSV lines = 1001
f_ops = 32
g_ops = 32
hard_decisions = 16
partial_xors_est = 24
latency_lower_bound_cycles = 80
latency_conservative_est_cycles = 104
```

Expected schedule-generator result:

```text
schedule rows = 112
partial_output_rows = 32
latency_if_partial_outputs_one_cycle_each = 112
```

The main conclusion is:

```text
N=16 RTL should now be developed from the verified golden model and generated schedule, not by manual intuition alone.
```

The next step is:

```text
Project 8.2: SC Decoder N=16 Reference RTL Baseline
```