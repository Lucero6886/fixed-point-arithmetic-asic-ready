#!/usr/bin/env python3

from pathlib import Path
import re
import csv

ROOT = Path(__file__).resolve().parents[1]

targets = [
    {
        "design": "combinational_n8",
        "module": "sc_decoder_n8",
        "log": ROOT / "synth/reports/sc_decoder_n8_flat_yosys.log",
        "latency_note": "1-cycle combinational baseline",
    },
    {
        "design": "scheduled_n8",
        "module": "sc_decoder_n8_scheduled",
        "log": ROOT / "synth/reports/sc_decoder_n8_scheduled_yosys.log",
        "latency_note": "multi-cycle FSM baseline",
    },
    {
        "design": "resource_shared_n8",
        "module": "sc_decoder_n8_shared",
        "log": ROOT / "synth/reports/sc_decoder_n8_shared_yosys.log",
        "latency_note": "multi-cycle resource-shared baseline",
    },
]

def extract_block(text, module):
    marker = f"=== {module} ==="
    idx = text.find(marker)
    if idx < 0:
        return ""
    next_idx = text.find("===", idx + len(marker))
    if next_idx < 0:
        return text[idx:]
    return text[idx:next_idx]

def get_int(pattern, block):
    m = re.search(pattern, block)
    return int(m.group(1)) if m else 0

def extract_cells(block):
    cells = {}
    in_cells = False

    for line in block.splitlines():
        if "Number of cells:" in line:
            in_cells = True
            continue

        if in_cells:
            m = re.match(r"\s+(\S+)\s+(\d+)\s*$", line)
            if m:
                cells[m.group(1)] = int(m.group(2))
            elif line.strip() == "":
                continue

    return cells

def sum_cells(cells, keywords):
    total = 0
    for k, v in cells.items():
        ku = k.upper()
        if any(word.upper() in ku for word in keywords):
            total += v
    return total

rows = []

for item in targets:
    log_path = item["log"]
    module = item["module"]

    if not log_path.exists():
        raise FileNotFoundError(f"Missing log file: {log_path}")

    text = log_path.read_text(errors="ignore")
    block = extract_block(text, module)

    if not block:
        raise RuntimeError(f"Cannot find module block === {module} === in {log_path}")

    cells = extract_cells(block)

    total_cells = get_int(r"Number of cells:\s+(\d+)", block)
    # Count sequential cells once.
    # Important: DFFE contains the substring DFF, so do not count DFF and DFFE separately.
    seq_cells = sum(v for k, v in cells.items() if re.search(r"\$_DFF(E)?", k, re.IGNORECASE))
    mux_cells = sum_cells(cells, ["MUX"])
    xor_xnor_cells = sum_cells(cells, ["XOR", "XNOR"])
    nand_cells = sum_cells(cells, ["NAND"])
    and_cells = cells.get("$_AND_", 0)
    andnot_cells = cells.get("$_ANDNOT_", 0)
    or_cells = cells.get("$_OR_", 0)
    ornot_cells = cells.get("$_ORNOT_", 0)

    rows.append({
        "design": item["design"],
        "module": module,
        "latency_note": item["latency_note"],
        "wires": get_int(r"Number of wires:\s+(\d+)", block),
        "wire_bits": get_int(r"Number of wire bits:\s+(\d+)", block),
        "public_wires": get_int(r"Number of public wires:\s+(\d+)", block),
        "public_wire_bits": get_int(r"Number of public wire bits:\s+(\d+)", block),
        "memories": get_int(r"Number of memories:\s+(\d+)", block),
        "processes": get_int(r"Number of processes:\s+(\d+)", block),
        "total_cells": total_cells,
        "dff_dffe_cells": seq_cells,
        "estimated_comb_cells": total_cells - seq_cells,
        "mux_cells": mux_cells,
        "xor_xnor_cells": xor_xnor_cells,
        "nand_cells": nand_cells,
        "and_cells": and_cells,
        "andnot_cells": andnot_cells,
        "or_cells": or_cells,
        "ornot_cells": ornot_cells,
        "cell_breakdown": cells,
    })

out_csv = ROOT / "results/summary/sc_decoder_n8_three_arch_yosys_comparison.csv"
out_md = ROOT / "results/summary/sc_decoder_n8_three_arch_yosys_comparison.md"
out_csv.parent.mkdir(parents=True, exist_ok=True)

fieldnames = [
    "design",
    "module",
    "latency_note",
    "wires",
    "wire_bits",
    "public_wires",
    "public_wire_bits",
    "memories",
    "processes",
    "total_cells",
    "dff_dffe_cells",
    "estimated_comb_cells",
    "mux_cells",
    "xor_xnor_cells",
    "nand_cells",
    "and_cells",
    "andnot_cells",
    "or_cells",
    "ornot_cells",
]

with out_csv.open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    for r in rows:
        writer.writerow({k: r[k] for k in fieldnames})

def make_markdown(rows):
    lines = []
    lines.append("# SC Decoder N=8 Three-Architecture Yosys Comparison\n")
    lines.append("## Summary Table\n")
    lines.append("| Design | Wires | Wire bits | Total cells | DFF/DFFE | Est. comb cells | MUX | XOR/XNOR | NAND |")
    lines.append("|---|---:|---:|---:|---:|---:|---:|---:|---:|")
    for r in rows:
        lines.append(
            f"| {r['design']} | {r['wires']} | {r['wire_bits']} | "
            f"{r['total_cells']} | {r['dff_dffe_cells']} | "
            f"{r['estimated_comb_cells']} | {r['mux_cells']} | "
            f"{r['xor_xnor_cells']} | {r['nand_cells']} |"
        )

    base = rows[0]
    lines.append("\n## Ratios Relative To Combinational Baseline\n")
    lines.append("| Design | Total cells ratio | Est. comb cells ratio | MUX ratio | DFF/DFFE cells |")
    lines.append("|---|---:|---:|---:|---:|")

    for r in rows:
        total_ratio = r["total_cells"] / base["total_cells"] if base["total_cells"] else 0
        comb_ratio = r["estimated_comb_cells"] / base["estimated_comb_cells"] if base["estimated_comb_cells"] else 0
        mux_ratio = r["mux_cells"] / base["mux_cells"] if base["mux_cells"] else 0
        lines.append(
            f"| {r['design']} | {total_ratio:.2f}× | {comb_ratio:.2f}× | {mux_ratio:.2f}× | {r['dff_dffe_cells']} |"
        )

    lines.append("\n## Cell Breakdown\n")
    for r in rows:
        lines.append(f"### {r['design']}\n")
        lines.append("| Cell type | Count |")
        lines.append("|---|---:|")
        for cell, count in sorted(r["cell_breakdown"].items()):
            lines.append(f"| {cell} | {count} |")
        lines.append("")

    return "\n".join(lines) + "\n"

md = make_markdown(rows)
out_md.write_text(md)

print(md)
print(f"[OK] Wrote CSV summary to {out_csv}")
print(f"[OK] Wrote Markdown summary to {out_md}")