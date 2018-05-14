	model 	tiny
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
	in 	al, 61h
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
	mov 	ax, 3
	int	10h
	mov ax, 0b800h
	mov es, ax
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
	push cs
	pop ds
	push ax
	push es
	push di
	mov ax, 0b800h
	mov es, ax
	mov di, 0
@@1:
	hlt
	mov bx, head
	cmp bx, tail
	jz	@@1
	call read_buf
	call print
	cmp	al, 81h
	jnz	@@1
;
	pop di
	pop es
	pop ax
	xor ax, ax
	push ax
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
	mov ah, 07h
	mov bl, al
	shr al, 4
	.386
	movzx si, al
	.286
	mov al, symbols[si]
	stosw
	mov al, bl
	shl al, 4
	shr al, 4
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