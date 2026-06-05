section .text
   global clamp_branchless
   global clamp_branchless_op


; extern long clamp_branchless(long val, long min, long max);
; long clamp(long val, long min, long max) {
;     if (val < min) return min;
;     if (val > max) return max;
;     return val;
; }
; val -> rdi , min -> rsi , min -> rdx 
clamp_branchless:
    ; int x = min  s1
    mov rax, rsi 
    ; var - min   s2
    cmp rdi, rsi
    ; if var > min ; x= val s3  
    cmovg rax, rdi  
    ; x - max  s4 
    cmp rax , rdx
    ; if x > max  ; x = max  s5 
    cmovg rax, rdx  
    ; return x  s6 
    ret
; 我们分析下指令依赖关系 
; s1 和 s2 没有 true dependency，可以并行执行。
; s3 同时依赖：
;     s1 产生的 rax
;     s2 产生的 FLAGS
; s4 依赖：
;     s3 产生的 rax
; s5 同时依赖：
;     s4 产生的 FLAGS
;     s3 产生的 rax，因为 cmov 不成立时要保留旧 rax
; 所以关键路径大概是：
;     s1/s2 并行
;         -> s3
;         -> s4
;         -> s5
;         -> ret

; 所以分析结果是 s1, s2 是可以并行发射的 
; s1: mov rax, rsi  ───────┐
;                          v
; s2: cmp rdi, rsi ───► s3: cmovg rax, rdi ───► s4: cmp rax, rdx ───► s5: cmovg rax, rdx ───► ret
;        │ flags                 │ rax                 │ flags              │ rax
;        └───────────────────────┘                     └───────────────────┘

; extern long clamp_branchless(long val, long min, long max);
; long clamp(long val, long min, long max) {
;     if (val < min) return min;
;     if (val > max) return max;
;     return val;
; }

; long clamp_branchless_gcc_style(long val, long min, long max);
; val -> rdi
; min -> rsi
; max -> rdx
; return -> rax

clamp_branchless_op:
    cmp     rdi, rdx        ; val - max
    mov     rax, rsi        ; rax = min
    cmovle  rdx, rdi        ; if val <= max, rdx = val
                            ; else rdx remains max
                            ; rdx = min(val, max)

    cmp     rdi, rsi        ; val - min

    cmovge  rax, rdx        ; if val >= min, rax = min(val, max)
                            ; else rax remains min
    ret



section .note.GNU-stack noalloc noexec write progbits 

