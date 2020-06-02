	.data
text:  	.asciiz "Enter string: \n" 
buf: 	.space 100

	.text
	.globl main
	
main:
	li $v0, 4
	la $a0, text
	syscall
	
	li $v0, 8
	la $a0, buf
	li $a1, 100
	syscall

	la $t0, buf	#adres bufora
	li $t1, 0		#ilosc cyfr
			
count_numbers:
	lb $t2, ($t0)
	beq $t2, '\n', pre_loop
	ble $t2, 47, up_1 	#jest to kod znaku / ktory jest bezposrednio przed cyframi
	bge $t2, 58, up_1	#kod znaku : - bezposrednio po liczbach
	addiu $t1, $t1, 1

up_1:
	addiu $t0, $t0, 1
	b count_numbers

pre_loop:
	ble $t1, 1, end
	move $t8, $t1
		
loop:
	subiu $t7, $t1 , 1
	la $t0, buf

find_num_1:
	lb $t2, ($t0)
	ble $t2, 47, up_2
	bge $t2, 58, up_2
	move $t4, $t0
	addiu $t0, $t0, 1
	
find_num_2:
	lb $t3, ($t0)
	ble $t3, 47, up_3
	bge $t3, 58, up_3
	
compare:
	ble $t2, $t3, swap
	move $t2, $t3
	move $t4, $t0
	subiu $t7, $t7, 1
	beqz $t7, condition
	addiu $t0, $t0, 1
	b find_num_2
	
swap:
	sb $t3, ($t4)
	sb $t2, ($t0)
	move $t4, $t0
	subiu $t7, $t7, 1
	beqz $t7, condition
	addiu $t0, $t0, 1
	b find_num_2	
up_2:
	addiu $t0, $t0, 1
	b find_num_1
	
up_3:
	addiu $t0, $t0, 1
	b find_num_2
	
condition:
	subiu $t8, $t8, 1
	bnez $t8 loop
	
end:
	li $v0, 4
	la $a0, buf
	syscall
	
	li $v0, 10
	syscall