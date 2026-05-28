section .text

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