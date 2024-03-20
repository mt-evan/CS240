#                                           CS 240, Lab #4
# 
#                                          IMPORTATNT NOTES:
# 
#                       Write your assembly code only in the marked blocks.
# 
#                       DO NOT change anything outside the marked blocks.
# 
#
j main
###############################################################################
#                           Data Section
.data

# 
# Fill in your name, student ID in the designated sections.
# 
student_name: .asciiz "Evan Tardiff"
student_id: .asciiz "828528877"

new_line: .asciiz "\n"
space: .asciiz " "


t1_str: .asciiz "Testing GCD: \n"
t2_str: .asciiz "Testing LCM: \n"
t3_str: .asciiz "Testing RANDOM SUM: \n"

po_str: .asciiz "Obtained output: " 
eo_str: .asciiz "Expected output: "

#GCD_test_data_A:	.word 1, 2, 128, 148, 36, 360, 108, 75, 28300, 0
#GCD_test_data_B:	.word 12, 12, 96, 36, 54, 210, 144, 28300, 74000, 143

GCD_test_data_A:	.word 1, 36, 360, 108, 28300
GCD_test_data_B:	.word 12,54, 210, 144, 74000

GCD_output:           .word 1, 18, 30, 36, 100

#LCM_test_data_A:	.word 0, 1, 2, 128, 148, 36, 360, 108, 75, 28300
#LCM_test_data_B:	.word 143, 12, 12, 96, 36, 54, 210, 144, 28300, 74000
#LCM_output:           .word 0, 12, 12, 384, 1332, 108, 2520, 432, 84900, 20942000 


LCM_test_data_A:	.word 1, 36, 360, 108, 28300
LCM_test_data_B:	.word 12,54, 210, 144, 74000
LCM_output:           .word 12, 108, 2520, 432, 20942000

RANDOM_test_data_A:	.word 1, 144, 42, 260, 74000
RANDOM_test_data_B:	.word 12, 108,  54, 210, 44000
RANDOM_test_data_C:	.word 4, 109, 36, 360, 28300

RANDOM_output:           .word 26, 720, 216, 3120, 21044400

###############################################################################
#                           Text Section
.text
# Utility function to print an array
print_array:
li $t1, 0
move $t2, $a0
print:

lw $a0, ($t2)
li $v0, 1   
syscall

li $v0, 4
la $a0, space
syscall

addi $t2, $t2, 4
addi $t1, $t1, 1
blt $t1, $a1, print
jr $ra
###############################################################################
###############################################################################
#                           PART 1 (GCD)
#a0: input number
#a1: input number

#v0: final gcd answer

.globl gcd
gcd:
############################### Part 1: your code begins here ################

addi $sp, $sp, -4
sw $ra, 0($sp) # saves the address from the jal
addi $sp, $sp, -4
sw $a0, 0($sp) # save first parameter into stack 
addi $sp, $sp, -4
sw $a1, 0($sp) # save second parameter into stack

move $t0, $a0 # value X (first param)
move $t1, $a1 # value Y (second param)


# base case, if Y == 0 then we return X
bne $t1, 0, skipBaseCase
move $v0, $t0
j GCD_found

# recursive case
skipBaseCase:
# return euclidGCD(Y, X % Y)
move $a0, $t1 # Y will be next first parameter X
div $t0, $t1 
mfhi $a1 # remainder in $a1 will be next second parameter Y
jal gcd # recursive call with new parameters


GCD_found:
lw $a1, 0($sp)
addi $sp, $sp, 4 
lw $a0, 0($sp)
addi $sp, $sp, 4 # maintain/update the stack
lw $ra, 0($sp)   # gets address back for the jr
addi $sp, $sp, 4
jr $ra 

############################### Part 1: your code ends here  ##################
jr $ra
###############################################################################
###############################################################################
#                           PART 2 (LCM)

# Find the least common multiplier of two numbers given
# Make a call to the GCD function to compute the LCM
# LCM = a1*a2 / GCD

# Preserve all required values in stack before calls to another function.
# preserve the $ra register value in stack before making the call!!!

#a0: input number
#a1: input number
#v0: final gcd answer

