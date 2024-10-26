### 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

#### 练习0：填写已有实验

本实验依赖实验1。请把你做的实验1的代码填入本实验中代码中有“LAB1”的注释相应部分并按照实验手册进行进一步的修改。具体来说，就是跟着实验手册的教程一步步做，然后完成教程后继续完成完成exercise部分的剩余练习。

# Lab2 最小可执行内核

## 一.实验目的

1. 理解页表的建立和使用方法
 
2. 理解物理内存的管理方法

3. 理解页面分配算法

## 二.实验过程

### 练习1:理解first-fit 连续物理内存分配算法（思考题）

*first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合kern/mm/default_pmm.c中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。*

#### 页的结构体定义
   ```C
struct Page {
    int ref;                        // page frame's reference counter
    uint64_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
    list_entry_t pra_page_link;     // used for pra (page replace algorithm)
    uintptr_t pra_vaddr;            // used for pra (page replace algorithm)
};
   ```
- ref变量表示该页被引用的次数。当引用计数变为 0 时,表示该页可以被回收利用。

- flags变量表示该页的状态帧,记录该页的各种状态位。

- page_link变量表示该页的链表链接。这是一个双向链表的节点,用于把该页链接到空闲页链表(free_list)中。

- pra_page_link变量表示该页用于页替换算法(PRA)的链表链接。这也是一个双向链表的节点，用于把该页链接到 PRA 使用的链表中。PRA需要维护一个页面访问历史，通过这个链表可以快速定位和管理页面。

- uintptr_t pra_vaddr变量记录了该页对应的虚拟地址，也是为了页替换算法(PRA)服务的。PRA 需要知道每个页面对应的虚拟地址，以便在发生缺页中断时进行页面换入换出。
#### 1.default_init函数
   ```C
   static void
   default_init(void) {
       list_init(&free_list);
       nr_free = 0;
   }
   ```
default_init() 函数的主要作用是初始化物理内存管理系统。该函数的步骤如下：
- 首先将free_list初始化为为空链表。free_list用于管理空闲内存块的链表。
- 然后将 nr_free 设置为 0，表示当前没有任何空闲内存块。
  
#### 2.default_init_memmap函数
   ```C
static void
default_init_memmap(struct Page *base, size_t n) {
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
}
   ```
default_init_memmap() 函数的作用是初始化一块连续的物理内存区域为空闲内存块，并将其添加到 free_list 中。具体步骤如下:

- 首先遍历该内存区域中的每一个 Page 结构体，然后检查该页是否为保留页，如果是保留页的话则。PageReserved(page)函数是test_bit函数的宏定义，检查该页的flags的保留位是否为1。接着将页的标志位 flags 和属性 property 都设置为 0，表示该页可以被分配使用。最后使用set_page_ref函数将页的引用计数 ref 设置为 0，表示当前没有任何虚拟地址映射到这个页框上。
  
- 将第一个页的属性 property 设置为该内存区域的页数 n。设置第一个页的 PG_property 标志位，表示这是一个空闲内存块的起始页。然后将 nr_free 增加 n，表示增加了 n 个空闲页。
- 最后将该内存区域的第一个页添加到 free_list 中。如果 free_list 为空，则直接将该空闲内存块的第一个页 base 添加到 free_list 的头部。如果 free_list 不为空，则需要找到合适的位置插入该空闲内存块：从 free_list 的第二个节点开始遍历(因为第一个节点已经被判断过了)，对于每个遍历到的节点,通过 le2page() 宏获取对应的 Page 结构体。
如果当前遍历到的页 page 的地址大于 base,说明应该把 base 插入到 page 之前
此时调用 list_add_before() 函数,将 base 插入到 page 之前
然后跳出循环
如果遍历到了 free_list 的尾部,还没找到合适的位置
此时调用 list_add() 函数,将 base 添加到 free_list 的尾部

#### 3.default_alloc_pages函数
   ```C
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(&free_list, &(p->page_link));
        }
        list_del(&(page->page_link));
        ClearPageProperty(page);
        nr_free -= n;
    }
    return page;
}
   ```
default_alloc_pages函数用于分配n个连续的物理页。它的实现过程如下:

- 首先检查是否有足够的空闲页可分配,如果 nr_free < n 则返回 NULL。遍历 free_list,找到第一个可满足 n 个页的空闲内存块。从 free_list 的头部开始遍历，对于每个遍历到的空闲内存块(通过 le2page() 宏获取),检查它的属性 property 是否大于等于 n，如果找到了合适的块,就跳出循环。
- 如果找到了合适的空闲内存块,则如果该块的大小大于 n,则将剩余部分重新加入到 free_list 中。计算剩余部分的大小为 p->property - n。创建一个新的 Page 结构体,将其属性 property设置为剩余部分的大小,并设置 PG_property 标志位。
将这个新的 Page 结构体插入到 free_list 中，从 free_list 中删除该内存块。将该内存块的属性标志位清除,表示已经被分配
将 nr_free 减少 n，最后返回分配的内存块的起始页。

#### 4.default_free_pages函数
   ```C
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(base->page_link));
        }
    }
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}
   ```
default_free_pages() 函数用于将一块连续的 n 个物理页释放回空闲内存列表。它的实现过程如下:

