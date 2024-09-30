.text

.globl main

main:

BEGIN:
# Read the input
li $v0, 5
syscall 
ori $a0, $v0, 0
# Call the function.
jal FACT
# Print the factorial.
ori $a0, $v0, 0
li $v0, 1
syscall
li $v0, 10
syscall

FACT:
addi $sp, $sp, -8
sw $ra, 4($sp)
sw $a0, 0($sp)
bne $a0, $0, NEXT
addi $v0, $0, 1
j EXIT

NEXT:
addi $a0, $a0, -1
jal FACT 
lw $a0, 0($sp)
mul $v0, $v0, $a0
j EXIT

EXIT:
lw $ra, 4($sp)
addi $sp, $sp, 8
jr $ra
