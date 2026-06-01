
section  .text


; extern void spin_lock(long *lock_ptr);
; extern void spin_unlock(long *lock_ptr);

global spin_lock
global spin_unlock

spin_lock:
; rdi 
._start:
  mov rax, 1
  ; 这里是加了mfence 的全能屏障
  xchg [rdi],rax ; change
  cmp rax, 0
  je ._out
  
  pause
  jmp ._start

._out:
  ret


spin_unlock:
  ; mov rax, 0
  ; xchg [rdi], rax
  mov qword [rdi], 0
  ; unlock 最重要的原子保证, 汇编指令 并没有保证 一行汇编在执行过程中 是不被"撕裂"的
  ; 但存在一个默认的保证, 对一个8字节对齐的内存一次性写入是不会被撕裂的 也就是存在原子保证的？ 
  ret
; 2. x86_64 的硬件保证：自然对齐的原子性
; 在 Intel 和 AMD 的官方《软件开发者手册（SDM）》中，明确给出了硬件级承诺（Guaranteed Atomic Operations）：
; 以下内存操作在硬件层面总是原子的，绝对不会被“撕裂”：
; 读写 1 字节（byte）
; 读写 16 位对齐的 2 字节（word）
; 读写 32 位对齐的 4 字节（dword）
; 读写 64 位对齐的 8 字节（qword）
; 为什么对齐就能保证原子？
; 现代 64 位 CPU 的内存总线宽度至少是 64 位（8 字节）。
; 如果数据是对齐的（即地址能被 8 整除）：CPU 只需要发起一次总线/缓存事务，即可把 8 字节数据一次性送入 L1 Cache。因为只有一次物理操作，所以外界要么看到写入前的值，要么看到写入后的值，绝对没有“中间态”。
; 如果数据未对齐（例如跨越了两个 8 字节物理边界或 Cache Line）：CPU 必须拆分成两次物理操作去写入。在这两次操作之间，其他核心就有可能横插一刀，读到被“撕裂”的半新半旧数据。

; 规则：Stores are not reordered with other Stores（写操作之间不能乱序）。


section .note.GNU-stack noalloc noexec write progbits  