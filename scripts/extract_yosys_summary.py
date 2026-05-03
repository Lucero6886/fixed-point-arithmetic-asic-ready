#!/usr/bin/env python3

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

targets = {
    "sc_decoder_n4": ROOT / "synth/reports/sc_decoder_n4_yosys.log",
    "sc_decoder_n8": ROOT / "synth/reports/sc_decoder_n8_yosys.log",
}

def extract_module_block(text, module_name):
    marker = f"=== {module_name} ==="
    idx = text.find(marker)
    if idx < 0:
        return ""
    next_idx = text.find("===", idx + len(marker))
    if next_idx < 0:
        return text[idx:]
    return text[idx:next_idx]

def extract_int(pattern, block):
    m = re.search(pattern, block)
    if not m:
        return None
    return int(m.group(1))

def extract_cell_types(block):
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

print("| Module | Wires | Wire bits | Public wires | Public wire bits | Cells |")
print("|---|---:|---:|---:|---:|---:|")

for name, path in targets.items():
    if not path.exists():
        print(f"| {name} | MISSING | MISSING | MISSING | MISSING | MISSING |")
        continue

    text = path.read_text(errors="ignore")
    block = extract_module_block(text, name)

    wires = extract_int(r"Number of wires:\s+(\d+)", block)
    wire_bits = extract_int(r"Number of wire bits:\s+(\d+)", block)
    pub_wires = extract_int(r"Number of public wires:\s+(\d+)", block)
    pub_wire_bits = extract_int(r"Number of public wire bits:\s+(\d+)", block)
    cells = extract_int(r"Number of cells:\s+(\d+)", block)

    print(f"| {name} | {wires} | {wire_bits} | {pub_wires} | {pub_wire_bits} | {cells} |")

print("\n## Cell Type Breakdown\n")

for name, path in targets.items():
    if not path.exists():
        continue

    text = path.read_text(errors="ignore")
    block = extract_module_block(text, name)
    cell_types = extract_cell_types(block)

    print(f"### {name}")
    if not cell_types:
        print("No cell type data found.\n")
        continue

    print("| Cell type | Count |")
    print("|---|---:|")
    for c, n in sorted(cell_types.items()):
        print(f"| {c} | {n} |")
    print()
