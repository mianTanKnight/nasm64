#include <stdio.h>
#include <stdlib.h>

// alpha = α
// C[i] = A[i] * α + B[i](1.0 - α)
// 0.0 <= a <= 1.0
extern void osb_vblend_f32(float *restrict c, const float *restrict a, const float *restrict b,
                           float alpha, size_t n);

int main(void) {

  // 11 个测试像素（故意不对齐 4 的倍数）
  float a[] = {100.0f, 150.0f, 200.0f, 50.0f, 80.0f, 120.0f, 250.0f, 10.0f, 90.0f, 180.0f, 30.0f};
  float b[] = {50.0f, 100.0f, 100.0f, 150.0f, 200.0f, 80.0f, 50.0f, 210.0f, 10.0f, 40.0f, 130.0f};
  size_t n = sizeof(a) / sizeof(a[0]);

  float *c = malloc(sizeof(float) * n);
  float alpha = 0.6f; // 前景权重 60%，背景权重 40%

  osb_vblend_f32(c, a, b, alpha, n);

  printf("Blended Pixels: \n  [");
  for (size_t i = 0; i < n; i++) {
    printf("%.1f", c[i]);
    if (i + 1 != n)
      printf(", ");
  }
  printf("]\n");
  // 正确输出应当是：
  // [80.0, 130.0, 160.0, 90.0, 128.0, 104.0, 170.0, 90.0, 58.0, 124.0, 70.0]

  free(c);
  return 0;
}