;set the stack pointer
;query the bios for lower memory size
;query the bios for upper memory size
;load the kernel
;enable A20
;load the GDT
; switch to protected mode
; disable interrupts
;load multiboot
; begin kernel execution

;if failed
;print error
;disable interrupts
;hang