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
	mov di, 0
@@1:
	hlt
	mov bx, head
	cmp bx, tail
	jz	@@1
	call read_buf
	cmp al, 9Ch; down enter
	je @@1
	cmp al, 39h
	je @@1
	cmp al, 1Ch; up enter
	jne @@2
	call break_line
	jmp @@1
	@@2:
	cmp al, 0B9h
	jne @@3
	call clear
	jmp @@1
	@@3:
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
	mov ah, 1
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
symbols db '0123456789ABCDEF'
end _start