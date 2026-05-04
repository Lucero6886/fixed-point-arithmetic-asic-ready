# Project 6.1: SC Decoder N=8 Golden Model

## 1. Project Objective

Project 6.1 builds the Python golden model for a Successive Cancellation Decoder with code length N=8.

The main objective is to create a trusted software reference before writing or verifying the RTL SC Decoder N=8.

The golden model receives:

```text
LLR[0:7]
frozen_mask[0:7]
```

and produces:

```text
u_hat[0:7]
```

The golden model is used to generate test vectors for RTL verification in later projects.

At the end of this project, the learner should understand:

```text
how SC decoding extends from N=4 to N=8
how the recursive f/g schedule works
how frozen bits are handled
how partial sums are generated for the right branch
why a golden model must be created before RTL
how to generate CSV vectors for Verilog testbenches
```

---

## 2. Why This Project Is Important

Project 5 already implemented a complete SC Decoder N=4.

Project 6 moves to SC Decoder N=8.

N=8 is significantly more complex than N=4 because it contains:

```text
more LLR inputs
more f operations
more g operations
more partial sums
larger frozen mask
larger output vector
more possible bit-order mistakes
more internal intermediate values
```

Writing RTL directly without a trusted reference is risky.

Possible errors include:

```text
wrong f/g schedule
wrong partial-sum mapping
wrong frozen-mask convention
wrong hard-decision rule
wrong bit ordering
wrong LLR index mapping
wrong u_hat packing
```

Therefore, Project 6.1 builds the Python golden model first.

The central question of this project is:

```text
Can we create a reliable software reference model for SC Decoder N=8 and generate golden vectors for RTL verification?
```

---

## 3. Position In The Roadmap

The roadmap up to this point is:

```text
Project 0: RTL-to-GDSII counter baseline
Project 1.1: signed adder
Project 1.2: signed subtractor
Project 1.3: absolute value unit
Project 1.4: minimum comparator
Project 1.5: absolute-minimum unit
Project 2: SC f unit
Project 3: SC g unit
Project 4: Polar Encoder N=8
Project 5: SC Decoder N=4
Project 5.5: Encoder/decoder comparison
Project 6.1: SC Decoder N=8 golden model
```

Project 6.1 is the first step in the N=8 decoder development flow.

The planned Project 6 sequence is:

```text
Project 6.1: SC Decoder N=8 golden model
Project 6.2: SC Decoder N=8 RTL baseline
Project 6.3: SC Decoder N=8 synthesis and complexity study
Project 6.4: SC Decoder N=8 OpenLane clean baseline
```

---

## 4. Why A Golden Model Is Required

A golden model is a trusted reference implementation.

For this project, the golden model is written in Python because Python is easier to inspect, debug, and modify than Verilog RTL.

The golden model is used to answer:

```text
For a given LLR vector and frozen mask, what should the correct u_hat output be?
```

The RTL decoder is considered correct only if it matches the golden model over many test vectors.

The verification chain is:

```text
Python golden model
→ generated CSV test vectors
→ Verilog testbench reads CSV
→ RTL decoder produces u_hat
→ testbench compares RTL u_hat with golden u_hat
```

This prevents the RTL from being verified only by manual inspection.

---

## 5. SC Decoder N=8 Inputs And Outputs

The N=8 decoder receives eight LLR inputs:

```text
llr0, llr1, llr2, llr3, llr4, llr5, llr6, llr7
```

It also receives an 8-bit frozen mask:

```text
frozen0, frozen1, frozen2, frozen3, frozen4, frozen5, frozen6, frozen7
```

The output is the estimated source vector:

```text
u_hat0, u_hat1, u_hat2, u_hat3, u_hat4, u_hat5, u_hat6, u_hat7
```

The CSV vector file contains:

```text
llr0..llr7
frozen0..frozen7
u_hat0..u_hat7
frozen_mask_int
u_hat_int
```

---

## 6. Frozen-Mask Convention

This project uses the same convention as previous decoder projects:

```text
frozen_mask[i] = 1 → u_i is frozen and forced to 0
frozen_mask[i] = 0 → u_i is an information bit
```

For each decoded bit:

```text
if frozen_mask[i] = 1:
    u_hat[i] = 0
else:
    u_hat[i] = hard_decision(LLR)
```

