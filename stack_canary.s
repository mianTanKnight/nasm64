extern printf
extern exit
extern __stack_chk_fail


section .data
    fmt db "Canary value checked successfully!", 10, 0

section  .text
    global main 


global safe_func
safe_func:
    push rbp 
    mov rbp, rsp   ; create stack frame 
    sub rsp, 32    ;

    ; canary
    mov rax, qword[fs:0x28]
    mov qword [rbp - 8], rax


    ;buss

    mov rax, qword [rbp - 8]
    xor rax, qword [fs:0x28]
    jne .corrupted

    mov rsp, rbp
    pop rbp
    ret 

.corrupted:
    call __stack_chk_fail


main:

    ; main 也是一个标准的函数 在  AMD 64_ ABI 要求  call 指令之前 rsp 的地址必须是 16对齐
    ; 因为 call 之后 的存在一个 隐形的指令  push  return addre(8 byte)
    ; 所以在 执行 sub rsp, 8  rsp的地址最后一位是 8 而非 0 这恰好是因为 AMD 64_ABI 被满足了
    ; 通常我们在进入一个函数之后 要创造 栈帧 也就是标准的 push rbp (8 byte) 也就是说 在真正执行业务之前 rsp 是依然是满足 16对齐
    ; 当然 我们在调用其他任何函数时(call) 也要满足 AMD 64_ ABI 要求


    sub rsp, 8 
    call safe_func
    
    mov rdi, fmt
    xor al, al
    call printf

    ; 在你的 main 中，最后调用 exit 退出，而没有执行对应的 add rsp, 8。
    ;为什么这里不执行 add rsp, 8 恢复栈平衡，程序也不会崩溃？如果把 call exit 换成普通函数的 ret 指令，不执行 add rsp, 8 会发生什么？
    
    ; mian 函数并没有执行 push rbp 所以它需要 手动对齐 也就是 sub rsp, 8
    
    ; add rsp, 8 
    ; mov rdi, 0
    ; ret 
    ; 使用 ret 也没问题 因为 存在 add rsp, 8 那么 rsp 回到进入main函数之初的地址 也就是rsp的地址最后一位是 8
    ; 重要的是 这时栈最底下依然有 一个 8 byte return addre(8 byte)  ret 默认会有这个弹出地址动作 
    ; rsp 依然满足 16 对齐
    
    ; add rsp, 8 
    mov rdi, 0
    call  exit

 section .note.GNU-stack noalloc noexec write progbits