org 0x10200
bits 32

	%define endl 0x0d, 0x0a

start:
    jmp main

functions:
print:
    
    lodsb
    cmp al, 0
    je return_print
    mov [edi], ax
    add edi, 2
    jmp print

return_print:
    ret

filling_screen_with_blue:

    mov edi, 0xb8000
    mov ecx, 1920
    mov ax, 0x1720
    rep stosw
    ret

filling_bottom_line_controls:

    mov edi, 0xb8F00
    mov ecx, 80
    mov al, 0xDB
    mov ah, 0x7
    rep stosw
    ret

PS2_read_key:

    in al, 0x64
    test al, 1
    jz PS2_read_key

    in al, 0x60
    mov ah, al

    test ah, 0x80
    jnz .break

    call 0x10000
    or al, al
    ret

.break:
    and ah, 0x7F
    xor al, al
    test al, al
    ret


main:

    call filling_screen_with_blue
    call filling_bottom_line_controls

print_top_text:

    mov edi, 0xb8000
    mov esi, IlyoDOS_top_text
    mov ah, 0x1F
    call print

print_welcome_text:

    mov edi, 0xb80A0
    mov esi, welcome
    mov ah, 0x1f
    call print

print_controls_text:

    mov edi, 0xb8f00
    mov esi, controls
    mov ah, 0x70
    call print

choose1:

    call PS2_read_key
    cmp al, '1'
    je informative_print
    cmp al, '0'
    je shut_down_machine
    jmp choose1

informative_print:

    mov edi, 0xb81e0
    mov esi, informative
    mov ah, 0x1F
    call print

choose2:

    call PS2_read_key
    cmp al, '1'
    je CPU_confirm
    cmp al, '0'
    je shut_down_machine
    jmp choose2

CPU_confirm:

    call filling_screen_with_blue
    mov edi, 0xb8000
    mov esi, cores_ask
    mov ah, 0x1F
    call print

key:

    call PS2_read_key
    call 0x10000
    jmp exit
    
shut_down_machine:

    call filling_screen_with_blue
    mov edi, 0xb8000
    mov esi, shut_down_message
    mov ah, 0x1F
    call print
    call filling_bottom_line_controls
    

data:

    IlyoDOS_top_text db "IlyoDOS 1.0 SE Setup:", 0
    welcome db "Welcome to IlyoDOS 1.0 Setup! (1/0)", 0
    informative db " The IlyoDOS 1.0 SE Setup configures your device, as plug and play is not        here... yet.", 0
    controls db " Continue = 1/2/3/4       Exit = 0", 0
    shut_down_message db "You may shut down your computer now.", 0
    cores_ask db "How much cores is in your CPU?: ", 0

exit:
    jmp exit

times 2048-($-$$) db 0
