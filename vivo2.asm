	.model 	tiny
	.code
	org	100h
	locals
_start:
	jmp begin
theend db 0
buf db 10 dup(0)
bufend:
head	dw offset buf
tail	dw offset buf
write_buf	proc near
	push 	di
	push 	bx
	push 	bp
	mov		di, cs:tail
	mov 	bx, di
	inc		di
	cmp		di, offset bufend
	jnz		@@1
	mov		di, offset buf
@@1:
	mov		bp, di
	cmp 	di, cs:head
	jz		@@9
	mov		di, bx
	mov 	byte ptr cs:[di], al
	mov 	cs:tail, bp
@@9:
	pop		bp
	pop 	bx
	pop		di
	ret
write_buf endp
int9 proc near
	push ax
	in 	al, 60h
	call write_buf
	in 	al, 61h;дальше идёт подтверждение??
	mov	ah, al
	or	al, 80h
	out	61h, al
	mov	al, ah
	out	61h, al
	mov	al, 20h
	out	20h, al
	pop ax
	iret
int9 endp
old9 dw 0, 0
begin proc near
	xor ax, ax
	mov ds, ax
	mov	si, 36
	mov	di, offset old9
	movsw
	movsw
	cli
	mov	ax, offset int9
	mov	ds:36, ax
	mov	ax, cs
	mov	ds:38, ax
	sti
	;;;;;;;;
	push cs
	pop ds
	push ax
	push es
	push di
	mov ax, 3
	int	10h
	mov ax, 0b800h
	mov es, ax
	;убираем курсор
	mov di, 0
	mov ah, 2
	mov dh, 26
	int 10h
	call print_help
	;int 20h
@@1:
	hlt
	mov bx, head
	cmp bx, tail
	jz	@@1
	call read_buf
	cmp al, 3Ch; down F2
	je @@1
	cmp al, 3Bh; down F1
	je @@1
	cmp al, 9Ch; up enter
	je @@1
	cmp al, 39h; down space
	je @@1
	cmp al, 1Ch; down enter
	jne @@2
	call break_line
	jmp @@1
@@2:
	cmp al, 0B9h; up space
	jne @@3
	call clear
	jmp @@1
@@3:
	cmp al, 0BCh; up F2
	jne @@4
	call change_mode
	jmp @@1
@@4:
	cmp al, 0BBh; up F1
	jne @@5
	mov ah, 05h
	mov al, 1h
	int 10h
@@6:
	hlt
	mov bx, head
	cmp bx, tail
	jz	@@6
	call read_buf
	cmp al, 0BBh
	jne @@6
	mov ah, 05h
	mov al, 0h
	int 10h
	jmp @@1
@@5:
	call print
	cmp	al, 81h
	jnz	@@1
;
	pop di
	pop es
	pop ax
	push 0
	pop es
	push cs
	pop	ds
	mov	si, offset old9
	mov	di, 36
	cli
	movsw
	movsw
	sti
	int 19h
begin endp
print proc near
	push bx
	push ax
	push si
	cmp di, 4000
	jng @@1
	pop si
	pop ax
	pop bx
	ret
@@1:
	mov ah, color
	mov bl, al
	shr al, 4
	.386
	movzx si, al
	.286
	mov al, symbols[si]
	stosw
	mov al, bl
	and al, 1111b
	.386
	movzx si, al
	.286
	mov al, symbols[si]
	stosw
	mov al, 0
	stosw
	stosw
	pop si
	pop ax
	pop bx
	ret
print endp
break_line	proc near
	push ax
	push bx
	push dx
	xor dx, dx
	mov ax, di
	mov bx, 160
	div bx
	mov bx, 160
	add ax, 1
	mul bx
	mov di, ax
	pop dx
	pop bx
	pop ax
	ret
break_line endp
clear	proc near
	push ax
	push dx
	push cx
	mov cx, 0
	mov dh, 25
	mov dl, 80
	mov ah, 06h
	mov al, 0
	int 10h
	mov di, 0
	pop cx
	pop dx
	pop ax
	ret
clear endp
change_mode proc near
	inc color
	cmp color, 10
	jng @@1
	mov color, 1
	@@1:
	ret
change_mode endp
read_buf	proc near
	mov bx, head
	mov al, byte ptr ds:[bx]
	inc bx
	cmp	bx, offset bufend
	jnz	@@1
	mov bx, offset buf
@@1:
	mov head, bx
	ret
read_buf endp
print_help	proc near
	push ax
	push si
	push di
	mov ax, 0b900h
	mov es, ax
	;убираем курсор
	mov di, 0
	mov bh, 1
	mov ah, 2
	mov dh, 26
	int 10h
	xor si, si
	@@1:
		cmp si, len
		jge exit
		mov al, text1[si]
		inc si
		cmp al, 92
		jne @@2
		cmp text1[si], 'n'
		jne @@2
		call break_line
		inc si
		jmp @@1
	@@2:
		mov ah, 3
		stosw
		jmp @@1
	exit:
		mov ax, 0b800h
		mov es, ax
		pop di
		pop si
		pop ax
		ret
print_help endp
symbols db '0123456789ABCDEF'
color db 3
text1 db ' *** HELP ***\n\n *** Keyboard character codes scanner. Available options: ***\n\n F2 - change text color.\n\n'
	  db ' Enter - output starts to a new line.\n\n'
      db ' Space - clear the output screen.\n\n *** Press F1 key to return... ***'
len dw $-text1
end _start