The hard decision rule is:

```text
if LLR < 0:
    bit = 1
else:
    bit = 0
```

This convention must remain consistent across:

```text
Python model
generated CSV file
Verilog RTL
Verilog testbench
documentation
```

---

## 7. Bit-Ordering Convention

This roadmap uses the following bit-ordering convention:

```text
u_hat[0] is decoded first.
u_hat[1] is decoded second.
...
u_hat[7] is decoded last.
```

The integer representation uses LSB-first packing:

```text
u_hat_int = u_hat0 * 2^0
          + u_hat1 * 2^1
          + u_hat2 * 2^2
          + ...
          + u_hat7 * 2^7
```

Similarly:

```text
frozen_mask_int = frozen0 * 2^0
                + frozen1 * 2^1
                + ...
                + frozen7 * 2^7
```

This convention is important because mismatch between LSB-first and MSB-first packing can cause false verification failures.

---

## 8. SC f And g Functions

The golden model uses the same min-sum f function as the RTL roadmap.

### 8.1 f Function

The f function is:

```text
f(a,b) = sign(a) sign(b) min(|a|, |b|)
```

In Python:

```text
mag = min(abs(a), abs(b))
sign_negative = (a < 0) XOR (b < 0)

if sign_negative:
    f = -mag
else:
    f = mag
```

### 8.2 g Function

The g function is:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

In Python:

```text
if u == 0:
    g = b + a
else:
    g = b - a
```

These two functions are the core of the SC decoding algorithm.

---

## 9. Polar Partial-Sum Convention

The SC decoder needs partial sums before computing the right branch.

The partial sums are generated using the same recursive Polar transform used in the encoder.

For N=4:

```text
partial0 = u0 ^ u1 ^ u2 ^ u3
partial1 = u1 ^ u3
partial2 = u2 ^ u3
partial3 = u3
```

For the N=8 top-level split, after decoding the left N=4 branch:

```text
u_left = [u0, u1, u2, u3]
```

the decoder computes:

```text
partial = polar_encode_N4(u_left)
```

Then the partial bits are used in the top-level g operations:

```text
right_llr[i] = g(llr[i], llr[i+4], partial[i])
```

for:

```text
i = 0, 1, 2, 3
```

This is one of the most important details in the N=8 decoder.

---

## 10. Recursive SC Decoding Rule

The golden model uses a recursive SC decoder.

For a node of size N:

```text
1. If N = 1:
       decide the bit using frozen mask and hard decision.

2. If N > 1:
       compute left LLRs using f
       recursively decode the left child
       compute partial sums from left decisions
       compute right LLRs using g
       recursively decode the right child
       concatenate left and right decisions
```

In pseudocode:

```text
SC_Decode(llrs, frozen_mask):

    if length(llrs) == 1:
        if frozen_mask[0] == 1:
            return [0]
        else:
            return [hard_decision(llrs[0])]

    half = N / 2

    left_llrs[i] = f(llrs[i], llrs[i+half])

    u_left = SC_Decode(left_llrs, frozen_mask_left)

    partial = Polar_Encode(u_left)

    right_llrs[i] = g(llrs[i], llrs[i+half], partial[i])

    u_right = SC_Decode(right_llrs, frozen_mask_right)

    return u_left + u_right
```

This recursive structure is clean and scalable to larger N.

---

## 11. N=8 Top-Level Schedule

For N=8, the top-level schedule is:

```text
Input LLRs:
L0, L1, L2, L3, L4, L5, L6, L7
```

### Step 1: Compute Left N=4 LLRs

```text
left0 = f(L0, L4)
left1 = f(L1, L5)
left2 = f(L2, L6)
left3 = f(L3, L7)
```

### Step 2: Decode Left N=4 Branch

```text
[u0, u1, u2, u3] = SC_Decode_N4(left0, left1, left2, left3)
```

using:

```text
frozen_mask[0:3]
```

### Step 3: Generate Partial Sums

```text
partial = Polar_Encode_N4([u0, u1, u2, u3])
```

Expanded:

```text
partial0 = u0 ^ u1 ^ u2 ^ u3
partial1 = u1 ^ u3
partial2 = u2 ^ u3
partial3 = u3
```

### Step 4: Compute Right N=4 LLRs

