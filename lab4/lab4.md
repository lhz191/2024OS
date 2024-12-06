## 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点
 
## 练习0：填写已有实验
本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

## 练习1：分配并初始化一个进程控制块（需要编码）
alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

*【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。*

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明proc_struct中struct context context和struct trapframe tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

设计实现过程如下：

alloc_proc 函数的作用是分配并初始化一个新的 proc_struct 结构体，用于表示一个新进程的管理信息。该函数通过动态内存分配 (kmalloc) 为进程控制块（PCB）分配内存空间，并对 proc_struct 中的各个成员变量进行初始化，确保每个字段具有合理的初始值。
```c
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
        proc->state = PROC_UNINIT;   // 将进程状态设置为未初始化状态
        proc->pid = -1;              // 初始化进程ID为-1，表示还未分配有效的进程ID
        proc->runs = 0;              // 进程的运行次数设置为0
        proc->kstack = 0;            // 内核栈指针初始化为0，尚未分配栈空间
        proc->need_resched = 0;      // 进程是否需要重新调度标志，初始化为0，不需要调度
        proc->parent = NULL;         // 进程的父进程为空，表示没有父进程
        proc->mm = NULL;             // 进程的内存管理结构体为空，表示未分配内存
        memset(&(proc->context), 0, sizeof(struct context));  // 清空进程的上下文信息（包括寄存器等）
        proc->tf = NULL;             // 进程的中断处理框架（trapframe）为空
        proc->cr3 = boot_cr3;       // 设置进程的页表基地址为系统启动时的页表基地址（boot_cr3）
        proc->flags = 0;             // 进程的标志位初始化为0
        memset(proc->name, 0, PROC_NAME_LEN + 1);  // 清空进程名称
    }
    return proc;
```

主要功能:
(1)分配内存：
使用 kmalloc(sizeof(struct proc_struct)) 为新的进程控制块（proc_struct）分配内存空间。如果分配失败，函数返回 NULL；如果分配成功，继续进行初始化。

(2)初始化字段：
进程的各个字段被初始化为合理的默认值。下面是对 proc_struct 中各个字段的简要解释：
- state: 设置进程状态为 PROC_UNINIT，表示进程尚未初始化。

- pid: 设置进程ID为 -1，表示进程ID尚未分配。

- runs: 进程的运行次数初始化为0。

- kstack: 内核栈指针初始化为0，表示还未为进程分配栈。

- need_resched: 设置为0，表示进程无需立即调度。

- parent: 设置父进程为 NULL，表示没有父进程。

- mm: 设置内存管理字段为 NULL，表示该进程尚未关联内存管理信息。

- context: 使用 memset 清空上下文信息（context 结构体），确保寄存器等信息处于清空状态。

- tf: 设置为 NULL，表示进程的中断处理框架为空。

- cr3: 设置进程的页表基地址为启动时的 boot_cr3，用于进程的虚拟地址到物理地址的映射。

- flags: 初始化为0，表示进程的标志位未设置。

- name: 使用 memset 清空进程的名称字段。

最终，函数返回新分配并初始化的 proc_struct 指针。

#### 说明proc_struct中struct context context和struct trapframe tf成员变量含义和在本实验中的作用是啥？
##### (1)struct context context的含义:
struct context 结构体用于保存进程在执行过程中的上下文信息（例如寄存器的值）。当进程被调度时，CPU 会保存当前进程的寄存器值到 context 中，以便下次调度时可以恢复进程的状态。
在进程调度（即上下文切换）时，struct context 会存储寄存器状态，确保进程能够在被调度后恢复到其执行状态。

##### (2)struct context context在本实验中的作用:

