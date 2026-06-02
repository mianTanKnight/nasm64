#include <stdio.h>
#include <unistd.h>

extern void test_syscall_registers(unsigned long *out_rcx, unsigned long *out_r11);

int main(void) {
  unsigned long rcx = 0, r11 = 0;
  printf("Executing syscall register  tracking test...\n");

  test_syscall_registers(&rcx, &r11);

  printf("Post-syscall RCX: 0x%016lx\n", rcx);
  printf("Post-syscall R11: 0x%016lx\n", r11);
  return 0;
}