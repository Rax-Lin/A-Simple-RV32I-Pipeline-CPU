/**
 * @file test.c
 * @brief A simple C program to test the basic functionality of the RV32I CPU.
 *
 * This program is the high-level language equivalent of the assembly code
 * in test.s and the machine code in program.txt. It is intended for
 * documentation and understanding purposes. Compiling this C file directly
 * with a standard RISC-V toolchain may not produce the exact same machine
 * code due to compiler optimizations.
 */

// This function is the entry point for bare-metal execution.
void _start() {
    // We use volatile to prevent the compiler from optimizing away variables
    // and memory accesses, making the behavior closer to the assembly code.
    volatile int reg1, reg2, reg3, reg4, reg5, reg6, reg7;

    // Corresponds to: addi x1, x0, 10
    reg1 = 10;

    // Corresponds to: addi x2, x0, 20
    reg2 = 20;

    // Corresponds to: add x3, x1, x2
    reg3 = reg1 + reg2; // Expected: reg3 = 30

    // This simulates storing to and loading from data memory address 0.
    // Corresponds to: sw x3, 0(x0) and lw x4, 0(x0)
    volatile int *mem_addr_zero = (int *)0;
    *mem_addr_zero = reg3;
    reg4 = *mem_addr_zero; // Expected: reg4 = 30

    // This tests the load-use hazard. The CPU should stall here.
    // Corresponds to: addi x5, x4, 5
    reg5 = reg4 + 5; // Expected: reg5 = 35

    // Corresponds to: addi x6, x0, 35
    reg6 = 35;

    // This tests a taken branch. The CPU should flush the next instruction.
    // Corresponds to: beq x5, x6, L1
    if (reg5 == reg6) {
        // Corresponds to: addi x7, x0, 1
        reg7 = 1; // Expected: reg7 = 1
    }

    // This tests an unconditional jump and the final loop.
    // Corresponds to: jal x0, END and beq x0, x0, END
    while(1) {
        // Infinite loop to halt the CPU for observation.
    }
}