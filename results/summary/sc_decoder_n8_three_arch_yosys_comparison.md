# SC Decoder N=8 Three-Architecture Yosys Comparison

## Summary Table

| Design | Wires | Wire bits | Total cells | DFF/DFFE | Est. comb cells | MUX | XOR/XNOR | NAND |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| combinational_n8 | 1760 | 3279 | 1475 | 0 | 1475 | 101 | 194 | 443 |
| scheduled_n8 | 2449 | 3931 | 2527 | 178 | 2349 | 124 | 233 | 840 |
| resource_shared_n8 | 826 | 1282 | 967 | 199 | 768 | 20 | 24 | 309 |

## Ratios Relative To Combinational Baseline

| Design | Total cells ratio | Est. comb cells ratio | MUX ratio | DFF/DFFE cells |
|---|---:|---:|---:|---:|
| combinational_n8 | 1.00× | 1.00× | 1.00× | 0 |
| scheduled_n8 | 1.71× | 1.59× | 1.23× | 178 |
| resource_shared_n8 | 0.66× | 0.52× | 0.20× | 199 |

## Cell Breakdown

### combinational_n8

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

### scheduled_n8

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

### resource_shared_n8

| Cell type | Count |
|---|---:|
| $_ANDNOT_ | 33 |
| $_AND_ | 259 |
| $_DFFE_PN0N_ | 89 |
| $_DFFE_PN0P_ | 109 |
| $_DFF_PN0_ | 1 |
| $_MUX_ | 20 |
| $_NAND_ | 309 |
| $_NOR_ | 22 |
| $_NOT_ | 12 |
| $_ORNOT_ | 46 |
| $_OR_ | 43 |
| $_XNOR_ | 13 |
| $_XOR_ | 11 |

