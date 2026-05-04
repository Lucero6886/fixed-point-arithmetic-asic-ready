#!/usr/bin/env python3
"""
Project 8.1: SC Decoder N=16 Golden Model And Schedule Analysis

Convention:
- u_hat[0] is decoded first.
- frozen_mask[i] = 1 means u_i is frozen and forced to 0.
- frozen_mask[i] = 0 means u_i is an information bit.
- Hard decision: LLR < 0 -> bit 1, otherwise bit 0.
- Min-sum f function is used.
"""

from __future__ import annotations

import argparse
import csv
import random
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "tests" / "golden_vectors"
SUMMARY_DIR = ROOT / "results" / "summary"


def hard_decision(llr: int) -> int:
    return 1 if llr < 0 else 0


def f_func(a: int, b: int) -> int:
    """
    Min-sum SC f function:
        f(a,b) = sign(a) sign(b) min(|a|, |b|)
    """
    mag = min(abs(a), abs(b))
    sign_negative = (a < 0) ^ (b < 0)
    return -mag if sign_negative else mag


def g_func(alpha: int, beta: int, u_decision: int) -> int:
    """
    SC g function:
        g(alpha,beta,u) = beta + alpha, if u = 0
                        = beta - alpha, if u = 1
    """
    return beta - alpha if u_decision else beta + alpha


def polar_encode(u: List[int]) -> List[int]:
    """
    Non-bit-reversed Arikan transform using recursive structure.

    For N=4:
        x0 = u0 ^ u1 ^ u2 ^ u3
        x1 = u1 ^ u3
        x2 = u2 ^ u3
        x3 = u3

    This matches the partial-sum convention used in earlier N=4/N=8 projects.
    """
    n = len(u)
    if n == 1:
        return [u[0] & 1]

    half = n // 2
    left = polar_encode(u[:half])
    right = polar_encode(u[half:])

    return [(left[i] ^ right[i]) for i in range(half)] + right


def sc_decode(llrs: List[int], frozen_mask: List[int]) -> List[int]:
    """
    Recursive SC decoder for N = 2^m.
    """
    n = len(llrs)

    if n != len(frozen_mask):
        raise ValueError("llrs and frozen_mask must have the same length")

    if n == 1:
        if frozen_mask[0]:
            return [0]
        return [hard_decision(llrs[0])]

    half = n // 2

    left_llrs = [
        f_func(llrs[i], llrs[i + half])
        for i in range(half)
    ]

    u_left = sc_decode(left_llrs, frozen_mask[:half])
    partial = polar_encode(u_left)

    right_llrs = [
        g_func(llrs[i], llrs[i + half], partial[i])
        for i in range(half)
    ]

    u_right = sc_decode(right_llrs, frozen_mask[half:])

    return u_left + u_right


def bits_to_int_lsb_first(bits: List[int]) -> int:
    value = 0
    for i, b in enumerate(bits):
        value |= (int(b) & 1) << i
    return value


def int_to_bits_lsb_first(value: int, n: int) -> List[int]:
    return [(value >> i) & 1 for i in range(n)]


@dataclass
class ScheduleCounts:
    n: int
    f_ops: int = 0
    g_ops: int = 0
    hard_decisions: int = 0
    partial_sum_encodes: int = 0
    partial_sum_xors_est: int = 0


def polar_xor_count(n: int) -> int:
    """
    Number of XOR operations in the direct butterfly Polar encoder.
    For N = 2^m: (N/2) * log2(N)
    """
    if n <= 1:
        return 0

    m = 0
    tmp = n
    while tmp > 1:
        tmp //= 2
        m += 1

    return (n // 2) * m


def count_sc_schedule(n: int) -> ScheduleCounts:
    """
    Count high-level algorithmic operations for recursive SC decoding.
    """
    counts = ScheduleCounts(n=n)

    def walk(size: int) -> None:
        if size == 1:
            counts.hard_decisions += 1
            return

        half = size // 2

        counts.f_ops += half
        walk(half)

        counts.partial_sum_encodes += 1
        counts.partial_sum_xors_est += polar_xor_count(half)

        counts.g_ops += half
        walk(half)

    walk(n)
    return counts


def generate_schedule_lines(n: int) -> List[str]:
    """
    Generate a readable recursive schedule description.
    """
    lines: List[str] = []

    def walk(size: int, offset: int, level: int) -> None:
        indent = "  " * level

        if size == 1:
            lines.append(f"{indent}- Decode u{offset}: hard decision or frozen-to-zero")
            return

        half = size // 2
        lines.append(f"{indent}- Node N={size}, u[{offset}:{offset+size-1}]")
        lines.append(f"{indent}  1) Compute {half} f operations for left child")
        walk(half, offset, level + 1)
        lines.append(f"{indent}  2) Compute partial sums using Polar Encode N={half}")
        lines.append(f"{indent}  3) Compute {half} g operations for right child")
        walk(half, offset + half, level + 1)

    walk(n, 0, 0)
    return lines


def run_basic_tests() -> None:
    print("Running basic tests for SC Decoder N=16...")

    test_cases = [
        {
            "llrs": [0] * 16,
            "mask": [1] * 16,
            "name": "all frozen, all zero LLR",
        },
        {
            "llrs": [4, 3, 2, 1, 4, 3, 2, 1, 4, 3, 2, 1, 4, 3, 2, 1],
            "mask": [0] * 16,
            "name": "all information, positive LLR",
        },
        {
            "llrs": [-4, 3, 2, -1, 4, -3, 2, 1, -2, 2, -3, 3, 4, -4, 1, -1],
            "mask": [0] * 16,
            "name": "all information, mixed LLR",
        },
        {
            "llrs": [1, -2, 3, -4, -1, 2, -3, 4, 5, -5, 6, -6, 7, -7, 8, -8],
            "mask": [1] * 8 + [0] * 8,
            "name": "left frozen, right information",
        },
    ]

    for case in test_cases:
        u_hat = sc_decode(case["llrs"], case["mask"])
        print(
            f"[OK] {case['name']} -> "
            f"u_hat={u_hat}, u_hat_int={bits_to_int_lsb_first(u_hat)}"
        )

    # Polar encoder sanity check for N=4.
    u4 = [1, 0, 1, 1]
    x4 = polar_encode(u4)
    expected_x4 = [
        u4[0] ^ u4[1] ^ u4[2] ^ u4[3],
        u4[1] ^ u4[3],
        u4[2] ^ u4[3],
        u4[3],
    ]
    assert x4 == expected_x4, f"Polar N=4 sanity check failed: {x4} != {expected_x4}"

    print("[OK] Basic tests completed.")


def generate_vectors(
    num_vectors: int,
    llr_min: int,
    llr_max: int,
    seed: int,
    output_csv: Path,
) -> None:
    rng = random.Random(seed)

    header = (
        [f"llr{i}" for i in range(16)]
        + [f"frozen{i}" for i in range(16)]
        + [f"u_hat{i}" for i in range(16)]
        + ["frozen_mask_int", "u_hat_int"]
    )

    with output_csv.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header)

        for _ in range(num_vectors):
            llrs = [rng.randint(llr_min, llr_max) for _ in range(16)]
            frozen = [rng.randint(0, 1) for _ in range(16)]
            u_hat = sc_decode(llrs, frozen)

            writer.writerow(
                llrs
                + frozen
                + u_hat
                + [
                    bits_to_int_lsb_first(frozen),
                    bits_to_int_lsb_first(u_hat),
                ]
            )