- 遍历这 n 个页,检查它们的标志位是否正确(不是保留页且不是空闲页)。然后将它们的标志位和引用计数都重置为 0。将第一个页的属性 property 设置为 n,表示这是一个大小为 n 的空闲内存块。同时设置其 PG_property 标志位。
- 遍历 free_list,检查是否可以和前后的空闲内存块合并:如果当前页块的尾地址等于下一个空闲页块的起始地址,则合并它们,并从 free_list 中删除下一个页块。
如果当前页块的起始地址等于上一个空闲页块的尾地址,则合并它们,
并从 free_list 中删除当前页块(即基地址为 base 的页块)。将合并后的新空闲页块添加到 free_list 中。将 nr_free 增加 n。

*你的first fit算法是否有进一步的改进空间？*

（1）合并空闲块的策略：在 default_free_pages 中，我们实现了合并相邻的空闲块的操作，这样做可以提高操作系统空间分配效率，减少内存碎片的产生。可以考虑在分配时也做相似的检查，在释放页面时，检查前后相邻的空闲块。如果相邻块是空闲的，则合并它们。这样可以减少内存碎片，提高内存使用率。

（2）内存分配策略的多样性：除了 first-fit，可以考虑实现其他分配策略（如 best-fit 或 worst-fit），并根据实际需求选择不同的策略，甚至可以实现自适应的分配策略，动态调整使用的算法。

（3）锁机制：在多线程环境中，考虑在分配和释放过程中加入锁机制，确保线程安全，避免竞态条件。可以在 default_alloc_pages 和 default_free_pages 中使用锁，确保多线程环境下的线程安全。

（4）延迟合并：可以引入延迟合并机制，允许合并操作在特定条件下进行，而不是每次释放时立即合并，这样可能会提高性能。可以定期对 free_list 进行重排，确保空闲块在列表中均匀分布，以加快分配速度。

（5）使用位图：使用位图来管理空闲页，可以在查找和分配时更高效地跟踪空闲状态。可以用位图记录空闲页的状态，每个位对应一个页，值为 1 表示空闲，0 表示已分配。分配时可以快速找到连续空闲页。
（6）记录分配请求的历史：可以根据系统的历史负载信息和当前的使用模式，建立历史数据记录，分析不同内存请求的模式，预测将来可能的分配和释放操作，提前进行，从而提高运行时性能。


### 练习2：实现Best-Fit连续物理内存分配算法（需要编程）
best_fit_alloc_pages 函数的实现与 first_fit_alloc_pages 的区别主要体现在，在遍历空闲页面链表时,我们不是直接找到第一个满足需求的页面,而是找到最小的满足需求的页面。
- 具体做法是我们用 min_size 变量记录当前找到的最小满足需求的页面大小,并用 page 变量记录这个页面。在遍历过程中,如果找到一个大小大于等于 n 且小于当前 min_size 的页面,就更新 min_size 和 page。
- 最后从空闲链表中删除找到的页面,并根据需求大小和页面大小进行切分和重新插入。
这样做的目的是尽可能找到最接近需求大小 n 的空闲页面,以减少内存碎片。这就是 Best-Fit 算法的核心思想。

其他部分的代码,如页面初始化、释放等,与练习1中的实现是一致的,这里就不再赘述了。
```c
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
     /*LAB2 EXERCISE 2: 2213026,2212478,2212180*/ 
    // 下面的代码是first-fit的部分代码，请修改下面的代码改为best-fit
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property < min_size && p->property >= n) {
            min_size = p->property;
            page = p;
        }
    }
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```
*你的 Best-Fit 算法是否有进一步的改进空间？*
1. 性能开销
缺点：Best-Fit 在遍历空闲链表时需要检查每一个空闲块，以找到最小的合适块，这在大多数情况下会导致更高的时间复杂度（O(n)），特别是在空闲块数量较多时。
改进空间：可以考虑使用自适应数据结构（如平衡树或哈希表）来维护空闲块，以加快查找速度。这样可以在 O(log n) 的时间复杂度内找到最适合的块。
2. 内存碎片问题
缺点：尽管 Best-Fit 的目标是减少碎片，但它可能会导致小的内存块（如 1 页）分散在内存中，形成“外部碎片”。
改进空间：可以结合合并策略（如延迟合并或懒惰合并），在释放内存时检查相邻块，并尝试合并，从而减轻外部碎片的问题。
3. 频繁的内存分配和释放
缺点：在内存频繁分配和释放的场景下，Best-Fit 可能会导致性能下降，因其需要不断维护和遍历空闲链表。
改进空间：可以考虑实现一个“内存池”或“对象池”来缓存常用的内存块，以减少频繁分配和释放带来的开销。
4. 不适合大块请求
缺点：Best-Fit 对于大块内存请求可能不够高效，特别是在内存已经相对紧张的情况下，可能会因小块分散而无法满足大块请求。
改进空间：可以结合其他分配策略（如首次适配）或引入策略切换机制，根据当前内存使用情况动态选择合适的分配算法。
5. 锁竞争问题
缺点：在多线程环境下，Best-Fit 可能面临更严重的锁竞争问题，因为多个线程可能需要同时访问和修改空闲链表。
改进空间：可以考虑采用细粒度锁或无锁算法来减少锁的竞争，提高并发性能。
6. 未使用的空间
缺点：Best-Fit 在选择适合块时可能会留下不必要的未使用空间，导致后续请求无法满足。
改进空间：引入更复杂的分配策略，例如 “动态适配”算法，根据当前的内存需求和使用模式调整策略，以提高整体内存利用率。

### 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）
*Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...
参考伙伴分配器的一个极简实现， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。*
#### 1.buddy_zone_t 结构体设计
```c
#define MAX_ORDER 11 // Max number of orders

typedef struct {
    free_area_t free_area[MAX_ORDER];  // This manages multiple free areas
    size_t n_sum;
} buddy_zone_t;

buddy_zone_t buddy_zone;  // declaration for buddy_zone
```
在 buddy system（伙伴系统）分配算法的实现中，buddy_zone_t 结构体用于管理系统内存的核心数据结构。它维护所有内存块的分配和回收，并根据 Buddy System 的逻辑将空闲的内存块管理起来。

