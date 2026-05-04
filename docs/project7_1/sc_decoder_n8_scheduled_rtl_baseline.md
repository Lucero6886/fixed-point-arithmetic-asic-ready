# Project 7.1: Scheduled / Multi-Cycle SC Decoder N=8 RTL Baseline

## 1. Project Objective

Project 7.1 implements and verifies a scheduled, multi-cycle SC Decoder N=8.

The main objective is to move beyond the one-cycle combinational SC Decoder N=8 from Project 6 and explore a decoder architecture that performs the SC decoding process over multiple clock cycles.

Project 6 used a combinational architecture:

```text
input LLRs
→ full SC decoding tree
→ u_hat output
within one large combinational path
```

Project 7.1 introduces a scheduled architecture:

```text
input LLRs
→ sequence of FSM-controlled computation steps
→ intermediate registers
→ final u_hat output after multiple cycles
```

At the end of this project, the learner should understand:

```text
why a multi-cycle decoder is useful
how SC decoding can be expressed as a schedule of operations
how an FSM controls decoder execution
how start/busy/done handshake works
how to verify a multi-cycle RTL design using golden vectors
why scheduled design is not automatically resource-shared
```

---

## 2. Why This Project Is Important

Project 6.4 showed that the combinational SC Decoder N=8 can be implemented through OpenLane cleanly, but it required a relaxed clock:

```text
CLOCK_PERIOD = 80 ns
critical_path_ns = 29.01 ns
die area = 0.64 mm²
```

This result proves physical feasibility, but it also reveals a limitation:

```text
The full combinational SC decoding path is long.
```

A natural next step is to split the computation into multiple cycles.

This is the purpose of Project 7.1.

The central question is:

```text
Can the SC Decoder N=8 be implemented as a multi-cycle scheduled RTL design and still match the golden vectors?
```

This project does not yet aim to minimize resources. It first proves that a scheduled SC decoder can be functionally correct.

---

## 3. Position In The Roadmap

The roadmap around Project 7 is:

```text
Project 6.4: combinational N=8 OpenLane clean baseline
Project 7.1: scheduled / multi-cycle N=8 RTL baseline
Project 7.2: Yosys comparison — combinational N=8 vs scheduled N=8
Project 7.3: resource-shared scheduled N=8 decoder
Project 7.4: three-architecture Yosys comparison
Project 7.5: OpenLane implementation of resource-shared N=8
Project 7.6: timing push for resource-shared N=8
```

Project 7.1 is the first step in the architecture exploration phase.

---

## 4. Input Files

The main input files are:

```text
rtl/sc_decoder_n8_scheduled.v
tb/tb_sc_decoder_n8_scheduled_vectors.v
sim/run_sc_decoder_n8_scheduled_vectors.sh
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

The golden vector file comes from Project 6.1:

```text
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

This file is reused to verify that the scheduled RTL produces the same output as the Python golden model and the combinational RTL baseline.

---

## 5. Output Files

The main output files are:

```text
sim/sc_decoder_n8_scheduled_vectors_sim
sim/waveforms/sc_decoder_n8_scheduled_vectors.vcd
simulation console output
```

The expected successful simulation result is:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED
```

---

## 6. Expected File Structure

The expected file structure for Project 7.1 is:

```text
rtl/
  sc_decoder_n8_scheduled.v

tb/
  tb_sc_decoder_n8_scheduled_vectors.v

sim/
  run_sc_decoder_n8_scheduled_vectors.sh
  waveforms/
    sc_decoder_n8_scheduled_vectors.vcd

tests/
  golden_vectors/
    sc_decoder_n8_vectors.csv

docs/
  project7_1/
    sc_decoder_n8_scheduled_rtl_baseline.md
```

---

## 7. Architecture Overview

The scheduled SC Decoder N=8 performs the same algorithm as the combinational decoder, but not in one combinational pass.

Instead, it uses:

```text
FSM controller
internal registers
intermediate LLR storage
partial-sum storage
decoded-bit storage
start/busy/done handshake
```

The high-level idea is:

```text
Cycle 0:
    load input LLRs and frozen mask

