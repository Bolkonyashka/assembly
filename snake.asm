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
	cmp al, 0ceh
	jz @@2
	cmp al, 0cah
	jz @@2
	cmp al, 81h
	jz @@2
	jmp @@9
@@2:
	;mov ah, game_end
	;cmp ah, 0
	;je next2
	;cmp al, 81h
	;je next2
	;mov al, 0
;next2:
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
	mov dh, cs:speed
	cmp al, 1
	jz @@3
	mov al, cs:counter_sneak
	inc al
	cmp al, dh;speed;10
	jbe @@2;
	;mov ah, game_end
	;cmp ah, 0
	;jne @@3;
	mov al, 0
	mov cs:counter_sneak, al	
	mov al, 30h
	call write_buf
	jmp @@3
@@2:
	mov cs:counter_sneak, al
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
;2 hor lines
	mov ah, 02h
	mov dh, 0
	mov dl, 19
	int 10h
	mov ah, 09h
	mov cx, 60
	mov bh, 0
	mov bl, 07h
	mov al, 0cdh
	int 10h
	mov ah, 02h
	mov dh, 24
	;mov dl, 19
	int 10h
	mov ah, 09h
	;mov cx, 60
	;mov bh, 0
	;mov bl, 07h
	;mov al, 0cdh
	int 10h

	mov ah, 02h
	mov dh, 0
	mov dl, 18
	int 10h
	mov ah, 09h
	mov cx, 1
	mov al, 0c9h
	int 10h
	mov ah, 02h
	mov dh, 0
	mov dl, 79
	int 10h
	mov ah, 09h
	mov al, 0bbh
	int 10h
	mov ah, 02h
	mov dh, 24
	mov dl, 18
	int 10h
	mov ah, 09h
	mov al, 0c8h
	int 10h
	mov ah, 02h
	mov dh, 24
	mov dl, 79
	int 10h
	mov ah, 09h
	mov al, 0bch
	int 10h

	;горизонтальные стены
	xor si, si
	xor cx, cx
	mov di, 198
	;mov ah, 7
	wall_loop:
		mov ah, hor_up[si]
		;add ah, 2
		cmp ah, 1
		je wall_next
		add ah, 5
		wall_next:
		mov al, 178
		stosw
		inc si
		cmp si, 60
		jl wall_loop
	xor si, si
	xor cx, cx
	mov di, 3718
	;mov ah, 7
	wall_loop2:
		mov ah, hor_down[si]
		cmp ah, 1
		je wall_next2
		add ah, 5
		wall_next2:
		mov al, 178
		stosw
		inc si
		cmp si, 60
		jl wall_loop2

	;mov cx, 25
	mov dh, 1
	mov bh, 0
	mov bl, 07h
	mov al, 0bah
vert_lines:
	;push cx
	mov ah, 02h
	mov dl, 18
	int 10h
	mov ah, 09h
	mov cx, 1
	int 10h
	push cx
	mov ah, 02h
	mov dl, 79
	int 10h
	mov ah, 09h
	mov cx, 1
	int 10h
	inc dh
	;pop cx
	cmp dh, 24
	jne vert_lines
	mov ah, 02h
	mov dl, 0
	mov dh, 25
	int 10h

	;вертикальные стены
	xor si, si
	xor cx, cx
	mov di, 358
	;mov ah, 7
	wall_loop3:
		mov ah, vert_left[si]
		cmp ah, 1
		je wall_next3
		add ah, 5
		wall_next3:
		mov al, 178
		stosw
		inc si
		add di, 158
		cmp si, 21
		jl wall_loop3
	
	xor si, si
	xor cx, cx
	mov di, 476
	;mov ah, 7
	wall_loop4:
		mov ah, vert_right[si]
		cmp ah, 1
		je wall_next4
		add ah, 5
		wall_next4:
		mov al, 178
		stosw
		inc si
		add di, 158
		cmp si, 21
		jl wall_loop4

	;портальчики
	mov di, 866
	mov ah, 3
	mov al, 86
	stosw

	mov di, 3010
	mov ah, 3
	mov al, 86
	stosw

;info
	mov di, 160
	xor si, si
	push di
text:
	cmp si, len
	jge next
	mov al, text1[si]
	inc si
	cmp al, 92
	jne print
	cmp text1[si], 'n'
	jne print
	pop di
	add di, 160
	push di
	inc si
	jmp text
	;inc si
	;jmp text