def write_summary(
    summary_path: Path,
    schedule_path: Path,
    num_vectors: int,
    llr_min: int,
    llr_max: int,
    seed: int,
) -> None:
    counts = count_sc_schedule(16)
    schedule_lines = generate_schedule_lines(16)

    with summary_path.open("w") as f:
        f.write("Project 8.1: SC Decoder N=16 Golden Model Summary\n")
        f.write("==================================================\n\n")
        f.write("Convention:\n")
        f.write("- u_hat[0] is decoded first.\n")
        f.write("- frozen_mask[i] = 1 means u_i is frozen and forced to 0.\n")
        f.write("- frozen_mask[i] = 0 means u_i is an information bit.\n")
        f.write("- Hard decision: LLR < 0 -> 1, otherwise 0.\n")
        f.write("- Min-sum f function is used.\n\n")

        f.write("Generated vectors:\n")
        f.write(f"- num_vectors = {num_vectors}\n")
        f.write(f"- LLR range = [{llr_min}, {llr_max}]\n")
        f.write(f"- seed = {seed}\n\n")

        f.write("Schedule counts for N=16:\n")
        f.write(f"- f operations = {counts.f_ops}\n")
        f.write(f"- g operations = {counts.g_ops}\n")
        f.write(f"- hard decisions = {counts.hard_decisions}\n")
        f.write(f"- partial-sum encode calls = {counts.partial_sum_encodes}\n")
        f.write(f"- estimated partial-sum XORs = {counts.partial_sum_xors_est}\n\n")

        f.write("Top-level N=16 decomposition:\n")
        f.write("- Compute 8 f operations to form left N=8 LLRs.\n")
        f.write("- Decode left N=8 branch.\n")
        f.write("- Compute N=8 partial sums using Polar Encode N=8.\n")
        f.write("- Compute 8 g operations to form right N=8 LLRs.\n")
        f.write("- Decode right N=8 branch.\n\n")

    with schedule_path.open("w") as f:
        f.write("SC Decoder N=16 Recursive Schedule\n")
        f.write("==================================\n\n")
        for line in schedule_lines:
            f.write(line + "\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--num-vectors", type=int, default=2000)
    parser.add_argument("--llr-min", type=int, default=-8)
    parser.add_argument("--llr-max", type=int, default=8)
    parser.add_argument("--seed", type=int, default=20260503)
    args = parser.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    SUMMARY_DIR.mkdir(parents=True, exist_ok=True)

    output_csv = OUT_DIR / "sc_decoder_n16_vectors.csv"
    summary_txt = OUT_DIR / "sc_decoder_n16_summary.txt"
    schedule_txt = SUMMARY_DIR / "sc_decoder_n16_schedule_analysis.txt"

    run_basic_tests()

    print("Generating random golden vectors...")
    generate_vectors(
        num_vectors=args.num_vectors,
        llr_min=args.llr_min,
        llr_max=args.llr_max,
        seed=args.seed,
        output_csv=output_csv,
    )

    write_summary(
        summary_path=summary_txt,
        schedule_path=schedule_txt,
        num_vectors=args.num_vectors,
        llr_min=args.llr_min,
        llr_max=args.llr_max,
        seed=args.seed,
    )

    print(f"[OK] Wrote vectors to {output_csv}")
    print(f"[OK] Wrote summary to {summary_txt}")
    print(f"[OK] Wrote schedule analysis to {schedule_txt}")

    counts = count_sc_schedule(16)
    print("Schedule counts:")
    print(f"  f operations              = {counts.f_ops}")
    print(f"  g operations              = {counts.g_ops}")
    print(f"  hard decisions            = {counts.hard_decisions}")
    print(f"  partial-sum encode calls  = {counts.partial_sum_encodes}")
    print(f"  estimated partial XORs    = {counts.partial_sum_xors_est}")


if __name__ == "__main__":
    main()