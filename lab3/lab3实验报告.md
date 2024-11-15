### 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点



# Lab3 缺页异常和页面置换

## 一.实验目的

1.了解虚拟内存的Page Fault异常处理实现

2.了解页替换算法在操作系统中的实现

3.学会如何使用多级页表，处理缺页异常（Page Fault），实现页面置换算法。

## 二.实验过程
### 练习0：填写已有实验

本实验依赖实验2。请把你做的实验2的代码填入本实验中代码中有“LAB2”的注释相应部分。（建议手动补充，不要直接使用merge）


### 练习1：理解基于FIFO的页面替换算法（思考题）
*描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数*



### 练习2：深入理解不同分页模式的工作原理（思考题）
*get_pte()函数（位于kern/mm/pmm.c）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？*



#### 1. **get_pte()函数的相似性分析**

`get_pte()`函数位于 `kern/mm/pmm.c`，用于在页表中查找或创建页表项，从而实现虚拟地址与物理地址的映射。在这个过程中，`get_pte()`函数通过查找页表项（PTE），根据虚拟地址映射对应的物理页。函数中有两段形式相似的代码，分别处理了不同层级的页表，分别是针对**GiGa Page**（即高层页表）和**MeGa Page**（即较低层页表）。
```c
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    // 获取虚拟地址 la 对应的页目录项
    pde_t *pdep1 = &pgdir[PDX1(la)];
    
    // 如果第一级页表项无效（即页目录项不存在），需要创建新的页表
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;  // 如果无法分配页面，返回 NULL
        }
        set_page_ref(page, 1);  // 设置新分配的页面的引用计数为 1
        uintptr_t pa = page2pa(page);  // 获取物理地址
        memset(KADDR(pa), 0, PGSIZE);  // 将该页的内容清零
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);  // 创建新的页表项并写入页目录
    }

    // 获取第二级页表项，即通过第一级页表项找到第二级页表
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    
    // 如果第二级页表项无效（即页表项不存在），需要创建新的页表
    if (!(*pdep0 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;  // 如果无法分配页面，返回 NULL
        }
        set_page_ref(page, 1);  // 设置新分配的页面的引用计数为 1
        uintptr_t pa = page2pa(page);  // 获取物理地址
        memset(KADDR(pa), 0, PGSIZE);  // 将该页的内容清零
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);  // 创建新的页表项并写入页目录
    }

    // 返回最终的页表项，指向目标物理页
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}
```

这两段代码的相似性来自于它们的操作逻辑：都先通过虚拟地址计算出相应的页表项索引（如`PDX1`和`PDX0`），然后在相应的页表中查找该索引对应的地址。如果该页表项不存在（即地址非法），则会为其分配新的页表项。区别在于：

- 第一段代码针对**GiGa Page**，查找的是`PDX1`的页表项，偏移量较高，通常对应更高层次的页表。
- 第二段代码针对**MeGa Page**，查找的是`PDX0`的页表项，偏移量较低，通常对应较低层次的页表。

两段代码逻辑一致，只是在查找的层级（即虚拟地址中的不同偏移部分）和页表项的地址长度上有所区别。

#### 2. **sv32、sv39、sv48的异同**

这三种分页模式本质上都是在虚拟地址与物理地址之间进行映射，只是在页表的结构和地址的位数上有所不同：

- **sv32**：使用32位虚拟地址，地址空间较小，页表只分为两级。
- **sv39**：使用39位虚拟地址，地址空间增大，页表分为三级。
- **sv48**：使用48位虚拟地址，进一步扩大地址空间，页表分为四级。

这三种模式的共同点是都使用页表的层级结构来实现虚拟地址到物理地址的映射，区别仅在于层级数量（即页表项的级数）和虚拟地址的位数。因此，`get_pte()`函数中的两段代码的相似性就在于，尽管虚拟地址的长度和页表的层级不同，但它们都遵循相同的规则：根据虚拟地址计算相应的页表项，进行查找并在必要时分配新的页表项。

#### 3. **是否有必要将两个功能拆开**

当前`get_pte()`函数将页表项的查找和页表项的分配合并在一个函数中。我们认为这种设计是合理的，主要原因如下：

- **减少代码重复**：在大多数情况下，我们只需要在页表项不存在时才会进行分配操作。这意味着查找和分配是紧密相关的，合并在一个函数中可以避免重复编写查找逻辑。
- **提高执行效率**：将两者合并能减少函数调用的开销，尤其是在分页机制中，频繁的查找和创建操作可能影响性能。减少函数调用的深度和频次可以提升效率。
- **简化代码结构**：这种写法使得代码更加简洁，易于理解和维护。

