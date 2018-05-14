.model tiny
.code
org 100h
begin:
    jmp short _start
operator        db 'MBR.180K'
; BPB
BytesPerSec     dw 200h
SectPerClust    db 1
RsvdSectors     dw 1
NumFATs         db 2
RootEntryCnt    dw 64
TotalSectors    dw 360
MediaByte       db 0FCh
FATsize         dw 2
SecPerTrk       dw 9
NumHeads        dw 1
HidSec          dw 0, 0
TotSec32        dd 0
DrvNum          db 0
Reserved        db 0
Signatura       db ')'
;
Vol_ID          db 'XDRV'
DiskLabel       db 'TestMBRdisk'
FATtype         db 'FAT12   '
;
_start:
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
org     766
dw      0aa55h
end begin