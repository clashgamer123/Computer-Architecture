.data
    .align 2 # As we are using words that are 4 bytes.
A : .word 0, 0    # A[0]
    .word -1, 2   # A[1]
    .word 0, 2    # A[2] 
    .word -1, -1  # A[3]

    .align 2
len : .word 4

.globl main 

.text

main:

la $t0, A
lw $t1, 16($t0) # A[2] is 2*8 = 16 bytes offset.
lw $t2, 20($t0) # 2*8 + 4 = 20 bytes offset.

add $a0, $t1, $t2
li $v0, 1
syscall

# Exit
li $v0, 10
syscall