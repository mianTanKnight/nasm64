section .text
    global va_split

; void va_split(uint64_t va, struct VaParts *out)
;
; System V ABI:
;   rdi = va
;   rsi = out
;
; struct VaParts {
;   uint64_t pml4;
;   uint64_t pdpt;
;   uint64_t pd;
;   uint64_t pt;
;   uint64_t offset;
;   uint64_t vpn;
; };

va_split:
    ; PML4 = (va >> 39) & 0x1ff
    mov     rax, rdi
    shr     rax, 39
    and     rax, 0x1ff
    mov     [rsi + 0], rax

    ; PDPT = (va >> 30) & 0x1ff
    mov     rax, rdi
    shr     rax, 30
    and     rax, 0x1ff
    mov     [rsi + 8], rax

    ; PD = (va >> 21) & 0x1ff
    mov     rax, rdi
    shr     rax, 21
    and     rax, 0x1ff
    mov     [rsi + 16], rax

    ; PT = (va >> 12) & 0x1ff
    mov     rax, rdi
    shr     rax, 12
    and     rax, 0x1ff
    mov     [rsi + 24], rax

    ; offset = va & 0xfff
    mov     rax, rdi
    and     rax, 0xfff
    mov     [rsi + 32], rax

    ; vpn = va >> 12
    mov     rax, rdi
    shr     rax, 12
    mov     [rsi + 40], rax

    ret

section .note.GNU-stack noalloc noexec write progbits