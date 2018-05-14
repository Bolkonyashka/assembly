model tiny
.code
org 100h
locals
_start:
    mov ax, 4
    int 10h
    mov ax, 0b800h
    mov es, ax
    mov di, 200
    mov ax, 0aaaah;
    stosw
    mov di, 40
    stosw
    mov di, 120
    stosw
    mov di, 160
    stosw
    xor ax, ax
    int 16h
    mov ax, 3
    int 10h
    ret
end _start
