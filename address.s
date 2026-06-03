
; 我们使用nasm 实现拆解一个虚拟地址
; PML4 = virtual_address 的 bit 47..39  // 9bit  -> mask 0x0000 FF80 0000 0000
; PDPT = virtual_address 的 bit 38..30  // 9bit  -> mask 0x0000 007F C000 0000
; PD   = virtual_address 的 bit 29..21  // 9bit  -> mask 0x0000 0000 3FE0 0000
; PT   = virtual_address 的 bit 20..12  // 9bit  -> mask 0x0000 0000 001F F000
; offset = virtual_address 的 bit 11..0 // 12bit -> mask 0x0000 0000 0000 0FFF

; rdi is virtual address, rsi is transfom address (C)
; struct transform { 
;   unsigned long PML4;   // 8
;   unsigned long PDPT;   // 8
;   unsigned long PD;     // 8 
;   unsigned long PT;     // 8 
;   unsigned long offset; // 8
; }; (十进制) sizeof -> 40

; 我们来解决下面问题
; 1: 16制 转 2进制  这个天然解决 因为寄存器天然储存的就是二进制 mov rdi, address rdi 中就是二进制
; 2: 对rdi进行位级别的操作 
section .rodata
    PML4  equ  0x0000FF8000000000
    PDPT  equ  0x0000007FC0000000
    PD    equ  0x000000003FE00000
    PT    equ  0x00000000001FF000
    OFFSET equ 0x0000000000000FFF

section .text
    global transform_virtual_address


; 我们使用掩码 + and 
; transform_virtual_address(unsigned long long virtual_address, struct transform *t);
transform_virtual_address:
; offset
    mov rax, rdi 
    and rax, OFFSET
    mov qword [rsi + 32], rax ;  qword is 8 byte
    
; PT 
    mov rax, rdi
    and rax, PT 
    shr rax, 12
    mov qword [rsi + 24], rax 

; PD 
    mov rax, rdi
    and rax, PD 
    shr rax, 21
    mov qword [rsi + 16], rax

; PDPT
    mov rax, rdi 
    mov rdx, PDPT
    and rax, rdx
    shr rax, 30
    mov qword [rsi + 8], rax 

; PML4
    mov rax, rdi
    mov rdx, PML4
    and rax, rdx
    shr rax, 39
    mov qword [rsi], rax 


    xor rax, rax
    ret 
     

section .note.GNU-stack noalloc noexec write progbits  