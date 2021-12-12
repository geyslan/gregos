org 0x7c00
bits 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

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
; - jump to (0x7c00 + setup2 offset)
setup1:
	jmp 0:setup2

setup2:
	cli ; disable interrupt handlers

	; set data (ds) and extra (es) segments equal to code segment (cs)
	mov ax, cs
	mov ds, ax
	mov es, ax

	; setup stack	
	mov ss, ax
	; the beginning of the stack is the same as the code in memory
	; but the stack grows downwards
	mov sp, 0x7c00

	sti ; enable interrupt handlers

.load_protected:
	cli
	lgdt [gdt_descriptor]	; Load Global Descriptor Table register (gdtr)
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	jmp CODE_SEG:run32
	

; GDT (Global Descriptor Table) entries
gdt_start:

; offset 0
gdt_null:
	dq 0

; offset 8
gdt_code:		; (cs) should point to this descriptor
	dw 0xffff	; segment limit first 0-15 bits
	dw 0		; base low 0-15 bits
	db 0		; base middle 16-23 bits
	db 0x9a		; access byte
	db 11001111b	; high 4 bit flags and the low 4 bit flags
	db 0		; base high 24-31 bits

; offset 16
gdt_data:		; (ds, ss, es, fs, gs) should point to this descriptor
	dw 0xffff	; segment limit first 0-15 bits
	dw 0		; base low 0-15 bits
	db 0		; base middle 16-23 bits
	db 0x92		; access byte
	db 11001111b	; high 4 bit flags and the low 4 bit flags
	db 0		; base high 24-31 bits

gdt_end:

; GDT escriptor structure
gdt_descriptor:
	dw gdt_end - gdt_start - 1	; size - 1
	dd gdt_start			; offset (linear address)


; protected mode (32 bits) code 
[bits 32]
run32:
	;; set segment registers
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov ebp, 0x00200000
	mov esp, ebp

	jmp $

times 510-($ - $$) db 0
dw 0xaa55
