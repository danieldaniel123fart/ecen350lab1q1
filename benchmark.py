"""Benchmark program for ECEN 350 Lab 1."""

SIZE = 50000
EXPECTED_CHECKSUM = 41667916675000


def main():
    # Initialize the three 50,000-element arrays.
    A = [i for i in range(SIZE)]
    B = [SIZE - i for i in range(SIZE)]
    C = [0] * SIZE

    # C[i] is the sum of B[0] through B[A[i]], inclusive.
    for i in range(SIZE):
        for j in range(A[i] + 1):
            C[i] += B[j]

    # Add all values in C to form the checksum.
    checksum = sum(C)
    print(f"Checksum: {checksum}")

    # Verify the result and return a nonzero status on failure.
    if checksum != EXPECTED_CHECKSUM:
        print("Error: checksum does not match the expected value.")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