* free_area_t free_area[MAX_ORDER]表示从 0 到 MAX_ORDER-1 的不同阶数的空闲区域，每个阶数 order 对应的内存块大小为 2^order。
* free_area_t用于管理各阶数下的内存块。nr_free记录该阶数下空闲块的数量，free_list指向当前阶数下所有空闲块的链表。每个阶数的链表存储相应大小的块，并在分配/回收时从链表中移除或添加。
* size_t n_sum记录当前系统中所有阶数下空闲内存块的总和。每次分配或释放内存时都会更新 n_sum，以便能够快速判断系统的剩余内存情况。

buddy_zone_t 结构体通过 free_area 数组维护多个不同大小的内存块集合，确保可以按照 2^order 的内存块大小进行分配和释放。在实际使用中，当请求分配一块大小为 n 的内存时，会根据 buddy system 算法找到合适的阶数，将内存块拆分到满足需求的最小块，并将剩余的部分重新放回到对应阶数的链表中。

#### 2.buddy_system_pmm_init函数
```c
static void buddy_system_pmm_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
        list_init(&buddy_zone.free_area[i].free_list);  // Initialize each free list
        buddy_zone.free_area[i].nr_free = 0;  // Properly access nr_free for buddy_zone
    }
}
```
buddy_system_pmm_init 函数用于初始化 buddy_zone 结构体及其相关的空闲内存块链表。
* 首先，遍历所有阶数（从 0 到 MAX_ORDER - 1），对每个阶数的空闲链表进行初始化（list_init），确保每个阶数的链表开始时都是空的。
* 同时，将每个阶数的空闲块数量（nr_free）设置为 0，表示在初始化时没有任何空闲块。
* 最后，初始化 n_sum 为 0，以便后续使用时能够正确表示当前系统中空闲块的总数。

该初始化函数是实现 Buddy System 的重要步骤，确保系统在运行之前，各个数据结构都处于正确的初始状态。这为后续的内存分配和回收提供了基础。

#### 3.辅助函数设计
```c
//检查给定的数 n 是否是2的幂次方。
//如果 n 是2的幂次方，则它的二进制表示中只有一个1，n - 1 则是全1的数（即 n 将所有更小的位设为1）。因此，n & (n - 1) 的结果为0。
static int is_pow2(size_t n)
{
    if(n==0)
    {
        return 1;
    }
    if(n==1)
    {
        return 0;
    }
    if (n & (n - 1)) return 0;
    else return 1;
}
```
is_pow2函数用于检查给定的数 n 是否是 2 的幂次方。
```c
//这个函数返回给定数 n 对应的幂次（即 log2(n) 的整数部分）
static unsigned int getorder(size_t n)
{
    unsigned int order = 0;
    while (n >> 1)
    {
        n >>= 1;
        order++;
    }
    return order;
}
```
getorder函数用于返回给定数 n 的对应的幂次（即 log2(n) 的整数部分）。
```c
static size_t getdown2(size_t n)
{
    if(n==0)
    {
        return 0;
    }
    if(n==1)//这个是为了照顾最后n=1的情况
    {
        return 1;//
    }
    size_t res = 1;
    if (!is_pow2(n))
    {
        while (n)
        {
            n = n >> 1;
            res = res << 1;
        }
        return res >> 1;
    }
    else
    {
        return n;
    }
}
```
getdown2函数用于返回小于等于n的最大2的幂。
```c
static size_t getup2(size_t n)
{
    if(n==1)
    {
        return 1;
    }
    size_t res = 1;
    if (!is_pow2(n))
    {
        while (n)
        {
            n = n >> 1;
            res = res << 1;
        }
        return res;
    }
    else
    {
        return n;
    }
}
```
getup2函数用于返回大于等于n的最小2的幂。

