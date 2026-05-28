section .data
    array dd -15, 42, -5, 88, 12, 60
    size equ 6

section .bss 
    maxv resq 1

section .text
    global _start 


; int findmax_func(int * array, size_t size);
global findmax_func
findmax_func:
   push rbp                 ; create stack 
   mov  rbp, rsp            ; 
   sub  rsp, 8              ;  16 对齐
   movsx rdx,  dword[rdi]   ;
   
   ; 这里有一个关键点 sub rsp, 8 创建了栈帧 头元素不是在 rbp 而在 rbp - 8 顺序是从低往高
   mov  [rbp - 8], rdx          ; long max = array[0]
   xor  rcx, rcx            ; int i = 0

_for_begin:
   inc rcx
   cmp rcx, rsi
   jge _for_end

   movsx rdx, dword [rdi + (rcx * 4)]
   cmp  [rbp - 8], rdx
   jge _for_begin
   mov  [rbp - 8], rdx
   jmp _for_begin

_for_end:
   mov rax, [rbp - 8]
   mov rsp, rbp     ; pop stack
   pop rbp
   ret 

_start:
   xor rax, rax
   mov rdi, array  ; param 1 -> int* array
   mov rsi, size   ; param 2 -> size_t size
   ; called saved
   push rcx ;
   push rdx ;
   call findmax_func ; call findmax_func 
   pop rdx 
   pop rcx
   mov [maxv], rax
   mov rdi, [maxv]

_exit:
   mov rax, 60
   syscall