print:
	mov ah, 3
	stosw
	jmp text
next:
	mov di, 1680
	jmp speedup_bri

loop_gen:
	hlt
	mov bx, head
	cmp bx, tail
	jz loop_gen
	call read_buf
	call gec
	;mov ah, game_end
	;cmp ah, 0
	;jne reb_mark
	;cmp al, 30h
	;jz sec_up
	cmp al, 0cbh
	jz left
	cmp al, 0b9h
	jz start_stop
	cmp al, 0c8h
	jz up
	cmp al, 0cdh
	jz right
	;cmp al, 0cbh
	;jz left
	cmp al, 30h
	jz s_u;sec_up
	cmp al, 0d0h
	jz down;
	cmp al, 0ceh
	jz speedup_bri;
	cmp al, 0cah
	jz speeddown_bri
;reb_mark:
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
	jz c_rev;loop_gen
	mov al, 3
	mov direct, al
	jmp loop_gen
down:
	mov al, direct
	cmp al, 1
	jz c_rev;loop_gen
	mov al, 2
	mov direct, al
	jmp loop_gen
up:
	mov al, direct
	cmp al, 2
	jz c_rev;loop_gen
	mov al, 1
	mov direct, al
	jmp loop_gen
right:
	mov al, direct
	cmp al, 3
	jz c_rev;loop_gen
	mov al, 0
	mov direct, al
	jmp loop_gen
c_rev:
	call reverse
	jmp loop_gen
s_u:
	jmp sec_up
loop_gen_bri:
	jmp loop_gen
speedup_bri:
	jmp speedup
speeddown_bri:
	jmp speeddown
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
	mov al, dist
	inc al
	cmp al, 20
	jz scores_up_bri
sc_up_ret:
	mov dist, al;
	mov cx, snake_len
	sub cx, 1
	mov ax, 2
	mul cx
	mov si, ax;4;2
	mov di, snake_tail[si]
	mov ax, 0000h
	stosw
	
	mov cx, snake_len
	sub cx, 2
	mov ax, 2
	mul cx
	mov si, ax
	;mov si, 2;0
	;mov cx, 2;1
	mov cx, snake_len
	sub cx, 1
sneak_move_start:
	mov di, snake_tail[si]
	mov snake_tail[si+2], di
	sub si, 2
	loop sneak_move_start
	
	mov si, 0
	mov di, snake_tail[si]
	call move
	mov snake_tail[si], di
	
	pop si
	jmp loop_gen
scores_up_bri:
	jmp scores_up
loop_gen_bri2:
	jmp loop_gen_bri
speedup:
	mov al, speed
	cmp al, 0;2
	jz loop_gen_bri2
	sub al, 4
	mov speed, al
	mov di, 498
	mov ah, 3
	mov al, speedinfo
	inc al
	mov speedinfo, al
	stosw

	jmp loop_gen_bri
speeddown:
	mov al, speed
	cmp al, 16;18
	jz loop_gen_bri2
	add al, 4
	mov speed, al
	mov di, 498
	mov ah, 3
	mov al, speedinfo
	dec al
	mov speedinfo, al
	stosw

	jmp loop_gen_bri2
scores_up:
	;mov ah, 3
	;mov al, 178
	;mov di, 178
	;stosw

	;mov al, snake_len
	;inc al
	;mov snake_len, al
	;aam
	;mov ch, ah
	;mov ah, 3
	;mov di, 182
	;add al, 30h
	;mov al, bl
	;stosw
	;mov al, ch
	;add al, 30h
	;mov di, 180
	;stosw
	mov ax, snake_len
	inc ax
	mov snake_len, ax
	mov ax, scores
	xor ch, ch
	mov cl, speedinfo
	sub cx, 30h
	add ax, cx
	mov scores, ax
	mov bl, 10
	mov di, 178
	xor cx, cx
	vivoloop:
		inc cx
		div bl
		push ax
		cmp al, 0
		jz vivend
		xor ah, ah
		jmp vivoloop
		;add dl, 30h
		;mov ah, 3
		;mov di, 182
		;mov al, dl
		;stosw
	vivend:
		pop ax
		mov al, ah
		add al, 30h
		mov ah, 3
		stosw
		loop vivend
	mov al, 0
	jmp sc_up_ret