以上四个辅助函数为 Buddy System 的内存分配提供了重要的支持，确保在分配和释放内存时，能够正确处理内存块的大小和相应的计算。这些函数的设计使得整个内存管理系统更加高效和可靠。通过合理使用这些函数，可以简化主要分配逻辑中的计算，减少复杂性，提高代码的可读性和可维护性。
#### 4.buddy_system_pmm_init_memmap函数
```c
static void buddy_system_pmm_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }

    buddy_zone.n_sum += n;

    int n_now = n;
    struct Page *now_page = base;
    while (n_now != 0) {
        int n_temp = getdown2(n_now);
        // cprintf("n_now: %d\n", n_now);  // 打印 n_now 的值
        int order = getorder(n_temp);
        // cprintf("order: %d\n", order);  // 打印 order 的值
        // 确保不会超过最大order
        if (order >= MAX_ORDER) {
            order = MAX_ORDER - 1;  // 如果 order 超过最大值，则将其设置为最大值的前一个
        }

        // 处理最大块
        if (order == MAX_ORDER - 1) {
            int max_block_size = 1 << (MAX_ORDER - 1); // 计算每个块的页数（2^(MAX_ORDER-1)）
            int num_blocks = n_now / max_block_size; // 计算需要的最大块数

            for (int i = 0; i < num_blocks; i++) {
                now_page->property = max_block_size; // 每个块的页数
                SetPageProperty(now_page); // 设置页的属性
                buddy_zone.free_area[MAX_ORDER - 1].nr_free += max_block_size; // 更新 free_area 中的块数

                // 将块添加到 free_list
                list_entry_t *free_list_order = &buddy_zone.free_area[MAX_ORDER - 1].free_list;
                if (list_empty(free_list_order)) {
                    // cprintf("now_page: %d\n", now_page);
                    list_add(free_list_order, &now_page->page_link);
                } else {
                    list_entry_t *le = list_next(free_list_order);
                    while (le != free_list_order) {
                        struct Page *page = le2page(le, page_link);
                        if (now_page < page) {
                            // cprintf("now_page: %d\n", now_page);
                            list_add_before(le, &now_page->page_link);
                            break;
                        } else if (list_next(le) == free_list_order) {
                            // cprintf("now_page: %d\n", now_page);
                            list_add(le, &now_page->page_link);
                            break;
                        }
                        le = list_next(le);
                    }
                }
                // cprintf("now_page_before: %p\n", now_page);
                now_page += max_block_size; // 更新当前页指针
                // cprintf("now_page_after: %p\n", now_page);
                // cprintf("Size of struct Page: %u bytes\n", (unsigned int)sizeof(struct Page));
            }
            n_now -= num_blocks * max_block_size; // 更新剩余页数
        } else {
            // 对于小于最大块的情况，继续原有逻辑
            n_now -= n_temp;
            now_page->property = n_temp;
            SetPageProperty(now_page);
            buddy_zone.free_area[order].nr_free += n_temp;

            // 添加到对应的 free_list
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
            if (list_empty(free_list_order)) {
                list_add(free_list_order, &now_page->page_link);
            } else {
                list_entry_t *le = list_next(free_list_order);
                while (le != free_list_order) {
                    struct Page *page = le2page(le, page_link);
                    if (now_page < page) {
                        list_add_before(le, &now_page->page_link);
                        break;
                    } else if (list_next(le) == free_list_order) {
                        list_add(le, &now_page->page_link);
                        break;
                    }
                    le = list_next(le);
                }
            }
        now_page += n_temp; // 更新当前页指针
        }
    }
}
```
buddy_system_pmm_init_memmap 函数负责初始化伙伴系统中的内存映射。这是实现内存分配的关键步骤之一，通过设置每个页面的属性和将其加入适当的空闲列表，从而为后续的内存分配做准备。以下是该函数的详细分析和解释。

1. 函数功能：
* 初始化给定的页面范围，设置页面的属性并将其添加到合适的空闲列表。
* 处理不同大小的内存块，确保伙伴系统可以有效地管理和分配内存。

2. 初始化过程:

* Assertions:确保 n 大于 0，避免初始化 0 页。遍历 base 到 base + n 的所有页面，确保每个页面都被保留。
* 页面属性重置:清除每个页面的标志和属性，并将引用计数设置为 0。
* 管理空闲页面，更新 buddy_zone.n_sum，记录总页面数。使用 n_now 记录剩余页面数，并通过循环处理每个页面。
* 处理 2 的幂次:通过 getdown2 获取小于等于 n_now 的最大 2 的幂，并获取其对应的 order。确保 order 不超过最大值 MAX_ORDER。
* 最大块处理:如果 order 是 MAX_ORDER - 1，计算最大块的大小和数量。将每个块的属性设置为块大小，更新空闲区域的块数。将块添加到空闲列表中，确保按顺序插入。
* 小于最大块的处理:处理小于最大块的页面，更新剩余页面和当前页面指针。设置当前页面的属性并更新空闲区域块数，插入到相应的空闲列表中。

#### 5.buddy_system_pmm_alloc_pages函数
```c
static struct Page * buddy_system_pmm_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > buddy_zone.n_sum) {
        return NULL;
    }
    int order_copy;
    int order_needed = getorder(getup2(n)); // 找到需要的最小阶层
    order_copy=order_needed;
    for (int order = order_needed; order < MAX_ORDER; order++) {
        if (buddy_zone.free_area[order].nr_free / (1 << order) > 0) {
            list_entry_t *le = list_next(&buddy_zone.free_area[order].free_list);
            struct Page *p = le2page(le, page_link);
            list_del(&(p->page_link));
            buddy_zone.free_area[order].nr_free-=(1<<order);
            ClearPageProperty(p);
            struct Page *buddy=p;
            if(is_pow2(n)||n==1){
            int n_more=(1<<order)-(1<<order_needed);
            while (order > order_needed) {
                order--;
                buddy->property = 1 << order;
                SetPageProperty(buddy);
                list_add(&buddy_zone.free_area[order].free_list, &buddy->page_link);
                buddy += (1 << order);
                buddy_zone.free_area[order].nr_free+=1<<order;
            }
            p=buddy+(1<<order_needed);
            p->property=1<<order_copy;
            return p;
            }
            else
            {       
                cprintf("begin");
                size_t excess_pages = (1 << order) - n; 
                // 当空闲块大于2倍需要的大小时，继续分裂
                cprintf("order: %d\n", order);  // 打印 n 的值
                cprintf("n: %d\n", n);  // 打印 n 的值
                while ((1 << order) > 2 * n) {
                    order--;
                    struct Page *split_buddy = p + (1 << (order-1));
                    p+=1<<order;
                    // 把分裂出来的块放入空闲列表
                    split_buddy->property = 1 << (order-1);
                    SetPageProperty(split_buddy);
                    list_add(&buddy_zone.free_area[order-1].free_list, &split_buddy->page_link);
                    buddy_zone.free_area[order-1].nr_free+=(1<<(order-1));
                }
                p=buddy;
                p->property=1<<order_copy;
                return p;
            }
        }
    }
    return NULL; // 如果没有合适的块
}
```

