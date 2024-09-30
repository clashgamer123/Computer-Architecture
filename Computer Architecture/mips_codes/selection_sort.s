.data
# The array to be sorted
    .align 2
A : .word 2, -6, 11, 51, 8, 11, 21, 14, 131, 29
    .align 2
n : .word 10
space : .asciiz " "


.globl main

.text

main:
# load the args a0 = A, a1 = n
la $a0, A 
la $a1, n
lw $a1, 0($a1)

jal SORT

# For loop to print the sorted array:
li $t0, 0
PRINT_BEGIN:
slt $t1, $t0, $a1
beq $t1, $0, PRINT_EXIT
sll $t2, $t0, 2
add $t2, $a0, $t2
ori $t5, $a0, 0
lw $a0, 0($t2)
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
addi $t0, $t0, 1
ori $a0, $t5, 0
j PRINT_BEGIN

PRINT_EXIT:
li $v0, 10
syscall

SORT:
li $t0, 0  # t0 = i, t1 = m, t2 = j
FOR_1_BEGIN:
slt $t1, $t0, $a1
beq $t1, $0, FOR_1_EXIT
ori $t1, $t0, 0
addi $t2, $t0, 1
FOR_2_BEGIN:
slt $t3, $t2, $a1
beq $t3, $0, SWAP
sll $t4, $t2, 2  # t4 = A[j]
add $t4, $a0, $t4
lw $t4, 0($t4)

sll $t5, $t1, 2 # t5 = A[m]
add $t5, $a0, $t5
lw $t5, 0($t5) 

blt $t4, $t5, UPDATE_MIN
addi $t2, $t2, 1
j FOR_2_BEGIN

UPDATE_MIN:
ori $t1, $t2, 0
addi $t2, $t2, 1
j FOR_2_BEGIN

SWAP:
# swap A[i] and A[m] t0 = i, t1 = m
# t5 = A[i] and t7 = A[m]
sll $t4, $t0, 2
add $t4, $a0, $t4
lw $t5, 0($t4)
sll $t6, $t1, 2
add $t6, $a0, $t6
lw $t7, 0($t6)
sw $t5, 0($t6)
sw $t7, 0($t4)

addi $t0, $t0, 1
j FOR_1_BEGIN

FOR_1_EXIT:
jr $ra


