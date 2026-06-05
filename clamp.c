#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ARRAY_SIZE 10000000

extern long clamp_branchless(long val, long min, long max);
extern long clamp_branchless_op(long val, long min, long max);

static volatile long sink;

__attribute__((noinline)) long clamp_branched(long val, long min, long max) {
  if (val < min)
    return min;
  if (val > max)
    return max;
  return val;
}

static double seconds(clock_t start, clock_t end) { return (double)(end - start) / CLOCKS_PER_SEC; }

int main(void) {
  long *test_data = malloc(sizeof(long) * ARRAY_SIZE);
  if (!test_data) {
    perror("malloc");
    return 1;
  }

  srand(42);

  for (int i = 0; i < ARRAY_SIZE; i++) {
    test_data[i] = rand() % 30;
  }

  long min = 10;
  long max = 20;

  long sum1 = 0;
  clock_t start_time = clock();

  for (int i = 0; i < ARRAY_SIZE; i++) {
    sum1 += clamp_branched(test_data[i], min, max);
  }

  clock_t end_time = clock();
  sink = sum1;

  printf("C version:        Time = %.5f seconds, Sum = %ld\n", seconds(start_time, end_time), sink);

  long sum2 = 0;
  start_time = clock();

  for (int i = 0; i < ARRAY_SIZE; i++) {
    sum2 += clamp_branchless_op(test_data[i], min, max);
  }

  end_time = clock();
  sink = sum2;

  printf("ASM branchless:   Time = %.5f seconds, Sum = %ld\n", seconds(start_time, end_time), sink);

  free(test_data);
  return 0;
}