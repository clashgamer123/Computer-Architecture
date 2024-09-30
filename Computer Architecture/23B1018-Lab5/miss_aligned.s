.data
B : .byte 1
.align 1
A : .byte 2
    .word 3
    .word 4

.globl main

.text

main:
    la $t0, A
    lw $t1, 4($t0)
    li $v0, 10
    syscall