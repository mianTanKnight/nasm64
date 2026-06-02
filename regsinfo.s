section .text
    global  test_syscall_registers



;extern void test_syscall_registers(unsigned long *out_rcx, unsigned long *out_r11);
test_syscall_registers:
    push rdi
    push rsi

    mov rcx, 0xAAAAAAAAAAAAAAAA
    mov r11, 0xBBBBBBBBBBBBBBBB

    mov rax, 39

    ; 系统调用
    ; syscall 会由用户态 切换 内核态
    ; 在 syscall 被执行之后 rcx , r11 会被内核临时使用 用来储存 返回地址(syscall 之后的下一条指令地址) 和 rflags 的值(计算状态)
    ; rcx和r11的值是硬件直接写入的
    ; 那么为什么 不使用栈呢 ? 也就是在 执行syscall 之前把 returnaddress 压当前栈?
    ; 1: 当前栈是用户栈 也就是说在执行syscall 后面 切换到内核态 返回地址在调用者 用户栈的栈顶, 用户栈是不安全的
    ; 2: return address 和 rflags 的值 是 syscall 之后内核态可能需要使用的, 它会把数据copy 到内核栈上, 最后在 sysret 时 赋值给用户态的 rcx 和 r11
    syscall

    ; syscall 和 call 在 ABI 调用约定并不一样
    ; call -> rdi, rsi, rdx, rcx, r8, r9
    ; syscall -> rdi, rsi, rdx, r10, r8, r9

    ;Post-syscall R11 打印出来的十六进制值，其二进制中的第 9 位（IF, Interrupt Flag，中断允许标志）是否为 1？这代表了什么硬件状态？

    ; eflags -> [IF] = 1
    ; 首先我们都要明白 IF 是中断允许
    ; 什么叫中断 ? 我们知道程序在 表面上是线性执行的
    ; example : while(1) {}
    ; 在 CPU眼中 它依然是线性执行的(只是不会停止), 人们会觉得 CPU 无法切出
    ; 但中断是一种线性打断机制 就像在一条直线上 开出一个口子 两端接入另一条线, 对于 CPU来说这依然是线性的 
    ; 但对于内核或(多任务支持设计 UINX) 来说这是一切的最重要的基石 , 这也是软件和硬件看问题的区别(硬件要足够简单和线性, 但软件需要组织复杂)
    ; 对于软件来说 它由中断掌控复杂 例如 多任务交叉执行,  用户态-> 内核态, IO, 外部硬件输入等等 
    ; 它告诉硬件 当前有更重要的事情需要你去做 但对于硬件来说 它不在乎这个 它只需要线性的执行指令(线性)
    
    ; 但中断也是需要控制时机的 这非常关键  有时候内核在一些核心事件事 是不能被打断的(安全与原子)
    ; IF = 1是默认的 但 IF = 0 是特权的 
    ; 用户态 IF 是默认1 或者说 IF set 0 用户态是没有权限的
    ; IF = 0 是内核特权 -> sysall -> 内核态 -> do core code (set IF = 0) -> reset IF = 1 -> sysret  -> 用户态、
    ; 关中断是 CPU 硬件在执行 syscall 时自动完成的
    
    ; 但中断是有成本的 当中断发生之后 当前执行环境是需要被保存的 以支持能返回继续执行
    ; 但保存是混合的 一个 CPU 保存关键的环境信息例如 寄存器与 eflag 其余的会由内核代码保存 

.next_instr:
    pop rsi
    pop rdi
    
    mov [rdi], rcx 
    mov [rsi], r11
    ret

section .note.GNU-stack noalloc noexec write progbits   