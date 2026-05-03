#!/usr/bin/env python3
"""
Project 6.1: SC Decoder N=8 Behavioral/Golden Model

This script implements a golden reference model for an N=8 Polar SC decoder
using the min-sum approximation:

    f(a, b) = sign(a) sign(b) min(|a|, |b|)
    g(a, b, u) = b + a, if u = 0
                 b - a, if u = 1

Bit-order convention:
    u_hat[0] is decoded first.
    frozen_mask[i] = 1 means u_i is frozen and forced to 0.
"""

from __future__ import annotations

import csv
import random
from pathlib import Path
from typing import List, Sequence, Tuple


def f_func(a: int, b: int) -> int:
    """Min-sum SC f function."""
    mag = min(abs(a), abs(b))
    sign_negative = (a < 0) ^ (b < 0)
    return -mag if sign_negative else mag


def g_func(alpha: int, beta: int, u_hat: int) -> int:
    """SC g function."""
    if u_hat == 0:
        return beta + alpha
    return beta - alpha


def hard_decision(llr: int) -> int:
    """Hard decision rule for LLR."""
    return 1 if llr < 0 else 0


def polar_encode_n2(u: Sequence[int]) -> List[int]:
    """Polar transform for N=2: x = [u0 xor u1, u1]."""
    assert len(u) == 2
    return [u[0] ^ u[1], u[1]]


def polar_encode_n4(u: Sequence[int]) -> List[int]:
    """Polar transform for N=4 using the same convention as RTL Project 5."""
    assert len(u) == 4

    # Stage 1: distance = 1
    s1 = [0] * 4
    s1[0] = u[0] ^ u[1]
    s1[1] = u[1]
    s1[2] = u[2] ^ u[3]
    s1[3] = u[3]

    # Stage 2: distance = 2
    x = [0] * 4
    x[0] = s1[0] ^ s1[2]
    x[1] = s1[1] ^ s1[3]
    x[2] = s1[2]
    x[3] = s1[3]

    return x


def polar_encode_n8(u: Sequence[int]) -> List[int]:
    """Polar transform for N=8, consistent with Project 4 RTL."""
    assert len(u) == 8

    # Stage 1: distance = 1
    s1 = [0] * 8
    for base in range(0, 8, 2):
        s1[base] = u[base] ^ u[base + 1]
        s1[base + 1] = u[base + 1]

    # Stage 2: distance = 2
    s2 = [0] * 8
    for base in range(0, 8, 4):
        s2[base] = s1[base] ^ s1[base + 2]
        s2[base + 1] = s1[base + 1] ^ s1[base + 3]
        s2[base + 2] = s1[base + 2]
        s2[base + 3] = s1[base + 3]

    # Stage 3: distance = 4
    x = [0] * 8
    for i in range(4):
        x[i] = s2[i] ^ s2[i + 4]
        x[i + 4] = s2[i + 4]

    return x


def sc_decode_n2(llr: Sequence[int], frozen_mask: Sequence[int]) -> List[int]:
    """SC decoder for N=2."""
    assert len(llr) == 2
    assert len(frozen_mask) == 2

    left = f_func(llr[0], llr[1])

    if frozen_mask[0]:
        u0 = 0
    else:
        u0 = hard_decision(left)

    right = g_func(llr[0], llr[1], u0)

    if frozen_mask[1]:
        u1 = 0
    else:
        u1 = hard_decision(right)

    return [u0, u1]


def sc_decode_n4(llr: Sequence[int], frozen_mask: Sequence[int]) -> List[int]:
    """SC decoder for N=4, consistent with RTL Project 5."""
    assert len(llr) == 4
    assert len(frozen_mask) == 4

    left_llr = [
        f_func(llr[0], llr[2]),
        f_func(llr[1], llr[3]),
    ]

    u_left = sc_decode_n2(left_llr, frozen_mask[0:2])

    partial = polar_encode_n2(u_left)

    right_llr = [
        g_func(llr[0], llr[2], partial[0]),
        g_func(llr[1], llr[3], partial[1]),
    ]

    u_right = sc_decode_n2(right_llr, frozen_mask[2:4])

    return u_left + u_right


