# SC Decoder N=8: Combinational vs Scheduled Yosys Comparison

| Design | Wires | Wire bits | Total cells | DFF cells | Estimated comb cells | MUX cells | XOR/XNOR cells |
|---|---:|---:|---:|---:|---:|---:|---:|
| sc_decoder_n8_comb | 1760 | 3279 | 1475 | 0 | 1475 | 101 | 194 |
| sc_decoder_n8_scheduled | 2449 | 3931 | 2527 | 178 | 2349 | 124 | 233 |

## Ratios: Scheduled / Combinational

| Metric | Ratio |
|---|---:|
| Wires | 1.39x |
| Wire bits | 1.20x |
| Total cells | 1.71x |
| Estimated comb cells | 1.59x |
| MUX cells | 1.23x |
| XOR/XNOR cells | 1.20x |

[OK] Wrote CSV summary to /home/lucero/ic_design_projects/fixed_point_arithmetic_asic_ready/results/summary/sc_decoder_n8_comb_vs_scheduled_yosys_comparison.csv

## Cell Breakdown

### sc_decoder_n8_comb
| Cell type | Count |
|---|---:|
| $_ANDNOT_ | 87 |
| $_AND_ | 236 |
| $_MUX_ | 101 |
| $_NAND_ | 443 |
| $_NOR_ | 43 |
| $_NOT_ | 12 |
| $_ORNOT_ | 212 |
| $_OR_ | 147 |
| $_XNOR_ | 133 |
| $_XOR_ | 61 |

### sc_decoder_n8_scheduled
| Cell type | Count |
|---|---:|
| $_ANDNOT_ | 112 |
| $_AND_ | 409 |
| $_DFFE_PN0N_ | 40 |
| $_DFFE_PN0P_ | 137 |
| $_DFF_PN0_ | 1 |
| $_MUX_ | 124 |
| $_NAND_ | 840 |
| $_NOR_ | 41 |
| $_NOT_ | 15 |
| $_ORNOT_ | 377 |
| $_OR_ | 198 |
| $_XNOR_ | 130 |
| $_XOR_ | 103 |

