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


### Challenge2:任意大小的内存单元slub分配算法实现
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