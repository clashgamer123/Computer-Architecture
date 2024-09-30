# Create array statically.
.data
.align 2
A : .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 12
.align 2
len : .word 10

.globl main

.text

main:

BEGIN :
# Func format is int binarySearch(int *A, int len, int val, int start, int end)
# Take the value to be searched that is val.
# As we have 5 arguments lets store len in stack.
la $a0, A         # $a0 has A
la $t0, len       # $a1 has len
lw $a1, 0($t0)    # $a2 has val

# Take val as input
li $v0, 5
syscall
ori $a2, $v0, 0

# We will store start and end on the stack.
addi $sp, $sp, -8
sw $0, 4($sp)
sw $a1, 0($sp)

# Now call the binary search function.
jal BinarySearch
# Print the return value in $v0
ori $a0, $v0, 0
li $v0, 1
syscall

# Exit
li $v0, 10
syscall

BinarySearch:
# retrieve the arguments and also store $ra on stack.
lw $t0, 4($sp) # $t0 = start
lw $t1, 0($sp) # $t1 = end
# Restore the stack
addi $sp, $sp, 8

addi $sp, $sp, -4
sw $ra, 0($sp)

beq $t0, $t1, FAIL

# Calculate mid in $t2
add $t2, $t0, $t1
srl $t2, $t2, 1
# Calculate A[mid] in $t3
sll $t3, $t2, 2
add $t3, $t3, $a0
lw $t3, 0($t3)

# If equal return mid
beq $t3, $a2, EQUAL

# A[mid] Less than val
slt $t4, $a2, $t3
beq $t4, $0, LESS

# Write code for greater than case:
addi $sp, $sp, -8
sw $t0, 4($sp)
sw $t2, 0($sp)
jal BinarySearch
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

LESS:
addi $sp, $sp, -8
addi $t2, $t2, 1
sw $t2, 4($sp)
sw $t1, 0($sp)
jal BinarySearch
# We here already have our answer in $v0
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

EQUAL:
ori $v0, $t2, 0 
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

FAIL:
addi $v0, $0, -1
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra




