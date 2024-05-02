.data
    prompt_name: .asciiz "Player name:"
    prompt_pluspt: .asciiz "Points team scored:"
    prompt_minuspt: .asciiz "Points opponent scored:"
    done: .asciiz "DONE"
    newline: .asciiz "\n"
    space: .asciiz " "

.text
.align 2

.globl main
main:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # $s0 holds head; initialized as null
    li $s0, 0

_read_loop:
    # Dynamically allocate memory for player name and score
    li $v0, 9
    li $a0, 72 # 64B string ($s1) + 4B +/- metric ($t2) + 4B next pointer
    syscall
    move $s1, $v0 # current

    # Print name prompt (string)
    li $v0, 4
    la $a0, prompt_name
    syscall
    # Read user input (string)
    li $v0, 8
    move $a0, $s1
    li $a1, 64
    syscall

    # Remove newline that occurs after syscalling/printing the player name
    move $a0, $s1 

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal strclr

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # Check if string is "DONE"
    la $a1, done

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal strcmp

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    beqz $v0, _print # If "DONE" reached, proceed to print output

    # Print offense point prompt (string)
    li $v0, 4
    la $a0, prompt_pluspt
    syscall
    # Read user input (integer)
    li $v0, 5
    syscall
    move $t0, $v0 # temp

    # Print opponent point prompt (string)
    li $v0, 4
    la $a0, prompt_minuspt
    syscall
    # Read user input (integer)
    li $v0, 5
    syscall
    move $t1, $v0 # temp

    # +/- metric = team points - opponent points
    sub $t2, $t0, $t1
    sw $t2, 64($s1)
    
    # Link new node to front of list
    sw $s0, 68($s1)
    move $s0, $s1

    # Sort as developing linked list (!!!)
    move $a0, $s0

    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    # sw $s0, 16($sp)

    jal sort

    # sw $s0, 16($sp)
    lw $t2, 12($sp)
    lw $t1, 8($sp)
    lw $t0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 20

    # Read next player information
    j _read_loop

_print:
    # Print name
    li $v0, 4
    la $a0, 0($s0)
    syscall

    # Print space
    li $v0, 4
    la $a0, space
    syscall

    # Print +/- metric
    li $v0, 1
    lw $a0, 64($s0)
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # Next node
    lw $s0, 68($s0)

    # Done printing, jump to exit main to finish program
    beqz $s0, _exit_main

    # Otherwise loop back to keep printing
    j _print

_exit_main:
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12

    jr $ra

.end main


###--FUNCTION CALLS--###

sort:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # initialize
    move $s0, $a0
    li $s3, 0
    li $s4, 0

_start_sort:
    beqz $s0, _end_sort 

    lw $s1, 68($s0)
    move $s2, $s0

    move $s0, $s1
    move $s5, $s3

_while:
    # CASE 4: reached end of linked list
    beqz $s5, _insert

    lw $s6, 64($s2)
    lw $s7, 64($s5)

    # CASE 2: current node < next node = look for insertion! [IF]
    bgt $s6, $s7, _insert

    # CASE 3: current == next = strcmp [ELSEIF]
    beq $s6, $s7, _tiebreaker

_move:
    # CASE 1: current node > next node = keep moving LL [ELSE]
    move $s4, $s5
    lw $s5, 68($s5)

    j _while

    _insert:
        sw $s5, 68($s2)

        # CASE 5: adding to front of the list
        beqz $s4, _update_head 
        
        sw $s2, 68($s4)

        j _start_sort

    _tiebreaker:
        move $a0, $s2
        move $a1, $s5

        addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $s6, 4($sp)
        sw $s7, 8($sp)

        jal strcmp

        lw $s7, 8($sp)
        lw $s6, 4($sp)
        lw $ra, 0($sp)
        addi $sp, $sp, 12

        move $t2, $v0
        
        bltz $t2, _insert

        # ELSE
        j _move

    _update_head:
        move $s3, $s2
        j _start_sort

_end_sort:
    move $s0, $s3

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra


###

strclr:
    move $t3, $a0

_strclr_loop:
    lb $t4, 0($t3)
    beqz $t4, _done_clearing
    li $t5, 10
    bne $t4, $t5, _next_char
    sb $0, 0($t3)

_next_char:
    addi $t3, $t3, 1
    j _strclr_loop

_done_clearing:
    jr $ra


###

strcmp:
    lb $t0, 0($a0)
    lb $t1, 0($a1)

    bne $t0, $t1, _done_with_strcmp
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    bnez $t0, strcmp
    li $v0, 0

    jr $ra

_done_with_strcmp:
    sub $v0, $t0, $t1

    jr $ra


###