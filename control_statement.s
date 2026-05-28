section .data
    array dd 20, -10, 60
    size equ  3 

section .text
   global _start


; 循环求和
_start:
   xor rcx, rcx  ; for var
   xor rax, rax
   
_for_begin:      ; for 
   cmp rcx, size ; 
   jge _for_end  ; if rcx >= size 
   movsx rdx, dword [array + (rcx * 4)] ;  
   add rax, rdx
   inc rcx       ; i++
   jmp _for_begin

_for_end:   
   mov rdi, rax

_exit:
   mov rax,  60 
   syscall 