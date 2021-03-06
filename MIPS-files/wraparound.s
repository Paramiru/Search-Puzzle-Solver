
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid, including wrap-around
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dictionary_idx:		.space 4004
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
    li  $t0, 0                          # idx = 0;
    li  $t1, 0                          # start_idx = 0;
    li  $t2, 0                          # dict_idx = 0;	

store_st_index:	  # Storing the starting index of each word in the dictionary

    lb  $a1, dictionary($t0)    # c_input = dictionary[idx];		
    beq  $a1, $0, strfind_setup # if (c_input == '\0') {break;}
    addi  $v0, $0, 10
    beq  $a1, $v0, add_to_array # if (c_input == '\n') do...
    add  $t0, $t0, 1            # idx += 1;
    j  store_st_index

add_to_array:
		
    sw  $t1, dictionary_idx($t2)  # dictionary_idx[dict_idx] = start_idx
    add  $t2, $t2, 4              # dict_idx ++ -> Add 4 since int array

    add  $t1, $t0, 1              # start_idx = idx + 1;
    add  $t0, $t0, 1              # idx += 1;
		
    j  store_st_index
		 
strfind_setup:
    move  $t6, $t2              # length of dict_num_words		
    li  $t0, 0			# idx = 0;
    li  $t1, 0			# grid_idx = 0;
    li  $t8, 0                  # Length of the row
    li  $t9, 0                  # Get number of row in which we are currently
    li  $s1, 0                  # Length of grid
		
get_length_of_row:
    lb   $a1, grid($t8)         # load char until newline, then we stop and have the length
    addi $v0, $0, 10
    beq  $a1, $v0, get_length_of_grid
    addi $t8, $t8, 1
    j get_length_of_row
    
get_length_of_grid:
    addi $s1, $s1, 1
    lb   $a1, grid($s1)
    beq  $a1, $0, get_number_of_rows
    j    get_length_of_grid
    
get_number_of_rows:
    move  $s0, $s1                # subtract row_length from grid_length
ou_mamma:                         # until grid_length = 0
    sub   $s0, $s0, $t8
    sub   $s0, $s0, 1
    addi  $t0, $t0, 1
    beqz  $s0, reset
    j     ou_mamma
    
reset:
    move $t2, $t0          # $t2 has number of rows 
    li   $t0, 0
    	
strfind:
         # Use load byte because grid is a char array	
    lb   $a1, grid($t1)                         # Load grid[grid_idx]
    beq  $a1, $0, check_if_print_minus_one	# if grid[grid_idx] == \0 check if should print -1
    addi $v0, $0, 10                            # newline
    beq  $a1, $v0, go_one_row_down
    beq  $t0, $t6, update_grid_idx      # if idx = dict_num_words -> for loop has finished updated:	
    la   $a2, dictionary                # word = dictionary
    lw   $t3, dictionary_idx($t0)       # get the starting int of the word	
    add  $a2, $a2, $t3                  # word = dictionary + dictionary_idx[idx]
    li   $s4, 0				# Store LENGTH of the word!!!!	
    la   $a3, grid                      # string = grid
    add  $a3, $a3, $t1                  # string = grid + grid_idx	
	
################ get the X coordinate starting from 0 ##################
    addi  $a0, $t9, 0   # we have number of row in temporary variable
    move  $s7, $t1      # we have the x coordinate + length of rows * number of rows
looooop:
    beqz  $a0, exit_looooop
    sub   $s7, $s7, $t8      # Subtract length of the row
    sub   $s7, $s7, 1        # take into account the newline
    addi  $a0, $a0, -1       # Update temporary variable of the for loop
    j     looooop            # s7 has the index_to_print
exit_looooop:
################ Start horizontal contain ##############################
              
    li   $s6, 0                         # This indicates I need to print a 'H'
    jal horizontalContain
    beq  $v1, 1, print_
coming_back_from_printing_H:
    li   $v1, 0
	
########## LOAD WORD AND STRING AGAIN TO HAVE THE RIGHT ADDRESS #################
	
    lb   $a1, grid($t1)                 # Load grid[grid_idx]	
    la   $a2, dictionary                # word = dictionary
    lw   $t3, dictionary_idx($t0)       # get the starting int of the word
    add  $a2, $a2, $t3                  # word = dictionary + dictionary_idx[idx]
    li   $s4, 0				# Store LENGTH of the word!!!!
    la   $a3, grid                      # string = grid
    add  $a3, $a3, $t1                  # string = grid + grid_idx
    
    