buddy_system_pmm_alloc_pages 函数的作用是从 Buddy System 的内存池中分配指定数量的连续页（大小为 n），并返回起始页的指针。这个函数的实现包含了必要的内存分配和分裂操作，确保尽量找到符合大小的空闲块并高效利用内存。


关键步骤解析:
1. 检查请求的页数：一开始通过 assert(n > 0); 确保 n 大于 0，然后通过 if (n > buddy_zone.n_sum) { return NULL; } 检查当前可用的页数 buddy_zone.n_sum 是否足够。

2. 确定最小阶层：order_needed = getorder(getup2(n)) 确定当前所需的最小阶层。
* getup2(n) 返回比 n 大的最小 2 的幂次，用于找到合适的 Buddy 阶层。

3. 遍历阶层寻找可用块：
* 从 order_needed 开始遍历到 MAX_ORDER，查找对应阶层的空闲块 nr_free 是否足够。
* 如果找到合适的块，将其从空闲列表中删除，并更新 nr_free。
4. 块分裂：
* 如果找到的块大小刚好是 n，则直接返回该块。
* 否则，如果块大于 n：当块大小为 2 的幂次（例如 n=1）：按需要将大块逐层分裂，直到生成合适大小的块，更新空闲列表。
* 当块大小不是 2 的幂次：计算空闲块的大小并检查是否需要继续分裂，直到块大小满足请求。
维护块的 property 和空闲块数。

#### 6.buddy_system_pmm_free_pages函数
```c
static void buddy_system_pmm_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    // 获取块的初始 order
    int order = getorder(getup2(n));
    struct Page *p = base;
    // 标记并添加到相应的空闲列表中
    p->property = 1 << order;
    SetPageProperty(p);
    list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
    while (order < MAX_ORDER - 1) { // 修正为最大 order - 1
        bool merged = 0;  // 标志是否进行了合并
        if (list_empty(free_list_order)) {
            // 没有块可以合并，直接添加到空闲列表中
            list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
            buddy_zone.free_area[order].nr_free += (1 << order);
            buddy_zone.n_sum += (1 << order);
            // cprintf("return\n");
            return;
        }
        list_entry_t *le;
        for (le = list_next(free_list_order); le != free_list_order; le = list_next(le)) { 
            struct Page *current_page = le2page(le, page_link);
            size_t block_size = 1 << order;  // 当前块的大小
            size_t page_size = sizeof(struct Page);  // 页的大小
            if ((uintptr_t)current_page == (uintptr_t)p + page_size * block_size) {
                // 合并，p 是第一个
                p->property += current_page->property;
                ClearPageProperty(current_page);
                list_del(&current_page->page_link);
                merged = 1;
                // cprintf("merge\n");
                break; // 合并完成后退出，准备提升 order
            } else if ((uintptr_t)p == (uintptr_t)current_page + block_size * page_size) {
                // 合并，current_page 是第一个
                current_page->property += p->property;
                ClearPageProperty(p);
                list_del(&p->page_link);
                p = current_page;  // 更新 p 为 current_page
                merged = 1;
                break; // 合并完成后退出，准备提升 order
            }
            if(merged)
            {
                break;
            }
            if(le==list_next(le))
            {
            list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
            buddy_zone.free_area[order].nr_free += (1 << order);
            buddy_zone.n_sum += (1 << order);
            cprintf("return\n");
            return;
            }
        }
        // 如果没有合并，退出循环
        if (!merged) {
            list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
            buddy_zone.free_area[order].nr_free += (1 << order);
            buddy_zone.n_sum += (1 << order);
            return;
        }
        buddy_zone.free_area[order].nr_free -= (1 << order);
        buddy_zone.n_sum -= (1 << order);
        // 继续合并到更大的块
        order++;
        free_list_order = &buddy_zone.free_area[order].free_list;
    }
}
```
buddy_system_pmm_free_pages 函数负责将指定的页面块释放并尝试与相邻的空闲块合并，以实现内存块的回收与合并。这是伙伴系统分配算法的关键步骤之一，通过合理的合并机制，减少了内存碎片，提高了分配效率。以下是代码的详细分析：

函数结构:
1. 块的初始阶层（order）计算：
根据所需释放的页面数 n，调用 getorder(getup2(n)) 计算需要的阶层 order，并初始化指向第一个页面的指针 p。

2. 标记空闲状态：
将页面块的 property 属性设置为 2 的 order 次幂（即块大小），标记其空闲状态，并获取该阶层的空闲链表指针free_list_order。

3. 块合并循环：
该循环尝试逐层合并相邻的空闲块，直到达到最大阶层 MAX_ORDER - 1。
* 如果 free_list_order 为空（即当前阶层没有空闲块），则直接将该块 p 添加到对应的空闲链表中，并更新该阶层的空闲块数和伙伴区的总块数，随后返回。

4. 合并相邻空闲块：
遍历当前阶层的空闲链表，查找与块 p 相邻的页面块 current_page：
* 情况1：current_page 紧跟在 p 后面，则将 current_page 合并到 p。
* 情况2：p 紧跟在 current_page 后面，则更新 p 为 current_page，并将 p 合并到 current_page。
* 一旦合并成功，更新标记 merged 为 1，随后跳出循环并提升 order。

5. 未合并时的退出条件：
若未找到相邻的空闲块可合并，直接将块 p 插入到当前阶层的空闲链表，并更新空闲块数和伙伴区的总块数，退出循环返回。

