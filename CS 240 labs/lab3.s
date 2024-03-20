jal main
#                                           CS 240, Lab #3
# 
#                                          IMPORTATNT NOTES:
# 
#                       Write your assembly code only in the marked blocks.
# 
#                     	DO NOT change anything outside the marked blocks.
# 
#               Remember to fill in your name, student ID in the designated sections.
# 
#
j main
###############################################################
#                           Data Section
.data
# 
# Fill in your name, student ID in the designated sections.
# 
student_name: .asciiz "Evan Tardiff"
student_id: .asciiz "828528877"

new_line: .asciiz "\n"
space: .asciiz " "
testing_label: .asciiz ""
unsigned_addition_label: .asciiz "Unsigned Addition (Hexadecimal Values)\nExpected Output:\n0154B8FB06E97360 BAC4BABA1BBBFDB9 00AA8FAD921FE305 \nObtained Output:\n"
fibonacci_label: .asciiz "Fibonacci\nExpected Output:\n0 1 5 55 6765 3524578 \nObtained Output:\n"
file_label: .asciiz "File I/O\nObtained Output:\n"

addition_test_data_A:	.word 0xeee94560, 0x0154a8d0, 0x09876543, 0x000ABABA, 0xFEABBAEF, 0x00a9b8c7
addition_test_data_B:	.word 0x18002e00, 0x0000102a, 0x12349876, 0xBABA0000, 0x93742816, 0x0000d6e5

fibonacci_test_data:	.word  0, 1, 2, 3, 5, 6, 

bcd_2_bin_lbl: .asciiz "\nAiken to Binary (Hexadecimal Values)\nExpected output:\n004CC853 00BC614E 00008AE0\nObtained output:\n"
bin_2_bcd_lbl: .asciiz "\nBinary to Aiken (Hexadecimal Values) \nExpected output:\n0B03201F 0CC3C321 000CBB3B\nObtained output:\n"


bcd_2_bin_test_data: .word 0x0B03201F, 0x1234BCDE, 0x3BBB2

bin_2_bcd_test_data: .word 0x4CC853, 0x654321, 0xFFFF


hex_digits: .byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

file_name:
	.asciiz	"lab3_data.dat"	# File name
	.word	0
read_buffer:
	.space	300			# Place to store character
###############################################################
#                           Text Section
.text
# Utility function to print hexadecimal numbers
print_hex:
move $t0, $a0
li $t1, 8 # digits
lui $t2, 0xf000 # mask
mask_and_print:
# print last hex digit
and $t4, $t0, $t2 
srl $t4, $t4, 28
la    $t3, hex_digits  
add   $t3, $t3, $t4 
lb    $a0, 0($t3)            
li    $v0, 11                
syscall 
# shift 4 times
sll $t0, $t0, 4
addi $t1, $t1, -1
bgtz $t1, mask_and_print
exit:
jr $ra
###############################################################
###############################################################
###############################################################
#                           PART 1 (Unsigned Addition)
# You are given two 64-bit numbers A,B located in 4 registers
# $t0 and $t1 for lower and upper 32-bits of A and $t2 and $t3
# for lower and upper 32-bits of B, You need to store the result
# of the unsigned addition in $t4 and $t5 for lower and upper 32-bits.
#
.globl Unsigned_Add_64bit
Unsigned_Add_64bit:
move $t0, $a0
move $t1, $a1
move $t2, $a2
move $t3, $a3
############################## Part 1: your code begins here ###

# add lower bits
addu $t4, $t0, $t2

# add upper bits
addu $t5, $t1, $t3

# check if overflow occured with lower bits
blt $t4, $t0, overflow
blt $t4, $t2, overflow



j END
overflow:
addu $t5, $t5, 1

END:


############################## Part 1: your code ends here   ###
move $v0, $t4
move $v1, $t5
jr $ra
###############################################################
###############################################################
###############################################################
#                            PART 2 (Aiken Code to Binary)
# 
# You are given a 32-bits integer stored in $t0. This 32-bits
# present a Aiken number. You need to convert it to a binary number.
# For example: 0xDCB43210 should return 0x48FF4EA.
# The result must be stored inside $t0 as well.
.globl aiken2bin
aiken2bin:
move $t0, $a0
############################ Part 2: your code begins here ###

