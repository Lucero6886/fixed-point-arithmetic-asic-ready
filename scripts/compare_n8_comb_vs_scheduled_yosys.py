#!/usr/bin/env python3

from pathlib import Path
import re
import csv

ROOT = Path(__file__).resolve().parents[1]

targets = {
    "sc_decoder_n8_comb": {
        "module": "sc_decoder_n8",
        "log": ROOT / "synth/reports/sc_decoder_n8_flat_yosys.log",
    },
    "sc_decoder_n8_scheduled": {
        "module": "sc_decoder_n8_scheduled",
        "log": ROOT / "synth/reports/sc_decoder_n8_scheduled_yosys.log",
    },
}

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

rows = []

for label, item in targets.items():
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
    dff_cells = sum(v for k, v in cells.items() if "DFF" in k or "dff" in k)
    mux_cells = sum(v for k, v in cells.items() if "MUX" in k or "mux" in k)
    xor_cells = sum(v for k, v in cells.items() if "XOR" in k or "XNOR" in k or "xor" in k or "xnor" in k)

    rows.append({
        "design": label,
        "module": module,
        "wires": get_int(r"Number of wires:\s+(\d+)", block),
        "wire_bits": get_int(r"Number of wire bits:\s+(\d+)", block),
        "public_wires": get_int(r"Number of public wires:\s+(\d+)", block),
        "public_wire_bits": get_int(r"Number of public wire bits:\s+(\d+)", block),
        "memories": get_int(r"Number of memories:\s+(\d+)", block),
        "processes": get_int(r"Number of processes:\s+(\d+)", block),
        "total_cells": total_cells,
        "dff_cells": dff_cells,
        "comb_cells_est": total_cells - dff_cells,
        "mux_cells": mux_cells,
        "xor_xnor_cells": xor_cells,
        "cell_breakdown": cells,
    })

out_csv = ROOT / "results/summary/sc_decoder_n8_comb_vs_scheduled_yosys_comparison.csv"
out_csv.parent.mkdir(parents=True, exist_ok=True)

with out_csv.open("w", newline="") as f:
    fieldnames = [
        "design",
        "module",
        "wires",
        "wire_bits",
        "public_wires",
        "public_wire_bits",
        "memories",
        "processes",
        "total_cells",
        "dff_cells",
        "comb_cells_est",
        "mux_cells",
        "xor_xnor_cells",
    ]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    for r in rows:
        writer.writerow({k: r[k] for k in fieldnames})

print("# SC Decoder N=8: Combinational vs Scheduled Yosys Comparison\n")

print("| Design | Wires | Wire bits | Total cells | DFF cells | Estimated comb cells | MUX cells | XOR/XNOR cells |")
print("|---|---:|---:|---:|---:|---:|---:|---:|")

for r in rows:
    print(
        f"| {r['design']} | {r['wires']} | {r['wire_bits']} | "
        f"{r['total_cells']} | {r['dff_cells']} | {r['comb_cells_est']} | "
        f"{r['mux_cells']} | {r['xor_xnor_cells']} |"
    )

if len(rows) == 2:
    comb = rows[0]
    sched = rows[1]

    def ratio(a, b):
        if b == 0:
            return "NA"
        return f"{a / b:.2f}x"

    print("\n## Ratios: Scheduled / Combinational\n")
    print("| Metric | Ratio |")
    print("|---|---:|")
    print(f"| Wires | {ratio(sched['wires'], comb['wires'])} |")
    print(f"| Wire bits | {ratio(sched['wire_bits'], comb['wire_bits'])} |")
    print(f"| Total cells | {ratio(sched['total_cells'], comb['total_cells'])} |")
    print(f"| Estimated comb cells | {ratio(sched['comb_cells_est'], comb['comb_cells_est'])} |")
    print(f"| MUX cells | {ratio(sched['mux_cells'], comb['mux_cells'])} |")
    print(f"| XOR/XNOR cells | {ratio(sched['xor_xnor_cells'], comb['xor_xnor_cells'])} |")

print(f"\n[OK] Wrote CSV summary to {out_csv}")

print("\n## Cell Breakdown\n")

for r in rows:
    print(f"### {r['design']}")
    print("| Cell type | Count |")
    print("|---|---:|")
    for cell, count in sorted(r["cell_breakdown"].items()):
        print(f"| {cell} | {count} |")
    print()