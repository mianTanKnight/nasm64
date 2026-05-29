#include <stdio.h>

extern long calculator(long a, long b, int op_code);

int main() {
  long a = 40;
  long b = 10;

  printf("40 + 10 = %ld (Expected: 50)\n", calculator(a, b, 0));
  printf("40 - 10 = %ld (Expected: 30)\n", calculator(a, b, 1));
  printf("40 * 10 = %ld (Expected: 400)\n", calculator(a, b, 2));
  printf("40 & 10 = %ld (Expected: 8)\n", calculator(a, b, 3));
  printf("Default (4) = %ld (Expected: -1)\n", calculator(a, b, 4));

  return 0;
}