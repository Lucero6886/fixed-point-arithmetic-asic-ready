# SC Decoder N=16 Resource-Shared Functional Verification Summary

## 1. Summary

This document summarizes the functional verification result of the resource-shared scheduled SC Decoder N=16 developed in Project 8.3.

The design under test is:

```text
rtl/sc_decoder_n16_shared.v
```

The RTL generator is:

```text
scripts/generate_sc_decoder_n16_shared_rtl.py
```

The testbench is:

```text
tb/tb_sc_decoder_n16_shared_vectors.v
```

The simulation script is:

```text
sim/run_sc_decoder_n16_shared_vectors.sh
```

The golden-vector dataset is:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

The waveform file is:

```text
sim/waveforms/sc_decoder_n16_shared_vectors.vcd
```

The verification result confirms that the resource-shared scheduled SC Decoder N=16 matches the Python golden model on all generated test vectors.

---

## 2. Verification Target

The main verification target is:

```text
1000 N=16 golden vectors
0 errors
ALL TESTS PASSED
```

The purpose of this verification is to confirm that the multi-cycle resource-shared RTL produces the same decoded output as the Project 8.1 Python golden model.

The verification checks:

```text
LLR input handling
frozen-mask handling
SC f-operation correctness
SC g-operation correctness
partial-sum correctness
hard-decision correctness
bit-ordering correctness
start/busy/done protocol correctness
u_hat output correctness
deterministic latency
```

---

## 3. Simulation Result

The simulation output was:

```text
Running simulation...
VCD info: dumpfile sim/waveforms/sc_decoder_n16_shared_vectors.vcd opened for output.
====================================
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
Latency min cycles      = 115
Latency max cycles      = 115
Latency avg cycles      = 115
ALL TESTS PASSED.
====================================
tb/tb_sc_decoder_n16_shared_vectors.v:252: $finish called at 1160066000 (1ps)
Simulation completed.
Waveform: sim/waveforms/sc_decoder_n16_shared_vectors.vcd
```

---

## 4. Key Verification Metrics

| Metric | Value |
|---|---:|
| Vector lines read | 1000 |
| Total tests | 1000 |
| Total errors | 0 |
| Minimum latency | 115 cycles |
| Maximum latency | 115 cycles |
| Average latency | 115 cycles |
| Result | ALL TESTS PASSED |

The result is deterministic because:

```text
latency_min = latency_max = latency_avg = 115 cycles
```

This means every decoded vector requires the same number of cycles under the current FSM schedule.

---

## 5. Interpretation

The result confirms that:

```text
rtl/sc_decoder_n16_shared.v
```

is functionally correct against:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

The generated resource-shared scheduled SC Decoder N=16 passed:

```text
1000 / 1000 vectors
```

with:

```text
0 errors
```

Therefore, the first and most important milestone of Project 8.3 has been achieved:

```text
The SC Decoder N=16 resource-shared scheduled RTL is functionally correct.
```

---

## 6. Architecture Under Verification

The verified architecture is a multi-cycle resource-shared SC Decoder N=16.

It uses:

```text
start/busy/done interface
FSM controller
one shared f/g datapath
internal LLR registers
partial-sum registers
decoded-bit registers
u_hat output register
schedule-guided operation sequence
```

The architecture follows the Project 8.1 schedule generated from:

```text
model/sc_schedule_generator.py
```

and the schedule files:

```text
results/schedules/sc_decoder_n16_schedule.csv
results/schedules/sc_decoder_n16_schedule.md
results/schedules/sc_decoder_n16_operation_count.json
```

The generated RTL is produced by:

```text
scripts/generate_sc_decoder_n16_shared_rtl.py
```

This means the RTL is not manually written state-by-state. It is generated from the schedule-analysis infrastructure developed in Project 8.1.

---

## 7. Golden Model Reference

The Python golden model used to generate expected results is:

```text
model/sc_decoder_n16_golden.py
```

The generated vector file is:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

The vector file contains:

```text
16 LLR values
16 frozen-mask bits
16 expected decoded bits
frozen_mask_int
u_hat_int
```

The expected number of lines is:

```text
1001 lines = 1 header + 1000 vectors
```

This was confirmed earlier in Project 8.1.

---

## 8. Preserved Conventions

The RTL and testbench preserve the same conventions used in the Python golden model.

### 8.1 Frozen-Mask Convention

```text
frozen_mask[i] = 1 → bit i is frozen and forced to 0
frozen_mask[i] = 0 → bit i is an information bit
```

### 8.2 Hard-Decision Convention

