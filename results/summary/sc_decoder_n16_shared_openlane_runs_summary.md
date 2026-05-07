# SC Decoder N=16 Resource-Shared OpenLane Run Summary

## 1. Summary

This document summarizes the OpenLane implementation runs for the resource-shared scheduled SC Decoder N=16.

The OpenLane top-level design is:

```text
sc_decoder_n16_shared_top
```

The wrapped RTL core is:

```text
sc_decoder_n16_shared
```

The implementation target is the SkyWater SKY130 standard-cell library through the OpenLane RTL-to-GDSII flow.

The purpose of this summary is to record the OpenLane run history, compare the physical implementation results, identify the best current run, and clarify the remaining limitation before moving to targeted antenna closure.

---

## 2. Context

The resource-shared scheduled SC Decoder N=16 was developed and verified in Project 8.3.

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

Project 8.4 showed that the resource-shared N=16 architecture significantly reduces the estimated combinational complexity compared with the N=16 reference RTL.

The key Yosys comparison result was:

```text
Estimated combinational cells:
Reference N=16 = 4431
Shared N=16    = 1979
Reduction      = 55.34%
```

Project 8.5 then moved the resource-shared decoder into OpenLane physical implementation.

---

## 3. OpenLane Top-Level Design

The OpenLane top module is:

```text
sc_decoder_n16_shared_top
```

This module wraps:

```text
sc_decoder_n16_shared
```

with:

```text
W_IN  = 6
W_INT = 10
```

The top-level ports include:

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

---

## 4. Best Current Run

The best current run is:

```text
RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16
```

This run uses the currently supported OpenLane antenna-related configuration and does not rely on deprecated `DIODE_INSERTION_STRATEGY`.

The corresponding configuration is:

```text
DIE_AREA = 0 0 800 800
FP_CORE_UTIL = 45
PL_TARGET_DENSITY = 0.38
CLOCK_PERIOD = 30 ns
GRT_REPAIR_ANTENNAS = 1
RUN_HEURISTIC_DIODE_INSERTION = 1
DIODE_ON_PORTS = none
```

The key metrics are:

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

## 5. Signoff Status Of Best Current Run

The best current run passes:

```text
routing
Magic DRC
LVS
30 ns timing
```

Specifically:

```text
tritonRoute violations = 0
Magic DRC violations   = 0
LVS total errors       = 0
critical_path_ns       = 10.49 ns
CLOCK_PERIOD           = 30 ns
```

However, it still reports:

```text
pin_antenna_violations = 2
net_antenna_violations = 2
```

Therefore, the best current run is a strong OpenLane physical implementation baseline, but it is not yet a full signoff-clean implementation.

The correct status is:

```text
OpenLane physical baseline completed.
Antenna signoff closure remains incomplete.
```

---

## 6. Run Comparison Table

