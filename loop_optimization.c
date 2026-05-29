#include <stdio.h>

// 汇编函数声明：
// 计算并返回 8 字节有符号整型数组的所有元素之和
// 假设输入参数 len 永远是 2 的倍数（且大于 0）
extern long sum_array_unrolled_8(const long *arr, long len);

int main() {
  long my_array[] = {10, -20, 30, 40, -50, 60, 70, 80}; // 8 个元素
  long len = 8;

  long total = sum_array_unrolled_8(my_array, len);
  printf("Sum = %ld (Expected: 220)\n", total);

  return 0;
}