/**
 * @file function_call.c
 * @brief A simple C program to test function calls (jal/jalr).
 *
 * This program is the high-level language equivalent for function_call.s.
 * It is intended for documentation and understanding purposes.
 */

// Define a simple function to be called.
// In assembly, this will be a label.
int add_five(int a) {
    return a + 5;
}

// This function is the entry point for bare-metal execution.
void _start() {
    volatile int input_val = 10;
    volatile int result;

    // This corresponds to calling the 'add_five' function.
    // The 'jal' instruction will jump to the function and store the
    // return address in the link register (ra, x1).
    result = add_five(input_val);

    // After the function returns (using 'jalr'), the program continues here.
    // We expect 'result' to be 15.

    // Infinite loop to halt the CPU for observation.
    while(1) {
        // Loop forever.
    }
}