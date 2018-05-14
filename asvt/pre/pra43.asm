model tiny
.code
org 100h
locals
_start:
    mov ax, 1
    int 10h
    mov ah, 5
    mov al, 5
    int 10h



    mov ax, 0b800h
    mov es, ax
    mov di, 0
    xor bx, bx
    mov al, 0
    mov cx, 255
    etoloop:
        stosw
        inc al
        inc bx
        loop etoloop
    int 16h
end _start