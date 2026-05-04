#!/usr/bin/env python3
"""
Compare Yosys summaries:
- SC Decoder N=16 reference RTL
- SC Decoder N=16 resource-shared scheduled RTL

Output:
- results/summary/sc_decoder_n16_ref_vs_shared_yosys_comparison.csv
- results/summary/sc_decoder_n16_ref_vs_shared_yosys_comparison.md
"""

from __future__ import annotations

import csv
from pathlib import Path


REF_CSV = Path("results/summary/sc_decoder_n16_ref_yosys_summary.csv")
SHARED_CSV = Path("results/summary/sc_decoder_n16_shared_yosys_summary.csv")

OUT_CSV = Path("results/summary/sc_decoder_n16_ref_vs_shared_yosys_comparison.csv")
OUT_MD = Path("results/summary/sc_decoder_n16_ref_vs_shared_yosys_comparison.md")


METRICS = [
    "wires",
    "wire_bits",
    "public_wires",
    "public_wire_bits",
    "total_cells",
    "dff_dffe_cells_raw",
    "estimated_comb_cells",
    "mux_cells",
    "xor_cells",
    "xnor_cells",
    "xor_xnor_cells",
    "nand_cells",
]


def read_single_row(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(f"Missing file: {path}")

    with path.open("r", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    if len(rows) != 1:
        raise RuntimeError(f"Expected exactly one row in {path}, got {len(rows)}")

    row = rows[0]

    out = {}
    for k, v in row.items():
        if k == "design":
            out[k] = v
        else:
            try:
                out[k] = int(v)
            except ValueError:
                out[k] = v

    return out


def ratio(shared: int, ref: int) -> str:
    if ref == 0:
        if shared == 0:
            return "N/A"
        return "inf"
    return f"{shared / ref:.3f}x"


def reduction(shared: int, ref: int) -> str:
    if ref == 0:
        return "N/A"
    value = (1.0 - shared / ref) * 100.0
    return f"{value:.2f}%"


def main() -> None:
    ref = read_single_row(REF_CSV)
    shared = read_single_row(SHARED_CSV)

    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)

    rows = []
    for metric in METRICS:
        ref_value = int(ref.get(metric, 0))
        shared_value = int(shared.get(metric, 0))

        rows.append({
            "metric": metric,
            "reference_n16": ref_value,
            "shared_n16": shared_value,
            "shared_over_reference_ratio": ratio(shared_value, ref_value),
            "reduction_from_reference": reduction(shared_value, ref_value),
        })

    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "metric",
                "reference_n16",
                "shared_n16",
                "shared_over_reference_ratio",
                "reduction_from_reference",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    with OUT_MD.open("w", encoding="utf-8") as f:
        f.write("# SC Decoder N=16: Reference RTL vs Resource-Shared RTL Yosys Comparison\n\n")

        f.write("## 1. Compared Designs\n\n")
        f.write("| Design | Source |\n")
        f.write("|---|---|\n")
        f.write(f"| Reference N=16 RTL | `{REF_CSV}` |\n")
        f.write(f"| Resource-shared N=16 RTL | `{SHARED_CSV}` |\n\n")

        f.write("## 2. Main Comparison Table\n\n")
        f.write("| Metric | Reference N=16 | Shared N=16 | Shared / Reference | Reduction From Reference |\n")
        f.write("|---|---:|---:|---:|---:|\n")

        for r in rows:
            f.write(
                f"| {r['metric']} | {r['reference_n16']} | {r['shared_n16']} | "
                f"{r['shared_over_reference_ratio']} | {r['reduction_from_reference']} |\n"
            )

        f.write("\n## 3. Latency Context\n\n")
        f.write("The resource-shared N=16 RTL passed functional verification with deterministic latency:\n\n")
        f.write("```text\n")
        f.write("latency_cycles = 115\n")
        f.write("```\n\n")

        f.write("The reference RTL is combinational, while the shared RTL is sequential and multi-cycle. ")
        f.write("Therefore, total cell count alone is not sufficient. The comparison should consider:\n\n")
        f.write("```text\n")
        f.write("total cells\n")
        f.write("DFF/DFFE cells\n")
        f.write("estimated combinational cells\n")
        f.write("latency cycles\n")
        f.write("future clock period after OpenLane\n")
        f.write("effective decode time\n")
        f.write("```\n\n")

        f.write("## 4. Interpretation Guideline\n\n")
        f.write("If the shared design reduces estimated combinational cells, it supports the resource-sharing hypothesis. ")
        f.write("If total cells are not reduced, this may still be acceptable because the shared design introduces registers and FSM logic. ")
        f.write("A final conclusion requires latency-aware and physical-design-aware comparison.\n")

    print(f"[OK] Wrote CSV comparison: {OUT_CSV}")
    print(f"[OK] Wrote Markdown comparison: {OUT_MD}")


if __name__ == "__main__":
    main()