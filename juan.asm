;
; assemble with: nasm -f bin juan.asm -o juan.img
; run with qemu: qemu-system-x86_64 -fda juan.img
;
[org 0x7c00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov ah, 0x00
    mov al, 0x03
    int 0x10

    mov si, welcome_msg
    call print_string

main_loop:
    mov si, prompt
    call print_string

    mov di, user_buffer
read_loop:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0d
    je execute_code

    cmp al, 0x08
    je handle_backspace

    mov ah, 0x0e
    int 0x10

    stosb
    jmp read_loop

handle_backspace:
    cmp di, user_buffer
    jbe read_loop

    dec di
    mov byte [di], 0


    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp read_loop

execute_code:

    mov si, newline
    call print_string


    mov si, user_buffer
    mov di, code_buffer

parse_loop:
    mov al, [si]
    cmp al, 0
    je done_parsing

    call hex_to_bin
    shl al, 4
    mov bl, al

    inc si
    mov al, [si]
    cmp al, 0
    je done_parsing

    call hex_to_bin
    add bl, al
    mov [di], bl

    inc si
    inc di
    jmp parse_loop

done_parsing:
    ; mov si, exec_msg
    ; call print_string

    call code_buffer

    jmp main_loop

print_string:
    mov ah, 0x0e
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

hex_to_bin:
    cmp al, '9'
    jbe .is_digit
    cmp al, 'F'
		jbe .is_upper
		cmp al, 'f'
		jbe .is_lower
    jmp .done
.is_digit:
    sub al, '0'
		jmp .done
.is_upper:
	sub al, 'A' - 10
	jmp .done
.is_lower:
	sub al, 'a' - 10
.done:
    ret

welcome_msg: db 'juan v0.1', 0x0d, 0x0a, 0
prompt:      db 0x0d, 0x0a, '> ', 0
newline:     db 0x0d, 0x0a, 0
; exec_msg:    db 'juanning', 0x0d, 0x0a, 0

user_buffer: resb 128
code_buffer: resb 128
times 510 - ($ - $$) db 0
dw 0xaa55