.globl lcm
lcm:
############################### Part 2: your code begins here ################



addi $sp, $sp, -4 # saves address
sw $ra, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
addi $sp, $sp, -4
sw $a1, 0($sp)

# get the GCD
# GCD will be in $v0, the product of $a1 and $a0 is in $t5
jal gcd2

lw $a1, 0($sp)
addi $sp, $sp, 4
lw $a0, 0($sp)
addi $sp, $sp, 4
lw $ra, 0($sp) # retreives address
addi $sp, $sp, 4

# get $a1 * $a0
mul $t5, $a1, $a0

div $v0, $t5, $v0 # (a1 * a0) / GCD

############################### Part 2: your code ends here  ##################
jr $ra
###############################################################################
#                           PART 3 (Random SUM)

# You are given three integers. You need to find the smallest 
# one and the largest one.
# 
# Then find the GCD and LCM of the two numbers. 
#
# Return the sum of Smallest, largest, GCD and LCM
#
# Implementation details:
# The three integers are stored in registers $a0, $a1, and $a2.
# Store the answer into register $v0. 
# Preserve all required values in stack before calls to another function.
# preserve the $ra register value in stack before making the call!!!
# Use stacks to store the smallest and largest values before making the function call. 

.globl random_sum
random_sum:
############################### Part 3: your code begins here ################

# $t1 will store the largest number
# $t0 will store the smallest number

# find smallest of a0 a1 and a2
bgt $a0, $a1, a0_bigger
bgt $a1, $a2, a1_biggest
# if this line is read, means $a2 is biggest and $a0 is smallest
move $t1, $a2
move $t0, $a0
j finalPart

a0_bigger: # is a0 bigger than a2?
bgt $a0, $a2, a0_biggest
# if this line is read, means a2 is biggest and a1 is smallest
move $t1, $a2
move $t0, $a1
j finalPart

a0_biggest: # is a1 or a2 smaller
move $t1, $a0
blt $a1, $a2, a1_smallest
j a2_smallest

a1_biggest: # is a0 or a2 smaller
move $t1, $a1
blt $a0, $a2, a0_smallest
j a2_smallest


a0_smallest:
move $t0, $a0
j finalPart

a1_smallest:
move $t0, $a1
j finalPart

a2_smallest:
move $t0, $a2


# the smallest and largest numbers are found in t0 and t1. find the GCM and LCD
finalPart:

# find GCM and store in $t2

move $a0, $t0 # sets up parameters for gcd
move $a1, $t1

# stores smallest and largest numbers in stack and retrieve them after
addi $sp, $sp, -4
sw $ra, 0($sp)
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
addi $sp, $sp, -4
sw $a1, 0($sp)


jal gcd2

lw $a1, 0($sp)
addi $sp, $sp, 4
lw $a0, 0($sp)
addi $sp, $sp, 4
lw $t1, 0($sp)
addi $sp, $sp, 4
lw $t0, 0($sp)
addi $sp, $sp, 4
lw $ra, 0($sp)
addi $sp, $sp, 4

move $t2, $v0 # GCD value stored

# find LCM and store in $t3
move $a0, $t0 # sets up parameters for lcm
move $a1, $t1

# stores all relevant values into stack then retrieves them after the jal
addi $sp, $sp, -4
sw $ra, 0($sp)
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
addi $sp, $sp, -4
sw $a1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)


jal lcm2

lw $t2, 0($sp)
addi $sp, $sp, 4
lw $a1, 0($sp)
addi $sp, $sp, 4
lw $a0, 0($sp)
addi $sp, $sp, 4
lw $t1, 0($sp)
addi $sp, $sp, 4
lw $t0, 0($sp)
addi $sp, $sp, 4
lw $ra, 0($sp)
addi $sp, $sp, 4

move $t3, $v0 # LCM value stored

# add the smallest and largest number with LCM and GCD
add $v0, $t0, $t1
add $v0, $v0, $t2
add $v0, $v0, $t3

############################### Part 3: your code ends here  ##################
jr $ra
###############################################################################

