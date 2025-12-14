org 0x10000
bits 32

convert_scancode:
    cmp ah, 0xf0
    je brk
    movzx ebx, ah
    mov al, 0
    cmp ebx, table_end
    ja done
    mov al, [table + ebx]
done:
    ret
brk:
    xor al, al
    ret

table:
    times 0x1c db 0
    db 'a'
    db 's'
    db 'd'
    db 'f'
    db 'g'
    db 'h'
    db 'j'
    db 'k'
    db 'l'
    db ';'
    db '\''
    db '`'
    db 0
    db '\'

    db 'z'
    db 'x'
    db 'c'
    db 'v'
    db 'b'
    db 'n'
    db 'm'
    db ','
    db '.'
    db '/'
    db 0
    db 0
    db 0
    db ' '

    times (0x45 - ($-table)) db 0
    db '1'
    db '2'
    db '3'
    db '4'
    db '5'
    db '6'
    db '7'
    db '8'
    db '9'
    db '0'
    db '-'
    db '='

    times (0x59 - ($-table)) db 0
    db 'q'
    db 'w'
    db 'e'
    db 'r'
    db 't'
    db 'y'
    db 'u'
    db 'i'
    db 'o'
    db 'p'
    db '['
    db ']'
    db 13

table_end equ ($ - table - 1)

times 512-($-$$) db 0
