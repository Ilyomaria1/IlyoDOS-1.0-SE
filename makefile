# Directories
SRC_BOOT_DIR := src/boot
SRC_KERNEL_DIR := src/kernel
SRC_SETUP_DIR := src/setup
BUILD_DIR := build
RESULT_DIR := $(BUILD_DIR)/result

# Files
BOOT_ASM := $(SRC_BOOT_DIR)/boot.asm
BOOT_BIN := $(BUILD_DIR)/boot.bin

KER_MAIN_ASM := $(SRC_KERNEL_DIR)/kernel.asm
KER_MAIN_BIN := $(BUILD_DIR)/KERNEL.BIN

KEYBOARD_ASM := $(SRC_KERNEL_DIR)/keyboard.asm
KEYBOARD_BIN := $(BUILD_DIR)/KEYBOARD.BIN

SETUP_ASM := $(SRC_SETUP_DIR)/setup.asm
SETUP_BIN := $(BUILD_DIR)/SETUP.BIN

CONFIG_FILE := $(BUILD_DIR)/CONFIG     # no extension

FLOPPY_IMG := $(RESULT_DIR)/floppy.img

# Tools
NASM := nasm
DD := dd
MKFS := mkfs.fat
QEMU := qemu-system-i386

all: $(FLOPPY_IMG)

$(BOOT_BIN): $(BOOT_ASM)
	mkdir -p $(BUILD_DIR)
	$(NASM) -f bin $(BOOT_ASM) -o $(BOOT_BIN)

$(KER_MAIN_BIN): $(KER_MAIN_ASM)
	mkdir -p $(BUILD_DIR)
	$(NASM) -f bin $(KER_MAIN_ASM) -o $(KER_MAIN_BIN)

$(KEYBOARD_BIN): $(KEYBOARD_ASM)
	mkdir -p $(BUILD_DIR)
	$(NASM) -f bin $(KEYBOARD_ASM) -o $(KEYBOARD_BIN)

$(SETUP_BIN): $(SETUP_ASM)
	mkdir -p $(BUILD_DIR)
	$(NASM) -f bin $(SETUP_ASM) -o $(SETUP_BIN)

# Create config file if it doesn't exist
$(CONFIG_FILE):
	touch $(CONFIG_FILE)

$(FLOPPY_IMG): $(BOOT_BIN) $(KER_MAIN_BIN) $(KEYBOARD_BIN) $(SETUP_BIN) $(CONFIG_FILE)
	mkdir -p $(RESULT_DIR)
	$(DD) if=/dev/zero of=$(FLOPPY_IMG) bs=512 count=2880
	$(MKFS) -F 12 -n ILYOOS_SE1 $(FLOPPY_IMG)

	# write boot sector
	$(DD) if=$(BOOT_BIN) of=$(FLOPPY_IMG) bs=512 count=1 conv=notrunc

	# copy kernel, keyboard, setup, and config into floppy
	mcopy -i $(FLOPPY_IMG) $(KER_MAIN_BIN) ::
	mcopy -i $(FLOPPY_IMG) $(KEYBOARD_BIN) ::
	mcopy -i $(FLOPPY_IMG) $(SETUP_BIN) ::
	mcopy -i $(FLOPPY_IMG) $(CONFIG_FILE) ::CONFIG

run: $(FLOPPY_IMG)
	$(QEMU) \
		-drive file=$(FLOPPY_IMG),if=floppy,format=raw \
		-m 32M -cpu 486 -monitor stdio

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
