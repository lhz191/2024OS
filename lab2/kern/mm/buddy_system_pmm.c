#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

#define MAX_ORDER 11 // Max number of orders

typedef struct {
    free_area_t free_area[MAX_ORDER];  // This manages multiple free areas
    size_t n_sum;
} buddy_zone_t;

buddy_zone_t buddy_zone;  // External declaration for buddy_zone

// Init function for buddy system
static void buddy_system_pmm_init(void) {
    // cprintf("111111111111111111111111\n");
    for (int i = 0; i < MAX_ORDER; i++) {
        list_init(&buddy_zone.free_area[i].free_list);  // Initialize each free list
        buddy_zone.free_area[i].nr_free = 0;  // Properly access nr_free for buddy_zone
    }
    // buddy_zone.free_area[0].nr_free = 0;  // Properly access nr_free for buddy_zone
    //  cprintf("22222222222222222222\n");
}

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
static void dbg_buddy1() {
    // 打印每个 order 的空闲块链表地址和块信息
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
        // 打印当前 order 的链表指针和链表中的块地址
        list_entry_t *le = &buddy_zone.free_area[order].free_list;
        cprintf("[dbg_buddy] order %2d list: %016x --> \n", order, le);

        while ((le = list_next(le)) != &buddy_zone.free_area[order].free_list) {
            struct Page *page = le2page(le, page_link);
            cprintf("    %016lx (property: %d) --> \n", (size_t)page, page->property);
        }

        cprintf("    NULL\n\n"); // 加入换行
    }

    // 打印每个 order 空闲块的总数
    cprintf("[dbg_buddy] block count: \n");
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
        cprintf("    order %2d: %2d blocks\n", order, buddy_zone.free_area[order].nr_free / (1 << order));
    }
    cprintf("\n");
}
static void dbg_buddy() {
    // for (int order = BUDDY_MAX_ORDER - 1; order >= 0; order--) {
    //     // print linked list
    //     list_entry_t *le = &buddy_zone.free_area[order].free_list;

    //     cprintf("[dbg_buddy] list: %016x --> ", le);

    //     while ((le = list_next(le)) != &buddy_zone.free_area[order].free_list) {
    //         cprintf("%016lx --> ", le2page(le, page_link));
    //     }

    //     cprintf("\n");
    // }

    cprintf("[dbg_buddy] block: ");
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
    }
    cprintf("\n");
}

static void buddy_system_pmm_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    // cprintf("3333333333333333333333\n");
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
            now_page += n_temp; // 更新当前页指针
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
        }
    }
    // cprintf("44444444444444444444444444\n");
}