尽管如此，也可以考虑在某些场景下将两者拆开，特别是当我们需要单独优化或扩展查找或分配的功能时。拆分功能可以提高代码的灵活性和可扩展性，便于未来的维护和修改。例如，在某些特殊情况下，可能需要单独处理页表项的创建逻辑，或者根据不同策略优化页表项查找过程。

#### 4. **结论**

总体而言，当前`get_pte()`函数的设计是合适的。在大多数情况下，合并查找和分配功能能有效简化代码，减少重复，提升性能。但也需要考虑未来可能出现的需求变化，是否需要将这两个操作拆开以提高代码的灵活性。

### 练习3：给未被映射的地址映射上物理页（需要编程）















### 练习4：补充完成Clock页替换算法（需要编程）

Clock算法也被称为"二次机会算法"或"简单的CLOCK算法"，其核心思想是给那些曾经被访问过的页面一个"第二次机会"，避免将经常使用的页面置换出去。

原理如下：

#### 1、基本结构：

- 维护一个循环链表，存放所有的页面
- 每个页面都有一个访问位(visited bit)，用于标记该页面是否被访问过
- 有一个类似时钟指针的标记(clock hand)，用于遍历这个循环链表

#### 2、算法流程

初始状态：
- 所有新加入的页面，访问位都设为1
- 时钟指针指向最老的页面

当需要替换页面时：
1. 检查当前指针指向的页面：
   - 如果访问位=0：该页面被选作替换页面
   - 如果访问位=1：将访问位改为0，指针移到下一个页面
2. 重复步骤1直到找到可替换的页面

Clock页替换算法所是实现的函数接口与FIFO页替换算法的函数接口一致，均为swap_manager结构体所定义的函数接口，主要函数如下：

好的,我来详细解释Clock算法的每个函数设计说明。

1. _clock_init_mm：初始化页面替换链表和时钟指针
```c
static int
_clock_init_mm(struct mm_struct *mm)
{     

     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作

     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
     return 0;
}
```

功能：此函数负责初始化Clock算法所需的数据结构。
* 首先调用list_init初始化全局变量pra_list_head，用于构建循环链表结构
* 将curr_ptr指针(时钟指针)初始化为指向链表头
* 将链表头地址存储在mm->sm_priv中，用于后续的页面替换操作

设计说明：在Clock算法中，我们需要一个循环链表来模拟时钟结构，curr_ptr作为时钟指针在链表中循环移动。该函数确保每个进程拥有独立的页面替换机制。

2. _clock_map_swappable：将新页面加入循环链表
```c
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    // 每次插到尾部，并将访问位设置为1
    list_add_before(head, entry);
    page->visited = 1;
    return 0;
}
```

功能：此函数负责将新页面加入到循环链表中，并初始化其访问位。
* 将新页面添加到链表末尾
* 将页面的访问位(visited)设置为1，表示该页面刚被访问过

设计说明：
* 新加入的页面被放在链表末尾，保持时钟的循环特性
* 访问位设为1给予新页面一次"机会"，避免其刚加入就被替换出去

3. _clock_swap_out_victim：选择被替换的页面
```c
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
    while (1) {
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        if(curr_ptr == head) 
        {
            curr_ptr = list_next(curr_ptr);
            continue;
        }
    //当链表已满时，需要调出块，调出块就是遍历链表，如果标志位为1就置为0，继续遍历，
    //直到遍历到访问位为0的块，将其删去，指针后移，再将调入快插到链表后端
        struct Page *page = le2page(curr_ptr, pra_page_link);
        if(page->visited == 0) {
            cprintf("curr_ptr %p\n", curr_ptr);
            list_entry_t *next = list_next(curr_ptr);
            list_del(curr_ptr);
            *ptr_page = page;
            curr_ptr = next;  
            break;
        }
        else {
            page->visited = 0;
            curr_ptr = list_next(curr_ptr);
        }
    }
    return 0;
}
```

功能：此函数负责选择要被替换出去的页面。
* 时钟指针curr_ptr在循环链表中移动，检查每个页面的访问位
* 如果遇到访问位为0的页面，选择该页面进行替换
* 如果页面访问位为1，将其置为0并继续查找

