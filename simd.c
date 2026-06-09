#include <stdio.h>

extern void vadd4(int *a, const int *b);

// 1. 每次 SIMD 处理 4 个 int
// 2. 剩下不足 4 个的元素，用标量尾部处理
// 3. 允许 a 和 b 不一定 16 字节对齐
// 4. 所以先使用 movdqu，不使用 movdqa
extern void vadd_i32_sse2(int *a, const int *b, size_t n);
extern void vadd_i32_sse2_qa(int *a, const int *b, size_t n);

static void print_array(const char *name, const int *x, size_t n) {
  printf("%s = [", name);
  for (size_t i = 0; i < n; i++) {
    printf("%d", x[i]);
    if (i + 1 != n) {
      printf(", ");
    }
  }
  printf("]\n");
}

int main(void) {
  int a[] = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110};
  int b[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};

  printf("a address :%p \n", a);
  printf("a is align of 16 ? -> %lld \n", (long long)a & 0xF);
  printf("b address :%p \n", b);
  printf("b is align of 16 ? -> %lld \n", (long long)b & 0xF);

  _Alignas(16) int a1[] = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110};
  _Alignas(16) int b1[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};

  printf("a1 address :%p \n", a1);
  printf("a1 is align of 16 ? -> %lld \n", (long long)a1 & 0xF);
  printf("b1 address :%p \n", b1);
  printf("b1 is align of 16 ? -> %lld \n", (long long)b1 & 0xF);

  // a2 / b2 不会对齐 16
  int *a2 = a + 1;
  int *b2 = b + 1;

  printf("a2 address :%p \n", a2);
  printf("a2 is align of 16 ? -> %lld \n", (long long)a2 & 0xF);
  printf("b2 address :%p \n", b2);
  printf("b2 is align of 16 ? -> %lld \n", (long long)b2 & 0xF);

  size_t n = sizeof(a) / sizeof(a[0]);
  // vadd_i32_sse2(a, b, n);
  // print_array("a", a, n);

  // 测试不对齐
  vadd_i32_sse2(a2, b2, n - 1);
  print_array("a2", a2, n - 1);

  // output:
  // a address :0x7ffffa1c8ed0
  // a is align of 16 ? -> 0
  // b address :0x7ffffa1c8f00
  // b is align of 16 ? -> 0
  // a1 address :0x7ffffa1c8f30
  // a1 is align of 16 ? -> 0
  // b1 address :0x7ffffa1c8f60
  // b1 is align of 16 ? -> 0
  // a2 address :0x7ffffa1c8ed4
  // a2 is align of 16 ? -> 4
  // b2 address :0x7ffffa1c8f04
  // b2 is align of 16 ? -> 4
  // a2 = [22, 33, 44, 55, 66, 77, 88, 99, 110, 121]
  // 我们发现不对使用 qu 也能处理

  vadd_i32_sse2_qa(a2, b2, n - 1);
  print_array("a2", a2, n - 1);

  // output:
  // a address :0x7ffc1cc27f50
  // a is align of 16 ? -> 0
  // b address :0x7ffc1cc27f80
  // b is align of 16 ? -> 0
  // a1 address :0x7ffc1cc27fb0
  // a1 is align of 16 ? -> 0
  // b1 address :0x7ffc1cc27fe0
  // b1 is align of 16 ? -> 0
  // a2 address :0x7ffc1cc27f54
  // a2 is align of 16 ? -> 4
  // b2 address :0x7ffc1cc27f84
  // b2 is align of 16 ? -> 4
  // a2 = [22, 33, 44, 55, 66, 77, 88, 99, 110, 121]
  // [1]    3158216 segmentation fault (core dumped)  ./simd
  // 出现了段错误

  return 0;
}