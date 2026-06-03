#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#define LEVEL_NUM 4ULL
#define LEVEL_SIZE 512ULL
#define LEVEL_ void **

static uint64_t level_byte_size() { return LEVEL_SIZE * sizeof(void *); }

static LEVEL_ create_level() { return (LEVEL_)calloc(1, level_byte_size()); }

int main(void) {

  uint64_t total = 0;
  LEVEL_ L1 = create_level();
  total += level_byte_size();
  srand((unsigned int)time(NULL));

  for (size_t i = 0; i < 1000; i++) {
    LEVEL_ current_level = L1;

    void *itemptr = NULL;
    for (size_t j = 0; j < LEVEL_NUM - 1; j++) {
      int rdn = rand() % 512;
      itemptr = current_level[rdn];
      if (itemptr == NULL) {

        LEVEL_ cl = create_level();
        total += level_byte_size();
        itemptr = (void *)cl;
        current_level[rdn] = itemptr;
      }
      current_level = (LEVEL_)itemptr;
    }
  }
  printf("%" PRIu64 "\n", total);
  return 0;
}
