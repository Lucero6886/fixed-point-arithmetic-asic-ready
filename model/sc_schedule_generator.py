#!/usr/bin/env python3
"""
Project 8.1: Recursive SC Decoder Schedule Generator

This script generates an operation schedule for a resource-shared
Successive Cancellation Polar decoder.

Default target:
    N = 16

The generated schedule is intended for architecture analysis before RTL.

Conventions:
- LSB-first bit ordering.
- frozen_mask[i] = 1 means frozen.
- f(a,b) = sign(a) sign(b) min(|a|, |b|)
- g(a,b,u) = b + a if u=0, b - a if u=1.
- Partial sums use the same recursive Polar transform as previous projects.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import List, Sequence, Set


@dataclass
class ScheduleRow:
    step: int
    node: str
    node_path: str
    node_size: int
    bit_offset: int
    op_type: str
    local_index: int
    operand_a: str
    operand_b: str
    g_bit: str
    destination: str
    expression: str
    comment: str


def is_power_of_two(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0


def sort_key_signal(name: str):
    m = re.search(r"(\d+)$", name)
    if m:
        return (name[:m.start()], int(m.group(1)))
    return (name, -1)


def xor_terms(a: Set[str], b: Set[str]) -> Set[str]:
    """GF(2) XOR of symbolic term sets using symmetric difference."""
    return set(a.symmetric_difference(b))


def format_terms(terms: Set[str]) -> str:
    if not terms:
        return "0"
    ordered = sorted(terms, key=sort_key_signal)
    return " ^ ".join(ordered)


def polar_encode_termsets(bit_names: Sequence[str]) -> List[Set[str]]:
    """
    Generate symbolic partial-sum expressions using recursive Polar transform.

    Example for N=4:
        p0 = u0 ^ u1 ^ u2 ^ u3
        p1 = u1 ^ u3
        p2 = u2 ^ u3
        p3 = u3
    """
    n = len(bit_names)
    if not is_power_of_two(n):
        raise ValueError(f"length must be a power of two, got {n}")

    terms = [{name} for name in bit_names]
    return _polar_encode_terms_recursive(terms)


def _polar_encode_terms_recursive(terms: Sequence[Set[str]]) -> List[Set[str]]:
    n = len(terms)
    if n == 1:
        return [set(terms[0])]

    half = n // 2

    upper = [
        xor_terms(terms[i], terms[i + half])
        for i in range(half)
    ]
    lower = [
        set(terms[i + half])
        for i in range(half)
    ]

    return _polar_encode_terms_recursive(upper) + _polar_encode_terms_recursive(lower)


def node_name_from_path(path: str) -> str:
    if path == "":
        return "ROOT"
    return "N" + path


def llr_name_for_input(index: int) -> str:
    return f"L{index}"


def operation_count(n: int) -> dict:
    if not is_power_of_two(n):
        raise ValueError(f"N must be a power of two, got {n}")

    levels = int(math.log2(n))
    f_ops = (n // 2) * levels
    g_ops = (n // 2) * levels
    hard_decisions = n

    partial_output_rows = 0
    partial_xors_est = 0

    node_size = 2
    while node_size <= n:
        num_nodes = n // node_size
        half = node_size // 2

        # One partial output row per g-control partial bit.
        partial_output_rows += num_nodes * half

        # Staged butterfly XOR count for Polar_Encode(half).
        if half >= 2:
            xors_per_node = (half // 2) * int(math.log2(half))
        else:
            xors_per_node = 0

        partial_xors_est += num_nodes * xors_per_node
        node_size *= 2

    return {
        "N": n,
        "levels": levels,
        "f_ops": f_ops,
        "g_ops": g_ops,
        "hard_decisions": hard_decisions,
        "partial_output_rows": partial_output_rows,
        "partial_xors_est_staged": partial_xors_est,
        "fg_ops_total": f_ops + g_ops,
        "fg_plus_hard_decisions": f_ops + g_ops + hard_decisions,
        "latency_lower_bound_cycles": f_ops + g_ops + hard_decisions,
        "latency_if_partial_outputs_one_cycle_each": f_ops + g_ops + hard_decisions + partial_output_rows,
        "latency_conservative_est_cycles": f_ops + g_ops + hard_decisions + partial_xors_est,
    }


def generate_schedule(n: int) -> List[ScheduleRow]:
    if not is_power_of_two(n):
        raise ValueError(f"N must be a power of two, got {n}")

    rows: List[ScheduleRow] = []
    input_llrs = [llr_name_for_input(i) for i in range(n)]

    def add_row(
        node: str,
        node_path: str,
        node_size: int,
        bit_offset: int,
        op_type: str,
        local_index: int,
        operand_a: str,
        operand_b: str,
        g_bit: str,
        destination: str,
        expression: str,
        comment: str,
    ) -> None:
        rows.append(
            ScheduleRow(
                step=len(rows),
                node=node,
                node_path=node_path if node_path else "ROOT",
                node_size=node_size,
                bit_offset=bit_offset,
                op_type=op_type,
                local_index=local_index,
                operand_a=operand_a,
                operand_b=operand_b,
                g_bit=g_bit,
                destination=destination,
                expression=expression,
                comment=comment,
            )
        )

    def recurse(node_path: str, bit_offset: int, node_size: int, llrs: List[str]) -> None:
        node = node_name_from_path(node_path)

        if node_size == 1:
            bit_name = f"u{bit_offset}"
            llr = llrs[0]

            add_row(
                node=node,
                node_path=node_path,
                node_size=node_size,
                bit_offset=bit_offset,
                op_type="DECISION",
                local_index=0,
                operand_a=llr,
                operand_b="-",
                g_bit="-",
                destination=bit_name,
                expression=f"{bit_name} = 0 if frozen{bit_offset}=1 else hard_decision({llr})",
                comment="Leaf hard decision with frozen-mask control.",
            )
            return

        half = node_size // 2

        left_llrs = [
            f"llr_{node}_L{i}"
            for i in range(half)
        ]

        right_llrs = [
            f"llr_{node}_R{i}"
            for i in range(half)
        ]

        # 1. f operations for left branch
        for i in range(half):
            a = llrs[i]
            b = llrs[i + half]
            dst = left_llrs[i]

            add_row(
                node=node,
                node_path=node_path,
                node_size=node_size,
                bit_offset=bit_offset,
                op_type="F",
                local_index=i,
                operand_a=a,
                operand_b=b,
                g_bit="-",
                destination=dst,
                expression=f"{dst} = f({a}, {b})",
                comment="Compute left-branch LLR.",
            )

        # 2. Decode left child
        recurse(node_path + "L", bit_offset, half, left_llrs)

        # 3. Partial sums from left decoded bits
        u_left = [f"u{bit_offset + i}" for i in range(half)]
        partial_expr_terms = polar_encode_termsets(u_left)
        partial_names = [f"p_{node}_{i}" for i in range(half)]

        for i, terms in enumerate(partial_expr_terms):
            expr = format_terms(terms)
            dst = partial_names[i]

            add_row(
                node=node,
                node_path=node_path,
                node_size=node_size,
                bit_offset=bit_offset,
                op_type="PARTIAL",
                local_index=i,
                operand_a=expr,
                operand_b="-",
                g_bit="-",
                destination=dst,
                expression=f"{dst} = {expr}",
                comment="Partial sum used as g-control bit.",
            )

        # 4. g operations for right branch
        for i in range(half):
            a = llrs[i]
            b = llrs[i + half]
            g_bit = partial_names[i]
            dst = right_llrs[i]

            add_row(
                node=node,
                node_path=node_path,
                node_size=node_size,
                bit_offset=bit_offset,
                op_type="G",
                local_index=i,
                operand_a=a,
                operand_b=b,
                g_bit=g_bit,
                destination=dst,
                expression=f"{dst} = g({a}, {b}, {g_bit})",
                comment="Compute right-branch LLR.",
            )

        # 5. Decode right child
        recurse(node_path + "R", bit_offset + half, half, right_llrs)

    recurse("", 0, n, input_llrs)
    return rows


def validate_schedule(rows: Sequence[ScheduleRow], n: int) -> dict:
    counts = operation_count(n)

    actual = {
        "F": sum(1 for r in rows if r.op_type == "F"),
        "G": sum(1 for r in rows if r.op_type == "G"),
        "DECISION": sum(1 for r in rows if r.op_type == "DECISION"),
        "PARTIAL": sum(1 for r in rows if r.op_type == "PARTIAL"),
        "TOTAL_ROWS": len(rows),
    }

    expected = {
        "F": counts["f_ops"],
        "G": counts["g_ops"],
        "DECISION": counts["hard_decisions"],
        "PARTIAL": counts["partial_output_rows"],
    }

    errors = []

    for key, expected_value in expected.items():
        if actual[key] != expected_value:
            errors.append(f"{key}: actual={actual[key]}, expected={expected_value}")

    if errors:
        raise AssertionError("Schedule validation failed: " + "; ".join(errors))

    return {
        "actual": actual,
        "expected": expected,
        "operation_count": counts,
    }


def write_csv(rows: Sequence[ScheduleRow], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = list(asdict(rows[0]).keys()) if rows else [
        "step",
        "node",
        "node_path",
        "node_size",
        "bit_offset",
        "op_type",
        "local_index",
        "operand_a",
        "operand_b",
        "g_bit",
        "destination",
        "expression",
        "comment",
    ]

    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(asdict(row))


def write_markdown(rows: Sequence[ScheduleRow], path: Path, validation: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    counts = validation["operation_count"]
    actual = validation["actual"]

    with path.open("w", encoding="utf-8") as f:
        f.write("# SC Decoder N=16 Resource-Shared Schedule Analysis\n\n")

        f.write("## 1. Summary\n\n")
        f.write("This file is generated by `model/sc_schedule_generator.py`.\n\n")
        f.write("The schedule follows recursive SC decoding and is intended for a future resource-shared RTL implementation.\n\n")

        f.write("## 2. Operation Count\n\n")
        f.write("| Metric | Value |\n")
        f.write("|---|---:|\n")
        for key, value in counts.items():
            f.write(f"| {key} | {value} |\n")

        f.write("\n## 3. Actual Schedule Row Counts\n\n")
        f.write("| Row Type | Count |\n")
        f.write("|---|---:|\n")
        for key, value in actual.items():
            f.write(f"| {key} | {value} |\n")

        f.write("\n## 4. Important Interpretation\n\n")
        f.write("The core f/g operation count for N=16 is:\n\n")
        f.write("```text\n")
        f.write("f_ops = 32\n")
        f.write("g_ops = 32\n")
        f.write("hard_decisions = 16\n")
        f.write("```\n\n")

        f.write("The lower-bound latency for a one-f/g-operation-per-cycle shared datapath is:\n\n")
        f.write("```text\n")
        f.write("latency_lower_bound_cycles = 80\n")
        f.write("```\n\n")

        f.write("The conservative estimate including staged partial-sum XOR operations is:\n\n")
        f.write("```text\n")
        f.write("latency_conservative_est_cycles = 104\n")
        f.write("```\n\n")

        f.write("The generated schedule includes `PARTIAL` rows as explicit documentation/writeback points. ")
        f.write("In actual RTL, some partial sums may be computed combinationally or grouped into fewer cycles.\n\n")

        f.write("## 5. Full Schedule Table\n\n")
        f.write("| Step | Node | Size | Offset | Op | Idx | A | B | g bit | Destination | Expression |\n")
        f.write("|---:|---|---:|---:|---|---:|---|---|---|---|---|\n")

        for r in rows:
            f.write(
                f"| {r.step} | {r.node} | {r.node_size} | {r.bit_offset} "
                f"| {r.op_type} | {r.local_index} | `{r.operand_a}` | `{r.operand_b}` "
                f"| `{r.g_bit}` | `{r.destination}` | `{r.expression}` |\n"
            )


def write_json(validation: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding="utf-8") as f:
        json.dump(validation, f, indent=2)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate recursive SC decoder schedule for resource-shared architecture."
    )
    parser.add_argument("--n", type=int, default=16)
    parser.add_argument(
        "--csv",
        type=Path,
        default=Path("results/schedules/sc_decoder_n16_schedule.csv"),
    )
    parser.add_argument(
        "--md",
        type=Path,
        default=Path("results/schedules/sc_decoder_n16_schedule.md"),
    )
    parser.add_argument(
        "--json",
        type=Path,
        default=Path("results/schedules/sc_decoder_n16_operation_count.json"),
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    rows = generate_schedule(args.n)
    validation = validate_schedule(rows, args.n)

    write_csv(rows, args.csv)
    write_markdown(rows, args.md, validation)
    write_json(validation, args.json)

    print(f"[OK] Generated schedule for N={args.n}")
    print(f"[OK] Rows: {len(rows)}")
    print(f"[OK] CSV: {args.csv}")
    print(f"[OK] Markdown: {args.md}")
    print(f"[OK] JSON: {args.json}")

    print("[OK] Operation count:")
    print(json.dumps(validation["operation_count"], indent=2))


if __name__ == "__main__":
    main()