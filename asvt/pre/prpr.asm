.model tiny
.code
org 100h
begin:
    jmp main
handler:
    mov ax, 0b800h
    mov es, ax
    mov di, 660
    mov ah, 60h
    mov al, 35h
    stosw
    iret
main:
    mov ax, 0
    mov ds, ax
    cli
    mov [ds:0086h], 100h
    mov [ds:0084h], offset handler
    sti
    int 21h
    