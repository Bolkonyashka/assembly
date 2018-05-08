.model tiny
.code
org 100h
begin:
	jmp short _start
	nop
operator	db 'MBR.180K'
; BPB
BytesPerSec	dw 200h
SectPerClust	db 1
RsvdSectors	dw 1
NumFATs		db 2
RootEntryCnt	dw 64
TotalSectors	dw 360
MediaByte	db 0FCh
FATsize		dw 2
SecPerTrk	dw 9
NumHeads	dw 1
HidSec		dw 0, 0
TotSec32	dd 0
DrvNum		db 0
Reserved	db 0
Signatura	db ')'
;
Vol_ID		db 'XDRV'
DiskLabel	db 'TestMBRdisk'
FATtype		db 'FAT12    '
;
_start:
	mov ax, 1000h
	mov es, ax ; база
	mov ah, 02h; функция чтения секторов
	mov dl, 0 ;номер диска
	mov dh, 0 ;номер головки чтения/записи
	mov ch, 1 ;номер дорожки
	mov cl, 1 ;стартовый сектор для считывания (1-9)
	mov al, 9 ;количество считываемых секторов
	mov bx, 100h ;смещение
	int 13h
	cli
	mov ax, 1000h
	mov ss, ax
	mov ds, ax
	mov ax, 0fffeh
	mov sp, ax
	;mov [2000h:0], 0h
	;mov [ds:0ffffh], 0h
	mov [ds:0fffeh], 0h
	mov [ds:0], 0cdh
	mov [ds:1], 19h
	mov ax, 1000h ;база для перехода
	push ax
	mov ax, 0100h ;смещение для перехода
	push ax
	sti
	retf ; собственно сам переход и смена сегмента кода
org	766
dw	0aa55h
end	begin