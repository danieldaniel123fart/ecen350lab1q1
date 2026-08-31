#include <stdio.h>

#define SIZE 50000
#define EXPECTED_CHECKSUM 41667916675000LL

/* Static allocation keeps the arrays out of the stack and avoids malloc. */
static int A[SIZE];
static int B[SIZE];
static int C[SIZE];

int main(void) {
    long long checksum = 0;

    /* Initialize the input and result arrays. */
    for (int i = 0; i < SIZE; i++) {
        A[i] = i;
        B[i] = SIZE - i;
        C[i] = 0;
    }

    /* C[i] is the sum of B[0] through B[A[i]], inclusive. */
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j <= A[i]; j++) {
            C[i] += B[j];
        }
    }

    /* Add every element of C to produce the checksum. */
    for (int i = 0; i < SIZE; i++) {
        checksum += C[i];
    }

    /* Print and verify the checksum required by the assignment. */
    printf("Checksum: %lld\n", checksum);
    if (checksum != EXPECTED_CHECKSUM) {
        fprintf(stderr, "Error: checksum does not match the expected value.\n");
        return 1;
    }

    return 0;
}
