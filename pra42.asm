model tiny
.code
org 100h
locals
color=5
_start:
    mov ax, 4
    int 10h
    mov al, color
    mov cx, 10
    mov dx, 20
    xor bx, bx
    mov ah, 0ch
    int 10h
    xor ax, ax
    int 16h
    mov ax, 3
    int 10h
    ret
end _start
