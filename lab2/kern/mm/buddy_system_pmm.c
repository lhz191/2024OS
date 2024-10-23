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

extern buddy_zone_t buddy_zone;  // External declaration for buddy_zone

// Init function for buddy system
static void buddy_system_pmm_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&buddy_zone.free_area[i].free_list);  // Initialize each free list
    }
    buddy_zone.free_area[0].nr_free = 0;  // Properly access nr_free for buddy_zone
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

static void buddy_system_pmm_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    
    // // Update the nr_free within the correct free_area
    buddy_zone.n_sum += n;

    int n_now = n;
    struct Page *now_page = base;
    while (n_now != 0) {
        int n_temp = getdown2(n_now);
        int order = getorder(n_temp);
        n_now -= n_temp;
        now_page = now_page + n_temp;
        now_page->property = n_temp;
        SetPageProperty(now_page);
        buddy_zone.free_area[order].nr_free += n_temp;
        // Add the page to the corresponding free_list for the order
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


static struct Page * buddy_system_pmm_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > buddy_zone.n_sum) {
        return NULL;
    }
    int order_needed = getorder(getup2(n)); // 找到需要的最小阶层

    for (int order = order_needed; order <= MAX_ORDER; order++) {
        if (buddy_zone.free_area[order].nr_free > 0) {
            // 找到空闲块
            list_entry_t *le = list_next(&buddy_zone.free_area[order].free_list);
            struct Page *p = le2page(le, page_link);
            list_del(&(p->page_link));
            buddy_zone.free_area[order].nr_free--;
            ClearPageProperty(p);

            // 从找到的块中分裂出合适大小
            while (order > order_needed) {
                order--;
                struct Page *buddy = p + (1 << order);
                buddy->property = 1 << order;
                SetPageProperty(buddy);
                list_add(&buddy_zone.free_area[order].free_list, &buddy->page_link);
                buddy_zone.free_area[order].nr_free++;
            }

            return p;
        }
    }
    return NULL; // 如果没有合适的块
}

static void buddy_system_pmm_free_pages(struct Page *base, size_t n) {
    assert(n > 0);

    int order = getorder(getup2(n));
    struct Page *p = base;

    // 标记并添加到相应的空闲列表中
    p->property = 1 << order;
    SetPageProperty(p);
    list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
    buddy_zone.free_area[order].nr_free++;
    buddy_zone.n_sum += (1 << order);

    // 迭代合并相邻的伙伴块
    while (order < MAX_ORDER) {
        size_t buddy_addr = ((size_t)p - (size_t)base) ^ (1 << order);
        struct Page *buddy = base + buddy_addr;

        // 检查伙伴块是否可合并
        if (!PageProperty(buddy) || buddy->property != (1 << order)) {
            break; // 不能合并则退出
        }

        // 从当前阶层中删除伙伴块
        list_del(&buddy->page_link);
        buddy_zone.free_area[order].nr_free--;
        buddy_zone.n_sum -= (1 << order);

        // 合并块并移动到更高阶层
        if (p > buddy) {
            p = buddy;
        }
        order++;
        p->property = 1 << order;
        SetPageProperty(p);
        list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
        buddy_zone.free_area[order].nr_free++;
        buddy_zone.n_sum += (1 << order);
    }
}


static size_t buddy_nr_free_pages(void) {
    size_t total_cnt = 0;
    for (size_t i = 0; i < MAX_ORDER; i++) {
        total_cnt += buddy_zone.free_area[i].nr_free;
    }
    return total_cnt;
}

static void buddy_check_0(void) {

#define ALLOC_PAGE_NUM 100

    cprintf("[buddy_check_0] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");

    size_t initial_nr_free_pages = nr_free_pages();

    cprintf("[buddy_check_0] before alloc: ");
    dbg_buddy();


    cprintf("[buddy_check_0] trying to alloc %d * 1 pages\n", ALLOC_PAGE_NUM);

    struct Page *pages[ALLOC_PAGE_NUM];

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
        pages[i] = alloc_pages(1);
        assert(pages[i] != NULL);
    }

    assert(nr_free_pages() == initial_nr_free_pages - ALLOC_PAGE_NUM);

    cprintf("[buddy_check_0] after alloc:  ");
    dbg_buddy();

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
        free_pages(pages[i], 1);
    }

    assert(nr_free_pages() == initial_nr_free_pages);

    cprintf("[buddy_check_0] after free:   ");
    dbg_buddy();

    cprintf("[buddy_check_0] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
}

static void buddy_check_1(void) {
    cprintf("[buddy_check_1] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");


    size_t initial_nr_free_pages = nr_free_pages();

    cprintf("[buddy_check_0] before alloc:          ");
    dbg_buddy();

    struct Page* p0 = alloc_pages(512);
    assert(p0 != NULL);
    assert(p0->property == 512);
    cprintf("[buddy_check_1] after alloc 512 pages: ");
    dbg_buddy();

    struct Page* p1 = alloc_pages(513);
    assert(p1 != NULL);
    assert(p1->property == 1024);
    cprintf("[buddy_check_1] after alloc 513 pages: ");
    dbg_buddy();

    struct Page* p2 = alloc_pages(79);
    assert(p2 != NULL);
    assert(p2->property == 128);
    cprintf("[buddy_check_1] after alloc 79 pages:  ");
    dbg_buddy();

    struct Page* p3 = alloc_pages(37);
    assert(p3 != NULL);
    assert(p3->property == 64);
    cprintf("[buddy_check_1] after alloc 37 pages:  ");
    dbg_buddy();

    struct Page* p4 = alloc_pages(3);
    assert(p4 != NULL);
    assert(p4->property == 4);
    cprintf("[buddy_check_1] after alloc 3 pages:   ");
    dbg_buddy();

    struct Page* p5 = alloc_pages(196);
    assert(p5 != NULL);
    assert(p5->property == 256);
    cprintf("[buddy_check_1] after alloc 196 pages: ");
    dbg_buddy();

    free_pages(p4, 3);
    free_pages(p0, 512);
    free_pages(p2, 79);
    free_pages(p3, 37);
    free_pages(p5, 196);
    free_pages(p1, 513);

    cprintf("[buddy_check_1] after free:            ");
    dbg_buddy();

    assert(nr_free_pages() == initial_nr_free_pages);

    cprintf("[buddy_check_1] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");
}

static void buddy_check(void) {
    buddy_check_0();
    buddy_check_1();
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};



