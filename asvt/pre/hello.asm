.model tiny
.code
org 100h
begin:
	cld
	mov     ax, 0b800h;0b800h соответствует сегменту дисплея в тестовом режиме
	mov     es, ax; т.к. загрузка числа напрямую в сегментный регистр запрещена
	mov     di, 0;загрузка в регистр данных - это смещение относительно сегмента 0b800h
keyw:
	xor     ah, ah
	int     16h; Читает из кольцевого буфера ввода символ и скан-код. После считывания они удаляются из буфера и возвращаются в регистре AX. Если буфер пуст, ожидает ввода
	cmp     ah, 0eh
	jz      backspace
	cmp     ah, 1
	jz      restart
	mov     ah, 6
	stosw
	jmp     keyw
backspace:
	sub     di, 2
	mov     al, 20h
	stosw
	sub     di, 2
	jmp     keyw
restart:
	int     19h
end begin