```text
right0 = g(L0, L4, partial0)
right1 = g(L1, L5, partial1)
right2 = g(L2, L6, partial2)
right3 = g(L3, L7, partial3)
```

### Step 5: Decode Right N=4 Branch

```text
[u4, u5, u6, u7] = SC_Decode_N4(right0, right1, right2, right3)
```

using:

```text
frozen_mask[4:7]
```

### Step 6: Output

```text
u_hat = [u0, u1, u2, u3, u4, u5, u6, u7]
```

---

## 12. Expected File Structure

The expected file structure for Project 6.1 is:

```text
model/
  sc_decoder_n8_golden.py

tests/
  golden_vectors/
    sc_decoder_n8_vectors.csv
    sc_decoder_n8_summary.txt

results/
  summary/
    optional schedule or statistics files

docs/
  project6_1/
    sc_decoder_n8_golden_model.md
```

The most important generated file is:

```text
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

This file will be used by the Verilog testbench in Project 6.2.

---

## 13. Python Golden Model Structure

The Python golden model should contain the following functions:

```text
hard_decision(llr)
f_func(a, b)
g_func(a, b, u)
polar_encode(u)
sc_decode(llrs, frozen_mask)
bits_to_int_lsb_first(bits)
generate_vectors(...)
run_basic_tests()
main()
```

Each function has a clear role.

### 13.1 hard_decision

```text
LLR < 0 → 1
LLR >= 0 → 0
```

### 13.2 f_func

Computes the min-sum f operation.

### 13.3 g_func

Computes the conditional add/subtract g operation.

### 13.4 polar_encode

Generates partial sums using the recursive Polar transform.

### 13.5 sc_decode

Runs recursive SC decoding.

### 13.6 generate_vectors

Generates random LLR/frozen-mask test cases and writes expected outputs to CSV.

---

## 14. Basic Test Cases

The golden model should first run simple test cases before generating random vectors.

Example test cases include:

```text
1. All LLRs are zero and all bits are frozen.
2. All LLRs are positive and all bits are information.
3. Mixed positive/negative LLRs and all bits are information.
4. Some frozen bits and some information bits.
```

These tests are useful because they help identify convention errors before generating a large CSV file.

---

## 15. Confirmed Basic Test Output

The following basic tests were observed:

```text
Project 6.1: SC Decoder N=8 Golden Model
Running basic tests...
LLR=[0, 0, 0, 0, 0, 0, 0, 0], mask=[1, 1, 1, 1, 1, 1, 1, 1] -> u_hat=[0, 0, 0, 0, 0, 0, 0, 0], u_hat_int=0
LLR=[4, 3, 2, 1, 4, 3, 2, 1], mask=[0, 0, 0, 0, 0, 0, 0, 0] -> u_hat=[0, 0, 0, 0, 0, 0, 0, 0], u_hat_int=0
LLR=[-4, 3, 2, -1, 4, -3, 2, 1], mask=[0, 0, 0, 0, 0, 0, 0, 0] -> u_hat=[1, 0, 1, 1, 1, 1, 0, 0], u_hat_int=61
LLR=[1, -2, 3, -4, -1, 2, -3, 4], mask=[1, 1, 1, 1, 0, 0, 0, 0] -> u_hat=[0, 0, 0, 0, 0, 0, 0, 0], u_hat_int=0
[OK] Basic tests completed.
```

These cases confirm that the model handles frozen masks, hard decisions, and recursive decoding.

---

## 16. Golden Vector Generation

After the basic tests pass, the model generates random test vectors.

The generated CSV file is:

```text
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

The generated summary file is:

```text
tests/golden_vectors/sc_decoder_n8_summary.txt
```

A typical command is:

```bash
python3 model/sc_decoder_n8_golden.py
```

or, if arguments are supported:

```bash
python3 model/sc_decoder_n8_golden.py --num-vectors 1000 --llr-min -8 --llr-max 8
```

The exact command depends on the current Python file implementation.

---

## 17. Confirmed Golden Vector Output

The confirmed generated output was:

```text
Generating random golden vectors...
[OK] Wrote vectors to /home/lucero/ic_design_projects/fixed_point_arithmetic_asic_ready/tests/golden_vectors/sc_decoder_n8_vectors.csv
[OK] Wrote summary to /home/lucero/ic_design_projects/fixed_point_arithmetic_asic_ready/tests/golden_vectors/sc_decoder_n8_summary.txt
```