在本实验中，struct context 主要用于保存和恢复进程的上下文，以实现进程的上下文切换。在ucore中，switch_to 函数负责保存当前进程的上下文，并切换到目标进程。
```c
void switch_to(struct context *from, struct context *to);
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
    STORE sp, 1*REGBYTES(a0)
    STORE s0, 2*REGBYTES(a0)
    STORE s1, 3*REGBYTES(a0)
    STORE s2, 4*REGBYTES(a0)
    STORE s3, 5*REGBYTES(a0)
    STORE s4, 6*REGBYTES(a0)
    STORE s5, 7*REGBYTES(a0)
    STORE s6, 8*REGBYTES(a0)
    STORE s7, 9*REGBYTES(a0)
    STORE s8, 10*REGBYTES(a0)
    STORE s9, 11*REGBYTES(a0)
    STORE s10, 12*REGBYTES(a0)
    STORE s11, 13*REGBYTES(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
    LOAD sp, 1*REGBYTES(a1)
    LOAD s0, 2*REGBYTES(a1)
    LOAD s1, 3*REGBYTES(a1)
    LOAD s2, 4*REGBYTES(a1)
    LOAD s3, 5*REGBYTES(a1)
    LOAD s4, 6*REGBYTES(a1)
    LOAD s5, 7*REGBYTES(a1)
    LOAD s6, 8*REGBYTES(a1)
    LOAD s7, 9*REGBYTES(a1)
    LOAD s8, 10*REGBYTES(a1)
    LOAD s9, 11*REGBYTES(a1)
    LOAD s10, 12*REGBYTES(a1)
    LOAD s11, 13*REGBYTES(a1)

    ret
```
首先保存当前进程的寄存器状态，以便在以后恢复。当前进程的寄存器（如 ra、sp、s0 到 s11 等）会被保存在 from 进程的 context 中。

接下来，switch_to 会获取目标进程（to）的寄存器状态。通过从 to 进程的 context 中加载寄存器的值，获得目标进程的执行状态。
##### (3)struct trapframe* tf的含义:
struct trapframe 主要用于存储发生异常（如中断、系统调用）时的寄存器状态。它捕获了程序的执行状态，特别是当程序发生系统调用或中断时，CPU 会将当前寄存器值保存到 tf 中，之后再恢复。

在进程中，tf 保存了进程在发生异常或中断时的寄存器值，包括栈指针、程序计数器等关键信息。

##### (4)struct trapframe* tf在本实验中的作用(通过看代码和编程调试发现):
在本实验中，forkret 函数内部调用了 forkrets(current->tf)，其中 current->tf 是当前进程的 trapframe。通过 forkrets，当前进程的 trapframe 被传递给新进程，初始化新进程的栈，并跳转到 __trapret，使新进程开始执行。即完成创建子进程时，将父进程的trapframe传递给子进程的作用。









## 练习二 为新创建的内核线程分配资源（需要编码）

### 1. `proc.c`工作的总结

`proc.c`文件是ucore操作系统中负责进程管理的核心模块之一。它实现了进程的创建、调度、状态管理以及进程间关系的维护。主要功能包括：

- 进程控制块的分配与初始化
- 进程的状态转换与调度
- 进程的创建与销毁
- 进程间的父子关系管理
- 进程的唯一标识符（PID）分配

### 2. `proc.c`主要函数作用的分析

在分析`do_fork`函数的实现之前，我们需要先了解`proc.c`中几个重要的辅助函数。这些函数共同配合,完成了进程创建、初始化和管理的核心功能。下面我们将详细分析这些关键函数的实现和作用。

### `alloc_proc`

**功能**：分配并初始化一个新的进程控制块（`proc_struct`），为新进程提供必要的内存空间和初始状态。

```cpp
static struct proc_struct *alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
        proc->state = PROC_UNINIT; // 初始化进程状态为未初始化
        proc->pid = -1; // 初始化进程ID为-1
        proc->runs = 0; // 初始化运行次数为0
        proc->kstack = 0; // 初始化内核栈指针为0
        proc->need_resched = 0; // 初始化调度标志为不需要调度
        proc->parent = NULL; // 初始化父进程指针为空
        proc->mm = NULL; // 初始化内存管理指针为空
        memset(&(proc->context), 0, sizeof(struct context)); // 清空上下文信息
        proc->tf = NULL; // 初始化中断帧指针为空
        proc->cr3 = boot_cr3; // 设置CR3寄存器为启动时的CR3
        proc->flags = 0; // 初始化进程标志为0
        memset(proc->name, 0, sizeof(proc->name)); // 清空进程名称
    }
    return proc;
}
```

### `setup_kstack`

**功能**：为进程分配内核栈，确保进程在内核态运行时有独立的栈空间。

```cpp
static int setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page); // 将分配的页转换为虚拟地址并赋值给内核栈指针
        return 0; // 成功返回0
    }
    return -E_NO_MEM; // 分配失败返回内存不足错误
}
```

### `copy_mm`

**功能**：根据`clone_flags`决定是复制还是共享当前进程的内存管理信息。对于内核线程，通常不需要复制内存空间。

