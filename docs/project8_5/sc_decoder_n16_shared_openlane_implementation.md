# Project 8.5: OpenLane Implementation Of Resource-Shared SC Decoder N=16

## 1. Project Objective

Project 8.5 performs OpenLane physical implementation for the resource-shared scheduled SC Decoder N=16.

The target OpenLane top-level design is:

```text
sc_decoder_n16_shared_top
```

The wrapped RTL core is:

```text
rtl/sc_decoder_n16_shared.v
```

The top wrapper is:

```text
rtl/sc_decoder_n16_shared_top.v
```

The main objective is to validate whether the functionally verified and Yosys-characterized resource-shared SC Decoder N=16 can pass the open-source RTL-to-GDSII physical design flow.

The expected OpenLane outputs include:

```text
GDSII
Magic DRC report
LVS report
antenna report
timing metrics
area metrics
routing metrics
```

---

## 2. Background

Project 8.3 verified the resource-shared scheduled SC Decoder N=16 against Python-generated golden vectors.

The functional verification result was:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
Latency min cycles      = 115
Latency max cycles      = 115
Latency avg cycles      = 115
ALL TESTS PASSED.
```

This confirms that the multi-cycle resource-shared RTL produces the same decoded output as the Python golden model from Project 8.1.

Project 8.4 compared the N=16 reference RTL and the N=16 resource-shared scheduled RTL using Yosys synthesis metrics.

The key synthesis-level result was:

```text
Estimated combinational cells:
Reference N=16 = 4431
Shared N=16    = 1979
Reduction      = 55.34%
```

The total cell count was also reduced:

```text
Total cells:
Reference N=16 = 4431
Shared N=16    = 2660
Reduction      = 39.97%
```

Therefore, Project 8.5 moves the resource-shared scheduled N=16 architecture from functional RTL and Yosys synthesis into physical implementation using OpenLane.

---

## 3. Role Of Project 8.5 In The Roadmap

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

Project 8.3.1:
    Yosys synthesis study for SC Decoder N=16 resource-shared RTL.

Project 8.4:
    N=16 architecture comparison using Yosys.

Project 8.5:
    OpenLane physical implementation of resource-shared SC Decoder N=16.

Project 8.5.1:
    Targeted antenna closure for resource-shared SC Decoder N=16.
```

Project 8.5 is the first RTL-to-GDSII physical implementation step for the N=16 resource-shared decoder.

---

## 4. OpenLane Design Package

The reproducible OpenLane design package is stored in the repository at:

```text
openlane_designs/sc_decoder_n16_shared_top/
```

The expected folder structure is:

```text
openlane_designs/sc_decoder_n16_shared_top/
├── config.json
└── src/
    ├── sc_decoder_n16_shared.v
    └── sc_decoder_n16_shared_top.v
```

For actual OpenLane execution using the current working setup, this package should be copied to:

```text
~/OpenLane/designs/sc_decoder_n16_shared_top/
```

The actual run command is executed from:

```text
~/OpenLane
```

using:

```bash
make mount
```

Inside the OpenLane container, the flow is launched by:

```bash
./flow.tcl -design sc_decoder_n16_shared_top
```

---

## 5. Top-Level Module

The OpenLane top-level module is:

```text
sc_decoder_n16_shared_top
```

This wrapper instantiates:

```text
sc_decoder_n16_shared
```

with the parameters:

```text
W_IN  = 6
W_INT = 10
```

The top-level interface contains:

```text
clk
rst_n
start
llr0 ... llr15
frozen_mask
u_hat
busy
done
```

The wrapper is used to expose a clean ASIC implementation interface for the generated resource-shared decoder core.

---

## 6. Preserved Design Conventions

Project 8.5 preserves the same conventions used in Projects 8.1, 8.2, and 8.3.

### 6.1 LLR Width

```text
Input LLR width     = 6 bits
Internal LLR width  = 10 bits
```

The input LLRs are sign-extended to 10-bit internal values.

### 6.2 Frozen-Mask Convention

```text
frozen_mask[i] = 1 → u_i is frozen and forced to 0
frozen_mask[i] = 0 → u_i is an information bit
```

### 6.3 Hard-Decision Convention

```text
LLR < 0  → decoded bit = 1
LLR >= 0 → decoded bit = 0
```

### 6.4 Bit-Ordering Convention

```text
u_hat[0]  = u0
u_hat[1]  = u1
...
u_hat[15] = u15
```

The output is packed LSB-first.

### 6.5 g-Function Convention

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

---

## 7. Best Current OpenLane Configuration

The best current baseline uses the supported OpenLane antenna-related configuration without deprecated `DIODE_INSERTION_STRATEGY`.

The best configuration is:

