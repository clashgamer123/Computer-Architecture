.text

main:

li $s0, 1003
li $s1, 17

slt $t0, $s0, $s1 
beq $0, $t0, BEGIN1

# This code will be when s1>s0.
BEGIN0:
slt $t1, $0, $s1 
beq $t1, $0, EXIT1
sub $s1, $s1, $s0
j BEGIN0

# This code is if s1<=s0
BEGIN1:
slt $t1, $0, $s0
beq $t1, $0, EXIT2
sub $s0, $s0, $s1
j BEGIN1

# When code exits from BEGIN0
EXIT1:
beq $s1, $0, TRUE
addi $s2 , $0, 0
j EXIT

# When code exits from BEGIN1
EXIT2:
beq $s0, $0, TRUE
addi $s2, $0, 0
j EXIT

# If multiple
TRUE:
addi $s2, $0, 1 

# Exit
EXIT:

