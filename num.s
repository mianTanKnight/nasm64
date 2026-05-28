section  .data
         num dw 5
section  .text 
global _start 


_start:
  mov di, word [num]

exit:
   mov rax, 60
   syscall
