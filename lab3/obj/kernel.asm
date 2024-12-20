
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53260613          	addi	a2,a2,1330 # ffffffffc021156c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	458040ef          	jal	ra,ffffffffc02044a2 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	48258593          	addi	a1,a1,1154 # ffffffffc02044d0 <etext+0x4>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	49a50513          	addi	a0,a0,1178 # ffffffffc02044f0 <etext+0x24>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	281010ef          	jal	ra,ffffffffc0201ae6 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	704030ef          	jal	ra,ffffffffc0203772 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	0d5020ef          	jal	ra,ffffffffc020294a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	39a000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	743030ef          	jal	ra,ffffffffc0203ff0 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	70d030ef          	jal	ra,ffffffffc0203ff0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	ae0d                	j	ffffffffc0200422 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	360000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200102:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	3f450513          	addi	a0,a0,1012 # ffffffffc02044f8 <etext+0x2c>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204518 <etext+0x4c>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	3a658593          	addi	a1,a1,934 # ffffffffc02044cc <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	40a50513          	addi	a0,a0,1034 # ffffffffc0204538 <etext+0x6c>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	41650513          	addi	a0,a0,1046 # ffffffffc0204558 <etext+0x8c>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	41e58593          	addi	a1,a1,1054 # ffffffffc021156c <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	42250513          	addi	a0,a0,1058 # ffffffffc0204578 <etext+0xac>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	80958593          	addi	a1,a1,-2039 # ffffffffc021196b <end+0x3ff>
ffffffffc020016a:	00000797          	auipc	a5,0x0
ffffffffc020016e:	ec878793          	addi	a5,a5,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200176:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200180:	95be                	add	a1,a1,a5
ffffffffc0200182:	85a9                	srai	a1,a1,0xa
ffffffffc0200184:	00004517          	auipc	a0,0x4
ffffffffc0200188:	41450513          	addi	a0,a0,1044 # ffffffffc0204598 <etext+0xcc>
}
ffffffffc020018c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018e:	b735                	j	ffffffffc02000ba <cprintf>

ffffffffc0200190 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200190:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200192:	00004617          	auipc	a2,0x4
ffffffffc0200196:	43660613          	addi	a2,a2,1078 # ffffffffc02045c8 <etext+0xfc>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	44250513          	addi	a0,a0,1090 # ffffffffc02045e0 <etext+0x114>
void print_stackframe(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a8:	1cc000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001ac <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ac:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ae:	00004617          	auipc	a2,0x4
ffffffffc02001b2:	44a60613          	addi	a2,a2,1098 # ffffffffc02045f8 <etext+0x12c>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	46258593          	addi	a1,a1,1122 # ffffffffc0204618 <etext+0x14c>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	46250513          	addi	a0,a0,1122 # ffffffffc0204620 <etext+0x154>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	46460613          	addi	a2,a2,1124 # ffffffffc0204630 <etext+0x164>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	48458593          	addi	a1,a1,1156 # ffffffffc0204658 <etext+0x18c>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	44450513          	addi	a0,a0,1092 # ffffffffc0204620 <etext+0x154>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	48060613          	addi	a2,a2,1152 # ffffffffc0204668 <etext+0x19c>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	49858593          	addi	a1,a1,1176 # ffffffffc0204688 <etext+0x1bc>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	42850513          	addi	a0,a0,1064 # ffffffffc0204620 <etext+0x154>
ffffffffc0200200:	ebbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200204:	60a2                	ld	ra,8(sp)
ffffffffc0200206:	4501                	li	a0,0
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200210:	ef3ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200220:	f71ff0ef          	jal	ra,ffffffffc0200190 <print_stackframe>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022c:	7115                	addi	sp,sp,-224
ffffffffc020022e:	ed5e                	sd	s7,152(sp)
ffffffffc0200230:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200232:	00004517          	auipc	a0,0x4
ffffffffc0200236:	46650513          	addi	a0,a0,1126 # ffffffffc0204698 <etext+0x1cc>
kmonitor(struct trapframe *tf) {
ffffffffc020023a:	ed86                	sd	ra,216(sp)
ffffffffc020023c:	e9a2                	sd	s0,208(sp)
ffffffffc020023e:	e5a6                	sd	s1,200(sp)
ffffffffc0200240:	e1ca                	sd	s2,192(sp)
ffffffffc0200242:	fd4e                	sd	s3,184(sp)
ffffffffc0200244:	f952                	sd	s4,176(sp)
ffffffffc0200246:	f556                	sd	s5,168(sp)
ffffffffc0200248:	f15a                	sd	s6,160(sp)
ffffffffc020024a:	e962                	sd	s8,144(sp)
ffffffffc020024c:	e566                	sd	s9,136(sp)
ffffffffc020024e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200250:	e6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	46c50513          	addi	a0,a0,1132 # ffffffffc02046c0 <etext+0x1f4>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	4bec0c13          	addi	s8,s8,1214 # ffffffffc0204728 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	8d690913          	addi	s2,s2,-1834 # ffffffffc0205b48 <default_pmm_manager+0x928>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	46e48493          	addi	s1,s1,1134 # ffffffffc02046e8 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	46cb0b13          	addi	s6,s6,1132 # ffffffffc02046f0 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	38ca0a13          	addi	s4,s4,908 # ffffffffc0204618 <etext+0x14c>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	0da040ef          	jal	ra,ffffffffc0204372 <readline>
ffffffffc020029c:	842a                	mv	s0,a0
ffffffffc020029e:	dd65                	beqz	a0,ffffffffc0200296 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a6:	e1bd                	bnez	a1,ffffffffc020030c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002a8:	fe0c87e3          	beqz	s9,ffffffffc0200296 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ac:	6582                	ld	a1,0(sp)
ffffffffc02002ae:	00004d17          	auipc	s10,0x4
ffffffffc02002b2:	47ad0d13          	addi	s10,s10,1146 # ffffffffc0204728 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	1b2040ef          	jal	ra,ffffffffc020446e <strcmp>
ffffffffc02002c0:	c919                	beqz	a0,ffffffffc02002d6 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	0b540063          	beq	s0,s5,ffffffffc0200364 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c8:	000d3503          	ld	a0,0(s10)
ffffffffc02002cc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	19e040ef          	jal	ra,ffffffffc020446e <strcmp>
ffffffffc02002d4:	f57d                	bnez	a0,ffffffffc02002c2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002d6:	00141793          	slli	a5,s0,0x1
ffffffffc02002da:	97a2                	add	a5,a5,s0
ffffffffc02002dc:	078e                	slli	a5,a5,0x3
ffffffffc02002de:	97e2                	add	a5,a5,s8
ffffffffc02002e0:	6b9c                	ld	a5,16(a5)
ffffffffc02002e2:	865e                	mv	a2,s7
ffffffffc02002e4:	002c                	addi	a1,sp,8
ffffffffc02002e6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ea:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002ec:	fa0555e3          	bgez	a0,ffffffffc0200296 <kmonitor+0x6a>
}
ffffffffc02002f0:	60ee                	ld	ra,216(sp)
ffffffffc02002f2:	644e                	ld	s0,208(sp)
ffffffffc02002f4:	64ae                	ld	s1,200(sp)
ffffffffc02002f6:	690e                	ld	s2,192(sp)
ffffffffc02002f8:	79ea                	ld	s3,184(sp)
ffffffffc02002fa:	7a4a                	ld	s4,176(sp)
ffffffffc02002fc:	7aaa                	ld	s5,168(sp)
ffffffffc02002fe:	7b0a                	ld	s6,160(sp)
ffffffffc0200300:	6bea                	ld	s7,152(sp)
ffffffffc0200302:	6c4a                	ld	s8,144(sp)
ffffffffc0200304:	6caa                	ld	s9,136(sp)
ffffffffc0200306:	6d0a                	ld	s10,128(sp)
ffffffffc0200308:	612d                	addi	sp,sp,224
ffffffffc020030a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	8526                	mv	a0,s1
ffffffffc020030e:	17e040ef          	jal	ra,ffffffffc020448c <strchr>
ffffffffc0200312:	c901                	beqz	a0,ffffffffc0200322 <kmonitor+0xf6>
ffffffffc0200314:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200318:	00040023          	sb	zero,0(s0)
ffffffffc020031c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	d5c9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200320:	b7f5                	j	ffffffffc020030c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200322:	00044783          	lbu	a5,0(s0)
ffffffffc0200326:	d3c9                	beqz	a5,ffffffffc02002a8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200328:	033c8963          	beq	s9,s3,ffffffffc020035a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020032c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200330:	0118                	addi	a4,sp,128
ffffffffc0200332:	97ba                	add	a5,a5,a4
ffffffffc0200334:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200338:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033e:	e591                	bnez	a1,ffffffffc020034a <kmonitor+0x11e>
ffffffffc0200340:	b7b5                	j	ffffffffc02002ac <kmonitor+0x80>
ffffffffc0200342:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200346:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200348:	d1a5                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc020034a:	8526                	mv	a0,s1
ffffffffc020034c:	140040ef          	jal	ra,ffffffffc020448c <strchr>
ffffffffc0200350:	d96d                	beqz	a0,ffffffffc0200342 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	00044583          	lbu	a1,0(s0)
ffffffffc0200356:	d9a9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200358:	bf55                	j	ffffffffc020030c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200362:	b7e9                	j	ffffffffc020032c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	3aa50513          	addi	a0,a0,938 # ffffffffc0204710 <etext+0x244>
ffffffffc020036e:	d4dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc0200372:	b715                	j	ffffffffc0200296 <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	18430313          	addi	t1,t1,388 # ffffffffc02114f8 <is_panic>
ffffffffc020037c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	020e1a63          	bnez	t3,ffffffffc02003c4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039a:	8432                	mv	s0,a2
ffffffffc020039c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039e:	862e                	mv	a2,a1
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	3ce50513          	addi	a0,a0,974 # ffffffffc0204770 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	ce7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	2e050513          	addi	a0,a0,736 # ffffffffc0205698 <default_pmm_manager+0x478>
ffffffffc02003c0:	cfbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12a000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e63ff0ef          	jal	ra,ffffffffc020022c <kmonitor>
    while (1) {
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x54>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	12f73923          	sd	a5,306(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	39a50513          	addi	a0,a0,922 # ffffffffc0204790 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	1007b123          	sd	zero,258(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b955                	j	ffffffffc02000ba <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	0fc7b783          	ld	a5,252(a5) # ffffffffc0211508 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	zext.b	a0,a0
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	0ae000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a851                	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	07c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	062000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a0:	0000a797          	auipc	a5,0xa
ffffffffc02004a4:	ba078793          	addi	a5,a5,-1120 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004a8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	95be                	add	a1,a1,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b8:	7fd030ef          	jal	ra,ffffffffc02044b4 <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0000a517          	auipc	a0,0xa
ffffffffc02004cc:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d0:	1141                	addi	sp,sp,-16
ffffffffc02004d2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	953e                	add	a0,a0,a5
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004da:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004dc:	7d9030ef          	jal	ra,ffffffffc02044b4 <memcpy>
    return 0;
}
ffffffffc02004e0:	60a2                	ld	ra,8(sp)
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	0141                	addi	sp,sp,16
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	28c50513          	addi	a0,a0,652 # ffffffffc02047b0 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03053503          	ld	a0,48(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	0030306f          	j	ffffffffc0203d4a <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	28460613          	addi	a2,a2,644 # ffffffffc02047d0 <commands+0xa8>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	29050513          	addi	a0,a0,656 # ffffffffc02047e8 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	4b878793          	addi	a5,a5,1208 # ffffffffc0200a20 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	27650513          	addi	a0,a0,630 # ffffffffc0204800 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	27e50513          	addi	a0,a0,638 # ffffffffc0204818 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	28850513          	addi	a0,a0,648 # ffffffffc0204830 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	29250513          	addi	a0,a0,658 # ffffffffc0204848 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	29c50513          	addi	a0,a0,668 # ffffffffc0204860 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	2a650513          	addi	a0,a0,678 # ffffffffc0204878 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	2b050513          	addi	a0,a0,688 # ffffffffc0204890 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	2ba50513          	addi	a0,a0,698 # ffffffffc02048a8 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	2c450513          	addi	a0,a0,708 # ffffffffc02048c0 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	2ce50513          	addi	a0,a0,718 # ffffffffc02048d8 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	2d850513          	addi	a0,a0,728 # ffffffffc02048f0 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	2e250513          	addi	a0,a0,738 # ffffffffc0204908 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	2ec50513          	addi	a0,a0,748 # ffffffffc0204920 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	2f650513          	addi	a0,a0,758 # ffffffffc0204938 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	30050513          	addi	a0,a0,768 # ffffffffc0204950 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	30a50513          	addi	a0,a0,778 # ffffffffc0204968 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	31450513          	addi	a0,a0,788 # ffffffffc0204980 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	31e50513          	addi	a0,a0,798 # ffffffffc0204998 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	32850513          	addi	a0,a0,808 # ffffffffc02049b0 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	33250513          	addi	a0,a0,818 # ffffffffc02049c8 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	33c50513          	addi	a0,a0,828 # ffffffffc02049e0 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	34650513          	addi	a0,a0,838 # ffffffffc02049f8 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	35050513          	addi	a0,a0,848 # ffffffffc0204a10 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	35a50513          	addi	a0,a0,858 # ffffffffc0204a28 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	36450513          	addi	a0,a0,868 # ffffffffc0204a40 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	36e50513          	addi	a0,a0,878 # ffffffffc0204a58 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	37850513          	addi	a0,a0,888 # ffffffffc0204a70 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	38250513          	addi	a0,a0,898 # ffffffffc0204a88 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	38c50513          	addi	a0,a0,908 # ffffffffc0204aa0 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	39650513          	addi	a0,a0,918 # ffffffffc0204ab8 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	3a050513          	addi	a0,a0,928 # ffffffffc0204ad0 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	3a650513          	addi	a0,a0,934 # ffffffffc0204ae8 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	3aa50513          	addi	a0,a0,938 # ffffffffc0204b00 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	3aa50513          	addi	a0,a0,938 # ffffffffc0204b18 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	3b250513          	addi	a0,a0,946 # ffffffffc0204b30 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	3ba50513          	addi	a0,a0,954 # ffffffffc0204b48 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	3be50513          	addi	a0,a0,958 # ffffffffc0204b60 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	08f76c63          	bltu	a4,a5,ffffffffc0200852 <interrupt_handler+0xa2>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	46a70713          	addi	a4,a4,1130 # ffffffffc0204c28 <commands+0x500>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	40850513          	addi	a0,a0,1032 # ffffffffc0204bd8 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	3dc50513          	addi	a0,a0,988 # ffffffffc0204bb8 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	39050513          	addi	a0,a0,912 # ffffffffc0204b78 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	3a450513          	addi	a0,a0,932 # ffffffffc0204b98 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e022                	sd	s0,0(sp)
ffffffffc0200804:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();  // 设置下一次时钟事件
ffffffffc0200806:	c03ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            ticks++;  // 时钟中断次数加1
ffffffffc020080a:	00011697          	auipc	a3,0x11
ffffffffc020080e:	d0a68693          	addi	a3,a3,-758 # ffffffffc0211514 <ticks.1>
ffffffffc0200812:	429c                	lw	a5,0(a3)

            // 每100次中断，输出 "100 ticks"
            if (ticks % TICK_NUM == 0) {
ffffffffc0200814:	06400713          	li	a4,100
ffffffffc0200818:	00011417          	auipc	s0,0x11
ffffffffc020081c:	cf840413          	addi	s0,s0,-776 # ffffffffc0211510 <num.0>
            ticks++;  // 时钟中断次数加1
ffffffffc0200820:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0) {
ffffffffc0200822:	02e7e73b          	remw	a4,a5,a4
            ticks++;  // 时钟中断次数加1
ffffffffc0200826:	c29c                	sw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200828:	c715                	beqz	a4,ffffffffc0200854 <interrupt_handler+0xa4>
                num++;
                cprintf("100 ticks\n");
            }

            // 输出10次 "100 ticks" 后，关机
            if (num == 10) {
ffffffffc020082a:	4018                	lw	a4,0(s0)
ffffffffc020082c:	47a9                	li	a5,10
ffffffffc020082e:	00f71863          	bne	a4,a5,ffffffffc020083e <interrupt_handler+0x8e>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200832:	4501                	li	a0,0
ffffffffc0200834:	4581                	li	a1,0
ffffffffc0200836:	4601                	li	a2,0
ffffffffc0200838:	48a1                	li	a7,8
ffffffffc020083a:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020083e:	60a2                	ld	ra,8(sp)
ffffffffc0200840:	6402                	ld	s0,0(sp)
ffffffffc0200842:	0141                	addi	sp,sp,16
ffffffffc0200844:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200846:	00004517          	auipc	a0,0x4
ffffffffc020084a:	3c250513          	addi	a0,a0,962 # ffffffffc0204c08 <commands+0x4e0>
ffffffffc020084e:	86dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200852:	bdf5                	j	ffffffffc020074e <print_trapframe>
                num++;
ffffffffc0200854:	401c                	lw	a5,0(s0)
                cprintf("100 ticks\n");
ffffffffc0200856:	00004517          	auipc	a0,0x4
ffffffffc020085a:	3a250513          	addi	a0,a0,930 # ffffffffc0204bf8 <commands+0x4d0>
                num++;
ffffffffc020085e:	2785                	addiw	a5,a5,1
ffffffffc0200860:	c01c                	sw	a5,0(s0)
                cprintf("100 ticks\n");
ffffffffc0200862:	859ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200866:	b7d1                	j	ffffffffc020082a <interrupt_handler+0x7a>

ffffffffc0200868 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200868:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020086c:	1101                	addi	sp,sp,-32
ffffffffc020086e:	e822                	sd	s0,16(sp)
ffffffffc0200870:	ec06                	sd	ra,24(sp)
ffffffffc0200872:	e426                	sd	s1,8(sp)
ffffffffc0200874:	473d                	li	a4,15
ffffffffc0200876:	842a                	mv	s0,a0
ffffffffc0200878:	02f76c63          	bltu	a4,a5,ffffffffc02008b0 <exception_handler+0x48>
ffffffffc020087c:	00004717          	auipc	a4,0x4
ffffffffc0200880:	5a470713          	addi	a4,a4,1444 # ffffffffc0204e20 <commands+0x6f8>
ffffffffc0200884:	078a                	slli	a5,a5,0x2
ffffffffc0200886:	97ba                	add	a5,a5,a4
ffffffffc0200888:	439c                	lw	a5,0(a5)
ffffffffc020088a:	97ba                	add	a5,a5,a4
ffffffffc020088c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020088e:	00004517          	auipc	a0,0x4
ffffffffc0200892:	57a50513          	addi	a0,a0,1402 # ffffffffc0204e08 <commands+0x6e0>
ffffffffc0200896:	825ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020089a:	8522                	mv	a0,s0
ffffffffc020089c:	c59ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008a0:	84aa                	mv	s1,a0
ffffffffc02008a2:	14051563          	bnez	a0,ffffffffc02009ec <exception_handler+0x184>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a6:	60e2                	ld	ra,24(sp)
ffffffffc02008a8:	6442                	ld	s0,16(sp)
ffffffffc02008aa:	64a2                	ld	s1,8(sp)
ffffffffc02008ac:	6105                	addi	sp,sp,32
ffffffffc02008ae:	8082                	ret
            print_trapframe(tf);
ffffffffc02008b0:	8522                	mv	a0,s0
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02008ba:	bd51                	j	ffffffffc020074e <print_trapframe>
            cprintf("Instruction address misaligned\n");
ffffffffc02008bc:	00004517          	auipc	a0,0x4
ffffffffc02008c0:	39c50513          	addi	a0,a0,924 # ffffffffc0204c58 <commands+0x530>
}
ffffffffc02008c4:	6442                	ld	s0,16(sp)
ffffffffc02008c6:	60e2                	ld	ra,24(sp)
ffffffffc02008c8:	64a2                	ld	s1,8(sp)
ffffffffc02008ca:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008cc:	feeff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008d0:	00004517          	auipc	a0,0x4
ffffffffc02008d4:	3a850513          	addi	a0,a0,936 # ffffffffc0204c78 <commands+0x550>
ffffffffc02008d8:	b7f5                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Exception type: breakpoint\n");
ffffffffc02008da:	00004517          	auipc	a0,0x4
ffffffffc02008de:	3be50513          	addi	a0,a0,958 # ffffffffc0204c98 <commands+0x570>
ffffffffc02008e2:	fd8ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            cprintf("ebreak caught at 0x%lx\n", tf->epc);  // 打印断点指令地址
ffffffffc02008e6:	10843583          	ld	a1,264(s0)
ffffffffc02008ea:	00004517          	auipc	a0,0x4
ffffffffc02008ee:	3ce50513          	addi	a0,a0,974 # ffffffffc0204cb8 <commands+0x590>
ffffffffc02008f2:	fc8ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            tf->epc += 2;
ffffffffc02008f6:	10843783          	ld	a5,264(s0)
ffffffffc02008fa:	0789                	addi	a5,a5,2
ffffffffc02008fc:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200900:	b75d                	j	ffffffffc02008a6 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	3ce50513          	addi	a0,a0,974 # ffffffffc0204cd0 <commands+0x5a8>
ffffffffc020090a:	bf6d                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Load access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	3e450513          	addi	a0,a0,996 # ffffffffc0204cf0 <commands+0x5c8>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d159                	beqz	a0,ffffffffc02008a6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	3de60613          	addi	a2,a2,990 # ffffffffc0204d08 <commands+0x5e0>
ffffffffc0200932:	0ea00593          	li	a1,234
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	eb250513          	addi	a0,a0,-334 # ffffffffc02047e8 <commands+0xc0>
ffffffffc020093e:	a37ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	3e650513          	addi	a0,a0,998 # ffffffffc0204d28 <commands+0x600>
ffffffffc020094a:	bfad                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Store/AMO access fault\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	3f450513          	addi	a0,a0,1012 # ffffffffc0204d40 <commands+0x618>
ffffffffc0200954:	f66ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200958:	8522                	mv	a0,s0
ffffffffc020095a:	b9bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020095e:	84aa                	mv	s1,a0
ffffffffc0200960:	d139                	beqz	a0,ffffffffc02008a6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200962:	8522                	mv	a0,s0
ffffffffc0200964:	debff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200968:	86a6                	mv	a3,s1
ffffffffc020096a:	00004617          	auipc	a2,0x4
ffffffffc020096e:	39e60613          	addi	a2,a2,926 # ffffffffc0204d08 <commands+0x5e0>
ffffffffc0200972:	0f400593          	li	a1,244
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	e7250513          	addi	a0,a0,-398 # ffffffffc02047e8 <commands+0xc0>
ffffffffc020097e:	9f7ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	3d650513          	addi	a0,a0,982 # ffffffffc0204d58 <commands+0x630>
ffffffffc020098a:	bf2d                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Environment call from S-mode\n");
ffffffffc020098c:	00004517          	auipc	a0,0x4
ffffffffc0200990:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204d78 <commands+0x650>
ffffffffc0200994:	bf05                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Environment call from H-mode\n");
ffffffffc0200996:	00004517          	auipc	a0,0x4
ffffffffc020099a:	40250513          	addi	a0,a0,1026 # ffffffffc0204d98 <commands+0x670>
ffffffffc020099e:	b71d                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Environment call from M-mode\n");
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	41850513          	addi	a0,a0,1048 # ffffffffc0204db8 <commands+0x690>
ffffffffc02009a8:	bf31                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Instruction page fault\n");
ffffffffc02009aa:	00004517          	auipc	a0,0x4
ffffffffc02009ae:	42e50513          	addi	a0,a0,1070 # ffffffffc0204dd8 <commands+0x6b0>
ffffffffc02009b2:	bf09                	j	ffffffffc02008c4 <exception_handler+0x5c>
            cprintf("Load page fault\n");
ffffffffc02009b4:	00004517          	auipc	a0,0x4
ffffffffc02009b8:	43c50513          	addi	a0,a0,1084 # ffffffffc0204df0 <commands+0x6c8>
ffffffffc02009bc:	efeff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c0:	8522                	mv	a0,s0
ffffffffc02009c2:	b33ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02009c6:	84aa                	mv	s1,a0
ffffffffc02009c8:	ec050fe3          	beqz	a0,ffffffffc02008a6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009cc:	8522                	mv	a0,s0
ffffffffc02009ce:	d81ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d2:	86a6                	mv	a3,s1
ffffffffc02009d4:	00004617          	auipc	a2,0x4
ffffffffc02009d8:	33460613          	addi	a2,a2,820 # ffffffffc0204d08 <commands+0x5e0>
ffffffffc02009dc:	10a00593          	li	a1,266
ffffffffc02009e0:	00004517          	auipc	a0,0x4
ffffffffc02009e4:	e0850513          	addi	a0,a0,-504 # ffffffffc02047e8 <commands+0xc0>
ffffffffc02009e8:	98dff0ef          	jal	ra,ffffffffc0200374 <__panic>
                print_trapframe(tf);
ffffffffc02009ec:	8522                	mv	a0,s0
ffffffffc02009ee:	d61ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009f2:	86a6                	mv	a3,s1
ffffffffc02009f4:	00004617          	auipc	a2,0x4
ffffffffc02009f8:	31460613          	addi	a2,a2,788 # ffffffffc0204d08 <commands+0x5e0>
ffffffffc02009fc:	11100593          	li	a1,273
ffffffffc0200a00:	00004517          	auipc	a0,0x4
ffffffffc0200a04:	de850513          	addi	a0,a0,-536 # ffffffffc02047e8 <commands+0xc0>
ffffffffc0200a08:	96dff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a0c <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a0c:	11853783          	ld	a5,280(a0)
ffffffffc0200a10:	0007c363          	bltz	a5,ffffffffc0200a16 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a14:	bd91                	j	ffffffffc0200868 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a16:	bb69                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc0200a20 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a20:	14011073          	csrw	sscratch,sp
ffffffffc0200a24:	712d                	addi	sp,sp,-288
ffffffffc0200a26:	e406                	sd	ra,8(sp)
ffffffffc0200a28:	ec0e                	sd	gp,24(sp)
ffffffffc0200a2a:	f012                	sd	tp,32(sp)
ffffffffc0200a2c:	f416                	sd	t0,40(sp)
ffffffffc0200a2e:	f81a                	sd	t1,48(sp)
ffffffffc0200a30:	fc1e                	sd	t2,56(sp)
ffffffffc0200a32:	e0a2                	sd	s0,64(sp)
ffffffffc0200a34:	e4a6                	sd	s1,72(sp)
ffffffffc0200a36:	e8aa                	sd	a0,80(sp)
ffffffffc0200a38:	ecae                	sd	a1,88(sp)
ffffffffc0200a3a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a3c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a3e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a40:	fcbe                	sd	a5,120(sp)
ffffffffc0200a42:	e142                	sd	a6,128(sp)
ffffffffc0200a44:	e546                	sd	a7,136(sp)
ffffffffc0200a46:	e94a                	sd	s2,144(sp)
ffffffffc0200a48:	ed4e                	sd	s3,152(sp)
ffffffffc0200a4a:	f152                	sd	s4,160(sp)
ffffffffc0200a4c:	f556                	sd	s5,168(sp)
ffffffffc0200a4e:	f95a                	sd	s6,176(sp)
ffffffffc0200a50:	fd5e                	sd	s7,184(sp)
ffffffffc0200a52:	e1e2                	sd	s8,192(sp)
ffffffffc0200a54:	e5e6                	sd	s9,200(sp)
ffffffffc0200a56:	e9ea                	sd	s10,208(sp)
ffffffffc0200a58:	edee                	sd	s11,216(sp)
ffffffffc0200a5a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a5c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a5e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a60:	fdfe                	sd	t6,248(sp)
ffffffffc0200a62:	14002473          	csrr	s0,sscratch
ffffffffc0200a66:	100024f3          	csrr	s1,sstatus
ffffffffc0200a6a:	14102973          	csrr	s2,sepc
ffffffffc0200a6e:	143029f3          	csrr	s3,stval
ffffffffc0200a72:	14202a73          	csrr	s4,scause
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	e226                	sd	s1,256(sp)
ffffffffc0200a7a:	e64a                	sd	s2,264(sp)
ffffffffc0200a7c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a7e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a80:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a82:	f8bff0ef          	jal	ra,ffffffffc0200a0c <trap>

ffffffffc0200a86 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a86:	6492                	ld	s1,256(sp)
ffffffffc0200a88:	6932                	ld	s2,264(sp)
ffffffffc0200a8a:	10049073          	csrw	sstatus,s1
ffffffffc0200a8e:	14191073          	csrw	sepc,s2
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	61e2                	ld	gp,24(sp)
ffffffffc0200a96:	7202                	ld	tp,32(sp)
ffffffffc0200a98:	72a2                	ld	t0,40(sp)
ffffffffc0200a9a:	7342                	ld	t1,48(sp)
ffffffffc0200a9c:	73e2                	ld	t2,56(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	64a6                	ld	s1,72(sp)
ffffffffc0200aa2:	6546                	ld	a0,80(sp)
ffffffffc0200aa4:	65e6                	ld	a1,88(sp)
ffffffffc0200aa6:	7606                	ld	a2,96(sp)
ffffffffc0200aa8:	76a6                	ld	a3,104(sp)
ffffffffc0200aaa:	7746                	ld	a4,112(sp)
ffffffffc0200aac:	77e6                	ld	a5,120(sp)
ffffffffc0200aae:	680a                	ld	a6,128(sp)
ffffffffc0200ab0:	68aa                	ld	a7,136(sp)
ffffffffc0200ab2:	694a                	ld	s2,144(sp)
ffffffffc0200ab4:	69ea                	ld	s3,152(sp)
ffffffffc0200ab6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ab8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aba:	7b4a                	ld	s6,176(sp)
ffffffffc0200abc:	7bea                	ld	s7,184(sp)
ffffffffc0200abe:	6c0e                	ld	s8,192(sp)
ffffffffc0200ac0:	6cae                	ld	s9,200(sp)
ffffffffc0200ac2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ac4:	6dee                	ld	s11,216(sp)
ffffffffc0200ac6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ac8:	7eae                	ld	t4,232(sp)
ffffffffc0200aca:	7f4e                	ld	t5,240(sp)
ffffffffc0200acc:	7fee                	ld	t6,248(sp)
ffffffffc0200ace:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ad0:	10200073          	sret
	...

ffffffffc0200ae0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae0:	00010797          	auipc	a5,0x10
ffffffffc0200ae4:	56078793          	addi	a5,a5,1376 # ffffffffc0211040 <free_area>
ffffffffc0200ae8:	e79c                	sd	a5,8(a5)
ffffffffc0200aea:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aec:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200af0:	8082                	ret

ffffffffc0200af2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200af2:	00010517          	auipc	a0,0x10
ffffffffc0200af6:	55e56503          	lwu	a0,1374(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200afa:	8082                	ret

ffffffffc0200afc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200afc:	715d                	addi	sp,sp,-80
ffffffffc0200afe:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b00:	00010417          	auipc	s0,0x10
ffffffffc0200b04:	54040413          	addi	s0,s0,1344 # ffffffffc0211040 <free_area>
ffffffffc0200b08:	641c                	ld	a5,8(s0)
ffffffffc0200b0a:	e486                	sd	ra,72(sp)
ffffffffc0200b0c:	fc26                	sd	s1,56(sp)
ffffffffc0200b0e:	f84a                	sd	s2,48(sp)
ffffffffc0200b10:	f44e                	sd	s3,40(sp)
ffffffffc0200b12:	f052                	sd	s4,32(sp)
ffffffffc0200b14:	ec56                	sd	s5,24(sp)
ffffffffc0200b16:	e85a                	sd	s6,16(sp)
ffffffffc0200b18:	e45e                	sd	s7,8(sp)
ffffffffc0200b1a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b1c:	2c878763          	beq	a5,s0,ffffffffc0200dea <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200b20:	4481                	li	s1,0
ffffffffc0200b22:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b24:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b28:	8b09                	andi	a4,a4,2
ffffffffc0200b2a:	2c070463          	beqz	a4,ffffffffc0200df2 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200b2e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b32:	679c                	ld	a5,8(a5)
ffffffffc0200b34:	2905                	addiw	s2,s2,1
ffffffffc0200b36:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b38:	fe8796e3          	bne	a5,s0,ffffffffc0200b24 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b3c:	89a6                	mv	s3,s1
ffffffffc0200b3e:	385000ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0200b42:	71351863          	bne	a0,s3,ffffffffc0201252 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b46:	4505                	li	a0,1
ffffffffc0200b48:	2a9000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200b4c:	8a2a                	mv	s4,a0
ffffffffc0200b4e:	44050263          	beqz	a0,ffffffffc0200f92 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b52:	4505                	li	a0,1
ffffffffc0200b54:	29d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200b58:	89aa                	mv	s3,a0
ffffffffc0200b5a:	70050c63          	beqz	a0,ffffffffc0201272 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b5e:	4505                	li	a0,1
ffffffffc0200b60:	291000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200b64:	8aaa                	mv	s5,a0
ffffffffc0200b66:	4a050663          	beqz	a0,ffffffffc0201012 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b6a:	2b3a0463          	beq	s4,s3,ffffffffc0200e12 <default_check+0x316>
ffffffffc0200b6e:	2aaa0263          	beq	s4,a0,ffffffffc0200e12 <default_check+0x316>
ffffffffc0200b72:	2aa98063          	beq	s3,a0,ffffffffc0200e12 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b76:	000a2783          	lw	a5,0(s4)
ffffffffc0200b7a:	2a079c63          	bnez	a5,ffffffffc0200e32 <default_check+0x336>
ffffffffc0200b7e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b82:	2a079863          	bnez	a5,ffffffffc0200e32 <default_check+0x336>
ffffffffc0200b86:	411c                	lw	a5,0(a0)
ffffffffc0200b88:	2a079563          	bnez	a5,ffffffffc0200e32 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b8c:	00011797          	auipc	a5,0x11
ffffffffc0200b90:	9a47b783          	ld	a5,-1628(a5) # ffffffffc0211530 <pages>
ffffffffc0200b94:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b98:	870d                	srai	a4,a4,0x3
ffffffffc0200b9a:	00006597          	auipc	a1,0x6
ffffffffc0200b9e:	88e5b583          	ld	a1,-1906(a1) # ffffffffc0206428 <error_string+0x38>
ffffffffc0200ba2:	02b70733          	mul	a4,a4,a1
ffffffffc0200ba6:	00006617          	auipc	a2,0x6
ffffffffc0200baa:	88a63603          	ld	a2,-1910(a2) # ffffffffc0206430 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bae:	00011697          	auipc	a3,0x11
ffffffffc0200bb2:	97a6b683          	ld	a3,-1670(a3) # ffffffffc0211528 <npage>
ffffffffc0200bb6:	06b2                	slli	a3,a3,0xc
ffffffffc0200bb8:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bba:	0732                	slli	a4,a4,0xc
ffffffffc0200bbc:	28d77b63          	bgeu	a4,a3,ffffffffc0200e52 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bc0:	40f98733          	sub	a4,s3,a5
ffffffffc0200bc4:	870d                	srai	a4,a4,0x3
ffffffffc0200bc6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bca:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bcc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bce:	4cd77263          	bgeu	a4,a3,ffffffffc0201092 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bd2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bd6:	878d                	srai	a5,a5,0x3
ffffffffc0200bd8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bdc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bde:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200be0:	30d7f963          	bgeu	a5,a3,ffffffffc0200ef2 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200be4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200be6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bea:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bee:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200bf2:	e400                	sd	s0,8(s0)
ffffffffc0200bf4:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200bf6:	00010797          	auipc	a5,0x10
ffffffffc0200bfa:	4407ad23          	sw	zero,1114(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bfe:	1f3000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c02:	2c051863          	bnez	a0,ffffffffc0200ed2 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200c06:	4585                	li	a1,1
ffffffffc0200c08:	8552                	mv	a0,s4
ffffffffc0200c0a:	279000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p1);
ffffffffc0200c0e:	4585                	li	a1,1
ffffffffc0200c10:	854e                	mv	a0,s3
ffffffffc0200c12:	271000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p2);
ffffffffc0200c16:	4585                	li	a1,1
ffffffffc0200c18:	8556                	mv	a0,s5
ffffffffc0200c1a:	269000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c1e:	4818                	lw	a4,16(s0)
ffffffffc0200c20:	478d                	li	a5,3
ffffffffc0200c22:	28f71863          	bne	a4,a5,ffffffffc0200eb2 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c26:	4505                	li	a0,1
ffffffffc0200c28:	1c9000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c2c:	89aa                	mv	s3,a0
ffffffffc0200c2e:	26050263          	beqz	a0,ffffffffc0200e92 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	1bd000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c38:	8aaa                	mv	s5,a0
ffffffffc0200c3a:	3a050c63          	beqz	a0,ffffffffc0200ff2 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c3e:	4505                	li	a0,1
ffffffffc0200c40:	1b1000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c44:	8a2a                	mv	s4,a0
ffffffffc0200c46:	38050663          	beqz	a0,ffffffffc0200fd2 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c4a:	4505                	li	a0,1
ffffffffc0200c4c:	1a5000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c50:	36051163          	bnez	a0,ffffffffc0200fb2 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c54:	4585                	li	a1,1
ffffffffc0200c56:	854e                	mv	a0,s3
ffffffffc0200c58:	22b000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c5c:	641c                	ld	a5,8(s0)
ffffffffc0200c5e:	20878a63          	beq	a5,s0,ffffffffc0200e72 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c62:	4505                	li	a0,1
ffffffffc0200c64:	18d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c68:	30a99563          	bne	s3,a0,ffffffffc0200f72 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c6c:	4505                	li	a0,1
ffffffffc0200c6e:	183000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200c72:	2e051063          	bnez	a0,ffffffffc0200f52 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c76:	481c                	lw	a5,16(s0)
ffffffffc0200c78:	2a079d63          	bnez	a5,ffffffffc0200f32 <default_check+0x436>
    free_page(p);
ffffffffc0200c7c:	854e                	mv	a0,s3
ffffffffc0200c7e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c80:	01843023          	sd	s8,0(s0)
ffffffffc0200c84:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c88:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c8c:	1f7000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p1);
ffffffffc0200c90:	4585                	li	a1,1
ffffffffc0200c92:	8556                	mv	a0,s5
ffffffffc0200c94:	1ef000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p2);
ffffffffc0200c98:	4585                	li	a1,1
ffffffffc0200c9a:	8552                	mv	a0,s4
ffffffffc0200c9c:	1e7000ef          	jal	ra,ffffffffc0201682 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ca0:	4515                	li	a0,5
ffffffffc0200ca2:	14f000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200ca6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ca8:	26050563          	beqz	a0,ffffffffc0200f12 <default_check+0x416>
ffffffffc0200cac:	651c                	ld	a5,8(a0)
ffffffffc0200cae:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200cb0:	8b85                	andi	a5,a5,1
ffffffffc0200cb2:	54079063          	bnez	a5,ffffffffc02011f2 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cb6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cb8:	00043b03          	ld	s6,0(s0)
ffffffffc0200cbc:	00843a83          	ld	s5,8(s0)
ffffffffc0200cc0:	e000                	sd	s0,0(s0)
ffffffffc0200cc2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cc4:	12d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200cc8:	50051563          	bnez	a0,ffffffffc02011d2 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200ccc:	09098a13          	addi	s4,s3,144
ffffffffc0200cd0:	8552                	mv	a0,s4
ffffffffc0200cd2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200cd4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200cd8:	00010797          	auipc	a5,0x10
ffffffffc0200cdc:	3607ac23          	sw	zero,888(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200ce0:	1a3000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ce4:	4511                	li	a0,4
ffffffffc0200ce6:	10b000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200cea:	4c051463          	bnez	a0,ffffffffc02011b2 <default_check+0x6b6>
ffffffffc0200cee:	0989b783          	ld	a5,152(s3)
ffffffffc0200cf2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200cf4:	8b85                	andi	a5,a5,1
ffffffffc0200cf6:	48078e63          	beqz	a5,ffffffffc0201192 <default_check+0x696>
ffffffffc0200cfa:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cfe:	478d                	li	a5,3
ffffffffc0200d00:	48f71963          	bne	a4,a5,ffffffffc0201192 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d04:	450d                	li	a0,3
ffffffffc0200d06:	0eb000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d0a:	8c2a                	mv	s8,a0
ffffffffc0200d0c:	46050363          	beqz	a0,ffffffffc0201172 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200d10:	4505                	li	a0,1
ffffffffc0200d12:	0df000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d16:	42051e63          	bnez	a0,ffffffffc0201152 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200d1a:	418a1c63          	bne	s4,s8,ffffffffc0201132 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d1e:	4585                	li	a1,1
ffffffffc0200d20:	854e                	mv	a0,s3
ffffffffc0200d22:	161000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d26:	458d                	li	a1,3
ffffffffc0200d28:	8552                	mv	a0,s4
ffffffffc0200d2a:	159000ef          	jal	ra,ffffffffc0201682 <free_pages>
ffffffffc0200d2e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d32:	04898c13          	addi	s8,s3,72
ffffffffc0200d36:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d38:	8b85                	andi	a5,a5,1
ffffffffc0200d3a:	3c078c63          	beqz	a5,ffffffffc0201112 <default_check+0x616>
ffffffffc0200d3e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d42:	4785                	li	a5,1
ffffffffc0200d44:	3cf71763          	bne	a4,a5,ffffffffc0201112 <default_check+0x616>
ffffffffc0200d48:	008a3783          	ld	a5,8(s4)
ffffffffc0200d4c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d4e:	8b85                	andi	a5,a5,1
ffffffffc0200d50:	3a078163          	beqz	a5,ffffffffc02010f2 <default_check+0x5f6>
ffffffffc0200d54:	018a2703          	lw	a4,24(s4)
ffffffffc0200d58:	478d                	li	a5,3
ffffffffc0200d5a:	38f71c63          	bne	a4,a5,ffffffffc02010f2 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d5e:	4505                	li	a0,1
ffffffffc0200d60:	091000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d64:	36a99763          	bne	s3,a0,ffffffffc02010d2 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d68:	4585                	li	a1,1
ffffffffc0200d6a:	119000ef          	jal	ra,ffffffffc0201682 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d6e:	4509                	li	a0,2
ffffffffc0200d70:	081000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d74:	32aa1f63          	bne	s4,a0,ffffffffc02010b2 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d78:	4589                	li	a1,2
ffffffffc0200d7a:	109000ef          	jal	ra,ffffffffc0201682 <free_pages>
    free_page(p2);
ffffffffc0200d7e:	4585                	li	a1,1
ffffffffc0200d80:	8562                	mv	a0,s8
ffffffffc0200d82:	101000ef          	jal	ra,ffffffffc0201682 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d86:	4515                	li	a0,5
ffffffffc0200d88:	069000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d8c:	89aa                	mv	s3,a0
ffffffffc0200d8e:	48050263          	beqz	a0,ffffffffc0201212 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d92:	4505                	li	a0,1
ffffffffc0200d94:	05d000ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0200d98:	2c051d63          	bnez	a0,ffffffffc0201072 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d9c:	481c                	lw	a5,16(s0)
ffffffffc0200d9e:	2a079a63          	bnez	a5,ffffffffc0201052 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200da2:	4595                	li	a1,5
ffffffffc0200da4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200da6:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200daa:	01643023          	sd	s6,0(s0)
ffffffffc0200dae:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200db2:	0d1000ef          	jal	ra,ffffffffc0201682 <free_pages>
    return listelm->next;
ffffffffc0200db6:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200db8:	00878963          	beq	a5,s0,ffffffffc0200dca <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dbc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200dc0:	679c                	ld	a5,8(a5)
ffffffffc0200dc2:	397d                	addiw	s2,s2,-1
ffffffffc0200dc4:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dc6:	fe879be3          	bne	a5,s0,ffffffffc0200dbc <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200dca:	26091463          	bnez	s2,ffffffffc0201032 <default_check+0x536>
    assert(total == 0);
ffffffffc0200dce:	46049263          	bnez	s1,ffffffffc0201232 <default_check+0x736>
}
ffffffffc0200dd2:	60a6                	ld	ra,72(sp)
ffffffffc0200dd4:	6406                	ld	s0,64(sp)
ffffffffc0200dd6:	74e2                	ld	s1,56(sp)
ffffffffc0200dd8:	7942                	ld	s2,48(sp)
ffffffffc0200dda:	79a2                	ld	s3,40(sp)
ffffffffc0200ddc:	7a02                	ld	s4,32(sp)
ffffffffc0200dde:	6ae2                	ld	s5,24(sp)
ffffffffc0200de0:	6b42                	ld	s6,16(sp)
ffffffffc0200de2:	6ba2                	ld	s7,8(sp)
ffffffffc0200de4:	6c02                	ld	s8,0(sp)
ffffffffc0200de6:	6161                	addi	sp,sp,80
ffffffffc0200de8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dea:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dec:	4481                	li	s1,0
ffffffffc0200dee:	4901                	li	s2,0
ffffffffc0200df0:	b3b9                	j	ffffffffc0200b3e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200df2:	00004697          	auipc	a3,0x4
ffffffffc0200df6:	06e68693          	addi	a3,a3,110 # ffffffffc0204e60 <commands+0x738>
ffffffffc0200dfa:	00004617          	auipc	a2,0x4
ffffffffc0200dfe:	07660613          	addi	a2,a2,118 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200e02:	0f000593          	li	a1,240
ffffffffc0200e06:	00004517          	auipc	a0,0x4
ffffffffc0200e0a:	08250513          	addi	a0,a0,130 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200e0e:	d66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e12:	00004697          	auipc	a3,0x4
ffffffffc0200e16:	10e68693          	addi	a3,a3,270 # ffffffffc0204f20 <commands+0x7f8>
ffffffffc0200e1a:	00004617          	auipc	a2,0x4
ffffffffc0200e1e:	05660613          	addi	a2,a2,86 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200e22:	0bd00593          	li	a1,189
ffffffffc0200e26:	00004517          	auipc	a0,0x4
ffffffffc0200e2a:	06250513          	addi	a0,a0,98 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200e2e:	d46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	11668693          	addi	a3,a3,278 # ffffffffc0204f48 <commands+0x820>
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	03660613          	addi	a2,a2,54 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200e42:	0be00593          	li	a1,190
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	04250513          	addi	a0,a0,66 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200e4e:	d26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e52:	00004697          	auipc	a3,0x4
ffffffffc0200e56:	13668693          	addi	a3,a3,310 # ffffffffc0204f88 <commands+0x860>
ffffffffc0200e5a:	00004617          	auipc	a2,0x4
ffffffffc0200e5e:	01660613          	addi	a2,a2,22 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200e62:	0c000593          	li	a1,192
ffffffffc0200e66:	00004517          	auipc	a0,0x4
ffffffffc0200e6a:	02250513          	addi	a0,a0,34 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200e6e:	d06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e72:	00004697          	auipc	a3,0x4
ffffffffc0200e76:	19e68693          	addi	a3,a3,414 # ffffffffc0205010 <commands+0x8e8>
ffffffffc0200e7a:	00004617          	auipc	a2,0x4
ffffffffc0200e7e:	ff660613          	addi	a2,a2,-10 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200e82:	0d900593          	li	a1,217
ffffffffc0200e86:	00004517          	auipc	a0,0x4
ffffffffc0200e8a:	00250513          	addi	a0,a0,2 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200e8e:	ce6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e92:	00004697          	auipc	a3,0x4
ffffffffc0200e96:	02e68693          	addi	a3,a3,46 # ffffffffc0204ec0 <commands+0x798>
ffffffffc0200e9a:	00004617          	auipc	a2,0x4
ffffffffc0200e9e:	fd660613          	addi	a2,a2,-42 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200ea2:	0d200593          	li	a1,210
ffffffffc0200ea6:	00004517          	auipc	a0,0x4
ffffffffc0200eaa:	fe250513          	addi	a0,a0,-30 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200eae:	cc6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200eb2:	00004697          	auipc	a3,0x4
ffffffffc0200eb6:	14e68693          	addi	a3,a3,334 # ffffffffc0205000 <commands+0x8d8>
ffffffffc0200eba:	00004617          	auipc	a2,0x4
ffffffffc0200ebe:	fb660613          	addi	a2,a2,-74 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200ec2:	0d000593          	li	a1,208
ffffffffc0200ec6:	00004517          	auipc	a0,0x4
ffffffffc0200eca:	fc250513          	addi	a0,a0,-62 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200ece:	ca6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ed2:	00004697          	auipc	a3,0x4
ffffffffc0200ed6:	11668693          	addi	a3,a3,278 # ffffffffc0204fe8 <commands+0x8c0>
ffffffffc0200eda:	00004617          	auipc	a2,0x4
ffffffffc0200ede:	f9660613          	addi	a2,a2,-106 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200ee2:	0cb00593          	li	a1,203
ffffffffc0200ee6:	00004517          	auipc	a0,0x4
ffffffffc0200eea:	fa250513          	addi	a0,a0,-94 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200eee:	c86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ef2:	00004697          	auipc	a3,0x4
ffffffffc0200ef6:	0d668693          	addi	a3,a3,214 # ffffffffc0204fc8 <commands+0x8a0>
ffffffffc0200efa:	00004617          	auipc	a2,0x4
ffffffffc0200efe:	f7660613          	addi	a2,a2,-138 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200f02:	0c200593          	li	a1,194
ffffffffc0200f06:	00004517          	auipc	a0,0x4
ffffffffc0200f0a:	f8250513          	addi	a0,a0,-126 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200f0e:	c66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f12:	00004697          	auipc	a3,0x4
ffffffffc0200f16:	14668693          	addi	a3,a3,326 # ffffffffc0205058 <commands+0x930>
ffffffffc0200f1a:	00004617          	auipc	a2,0x4
ffffffffc0200f1e:	f5660613          	addi	a2,a2,-170 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200f22:	0f800593          	li	a1,248
ffffffffc0200f26:	00004517          	auipc	a0,0x4
ffffffffc0200f2a:	f6250513          	addi	a0,a0,-158 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200f2e:	c46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f32:	00004697          	auipc	a3,0x4
ffffffffc0200f36:	11668693          	addi	a3,a3,278 # ffffffffc0205048 <commands+0x920>
ffffffffc0200f3a:	00004617          	auipc	a2,0x4
ffffffffc0200f3e:	f3660613          	addi	a2,a2,-202 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200f42:	0df00593          	li	a1,223
ffffffffc0200f46:	00004517          	auipc	a0,0x4
ffffffffc0200f4a:	f4250513          	addi	a0,a0,-190 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200f4e:	c26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f52:	00004697          	auipc	a3,0x4
ffffffffc0200f56:	09668693          	addi	a3,a3,150 # ffffffffc0204fe8 <commands+0x8c0>
ffffffffc0200f5a:	00004617          	auipc	a2,0x4
ffffffffc0200f5e:	f1660613          	addi	a2,a2,-234 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200f62:	0dd00593          	li	a1,221
ffffffffc0200f66:	00004517          	auipc	a0,0x4
ffffffffc0200f6a:	f2250513          	addi	a0,a0,-222 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200f6e:	c06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f72:	00004697          	auipc	a3,0x4
ffffffffc0200f76:	0b668693          	addi	a3,a3,182 # ffffffffc0205028 <commands+0x900>
ffffffffc0200f7a:	00004617          	auipc	a2,0x4
ffffffffc0200f7e:	ef660613          	addi	a2,a2,-266 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200f82:	0dc00593          	li	a1,220
ffffffffc0200f86:	00004517          	auipc	a0,0x4
ffffffffc0200f8a:	f0250513          	addi	a0,a0,-254 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200f8e:	be6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f92:	00004697          	auipc	a3,0x4
ffffffffc0200f96:	f2e68693          	addi	a3,a3,-210 # ffffffffc0204ec0 <commands+0x798>
ffffffffc0200f9a:	00004617          	auipc	a2,0x4
ffffffffc0200f9e:	ed660613          	addi	a2,a2,-298 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200fa2:	0b900593          	li	a1,185
ffffffffc0200fa6:	00004517          	auipc	a0,0x4
ffffffffc0200faa:	ee250513          	addi	a0,a0,-286 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200fae:	bc6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb2:	00004697          	auipc	a3,0x4
ffffffffc0200fb6:	03668693          	addi	a3,a3,54 # ffffffffc0204fe8 <commands+0x8c0>
ffffffffc0200fba:	00004617          	auipc	a2,0x4
ffffffffc0200fbe:	eb660613          	addi	a2,a2,-330 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200fc2:	0d600593          	li	a1,214
ffffffffc0200fc6:	00004517          	auipc	a0,0x4
ffffffffc0200fca:	ec250513          	addi	a0,a0,-318 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200fce:	ba6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fd2:	00004697          	auipc	a3,0x4
ffffffffc0200fd6:	f2e68693          	addi	a3,a3,-210 # ffffffffc0204f00 <commands+0x7d8>
ffffffffc0200fda:	00004617          	auipc	a2,0x4
ffffffffc0200fde:	e9660613          	addi	a2,a2,-362 # ffffffffc0204e70 <commands+0x748>
ffffffffc0200fe2:	0d400593          	li	a1,212
ffffffffc0200fe6:	00004517          	auipc	a0,0x4
ffffffffc0200fea:	ea250513          	addi	a0,a0,-350 # ffffffffc0204e88 <commands+0x760>
ffffffffc0200fee:	b86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ff2:	00004697          	auipc	a3,0x4
ffffffffc0200ff6:	eee68693          	addi	a3,a3,-274 # ffffffffc0204ee0 <commands+0x7b8>
ffffffffc0200ffa:	00004617          	auipc	a2,0x4
ffffffffc0200ffe:	e7660613          	addi	a2,a2,-394 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201002:	0d300593          	li	a1,211
ffffffffc0201006:	00004517          	auipc	a0,0x4
ffffffffc020100a:	e8250513          	addi	a0,a0,-382 # ffffffffc0204e88 <commands+0x760>
ffffffffc020100e:	b66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201012:	00004697          	auipc	a3,0x4
ffffffffc0201016:	eee68693          	addi	a3,a3,-274 # ffffffffc0204f00 <commands+0x7d8>
ffffffffc020101a:	00004617          	auipc	a2,0x4
ffffffffc020101e:	e5660613          	addi	a2,a2,-426 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201022:	0bb00593          	li	a1,187
ffffffffc0201026:	00004517          	auipc	a0,0x4
ffffffffc020102a:	e6250513          	addi	a0,a0,-414 # ffffffffc0204e88 <commands+0x760>
ffffffffc020102e:	b46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201032:	00004697          	auipc	a3,0x4
ffffffffc0201036:	17668693          	addi	a3,a3,374 # ffffffffc02051a8 <commands+0xa80>
ffffffffc020103a:	00004617          	auipc	a2,0x4
ffffffffc020103e:	e3660613          	addi	a2,a2,-458 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201042:	12500593          	li	a1,293
ffffffffc0201046:	00004517          	auipc	a0,0x4
ffffffffc020104a:	e4250513          	addi	a0,a0,-446 # ffffffffc0204e88 <commands+0x760>
ffffffffc020104e:	b26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201052:	00004697          	auipc	a3,0x4
ffffffffc0201056:	ff668693          	addi	a3,a3,-10 # ffffffffc0205048 <commands+0x920>
ffffffffc020105a:	00004617          	auipc	a2,0x4
ffffffffc020105e:	e1660613          	addi	a2,a2,-490 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201062:	11a00593          	li	a1,282
ffffffffc0201066:	00004517          	auipc	a0,0x4
ffffffffc020106a:	e2250513          	addi	a0,a0,-478 # ffffffffc0204e88 <commands+0x760>
ffffffffc020106e:	b06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201072:	00004697          	auipc	a3,0x4
ffffffffc0201076:	f7668693          	addi	a3,a3,-138 # ffffffffc0204fe8 <commands+0x8c0>
ffffffffc020107a:	00004617          	auipc	a2,0x4
ffffffffc020107e:	df660613          	addi	a2,a2,-522 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201082:	11800593          	li	a1,280
ffffffffc0201086:	00004517          	auipc	a0,0x4
ffffffffc020108a:	e0250513          	addi	a0,a0,-510 # ffffffffc0204e88 <commands+0x760>
ffffffffc020108e:	ae6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201092:	00004697          	auipc	a3,0x4
ffffffffc0201096:	f1668693          	addi	a3,a3,-234 # ffffffffc0204fa8 <commands+0x880>
ffffffffc020109a:	00004617          	auipc	a2,0x4
ffffffffc020109e:	dd660613          	addi	a2,a2,-554 # ffffffffc0204e70 <commands+0x748>
ffffffffc02010a2:	0c100593          	li	a1,193
ffffffffc02010a6:	00004517          	auipc	a0,0x4
ffffffffc02010aa:	de250513          	addi	a0,a0,-542 # ffffffffc0204e88 <commands+0x760>
ffffffffc02010ae:	ac6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010b2:	00004697          	auipc	a3,0x4
ffffffffc02010b6:	0b668693          	addi	a3,a3,182 # ffffffffc0205168 <commands+0xa40>
ffffffffc02010ba:	00004617          	auipc	a2,0x4
ffffffffc02010be:	db660613          	addi	a2,a2,-586 # ffffffffc0204e70 <commands+0x748>
ffffffffc02010c2:	11200593          	li	a1,274
ffffffffc02010c6:	00004517          	auipc	a0,0x4
ffffffffc02010ca:	dc250513          	addi	a0,a0,-574 # ffffffffc0204e88 <commands+0x760>
ffffffffc02010ce:	aa6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010d2:	00004697          	auipc	a3,0x4
ffffffffc02010d6:	07668693          	addi	a3,a3,118 # ffffffffc0205148 <commands+0xa20>
ffffffffc02010da:	00004617          	auipc	a2,0x4
ffffffffc02010de:	d9660613          	addi	a2,a2,-618 # ffffffffc0204e70 <commands+0x748>
ffffffffc02010e2:	11000593          	li	a1,272
ffffffffc02010e6:	00004517          	auipc	a0,0x4
ffffffffc02010ea:	da250513          	addi	a0,a0,-606 # ffffffffc0204e88 <commands+0x760>
ffffffffc02010ee:	a86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010f2:	00004697          	auipc	a3,0x4
ffffffffc02010f6:	02e68693          	addi	a3,a3,46 # ffffffffc0205120 <commands+0x9f8>
ffffffffc02010fa:	00004617          	auipc	a2,0x4
ffffffffc02010fe:	d7660613          	addi	a2,a2,-650 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201102:	10e00593          	li	a1,270
ffffffffc0201106:	00004517          	auipc	a0,0x4
ffffffffc020110a:	d8250513          	addi	a0,a0,-638 # ffffffffc0204e88 <commands+0x760>
ffffffffc020110e:	a66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201112:	00004697          	auipc	a3,0x4
ffffffffc0201116:	fe668693          	addi	a3,a3,-26 # ffffffffc02050f8 <commands+0x9d0>
ffffffffc020111a:	00004617          	auipc	a2,0x4
ffffffffc020111e:	d5660613          	addi	a2,a2,-682 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201122:	10d00593          	li	a1,269
ffffffffc0201126:	00004517          	auipc	a0,0x4
ffffffffc020112a:	d6250513          	addi	a0,a0,-670 # ffffffffc0204e88 <commands+0x760>
ffffffffc020112e:	a46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201132:	00004697          	auipc	a3,0x4
ffffffffc0201136:	fb668693          	addi	a3,a3,-74 # ffffffffc02050e8 <commands+0x9c0>
ffffffffc020113a:	00004617          	auipc	a2,0x4
ffffffffc020113e:	d3660613          	addi	a2,a2,-714 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201142:	10800593          	li	a1,264
ffffffffc0201146:	00004517          	auipc	a0,0x4
ffffffffc020114a:	d4250513          	addi	a0,a0,-702 # ffffffffc0204e88 <commands+0x760>
ffffffffc020114e:	a26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201152:	00004697          	auipc	a3,0x4
ffffffffc0201156:	e9668693          	addi	a3,a3,-362 # ffffffffc0204fe8 <commands+0x8c0>
ffffffffc020115a:	00004617          	auipc	a2,0x4
ffffffffc020115e:	d1660613          	addi	a2,a2,-746 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201162:	10700593          	li	a1,263
ffffffffc0201166:	00004517          	auipc	a0,0x4
ffffffffc020116a:	d2250513          	addi	a0,a0,-734 # ffffffffc0204e88 <commands+0x760>
ffffffffc020116e:	a06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201172:	00004697          	auipc	a3,0x4
ffffffffc0201176:	f5668693          	addi	a3,a3,-170 # ffffffffc02050c8 <commands+0x9a0>
ffffffffc020117a:	00004617          	auipc	a2,0x4
ffffffffc020117e:	cf660613          	addi	a2,a2,-778 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201182:	10600593          	li	a1,262
ffffffffc0201186:	00004517          	auipc	a0,0x4
ffffffffc020118a:	d0250513          	addi	a0,a0,-766 # ffffffffc0204e88 <commands+0x760>
ffffffffc020118e:	9e6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201192:	00004697          	auipc	a3,0x4
ffffffffc0201196:	f0668693          	addi	a3,a3,-250 # ffffffffc0205098 <commands+0x970>
ffffffffc020119a:	00004617          	auipc	a2,0x4
ffffffffc020119e:	cd660613          	addi	a2,a2,-810 # ffffffffc0204e70 <commands+0x748>
ffffffffc02011a2:	10500593          	li	a1,261
ffffffffc02011a6:	00004517          	auipc	a0,0x4
ffffffffc02011aa:	ce250513          	addi	a0,a0,-798 # ffffffffc0204e88 <commands+0x760>
ffffffffc02011ae:	9c6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011b2:	00004697          	auipc	a3,0x4
ffffffffc02011b6:	ece68693          	addi	a3,a3,-306 # ffffffffc0205080 <commands+0x958>
ffffffffc02011ba:	00004617          	auipc	a2,0x4
ffffffffc02011be:	cb660613          	addi	a2,a2,-842 # ffffffffc0204e70 <commands+0x748>
ffffffffc02011c2:	10400593          	li	a1,260
ffffffffc02011c6:	00004517          	auipc	a0,0x4
ffffffffc02011ca:	cc250513          	addi	a0,a0,-830 # ffffffffc0204e88 <commands+0x760>
ffffffffc02011ce:	9a6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d2:	00004697          	auipc	a3,0x4
ffffffffc02011d6:	e1668693          	addi	a3,a3,-490 # ffffffffc0204fe8 <commands+0x8c0>
ffffffffc02011da:	00004617          	auipc	a2,0x4
ffffffffc02011de:	c9660613          	addi	a2,a2,-874 # ffffffffc0204e70 <commands+0x748>
ffffffffc02011e2:	0fe00593          	li	a1,254
ffffffffc02011e6:	00004517          	auipc	a0,0x4
ffffffffc02011ea:	ca250513          	addi	a0,a0,-862 # ffffffffc0204e88 <commands+0x760>
ffffffffc02011ee:	986ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011f2:	00004697          	auipc	a3,0x4
ffffffffc02011f6:	e7668693          	addi	a3,a3,-394 # ffffffffc0205068 <commands+0x940>
ffffffffc02011fa:	00004617          	auipc	a2,0x4
ffffffffc02011fe:	c7660613          	addi	a2,a2,-906 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201202:	0f900593          	li	a1,249
ffffffffc0201206:	00004517          	auipc	a0,0x4
ffffffffc020120a:	c8250513          	addi	a0,a0,-894 # ffffffffc0204e88 <commands+0x760>
ffffffffc020120e:	966ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201212:	00004697          	auipc	a3,0x4
ffffffffc0201216:	f7668693          	addi	a3,a3,-138 # ffffffffc0205188 <commands+0xa60>
ffffffffc020121a:	00004617          	auipc	a2,0x4
ffffffffc020121e:	c5660613          	addi	a2,a2,-938 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201222:	11700593          	li	a1,279
ffffffffc0201226:	00004517          	auipc	a0,0x4
ffffffffc020122a:	c6250513          	addi	a0,a0,-926 # ffffffffc0204e88 <commands+0x760>
ffffffffc020122e:	946ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201232:	00004697          	auipc	a3,0x4
ffffffffc0201236:	f8668693          	addi	a3,a3,-122 # ffffffffc02051b8 <commands+0xa90>
ffffffffc020123a:	00004617          	auipc	a2,0x4
ffffffffc020123e:	c3660613          	addi	a2,a2,-970 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201242:	12600593          	li	a1,294
ffffffffc0201246:	00004517          	auipc	a0,0x4
ffffffffc020124a:	c4250513          	addi	a0,a0,-958 # ffffffffc0204e88 <commands+0x760>
ffffffffc020124e:	926ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201252:	00004697          	auipc	a3,0x4
ffffffffc0201256:	c4e68693          	addi	a3,a3,-946 # ffffffffc0204ea0 <commands+0x778>
ffffffffc020125a:	00004617          	auipc	a2,0x4
ffffffffc020125e:	c1660613          	addi	a2,a2,-1002 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201262:	0f300593          	li	a1,243
ffffffffc0201266:	00004517          	auipc	a0,0x4
ffffffffc020126a:	c2250513          	addi	a0,a0,-990 # ffffffffc0204e88 <commands+0x760>
ffffffffc020126e:	906ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201272:	00004697          	auipc	a3,0x4
ffffffffc0201276:	c6e68693          	addi	a3,a3,-914 # ffffffffc0204ee0 <commands+0x7b8>
ffffffffc020127a:	00004617          	auipc	a2,0x4
ffffffffc020127e:	bf660613          	addi	a2,a2,-1034 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201282:	0ba00593          	li	a1,186
ffffffffc0201286:	00004517          	auipc	a0,0x4
ffffffffc020128a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0204e88 <commands+0x760>
ffffffffc020128e:	8e6ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201292 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201292:	1141                	addi	sp,sp,-16
ffffffffc0201294:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201296:	14058a63          	beqz	a1,ffffffffc02013ea <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020129a:	00359693          	slli	a3,a1,0x3
ffffffffc020129e:	96ae                	add	a3,a3,a1
ffffffffc02012a0:	068e                	slli	a3,a3,0x3
ffffffffc02012a2:	96aa                	add	a3,a3,a0
ffffffffc02012a4:	87aa                	mv	a5,a0
ffffffffc02012a6:	02d50263          	beq	a0,a3,ffffffffc02012ca <default_free_pages+0x38>
ffffffffc02012aa:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012ac:	8b05                	andi	a4,a4,1
ffffffffc02012ae:	10071e63          	bnez	a4,ffffffffc02013ca <default_free_pages+0x138>
ffffffffc02012b2:	6798                	ld	a4,8(a5)
ffffffffc02012b4:	8b09                	andi	a4,a4,2
ffffffffc02012b6:	10071a63          	bnez	a4,ffffffffc02013ca <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02012ba:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012be:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012c2:	04878793          	addi	a5,a5,72
ffffffffc02012c6:	fed792e3          	bne	a5,a3,ffffffffc02012aa <default_free_pages+0x18>
    base->property = n;
ffffffffc02012ca:	2581                	sext.w	a1,a1
ffffffffc02012cc:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012ce:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012d2:	4789                	li	a5,2
ffffffffc02012d4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012d8:	00010697          	auipc	a3,0x10
ffffffffc02012dc:	d6868693          	addi	a3,a3,-664 # ffffffffc0211040 <free_area>
ffffffffc02012e0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012e2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012e4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012e8:	9db9                	addw	a1,a1,a4
ffffffffc02012ea:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012ec:	0ad78863          	beq	a5,a3,ffffffffc020139c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012f0:	fe078713          	addi	a4,a5,-32
ffffffffc02012f4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012f8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012fa:	00e56a63          	bltu	a0,a4,ffffffffc020130e <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02012fe:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201300:	06d70263          	beq	a4,a3,ffffffffc0201364 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201304:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201306:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020130a:	fee57ae3          	bgeu	a0,a4,ffffffffc02012fe <default_free_pages+0x6c>
ffffffffc020130e:	c199                	beqz	a1,ffffffffc0201314 <default_free_pages+0x82>
ffffffffc0201310:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201314:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201316:	e390                	sd	a2,0(a5)
ffffffffc0201318:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020131a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020131c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020131e:	02d70063          	beq	a4,a3,ffffffffc020133e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201322:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201326:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc020132a:	02081613          	slli	a2,a6,0x20
ffffffffc020132e:	9201                	srli	a2,a2,0x20
ffffffffc0201330:	00361793          	slli	a5,a2,0x3
ffffffffc0201334:	97b2                	add	a5,a5,a2
ffffffffc0201336:	078e                	slli	a5,a5,0x3
ffffffffc0201338:	97ae                	add	a5,a5,a1
ffffffffc020133a:	02f50f63          	beq	a0,a5,ffffffffc0201378 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020133e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201340:	00d70f63          	beq	a4,a3,ffffffffc020135e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201344:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201346:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020134a:	02059613          	slli	a2,a1,0x20
ffffffffc020134e:	9201                	srli	a2,a2,0x20
ffffffffc0201350:	00361793          	slli	a5,a2,0x3
ffffffffc0201354:	97b2                	add	a5,a5,a2
ffffffffc0201356:	078e                	slli	a5,a5,0x3
ffffffffc0201358:	97aa                	add	a5,a5,a0
ffffffffc020135a:	04f68863          	beq	a3,a5,ffffffffc02013aa <default_free_pages+0x118>
}
ffffffffc020135e:	60a2                	ld	ra,8(sp)
ffffffffc0201360:	0141                	addi	sp,sp,16
ffffffffc0201362:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201364:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201366:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201368:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020136a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136c:	02d70563          	beq	a4,a3,ffffffffc0201396 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201370:	8832                	mv	a6,a2
ffffffffc0201372:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201374:	87ba                	mv	a5,a4
ffffffffc0201376:	bf41                	j	ffffffffc0201306 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201378:	4d1c                	lw	a5,24(a0)
ffffffffc020137a:	0107883b          	addw	a6,a5,a6
ffffffffc020137e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201382:	57f5                	li	a5,-3
ffffffffc0201384:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201388:	7110                	ld	a2,32(a0)
ffffffffc020138a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020138c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020138e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201390:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201392:	e390                	sd	a2,0(a5)
ffffffffc0201394:	b775                	j	ffffffffc0201340 <default_free_pages+0xae>
ffffffffc0201396:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201398:	873e                	mv	a4,a5
ffffffffc020139a:	b761                	j	ffffffffc0201322 <default_free_pages+0x90>
}
ffffffffc020139c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020139e:	e390                	sd	a2,0(a5)
ffffffffc02013a0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013a2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013a4:	f11c                	sd	a5,32(a0)
ffffffffc02013a6:	0141                	addi	sp,sp,16
ffffffffc02013a8:	8082                	ret
            base->property += p->property;
