model tiny
.code
org 100h
start:
jmp work
    keyw:
		xor ah, ah
		int 16h
		cmp ah, 1
		je restart
		cmp ah, 39h
		je work
		jmp keyw
	restart:
		int     19h
    work:
        xor ax, ax
        mov al, 2
        int 10h
        mov al, 2
        mov ah, 05h
        int 10h
        mov bh, 2
        mov cx, 1
        mov bl, 00011111b
        mov dx, 0
        mov ah, 2
        int 10h
        mov ah, 9
        mov al, 3
        int 10h
        jmp keyw
end start