.section .text
.globl _start

_start:
    # Setup: Load an initial value into a0 (x10), which is the first argument register.
    # PC = 0x00
    li      a0, 10          # a0 = 10

    # Call the function 'add_five'.
    # 'jal ra, add_five' will do two things:
    # 1. Store the return address (PC+4, which is 0x08) into ra (x1).
    # 2. Jump to the 'add_five' label (PC = 0x10).
    # PC = 0x04
    jal     ra, add_five

    # This is the return point. This instruction should be executed after 'add_five' returns.
    # The result from the function is in a0 (x10).
    # PC = 0x08
    add     a1, a0, x0      # a1 = a0 (result)

END:
    # PC = 0x0C
    beq     x0, x0, END     # Infinite loop to end the program.

add_five:
    # This is the function body. It takes an argument in a0.
    # PC = 0x10
    addi    a0, a0, 5       # a0 = a0 + 5
    # PC = 0x14
    jalr    x0, 0(ra)       # Return to the address stored in ra (x1).