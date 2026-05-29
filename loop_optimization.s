section .text
   global sum_array_unrolled
   global sum_array_unrolled_4
   global sum_array_unrolled_8
 
; 汇编函数声明：
; 计算并返回 8 字节有符号整型数组的所有元素之和
; 假设输入参数 len 永远是 2 的倍数（且大于 0）
; extern long sum_array_unrolled(const long* arr, long len); 

sum_array_unrolled:
; rdi arrpoint , rsi len is 2^{n}  
; use << 1 replace div 2
   xor rax, rax 
   mov rcx, rsi
   shr rcx, 1 
   mov r8, rdi
   test rcx, rcx
   jle ._loop_end

._loop:
   
   add rax, [r8]
   add rax, [r8 + 8]
   lea r8,  [r8 + 16]

   dec rcx
   jnz ._loop

._loop_end: 
   ret 


sum_array_unrolled_4:
; rdi arrpoint , rsi len is 2^{n}  
; use << 1 replace div 2
   xor rax, rax 
   mov rcx, rsi
   shr rcx, 2  ;
   mov r8, rdi
   test rcx, rcx 
   jle  ._loop_end

._loop:
   
   add rax, [r8]
   add rax, [r8 + 8]
   add rax, [r8 + 16]
   add rax, [r8 + 24]
   lea r8,  [r8 + 32]

   dec rcx
   jnz ._loop

._loop_end: 
   ret 


sum_array_unrolled_8:
; rdi arrpoint , rsi len is 2^{n}  
; use << 1 replace div 2
   xor rax, rax 
   mov rcx, rsi
   shr rcx, 3  ; 
   mov r8, rdi

   test rcx, rcx  ; if len = 0 
   jle ._loop_end

._loop:

   add rax, [r8]
   add rax, [r8 + 8]
   add rax, [r8 + 16]
   add rax, [r8 + 24]
   add rax, [r8 + 32]
   add rax, [r8 + 40]
   add rax, [r8 + 48]
   add rax, [r8 + 56]
   lea r8,  [r8 + 64]

   dec rcx
   jnz ._loop

._loop_end: 
   ret 



section .note.GNU-stack noalloc noexec write progbits   