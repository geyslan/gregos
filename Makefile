.PHONY: all
all: bootloader

bootloader: boot.bin

boot.bin: boot.asm
	nasm -f bin $< -o $@

.PHONY: run
run: boot.bin
	qemu-system-x86_64 -hda boot.bin

.PHONY: clean
clean:
	rm -f boot.bin