设计说明：
* 实现了Clock算法的核心思想：给予页面"第二次机会"
* 通过访问位的检查和重置，保证经常使用的页面不会被轻易替换
* 时钟指针的循环移动确保了页面替换的公平性

这种实现体现了Clock算法的特点：既考虑了页面的使用频率（通过访问位），又保持了实现的简单性（通过循环链表和时钟指针）。相比FIFO算法，它能更好地适应程序的局部性原理，提供更好的性能表现。



### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

与分级页表相比，一个大页具有如下优势和劣势：

优势：

* 性能更好

	- TLB命中率提高，因为一个TLB表项可以覆盖更大的内存范围

	- 页表层级更少，减少了内存访问次数

	- 页表占用空间更小,节省内存

* 管理简单
	- 页表结构简单,维护成本低
	- 地址转换过程更直接

缺点：

* 内存碎片

	* 大页会造成更严重的内部碎片

	* 内存利用率可能降低

* 灵活性差

	- 不能细粒度地控制内存访问权限，这可能导致严重的安全风险，例如内核代码被篡改

	- 对小块内存分配不友好
	- 难以实现按需分页(demand paging)

安全风险

- 一个页面错误可能影响更大范围的内存
- 权限粒度太粗,可能带来安全隐患



### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）

*challenge部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。*

在操作系统中，页面置换算法用于管理有限的物理内存，通过选择合适的页面进行换出，确保系统能够高效运行。LRU（Least Recently Used）算法是一种常见的页面置换策略，它通过记录页面的访问时间来决定哪些页面应该被换出。LRU 算法选择最久未被访问的页面进行换出，保证最近使用的页面始终在内存中。

本实验通过实现一个不考虑开销和效率的 LRU 页替换算法，使用双向链表来模拟 LRU 页替换机制，并进行测试验证。

#### 1._lru_init_mm：初始化页面替换链表
   ```C
    static int _lru_init_mm(struct mm_struct *mm) {
        list_init(&pra_list_head);  // 初始化链表
        mm->sm_priv = &pra_list_head;  // 将链表头部的地址赋值给 mm->sm_priv
        return 0;
    }
   ```
功能：此函数负责初始化页面替换算法所需的数据结构。
- 首先，它调用 list_init 函数初始化全局变量 pra_list_head，这个变量将用于管理页面的替换。
- 然后，将链表的头部地址存储在 mm->sm_priv 中，sm_priv 是 mm_struct 结构体中的一个指针，专门用于存储与当前进程相关的页面替换数据。

设计说明：在 LRU 算法中，我们使用一个链表来管理页面的访问顺序。该函数确保每个进程拥有独立的链表，以便管理该进程的页面替换。

#### 2. _lru_map_swappable：标记页面为可换出
   ```C
 static int _lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
     list_entry_t *head = (list_entry_t*) mm->sm_priv;
     list_entry_t *entry = &(page->pra_page_link);
     
     assert(entry != NULL && head != NULL);
     
     // 遍历链表以检查页面是否已经存在
     list_entry_t *le = list_next(head);
     while (le != head) {
         if (le == entry) {
             // 如果页面已在链表中，将其删除
             list_del(entry);
             break;
         }
         le = list_next(le);
     }

     // 将页面插入到链表头部的后面，表示最近使用
     list_add_after(head, entry);
     
     return 0;
 }
   ```
功能：此函数标记页面为可换出页面，并在访问时更新页面的顺序。当页面被访问时，它会被从链表中删除并插入到链表头部，表示这是最近使用的页面。

设计说明：
- 我们遍历链表检查页面是否已存在，如果存在，则将其从链表中删除（移除旧的位置）。
- 然后，将该页面插入到链表的头部，确保其被标记为“最近使用”。
这种操作保证了链表中最前面的页面为最近访问的页面，尾部的页面为最久未访问的页面。

#### 3. _lru_swap_out_victim：选择需要换出的页面
   ```C
 static int _lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {
     list_entry_t *head = (list_entry_t*) mm->sm_priv;
     assert(head != NULL);
     assert(in_tick == 0);

     // 找到链表尾部的页面（最久未使用的页面）
     list_entry_t *victim = list_prev(head);
     if (victim == head) {
         return -1; // 链表为空，无法找到被替换的页面
     }
     
     list_del(victim); // 从链表中移除该页面
     *ptr_page = le2page(victim, pra_page_link); // 设置被替换页面的指针
     return 0;
 }
   ```
