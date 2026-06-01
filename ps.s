section  .text
   global _x86_64_single_slot_publish_data 
   global _x86_64_single_slot_consume_data


; 这里我们要明白一个基础概念
; CPU 的乱序执行（Out-of-Order Execution）与 汇编指令的架构顺序是两回事
; mov[rdi],rdx ; s1
; mov [rsi],1 ; s2
; 这两条指令在汇编代码中是顺序的，但是 CPU 它不会检查"业务逻辑顺序"
; CPU 只会检查是否存在 数据依赖关系 （Data Dependency）来决定指令的执行顺序
; 所以 s1 和 s2 之间是没有数据依赖关系的，所以 CPU 就可能会乱序执行它们， 也就是 s2 可能会被执行到 s1 前面去。

; mov rcx, [rsi] 
; cmp rcx, 1
; 是否可能存在乱序执行的情况呢？ 
; 不会 因为存在 rcx 数据顺序依赖关系 

; extern void _x86_64_single_slot_publish_data( volatile long* payload_ptr, volatile long* ready_ptr, long data);
_x86_64_single_slot_publish_data:
; step 1 检查 ready_ptr = 0 
.rstart:
    mov rcx , [rsi]
    cmp rcx, 0
    je .rready
    
    pause
    jmp .rstart

.rready:
    mov [rdi], rdx ; store data to payload_ptr  ; s1
    sfence  ; store Fance Birrier, 保证 s1 已提交
    mov qword [rsi], 1  ;
    ret 



; 这里有一个非常有意思的 CPU执行的概念 -> 投机执行（Speculative Execution）
; 它是和 CPU 的分支预测（Branch Prediction）密切相关的

; 如果 [rsi] 是一个非常耗时的操作呢 不在 L1 Cache 中呢？ 可能会存在一个非常长的等待时间
; 关键点是 je .rready 这个分支指令了
; CPU 会对这个分支指令进行分支预测，这就会产生 "投机" 行为
; 先把可能的最终结果 mov rax, [rdi] 先执行。 这是一个典型的投机执行  因为 rsi 根本还是没有准备好的(因为它是一个非常耗时的操作);
; 执行顺序是这样的：
; mov rax, [rdi]
; cmp [rsi], 1 
; je  ret
; rollback (冲刷流水线 + 跳回 .rstart 重新执行(丢弃 rax的旧值))
; 但最终结果的正确性是会得到保证的


; extern long _x86_64_single_slot_consume_data( volatile long *payload_ptr, volatile long *ready_ptr);
_x86_64_single_slot_consume_data:
.rstart:
    cmp qword [rsi], 1
    je .rready
    pause
    jmp .rstart
; 那么 mov rax, [rdi]  会在      cmp [rsi], 1 之前执行吗 ？
; 存在可能性  
; 那么是否需要加 lfence 来禁止 load 和 store 之间的乱序执行呢？
; 不需要 因为 cpu 会保证最终正确性(虽然存在投机执行的情况)
.rready:
    mov rax, [rdi]          ; 1. 读取 payload 数据到 rax
    mov qword [rsi], 0      ; 将 ready 标志重置为 0，锁住下一次读取
    ret

section .note.GNU-stack noalloc noexec write progbits      