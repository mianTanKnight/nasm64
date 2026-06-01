##

.section 定义域

## Data

DB: byte
DW: two byte
DD: four byte
DQ: eight byte
DT: ten/eighty byte

byte：1 字节
word：2 字节
dword：4 字节
qword：8 字节

寄存器保护责任（核心考点）
Callee-saved (被调用者保存)：rbx, rsp, rbp, r12-r15。
如果你的函数要修改这些寄存器，必须先 push 保护，在函数返回（ret）前 pop 恢复。
Caller-saved (调用者保存)：除上面以外的寄存器（如 rax, rdi, rsi, rdx, rcx, r8-r11）。
函数内部可以随意覆盖这些寄存器。如果你调用了别的函数，必须默认这些寄存器的值已经被别人改掉了。

nasm -f elf64 -g -F dwarf hello.asm -o hello.o
ld hello.o -o hello
底循环

x86 中所有算术和逻辑指令都会根据结果设置标志位% 
