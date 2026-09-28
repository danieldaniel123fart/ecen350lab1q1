/*
 * lab04b.S
 * long long power(long long base, long long exp):
 *   if (exp == 0) return 1;
 *   return my_mul(base, power(base, exp - 1));
 *
 * X19 = base, X20 = exp, X21 = scratch (all callee-saved, saved on stack)
 * X30 (LR) saved/restored around each BL since BL overwrites it.
 */

    .global power
    .extern my_mul

    .text
power:
    // save regs we use
    stp     x30, x19, [sp, #-16]!
    stp     x20, x21, [sp, #-16]!

    mov     x19, x0                 // x19 = base
    mov     x20, x1                 // x20 = exp

    // base case
    cmp     x20, #0
    b.ne    power_recurse
    mov     x0, #1
    b       power_done

power_recurse:
    // power(base, exp - 1)
    mov     x0, x19
    sub     x1, x20, #1
    bl      power
    mov     x21, x0                 // save result before my_mul call

    // my_mul(base, result)
    mov     x0, x19
    mov     x1, x21
    bl      my_mul

power_done:
    // restore regs and return
    ldp     x20, x21, [sp], #16
    ldp     x30, x19, [sp], #16
    br      lr