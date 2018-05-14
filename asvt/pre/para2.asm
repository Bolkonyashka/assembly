model tiny 
.code 
org 100h 
locals 
_start: 
jmp begin 
theend db 0 
buf db 10 dup(0) 
bufend: 
head dw offset buf 
tail dw offset buf 
write_buf proc near 
push di 
push bx 
push bp 
mov di, cs:tail 
mov bx, di 
inc di 
cmp di, offset bufend 
jnz @@1 
mov di, offset buf 
@@1: 
mov bp, di 
cmp di, cs:head 
jz @@9 
mov di, bx 
mov byte ptr cs:[di], al 
mov cs:tail, bp 
@@9: 
pop bp 
pop bx 
pop di 
ret 
write_buf endp 
int9 proc near 
push ax 
in al, 60h 
call write_buf 
in al, 61h 
mov ah, al 
or al, 80h 
out 61h, al 
mov al, ah 
out 61h, al 
mov al, 20h 
out 20h, al 
pop ax 
iret 
int9 endp 
old9 dw 0, 0 
begin proc near 
mov ax, 3 
int 10h 
xor ax, ax 
mov ds, ax 
mov si, 36 
mov di, offset old9 
movsw 
movsw 
cli 
mov ax, offset int9 
mov ds:36, ax 
mov ax, cs 
mov ds:38, ax 
sti 
push cs 
pop ds 
@@1: 
hlt 
mov bx, head 
cmp bx, tail 
jz @@1 
call read_buf 
cmp al, 81h 
jnz @@1 
; 
xor ax, ax 
push ax 
pop es 
push cs 
pop ds 
mov si, offset old9 
mov di, 36 
cli 
movsw 
movsw 
sti 
ret 
begin endp 
read_buf proc near 
mov bx, head 
mov al, byte ptr ds:[bx] 
inc bx 
cmp bx, offset bufend 
jnz @@1 
mov bx, offset buf 
@@1: 
mov head, bx 
ret 
read_buf endp 
end _start