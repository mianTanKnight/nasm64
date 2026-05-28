extern printf 
section .data
    x equ 10
    fmt db "y = x * 25 + 12 , y = %ld", 10 , 0

section .text
  global main


; y = x * 25 + 12
; y = x * (5*5) + 12 
main:
   sub rsp, 8   ; 16 对齐
   lea rsi, [x * 4 + x]  ; temp = x * 5 
   lea rsi, [rsi * 4 + rsi + 12] ; y= x * 25 + 12 
   mov rdi, fmt
   call printf
   
   add rsp, 8
_exit:
   mov rax, 60
   mov rdi, 0
   syscall


section .note.GNU-stack noalloc noexec write progbits  