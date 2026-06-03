#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PAGE_SIZE 4096ULL // ULL =  unsigned long long
// 16MB  byte array for mem
#define PHYS_MEM_SIZE (16ULL * 1024 * 1024)

// 页表项地址部分 mask。
// x86-64 页表项低 12 位不是地址，而是 flag。
// 所以物理页框地址在 bit 51..12 附近。
#define PTE_ADDR_MASK 0x000FFFFFFFFFF000ULL

// page flag
#define PTE_P (1ULL << 0)  // 映射是否存在
#define PTE_RW (1ULL << 1) // Read/Write 是否允许写
#define PTE_US (1ULL << 2) // User/Supervisor: 用户态是否允许访问

// VPN : Virtual Page Number
// PPN : Physical Page Number
// PTE : Page Table Entry   VPN -> PPN table
// TLB : Translation Lookaside Buffer  快表，缓存常用的 VPN-PPN 映射，加速地址转换

// v_a split struct
struct VaParts {
  uint64_t pml4;
  uint64_t pdpt;
  uint64_t pd;
  uint64_t pt;
  uint64_t offset;
  uint64_t vpn; // virtual page number
};

// 我们知道一个物理page 是 4kb
// 那么摆在 OS 面前的最大的问题是 怎么找到这一粒度的 page(单位)

// 1: 64位 48位虚拟地址空间中(常用) 存在多少个这样的单位  2^{48} / 2^{12} = 2^{36}
// 使用数组储存 那么需要的大小是 2^{36} * 8(byte) = 512GB
// 这是不可接受的

// 我们现在想象有一个盒子  这个盒子打开之后 有 512 个小盒子, 盒子打开之后 又有 512 个小盒子  有4级
// s1[s2[s3[s4(page)[]]]] page单位 永远是放在第四级 那么我们怎么找到page 单位
// s1 -> 512 * s2 -> 512 * s3  ->  512 * page
// 从数学上说 s1 能表达多少个 page ? 512^{4}
// pml4 -> s1
// pdpt -> s2
// pd  ->  s3
// pt ->  page

// pml4,pdpt,pd,pt 都是偏移量也就是盒子的 index
// 具体可以参考下列代码(对多级表进行真实的内存消耗计算):

// #include <inttypes.h>
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <time.h>
// #define LEVEL_NUM 4ULL
// #define LEVEL_SIZE 512ULL
// #define LEVEL_ void **

// static uint64_t level_byte_size() { return LEVEL_SIZE * sizeof(void *); }
// static LEVEL_ create_level() { return (LEVEL_)calloc(1, level_byte_size()); }

// int main(void) {

//   uint64_t total = 0;
//   LEVEL_ L1 = create_level();
//   total += level_byte_size();
//   srand((unsigned int)time(NULL));

//   for (size_t i = 0; i < 1000; i++) {
//     LEVEL_ current_level = L1;

//     void *itemptr = NULL;
//     for (size_t j = 0; j < LEVEL_NUM - 1; j++) {
//       int rdn = rand() % 512;
//       itemptr = current_level[rdn];
//       if (itemptr == NULL) {

//         LEVEL_ cl = create_level();
//         total += level_byte_size();
//         itemptr = (void *)cl;
//         current_level[rdn] = itemptr;
//       }
//       current_level = (LEVEL_)itemptr;
//     }
//   }
//   printf("%" PRIu64 "\n", total);
//   return 0;
// }

extern void va_split(uint64_t va, struct VaParts *out);

static void dump_va(uint64_t va) {
  struct VaParts p;

  va_split(va, &p);

  printf("[va split]\n");
  printf("  va     = 0x%016" PRIx64 "\n", va);
  printf("  pml4   = %" PRIu64 "\n", p.pml4);
  printf("  pdpt   = %" PRIu64 "\n", p.pdpt);
  printf("  pd     = %" PRIu64 "\n", p.pd);
  printf("  pt     = %" PRIu64 "\n", p.pt);
  printf("  offset = 0x%" PRIx64 "\n", p.offset);
  printf("  vpn    = 0x%" PRIx64 "\n", p.vpn);
}

// TLB entry
// Example:
// VA = 0x00007ffec813f97c
// VPN = VA >> 12 = 0x7ffec813f
// TLB :
// VPN 0x7ffec813f -> PFN 0x200
// Physical Address :
// PFN << 12 | offset(form VA last 12)

struct TLBEntry {
  bool valid; // entry 是否有效
  uint64_t vpn;
  uint64_t pfn;
  uint64_t flags;
};

// mmu

struct MMU {
  unsigned char phys_mem[PHYS_MEM_SIZE];
  // CR3 存的是 PML4 表的物理基地址。
  //
  // 注意：
  //   CR3 里不是虚拟地址。
  //   CR3 里是物理地址。
  uint64_t cr3;
  // 下一个可分配的物理页地址。
  // 这是模拟器自己的简单物理页分配器。
  uint64_t next_free;
  struct TLBEntry tlb;
};

static uint64_t alloc_phys_page(struct MMU *mmu) {
  uint64_t pa = mmu->next_free;
  if (pa + PAGE_SIZE > PHYS_MEM_SIZE) {
    fprintf(stderr, "out of mem");
    exit(1);
  }
  memset(mmu->phys_mem + pa, 0, PAGE_SIZE);
  mmu->next_free = pa + PAGE_SIZE;
  return pa;
}

