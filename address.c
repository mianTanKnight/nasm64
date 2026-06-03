#include <stdio.h>
// ; 39 - 47 -> PML4
// ; 30 - 38 -> PDPT
// ; 21 - 29 -> PD
// ; 12 - 20 -> PT
// ; 0  - 11 -> offset

struct transform {
  unsigned long PML4;   // 8
  unsigned long PDPT;   // 8
  unsigned long PD;     // 8
  unsigned long PT;     // 8
  unsigned long offset; // 8
};

extern int transform_virtual_address(unsigned long long virtual_address, struct transform *t);

int main(void) {
  struct transform t = {0};
  printf("tsize %zu \n", sizeof(struct transform)); // 40
  printf("sq1 %lld \n", ((unsigned long long)&t.PDPT) - ((unsigned long long)&t.PML4));
  printf("sq2 %lld \n", ((unsigned long long)&t.PD) - ((unsigned long long)&t.PDPT));
  printf("sq3 %lld \n", ((unsigned long long)&t.PT) - ((unsigned long long)&t.PD));
  printf("sq4 %lld \n", ((unsigned long long)&t.offset) - ((unsigned long long)&t.PT));

  int a = 10;
  printf("virtual address  %p\n", (void *)&a);
  transform_virtual_address(((unsigned long long)&a), &t);
  printf("PML4 %ld \n", t.PML4);
  printf("PDPT %ld \n", t.PDPT);
  printf("PD %ld \n", t.PD);
  printf("PT %ld \n", t.PT);
  printf("offset %ld \n", t.offset);
  return 0;
}