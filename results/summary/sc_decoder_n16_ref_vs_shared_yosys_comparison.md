# SC Decoder N=16: Reference RTL vs Resource-Shared RTL Yosys Comparison

## 1. Compared Designs

| Design | Source |
|---|---|
| Reference N=16 RTL | `results/summary/sc_decoder_n16_ref_yosys_summary.csv` |
| Resource-shared N=16 RTL | `results/summary/sc_decoder_n16_shared_yosys_summary.csv` |

## 2. Main Comparison Table

| Metric | Reference N=16 | Shared N=16 | Shared / Reference | Reduction From Reference |
|---|---:|---:|---:|---:|
| wires | 4850 | 2142 | 0.442x | 55.84% |
| wire_bits | 7654 | 3217 | 0.420x | 57.97% |
| public_wires | 435 | 179 | 0.411x | 58.85% |
| public_wire_bits | 3239 | 1246 | 0.385x | 61.53% |
| total_cells | 4431 | 2660 | 0.600x | 39.97% |
| dff_dffe_cells_raw | 0 | 681 | inf | N/A |
| estimated_comb_cells | 4431 | 1979 | 0.447x | 55.34% |
| mux_cells | 326 | 18 | 0.055x | 94.48% |
| xor_cells | 242 | 20 | 0.083x | 91.74% |
| xnor_cells | 393 | 28 | 0.071x | 92.88% |
| xor_xnor_cells | 635 | 48 | 0.076x | 92.44% |
| nand_cells | 1322 | 840 | 0.635x | 36.46% |

## 3. Latency Context

The resource-shared N=16 RTL passed functional verification with deterministic latency:

```text
latency_cycles = 115
```

The reference RTL is combinational, while the shared RTL is sequential and multi-cycle. Therefore, total cell count alone is not sufficient. The comparison should consider:

```text
total cells
DFF/DFFE cells
estimated combinational cells
latency cycles
future clock period after OpenLane
effective decode time
```

## 4. Interpretation Guideline

If the shared design reduces estimated combinational cells, it supports the resource-sharing hypothesis. If total cells are not reduced, this may still be acceptable because the shared design introduces registers and FSM logic. A final conclusion requires latency-aware and physical-design-aware comparison.
