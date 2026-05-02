/**
 * @file test_compiled.s
 * @brief A hypothetical assembly output from compiling test.c with optimizations.
 *
 * This file demonstrates how a real compiler would optimize the C code,
 * which is why we use hand-written assembly for targeted hardware testing.
 */

.section .text
.globl _start
_start:
    # The compiler sees that reg1, reg2, reg3 are temporary and can be optimized.
    # It calculates reg3 = 30 at compile time.
    li      a0, 30          # a0 (x10) = 30

    # The volatile keyword forces the compiler to perform the memory operations.
    sw      a0, 0(x0)       # Store 30 to memory address 0

    # The compiler knows the 'if (reg5 == reg6)' is always true,
    # so it directly sets the result for reg7 and enters the loop.
    li      a1, 1           # a1 (x11) = 1. This corresponds to reg7.

END:
    j       END             # Infinite loop (j is a pseudoinstruction for jal x0, offset)