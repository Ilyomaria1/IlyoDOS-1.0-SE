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

; @param ax: color
fill_screen:
	mov ecx, 1000
	mov edi, 0xb8000
	rep stosb
    ret


	
IDT_start:
division_error:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

debug_exception:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

NMI_interrupt:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

break_point:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

overflow:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

bound_range_exceeded:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

invalid_opcode:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

no_coprocessor_found:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

double_fault:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

coprocessesor_segment_overrun:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

invalid_TSS:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

segment_not_present:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

stack_segment_fault:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

general_protection_fault:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

page_fault:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0
	
	dq 0

x87_floating_point_error:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

alignment_check:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

machine_check:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

simd_floating_point_exception:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

virtualization_exception:

	dw print_kernel_panic
	dw 0x8
	db 0
	db 0x8e
	dw 0

control_protection_exception:

	dw print_kernel_panic
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

IDT_end:

IDT_descriptor:

	dw IDT_end - IDT_start - 1
	dd IDT_start

KERNEL_EXCEPTION_PRINTS:
print_kernel_panic:
	mov ax, 0x1f
    call fill_screen
    mov edi, 0xb8000
    mov esi, kernel_panic
    mov ah, 0x1f
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

setup_check_if_valid:

	mov al, [0x10800]
	cmp al, 0
	je jump_to_setup_bin

jump_to_setup_bin:

	jmp 0x10200


data:

	kernel_panic db "KERNEL PANIC!", 0

exit:
	jmp exit

	times 33280-($-$$) db 0
