bits 16
org 0x7e00

start:
protected_mode_switch:

	cli
	in al, 0x92
	test al, 2
	jnz protected_mode
	or al, 2
	and al, 0xFE
	out 0x92, al
	jmp protected_mode_switch

gdt_start:

	dq 0
	dq 0x00CF9A000000FFFF
	dq 0x00CF92000000FFFF
	
gdt_end:

gdt_ptr:

	dw gdt_end-gdt_start-1
	dd gdt_start

protected_mode:

	cli
	lgdt [gdt_ptr]
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	jmp 0x8:protected_mode_start

bits 32
protected_mode_start:

	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	jmp main

functions:
fill_blue_screen:

    mov edi, 0xb8000
    mov ecx, 2000
    mov al, ' '
    mov ah, 0x1F
    
loop:

    mov [edi], ax
    add edi, 2
    loop loop
    ret

fill_black_screen:

    mov edi, 0xb8000
    mov ecx, 2000
    mov al, ' '
    mov ah, 0x0F
    
loop1:

    mov [edi], ax
    add edi, 2
    loop loop1
    ret

fill_yellow_screen:

    mov edi, 0xb8000
    mov ecx, 2000
    mov al, ' '
    mov ah, 0xe0
    
loop2:

    mov [edi], ax
    add edi, 2
    loop loop2
    ret

	
IDT_start:
division_error:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

debug_exception:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

NMI_interrupt:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

break_point:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

overflow:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

bound_range_exceeded:

	dw print_kernel_panic_yellow
	dw 0x8
	db 0
	db 0x8e
	dw 0

invalid_opcode:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

no_coprocessor_found:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

double_fault:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

coprocessesor_segment_overrun:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

invalid_TSS:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

segment_not_present:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

stack_segment_fault:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

general_protection_fault:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

page_fault:

	dw print_kernel_panic_yellow
	dw 0x8
	db 0
	db 0x8e
	dw 0
	
	dq 0

x87_floating_point_error:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

alignment_check:

	dw print_kernel_panic_yellow
	dw 0x8
	db 0
	db 0x8e
	dw 0

machine_check:

	dw print_kernel_panic_black
	dw 0x8
	db 0
	db 0x8e
	dw 0

simd_floating_point_exception:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

virtualization_exception:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

control_protection_exception:

	dw print_kernel_panic_blue
	dw 0x8
	db 0
	db 0x8e
	dw 0

	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0

software_interrupts_IDT:
main_software_interrupts:

	dw software_int32
	dw 0x8
	db 0
	db 0x8e
	dw 0


IDT_end:

IDT_descriptor:

	dw IDT_end - IDT_start - 1
	dd IDT_start

KERNEL_EXCEPTION_PRINTS:
print_kernel_panic_blue:

    call fill_blue_screen
    mov edi, 0xb8000
    mov esi, kernel_panic
    mov ah, 0x1f
    jmp print_loop_kernel_panic

print_kernel_panic_yellow:

    call fill_yellow_screen
    mov edi, 0xb8000
    mov esi, kernel_panic
    mov ah, 0xe0
    jmp print_loop_kernel_panic

print_kernel_panic_black:

    call fill_black_screen
    mov edi, 0xb8000
    mov esi, kernel_panic
    mov ah, 0x0f
    jmp print_loop_kernel_panic

print_loop_kernel_panic:

    lodsb
    cmp al, 0
    je exit
    mov [edi], ax
    add edi, 2
    jmp print_loop_kernel_panic

main:
load_IDT:
	lidt [IDT_descriptor]
	jmp user_code

software_int32:

	jmp exit

user_code:

	mov ah, 0x1c
	call 0x1000
	jmp exit

data:

	kernel_panic db "KERNEL PANIC!", 0

exit:
	jmp exit

	times 33280-($-$$) db 0