| Run | DIEAREA mm² | Magic DRC | LVS | Routing | Antenna Pin/Net | Wire Length | Vias | Critical Path | Assessment |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `RUN_2026.05.04_16.42.44` | 1.00 | 0 | 0 | 0 | 3 / 3 | 284317 | 37632 | 10.55 ns | Valid baseline, sparse layout |
| `RUN_2026.05.04_n16_shared_30ns_antenna_fix` | 1.00 | 0 | 0 | 0 | 6 / 6 | 296321 | 37854 | 10.76 ns | Worse antenna |
| `RUN_2026.05.04_n16_shared_30ns_ant_v2` | 1.00 | 0 | 0 | 0 | 3 / 3 | 284317 | 37632 | 10.55 ns | Same as baseline |
| `RUN_2026.05.04_n16_shared_30ns_compact_v4` | 0.49 | 0 | 0 | 0 | 3 / 3 | 243130 | 37694 | 10.45 ns | Best area, antenna still 3/3 |
| `RUN_2026.05.04_n16_shared_30ns_compact_v5` | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | Strong baseline |
| `RUN_2026.05.04_n16_shared_30ns_compact_v7` | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | Strong baseline |
| `RUN_2026.05.04_n16_shared_30ns_fanout5_v8` | 0.64 | 0 | 0 | 0 | 2 / 2 | 275433 | 38139 | 10.79 ns | Worse wire/timing/cell count |
| `RUN_2026.05.04_n16_shared_30ns_diode2_v9` | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | Strong baseline |
| `RUN_2026.05.04_n16_shared_30ns_diode4_v10` | 0.64 | 0 | 0 | 0 | 3 / 3 | 258199 | 37284 | 10.58 ns | Worse antenna |
| `RUN_2026.05.04_n16_shared_30ns_supported_ant_900_v14b` | 0.81 | 0 | 0 | 0 | 6 / 6 | 286970 | 37491 | 10.61 ns | Larger die, worse antenna |
| `RUN_2026.05.04_n16_shared_30ns_supported_ant_900_none_v15` | 0.81 | 0 | 0 | 0 | 5 / 5 | 286882 | 37449 | 10.62 ns | Larger die, worse antenna |
| `RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16` | 0.64 | 0 | 0 | 0 | 2 / 2 | 258186 | 37181 | 10.49 ns | Best current supported baseline |

---

## 7. Ranking Of Runs

### 7.1 Rank 1: Best Physical Baseline

```text
RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16
```

Reasons:

```text
uses supported OpenLane antenna configuration
does not rely on deprecated DIODE_INSERTION_STRATEGY
flow completed
routing clean
Magic DRC clean
LVS clean
timing passes at 30 ns
antenna reduced to the current minimum of 2 / 2
DIEAREA = 0.64 mm²
critical_path_ns = 10.49 ns
```

This is the best run to use as the Project 8.5 physical implementation baseline.

---

### 7.2 Rank 2: Best Area-Oriented Run

```text
RUN_2026.05.04_n16_shared_30ns_compact_v4
```

Reasons:

```text
DIEAREA = 0.49 mm²
wire_length = 243130
critical_path_ns = 10.45 ns
```

Limitation:

```text
antenna remains 3 / 3
```

This run is useful as an area-oriented reference, but it is not the best overall physical baseline because antenna closure is worse than in the 800 × 800 runs.

---

### 7.3 Rank 3: Strong Deprecated-Configuration Baselines

```text
RUN_2026.05.04_n16_shared_30ns_compact_v7
RUN_2026.05.04_n16_shared_30ns_diode2_v9
```

Reasons:

```text
DIEAREA = 0.64 mm²
critical_path_ns = 10.49 ns
antenna = 2 / 2
routing clean
Magic DRC clean
LVS clean
timing pass at 30 ns
```

Limitation:

```text
some previous run variants used deprecated diode-related configuration fields
```

These runs are technically strong, but `supported_ant_800_none_v16` is preferred because it uses the currently supported OpenLane configuration style.

---

### 7.4 Not Recommended Runs

```text
RUN_2026.05.04_n16_shared_30ns_antenna_fix
RUN_2026.05.04_n16_shared_30ns_fanout5_v8
RUN_2026.05.04_n16_shared_30ns_diode4_v10
RUN_2026.05.04_n16_shared_30ns_supported_ant_900_v14b
RUN_2026.05.04_n16_shared_30ns_supported_ant_900_none_v15
```

Reasons:

```text
no antenna improvement
or worse antenna result
or larger die area
or increased wire length
or degraded timing
or increased cell/routing cost
```

---

## 8. Interpretation Of Floorplan Experiments

The OpenLane results show that the best physical operating region is:

```text
DIE_AREA = 0 0 800 800
FP_CORE_UTIL = 45
PL_TARGET_DENSITY = 0.38
```

The `1000 × 1000` runs are too sparse and show larger wire length and more antenna violations.

The `900 × 900` runs also do not improve antenna. They increase wire length and antenna violations.

The `700 × 700` run gives the smallest die area and shortest wire length, but it does not reduce antenna below `3 / 3`.

