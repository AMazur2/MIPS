	.data
	    .align 4
buf:	    .space 4
size:	    .space 4
offset:	    .space 4
width:	    .space 4
height:	    .space 4
padding:	    .space 4
start:	    .space 4
actualWidth:  .space 4
pointer:	    .space 4
	
welcome:	.asciiz "Brnsley Fern generator\n"
finish:	.asciiz "Finished\n"
fileIn:	.asciiz "empty.bmp"
fileOut:	.asciiz "new80000000.bmp"
fileError:.asciiz "Error with data or during file editing\n"

# s0 - adres zaalokowanej pamiêci
# s1 - size
# s2 - actual width
# s3 - height
# s4 - current x
# s5 - current y
# s6 - next x
# s7 - next y
# t8 - x do rysowanie
# t9 - y do rysowania

	.text
	.globl main
main:
	la $a0, welcome
	li $v0, 4
	syscall


openFile:
	la $a0, fileIn
	li $a1, 0 	#read only
	li $a2, 0
	li $v0, 13
	syscall
	
	move $t0, $v0 	
	bltz $t0, error
	
readHeader:
	move $a0, $t0
	la $a1, buf 	#read signature
	li $a2, 2
	li $v0, 14
	syscall 
	
	move $a0, $t0
	la $a1, size 	
	li $a2, 4
	li $v0, 14
	syscall
	
	move $a0, $t0
	la $a1, buf 	#read 4 reserved bits
	li $a2, 4
	li $v0, 14
	syscall
	
	move $a0, $t0
	la $a1, offset 	
	li $a2, 4
	li $v0, 14
	syscall
	
	move $a0, $t0
	la $a1, buf 	#read size of header
	li $a2, 4
	li $v0, 14
	syscall	
	
	move $a0, $t0
	la $a1, width 	
	li $a2, 4
	li $v0, 14
	syscall
	
	move $a0, $t0
	la $a1, height 	
	li $a2, 4
	li $v0, 14
	syscall		
	
	move $a0, $t0
	li $v0, 16
	syscall 		#close and open to re-set pointer

allocateMem:
	lw $a0, size
	li $v0,9
	syscall
	
	move $s0, $v0 	#adres zaalokowanej pamiêci
	sw $s0, start
	
readBites:
	la $a0, fileIn
	li $a1, 0 
	li $a2, 0
	li $v0, 13
	syscall
	
	move $t0, $v0 	#deskryptor
	
	move $a0, $v0
	la $a1, ($s0)
	lw $s1, size
	la $a2, ($s1) 	
	li $v0, 14
	syscall
	
	move $a0, $t0
	li $v0, 16
	syscall

setPadding:
	lw $t2, width
	mul $t6, $t2, 3		
	andi $t6, $t6, 3	 
	
setPointer:
	lw $t0, offset
	addu $s0, $s0, $t0
	
setParameters:
	lw $s2, width
	mulu $t7, $s2, 3
	addu $s2, $t7, $t6
	subiu $t7, $t7, 3 	 
	sw $s2, actualWidth	#s2 actualWidth (width*3+padding)
	
	lw $s3, height
	
set1x1:
	addiu $s2, $s2, 3
	addu $s0, $s0, $s2	#ustawiamu pointer na punkt (1,1) 
	sw $s0, pointer

preloop:
	li $t7, 80000000 	#liczba iteracji programu

loop:
	li $v0, 42
	li $a1, 1000
	syscall		#losuje randomow¹ liczbê z przedzia³u 0-1000
	
	blt $a0, 10, fun1
	blt $a0, 860, fun2
	blt $a0, 930, fun3
	
#f4(x,y) = (0, 0.16y)
fun4:
	li $s6, 0 #nowy x
	
	li $t1, 0x28F #0.16
	sll $t1, $t1, 2
	
	mult $s5, $t1 #0.16*y
	mflo $t4
	sra $s7, $t4, 14 #nowy y
	
	b scale
	
# f1(x,y) = (0.85x+0.04y, -0.04x+0.85y+1.6)
fun1:
	#obliczane nastêpnego x:
	li $t1, 0xD99 	#0.85
	sll $t1, $t1, 2
	li $t2, 0x0A3 	#0.04
	sll $t2, $t2, 2
	
	mult $t1, $s4 	#0.85*x
	mflo $t4
	sra $t4, $t4, 14 	#wyrównando do przecinka
	
	mult $t2, $s5 	#0.04*y
	mflo $t5
	sra $t5, $t5, 14
		
	add $s6, $t4, $t5 	#0.85*x + 0.04*y - nowy x
	
	#obliczanie nowego y:
	li $t2, -0x0A3 	#-0.04
	sll $t2, $t2, 2
	li $t3, 0x1999 	#1.6
	sll $t3, $t3, 2
	
	mult $t2, $s4 	#-0,04*x
	mflo $t4
	sra $t4, $t4, 14
	
	mult $t1, $s5 	#0.85*y
	mflo $t5
	sra $t5, $t5, 14
	
	add $s7, $t4, $t5 	#-0,04*x + 0.85*y
	add $s7, $s7, $t3 	#+ 1.6 - nowy y
	
	b scale
	
