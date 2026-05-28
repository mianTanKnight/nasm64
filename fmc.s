extern printf
extern exit

section .data
   array dd  -15, 42, -5, 88, 12, 60 
   size equ  6

   ; C standard format string
   c_message db "The final max value : %ld", 10, 0

section .text
   global main


; int findmax(int *array, size_t size)
global findmax
findmax:
   movsx rax, dword [rdi]
   xor rcx, rcx  ; int i = 0 

_loop: 
   inc rcx
   cmp rcx, rsi
   jge _loop_end
   movsx rdx, dword [rdi + (rcx * 4)]
   cmp rax, rdx
   jge _loop
   mov rax, rdx
   jmp _loop

_loop_end:
   ret

main:

  mov rdi, array
  mov rsi, size
  ; caller save rdi, rsi, rdx, rcx, r8 - r11
  ; 如果在调用之前使用了 caller save,需要保存指定寄存器
  call findmax  ;  rax saved maxvalue

  sub rsp, 8   ; 16 Align
  mov rsi,rax
  mov rdi, c_message
  xor al, al ; zero xmm count  
  call printf 

  mov rdi, 0
  call exit
  

section .note.GNU-stack noalloc noexec write progbits