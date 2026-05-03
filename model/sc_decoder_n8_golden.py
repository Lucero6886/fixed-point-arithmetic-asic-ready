#!/usr/bin/env python3

import csv
import random
from pathlib import Path


def f_func(a, b):
    mag = min(abs(a), abs(b))
    return -mag if ((a < 0) ^ (b < 0)) else mag


def g_func(alpha, beta, u_hat):
    return beta + alpha if u_hat == 0 else beta - alpha


def hard_decision(llr):
    return 1 if llr < 0 else 0


def polar_encode_n2(u):
    return [u[0] ^ u[1], u[1]]


def polar_encode_n4(u):
    s1 = [0] * 4
    s1[0] = u[0] ^ u[1]
    s1[1] = u[1]
    s1[2] = u[2] ^ u[3]
    s1[3] = u[3]

    x = [0] * 4
    x[0] = s1[0] ^ s1[2]
    x[1] = s1[1] ^ s1[3]
    x[2] = s1[2]
    x[3] = s1[3]
    return x


def sc_decode_n2(llr, frozen_mask):
    u0_llr = f_func(llr[0], llr[1])
    u0 = 0 if frozen_mask[0] else hard_decision(u0_llr)

    u1_llr = g_func(llr[0], llr[1], u0)
    u1 = 0 if frozen_mask[1] else hard_decision(u1_llr)

    return [u0, u1]


def sc_decode_n4(llr, frozen_mask):
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


def sc_decode_n8(llr, frozen_mask):
    left_llr = [
        f_func(llr[0], llr[4]),
        f_func(llr[1], llr[5]),
        f_func(llr[2], llr[6]),
        f_func(llr[3], llr[7]),
    ]

    u_left = sc_decode_n4(left_llr, frozen_mask[0:4])
    partial = polar_encode_n4(u_left)

    right_llr = [
        g_func(llr[0], llr[4], partial[0]),
        g_func(llr[1], llr[5], partial[1]),
        g_func(llr[2], llr[6], partial[2]),
        g_func(llr[3], llr[7], partial[3]),
    ]

    u_right = sc_decode_n4(right_llr, frozen_mask[4:8])
    return u_left + u_right


def bits_to_int_lsb_first(bits):
    value = 0
    for i, bit in enumerate(bits):
        value |= (int(bit) & 1) << i
    return value


def generate_vectors(num_vectors=1000, llr_min=-8, llr_max=8, seed=20260503):
    random.seed(seed)
    vectors = []

    for _ in range(num_vectors):
        llr = [random.randint(llr_min, llr_max) for _ in range(8)]
        frozen_mask = [random.randint(0, 1) for _ in range(8)]
        u_hat = sc_decode_n8(llr, frozen_mask)
        vectors.append((llr, frozen_mask, u_hat))

    return vectors


def write_vectors_csv(vectors, out_path):
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


def main():
    project_root = Path(__file__).resolve().parents[1]

    print("Project 6.1: SC Decoder N=8 Golden Model")
    print("Running basic tests...")

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

    vectors = generate_vectors(num_vectors=1000)

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