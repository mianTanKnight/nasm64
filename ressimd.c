#include <stdio.h>

void vadd_normal(int *a, int *b, int *c, size_t n) {
  for (size_t i = 0; i < n; i++)
    c[i] = a[i] + b[i];
}

void vadd_restrict(int *restrict a, int *restrict b, int *restrict c, size_t n) {
  for (size_t i = 0; i < n; i++)
    c[i] = a[i] + b[i];
}

// vadd_normal:
//         test    rcx, rcx
//         je      .LBB0_12
//         cmp     rcx, 12      // 这里选的是 12
//         jae     .LBB0_3
//         xor     eax, eax
//         jmp     .LBB0_8
// .LBB0_3:
//         mov     r8, rdx
//         sub     r8, rdi      // long spacing = c - a
//         xor     eax, eax
//         cmp     r8, 32
//         jb      .LBB0_8     //  if spacing < 32
//         mov     r8, rdx
//         sub     r8, rsi     //  spacing = c - b
//         cmp     r8, 32      //  if spacing < 32
//         jb      .LBB0_8
//         mov     rax, rcx
//         and     rax, -8      //  div 8  商在 rax
//         xor     r8d, r8d
// .LBB0_6:    // 使用向量化处理
//         movdqu  xmm0, xmmword ptr [rdi + 4*r8]        // xmm0 = a + offset
//         movdqu  xmm1, xmmword ptr [rdi + 4*r8 + 16]   // xmm1 = a + offset + 16
//         movdqu  xmm2, xmmword ptr [rsi + 4*r8]        // xmm2 = b + offset
//         paddd   xmm2, xmm0                            // xmm2 += xmm0
//         movdqu  xmm0, xmmword ptr [rsi + 4*r8 + 16]   // xmm0 = b  + offset + 16
//         paddd   xmm0, xmm1                            // xmm0 += xmm1
//         movdqu  xmmword ptr [rdx + 4*r8], xmm2        // 一次循环处理了 2个 4 * int
//         movdqu  xmmword ptr [rdx + 4*r8 + 16], xmm0
//         add     r8, 8
//         cmp     rax, r8
//         jne     .LBB0_6
//         cmp     rax, rcx
//         je      .LBB0_12
// .LBB0_8:
//         mov     r8, rax
//         not     r8
//         add     r8, rcx
//         mov     r9, rcx
//         and     r9, 3      // 余数在 r9
//         je      .LBB0_10
// .LBB0_9:
//         mov     r10d, dword ptr [rsi + 4*rax]
//         add     r10d, dword ptr [rdi + 4*rax]
//         mov     dword ptr [rdx + 4*rax], r10d
//         inc     rax
//         dec     r9
//         jne     .LBB0_9
// .LBB0_10:
//         cmp     r8, 3
//         jb      .LBB0_12
// .LBB0_11:
//         mov     r8d, dword ptr [rsi + 4*rax]
//         add     r8d, dword ptr [rdi + 4*rax]
//         mov     dword ptr [rdx + 4*rax], r8d
//         mov     r8d, dword ptr [rsi + 4*rax + 4]
//         add     r8d, dword ptr [rdi + 4*rax + 4]
//         mov     dword ptr [rdx + 4*rax + 4], r8d
//         mov     r8d, dword ptr [rsi + 4*rax + 8]
//         add     r8d, dword ptr [rdi + 4*rax + 8]
//         mov     dword ptr [rdx + 4*rax + 8], r8d
//         mov     r8d, dword ptr [rsi + 4*rax + 12]
//         add     r8d, dword ptr [rdi + 4*rax + 12]
//         mov     dword ptr [rdx + 4*rax + 12], r8d
//         add     rax, 4
//         cmp     rcx, rax
//         jne     .LBB0_11
// .LBB0_12:
//         ret

// vadd_restrict:
//         test    rcx, rcx  // if n = 0
//         je      .LBB1_7
//         cmp     rcx, 8    // if n >= 8
//         jae     .LBB1_3   // 向量化处理
//         xor     eax, eax
//         jmp     .LBB1_6   // 普通处理
// .LBB1_3:
//         mov     rax, rcx
//         and     rax, -8
//         xor     r8d, r8d
// .LBB1_4:
//         movdqu  xmm0, xmmword ptr [rdi + 4*r8]
//         movdqu  xmm1, xmmword ptr [rdi + 4*r8 + 16]
//         movdqu  xmm2, xmmword ptr [rsi + 4*r8]
//         paddd   xmm2, xmm0
//         movdqu  xmm0, xmmword ptr [rsi + 4*r8 + 16]
//         paddd   xmm0, xmm1
//         movdqu  xmmword ptr [rdx + 4*r8], xmm2
//         movdqu  xmmword ptr [rdx + 4*r8 + 16], xmm0
//         add     r8, 8
//         cmp     rax, r8
//         jne     .LBB1_4
//         cmp     rax, rcx
//         je      .LBB1_7
// .LBB1_6:
//         mov     r8d, dword ptr [rsi + 4*rax]
//         add     r8d, dword ptr [rdi + 4*rax]
//         mov     dword ptr [rdx + 4*rax], r8d
//         inc     rax
//         cmp     rcx, rax
//         jne     .LBB1_6
// .LBB1_7:
//         ret

// 我们从汇编上分析得到的 gcc -03
// 对于这种多数组的顺序运算 或者说可以明显可以向量化
// 编译器 不会因为 a, b ,c 存在可能的内存重叠 而放弃向量化
// 而是使用 地址差来解决 问题

// 但对于 存在 restrict 语义保证的 编译器不会执地址差比较
// 这就是 C 标准赋予 编译器 关于 UB 的权力
