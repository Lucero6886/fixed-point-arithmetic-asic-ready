import csv
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]

targets = {
    "polar_encoder_n8_top": PROJECT_ROOT / "asic_openlane/polar_encoder_n8_top/reports/metrics.csv",
    "sc_decoder_n4_top": PROJECT_ROOT / "asic_openlane/sc_decoder_n4_top/reports/metrics.csv",
}

fields = [
    "design_name",
    "flow_status",
    "CLOCK_PERIOD",
    "DIEAREA_mm^2",
    "synth_cell_count",
    "wire_length",
    "vias",
    "wns",
    "tns",
    "critical_path_ns",
    "suggested_clock_frequency",
    "Magic_violations",
    "pin_antenna_violations",
    "net_antenna_violations",
    "STD_CELL_LIBRARY",
]

out_file = PROJECT_ROOT / "results/summary/project5_5_metrics_summary.csv"
out_file.parent.mkdir(parents=True, exist_ok=True)

rows = []

for name, path in targets.items():
    if not path.exists():
        print(f"[WARN] Missing metrics file for {name}: {path}")
        continue

    with open(path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            selected = {field: row.get(field, "") for field in fields}
            selected["module"] = name
            rows.append(selected)

if rows:
    with open(out_file, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["module"] + fields)
        writer.writeheader()
        writer.writerows(rows)

    print(f"[OK] Wrote summary to {out_file}")
else:
    print("[ERROR] No metrics found.")