static struct Page * buddy_system_pmm_alloc_pages(size_t n) {
    // cprintf("555555555555555555555555555555\n");
    assert(n > 0);
    if (n > buddy_zone.n_sum) {
        return NULL;
    }
    int order_copy;
    // cprintf("n: %d\n", n);  // 打印 n 的值
    int order_needed = getorder(getup2(n)); // 找到需要的最小阶层
    order_copy=order_needed;
    // cprintf("order_needed: %d\n", order_needed);  // 打印 n 的值
    for (int order = order_needed; order <= MAX_ORDER; order++) {
        if (buddy_zone.free_area[order].nr_free / (1 << order) > 0) {
            // 找到空闲块
            // cprintf("找到的块序号为order: %d\n", order);  // 打印 n 的值
            // cprintf("test1\n");
            // dbg_buddy();
            list_entry_t *le = list_next(&buddy_zone.free_area[order].free_list);
            struct Page *p = le2page(le, page_link);
            // cprintf("删除的页: %p\n", p);
            list_del(&(p->page_link));
            // cprintf("buddy_zone.free_area[order].nr_free: %d\n", buddy_zone.free_area[order].nr_free);  // 打印 n 的值
            buddy_zone.free_area[order].nr_free-=(1<<order);
            // cprintf("buddy_zone.free_area[order].nr_free: %d\n", buddy_zone.free_area[order].nr_free);  // 打印 n 的值
            ClearPageProperty(p);
            // cprintf("test2\n");
            // dbg_buddy();
            // 从找到的块中分裂出合适大小
            struct Page *buddy=p;
            if(is_pow2(n)||n==1){
            int n_more=(1<<order)-(1<<order_needed);
            while (order > order_needed) {
                order--;
                // cprintf("多余的页: %p\n", buddy);
                buddy->property = 1 << order;
                SetPageProperty(buddy);
                list_add(&buddy_zone.free_area[order].free_list, &buddy->page_link);
                buddy += (1 << order);
                buddy_zone.free_area[order].nr_free+=1<<order;
                // cprintf("order: %d\n", order);  // 打印 n 的值
                // cprintf("buddy_zone.free_area[order].nr_free %d\n", buddy_zone.free_area[order].nr_free);  
            }
            p=buddy+(1<<order_needed);
            p->property=1<<order_copy;
            // ClearPageProperty(p);
            // cprintf("分配的页: %p\n", buddy);
            return p;
            }
            else
            {       
                cprintf("begin");
                size_t excess_pages = (1 << order) - n; 
                // cprintf("多余的页: %p\n", excess_pages);
                while (excess_pages > 0) {
                    int highest_pow2 = getdown2(excess_pages); // 找到不超过 excess_pages 的最大 2 的幂
                    // cprintf("分配的页: %p\n",highest_pow2 );
                    excess_pages -= highest_pow2;
                    struct Page *extra_buddy = buddy;
                    buddy+=1<<highest_pow2;
                    extra_buddy->property = highest_pow2;
                    SetPageProperty(extra_buddy);
                    list_add(&buddy_zone.free_area[getorder(highest_pow2)].free_list, &extra_buddy->page_link);
                    buddy_zone.free_area[getorder(highest_pow2)].nr_free += highest_pow2;
                    buddy_zone.n_sum+=highest_pow2;
                }
                p=buddy;
                p->property=1<<order_copy;
                // ClearPageProperty(p);
                // cprintf("分配的页: %p\n", buddy);
                return p;
            }
        }
    }
    // cprintf("6666666666666666666666666\n");
    return NULL; // 如果没有合适的块
    
}


static void buddy_system_pmm_free_pages(struct Page *base, size_t n) {
    assert(n > 0);

    // 获取块的初始 order
    int order = getorder(getup2(n));
    struct Page *p = base;

    // 标记并添加到相应的空闲列表中
    p->property = 1 << order;
    SetPageProperty(p);
    // buddy_zone.free_area[order].nr_free += (1 << order);
    // buddy_zone.n_sum += (1 << order);

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
            
            // 打印当前页地址和要合并的页地址
            // 打印当前页地址和要合并的页地址
            // cprintf("first页: %p\n", (uintptr_t)p);
            // cprintf("second页: %p\n", (uintptr_t)current_page);
            // cprintf("p 和 current_page 之间的差值 (16进制): %lx\n", (uintptr_t)p - (uintptr_t)current_page);
            // cprintf("page_size (16进制): %lx\n", page_size);
            // 检查 p 和 current_page 是否相邻
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
                // cprintf("merge\n");
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
            // cprintf("return\n");
            return;
        }
        buddy_zone.free_area[order].nr_free -= (1 << order);
        buddy_zone.n_sum -= (1 << order);
        // 继续合并到更大的块
        order++;
        free_list_order = &buddy_zone.free_area[order].free_list;
        // cprintf("jixu\n");
    }
}


static size_t buddy_nr_free_pages(void) {
    size_t total_cnt = 0;
    for (size_t i = 0; i < MAX_ORDER; i++) {
        total_cnt += buddy_zone.free_area[i].nr_free;
    }
    return total_cnt;
}

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
    // cprintf("11111111111");
    buddy_system_pmm_check();
}

const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_pmm_init,
    .init_memmap = buddy_system_pmm_init_memmap,
    .alloc_pages = buddy_system_pmm_alloc_pages,
    .free_pages = buddy_system_pmm_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};



