.data
    prompt: .asciiz "Please enter a positive integer value for N:"
    newline: .asciiz "\n"

.text
.align 2

.globl main
main:
    # Sets up the stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Print prompt (string)
    li $v0, 4
    la $a0, prompt
    syscall

    # Read user input (integer)
    li $v0, 5
    syscall
    move $a1, $v0

    # Call rescursive function
    jal recurse

    # Print final answer
    move $a0, $v0
    li $v0, 1
    syscall

    # Puts the stack back to normal
    lw $ra, 0($sp)
    addi $sp, $sp, 4

_exit_main:
    jr $ra


# Recall user input stored in $a1, $a0 can be overwritten
recurse:
    # Open frame for $sp on function call
    addi $sp, $sp, -4   
    sw $ra, 0($sp)
    
    # Base case f(N = 0) = 2
    li $v0, 2
    beqz $a1, _exit_recurse

    # Storing value of N
    move $t0, $a1

    # Decrement N for recursive call
    addi $a1, $a1, -1  

    # Stack to store value of N through recurse call
    addi $sp, $sp, -4 
    sw $t0, 0($sp)

    jal recurse

    # Mirror/close stack
    lw $t0, 0($sp)
    addi $sp, $sp, 4

    # Store the recursive call
    move $t4, $v0

    # Calculating the function: 3*N - 2*recurse(N-1) + 7 = T1 - T2 + 7
    li $t1, 3
    mul $t2, $t1, $t0 # 3 * N

    li $t1, 2
    mul $t3, $t1, $t4 # 2 * recurse(N-1)

    sub $v0, $t2, $t3 # 3*N - 2*recurse(N-1)
    addi $v0, $v0, 7 # 3*N - 2*(N-1) + 7

_exit_recurse:
    # Puts the stack back to normal
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

.end main