void mmu_init(struct MMU *mmu) {
  memset(mmu, 0, sizeof(struct MMU));
  mmu->next_free = 0x1000;
  mmu->cr3 = alloc_phys_page(mmu);
}

uint64_t phys_read_u64(struct MMU *mmu, uint64_t entry_pa) {

  if (entry_pa + 8 >= PHYS_MEM_SIZE) {
    fprintf(stderr, "read overflow!");
    exit(1);
  }
  uint64_t v = 0;
  memcpy(&v, mmu->phys_mem + entry_pa, 8);
  return v;
}

void phys_write_u64(struct MMU *mmu, uint64_t entry_pa, uint64_t entry) {
  if (entry_pa + 8 >= PHYS_MEM_SIZE) {
    fprintf(stderr, "writer overflow!");
    exit(1);
  }
  memcpy(mmu->phys_mem + entry_pa, &entry, 8);
}

static void map_page_4k(struct MMU *mmu, uint64_t va_page, uint64_t pa_frame, uint64_t flags) {

  if ((va_page & 0xfff) != 0) {
    fprintf(stderr, "map_page_4k: va_page must be 4KB aligned\n");
    exit(1);
  }

  if ((pa_frame & 0xfff) != 0) {
    fprintf(stderr, "map_page_4k: pa_frame must be 4KB aligned\n");
    exit(1);
  }
  struct VaParts p;
  va_split(va_page, &p);

  printf("[map]\n");
  printf("  map VA page 0x%" PRIx64 " -> PA frame 0x%" PRIx64 "\n", va_page, pa_frame);

  uint64_t table_pa = mmu->cr3;

  uint64_t indexes[4] = {p.pml4, p.pdpt, p.pd, p.pt};
  const char *names[4] = {"PML4E", "PDPTE", "PDE", "PTE"};

  for (size_t level = 0; level < 3; level++) {

    // 这里算出了一层的物理地址 (但不是最终层)
    uint64_t entry_pa = table_pa + indexes[level] * 8;
    // 直接读物理内存
    uint64_t entry = phys_read_u64(mmu, entry_pa);

    if ((entry & PTE_P) == 0) {
      uint64_t new_table = alloc_phys_page(mmu);
      entry = new_table | PTE_P | PTE_RW | PTE_US;
      phys_write_u64(mmu, entry_pa, entry);
      printf("  create %-5s at PA 0x%06" PRIx64 " -> next table PA 0x%06" PRIx64 "\n", names[level],
             entry_pa, new_table);
    } else {
      printf("  reuse  %-5s at PA 0x%06" PRIx64 " = 0x%016" PRIx64 "\n", names[level], entry_pa,
             entry);
    }

    // 进入下一级页表。
    //
    // 低 12 位是 flags，不是地址。
    // 所以必须 mask 掉低 12 位。
    table_pa = entry & PTE_ADDR_MASK;
  }

  // 最后一级：写 PTE。
  // PTE 指向真正的数据物理页。
  uint64_t pte_pa = table_pa + indexes[3] * 8;

  uint64_t pte = pa_frame | flags | PTE_P;

  phys_write_u64(mmu, pte_pa, pte);
  printf("  write  %-5s at PA 0x%06llx -> frame PA 0x%06llx flags=0x%llx\n", names[3],
         (unsigned long long)pte_pa, (unsigned long long)pa_frame,
         (unsigned long long)(flags | PTE_P));
}

static bool tlb_lookup(struct MMU *m, uint64_t va, uint64_t *pa_out) {
  struct VaParts p;

  va_split(va, &p);

  if (!m->tlb.valid) {
    printf("[tlb] miss: entry invalid\n");
    return false;
  }

  if (m->tlb.vpn != p.vpn) {
    printf("[tlb] miss: vpn mismatch, want=0x%" PRIx64 ", cached=0x%" PRIx64 "\n", p.vpn,
           m->tlb.vpn);
    return false;
  }

  // TLB hit。
  //
  // 物理地址 = PFN << 12 | offset
  //
  // offset 不需要翻译。
  *pa_out = (m->tlb.pfn << 12) | p.offset;

  printf("[tlb] hit: vpn=0x%" PRIx64 " -> pfn=0x%" PRIx64 ", pa=0x%" PRIx64 "\n", p.vpn, m->tlb.pfn,
         *pa_out);

  return true;
}

int main(void) {

  struct MMU *mmu = (struct MMU *)calloc(1, sizeof(struct MMU));
  if (!mmu) {
    perror("Calloc error");
    return 1;
  }
  mmu_init(mmu);

  // 选一个 canonical 的用户态虚拟地址。
  // 这是我们模拟的虚拟地址，不是当前进程真实地址。
  uint64_t va = 0x00007ffec813f97cULL;

  // 4KB 页对齐后的虚拟页基址。
  uint64_t va_page = va & ~0xfffULL;

  // 选一个模拟物理页框。
  //
  // 必须 4KB 对齐。
  uint64_t pa_frame = 0x00200000ULL;

  printf("\n");
  dump_va(va);

  printf("\n");

  // 模拟 OS 建立映射：
  //   va_page -> pa_frame
  // 权限：
  //   Present 会在 map_page_4k 内部自动加
  //   RW = 可写
  //   US = 用户态可访问
  map_page_4k(mmu, va_page, pa_frame, PTE_RW | PTE_US);

  printf("\n");
  return 0;
}
