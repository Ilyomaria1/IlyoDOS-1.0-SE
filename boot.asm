org 0x7c00
bits 16

bpb:
	jmp short main
	nop
	oem						db "NILOS_SL"
	bytes_per_sector 		dw 512
	sectors_per_cluster		db 1
	reserved_sectors		dw 1
	file_allocation_tables	db 2
	root_dir_entries		dw 224
	total_sectors_16_bit	dw 2880
	media_descriptor		db 0xF0
	sectors_per_fat			dw 9
	sectors_per_track		dw 18
	num_of_heads				dw 2
	hidden_sectors			dd 0
	total_sectors_32_bit	dd 0

ebpb:
	drive_num				db 0
	reserved				db 0
	signature 				db 0x29
	volume_id				dd 0x4E494C00
	volume_label_string		db "NILOS_SNOWL"
	sys_identifier			db "FAT12   "
	
main:
configure_boot:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax

configure_stack:
	mov sp, 0x7c00
data_read_start:
	mov si, 5
read_data:
	mov ah, 2
	mov al, 1
	mov ch, [cylinders]
	mov cl, [sectors]
	mov dh, [heads]
	mov dl, 0
	mov bx, 0x7e00
	int 13h
	jc error_print
	dec si
	cmp si, 0
	jne read_data
	jmp print_msg
	
error_print:
	mov ah, 0x0e
	mov si, error

print_error:
	lodsb
	cmp al, 0
	je exit
	int 10h
	jmp print_error
	
print_msg:
	mov si, welcome
	mov ah, 0x0e
print2:
	lodsb
	cmp al, 0
	je exit
	int 10h
	jmp print2
	
exit:
	jmp exit
data:
	error db "Disk Error."
	welcome db "Welcome to NilOS - Snow Leopard - Copyrighted. All rights reserved.", 0
fat_data:
	lba db 19
	cylinders db 0
	heads db 1
	sectors db 16
important:
	dw 0xAA55