Cycles 1..k:
    execute SC decoding steps according to a schedule

Final cycle:
    assert done and output u_hat
```

This turns one large combinational computation into a multi-cycle computation.

---

## 8. Scheduled Versus Combinational Decoder

### 8.1 Combinational Decoder

The combinational decoder from Project 6 computes:

```text
u_hat = SC_Decode_N8(LLR, frozen_mask)
```

in one combinational path.

Advantage:

```text
simple interface
easy to verify
no controller
```

Disadvantage:

```text
long critical path
larger duplicated combinational logic
poor scalability
```

---

### 8.2 Scheduled Decoder

The scheduled decoder computes the same result over several cycles.

Advantage:

```text
clear algorithmic schedule
shorter per-cycle intended computation
closer to real sequential hardware
prepares for resource sharing
```

Disadvantage:

```text
requires FSM
requires internal registers
requires handshake
may increase cell count if resources are not explicitly shared
```

The key lesson is:

```text
Scheduling alone is not the same as resource sharing.
```

Project 7.1 is scheduled, but it is not yet the final resource-shared design.

---

## 9. Handshake Interface

The scheduled decoder uses a control interface such as:

```text
clk
rst_n
start
busy
done
```

Typical behavior:

```text
start = 1:
    load inputs and begin decoding

busy = 1:
    decoder is running

done = 1:
    output u_hat is valid
```

The testbench must wait until:

```text
done == 1
```

before checking the output.

This is different from the combinational decoder, where the output can be checked after a small combinational delay.

---

## 10. Input And Output Interface

A typical interface is:

```verilog
module sc_decoder_n8_scheduled #(
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

The exact RTL interface may differ, but the key concept is that the decoder is no longer purely combinational.

It has sequential control.

---

## 11. SC Decoder N=8 Schedule

The scheduled decoder must implement the same N=8 schedule as the golden model.

The high-level schedule is:

```text
1. Load LLR inputs and frozen mask.
2. Compute top-level left LLRs:
       left0 = f(L0, L4)
       left1 = f(L1, L5)
       left2 = f(L2, L6)
       left3 = f(L3, L7)

3. Decode left N=4 branch:
       compute u0
       compute u1
       compute u2
       compute u3

4. Compute top-level partial sums:
       p0 = u0 ^ u1 ^ u2 ^ u3
       p1 = u1 ^ u3
       p2 = u2 ^ u3
       p3 = u3

5. Compute top-level right LLRs:
       right0 = g(L0, L4, p0)
       right1 = g(L1, L5, p1)
       right2 = g(L2, L6, p2)
       right3 = g(L3, L7, p3)

6. Decode right N=4 branch:
       compute u4
       compute u5
       compute u6
       compute u7

7. Assert done.
```

The scheduled RTL may implement these steps as FSM states.

---

## 12. Example FSM State Organization

A possible FSM organization is:

```text
S_IDLE
S_LOAD

S_TOP_F0
S_TOP_F1
S_TOP_F2
S_TOP_F3

S_LEFT_U0
S_LEFT_U1
S_LEFT_PARTIAL
S_LEFT_U2
S_LEFT_U3

S_TOP_PARTIAL
S_TOP_G0
S_TOP_G1
S_TOP_G2
S_TOP_G3

S_RIGHT_U4
S_RIGHT_U5
S_RIGHT_PARTIAL
S_RIGHT_U6
S_RIGHT_U7

S_DONE
```

The actual implementation may group several operations into one state or compute several independent operations in parallel.

The important point is that the FSM order must respect SC data dependencies.

---

## 13. Data Dependency In SC Decoding

SC decoding has strict dependencies.

For example, the right branch cannot be computed before the left branch decisions are available.

For N=8:

```text
right_i = g(L_i, L_{i+4}, partial_i)
```

But:

```text
partial_i depends on u0, u1, u2, u3
```