```text
LLR < 0  → decoded bit = 1
LLR >= 0 → decoded bit = 0
```

### 8.3 Bit-Ordering Convention

```text
u_hat[0]  = u0
u_hat[1]  = u1
...
u_hat[15] = u15
```

The output is packed LSB-first.

### 8.4 g-Function Convention

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

The subtraction order is:

```text
b - a
```

not:

```text
a - b
```

### 8.5 Internal Width Convention

The generated shared decoder follows the Project 8.1 and Project 8.2 width policy:

```text
W_IN  = 6
W_INT = 10
```

Input LLRs are sign-extended from 6-bit to 10-bit internal values.

This prevents mismatch with the Python golden model caused by overflow during recursive g operations.

---

## 9. Latency Interpretation

The measured latency is:

```text
latency_cycles = 115
```

This is the actual RTL-level latency measured by the testbench from the start transaction until the done signal is observed.

Project 8.1 estimated:

```text
latency_lower_bound_cycles = 80
latency_conservative_est_cycles = 104
latency_if_partial_outputs_one_cycle_each = 112
```

The measured value is slightly larger:

```text
measured_latency = 115 cycles
```

This is reasonable because the actual RTL includes additional FSM and handshake overhead, such as:

```text
S_IDLE
S_LOAD
schedule execution states
partial-sum/writeback states
S_DONE
u_hat update
done observation by the testbench
```

Therefore, the correct interpretation is:

```text
The theoretical schedule estimates were planning estimates.
The measured RTL latency is 115 cycles.
```

---

## 10. Why Latency Is Deterministic

The latency is deterministic because the FSM follows a fixed SC decoding schedule.

The decoding path does not change based on:

```text
LLR values
frozen-mask pattern
decoded-bit values
```

Every vector executes the same schedule.

Therefore:

```text
Latency min cycles = 115
Latency max cycles = 115
Latency avg cycles = 115
```

This is a useful property for hardware integration because the decoder has predictable timing behavior.

---

## 11. Functional Significance

This result is important because the resource-shared N=16 design is much more complex than the N=8 version.

It verifies:

```text
recursive N=16 SC schedule correctness
correct reuse of the shared f/g datapath
correct intermediate LLR writeback
correct partial-sum generation
correct right-branch g-control bits
correct final u_hat ordering
correct start/done synchronization
```

Passing 1000 golden vectors with zero errors is strong evidence that the RTL implementation is functionally stable.

---

## 12. Relationship To Project 8.1

Project 8.1 produced:

```text
Python golden model
N=16 golden vectors
schedule generator
operation-count analysis
latency estimates
```

Project 8.3 now confirms that the generated schedule can be used to produce a working RTL implementation.

This validates the design methodology:

```text
golden model
→ schedule generation
→ generated/shared RTL
→ golden-vector verification
```

This is a major step toward a schedule-generated resource-shared SC Polar decoder architecture.

---

## 13. Relationship To Project 8.2

Project 8.2 implemented the N=16 reference RTL baseline.

Project 8.3 implements the optimized architectural direction:

```text
resource-shared scheduled SC Decoder N=16
```

Both should be verified using the same dataset:

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

This allows fair comparison between:

```text
N=16 reference RTL
N=16 resource-shared scheduled RTL
```

The next comparison should include:

```text
Yosys cell count
DFF/DFFE count
estimated combinational cell count
MUX count
XOR/XNOR count
NAND count
latency cycles
```

---

## 14. Relationship To Project 8.2.1

Project 8.2.1 measures the synthesis complexity of the N=16 reference RTL.

Project 8.3 functional verification prepares the resource-shared design for a similar Yosys study.

The next expected file set is:

```text
synth/sc_decoder_n16_shared.ys
synth/run_sc_decoder_n16_shared_yosys.sh
scripts/extract_sc_decoder_n16_shared_yosys_summary.py
results/summary/sc_decoder_n16_shared_yosys_summary.csv
results/summary/sc_decoder_n16_shared_yosys_summary.md
```

This will enable direct synthesis-level comparison between the reference and resource-shared architectures.

---

## 15. Current Project 8.3 Status

Project 8.3 currently has the following status:

| Item | Status |
|---|---|
| RTL generator | Completed |
| RTL generated | Completed |
| Testbench created | Completed |
| Simulation script created | Completed |
| Golden-vector verification | Passed |
| Latency measurement | Completed |
| Yosys synthesis | Next step |
| OpenLane implementation | Future step |

The current milestone is:

```text
Functional RTL verification completed successfully.
```

---

