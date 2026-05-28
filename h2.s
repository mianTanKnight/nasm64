section .rodata
    message1 db "Hi, C Programmer", 10 
    message1_len equ $ - message1
    message2 db "Learning NASM", 10 
    message2_len equ $ - message2

section .text
   global _start

_start:
   mov rax, 1 ; syscall code 1 
   mov rdi, 1 ; stdout
   mov rsi, message1 
   mov rdx, message1_len
   syscall
   mov rax, 1 ; syscall code 1 
   mov rdi, 1 ; stdout
   mov rsi, message2 
   mov rdx, message2_len
   syscall


_exit:
   mov rax, 60
   mov rdi, 17
   syscall 