Therefore:

```text
u0..u3 must be decoded before right0..right3 can be computed
```

This dependency is the reason a scheduled decoder is natural.

---

## 14. Internal Registers

The scheduled decoder typically stores:

```text
input LLRs
left LLRs
right LLRs
intermediate N=2 LLRs
partial sums
decoded bits
frozen mask
```

Example internal registers:

```text
L0_reg..L7_reg
left0_reg..left3_reg
right0_reg..right3_reg
u0_reg..u7_reg
p0_reg..p3_reg
frozen_mask_reg
```

These registers allow the decoder to preserve intermediate values across cycles.

---

## 15. f And g Computation In Scheduled RTL

The scheduled RTL may compute f/g operations using:

```text
combinational helper functions
instantiated sc_f_unit/sc_g_unit modules
inline arithmetic expressions
```

For Project 7.1, the goal is not necessarily to share one f/g unit.

The goal is to implement a correct multi-cycle schedule.

Resource sharing is introduced more explicitly in Project 7.3.

---

## 16. Important Concept: Scheduled Does Not Mean Resource-Shared

This is the most important conceptual point of Project 7.1.

A scheduled decoder means:

```text
the computation is divided into multiple cycles
```

A resource-shared decoder means:

```text
the same hardware datapath is reused for multiple operations
```

These are related but not identical.

A design can be scheduled but still use many duplicated arithmetic blocks.

Therefore:

```text
Project 7.1 = scheduled baseline
Project 7.3 = explicit resource-shared scheduled design
```

This distinction is later confirmed by Yosys comparison in Project 7.2.

---

## 17. Testbench Objective

The testbench verifies the scheduled RTL against the same golden vectors used in Project 6.2.

For each CSV row, the testbench should:

```text
1. Read LLRs.
2. Read frozen mask.
3. Read expected u_hat.
4. Apply inputs.
5. Pulse start.
6. Wait for done.
7. Compare RTL u_hat with expected u_hat.
8. Count errors.
```

Unlike the combinational testbench, it must not check the output immediately.

It must wait for:

```text
done == 1
```

---

## 18. Why The First Testbench Failed

An initial testbench version produced:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 1000
TEST FAILED
```

This means every vector failed.

When all vectors fail, the cause is usually not a small arithmetic bug.

Common causes include:

```text
checking output too early
not waiting for done
wrong handshake timing
start pulse not aligned
reset not released correctly
u_hat sampled before valid
expected/actual bit order mismatch
```

In this case, the issue was corrected by updating the testbench so that it properly synchronized with the scheduled decoder.

---

## 19. Corrected Testbench Behavior

The corrected testbench waits for the decoder to finish before checking output.

The correct flow is:

```text
apply inputs
pulse start
wait until busy becomes active or done becomes valid
wait for done
sample u_hat
compare with expected
move to next vector
```

This is required for all multi-cycle designs.

---

## 20. Confirmed Simulation Result

After updating the testbench, Project 7.1 achieved the following result:

```text
Running simulation...
VCD info: dumpfile sim/waveforms/sc_decoder_n8_scheduled_vectors.vcd opened for output.
====================================
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED.
====================================
tb/tb_sc_decoder_n8_scheduled_vectors.v:280: $finish called at 280046000 (1ps)
Simulation completed.
Waveform: sim/waveforms/sc_decoder_n8_scheduled_vectors.vcd
```

This confirms that the scheduled N=8 RTL matches the Python golden model for 1000 vectors.

---

## 21. Simulation Command

Run the simulation using:

```bash
./sim/run_sc_decoder_n8_scheduled_vectors.sh
```

A direct command may look like:

```bash
iverilog -g2012 -o sim/sc_decoder_n8_scheduled_vectors_sim \
    rtl/sc_decoder_n8_scheduled.v \
    tb/tb_sc_decoder_n8_scheduled_vectors.v