#################################################################################  
	
    li   $s6, 1                         # This indicates I need to print a 'V'	
    move  $a0, $t9                      # temp variable with number of row
    jal  vertical_contain
    beq  $v1, 1, print_
coming_back_from_printing_V:
    li  $v1, 0
    
########## LOAD WORD AND STRING AGAIN TO HAVE THE RIGHT ADDRESS #################
	
    lb   $a1, grid($t1)                 # Load grid[grid_idx]	
    la   $a2, dictionary                # word = dictionary
    lw   $t3, dictionary_idx($t0)       # get the starting int of the word
    add  $a2, $a2, $t3                  # word = dictionary + dictionary_idx[idx]
    li   $s4, 0				# Store LENGTH of the word!!!!
    la   $a3, grid                      # string = grid
    add  $a3, $a3, $t1                  # string = grid + grid_idx
    
    
 ################################################################################  
    move  $v0, $s7                # temp variable with number of column
    move  $a0, $t9                # temp variable with number of row
 
    li   $s6, 2                   # This indicates I need to print a 'D'
    jal diagonal_contain
    beq  $v1, 1, print_
coming_back_from_printing_D:
    li   $v1, 0
    
    addi $t0, $t0, 4                    # idx++ from the for loop	
    j    strfind
 
vertical_contain: 
    lb    $t4, ($a2)              # load char from word
    lb    $t5, ($a3)              # load char from string
    beq   $t4, $t5, follow_vertical_contain   # check if the characters are equal and update them
    addi  $v0, $0, 10             # newline in ascii is 10
    beq   $t4, $v0, isequal       # if word is equal to newline set v1 to 1 and come back to strfind
    li    $v1, 0                  # if not equal set v1 to zero and go back to
    jr    $ra                     # strfind        
  
follow_vertical_contain:
    addi  $s4, $s4, 1		  # stores the length if the words are the same
# check if we are in the last row:
    move  $s0, $t2                # $s0 has now number_of_rowsss
    addi  $s0, $s0, -1            # $s0 has the number of last row because we start from 0
    beq   $s0, $a0, go_to_first_row_vertical      # if number_of_row == number_of_rows - 1 
    add   $a3, $a3, $t8                 # update address of string by adding a row  
    addi  $a3, $a3, 1                   # Remember the newline AND that we have to add 1 for diagonal   
    addi  $a2, $a2, 1                   # updates address of word   
    addi  $a0, $a0, 1
    j     vertical_contain

go_to_first_row_vertical:
    beqz  $a0, update_word
    sub   $a3, $a3, $t8
    sub   $a3, $a3, 1                    # come back from the vertical
    addi  $a0, $a0, -1
    j     go_to_first_row_vertical
update_word:
    addi  $a2, $a2, 1
    j     vertical_contain
when_finished_update_word:
    addi  $a2, $a2, 1
    j     diagonal_contain



diagonal_contain:
    lb    $t4, ($a2)              # load char from word
    lb    $t5, ($a3)              # load char from string
    beq   $t4, $t5, follow_diagonal_contain   # check if the characters are equal and update them
    addi  $v0, $0, 10             # newline in ascii is 10
    beq   $t4, $v0, isequal       # if word is equal to newline set v1 to 1 and come back to strfind
    li    $v1, 0                  # if not equal set v1 to zero and go back to
    jr    $ra                     # strfind        
  
follow_diagonal_contain:
    addi  $s4, $s4, 1		  # stores the length if the words are the same
# check if we are in the last row:

    move  $s0, $t2                # $s0 has now number_of_rowsss
    addi  $s0, $s0, -1            # $s0 has the number of last row because we start from 0
    beq   $s0, $a0, go_to_first_row_or_column      # if number_of_row == number_of_rows - 1 
    move  $s0, $t8
    addi  $s0, $s0, -1            # $s0 has number of column
    beq   $s0, $v0, go_to_first_row_or_column      # if column == row_length - 1 (lst col without newline)   
    add   $a3, $a3, $t8                 # update address of string by adding a row  
    addi  $a3, $a3, 2                   # Remember the newline AND that we have to add 1 for diagonal   
    addi  $a2, $a2, 1                   # updates address of word   
    addi  $v0, $v0, 1
    addi  $a0, $a0, 1
    j     diagonal_contain