#                          Main Function 
main:
li $v0, 4
la $a0, student_name
syscall
la $a0, new_line
syscall  
la $a0, student_id
syscall 
la $a0, new_line
syscall
la $a0, new_line
syscall
###############################################################################
#                          TESTING PART 1 - GCD
li $v0, 4
la $a0, new_line
syscall

li $v0, 4
la $a0, t1_str
syscall

li $v0, 4
la $a0, eo_str
syscall

li $v0, 4
la $a0, new_line
syscall

li $s0, 5 # num tests
la $s2, GCD_output
move $a0, $s2
move $a1, $s0
jal print_array

li $v0, 4
la $a0, new_line
syscall


li $v0, 4
la $a0, po_str
syscall

li $v0, 4
la $a0, new_line
syscall


#test_GCD:
li $s0, 5 # num tests
li $s1, 0
la $s2, GCD_test_data_A
la $s3, GCD_test_data_B
#j skip_line
##############################################
test_gcd:
#li $v0, 4
#la $a0, new_line
#syscall
#skip_line:
add $s4, $s2, $s1
add $s5, $s3, $s1
# Pass input parameter
lw $a0, 0($s4)
lw $a1, 0($s5)
jal gcd

move $a0, $v0
li $v0,1
syscall

li $v0, 4
la $a0, space
syscall

addi $s1, $s1, 4
addi $s0, $s0, -1
bgtz $s0, test_gcd

###############################################################################

#                          TESTING PART 2 - LCM
li $v0, 4
la $a0, new_line
syscall

li $v0, 4
la $a0, new_line
syscall

li $v0, 4
la $a0, t2_str
syscall

li $v0, 4
la $a0, eo_str
syscall

li $v0, 4
la $a0, new_line
syscall

li $s0, 5 # num tests
la $s2, LCM_output
move $a0, $s2
move $a1, $s0
jal print_array

li $v0, 4
la $a0, new_line
syscall


li $v0, 4
la $a0, po_str
syscall

li $v0, 4
la $a0, new_line
syscall


#test_GCD:
li $s0, 5 # num tests
li $s1, 0
la $s2, LCM_test_data_A
la $s3, LCM_test_data_B
#j skip_line
##############################################
test_lcm:
#li $v0, 4
#la $a0, new_line
#syscall
#skip_line:
add $s4, $s2, $s1
add $s5, $s3, $s1
# Pass input parameter
lw $a0, 0($s4)
lw $a1, 0($s5)
jal lcm

move $a0, $v0
li $v0,1
syscall

li $v0, 4
la $a0, space
syscall

addi $s1, $s1, 4
addi $s0, $s0, -1
bgtz $s0, test_lcm

###############################################################################
#                          TESTING PART 3 - RANDOM SUM
li $v0, 4
la $a0, new_line
syscall

li $v0, 4
la $a0, new_line
syscall

li $v0, 4
la $a0, t3_str
syscall

li $v0, 4
la $a0, eo_str
syscall

li $v0, 4
la $a0, new_line
syscall

li $s0, 5 # num tests
la $s2, RANDOM_output
move $a0, $s2
move $a1, $s0
jal print_array

li $v0, 4
la $a0, new_line
syscall


li $v0, 4
la $a0, po_str
syscall

li $v0, 4
la $a0, new_line
syscall


#test_GCD:
li $s0, 5 # num tests
li $s1, 0
la $s2, RANDOM_test_data_A
la $s3, RANDOM_test_data_B
la $s4, RANDOM_test_data_C
#j skip_line
##############################################
test_random:
#li $v0, 4
#la $a0, new_line
#syscall
#skip_line:
add $s5, $s2, $s1
add $s6, $s3, $s1
add $s7, $s4, $s1
# Pass input parameter
lw $a0, 0($s5)
lw $a1, 0($s6)
lw $a2, 0($s7)
jal random_sum

move $a0, $v0
li $v0,1
syscall

li $v0, 4
la $a0, space
syscall

addi $s1, $s1, 4
addi $s0, $s0, -1
bgtz $s0, test_random

###############################################################################

_end:

# new line
li $v0, 4
la $a0, new_line
syscall

# end program
li $v0, 10
syscall
###############################################################################