ffffffffc02013aa:	ff872783          	lw	a5,-8(a4)
ffffffffc02013ae:	fe870693          	addi	a3,a4,-24
ffffffffc02013b2:	9dbd                	addw	a1,a1,a5
ffffffffc02013b4:	cd0c                	sw	a1,24(a0)
ffffffffc02013b6:	57f5                	li	a5,-3
ffffffffc02013b8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013bc:	6314                	ld	a3,0(a4)
ffffffffc02013be:	671c                	ld	a5,8(a4)
}
ffffffffc02013c0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013c2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013c4:	e394                	sd	a3,0(a5)
ffffffffc02013c6:	0141                	addi	sp,sp,16
ffffffffc02013c8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013ca:	00004697          	auipc	a3,0x4
ffffffffc02013ce:	e0668693          	addi	a3,a3,-506 # ffffffffc02051d0 <commands+0xaa8>
ffffffffc02013d2:	00004617          	auipc	a2,0x4
ffffffffc02013d6:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0204e70 <commands+0x748>
ffffffffc02013da:	08300593          	li	a1,131
ffffffffc02013de:	00004517          	auipc	a0,0x4
ffffffffc02013e2:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0204e88 <commands+0x760>
ffffffffc02013e6:	f8ffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02013ea:	00004697          	auipc	a3,0x4
ffffffffc02013ee:	dde68693          	addi	a3,a3,-546 # ffffffffc02051c8 <commands+0xaa0>
ffffffffc02013f2:	00004617          	auipc	a2,0x4
ffffffffc02013f6:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204e70 <commands+0x748>
ffffffffc02013fa:	08000593          	li	a1,128
ffffffffc02013fe:	00004517          	auipc	a0,0x4
ffffffffc0201402:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0204e88 <commands+0x760>
ffffffffc0201406:	f6ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020140a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020140a:	c959                	beqz	a0,ffffffffc02014a0 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020140c:	00010597          	auipc	a1,0x10
ffffffffc0201410:	c3458593          	addi	a1,a1,-972 # ffffffffc0211040 <free_area>
ffffffffc0201414:	0105a803          	lw	a6,16(a1)
ffffffffc0201418:	862a                	mv	a2,a0
ffffffffc020141a:	02081793          	slli	a5,a6,0x20
ffffffffc020141e:	9381                	srli	a5,a5,0x20
ffffffffc0201420:	00a7ee63          	bltu	a5,a0,ffffffffc020143c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201424:	87ae                	mv	a5,a1
ffffffffc0201426:	a801                	j	ffffffffc0201436 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201428:	ff87a703          	lw	a4,-8(a5)
ffffffffc020142c:	02071693          	slli	a3,a4,0x20
ffffffffc0201430:	9281                	srli	a3,a3,0x20
ffffffffc0201432:	00c6f763          	bgeu	a3,a2,ffffffffc0201440 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201436:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201438:	feb798e3          	bne	a5,a1,ffffffffc0201428 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020143c:	4501                	li	a0,0
}
ffffffffc020143e:	8082                	ret
    return listelm->prev;