```json
{
    "DESIGN_NAME": "sc_decoder_n16_shared_top",

    "VERILOG_FILES": "dir::src/*.v",

    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": 30,

    "FP_SIZING": "absolute",
    "DIE_AREA": "0 0 800 800",

    "FP_ASPECT_RATIO": 1,
    "FP_CORE_UTIL": 45,
    "PL_TARGET_DENSITY": 0.38,

    "SYNTH_STRATEGY": "AREA 0",
    "MAX_FANOUT_CONSTRAINT": 10,

    "GRT_ADJUSTMENT": 0.3,
    "GRT_REPAIR_ANTENNAS": 1,
    "RUN_HEURISTIC_DIODE_INSERTION": 1,
    "DIODE_ON_PORTS": "none",

    "FP_PDN_HPITCH": 153.18,
    "FP_PDN_VPITCH": 153.6
}
```

This corresponds to the run:

```text
RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16
```

This configuration is preferred because it uses the currently supported OpenLane antenna-related settings:

```text
GRT_REPAIR_ANTENNAS = 1
RUN_HEURISTIC_DIODE_INSERTION = 1
DIODE_ON_PORTS = none
```

and avoids the deprecated setting:

```text
DIODE_INSERTION_STRATEGY
```

---

## 8. Best Current Physical Baseline

The best current run is:

```text
RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16
```

The key OpenLane metrics are:

| Metric | Value |
|---|---:|
| Flow status | flow completed |
| DIEAREA | 0.64 mm² |
| FP_CORE_UTIL | 45 |
| PL_TARGET_DENSITY | 0.38 |
| synth_cell_count | 3577 |
| TotalCells | 68940 |
| CoreArea | 613701.088 µm² |
| tritonRoute violations | 0 |
| Magic DRC violations | 0 |
| LVS total errors | 0 |
| Pin antenna violations | 2 |
| Net antenna violations | 2 |
| wire_length | 258186 |
| vias | 37181 |
| critical_path_ns | 10.49 ns |
| CLOCK_PERIOD | 30 ns |
| suggested_clock_period | 30 ns |
| suggested_clock_frequency | 33.33 MHz |

---

## 9. Signoff Status

The current best run achieves:

```text
Routing violations = 0
Magic DRC violations = 0
LVS total errors = 0
Timing passes at 30 ns
```

However, the run still reports:

```text
Pin antenna violations = 2
Net antenna violations = 2
```

Therefore, Project 8.5 should be classified as:

```text
OpenLane physical implementation baseline completed
```

not:

```text
signoff-clean implementation completed
```

The correct current status is:

```text
Physical implementation feasible, but antenna closure remains incomplete.
```

---

## 10. Run History

Several OpenLane configurations were tested.

| Run | DIEAREA mm² | DRC | LVS | Routing | Antenna Pin/Net | Wire Length | Vias | Critical Path | Assessment |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| RUN_2026.05.04_16.42.44 | 1.00 | 0 | 0 | 0 | 3 / 3 | 284317 | 37632 | 10.55 ns | valid baseline, too sparse |
| RUN_2026.05.04_n16_shared_30ns_antenna_fix | 1.00 | 0 | 0 | 0 | 6 / 6 | 296321 | 37854 | 10.76 ns | worse antenna |
| RUN_2026.05.04_n16_shared_30ns_ant_v2 | 1.00 | 0 | 0 | 0 | 3 / 3 | 284317 | 37632 | 10.55 ns | same as baseline |
| RUN_2026.05.04_n16_shared_30ns_compact_v4 | 0.49 | 0 | 0 | 0 | 3 / 3 | 243130 | 37694 | 10.45 ns | best area, antenna not improved |
| RUN_2026.05.04_n16_shared_30ns_compact_v5 | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | strong baseline |
| RUN_2026.05.04_n16_shared_30ns_compact_v7 | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | strong baseline |
| RUN_2026.05.04_n16_shared_30ns_fanout5_v8 | 0.64 | 0 | 0 | 0 | 2 / 2 | 275433 | 38139 | 10.79 ns | worse than compact baseline |
| RUN_2026.05.04_n16_shared_30ns_diode2_v9 | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | strong baseline |
| RUN_2026.05.04_n16_shared_30ns_diode4_v10 | 0.64 | 0 | 0 | 0 | 3 / 3 | 258199 | 37284 | 10.58 ns | worse antenna |
| RUN_2026.05.04_n16_shared_30ns_supported_ant_900_v14b | 0.81 | 0 | 0 | 0 | 6 / 6 | 286970 | 37491 | 10.61 ns | larger die, worse antenna |
| RUN_2026.05.04_n16_shared_30ns_supported_ant_900_none_v15 | 0.81 | 0 | 0 | 0 | 5 / 5 | 286882 | 37449 | 10.62 ns | larger die, worse antenna |
| RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16 | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | best current supported baseline |