;4 9
snake_tail dw 1680, 1678, 1676, 1000 dup(0);, 1674, 1672, 1670, 1668
hor_up db 5 dup(1), 10 dup(0), 5 dup(1), 20 dup(1), 20 dup(1) 
hor_down db 5 dup(1), 10 dup(1), 5 dup(1), 20 dup(0), 20 dup(1) 
vert_left db 4 dup(1), 4 dup(0), 8 dup(1), 2 dup(0), 3 dup(1)
vert_right db 4 dup(1), 4 dup(1), 6 dup(1), 4 dup(0), 3 dup(1)
counter_sneak db 50
speed db 20;22
speedinfo db 30h
direct db 0
is_move db 0
dist db 0
snake_len dw 3
scores dw 0
game_end db 0
pre_direct db 0
prot db 3, 2, 1, 0
;apple dw 0
;apple_counter dw 0
;apple_lim dw 10
;apple_pos dw 0
;apple_list dw 944, 1090, 1260, 1326, 1700, 2064, 580, 3288, 2606, 1720

gec proc near
	mov ah, game_end
	cmp ah, 0
	je @@re
	cmp al, 81h
	je @@re
	mov al, 0
	@@re:
		ret
gec endp

reverse proc near
	mov ax, 2
	mul snake_len
	mov si, ax
	sub si, 2
	mov ax, snake_tail[si] 
	sub si, 2
	sub ax, snake_tail[si]
	cmp ax, 2
	je @@right
	cmp ax, 160
	je @@down
	cmp ax, -2
	je @@left
	jmp @@up

	@@right:
		mov pre_direct, 0
		jmp do_rev
	@@left:
		mov pre_direct, 3
		jmp do_rev
	@@down:
		mov pre_direct, 2
		jmp do_rev
	@@up:
		mov pre_direct, 1

	do_rev:

	mov ax, 2
	mul snake_len
	mov si, 0
	mov di, ax
	sub di, 2
	rev_loop:
		mov ax, snake_tail[si]
		mov bx, snake_tail[di]
		mov snake_tail[si], bx
		mov snake_tail[di], ax
		add si, 2
		sub di, 2
		cmp si, di
		jb rev_loop
	mov al, pre_direct;hhh
	cmp al, direct
	je @@retr
	xor ax, ax
	mov al, direct
	mov si, ax
	mov al, prot[si]
	mov direct, al
	@@retr:
	ret
reverse endp

move	proc near
	push si
	call shift
	call check
	pop si
	mov al, game_end
	cmp al, 0
	jne ret_mark
	
	;mov ax, 7000h
	mov ah, 2
	mov al, 1;64;79
	stosw
	push di
	mov di, snake_tail[2]
	mov al, 79
	stosw
	pop di
	sub di, 2
	ret_mark:	
		ret
move endp

check proc near
	cmp di, 866
	jne @@chnext
	mov di, 3010
	mov ah, direct
	cmp ah, 3
	je @@lft
	cmp ah, 0
	je @@rght
	cmp ah, 1
	je @@up
	jmp @@dwn
	;jmp @@chnext2
	@@chnext:
	cmp di, 3010
	jne @@chnext2
	mov di, 866
	mov ah, direct
	cmp ah, 3
	je @@lft
	cmp ah, 0
	je @@rght
	cmp ah, 1
	je @@up
	jmp @@dwn
	;jmp @@chnext2
	@@lft:
		sub di, 2
		jmp @@chnext2
	@@rght:
		add di, 2
		jmp @@chnext2
	@@up:
		sub di, 160
		jmp @@chnext2
	@@dwn:
		add di, 160
		jmp @@chnext2
	@@chnext2:
	mov cx, snake_len
	sub cx, 1
	mov ax, 2
	mul cx
	mov si, ax;проверка на самопоедание
	ch_loop:
		mov bx, snake_tail[si]
		cmp di, bx
		je game_end_pr
		cmp si, 0
		je ch_walls;ret_m
		sub si, 2
		jmp ch_loop
	ch_walls:
	;проверка на стенки
	call check_walls
	cmp cx, 0
	je ret_m

	game_end_pr:
		mov al, game_end
		inc al
		mov game_end, al
		mov di, 1638
		mov ah, 4
		mov al, 205
		print_loop:
			stosw
			cmp di, 1758
			jne print_loop
			mov di, 1798
			mov ax, 0
		print_loop2:
			stosw
			cmp di, 1918
			jl print_loop2
			add di, 40
		print_loop3:
			stosw
			cmp di, 2078
			jl print_loop3
			add di, 40
		print_loop4:
			stosw
			cmp di, 2238
			jl print_loop4
			xor si, si
			mov ah, 4
			mov di, 2008
		print_gn:
			cmp si, gnlen
			jge prnext
			mov al, goodnews[si]
			stosw
			inc si
			jmp print_gn
		prnext:
			mov di, 2278
			mov ah, 4
			mov al, 205
		print_loop5:
			stosw
			cmp di, 2398
			jne print_loop5
	ret_m:
	 	ret
