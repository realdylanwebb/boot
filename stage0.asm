[BITS 16]
[ORG 7C00h]

cli                     ; disable interrupts
jmp _start              ; set CS & IP

_start:

; set up segment registers
movw ax, 0100h
movw es, ax ; first bootloader loading area
movw ax, 0700h
movw ds, ax ; set up data segment
movw ax, 0700h
movw ss, ax ; set the stack segment
movw ax, 0000h

; set up the stack
movw sp, ax ; set the stack pointer
movw bp, ax ; set the base pointer

sti         ; enable interrupts

call readNextStage ; read boot1
or ah, ah   ; did error
jz .loadBootOne
call fatal
.loadBootOne
jmp [ax] ; next bootloader address



; dl needs to be maintained from boot for this to point to the boot device
; cmp to check if es:bx+sectors*512 does not cross a 64k segment boundary
; if so, reset es to the end of the read data, and set bx to 0
; read disk and increment es:xb
readNextStage:
push bp, si, ds, cx
mov ah 42h
;set disk address packet
mov bx, bootOneDap
mov ds, bx
mov si, 0000h
mov cl, 00h
.loop
cmp cl, 02h ;retry three times on failure to read, then return with error code
je .break
int 13h
inc cl
jnc .loop
.break
pop bp, si, ds, cx
ret


            
ctrlReset:
push bp, dl

pop bp, dl
ret

fatal:
mov cl, ah
;set up ds:si
mov ax, fatalDiskErr
mov ds, ax
mov si, 0000h
mov ah, 0Eh
mov bh, 00h
mov bl, 07h
.nextChar
lodsb
or al, al
jz .errCode
int 10h
jmp .nextChar
.errCode
add cl, 30h ;convert error code to ascii
mov al, cx
int 10h
cli
.hang
jmp .hang

fatalDiskErr db 'Fatal disk error ', 0

bootOneDap:              ; disk address packet for loading the next bootloader
db 10h
db 00h
dw 0013h                ; number of sectors to be read
dd 00000100h            ; segment offset pointer to the destination for the sectors, in LITTLE ENDIAN meaning it's written offset:segment
dd 00000000h            ; first half of the sector start
dd 00000002h            ; second half of the sector start

times 510-($-$$) db 0
dw 0xAA55