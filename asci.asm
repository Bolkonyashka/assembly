.model   tiny
.code
org      100h
start:
	xor	bp, bp
	;jmp GO
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
        PrintTable:
            cmp si, len
            je kpress
            mov al, arr[si]
            mov dl, arr[si+1]
            mov dh, arr[si+2]
            add si, 5
            cloop:
                PrintRaw:
                    mov ah, 2
                    int 10h
                    mov ah,9
                    int 10h
                    cmp si, 80
                    jng @@1
                    inc al
                @@1:
                    cmp dl, arr[si-2]
                    je @@2
                    inc dl
                    jmp PrintRaw
                @@2:
                    cmp dh, arr[si-1]
                    je PrintTable
                    mov dl, arr[si-4]
                    inc dh
                    jmp cloop
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

arr db 0, 0, 0, 23, 21
	db 196, 0, 0, 23, 0
	db 179, 0, 0, 0, 21
	db 196, 0, 2, 23, 2
	db 179, 4, 0, 4, 21
	db 196, 0, 21, 23, 21
	db 179, 23, 0, 23, 21
	db 218, 0, 0, 0, 0
	db 192, 0, 21, 0, 21
	db 194, 4, 0, 4, 0
	db 197, 4, 2, 4, 2
	db 195, 0, 2, 0, 2
	db 193, 4, 21, 4, 21
	db 191, 23, 0, 23, 0
	db 180, 23, 2, 23, 2
	db 217, 23, 21, 23, 21
	db 48, 6, 1, 15, 1
	db 65, 16, 1, 21, 1
	db 0, 6, 3, 21, 18
	db 48, 2, 3, 2, 12
	db 65, 2, 13, 2, 18
len dw $-arr
modes db 0, 1, 2, 3, 7
end start