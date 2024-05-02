# CS250-Computer-Architecture

A collection of several projects completed in CS 250: Computer Architecture.

## CPU
**cpu.circ:** A Logisim implementation of the Duke 250/16, a 16-bit MIPS-like, word-addressed RISC architecture. Handles the Duke 250/16 instructions: add, sub, addi, not, xor, sll, srl, lw, sw, beqz, blt, j, jal, jr, input, and output. Components include a control unit, register file, ALU, and I/O.

## Caches
**cachesim.c:** A simulator of a single-level cache and the memory underneath it. The simulator, called cachesim, takes the following input parameters on the command line: name of the file holding the loads and stores, cache size (not including tags or valid bits) in kB, associativity, and the block size in bytes. The replacement policy is always LRU. The cache is write-back and write-allocate. 

## Assembly
**plusminus.s:** A MIPS program that ranks basketball players based on the metric known as “plus/minus”.
**recurse.s:** A recursive MIPS program that computes f(N), where N is an integer greater than zero that is input to the program. f(N) = 3*N – 2*f(N-1) + 7. The base case is f(0)=2.
**tribonacci.s:** A MIPS program that prints out the first N Tribonacci numbers, where N is an integer that is input to the program. 

## Duke Community Standard

Intellectual and academic honesty are at the heart of the academic life of any university. It is the responsibility of all students to understand and abide by Duke's expectations regarding academic work. Students found guilty of plagiarism, lying, cheating or other forms of academic dishonesty may be suspended. 