# reset registers used in part 1 except for $t0
addi $t4, $zero, 0
addi $t5, $zero, 0 
addi $t1, $zero, 0
addi $t2, $zero, 0
addi $t3, $zero, 0
li $t6, 0



addi $t1, $0, 0xF0000000   # t1 will be used to extract bits
addi $t2, $0, 8            # loop 8 times
addi $t4, $0, 0xB0000000   # holds value B
addi $t5, $0, 0x60000000   # holds value 6

# converts aiken to BCD
theLoop:
beqz $t2, BCDcomplete

and $t3, $t0, $t1        # four bits extracted to t3

# if value is less than 5 (which is B), we don't need to change it
beqz $t3, skip
beq $t3, 0x10000000, skip      # I put these extra beq and beqz instrunctions here because sometimes $t3 would be less than $t4 and it would not branch.
beq $t3, 0x20000000, skip
beq $t3, 0x30000000, skip
beq $t3, 0x40000000, skip
blt $t3, $t4, skip

# change values from aiken to BCD by sub 6
subu $t3, $t3, $t5


skip: 
srl $t1, $t1, 4
srl $t4, $t4, 4
srl $t5, $t5, 4
addi $t2, $t2, -1
or $t6, $t6, $t3       # by end of the loops, the BCD value should be in t6
j theLoop
BCDcomplete:

# Convert from BCD to decimal/binary ############################################################
li $t0, 0    # resets 0 so it can store final answer later
li $t1, 0xF0000000
li $t2, 8
li $t3, 10000000  # ten million, will get divded by 10 each loop
li $t4, 28     # will decrease by 4 each loop
li $t9, 0

toBinary:
beqz $t2, part2Done

and $t9, $t6, $t1        # group of four bits extracted to t9
srlv $t9, $t9, $t4       # shifts bits all the way to the right
mul $t9, $t9, $t3        # multiplies value by the place (like 1's place, 10's place) it should occupy
add $t0, $t0, $t9


srl $t1, $t1, 4
div $t3, $t3, 10
addi $t4, $t4, -4
addi $t2, $t2, -1
j toBinary

part2Done:



############################ Part 2: your code ends here ###
move $v0, $t0
jr $ra

###############################################################
###############################################################
###############################################################
#                            PART 3 (Binary to Aiken Code)
# 
# You are given a 32-bits integer stored in $t0. This 32-bits
# present an integer number. You need to convert it to a Aiken.
# The result must be stored inside $t0 as well.
.globl bin2aiken
bin2aiken:
move $t0, $a0
############################ Part 3: your code begins here ###

# resets all registers except for $t0
li $t1, 0
li $t2, 0
li $t3, 0
li $t4, 0
li $t5, 0
li $t6, 0
li $t7, 0

# initializes registers used

# t3 will hold the quotients
li $t1, 10   # will be used to divide by 10
li $t4 0
add $t3, $t3, $t0

# convert from binary to BCD
aLoop:
beqz $t3, QisZero    # when quotient is 0, we are done diving by 10
div $t3, $t1         # remainder stored in HI
mfhi $t2             # t2 will has remainder
mflo $t3             # t3 is used for branching condition
sllv $t2, $t2, $t4   # shifts the numbers so that they are in their proper spot
addi $t4, $t4, 4     # increments the shifter
or $t5, $t5, $t2     # stores the new values in BCD form in t5
j aLoop


QisZero:
# t5 should have the number in BCD form
li $t0, 0 # resets 0 to store final answer


# convert BCD to aiken
li $t1, 8   # loop 8 times
li $t2, 0xF0000000    # masks out each group of four bits
li $t3, 0x50000000    # will be used to compare with each group
li $t4, 0x60000000    # will be used to add 6 if needed

BCD_to_aiken:
beqz $t1, finishedPart3
and $t6, $t5, $t2   # extracts group of four bits

blt $t6, $t3, skipConvert    # if extracted bits in t6 is less than 5, skip the conversion
add $t6, $t6, $t4


skipConvert:
srl $t2, $t2, 4
srl $t3, $t3, 4
srl $t4, $t4, 4
addi $t1, $t1, -1
or $t0, $t0, $t6
j BCD_to_aiken
finishedPart3:





############################ Part 3: your code ends here ###
move $v0, $t0
jr $ra