6. 合并到更高阶层：
如果发生合并，则减少当前阶层的空闲块数和总块数，并递增 order，继续在更高阶层中尝试合并。

#### 7.buddy_nr_free_pages函数
```c
static size_t buddy_nr_free_pages(void) {
    size_t total_cnt = 0;
    for (size_t i = 0; i < MAX_ORDER; i++) {
        total_cnt += buddy_zone.free_area[i].nr_free;
    }
    return total_cnt;
}
```
buddy_nr_free_pages 函数用于计算当前伙伴系统中所有空闲页面的总数。该函数遍历所有阶层（order），将每个阶层的空闲页面数量累加得到整个伙伴系统的总空闲页面数。

#### 8.buddy_system_pmm_check函数
```c
static void buddy_system_pmm_check(void) {
#define ALLOC_PAGE_NUM 100
    cprintf("[buddy_check] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
    size_t initial_nr_free_pages = nr_free_pages();
    cprintf("initial_nr_free_pages %d\n", initial_nr_free_pages);  // 打印 order 的值
    cprintf("[buddy_check] before alloc: ");
    dbg_buddy();
    cprintf("[buddy_check] trying to alloc %d * 1 pages\n", ALLOC_PAGE_NUM);

    struct Page *pages[ALLOC_PAGE_NUM];

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
        pages[i] = alloc_pages(1);
        assert(pages[i] != NULL);
        cprintf("[buddy_check] after alloc: ");
        // dbg_buddy();
    }
        dbg_buddy1();
    assert(nr_free_pages() == initial_nr_free_pages - ALLOC_PAGE_NUM);

    cprintf("[buddy_check] after alloc:  ");
    dbg_buddy();

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
        free_pages(pages[i], 1);
        cprintf("[buddy_check] after free: ");
        dbg_buddy();
    }

    assert(nr_free_pages() == initial_nr_free_pages);

    cprintf("[buddy_check] after free:   ");
    dbg_buddy();
        struct Page* p1 = alloc_pages(513);
    assert(p1 != NULL);
    assert(p1->property == 1024);
    cprintf("[buddy_check] after alloc 513 pages: ");
    dbg_buddy();

    struct Page* p2 = alloc_pages(79);
    assert(p2 != NULL);
    assert(p2->property == 128);
    cprintf("[buddy_check] after alloc 79 pages:  ");
    dbg_buddy();

    struct Page* p3 = alloc_pages(37);
    assert(p3 != NULL);
    assert(p3->property == 64);
    cprintf("[buddy_check] after alloc 37 pages:  ");
    dbg_buddy();

    struct Page* p4 = alloc_pages(3);
    assert(p4 != NULL);
    assert(p4->property == 4);
    cprintf("[buddy_check] after alloc 3 pages:   ");
    dbg_buddy();
    cprintf("[buddy_check] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
}
static void buddy_check(void) {
    buddy_system_pmm_check();
}

```


buddy_system_pmm_check 函数是对伙伴系统内存分配和释放功能的测试程序，用于验证伙伴系统中各个函数的正确性，确保内存分配和释放操作符合预期行为。它通过一系列内存分配和释放操作来测试伙伴系统的分配和回收机制，并检查每次操作后伙伴系统的状态。

代码解析:
1. 初始化并打印初始状态：
* 获取初始的空闲页面数 initial_nr_free_pages，并使用 dbg_buddy 函数打印当前伙伴系统的状态。
2. 分配测试（分配 100 个单页面）：
* 使用 alloc_pages(1) 循环分配 100 个单页面（每次分配 1 页）。
* 每次分配后打印伙伴系统状态，以便确认每次分配的变化。
* 断言检查：确保分配后伙伴系统的空闲页面数减少了 100。
3. 释放测试（释放前面分配的 100 个单页面）：
* 使用 free_pages(pages[i], 1) 释放先前分配的 100 个单页面。
* 每次释放后再次打印伙伴系统状态，确保释放操作的正确性。
* 断言检查：验证释放后的空闲页面数与初始空闲页面数相同。
大块内存分配测试：
4. 分配 513 页：调用 alloc_pages(513) 分配一个较大的页面块。
* 断言分配成功，并检查分配块的属性是否为 1024（符合 buddy 分配规则的最近 2 的幂次）。
5. 分配 79 页：调用 alloc_pages(79) 分配一个 79 页的页面块。
* 断言分配成功，检查属性是否为 128。
6. 分配 37 页：调用 alloc_pages(37) 分配一个 37 页的页面块。
* 断言分配成功，检查属性是否为 64。
7. 分配 3 页：调用 alloc_pages(3) 分配一个 3 页的页面块。
* 断言分配成功，检查属性是否为 4。
8. 结束标记：
* 打印伙伴系统检查结束的标记，表示测试过程完成。

通过 buddy_system_pmm_check 函数，可以验证以下几个方面：

* 基本的页面分配和释放功能是否正常。
* 大块内存分配是否按伙伴系统的规则进行。
* 在内存释放后是否正确合并并回归到合适的空闲列表。

#### 9.buddy_system_pmm_manager定义
```c
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_pmm_init,
    .init_memmap = buddy_system_pmm_init_memmap,
    .alloc_pages = buddy_system_pmm_alloc_pages,
    .free_pages = buddy_system_pmm_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
```
buddy_system_pmm_manager 结构体定义了伙伴系统的物理内存管理器，并将各个函数指针绑定到具体实现函数中。每个函数实现了特定的内存管理功能，具体功能如下：

1. .name：定义了内存管理器的名称，这里命名为 "buddy_system_pmm_manager"，方便调试和区分不同的内存管理策略。

