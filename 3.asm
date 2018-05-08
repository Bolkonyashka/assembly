	.model   tiny
	.code
	org      100h    ; ������ ���-�����
start:
	;cld
	;mov ax, 0b800h;0b800h ������������� �������� ������� � �������� ������
	;mov es, ax; �.�. �������� ����� �������� � ���������� ������� ���������
	;xor di, di;�������� � ������� ������ - ��� �������� ������������ �������� 0b800h
	xor	bp, bp
	jmp GO
	keyw:
		xor ah, ah
		int 16h
		cmp ah, 1
		je restart
		cmp ah, 39h
		je GO
		jmp keyw
	restart:
		int     19h
GO:
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
	;mov ah,9    ; ����� ������������ "����� ������� � ���������"
	mov	cx,1    ; ��������� ���� ������ �� ���
	mov bl, 00011111b ;������� ������� - ����� �� �����
	inc bp
	xor si, si
	PrintTable:
		cmp si, len
		je keyw
		mov al, arr[si]
		mov dl, arr[si+1]
		mov dh, arr[si+2]
		add si, 5
		lop:
			PrintRaw:
				;push ax      ; ��������� ������� ������ � ����� �������
				mov ah, 2    ; ����� ������������ 2 - �������� ��������� �������
				int 10h     ; ����������� ������
				;pop ax
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
				jmp lop
arr db 0, 0, 0, 23, 21
	db 205, 0, 0, 23, 0
	db 186, 0, 0, 0, 21
	db 196, 0, 2, 23, 2
	db 179, 4, 0, 4, 21
	db 205, 0, 21, 23, 21
	db 186, 23, 0, 23, 21
	db 201, 0, 0, 0, 0
	db 200, 0, 21, 0, 21
	db 209, 4, 0, 4, 0
	db 197, 4, 2, 4, 2
	db 199, 0, 2, 0, 2
	db 207, 4, 21, 4, 21
	db 187, 23, 0, 23, 0
	db 182, 23, 2, 23, 2
	db 188, 23, 21, 23, 21
	db 48, 6, 1, 15, 1
	db 65, 16, 1, 21, 1
	db 0, 6, 3, 21, 18
	db 48, 2, 3, 2, 12
	db 65, 2, 13, 2, 18
len dw $-arr
modes db 0, 1, 2, 3, 7
end      start