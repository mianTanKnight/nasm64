#ifndef __COMMONUTILS_H__
#define __COMMONUTILS_H__

#include <stdint.h>
#include <stdio.h>
#include <time.h>

// Timing of function execution ns
#define EXEC_FUNC_NSTIME(func)                                                                     \
  ({                                                                                               \
    struct timespec start = {0}, end = {0};                                                        \
    timespec_get(&start, TIME_UTC);                                                                \
    func;                                                                                          \
    timespec_get(&end, TIME_UTC);                                                                  \
    (end.tv_sec - start.tv_sec) * 1000000000LL + (end.tv_nsec - start.tv_nsec);                    \
  })

// Printf Binary
#define PRINTF_BRINAR(v)                                                                           \
  {                                                                                                \
    size_t size_byte = sizeof(v);                                                                  \
    unsigned long long ullv = (unsigned long long)v;                                               \
    for (int i = (size_byte << 3) - 1; i >= 0; --i) {                                              \
      printf("%d", (int)(ullv >> i & 1L));                                                         \
      if (!(i & 7))                                                                                \
        printf(" ");                                                                               \
    };                                                                                             \
    printf("\n");                                                                                  \
  }

#endif /* __COMMONUTILS_H__ */
