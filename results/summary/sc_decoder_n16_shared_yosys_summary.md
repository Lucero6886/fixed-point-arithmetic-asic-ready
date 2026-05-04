# SC Decoder N=16 Resource-Shared RTL Yosys Summary

## 1. Main Metrics

| Metric | Value |
|---|---:|
| Design | sc_decoder_n16_shared |
| Wires | 2142 |
| Wire bits | 3217 |
| Public wires | 179 |
| Public wire bits | 1246 |
| Memories | 0 |
| Memory bits | 0 |
| Processes | 0 |
| Total cells | 2660 |
| Raw DFF/DFFE cells | 681 |
| Estimated combinational cells | 1979 |
| MUX cells | 18 |
| XOR cells | 20 |
| XNOR cells | 28 |
| XOR + XNOR cells | 48 |
| NAND cells | 840 |
| AND cells | 894 |
| OR cells | 29 |

## 2. Cell Breakdown

| Cell type | Count |
|---|---:|
| `$_ANDNOT_` | 76 |
| `$_AND_` | 894 |
| `$_DFFE_PN0N_` | 657 |
| `$_DFFE_PN0P_` | 23 |
| `$_DFF_PN0_` | 1 |
| `$_MUX_` | 18 |
| `$_NAND_` | 840 |
| `$_NOR_` | 33 |
| `$_NOT_` | 11 |
| `$_ORNOT_` | 30 |
| `$_OR_` | 29 |
| `$_XNOR_` | 28 |
| `$_XOR_` | 20 |

## 3. Interpretation

This synthesis result is for the multi-cycle resource-shared SC Decoder N=16. Unlike the reference combinational RTL, this design is expected to contain sequential cells because it uses FSM state registers, internal LLR registers, decoded-bit registers, partial-sum registers, and output/control registers.

The most important future comparison is against the N=16 reference RTL baseline. In particular, compare total cells, DFF/DFFE cells, estimated combinational cells, MUX cells, XOR/XNOR cells, NAND cells, and measured latency cycles.