The vector file begins with the header:

```text
llr0,llr1,llr2,llr3,llr4,llr5,llr6,llr7,frozen0,frozen1,frozen2,frozen3,frozen4,frozen5,frozen6,frozen7,u_hat0,u_hat1,u_hat2,u_hat3,u_hat4,u_hat5,u_hat6,u_hat7,frozen_mask_int,u_hat_int
```

Example vector line:

```text
-1,-8,4,8,-7,-6,-3,7,0,0,0,1,1,0,1,1,1,0,1,0,0,1,0,0,216,37
```

This means:

```text
LLRs:
[-1, -8, 4, 8, -7, -6, -3, 7]

Frozen mask:
[0, 0, 0, 1, 1, 0, 1, 1]

Expected u_hat:
[1, 0, 1, 0, 0, 1, 0, 0]

frozen_mask_int = 216
u_hat_int = 37
```

---

## 18. CSV File Format

Each row in the CSV file has:

```text
8 LLR values
8 frozen-mask bits
8 expected decoded bits
1 frozen-mask integer
1 u_hat integer
```

Column groups:

```text
llr0..llr7
frozen0..frozen7
u_hat0..u_hat7
frozen_mask_int
u_hat_int
```

This format is designed to be easy for a Verilog testbench to parse using `$fscanf`.

---

## 19. Why CSV Vectors Are Useful

CSV golden vectors allow the same reference data to be reused by:

```text
Verilog RTL testbench
future Python analysis scripts
debug scripts
documentation examples
regression tests
```

This creates a reproducible verification flow.

Instead of manually writing test cases in the Verilog testbench, the testbench reads the golden file.

The advantage is:

```text
the Python model remains the single source of truth
the RTL can be tested against many cases automatically
the same vectors can be reused after RTL changes
```

---

## 20. Expected Python Script Location

The Python golden model should be stored at:

```text
model/sc_decoder_n8_golden.py
```

If the script is accidentally placed in another folder, later scripts may fail to find it.

The recommended command should be run from the repository root:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready
python3 model/sc_decoder_n8_golden.py
```

This ensures that generated files are placed in:

```text
tests/golden_vectors/
```

---

## 21. Common File Path Issue

A previous issue occurred when the golden vector file could not be found:

```text
ERROR: Cannot open tests/golden_vectors/sc_decoder_n8_vectors.csv
```

This usually means one of the following:

```text
the Python model was not run
the file was generated in a wrong directory
the tests/golden_vectors folder did not exist
the simulation was run from a different working directory
```

Recommended fix:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready
mkdir -p tests/golden_vectors
python3 model/sc_decoder_n8_golden.py
ls -lh tests/golden_vectors/sc_decoder_n8_vectors.csv
```

The Verilog simulation should also be run from the repository root unless the script changes directory internally.

---

## 22. Validation Checklist For Project 6.1

Project 6.1 is complete if the following are true:

```text
model/sc_decoder_n8_golden.py exists
tests/golden_vectors/sc_decoder_n8_vectors.csv exists
tests/golden_vectors/sc_decoder_n8_summary.txt exists
basic tests pass
random golden vectors are generated
CSV header is correct
CSV rows contain LLR, frozen mask, u_hat, and integer summaries
bit-order convention is documented
frozen-mask convention is documented
```

Recommended commands:

```bash
cd ~/ic_design_projects/fixed_point_arithmetic_asic_ready

ls -lh model/sc_decoder_n8_golden.py
ls -lh tests/golden_vectors/sc_decoder_n8_vectors.csv
ls -lh tests/golden_vectors/sc_decoder_n8_summary.txt

head -5 tests/golden_vectors/sc_decoder_n8_vectors.csv
wc -l tests/golden_vectors/sc_decoder_n8_vectors.csv
```

---

## 23. Expected Number Of Lines

If the script generates 1000 vectors, the CSV file should contain:

```text
1001 lines
```

because:

```text
1 header line
1000 vector lines
```

Check with:

```bash
wc -l tests/golden_vectors/sc_decoder_n8_vectors.csv
```

If the output is:

```text
1001 tests/golden_vectors/sc_decoder_n8_vectors.csv
```

then the file has the expected number of lines.

