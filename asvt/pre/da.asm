.model
.code
org 100h
begin:
	jmp short _start
	nop
opertor	db 'MBR.180K'
; BPB
BytesPerSec 	dw 200h
SectPerClust	db 1
RsvdSectors		dw 100h
NumFATs			db 200h
RootEntryCnt	dw 64
TotalSectors 	dw 360
MediaByte 		db 0FCh
FATsize			dw 200h
SecPerTrk		dw 9
NumHeads 		dw 1
HidSec 			dw 0, 0
TotSec32 		dd 0
DrvNum 			db 0
Reserved 		db 0
Signatura 		db ')'

Vol_ID			db 'XDRV'
DiskLabel 		db 'TestMBRdisk'
FATtype 		db 'FAT 12'

_start:
	cld
	mov ax, 0b800h
	mov es, ax
	mov di, 660
@@1:
	xor ah, ah
	int 16h
	cmp ax, 0eh
	jz @@2
	cmp ah, 1
	jz @@3
	mov ah, 0ah 
	stosw
	jmp @@1
@@2:
	sub di, 2
	mov ax, 0720h
	stosw
	sub di, 2
	jmp @@1
@@3:
	;jmp far ptr 0ffffh:0
	int 19h
	nop
	nop
org 766
dw 0aa55h
end begin