vvp sim/sc_decoder_n8_scheduled_vectors_sim
```

The exact file list depends on whether helper modules or functions are used.

---

## 22. What To Check In The Waveform

Open waveform:

```bash
gtkwave sim/waveforms/sc_decoder_n8_scheduled_vectors.vcd
```

Important signals to inspect:

```text
clk
rst_n
start
busy
done
state
llr inputs
frozen_mask
intermediate LLR registers
partial sums
u_hat
expected_u_hat
test_count
error_count
```

Important waveform behavior:

```text
start should pulse once per vector
busy should indicate active decoding
done should assert after the scheduled computation completes
u_hat should be checked only when done is asserted
state should progress through the expected decoding sequence
```

---

## 23. Latency Observation

From the simulation output:

```text
finish called at 280046000 ps
```

The testbench processed:

```text
1000 vectors
```

The approximate average simulation time per vector is:

```text
280046000 ps / 1000 = 280046 ps
```

If the testbench uses a 10 ns clock period, this corresponds approximately to:

```text
about 28 cycles per vector
```

This suggests that the scheduled decoder latency is around the expected multi-cycle range.

The exact cycle count should be measured directly from the RTL/testbench state timing and documented if needed.

---

## 24. Recommended Latency Measurement

To make latency explicit, the testbench can count cycles between:

```text
start assertion
```

and:

```text
done assertion
```

Example:

```verilog
cycle_count = 0;

while (!done) begin
    @(posedge clk);
    cycle_count = cycle_count + 1;
end
```

The measured latency should be reported as:

```text
latency_cycles = number of cycles from start to done
```

This metric will be important for comparing future architectures.

---

## 25. Validation Checklist

Project 7.1 is complete if:

```text
rtl/sc_decoder_n8_scheduled.v exists
tb/tb_sc_decoder_n8_scheduled_vectors.v exists
sim/run_sc_decoder_n8_scheduled_vectors.sh exists
tests/golden_vectors/sc_decoder_n8_vectors.csv exists
simulation reads 1000 vectors
simulation reports 0 errors
waveform is generated
start/busy/done behavior is correct
testbench waits for done before checking output
```

Recommended commands:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

ls -lh rtl/sc_decoder_n8_scheduled.v
ls -lh tb/tb_sc_decoder_n8_scheduled_vectors.v
ls -lh sim/run_sc_decoder_n8_scheduled_vectors.sh
ls -lh tests/golden_vectors/sc_decoder_n8_vectors.csv

./sim/run_sc_decoder_n8_scheduled_vectors.sh
```

---

## 26. Difference Between Project 6.2 And Project 7.1

Project 6.2 implemented:

```text
combinational SC Decoder N=8
```

Project 7.1 implements:

```text
scheduled / multi-cycle SC Decoder N=8
```

Comparison:

| Feature | Project 6.2 | Project 7.1 |
|---|---|---|
| Architecture | combinational | multi-cycle scheduled |
| Control FSM | no | yes |
| start/done handshake | no | yes |
| Intermediate registers | no or minimal | yes |
| Output valid timing | after combinational delay | after done |
| Verification style | direct check | wait-for-done check |
| Goal | functional RTL baseline | scheduled RTL baseline |

Both designs should produce the same `u_hat` for the same input vectors.

---

## 27. Difference Between Project 7.1 And Project 7.3

Project 7.1 proves that a scheduled SC Decoder N=8 can be functionally correct.

Project 7.3 will explicitly share hardware resources.

The difference is:

```text
Project 7.1:
    schedule the computation with FSM

Project 7.3:
    schedule the computation and reuse a shared f/g datapath
```

Therefore, Project 7.1 is a necessary intermediate step but not the final architecture optimization.

---

## 28. Why Project 7.1 Is Still Useful Even If Cell Count Increases

Later Project 7.2 shows that the scheduled decoder may have more cells than the combinational baseline.

This does not make Project 7.1 useless.

Project 7.1 is useful because it teaches:

```text
how to write a multi-cycle SC decoder
how to control SC computation using FSM
how to verify a sequential decoder
how to handle start/done protocol
why scheduling alone is not enough
```

