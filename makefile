OUTPUT_IMG := build/result/floppy.img

MAKE_ASSEMBLER := nasm
MAKE_EMULATOR := qemu-system-i386

all: $(OUTPUT_IMG)

assemble: 
	mkdir -p build
	$(MAKE_ASSEMBLER) -f bin src/boot/boot.asm -o build/boot.bin

	$(MAKE_ASSEMBLER) -f bin src/kernel/kernel.asm -o build/KERNEL.BIN

	$(MAKE_ASSEMBLER) -f bin src/kernel/keyboard.asm -o build/KEYBOARD.BIN

	$(MAKE_ASSEMBLER) -f bin src/setup/setup.asm -o build/SETUP.BIN

	touch build/CONFIG

$(OUTPUT_IMG): assemble
	mkdir -p build/result
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n ILYOOS_SE1 $@

	# write boot sector
	dd if=build/boot.bin of=$@ bs=512 count=1 conv=notrunc

	# copy files into floppy
	mcopy -i $@ build/KERNEL.BIN ::
	mcopy -i $@ build/KEYBOARD.BIN ::
	mcopy -i $@ build/SETUP.BIN ::
	mcopy -i $@ build/CONFIG ::CONFIG

run: $(OUTPUT_IMG)
	$(MAKE_EMULATOR) \
		-drive file=$(OUTPUT_IMG),if=floppy,format=raw \
		-m 32M -cpu 486 -monitor stdio
clean:
	rm -rf $(OUTPUT_IMG)

.PHONY: all run clean