The `800 × 800` region provides the best balance:

```text
DIEAREA = 0.64 mm²
critical_path_ns = 10.49 ns
antenna = 2 / 2
routing clean
DRC clean
LVS clean
```

---

## 9. Interpretation Of Fanout Experiment

The run:

```text
RUN_2026.05.04_n16_shared_30ns_fanout5_v8
```

uses a reduced fanout constraint:

```text
MAX_FANOUT_CONSTRAINT = 5
```

However, it does not reduce antenna violations.

It keeps:

```text
antenna = 2 / 2
```

but worsens:

```text
synth_cell_count
wire_length
vias
critical_path_ns
```

Therefore, reducing the fanout constraint is not beneficial for the current implementation.

The best baseline keeps:

```text
MAX_FANOUT_CONSTRAINT = 10
```

---

## 10. Interpretation Of Diode / Antenna Repair Experiments

The current OpenLane version no longer supports some older `DIODE_INSERTION_STRATEGY` values.

The flow reports:

```text
DIODE_INSERTION_STRATEGY is now deprecated.
```

The supported configuration approach uses:

```text
GRT_REPAIR_ANTENNAS = 1
RUN_HEURISTIC_DIODE_INSERTION = 1
DIODE_ON_PORTS = none / in / out / both
```

The best supported result so far uses:

```text
DIODE_ON_PORTS = none
```

Adding port diode protection through:

```text
DIODE_ON_PORTS = both
```

worsens antenna in this design because the remaining violations appear to be internal-net related rather than top-level port related.

Therefore, the supported best configuration is:

```text
GRT_REPAIR_ANTENNAS = 1
RUN_HEURISTIC_DIODE_INSERTION = 1
DIODE_ON_PORTS = none
```

---

## 11. Main Technical Conclusion

The resource-shared scheduled SC Decoder N=16 is physically implementable with OpenLane.

The best current physical baseline achieves:

```text
flow completed
routing violations = 0
Magic DRC violations = 0
LVS total errors = 0
critical_path_ns = 10.49 ns
CLOCK_PERIOD = 30 ns
DIEAREA = 0.64 mm²
```

However, antenna signoff is not yet clean:

```text
pin_antenna_violations = 2
net_antenna_violations = 2
```

Therefore, the correct conclusion is:

```text
Project 8.5 successfully establishes an OpenLane physical implementation baseline, but full signoff-clean closure requires further antenna repair.
```

---

## 12. Why Project 8.5 Should Be Closed As Baseline

Project 8.5 has achieved the main physical implementation goals except antenna closure.

It has shown that the design can:

```text
enter OpenLane
synthesize
place
route
generate GDSII
pass routing checks
pass Magic DRC
pass LVS
meet the 30 ns timing constraint
```

The remaining problem is local antenna closure, which should be treated as a specialized follow-up task.

Therefore, Project 8.5 should be closed as:

```text
OpenLane physical implementation baseline completed
```

and not as:

```text
final signoff-clean implementation completed
```

---

## 13. Recommended Next Step

The recommended next project is:

```text
Project 8.5.1: Targeted Antenna Closure For Resource-Shared SC Decoder N=16
```

The next project should focus on:

```text
extracting the remaining antenna violator nets
checking whether the same nets persist across runs
identifying whether they are internal synthesized nets
investigating targeted antenna ECO or manual diode insertion
attempting to reduce antenna violations from 2 / 2 to 0 / 0
```

---

## 14. Final Statement

The best current OpenLane run is:

```text
RUN_2026.05.04_n16_shared_30ns_supported_ant_800_none_v16
```

It is the best physical implementation baseline because it uses supported OpenLane settings and achieves the strongest overall result:

```text
DIEAREA = 0.64 mm²
critical_path_ns = 10.49 ns
routing violations = 0
Magic DRC violations = 0
LVS total errors = 0
antenna violations = 2 pin / 2 net
```

This run should be used as the baseline input for Project 8.5.1.