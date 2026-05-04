#!/bin/bash

set -e

echo "Creating backup..."
TS=$(date +%Y%m%d_%H%M%S)
cp -r docs "docs_backup_before_standard_docs_$TS" 2>/dev/null || true

mkdir -p docs
mkdir -p docs/project5_5
mkdir -p docs/project6_1 docs/project6_2 docs/project6_3 docs/project6_4
mkdir -p docs/project7_1 docs/project7_2 docs/project7_3 docs/project7_4 docs/project7_5 docs/project7_6 docs/project7_7
mkdir -p docs/project8_1
mkdir -p docs/master_review

cat > docs/project0_counter_report.md <<'EOF'
# Project 0: Counter RTL-To-GDSII Baseline

## 1. Objective

Project 0 introduces the complete open-source RTL-to-GDSII flow using a very small digital circuit: a counter.

The purpose is not to design an advanced circuit, but to understand the full ASIC implementation path:

```text
RTL
→ simulation
→ synthesis
→ floorplan
→ placement
→ routing
→ signoff checks
→ GDSII