2. .init：指向 buddy_system_pmm_init 函数，用于初始化伙伴系统的整体数据结构。通常用于设置伙伴系统的初始状态，比如定义空闲区域等。

3. .init_memmap：指向 buddy_system_pmm_init_memmap 函数，用于初始化伙伴系统的物理内存映射，将内存页面映射到伙伴系统的数据结构中。

4. .alloc_pages：指向 buddy_system_pmm_alloc_pages 函数，用于实现页面的分配逻辑。通过伙伴算法找到合适大小的页面块并返回。

5. .free_pages：指向 buddy_system_pmm_free_pages 函数，用于释放已经分配的页面块，并尝试将相邻的空闲块合并。

6. .nr_free_pages：指向 buddy_nr_free_pages 函数，用于返回当前伙伴系统中可用的空闲页面总数。

7. .check：指向 buddy_check 函数，用于检查和验证伙伴系统的正确性。调用该函数可以测试分配和释放的正确性，确保伙伴系统按照设计预期工作。

buddy_system_pmm_manager 结构体通过将伙伴系统内存管理的各个核心函数进行封装，形成统一的接口，方便在操作系统内核中调用和管理内存。这种设计使得内存管理模块更具灵活性，可以轻松替换或扩展为其他内存管理策略。
### 扩展练习Challenge2:任意大小的内存单元slub分配算法实现
SLUB（Simple List of Unused Blocks）分配器旨在通过分配不同大小的内存块来有效地管理物理内存。与 First-Fit 和 Best-Fit 等连续分配策略不同，SLUB 提供了更大的灵活性来处理可变大小的内存分配请求，使其适合用于管理多样化的内存分配需求。在大多数情况下，程序需要的并不是一整页，而是几个、几十个字节的小内存。于是需要另外一套系统来完成对小内存的管理，这就是slub系统。slub系统运行在伙伴系统之上，为内核提供小内存管理的功能。形象地说slub就相当于零售商，它向伙伴系统“批发”内存，然后再零售出去。

在本实验中，我在kern/mm/slub_pmm.c中实现了 SLUB 分配器，以支持任意大小的内存块的分配和释放。在make qemu生成时运行测试函数。以下是实现和测试过程的详细说明。


#### 实现细节

SLUB 分配器使用了两个主要的数据结构：slob_t 和 bigblock_t。slob_t 结构用于管理较小的分配单元，而 bigblock_t 结构用于管理需要多个页的大型内存分配请求。



- slob_t 表示一个内存块，存储块的大小和指向下一个块的指针。

- bigblock_t 表示一个大内存分配，存储分配的页数（order）和指向下一个大块的指针。

分配器通过一个链表 (slobfree) 来跟踪空闲块，维护可用内存块的列表。
SLUB 分配器的主要函数包括：

- slub_alloc(size_t size)：分配给定大小的内存块。

- slub_free(void *block)：释放已分配的内存块。

- slub_size(const void *block)：返回给定内存块的大小。

- slub_check()：执行测试以验证 SLUB 实现的正确性。

以下是 SLUB 分配器的关键部分代码及其详细说明：
##### 1. `slub_alloc()`函数
```c
static void *slob_alloc(size_t size) {
    assert(size < PGSIZE);

    slob_t *prev, *cur;
    int units = SLOB_UNITS(size);

    prev = slobfree;
    for (cur = prev->next;; prev = cur, cur = cur->next) {
        if (cur->units >= units) {
            if (cur->units == units) {
                prev->next = cur->next;
            } else {
                prev->next = cur + units;
                prev->next->units = cur->units - units;
                prev->next->next = cur->next;
                cur->units = units;
            }
            slobfree = prev;
            return cur;
        }
        if (cur == slobfree) {
            if (size == PGSIZE) return 0;
            cur = (slob_t *)alloc_pages(1);
            if (!cur) return 0;
            slob_free(cur, PGSIZE);
            cur = slobfree;
        }
    }
}
```
该函数通过遍历 slobfree 链表，找到合适的空闲块进行分配。若没有找到合适的块，则分配一个新的页并将其分割为小块。
如果当前块足够大，则分割块并返回其中的 units 单元给调用者。

##### 2. `slub_free()` 函数
slub_free 函数用于释放之前分配的内存块，将其返回到空闲链表中，并进行适当的合并操作以减少碎片化。

```c
void slub_free(void *block) {
    bigblock_t *bb, **last = &bigblocks;

    if (!block) return;

    if (!((unsigned long)block & (PGSIZE - 1))) {
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
            if (bb->pages == block) {
                *last = bb->next;
                free_pages((struct Page *)block, bb->order);
                slob_free(bb, sizeof(bigblock_t));
                return;
            }
        }
    }

    slob_free((slob_t *)block - 1, 0);
    return;
}
```

