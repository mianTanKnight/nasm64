section .data
   array dd -15, 42, -5, 88, 12, 60
   count equ 6

section .bss
    max_v resq 1
section .text 
   global _start

_start:
   xor rax, rax
   xor rcx,  rcx
   movsx rdx, dword [array]  ; long max = array[0] 

_for_begin:
   inc rcx
   cmp rcx, count 
   jge _for_end
   
   movsx rsi, dword [array + (rcx * 4)] 
   cmp rdx, rsi
   jge _for_begin
   mov rdx, rsi
   jmp _for_begin

_for_end:
   mov [max_v], rdx
   mov rdi, [max_v]

_exit:
    mov rax, 60 
    syscall 