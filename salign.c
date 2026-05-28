#include <stdio.h>

struct S {
  char grade;
  long id;
  int age;
};

// 手写汇编 update_student.asm：
// 接收参数：rdi = struct Student* s（结构体首地址）。
// 函数功能：
// 将 grade 修改为 'B'
// 将 id 修改为 2025
// 将 age 修改为 20
// 核心挑战：你必须非常精确地计算出 grade、id、age 距离首地址 rdi
// 的字节偏移量（Offset）。一旦计算错误，就会把相邻的变量覆盖损坏。

extern void update_student(struct S *s);

int main() {
  struct S s = {'A', 1001, 18};
  printf("Before: Grade=%c, ID=%ld, Age=%d\n", s.grade, s.id, s.age);
  update_student(&s);
  printf("After:  Grade=%c, ID=%ld, Age=%d\n", s.grade, s.id, s.age);

  return 0;
}
