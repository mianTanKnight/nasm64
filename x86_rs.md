这份文档为你整理了 **x86_64 汇编核心知识字典**。它针对你目前在 Ubuntu (Linux) 环境下使用 GCC 分析 C 语言代码的需求进行了优化。

---

# x86_64 汇编核心知识手册 (Linux/System V ABI)

## 1. 寄存器体系 (Registers)

x86_64 共有 16 个 64 位通用寄存器。它们具有嵌套结构，可以访问其低位部分。

### 1.1 寄存器嵌套结构 (以 A 寄存器为例)

| 64位名 (8字节) | 32位名 (4字节) | 16位名 (2字节) | 8位名 (1字节) | 用途备注                            |
| :------------- | :------------- | :------------- | :------------ | :---------------------------------- |
| **RAX**        | EAX            | AX             | AL            | 累加器 / **函数返回值**             |
| **RBX**        | EBX            | BX             | BL            | 基址寄存器 (Callee-saved)           |
| **RCX**        | ECX            | CX             | CL            | 计数器 (第4个参数)                  |
| **RDX**        | EDX            | DX             | DL            | 数据寄存器 (第3个参数)              |
| **RSI**        | ESI            | SI             | SIL           | 源变址寄存器 (第2个参数)            |
| **RDI**        | EDI            | DI             | DIL           | 目的变址寄存器 (第1个参数)          |
| **RBP**        | EBP            | BP             | BPL           | 栈基指针 (指向栈底)                 |
| **RSP**        | ESP            | SP             | SPL           | **栈指针 (指向栈顶)**               |
| **R8-R15**     | R8D-R15D       | R8W-R15W       | R8B-R15B      | 额外通用寄存器 (R8,R9为第5,6个参数) |

---

## 2. Linux 函数调用约定 (Calling Convention - System V ABI)

在 Linux x86_64 环境下，函数调用遵循 **System V AMD64 ABI** 协议。

### 2.1 参数传递

- **前 6 个整数/指针参数** 依次通过寄存器传递：
  1.  `RDI`
  2.  `RSI`
  3.  `RDX`
  4.  `RCX`
  5.  `R8`
  6.  `R9`
- **第 7 个及以后的参数**：通过**内存栈**传递。
- **浮点参数**：使用 `XMM0` 到 `XMM7` 寄存器。

### 2.2 寄存器保护责任

- **Caller-saved (调用者保存)**: `RAX`, `RCX`, `RDX`, `RDI`, `RSI`, `R8-R11`。
  - 函数内部可以随意覆盖这些寄存器，如果调用者还需要它们，必须在调用前自己存入栈中。
- **Callee-saved (被调用者保存)**: `RBX`, `RBP`, `R12-R15`。
  - 如果函数要用到这些寄存器，必须先 `push` 保存，退出前 `pop` 恢复，保证调用者看到的寄存器值不变。

---

## 3. 核心指令集 (Core Instructions)

### 3.1 数据移动

- `mov  dest, src`: 数据赋值。
- `movzx`: 零扩展移动（用于将小内存数据放入大寄存器，高位补0）。
- `lea  dest, [src]`: **Load Effective Address**。计算地址但不访问内存。常用于 `dest = 基址 + 偏移` 的快速加法。

### 3.2 算术逻辑

- `add / sub`: 加/减。
- `inc / dec`: 自增/自减（不推荐，现代 CPU 常用 add 1）。
- `imul / idiv`: 有符号乘/除。
- `xor eax, eax`: **清零寄存器的标准做法**（比 mov eax, 0 快且指令短）。
- `test`: 逻辑与运算（不保留结果，仅影响标志位）。常用于 `test eax, eax` 检查是否为 0。
- `cmp`: 比较运算（减法，不保留结果，仅影响标志位）。

### 3.3 控制流

- `jmp`: 无条件跳转。
- `je / jne`: 等于则跳 / 不等于则跳 (Check ZF flag)。
- `jg / jl`: 大于跳 / 小于跳 (有符号)。
- `ja / jb`: 高于跳 / 低于跳 (无符号)。
- `call`: 调用函数（将下一条指令地址压栈，跳到目标）。
- `ret`: 返回（从栈顶弹出地址并跳回）。

---

## 4. 内存操作与尺寸 (Intel 语法)

### 4.1 尺寸限定符

- `BYTE PTR [addr]`: 1 字节 (char)
- `WORD PTR [addr]`: 2 字节 (short)
- `DWORD PTR [addr]`: 4 字节 (int/long)
- `QWORD PTR [addr]`: 8 字节 (long long/指针)

### 4.2 寻址表达式

标准格式：`[base + index * scale + displacement]`

- `mov eax, [rbp - 8]`: 访问局部变量。
- `mov rdx, [rdi + rcx * 8]`: 访问数组元素（rdi 是首地址，rcx 是索引，8 是 size）。

---

## 5. 语法风格差异对照 (Cheat Sheet)

| 特性         | Intel (推荐)      | AT&T (GCC 默认)                     |
| :----------- | :---------------- | :---------------------------------- |
| **GCC 参数** | `-masm=intel`     | `-masm=att`                         |
| **顺序**     | `instr dest, src` | `instr src, dest`                   |
| **寄存器**   | `rax`             | `%rax`                              |
| **立即数**   | `5`               | `$5`                                |
| **内存访问** | `[rax]`           | `(%rax)`                            |
| **内存尺寸** | `DWORD PTR [rax]` | `movl (%rax), %eax` (通过 l,q 后缀) |

---

## 6. 特殊标记与安全

- **RIP-relative addressing**: `[rip + flag]`。现代 64 位代码为了实现 **ASLR (地址空间布局随机化)**，访问全局变量通常基于当前指令指针（RIP）的相对偏移。
- **Endbr64**: 现代 Linux 下函数的第一个指令，用于 **IBT (间接分支跟踪)**，防止非法的跳转攻击。
- **Stack Alignment**: 在 `call` 外部函数之前，栈指针 `RSP` 必须 **16 字节对齐**（这是 ABI 的硬性规定，否则程序会 Segment Fault）。

---

## 7. 分析 `volatile` 的特别提示

1.  **标志位（Flags）**: `test` 或 `cmp` 之后紧跟的 `jne/je` 指令是观察 `volatile` 逻辑的核心。
2.  **原子操作前缀**: 如果你看到 `lock add dword ptr...`，这代表不仅是 volatile，而且是一个**原子加法**。
3.  **屏障（Barriers）**: `mfence`, `lfence`, `sfence` 是真正的硬件内存屏障，`volatile` 本身不会产生这些指令。

rcx -> 天然计数器
