section .data
section .text
global _start 

_start:
    mov rbx, 1
exit:
    mov rax, 60
    syscall
