	.file	"clamp.c"
	.intel_syntax noprefix
# GNU C17 (Ubuntu 13.3.0-6ubuntu2~24.04.1) version 13.3.0 (x86_64-linux-gnu)
#	compiled by GNU C version 13.3.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.26-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -masm=intel -mtune=generic -march=x86-64 -O3 -fno-asynchronous-unwind-tables -fcf-protection=none -fstack-protector-strong -fstack-clash-protection
	.text
	.p2align 4
	.globl	clamp_branched
	.type	clamp_branched, @function
clamp_branched:
# clamp.c:13:   if (val > max)
	cmp	rdi, rdx	# val, tmp91
	mov	rax, rsi	# min, min
	cmovle	rdx, rdi	# val,, tmp87
	cmp	rdi, rsi	# val, min
	cmovge	rax, rdx	# tmp87,, min
# clamp.c:16: }
	ret	
	.size	clamp_branched, .-clamp_branched
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Malloc failed"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC2:
	.string	"Branched Version:   Time = %.5f seconds, Sum = %ld\n"
	.align 8
.LC3:
	.string	"Branchless Version: Time = %.5f seconds, Sum = %ld\n"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB4:
	.section	.text.startup,"ax",@progbits
.LHOTB4:
	.p2align 4
	.globl	main
	.type	main, @function
main:
	push	r13	#
# clamp.c:20:   long *test_data = malloc(sizeof(long) * ARRAY_SIZE);
	mov	edi, 80000000	#,
# clamp.c:18: int main() {
	push	r12	#
	push	rbp	#
	push	rbx	#
	sub	rsp, 24	#,
# clamp.c:20:   long *test_data = malloc(sizeof(long) * ARRAY_SIZE);
	call	malloc@PLT	#
# clamp.c:21:   if (!test_data) {
	test	rax, rax	# test_data
	je	.L14	#,
	mov	rbp, rax	# test_data, tmp142
# clamp.c:26:   srand(42); // 固定随机种子，确保测试公平性
	mov	edi, 42	#,
	call	srand@PLT	#
	mov	r12, rbp	# ivtmp.21, test_data
	lea	rbx, 80000000[rbp]	# _90,
	mov	r13, rbp	# ivtmp.36, test_data
	.p2align 4,,10
	.p2align 3
.L8:
# clamp.c:28:     test_data[i] = rand() % 30; // 数据范围 0 ~ 29
	call	rand@PLT	#
# clamp.c:27:   for (int i = 0; i < ARRAY_SIZE; i++) {
	add	r13, 8	# ivtmp.36,
# clamp.c:28:     test_data[i] = rand() % 30; // 数据范围 0 ~ 29
	movsx	rdx, eax	# _1, _1
	mov	ecx, eax	# tmp123, _1
	imul	rdx, rdx, -2004318071	# tmp119, _1,
	sar	ecx, 31	# tmp123,
	shr	rdx, 32	# tmp120,
	add	edx, eax	# tmp121, _1
	sar	edx, 4	# tmp122,
	sub	edx, ecx	# tmp117, tmp123
	imul	edx, edx, 30	# tmp124, tmp117,
	sub	eax, edx	# tmp125, tmp124
	cdqe
	mov	QWORD PTR -8[r13], rax	# MEM[(long int *)_88], tmp126
# clamp.c:27:   for (int i = 0; i < ARRAY_SIZE; i++) {
	cmp	r13, rbx	# ivtmp.36, _90
	jne	.L8	#,
# clamp.c:33:   volatile long sum = 0; // 使用 volatile 防止编译器把整个循环优化掉
	mov	QWORD PTR 8[rsp], 0	# sum,
# clamp.c:38:   clock_t start_time = clock();
	call	clock@PLT	#
	mov	rdx, rbp	# ivtmp.29, test_data
	mov	r13, rax	# start_time, tmp144
	.p2align 4,,10
	.p2align 3
.L9:
# clamp.c:13:   if (val > max)
	mov	rax, QWORD PTR [rdx]	# MEM[(long int *)_31], MEM[(long int *)_31]
	mov	ecx, 20	# tmp149,
# clamp.c:40:     sum += clamp_branched(test_data[i], min, max);
	mov	rsi, QWORD PTR 8[rsp]	# sum.0_11, sum
# clamp.c:13:   if (val > max)
	cmp	rax, rcx	# MEM[(long int *)_31], tmp149
	cmovg	rax, rcx	# MEM[(long int *)_31],, tmp127, tmp149
# clamp.c:40:     sum += clamp_branched(test_data[i], min, max);
	mov	ecx, 10	# tmp150,
	cmp	rax, rcx	# tmp127, tmp150
	cmovl	rax, rcx	# tmp127,, tmp127, tmp150