---

## 24. Interpretation Of Project 6.1 Result

Project 6.1 does not produce RTL yet.

It produces the reference model and verification data for later RTL.

The important result is not a GDSII file or synthesis report.

The important result is:

```text
a trusted SC Decoder N=8 reference
a generated golden-vector dataset
a clear convention for bit order and frozen mask
```

This project reduces risk before writing Verilog.

---

## 25. Difference Between N=4 And N=8 Decoder

Compared with N=4, the N=8 decoder has:

```text
twice as many input LLRs
twice as many output bits
a larger frozen mask
a top-level N=8 split into two N=4 branches
more partial sums
more f/g operations
more chances for mapping errors
```

N=4 can be manually checked relatively easily.

N=8 should use a golden model and vector-based verification.

---

## 26. Why N=8 Is A Major Step

N=8 is the first size where the decoder begins to show clear architectural complexity.

It is still small enough to implement and debug, but large enough to demonstrate:

```text
recursive SC decoding
reuse of N=4 decoder structure
partial-sum generation
top-level f/g stages
larger verification dataset
future synthesis and OpenLane comparison
```

Therefore, N=8 is a good architecture exploration point before moving to N=16.

---

## 27. Common Mistakes And Debugging

### Mistake 1: Reversing Frozen Mask Meaning

Correct convention:

```text
1 = frozen
0 = information
```

If this is reversed, many outputs will be wrong.

---

### Mistake 2: Wrong Hard Decision Rule

Correct rule:

```text
LLR < 0 → 1
LLR >= 0 → 0
```

---

### Mistake 3: Wrong Partial Sum

For top-level N=8 right branch, the partial sums must come from:

```text
Polar_Encode_N4(u_left)
```

not simply:

```text
u_left
```

---

### Mistake 4: Wrong g Input Order

Correct g function:

```text
g(a,b,u) = b + a, if u = 0
g(a,b,u) = b - a, if u = 1
```

The order `b - a` is important.

---

### Mistake 5: Wrong CSV Location

The RTL testbench expects:

```text
tests/golden_vectors/sc_decoder_n8_vectors.csv
```

If the file is missing, regenerate it from the repository root.

---

### Mistake 6: Wrong Integer Packing

The project uses LSB-first packing:

```text
bit i contributes 2^i
```

If MSB-first packing is used accidentally, `u_hat_int` will not match.

---

## 28. Lessons Learned

Project 6.1 teaches the following key lessons:

```text
1. A golden model is essential before implementing a larger SC decoder.
2. N=8 introduces enough complexity that manual verification is risky.
3. The recursive SC algorithm maps naturally to Python.
4. Frozen-mask convention must be fixed early.
5. Bit-order convention must be fixed early.
6. Partial sums must follow the Polar transform.
7. CSV-based golden vectors provide a reusable RTL verification method.
8. The golden model becomes the single source of truth for Project 6.2.
```

---

## 29. Role Of This Project In The Full Roadmap

Project 6.1 belongs to the SC Decoder N=8 baseline layer.

It prepares:

```text
Project 6.2: RTL SC Decoder N=8
Project 6.3: Yosys synthesis study
Project 6.4: OpenLane baseline
Project 7.1: scheduled N=8 decoder
Project 7.3: resource-shared N=8 decoder
```

Without Project 6.1, later RTL verification would be much less reliable.

---

## 30. What This Project Is Not

Project 6.1 is not an RTL implementation project.

It should not be presented as:

```text
a hardware architecture
a synthesized decoder
an OpenLane result
a physical implementation milestone
```

Instead, it should be presented as:

```text
a golden-reference modeling project
a verification preparation project
a required foundation for RTL decoder development
```

---

## 31. Conclusion

Project 6.1 builds the Python golden model for SC Decoder N=8.

It defines the key conventions:

```text
frozen_mask[i] = 1 means frozen
LLR < 0 means hard decision 1
u_hat is packed LSB-first
partial sums are generated using the recursive Polar transform
```

The project generates:

```text
tests/golden_vectors/sc_decoder_n8_vectors.csv
tests/golden_vectors/sc_decoder_n8_summary.txt
```

These files are used in Project 6.2 to verify the RTL SC Decoder N=8.

The next step is Project 6.2: SC Decoder N=8 RTL Baseline.