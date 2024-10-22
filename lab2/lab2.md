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

   ```
default_alloc_pages函数用于分配n个连续的物理页。它的实现过程如下:

- 首先检查是否有足够的空闲页可分配,如果 nr_free < n 则返回 NULL。遍历 free_list,找到第一个可满足 n 个页的空闲内存块。具体做法是:
从 free_list 的头部开始遍历
对于每个遍历到的空闲内存块(通过 le2page() 宏获取),检查它的属性 property 是否大于等于 n
如果找到了合适的块,就跳出循环
如果找到了合适的空闲内存块,则:
如果该块的大小大于 n,则将剩余部分重新加入到 free_list 中。具体做法是:
计算剩余部分的大小为 p->property - n
创建一个新的 Page 结构体,将其属性 property 设置为剩余部分的大小,并设置 PG_property 标志位
将这个新的 Page 结构体插入到 free_list 中
从 free_list 中删除该内存块
将该内存块的属性标志位清除,表示已经被分配
将 nr_free 减少 n
最后返回分配的内存块的起始页

