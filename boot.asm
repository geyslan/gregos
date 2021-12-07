org 0
bits 16

; FAT Boot Record
; BPB (BIOS Parameter Block)
; https://wiki.osdev.org/FAT#BPB_.28BIOS_Parameter_Block.29
; https://wiki.osdev.org/FAT#Extended_Boot_Record
bpb:
	jmp short setup1
	nop
; reserve space as some BIOSes may change this area
; 62 is the size of BPB + FAT 16 EBPB (Extended Boot Record)
times 62-($ - $$) db 0

; BIOS historically loads the bootloader to 0x7c00 memory address (20 bits)
; cs:offset is translated to ((cs << 4) + offset) address
; so 'jmp 0x07c0:setup':
; - set code segment (cs) to 0x07c0
; - jump to (0x7c00 + setup offset)
setup1:
	jmp 0x07c0:setup2

setup2:
	cli ; disable interrupt handlers

	; set data segment (ds) equal to code segment (cs)
	mov ax, cs
	mov ds, ax	

	; setup stack
	mov ax, 0
	mov ss, ax
	; the beginning of the stack is the same as the code in memory
	; but the stack grows downwards
	mov sp, 0x7c00

	sti ; enable interrupt handlers

start:
	; call print
	mov si, message
	call print
	jmp $

print:
	mov bx, 0
.loop:
	lodsb
	cmp al, 0
	je .done
	call print_char
	jmp .loop
.done:
	ret

print_char:
	mov ah, 0xe
	int 0x10
	ret

message: db 'Hello World! I am GregOS Bootloader!', 0

times 510-($ - $$) db 0
dw 0xaa55
