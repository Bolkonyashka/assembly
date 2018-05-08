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
	cli
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
	sti
	ret
write_buf endp
int9 proc near
	push ax
	push bx
	push cx
	push dx
	in 	al, 60h
	cmp al, 0b9h
	jz @@2
	cmp al, 09ch
	jz @@2
	cmp al, 81h
	jz @@2
	jmp @@9
@@2:
	call write_buf
@@9:
	in 	al, 61h
	mov	ah, al
	or	al, 80h
	out	61h, al
	mov	al, ah
	out	61h, al
	mov	al, 20h
	out	20h, al
	pop dx
	pop cx
	pop bx
	pop ax
	iret
int9 endp
old9 dw 0, 0
iterb db 0
int1c proc near
	cli
	push ax
	mov al, iterb
	inc al
	mov ah, 07h
	mov di, 0
	
	
	mov al, cs:switch
	cmp ax, 0700h
	jz @@next_up
	jmp @@2
@@next_up:
	mov al, iterb
	inc al
	cmp al, counter
	jz @@ttr_up
	mov iterb, al
	jmp @@2
@@ttr_up:
	mov al, 0
	mov iterb, al
	mov al, itera
	cmp al, ccs
	jz @@ttra_up
	inc al
	mov itera, al
	mov al, 18
	mov counter, al
	jmp @@ttrb_up
@@ttra_up:
	mov al, 0
	mov itera, al
	mov al, 19
	mov counter, al
	mov al, 4
	mov ccs, al
@@ttrb_up:
	mov al, 0
	mov iterb, al
	
	mov al, 30h
	call write_buf
@@2:
	mov	al, 20h
	out	20h, al
	pop ax
	sti
	iret
int1c endp
old1c dw 0, 0
begin:
	mov ax, 3
	int	10h
	mov ah, 02h
	mov bh, 0
	mov dh, 25
	mov dl, 0
	int 10h
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
	
	mov	si, 112
	mov	di, offset old1c
	movsw	
	movsw
	cli
	mov	ax, offset int1c
	mov	ds:112, ax
	mov	ax, cs
	mov	ds:114, ax
	sti
	
	push cs
	pop ds
	push ax
	push es
	push di
	mov ax, 0b800h
	mov es, ax
	mov cx, 0ffffh
	mov ax, 0
loop_b:
	stosw
	loop loop_b
	mov di, 0
	mov dl, 07h
	mov di, 1680
	jmp up_exit
loop_gen:
	hlt
	mov bx, head
	cmp bx, tail
	jz loop_gen
	call read_buf
	cmp al, 30h
	jz sec_up
	cmp al, 0b9h
	jz start_stop
	cmp al, 09ch
	jz reset
	cmp	al, 81h
	jnz	loop_gen
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
switch db 0
reset:
	cli
	mov al, 0
	mov hour, al
	mov minute, al
	mov second, al
	mov itera, al
	mov al, 18
	mov counter, al
	mov al, 3
	mov ccs, al
	mov di, 1680
	sti
	jmp up_exit
start_stop:
	mov al, switch
	cmp al, 0
	jz stop
	mov al, 0
	mov switch, al
	jmp loop_gen
stop:
	mov al, 1
	mov switch, al
	jmp loop_gen
sec_up:
	mov di, 1680
	mov al, second
	inc al
	cmp al, 60
	jz minute_up
	mov second, al
	jmp up_exit
minute_up:
	mov al, 0
	mov second, al
	mov al, minute
	inc al
	cmp al, 60
	jz hour_up
	mov minute, al
	jmp up_exit
hour_up:
	mov al, 0
	mov minute, al
	mov al, hour
	inc al
	mov hour, al
	jmp up_exit
up_exit:
	.386
	movzx ax, hour
	.286
	call print
	mov al, ':'
	stosw
	.386
	movzx ax, minute
	.286
	call print
	mov al, ':'
	stosw
	.386
	movzx ax, second
	.286
	call print
	jmp loop_gen
itera db 0
counter db 18
ccs db 3
hour db 0
minute db 0
second db 0
print proc near
	cli
	mov bl, 10
	div bl
	mov dl, ah
	mov ah, 07h
	add al, '0'
	stosw
	mov al, dl
	add al, '0'
	stosw
	sti
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
end _start