###############################################################
###############################################################
###############################################################
###############################################################
###############################################################


###############################################################
###############################################################
###############################################################
#                           PART 4 (ReadFile)
#
# You will read characters (bytes) from a file (lab3_data.dat) 
# and print them. 
#Valid characters are defined to be
# alphanumeric characters (a-z, A-Z, 0-9),
# " " (space),
# "." (period),
# (new line).
#
# 
# Hint: Remember the ascii table. 
#
.globl file_read
file_read:
############################### Part 4: your code begins here ##

# open file
li $v0, 13         # 13 for opening a file
la $a0, file_name  # address of filename
li $a1, 0          # flags
li $a2, 0          # mode
syscall
move $t9, $v0    # save the file descriptor in t9


li $v0, 14             # 14 for reading
move $a0, $t9          # puts file descripter into first argument
la $a1, read_buffer    # address of input buffer 
li $a2, 300            # max number of characters to read
syscall



# Close the file 

li   $v0, 16       # system call for close file
move $a0, $t9      # file descriptor to close
syscall            # close file


la $t1, read_buffer
li $t2, 300

finalLoop:
beqz $t2, laFin   # loop 300 times
lbu $t0, 0($t1)   # load the byte that was character that is being checked


# ascii check for if it is period, space, or new line
beq $t0, 10, doAscii
beq $t0, 46, doAscii
beq $t0, 32, doAscii

bgt $t0, 122, skipAscii

blt $t0, 48, skipAscii   
blt $t0, 58, doAscii

blt $t0, 65, skipAscii
blt $t0, 91, doAscii

blt $t0, 97, skipAscii
blt $t0, 123, doAscii

j skipAscii
doAscii:
# print character
li $v0, 11
move $a0, $t0
syscall

skipAscii:
addi $t2, $t2, -1
addi $t1, $t1, 1
j finalLoop

laFin:


############################### Part 4: your code ends here   ##
jr $ra
###############################################################
###############################################################
###############################################################

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
##############################################
##############################################
test_64bit_Add_Unsigned:
li $s0, 3
li $s1, 0
la $s2, addition_test_data_A
la $s3, addition_test_data_B
li $v0, 4
la $a0, testing_label
syscall
la $a0, unsigned_addition_label
syscall
##############################################
test_add:
add $s4, $s2, $s1
add $s5, $s3, $s1
# Pass input parameter
lw $a0, 0($s4)
lw $a1, 4($s4)
lw $a2, 0($s5)
lw $a3, 4($s5)
jal Unsigned_Add_64bit

move $s6, $v0
move $a0, $v1
jal print_hex
move $a0, $s6
jal print_hex

li $v0, 4
la $a0, space
syscall

addi $s1, $s1, 8
addi $s0, $s0, -1
bgtz $s0, test_add

li $v0, 4
la $a0, new_line
syscall
##############################################
##############################################
li $v0, 4
la $a0, new_line
syscall
la $a0, bcd_2_bin_lbl
syscall
# Testing part 2
li $s0, 3 # num of test cases
li $s1, 0
la $s2, bcd_2_bin_test_data

test_p2:
add $s4, $s2, $s1
# Pass input parameter
lw $a0, 0($s4)
jal aiken2bin

move $a0, $v0        # hex to print
jal print_hex

li $v0, 4
la $a0, space
syscall

addi $s1, $s1, 4
addi $s0, $s0, -1
bgtz $s0, test_p2

##############################################
##############################################
li $v0, 4
la $a0, new_line
syscall
la $a0, bin_2_bcd_lbl
syscall

# Testing part 3
li $s0, 3 # num of test cases
li $s1, 0
la $s2, bin_2_bcd_test_data

test_p3:
add $s4, $s2, $s1
# Pass input parameter
lw $a0, 0($s4)
jal bin2aiken

move $a0, $v0        # hex to print
jal print_hex

li $v0, 4
la $a0, space
syscall

addi $s1, $s1, 4
addi $s0, $s0, -1
bgtz $s0, test_p3
##############################################
##############################################
li $v0, 4
la $a0, new_line
syscall
test_file_read:
li $v0, 4
la $a0, new_line
syscall
li $s0, 0
li $v0, 4
la $a0, testing_label
syscall
la $a0, file_label
syscall 
jal file_read
end:
# end program
li $v0, 10
syscall
