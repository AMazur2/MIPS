	.data
prompt: .asciiz "Enter string: " 
buf:	.space 100
	
	.text
	.globl main
	
main:	
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 8
	la $a0, buf
	li $a1, 100
	syscall
	
	li $t0, 'a'
	li $t1, 'z'
	li $t2, 0x20 	#'a'-'A' = 32
	
	la $t3, buf	# char* t3 = buf
	lb $t4, ($t3)	# char t4 = *t3
	beqz $t4, end
	
loop:
	blt $t4, $t0, next
	bgt $t4, $t1, next
	
	sub $t4, $t4, $t2
	sb $t4, ($t3)
	
next:
	addi $t3, $t3, 1	#inkrementujemy adres t3
	lb $t4, ($t3)
	bnez $t4, loop
	
end:
	li $v0, 4
	la $a0, buf
	syscall 
	
	li $v0, 10
	syscall
	