# clamp.c:39:   for (int i = 0; i < ARRAY_SIZE; i++) {
	add	rdx, 8	# ivtmp.29,
# clamp.c:40:     sum += clamp_branched(test_data[i], min, max);
	add	rax, rsi	# _12, sum.0_11
	mov	QWORD PTR 8[rsp], rax	# sum, _12
# clamp.c:39:   for (int i = 0; i < ARRAY_SIZE; i++) {
	cmp	rdx, rbx	# ivtmp.29, _90
	jne	.L9	#,
# clamp.c:42:   clock_t end_time = clock();
	call	clock@PLT	#
# clamp.c:44:   printf("Branched Version:   Time = %.5f seconds, Sum = %ld\n", time_branched, sum);
	mov	rdx, QWORD PTR 8[rsp]	# sum.1_15, sum
# clamp.c:43:   double time_branched = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	pxor	xmm0, xmm0	# tmp130
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	lea	rsi, .LC2[rip]	# tmp133,
# clamp.c:43:   double time_branched = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	sub	rax, r13	# tmp129, start_time
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	mov	edi, 2	#,
# clamp.c:43:   double time_branched = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	cvtsi2sd	xmm0, rax	# tmp130, tmp129
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	mov	eax, 1	#,
# clamp.c:43:   double time_branched = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	divsd	xmm0, QWORD PTR .LC1[rip]	# time_branched,
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	call	__printf_chk@PLT	#
# clamp.c:49:   sum = 0; // 重置 sum
	mov	QWORD PTR 8[rsp], 0	# sum,
# clamp.c:50:   start_time = clock();
	call	clock@PLT	#
	mov	r13, rax	# start_time, tmp146
	.p2align 4,,10
	.p2align 3
.L10:
# clamp.c:52:     sum += clamp_branchless(test_data[i], min, max);
	mov	rdi, QWORD PTR [r12]	# MEM[(long int *)_69], MEM[(long int *)_69]
	mov	edx, 20	#,
	mov	esi, 10	#,
# clamp.c:51:   for (int i = 0; i < ARRAY_SIZE; i++) {
	add	r12, 8	# ivtmp.21,
# clamp.c:52:     sum += clamp_branchless(test_data[i], min, max);
	call	clamp_branchless@PLT	#
	mov	rdx, rax	# tmp147,
# clamp.c:52:     sum += clamp_branchless(test_data[i], min, max);
	mov	rax, QWORD PTR 8[rsp]	# sum.2_20, sum
	add	rax, rdx	# _21, tmp147
	mov	QWORD PTR 8[rsp], rax	# sum, _21
# clamp.c:51:   for (int i = 0; i < ARRAY_SIZE; i++) {
	cmp	r12, rbx	# ivtmp.21, _90
	jne	.L10	#,
# clamp.c:54:   end_time = clock();
	call	clock@PLT	#
# clamp.c:56:   printf("Branchless Version: Time = %.5f seconds, Sum = %ld\n", time_branchless, sum);
	mov	rdx, QWORD PTR 8[rsp]	# sum.3_24, sum
# clamp.c:55:   double time_branchless = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	pxor	xmm0, xmm0	# tmp136
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	lea	rsi, .LC3[rip]	# tmp139,
# clamp.c:55:   double time_branchless = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	sub	rax, r13	# tmp135, start_time
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	mov	edi, 2	#,
# clamp.c:55:   double time_branchless = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	cvtsi2sd	xmm0, rax	# tmp136, tmp135
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	mov	eax, 1	#,
# clamp.c:55:   double time_branchless = (double)(end_time - start_time) / CLOCKS_PER_SEC;
	divsd	xmm0, QWORD PTR .LC1[rip]	# time_branchless,
# /usr/include/x86_64-linux-gnu/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	call	__printf_chk@PLT	#
# clamp.c:58:   free(test_data);
	mov	rdi, rbp	#, test_data
	call	free@PLT	#
# clamp.c:59:   return 0;
	xor	eax, eax	# <retval>
.L5:
# clamp.c:60: }
	add	rsp, 24	#,
	pop	rbx	#
	pop	rbp	#
	pop	r12	#
	pop	r13	#
	ret	
	.section	.text.unlikely
	.type	main.cold, @function
main.cold:
.L14:
# clamp.c:22:     perror("Malloc failed");
	lea	rdi, .LC0[rip]	# tmp116,
	call	perror@PLT	#
# clamp.c:23:     return 1;
	mov	eax, 1	# <retval>,
	jmp	.L5	#
	.section	.text.startup
	.size	main, .-main
	.section	.text.unlikely
	.size	main.cold, .-main.cold
.LCOLDE4:
	.section	.text.startup
.LHOTE4:
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC1:
	.long	0
	.long	1093567616
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
