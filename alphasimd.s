section .rodata
    align 16 
    ones: times 4 dd 1.0  ; 4 * 1.0(float)

section .text 
  global osb_vblend_f32

; extern void osb_vblend_f32(float *restrict c, const float *restrict a, const float *restrict b,
;                       float alpha, size_t n);
; ABI 
; rdi -> float * c 
; rsi -> float * a
; rdx -> float * b
; xxm0 -> alpha 
; rcx -> n 
; a , b , c  No memory overlap for restrict 
; alpha = α
; C[i] = A[i] * α + B[i](1.0 - α)
; 0.0 <= a <= 1.0
osb_vblend_f32:
; step 1:  div 4
   mov r8, rcx
   shr rcx, 2 ; 商
   and r8, 3  ; 余数

; step 2: preparation data
   ; 
   ; float alpha =  xmm0[0]
   ; broadcast xmm0 
   pshufd xmm0, xmm0, 0
   ;
   movups xmm1, [ones]
   ; xmm1 -= xmm0
   subps xmm1, xmm0

   ; long offset = 0 
   xor rax, rax
   ; if rcx = 0  
   test rcx, rcx 
   jz ._remainder

   ; xmm0 = aplha  
   ; xmm1 = (1.0 - aplha)

._quotient:
   ; xmm2 =  a + offset
   movups xmm2, [rsi + rax]  
   ; xmm3 =  b + offset
   movups xmm3, [rdx + rax]

   ; C[i] = A[i] * α + B[i](1.0 - α)
   mulps xmm2, xmm0   
   mulps xmm3, xmm1 
   addps xmm2, xmm3
   movups [rdi + rax], xmm2
   add rax, 16
   dec rcx
   jnz ._quotient
   
._remainder:
   test r8, r8
   jz ._out
   pxor xmm2, xmm2  ; set xmm2 = 0  
   pxor xmm3, xmm3  ; set xmm3 = 0
   
._remainder_loop:
   ; xmm2[0] = rsi + offset
   movd xmm2, dword [rsi + rax]
   movd xmm3, dword [rdx + rax]

   ; C[i] = A[i] * α + B[i](1.0 - α)xmm2
   ; xmm0 = aplha  
   ; xmm1 = (1.0 - aplha)
   mulss xmm2, xmm0  
   mulss xmm3, xmm1
   addss xmm2, xmm3
   movd dword [rdi + rax], xmm2
   add rax, 4 
   dec r8
   jnz ._remainder_loop

._out:
   ret

section .note.GNU-stack noalloc noexec write progbits   