check endp

check_walls proc near
	mov cx, 0
	cmp di, 320
	jle @@hor_up
	cmp di, 3718
	jge @@hor_down
	jmp check_vert

	@@hor_up:
		mov bx, di
		sub bx, 200
		xor si, si
		@@finder:
			mov ax, 2
			mul si
			inc si
			cmp ax, bx
			jne @@finder
		xor ax, ax
		mov al, hor_up[si]
		cmp al, 0
		je @@wret
		mov cx, 1
		mov ax, snake_tail[2]
		cmp ax, 3718
		jle @@wret
		mov hor_up[si], 0 
		mov cx, 0
		@@wret:
			ret
	@@hor_down:
		mov bx, di
		sub bx, 3720
		xor si, si
		@@finder2:
			mov ax, 2
			mul si
			inc si
			cmp ax, bx
			jne @@finder2
		xor ax, ax
		mov al, hor_down[si]
		cmp al, 0
		je @@wret2
		mov cx, 1
		mov ax, snake_tail[2]
		cmp ax, 320
		jge @@wret2
		mov hor_down[si], 0 
		mov cx, 0
		@@wret2:
			ret
	check_vert:
		mov bx, di
		mov cx, 0
		@@vichet:
			inc cx
			sub bx, 160
			cmp bx, 480
			ja @@vichet

		;sub cx, 1
		cmp bx, 358
		;ja @@ver_right
		je @@ver_left
		cmp bx, 476
		je @@ver_right
		mov cx, 0
		jmp @@wret3

		@@ver_left:
			mov si, cx
			mov cx, 0
			mov al, vert_left[si]
			cmp al, 0
			je @@wret3
			mov cx, 1
			mov ax, snake_tail[0]
			sub ax, di
			cmp ax, 10
			jb @@wret3
			mov vert_left[si], 0 
			mov cx, 0
			@@wret3:
				ret

		@@ver_right:
			mov si, cx
			mov cx, 0
			mov al, vert_right[si]
			cmp al, 0
			je @@wret4
			mov cx, 1
			mov ax, di
			sub ax, snake_tail[0]
			cmp ax, 10
			jb @@wret4
			mov vert_right[si], 0 
			mov cx, 0
			@@wret4:
				ret
	
check_walls endp

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
	mov dx, 156;158
	mov cx, 25
@@loop_right:
	cmp dx, di
	jz @@right_shift
	add dx, 160
	loop @@loop_right
	add di, 2
	jmp @@end
@@right_shift:
	sub di, 118;158
	jmp @@end
	
@@direct_up:
	mov dx, 160;0
	mov cx, 80
@@loop_up:
	cmp dx, di
	jz @@up_shift
	add dx, 2
	loop @@loop_up
	sub di, 160
	jmp @@end
@@up_shift:
	add di, 160*22;160*24
	jmp @@end

@@direct_down:
	mov dx, 160*23;160*24
	mov cx, 80
@@loop_down:
	cmp dx, di
	jz @@down_shift
	add dx, 2
	loop @@loop_down
	add di, 160
	jmp @@end
@@down_shift:
	sub di, 160*22;160*24
	jmp @@end

@@direct_left:
	mov dx, 38;0
	mov cx, 25
@@loop_left:
	cmp dx, di
	jz @@left_shift
	add dx, 160
	loop @@loop_left
	sub di, 2
	jmp @@end
@@left_shift:
	add di, 118;158
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
goodnews db ' You died.'
gnlen dw $-goodnews
text1 db ' Scores: 0\n\n'
	  db ' Speed: \n\n\n'
      db ' Help!\n\n'
	  db ' Change speed:\n +/- \n\n'
	  db ' Stop:\n Space button\n\n'
	  db ' Snake control:\n Arrow buttons'
len dw $-text1
end _start