```c:kern/process/proc.c
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL); // 确保当前进程的内存管理为空
    /* do nothing in this project */ // 在本项目中不进行任何操作
    return 0; // 返回0表示成功
}
```

### `copy_thread`

**功能**：设置新进程的中断帧和上下文信息，确保新进程在被调度时能够正确执行。

```cpp
static void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe)); // 设置中断帧位置
    *(proc->tf) = *tf; // 复制中断帧内容

    proc->tf->gpr.a0 = 0; // 设置a0寄存器为0，表示子进程刚被fork
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp; // 设置栈指针

    proc->context.ra = (uintptr_t)forkret; // 设置返回地址为forkret
    proc->context.sp = (uintptr_t)(proc->tf); // 设置上下文栈指针
}
```

### `get_pid`

**功能**：分配一个唯一的PID给新进程，确保系统中每个进程的PID不重复。

```cpp
static int get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS); // 确保最大PID大于最大进程数
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1; // 如果超过最大PID，重置为1
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid; // 返回分配的PID
}
```

这些函数通过分配和初始化进程控制块、内核栈、上下文信息等，确保新进程能够正确创建和运行。




### 3.do_fork函数实现

````c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    
    // 1. 检查进程数量是否超过限制
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    
    // 2. 分配并初始化进程控制块
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    
    // 3. 设置父子关系
    proc->parent = current;
    
    // 4. 分配内核栈
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }
    
    // 5. 根据clone_flags复制或共享内存管理信息
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    
    // 6. 设置中断帧和上下文
    copy_thread(proc, stack, tf);
    
    // 7. 将新进程添加到进程hash表和进程列表中
    bool intr_flag;
    local_intr_save(intr_flag);        // 关中断
    {
        proc->pid = get_pid();         // 分配PID
        hash_proc(proc);               // 加入hash表
        list_add(&proc_list, &(proc->list_link)); // 加入进程列表
        nr_process ++;                 // 进程数量加1
    }
    local_intr_restore(intr_flag);     // 开中断
    
    // 8. 将新进程设置为就绪状态
    wakeup_proc(proc);
    
    // 9. 返回新进程的pid
    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
````

do_fork函数的主要工作是:

1. 创建新进程时的资源分配和初始化工作,包括:
   - 分配进程控制块
   - 分配内核栈
   - 建立父子关系
   - 复制或共享内存空间
   - 设置执行上下文

2. 将新进程加入到系统的管理数据结构中:
   - 分配唯一的PID
   - 加入进程hash表和进程列表
   - 更新系统进程计数

3. 错误处理和资源释放:
   - 各个步骤失败时的清理工作
   - 保证资源分配的原子性
   - 维护系统状态的一致性

通过这些步骤,do_fork实现了创建一个与当前进程几乎完全相同的新进程,为进程复制和创建新线程提供了基础支持。整个过程需要考虑同步互斥、错误处理等关键问题。



### 设计思路分析

1. **进程数量检查**
   ```c
   if (nr_process >= MAX_PROCESS) {
       goto fork_out;
   }
   ```
   - 首先检查系统中的进程数量是否已达到最大值
   - 如果超过限制,直接返回错误码`E_NO_FREE_PROC`

2. **分配进程控制块**
   ```c
   if ((proc = alloc_proc()) == NULL) {
       goto fork_out;
   }
   ```
   - 调用`alloc_proc`分配新的进程控制块
   - 如果内存分配失败,返回错误码`E_NO_MEM`

3. **建立父子关系**
   ```c
   proc->parent = current;
   ```
   - 将新进程的父进程设置为当前进程
   - 建立进程间的父子关系,便于进程管理

4. **分配内核栈**
   ```c
   if (setup_kstack(proc) != 0) {
       goto bad_fork_cleanup_proc;
   }
   ```
   - 为新进程分配内核栈空间
   - 如果分配失败,需要释放之前分配的进程控制块

5. **复制内存管理信息**
   ```c
   if (copy_mm(clone_flags, proc) != 0) {
       goto bad_fork_cleanup_kstack;
   }
   ```
   - 根据`clone_flags`决定是复制还是共享内存空间
   - 对于内核线程,这一步实际上不做任何操作

6. **设置执行现场**
   ```c
   copy_thread(proc, stack, tf);
   ```
   - 复制中断帧和上下文信息
   - 设置新进程的入口点和栈指针

