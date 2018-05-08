model   tiny
.code
org      100h
start:
	xor	bp, bp
    work:
        cmp bp, 5
        jne next
        xor bp, bp
        next:
        xor ax, ax
        mov al, modes[bp]
        int 10h
        mov al, modes[bp]
        mov ah, 05h
        int 10h
        mov bh, modes[bp]
        mov	cx,1
        mov bl, 00011111b
        inc bp
        xor si, si
        mov dl, 0
        mov dh, 0
        loop1:
            mov al, fraw[si]
            inc si
            mov ah, 2
            int 10h
            mov ah,9
            int 10h
            inc al
            inc dl
            cmp si, 22
            je cont_loop1
            cmp si, 44
            je cont_loop1
            cmp si, 66
            jne loop1
            xor si, si
            inc dh
            mov dl, 0
            jmp loop3
        cont_loop1:
            inc dh
            mov dl, 0
            jmp loop1
        kpress:
            xor ah, ah
            int 16h
            cmp ah, 1
            je restart
            cmp ah, 39h
            je work
            jmp kpress
        restart:
            int     19h
        loop3:
            mov al, 179
            mov ah, 2
            int 10h
            mov ah,9
            int 10h

            inc dl
            mov al, fraw3[si]
            inc si
            mov ah, 2
            int 10h
            mov ah,9
            int 10h

            inc dl
            mov al, 179
            mov ah, 2
            int 10h
            mov ah,9
            int 10h

            inc dl
            mov al, 0
            mov ah, 2
            int 10h
            mov ah,9
            int 10h

            mov dl, 0
            inc al
            inc dh
            cmp si, 16
            jne loop3
            mov si, 256
            mov al, 0
            mov dh, 3
            mov dl, 4
            jmp loop4
        loop4:
            mov ah, 2
            int 10h
            mov ah,9
            int 10h
            inc al
            inc dl
            test al, 0Fh
            jnz cont_loop4

            push ax
            mov al, 0
            mov ah, 2
            int 10h
            mov ah,9
            int 10h
            inc dl
            mov al, 179
            mov ah, 2
            int 10h
            mov ah,9
            int 10h
            pop ax

            inc dh
            mov dl, 4
        cont_loop4:
            dec si
            jnz loop4
            xor si, si
            mov dl, 0
            jmp loop5
        loop5:
            mov al, fraw4[si]
            inc si
            mov ah, 2
            int 10h
            mov ah,9
            int 10h
            inc dl
            cmp si, 22
            jne loop5
            jmp kpress

fraw db 218, 196, 194, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 191
     db 179, 0, 179, 0,  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 0, 179
     db 195, 196, 197, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 180
fraw3 db 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70
fraw4 db 192, 196, 193, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 196, 217
modes db 0, 1, 2, 3, 7
end start