ffffffffc0201440:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201444:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201448:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020144c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201450:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201454:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201458:	02d67b63          	bgeu	a2,a3,ffffffffc020148e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020145c:	00361693          	slli	a3,a2,0x3
ffffffffc0201460:	96b2                	add	a3,a3,a2
ffffffffc0201462:	068e                	slli	a3,a3,0x3
ffffffffc0201464:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201466:	41c7073b          	subw	a4,a4,t3
ffffffffc020146a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020146c:	00868613          	addi	a2,a3,8
ffffffffc0201470:	4709                	li	a4,2
ffffffffc0201472:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201476:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020147a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020147e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201482:	e310                	sd	a2,0(a4)
ffffffffc0201484:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201488:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020148a:	0316b023          	sd	a7,32(a3)
ffffffffc020148e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201492:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201496:	5775                	li	a4,-3
ffffffffc0201498:	17a1                	addi	a5,a5,-24
ffffffffc020149a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020149e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014a0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014a2:	00004697          	auipc	a3,0x4
ffffffffc02014a6:	d2668693          	addi	a3,a3,-730 # ffffffffc02051c8 <commands+0xaa0>
ffffffffc02014aa:	00004617          	auipc	a2,0x4
ffffffffc02014ae:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204e70 <commands+0x748>
ffffffffc02014b2:	06200593          	li	a1,98
ffffffffc02014b6:	00004517          	auipc	a0,0x4
ffffffffc02014ba:	9d250513          	addi	a0,a0,-1582 # ffffffffc0204e88 <commands+0x760>
default_alloc_pages(size_t n) {
ffffffffc02014be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014c0:	eb5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014c4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014c4:	1141                	addi	sp,sp,-16
ffffffffc02014c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014c8:	c9e1                	beqz	a1,ffffffffc0201598 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02014ca:	00359693          	slli	a3,a1,0x3
ffffffffc02014ce:	96ae                	add	a3,a3,a1
ffffffffc02014d0:	068e                	slli	a3,a3,0x3
ffffffffc02014d2:	96aa                	add	a3,a3,a0
ffffffffc02014d4:	87aa                	mv	a5,a0
ffffffffc02014d6:	00d50f63          	beq	a0,a3,ffffffffc02014f4 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014da:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014dc:	8b05                	andi	a4,a4,1
ffffffffc02014de:	cf49                	beqz	a4,ffffffffc0201578 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014e0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014e4:	0007b423          	sd	zero,8(a5)
ffffffffc02014e8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014ec:	04878793          	addi	a5,a5,72
ffffffffc02014f0:	fed795e3          	bne	a5,a3,ffffffffc02014da <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014f4:	2581                	sext.w	a1,a1
ffffffffc02014f6:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014f8:	4789                	li	a5,2
ffffffffc02014fa:	00850713          	addi	a4,a0,8
ffffffffc02014fe:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201502:	00010697          	auipc	a3,0x10
ffffffffc0201506:	b3e68693          	addi	a3,a3,-1218 # ffffffffc0211040 <free_area>
ffffffffc020150a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020150c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020150e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201512:	9db9                	addw	a1,a1,a4
ffffffffc0201514:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201516:	04d78a63          	beq	a5,a3,ffffffffc020156a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020151a:	fe078713          	addi	a4,a5,-32
ffffffffc020151e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201522:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201524:	00e56a63          	bltu	a0,a4,ffffffffc0201538 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201528:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020152a:	02d70263          	beq	a4,a3,ffffffffc020154e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020152e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201530:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201534:	fee57ae3          	bgeu	a0,a4,ffffffffc0201528 <default_init_memmap+0x64>
ffffffffc0201538:	c199                	beqz	a1,ffffffffc020153e <default_init_memmap+0x7a>
ffffffffc020153a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020153e:	6398                	ld	a4,0(a5)
}
ffffffffc0201540:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201542:	e390                	sd	a2,0(a5)
ffffffffc0201544:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201546:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201548:	f118                	sd	a4,32(a0)
ffffffffc020154a:	0141                	addi	sp,sp,16
ffffffffc020154c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020154e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201550:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201552:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201554:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201556:	00d70663          	beq	a4,a3,ffffffffc0201562 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020155a:	8832                	mv	a6,a2
ffffffffc020155c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020155e:	87ba                	mv	a5,a4
ffffffffc0201560:	bfc1                	j	ffffffffc0201530 <default_init_memmap+0x6c>
}
ffffffffc0201562:	60a2                	ld	ra,8(sp)
ffffffffc0201564:	e290                	sd	a2,0(a3)
ffffffffc0201566:	0141                	addi	sp,sp,16
ffffffffc0201568:	8082                	ret
ffffffffc020156a:	60a2                	ld	ra,8(sp)
ffffffffc020156c:	e390                	sd	a2,0(a5)
ffffffffc020156e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201570:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201572:	f11c                	sd	a5,32(a0)
ffffffffc0201574:	0141                	addi	sp,sp,16
ffffffffc0201576:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201578:	00004697          	auipc	a3,0x4
ffffffffc020157c:	c8068693          	addi	a3,a3,-896 # ffffffffc02051f8 <commands+0xad0>
ffffffffc0201580:	00004617          	auipc	a2,0x4
ffffffffc0201584:	8f060613          	addi	a2,a2,-1808 # ffffffffc0204e70 <commands+0x748>
ffffffffc0201588:	04900593          	li	a1,73
ffffffffc020158c:	00004517          	auipc	a0,0x4
ffffffffc0201590:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0204e88 <commands+0x760>
ffffffffc0201594:	de1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201598:	00004697          	auipc	a3,0x4
ffffffffc020159c:	c3068693          	addi	a3,a3,-976 # ffffffffc02051c8 <commands+0xaa0>
ffffffffc02015a0:	00004617          	auipc	a2,0x4
ffffffffc02015a4:	8d060613          	addi	a2,a2,-1840 # ffffffffc0204e70 <commands+0x748>
ffffffffc02015a8:	04600593          	li	a1,70
ffffffffc02015ac:	00004517          	auipc	a0,0x4
ffffffffc02015b0:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0204e88 <commands+0x760>
ffffffffc02015b4:	dc1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015b8 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015b8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015ba:	00004617          	auipc	a2,0x4
ffffffffc02015be:	c9e60613          	addi	a2,a2,-866 # ffffffffc0205258 <default_pmm_manager+0x38>
ffffffffc02015c2:	06500593          	li	a1,101
ffffffffc02015c6:	00004517          	auipc	a0,0x4
ffffffffc02015ca:	cb250513          	addi	a0,a0,-846 # ffffffffc0205278 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015ce:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015d0:	da5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015d4 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015d4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015d6:	00004617          	auipc	a2,0x4
ffffffffc02015da:	cb260613          	addi	a2,a2,-846 # ffffffffc0205288 <default_pmm_manager+0x68>
ffffffffc02015de:	07000593          	li	a1,112
ffffffffc02015e2:	00004517          	auipc	a0,0x4
ffffffffc02015e6:	c9650513          	addi	a0,a0,-874 # ffffffffc0205278 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015ea:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015ec:	d89fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015f0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015f0:	7139                	addi	sp,sp,-64
ffffffffc02015f2:	f426                	sd	s1,40(sp)
ffffffffc02015f4:	f04a                	sd	s2,32(sp)
ffffffffc02015f6:	ec4e                	sd	s3,24(sp)
ffffffffc02015f8:	e852                	sd	s4,16(sp)
ffffffffc02015fa:	e456                	sd	s5,8(sp)
ffffffffc02015fc:	e05a                	sd	s6,0(sp)
ffffffffc02015fe:	fc06                	sd	ra,56(sp)
ffffffffc0201600:	f822                	sd	s0,48(sp)
ffffffffc0201602:	84aa                	mv	s1,a0
ffffffffc0201604:	00010917          	auipc	s2,0x10
ffffffffc0201608:	f3490913          	addi	s2,s2,-204 # ffffffffc0211538 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020160c:	4a05                	li	s4,1
ffffffffc020160e:	00010a97          	auipc	s5,0x10
ffffffffc0201612:	f4aa8a93          	addi	s5,s5,-182 # ffffffffc0211558 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201616:	0005099b          	sext.w	s3,a0
ffffffffc020161a:	00010b17          	auipc	s6,0x10
ffffffffc020161e:	f46b0b13          	addi	s6,s6,-186 # ffffffffc0211560 <check_mm_struct>
ffffffffc0201622:	a01d                	j	ffffffffc0201648 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201624:	00093783          	ld	a5,0(s2)
ffffffffc0201628:	6f9c                	ld	a5,24(a5)
ffffffffc020162a:	9782                	jalr	a5
ffffffffc020162c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020162e:	4601                	li	a2,0
ffffffffc0201630:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201632:	ec0d                	bnez	s0,ffffffffc020166c <alloc_pages+0x7c>
ffffffffc0201634:	029a6c63          	bltu	s4,s1,ffffffffc020166c <alloc_pages+0x7c>
ffffffffc0201638:	000aa783          	lw	a5,0(s5)
ffffffffc020163c:	2781                	sext.w	a5,a5
ffffffffc020163e:	c79d                	beqz	a5,ffffffffc020166c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201640:	000b3503          	ld	a0,0(s6)
ffffffffc0201644:	189010ef          	jal	ra,ffffffffc0202fcc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201648:	100027f3          	csrr	a5,sstatus
ffffffffc020164c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020164e:	8526                	mv	a0,s1
ffffffffc0201650:	dbf1                	beqz	a5,ffffffffc0201624 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201652:	e9dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201656:	00093783          	ld	a5,0(s2)
ffffffffc020165a:	8526                	mv	a0,s1
ffffffffc020165c:	6f9c                	ld	a5,24(a5)
ffffffffc020165e:	9782                	jalr	a5
ffffffffc0201660:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201662:	e87fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201666:	4601                	li	a2,0
ffffffffc0201668:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020166a:	d469                	beqz	s0,ffffffffc0201634 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020166c:	70e2                	ld	ra,56(sp)
ffffffffc020166e:	8522                	mv	a0,s0
ffffffffc0201670:	7442                	ld	s0,48(sp)
ffffffffc0201672:	74a2                	ld	s1,40(sp)
ffffffffc0201674:	7902                	ld	s2,32(sp)
ffffffffc0201676:	69e2                	ld	s3,24(sp)
ffffffffc0201678:	6a42                	ld	s4,16(sp)
ffffffffc020167a:	6aa2                	ld	s5,8(sp)
ffffffffc020167c:	6b02                	ld	s6,0(sp)
ffffffffc020167e:	6121                	addi	sp,sp,64
ffffffffc0201680:	8082                	ret

