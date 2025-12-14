org 0x7c00
bits 16

	%define endl 0x0d, 0x0a
bpb:

	jmp short start
	nop
	oem									db "ILYOOS1 "
	bytes_per_sector					dw 512
	sectors_per_cluster					db 1
	reserved_sectors					dw 1
	num_of_fats							db 2
	root_dir_entries					dw 224
	total_sectors_16_bit				dw 2880
	media_descriptor_type				db 0xF0
	sectors_per_fat						dw 9
	sectors_per_track					dw 18
	heads								dw 2
	hidden_sectors						dd 0
	total_sectors_32_bit				dd 0

ebpb:

	drive_num							db 0
										db 0
	signature							db 0x29
	volume_id_serial					db "ILYO"
	volume_label						db "ILYOOS_SE1 "
	system_identifier					db "FAT12   "

start:
configure_boot:

	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov [drive_num], dl

configure_stack:

	mov sp, 0x7c00
	jmp main
	
functions:
lba_to_chs:

	xor dx, dx
	div word [sectors_per_track]
	inc dx
	mov cl, dl
	xor dx, dx
	div word [heads]
	mov dh, dl
	mov ch, al
	shl ah, 6
	or cl, ah
	ret
		
main:
clear_screen_and_configure_text_mode:

	mov ax, 3
	int 10h

root_dir_start_calculation:

	mov ax, [num_of_fats]
	mul word [sectors_per_fat]
	add ax, [reserved_sectors]
	mov [root_dir_start], ax

root_dir_sectors_calculation:

	mov ax, [root_dir_entries]
	mov bx, 32
	mul bx
	xor dx, dx
	div word [bytes_per_sector]
	mov [root_dir_sectors], ax

data_start_calculation:

	mov ax, [root_dir_sectors]
	add ax, [root_dir_start]
	mov [data_start], ax
	mov di, 5

root_dir_read:

	mov ax, [root_dir_start]
	xor ah, ah
	call lba_to_chs
	mov al, [root_dir_sectors]
	mov ah, 2h
	mov dl, [drive_num]
	mov bx, 0x500
	int 13h

	dec di
	cmp di, 0
	je fat_read1
	jmp root_dir_read

fat_read1:
	mov di, 5
 
fat_read:

	mov ax, [reserved_sectors]
	xor ah, ah
	call lba_to_chs
	mov ah, 2h
	mov al, 9
	mov dl, [drive_num]
	mov bx, 0x2100
	int 13h

	dec di
	cmp di, 0
	je di_configure1
	jmp fat_read

di_configure1:
	mov di, 5

kernel_file_read:

	mov ax, 33
	call lba_to_chs

	mov ah, 2h
	mov al, 18
	mov dl, [drive_num]
	mov bx, 0x7e00
	int 13h

	dec di
	cmp di, 0
	je di_configure2
	jmp kernel_file_read

di_configure2:
	mov di, 5

kernel_file_read2:

	mov ax, 51
	call lba_to_chs

	mov ah, 2h
	mov al, 18
	mov dl, [drive_num]
	mov bx, 0xA200
	int 13h

	dec di
	cmp di, 0
	je di_configure3
	jmp kernel_file_read2

di_configure3:
	mov di, 5

kernel_file_read3:

	mov ax, 69
	call lba_to_chs

	mov ah, 2h
	mov al, 18
	mov dl, [drive_num]
	mov bx, 0xC600
	int 13h

	dec di
	cmp di, 0
	je di_configure4
	jmp kernel_file_read3

di_configure4:
	mov di, 5

kernel_file_read4:

	mov ax, 87
	call lba_to_chs

	mov ah, 2h
	mov al, 10
	mov dl, [drive_num]
	mov bx, 0xEA00
	int 13h

	dec di
	cmp di, 0
	je di_configure5
	jmp kernel_file_read4

di_configure5:
	mov di, 5

keyboard_bin_file_read:

	mov ax, 98
	call lba_to_chs

	mov ah, 2h
	mov al, 8
	mov dl, [drive_num]
	mov bx, 0x1000
	mov es, bx
	xor bx, bx
	int 13h

	dec di
	cmp di, 0
	je di_configure6
	jmp keyboard_bin_file_read

di_configure6:
	mov di, 5

setup_bin_file_read:

	mov ax, 99
	call lba_to_chs

	mov ah, 2h
	mov al, 4
	mov dl, [drive_num]
	mov bx, 0x1000
	mov es, bx
	mov bx, 0x200
	int 13h

	dec di
	cmp di, 0
	je di_configure7 
	jmp setup_bin_file_read

di_configure7:
	mov di, 5

CONFIG_file_read:

	mov ax, 100
	call lba_to_chs

	mov ah, 2h
	mov al, 1
	mov dl, [drive_num]
	mov bx, 0x1000
	mov es, bx
	mov bx, 0x800
	int 13h

	dec di
	cmp di, 0
	je print_welcome
	jmp CONFIG_file_read


print_welcome:

	mov ah, 0x0e
	mov si, welcome

print_loop:

	lodsb
	cmp al, 0
	je exit
	int 10h
	jmp print_loop

exit:
	
	jmp 0:0x7e00

data:

	welcome db "Welcome to IlyoOS!", endl, 0

fat_data:

	root_dir_start dw 0
	root_dir_sectors dw 0
	data_start dw 0
	
important:

	times 510-($-$$) db 0
	dw 0xAA55
