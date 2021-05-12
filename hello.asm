[BITS 16]    ; 16 bit code
[ORG 0x7C00] ; Code origin set to 7C00
jmp _start

global _start
_start:

mov ax, 0000h
mov ds, ax

mov si, HelloWorld

call putChar

jmp _start

putChar:

mov ah, 0Eh
mov bh, 00h
mov bl, 07h

.nextChar
lodsb
or al, al
jz .return

int 10h
jmp .nextChar
.return
ret 

HelloWorld db 'Hello World', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55