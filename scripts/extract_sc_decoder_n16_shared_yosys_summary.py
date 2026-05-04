#!/usr/bin/env python3
"""
Extract Yosys summary for Project 8.3.1:
SC Decoder N=16 resource-shared scheduled RTL synthesis baseline.
"""

from __future__ import annotations

import csv
import re
from pathlib import Path


LOG_PATH = Path("synth/reports/sc_decoder_n16_shared_flat_yosys.log")
CSV_PATH = Path("results/summary/sc_decoder_n16_shared_yosys_summary.csv")
MD_PATH = Path("results/summary/sc_decoder_n16_shared_yosys_summary.md")


def parse_yosys_log(text: str) -> dict:
    blocks = re.findall(
        r"=== sc_decoder_n16_shared ===(?P<body>.*?)(?=\n=== |\nEnd of script\.|\Z)",
        text,
        flags=re.S,
    )

    if not blocks:
        raise RuntimeError("Could not find '=== sc_decoder_n16_shared ===' block in Yosys log.")

    body = blocks[-1]

    def get_int(label: str) -> int:
        m = re.search(rf"{re.escape(label)}:\s+(\d+)", body)
        if not m:
            raise RuntimeError(f"Could not find metric: {label}")
        return int(m.group(1))

    result = {
        "design": "sc_decoder_n16_shared",
        "wires": get_int("Number of wires"),
        "wire_bits": get_int("Number of wire bits"),
        "public_wires": get_int("Number of public wires"),
        "public_wire_bits": get_int("Number of public wire bits"),
        "memories": get_int("Number of memories"),
        "memory_bits": get_int("Number of memory bits"),
        "processes": get_int("Number of processes"),
        "total_cells": get_int("Number of cells"),
    }

    cell_counts = {}
    for line in body.splitlines():
        m = re.match(r"\s+(\S+)\s+(\d+)\s*$", line)
        if m:
            cell_counts[m.group(1)] = int(m.group(2))

    result["cell_counts"] = cell_counts

    dff_dffe = sum(
        count for cell, count in cell_counts.items()
        if "DFF" in cell or "DFFE" in cell
    )

    result["dff_dffe_cells_raw"] = dff_dffe
    result["estimated_comb_cells"] = result["total_cells"] - dff_dffe
    result["mux_cells"] = cell_counts.get("$_MUX_", 0)
    result["xor_cells"] = cell_counts.get("$_XOR_", 0)
    result["xnor_cells"] = cell_counts.get("$_XNOR_", 0)
    result["xor_xnor_cells"] = result["xor_cells"] + result["xnor_cells"]
    result["nand_cells"] = cell_counts.get("$_NAND_", 0)
    result["and_cells"] = cell_counts.get("$_AND_", 0)
    result["or_cells"] = cell_counts.get("$_OR_", 0)

    return result


def write_csv(summary: dict) -> None:
    CSV_PATH.parent.mkdir(parents=True, exist_ok=True)

    row = {
        "design": summary["design"],
        "wires": summary["wires"],
        "wire_bits": summary["wire_bits"],
        "public_wires": summary["public_wires"],
        "public_wire_bits": summary["public_wire_bits"],
        "memories": summary["memories"],
        "memory_bits": summary["memory_bits"],
        "processes": summary["processes"],
        "total_cells": summary["total_cells"],
        "dff_dffe_cells_raw": summary["dff_dffe_cells_raw"],
        "estimated_comb_cells": summary["estimated_comb_cells"],
        "mux_cells": summary["mux_cells"],
        "xor_cells": summary["xor_cells"],
        "xnor_cells": summary["xnor_cells"],
        "xor_xnor_cells": summary["xor_xnor_cells"],
        "nand_cells": summary["nand_cells"],
        "and_cells": summary["and_cells"],
        "or_cells": summary["or_cells"],
    }

    with CSV_PATH.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(row.keys()))
        writer.writeheader()
        writer.writerow(row)


def write_markdown(summary: dict) -> None:
    MD_PATH.parent.mkdir(parents=True, exist_ok=True)

    cell_counts = summary["cell_counts"]

    with MD_PATH.open("w", encoding="utf-8") as f:
        f.write("# SC Decoder N=16 Resource-Shared RTL Yosys Summary\n\n")

        f.write("## 1. Main Metrics\n\n")
        f.write("| Metric | Value |\n")
        f.write("|---|---:|\n")
        f.write(f"| Design | {summary['design']} |\n")
        f.write(f"| Wires | {summary['wires']} |\n")
        f.write(f"| Wire bits | {summary['wire_bits']} |\n")
        f.write(f"| Public wires | {summary['public_wires']} |\n")
        f.write(f"| Public wire bits | {summary['public_wire_bits']} |\n")
        f.write(f"| Memories | {summary['memories']} |\n")
        f.write(f"| Memory bits | {summary['memory_bits']} |\n")
        f.write(f"| Processes | {summary['processes']} |\n")
        f.write(f"| Total cells | {summary['total_cells']} |\n")
        f.write(f"| Raw DFF/DFFE cells | {summary['dff_dffe_cells_raw']} |\n")
        f.write(f"| Estimated combinational cells | {summary['estimated_comb_cells']} |\n")
        f.write(f"| MUX cells | {summary['mux_cells']} |\n")
        f.write(f"| XOR cells | {summary['xor_cells']} |\n")
        f.write(f"| XNOR cells | {summary['xnor_cells']} |\n")
        f.write(f"| XOR + XNOR cells | {summary['xor_xnor_cells']} |\n")
        f.write(f"| NAND cells | {summary['nand_cells']} |\n")
        f.write(f"| AND cells | {summary['and_cells']} |\n")
        f.write(f"| OR cells | {summary['or_cells']} |\n")

        f.write("\n## 2. Cell Breakdown\n\n")
        f.write("| Cell type | Count |\n")
        f.write("|---|---:|\n")
        for cell, count in sorted(cell_counts.items()):
            f.write(f"| `{cell}` | {count} |\n")

        f.write("\n## 3. Interpretation\n\n")
        f.write(
            "This synthesis result is for the multi-cycle resource-shared SC Decoder N=16. "
            "Unlike the reference combinational RTL, this design is expected to contain sequential cells "
            "because it uses FSM state registers, internal LLR registers, decoded-bit registers, "
            "partial-sum registers, and output/control registers.\n\n"
        )
        f.write(
            "The most important future comparison is against the N=16 reference RTL baseline. "
            "In particular, compare total cells, DFF/DFFE cells, estimated combinational cells, "
            "MUX cells, XOR/XNOR cells, NAND cells, and measured latency cycles.\n"
        )


def main() -> None:
    if not LOG_PATH.exists():
        raise FileNotFoundError(f"Missing Yosys log: {LOG_PATH}")

    text = LOG_PATH.read_text(encoding="utf-8", errors="ignore")
    summary = parse_yosys_log(text)

    write_csv(summary)
    write_markdown(summary)

    print(f"[OK] Parsed {LOG_PATH}")
    print(f"[OK] Wrote {CSV_PATH}")
    print(f"[OK] Wrote {MD_PATH}")
    print(f"[OK] Total cells = {summary['total_cells']}")
    print(f"[OK] DFF/DFFE cells = {summary['dff_dffe_cells_raw']}")
    print(f"[OK] Estimated comb cells = {summary['estimated_comb_cells']}")


if __name__ == "__main__":
    main()