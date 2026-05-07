# Project 8.4: N=16 Architecture Comparison Using Yosys

## 1. Project Objective

Project 8.4 compares two SC Decoder N=16 RTL architectures using Yosys synthesis metrics.

The compared designs are:

```text
1. Reference/combinational SC Decoder N=16
2. Resource-shared scheduled SC Decoder N=16
```

The main objective is to determine whether the resource-shared scheduled architecture reduces duplicated combinational logic compared with the reference RTL baseline.

---

## 2. Compared Designs

| Design | Role | Source Summary |
|---|---|---|
| `sc_decoder_n16_ref` | Reference N=16 RTL baseline | `results/summary/sc_decoder_n16_ref_yosys_summary.csv` |
| `sc_decoder_n16_shared` | Resource-shared scheduled N=16 RTL | `results/summary/sc_decoder_n16_shared_yosys_summary.csv` |

The reference RTL was developed in Project 8.2 and synthesized in Project 8.2.1.

The resource-shared RTL was developed in Project 8.3 and synthesized in Project 8.3.1.

---

## 3. Functional Verification Context

The resource-shared N=16 RTL passed functional verification with:

```text
Total vector lines read = 1000
Total tests             = 1000
Total errors            = 0
Latency min cycles      = 115
Latency max cycles      = 115
Latency avg cycles      = 115
ALL TESTS PASSED.
```

Therefore, the Yosys comparison is performed between functionally verified N=16 designs.

---

## 4. Main Yosys Comparison Table

| Metric | Reference N=16 | Shared N=16 | Shared / Reference | Reduction From Reference |
|---|---:|---:|---:|---:|
| Wires | 4850 | 2142 | 0.442× | 55.84% |
| Wire bits | 7654 | 3217 | 0.420× | 57.97% |
| Public wires | 435 | 179 | 0.411× | 58.85% |
| Public wire bits | 3239 | 1246 | 0.385× | 61.53% |
| Total cells | 4431 | 2660 | 0.600× | 39.97% |
| Raw DFF/DFFE cells | 0 | 681 | inf | N/A |
| Estimated combinational cells | 4431 | 1979 | 0.447× | 55.34% |
| MUX cells | 326 | 18 | 0.055× | 94.48% |
| XOR cells | 242 | 20 | 0.083× | 91.74% |
| XNOR cells | 393 | 28 | 0.071× | 92.88% |
| XOR + XNOR cells | 635 | 48 | 0.076× | 92.44% |
| NAND cells | 1322 | 840 | 0.635× | 36.46% |
| AND cells | 0 | 894 | inf | N/A |
| OR cells | 0 | 29 | inf | N/A |

---

## 5. Key Metrics For Interpretation

The most important metrics are:

```text
total_cells
dff_dffe_cells_raw
estimated_comb_cells
mux_cells
xor_xnor_cells
nand_cells
latency_cycles
```

The reference design is primarily combinational, while the shared design is sequential and multi-cycle.

Therefore, the most meaningful synthesis-level comparison is not only total cell count, but also estimated combinational cell count after separating DFF/DFFE storage overhead.

---

## 6. Latency Context

The resource-shared N=16 RTL has deterministic latency:

```text
latency_cycles = 115
```

The reference RTL is a combinational/reference baseline. It does not use the same multi-cycle start/busy/done protocol.

Therefore, a final performance comparison must later include:

```text
clock period
latency cycles
effective decode time
area or cell count
area-latency product
```

---

## 7. Interpretation

The Yosys comparison shows that the resource-shared scheduled SC Decoder N=16 significantly reduces the estimated combinational complexity compared with the reference N=16 RTL.

The most important result is:

```text
Estimated combinational cells:
Reference N=16 = 4431
Shared N=16    = 1979
Reduction      = 55.34%
```

This result supports the resource-sharing hypothesis at the synthesis level. Although the shared architecture introduces 681 DFF/DFFE cells for FSM control, LLR storage, partial-sum storage, decoded-bit storage, and output/control registers, the duplicated combinational logic is substantially reduced.

The total cell count also decreases:

```text
Total cells:
Reference N=16 = 4431
Shared N=16    = 2660
Reduction      = 39.97%
```

This is particularly meaningful because the shared design achieves this reduction despite introducing sequential storage.

The interconnect-related metrics also improve:

```text
Wires:
4850 → 2142
Reduction = 55.84%

Wire bits:
7654 → 3217
Reduction = 57.97%
```

This suggests that resource sharing reduces not only arithmetic duplication but also internal wiring complexity.

The largest reductions are observed in MUX and XOR/XNOR cells:

```text
MUX cells:
326 → 18
Reduction = 94.48%

XOR + XNOR cells:
635 → 48
Reduction = 92.44%
```

These reductions are consistent with the expected effect of reusing a shared f/g datapath instead of instantiating a large combinational decoding tree.

However, the shared decoder is multi-cycle. Project 8.3 measured a deterministic latency of:

```text
latency_cycles = 115
```

Therefore, the correct conclusion is not simply that the shared design is faster. The correct conclusion is that the shared architecture reduces synthesis-level combinational complexity and total cell count, at the cost of sequential storage and multi-cycle latency.

A final performance conclusion requires physical implementation and timing analysis through OpenLane, including clock period, critical path, area, and effective decode time.

---

## 8. Academic Interpretation

Project 8.4 provides the first synthesis-level architecture comparison for SC Decoder N=16. It connects the reference RTL baseline and the resource-shared scheduled RTL under the same Yosys-based metric extraction flow.

The correct academic claim should be cautious:

```text
The resource-shared scheduled N=16 decoder has been functionally verified and synthesized. Yosys metrics show how resource sharing changes total cells, sequential storage, and estimated combinational complexity relative to the N=16 reference RTL.
```

Stronger claims about physical area, timing closure, and effective throughput require OpenLane results.

---

## 9. Limitations

This comparison is limited because:

```text
1. It uses generic Yosys cell metrics, not final physical area.
2. It does not include OpenLane placement/routing results yet.
3. It does not include timing closure or critical path after physical implementation.
4. It does not include power or energy estimation.
5. The shared design has multi-cycle latency, so throughput must be evaluated separately.
```

---

## 10. Recommended Next Step

The next logical step is OpenLane physical implementation for both or at least the resource-shared N=16 decoder.

Recommended next project:

```text
Project 8.5: OpenLane Implementation Of Resource-Shared SC Decoder N=16
```

The OpenLane study should measure:

```text
DIEAREA
synth_cell_count
critical_path_ns
suggested_clock_period
DRC violations
LVS result
antenna violations
wire length
via count
```

---

## 11. Generated Files

This report was generated from:

```text
results/summary/sc_decoder_n16_ref_yosys_summary.csv
results/summary/sc_decoder_n16_shared_yosys_summary.csv
```

Generated outputs:

```text
results/summary/sc_decoder_n16_yosys_architecture_comparison.csv
results/summary/sc_decoder_n16_yosys_architecture_comparison.md
docs/project8_4/sc_decoder_n16_architecture_comparison_yosys.md
```

---

## 12. Conclusion

Project 8.4 consolidates the Yosys-level comparison between the N=16 reference RTL and the N=16 resource-shared scheduled RTL.

This comparison is the required synthesis-level evidence before moving to physical implementation. The next stage should validate whether the resource-shared decoder also provides a favorable area/timing trade-off after OpenLane implementation.
