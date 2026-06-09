section .text

   global vadd4 
   global vadd_i32_sse2
   global vadd_i32_sse2_qa


;extern void vadd4(int *a, const int *b);
;xmm 128 bit -> 16 byte 
vadd4: 
   movdqa xmm0, [rdi]
   movdqa xmm1, [rsi]
   paddd xmm0, xmm1   
   movdqa [rdi], xmm0
   ret


; // 1. 每次 SIMD 处理 4 个 int
; // 2. 剩下不足 4 个的元素，用标量尾部处理
; // 3. 允许 a 和 b 不一定 16 字节对齐
; // 4. 所以先使用 movdqu，不使用 movdqa
; extern void vadd_i32_sse2(int *a, const int *b, size_t n);
; a -> rdi, b -> rsi, n -> rdx 
; step1： n / 4  rax -> 商, rdx -> 余


; qu 非对齐版
vadd_i32_sse2: 

   ; step 1: div 
   mov rax, rdx ;   
   ; xor rdx, rdx ; rdx set 0
   ; 使用 shr + and 实现 div 4, 当 除数满足是 2^{n} 条件时
   ; rax -> 商, rdx -> 余 
   shr rax, 2 
   and rdx, 3
   
   ; step 2: loop 
   test rax,rax  ; if rax == 0  goto ._remaining 
   jz ._remaining 

._quotient:
   mov rcx, rax ; size_t i = rax  
   xor r10, r10 ; size_t offset

._quotient_start_loop:
   movdqu xmm0, [rdi + r10]  ; rdi + i * 16 byte (4 int)
   movdqu xmm1, [rsi + r10]  ; rsi + i * 16 byte (4 int)
   paddd xmm0, xmm1 
   movdqu [rdi + r10], xmm0 
   add r10, 16   
   dec rcx 
   jz ._remaining  ; if i == 0 goto  _remaining
   jmp ._quotient_start_loop

._remaining:
   test rdx, rdx ; if  _remaining == 0; got .out_
   jz .out_

._remaining_start_loop:
   mov r9d, [rsi + r10]  ; r9d -> 32
   add [rdi + r10], r9d
   add r10, 4
   dec rdx
   jz .out_ 
   jmp ._remaining_start_loop

.out_:
   ret



; qa 对齐版
vadd_i32_sse2_qa: 

   ; step 1: div 
   mov rax, rdx ;   
   ; xor rdx, rdx ; rdx set 0
   ; 使用 shr + and 实现 div 4, 当 除数满足是 2^{n} 条件时
   ; rax -> 商, rdx -> 余 
   shr rax, 2 
   and rdx, 3
   
   ; step 2: loop 
   test rax,rax  ; if rax == 0  goto ._remaining 
   jz ._remaining 

._quotient:
   mov rcx, rax ; size_t i = rax  
   xor r10, r10 ; size_t offset

._quotient_start_loop:
   movdqa xmm0, [rdi + r10]  ; rdi + i * 16 byte (4 int)
   movdqa xmm1, [rsi + r10]  ; rsi + i * 16 byte (4 int)
   paddd xmm0, xmm1 
   movdqa [rdi + r10], xmm0 
   add r10, 16   
   dec rcx 
   jz ._remaining  ; if i == 0 goto  _remaining
   jmp ._quotient_start_loop

._remaining:
   test rdx, rdx ; if  _remaining == 0; got .out_
   jz .out_

._remaining_start_loop:
   mov r9d, [rsi + r10]  ; r9d -> 32
   add [rdi + r10], r9d
   add r10, 4
   dec rdx
   jz .out_ 
   jmp ._remaining_start_loop

.out_:
   ret



section .note.GNU-stack noalloc noexec write progbits 
