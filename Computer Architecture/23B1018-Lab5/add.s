.text

main:

# Read first integer.
# $v0 = 5 is reading int into $v0.
li $v0, 5  
syscall
ori $t0, $v0, 0 

# Read second integer.
li $v0, 5
syscall
ori $t1, $v0, 0

# Print the sum.
# $v0 = 1 is printing int in $a0.
add $a0, $t0, $t1
li $v0, 1
syscall

# Exit
li $v0, 10
syscall