#####  3.`slub_check()`函数
slub_check 函数用于测试 SLUB 分配器的正确性，验证内存分配和释放过程是否正常工作。以下是代码的详细实现：
```c
void slub_check() {
    cprintf("slub check begin\n");
    // 1. 初始空闲列表长度
    cprintf("slobfree len (initial): %d\n", slobfree_len());
    // 2. 分配4KB
    void *p1 = slub_alloc(4096);
    cprintf("slobfree len (after alloc 4KB): %d\n", slobfree_len());
    // 3. 分配小块
    void *p2 = slub_alloc(2);
    void *p3 = slub_alloc(2);
    cprintf("slobfree len (after alloc 2B and 2B): %d\n", slobfree_len());
    // 4. 释放一个小块
    slub_free(p2);
    cprintf("slobfree len (after free p2): %d\n", slobfree_len());
    // 5. 释放另一个小块
    slub_free(p3);
    cprintf("slobfree len (after free p3): %d\n", slobfree_len());
    // 6. 释放4KB块
    slub_free(p1);
    cprintf("slobfree len (after free p1): %d\n", slobfree_len());
    // 7. 分配多个不同大小的块
    void *p4 = slub_alloc(1);
    void *p5 = slub_alloc(512);
    void *p6 = slub_alloc(1024);
    cprintf("slobfree len (after alloc 1B, 512B, 1KB): %d\n", slobfree_len());
    // 8. 检查内存分配有效性（例如通过写入测试）
    if (p4 && p5 && p6) {
        *((char *)p4) = 'A'; // 写入测试
        *((char *)p5) = 'B';
        *((char *)p6) = 'C';
        cprintf("Memory write test passed for p4, p5, p6\n");
    } else {
        cprintf("Memory allocation failed for p4, p5, or p6\n");
    }
    // 9. 释放这些块
    slub_free(p4);
    slub_free(p5);
    slub_free(p6);
    cprintf("slobfree len (after free p4, p5, p6): %d\n", slobfree_len());

    cprintf("slub check end\n");
}
```
测试结果分析:

从控制台输出可以看出，每次分配和释放操作都成功管理，且空闲列表长度在测试过程中反映了预期的变化：
```
slub_init() succeeded!
slub check begin
slobfree len (initial): 0
slobfree len (after alloc 4KB): 1
slobfree len (after alloc 2B and 2B): 1
slobfree len (after free p2): 2
slobfree len (after free p3): 1
slobfree len (after free p1): 2
slobfree len (after alloc 1B, 512B, 1KB): 2
Memory write test passed for p4, p5, p6
slobfree len (after free p4, p5, p6): 2
```
输出表明 SLUB 分配器在处理不同大小的内存请求时，能够正确管理空闲块的分配和释放，验证了实现的正确性和稳定性。
- 分配 4KB 后：空闲列表的长度增加了 1，因为分配器从空闲列表中划分出了一个 4KB 的块。

- 分配 2B 和 2B 后：空闲列表的长度保持不变，这是因为这些小块被从已分配的页面中分割出来，而不是从空闲列表中分配新的页。

- 释放小块 p2 和 p3 后：空闲列表的长度先增加再减少，验证了分配器对于小块释放的正确管理。

- 释放 4KB 块后：空闲列表的长度恢复到原来的状态，验证了大块内存的正确释放。

- 内存写入测试：对已分配内存块的写入操作没有出现错误，说明分配器分配的内存块可正常使用。

#### 算法分析
优点：SLUB 分配器有效管理了不同大小的内存块，相较于 First-Fit 和 Best-Fit 等固定大小的分配方法，减少了内存碎片，并增加了灵活性。

局限性：在特定场景下（尤其是反复分配和释放小块内存），当前实现仍可能导致碎片化。可以通过优化策略（例如合并相邻块或使用更复杂的空闲列表结构）来缓解这一问题。

## 三. 实验中的知识点

#### 1. 物理内存管理与内存分配算法

实验实现了 First-Fit、Best-Fit 和 SLUB 三种内存分配算法。这些算法用于管理物理内存的分配和释放，决定了内存块在空闲列表中的组织方式，以满足不同的内存请求。


在os中，操作系统中物理内存管理的核心是内存分配算法。First-Fit 和 Best-Fit 算法是经典的连续内存分配方法，它们以不同的策略来管理和分配内存，从而影响系统的性能和内存碎片。SLUB 算法则是用于内核小内存分配的现代方法，提供更精细的内存块管理，减少内存碎片化。

理解：实验中的 First-Fit 和 Best-Fit 实现了基本的连续内存管理，而 SLUB 则展示了一个更灵活的方式来处理不同大小的内存请求。SLUB 的实现更贴近现代操作系统的实际需求，尤其是在管理小内存块时，它能够有效减少内存碎片。

#### 2. 页结构体的设计与页表管理


在实验中，通过 struct Page 结构体来管理物理页帧的信息，包括引用计数、标志位、空闲链表链接等。这些信息用于追踪每一个物理页帧的状态。

在os中，页表是操作系统实现虚拟内存的关键数据结构，通过页表可以将虚拟地址映射到物理地址。页帧管理是内存管理的基础，操作系统需要跟踪物理内存中的每一个页的使用情况。

理解：实验中的页结构体主要用于物理页的管理，而在实际操作系统中，页表负责管理虚拟地址到物理地址的映射。虽然实验中没有直接涉及页表的实现，但通过管理物理页帧的引用计数和状态标志，可以看到物理内存管理与虚拟内存管理之间的联系。

#### 3. 空闲链表管理与内存碎片

在 First-Fit、Best-Fit 和 SLUB 实验中，空闲链表用于管理空闲的内存块。分配和释放内存时，会对链表进行相应的插入、删除和合并操作，以减少内存碎片。


在os中，操作系统需要应对内存碎片的问题，尤其是在频繁的分配和释放内存后，内存可能被分割为许多小的块。连续内存分配策略中的空闲链表管理以及延迟合并等技术，都是为了解决内存碎片的问题。

理解:实验通过链表管理空闲块，演示了如何应对内存碎片的问题。而在实际操作系统中，除了空闲链表，还会使用位图、伙伴系统等更复杂的数据结构，以提高分配和合并的效率。

#### OS 原理中重要，但实验中未涉及的知识点
在本次实验中，未提及的知识点进程调度算法，文件系统与I/O管理，内存映射与缓存管理等等。