功能：
该函数负责选择需要换出的页面，即链表中尾部的页面（最久未使用的页面）。如果链表为空，表示没有页面可以换出，返回 -1；否则，移除链表尾部的页面，并返回该页面的指针。

设计说明：
- 链表尾部的页面最久未使用，因此最合适用于替换。
- 通过 list_prev 获取链表尾部的页面，使用 list_del 从链表中删除该页面，最后返回页面指针。

#### 4. _lru_check_swap：测试 LRU 页替换算法
   ```C
 static int _lru_check_swap(void) {
     cprintf("write Virt Page c in lru_check_swap\n");
     *(unsigned char *)0x3000 = 0x0c;
     assert(pgfault_num == 4);
     cprintf("write Virt Page a in lru_check_swap\n");
     *(unsigned char *)0x1000 = 0x0a;
     assert(pgfault_num == 4);
     cprintf("write Virt Page d in lru_check_swap\n");
     *(unsigned char *)0x4000 = 0x0d;
     assert(pgfault_num == 4);
     cprintf("write Virt Page b in lru_check_swap\n");
     *(unsigned char *)0x2000 = 0x0b;
     assert(pgfault_num == 4);
     cprintf("write Virt Page e in lru_check_swap\n");
     *(unsigned char *)0x5000 = 0x0e;
     assert(pgfault_num == 5);
     cprintf("write Virt Page b in lru_check_swap\n");
     *(unsigned char *)0x2000 = 0x0b;
     assert(pgfault_num == 5);
     cprintf("write Virt Page a in lru_check_swap\n");
     *(unsigned char *)0x1000 = 0x0a;
     assert(pgfault_num == 6);
     cprintf("write Virt Page b in lru_check_swap\n");
     *(unsigned char *)0x2000 = 0x0b;
     assert(pgfault_num == 7);
     cprintf("write Virt Page c in lru_check_swap\n");
     *(unsigned char *)0x3000 = 0x0c;
     assert(pgfault_num == 8);
     cprintf("write Virt Page d in lru_check_swap\n");
     *(unsigned char *)0x4000 = 0x0d;
     assert(pgfault_num == 9);
     cprintf("write Virt Page e in lru_check_swap\n");
     *(unsigned char *)0x5000 = 0x0e;
     assert(pgfault_num == 10);
     cprintf("write Virt Page a in lru_check_swap\n");
     assert(*(unsigned char *)0x1000 == 0x0a);
     *(unsigned char *)0x1000 = 0x0a;
     assert(pgfault_num == 11);
     return 0;
 }
   ```
功能：
该函数用于测试 LRU 页替换算法的正确性。通过访问不同的虚拟页面并触发页面错误（pgfault_num），验证 LRU 算法是否按照预期替换最久未使用的页面。

设计说明：
- 在每次访问页面时，通过对虚拟地址的访问模拟触发页面错误。
pgfault_num 是用于记录页面错误次数的变量，测试过程中每次访问页面都会增加其值。
- 通过检查 pgfault_num 的值是否符合预期，来验证算法是否正确地执行了页面替换。

#### 5. swap_manager_lru：定义 LRU 页替换管理器
   ```C
 struct swap_manager swap_manager_lru = 
 {
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
 };
   ```
功能：
设计了一个 swap_manager 结构体实例，包含了 LRU 页替换算法所需的所有函数。这些函数包括初始化、页面标记为可换出、选择换出页面、测试交换等操作。

#### 实验结果与分析
在进行测试时，_lru_check_swap 函数模拟了多次页面访问，验证了 LRU 算法的有效性。通过访问不同的虚拟页面，测试了页替换过程中最久未使用页面的选择逻辑，并使用 pgfault_num 检查了页面换出的次数。

最终结果显示，LRU 算法能够正确地根据页面的访问顺序选择最久未使用的页面进行替换，并且实验中没有出现意外错误，证明算法的实现是正确的。

#### 总结
本实验通过实现不考虑效率的 LRU 页替换算法，深入理解了操作系统中页面置换的原理。通过使用链表来管理页面访问顺序，我们能够模拟和验证 LRU 算法的正确性，并进行性能测试。

在实际应用中，LRU 算法由于其高效的访问管理机制，被广泛应用于虚拟内存管理中。实验过程中的设计和实现为进一步研究和优化页面替换算法提供了基础。
## 三. 实验中的知识点