## 16. Files Generated Or Used

### RTL Generator

```text
scripts/generate_sc_decoder_n16_shared_rtl.py
```

### Generated RTL

```text
rtl/sc_decoder_n16_shared.v
```

### Testbench

```text
tb/tb_sc_decoder_n16_shared_vectors.v
```

### Simulation Script

```text
sim/run_sc_decoder_n16_shared_vectors.sh
```

### Golden Vectors

```text
tests/golden_vectors/sc_decoder_n16_vectors.csv
```

### Waveform

```text
sim/waveforms/sc_decoder_n16_shared_vectors.vcd
```

### Functional Summary

```text
results/summary/sc_decoder_n16_shared_functional_summary.md
```

---

## 17. Recommended Reproduction Command

To reproduce the functional verification result, run:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

./sim/run_sc_decoder_n16_shared_vectors.sh
```

Expected result:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
Latency min cycles      = 115
Latency max cycles      = 115
Latency avg cycles      = 115
ALL TESTS PASSED.
```

---

## 18. What This Result Does Not Yet Prove

This functional verification result does not yet prove:

```text
lower area than the reference N=16 RTL
lower Yosys cell count
better physical timing
OpenLane DRC/LVS/antenna cleanliness
lower power
better throughput
```

Those claims require additional synthesis and physical implementation studies.

Specifically, the next step is:

```text
Project 8.3.1: Yosys synthesis study for SC Decoder N=16 resource-shared RTL
```

---

## 19. Academic Interpretation

The correct academic statement is:

```text
The resource-shared scheduled SC Decoder N=16 RTL has been functionally verified against 1000 Python-generated golden vectors, achieving zero errors with deterministic 115-cycle latency.
```

A stronger architecture claim should wait until Yosys and OpenLane results are available.

At this stage, the verified contribution is:

```text
correct schedule-guided resource-shared RTL implementation for N=16
```

not yet:

```text
proven area/timing superiority
```

---

## 20. Importance For Research Roadmap

This result is a strong roadmap milestone because it confirms that the N=8 resource-sharing idea can be extended to N=16.

The project has now demonstrated:

```text
N=8 resource-shared scheduled decoder
N=16 schedule generation
N=16 resource-shared RTL generation
N=16 functional verification
```

This supports the longer-term research direction:

```text
schedule-generated resource-shared SC Polar decoder architecture
```

---

## 21. Recommended Next Step

The next step should be:

```text
Project 8.3.1: Yosys synthesis study for SC Decoder N=16 resource-shared RTL
```

The purpose is to answer:

```text
Does the resource-shared N=16 RTL reduce combinational complexity compared with the N=16 reference RTL?
```

The comparison should include:

```text
total cells
DFF/DFFE cells
estimated combinational cells
MUX cells
XOR/XNOR cells
NAND cells
latency cycles
```

---

## 22. Recommended Commit

The following files should be committed after functional verification:

```text
scripts/generate_sc_decoder_n16_shared_rtl.py
rtl/sc_decoder_n16_shared.v
tb/tb_sc_decoder_n16_shared_vectors.v
sim/run_sc_decoder_n16_shared_vectors.sh
docs/project8_3/sc_decoder_n16_resource_shared_scheduled.md
results/summary/sc_decoder_n16_shared_functional_summary.md
```

Recommended command:

```bash
git add scripts/generate_sc_decoder_n16_shared_rtl.py \
        rtl/sc_decoder_n16_shared.v \
        tb/tb_sc_decoder_n16_shared_vectors.v \
        sim/run_sc_decoder_n16_shared_vectors.sh \
        docs/project8_3/sc_decoder_n16_resource_shared_scheduled.md \
        results/summary/sc_decoder_n16_shared_functional_summary.md

git commit -m "project8.3: add resource-shared scheduled SC decoder N16"
git push origin main
```

The waveform file should normally not be committed if it is large:

```text
sim/waveforms/sc_decoder_n16_shared_vectors.vcd
```

---

## 23. Conclusion

The resource-shared scheduled SC Decoder N=16 has passed functional verification.

The final verification result is:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
Latency min cycles      = 115
Latency max cycles      = 115
Latency avg cycles      = 115
ALL TESTS PASSED.
```

The measured deterministic latency is:

```text
115 cycles
```

This confirms that Project 8.3 has achieved its first major milestone:

```text
functional RTL correctness of the N=16 resource-shared scheduled SC decoder
```

The next required milestone is synthesis characterization:

```text
Project 8.3.1: Yosys synthesis study for SC Decoder N=16 resource-shared RTL
```