ffffffffc0201682 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201682:	100027f3          	csrr	a5,sstatus
ffffffffc0201686:	8b89                	andi	a5,a5,2
ffffffffc0201688:	e799                	bnez	a5,ffffffffc0201696 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020168a:	00010797          	auipc	a5,0x10
ffffffffc020168e:	eae7b783          	ld	a5,-338(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201692:	739c                	ld	a5,32(a5)
ffffffffc0201694:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201696:	1101                	addi	sp,sp,-32
ffffffffc0201698:	ec06                	sd	ra,24(sp)
ffffffffc020169a:	e822                	sd	s0,16(sp)
ffffffffc020169c:	e426                	sd	s1,8(sp)
ffffffffc020169e:	842a                	mv	s0,a0
ffffffffc02016a0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016a2:	e4dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016a6:	00010797          	auipc	a5,0x10
ffffffffc02016aa:	e927b783          	ld	a5,-366(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016ae:	739c                	ld	a5,32(a5)
ffffffffc02016b0:	85a6                	mv	a1,s1
ffffffffc02016b2:	8522                	mv	a0,s0
ffffffffc02016b4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016b6:	6442                	ld	s0,16(sp)
ffffffffc02016b8:	60e2                	ld	ra,24(sp)
ffffffffc02016ba:	64a2                	ld	s1,8(sp)
ffffffffc02016bc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016be:	e2bfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc02016c2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c2:	100027f3          	csrr	a5,sstatus
ffffffffc02016c6:	8b89                	andi	a5,a5,2
ffffffffc02016c8:	e799                	bnez	a5,ffffffffc02016d6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016ca:	00010797          	auipc	a5,0x10
ffffffffc02016ce:	e6e7b783          	ld	a5,-402(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016d2:	779c                	ld	a5,40(a5)
ffffffffc02016d4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016d6:	1141                	addi	sp,sp,-16
ffffffffc02016d8:	e406                	sd	ra,8(sp)
ffffffffc02016da:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016dc:	e13fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016e0:	00010797          	auipc	a5,0x10
ffffffffc02016e4:	e587b783          	ld	a5,-424(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016e8:	779c                	ld	a5,40(a5)
ffffffffc02016ea:	9782                	jalr	a5
ffffffffc02016ec:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016ee:	dfbfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016f2:	60a2                	ld	ra,8(sp)
ffffffffc02016f4:	8522                	mv	a0,s0
ffffffffc02016f6:	6402                	ld	s0,0(sp)
ffffffffc02016f8:	0141                	addi	sp,sp,16
ffffffffc02016fa:	8082                	ret

ffffffffc02016fc <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016fc:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201700:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201704:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201706:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201708:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020170a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc020170e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201710:	f84a                	sd	s2,48(sp)
ffffffffc0201712:	f44e                	sd	s3,40(sp)
ffffffffc0201714:	f052                	sd	s4,32(sp)
ffffffffc0201716:	e486                	sd	ra,72(sp)
ffffffffc0201718:	e0a2                	sd	s0,64(sp)
ffffffffc020171a:	ec56                	sd	s5,24(sp)
ffffffffc020171c:	e85a                	sd	s6,16(sp)
ffffffffc020171e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201720:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201724:	892e                	mv	s2,a1
ffffffffc0201726:	8a32                	mv	s4,a2
ffffffffc0201728:	00010997          	auipc	s3,0x10
ffffffffc020172c:	e0098993          	addi	s3,s3,-512 # ffffffffc0211528 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201730:	efb5                	bnez	a5,ffffffffc02017ac <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201732:	14060c63          	beqz	a2,ffffffffc020188a <get_pte+0x18e>
ffffffffc0201736:	4505                	li	a0,1
ffffffffc0201738:	eb9ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc020173c:	842a                	mv	s0,a0
ffffffffc020173e:	14050663          	beqz	a0,ffffffffc020188a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201742:	00010b97          	auipc	s7,0x10
ffffffffc0201746:	deeb8b93          	addi	s7,s7,-530 # ffffffffc0211530 <pages>
ffffffffc020174a:	000bb503          	ld	a0,0(s7)
ffffffffc020174e:	00005b17          	auipc	s6,0x5
ffffffffc0201752:	cdab3b03          	ld	s6,-806(s6) # ffffffffc0206428 <error_string+0x38>
ffffffffc0201756:	00080ab7          	lui	s5,0x80
ffffffffc020175a:	40a40533          	sub	a0,s0,a0
ffffffffc020175e:	850d                	srai	a0,a0,0x3
ffffffffc0201760:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201764:	00010997          	auipc	s3,0x10
ffffffffc0201768:	dc498993          	addi	s3,s3,-572 # ffffffffc0211528 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020176c:	4785                	li	a5,1
ffffffffc020176e:	0009b703          	ld	a4,0(s3)
ffffffffc0201772:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201774:	9556                	add	a0,a0,s5
ffffffffc0201776:	00c51793          	slli	a5,a0,0xc
ffffffffc020177a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020177c:	0532                	slli	a0,a0,0xc
ffffffffc020177e:	14e7fd63          	bgeu	a5,a4,ffffffffc02018d8 <get_pte+0x1dc>
ffffffffc0201782:	00010797          	auipc	a5,0x10
ffffffffc0201786:	dbe7b783          	ld	a5,-578(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc020178a:	6605                	lui	a2,0x1
ffffffffc020178c:	4581                	li	a1,0
ffffffffc020178e:	953e                	add	a0,a0,a5
ffffffffc0201790:	513020ef          	jal	ra,ffffffffc02044a2 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201794:	000bb683          	ld	a3,0(s7)
ffffffffc0201798:	40d406b3          	sub	a3,s0,a3
ffffffffc020179c:	868d                	srai	a3,a3,0x3
ffffffffc020179e:	036686b3          	mul	a3,a3,s6
ffffffffc02017a2:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017a4:	06aa                	slli	a3,a3,0xa
ffffffffc02017a6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017aa:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02017ac:	77fd                	lui	a5,0xfffff
ffffffffc02017ae:	068a                	slli	a3,a3,0x2
ffffffffc02017b0:	0009b703          	ld	a4,0(s3)
ffffffffc02017b4:	8efd                	and	a3,a3,a5
ffffffffc02017b6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017ba:	0ce7fa63          	bgeu	a5,a4,ffffffffc020188e <get_pte+0x192>
ffffffffc02017be:	00010a97          	auipc	s5,0x10
ffffffffc02017c2:	d82a8a93          	addi	s5,s5,-638 # ffffffffc0211540 <va_pa_offset>
ffffffffc02017c6:	000ab403          	ld	s0,0(s5)
ffffffffc02017ca:	01595793          	srli	a5,s2,0x15
ffffffffc02017ce:	1ff7f793          	andi	a5,a5,511
ffffffffc02017d2:	96a2                	add	a3,a3,s0
ffffffffc02017d4:	00379413          	slli	s0,a5,0x3
ffffffffc02017d8:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017da:	6014                	ld	a3,0(s0)
ffffffffc02017dc:	0016f793          	andi	a5,a3,1
ffffffffc02017e0:	ebad                	bnez	a5,ffffffffc0201852 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017e2:	0a0a0463          	beqz	s4,ffffffffc020188a <get_pte+0x18e>
ffffffffc02017e6:	4505                	li	a0,1
ffffffffc02017e8:	e09ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc02017ec:	84aa                	mv	s1,a0
ffffffffc02017ee:	cd51                	beqz	a0,ffffffffc020188a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017f0:	00010b97          	auipc	s7,0x10
ffffffffc02017f4:	d40b8b93          	addi	s7,s7,-704 # ffffffffc0211530 <pages>
ffffffffc02017f8:	000bb503          	ld	a0,0(s7)
ffffffffc02017fc:	00005b17          	auipc	s6,0x5
ffffffffc0201800:	c2cb3b03          	ld	s6,-980(s6) # ffffffffc0206428 <error_string+0x38>
ffffffffc0201804:	00080a37          	lui	s4,0x80
ffffffffc0201808:	40a48533          	sub	a0,s1,a0
ffffffffc020180c:	850d                	srai	a0,a0,0x3
ffffffffc020180e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201812:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201814:	0009b703          	ld	a4,0(s3)
ffffffffc0201818:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020181a:	9552                	add	a0,a0,s4
ffffffffc020181c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201820:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201822:	0532                	slli	a0,a0,0xc
ffffffffc0201824:	08e7fd63          	bgeu	a5,a4,ffffffffc02018be <get_pte+0x1c2>
ffffffffc0201828:	000ab783          	ld	a5,0(s5)
ffffffffc020182c:	6605                	lui	a2,0x1
ffffffffc020182e:	4581                	li	a1,0
ffffffffc0201830:	953e                	add	a0,a0,a5
ffffffffc0201832:	471020ef          	jal	ra,ffffffffc02044a2 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201836:	000bb683          	ld	a3,0(s7)
ffffffffc020183a:	40d486b3          	sub	a3,s1,a3
ffffffffc020183e:	868d                	srai	a3,a3,0x3
ffffffffc0201840:	036686b3          	mul	a3,a3,s6
ffffffffc0201844:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201846:	06aa                	slli	a3,a3,0xa
ffffffffc0201848:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020184c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020184e:	0009b703          	ld	a4,0(s3)
ffffffffc0201852:	068a                	slli	a3,a3,0x2
ffffffffc0201854:	757d                	lui	a0,0xfffff
ffffffffc0201856:	8ee9                	and	a3,a3,a0
ffffffffc0201858:	00c6d793          	srli	a5,a3,0xc
ffffffffc020185c:	04e7f563          	bgeu	a5,a4,ffffffffc02018a6 <get_pte+0x1aa>
ffffffffc0201860:	000ab503          	ld	a0,0(s5)
ffffffffc0201864:	00c95913          	srli	s2,s2,0xc
ffffffffc0201868:	1ff97913          	andi	s2,s2,511
ffffffffc020186c:	96aa                	add	a3,a3,a0
ffffffffc020186e:	00391513          	slli	a0,s2,0x3
ffffffffc0201872:	9536                	add	a0,a0,a3
}
ffffffffc0201874:	60a6                	ld	ra,72(sp)
ffffffffc0201876:	6406                	ld	s0,64(sp)
ffffffffc0201878:	74e2                	ld	s1,56(sp)
ffffffffc020187a:	7942                	ld	s2,48(sp)
ffffffffc020187c:	79a2                	ld	s3,40(sp)
ffffffffc020187e:	7a02                	ld	s4,32(sp)
ffffffffc0201880:	6ae2                	ld	s5,24(sp)
ffffffffc0201882:	6b42                	ld	s6,16(sp)
ffffffffc0201884:	6ba2                	ld	s7,8(sp)
ffffffffc0201886:	6161                	addi	sp,sp,80
ffffffffc0201888:	8082                	ret
            return NULL;
ffffffffc020188a:	4501                	li	a0,0
ffffffffc020188c:	b7e5                	j	ffffffffc0201874 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020188e:	00004617          	auipc	a2,0x4
ffffffffc0201892:	a2260613          	addi	a2,a2,-1502 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc0201896:	10400593          	li	a1,260
ffffffffc020189a:	00004517          	auipc	a0,0x4
ffffffffc020189e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02018a2:	ad3fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018a6:	00004617          	auipc	a2,0x4
ffffffffc02018aa:	a0a60613          	addi	a2,a2,-1526 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc02018ae:	11100593          	li	a1,273
ffffffffc02018b2:	00004517          	auipc	a0,0x4
ffffffffc02018b6:	a2650513          	addi	a0,a0,-1498 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02018ba:	abbfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018be:	86aa                	mv	a3,a0
ffffffffc02018c0:	00004617          	auipc	a2,0x4
ffffffffc02018c4:	9f060613          	addi	a2,a2,-1552 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc02018c8:	10d00593          	li	a1,269
ffffffffc02018cc:	00004517          	auipc	a0,0x4
ffffffffc02018d0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02018d4:	aa1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018d8:	86aa                	mv	a3,a0
ffffffffc02018da:	00004617          	auipc	a2,0x4
ffffffffc02018de:	9d660613          	addi	a2,a2,-1578 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc02018e2:	10100593          	li	a1,257
ffffffffc02018e6:	00004517          	auipc	a0,0x4
ffffffffc02018ea:	9f250513          	addi	a0,a0,-1550 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02018ee:	a87fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02018f2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018f2:	1141                	addi	sp,sp,-16
ffffffffc02018f4:	e022                	sd	s0,0(sp)
ffffffffc02018f6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018f8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018fa:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018fc:	e01ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201900:	c011                	beqz	s0,ffffffffc0201904 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201902:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201904:	c511                	beqz	a0,ffffffffc0201910 <get_page+0x1e>
ffffffffc0201906:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201908:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020190a:	0017f713          	andi	a4,a5,1
ffffffffc020190e:	e709                	bnez	a4,ffffffffc0201918 <get_page+0x26>
}
ffffffffc0201910:	60a2                	ld	ra,8(sp)
ffffffffc0201912:	6402                	ld	s0,0(sp)
ffffffffc0201914:	0141                	addi	sp,sp,16
ffffffffc0201916:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201918:	078a                	slli	a5,a5,0x2
ffffffffc020191a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020191c:	00010717          	auipc	a4,0x10
ffffffffc0201920:	c0c73703          	ld	a4,-1012(a4) # ffffffffc0211528 <npage>
ffffffffc0201924:	02e7f263          	bgeu	a5,a4,ffffffffc0201948 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201928:	fff80537          	lui	a0,0xfff80
ffffffffc020192c:	97aa                	add	a5,a5,a0
ffffffffc020192e:	60a2                	ld	ra,8(sp)
ffffffffc0201930:	6402                	ld	s0,0(sp)
ffffffffc0201932:	00379513          	slli	a0,a5,0x3
ffffffffc0201936:	97aa                	add	a5,a5,a0
ffffffffc0201938:	078e                	slli	a5,a5,0x3
ffffffffc020193a:	00010517          	auipc	a0,0x10
ffffffffc020193e:	bf653503          	ld	a0,-1034(a0) # ffffffffc0211530 <pages>
ffffffffc0201942:	953e                	add	a0,a0,a5
ffffffffc0201944:	0141                	addi	sp,sp,16
ffffffffc0201946:	8082                	ret
ffffffffc0201948:	c71ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>

ffffffffc020194c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020194c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020194e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201950:	ec06                	sd	ra,24(sp)
ffffffffc0201952:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201954:	da9ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    if (ptep != NULL) {
ffffffffc0201958:	c511                	beqz	a0,ffffffffc0201964 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020195a:	611c                	ld	a5,0(a0)
ffffffffc020195c:	842a                	mv	s0,a0
ffffffffc020195e:	0017f713          	andi	a4,a5,1
ffffffffc0201962:	e709                	bnez	a4,ffffffffc020196c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201964:	60e2                	ld	ra,24(sp)
ffffffffc0201966:	6442                	ld	s0,16(sp)
ffffffffc0201968:	6105                	addi	sp,sp,32
ffffffffc020196a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020196c:	078a                	slli	a5,a5,0x2
ffffffffc020196e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201970:	00010717          	auipc	a4,0x10
ffffffffc0201974:	bb873703          	ld	a4,-1096(a4) # ffffffffc0211528 <npage>
ffffffffc0201978:	06e7f563          	bgeu	a5,a4,ffffffffc02019e2 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020197c:	fff80737          	lui	a4,0xfff80
ffffffffc0201980:	97ba                	add	a5,a5,a4
ffffffffc0201982:	00379513          	slli	a0,a5,0x3
ffffffffc0201986:	97aa                	add	a5,a5,a0
ffffffffc0201988:	078e                	slli	a5,a5,0x3
ffffffffc020198a:	00010517          	auipc	a0,0x10
ffffffffc020198e:	ba653503          	ld	a0,-1114(a0) # ffffffffc0211530 <pages>
ffffffffc0201992:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201994:	411c                	lw	a5,0(a0)
ffffffffc0201996:	fff7871b          	addiw	a4,a5,-1
ffffffffc020199a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020199c:	cb09                	beqz	a4,ffffffffc02019ae <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020199e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019a2:	12000073          	sfence.vma
}
ffffffffc02019a6:	60e2                	ld	ra,24(sp)
ffffffffc02019a8:	6442                	ld	s0,16(sp)
ffffffffc02019aa:	6105                	addi	sp,sp,32
ffffffffc02019ac:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019ae:	100027f3          	csrr	a5,sstatus
ffffffffc02019b2:	8b89                	andi	a5,a5,2
ffffffffc02019b4:	eb89                	bnez	a5,ffffffffc02019c6 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019b6:	00010797          	auipc	a5,0x10
ffffffffc02019ba:	b827b783          	ld	a5,-1150(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019be:	739c                	ld	a5,32(a5)
ffffffffc02019c0:	4585                	li	a1,1
ffffffffc02019c2:	9782                	jalr	a5
    if (flag) {
ffffffffc02019c4:	bfe9                	j	ffffffffc020199e <page_remove+0x52>
        intr_disable();
ffffffffc02019c6:	e42a                	sd	a0,8(sp)
ffffffffc02019c8:	b27fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02019cc:	00010797          	auipc	a5,0x10
ffffffffc02019d0:	b6c7b783          	ld	a5,-1172(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019d4:	739c                	ld	a5,32(a5)
ffffffffc02019d6:	6522                	ld	a0,8(sp)
ffffffffc02019d8:	4585                	li	a1,1
ffffffffc02019da:	9782                	jalr	a5
        intr_enable();
ffffffffc02019dc:	b0dfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02019e0:	bf7d                	j	ffffffffc020199e <page_remove+0x52>
ffffffffc02019e2:	bd7ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>

ffffffffc02019e6 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019e6:	7179                	addi	sp,sp,-48
ffffffffc02019e8:	87b2                	mv	a5,a2
ffffffffc02019ea:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019ec:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019ee:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019f0:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019f2:	ec26                	sd	s1,24(sp)
ffffffffc02019f4:	f406                	sd	ra,40(sp)
ffffffffc02019f6:	e84a                	sd	s2,16(sp)
ffffffffc02019f8:	e44e                	sd	s3,8(sp)
ffffffffc02019fa:	e052                	sd	s4,0(sp)
ffffffffc02019fc:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019fe:	cffff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    if (ptep == NULL) {
ffffffffc0201a02:	cd71                	beqz	a0,ffffffffc0201ade <page_insert+0xf8>
    page->ref += 1;
ffffffffc0201a04:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a06:	611c                	ld	a5,0(a0)
ffffffffc0201a08:	89aa                	mv	s3,a0
ffffffffc0201a0a:	0016871b          	addiw	a4,a3,1
ffffffffc0201a0e:	c018                	sw	a4,0(s0)
ffffffffc0201a10:	0017f713          	andi	a4,a5,1
ffffffffc0201a14:	e331                	bnez	a4,ffffffffc0201a58 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a16:	00010797          	auipc	a5,0x10
ffffffffc0201a1a:	b1a7b783          	ld	a5,-1254(a5) # ffffffffc0211530 <pages>
ffffffffc0201a1e:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a22:	878d                	srai	a5,a5,0x3
ffffffffc0201a24:	00005417          	auipc	s0,0x5
ffffffffc0201a28:	a0443403          	ld	s0,-1532(s0) # ffffffffc0206428 <error_string+0x38>
ffffffffc0201a2c:	028787b3          	mul	a5,a5,s0
ffffffffc0201a30:	00080437          	lui	s0,0x80
ffffffffc0201a34:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a36:	07aa                	slli	a5,a5,0xa
ffffffffc0201a38:	8cdd                	or	s1,s1,a5
ffffffffc0201a3a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a3e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a42:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a46:	4501                	li	a0,0
}
ffffffffc0201a48:	70a2                	ld	ra,40(sp)
ffffffffc0201a4a:	7402                	ld	s0,32(sp)
ffffffffc0201a4c:	64e2                	ld	s1,24(sp)
ffffffffc0201a4e:	6942                	ld	s2,16(sp)
ffffffffc0201a50:	69a2                	ld	s3,8(sp)
ffffffffc0201a52:	6a02                	ld	s4,0(sp)
ffffffffc0201a54:	6145                	addi	sp,sp,48
ffffffffc0201a56:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a58:	00279713          	slli	a4,a5,0x2
ffffffffc0201a5c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a5e:	00010797          	auipc	a5,0x10
ffffffffc0201a62:	aca7b783          	ld	a5,-1334(a5) # ffffffffc0211528 <npage>
ffffffffc0201a66:	06f77e63          	bgeu	a4,a5,ffffffffc0201ae2 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a6a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a6e:	973e                	add	a4,a4,a5
ffffffffc0201a70:	00010a17          	auipc	s4,0x10
ffffffffc0201a74:	ac0a0a13          	addi	s4,s4,-1344 # ffffffffc0211530 <pages>
ffffffffc0201a78:	000a3783          	ld	a5,0(s4)
ffffffffc0201a7c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a80:	993a                	add	s2,s2,a4
ffffffffc0201a82:	090e                	slli	s2,s2,0x3
ffffffffc0201a84:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a86:	03240063          	beq	s0,s2,ffffffffc0201aa6 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a8a:	00092783          	lw	a5,0(s2)
ffffffffc0201a8e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a92:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201a96:	cb11                	beqz	a4,ffffffffc0201aaa <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a98:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a9c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201aa0:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201aa4:	bfad                	j	ffffffffc0201a1e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201aa6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201aa8:	bf9d                	j	ffffffffc0201a1e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201aaa:	100027f3          	csrr	a5,sstatus
ffffffffc0201aae:	8b89                	andi	a5,a5,2
ffffffffc0201ab0:	eb91                	bnez	a5,ffffffffc0201ac4 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201ab2:	00010797          	auipc	a5,0x10
ffffffffc0201ab6:	a867b783          	ld	a5,-1402(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201aba:	739c                	ld	a5,32(a5)
ffffffffc0201abc:	4585                	li	a1,1
ffffffffc0201abe:	854a                	mv	a0,s2
ffffffffc0201ac0:	9782                	jalr	a5
    if (flag) {
ffffffffc0201ac2:	bfd9                	j	ffffffffc0201a98 <page_insert+0xb2>
        intr_disable();
ffffffffc0201ac4:	a2bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201ac8:	00010797          	auipc	a5,0x10
ffffffffc0201acc:	a707b783          	ld	a5,-1424(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201ad0:	739c                	ld	a5,32(a5)
ffffffffc0201ad2:	4585                	li	a1,1
ffffffffc0201ad4:	854a                	mv	a0,s2
ffffffffc0201ad6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201ad8:	a11fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201adc:	bf75                	j	ffffffffc0201a98 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201ade:	5571                	li	a0,-4
ffffffffc0201ae0:	b7a5                	j	ffffffffc0201a48 <page_insert+0x62>
ffffffffc0201ae2:	ad7ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>

ffffffffc0201ae6 <pmm_init>:
    pmm_manager=&default_pmm_manager;
ffffffffc0201ae6:	00003797          	auipc	a5,0x3
ffffffffc0201aea:	73a78793          	addi	a5,a5,1850 # ffffffffc0205220 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201aee:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201af0:	7159                	addi	sp,sp,-112
ffffffffc0201af2:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201af4:	00003517          	auipc	a0,0x3
ffffffffc0201af8:	7f450513          	addi	a0,a0,2036 # ffffffffc02052e8 <default_pmm_manager+0xc8>
    pmm_manager=&default_pmm_manager;
ffffffffc0201afc:	00010b97          	auipc	s7,0x10
ffffffffc0201b00:	a3cb8b93          	addi	s7,s7,-1476 # ffffffffc0211538 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b04:	f486                	sd	ra,104(sp)
ffffffffc0201b06:	f0a2                	sd	s0,96(sp)
ffffffffc0201b08:	eca6                	sd	s1,88(sp)
ffffffffc0201b0a:	e8ca                	sd	s2,80(sp)
ffffffffc0201b0c:	e4ce                	sd	s3,72(sp)
ffffffffc0201b0e:	f85a                	sd	s6,48(sp)
    pmm_manager=&default_pmm_manager;
ffffffffc0201b10:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201b14:	e0d2                	sd	s4,64(sp)
ffffffffc0201b16:	fc56                	sd	s5,56(sp)
ffffffffc0201b18:	f062                	sd	s8,32(sp)
ffffffffc0201b1a:	ec66                	sd	s9,24(sp)
ffffffffc0201b1c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b1e:	d9cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b22:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b26:	4445                	li	s0,17
ffffffffc0201b28:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201b2c:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b2e:	00010997          	auipc	s3,0x10
ffffffffc0201b32:	a1298993          	addi	s3,s3,-1518 # ffffffffc0211540 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b36:	00010497          	auipc	s1,0x10
ffffffffc0201b3a:	9f248493          	addi	s1,s1,-1550 # ffffffffc0211528 <npage>
    pmm_manager->init();
ffffffffc0201b3e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b40:	57f5                	li	a5,-3
ffffffffc0201b42:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b44:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b48:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b4c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b50:	00003517          	auipc	a0,0x3
ffffffffc0201b54:	7b050513          	addi	a0,a0,1968 # ffffffffc0205300 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b58:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b5c:	d5efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b60:	00003517          	auipc	a0,0x3
ffffffffc0201b64:	7d050513          	addi	a0,a0,2000 # ffffffffc0205330 <default_pmm_manager+0x110>
ffffffffc0201b68:	d52fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b6c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b70:	16fd                	addi	a3,a3,-1
ffffffffc0201b72:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b76:	01591613          	slli	a2,s2,0x15
ffffffffc0201b7a:	00003517          	auipc	a0,0x3
ffffffffc0201b7e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205348 <default_pmm_manager+0x128>
ffffffffc0201b82:	d38fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b86:	777d                	lui	a4,0xfffff
ffffffffc0201b88:	00011797          	auipc	a5,0x11
ffffffffc0201b8c:	9e378793          	addi	a5,a5,-1565 # ffffffffc021256b <end+0xfff>
ffffffffc0201b90:	8ff9                	and	a5,a5,a4
ffffffffc0201b92:	00010b17          	auipc	s6,0x10
ffffffffc0201b96:	99eb0b13          	addi	s6,s6,-1634 # ffffffffc0211530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201b9a:	00088737          	lui	a4,0x88
ffffffffc0201b9e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201ba0:	00fb3023          	sd	a5,0(s6)
ffffffffc0201ba4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201ba6:	4701                	li	a4,0
ffffffffc0201ba8:	4505                	li	a0,1
ffffffffc0201baa:	fff805b7          	lui	a1,0xfff80
ffffffffc0201bae:	a019                	j	ffffffffc0201bb4 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201bb0:	000b3783          	ld	a5,0(s6)
ffffffffc0201bb4:	97b6                	add	a5,a5,a3
ffffffffc0201bb6:	07a1                	addi	a5,a5,8
ffffffffc0201bb8:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bbc:	609c                	ld	a5,0(s1)
ffffffffc0201bbe:	0705                	addi	a4,a4,1
ffffffffc0201bc0:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201bc4:	00b78633          	add	a2,a5,a1
ffffffffc0201bc8:	fec764e3          	bltu	a4,a2,ffffffffc0201bb0 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bcc:	000b3503          	ld	a0,0(s6)
ffffffffc0201bd0:	00379693          	slli	a3,a5,0x3
ffffffffc0201bd4:	96be                	add	a3,a3,a5
ffffffffc0201bd6:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bda:	972a                	add	a4,a4,a0
ffffffffc0201bdc:	068e                	slli	a3,a3,0x3
ffffffffc0201bde:	96ba                	add	a3,a3,a4
ffffffffc0201be0:	c0200737          	lui	a4,0xc0200
ffffffffc0201be4:	64e6e463          	bltu	a3,a4,ffffffffc020222c <pmm_init+0x746>
ffffffffc0201be8:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201bec:	4645                	li	a2,17
ffffffffc0201bee:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bf0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201bf2:	4ec6e263          	bltu	a3,a2,ffffffffc02020d6 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201bf6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bfa:	00010917          	auipc	s2,0x10
ffffffffc0201bfe:	92690913          	addi	s2,s2,-1754 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c02:	7b9c                	ld	a5,48(a5)
ffffffffc0201c04:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c06:	00003517          	auipc	a0,0x3
ffffffffc0201c0a:	79250513          	addi	a0,a0,1938 # ffffffffc0205398 <default_pmm_manager+0x178>
ffffffffc0201c0e:	cacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c12:	00007697          	auipc	a3,0x7
ffffffffc0201c16:	3ee68693          	addi	a3,a3,1006 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c1a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c1e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c22:	62f6e163          	bltu	a3,a5,ffffffffc0202244 <pmm_init+0x75e>
ffffffffc0201c26:	0009b783          	ld	a5,0(s3)
ffffffffc0201c2a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c2c:	00010797          	auipc	a5,0x10
ffffffffc0201c30:	8ed7b623          	sd	a3,-1812(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c34:	100027f3          	csrr	a5,sstatus
ffffffffc0201c38:	8b89                	andi	a5,a5,2
ffffffffc0201c3a:	4c079763          	bnez	a5,ffffffffc0202108 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c3e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c42:	779c                	ld	a5,40(a5)
ffffffffc0201c44:	9782                	jalr	a5
ffffffffc0201c46:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c48:	6098                	ld	a4,0(s1)
ffffffffc0201c4a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c4e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c50:	62e7e663          	bltu	a5,a4,ffffffffc020227c <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c54:	00093503          	ld	a0,0(s2)
ffffffffc0201c58:	60050263          	beqz	a0,ffffffffc020225c <pmm_init+0x776>
ffffffffc0201c5c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c60:	5e079e63          	bnez	a5,ffffffffc020225c <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c64:	4601                	li	a2,0
ffffffffc0201c66:	4581                	li	a1,0
ffffffffc0201c68:	c8bff0ef          	jal	ra,ffffffffc02018f2 <get_page>
ffffffffc0201c6c:	66051a63          	bnez	a0,ffffffffc02022e0 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c70:	4505                	li	a0,1
ffffffffc0201c72:	97fff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0201c76:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c78:	00093503          	ld	a0,0(s2)
ffffffffc0201c7c:	4681                	li	a3,0
ffffffffc0201c7e:	4601                	li	a2,0
ffffffffc0201c80:	85d2                	mv	a1,s4
ffffffffc0201c82:	d65ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201c86:	62051d63          	bnez	a0,ffffffffc02022c0 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c8a:	00093503          	ld	a0,0(s2)
ffffffffc0201c8e:	4601                	li	a2,0
ffffffffc0201c90:	4581                	li	a1,0
ffffffffc0201c92:	a6bff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201c96:	60050563          	beqz	a0,ffffffffc02022a0 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c9a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c9c:	0017f713          	andi	a4,a5,1
ffffffffc0201ca0:	5e070e63          	beqz	a4,ffffffffc020229c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201ca4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ca6:	078a                	slli	a5,a5,0x2
ffffffffc0201ca8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201caa:	56c7ff63          	bgeu	a5,a2,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cae:	fff80737          	lui	a4,0xfff80
ffffffffc0201cb2:	97ba                	add	a5,a5,a4
ffffffffc0201cb4:	000b3683          	ld	a3,0(s6)
ffffffffc0201cb8:	00379713          	slli	a4,a5,0x3
ffffffffc0201cbc:	97ba                	add	a5,a5,a4
ffffffffc0201cbe:	078e                	slli	a5,a5,0x3
ffffffffc0201cc0:	97b6                	add	a5,a5,a3
ffffffffc0201cc2:	14fa18e3          	bne	s4,a5,ffffffffc0202612 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201cc6:	000a2703          	lw	a4,0(s4)
ffffffffc0201cca:	4785                	li	a5,1
ffffffffc0201ccc:	16f71fe3          	bne	a4,a5,ffffffffc020264a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201cd0:	00093503          	ld	a0,0(s2)
ffffffffc0201cd4:	77fd                	lui	a5,0xfffff
ffffffffc0201cd6:	6114                	ld	a3,0(a0)
ffffffffc0201cd8:	068a                	slli	a3,a3,0x2
ffffffffc0201cda:	8efd                	and	a3,a3,a5
ffffffffc0201cdc:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201ce0:	14c779e3          	bgeu	a4,a2,ffffffffc0202632 <pmm_init+0xb4c>
ffffffffc0201ce4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ce8:	96e2                	add	a3,a3,s8
ffffffffc0201cea:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cee:	0a8a                	slli	s5,s5,0x2
ffffffffc0201cf0:	00fafab3          	and	s5,s5,a5
ffffffffc0201cf4:	00cad793          	srli	a5,s5,0xc
ffffffffc0201cf8:	66c7f463          	bgeu	a5,a2,ffffffffc0202360 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cfc:	4601                	li	a2,0
ffffffffc0201cfe:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d00:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d02:	9fbff0ef          	jal	ra,ffffffffc02016fc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d06:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d08:	63551c63          	bne	a0,s5,ffffffffc0202340 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201d0c:	4505                	li	a0,1
ffffffffc0201d0e:	8e3ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0201d12:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d14:	00093503          	ld	a0,0(s2)
ffffffffc0201d18:	46d1                	li	a3,20
ffffffffc0201d1a:	6605                	lui	a2,0x1
ffffffffc0201d1c:	85d6                	mv	a1,s5
ffffffffc0201d1e:	cc9ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201d22:	5c051f63          	bnez	a0,ffffffffc0202300 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d26:	00093503          	ld	a0,0(s2)
ffffffffc0201d2a:	4601                	li	a2,0
ffffffffc0201d2c:	6585                	lui	a1,0x1
ffffffffc0201d2e:	9cfff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201d32:	12050ce3          	beqz	a0,ffffffffc020266a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201d36:	611c                	ld	a5,0(a0)
ffffffffc0201d38:	0107f713          	andi	a4,a5,16
ffffffffc0201d3c:	72070f63          	beqz	a4,ffffffffc020247a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d40:	8b91                	andi	a5,a5,4
ffffffffc0201d42:	6e078c63          	beqz	a5,ffffffffc020243a <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d46:	00093503          	ld	a0,0(s2)
ffffffffc0201d4a:	611c                	ld	a5,0(a0)
ffffffffc0201d4c:	8bc1                	andi	a5,a5,16
ffffffffc0201d4e:	6c078663          	beqz	a5,ffffffffc020241a <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201d52:	000aa703          	lw	a4,0(s5)
ffffffffc0201d56:	4785                	li	a5,1
ffffffffc0201d58:	5cf71463          	bne	a4,a5,ffffffffc0202320 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d5c:	4681                	li	a3,0
ffffffffc0201d5e:	6605                	lui	a2,0x1
ffffffffc0201d60:	85d2                	mv	a1,s4
ffffffffc0201d62:	c85ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201d66:	66051a63          	bnez	a0,ffffffffc02023da <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d6a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d6e:	4789                	li	a5,2
ffffffffc0201d70:	64f71563          	bne	a4,a5,ffffffffc02023ba <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201d74:	000aa783          	lw	a5,0(s5)
ffffffffc0201d78:	62079163          	bnez	a5,ffffffffc020239a <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d7c:	00093503          	ld	a0,0(s2)
ffffffffc0201d80:	4601                	li	a2,0
ffffffffc0201d82:	6585                	lui	a1,0x1
ffffffffc0201d84:	979ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201d88:	5e050963          	beqz	a0,ffffffffc020237a <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d8c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d8e:	00177793          	andi	a5,a4,1
ffffffffc0201d92:	50078563          	beqz	a5,ffffffffc020229c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d96:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d98:	00271793          	slli	a5,a4,0x2
ffffffffc0201d9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d9e:	48d7f563          	bgeu	a5,a3,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201da2:	fff806b7          	lui	a3,0xfff80
ffffffffc0201da6:	97b6                	add	a5,a5,a3
ffffffffc0201da8:	000b3603          	ld	a2,0(s6)
ffffffffc0201dac:	00379693          	slli	a3,a5,0x3
ffffffffc0201db0:	97b6                	add	a5,a5,a3
ffffffffc0201db2:	078e                	slli	a5,a5,0x3
ffffffffc0201db4:	97b2                	add	a5,a5,a2
ffffffffc0201db6:	72fa1263          	bne	s4,a5,ffffffffc02024da <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dba:	8b41                	andi	a4,a4,16
ffffffffc0201dbc:	6e071f63          	bnez	a4,ffffffffc02024ba <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201dc0:	00093503          	ld	a0,0(s2)
ffffffffc0201dc4:	4581                	li	a1,0
ffffffffc0201dc6:	b87ff0ef          	jal	ra,ffffffffc020194c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dca:	000a2703          	lw	a4,0(s4)
ffffffffc0201dce:	4785                	li	a5,1
ffffffffc0201dd0:	6cf71563          	bne	a4,a5,ffffffffc020249a <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201dd4:	000aa783          	lw	a5,0(s5)
ffffffffc0201dd8:	78079d63          	bnez	a5,ffffffffc0202572 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201ddc:	00093503          	ld	a0,0(s2)
ffffffffc0201de0:	6585                	lui	a1,0x1
ffffffffc0201de2:	b6bff0ef          	jal	ra,ffffffffc020194c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201de6:	000a2783          	lw	a5,0(s4)
ffffffffc0201dea:	76079463          	bnez	a5,ffffffffc0202552 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201dee:	000aa783          	lw	a5,0(s5)
ffffffffc0201df2:	74079063          	bnez	a5,ffffffffc0202532 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201df6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201dfa:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dfc:	000a3783          	ld	a5,0(s4)
ffffffffc0201e00:	078a                	slli	a5,a5,0x2
ffffffffc0201e02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e04:	42c7f263          	bgeu	a5,a2,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e08:	fff80737          	lui	a4,0xfff80
ffffffffc0201e0c:	973e                	add	a4,a4,a5
ffffffffc0201e0e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e12:	000b3503          	ld	a0,0(s6)
ffffffffc0201e16:	97ba                	add	a5,a5,a4
ffffffffc0201e18:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e1a:	00f50733          	add	a4,a0,a5
ffffffffc0201e1e:	4314                	lw	a3,0(a4)
ffffffffc0201e20:	4705                	li	a4,1
ffffffffc0201e22:	6ee69863          	bne	a3,a4,ffffffffc0202512 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e26:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e2a:	00004c97          	auipc	s9,0x4
ffffffffc0201e2e:	5fecbc83          	ld	s9,1534(s9) # ffffffffc0206428 <error_string+0x38>
ffffffffc0201e32:	039686b3          	mul	a3,a3,s9
ffffffffc0201e36:	000805b7          	lui	a1,0x80
ffffffffc0201e3a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e3c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e40:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e42:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e44:	6ac77b63          	bgeu	a4,a2,ffffffffc02024fa <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e48:	0009b703          	ld	a4,0(s3)
ffffffffc0201e4c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e4e:	629c                	ld	a5,0(a3)
ffffffffc0201e50:	078a                	slli	a5,a5,0x2
ffffffffc0201e52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e54:	3cc7fa63          	bgeu	a5,a2,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e58:	8f8d                	sub	a5,a5,a1
ffffffffc0201e5a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e5e:	97ba                	add	a5,a5,a4
ffffffffc0201e60:	078e                	slli	a5,a5,0x3
ffffffffc0201e62:	953e                	add	a0,a0,a5
ffffffffc0201e64:	100027f3          	csrr	a5,sstatus
ffffffffc0201e68:	8b89                	andi	a5,a5,2
ffffffffc0201e6a:	2e079963          	bnez	a5,ffffffffc020215c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e6e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e72:	4585                	li	a1,1
ffffffffc0201e74:	739c                	ld	a5,32(a5)
ffffffffc0201e76:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e78:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e7c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e7e:	078a                	slli	a5,a5,0x2
ffffffffc0201e80:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e82:	3ae7f363          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e86:	fff80737          	lui	a4,0xfff80
ffffffffc0201e8a:	97ba                	add	a5,a5,a4
ffffffffc0201e8c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e90:	00379713          	slli	a4,a5,0x3
ffffffffc0201e94:	97ba                	add	a5,a5,a4
ffffffffc0201e96:	078e                	slli	a5,a5,0x3
ffffffffc0201e98:	953e                	add	a0,a0,a5
ffffffffc0201e9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e9e:	8b89                	andi	a5,a5,2
ffffffffc0201ea0:	2a079263          	bnez	a5,ffffffffc0202144 <pmm_init+0x65e>
ffffffffc0201ea4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ea8:	4585                	li	a1,1
ffffffffc0201eaa:	739c                	ld	a5,32(a5)
ffffffffc0201eac:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201eae:	00093783          	ld	a5,0(s2)
ffffffffc0201eb2:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201eb6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eba:	8b89                	andi	a5,a5,2
ffffffffc0201ebc:	26079a63          	bnez	a5,ffffffffc0202130 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ec0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ec4:	779c                	ld	a5,40(a5)
ffffffffc0201ec6:	9782                	jalr	a5
ffffffffc0201ec8:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201eca:	73441463          	bne	s0,s4,ffffffffc02025f2 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ece:	00003517          	auipc	a0,0x3
ffffffffc0201ed2:	7b250513          	addi	a0,a0,1970 # ffffffffc0205680 <default_pmm_manager+0x460>
ffffffffc0201ed6:	9e4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201eda:	100027f3          	csrr	a5,sstatus
ffffffffc0201ede:	8b89                	andi	a5,a5,2
ffffffffc0201ee0:	22079e63          	bnez	a5,ffffffffc020211c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ee4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ee8:	779c                	ld	a5,40(a5)
ffffffffc0201eea:	9782                	jalr	a5
ffffffffc0201eec:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eee:	6098                	ld	a4,0(s1)
ffffffffc0201ef0:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ef4:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ef6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201efa:	6a05                	lui	s4,0x1
ffffffffc0201efc:	02f47c63          	bgeu	s0,a5,ffffffffc0201f34 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f00:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f04:	00093503          	ld	a0,0(s2)
ffffffffc0201f08:	30e7f363          	bgeu	a5,a4,ffffffffc020220e <pmm_init+0x728>
ffffffffc0201f0c:	0009b583          	ld	a1,0(s3)
ffffffffc0201f10:	4601                	li	a2,0
ffffffffc0201f12:	95a2                	add	a1,a1,s0
ffffffffc0201f14:	fe8ff0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0201f18:	2c050b63          	beqz	a0,ffffffffc02021ee <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f1c:	611c                	ld	a5,0(a0)
ffffffffc0201f1e:	078a                	slli	a5,a5,0x2
ffffffffc0201f20:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f24:	2a879563          	bne	a5,s0,ffffffffc02021ce <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f28:	6098                	ld	a4,0(s1)
ffffffffc0201f2a:	9452                	add	s0,s0,s4
ffffffffc0201f2c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f30:	fcf468e3          	bltu	s0,a5,ffffffffc0201f00 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f34:	00093783          	ld	a5,0(s2)
ffffffffc0201f38:	639c                	ld	a5,0(a5)
ffffffffc0201f3a:	68079c63          	bnez	a5,ffffffffc02025d2 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f3e:	4505                	li	a0,1
ffffffffc0201f40:	eb0ff0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0201f44:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f46:	00093503          	ld	a0,0(s2)
ffffffffc0201f4a:	4699                	li	a3,6
ffffffffc0201f4c:	10000613          	li	a2,256
ffffffffc0201f50:	85d6                	mv	a1,s5
ffffffffc0201f52:	a95ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201f56:	64051e63          	bnez	a0,ffffffffc02025b2 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f5a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201f5e:	4785                	li	a5,1
ffffffffc0201f60:	62f71963          	bne	a4,a5,ffffffffc0202592 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f64:	00093503          	ld	a0,0(s2)
ffffffffc0201f68:	6405                	lui	s0,0x1
ffffffffc0201f6a:	4699                	li	a3,6
ffffffffc0201f6c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f70:	85d6                	mv	a1,s5
ffffffffc0201f72:	a75ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0201f76:	48051263          	bnez	a0,ffffffffc02023fa <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f7a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f7e:	4789                	li	a5,2
ffffffffc0201f80:	74f71563          	bne	a4,a5,ffffffffc02026ca <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f84:	00004597          	auipc	a1,0x4
ffffffffc0201f88:	83458593          	addi	a1,a1,-1996 # ffffffffc02057b8 <default_pmm_manager+0x598>
ffffffffc0201f8c:	10000513          	li	a0,256
ffffffffc0201f90:	4cc020ef          	jal	ra,ffffffffc020445c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f94:	10040593          	addi	a1,s0,256
ffffffffc0201f98:	10000513          	li	a0,256
ffffffffc0201f9c:	4d2020ef          	jal	ra,ffffffffc020446e <strcmp>
ffffffffc0201fa0:	70051563          	bnez	a0,ffffffffc02026aa <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fa4:	000b3683          	ld	a3,0(s6)
ffffffffc0201fa8:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fac:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fae:	40da86b3          	sub	a3,s5,a3
ffffffffc0201fb2:	868d                	srai	a3,a3,0x3
ffffffffc0201fb4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fb8:	609c                	ld	a5,0(s1)
ffffffffc0201fba:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fbc:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fbe:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc4:	52f77b63          	bgeu	a4,a5,ffffffffc02024fa <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fc8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fcc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fd0:	96be                	add	a3,a3,a5
ffffffffc0201fd2:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb94>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fd6:	450020ef          	jal	ra,ffffffffc0204426 <strlen>
ffffffffc0201fda:	6a051863          	bnez	a0,ffffffffc020268a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fde:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fe2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe4:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201fe8:	078a                	slli	a5,a5,0x2
ffffffffc0201fea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fec:	22e7fe63          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff0:	41a787b3          	sub	a5,a5,s10
ffffffffc0201ff4:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ff8:	96be                	add	a3,a3,a5
ffffffffc0201ffa:	03968cb3          	mul	s9,a3,s9
ffffffffc0201ffe:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202002:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202004:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202006:	4ee47a63          	bgeu	s0,a4,ffffffffc02024fa <pmm_init+0xa14>
ffffffffc020200a:	0009b403          	ld	s0,0(s3)
ffffffffc020200e:	9436                	add	s0,s0,a3
ffffffffc0202010:	100027f3          	csrr	a5,sstatus
ffffffffc0202014:	8b89                	andi	a5,a5,2
ffffffffc0202016:	1a079163          	bnez	a5,ffffffffc02021b8 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020201a:	000bb783          	ld	a5,0(s7)
ffffffffc020201e:	4585                	li	a1,1
ffffffffc0202020:	8556                	mv	a0,s5
ffffffffc0202022:	739c                	ld	a5,32(a5)
ffffffffc0202024:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202026:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202028:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020202a:	078a                	slli	a5,a5,0x2
ffffffffc020202c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020202e:	1ee7fd63          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202032:	fff80737          	lui	a4,0xfff80
ffffffffc0202036:	97ba                	add	a5,a5,a4
ffffffffc0202038:	000b3503          	ld	a0,0(s6)
ffffffffc020203c:	00379713          	slli	a4,a5,0x3
ffffffffc0202040:	97ba                	add	a5,a5,a4
ffffffffc0202042:	078e                	slli	a5,a5,0x3
ffffffffc0202044:	953e                	add	a0,a0,a5
ffffffffc0202046:	100027f3          	csrr	a5,sstatus
ffffffffc020204a:	8b89                	andi	a5,a5,2
ffffffffc020204c:	14079a63          	bnez	a5,ffffffffc02021a0 <pmm_init+0x6ba>
ffffffffc0202050:	000bb783          	ld	a5,0(s7)
ffffffffc0202054:	4585                	li	a1,1
ffffffffc0202056:	739c                	ld	a5,32(a5)
ffffffffc0202058:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020205a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020205e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202060:	078a                	slli	a5,a5,0x2
ffffffffc0202062:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202064:	1ce7f263          	bgeu	a5,a4,ffffffffc0202228 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202068:	fff80737          	lui	a4,0xfff80
ffffffffc020206c:	97ba                	add	a5,a5,a4
ffffffffc020206e:	000b3503          	ld	a0,0(s6)
ffffffffc0202072:	00379713          	slli	a4,a5,0x3
ffffffffc0202076:	97ba                	add	a5,a5,a4
ffffffffc0202078:	078e                	slli	a5,a5,0x3
ffffffffc020207a:	953e                	add	a0,a0,a5
ffffffffc020207c:	100027f3          	csrr	a5,sstatus
ffffffffc0202080:	8b89                	andi	a5,a5,2
ffffffffc0202082:	10079363          	bnez	a5,ffffffffc0202188 <pmm_init+0x6a2>
ffffffffc0202086:	000bb783          	ld	a5,0(s7)
ffffffffc020208a:	4585                	li	a1,1
ffffffffc020208c:	739c                	ld	a5,32(a5)
ffffffffc020208e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202090:	00093783          	ld	a5,0(s2)
ffffffffc0202094:	0007b023          	sd	zero,0(a5)
ffffffffc0202098:	100027f3          	csrr	a5,sstatus
ffffffffc020209c:	8b89                	andi	a5,a5,2
ffffffffc020209e:	0c079b63          	bnez	a5,ffffffffc0202174 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020a2:	000bb783          	ld	a5,0(s7)
ffffffffc02020a6:	779c                	ld	a5,40(a5)
ffffffffc02020a8:	9782                	jalr	a5
ffffffffc02020aa:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02020ac:	3a8c1763          	bne	s8,s0,ffffffffc020245a <pmm_init+0x974>
}
ffffffffc02020b0:	7406                	ld	s0,96(sp)
ffffffffc02020b2:	70a6                	ld	ra,104(sp)
ffffffffc02020b4:	64e6                	ld	s1,88(sp)
ffffffffc02020b6:	6946                	ld	s2,80(sp)
ffffffffc02020b8:	69a6                	ld	s3,72(sp)
ffffffffc02020ba:	6a06                	ld	s4,64(sp)
ffffffffc02020bc:	7ae2                	ld	s5,56(sp)
ffffffffc02020be:	7b42                	ld	s6,48(sp)
ffffffffc02020c0:	7ba2                	ld	s7,40(sp)
ffffffffc02020c2:	7c02                	ld	s8,32(sp)
ffffffffc02020c4:	6ce2                	ld	s9,24(sp)
ffffffffc02020c6:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020c8:	00003517          	auipc	a0,0x3
ffffffffc02020cc:	76850513          	addi	a0,a0,1896 # ffffffffc0205830 <default_pmm_manager+0x610>
}
ffffffffc02020d0:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020d2:	fe9fd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020d6:	6705                	lui	a4,0x1
ffffffffc02020d8:	177d                	addi	a4,a4,-1
ffffffffc02020da:	96ba                	add	a3,a3,a4
ffffffffc02020dc:	777d                	lui	a4,0xfffff
ffffffffc02020de:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02020e0:	00c75693          	srli	a3,a4,0xc
ffffffffc02020e4:	14f6f263          	bgeu	a3,a5,ffffffffc0202228 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02020e8:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020ec:	95b6                	add	a1,a1,a3
ffffffffc02020ee:	00359793          	slli	a5,a1,0x3
ffffffffc02020f2:	97ae                	add	a5,a5,a1
ffffffffc02020f4:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f8:	40e60733          	sub	a4,a2,a4
ffffffffc02020fc:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020fe:	00c75593          	srli	a1,a4,0xc
ffffffffc0202102:	953e                	add	a0,a0,a5
ffffffffc0202104:	9682                	jalr	a3
}
ffffffffc0202106:	bcc5                	j	ffffffffc0201bf6 <pmm_init+0x110>
        intr_disable();
ffffffffc0202108:	be6fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020210c:	000bb783          	ld	a5,0(s7)
ffffffffc0202110:	779c                	ld	a5,40(a5)
ffffffffc0202112:	9782                	jalr	a5
ffffffffc0202114:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202116:	bd2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020211a:	b63d                	j	ffffffffc0201c48 <pmm_init+0x162>
        intr_disable();
ffffffffc020211c:	bd2fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202120:	000bb783          	ld	a5,0(s7)
ffffffffc0202124:	779c                	ld	a5,40(a5)
ffffffffc0202126:	9782                	jalr	a5
ffffffffc0202128:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020212a:	bbefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020212e:	b3c1                	j	ffffffffc0201eee <pmm_init+0x408>
        intr_disable();
ffffffffc0202130:	bbefe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202134:	000bb783          	ld	a5,0(s7)
ffffffffc0202138:	779c                	ld	a5,40(a5)
ffffffffc020213a:	9782                	jalr	a5
ffffffffc020213c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020213e:	baafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202142:	b361                	j	ffffffffc0201eca <pmm_init+0x3e4>
ffffffffc0202144:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202146:	ba8fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020214a:	000bb783          	ld	a5,0(s7)
ffffffffc020214e:	6522                	ld	a0,8(sp)
ffffffffc0202150:	4585                	li	a1,1
ffffffffc0202152:	739c                	ld	a5,32(a5)
ffffffffc0202154:	9782                	jalr	a5
        intr_enable();
ffffffffc0202156:	b92fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020215a:	bb91                	j	ffffffffc0201eae <pmm_init+0x3c8>
ffffffffc020215c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020215e:	b90fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202162:	000bb783          	ld	a5,0(s7)
ffffffffc0202166:	6522                	ld	a0,8(sp)
ffffffffc0202168:	4585                	li	a1,1
ffffffffc020216a:	739c                	ld	a5,32(a5)
ffffffffc020216c:	9782                	jalr	a5
        intr_enable();
ffffffffc020216e:	b7afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202172:	b319                	j	ffffffffc0201e78 <pmm_init+0x392>
        intr_disable();
ffffffffc0202174:	b7afe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202178:	000bb783          	ld	a5,0(s7)
ffffffffc020217c:	779c                	ld	a5,40(a5)
ffffffffc020217e:	9782                	jalr	a5
ffffffffc0202180:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202182:	b66fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202186:	b71d                	j	ffffffffc02020ac <pmm_init+0x5c6>
ffffffffc0202188:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020218a:	b64fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020218e:	000bb783          	ld	a5,0(s7)
ffffffffc0202192:	6522                	ld	a0,8(sp)
ffffffffc0202194:	4585                	li	a1,1
ffffffffc0202196:	739c                	ld	a5,32(a5)
ffffffffc0202198:	9782                	jalr	a5
        intr_enable();
ffffffffc020219a:	b4efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020219e:	bdcd                	j	ffffffffc0202090 <pmm_init+0x5aa>
ffffffffc02021a0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021a2:	b4cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021a6:	000bb783          	ld	a5,0(s7)
ffffffffc02021aa:	6522                	ld	a0,8(sp)
ffffffffc02021ac:	4585                	li	a1,1
ffffffffc02021ae:	739c                	ld	a5,32(a5)
ffffffffc02021b0:	9782                	jalr	a5
        intr_enable();
ffffffffc02021b2:	b36fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021b6:	b555                	j	ffffffffc020205a <pmm_init+0x574>
        intr_disable();
ffffffffc02021b8:	b36fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021bc:	000bb783          	ld	a5,0(s7)
ffffffffc02021c0:	4585                	li	a1,1
ffffffffc02021c2:	8556                	mv	a0,s5
ffffffffc02021c4:	739c                	ld	a5,32(a5)
ffffffffc02021c6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021c8:	b20fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021cc:	bda9                	j	ffffffffc0202026 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02021ce:	00003697          	auipc	a3,0x3
ffffffffc02021d2:	51268693          	addi	a3,a3,1298 # ffffffffc02056e0 <default_pmm_manager+0x4c0>
ffffffffc02021d6:	00003617          	auipc	a2,0x3
ffffffffc02021da:	c9a60613          	addi	a2,a2,-870 # ffffffffc0204e70 <commands+0x748>
ffffffffc02021de:	1d100593          	li	a1,465
ffffffffc02021e2:	00003517          	auipc	a0,0x3
ffffffffc02021e6:	0f650513          	addi	a0,a0,246 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02021ea:	98afe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02021ee:	00003697          	auipc	a3,0x3
ffffffffc02021f2:	4b268693          	addi	a3,a3,1202 # ffffffffc02056a0 <default_pmm_manager+0x480>
ffffffffc02021f6:	00003617          	auipc	a2,0x3
ffffffffc02021fa:	c7a60613          	addi	a2,a2,-902 # ffffffffc0204e70 <commands+0x748>
ffffffffc02021fe:	1d000593          	li	a1,464
ffffffffc0202202:	00003517          	auipc	a0,0x3
ffffffffc0202206:	0d650513          	addi	a0,a0,214 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020220a:	96afe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020220e:	86a2                	mv	a3,s0
ffffffffc0202210:	00003617          	auipc	a2,0x3
ffffffffc0202214:	0a060613          	addi	a2,a2,160 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc0202218:	1d000593          	li	a1,464
ffffffffc020221c:	00003517          	auipc	a0,0x3
ffffffffc0202220:	0bc50513          	addi	a0,a0,188 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202224:	950fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202228:	b90ff0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020222c:	00003617          	auipc	a2,0x3
ffffffffc0202230:	14460613          	addi	a2,a2,324 # ffffffffc0205370 <default_pmm_manager+0x150>
ffffffffc0202234:	07900593          	li	a1,121
ffffffffc0202238:	00003517          	auipc	a0,0x3
ffffffffc020223c:	0a050513          	addi	a0,a0,160 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202240:	934fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202244:	00003617          	auipc	a2,0x3
ffffffffc0202248:	12c60613          	addi	a2,a2,300 # ffffffffc0205370 <default_pmm_manager+0x150>
ffffffffc020224c:	0bf00593          	li	a1,191
ffffffffc0202250:	00003517          	auipc	a0,0x3
ffffffffc0202254:	08850513          	addi	a0,a0,136 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202258:	91cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020225c:	00003697          	auipc	a3,0x3
ffffffffc0202260:	17c68693          	addi	a3,a3,380 # ffffffffc02053d8 <default_pmm_manager+0x1b8>
ffffffffc0202264:	00003617          	auipc	a2,0x3
ffffffffc0202268:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0204e70 <commands+0x748>
ffffffffc020226c:	19600593          	li	a1,406
ffffffffc0202270:	00003517          	auipc	a0,0x3
ffffffffc0202274:	06850513          	addi	a0,a0,104 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202278:	8fcfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020227c:	00003697          	auipc	a3,0x3
ffffffffc0202280:	13c68693          	addi	a3,a3,316 # ffffffffc02053b8 <default_pmm_manager+0x198>
ffffffffc0202284:	00003617          	auipc	a2,0x3
ffffffffc0202288:	bec60613          	addi	a2,a2,-1044 # ffffffffc0204e70 <commands+0x748>
ffffffffc020228c:	19500593          	li	a1,405
ffffffffc0202290:	00003517          	auipc	a0,0x3
ffffffffc0202294:	04850513          	addi	a0,a0,72 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202298:	8dcfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020229c:	b38ff0ef          	jal	ra,ffffffffc02015d4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	1c868693          	addi	a3,a3,456 # ffffffffc0205468 <default_pmm_manager+0x248>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204e70 <commands+0x748>
ffffffffc02022b0:	19d00593          	li	a1,413
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	02450513          	addi	a0,a0,36 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02022bc:	8b8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	17868693          	addi	a3,a3,376 # ffffffffc0205438 <default_pmm_manager+0x218>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e70 <commands+0x748>
ffffffffc02022d0:	19b00593          	li	a1,411
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	00450513          	addi	a0,a0,4 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02022dc:	898fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	13068693          	addi	a3,a3,304 # ffffffffc0205410 <default_pmm_manager+0x1f0>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204e70 <commands+0x748>
ffffffffc02022f0:	19700593          	li	a1,407
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	fe450513          	addi	a0,a0,-28 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02022fc:	878fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202300:	00003697          	auipc	a3,0x3
ffffffffc0202304:	1f068693          	addi	a3,a3,496 # ffffffffc02054f0 <default_pmm_manager+0x2d0>
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202310:	1a600593          	li	a1,422
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	fc450513          	addi	a0,a0,-60 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020231c:	858fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202320:	00003697          	auipc	a3,0x3
ffffffffc0202324:	27068693          	addi	a3,a3,624 # ffffffffc0205590 <default_pmm_manager+0x370>
ffffffffc0202328:	00003617          	auipc	a2,0x3
ffffffffc020232c:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202330:	1ab00593          	li	a1,427
ffffffffc0202334:	00003517          	auipc	a0,0x3
ffffffffc0202338:	fa450513          	addi	a0,a0,-92 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020233c:	838fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202340:	00003697          	auipc	a3,0x3
ffffffffc0202344:	18868693          	addi	a3,a3,392 # ffffffffc02054c8 <default_pmm_manager+0x2a8>
ffffffffc0202348:	00003617          	auipc	a2,0x3
ffffffffc020234c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202350:	1a300593          	li	a1,419
ffffffffc0202354:	00003517          	auipc	a0,0x3
ffffffffc0202358:	f8450513          	addi	a0,a0,-124 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020235c:	818fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202360:	86d6                	mv	a3,s5
ffffffffc0202362:	00003617          	auipc	a2,0x3
ffffffffc0202366:	f4e60613          	addi	a2,a2,-178 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc020236a:	1a200593          	li	a1,418
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	f6a50513          	addi	a0,a0,-150 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202376:	ffffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	1ae68693          	addi	a3,a3,430 # ffffffffc0205528 <default_pmm_manager+0x308>
ffffffffc0202382:	00003617          	auipc	a2,0x3
ffffffffc0202386:	aee60613          	addi	a2,a2,-1298 # ffffffffc0204e70 <commands+0x748>
ffffffffc020238a:	1b000593          	li	a1,432
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	f4a50513          	addi	a0,a0,-182 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202396:	fdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	25668693          	addi	a3,a3,598 # ffffffffc02055f0 <default_pmm_manager+0x3d0>
ffffffffc02023a2:	00003617          	auipc	a2,0x3
ffffffffc02023a6:	ace60613          	addi	a2,a2,-1330 # ffffffffc0204e70 <commands+0x748>
ffffffffc02023aa:	1af00593          	li	a1,431
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	f2a50513          	addi	a0,a0,-214 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02023b6:	fbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	21e68693          	addi	a3,a3,542 # ffffffffc02055d8 <default_pmm_manager+0x3b8>
ffffffffc02023c2:	00003617          	auipc	a2,0x3
ffffffffc02023c6:	aae60613          	addi	a2,a2,-1362 # ffffffffc0204e70 <commands+0x748>
ffffffffc02023ca:	1ae00593          	li	a1,430
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	f0a50513          	addi	a0,a0,-246 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02023d6:	f9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	1ce68693          	addi	a3,a3,462 # ffffffffc02055a8 <default_pmm_manager+0x388>
ffffffffc02023e2:	00003617          	auipc	a2,0x3
ffffffffc02023e6:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0204e70 <commands+0x748>
ffffffffc02023ea:	1ad00593          	li	a1,429
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	eea50513          	addi	a0,a0,-278 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02023f6:	f7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	36668693          	addi	a3,a3,870 # ffffffffc0205760 <default_pmm_manager+0x540>
ffffffffc0202402:	00003617          	auipc	a2,0x3
ffffffffc0202406:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204e70 <commands+0x748>
ffffffffc020240a:	1db00593          	li	a1,475
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	eca50513          	addi	a0,a0,-310 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202416:	f5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	15e68693          	addi	a3,a3,350 # ffffffffc0205578 <default_pmm_manager+0x358>
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204e70 <commands+0x748>
ffffffffc020242a:	1aa00593          	li	a1,426
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	eaa50513          	addi	a0,a0,-342 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202436:	f3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	12e68693          	addi	a3,a3,302 # ffffffffc0205568 <default_pmm_manager+0x348>
ffffffffc0202442:	00003617          	auipc	a2,0x3
ffffffffc0202446:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204e70 <commands+0x748>
ffffffffc020244a:	1a900593          	li	a1,425
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	e8a50513          	addi	a0,a0,-374 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202456:	f1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	20668693          	addi	a3,a3,518 # ffffffffc0205660 <default_pmm_manager+0x440>
ffffffffc0202462:	00003617          	auipc	a2,0x3
ffffffffc0202466:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204e70 <commands+0x748>
ffffffffc020246a:	1eb00593          	li	a1,491
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	e6a50513          	addi	a0,a0,-406 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202476:	efffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	0de68693          	addi	a3,a3,222 # ffffffffc0205558 <default_pmm_manager+0x338>
ffffffffc0202482:	00003617          	auipc	a2,0x3
ffffffffc0202486:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204e70 <commands+0x748>
ffffffffc020248a:	1a800593          	li	a1,424
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	e4a50513          	addi	a0,a0,-438 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202496:	edffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020249a:	00003697          	auipc	a3,0x3
ffffffffc020249e:	01668693          	addi	a3,a3,22 # ffffffffc02054b0 <default_pmm_manager+0x290>
ffffffffc02024a2:	00003617          	auipc	a2,0x3
ffffffffc02024a6:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204e70 <commands+0x748>
ffffffffc02024aa:	1b500593          	li	a1,437
ffffffffc02024ae:	00003517          	auipc	a0,0x3
ffffffffc02024b2:	e2a50513          	addi	a0,a0,-470 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02024b6:	ebffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ba:	00003697          	auipc	a3,0x3
ffffffffc02024be:	14e68693          	addi	a3,a3,334 # ffffffffc0205608 <default_pmm_manager+0x3e8>
ffffffffc02024c2:	00003617          	auipc	a2,0x3
ffffffffc02024c6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204e70 <commands+0x748>
ffffffffc02024ca:	1b200593          	li	a1,434
ffffffffc02024ce:	00003517          	auipc	a0,0x3
ffffffffc02024d2:	e0a50513          	addi	a0,a0,-502 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02024d6:	e9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02024da:	00003697          	auipc	a3,0x3
ffffffffc02024de:	fbe68693          	addi	a3,a3,-66 # ffffffffc0205498 <default_pmm_manager+0x278>
ffffffffc02024e2:	00003617          	auipc	a2,0x3
ffffffffc02024e6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204e70 <commands+0x748>
ffffffffc02024ea:	1b100593          	li	a1,433
ffffffffc02024ee:	00003517          	auipc	a0,0x3
ffffffffc02024f2:	dea50513          	addi	a0,a0,-534 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02024f6:	e7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02024fa:	00003617          	auipc	a2,0x3
ffffffffc02024fe:	db660613          	addi	a2,a2,-586 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc0202502:	06a00593          	li	a1,106
ffffffffc0202506:	00003517          	auipc	a0,0x3
ffffffffc020250a:	d7250513          	addi	a0,a0,-654 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc020250e:	e67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202512:	00003697          	auipc	a3,0x3
ffffffffc0202516:	12668693          	addi	a3,a3,294 # ffffffffc0205638 <default_pmm_manager+0x418>
ffffffffc020251a:	00003617          	auipc	a2,0x3
ffffffffc020251e:	95660613          	addi	a2,a2,-1706 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202522:	1bc00593          	li	a1,444
ffffffffc0202526:	00003517          	auipc	a0,0x3
ffffffffc020252a:	db250513          	addi	a0,a0,-590 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020252e:	e47fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202532:	00003697          	auipc	a3,0x3
ffffffffc0202536:	0be68693          	addi	a3,a3,190 # ffffffffc02055f0 <default_pmm_manager+0x3d0>
ffffffffc020253a:	00003617          	auipc	a2,0x3
ffffffffc020253e:	93660613          	addi	a2,a2,-1738 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202542:	1ba00593          	li	a1,442
ffffffffc0202546:	00003517          	auipc	a0,0x3
ffffffffc020254a:	d9250513          	addi	a0,a0,-622 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020254e:	e27fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202552:	00003697          	auipc	a3,0x3
ffffffffc0202556:	0ce68693          	addi	a3,a3,206 # ffffffffc0205620 <default_pmm_manager+0x400>
ffffffffc020255a:	00003617          	auipc	a2,0x3
ffffffffc020255e:	91660613          	addi	a2,a2,-1770 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202562:	1b900593          	li	a1,441
ffffffffc0202566:	00003517          	auipc	a0,0x3
ffffffffc020256a:	d7250513          	addi	a0,a0,-654 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020256e:	e07fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202572:	00003697          	auipc	a3,0x3
ffffffffc0202576:	07e68693          	addi	a3,a3,126 # ffffffffc02055f0 <default_pmm_manager+0x3d0>
ffffffffc020257a:	00003617          	auipc	a2,0x3
ffffffffc020257e:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202582:	1b600593          	li	a1,438
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	d5250513          	addi	a0,a0,-686 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020258e:	de7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202592:	00003697          	auipc	a3,0x3
ffffffffc0202596:	1b668693          	addi	a3,a3,438 # ffffffffc0205748 <default_pmm_manager+0x528>
ffffffffc020259a:	00003617          	auipc	a2,0x3
ffffffffc020259e:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204e70 <commands+0x748>
ffffffffc02025a2:	1da00593          	li	a1,474
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	d3250513          	addi	a0,a0,-718 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02025ae:	dc7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	15e68693          	addi	a3,a3,350 # ffffffffc0205710 <default_pmm_manager+0x4f0>
ffffffffc02025ba:	00003617          	auipc	a2,0x3
ffffffffc02025be:	8b660613          	addi	a2,a2,-1866 # ffffffffc0204e70 <commands+0x748>
ffffffffc02025c2:	1d900593          	li	a1,473
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	d1250513          	addi	a0,a0,-750 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02025ce:	da7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	12668693          	addi	a3,a3,294 # ffffffffc02056f8 <default_pmm_manager+0x4d8>
ffffffffc02025da:	00003617          	auipc	a2,0x3
ffffffffc02025de:	89660613          	addi	a2,a2,-1898 # ffffffffc0204e70 <commands+0x748>
ffffffffc02025e2:	1d500593          	li	a1,469
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	cf250513          	addi	a0,a0,-782 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02025ee:	d87fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02025f2:	00003697          	auipc	a3,0x3
ffffffffc02025f6:	06e68693          	addi	a3,a3,110 # ffffffffc0205660 <default_pmm_manager+0x440>
ffffffffc02025fa:	00003617          	auipc	a2,0x3
ffffffffc02025fe:	87660613          	addi	a2,a2,-1930 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202602:	1c300593          	li	a1,451
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	cd250513          	addi	a0,a0,-814 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020260e:	d67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202612:	00003697          	auipc	a3,0x3
ffffffffc0202616:	e8668693          	addi	a3,a3,-378 # ffffffffc0205498 <default_pmm_manager+0x278>
ffffffffc020261a:	00003617          	auipc	a2,0x3
ffffffffc020261e:	85660613          	addi	a2,a2,-1962 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202622:	19e00593          	li	a1,414
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	cb250513          	addi	a0,a0,-846 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020262e:	d47fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202632:	00003617          	auipc	a2,0x3
ffffffffc0202636:	c7e60613          	addi	a2,a2,-898 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc020263a:	1a100593          	li	a1,417
ffffffffc020263e:	00003517          	auipc	a0,0x3
ffffffffc0202642:	c9a50513          	addi	a0,a0,-870 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202646:	d2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020264a:	00003697          	auipc	a3,0x3
ffffffffc020264e:	e6668693          	addi	a3,a3,-410 # ffffffffc02054b0 <default_pmm_manager+0x290>
ffffffffc0202652:	00003617          	auipc	a2,0x3
ffffffffc0202656:	81e60613          	addi	a2,a2,-2018 # ffffffffc0204e70 <commands+0x748>
ffffffffc020265a:	19f00593          	li	a1,415
ffffffffc020265e:	00003517          	auipc	a0,0x3
ffffffffc0202662:	c7a50513          	addi	a0,a0,-902 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202666:	d0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020266a:	00003697          	auipc	a3,0x3
ffffffffc020266e:	ebe68693          	addi	a3,a3,-322 # ffffffffc0205528 <default_pmm_manager+0x308>
ffffffffc0202672:	00002617          	auipc	a2,0x2
ffffffffc0202676:	7fe60613          	addi	a2,a2,2046 # ffffffffc0204e70 <commands+0x748>
ffffffffc020267a:	1a700593          	li	a1,423
ffffffffc020267e:	00003517          	auipc	a0,0x3
ffffffffc0202682:	c5a50513          	addi	a0,a0,-934 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202686:	ceffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020268a:	00003697          	auipc	a3,0x3
ffffffffc020268e:	17e68693          	addi	a3,a3,382 # ffffffffc0205808 <default_pmm_manager+0x5e8>
ffffffffc0202692:	00002617          	auipc	a2,0x2
ffffffffc0202696:	7de60613          	addi	a2,a2,2014 # ffffffffc0204e70 <commands+0x748>
ffffffffc020269a:	1e300593          	li	a1,483
ffffffffc020269e:	00003517          	auipc	a0,0x3
ffffffffc02026a2:	c3a50513          	addi	a0,a0,-966 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02026a6:	ccffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02026aa:	00003697          	auipc	a3,0x3
ffffffffc02026ae:	12668693          	addi	a3,a3,294 # ffffffffc02057d0 <default_pmm_manager+0x5b0>
ffffffffc02026b2:	00002617          	auipc	a2,0x2
ffffffffc02026b6:	7be60613          	addi	a2,a2,1982 # ffffffffc0204e70 <commands+0x748>
ffffffffc02026ba:	1e000593          	li	a1,480
ffffffffc02026be:	00003517          	auipc	a0,0x3
ffffffffc02026c2:	c1a50513          	addi	a0,a0,-998 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02026c6:	caffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02026ca:	00003697          	auipc	a3,0x3
ffffffffc02026ce:	0d668693          	addi	a3,a3,214 # ffffffffc02057a0 <default_pmm_manager+0x580>
ffffffffc02026d2:	00002617          	auipc	a2,0x2
ffffffffc02026d6:	79e60613          	addi	a2,a2,1950 # ffffffffc0204e70 <commands+0x748>
ffffffffc02026da:	1dc00593          	li	a1,476
ffffffffc02026de:	00003517          	auipc	a0,0x3
ffffffffc02026e2:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc02026e6:	c8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02026ea <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02026ea:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02026ee:	8082                	ret

ffffffffc02026f0 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026f0:	7179                	addi	sp,sp,-48
ffffffffc02026f2:	e84a                	sd	s2,16(sp)
ffffffffc02026f4:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02026f6:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026f8:	f022                	sd	s0,32(sp)
ffffffffc02026fa:	ec26                	sd	s1,24(sp)
ffffffffc02026fc:	e44e                	sd	s3,8(sp)
ffffffffc02026fe:	f406                	sd	ra,40(sp)
ffffffffc0202700:	84ae                	mv	s1,a1
ffffffffc0202702:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202704:	eedfe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0202708:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020270a:	cd09                	beqz	a0,ffffffffc0202724 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020270c:	85aa                	mv	a1,a0
ffffffffc020270e:	86ce                	mv	a3,s3
ffffffffc0202710:	8626                	mv	a2,s1
ffffffffc0202712:	854a                	mv	a0,s2
ffffffffc0202714:	ad2ff0ef          	jal	ra,ffffffffc02019e6 <page_insert>
ffffffffc0202718:	ed21                	bnez	a0,ffffffffc0202770 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020271a:	0000f797          	auipc	a5,0xf
ffffffffc020271e:	e3e7a783          	lw	a5,-450(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0202722:	eb89                	bnez	a5,ffffffffc0202734 <pgdir_alloc_page+0x44>
}
ffffffffc0202724:	70a2                	ld	ra,40(sp)
ffffffffc0202726:	8522                	mv	a0,s0
ffffffffc0202728:	7402                	ld	s0,32(sp)
ffffffffc020272a:	64e2                	ld	s1,24(sp)
ffffffffc020272c:	6942                	ld	s2,16(sp)
ffffffffc020272e:	69a2                	ld	s3,8(sp)
ffffffffc0202730:	6145                	addi	sp,sp,48
ffffffffc0202732:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202734:	4681                	li	a3,0
ffffffffc0202736:	8622                	mv	a2,s0
ffffffffc0202738:	85a6                	mv	a1,s1
ffffffffc020273a:	0000f517          	auipc	a0,0xf
ffffffffc020273e:	e2653503          	ld	a0,-474(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0202742:	07f000ef          	jal	ra,ffffffffc0202fc0 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202746:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202748:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020274a:	4785                	li	a5,1
ffffffffc020274c:	fcf70ce3          	beq	a4,a5,ffffffffc0202724 <pgdir_alloc_page+0x34>
ffffffffc0202750:	00003697          	auipc	a3,0x3
ffffffffc0202754:	10068693          	addi	a3,a3,256 # ffffffffc0205850 <default_pmm_manager+0x630>
ffffffffc0202758:	00002617          	auipc	a2,0x2
ffffffffc020275c:	71860613          	addi	a2,a2,1816 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202760:	17d00593          	li	a1,381
ffffffffc0202764:	00003517          	auipc	a0,0x3
ffffffffc0202768:	b7450513          	addi	a0,a0,-1164 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020276c:	c09fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202770:	100027f3          	csrr	a5,sstatus
ffffffffc0202774:	8b89                	andi	a5,a5,2
ffffffffc0202776:	eb99                	bnez	a5,ffffffffc020278c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202778:	0000f797          	auipc	a5,0xf
ffffffffc020277c:	dc07b783          	ld	a5,-576(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0202780:	739c                	ld	a5,32(a5)
ffffffffc0202782:	8522                	mv	a0,s0
ffffffffc0202784:	4585                	li	a1,1
ffffffffc0202786:	9782                	jalr	a5
            return NULL;
ffffffffc0202788:	4401                	li	s0,0
ffffffffc020278a:	bf69                	j	ffffffffc0202724 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020278c:	d63fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202790:	0000f797          	auipc	a5,0xf
ffffffffc0202794:	da87b783          	ld	a5,-600(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0202798:	739c                	ld	a5,32(a5)
ffffffffc020279a:	8522                	mv	a0,s0
ffffffffc020279c:	4585                	li	a1,1
ffffffffc020279e:	9782                	jalr	a5
            return NULL;
ffffffffc02027a0:	4401                	li	s0,0
        intr_enable();
ffffffffc02027a2:	d47fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02027a6:	bfbd                	j	ffffffffc0202724 <pgdir_alloc_page+0x34>

ffffffffc02027a8 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02027a8:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027aa:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02027ac:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ae:	fff50713          	addi	a4,a0,-1
ffffffffc02027b2:	17f9                	addi	a5,a5,-2
ffffffffc02027b4:	04e7ea63          	bltu	a5,a4,ffffffffc0202808 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027b8:	6785                	lui	a5,0x1
ffffffffc02027ba:	17fd                	addi	a5,a5,-1
ffffffffc02027bc:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027be:	8131                	srli	a0,a0,0xc
ffffffffc02027c0:	e31fe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
    assert(base != NULL);
ffffffffc02027c4:	cd3d                	beqz	a0,ffffffffc0202842 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027c6:	0000f797          	auipc	a5,0xf
ffffffffc02027ca:	d6a7b783          	ld	a5,-662(a5) # ffffffffc0211530 <pages>
ffffffffc02027ce:	8d1d                	sub	a0,a0,a5
ffffffffc02027d0:	00004697          	auipc	a3,0x4
ffffffffc02027d4:	c586b683          	ld	a3,-936(a3) # ffffffffc0206428 <error_string+0x38>
ffffffffc02027d8:	850d                	srai	a0,a0,0x3
ffffffffc02027da:	02d50533          	mul	a0,a0,a3
ffffffffc02027de:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027e2:	0000f717          	auipc	a4,0xf
ffffffffc02027e6:	d4673703          	ld	a4,-698(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027ea:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027ec:	00c51793          	slli	a5,a0,0xc
ffffffffc02027f0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02027f2:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027f4:	02e7fa63          	bgeu	a5,a4,ffffffffc0202828 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02027f8:	60a2                	ld	ra,8(sp)
ffffffffc02027fa:	0000f797          	auipc	a5,0xf
ffffffffc02027fe:	d467b783          	ld	a5,-698(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0202802:	953e                	add	a0,a0,a5
ffffffffc0202804:	0141                	addi	sp,sp,16
ffffffffc0202806:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202808:	00003697          	auipc	a3,0x3
ffffffffc020280c:	06068693          	addi	a3,a3,96 # ffffffffc0205868 <default_pmm_manager+0x648>
ffffffffc0202810:	00002617          	auipc	a2,0x2
ffffffffc0202814:	66060613          	addi	a2,a2,1632 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202818:	1f300593          	li	a1,499
ffffffffc020281c:	00003517          	auipc	a0,0x3
ffffffffc0202820:	abc50513          	addi	a0,a0,-1348 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202824:	b51fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202828:	86aa                	mv	a3,a0
ffffffffc020282a:	00003617          	auipc	a2,0x3
ffffffffc020282e:	a8660613          	addi	a2,a2,-1402 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc0202832:	06a00593          	li	a1,106
ffffffffc0202836:	00003517          	auipc	a0,0x3
ffffffffc020283a:	a4250513          	addi	a0,a0,-1470 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc020283e:	b37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc0202842:	00003697          	auipc	a3,0x3
ffffffffc0202846:	04668693          	addi	a3,a3,70 # ffffffffc0205888 <default_pmm_manager+0x668>
ffffffffc020284a:	00002617          	auipc	a2,0x2
ffffffffc020284e:	62660613          	addi	a2,a2,1574 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202852:	1f600593          	li	a1,502
ffffffffc0202856:	00003517          	auipc	a0,0x3
ffffffffc020285a:	a8250513          	addi	a0,a0,-1406 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc020285e:	b17fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202862 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202862:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202864:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202866:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202868:	fff58713          	addi	a4,a1,-1
ffffffffc020286c:	17f9                	addi	a5,a5,-2
ffffffffc020286e:	0ae7ee63          	bltu	a5,a4,ffffffffc020292a <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202872:	cd41                	beqz	a0,ffffffffc020290a <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202874:	6785                	lui	a5,0x1
ffffffffc0202876:	17fd                	addi	a5,a5,-1
ffffffffc0202878:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020287a:	c02007b7          	lui	a5,0xc0200
ffffffffc020287e:	81b1                	srli	a1,a1,0xc
ffffffffc0202880:	06f56863          	bltu	a0,a5,ffffffffc02028f0 <kfree+0x8e>
ffffffffc0202884:	0000f697          	auipc	a3,0xf
ffffffffc0202888:	cbc6b683          	ld	a3,-836(a3) # ffffffffc0211540 <va_pa_offset>
ffffffffc020288c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020288e:	8131                	srli	a0,a0,0xc
ffffffffc0202890:	0000f797          	auipc	a5,0xf
ffffffffc0202894:	c987b783          	ld	a5,-872(a5) # ffffffffc0211528 <npage>
ffffffffc0202898:	04f57a63          	bgeu	a0,a5,ffffffffc02028ec <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020289c:	fff806b7          	lui	a3,0xfff80
ffffffffc02028a0:	9536                	add	a0,a0,a3
ffffffffc02028a2:	00351793          	slli	a5,a0,0x3
ffffffffc02028a6:	953e                	add	a0,a0,a5
ffffffffc02028a8:	050e                	slli	a0,a0,0x3
ffffffffc02028aa:	0000f797          	auipc	a5,0xf
ffffffffc02028ae:	c867b783          	ld	a5,-890(a5) # ffffffffc0211530 <pages>
ffffffffc02028b2:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028b4:	100027f3          	csrr	a5,sstatus
ffffffffc02028b8:	8b89                	andi	a5,a5,2
ffffffffc02028ba:	eb89                	bnez	a5,ffffffffc02028cc <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02028bc:	0000f797          	auipc	a5,0xf
ffffffffc02028c0:	c7c7b783          	ld	a5,-900(a5) # ffffffffc0211538 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02028c4:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02028c6:	739c                	ld	a5,32(a5)
}
ffffffffc02028c8:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02028ca:	8782                	jr	a5
        intr_disable();
ffffffffc02028cc:	e42a                	sd	a0,8(sp)
ffffffffc02028ce:	e02e                	sd	a1,0(sp)
ffffffffc02028d0:	c1ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02028d4:	0000f797          	auipc	a5,0xf
ffffffffc02028d8:	c647b783          	ld	a5,-924(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02028dc:	6582                	ld	a1,0(sp)
ffffffffc02028de:	6522                	ld	a0,8(sp)
ffffffffc02028e0:	739c                	ld	a5,32(a5)
ffffffffc02028e2:	9782                	jalr	a5
}
ffffffffc02028e4:	60e2                	ld	ra,24(sp)
ffffffffc02028e6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02028e8:	c01fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02028ec:	ccdfe0ef          	jal	ra,ffffffffc02015b8 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028f0:	86aa                	mv	a3,a0
ffffffffc02028f2:	00003617          	auipc	a2,0x3
ffffffffc02028f6:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0205370 <default_pmm_manager+0x150>
ffffffffc02028fa:	06c00593          	li	a1,108
ffffffffc02028fe:	00003517          	auipc	a0,0x3
ffffffffc0202902:	97a50513          	addi	a0,a0,-1670 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc0202906:	a6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020290a:	00003697          	auipc	a3,0x3
ffffffffc020290e:	f8e68693          	addi	a3,a3,-114 # ffffffffc0205898 <default_pmm_manager+0x678>
ffffffffc0202912:	00002617          	auipc	a2,0x2
ffffffffc0202916:	55e60613          	addi	a2,a2,1374 # ffffffffc0204e70 <commands+0x748>
ffffffffc020291a:	1fd00593          	li	a1,509
ffffffffc020291e:	00003517          	auipc	a0,0x3
ffffffffc0202922:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202926:	a4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020292a:	00003697          	auipc	a3,0x3
ffffffffc020292e:	f3e68693          	addi	a3,a3,-194 # ffffffffc0205868 <default_pmm_manager+0x648>
ffffffffc0202932:	00002617          	auipc	a2,0x2
ffffffffc0202936:	53e60613          	addi	a2,a2,1342 # ffffffffc0204e70 <commands+0x748>
ffffffffc020293a:	1fc00593          	li	a1,508
ffffffffc020293e:	00003517          	auipc	a0,0x3
ffffffffc0202942:	99a50513          	addi	a0,a0,-1638 # ffffffffc02052d8 <default_pmm_manager+0xb8>
ffffffffc0202946:	a2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020294a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020294a:	7135                	addi	sp,sp,-160
ffffffffc020294c:	ed06                	sd	ra,152(sp)
ffffffffc020294e:	e922                	sd	s0,144(sp)
ffffffffc0202950:	e526                	sd	s1,136(sp)
ffffffffc0202952:	e14a                	sd	s2,128(sp)
ffffffffc0202954:	fcce                	sd	s3,120(sp)
ffffffffc0202956:	f8d2                	sd	s4,112(sp)
ffffffffc0202958:	f4d6                	sd	s5,104(sp)
ffffffffc020295a:	f0da                	sd	s6,96(sp)
ffffffffc020295c:	ecde                	sd	s7,88(sp)
ffffffffc020295e:	e8e2                	sd	s8,80(sp)
ffffffffc0202960:	e4e6                	sd	s9,72(sp)
ffffffffc0202962:	e0ea                	sd	s10,64(sp)
ffffffffc0202964:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202966:	4b2010ef          	jal	ra,ffffffffc0203e18 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020296a:	0000f697          	auipc	a3,0xf
ffffffffc020296e:	bde6b683          	ld	a3,-1058(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc0202972:	010007b7          	lui	a5,0x1000
ffffffffc0202976:	ff968713          	addi	a4,a3,-7
ffffffffc020297a:	17e1                	addi	a5,a5,-8
ffffffffc020297c:	3ee7e063          	bltu	a5,a4,ffffffffc0202d5c <swap_init+0x412>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     // sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     // sm = &swap_manager_fifo;
     sm = &swap_manager_lru;
ffffffffc0202980:	00007797          	auipc	a5,0x7
ffffffffc0202984:	68078793          	addi	a5,a5,1664 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc0202988:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;
ffffffffc020298a:	0000fb17          	auipc	s6,0xf
ffffffffc020298e:	bc6b0b13          	addi	s6,s6,-1082 # ffffffffc0211550 <sm>
ffffffffc0202992:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202996:	9702                	jalr	a4
ffffffffc0202998:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc020299a:	c10d                	beqz	a0,ffffffffc02029bc <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020299c:	60ea                	ld	ra,152(sp)
ffffffffc020299e:	644a                	ld	s0,144(sp)
ffffffffc02029a0:	64aa                	ld	s1,136(sp)
ffffffffc02029a2:	690a                	ld	s2,128(sp)
ffffffffc02029a4:	7a46                	ld	s4,112(sp)
ffffffffc02029a6:	7aa6                	ld	s5,104(sp)
ffffffffc02029a8:	7b06                	ld	s6,96(sp)
ffffffffc02029aa:	6be6                	ld	s7,88(sp)
ffffffffc02029ac:	6c46                	ld	s8,80(sp)
ffffffffc02029ae:	6ca6                	ld	s9,72(sp)
ffffffffc02029b0:	6d06                	ld	s10,64(sp)
ffffffffc02029b2:	7de2                	ld	s11,56(sp)
ffffffffc02029b4:	854e                	mv	a0,s3
ffffffffc02029b6:	79e6                	ld	s3,120(sp)
ffffffffc02029b8:	610d                	addi	sp,sp,160
ffffffffc02029ba:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029bc:	000b3783          	ld	a5,0(s6)
ffffffffc02029c0:	00003517          	auipc	a0,0x3
ffffffffc02029c4:	f1850513          	addi	a0,a0,-232 # ffffffffc02058d8 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc02029c8:	0000e497          	auipc	s1,0xe
ffffffffc02029cc:	67848493          	addi	s1,s1,1656 # ffffffffc0211040 <free_area>
ffffffffc02029d0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02029d2:	4785                	li	a5,1
ffffffffc02029d4:	0000f717          	auipc	a4,0xf
ffffffffc02029d8:	b8f72223          	sw	a5,-1148(a4) # ffffffffc0211558 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029dc:	edefd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029e0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02029e2:	4401                	li	s0,0
ffffffffc02029e4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029e6:	2c978163          	beq	a5,s1,ffffffffc0202ca8 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02029ea:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02029ee:	8b09                	andi	a4,a4,2
ffffffffc02029f0:	2a070e63          	beqz	a4,ffffffffc0202cac <swap_init+0x362>
        count ++, total += p->property;
ffffffffc02029f4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029f8:	679c                	ld	a5,8(a5)
ffffffffc02029fa:	2d05                	addiw	s10,s10,1
ffffffffc02029fc:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029fe:	fe9796e3          	bne	a5,s1,ffffffffc02029ea <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202a02:	8922                	mv	s2,s0
ffffffffc0202a04:	cbffe0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0202a08:	47251663          	bne	a0,s2,ffffffffc0202e74 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202a0c:	8622                	mv	a2,s0
ffffffffc0202a0e:	85ea                	mv	a1,s10
ffffffffc0202a10:	00003517          	auipc	a0,0x3
ffffffffc0202a14:	ee050513          	addi	a0,a0,-288 # ffffffffc02058f0 <default_pmm_manager+0x6d0>
ffffffffc0202a18:	ea2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202a1c:	39b000ef          	jal	ra,ffffffffc02035b6 <mm_create>
ffffffffc0202a20:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202a22:	52050963          	beqz	a0,ffffffffc0202f54 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a26:	0000f797          	auipc	a5,0xf
ffffffffc0202a2a:	b3a78793          	addi	a5,a5,-1222 # ffffffffc0211560 <check_mm_struct>
ffffffffc0202a2e:	6398                	ld	a4,0(a5)
ffffffffc0202a30:	54071263          	bnez	a4,ffffffffc0202f74 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a34:	0000fb97          	auipc	s7,0xf
ffffffffc0202a38:	aecbbb83          	ld	s7,-1300(s7) # ffffffffc0211520 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a3c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a40:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a42:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a46:	3c071763          	bnez	a4,ffffffffc0202e14 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a4a:	6599                	lui	a1,0x6
ffffffffc0202a4c:	460d                	li	a2,3
ffffffffc0202a4e:	6505                	lui	a0,0x1
ffffffffc0202a50:	3af000ef          	jal	ra,ffffffffc02035fe <vma_create>
ffffffffc0202a54:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a56:	3c050f63          	beqz	a0,ffffffffc0202e34 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a5a:	8556                	mv	a0,s5
ffffffffc0202a5c:	411000ef          	jal	ra,ffffffffc020366c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a60:	00003517          	auipc	a0,0x3
ffffffffc0202a64:	f0050513          	addi	a0,a0,-256 # ffffffffc0205960 <default_pmm_manager+0x740>
ffffffffc0202a68:	e52fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a6c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a70:	4605                	li	a2,1
ffffffffc0202a72:	6585                	lui	a1,0x1
ffffffffc0202a74:	c89fe0ef          	jal	ra,ffffffffc02016fc <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202a78:	3c050e63          	beqz	a0,ffffffffc0202e54 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a7c:	00003517          	auipc	a0,0x3
ffffffffc0202a80:	f3450513          	addi	a0,a0,-204 # ffffffffc02059b0 <default_pmm_manager+0x790>
ffffffffc0202a84:	0000e917          	auipc	s2,0xe
ffffffffc0202a88:	5f490913          	addi	s2,s2,1524 # ffffffffc0211078 <check_rp>
ffffffffc0202a8c:	e2efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a90:	0000ea17          	auipc	s4,0xe
ffffffffc0202a94:	608a0a13          	addi	s4,s4,1544 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a98:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202a9a:	4505                	li	a0,1
ffffffffc0202a9c:	b55fe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
ffffffffc0202aa0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202aa4:	28050c63          	beqz	a0,ffffffffc0202d3c <swap_init+0x3f2>
ffffffffc0202aa8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202aaa:	8b89                	andi	a5,a5,2
ffffffffc0202aac:	26079863          	bnez	a5,ffffffffc0202d1c <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ab0:	0c21                	addi	s8,s8,8
ffffffffc0202ab2:	ff4c14e3          	bne	s8,s4,ffffffffc0202a9a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202ab6:	609c                	ld	a5,0(s1)
ffffffffc0202ab8:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202abc:	e084                	sd	s1,0(s1)
ffffffffc0202abe:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202ac0:	489c                	lw	a5,16(s1)
ffffffffc0202ac2:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202ac4:	0000ec17          	auipc	s8,0xe
ffffffffc0202ac8:	5b4c0c13          	addi	s8,s8,1460 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202acc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202ace:	0000e797          	auipc	a5,0xe
ffffffffc0202ad2:	5807a123          	sw	zero,1410(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202ad6:	000c3503          	ld	a0,0(s8)
ffffffffc0202ada:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202adc:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202ade:	ba5fe0ef          	jal	ra,ffffffffc0201682 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ae2:	ff4c1ae3          	bne	s8,s4,ffffffffc0202ad6 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ae6:	0104ac03          	lw	s8,16(s1)
ffffffffc0202aea:	4791                	li	a5,4
ffffffffc0202aec:	4afc1463          	bne	s8,a5,ffffffffc0202f94 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202af0:	00003517          	auipc	a0,0x3
ffffffffc0202af4:	f4850513          	addi	a0,a0,-184 # ffffffffc0205a38 <default_pmm_manager+0x818>
ffffffffc0202af8:	dc2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202afc:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202afe:	0000f797          	auipc	a5,0xf
ffffffffc0202b02:	a607a523          	sw	zero,-1430(a5) # ffffffffc0211568 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b06:	4529                	li	a0,10
ffffffffc0202b08:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202b0c:	0000f597          	auipc	a1,0xf
ffffffffc0202b10:	a5c5a583          	lw	a1,-1444(a1) # ffffffffc0211568 <pgfault_num>
ffffffffc0202b14:	4805                	li	a6,1
ffffffffc0202b16:	0000f797          	auipc	a5,0xf
ffffffffc0202b1a:	a5278793          	addi	a5,a5,-1454 # ffffffffc0211568 <pgfault_num>
ffffffffc0202b1e:	3f059b63          	bne	a1,a6,ffffffffc0202f14 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b22:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0202b26:	4390                	lw	a2,0(a5)
ffffffffc0202b28:	2601                	sext.w	a2,a2
ffffffffc0202b2a:	40b61563          	bne	a2,a1,ffffffffc0202f34 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b2e:	6589                	lui	a1,0x2
ffffffffc0202b30:	452d                	li	a0,11
ffffffffc0202b32:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202b36:	4390                	lw	a2,0(a5)
ffffffffc0202b38:	4809                	li	a6,2
ffffffffc0202b3a:	2601                	sext.w	a2,a2
ffffffffc0202b3c:	35061c63          	bne	a2,a6,ffffffffc0202e94 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b40:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0202b44:	438c                	lw	a1,0(a5)
ffffffffc0202b46:	2581                	sext.w	a1,a1
ffffffffc0202b48:	36c59663          	bne	a1,a2,ffffffffc0202eb4 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b4c:	658d                	lui	a1,0x3
ffffffffc0202b4e:	4531                	li	a0,12
ffffffffc0202b50:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202b54:	4390                	lw	a2,0(a5)
ffffffffc0202b56:	480d                	li	a6,3
ffffffffc0202b58:	2601                	sext.w	a2,a2
ffffffffc0202b5a:	37061d63          	bne	a2,a6,ffffffffc0202ed4 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b5e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0202b62:	438c                	lw	a1,0(a5)
ffffffffc0202b64:	2581                	sext.w	a1,a1
ffffffffc0202b66:	38c59763          	bne	a1,a2,ffffffffc0202ef4 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b6a:	6591                	lui	a1,0x4
ffffffffc0202b6c:	4535                	li	a0,13
ffffffffc0202b6e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202b72:	4390                	lw	a2,0(a5)
ffffffffc0202b74:	2601                	sext.w	a2,a2
ffffffffc0202b76:	21861f63          	bne	a2,s8,ffffffffc0202d94 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b7a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0202b7e:	439c                	lw	a5,0(a5)
ffffffffc0202b80:	2781                	sext.w	a5,a5
ffffffffc0202b82:	22c79963          	bne	a5,a2,ffffffffc0202db4 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202b86:	489c                	lw	a5,16(s1)
ffffffffc0202b88:	24079663          	bnez	a5,ffffffffc0202dd4 <swap_init+0x48a>
ffffffffc0202b8c:	0000e797          	auipc	a5,0xe
ffffffffc0202b90:	50c78793          	addi	a5,a5,1292 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202b94:	0000e617          	auipc	a2,0xe
ffffffffc0202b98:	52c60613          	addi	a2,a2,1324 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202b9c:	0000e517          	auipc	a0,0xe
ffffffffc0202ba0:	52450513          	addi	a0,a0,1316 # ffffffffc02110c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202ba4:	55fd                	li	a1,-1
ffffffffc0202ba6:	c38c                	sw	a1,0(a5)
ffffffffc0202ba8:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202baa:	0791                	addi	a5,a5,4
ffffffffc0202bac:	0611                	addi	a2,a2,4
ffffffffc0202bae:	fef51ce3          	bne	a0,a5,ffffffffc0202ba6 <swap_init+0x25c>
ffffffffc0202bb2:	0000e817          	auipc	a6,0xe
ffffffffc0202bb6:	4a680813          	addi	a6,a6,1190 # ffffffffc0211058 <check_ptep>
ffffffffc0202bba:	0000e897          	auipc	a7,0xe
ffffffffc0202bbe:	4be88893          	addi	a7,a7,1214 # ffffffffc0211078 <check_rp>
ffffffffc0202bc2:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202bc4:	0000fc97          	auipc	s9,0xf
ffffffffc0202bc8:	96cc8c93          	addi	s9,s9,-1684 # ffffffffc0211530 <pages>
ffffffffc0202bcc:	00004c17          	auipc	s8,0x4
ffffffffc0202bd0:	864c0c13          	addi	s8,s8,-1948 # ffffffffc0206430 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202bd4:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202bd8:	4601                	li	a2,0
ffffffffc0202bda:	855e                	mv	a0,s7
ffffffffc0202bdc:	ec46                	sd	a7,24(sp)
ffffffffc0202bde:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202be0:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202be2:	b1bfe0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0202be6:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202be8:	65c2                	ld	a1,16(sp)
ffffffffc0202bea:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202bec:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202bf0:	0000f317          	auipc	t1,0xf
ffffffffc0202bf4:	93830313          	addi	t1,t1,-1736 # ffffffffc0211528 <npage>
ffffffffc0202bf8:	16050e63          	beqz	a0,ffffffffc0202d74 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bfc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202bfe:	0017f613          	andi	a2,a5,1
ffffffffc0202c02:	0e060563          	beqz	a2,ffffffffc0202cec <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202c06:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c0a:	078a                	slli	a5,a5,0x2
ffffffffc0202c0c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c0e:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202d04 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c12:	000c3603          	ld	a2,0(s8)
ffffffffc0202c16:	000cb503          	ld	a0,0(s9)
ffffffffc0202c1a:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c1e:	8f91                	sub	a5,a5,a2
ffffffffc0202c20:	00379613          	slli	a2,a5,0x3
ffffffffc0202c24:	97b2                	add	a5,a5,a2
ffffffffc0202c26:	078e                	slli	a5,a5,0x3
ffffffffc0202c28:	97aa                	add	a5,a5,a0
ffffffffc0202c2a:	0aff1163          	bne	t5,a5,ffffffffc0202ccc <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c2e:	6785                	lui	a5,0x1
ffffffffc0202c30:	95be                	add	a1,a1,a5
ffffffffc0202c32:	6795                	lui	a5,0x5
ffffffffc0202c34:	0821                	addi	a6,a6,8
ffffffffc0202c36:	08a1                	addi	a7,a7,8
ffffffffc0202c38:	f8f59ee3          	bne	a1,a5,ffffffffc0202bd4 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c3c:	00003517          	auipc	a0,0x3
ffffffffc0202c40:	ea450513          	addi	a0,a0,-348 # ffffffffc0205ae0 <default_pmm_manager+0x8c0>
ffffffffc0202c44:	c76fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202c48:	000b3783          	ld	a5,0(s6)
ffffffffc0202c4c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c4e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202c50:	1a051263          	bnez	a0,ffffffffc0202df4 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202c54:	00093503          	ld	a0,0(s2)
ffffffffc0202c58:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c5a:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202c5c:	a27fe0ef          	jal	ra,ffffffffc0201682 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c60:	ff491ae3          	bne	s2,s4,ffffffffc0202c54 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202c64:	8556                	mv	a0,s5
ffffffffc0202c66:	2d7000ef          	jal	ra,ffffffffc020373c <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202c6a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c6c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c70:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c72:	7782                	ld	a5,32(sp)
ffffffffc0202c74:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c76:	009d8a63          	beq	s11,s1,ffffffffc0202c8a <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202c7a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c7e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c82:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c84:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c86:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c7a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202c8a:	8622                	mv	a2,s0
ffffffffc0202c8c:	85ea                	mv	a1,s10
ffffffffc0202c8e:	00003517          	auipc	a0,0x3
ffffffffc0202c92:	e8250513          	addi	a0,a0,-382 # ffffffffc0205b10 <default_pmm_manager+0x8f0>
ffffffffc0202c96:	c24fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202c9a:	00003517          	auipc	a0,0x3
ffffffffc0202c9e:	e9650513          	addi	a0,a0,-362 # ffffffffc0205b30 <default_pmm_manager+0x910>
ffffffffc0202ca2:	c18fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202ca6:	b9dd                	j	ffffffffc020299c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ca8:	4901                	li	s2,0
ffffffffc0202caa:	bba9                	j	ffffffffc0202a04 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202cac:	00002697          	auipc	a3,0x2
ffffffffc0202cb0:	1b468693          	addi	a3,a3,436 # ffffffffc0204e60 <commands+0x738>
ffffffffc0202cb4:	00002617          	auipc	a2,0x2
ffffffffc0202cb8:	1bc60613          	addi	a2,a2,444 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202cbc:	0bd00593          	li	a1,189
ffffffffc0202cc0:	00003517          	auipc	a0,0x3
ffffffffc0202cc4:	c0850513          	addi	a0,a0,-1016 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202cc8:	eacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202ccc:	00003697          	auipc	a3,0x3
ffffffffc0202cd0:	dec68693          	addi	a3,a3,-532 # ffffffffc0205ab8 <default_pmm_manager+0x898>
ffffffffc0202cd4:	00002617          	auipc	a2,0x2
ffffffffc0202cd8:	19c60613          	addi	a2,a2,412 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202cdc:	0fd00593          	li	a1,253
ffffffffc0202ce0:	00003517          	auipc	a0,0x3
ffffffffc0202ce4:	be850513          	addi	a0,a0,-1048 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202ce8:	e8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cec:	00002617          	auipc	a2,0x2
ffffffffc0202cf0:	59c60613          	addi	a2,a2,1436 # ffffffffc0205288 <default_pmm_manager+0x68>
ffffffffc0202cf4:	07000593          	li	a1,112
ffffffffc0202cf8:	00002517          	auipc	a0,0x2
ffffffffc0202cfc:	58050513          	addi	a0,a0,1408 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc0202d00:	e74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	55460613          	addi	a2,a2,1364 # ffffffffc0205258 <default_pmm_manager+0x38>
ffffffffc0202d0c:	06500593          	li	a1,101
ffffffffc0202d10:	00002517          	auipc	a0,0x2
ffffffffc0202d14:	56850513          	addi	a0,a0,1384 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	cd468693          	addi	a3,a3,-812 # ffffffffc02059f0 <default_pmm_manager+0x7d0>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	14c60613          	addi	a2,a2,332 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202d2c:	0de00593          	li	a1,222
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	b9850513          	addi	a0,a0,-1128 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202d38:	e3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	c9c68693          	addi	a3,a3,-868 # ffffffffc02059d8 <default_pmm_manager+0x7b8>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	12c60613          	addi	a2,a2,300 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202d4c:	0dd00593          	li	a1,221
ffffffffc0202d50:	00003517          	auipc	a0,0x3
ffffffffc0202d54:	b7850513          	addi	a0,a0,-1160 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202d58:	e1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d5c:	00003617          	auipc	a2,0x3
ffffffffc0202d60:	b4c60613          	addi	a2,a2,-1204 # ffffffffc02058a8 <default_pmm_manager+0x688>
ffffffffc0202d64:	02800593          	li	a1,40
ffffffffc0202d68:	00003517          	auipc	a0,0x3
ffffffffc0202d6c:	b6050513          	addi	a0,a0,-1184 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202d70:	e04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202d74:	00003697          	auipc	a3,0x3
ffffffffc0202d78:	d2c68693          	addi	a3,a3,-724 # ffffffffc0205aa0 <default_pmm_manager+0x880>
ffffffffc0202d7c:	00002617          	auipc	a2,0x2
ffffffffc0202d80:	0f460613          	addi	a2,a2,244 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202d84:	0fc00593          	li	a1,252
ffffffffc0202d88:	00003517          	auipc	a0,0x3
ffffffffc0202d8c:	b4050513          	addi	a0,a0,-1216 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202d90:	de4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d94:	00003697          	auipc	a3,0x3
ffffffffc0202d98:	cfc68693          	addi	a3,a3,-772 # ffffffffc0205a90 <default_pmm_manager+0x870>
ffffffffc0202d9c:	00002617          	auipc	a2,0x2
ffffffffc0202da0:	0d460613          	addi	a2,a2,212 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202da4:	0a000593          	li	a1,160
ffffffffc0202da8:	00003517          	auipc	a0,0x3
ffffffffc0202dac:	b2050513          	addi	a0,a0,-1248 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202db0:	dc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202db4:	00003697          	auipc	a3,0x3
ffffffffc0202db8:	cdc68693          	addi	a3,a3,-804 # ffffffffc0205a90 <default_pmm_manager+0x870>
ffffffffc0202dbc:	00002617          	auipc	a2,0x2
ffffffffc0202dc0:	0b460613          	addi	a2,a2,180 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202dc4:	0a200593          	li	a1,162
ffffffffc0202dc8:	00003517          	auipc	a0,0x3
ffffffffc0202dcc:	b0050513          	addi	a0,a0,-1280 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202dd0:	da4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202dd4:	00002697          	auipc	a3,0x2
ffffffffc0202dd8:	27468693          	addi	a3,a3,628 # ffffffffc0205048 <commands+0x920>
ffffffffc0202ddc:	00002617          	auipc	a2,0x2
ffffffffc0202de0:	09460613          	addi	a2,a2,148 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202de4:	0f400593          	li	a1,244
ffffffffc0202de8:	00003517          	auipc	a0,0x3
ffffffffc0202dec:	ae050513          	addi	a0,a0,-1312 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202df0:	d84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202df4:	00003697          	auipc	a3,0x3
ffffffffc0202df8:	d1468693          	addi	a3,a3,-748 # ffffffffc0205b08 <default_pmm_manager+0x8e8>
ffffffffc0202dfc:	00002617          	auipc	a2,0x2
ffffffffc0202e00:	07460613          	addi	a2,a2,116 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202e04:	10300593          	li	a1,259
ffffffffc0202e08:	00003517          	auipc	a0,0x3
ffffffffc0202e0c:	ac050513          	addi	a0,a0,-1344 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202e10:	d64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e14:	00003697          	auipc	a3,0x3
ffffffffc0202e18:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0205940 <default_pmm_manager+0x720>
ffffffffc0202e1c:	00002617          	auipc	a2,0x2
ffffffffc0202e20:	05460613          	addi	a2,a2,84 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202e24:	0cd00593          	li	a1,205
ffffffffc0202e28:	00003517          	auipc	a0,0x3
ffffffffc0202e2c:	aa050513          	addi	a0,a0,-1376 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202e30:	d44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e34:	00003697          	auipc	a3,0x3
ffffffffc0202e38:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0205950 <default_pmm_manager+0x730>
ffffffffc0202e3c:	00002617          	auipc	a2,0x2
ffffffffc0202e40:	03460613          	addi	a2,a2,52 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202e44:	0d000593          	li	a1,208
ffffffffc0202e48:	00003517          	auipc	a0,0x3
ffffffffc0202e4c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202e50:	d24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202e54:	00003697          	auipc	a3,0x3
ffffffffc0202e58:	b4468693          	addi	a3,a3,-1212 # ffffffffc0205998 <default_pmm_manager+0x778>
ffffffffc0202e5c:	00002617          	auipc	a2,0x2
ffffffffc0202e60:	01460613          	addi	a2,a2,20 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202e64:	0d800593          	li	a1,216
ffffffffc0202e68:	00003517          	auipc	a0,0x3
ffffffffc0202e6c:	a6050513          	addi	a0,a0,-1440 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202e70:	d04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e74:	00002697          	auipc	a3,0x2
ffffffffc0202e78:	02c68693          	addi	a3,a3,44 # ffffffffc0204ea0 <commands+0x778>
ffffffffc0202e7c:	00002617          	auipc	a2,0x2
ffffffffc0202e80:	ff460613          	addi	a2,a2,-12 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202e84:	0c000593          	li	a1,192
ffffffffc0202e88:	00003517          	auipc	a0,0x3
ffffffffc0202e8c:	a4050513          	addi	a0,a0,-1472 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202e90:	ce4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202e94:	00003697          	auipc	a3,0x3
ffffffffc0202e98:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0205a70 <default_pmm_manager+0x850>
ffffffffc0202e9c:	00002617          	auipc	a2,0x2
ffffffffc0202ea0:	fd460613          	addi	a2,a2,-44 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202ea4:	09800593          	li	a1,152
ffffffffc0202ea8:	00003517          	auipc	a0,0x3
ffffffffc0202eac:	a2050513          	addi	a0,a0,-1504 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202eb0:	cc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202eb4:	00003697          	auipc	a3,0x3
ffffffffc0202eb8:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0205a70 <default_pmm_manager+0x850>
ffffffffc0202ebc:	00002617          	auipc	a2,0x2
ffffffffc0202ec0:	fb460613          	addi	a2,a2,-76 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202ec4:	09a00593          	li	a1,154
ffffffffc0202ec8:	00003517          	auipc	a0,0x3
ffffffffc0202ecc:	a0050513          	addi	a0,a0,-1536 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202ed0:	ca4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ed4:	00003697          	auipc	a3,0x3
ffffffffc0202ed8:	bac68693          	addi	a3,a3,-1108 # ffffffffc0205a80 <default_pmm_manager+0x860>
ffffffffc0202edc:	00002617          	auipc	a2,0x2
ffffffffc0202ee0:	f9460613          	addi	a2,a2,-108 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202ee4:	09c00593          	li	a1,156
ffffffffc0202ee8:	00003517          	auipc	a0,0x3
ffffffffc0202eec:	9e050513          	addi	a0,a0,-1568 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202ef0:	c84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ef4:	00003697          	auipc	a3,0x3
ffffffffc0202ef8:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0205a80 <default_pmm_manager+0x860>
ffffffffc0202efc:	00002617          	auipc	a2,0x2
ffffffffc0202f00:	f7460613          	addi	a2,a2,-140 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202f04:	09e00593          	li	a1,158
ffffffffc0202f08:	00003517          	auipc	a0,0x3
ffffffffc0202f0c:	9c050513          	addi	a0,a0,-1600 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202f10:	c64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f14:	00003697          	auipc	a3,0x3
ffffffffc0202f18:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0205a60 <default_pmm_manager+0x840>
ffffffffc0202f1c:	00002617          	auipc	a2,0x2
ffffffffc0202f20:	f5460613          	addi	a2,a2,-172 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202f24:	09400593          	li	a1,148
ffffffffc0202f28:	00003517          	auipc	a0,0x3
ffffffffc0202f2c:	9a050513          	addi	a0,a0,-1632 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202f30:	c44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f34:	00003697          	auipc	a3,0x3
ffffffffc0202f38:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0205a60 <default_pmm_manager+0x840>
ffffffffc0202f3c:	00002617          	auipc	a2,0x2
ffffffffc0202f40:	f3460613          	addi	a2,a2,-204 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202f44:	09600593          	li	a1,150
ffffffffc0202f48:	00003517          	auipc	a0,0x3
ffffffffc0202f4c:	98050513          	addi	a0,a0,-1664 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202f50:	c24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202f54:	00003697          	auipc	a3,0x3
ffffffffc0202f58:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205918 <default_pmm_manager+0x6f8>
ffffffffc0202f5c:	00002617          	auipc	a2,0x2
ffffffffc0202f60:	f1460613          	addi	a2,a2,-236 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202f64:	0c500593          	li	a1,197
ffffffffc0202f68:	00003517          	auipc	a0,0x3
ffffffffc0202f6c:	96050513          	addi	a0,a0,-1696 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202f70:	c04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f74:	00003697          	auipc	a3,0x3
ffffffffc0202f78:	9b468693          	addi	a3,a3,-1612 # ffffffffc0205928 <default_pmm_manager+0x708>
ffffffffc0202f7c:	00002617          	auipc	a2,0x2
ffffffffc0202f80:	ef460613          	addi	a2,a2,-268 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202f84:	0c800593          	li	a1,200
ffffffffc0202f88:	00003517          	auipc	a0,0x3
ffffffffc0202f8c:	94050513          	addi	a0,a0,-1728 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202f90:	be4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202f94:	00003697          	auipc	a3,0x3
ffffffffc0202f98:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0205a10 <default_pmm_manager+0x7f0>
ffffffffc0202f9c:	00002617          	auipc	a2,0x2
ffffffffc0202fa0:	ed460613          	addi	a2,a2,-300 # ffffffffc0204e70 <commands+0x748>
ffffffffc0202fa4:	0eb00593          	li	a1,235
ffffffffc0202fa8:	00003517          	auipc	a0,0x3
ffffffffc0202fac:	92050513          	addi	a0,a0,-1760 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0202fb0:	bc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202fb4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202fb4:	0000e797          	auipc	a5,0xe
ffffffffc0202fb8:	59c7b783          	ld	a5,1436(a5) # ffffffffc0211550 <sm>
ffffffffc0202fbc:	6b9c                	ld	a5,16(a5)
ffffffffc0202fbe:	8782                	jr	a5

ffffffffc0202fc0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202fc0:	0000e797          	auipc	a5,0xe
ffffffffc0202fc4:	5907b783          	ld	a5,1424(a5) # ffffffffc0211550 <sm>
ffffffffc0202fc8:	739c                	ld	a5,32(a5)
ffffffffc0202fca:	8782                	jr	a5

ffffffffc0202fcc <swap_out>:
{
ffffffffc0202fcc:	711d                	addi	sp,sp,-96
ffffffffc0202fce:	ec86                	sd	ra,88(sp)
ffffffffc0202fd0:	e8a2                	sd	s0,80(sp)
ffffffffc0202fd2:	e4a6                	sd	s1,72(sp)
ffffffffc0202fd4:	e0ca                	sd	s2,64(sp)
ffffffffc0202fd6:	fc4e                	sd	s3,56(sp)
ffffffffc0202fd8:	f852                	sd	s4,48(sp)
ffffffffc0202fda:	f456                	sd	s5,40(sp)
ffffffffc0202fdc:	f05a                	sd	s6,32(sp)
ffffffffc0202fde:	ec5e                	sd	s7,24(sp)
ffffffffc0202fe0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202fe2:	cde9                	beqz	a1,ffffffffc02030bc <swap_out+0xf0>
ffffffffc0202fe4:	8a2e                	mv	s4,a1
ffffffffc0202fe6:	892a                	mv	s2,a0
ffffffffc0202fe8:	8ab2                	mv	s5,a2
ffffffffc0202fea:	4401                	li	s0,0
ffffffffc0202fec:	0000e997          	auipc	s3,0xe
ffffffffc0202ff0:	56498993          	addi	s3,s3,1380 # ffffffffc0211550 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ff4:	00003b17          	auipc	s6,0x3
ffffffffc0202ff8:	bbcb0b13          	addi	s6,s6,-1092 # ffffffffc0205bb0 <default_pmm_manager+0x990>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202ffc:	00003b97          	auipc	s7,0x3
ffffffffc0203000:	b9cb8b93          	addi	s7,s7,-1124 # ffffffffc0205b98 <default_pmm_manager+0x978>
ffffffffc0203004:	a825                	j	ffffffffc020303c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203006:	67a2                	ld	a5,8(sp)
ffffffffc0203008:	8626                	mv	a2,s1
ffffffffc020300a:	85a2                	mv	a1,s0
ffffffffc020300c:	63b4                	ld	a3,64(a5)
ffffffffc020300e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203010:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203012:	82b1                	srli	a3,a3,0xc
ffffffffc0203014:	0685                	addi	a3,a3,1
ffffffffc0203016:	8a4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020301a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020301c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020301e:	613c                	ld	a5,64(a0)
ffffffffc0203020:	83b1                	srli	a5,a5,0xc
ffffffffc0203022:	0785                	addi	a5,a5,1
ffffffffc0203024:	07a2                	slli	a5,a5,0x8
ffffffffc0203026:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020302a:	e58fe0ef          	jal	ra,ffffffffc0201682 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020302e:	01893503          	ld	a0,24(s2)
ffffffffc0203032:	85a6                	mv	a1,s1
ffffffffc0203034:	eb6ff0ef          	jal	ra,ffffffffc02026ea <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203038:	048a0d63          	beq	s4,s0,ffffffffc0203092 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020303c:	0009b783          	ld	a5,0(s3)
ffffffffc0203040:	8656                	mv	a2,s5
ffffffffc0203042:	002c                	addi	a1,sp,8
ffffffffc0203044:	7b9c                	ld	a5,48(a5)
ffffffffc0203046:	854a                	mv	a0,s2
ffffffffc0203048:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020304a:	e12d                	bnez	a0,ffffffffc02030ac <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020304c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020304e:	01893503          	ld	a0,24(s2)
ffffffffc0203052:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203054:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203056:	85a6                	mv	a1,s1
ffffffffc0203058:	ea4fe0ef          	jal	ra,ffffffffc02016fc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020305c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020305e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203060:	8b85                	andi	a5,a5,1
ffffffffc0203062:	cfb9                	beqz	a5,ffffffffc02030c0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203064:	65a2                	ld	a1,8(sp)
ffffffffc0203066:	61bc                	ld	a5,64(a1)
ffffffffc0203068:	83b1                	srli	a5,a5,0xc
ffffffffc020306a:	0785                	addi	a5,a5,1
ffffffffc020306c:	00879513          	slli	a0,a5,0x8
ffffffffc0203070:	67b000ef          	jal	ra,ffffffffc0203eea <swapfs_write>
ffffffffc0203074:	d949                	beqz	a0,ffffffffc0203006 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203076:	855e                	mv	a0,s7
ffffffffc0203078:	842fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020307c:	0009b783          	ld	a5,0(s3)
ffffffffc0203080:	6622                	ld	a2,8(sp)
ffffffffc0203082:	4681                	li	a3,0
ffffffffc0203084:	739c                	ld	a5,32(a5)
ffffffffc0203086:	85a6                	mv	a1,s1
ffffffffc0203088:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020308a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020308c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020308e:	fa8a17e3          	bne	s4,s0,ffffffffc020303c <swap_out+0x70>
}
ffffffffc0203092:	60e6                	ld	ra,88(sp)
ffffffffc0203094:	8522                	mv	a0,s0
ffffffffc0203096:	6446                	ld	s0,80(sp)
ffffffffc0203098:	64a6                	ld	s1,72(sp)
ffffffffc020309a:	6906                	ld	s2,64(sp)
ffffffffc020309c:	79e2                	ld	s3,56(sp)
ffffffffc020309e:	7a42                	ld	s4,48(sp)
ffffffffc02030a0:	7aa2                	ld	s5,40(sp)
ffffffffc02030a2:	7b02                	ld	s6,32(sp)
ffffffffc02030a4:	6be2                	ld	s7,24(sp)
ffffffffc02030a6:	6c42                	ld	s8,16(sp)
ffffffffc02030a8:	6125                	addi	sp,sp,96
ffffffffc02030aa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02030ac:	85a2                	mv	a1,s0
ffffffffc02030ae:	00003517          	auipc	a0,0x3
ffffffffc02030b2:	aa250513          	addi	a0,a0,-1374 # ffffffffc0205b50 <default_pmm_manager+0x930>
ffffffffc02030b6:	804fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc02030ba:	bfe1                	j	ffffffffc0203092 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02030bc:	4401                	li	s0,0
ffffffffc02030be:	bfd1                	j	ffffffffc0203092 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030c0:	00003697          	auipc	a3,0x3
ffffffffc02030c4:	ac068693          	addi	a3,a3,-1344 # ffffffffc0205b80 <default_pmm_manager+0x960>
ffffffffc02030c8:	00002617          	auipc	a2,0x2
ffffffffc02030cc:	da860613          	addi	a2,a2,-600 # ffffffffc0204e70 <commands+0x748>
ffffffffc02030d0:	06900593          	li	a1,105
ffffffffc02030d4:	00002517          	auipc	a0,0x2
ffffffffc02030d8:	7f450513          	addi	a0,a0,2036 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc02030dc:	a98fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030e0 <swap_in>:
{
ffffffffc02030e0:	7179                	addi	sp,sp,-48
ffffffffc02030e2:	e84a                	sd	s2,16(sp)
ffffffffc02030e4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02030e6:	4505                	li	a0,1
{
ffffffffc02030e8:	ec26                	sd	s1,24(sp)
ffffffffc02030ea:	e44e                	sd	s3,8(sp)
ffffffffc02030ec:	f406                	sd	ra,40(sp)
ffffffffc02030ee:	f022                	sd	s0,32(sp)
ffffffffc02030f0:	84ae                	mv	s1,a1
ffffffffc02030f2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02030f4:	cfcfe0ef          	jal	ra,ffffffffc02015f0 <alloc_pages>
     assert(result!=NULL);
ffffffffc02030f8:	c129                	beqz	a0,ffffffffc020313a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02030fa:	842a                	mv	s0,a0
ffffffffc02030fc:	01893503          	ld	a0,24(s2)
ffffffffc0203100:	4601                	li	a2,0
ffffffffc0203102:	85a6                	mv	a1,s1
ffffffffc0203104:	df8fe0ef          	jal	ra,ffffffffc02016fc <get_pte>
ffffffffc0203108:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020310a:	6108                	ld	a0,0(a0)
ffffffffc020310c:	85a2                	mv	a1,s0
ffffffffc020310e:	543000ef          	jal	ra,ffffffffc0203e50 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203112:	00093583          	ld	a1,0(s2)
ffffffffc0203116:	8626                	mv	a2,s1
ffffffffc0203118:	00003517          	auipc	a0,0x3
ffffffffc020311c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0205c00 <default_pmm_manager+0x9e0>
ffffffffc0203120:	81a1                	srli	a1,a1,0x8
ffffffffc0203122:	f99fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203126:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203128:	0089b023          	sd	s0,0(s3)
}
ffffffffc020312c:	7402                	ld	s0,32(sp)
ffffffffc020312e:	64e2                	ld	s1,24(sp)
ffffffffc0203130:	6942                	ld	s2,16(sp)
ffffffffc0203132:	69a2                	ld	s3,8(sp)
ffffffffc0203134:	4501                	li	a0,0
ffffffffc0203136:	6145                	addi	sp,sp,48
ffffffffc0203138:	8082                	ret
     assert(result!=NULL);
ffffffffc020313a:	00003697          	auipc	a3,0x3
ffffffffc020313e:	ab668693          	addi	a3,a3,-1354 # ffffffffc0205bf0 <default_pmm_manager+0x9d0>
ffffffffc0203142:	00002617          	auipc	a2,0x2
ffffffffc0203146:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204e70 <commands+0x748>
ffffffffc020314a:	07f00593          	li	a1,127
ffffffffc020314e:	00002517          	auipc	a0,0x2
ffffffffc0203152:	77a50513          	addi	a0,a0,1914 # ffffffffc02058c8 <default_pmm_manager+0x6a8>
ffffffffc0203156:	a1efd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020315a <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020315a:	0000e797          	auipc	a5,0xe
ffffffffc020315e:	f8e78793          	addi	a5,a5,-114 # ffffffffc02110e8 <pra_list_head>

static int
_lru_init_mm(struct mm_struct *mm)
{     
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc0203162:	f51c                	sd	a5,40(a0)
ffffffffc0203164:	e79c                	sd	a5,8(a5)
ffffffffc0203166:	e39c                	sd	a5,0(a5)
    //cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203168:	4501                	li	a0,0
ffffffffc020316a:	8082                	ret

ffffffffc020316c <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc020316c:	4501                	li	a0,0
ffffffffc020316e:	8082                	ret

ffffffffc0203170 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203170:	4501                	li	a0,0
ffffffffc0203172:	8082                	ret

ffffffffc0203174 <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{
    return 0;
}
ffffffffc0203174:	4501                	li	a0,0
ffffffffc0203176:	8082                	ret

ffffffffc0203178 <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0203178:	711d                	addi	sp,sp,-96
ffffffffc020317a:	fc4e                	sd	s3,56(sp)
ffffffffc020317c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc020317e:	00003517          	auipc	a0,0x3
ffffffffc0203182:	ac250513          	addi	a0,a0,-1342 # ffffffffc0205c40 <default_pmm_manager+0xa20>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203186:	698d                	lui	s3,0x3
ffffffffc0203188:	4a31                	li	s4,12
_lru_check_swap(void) {
ffffffffc020318a:	e0ca                	sd	s2,64(sp)
ffffffffc020318c:	ec86                	sd	ra,88(sp)
ffffffffc020318e:	e8a2                	sd	s0,80(sp)
ffffffffc0203190:	e4a6                	sd	s1,72(sp)
ffffffffc0203192:	f456                	sd	s5,40(sp)
ffffffffc0203194:	f05a                	sd	s6,32(sp)
ffffffffc0203196:	ec5e                	sd	s7,24(sp)
ffffffffc0203198:	e862                	sd	s8,16(sp)
ffffffffc020319a:	e466                	sd	s9,8(sp)
ffffffffc020319c:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc020319e:	f1dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031a2:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num == 4);
ffffffffc02031a6:	0000e917          	auipc	s2,0xe
ffffffffc02031aa:	3c292903          	lw	s2,962(s2) # ffffffffc0211568 <pgfault_num>
ffffffffc02031ae:	4791                	li	a5,4
ffffffffc02031b0:	14f91e63          	bne	s2,a5,ffffffffc020330c <_lru_check_swap+0x194>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02031b4:	00003517          	auipc	a0,0x3
ffffffffc02031b8:	ae450513          	addi	a0,a0,-1308 # ffffffffc0205c98 <default_pmm_manager+0xa78>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031bc:	6a85                	lui	s5,0x1
ffffffffc02031be:	4b29                	li	s6,10
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02031c0:	efbfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02031c4:	0000e417          	auipc	s0,0xe
ffffffffc02031c8:	3a440413          	addi	s0,s0,932 # ffffffffc0211568 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031cc:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num == 4);
ffffffffc02031d0:	4004                	lw	s1,0(s0)
ffffffffc02031d2:	2481                	sext.w	s1,s1
ffffffffc02031d4:	2b249c63          	bne	s1,s2,ffffffffc020348c <_lru_check_swap+0x314>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc02031d8:	00003517          	auipc	a0,0x3
ffffffffc02031dc:	ae850513          	addi	a0,a0,-1304 # ffffffffc0205cc0 <default_pmm_manager+0xaa0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031e0:	6b91                	lui	s7,0x4
ffffffffc02031e2:	4c35                	li	s8,13
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc02031e4:	ed7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031e8:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num == 4);
ffffffffc02031ec:	00042903          	lw	s2,0(s0)
ffffffffc02031f0:	2901                	sext.w	s2,s2
ffffffffc02031f2:	26991d63          	bne	s2,s1,ffffffffc020346c <_lru_check_swap+0x2f4>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc02031f6:	00003517          	auipc	a0,0x3
ffffffffc02031fa:	af250513          	addi	a0,a0,-1294 # ffffffffc0205ce8 <default_pmm_manager+0xac8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02031fe:	6c89                	lui	s9,0x2
ffffffffc0203200:	4d2d                	li	s10,11
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203202:	eb9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203206:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num == 4);
ffffffffc020320a:	401c                	lw	a5,0(s0)
ffffffffc020320c:	2781                	sext.w	a5,a5
ffffffffc020320e:	23279f63          	bne	a5,s2,ffffffffc020344c <_lru_check_swap+0x2d4>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0203212:	00003517          	auipc	a0,0x3
ffffffffc0203216:	afe50513          	addi	a0,a0,-1282 # ffffffffc0205d10 <default_pmm_manager+0xaf0>
ffffffffc020321a:	ea1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020321e:	6795                	lui	a5,0x5
ffffffffc0203220:	4739                	li	a4,14
ffffffffc0203222:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 5);
ffffffffc0203226:	4004                	lw	s1,0(s0)
ffffffffc0203228:	4795                	li	a5,5
ffffffffc020322a:	2481                	sext.w	s1,s1
ffffffffc020322c:	20f49063          	bne	s1,a5,ffffffffc020342c <_lru_check_swap+0x2b4>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203230:	00003517          	auipc	a0,0x3
ffffffffc0203234:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205ce8 <default_pmm_manager+0xac8>
ffffffffc0203238:	e83fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020323c:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num == 5);
ffffffffc0203240:	401c                	lw	a5,0(s0)
ffffffffc0203242:	2781                	sext.w	a5,a5
ffffffffc0203244:	1c979463          	bne	a5,s1,ffffffffc020340c <_lru_check_swap+0x294>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203248:	00003517          	auipc	a0,0x3
ffffffffc020324c:	a5050513          	addi	a0,a0,-1456 # ffffffffc0205c98 <default_pmm_manager+0xa78>
ffffffffc0203250:	e6bfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203254:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num == 6);
ffffffffc0203258:	401c                	lw	a5,0(s0)
ffffffffc020325a:	4719                	li	a4,6
ffffffffc020325c:	2781                	sext.w	a5,a5
ffffffffc020325e:	18e79763          	bne	a5,a4,ffffffffc02033ec <_lru_check_swap+0x274>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203262:	00003517          	auipc	a0,0x3
ffffffffc0203266:	a8650513          	addi	a0,a0,-1402 # ffffffffc0205ce8 <default_pmm_manager+0xac8>
ffffffffc020326a:	e51fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020326e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num == 7);
ffffffffc0203272:	401c                	lw	a5,0(s0)
ffffffffc0203274:	471d                	li	a4,7
ffffffffc0203276:	2781                	sext.w	a5,a5
ffffffffc0203278:	14e79a63          	bne	a5,a4,ffffffffc02033cc <_lru_check_swap+0x254>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc020327c:	00003517          	auipc	a0,0x3
ffffffffc0203280:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205c40 <default_pmm_manager+0xa20>
ffffffffc0203284:	e37fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203288:	01498023          	sb	s4,0(s3)
    assert(pgfault_num == 8);
ffffffffc020328c:	401c                	lw	a5,0(s0)
ffffffffc020328e:	4721                	li	a4,8
ffffffffc0203290:	2781                	sext.w	a5,a5
ffffffffc0203292:	10e79d63          	bne	a5,a4,ffffffffc02033ac <_lru_check_swap+0x234>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203296:	00003517          	auipc	a0,0x3
ffffffffc020329a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0205cc0 <default_pmm_manager+0xaa0>
ffffffffc020329e:	e1dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02032a2:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num == 9);
ffffffffc02032a6:	401c                	lw	a5,0(s0)
ffffffffc02032a8:	4725                	li	a4,9
ffffffffc02032aa:	2781                	sext.w	a5,a5
ffffffffc02032ac:	0ee79063          	bne	a5,a4,ffffffffc020338c <_lru_check_swap+0x214>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc02032b0:	00003517          	auipc	a0,0x3
ffffffffc02032b4:	a6050513          	addi	a0,a0,-1440 # ffffffffc0205d10 <default_pmm_manager+0xaf0>
ffffffffc02032b8:	e03fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02032bc:	6795                	lui	a5,0x5
ffffffffc02032be:	4739                	li	a4,14
ffffffffc02032c0:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 10);
ffffffffc02032c4:	4004                	lw	s1,0(s0)
ffffffffc02032c6:	47a9                	li	a5,10
ffffffffc02032c8:	2481                	sext.w	s1,s1
ffffffffc02032ca:	0af49163          	bne	s1,a5,ffffffffc020336c <_lru_check_swap+0x1f4>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc02032ce:	00003517          	auipc	a0,0x3
ffffffffc02032d2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205c98 <default_pmm_manager+0xa78>
ffffffffc02032d6:	de5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032da:	6785                	lui	a5,0x1
ffffffffc02032dc:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02032e0:	06979663          	bne	a5,s1,ffffffffc020334c <_lru_check_swap+0x1d4>
    assert(pgfault_num == 11);
ffffffffc02032e4:	401c                	lw	a5,0(s0)
ffffffffc02032e6:	472d                	li	a4,11
ffffffffc02032e8:	2781                	sext.w	a5,a5
ffffffffc02032ea:	04e79163          	bne	a5,a4,ffffffffc020332c <_lru_check_swap+0x1b4>
}
ffffffffc02032ee:	60e6                	ld	ra,88(sp)
ffffffffc02032f0:	6446                	ld	s0,80(sp)
ffffffffc02032f2:	64a6                	ld	s1,72(sp)
ffffffffc02032f4:	6906                	ld	s2,64(sp)
ffffffffc02032f6:	79e2                	ld	s3,56(sp)
ffffffffc02032f8:	7a42                	ld	s4,48(sp)
ffffffffc02032fa:	7aa2                	ld	s5,40(sp)
ffffffffc02032fc:	7b02                	ld	s6,32(sp)
ffffffffc02032fe:	6be2                	ld	s7,24(sp)
ffffffffc0203300:	6c42                	ld	s8,16(sp)
ffffffffc0203302:	6ca2                	ld	s9,8(sp)
ffffffffc0203304:	6d02                	ld	s10,0(sp)
ffffffffc0203306:	4501                	li	a0,0
ffffffffc0203308:	6125                	addi	sp,sp,96
ffffffffc020330a:	8082                	ret
    assert(pgfault_num == 4);
ffffffffc020330c:	00003697          	auipc	a3,0x3
ffffffffc0203310:	95c68693          	addi	a3,a3,-1700 # ffffffffc0205c68 <default_pmm_manager+0xa48>
ffffffffc0203314:	00002617          	auipc	a2,0x2
ffffffffc0203318:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0204e70 <commands+0x748>
ffffffffc020331c:	04400593          	li	a1,68
ffffffffc0203320:	00003517          	auipc	a0,0x3
ffffffffc0203324:	96050513          	addi	a0,a0,-1696 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203328:	84cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 11);
ffffffffc020332c:	00003697          	auipc	a3,0x3
ffffffffc0203330:	ac468693          	addi	a3,a3,-1340 # ffffffffc0205df0 <default_pmm_manager+0xbd0>
ffffffffc0203334:	00002617          	auipc	a2,0x2
ffffffffc0203338:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0204e70 <commands+0x748>
ffffffffc020333c:	06600593          	li	a1,102
ffffffffc0203340:	00003517          	auipc	a0,0x3
ffffffffc0203344:	94050513          	addi	a0,a0,-1728 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203348:	82cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020334c:	00003697          	auipc	a3,0x3
ffffffffc0203350:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0205dc8 <default_pmm_manager+0xba8>
ffffffffc0203354:	00002617          	auipc	a2,0x2
ffffffffc0203358:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0204e70 <commands+0x748>
ffffffffc020335c:	06400593          	li	a1,100
ffffffffc0203360:	00003517          	auipc	a0,0x3
ffffffffc0203364:	92050513          	addi	a0,a0,-1760 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203368:	80cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 10);
ffffffffc020336c:	00003697          	auipc	a3,0x3
ffffffffc0203370:	a4468693          	addi	a3,a3,-1468 # ffffffffc0205db0 <default_pmm_manager+0xb90>
ffffffffc0203374:	00002617          	auipc	a2,0x2
ffffffffc0203378:	afc60613          	addi	a2,a2,-1284 # ffffffffc0204e70 <commands+0x748>
ffffffffc020337c:	06200593          	li	a1,98
ffffffffc0203380:	00003517          	auipc	a0,0x3
ffffffffc0203384:	90050513          	addi	a0,a0,-1792 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203388:	fedfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 9);
ffffffffc020338c:	00003697          	auipc	a3,0x3
ffffffffc0203390:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0205d98 <default_pmm_manager+0xb78>
ffffffffc0203394:	00002617          	auipc	a2,0x2
ffffffffc0203398:	adc60613          	addi	a2,a2,-1316 # ffffffffc0204e70 <commands+0x748>
ffffffffc020339c:	05f00593          	li	a1,95
ffffffffc02033a0:	00003517          	auipc	a0,0x3
ffffffffc02033a4:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc02033a8:	fcdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 8);
ffffffffc02033ac:	00003697          	auipc	a3,0x3
ffffffffc02033b0:	9d468693          	addi	a3,a3,-1580 # ffffffffc0205d80 <default_pmm_manager+0xb60>
ffffffffc02033b4:	00002617          	auipc	a2,0x2
ffffffffc02033b8:	abc60613          	addi	a2,a2,-1348 # ffffffffc0204e70 <commands+0x748>
ffffffffc02033bc:	05c00593          	li	a1,92
ffffffffc02033c0:	00003517          	auipc	a0,0x3
ffffffffc02033c4:	8c050513          	addi	a0,a0,-1856 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc02033c8:	fadfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 7);
ffffffffc02033cc:	00003697          	auipc	a3,0x3
ffffffffc02033d0:	99c68693          	addi	a3,a3,-1636 # ffffffffc0205d68 <default_pmm_manager+0xb48>
ffffffffc02033d4:	00002617          	auipc	a2,0x2
ffffffffc02033d8:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204e70 <commands+0x748>
ffffffffc02033dc:	05900593          	li	a1,89
ffffffffc02033e0:	00003517          	auipc	a0,0x3
ffffffffc02033e4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc02033e8:	f8dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 6);
ffffffffc02033ec:	00003697          	auipc	a3,0x3
ffffffffc02033f0:	96468693          	addi	a3,a3,-1692 # ffffffffc0205d50 <default_pmm_manager+0xb30>
ffffffffc02033f4:	00002617          	auipc	a2,0x2
ffffffffc02033f8:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0204e70 <commands+0x748>
ffffffffc02033fc:	05600593          	li	a1,86
ffffffffc0203400:	00003517          	auipc	a0,0x3
ffffffffc0203404:	88050513          	addi	a0,a0,-1920 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203408:	f6dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 5);
ffffffffc020340c:	00003697          	auipc	a3,0x3
ffffffffc0203410:	92c68693          	addi	a3,a3,-1748 # ffffffffc0205d38 <default_pmm_manager+0xb18>
ffffffffc0203414:	00002617          	auipc	a2,0x2
ffffffffc0203418:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0204e70 <commands+0x748>
ffffffffc020341c:	05300593          	li	a1,83
ffffffffc0203420:	00003517          	auipc	a0,0x3
ffffffffc0203424:	86050513          	addi	a0,a0,-1952 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203428:	f4dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 5);
ffffffffc020342c:	00003697          	auipc	a3,0x3
ffffffffc0203430:	90c68693          	addi	a3,a3,-1780 # ffffffffc0205d38 <default_pmm_manager+0xb18>
ffffffffc0203434:	00002617          	auipc	a2,0x2
ffffffffc0203438:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0204e70 <commands+0x748>
ffffffffc020343c:	05000593          	li	a1,80
ffffffffc0203440:	00003517          	auipc	a0,0x3
ffffffffc0203444:	84050513          	addi	a0,a0,-1984 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203448:	f2dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020344c:	00003697          	auipc	a3,0x3
ffffffffc0203450:	81c68693          	addi	a3,a3,-2020 # ffffffffc0205c68 <default_pmm_manager+0xa48>
ffffffffc0203454:	00002617          	auipc	a2,0x2
ffffffffc0203458:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0204e70 <commands+0x748>
ffffffffc020345c:	04d00593          	li	a1,77
ffffffffc0203460:	00003517          	auipc	a0,0x3
ffffffffc0203464:	82050513          	addi	a0,a0,-2016 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203468:	f0dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020346c:	00002697          	auipc	a3,0x2
ffffffffc0203470:	7fc68693          	addi	a3,a3,2044 # ffffffffc0205c68 <default_pmm_manager+0xa48>
ffffffffc0203474:	00002617          	auipc	a2,0x2
ffffffffc0203478:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0204e70 <commands+0x748>
ffffffffc020347c:	04a00593          	li	a1,74
ffffffffc0203480:	00003517          	auipc	a0,0x3
ffffffffc0203484:	80050513          	addi	a0,a0,-2048 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc0203488:	eedfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020348c:	00002697          	auipc	a3,0x2
ffffffffc0203490:	7dc68693          	addi	a3,a3,2012 # ffffffffc0205c68 <default_pmm_manager+0xa48>
ffffffffc0203494:	00002617          	auipc	a2,0x2
ffffffffc0203498:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0204e70 <commands+0x748>
ffffffffc020349c:	04700593          	li	a1,71
ffffffffc02034a0:	00002517          	auipc	a0,0x2
ffffffffc02034a4:	7e050513          	addi	a0,a0,2016 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc02034a8:	ecdfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02034ac <_lru_swap_out_victim>:
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
ffffffffc02034ac:	751c                	ld	a5,40(a0)
{
ffffffffc02034ae:	1101                	addi	sp,sp,-32
ffffffffc02034b0:	ec06                	sd	ra,24(sp)
ffffffffc02034b2:	e822                	sd	s0,16(sp)
ffffffffc02034b4:	e426                	sd	s1,8(sp)
    assert(head != NULL);
ffffffffc02034b6:	cfa1                	beqz	a5,ffffffffc020350e <_lru_swap_out_victim+0x62>
    assert(in_tick == 0);
ffffffffc02034b8:	ea1d                	bnez	a2,ffffffffc02034ee <_lru_swap_out_victim+0x42>
    return listelm->prev;
ffffffffc02034ba:	6380                	ld	s0,0(a5)
    if (victim == head) {
ffffffffc02034bc:	02878763          	beq	a5,s0,ffffffffc02034ea <_lru_swap_out_victim+0x3e>
    __list_del(listelm->prev, listelm->next);
ffffffffc02034c0:	6018                	ld	a4,0(s0)
ffffffffc02034c2:	641c                	ld	a5,8(s0)
ffffffffc02034c4:	84ae                	mv	s1,a1
    cprintf("curr_ptr %p\n", victim);
ffffffffc02034c6:	00003517          	auipc	a0,0x3
ffffffffc02034ca:	96250513          	addi	a0,a0,-1694 # ffffffffc0205e28 <default_pmm_manager+0xc08>
    prev->next = next;
ffffffffc02034ce:	e71c                	sd	a5,8(a4)
ffffffffc02034d0:	85a2                	mv	a1,s0
    next->prev = prev;
ffffffffc02034d2:	e398                	sd	a4,0(a5)
ffffffffc02034d4:	be7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *ptr_page = le2page(victim, pra_page_link); // 设置被替换页面的指针
ffffffffc02034d8:	fd040413          	addi	s0,s0,-48
ffffffffc02034dc:	e080                	sd	s0,0(s1)
    return 0;
ffffffffc02034de:	4501                	li	a0,0
}
ffffffffc02034e0:	60e2                	ld	ra,24(sp)
ffffffffc02034e2:	6442                	ld	s0,16(sp)
ffffffffc02034e4:	64a2                	ld	s1,8(sp)
ffffffffc02034e6:	6105                	addi	sp,sp,32
ffffffffc02034e8:	8082                	ret
        return -1; // 链表为空，无法找到被替换的页面
ffffffffc02034ea:	557d                	li	a0,-1
ffffffffc02034ec:	bfd5                	j	ffffffffc02034e0 <_lru_swap_out_victim+0x34>
    assert(in_tick == 0);
ffffffffc02034ee:	00003697          	auipc	a3,0x3
ffffffffc02034f2:	92a68693          	addi	a3,a3,-1750 # ffffffffc0205e18 <default_pmm_manager+0xbf8>
ffffffffc02034f6:	00002617          	auipc	a2,0x2
ffffffffc02034fa:	97a60613          	addi	a2,a2,-1670 # ffffffffc0204e70 <commands+0x748>
ffffffffc02034fe:	03200593          	li	a1,50
ffffffffc0203502:	00002517          	auipc	a0,0x2
ffffffffc0203506:	77e50513          	addi	a0,a0,1918 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc020350a:	e6bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(head != NULL);
ffffffffc020350e:	00003697          	auipc	a3,0x3
ffffffffc0203512:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205e08 <default_pmm_manager+0xbe8>
ffffffffc0203516:	00002617          	auipc	a2,0x2
ffffffffc020351a:	95a60613          	addi	a2,a2,-1702 # ffffffffc0204e70 <commands+0x748>
ffffffffc020351e:	03100593          	li	a1,49
ffffffffc0203522:	00002517          	auipc	a0,0x2
ffffffffc0203526:	75e50513          	addi	a0,a0,1886 # ffffffffc0205c80 <default_pmm_manager+0xa60>
ffffffffc020352a:	e4bfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020352e <_lru_map_swappable>:
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
ffffffffc020352e:	7518                	ld	a4,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203530:	c321                	beqz	a4,ffffffffc0203570 <_lru_map_swappable+0x42>
    return listelm->next;
ffffffffc0203532:	670c                	ld	a1,8(a4)
ffffffffc0203534:	03060693          	addi	a3,a2,48
    while (le != head) {
ffffffffc0203538:	00b70b63          	beq	a4,a1,ffffffffc020354e <_lru_map_swappable+0x20>
        if (le == entry) {
ffffffffc020353c:	00b68f63          	beq	a3,a1,ffffffffc020355a <_lru_map_swappable+0x2c>
ffffffffc0203540:	87ae                	mv	a5,a1
ffffffffc0203542:	a019                	j	ffffffffc0203548 <_lru_map_swappable+0x1a>
ffffffffc0203544:	00f68b63          	beq	a3,a5,ffffffffc020355a <_lru_map_swappable+0x2c>
ffffffffc0203548:	679c                	ld	a5,8(a5)
    while (le != head) {
ffffffffc020354a:	fef71de3          	bne	a4,a5,ffffffffc0203544 <_lru_map_swappable+0x16>
    prev->next = next->prev = elm;
ffffffffc020354e:	e194                	sd	a3,0(a1)
ffffffffc0203550:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0203552:	fe0c                	sd	a1,56(a2)
    elm->prev = prev;
ffffffffc0203554:	fa18                	sd	a4,48(a2)
}
ffffffffc0203556:	4501                	li	a0,0
ffffffffc0203558:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc020355a:	7a08                	ld	a0,48(a2)
ffffffffc020355c:	7e1c                	ld	a5,56(a2)
    prev->next = next;
ffffffffc020355e:	e51c                	sd	a5,8(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203560:	670c                	ld	a1,8(a4)
    next->prev = prev;
ffffffffc0203562:	e388                	sd	a0,0(a5)
ffffffffc0203564:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0203566:	e194                	sd	a3,0(a1)
ffffffffc0203568:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc020356a:	fe0c                	sd	a1,56(a2)
    elm->prev = prev;
ffffffffc020356c:	fa18                	sd	a4,48(a2)
ffffffffc020356e:	8082                	ret
{
ffffffffc0203570:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203572:	00003697          	auipc	a3,0x3
ffffffffc0203576:	8c668693          	addi	a3,a3,-1850 # ffffffffc0205e38 <default_pmm_manager+0xc18>
ffffffffc020357a:	00002617          	auipc	a2,0x2
ffffffffc020357e:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203582:	45e9                	li	a1,26
ffffffffc0203584:	00002517          	auipc	a0,0x2
ffffffffc0203588:	6fc50513          	addi	a0,a0,1788 # ffffffffc0205c80 <default_pmm_manager+0xa60>
{
ffffffffc020358c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020358e:	de7fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203592 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203592:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203594:	00003697          	auipc	a3,0x3
ffffffffc0203598:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0205e70 <default_pmm_manager+0xc50>
ffffffffc020359c:	00002617          	auipc	a2,0x2
ffffffffc02035a0:	8d460613          	addi	a2,a2,-1836 # ffffffffc0204e70 <commands+0x748>
ffffffffc02035a4:	07d00593          	li	a1,125
ffffffffc02035a8:	00003517          	auipc	a0,0x3
ffffffffc02035ac:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205e90 <default_pmm_manager+0xc70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035b0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02035b2:	dc3fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02035b6 <mm_create>:
mm_create(void) {
ffffffffc02035b6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035b8:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02035bc:	e022                	sd	s0,0(sp)
ffffffffc02035be:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035c0:	9e8ff0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc02035c4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02035c6:	c105                	beqz	a0,ffffffffc02035e6 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02035c8:	e408                	sd	a0,8(s0)
ffffffffc02035ca:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02035cc:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02035d0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02035d4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02035d8:	0000e797          	auipc	a5,0xe
ffffffffc02035dc:	f807a783          	lw	a5,-128(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc02035e0:	eb81                	bnez	a5,ffffffffc02035f0 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02035e2:	02053423          	sd	zero,40(a0)
}
ffffffffc02035e6:	60a2                	ld	ra,8(sp)
ffffffffc02035e8:	8522                	mv	a0,s0
ffffffffc02035ea:	6402                	ld	s0,0(sp)
ffffffffc02035ec:	0141                	addi	sp,sp,16
ffffffffc02035ee:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02035f0:	9c5ff0ef          	jal	ra,ffffffffc0202fb4 <swap_init_mm>
}
ffffffffc02035f4:	60a2                	ld	ra,8(sp)
ffffffffc02035f6:	8522                	mv	a0,s0
ffffffffc02035f8:	6402                	ld	s0,0(sp)
ffffffffc02035fa:	0141                	addi	sp,sp,16
ffffffffc02035fc:	8082                	ret

ffffffffc02035fe <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02035fe:	1101                	addi	sp,sp,-32
ffffffffc0203600:	e04a                	sd	s2,0(sp)
ffffffffc0203602:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203604:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203608:	e822                	sd	s0,16(sp)
ffffffffc020360a:	e426                	sd	s1,8(sp)
ffffffffc020360c:	ec06                	sd	ra,24(sp)
ffffffffc020360e:	84ae                	mv	s1,a1
ffffffffc0203610:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203612:	996ff0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
    if (vma != NULL) {
ffffffffc0203616:	c509                	beqz	a0,ffffffffc0203620 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203618:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020361c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020361e:	ed00                	sd	s0,24(a0)
}
ffffffffc0203620:	60e2                	ld	ra,24(sp)
ffffffffc0203622:	6442                	ld	s0,16(sp)
ffffffffc0203624:	64a2                	ld	s1,8(sp)
ffffffffc0203626:	6902                	ld	s2,0(sp)
ffffffffc0203628:	6105                	addi	sp,sp,32
ffffffffc020362a:	8082                	ret

ffffffffc020362c <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc020362c:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc020362e:	c505                	beqz	a0,ffffffffc0203656 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203630:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203632:	c501                	beqz	a0,ffffffffc020363a <find_vma+0xe>
ffffffffc0203634:	651c                	ld	a5,8(a0)
ffffffffc0203636:	02f5f263          	bgeu	a1,a5,ffffffffc020365a <find_vma+0x2e>
    return listelm->next;
ffffffffc020363a:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020363c:	00f68d63          	beq	a3,a5,ffffffffc0203656 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203640:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203644:	00e5e663          	bltu	a1,a4,ffffffffc0203650 <find_vma+0x24>
ffffffffc0203648:	ff07b703          	ld	a4,-16(a5)
ffffffffc020364c:	00e5ec63          	bltu	a1,a4,ffffffffc0203664 <find_vma+0x38>
ffffffffc0203650:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203652:	fef697e3          	bne	a3,a5,ffffffffc0203640 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203656:	4501                	li	a0,0
}
ffffffffc0203658:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020365a:	691c                	ld	a5,16(a0)
ffffffffc020365c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020363a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203660:	ea88                	sd	a0,16(a3)
ffffffffc0203662:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203664:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203668:	ea88                	sd	a0,16(a3)
ffffffffc020366a:	8082                	ret

ffffffffc020366c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020366c:	6590                	ld	a2,8(a1)
ffffffffc020366e:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203672:	1141                	addi	sp,sp,-16
ffffffffc0203674:	e406                	sd	ra,8(sp)
ffffffffc0203676:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203678:	01066763          	bltu	a2,a6,ffffffffc0203686 <insert_vma_struct+0x1a>
ffffffffc020367c:	a085                	j	ffffffffc02036dc <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020367e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203682:	04e66863          	bltu	a2,a4,ffffffffc02036d2 <insert_vma_struct+0x66>
ffffffffc0203686:	86be                	mv	a3,a5
ffffffffc0203688:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020368a:	fef51ae3          	bne	a0,a5,ffffffffc020367e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020368e:	02a68463          	beq	a3,a0,ffffffffc02036b6 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203692:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203696:	fe86b883          	ld	a7,-24(a3)
ffffffffc020369a:	08e8f163          	bgeu	a7,a4,ffffffffc020371c <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020369e:	04e66f63          	bltu	a2,a4,ffffffffc02036fc <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02036a2:	00f50a63          	beq	a0,a5,ffffffffc02036b6 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02036a6:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036aa:	05076963          	bltu	a4,a6,ffffffffc02036fc <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036ae:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036b2:	02c77363          	bgeu	a4,a2,ffffffffc02036d8 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02036b6:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036b8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036ba:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036be:	e390                	sd	a2,0(a5)
ffffffffc02036c0:	e690                	sd	a2,8(a3)
}
ffffffffc02036c2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036c4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02036c6:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02036c8:	0017079b          	addiw	a5,a4,1
ffffffffc02036cc:	d11c                	sw	a5,32(a0)
}
ffffffffc02036ce:	0141                	addi	sp,sp,16
ffffffffc02036d0:	8082                	ret
    if (le_prev != list) {
ffffffffc02036d2:	fca690e3          	bne	a3,a0,ffffffffc0203692 <insert_vma_struct+0x26>
ffffffffc02036d6:	bfd1                	j	ffffffffc02036aa <insert_vma_struct+0x3e>
ffffffffc02036d8:	ebbff0ef          	jal	ra,ffffffffc0203592 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036dc:	00002697          	auipc	a3,0x2
ffffffffc02036e0:	7c468693          	addi	a3,a3,1988 # ffffffffc0205ea0 <default_pmm_manager+0xc80>
ffffffffc02036e4:	00001617          	auipc	a2,0x1
ffffffffc02036e8:	78c60613          	addi	a2,a2,1932 # ffffffffc0204e70 <commands+0x748>
ffffffffc02036ec:	08400593          	li	a1,132
ffffffffc02036f0:	00002517          	auipc	a0,0x2
ffffffffc02036f4:	7a050513          	addi	a0,a0,1952 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc02036f8:	c7dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036fc:	00002697          	auipc	a3,0x2
ffffffffc0203700:	7e468693          	addi	a3,a3,2020 # ffffffffc0205ee0 <default_pmm_manager+0xcc0>
ffffffffc0203704:	00001617          	auipc	a2,0x1
ffffffffc0203708:	76c60613          	addi	a2,a2,1900 # ffffffffc0204e70 <commands+0x748>
ffffffffc020370c:	07c00593          	li	a1,124
ffffffffc0203710:	00002517          	auipc	a0,0x2
ffffffffc0203714:	78050513          	addi	a0,a0,1920 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203718:	c5dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020371c:	00002697          	auipc	a3,0x2
ffffffffc0203720:	7a468693          	addi	a3,a3,1956 # ffffffffc0205ec0 <default_pmm_manager+0xca0>
ffffffffc0203724:	00001617          	auipc	a2,0x1
ffffffffc0203728:	74c60613          	addi	a2,a2,1868 # ffffffffc0204e70 <commands+0x748>
ffffffffc020372c:	07b00593          	li	a1,123
ffffffffc0203730:	00002517          	auipc	a0,0x2
ffffffffc0203734:	76050513          	addi	a0,a0,1888 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203738:	c3dfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020373c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc020373c:	1141                	addi	sp,sp,-16
ffffffffc020373e:	e022                	sd	s0,0(sp)
ffffffffc0203740:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203742:	6508                	ld	a0,8(a0)
ffffffffc0203744:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203746:	00a40e63          	beq	s0,a0,ffffffffc0203762 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020374a:	6118                	ld	a4,0(a0)
ffffffffc020374c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020374e:	03000593          	li	a1,48
ffffffffc0203752:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203754:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203756:	e398                	sd	a4,0(a5)
ffffffffc0203758:	90aff0ef          	jal	ra,ffffffffc0202862 <kfree>
    return listelm->next;
ffffffffc020375c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020375e:	fea416e3          	bne	s0,a0,ffffffffc020374a <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203762:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203764:	6402                	ld	s0,0(sp)
ffffffffc0203766:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203768:	03000593          	li	a1,48
}
ffffffffc020376c:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020376e:	8f4ff06f          	j	ffffffffc0202862 <kfree>

ffffffffc0203772 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203772:	715d                	addi	sp,sp,-80
ffffffffc0203774:	e486                	sd	ra,72(sp)
ffffffffc0203776:	f44e                	sd	s3,40(sp)
ffffffffc0203778:	f052                	sd	s4,32(sp)
ffffffffc020377a:	e0a2                	sd	s0,64(sp)
ffffffffc020377c:	fc26                	sd	s1,56(sp)
ffffffffc020377e:	f84a                	sd	s2,48(sp)
ffffffffc0203780:	ec56                	sd	s5,24(sp)
ffffffffc0203782:	e85a                	sd	s6,16(sp)
ffffffffc0203784:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203786:	f3dfd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc020378a:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020378c:	f37fd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0203790:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203792:	03000513          	li	a0,48
ffffffffc0203796:	812ff0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
    if (mm != NULL) {
ffffffffc020379a:	56050863          	beqz	a0,ffffffffc0203d0a <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc020379e:	e508                	sd	a0,8(a0)
ffffffffc02037a0:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02037a2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037a6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037aa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037ae:	0000e797          	auipc	a5,0xe
ffffffffc02037b2:	daa7a783          	lw	a5,-598(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc02037b6:	84aa                	mv	s1,a0
ffffffffc02037b8:	e7b9                	bnez	a5,ffffffffc0203806 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc02037ba:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02037be:	03200413          	li	s0,50
ffffffffc02037c2:	a811                	j	ffffffffc02037d6 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02037c4:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02037c6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02037c8:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02037cc:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02037ce:	8526                	mv	a0,s1
ffffffffc02037d0:	e9dff0ef          	jal	ra,ffffffffc020366c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02037d4:	cc05                	beqz	s0,ffffffffc020380c <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037d6:	03000513          	li	a0,48
ffffffffc02037da:	fcffe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc02037de:	85aa                	mv	a1,a0
ffffffffc02037e0:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02037e4:	f165                	bnez	a0,ffffffffc02037c4 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc02037e6:	00002697          	auipc	a3,0x2
ffffffffc02037ea:	16a68693          	addi	a3,a3,362 # ffffffffc0205950 <default_pmm_manager+0x730>
ffffffffc02037ee:	00001617          	auipc	a2,0x1
ffffffffc02037f2:	68260613          	addi	a2,a2,1666 # ffffffffc0204e70 <commands+0x748>
ffffffffc02037f6:	0ce00593          	li	a1,206
ffffffffc02037fa:	00002517          	auipc	a0,0x2
ffffffffc02037fe:	69650513          	addi	a0,a0,1686 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203802:	b73fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203806:	faeff0ef          	jal	ra,ffffffffc0202fb4 <swap_init_mm>
ffffffffc020380a:	bf55                	j	ffffffffc02037be <vmm_init+0x4c>
ffffffffc020380c:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203810:	1f900913          	li	s2,505
ffffffffc0203814:	a819                	j	ffffffffc020382a <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0203816:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203818:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020381a:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020381e:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203820:	8526                	mv	a0,s1
ffffffffc0203822:	e4bff0ef          	jal	ra,ffffffffc020366c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203826:	03240a63          	beq	s0,s2,ffffffffc020385a <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020382a:	03000513          	li	a0,48
ffffffffc020382e:	f7bfe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc0203832:	85aa                	mv	a1,a0
ffffffffc0203834:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203838:	fd79                	bnez	a0,ffffffffc0203816 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc020383a:	00002697          	auipc	a3,0x2
ffffffffc020383e:	11668693          	addi	a3,a3,278 # ffffffffc0205950 <default_pmm_manager+0x730>
ffffffffc0203842:	00001617          	auipc	a2,0x1
ffffffffc0203846:	62e60613          	addi	a2,a2,1582 # ffffffffc0204e70 <commands+0x748>
ffffffffc020384a:	0d400593          	li	a1,212
ffffffffc020384e:	00002517          	auipc	a0,0x2
ffffffffc0203852:	64250513          	addi	a0,a0,1602 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203856:	b1ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc020385a:	649c                	ld	a5,8(s1)
ffffffffc020385c:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020385e:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203862:	2ef48463          	beq	s1,a5,ffffffffc0203b4a <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203866:	fe87b603          	ld	a2,-24(a5)
ffffffffc020386a:	ffe70693          	addi	a3,a4,-2
ffffffffc020386e:	26d61e63          	bne	a2,a3,ffffffffc0203aea <vmm_init+0x378>
ffffffffc0203872:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203876:	26e69a63          	bne	a3,a4,ffffffffc0203aea <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc020387a:	0715                	addi	a4,a4,5
ffffffffc020387c:	679c                	ld	a5,8(a5)
ffffffffc020387e:	feb712e3          	bne	a4,a1,ffffffffc0203862 <vmm_init+0xf0>
ffffffffc0203882:	4b1d                	li	s6,7
ffffffffc0203884:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203886:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020388a:	85a2                	mv	a1,s0
ffffffffc020388c:	8526                	mv	a0,s1
ffffffffc020388e:	d9fff0ef          	jal	ra,ffffffffc020362c <find_vma>
ffffffffc0203892:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203894:	2c050b63          	beqz	a0,ffffffffc0203b6a <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203898:	00140593          	addi	a1,s0,1
ffffffffc020389c:	8526                	mv	a0,s1
ffffffffc020389e:	d8fff0ef          	jal	ra,ffffffffc020362c <find_vma>
ffffffffc02038a2:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02038a4:	2e050363          	beqz	a0,ffffffffc0203b8a <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02038a8:	85da                	mv	a1,s6
ffffffffc02038aa:	8526                	mv	a0,s1
ffffffffc02038ac:	d81ff0ef          	jal	ra,ffffffffc020362c <find_vma>
        assert(vma3 == NULL);
ffffffffc02038b0:	2e051d63          	bnez	a0,ffffffffc0203baa <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02038b4:	00340593          	addi	a1,s0,3
ffffffffc02038b8:	8526                	mv	a0,s1
ffffffffc02038ba:	d73ff0ef          	jal	ra,ffffffffc020362c <find_vma>
        assert(vma4 == NULL);
ffffffffc02038be:	30051663          	bnez	a0,ffffffffc0203bca <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02038c2:	00440593          	addi	a1,s0,4
ffffffffc02038c6:	8526                	mv	a0,s1
ffffffffc02038c8:	d65ff0ef          	jal	ra,ffffffffc020362c <find_vma>
        assert(vma5 == NULL);
ffffffffc02038cc:	30051f63          	bnez	a0,ffffffffc0203bea <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02038d0:	00893783          	ld	a5,8(s2)
ffffffffc02038d4:	24879b63          	bne	a5,s0,ffffffffc0203b2a <vmm_init+0x3b8>
ffffffffc02038d8:	01093783          	ld	a5,16(s2)
ffffffffc02038dc:	25679763          	bne	a5,s6,ffffffffc0203b2a <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02038e0:	008ab783          	ld	a5,8(s5)
ffffffffc02038e4:	22879363          	bne	a5,s0,ffffffffc0203b0a <vmm_init+0x398>
ffffffffc02038e8:	010ab783          	ld	a5,16(s5)
ffffffffc02038ec:	21679f63          	bne	a5,s6,ffffffffc0203b0a <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02038f0:	0415                	addi	s0,s0,5
ffffffffc02038f2:	0b15                	addi	s6,s6,5
ffffffffc02038f4:	f9741be3          	bne	s0,s7,ffffffffc020388a <vmm_init+0x118>
ffffffffc02038f8:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02038fa:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02038fc:	85a2                	mv	a1,s0
ffffffffc02038fe:	8526                	mv	a0,s1
ffffffffc0203900:	d2dff0ef          	jal	ra,ffffffffc020362c <find_vma>
ffffffffc0203904:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203908:	c90d                	beqz	a0,ffffffffc020393a <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020390a:	6914                	ld	a3,16(a0)
ffffffffc020390c:	6510                	ld	a2,8(a0)
ffffffffc020390e:	00002517          	auipc	a0,0x2
ffffffffc0203912:	6f250513          	addi	a0,a0,1778 # ffffffffc0206000 <default_pmm_manager+0xde0>
ffffffffc0203916:	fa4fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020391a:	00002697          	auipc	a3,0x2
ffffffffc020391e:	70e68693          	addi	a3,a3,1806 # ffffffffc0206028 <default_pmm_manager+0xe08>
ffffffffc0203922:	00001617          	auipc	a2,0x1
ffffffffc0203926:	54e60613          	addi	a2,a2,1358 # ffffffffc0204e70 <commands+0x748>
ffffffffc020392a:	0f600593          	li	a1,246
ffffffffc020392e:	00002517          	auipc	a0,0x2
ffffffffc0203932:	56250513          	addi	a0,a0,1378 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203936:	a3ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc020393a:	147d                	addi	s0,s0,-1
ffffffffc020393c:	fd2410e3          	bne	s0,s2,ffffffffc02038fc <vmm_init+0x18a>
ffffffffc0203940:	a811                	j	ffffffffc0203954 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203942:	6118                	ld	a4,0(a0)
ffffffffc0203944:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203946:	03000593          	li	a1,48
ffffffffc020394a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020394c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020394e:	e398                	sd	a4,0(a5)
ffffffffc0203950:	f13fe0ef          	jal	ra,ffffffffc0202862 <kfree>
    return listelm->next;
ffffffffc0203954:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203956:	fea496e3          	bne	s1,a0,ffffffffc0203942 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020395a:	03000593          	li	a1,48
ffffffffc020395e:	8526                	mv	a0,s1
ffffffffc0203960:	f03fe0ef          	jal	ra,ffffffffc0202862 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203964:	d5ffd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0203968:	3caa1163          	bne	s4,a0,ffffffffc0203d2a <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020396c:	00002517          	auipc	a0,0x2
ffffffffc0203970:	6fc50513          	addi	a0,a0,1788 # ffffffffc0206068 <default_pmm_manager+0xe48>
ffffffffc0203974:	f46fc0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203978:	d4bfd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc020397c:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020397e:	03000513          	li	a0,48
ffffffffc0203982:	e27fe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc0203986:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203988:	2a050163          	beqz	a0,ffffffffc0203c2a <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020398c:	0000e797          	auipc	a5,0xe
ffffffffc0203990:	bcc7a783          	lw	a5,-1076(a5) # ffffffffc0211558 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203994:	e508                	sd	a0,8(a0)
ffffffffc0203996:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203998:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020399c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02039a0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039a4:	14079063          	bnez	a5,ffffffffc0203ae4 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc02039a8:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02039ac:	0000e917          	auipc	s2,0xe
ffffffffc02039b0:	b7493903          	ld	s2,-1164(s2) # ffffffffc0211520 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02039b4:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02039b8:	0000e717          	auipc	a4,0xe
ffffffffc02039bc:	ba873423          	sd	s0,-1112(a4) # ffffffffc0211560 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02039c0:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02039c4:	24079363          	bnez	a5,ffffffffc0203c0a <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039c8:	03000513          	li	a0,48
ffffffffc02039cc:	dddfe0ef          	jal	ra,ffffffffc02027a8 <kmalloc>
ffffffffc02039d0:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02039d2:	28050063          	beqz	a0,ffffffffc0203c52 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02039d6:	002007b7          	lui	a5,0x200
ffffffffc02039da:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02039de:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02039e0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02039e2:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02039e6:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02039e8:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02039ec:	c81ff0ef          	jal	ra,ffffffffc020366c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02039f0:	10000593          	li	a1,256
ffffffffc02039f4:	8522                	mv	a0,s0
ffffffffc02039f6:	c37ff0ef          	jal	ra,ffffffffc020362c <find_vma>
ffffffffc02039fa:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02039fe:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a02:	26aa1863          	bne	s4,a0,ffffffffc0203c72 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0203a06:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203a0a:	0785                	addi	a5,a5,1
ffffffffc0203a0c:	fee79de3          	bne	a5,a4,ffffffffc0203a06 <vmm_init+0x294>
        sum += i;
ffffffffc0203a10:	6705                	lui	a4,0x1
ffffffffc0203a12:	10000793          	li	a5,256
ffffffffc0203a16:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203a1a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203a1e:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203a22:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203a24:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203a26:	fec79ce3          	bne	a5,a2,ffffffffc0203a1e <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0203a2a:	26071463          	bnez	a4,ffffffffc0203c92 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203a2e:	4581                	li	a1,0
ffffffffc0203a30:	854a                	mv	a0,s2
ffffffffc0203a32:	f1bfd0ef          	jal	ra,ffffffffc020194c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a36:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203a3a:	0000e717          	auipc	a4,0xe
ffffffffc0203a3e:	aee73703          	ld	a4,-1298(a4) # ffffffffc0211528 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a42:	078a                	slli	a5,a5,0x2
ffffffffc0203a44:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a46:	26e7f663          	bgeu	a5,a4,ffffffffc0203cb2 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a4a:	00003717          	auipc	a4,0x3
ffffffffc0203a4e:	9e673703          	ld	a4,-1562(a4) # ffffffffc0206430 <nbase>
ffffffffc0203a52:	8f99                	sub	a5,a5,a4
ffffffffc0203a54:	00379713          	slli	a4,a5,0x3
ffffffffc0203a58:	97ba                	add	a5,a5,a4
ffffffffc0203a5a:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203a5c:	0000e517          	auipc	a0,0xe
ffffffffc0203a60:	ad453503          	ld	a0,-1324(a0) # ffffffffc0211530 <pages>
ffffffffc0203a64:	953e                	add	a0,a0,a5
ffffffffc0203a66:	4585                	li	a1,1
ffffffffc0203a68:	c1bfd0ef          	jal	ra,ffffffffc0201682 <free_pages>
    return listelm->next;
ffffffffc0203a6c:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203a6e:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203a72:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a76:	00a40e63          	beq	s0,a0,ffffffffc0203a92 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a7a:	6118                	ld	a4,0(a0)
ffffffffc0203a7c:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203a7e:	03000593          	li	a1,48
ffffffffc0203a82:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a84:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a86:	e398                	sd	a4,0(a5)
ffffffffc0203a88:	ddbfe0ef          	jal	ra,ffffffffc0202862 <kfree>
    return listelm->next;
ffffffffc0203a8c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a8e:	fea416e3          	bne	s0,a0,ffffffffc0203a7a <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203a92:	03000593          	li	a1,48
ffffffffc0203a96:	8522                	mv	a0,s0
ffffffffc0203a98:	dcbfe0ef          	jal	ra,ffffffffc0202862 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203a9c:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203a9e:	0000e797          	auipc	a5,0xe
ffffffffc0203aa2:	ac07b123          	sd	zero,-1342(a5) # ffffffffc0211560 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203aa6:	c1dfd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
ffffffffc0203aaa:	22a49063          	bne	s1,a0,ffffffffc0203cca <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203aae:	00002517          	auipc	a0,0x2
ffffffffc0203ab2:	60a50513          	addi	a0,a0,1546 # ffffffffc02060b8 <default_pmm_manager+0xe98>
ffffffffc0203ab6:	e04fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203aba:	c09fd0ef          	jal	ra,ffffffffc02016c2 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203abe:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ac0:	22a99563          	bne	s3,a0,ffffffffc0203cea <vmm_init+0x578>
}
ffffffffc0203ac4:	6406                	ld	s0,64(sp)
ffffffffc0203ac6:	60a6                	ld	ra,72(sp)
ffffffffc0203ac8:	74e2                	ld	s1,56(sp)
ffffffffc0203aca:	7942                	ld	s2,48(sp)
ffffffffc0203acc:	79a2                	ld	s3,40(sp)
ffffffffc0203ace:	7a02                	ld	s4,32(sp)
ffffffffc0203ad0:	6ae2                	ld	s5,24(sp)
ffffffffc0203ad2:	6b42                	ld	s6,16(sp)
ffffffffc0203ad4:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203ad6:	00002517          	auipc	a0,0x2
ffffffffc0203ada:	60250513          	addi	a0,a0,1538 # ffffffffc02060d8 <default_pmm_manager+0xeb8>
}
ffffffffc0203ade:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203ae0:	ddafc06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203ae4:	cd0ff0ef          	jal	ra,ffffffffc0202fb4 <swap_init_mm>
ffffffffc0203ae8:	b5d1                	j	ffffffffc02039ac <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203aea:	00002697          	auipc	a3,0x2
ffffffffc0203aee:	42e68693          	addi	a3,a3,1070 # ffffffffc0205f18 <default_pmm_manager+0xcf8>
ffffffffc0203af2:	00001617          	auipc	a2,0x1
ffffffffc0203af6:	37e60613          	addi	a2,a2,894 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203afa:	0dd00593          	li	a1,221
ffffffffc0203afe:	00002517          	auipc	a0,0x2
ffffffffc0203b02:	39250513          	addi	a0,a0,914 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203b06:	86ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b0a:	00002697          	auipc	a3,0x2
ffffffffc0203b0e:	4c668693          	addi	a3,a3,1222 # ffffffffc0205fd0 <default_pmm_manager+0xdb0>
ffffffffc0203b12:	00001617          	auipc	a2,0x1
ffffffffc0203b16:	35e60613          	addi	a2,a2,862 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203b1a:	0ee00593          	li	a1,238
ffffffffc0203b1e:	00002517          	auipc	a0,0x2
ffffffffc0203b22:	37250513          	addi	a0,a0,882 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203b26:	84ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b2a:	00002697          	auipc	a3,0x2
ffffffffc0203b2e:	47668693          	addi	a3,a3,1142 # ffffffffc0205fa0 <default_pmm_manager+0xd80>
ffffffffc0203b32:	00001617          	auipc	a2,0x1
ffffffffc0203b36:	33e60613          	addi	a2,a2,830 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203b3a:	0ed00593          	li	a1,237
ffffffffc0203b3e:	00002517          	auipc	a0,0x2
ffffffffc0203b42:	35250513          	addi	a0,a0,850 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203b46:	82ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203b4a:	00002697          	auipc	a3,0x2
ffffffffc0203b4e:	3b668693          	addi	a3,a3,950 # ffffffffc0205f00 <default_pmm_manager+0xce0>
ffffffffc0203b52:	00001617          	auipc	a2,0x1
ffffffffc0203b56:	31e60613          	addi	a2,a2,798 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203b5a:	0db00593          	li	a1,219
ffffffffc0203b5e:	00002517          	auipc	a0,0x2
ffffffffc0203b62:	33250513          	addi	a0,a0,818 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203b66:	80ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203b6a:	00002697          	auipc	a3,0x2
ffffffffc0203b6e:	3e668693          	addi	a3,a3,998 # ffffffffc0205f50 <default_pmm_manager+0xd30>
ffffffffc0203b72:	00001617          	auipc	a2,0x1
ffffffffc0203b76:	2fe60613          	addi	a2,a2,766 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203b7a:	0e300593          	li	a1,227
ffffffffc0203b7e:	00002517          	auipc	a0,0x2
ffffffffc0203b82:	31250513          	addi	a0,a0,786 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203b86:	feefc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203b8a:	00002697          	auipc	a3,0x2
ffffffffc0203b8e:	3d668693          	addi	a3,a3,982 # ffffffffc0205f60 <default_pmm_manager+0xd40>
ffffffffc0203b92:	00001617          	auipc	a2,0x1
ffffffffc0203b96:	2de60613          	addi	a2,a2,734 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203b9a:	0e500593          	li	a1,229
ffffffffc0203b9e:	00002517          	auipc	a0,0x2
ffffffffc0203ba2:	2f250513          	addi	a0,a0,754 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203ba6:	fcefc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203baa:	00002697          	auipc	a3,0x2
ffffffffc0203bae:	3c668693          	addi	a3,a3,966 # ffffffffc0205f70 <default_pmm_manager+0xd50>
ffffffffc0203bb2:	00001617          	auipc	a2,0x1
ffffffffc0203bb6:	2be60613          	addi	a2,a2,702 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203bba:	0e700593          	li	a1,231
ffffffffc0203bbe:	00002517          	auipc	a0,0x2
ffffffffc0203bc2:	2d250513          	addi	a0,a0,722 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203bc6:	faefc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203bca:	00002697          	auipc	a3,0x2
ffffffffc0203bce:	3b668693          	addi	a3,a3,950 # ffffffffc0205f80 <default_pmm_manager+0xd60>
ffffffffc0203bd2:	00001617          	auipc	a2,0x1
ffffffffc0203bd6:	29e60613          	addi	a2,a2,670 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203bda:	0e900593          	li	a1,233
ffffffffc0203bde:	00002517          	auipc	a0,0x2
ffffffffc0203be2:	2b250513          	addi	a0,a0,690 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203be6:	f8efc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203bea:	00002697          	auipc	a3,0x2
ffffffffc0203bee:	3a668693          	addi	a3,a3,934 # ffffffffc0205f90 <default_pmm_manager+0xd70>
ffffffffc0203bf2:	00001617          	auipc	a2,0x1
ffffffffc0203bf6:	27e60613          	addi	a2,a2,638 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203bfa:	0eb00593          	li	a1,235
ffffffffc0203bfe:	00002517          	auipc	a0,0x2
ffffffffc0203c02:	29250513          	addi	a0,a0,658 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203c06:	f6efc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203c0a:	00002697          	auipc	a3,0x2
ffffffffc0203c0e:	d3668693          	addi	a3,a3,-714 # ffffffffc0205940 <default_pmm_manager+0x720>
ffffffffc0203c12:	00001617          	auipc	a2,0x1
ffffffffc0203c16:	25e60613          	addi	a2,a2,606 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203c1a:	10d00593          	li	a1,269
ffffffffc0203c1e:	00002517          	auipc	a0,0x2
ffffffffc0203c22:	27250513          	addi	a0,a0,626 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203c26:	f4efc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203c2a:	00002697          	auipc	a3,0x2
ffffffffc0203c2e:	4c668693          	addi	a3,a3,1222 # ffffffffc02060f0 <default_pmm_manager+0xed0>
ffffffffc0203c32:	00001617          	auipc	a2,0x1
ffffffffc0203c36:	23e60613          	addi	a2,a2,574 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203c3a:	10a00593          	li	a1,266
ffffffffc0203c3e:	00002517          	auipc	a0,0x2
ffffffffc0203c42:	25250513          	addi	a0,a0,594 # ffffffffc0205e90 <default_pmm_manager+0xc70>
    check_mm_struct = mm_create();
ffffffffc0203c46:	0000e797          	auipc	a5,0xe
ffffffffc0203c4a:	9007bd23          	sd	zero,-1766(a5) # ffffffffc0211560 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203c4e:	f26fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203c52:	00002697          	auipc	a3,0x2
ffffffffc0203c56:	cfe68693          	addi	a3,a3,-770 # ffffffffc0205950 <default_pmm_manager+0x730>
ffffffffc0203c5a:	00001617          	auipc	a2,0x1
ffffffffc0203c5e:	21660613          	addi	a2,a2,534 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203c62:	11100593          	li	a1,273
ffffffffc0203c66:	00002517          	auipc	a0,0x2
ffffffffc0203c6a:	22a50513          	addi	a0,a0,554 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203c6e:	f06fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c72:	00002697          	auipc	a3,0x2
ffffffffc0203c76:	41668693          	addi	a3,a3,1046 # ffffffffc0206088 <default_pmm_manager+0xe68>
ffffffffc0203c7a:	00001617          	auipc	a2,0x1
ffffffffc0203c7e:	1f660613          	addi	a2,a2,502 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203c82:	11600593          	li	a1,278
ffffffffc0203c86:	00002517          	auipc	a0,0x2
ffffffffc0203c8a:	20a50513          	addi	a0,a0,522 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203c8e:	ee6fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203c92:	00002697          	auipc	a3,0x2
ffffffffc0203c96:	41668693          	addi	a3,a3,1046 # ffffffffc02060a8 <default_pmm_manager+0xe88>
ffffffffc0203c9a:	00001617          	auipc	a2,0x1
ffffffffc0203c9e:	1d660613          	addi	a2,a2,470 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203ca2:	12000593          	li	a1,288
ffffffffc0203ca6:	00002517          	auipc	a0,0x2
ffffffffc0203caa:	1ea50513          	addi	a0,a0,490 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203cae:	ec6fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203cb2:	00001617          	auipc	a2,0x1
ffffffffc0203cb6:	5a660613          	addi	a2,a2,1446 # ffffffffc0205258 <default_pmm_manager+0x38>
ffffffffc0203cba:	06500593          	li	a1,101
ffffffffc0203cbe:	00001517          	auipc	a0,0x1
ffffffffc0203cc2:	5ba50513          	addi	a0,a0,1466 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc0203cc6:	eaefc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cca:	00002697          	auipc	a3,0x2
ffffffffc0203cce:	37668693          	addi	a3,a3,886 # ffffffffc0206040 <default_pmm_manager+0xe20>
ffffffffc0203cd2:	00001617          	auipc	a2,0x1
ffffffffc0203cd6:	19e60613          	addi	a2,a2,414 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203cda:	12e00593          	li	a1,302
ffffffffc0203cde:	00002517          	auipc	a0,0x2
ffffffffc0203ce2:	1b250513          	addi	a0,a0,434 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203ce6:	e8efc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cea:	00002697          	auipc	a3,0x2
ffffffffc0203cee:	35668693          	addi	a3,a3,854 # ffffffffc0206040 <default_pmm_manager+0xe20>
ffffffffc0203cf2:	00001617          	auipc	a2,0x1
ffffffffc0203cf6:	17e60613          	addi	a2,a2,382 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203cfa:	0bd00593          	li	a1,189
ffffffffc0203cfe:	00002517          	auipc	a0,0x2
ffffffffc0203d02:	19250513          	addi	a0,a0,402 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203d06:	e6efc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203d0a:	00002697          	auipc	a3,0x2
ffffffffc0203d0e:	c0e68693          	addi	a3,a3,-1010 # ffffffffc0205918 <default_pmm_manager+0x6f8>
ffffffffc0203d12:	00001617          	auipc	a2,0x1
ffffffffc0203d16:	15e60613          	addi	a2,a2,350 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203d1a:	0c700593          	li	a1,199
ffffffffc0203d1e:	00002517          	auipc	a0,0x2
ffffffffc0203d22:	17250513          	addi	a0,a0,370 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203d26:	e4efc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d2a:	00002697          	auipc	a3,0x2
ffffffffc0203d2e:	31668693          	addi	a3,a3,790 # ffffffffc0206040 <default_pmm_manager+0xe20>
ffffffffc0203d32:	00001617          	auipc	a2,0x1
ffffffffc0203d36:	13e60613          	addi	a2,a2,318 # ffffffffc0204e70 <commands+0x748>
ffffffffc0203d3a:	0fb00593          	li	a1,251
ffffffffc0203d3e:	00002517          	auipc	a0,0x2
ffffffffc0203d42:	15250513          	addi	a0,a0,338 # ffffffffc0205e90 <default_pmm_manager+0xc70>
ffffffffc0203d46:	e2efc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d4a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d4a:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d4c:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d4e:	f022                	sd	s0,32(sp)
ffffffffc0203d50:	ec26                	sd	s1,24(sp)
ffffffffc0203d52:	f406                	sd	ra,40(sp)
ffffffffc0203d54:	e84a                	sd	s2,16(sp)
ffffffffc0203d56:	8432                	mv	s0,a2
ffffffffc0203d58:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d5a:	8d3ff0ef          	jal	ra,ffffffffc020362c <find_vma>

    pgfault_num++;
ffffffffc0203d5e:	0000e797          	auipc	a5,0xe
ffffffffc0203d62:	80a7a783          	lw	a5,-2038(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0203d66:	2785                	addiw	a5,a5,1
ffffffffc0203d68:	0000e717          	auipc	a4,0xe
ffffffffc0203d6c:	80f72023          	sw	a5,-2048(a4) # ffffffffc0211568 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203d70:	c159                	beqz	a0,ffffffffc0203df6 <do_pgfault+0xac>
ffffffffc0203d72:	651c                	ld	a5,8(a0)
ffffffffc0203d74:	08f46163          	bltu	s0,a5,ffffffffc0203df6 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203d78:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203d7a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203d7c:	8b89                	andi	a5,a5,2
ffffffffc0203d7e:	ebb1                	bnez	a5,ffffffffc0203dd2 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d80:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203d82:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d84:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203d86:	85a2                	mv	a1,s0
ffffffffc0203d88:	4605                	li	a2,1
ffffffffc0203d8a:	973fd0ef          	jal	ra,ffffffffc02016fc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203d8e:	610c                	ld	a1,0(a0)
ffffffffc0203d90:	c1b9                	beqz	a1,ffffffffc0203dd6 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203d92:	0000d797          	auipc	a5,0xd
ffffffffc0203d96:	7c67a783          	lw	a5,1990(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203d9a:	c7bd                	beqz	a5,ffffffffc0203e08 <do_pgfault+0xbe>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc0203d9c:	85a2                	mv	a1,s0
ffffffffc0203d9e:	0030                	addi	a2,sp,8
ffffffffc0203da0:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203da2:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203da4:	b3cff0ef          	jal	ra,ffffffffc02030e0 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203da8:	65a2                	ld	a1,8(sp)
ffffffffc0203daa:	6c88                	ld	a0,24(s1)
ffffffffc0203dac:	86ca                	mv	a3,s2
ffffffffc0203dae:	8622                	mv	a2,s0
ffffffffc0203db0:	c37fd0ef          	jal	ra,ffffffffc02019e6 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203db4:	6622                	ld	a2,8(sp)
ffffffffc0203db6:	4685                	li	a3,1
ffffffffc0203db8:	85a2                	mv	a1,s0
ffffffffc0203dba:	8526                	mv	a0,s1
ffffffffc0203dbc:	a04ff0ef          	jal	ra,ffffffffc0202fc0 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203dc0:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203dc2:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0203dc4:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0203dc6:	70a2                	ld	ra,40(sp)
ffffffffc0203dc8:	7402                	ld	s0,32(sp)
ffffffffc0203dca:	64e2                	ld	s1,24(sp)
ffffffffc0203dcc:	6942                	ld	s2,16(sp)
ffffffffc0203dce:	6145                	addi	sp,sp,48
ffffffffc0203dd0:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203dd2:	4959                	li	s2,22
ffffffffc0203dd4:	b775                	j	ffffffffc0203d80 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203dd6:	6c88                	ld	a0,24(s1)
ffffffffc0203dd8:	864a                	mv	a2,s2
ffffffffc0203dda:	85a2                	mv	a1,s0
ffffffffc0203ddc:	915fe0ef          	jal	ra,ffffffffc02026f0 <pgdir_alloc_page>
ffffffffc0203de0:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0203de2:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203de4:	f3ed                	bnez	a5,ffffffffc0203dc6 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203de6:	00002517          	auipc	a0,0x2
ffffffffc0203dea:	35250513          	addi	a0,a0,850 # ffffffffc0206138 <default_pmm_manager+0xf18>
ffffffffc0203dee:	accfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203df2:	5571                	li	a0,-4
            goto failed;
ffffffffc0203df4:	bfc9                	j	ffffffffc0203dc6 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203df6:	85a2                	mv	a1,s0
ffffffffc0203df8:	00002517          	auipc	a0,0x2
ffffffffc0203dfc:	31050513          	addi	a0,a0,784 # ffffffffc0206108 <default_pmm_manager+0xee8>
ffffffffc0203e00:	abafc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203e04:	5575                	li	a0,-3
        goto failed;
ffffffffc0203e06:	b7c1                	j	ffffffffc0203dc6 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203e08:	00002517          	auipc	a0,0x2
ffffffffc0203e0c:	35850513          	addi	a0,a0,856 # ffffffffc0206160 <default_pmm_manager+0xf40>
ffffffffc0203e10:	aaafc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e14:	5571                	li	a0,-4
            goto failed;
ffffffffc0203e16:	bf45                	j	ffffffffc0203dc6 <do_pgfault+0x7c>

ffffffffc0203e18 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203e18:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e1a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203e1c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e1e:	e76fc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203e22:	cd01                	beqz	a0,ffffffffc0203e3a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e24:	4505                	li	a0,1
ffffffffc0203e26:	e74fc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203e2a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e2c:	810d                	srli	a0,a0,0x3
ffffffffc0203e2e:	0000d797          	auipc	a5,0xd
ffffffffc0203e32:	70a7bd23          	sd	a0,1818(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203e36:	0141                	addi	sp,sp,16
ffffffffc0203e38:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e3a:	00002617          	auipc	a2,0x2
ffffffffc0203e3e:	34e60613          	addi	a2,a2,846 # ffffffffc0206188 <default_pmm_manager+0xf68>
ffffffffc0203e42:	45b5                	li	a1,13
ffffffffc0203e44:	00002517          	auipc	a0,0x2
ffffffffc0203e48:	36450513          	addi	a0,a0,868 # ffffffffc02061a8 <default_pmm_manager+0xf88>
ffffffffc0203e4c:	d28fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e50 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e50:	1141                	addi	sp,sp,-16
ffffffffc0203e52:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e54:	00855793          	srli	a5,a0,0x8
ffffffffc0203e58:	c3a5                	beqz	a5,ffffffffc0203eb8 <swapfs_read+0x68>
ffffffffc0203e5a:	0000d717          	auipc	a4,0xd
ffffffffc0203e5e:	6ee73703          	ld	a4,1774(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203e62:	04e7fb63          	bgeu	a5,a4,ffffffffc0203eb8 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e66:	0000d617          	auipc	a2,0xd
ffffffffc0203e6a:	6ca63603          	ld	a2,1738(a2) # ffffffffc0211530 <pages>
ffffffffc0203e6e:	8d91                	sub	a1,a1,a2
ffffffffc0203e70:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e74:	00002597          	auipc	a1,0x2
ffffffffc0203e78:	5b45b583          	ld	a1,1460(a1) # ffffffffc0206428 <error_string+0x38>
ffffffffc0203e7c:	02b60633          	mul	a2,a2,a1
ffffffffc0203e80:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e84:	00002797          	auipc	a5,0x2
ffffffffc0203e88:	5ac7b783          	ld	a5,1452(a5) # ffffffffc0206430 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e8c:	0000d717          	auipc	a4,0xd
ffffffffc0203e90:	69c73703          	ld	a4,1692(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e94:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e96:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e9a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e9c:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e9e:	02e7f963          	bgeu	a5,a4,ffffffffc0203ed0 <swapfs_read+0x80>
}
ffffffffc0203ea2:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ea4:	0000d797          	auipc	a5,0xd
ffffffffc0203ea8:	69c7b783          	ld	a5,1692(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203eac:	46a1                	li	a3,8
ffffffffc0203eae:	963e                	add	a2,a2,a5
ffffffffc0203eb0:	4505                	li	a0,1
}
ffffffffc0203eb2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203eb4:	decfc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203eb8:	86aa                	mv	a3,a0
ffffffffc0203eba:	00002617          	auipc	a2,0x2
ffffffffc0203ebe:	30660613          	addi	a2,a2,774 # ffffffffc02061c0 <default_pmm_manager+0xfa0>
ffffffffc0203ec2:	45d1                	li	a1,20
ffffffffc0203ec4:	00002517          	auipc	a0,0x2
ffffffffc0203ec8:	2e450513          	addi	a0,a0,740 # ffffffffc02061a8 <default_pmm_manager+0xf88>
ffffffffc0203ecc:	ca8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203ed0:	86b2                	mv	a3,a2
ffffffffc0203ed2:	06a00593          	li	a1,106
ffffffffc0203ed6:	00001617          	auipc	a2,0x1
ffffffffc0203eda:	3da60613          	addi	a2,a2,986 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc0203ede:	00001517          	auipc	a0,0x1
ffffffffc0203ee2:	39a50513          	addi	a0,a0,922 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc0203ee6:	c8efc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203eea <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203eea:	1141                	addi	sp,sp,-16
ffffffffc0203eec:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203eee:	00855793          	srli	a5,a0,0x8
ffffffffc0203ef2:	c3a5                	beqz	a5,ffffffffc0203f52 <swapfs_write+0x68>
ffffffffc0203ef4:	0000d717          	auipc	a4,0xd
ffffffffc0203ef8:	65473703          	ld	a4,1620(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203efc:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f52 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f00:	0000d617          	auipc	a2,0xd
ffffffffc0203f04:	63063603          	ld	a2,1584(a2) # ffffffffc0211530 <pages>
ffffffffc0203f08:	8d91                	sub	a1,a1,a2
ffffffffc0203f0a:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f0e:	00002597          	auipc	a1,0x2
ffffffffc0203f12:	51a5b583          	ld	a1,1306(a1) # ffffffffc0206428 <error_string+0x38>
ffffffffc0203f16:	02b60633          	mul	a2,a2,a1
ffffffffc0203f1a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f1e:	00002797          	auipc	a5,0x2
ffffffffc0203f22:	5127b783          	ld	a5,1298(a5) # ffffffffc0206430 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f26:	0000d717          	auipc	a4,0xd
ffffffffc0203f2a:	60273703          	ld	a4,1538(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f2e:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f30:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f34:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f36:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f38:	02e7f963          	bgeu	a5,a4,ffffffffc0203f6a <swapfs_write+0x80>
}
ffffffffc0203f3c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f3e:	0000d797          	auipc	a5,0xd
ffffffffc0203f42:	6027b783          	ld	a5,1538(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203f46:	46a1                	li	a3,8
ffffffffc0203f48:	963e                	add	a2,a2,a5
ffffffffc0203f4a:	4505                	li	a0,1
}
ffffffffc0203f4c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f4e:	d76fc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0203f52:	86aa                	mv	a3,a0
ffffffffc0203f54:	00002617          	auipc	a2,0x2
ffffffffc0203f58:	26c60613          	addi	a2,a2,620 # ffffffffc02061c0 <default_pmm_manager+0xfa0>
ffffffffc0203f5c:	45e5                	li	a1,25
ffffffffc0203f5e:	00002517          	auipc	a0,0x2
ffffffffc0203f62:	24a50513          	addi	a0,a0,586 # ffffffffc02061a8 <default_pmm_manager+0xf88>
ffffffffc0203f66:	c0efc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203f6a:	86b2                	mv	a3,a2
ffffffffc0203f6c:	06a00593          	li	a1,106
ffffffffc0203f70:	00001617          	auipc	a2,0x1
ffffffffc0203f74:	34060613          	addi	a2,a2,832 # ffffffffc02052b0 <default_pmm_manager+0x90>
ffffffffc0203f78:	00001517          	auipc	a0,0x1
ffffffffc0203f7c:	30050513          	addi	a0,a0,768 # ffffffffc0205278 <default_pmm_manager+0x58>
ffffffffc0203f80:	bf4fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203f84 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203f84:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f88:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203f8a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f8e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203f90:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f94:	f022                	sd	s0,32(sp)
ffffffffc0203f96:	ec26                	sd	s1,24(sp)
ffffffffc0203f98:	e84a                	sd	s2,16(sp)
ffffffffc0203f9a:	f406                	sd	ra,40(sp)
ffffffffc0203f9c:	e44e                	sd	s3,8(sp)
ffffffffc0203f9e:	84aa                	mv	s1,a0
ffffffffc0203fa0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203fa2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203fa6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203fa8:	03067e63          	bgeu	a2,a6,ffffffffc0203fe4 <printnum+0x60>
ffffffffc0203fac:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203fae:	00805763          	blez	s0,ffffffffc0203fbc <printnum+0x38>
ffffffffc0203fb2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203fb4:	85ca                	mv	a1,s2
ffffffffc0203fb6:	854e                	mv	a0,s3
ffffffffc0203fb8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203fba:	fc65                	bnez	s0,ffffffffc0203fb2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fbc:	1a02                	slli	s4,s4,0x20
ffffffffc0203fbe:	00002797          	auipc	a5,0x2
ffffffffc0203fc2:	22278793          	addi	a5,a5,546 # ffffffffc02061e0 <default_pmm_manager+0xfc0>
ffffffffc0203fc6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203fca:	9a3e                	add	s4,s4,a5
}
ffffffffc0203fcc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fce:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203fd2:	70a2                	ld	ra,40(sp)
ffffffffc0203fd4:	69a2                	ld	s3,8(sp)
ffffffffc0203fd6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fd8:	85ca                	mv	a1,s2
ffffffffc0203fda:	87a6                	mv	a5,s1
}
ffffffffc0203fdc:	6942                	ld	s2,16(sp)
ffffffffc0203fde:	64e2                	ld	s1,24(sp)
ffffffffc0203fe0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fe2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203fe4:	03065633          	divu	a2,a2,a6
ffffffffc0203fe8:	8722                	mv	a4,s0
ffffffffc0203fea:	f9bff0ef          	jal	ra,ffffffffc0203f84 <printnum>
ffffffffc0203fee:	b7f9                	j	ffffffffc0203fbc <printnum+0x38>

ffffffffc0203ff0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203ff0:	7119                	addi	sp,sp,-128
ffffffffc0203ff2:	f4a6                	sd	s1,104(sp)
ffffffffc0203ff4:	f0ca                	sd	s2,96(sp)
ffffffffc0203ff6:	ecce                	sd	s3,88(sp)
ffffffffc0203ff8:	e8d2                	sd	s4,80(sp)
ffffffffc0203ffa:	e4d6                	sd	s5,72(sp)
ffffffffc0203ffc:	e0da                	sd	s6,64(sp)
ffffffffc0203ffe:	fc5e                	sd	s7,56(sp)
ffffffffc0204000:	f06a                	sd	s10,32(sp)
ffffffffc0204002:	fc86                	sd	ra,120(sp)
ffffffffc0204004:	f8a2                	sd	s0,112(sp)
ffffffffc0204006:	f862                	sd	s8,48(sp)
ffffffffc0204008:	f466                	sd	s9,40(sp)
ffffffffc020400a:	ec6e                	sd	s11,24(sp)
ffffffffc020400c:	892a                	mv	s2,a0
ffffffffc020400e:	84ae                	mv	s1,a1
ffffffffc0204010:	8d32                	mv	s10,a2
ffffffffc0204012:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204014:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204018:	5b7d                	li	s6,-1
ffffffffc020401a:	00002a97          	auipc	s5,0x2
ffffffffc020401e:	1faa8a93          	addi	s5,s5,506 # ffffffffc0206214 <default_pmm_manager+0xff4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204022:	00002b97          	auipc	s7,0x2
ffffffffc0204026:	3ceb8b93          	addi	s7,s7,974 # ffffffffc02063f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020402a:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc020402e:	001d0413          	addi	s0,s10,1
ffffffffc0204032:	01350a63          	beq	a0,s3,ffffffffc0204046 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204036:	c121                	beqz	a0,ffffffffc0204076 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204038:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020403a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020403c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020403e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204042:	ff351ae3          	bne	a0,s3,ffffffffc0204036 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204046:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020404a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020404e:	4c81                	li	s9,0
ffffffffc0204050:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204052:	5c7d                	li	s8,-1
ffffffffc0204054:	5dfd                	li	s11,-1
ffffffffc0204056:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020405a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020405c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204060:	0ff5f593          	zext.b	a1,a1
ffffffffc0204064:	00140d13          	addi	s10,s0,1
ffffffffc0204068:	04b56263          	bltu	a0,a1,ffffffffc02040ac <vprintfmt+0xbc>
ffffffffc020406c:	058a                	slli	a1,a1,0x2
ffffffffc020406e:	95d6                	add	a1,a1,s5
ffffffffc0204070:	4194                	lw	a3,0(a1)
ffffffffc0204072:	96d6                	add	a3,a3,s5
ffffffffc0204074:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204076:	70e6                	ld	ra,120(sp)
ffffffffc0204078:	7446                	ld	s0,112(sp)
ffffffffc020407a:	74a6                	ld	s1,104(sp)
ffffffffc020407c:	7906                	ld	s2,96(sp)
ffffffffc020407e:	69e6                	ld	s3,88(sp)
ffffffffc0204080:	6a46                	ld	s4,80(sp)
ffffffffc0204082:	6aa6                	ld	s5,72(sp)
ffffffffc0204084:	6b06                	ld	s6,64(sp)
ffffffffc0204086:	7be2                	ld	s7,56(sp)
ffffffffc0204088:	7c42                	ld	s8,48(sp)
ffffffffc020408a:	7ca2                	ld	s9,40(sp)
ffffffffc020408c:	7d02                	ld	s10,32(sp)
ffffffffc020408e:	6de2                	ld	s11,24(sp)
ffffffffc0204090:	6109                	addi	sp,sp,128
ffffffffc0204092:	8082                	ret
            padc = '0';
ffffffffc0204094:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204096:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020409a:	846a                	mv	s0,s10
ffffffffc020409c:	00140d13          	addi	s10,s0,1
ffffffffc02040a0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040a4:	0ff5f593          	zext.b	a1,a1
ffffffffc02040a8:	fcb572e3          	bgeu	a0,a1,ffffffffc020406c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02040ac:	85a6                	mv	a1,s1
ffffffffc02040ae:	02500513          	li	a0,37
ffffffffc02040b2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040b4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02040b8:	8d22                	mv	s10,s0
ffffffffc02040ba:	f73788e3          	beq	a5,s3,ffffffffc020402a <vprintfmt+0x3a>
ffffffffc02040be:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02040c2:	1d7d                	addi	s10,s10,-1
ffffffffc02040c4:	ff379de3          	bne	a5,s3,ffffffffc02040be <vprintfmt+0xce>
ffffffffc02040c8:	b78d                	j	ffffffffc020402a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02040ca:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02040ce:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02040d4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02040d8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040dc:	02d86463          	bltu	a6,a3,ffffffffc0204104 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02040e0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040e4:	002c169b          	slliw	a3,s8,0x2
ffffffffc02040e8:	0186873b          	addw	a4,a3,s8
ffffffffc02040ec:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040f0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02040f2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02040f6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040f8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02040fc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204100:	fed870e3          	bgeu	a6,a3,ffffffffc02040e0 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204104:	f40ddce3          	bgez	s11,ffffffffc020405c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204108:	8de2                	mv	s11,s8
ffffffffc020410a:	5c7d                	li	s8,-1
ffffffffc020410c:	bf81                	j	ffffffffc020405c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020410e:	fffdc693          	not	a3,s11
ffffffffc0204112:	96fd                	srai	a3,a3,0x3f
ffffffffc0204114:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204118:	00144603          	lbu	a2,1(s0)
ffffffffc020411c:	2d81                	sext.w	s11,s11
ffffffffc020411e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204120:	bf35                	j	ffffffffc020405c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204122:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204126:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020412a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020412c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020412e:	bfd9                	j	ffffffffc0204104 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204130:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204132:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204136:	01174463          	blt	a4,a7,ffffffffc020413e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020413a:	1a088e63          	beqz	a7,ffffffffc02042f6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020413e:	000a3603          	ld	a2,0(s4)
ffffffffc0204142:	46c1                	li	a3,16
ffffffffc0204144:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204146:	2781                	sext.w	a5,a5
ffffffffc0204148:	876e                	mv	a4,s11
ffffffffc020414a:	85a6                	mv	a1,s1
ffffffffc020414c:	854a                	mv	a0,s2
ffffffffc020414e:	e37ff0ef          	jal	ra,ffffffffc0203f84 <printnum>
            break;
ffffffffc0204152:	bde1                	j	ffffffffc020402a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204154:	000a2503          	lw	a0,0(s4)
ffffffffc0204158:	85a6                	mv	a1,s1
ffffffffc020415a:	0a21                	addi	s4,s4,8
ffffffffc020415c:	9902                	jalr	s2
            break;
ffffffffc020415e:	b5f1                	j	ffffffffc020402a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204160:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204162:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204166:	01174463          	blt	a4,a7,ffffffffc020416e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020416a:	18088163          	beqz	a7,ffffffffc02042ec <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020416e:	000a3603          	ld	a2,0(s4)
ffffffffc0204172:	46a9                	li	a3,10
ffffffffc0204174:	8a2e                	mv	s4,a1
ffffffffc0204176:	bfc1                	j	ffffffffc0204146 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204178:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020417c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020417e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204180:	bdf1                	j	ffffffffc020405c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204182:	85a6                	mv	a1,s1
ffffffffc0204184:	02500513          	li	a0,37
ffffffffc0204188:	9902                	jalr	s2
            break;
ffffffffc020418a:	b545                	j	ffffffffc020402a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020418c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204190:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204192:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204194:	b5e1                	j	ffffffffc020405c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204196:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204198:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020419c:	01174463          	blt	a4,a7,ffffffffc02041a4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02041a0:	14088163          	beqz	a7,ffffffffc02042e2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02041a4:	000a3603          	ld	a2,0(s4)
ffffffffc02041a8:	46a1                	li	a3,8
ffffffffc02041aa:	8a2e                	mv	s4,a1
ffffffffc02041ac:	bf69                	j	ffffffffc0204146 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02041ae:	03000513          	li	a0,48
ffffffffc02041b2:	85a6                	mv	a1,s1
ffffffffc02041b4:	e03e                	sd	a5,0(sp)
ffffffffc02041b6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02041b8:	85a6                	mv	a1,s1
ffffffffc02041ba:	07800513          	li	a0,120
ffffffffc02041be:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02041c0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02041c2:	6782                	ld	a5,0(sp)
ffffffffc02041c4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02041c6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02041ca:	bfb5                	j	ffffffffc0204146 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02041cc:	000a3403          	ld	s0,0(s4)
ffffffffc02041d0:	008a0713          	addi	a4,s4,8
ffffffffc02041d4:	e03a                	sd	a4,0(sp)
ffffffffc02041d6:	14040263          	beqz	s0,ffffffffc020431a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02041da:	0fb05763          	blez	s11,ffffffffc02042c8 <vprintfmt+0x2d8>
ffffffffc02041de:	02d00693          	li	a3,45
ffffffffc02041e2:	0cd79163          	bne	a5,a3,ffffffffc02042a4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041e6:	00044783          	lbu	a5,0(s0)
ffffffffc02041ea:	0007851b          	sext.w	a0,a5
ffffffffc02041ee:	cf85                	beqz	a5,ffffffffc0204226 <vprintfmt+0x236>
ffffffffc02041f0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041f4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041f8:	000c4563          	bltz	s8,ffffffffc0204202 <vprintfmt+0x212>
ffffffffc02041fc:	3c7d                	addiw	s8,s8,-1
ffffffffc02041fe:	036c0263          	beq	s8,s6,ffffffffc0204222 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204202:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204204:	0e0c8e63          	beqz	s9,ffffffffc0204300 <vprintfmt+0x310>
ffffffffc0204208:	3781                	addiw	a5,a5,-32
ffffffffc020420a:	0ef47b63          	bgeu	s0,a5,ffffffffc0204300 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020420e:	03f00513          	li	a0,63
ffffffffc0204212:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204214:	000a4783          	lbu	a5,0(s4)
ffffffffc0204218:	3dfd                	addiw	s11,s11,-1
ffffffffc020421a:	0a05                	addi	s4,s4,1
ffffffffc020421c:	0007851b          	sext.w	a0,a5
ffffffffc0204220:	ffe1                	bnez	a5,ffffffffc02041f8 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204222:	01b05963          	blez	s11,ffffffffc0204234 <vprintfmt+0x244>
ffffffffc0204226:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204228:	85a6                	mv	a1,s1
ffffffffc020422a:	02000513          	li	a0,32
ffffffffc020422e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204230:	fe0d9be3          	bnez	s11,ffffffffc0204226 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204234:	6a02                	ld	s4,0(sp)
ffffffffc0204236:	bbd5                	j	ffffffffc020402a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204238:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020423a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020423e:	01174463          	blt	a4,a7,ffffffffc0204246 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204242:	08088d63          	beqz	a7,ffffffffc02042dc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204246:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020424a:	0a044d63          	bltz	s0,ffffffffc0204304 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020424e:	8622                	mv	a2,s0
ffffffffc0204250:	8a66                	mv	s4,s9
ffffffffc0204252:	46a9                	li	a3,10
ffffffffc0204254:	bdcd                	j	ffffffffc0204146 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204256:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020425a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020425c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020425e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204262:	8fb5                	xor	a5,a5,a3
ffffffffc0204264:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204268:	02d74163          	blt	a4,a3,ffffffffc020428a <vprintfmt+0x29a>
ffffffffc020426c:	00369793          	slli	a5,a3,0x3
ffffffffc0204270:	97de                	add	a5,a5,s7
ffffffffc0204272:	639c                	ld	a5,0(a5)
ffffffffc0204274:	cb99                	beqz	a5,ffffffffc020428a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204276:	86be                	mv	a3,a5
ffffffffc0204278:	00002617          	auipc	a2,0x2
ffffffffc020427c:	f9860613          	addi	a2,a2,-104 # ffffffffc0206210 <default_pmm_manager+0xff0>
ffffffffc0204280:	85a6                	mv	a1,s1
ffffffffc0204282:	854a                	mv	a0,s2
ffffffffc0204284:	0ce000ef          	jal	ra,ffffffffc0204352 <printfmt>
ffffffffc0204288:	b34d                	j	ffffffffc020402a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020428a:	00002617          	auipc	a2,0x2
ffffffffc020428e:	f7660613          	addi	a2,a2,-138 # ffffffffc0206200 <default_pmm_manager+0xfe0>
ffffffffc0204292:	85a6                	mv	a1,s1
ffffffffc0204294:	854a                	mv	a0,s2
ffffffffc0204296:	0bc000ef          	jal	ra,ffffffffc0204352 <printfmt>
ffffffffc020429a:	bb41                	j	ffffffffc020402a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020429c:	00002417          	auipc	s0,0x2
ffffffffc02042a0:	f5c40413          	addi	s0,s0,-164 # ffffffffc02061f8 <default_pmm_manager+0xfd8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042a4:	85e2                	mv	a1,s8
ffffffffc02042a6:	8522                	mv	a0,s0
ffffffffc02042a8:	e43e                	sd	a5,8(sp)
ffffffffc02042aa:	196000ef          	jal	ra,ffffffffc0204440 <strnlen>
ffffffffc02042ae:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02042b2:	01b05b63          	blez	s11,ffffffffc02042c8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02042b6:	67a2                	ld	a5,8(sp)
ffffffffc02042b8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042bc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02042be:	85a6                	mv	a1,s1
ffffffffc02042c0:	8552                	mv	a0,s4
ffffffffc02042c2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042c4:	fe0d9ce3          	bnez	s11,ffffffffc02042bc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042c8:	00044783          	lbu	a5,0(s0)
ffffffffc02042cc:	00140a13          	addi	s4,s0,1
ffffffffc02042d0:	0007851b          	sext.w	a0,a5
ffffffffc02042d4:	d3a5                	beqz	a5,ffffffffc0204234 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042d6:	05e00413          	li	s0,94
ffffffffc02042da:	bf39                	j	ffffffffc02041f8 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02042dc:	000a2403          	lw	s0,0(s4)
ffffffffc02042e0:	b7ad                	j	ffffffffc020424a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02042e2:	000a6603          	lwu	a2,0(s4)
ffffffffc02042e6:	46a1                	li	a3,8
ffffffffc02042e8:	8a2e                	mv	s4,a1
ffffffffc02042ea:	bdb1                	j	ffffffffc0204146 <vprintfmt+0x156>
ffffffffc02042ec:	000a6603          	lwu	a2,0(s4)
ffffffffc02042f0:	46a9                	li	a3,10
ffffffffc02042f2:	8a2e                	mv	s4,a1
ffffffffc02042f4:	bd89                	j	ffffffffc0204146 <vprintfmt+0x156>
ffffffffc02042f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02042fa:	46c1                	li	a3,16
ffffffffc02042fc:	8a2e                	mv	s4,a1
ffffffffc02042fe:	b5a1                	j	ffffffffc0204146 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204300:	9902                	jalr	s2
ffffffffc0204302:	bf09                	j	ffffffffc0204214 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204304:	85a6                	mv	a1,s1
ffffffffc0204306:	02d00513          	li	a0,45
ffffffffc020430a:	e03e                	sd	a5,0(sp)
ffffffffc020430c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020430e:	6782                	ld	a5,0(sp)
ffffffffc0204310:	8a66                	mv	s4,s9
ffffffffc0204312:	40800633          	neg	a2,s0
ffffffffc0204316:	46a9                	li	a3,10
ffffffffc0204318:	b53d                	j	ffffffffc0204146 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020431a:	03b05163          	blez	s11,ffffffffc020433c <vprintfmt+0x34c>
ffffffffc020431e:	02d00693          	li	a3,45
ffffffffc0204322:	f6d79de3          	bne	a5,a3,ffffffffc020429c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204326:	00002417          	auipc	s0,0x2
ffffffffc020432a:	ed240413          	addi	s0,s0,-302 # ffffffffc02061f8 <default_pmm_manager+0xfd8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020432e:	02800793          	li	a5,40
ffffffffc0204332:	02800513          	li	a0,40
ffffffffc0204336:	00140a13          	addi	s4,s0,1
ffffffffc020433a:	bd6d                	j	ffffffffc02041f4 <vprintfmt+0x204>
ffffffffc020433c:	00002a17          	auipc	s4,0x2
ffffffffc0204340:	ebda0a13          	addi	s4,s4,-323 # ffffffffc02061f9 <default_pmm_manager+0xfd9>
ffffffffc0204344:	02800513          	li	a0,40
ffffffffc0204348:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020434c:	05e00413          	li	s0,94
ffffffffc0204350:	b565                	j	ffffffffc02041f8 <vprintfmt+0x208>

ffffffffc0204352 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204352:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204354:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204358:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020435a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020435c:	ec06                	sd	ra,24(sp)
ffffffffc020435e:	f83a                	sd	a4,48(sp)
ffffffffc0204360:	fc3e                	sd	a5,56(sp)
ffffffffc0204362:	e0c2                	sd	a6,64(sp)
ffffffffc0204364:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204366:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204368:	c89ff0ef          	jal	ra,ffffffffc0203ff0 <vprintfmt>
}
ffffffffc020436c:	60e2                	ld	ra,24(sp)
ffffffffc020436e:	6161                	addi	sp,sp,80
ffffffffc0204370:	8082                	ret

ffffffffc0204372 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204372:	715d                	addi	sp,sp,-80
ffffffffc0204374:	e486                	sd	ra,72(sp)
ffffffffc0204376:	e0a6                	sd	s1,64(sp)
ffffffffc0204378:	fc4a                	sd	s2,56(sp)
ffffffffc020437a:	f84e                	sd	s3,48(sp)
ffffffffc020437c:	f452                	sd	s4,40(sp)
ffffffffc020437e:	f056                	sd	s5,32(sp)
ffffffffc0204380:	ec5a                	sd	s6,24(sp)
ffffffffc0204382:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204384:	c901                	beqz	a0,ffffffffc0204394 <readline+0x22>
ffffffffc0204386:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204388:	00002517          	auipc	a0,0x2
ffffffffc020438c:	e8850513          	addi	a0,a0,-376 # ffffffffc0206210 <default_pmm_manager+0xff0>
ffffffffc0204390:	d2bfb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0204394:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204396:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204398:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020439a:	4aa9                	li	s5,10
ffffffffc020439c:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020439e:	0000db97          	auipc	s7,0xd
ffffffffc02043a2:	d5ab8b93          	addi	s7,s7,-678 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043a6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02043aa:	d49fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043ae:	00054a63          	bltz	a0,ffffffffc02043c2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043b2:	00a95a63          	bge	s2,a0,ffffffffc02043c6 <readline+0x54>
ffffffffc02043b6:	029a5263          	bge	s4,s1,ffffffffc02043da <readline+0x68>
        c = getchar();
ffffffffc02043ba:	d39fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043be:	fe055ae3          	bgez	a0,ffffffffc02043b2 <readline+0x40>
            return NULL;
ffffffffc02043c2:	4501                	li	a0,0
ffffffffc02043c4:	a091                	j	ffffffffc0204408 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02043c6:	03351463          	bne	a0,s3,ffffffffc02043ee <readline+0x7c>
ffffffffc02043ca:	e8a9                	bnez	s1,ffffffffc020441c <readline+0xaa>
        c = getchar();
ffffffffc02043cc:	d27fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043d0:	fe0549e3          	bltz	a0,ffffffffc02043c2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043d4:	fea959e3          	bge	s2,a0,ffffffffc02043c6 <readline+0x54>
ffffffffc02043d8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02043da:	e42a                	sd	a0,8(sp)
ffffffffc02043dc:	d15fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02043e0:	6522                	ld	a0,8(sp)
ffffffffc02043e2:	009b87b3          	add	a5,s7,s1
ffffffffc02043e6:	2485                	addiw	s1,s1,1
ffffffffc02043e8:	00a78023          	sb	a0,0(a5)
ffffffffc02043ec:	bf7d                	j	ffffffffc02043aa <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02043ee:	01550463          	beq	a0,s5,ffffffffc02043f6 <readline+0x84>
ffffffffc02043f2:	fb651ce3          	bne	a0,s6,ffffffffc02043aa <readline+0x38>
            cputchar(c);
ffffffffc02043f6:	cfbfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02043fa:	0000d517          	auipc	a0,0xd
ffffffffc02043fe:	cfe50513          	addi	a0,a0,-770 # ffffffffc02110f8 <buf>
ffffffffc0204402:	94aa                	add	s1,s1,a0
ffffffffc0204404:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204408:	60a6                	ld	ra,72(sp)
ffffffffc020440a:	6486                	ld	s1,64(sp)
ffffffffc020440c:	7962                	ld	s2,56(sp)
ffffffffc020440e:	79c2                	ld	s3,48(sp)
ffffffffc0204410:	7a22                	ld	s4,40(sp)
ffffffffc0204412:	7a82                	ld	s5,32(sp)
ffffffffc0204414:	6b62                	ld	s6,24(sp)
ffffffffc0204416:	6bc2                	ld	s7,16(sp)
ffffffffc0204418:	6161                	addi	sp,sp,80
ffffffffc020441a:	8082                	ret
            cputchar(c);
ffffffffc020441c:	4521                	li	a0,8
ffffffffc020441e:	cd3fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0204422:	34fd                	addiw	s1,s1,-1
ffffffffc0204424:	b759                	j	ffffffffc02043aa <readline+0x38>

ffffffffc0204426 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204426:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020442a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020442c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020442e:	cb81                	beqz	a5,ffffffffc020443e <strlen+0x18>
        cnt ++;
ffffffffc0204430:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204432:	00a707b3          	add	a5,a4,a0
ffffffffc0204436:	0007c783          	lbu	a5,0(a5)
ffffffffc020443a:	fbfd                	bnez	a5,ffffffffc0204430 <strlen+0xa>
ffffffffc020443c:	8082                	ret
    }
    return cnt;
}
ffffffffc020443e:	8082                	ret

ffffffffc0204440 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204440:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204442:	e589                	bnez	a1,ffffffffc020444c <strnlen+0xc>
ffffffffc0204444:	a811                	j	ffffffffc0204458 <strnlen+0x18>
        cnt ++;
ffffffffc0204446:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204448:	00f58863          	beq	a1,a5,ffffffffc0204458 <strnlen+0x18>
ffffffffc020444c:	00f50733          	add	a4,a0,a5
ffffffffc0204450:	00074703          	lbu	a4,0(a4)
ffffffffc0204454:	fb6d                	bnez	a4,ffffffffc0204446 <strnlen+0x6>
ffffffffc0204456:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204458:	852e                	mv	a0,a1
ffffffffc020445a:	8082                	ret

ffffffffc020445c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020445c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020445e:	0005c703          	lbu	a4,0(a1)
ffffffffc0204462:	0785                	addi	a5,a5,1
ffffffffc0204464:	0585                	addi	a1,a1,1
ffffffffc0204466:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020446a:	fb75                	bnez	a4,ffffffffc020445e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020446c:	8082                	ret

ffffffffc020446e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020446e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204472:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204476:	cb89                	beqz	a5,ffffffffc0204488 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204478:	0505                	addi	a0,a0,1
ffffffffc020447a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020447c:	fee789e3          	beq	a5,a4,ffffffffc020446e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204480:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204484:	9d19                	subw	a0,a0,a4
ffffffffc0204486:	8082                	ret
ffffffffc0204488:	4501                	li	a0,0
ffffffffc020448a:	bfed                	j	ffffffffc0204484 <strcmp+0x16>

ffffffffc020448c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020448c:	00054783          	lbu	a5,0(a0)
ffffffffc0204490:	c799                	beqz	a5,ffffffffc020449e <strchr+0x12>
        if (*s == c) {
ffffffffc0204492:	00f58763          	beq	a1,a5,ffffffffc02044a0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204496:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020449a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020449c:	fbfd                	bnez	a5,ffffffffc0204492 <strchr+0x6>
    }
    return NULL;
ffffffffc020449e:	4501                	li	a0,0
}
ffffffffc02044a0:	8082                	ret

ffffffffc02044a2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02044a2:	ca01                	beqz	a2,ffffffffc02044b2 <memset+0x10>
ffffffffc02044a4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02044a6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02044a8:	0785                	addi	a5,a5,1
ffffffffc02044aa:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02044ae:	fec79de3          	bne	a5,a2,ffffffffc02044a8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02044b2:	8082                	ret

ffffffffc02044b4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02044b4:	ca19                	beqz	a2,ffffffffc02044ca <memcpy+0x16>
ffffffffc02044b6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02044b8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02044ba:	0005c703          	lbu	a4,0(a1)
ffffffffc02044be:	0585                	addi	a1,a1,1
ffffffffc02044c0:	0785                	addi	a5,a5,1
ffffffffc02044c2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02044c6:	fec59ae3          	bne	a1,a2,ffffffffc02044ba <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02044ca:	8082                	ret