go_to_first_row_or_column:
    beqz  $a0, when_finished_update_word
    beqz  $v0, when_finished_update_word
    sub   $a3, $a3, $t8
    sub   $a3, $a3, 2                    # come back from the diagonal
    addi  $a0, $a0, -1
    addi  $v0, $v0, -1
    j     go_to_first_row_or_column
    
    
horizontalContain:	
    lb    $t4, ($a2)              # load char from word
    lb    $t5, ($a3)              # load char from string
    addi  $v0, $0, 10             # newline in ascii is 10
    beq   $t4, $t5, check_if_newline_equal   # if they are equal and '\n', print;
                                             # otherwise just keep going
    beq   $t5, $v0, horizontal_wrap
    beq   $t4, $v0, isequal       # if word is equal to newline set v1 to 1 and go to contain
    li    $v1, 0                  # if not equal set v1 to zero and go back to
    jr    $ra                     # strfind
	
update_grid_idx:
    add  $t1, $t1, 1		  # grid_idx++
    li  $t0, 0			  # set idx to zero after end of for loop
    j  strfind
	
isequal:
    li   $v1, 1		          # if equal set v1 to 1
    jr   $ra

horizontal_wrap:
    sub  $a3, $a3, $t8              # subtract length of row without newline!
    j    horizontalContain          # do not update word and check again


check_if_newline_equal:
    beq   $t4, $v0, print_

followContains:
    addi  $s4, $s4, 1			  # stores the length if the words are the same
    addi  $a2, $a2, 1                     # updates address of word
    addi  $a3, $a3, 1                     # updates address of string
    j	horizontalContain
			

print_:
    li    $v0, 1            
    move  $a0, $t9
    syscall             # print row
    li  $v0, 11
    li  $a0, 44
    syscall             # print comma
    li	$v0, 1
    move	$a0, $s7			
    syscall             # print grid_idx updated so that it goes from 0 to length_of_row
    li	$v0, 11
    li	$a0, 32
    syscall             # print space character
    beq $s6, 2, print_D # print 'D; if coming from diagonalContain
    beq $s6, 1, print_V # print 'V' if coming from horizontalContain
    beq $s6, 0, print_H # print 'H' if coming from verticalContain
        
coming_back_from_H:
coming_back_from_V:
coming_back_from_D:
    li   $a0, 32
    syscall             # print space
    move  $s2, $a2
    j     print_word  # print the word 
comeback:	
    li  $v0, 11
    li  $a0, 10
    syscall
	
    beq  $s6, 0, coming_back_from_printing_H
    beq  $s6, 1, coming_back_from_printing_V
    j  coming_back_from_printing_D
	
	##### MOVE THE ADDRESS OF THE WORD WHICH SHOULD BE NEWLINE TO ANOTHER REGISTER #####
	##### SUBTRACT LENGTH OF WORD FROM IT SO THAT WE HAVE THE FIRST CHARACTER ##########
	##### AND THEN PRINT_WORD SHOULD WORK NOW!!!!!!!!! I Hope at least it does #########
	
print_word:
    move $s3, $s2	
    sub  $s3, $s3, $s4	# get the address of the first char
    lb   $t7, ($s3)
    beq  $t7, $0, comeback
    addi $v0, $0, 10
    beq  $t7, $v0, comeback
    li   $v0, 11
    move $a0, $t7
    syscall
    addi $s2, $s2, 1    # update addres of word
    li   $s5, 1         # do not print minus one
    j	 print_word
		
print_H:
    li  $v0, 11
    li  $a0, 72 
    syscall
    j coming_back_from_H

print_V:
    li  $v0, 11
    li  $a0, 86 
    syscall
    j coming_back_from_V
	
print_D:
    li  $v0, 11
    li  $a0, 68 
    syscall
    j coming_back_from_D	

print_minus_one:
    li  $v0, 1
    li  $a0, -1
    syscall
    j  main_end

go_one_row_down:
    addi  $t9, $t9, 1     # update number of row
    addi  $t1, $t1, 1     # update grid_idx and come back to 
    j     strfind
        



check_if_print_minus_one:
	beqz	$s5, print_minus_one

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
