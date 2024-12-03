### 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点
 
#### 练习0：填写已有实验
本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

#### 练习1：分配并初始化一个进程控制块（需要编码）
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