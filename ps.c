#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

// 使用 64 字节对齐，避免 false sharing(cache)
struct S {
  volatile long payload __attribute__((aligned(64)));
  volatile long ready __attribute__((aligned(64)));
} __attribute__((aligned(64)));

// 汇编函数声明
extern void _x86_64_single_slot_publish_data(volatile long *payload_ptr, volatile long *ready_ptr,
                                             long data);
extern long _x86_64_single_slot_consume_data(volatile long *payload_ptr, volatile long *ready_ptr);

void *publisher_thread(void *rags) {
  struct S *s = (struct S *)rags;
  for (long i = 1; i <= 1000000; i++) {
    _x86_64_single_slot_publish_data(&s->payload, &s->ready, i);
  }
  return NULL;
}

void *consumer_thread(void *rags) {
  struct S *s = (struct S *)rags;
  long last_val = 0;
  for (long i = 1; i <= 1000000; i++) {
    long data = _x86_64_single_slot_consume_data(&s->payload, &s->ready);
    if (data == 0) {
      printf("FATAL ERROR: Memory Reordering Detected! Data was 0!\n");
      return NULL;
    }
    last_val = data;
  }
  printf("All data consumed safely. Last value = %ld\n", last_val);
  return NULL;
}

int main() {
  struct S s = {0}; // init S , Avoid UB
  pthread_t t1, t2;
  pthread_create(&t1, NULL, publisher_thread, &s);
  pthread_create(&t2, NULL, consumer_thread, &s);

  pthread_join(t1, NULL);
  pthread_join(t2, NULL);
  return 0;
}