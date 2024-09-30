.data
    .align 2
A : .word 2, 2    # A[0]
    .word -3, 1   # A[1]
    .word 4, 2    # A[2] 
    .word 0, 6    # A[3]
    
    .align 2
len : .word 4

.globl main

.text

main:

BEGIN:
# Take x.re and x.im as input.
li $v0, 5
syscall
ori $a0, $v0, 0  # a0 has x.re

li $v0, 5
syscall
ori $a1, $v0, 0  # a1 has x.im

li $a2, 0        # a2 has start 0 from question
la $t0, len
lw $a3, 0($t0)   # a3 has end = len

# Store address of A in stack.
addi $sp, $sp, -4
la $t0, A
sw $t0, 0($sp) 

jal numLessThan 
addi $sp, $sp, 4  # Restore stack.

ori $a0, $v0, 0
li $v0, 1
syscall

li $v0, 10
syscall


# numLessThan func
numLessThan:
lw $t3, 0($sp)
addi $sp, $sp, -4
sw $ra, 0($sp)
addi $t0, $0, 0    #count = $t0
addi $t1, $a2, 0   #index = START = $t1 
j FOR_LOOP_START

FOR_LOOP_START:
slt $t2, $t1, $a3 
beq $t2, $0, FOR_LOOP_EXIT
addi $sp, $sp, -8
sw $a2, 4($sp)
sw $a3, 0($sp)
ori $a2, $t3, 0
ori $a3, $t1, 0
jal isLessThan
lw $a2, 4($sp)
lw $a3, 0($sp)
addi $sp, $sp, 8
bne $0, $v0, UPDATE
addi $t1, $t1, 1
j FOR_LOOP_START

UPDATE:
addi $t0, $t0, 1
addi $t1, $t1, 1
j FOR_LOOP_START

FOR_LOOP_EXIT:
lw $ra, 0($sp)
addi $sp, $sp, 4
ori $v0, $t0, 0
jr $ra

isLessThan:
# A is in $a2.
# index in $a3
sll $a3, $a3, 3        # Get the offset from base address.
add $a2, $a2, $a3
lw $t4, 0($a2)         # A[i].re
lw $t5, 4($a2)         # A[i].im
# x.re and x.im in $a0, $a1

slt $t6, $t4, $a0
beq $t6, $0, FIRST_ARG_NE
addi $v0, $0, 1
j RETURN

FIRST_ARG_NE:
beq $t4, $a0, SECOND_ARG
addi $v0, $0, 0
j RETURN

SECOND_ARG:
slt $t6, $t5, $a1
beq $t6, $0, FAIL
addi $v0, $0, 1
j RETURN

FAIL:
addi $v0, $0, 0
j RETURN

RETURN:
jr $ra






