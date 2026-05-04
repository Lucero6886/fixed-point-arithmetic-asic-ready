# SC Decoder N=16 Reference RTL Yosys Summary

## 1. Main Metrics

| Metric | Value |
|---|---:|
| Design | sc_decoder_n16_ref |
| Wires | 4850 |
| Wire bits | 7654 |
| Public wires | 435 |
| Public wire bits | 3239 |
| Memories | 0 |
| Memory bits | 0 |
| Processes | 0 |
| Total cells | 4431 |
| Raw DFF/DFFE cells | 0 |
| Estimated combinational cells | 4431 |
| MUX cells | 326 |
| XOR cells | 242 |
| XNOR cells | 393 |
| XOR + XNOR cells | 635 |
| NAND cells | 1322 |

## 2. Cell Breakdown

| Cell type | Count |
|---|---:|
| `$_ANDNOT_` | 266 |
| `$_AND_` | 777 |
| `$_MUX_` | 326 |
| `$_NAND_` | 1322 |
| `$_NOR_` | 93 |
| `$_NOT_` | 54 |
| `$_ORNOT_` | 569 |
| `$_OR_` | 389 |
| `$_XNOR_` | 393 |
| `$_XOR_` | 242 |

## 3. Interpretation

This synthesis result is the reference N=16 RTL baseline. It is intended for correctness and future architecture comparison, not as an optimized resource-shared implementation.

The key number to compare later is the total cell count and estimated combinational cell count against the future resource-shared N=16 decoder.