This learning is necessary before designing the resource-shared decoder.

---

## 29. Common Problems And Debugging

### Problem 1: All Vectors Fail

Symptom:

```text
Total errors = 1000
```

Likely causes:

```text
testbench checks u_hat before done
start pulse is wrong
reset timing is wrong
u_hat is sampled one cycle too early
expected bit order mismatch
```

Fix:

```text
wait for done before checking
inspect waveform
check start/busy/done timing
```

---

### Problem 2: Decoder Never Asserts done

Possible causes:

```text
FSM state transition bug
start not detected
reset stuck active
missing default state assignment
state register not updated
```

Fix:

```text
inspect state signal in waveform
check reset release
check start pulse width
check FSM next-state logic
```

---

### Problem 3: Decoder Produces Correct First Vector But Fails Later

Possible causes:

```text
internal registers not cleared between vectors
done not deasserted properly
start applied while busy
testbench does not wait for idle
```

Fix:

```text
wait for decoder to return to idle
clear internal registers if necessary
deassert start after one cycle
```

---

### Problem 4: u_hat Is One Vector Late

Possible cause:

```text
testbench samples output at wrong cycle
done and u_hat update timing not aligned
```

Fix:

```text
sample u_hat after done is asserted
or one clock after done depending on RTL convention
document the convention
```

---

### Problem 5: Partial Sums Are Wrong

For the N=8 top-level partial sums:

```text
p0 = u0 ^ u1 ^ u2 ^ u3
p1 = u1 ^ u3
p2 = u2 ^ u3
p3 = u3
```

If these are wrong, the right branch will fail.

---

### Problem 6: start While busy

The testbench should not assert `start` while `busy = 1`.

Correct protocol:

```text
wait until decoder is idle
apply inputs
pulse start
wait for done
check output
repeat
```

---

## 30. Lessons Learned

Project 7.1 teaches the following key lessons:

```text
1. SC decoding can be expressed as a sequence of scheduled operations.
2. A multi-cycle decoder requires FSM control and internal registers.
3. Sequential RTL verification requires handshake-aware testbenches.
4. The testbench must wait for done before checking output.
5. Scheduling alone does not guarantee resource sharing.
6. A scheduled decoder is an important bridge toward resource-shared architecture.
7. Multi-cycle designs require careful reset, start, busy, and done control.
```

---

## 31. Role Of This Project In The Full Roadmap

Project 7.1 belongs to the N=8 architecture exploration layer.

The roadmap progression is:

```text
Project 6.4: combinational N=8 OpenLane clean baseline
Project 7.1: scheduled N=8 RTL baseline
Project 7.2: Yosys comparison of combinational vs scheduled
Project 7.3: resource-shared scheduled N=8 RTL
Project 7.4: three-architecture Yosys comparison
Project 7.5: OpenLane implementation of resource-shared N=8
Project 7.6: timing push for resource-shared N=8
```

Project 7.1 introduces the scheduled-control concept needed for Project 7.3.

---

## 32. What This Project Is Not

Project 7.1 is not yet the final optimized architecture.

It should not be presented as:

```text
a resource-shared decoder
a lower-area decoder
a final ASIC architecture
a publication-level contribution by itself
```

Instead, it should be presented as:

```text
a functionally verified scheduled RTL baseline
a learning milestone for multi-cycle SC decoding
a bridge between combinational baseline and resource-shared architecture
```

---

## 33. Conclusion

Project 7.1 implements and verifies a scheduled, multi-cycle SC Decoder N=8.

The final simulation result is:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
ALL TESTS PASSED
```

This confirms that the scheduled RTL matches the Python golden model and the combinational N=8 baseline.

The project also reveals an important architectural lesson:

```text
Scheduling the decoder over multiple cycles is not the same as explicitly sharing hardware resources.
```

The next step is Project 7.2:

```text
Yosys comparison — combinational N=8 vs scheduled N=8
```