#include <stdio.h>

struct S {
  char a;
  int b;
  char c;
  long d;
};

struct S1 {
  char grade;
  long id;
  int age;
};

struct S2 {
  char grade;
  int age;
  long id;
};

struct S3 {
  long id;
  char grade;
  int age;
};

// 注意  S1, S2, S3 只是顺序不同 但struct 的大小是不一样的 24/16/16
// 证明对齐是顺序计算 最后补充

// struct S 是 24
// 对齐要求有两个点 ：1: 满足自身对齐 2: 满足结构体对齐(结构体要对齐8)
// a align 1
// -- padding 3
// b align 4
// -- padding 0
// c align 1
// -- padding 7
// d align 8

// S align 8 = 24

int main(void) {
  unsigned s = sizeof(struct S);
  unsigned ls = sizeof(long);
  printf("ls : %d \n", ls);
  printf("s: %d \n", s);
  printf("s1: %ld, s2: %ld, s3: %ld \n", sizeof(struct S1), sizeof(struct S2), sizeof(struct S3));
  return 0;
}