#!/usr/bin/env python3
"""
Project 8.4:
Generate N=16 architecture comparison report using Yosys summaries.

Inputs:
    results/summary/sc_decoder_n16_ref_yosys_summary.csv
    results/summary/sc_decoder_n16_shared_yosys_summary.csv

Outputs:
    results/summary/sc_decoder_n16_yosys_architecture_comparison.csv
    results/summary/sc_decoder_n16_yosys_architecture_comparison.md
    docs/project8_4/sc_decoder_n16_architecture_comparison_yosys.md
"""

from __future__ import annotations

import csv
from pathlib import Path


REF_CSV = Path("results/summary/sc_decoder_n16_ref_yosys_summary.csv")
SHARED_CSV = Path("results/summary/sc_decoder_n16_shared_yosys_summary.csv")

OUT_CSV = Path("results/summary/sc_decoder_n16_yosys_architecture_comparison.csv")
OUT_SUMMARY_MD = Path("results/summary/sc_decoder_n16_yosys_architecture_comparison.md")
OUT_DOC_MD = Path("docs/project8_4/sc_decoder_n16_architecture_comparison_yosys.md")

SHARED_LATENCY_CYCLES = 115

METRICS = [
    ("wires", "Wires"),
    ("wire_bits", "Wire bits"),
    ("public_wires", "Public wires"),
    ("public_wire_bits", "Public wire bits"),
    ("total_cells", "Total cells"),
    ("dff_dffe_cells_raw", "Raw DFF/DFFE cells"),
    ("estimated_comb_cells", "Estimated combinational cells"),
    ("mux_cells", "MUX cells"),
    ("xor_cells", "XOR cells"),
    ("xnor_cells", "XNOR cells"),
    ("xor_xnor_cells", "XOR + XNOR cells"),
    ("nand_cells", "NAND cells"),
    ("and_cells", "AND cells"),
    ("or_cells", "OR cells"),
]


