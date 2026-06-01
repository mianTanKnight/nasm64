#include <pthread.h>
#include <stdio.h>

// volatile
long my_lock = 0;
volatile long global_counter = 0;

extern void spin_lock(
    // volatile
    long *lock_ptr);
extern void spin_unlock(
    // volatile
    long *lock_ptr);

void *thread_func(void *arg) {
  for (size_t i = 0; i < 1000000; i++) {
    spin_lock(&my_lock);
    global_counter++;
    spin_unlock(&my_lock);
  }
  return NULL;
}

int main() {
  pthread_t t1, t2, t3, t4;

  pthread_create(&t1, NULL, thread_func, NULL);
  pthread_create(&t2, NULL, thread_func, NULL);
  pthread_create(&t3, NULL, thread_func, NULL);
  pthread_create(&t4, NULL, thread_func, NULL);

  pthread_join(t1, NULL);
  pthread_join(t2, NULL);
  pthread_join(t3, NULL);
  pthread_join(t4, NULL);

  printf("Final Counter = %ld (Expected: 4000000)\n", global_counter);
  return 0;
}