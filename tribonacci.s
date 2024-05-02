.data
    prompt: .asciiz "Please enter an integer value for N:"
    newline: .asciiz "\n"

.text
.align 2

.globl main
main:
    # No stack pointers needed since program is only using for loop and no function calls
    
    # Load the values for T_1, T_2, T_3 into the t registers
    li $t0, 1 # T_1 = 1
    li $t1, 1 # T_2 = 1
    li $t2, 2 # T_3 = 2

    # Initialize counter outside of loop to break once Nth number reached
    li $t3, 0

    # Print prompt (string)
    li $v0, 4
    la $a0, prompt
    syscall

    # Read user input (integer)
    li $v0, 5
    syscall
    move $a1, $v0

    # The user enters newline after their input (otherwise QtSpim didn't work)

_for_loop:
    # Check loop condition
    slt $t4, $t3, $a1 # Sets $t4 = 1 if counter < input N, else = 0
    beqz $t4, _exit # Break if $t4 = 0

    # Print tribonacci number (integer)
    move $a0, $t0
    li $v0, 1
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # Make the tribonacci number
    add $t5, $t0, $t1
    add $t5, $t5, $t2

    # Update registers with new values
    move $t0, $t1
    move $t1, $t2
    move $t2, $t5

    # Increment loop counter
    add $t3, $t3, 1

    j _for_loop

_exit:
    # Return (prohibited from using exit syscall)
    jr $ra

.end main