7. **进程管理结构更新**
   ```c
   local_intr_save(intr_flag);
   {
       proc->pid = get_pid();
       hash_proc(proc);
       list_add(&proc_list, &(proc->list_link));
       nr_process ++;
   }
   local_intr_restore(intr_flag);
   ```
   - 关中断保护临界区
   - 分配PID并将进程加入管理结构
   - 更新系统进程数量

8. **激活进程**
   ```c
   wakeup_proc(proc);
   ```
   - 将新进程状态设置为就绪态
   - 使其可以被调度器调度运行

9. **错误处理**
   ```c
   bad_fork_cleanup_kstack:
       put_kstack(proc);
   bad_fork_cleanup_proc:
       kfree(proc);
       goto fork_out;
   ```
   - 设置清晰的错误处理流程
   - 确保在失败时正确释放已分配的资源

这个实现遵循了"先分配资源,失败时及时回收"的原则,保证了资源分配的正确性和系统的稳定性。同时通过关中断等机制保护了临界区,确保了进程创建过程的原子性。


### 4. 问题：ucore是否做到给每个新fork的线程一个唯一的id？

是的，ucore能够保证为每个新fork的线程分配唯一的id。`get_pid`函数通过以下机制实现PID的唯一性：

- **PID范围**：PID的范围在1到`MAX_PID`之间，确保有足够的空间分配给所有可能的进程。

- **循环分配**：`get_pid`函数从`last_pid + 1`开始尝试分配新的PID，若达到`MAX_PID`则从1重新开始。

- **冲突检测**：通过遍历进程列表检查是否存在重复的PID，若发现重复则继续递增尝试新的PID值。

- **优化查找**：使用`next_safe`变量记录下一个可能产生冲突的PID值，减少不必要的遍历。

这种实现方式确保了每个进程获得唯一的PID，满足操作系统的基本要求。


## 练习三 编写proc_run 函数（需要编码）
```cpp
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
        bool intr_flag;
        local_intr_save(intr_flag);
        struct proc_struct * temp = current;
        current = proc;
        lcr3(current->cr3);
        switch_to(&(temp->context),&(proc->context));
        local_intr_restore(intr_flag);
       
    }
}
```

proc_run 函数用于将指定的进程 proc 切换到当前运行的进程。如果 proc 不是当前进程，则执行进程切换。首先，通过 local_intr_save 关闭中断以确保切换过程不被打断。然后，将当前进程 current 保存到临时变量 temp，并将 current 更新为 proc。接着，通过 lcr3 切换到 proc 的页表，确保地址空间正确。随后，调用 switch_to 函数，保存当前进程的上下文并恢复 proc 的上下文。最后，通过 local_intr_restore 恢复中断。这样，CPU 就会从 proc 的上下文继续执行，完成进程切换。

### 在本实验的执行过程中，创建且运行了几个内核线程？

一共创建了两个内核线程，分别为：init_main 和 idleproc。

## 扩展练习Challenge

### 说明语句local_intr_save(intr_flag)，local_intr_restore(intr_flag);是如何实现开关中断的？


语句的相关定义位于/kern/sync/sync.h中，代码如下：
```c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);
```
### 变量解释
- `read_csr(sstatus)`：这是一个读取控制状态寄存器的操作，`sstatus`寄存器包含了当前中断状态等信息。
- `SSTATUS_SIE`：这是一个位掩码，用于检查`SIE`位的状态。
- `intr_disable`和`intr_enable`：这些函数分别用于禁用和启用中断，确保在关键代码段执行时不会被中断打断。
- `local_intr_save`和`local_intr_restore`：这两个宏提供了一种简便的方法来保存和恢复中断状态，确保代码的原子性和一致性。


当调用`local_intr_save`时，存当前的中断状态，并禁用中断。此时会读取`sstatus`寄存器，判断`SIE`位的值，如果该位为1，则说明中断是能进行的，这时需要调用`intr_disable`将该位置0，并返回1，将`intr_flag`赋值为1；如果该位为0，则说明中断此时已经不能进行，则返回0，将`intr_flag`赋值为0。以此保证之后的代码执行时不会发生中断。

当调用`local_intr_restore`，用于恢复之前保存的中断状态。它调用`__intr_restore`函数，并传入`intr_flag`。如果`intr_flag`为1，表示中断在调用`local_intr_save`之前是启用的，`__intr_restore`会调用`intr_enable`来重新启用中断。如果`intr_flag`为0，表示中断在调用`local_intr_save`之前已经是禁用的，`__intr_restore`不会做任何操作。