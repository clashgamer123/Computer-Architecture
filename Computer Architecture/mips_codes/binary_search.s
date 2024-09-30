.data
# Define the array and len here
    .align 2
A : .word 1, 2, 3, 4, 6, 12, 13, 15, 18, 21
    .align 2
len : .word 10
prompt : .asciiz "Binary Search Output: "

.globl main

.text

main:

BEGIN:
# a0 = A, a1 = len, a2 = val 
la $a0, A 

la $a1, len
lw $a1, 0($a1)

li $v0, 5
syscall 
ori $a2, $v0, 0

# Args are ready and were chosen such that they do not change accross func calls.
# start and end args will be stored in the stack
addi $sp, $sp, -8
sw $0, 4($sp) 
addi $t0, $a1, -1
sw $t0, 0($sp)
jal BINARY_SEARCH

addi $sp, $sp, 8
ori $t0, $v0, 0
li $v0, 4
la $a0, prompt
syscall

li $v0, 1
ori $a0, $t0, 0
syscall

li $v0, 10
syscall


BINARY_SEARCH:
# retrieve start and end
lw $t0, 4($sp) 
lw $t1, 0($sp)  # t0 = start and t1 = end
addi $sp, $sp, 8

addi $sp, $sp, -4
sw $ra, 0($sp)

slt $t2, $t1, $t0
bne $t2, $0, EXIT_FALSE

add $t2, $t0, $t1
srl $t2, $t2, 1   # t2 = mid
sll $t3, $t2, 2
add $t3, $a0, $t3
lw $t3, 0($t3)     # t3 = A[mid]

beq $t3, $a2, EXIT_TRUE

# Verify other conditions and recurse.
slt $t4, $a2, $t3
beq $t4, $0, REC2
j REC1

REC1:
# We have A[mid]>val
addi $t2, $t2, -1
addi $sp, $sp, -8
sw $t0, 4($sp)
sw $t2, 0($sp)
jal BINARY_SEARCH
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

REC2:
#We have A[mid]<val
addi $t2, $t2, 1
addi $sp, $sp, -8
sw $t2, 4($sp)
sw $t1, 0($sp)
jal BINARY_SEARCH
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

EXIT_FALSE:
addi $v0, $0, -1
addi $sp, $sp, 4
jr $ra

EXIT_TRUE:
ori $v0, $t2, 0
addi $sp, $sp, 4
jr $ra 

