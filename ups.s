section .rodata
   align 8   
 
   ; jump_table_calculator 是一个标签
   jump_table_calculator:
      dq  calculator.calculator_case_0
      dq  calculator.calculator_case_1
      dq  calculator.calculator_case_2
      dq  calculator.calculator_case_3

section .text

;extern long calculator(long a, long b, int op_code);
global calculator
;extern void modify_via_dp(int **ptr_to_ptr);
global modify_via_dp
global update_student
; struct S {
;   char grade;  1 align 
;   padding 7
;   long id;     8 align
;   padding 0
;   int age;     4 align 
;   padding 4
; };
; extern void update_student(struct S *s);
;  将 grade 修改为 'B'
;  将 id 修改为 2025
;  将 age 修改为 20
update_student:
; rdi  s'point
; don't create stack farme 
   mov byte [rdi],  'B'
   mov qword [rdi + 8], 2025
   mov dword [rdi + 16], 20
   ret

modify_via_dp:
   mov rax, [rdi]
   mov dword [rax], 500
   xor rax, rax
   ret

;extern long calculator(long a, long b, int op_code);
calculator: 
   cmp rdx, 0 
   jl  .case_default ; if op_code < 0 
   cmp rdx, 4 
   jge .case_default ; if op_code >= 4
   jmp [jump_table_calculator + rdx * 8]


; 0  rax =  rdi + rsi
.calculator_case_0:
   lea rax, [rdi + rsi] 
   ret

; 1 rax = rdi - rsi
.calculator_case_1:
   mov rax, rdi
   sub rax, rsi
   ret 

; 2 rax = rdi * rsi
.calculator_case_2:
   mov rax, rdi
   imul rsi   ; 有符号乘法
   ret 

; 2 rax = rdi & rsi
.calculator_case_3:
   mov rax, rdi
   and rax, rsi
   ret 

.case_default:
   mov rax, -1
   ret


section .note.GNU-stack noalloc noexec write progbits