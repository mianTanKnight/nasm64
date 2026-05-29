#include <stdio.h>

extern void modify_via_dp(int **ptr_to_ptr);

int main() {
  int target = 100;
  int *sp = &target;
  int **dp = &sp;
  printf("Before: target = %d\n", target);
  // 传入二级指针的地址
  modify_via_dp(dp);
  printf("After:  target = %d\n", target); // 应当输出 500

  return 0;
}