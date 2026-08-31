
/*
 * Performs C[i] = sum_{j=0}^{A[i]} B[j] for each element of C,
 * use plain iterative for-loops O(N).
 *
 * Key observation: A[i] = i, so the upper bound of the summation is
 * always exactly the current index i. That means C[i] is just the
 * running total of B[0..i], and we can compute all of C in a single
 * O(N) pass by keeping a running sum as we go, instead of
 * recomputing the sum from scratch for every i (which would be O(N^2)).
 *
 * 
 * 
 */
 
#include <stdio.h>
#include <stdlib.h>
 
#define N 50000
 
/* Statically allocate arrays (global scope requires static storage duration).
 * Use long long because the  sum can grow to where it overflows regular int
 */

static int A[N];
static int B[N];
static long long C[N];
 
int main(void) {
    int i;
    long long checksum;
    long long expected = 41667916675000LL;
 
    /* Step 1: Initialize the arrays.
     *   A[i] = i
     *   B[i] = 50000 - i
     *   C[i] = 0
     */
    for (i = 0; i < N; i++) {
        B[i] = N - i;
        C[i] = 0;
    }
 
    /* Step 2: For every element C[i], compute C[i] = sum_{j=0}^{A[i]} B[j]. 
    Since A[i] == i for every i, this is equivalent to keeping a running total of B as we sweep through the array once:
    running_sum after processing index i == sum_{j=0}^{i} B[j]
    so we can set C[i] = running_sum directly, optimizing to get a single O(N) loop. */
    long long running_sum = 0;
    for (i = 0; i < N; i++) {
        running_sum += B[i];
        C[i] = running_sum;
    }
 
    /* Step 3: Compute the checksum as the sum of all elements in C,
     * using a simple iterative loop. */
    checksum = 0;
    for (i = 0; i < N; i++) {
        checksum += C[i];
    }
 
    /* check to see if checksum is the expected value validate it against the
     expected value. */
    printf("Checksum: %lld\n", checksum);
 
    if (checksum != expected) {
        fprintf(stderr,
                "Error: checksum mismatch. Expected %lld but got %lld\n",
                expected, checksum);
        return 1;
    }
 
    return 0;
}