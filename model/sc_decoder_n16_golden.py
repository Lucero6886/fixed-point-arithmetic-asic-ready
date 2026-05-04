#!/usr/bin/env python3
"""
Project 8.1: SC Decoder N=16 Golden Model

This script provides a recursive Python golden model for SC Polar decoding.
It preserves the conventions used in the N=8 roadmap:

- Min-sum f function:
    f(a,b) = sign(a) sign(b) min(|a|, |b|)

- g function:
    g(a,b,u) = b + a, if u = 0
    g(a,b,u) = b - a, if u = 1

- Hard decision:
    LLR < 0  -> bit = 1
    LLR >= 0 -> bit = 0

- Frozen mask:
    frozen_mask[i] = 1 -> frozen bit, force u_i = 0
    frozen_mask[i] = 0 -> information bit, use hard decision

- Bit ordering:
    u_hat[0] is packed as bit 0, LSB-first.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import random
from pathlib import Path
from typing import Dict, List, Sequence


def is_power_of_two(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0


def hard_decision(llr: int) -> int:
    """Return hard decision from LLR using project convention."""
    return 1 if llr < 0 else 0


def f_func(a: int, b: int) -> int:
    """Min-sum SC f function."""
    mag = min(abs(a), abs(b))
    negative = (a < 0) ^ (b < 0)
    return -mag if negative else mag


def g_func(a: int, b: int, u: int) -> int:
    """SC g function with project convention: b+a if u=0, b-a if u=1."""
    if u not in (0, 1):
        raise ValueError(f"u must be 0 or 1, got {u}")
    return b + a if u == 0 else b - a


def bits_to_int_lsb_first(bits: Sequence[int]) -> int:
    """Pack bits using LSB-first convention."""
    value = 0
    for i, bit in enumerate(bits):
        if bit not in (0, 1):
            raise ValueError(f"bit must be 0 or 1, got {bit}")
        value |= (bit << i)
    return value


def int_to_bits_lsb_first(value: int, n: int) -> List[int]:
    """Unpack integer into n bits using LSB-first convention."""
    if value < 0:
        raise ValueError("value must be non-negative")
    return [(value >> i) & 1 for i in range(n)]


def polar_encode(bits: Sequence[int]) -> List[int]:
    """
    Recursive Polar transform used for partial-sum generation.

    This matches the N=8 convention already used in the project:
        x0 = u0 ^ u1 ^ ... ^ u7
        x1 = u1 ^ u3 ^ u5 ^ u7
        x2 = u2 ^ u3 ^ u6 ^ u7
        x3 = u3 ^ u7
        x4 = u4 ^ u5 ^ u6 ^ u7
        x5 = u5 ^ u7
        x6 = u6 ^ u7
        x7 = u7
    """
    n = len(bits)
    if not is_power_of_two(n):
        raise ValueError(f"length must be a power of two, got {n}")

    clean_bits = [int(b) for b in bits]
    for b in clean_bits:
        if b not in (0, 1):
            raise ValueError(f"polar_encode expects bits 0/1, got {b}")

    if n == 1:
        return clean_bits[:]

    half = n // 2
    upper = [clean_bits[i] ^ clean_bits[i + half] for i in range(half)]
    lower = [clean_bits[i + half] for i in range(half)]

    return polar_encode(upper) + polar_encode(lower)


def sc_decode(llrs: Sequence[int], frozen_mask: Sequence[int]) -> List[int]:
    """
    Recursive SC decoder.

    llrs: signed integer LLRs
    frozen_mask: 1 means frozen, 0 means information bit
    """
    n = len(llrs)

    if n != len(frozen_mask):
        raise ValueError("llrs and frozen_mask must have the same length")

    if not is_power_of_two(n):
        raise ValueError(f"N must be a power of two, got {n}")

    llrs_i = [int(x) for x in llrs]
    mask_i = [int(x) for x in frozen_mask]

    for m in mask_i:
        if m not in (0, 1):
            raise ValueError(f"frozen mask must contain 0/1, got {m}")

    if n == 1:
        if mask_i[0] == 1:
            return [0]
        return [hard_decision(llrs_i[0])]

    half = n // 2

    left_llrs = [
        f_func(llrs_i[i], llrs_i[i + half])
        for i in range(half)
    ]

    u_left = sc_decode(left_llrs, mask_i[:half])

    partial = polar_encode(u_left)

    right_llrs = [
        g_func(llrs_i[i], llrs_i[i + half], partial[i])
        for i in range(half)
    ]

    u_right = sc_decode(right_llrs, mask_i[half:])

    return u_left + u_right


def polar_encode_n8_expanded(bits: Sequence[int]) -> List[int]:
    """Expanded N=8 equation check for convention consistency."""
    if len(bits) != 8:
        raise ValueError("polar_encode_n8_expanded expects 8 bits")

    u = [int(b) for b in bits]

    return [
        u[0] ^ u[1] ^ u[2] ^ u[3] ^ u[4] ^ u[5] ^ u[6] ^ u[7],
        u[1] ^ u[3] ^ u[5] ^ u[7],
        u[2] ^ u[3] ^ u[6] ^ u[7],
        u[3] ^ u[7],
        u[4] ^ u[5] ^ u[6] ^ u[7],
        u[5] ^ u[7],
        u[6] ^ u[7],
        u[7],
    ]


def operation_count(n: int) -> Dict[str, int]:
    """
    Estimate recursive SC operation counts for N.

    For N=16:
        f = 32
        g = 32
        hard decisions = 16
        partial XORs = 24
    """
    if not is_power_of_two(n):
        raise ValueError(f"N must be a power of two, got {n}")

    levels = int(math.log2(n))
    f_ops = (n // 2) * levels
    g_ops = (n // 2) * levels
    hard_decisions = n

    partial_xors = 0

    node_size = 2
    while node_size <= n:
        num_nodes = n // node_size
        left_len = node_size // 2

        if left_len >= 2:
            xors_per_partial_encode = (left_len // 2) * int(math.log2(left_len))
        else:
            xors_per_partial_encode = 0

        partial_xors += num_nodes * xors_per_partial_encode
        node_size *= 2

    return {
        "N": n,
        "levels": levels,
        "f_ops": f_ops,
        "g_ops": g_ops,
        "hard_decisions": hard_decisions,
        "partial_xors_est": partial_xors,
        "fg_ops_total": f_ops + g_ops,
        "fg_plus_hard_decisions": f_ops + g_ops + hard_decisions,
        "latency_lower_bound_cycles": f_ops + g_ops + hard_decisions,
        "latency_conservative_est_cycles": f_ops + g_ops + hard_decisions + partial_xors,
    }


def run_self_checks() -> None:
    """Run deterministic checks for convention consistency."""
    print("Project 8.1: SC Decoder N=16 Golden Model")
    print("Running self-checks...")

    # Check N=8 polar encode convention against expanded equations.
    for value in range(256):
        bits = int_to_bits_lsb_first(value, 8)
        rec = polar_encode(bits)
        exp = polar_encode_n8_expanded(bits)
        if rec != exp:
            raise AssertionError(
                f"N=8 polar_encode mismatch for value={value}: rec={rec}, exp={exp}"
            )

    print("[OK] polar_encode convention matches expanded N=8 equations.")

    # Compatibility checks inherited from Project 6.1 N=8.
    n8_tests = [
        {
            "name": "n8_all_zero_all_frozen",
            "llrs": [0, 0, 0, 0, 0, 0, 0, 0],
            "mask": [1, 1, 1, 1, 1, 1, 1, 1],
            "expected": [0, 0, 0, 0, 0, 0, 0, 0],
        },
        {
            "name": "n8_all_positive_all_info",
            "llrs": [4, 3, 2, 1, 4, 3, 2, 1],
            "mask": [0, 0, 0, 0, 0, 0, 0, 0],
            "expected": [0, 0, 0, 0, 0, 0, 0, 0],
        },
        {
            "name": "n8_mixed_all_info",
            "llrs": [-4, 3, 2, -1, 4, -3, 2, 1],
            "mask": [0, 0, 0, 0, 0, 0, 0, 0],
            "expected": [1, 0, 1, 1, 1, 1, 0, 0],
        },
        {
            "name": "n8_first_half_frozen",
            "llrs": [1, -2, 3, -4, -1, 2, -3, 4],
            "mask": [1, 1, 1, 1, 0, 0, 0, 0],
            "expected": [0, 0, 0, 0, 0, 0, 0, 0],
        },
    ]

    for item in n8_tests:
        got = sc_decode(item["llrs"], item["mask"])
        if got != item["expected"]:
            raise AssertionError(
                f"{item['name']} failed: got={got}, expected={item['expected']}"
            )

    print("[OK] N=8 compatibility checks passed.")

    # Deterministic N=16 examples.
    n16_tests = [
        {
            "name": "n16_all_zero_all_frozen",
            "llrs": [0] * 16,
            "mask": [1] * 16,
        },
        {
            "name": "n16_all_positive_all_info",
            "llrs": [4, 3, 2, 1, 5, 4, 3, 2, 4, 3, 2, 1, 5, 4, 3, 2],
            "mask": [0] * 16,
        },
        {
            "name": "n16_alternating_all_info",
            "llrs": [1, -2, 3, -4, 5, -6, 7, -8, -1, 2, -3, 4, -5, 6, -7, 8],
            "mask": [0] * 16,
        },
        {
            "name": "n16_first_half_frozen",
            "llrs": [1, -2, 3, -4, 5, -6, 7, -8, -1, 2, -3, 4, -5, 6, -7, 8],
            "mask": [1] * 8 + [0] * 8,
        },
    ]

    for item in n16_tests:
        u_hat = sc_decode(item["llrs"], item["mask"])
        u_hat_int = bits_to_int_lsb_first(u_hat)
        print(
            f"{item['name']}: "
            f"u_hat={u_hat}, u_hat_int={u_hat_int}"
        )

    counts = operation_count(16)
    print("[OK] N=16 operation count:")
    print(json.dumps(counts, indent=2))

    print("[OK] Self-checks completed.")


def generate_vectors(
    n: int,
    num_vectors: int,
    llr_min: int,
    llr_max: int,
    seed: int,
    csv_path: Path,
    summary_path: Path,
) -> None:
    """Generate random golden vectors for SC decoder."""
    if not is_power_of_two(n):
        raise ValueError(f"N must be a power of two, got {n}")

    if llr_min > llr_max:
        raise ValueError("llr_min must be <= llr_max")

    rng = random.Random(seed)

    csv_path.parent.mkdir(parents=True, exist_ok=True)
    summary_path.parent.mkdir(parents=True, exist_ok=True)

    header = (
        [f"llr{i}" for i in range(n)]
        + [f"frozen{i}" for i in range(n)]
        + [f"u_hat{i}" for i in range(n)]
        + ["frozen_mask_int", "u_hat_int"]
    )

    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)

        for _ in range(num_vectors):
            llrs = [rng.randint(llr_min, llr_max) for _ in range(n)]
            frozen_mask = [rng.randint(0, 1) for _ in range(n)]
            u_hat = sc_decode(llrs, frozen_mask)

            frozen_mask_int = bits_to_int_lsb_first(frozen_mask)
            u_hat_int = bits_to_int_lsb_first(u_hat)

            writer.writerow(llrs + frozen_mask + u_hat + [frozen_mask_int, u_hat_int])

    counts = operation_count(n)

    with summary_path.open("w", encoding="utf-8") as f:
        f.write("SC Decoder Golden Vector Summary\n")
        f.write("================================\n\n")
        f.write(f"N = {n}\n")
        f.write(f"num_vectors = {num_vectors}\n")
        f.write(f"llr_min = {llr_min}\n")
        f.write(f"llr_max = {llr_max}\n")
        f.write(f"seed = {seed}\n\n")

        f.write("Conventions\n")
        f.write("-----------\n")
        f.write("frozen_mask[i] = 1 means frozen; force u_i = 0\n")
        f.write("frozen_mask[i] = 0 means information bit\n")
        f.write("hard decision: LLR < 0 -> 1, otherwise 0\n")
        f.write("bit packing: LSB-first\n")
        f.write("g(a,b,u): b+a if u=0, b-a if u=1\n\n")

        f.write("Operation Count Estimate\n")
        f.write("------------------------\n")
        for key, value in counts.items():
            f.write(f"{key} = {value}\n")

        f.write("\nOutput Files\n")
        f.write("------------\n")
        f.write(f"csv_path = {csv_path}\n")
        f.write(f"summary_path = {summary_path}\n")

    print(f"[OK] Wrote vectors to {csv_path}")
    print(f"[OK] Wrote summary to {summary_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate SC Decoder N=16 golden vectors."
    )
    parser.add_argument("--n", type=int, default=16, help="Code length, power of two.")
    parser.add_argument("--num-vectors", type=int, default=1000)
    parser.add_argument("--llr-min", type=int, default=-8)
    parser.add_argument("--llr-max", type=int, default=8)
    parser.add_argument("--seed", type=int, default=20260503)
    parser.add_argument(
        "--csv",
        type=Path,
        default=Path("tests/golden_vectors/sc_decoder_n16_vectors.csv"),
    )
    parser.add_argument(
        "--summary",
        type=Path,
        default=Path("tests/golden_vectors/sc_decoder_n16_summary.txt"),
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    run_self_checks()

    print("Generating random golden vectors...")
    generate_vectors(
        n=args.n,
        num_vectors=args.num_vectors,
        llr_min=args.llr_min,
        llr_max=args.llr_max,
        seed=args.seed,
        csv_path=args.csv,
        summary_path=args.summary,
    )


if __name__ == "__main__":
    main()