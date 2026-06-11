#include "commonutils.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern int sum_i32_sse2(const int *a, size_t n);

#define ARRAY_SIZE 100000

static volatile int sink_int;

__attribute__((noinline)) int sum_sd(const int *a, size_t n) {
  int sum = 0;

  for (size_t i = 0; i < n; i++) {
    sum += a[i];
  }

  return sum;
}

__attribute__((noinline)) void run_sum_sd(const int *a, size_t n) { sink_int = sum_sd(a, n); }

__attribute__((noinline)) void run_sum_sse2(const int *a, size_t n) {
  sink_int = sum_i32_sse2(a, n);
}

int main(void) {
  srand((unsigned int)time(NULL));

  size_t n = ARRAY_SIZE;
  int *array = calloc(n, sizeof(int));

  if (!array) {
    perror("calloc");
    return 1;
  }

  for (size_t i = 0; i < n; i++) {
    array[i] = rand() % 1000;
  }

  long long x = EXEC_FUNC_NSTIME(run_sum_sd(array, n));
  int check1 = sink_int;

  long long x2 = EXEC_FUNC_NSTIME(run_sum_sse2(array, n));
  int check2 = sink_int;

  printf("scalar: %lld ns, sum=%d\n", x, check1);
  printf("sse2:   %lld ns, sum=%d\n", x2, check2);

  free(array);
  return 0;
}