# f2(x,y) = (-0.15x+0.28y, 0.26x+0.24y+0.44)
fun2:
	li $t1, -0x266 	#-0.15
	sll $t1, $t1, 2
	li $t2, 0x47A 	#0.28
	sll $t2, $t2, 2
	
	mult $t1, $s4 	#-0.15*x
	mflo $t4
	sra $t4, $t4, 14
	
	mult $s5, $t2	#0.28*y
	mflo $t5
	sra $t5, $t5, 14
	
	add $s6, $t4, $t5	#-0.15*x + 0.28*y - nowy x
	
	li $t1, 0x428 	#0.26
	sll $t1, $t1, 2
	li $t2, 0x3D7 	#0.24
	sll $t2, $t2, 2
	li $t3, 0x70A 	#0.44
	sll $t3, $t3, 2
	
	mult $t1, $s4 	#0.26*x
	mflo $t4
	sra $t4, $t4, 14
	
	mult $t2, $s5 	#0.24*y
	mflo $t5
	sra $t5, $t5, 14
	
	add $s7, $t4, $t5 	#0.26*x + 0.24*y
	add $s7, $s7, $t3 	#+0.44 - nowy y 
	
	b scale
	
#f3(x,y) = (0.20x-0.26y, 0.23x+0.22y+1.6)
fun3:
	li $t1, 0x333 	#0.20
	sll $t1, $t1, 2
	li $t2, -0x428 	#-0.26
	sll $t2, $t2, 2
	
	mult $t1, $s4 	#0.20*x
	mflo $t4
	sra $t4, $t4, 14
	
	mult $t2, $s5 	#-0.26*y
	mflo $t5
	sra $t5, $t5, 14
	
	add $s6, $t4, $t5 	#0.20*x-0.26*y - nowy x

	
	li $t1, 0x3AE 	#0.23
	sll $t1, $t1, 2
	li $t2, 0x385 	#0.22
	sll $t2, $t2, 2
	li $t3, 0x1999 	#1.6
	sll $t3, $t3, 2
	
	mult $t1, $s4 	#0.23*x
	mflo $t4
	sra $t4, $t4, 14
	
	mult $t2, $s5 	#0.22*y
	mflo $t5
	sra $t5, $t5, 14
	
	add $s7, $t4, $t5 	#0.23*x + 0.22*y
	add $s7, $s7, $t3 	#+ 1.6 - nowy y

#skalowanie:
# xrys = szerokoœæ*(x+3)/6
# yrys = wysokoœæ - wysokoœæ*(y+2)/14	
scale:
	lw $s2,actualWidth
	
	li $t1, 3
	sll $t1, $t1, 14
	
	li $t2, 2
	sll $t2, $t2, 14
	
	li $t3, 6
	li $t4, 7
	
	addu $t8, $s6, $t1	#x+3
	div $t8, $t8, $t3 	#/6
	mul $t8, $t8, $s2 	#szer*t8
	sra $t8, $t8, 14 	#wyrównanie do liczby ca³kowitej - xrys
	
	addu $t9, $s7, $t2	#y+2
	div $t9, $t9, $t4 	#/14
	mul $t9, $t9, $s3 	#wysokoœc * wart
	sra $t9, $t9, 14 	#wyrównanie przecinka
	
	move $s4, $s6 	#ustawiamy x na now¹ wartoœæ
	move $s5, $s7 	#ustawiamy y na now¹ wartoœæ
	
draw:				
	lw $s0, pointer
	
	mul $s2, $s2, $t9
	addu $s2, $s2, $t8
	addu $s0, $s0, $s2
	
fill:			#koloruje piksel na zielono	
	li $t1, 128
	sb $zero, 2($s0)
	sb $zero, 1($s0)
	sb $zero, 0($s0)
	
	
	sub $t7, $t7, 1
	
	bgtz $t7, loop

saveFile:			
	la $a0, fileOut
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
	
	move $t0, $v0
	
	bltz $t0, error
	lw $s1, size
	lw $s0, start
	move $a0, $t0
	la $a1, ($s0)
	la $a2, ($s1)
	li $v0, 15
	syscall
	
	move $a0, $t0
	li $v0, 16
	syscall
	
	b end
	
error:
	la $a0, fileError
	li $v0, 4
	syscall

end:
	la $a0, finish
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
