.globl _start
.text
_start:
	cmp $5, (%esp)
	jne exit

	mov $5, %eax
	mov 2*4(%esp), %ebx
	mov $2, %ecx
	int $0x80
	pushl %eax
	mov $3, %eax
	popl %ebx
	mov $str, %ecx
	mov $13842, %edx
	int $0x80

	mov %eax, %ebp
	dec %ebp

	mov $5, %eax
	mov 3*4(%esp), %ebx
	mov $2, %ecx
	int $0x80
	pushl %eax

	mov $0, %eax
	mov $0, %ecx
	mov 4*4(%esp), %ebx
	mov (%ebx), %eax
	shr $24, %eax
	sub $48, %eax
	inc %ebx
	cmpb $0, (%ebx)
	je end_s
	mov $10, %eax
	mov (%ebx), %edx
	shr $24, %edx
	sub $48, %edx
	add %edx, %eax

	mov $32, %ecx
	mul %ecx
	add $4096, %eax	
	inc %eax
	mov %eax, %ecx
	popl %ebx
	mov $19, %eax
	mov $0, %edx
	int $0x80

	mov $4, %eax
	mov $msg, %ecx
	mov $1, %edx
	int $0x80
	pushl %ebx
	mov 6*4(%esp), %ebx
	mov $name, %ecx
loop_b:	
	mov (%ebx), %edx
	mov %edx, (%ecx)
	inc %ebx
	inc %ecx
	mov (%ebx), %edx
	shr $24, %edx
	cmp $0, %edx
	jne loop_b
ssss:
	
	mov $0, %eax
	mov $0, %ecx
	mov 4*4(%esp), %ebx
	mov (%ebx), %eax
	shr $24, %eax
	sub $48, %eax
	inc %ebx
	cmpb $0, (%ebx)
	je end_s
	mov $10, %eax
	mov (%ebx), %edx
	shr $24, %edx
	sub $48, %edx
	add %edx, %eax

	mov $32, %ecx
	mul %ecx
	add $4096, %eax	
	inc %eax
	inc %eax
	mov %eax, %ecx
	popl %ebx
	mov $19, %eax
	mov $0, %edx
	int $0x80

	mov $4, %eax	
	mov $name, %ecx
	mov $30, %edx
	int $0x80
	pushl %ebx

	mov $0, %eax
	mov $0, %ecx
	mov 4*4(%esp), %ebx
	mov (%ebx), %eax
	shr $24, %eax
	sub $48, %eax
	inc %ebx
	cmpb $0, (%ebx)
	je end_s
	mov $10, %eax
	mov (%ebx), %edx
	shr $24, %edx
	sub $48, %edx
	add %edx, %eax
end_s:	
	mov $13824, %ecx
	mul %ecx
	mov %eax, %ecx
	add $4608, %ecx
	popl %ebx
	
	mov $19, %eax
	mov $0, %edx
	int $0x80
	
	mov $13824, %ecx
loop_a:
	pushl %ecx
	mov $4, %eax
	mov $zero, %ecx
	mov $1, %edx
	int $0x80
	popl %ecx
	loop loop_a

	mov $4, %eax
	mov $str, %ecx
	mov %ebp, %edx
	int $0x80

exit:
	mov $1, %eax
	mov $0, %ebx
	int $0x80
.data
name: .ascii "                                        \n"
msg: .byte 1
zero: .byte 0
str: .byte 0
