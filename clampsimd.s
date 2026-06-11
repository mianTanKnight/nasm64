section  .text
  global vclamp_i32_sse4
  global sum_i32_sse2

;手写 4 路并行向量化 Clamp

;extern void vclamp_i32_sse4(int *a, size_t n, int min, int max);
; rdi -> int *a
; rsi -> n
; rdx -> min 
; rcx -> max 

; use r8,r9
vclamp_i32_sse4:

; step1:
  mov r8, rsi ; div 4
  shr r8, 2   ; quotient in r8 
  and rsi, 3  ; remainder in rsi

  xor r9, r9  ; global offset long offset = 0 
  test r8, r8 ; if quotient == 0 
  jz  ._start_remainder 

  movd xmm1, edx              ; mov edx(32) to xmm1[0](32)
  pshufd xmm1, xmm1, 0        ; 广播 [0] 32byte 
  movd xmm2, ecx 
  pshufd xmm2, xmm2, 0

._start_quotient:
                              ;movdqu 16byte 向量寄存器 非对齐支持
  movdqu xmm0, [rdi + r9]
  pmaxsd xmm0, xmm1           ; xmm0 = max(xmm0, xmm1) 
  pminsd xmm0, xmm2           ; xmm0 = min(max(xmm0, xmm1), xmm2)

  movdqu [rdi + r9], xmm0    ;  r = xmm0 
  add r9, 16
  dec r8 
  jz ._start_remainder
  jmp ._start_quotient

._start_remainder:

  test rsi, rsi
  jz  ._out
  
._remainder_loop:
  mov eax, dword [rdi + r9] 
  cmp eax, edx                ; *(a + offset) = max(*(a + offset), min)
  cmovl eax, edx 
  cmp eax, ecx                ; *(a + offset) = min(*(a + offset), max)
  cmovg eax, ecx      
  mov dword[rdi + r9], eax  
  add r9, 4                   ; offset += 4
  dec rsi                     ; ramainder--
  jnz ._remainder_loop

._out:
  ret



; extern int sum_i32_sse2(const int *a, size_t n);  
; int sum = 0;
; for (size_t i = 0; i < n; i++) {
    ; sum += a[i];
; }
; return sum;
; rdi -> int* a
; rsi -> n
sum_i32_sse2:
  
  mov rdx, rsi     ; div 4
  shr rsi, 2       ; quotient in rsi 
  and rdx, 3       ; remainder in rdx

  xor rcx, rcx               ;  long offset = 0
  test rsi, rsi
  jz ._start_remainder

._start_quotient:
  movdqu xmm0, [rdi + rcx]   ;xmm0 init
  add rcx, 16
  dec rsi

._quotient_loop:
  jz ._start_remainder       ; rsi == 0
  movdqu xmm1, [rdi + rcx]
  paddd  xmm0, xmm1
  add rcx, 16
  dec rsi
  jmp ._quotient_loop

._start_remainder:

  pxor xmm1, xmm1           ; set xmm1 = 0 
  test rdx, rdx

._remainder_loop:  
  jz ._sum_xmm_int4
  cmp rdx, 1
  jz  ._mov_1
  cmp rdx, 2
  jz  ._mov_2

  jmp ._mov_3

._mov_1:
    pinsrd xmm1, [rdi + rcx], 1
    add rcx, 4 
    dec rdx
    jmp ._remainder_loop

._mov_2:
    pinsrd xmm1, [rdi + rcx], 2
    add rcx, 4 
    dec rdx
    jmp ._remainder_loop

._mov_3:
    pinsrd xmm1, [rdi + rcx], 3
    add rcx, 4 
    dec rdx
    jmp ._remainder_loop    


._sum_xmm_int4: 
  paddd  xmm0, xmm1  ; push last xmm 
  phaddd xmm0, xmm0  ; 水平相加
  phaddd xmm0, xmm0  ;
  movd eax, xmm0

._out:
  ret


section .note.GNU-stack noalloc noexec write progbits   