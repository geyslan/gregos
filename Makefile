.PHONY: all
all: bootloader

bootloader: boot.bin

boot.bin: boot.asm
	nasm -f bin $< -o $@

.PHONY: clean
clean:
	rm -f boot.bin