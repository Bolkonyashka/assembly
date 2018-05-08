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
	cmp al, 0c8h
	jz @@2
	cmp al, 0cbh
	jz @@2
	cmp al, 0cdh
	jz @@2
	cmp al, 0d0h
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
	mov al, cs:switch
	cmp al, 1
	jz @@3
	mov al, counter_sneak
	inc al
	cmp al, 10
	jle @@2
	mov al, 0
	mov counter_sneak, al	
	mov al, 30h
	call write_buf
@@2:
	mov counter_sneak, al
@@3:
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
	cmp al, 0c8h
	jz up
	cmp al, 0cdh
	jz right
	cmp al, 0cbh
	jz left
	cmp al, 0d0h
	jz down
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
left:
	mov al, direct
	cmp al, 0
	jz loop_gen
	mov al, 3
	mov direct, al
	jmp loop_gen
down:
	mov al, direct
	cmp al, 1
	jz loop_gen
	mov al, 2
	mov direct, al
	jmp loop_gen
up:
	mov al, direct
	cmp al, 2
	jz loop_gen
	mov al, 1
	mov direct, al
	jmp loop_gen
right:
	mov al, direct
	cmp al, 3
	jz loop_gen
	mov al, 0
	mov direct, al
	jmp loop_gen
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
	push si
	mov si, 12
	mov di, sneak_tail[si]
	mov ax, 0000h
	stosw

	mov si, 10
	mov cx, 6
sneak_move_start:
	mov di, sneak_tail[si]
	mov sneak_tail[si+2], di
	sub si, 2
	loop sneak_move_start
	
	mov si, 0
	mov di, sneak_tail[si]
	call move
	mov sneak_tail[si], di
	
	pop si
	jmp loop_gen

sneak_tail dw 1680, 1678, 1676, 1674, 1672, 1670, 1668
counter_sneak db 50
direct db 0
is_move db 0
move	proc near
	call shift
	
	mov ax, 7000h
	stosw
	sub di, 2
	
	
	ret
move endp

shift	proc near
	mov al, direct
	cmp al, 0
	jz @@direct_right
	cmp al, 1
	jz @@direct_up
	cmp al, 2
	jz @@direct_down
	cmp al, 3
	jz @@direct_left
@@direct_right:
	mov dx, 158
	mov cx, 25
@@loop_right:
	cmp dx, di
	jz @@right_shift
	add dx, 160
	loop @@loop_right
	add di, 2
	jmp @@end
@@right_shift:
	sub di, 158
	jmp @@end
	
@@direct_up:
	mov dx, 0
	mov cx, 80
@@loop_up:
	cmp dx, di
	jz @@up_shift
	add dx, 2
	loop @@loop_up
	sub di, 160
	jmp @@end
@@up_shift:
	add di, 160*24
	jmp @@end

@@direct_down:
	mov dx, 160*24
	mov cx, 80
@@loop_down:
	cmp dx, di
	jz @@down_shift
	add dx, 2
	loop @@loop_down
	add di, 160
	jmp @@end
@@down_shift:
	sub di, 160*24
	jmp @@end

@@direct_left:
	mov dx, 0
	mov cx, 25
@@loop_left:
	cmp dx, di
	jz @@left_shift
	add dx, 160
	loop @@loop_left
	sub di, 2
	jmp @@end
@@left_shift:
	add di, 158
	jmp @@end
	
@@end:
	ret
shift endp
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