---

## 11. Interpretation Of Configuration Experiments

The experiments show that the best physical region is around:

```text
DIE_AREA = 0 0 800 800
FP_CORE_UTIL = 45
PL_TARGET_DENSITY = 0.38
```

Larger, sparser layouts such as `900 × 900` or `1000 × 1000` do not improve antenna closure. In fact, they increase wire length and antenna violations.

The compact `700 × 700` run reduces die area and wire length, but antenna remains at:

```text
3 pin / 3 net violations
```

The `800 × 800` configuration reduces antenna to:

```text
2 pin / 2 net violations
```

while keeping routing, DRC, LVS, and timing clean.

Lowering `MAX_FANOUT_CONSTRAINT` to 5 does not improve antenna closure and increases:

```text
cell count
wire length
via count
critical path
```

Deprecated `DIODE_INSERTION_STRATEGY` values should not be used in the current OpenLane version. The current supported configuration uses:

```text
GRT_REPAIR_ANTENNAS = 1
RUN_HEURISTIC_DIODE_INSERTION = 1
DIODE_ON_PORTS = none
```

---

## 12. Why The Best Run Is Not Yet Signoff-Clean

The best run is not yet signoff-clean because it still reports:

```text
pin_antenna_violations = 2
net_antenna_violations = 2
```

The fact that multiple global configuration changes could not reduce the violations below `2 / 2` suggests that the remaining antenna problem is local and net-specific.

The remaining issue is likely associated with internal synthesized nets rather than a global floorplan problem.

Therefore, further work should focus on targeted antenna closure rather than additional random global configuration sweeps.

---

## 13. Academic Interpretation

Project 8.5 demonstrates that the resource-shared scheduled SC Decoder N=16 is physically implementable using the OpenLane RTL-to-GDSII flow.

The design successfully completes the OpenLane flow and passes:

```text
routing
Magic DRC
LVS
30 ns timing
```

The achieved critical path is:

```text
critical_path_ns = 10.49 ns
```

under:

```text
CLOCK_PERIOD = 30 ns
```

The current best die area is:

```text
DIEAREA = 0.64 mm²
```

However, antenna closure has not yet been achieved because the best run still reports:

```text
2 pin antenna violations
2 net antenna violations
```

Therefore, the correct academic statement is:

```text
The resource-shared scheduled SC Decoder N=16 has been functionally verified, synthesized, and physically implemented using OpenLane. The implementation passes routing, Magic DRC, LVS, and 30 ns timing, but remains not fully signoff-clean due to 2 remaining antenna violations.
```

A stronger claim such as:

```text
signoff-clean RTL-to-GDSII implementation
```

should only be made after:

```text
pin_antenna_violations = 0
net_antenna_violations = 0
```

---

## 14. Current Limitation

The current limitation is local antenna closure.

The automatic OpenLane configuration-based antenna repair is stuck at:

```text
2 pin antenna violations
2 net antenna violations
```

The remaining antenna violations are likely local internal-net violations rather than global floorplan problems.

This conclusion is supported by the fact that multiple global configuration changes did not reduce the violations below `2 / 2`.

---

## 15. Recommended Next Step

The next project should be:

```text
Project 8.5.1: Targeted Antenna Closure For Resource-Shared SC Decoder N=16
```

The goal of Project 8.5.1 is:

```text
1. Extract the remaining antenna violator nets.
2. Compare violator nets across the best runs.
3. Identify whether the violations are persistent internal nets.
4. Apply targeted antenna ECO/manual diode/buffer repair if possible.
5. Achieve antenna signoff clean: 0 pin / 0 net violations.
```

The first diagnostic commands for Project 8.5.1 should be:

```bash
RUN_DIR=~/OpenLane/designs/sc_decoder_n16_shared_top/runs/RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16

cat "$RUN_DIR/reports/signoff/45-antenna_violators_pins.txt"
cat "$RUN_DIR/reports/signoff/45-antenna_violators.rpt"
```

---

## 16. Project 8.5 Conclusion

Project 8.5 establishes the OpenLane physical implementation baseline for the resource-shared scheduled SC Decoder N=16.

The best current physical baseline is:

```text
RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16
```

This run achieves:

```text
flow completed
routing violations = 0
Magic DRC violations = 0
LVS total errors = 0
critical_path_ns = 10.49 ns
CLOCK_PERIOD = 30 ns
DIEAREA = 0.64 mm²
```

but still reports:

```text
pin_antenna_violations = 2
net_antenna_violations = 2
```

Therefore, Project 8.5 should be considered completed as a physical implementation baseline, while antenna signoff closure should be continued in Project 8.5.1.