def sc_decode_n8(llr: Sequence[int], frozen_mask: Sequence[int]) -> List[int]:
    """SC decoder for N=8."""
    assert len(llr) == 8
    assert len(frozen_mask) == 8

    # Left branch LLRs: f(L[i], L[i+4])
    left_llr = [
        f_func(llr[0], llr[4]),
        f_func(llr[1], llr[5]),
        f_func(llr[2], llr[6]),
        f_func(llr[3], llr[7]),
    ]

    # Decode u0..u3
    u_left = sc_decode_n4(left_llr, frozen_mask[0:4])

    # Partial sums for left branch
    partial = polar_encode_n4(u_left)

    # Right branch LLRs: g(L[i], L[i+4], partial[i])
    right_llr = [
        g_func(llr[0], llr[4], partial[0]),
        g_func(llr[1], llr[5], partial[1]),
        g_func(llr[2], llr[6], partial[2]),
        g_func(llr[3], llr[7], partial[3]),
    ]

    # Decode u4..u7
    u_right = sc_decode_n4(right_llr, frozen_mask[4:8])

    return u_left + u_right


def bits_to_int_lsb_first(bits: Sequence[int]) -> int:
    """Convert [b0,b1,...] to integer with b0 as LSB."""
    value = 0
    for i, bit in enumerate(bits):
        value |= (int(bit) & 1) << i
    return value


def int_to_bits_lsb_first(value: int, n: int) -> List[int]:
    """Convert integer to [b0,b1,...,b_{n-1}]."""
    return [(value >> i) & 1 for i in range(n)]


def run_basic_tests() -> None:
    """Basic sanity tests."""
    test_cases = [
        ([0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1, 1, 1]),
        ([4, 3, 2, 1, 4, 3, 2, 1], [0, 0, 0, 0, 0, 0, 0, 0]),
        ([-4, 3, 2, -1, 4, -3, 2, 1], [0, 0, 0, 0, 0, 0, 0, 0]),
        ([1, -2, 3, -4, -1, 2, -3, 4], [1, 1, 1, 1, 0, 0, 0, 0]),
    ]

    for llr, mask in test_cases:
        u_hat = sc_decode_n8(llr, mask)
        print(f"LLR={llr}, mask={mask} -> u_hat={u_hat}, u_hat_int={bits_to_int_lsb_first(u_hat)}")

    print("[OK] Basic tests completed.")


def generate_random_vectors(
    num_vectors: int = 1000,
    llr_min: int = -8,
    llr_max: int = 8,
    seed: int = 20260503,
) -> List[Tuple[List[int], List[int], List[int]]]:
    """Generate random test vectors for future RTL verification."""
    random.seed(seed)
    vectors = []

    for _ in range(num_vectors):
        llr = [random.randint(llr_min, llr_max) for _ in range(8)]
        frozen_mask = [random.randint(0, 1) for _ in range(8)]
        u_hat = sc_decode_n8(llr, frozen_mask)
        vectors.append((llr, frozen_mask, u_hat))

    return vectors


def write_vectors_csv(vectors: List[Tuple[List[int], List[int], List[int]]], out_path: Path) -> None:
    """Write vectors to CSV."""
    out_path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = (
        [f"llr{i}" for i in range(8)]
        + [f"frozen{i}" for i in range(8)]
        + [f"u_hat{i}" for i in range(8)]
        + ["frozen_mask_int", "u_hat_int"]
    )

    with out_path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for llr, frozen_mask, u_hat in vectors:
            row = {}
            for i in range(8):
                row[f"llr{i}"] = llr[i]
                row[f"frozen{i}"] = frozen_mask[i]
                row[f"u_hat{i}"] = u_hat[i]

            row["frozen_mask_int"] = bits_to_int_lsb_first(frozen_mask)
            row["u_hat_int"] = bits_to_int_lsb_first(u_hat)

            writer.writerow(row)


def main() -> None:
    project_root = Path(__file__).resolve().parents[1]

    print("Project 6.1: SC Decoder N=8 Golden Model")
    print("Running basic tests...")
    run_basic_tests()

    print("Generating random golden vectors...")
    vectors = generate_random_vectors(num_vectors=1000)

    out_csv = project_root / "tests/golden_vectors/sc_decoder_n8_vectors.csv"
    write_vectors_csv(vectors, out_csv)

    summary_file = project_root / "tests/golden_vectors/sc_decoder_n8_summary.txt"
    with summary_file.open("w") as f:
        f.write("Project 6.1: SC Decoder N=8 Golden Model\n")
        f.write("Number of random vectors: 1000\n")
        f.write("LLR range: -8 to +8\n")
        f.write("Frozen-mask convention: 1 means frozen bit forced to zero\n")
        f.write("Bit order: u_hat[0] is LSB / first decoded bit\n")

    print(f"[OK] Wrote vectors to {out_csv}")
    print(f"[OK] Wrote summary to {summary_file}")


if __name__ == "__main__":
    main()