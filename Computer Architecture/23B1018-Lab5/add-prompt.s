.data

prompt_1 : .asciiz "Enter the 1st integer: "
prompt_2 : .asciiz "Enter the 2nd integer: "
prompt_3 : .asciiz "The sum : "

.text

main:

# print string => syscall 4.
li $v0, 4
la $a0, prompt_1
syscall

li $v0, 5
syscall
ori $t0, $v0, 0

li $v0, 4
la $a0, prompt_2
syscall

li $v0, 5
syscall
ori $t1, $v0, 0

li $v0, 4
la $a0, prompt_3
syscall

add $a0, $t0, $t1
li $v0, 1
syscall

# syscall 10 to exit .
li $v0, 10
syscall

