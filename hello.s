section .rodata
        message db "Hello NASM", 10 
        message_len equ $ - message

section .text
        global _start

_start:
    mov rax, 1  ; 系统调用号
    mov rdi, 1  ; stdout
    mov rsi, message 
    mov rdx, message_len
    syscall

exit:
    mov rax, 60
    mov rdi, 0
    syscall 