def read_single_row(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(
            f"Missing required file: {path}\n"
            "Run the corresponding Yosys project first."
        )

    with path.open("r", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    if len(rows) != 1:
        raise RuntimeError(f"Expected exactly one row in {path}, got {len(rows)}")

    row = rows[0]
    out = {}

    for key, value in row.items():
        if key == "design":
            out[key] = value
        else:
            try:
                out[key] = int(value)
            except (TypeError, ValueError):
                out[key] = 0

    return out


def safe_ratio(shared: int, ref: int) -> str:
    if ref == 0:
        if shared == 0:
            return "N/A"
        return "inf"
    return f"{shared / ref:.3f}×"


def safe_reduction(shared: int, ref: int) -> str:
    if ref == 0:
        return "N/A"
    return f"{(1.0 - shared / ref) * 100.0:.2f}%"


def numeric_ratio(shared: int, ref: int):
    if ref == 0:
        return None
    return shared / ref


def make_rows(ref: dict, shared: dict) -> list[dict]:
    rows = []

    for key, label in METRICS:
        ref_value = int(ref.get(key, 0))
        shared_value = int(shared.get(key, 0))
        rows.append({
            "metric_key": key,
            "metric": label,
            "reference_n16": ref_value,
            "shared_n16": shared_value,
            "shared_over_reference_ratio": safe_ratio(shared_value, ref_value),
            "reduction_from_reference": safe_reduction(shared_value, ref_value),
        })

    return rows


def write_csv(rows: list[dict]) -> None:
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        "metric_key",
        "metric",
        "reference_n16",
        "shared_n16",
        "shared_over_reference_ratio",
        "reduction_from_reference",
    ]

    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def conclusion_text(ref: dict, shared: dict) -> str:
    ref_total = int(ref.get("total_cells", 0))
    shared_total = int(shared.get("total_cells", 0))
    ref_comb = int(ref.get("estimated_comb_cells", 0))
    shared_comb = int(shared.get("estimated_comb_cells", 0))
    ref_dff = int(ref.get("dff_dffe_cells_raw", 0))
    shared_dff = int(shared.get("dff_dffe_cells_raw", 0))

    comb_ratio = numeric_ratio(shared_comb, ref_comb)
    total_ratio = numeric_ratio(shared_total, ref_total)

    lines = []

    if comb_ratio is not None and shared_comb < ref_comb:
        lines.append(
            "The resource-shared N=16 decoder reduces the estimated combinational cell count "
            "relative to the reference N=16 RTL. This supports the resource-sharing hypothesis "
            "at synthesis level."
        )
    elif comb_ratio is not None:
        lines.append(
            "The resource-shared N=16 decoder does not reduce estimated combinational cell count "
            "relative to the reference N=16 RTL in this run. The architecture should therefore be "
            "reviewed carefully before making a strong area-efficiency claim."
        )
    else:
        lines.append(
            "The estimated combinational-cell ratio cannot be computed because the reference value is zero."
        )

    if total_ratio is not None:
        if shared_total < ref_total:
            lines.append(
                "The total cell count is also lower for the resource-shared design."
            )
        else:
            lines.append(
                "The total cell count is not lower for the resource-shared design. This may still be acceptable "
                "because the shared architecture intentionally introduces sequential storage and FSM control."
            )

    if shared_dff > ref_dff:
        lines.append(
            "The resource-shared design has more DFF/DFFE cells, as expected for a multi-cycle scheduled architecture."
        )

    lines.append(
        f"The measured latency of the resource-shared N=16 decoder is {SHARED_LATENCY_CYCLES} cycles, "
        "so final conclusions must be latency-aware rather than based on cell count alone."
    )

    return "\n\n".join(lines)


def write_markdown(path: Path, ref: dict, shared: dict, rows: list[dict], full_doc: bool) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    title = "Project 8.4: N=16 Architecture Comparison Using Yosys" if full_doc else \
            "SC Decoder N=16 Yosys Architecture Comparison"

    ref_design = ref.get("design", "sc_decoder_n16_ref")
    shared_design = shared.get("design", "sc_decoder_n16_shared")

    with path.open("w", encoding="utf-8") as f:
        f.write(f"# {title}\n\n")

        f.write("## 1. Project Objective\n\n")
        f.write(
            "Project 8.4 compares two SC Decoder N=16 RTL architectures using Yosys synthesis metrics.\n\n"
        )
        f.write("The compared designs are:\n\n")
        f.write("```text\n")
        f.write("1. Reference/combinational SC Decoder N=16\n")
        f.write("2. Resource-shared scheduled SC Decoder N=16\n")
        f.write("```\n\n")
        f.write("The main objective is to determine whether the resource-shared scheduled architecture reduces duplicated combinational logic compared with the reference RTL baseline.\n\n")

        f.write("---\n\n")
        f.write("## 2. Compared Designs\n\n")
        f.write("| Design | Role | Source Summary |\n")
        f.write("|---|---|---|\n")
        f.write(f"| `{ref_design}` | Reference N=16 RTL baseline | `{REF_CSV}` |\n")
        f.write(f"| `{shared_design}` | Resource-shared scheduled N=16 RTL | `{SHARED_CSV}` |\n\n")

        f.write("The reference RTL was developed in Project 8.2 and synthesized in Project 8.2.1.\n\n")
        f.write("The resource-shared RTL was developed in Project 8.3 and synthesized in Project 8.3.1.\n\n")

        f.write("---\n\n")
        f.write("## 3. Functional Verification Context\n\n")
        f.write("The resource-shared N=16 RTL passed functional verification with:\n\n")
        f.write("```text\n")
        f.write("Total vector lines read = 1000\n")
        f.write("Total tests             = 1000\n")
        f.write("Total errors            = 0\n")
        f.write("Latency min cycles      = 115\n")
        f.write("Latency max cycles      = 115\n")
        f.write("Latency avg cycles      = 115\n")
        f.write("ALL TESTS PASSED.\n")
        f.write("```\n\n")
        f.write("Therefore, the Yosys comparison is performed between functionally verified N=16 designs.\n\n")

        f.write("---\n\n")
        f.write("## 4. Main Yosys Comparison Table\n\n")
        f.write("| Metric | Reference N=16 | Shared N=16 | Shared / Reference | Reduction From Reference |\n")
        f.write("|---|---:|---:|---:|---:|\n")
        for r in rows:
            f.write(
                f"| {r['metric']} | {r['reference_n16']} | {r['shared_n16']} | "
                f"{r['shared_over_reference_ratio']} | {r['reduction_from_reference']} |\n"
            )

        f.write("\n---\n\n")
        f.write("## 5. Key Metrics For Interpretation\n\n")
        f.write("The most important metrics are:\n\n")
        f.write("```text\n")
        f.write("total_cells\n")
        f.write("dff_dffe_cells_raw\n")
        f.write("estimated_comb_cells\n")
        f.write("mux_cells\n")
        f.write("xor_xnor_cells\n")
        f.write("nand_cells\n")
        f.write("latency_cycles\n")
        f.write("```\n\n")
        f.write("The reference design is primarily combinational, while the shared design is sequential and multi-cycle.\n\n")
        f.write("Therefore, the most meaningful synthesis-level comparison is not only total cell count, but also estimated combinational cell count after separating DFF/DFFE storage overhead.\n\n")

        f.write("---\n\n")
        f.write("## 6. Latency Context\n\n")
        f.write("The resource-shared N=16 RTL has deterministic latency:\n\n")
        f.write("```text\n")
        f.write(f"latency_cycles = {SHARED_LATENCY_CYCLES}\n")
        f.write("```\n\n")
        f.write("The reference RTL is a combinational/reference baseline. It does not use the same multi-cycle start/busy/done protocol.\n\n")
        f.write("Therefore, a final performance comparison must later include:\n\n")
        f.write("```text\n")
        f.write("clock period\n")
        f.write("latency cycles\n")
        f.write("effective decode time\n")
        f.write("area or cell count\n")
        f.write("area-latency product\n")
        f.write("```\n\n")

        f.write("---\n\n")
        f.write("## 7. Interpretation\n\n")
        f.write(conclusion_text(ref, shared))
        f.write("\n\n")

        f.write("---\n\n")
        f.write("## 8. Academic Interpretation\n\n")
        f.write(
            "Project 8.4 provides the first synthesis-level architecture comparison for SC Decoder N=16. "
            "It connects the reference RTL baseline and the resource-shared scheduled RTL under the same Yosys-based metric extraction flow.\n\n"
        )
        f.write("The correct academic claim should be cautious:\n\n")
        f.write("```text\n")
        f.write("The resource-shared scheduled N=16 decoder has been functionally verified and synthesized. ")
        f.write("Yosys metrics show how resource sharing changes total cells, sequential storage, and estimated combinational complexity relative to the N=16 reference RTL.\n")
        f.write("```\n\n")
        f.write("Stronger claims about physical area, timing closure, and effective throughput require OpenLane results.\n\n")

        f.write("---\n\n")
        f.write("## 9. Limitations\n\n")
        f.write("This comparison is limited because:\n\n")
        f.write("```text\n")
        f.write("1. It uses generic Yosys cell metrics, not final physical area.\n")
        f.write("2. It does not include OpenLane placement/routing results yet.\n")
        f.write("3. It does not include timing closure or critical path after physical implementation.\n")
        f.write("4. It does not include power or energy estimation.\n")
        f.write("5. The shared design has multi-cycle latency, so throughput must be evaluated separately.\n")
        f.write("```\n\n")

        f.write("---\n\n")
        f.write("## 10. Recommended Next Step\n\n")
        f.write("The next logical step is OpenLane physical implementation for both or at least the resource-shared N=16 decoder.\n\n")
        f.write("Recommended next project:\n\n")
        f.write("```text\n")
        f.write("Project 8.5: OpenLane Implementation Of Resource-Shared SC Decoder N=16\n")
        f.write("```\n\n")
        f.write("The OpenLane study should measure:\n\n")
        f.write("```text\n")
        f.write("DIEAREA\n")
        f.write("synth_cell_count\n")
        f.write("critical_path_ns\n")
        f.write("suggested_clock_period\n")
        f.write("DRC violations\n")
        f.write("LVS result\n")
        f.write("antenna violations\n")
        f.write("wire length\n")
        f.write("via count\n")
        f.write("```\n\n")

        f.write("---\n\n")
        f.write("## 11. Generated Files\n\n")
        f.write("This report was generated from:\n\n")
        f.write("```text\n")
        f.write(f"{REF_CSV}\n")
        f.write(f"{SHARED_CSV}\n")
        f.write("```\n\n")
        f.write("Generated outputs:\n\n")
        f.write("```text\n")
        f.write(f"{OUT_CSV}\n")
        f.write(f"{OUT_SUMMARY_MD}\n")
        f.write(f"{OUT_DOC_MD}\n")
        f.write("```\n\n")

        f.write("---\n\n")
        f.write("## 12. Conclusion\n\n")
        f.write(
            "Project 8.4 consolidates the Yosys-level comparison between the N=16 reference RTL and "
            "the N=16 resource-shared scheduled RTL.\n\n"
        )
        f.write(
            "This comparison is the required synthesis-level evidence before moving to physical implementation. "
            "The next stage should validate whether the resource-shared decoder also provides a favorable area/timing trade-off after OpenLane implementation.\n"
        )


def main() -> None:
    ref = read_single_row(REF_CSV)
    shared = read_single_row(SHARED_CSV)

    rows = make_rows(ref, shared)

    write_csv(rows)
    write_markdown(OUT_SUMMARY_MD, ref, shared, rows, full_doc=False)
    write_markdown(OUT_DOC_MD, ref, shared, rows, full_doc=True)

    print(f"[OK] Wrote {OUT_CSV}")
    print(f"[OK] Wrote {OUT_SUMMARY_MD}")
    print(f"[OK] Wrote {OUT_DOC_MD}")


if __name__ == "__main__":
    main()