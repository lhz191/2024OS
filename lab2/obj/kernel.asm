
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <buddy_zone>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	52e60613          	addi	a2,a2,1326 # ffffffffc0206568 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	22f010ef          	jal	ra,ffffffffc0201a78 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0201a90 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	308010ef          	jal	ra,ffffffffc020136e <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	4fc010ef          	jal	ra,ffffffffc02015a2 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	4c6010ef          	jal	ra,ffffffffc02015a2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	97450513          	addi	a0,a0,-1676 # ffffffffc0201ab0 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	97e50513          	addi	a0,a0,-1666 # ffffffffc0201ad0 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	92c58593          	addi	a1,a1,-1748 # ffffffffc0201a8a <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201af0 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buddy_zone>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	99650513          	addi	a0,a0,-1642 # ffffffffc0201b10 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	3e258593          	addi	a1,a1,994 # ffffffffc0206568 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201b30 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	7cd58593          	addi	a1,a1,1997 # ffffffffc0206967 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	99450513          	addi	a0,a0,-1644 # ffffffffc0201b50 <etext+0xc6>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	9b660613          	addi	a2,a2,-1610 # ffffffffc0201b80 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201b98 <etext+0x10e>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0201bb0 <etext+0x126>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	9e258593          	addi	a1,a1,-1566 # ffffffffc0201bd0 <etext+0x146>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	9e250513          	addi	a0,a0,-1566 # ffffffffc0201bd8 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	9e460613          	addi	a2,a2,-1564 # ffffffffc0201be8 <etext+0x15e>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	a0458593          	addi	a1,a1,-1532 # ffffffffc0201c10 <etext+0x186>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	9c450513          	addi	a0,a0,-1596 # ffffffffc0201bd8 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	a0060613          	addi	a2,a2,-1536 # ffffffffc0201c20 <etext+0x196>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	a1858593          	addi	a1,a1,-1512 # ffffffffc0201c40 <etext+0x1b6>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	9a850513          	addi	a0,a0,-1624 # ffffffffc0201bd8 <etext+0x14e>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	9e650513          	addi	a0,a0,-1562 # ffffffffc0201c50 <etext+0x1c6>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0201c78 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	a46c0c13          	addi	s8,s8,-1466 # ffffffffc0201ce8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	9f690913          	addi	s2,s2,-1546 # ffffffffc0201ca0 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	9f648493          	addi	s1,s1,-1546 # ffffffffc0201ca8 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	9f4b0b13          	addi	s6,s6,-1548 # ffffffffc0201cb0 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	90ca0a13          	addi	s4,s4,-1780 # ffffffffc0201bd0 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	654010ef          	jal	ra,ffffffffc0201924 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	a02d0d13          	addi	s10,s10,-1534 # ffffffffc0201ce8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	750010ef          	jal	ra,ffffffffc0201a44 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	73c010ef          	jal	ra,ffffffffc0201a44 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	71c010ef          	jal	ra,ffffffffc0201a62 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	6de010ef          	jal	ra,ffffffffc0201a62 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	93250513          	addi	a0,a0,-1742 # ffffffffc0201cd0 <etext+0x246>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	17430313          	addi	t1,t1,372 # ffffffffc0206520 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	95650513          	addi	a0,a0,-1706 # ffffffffc0201d30 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	e0850513          	addi	a0,a0,-504 # ffffffffc02021f8 <commands+0x510>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	5d2010ef          	jal	ra,ffffffffc02019f2 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	1007b123          	sd	zero,258(a5) # ffffffffc0206528 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	92250513          	addi	a0,a0,-1758 # ffffffffc0201d50 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5ac0106f          	j	ffffffffc02019f2 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	5880106f          	j	ffffffffc02019d8 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5b80106f          	j	ffffffffc0201a0c <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201d70 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201d88 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	90450513          	addi	a0,a0,-1788 # ffffffffc0201da0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	90e50513          	addi	a0,a0,-1778 # ffffffffc0201db8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	91850513          	addi	a0,a0,-1768 # ffffffffc0201dd0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	92250513          	addi	a0,a0,-1758 # ffffffffc0201de8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	92c50513          	addi	a0,a0,-1748 # ffffffffc0201e00 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	93650513          	addi	a0,a0,-1738 # ffffffffc0201e18 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	94050513          	addi	a0,a0,-1728 # ffffffffc0201e30 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201e48 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	95450513          	addi	a0,a0,-1708 # ffffffffc0201e60 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201e78 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	96850513          	addi	a0,a0,-1688 # ffffffffc0201e90 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	97250513          	addi	a0,a0,-1678 # ffffffffc0201ea8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	97c50513          	addi	a0,a0,-1668 # ffffffffc0201ec0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	98650513          	addi	a0,a0,-1658 # ffffffffc0201ed8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	99050513          	addi	a0,a0,-1648 # ffffffffc0201ef0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201f08 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201f20 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0201f38 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0201f50 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201f68 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0201f80 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201f98 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9e050513          	addi	a0,a0,-1568 # ffffffffc0201fb0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0201fc8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9f450513          	addi	a0,a0,-1548 # ffffffffc0201fe0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0201ff8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0202010 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	a1250513          	addi	a0,a0,-1518 # ffffffffc0202028 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0202040 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0202058 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	a2650513          	addi	a0,a0,-1498 # ffffffffc0202070 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	a2650513          	addi	a0,a0,-1498 # ffffffffc0202088 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02020a0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	a3650513          	addi	a0,a0,-1482 # ffffffffc02020b8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02020d0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	b0070713          	addi	a4,a4,-1280 # ffffffffc02021b0 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	a8650513          	addi	a0,a0,-1402 # ffffffffc0202148 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0202128 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	a1250513          	addi	a0,a0,-1518 # ffffffffc02020e8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a8850513          	addi	a0,a0,-1400 # ffffffffc0202168 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	e3668693          	addi	a3,a3,-458 # ffffffffc0206528 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	a8050513          	addi	a0,a0,-1408 # ffffffffc0202190 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0202108 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	a5450513          	addi	a0,a0,-1452 # ffffffffc0202180 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_nr_free_pages>:



static size_t buddy_nr_free_pages(void) {
    size_t total_cnt = 0;
    for (size_t i = 0; i < MAX_ORDER; i++) {
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	81e78793          	addi	a5,a5,-2018 # ffffffffc0206020 <buddy_zone+0x10>
ffffffffc020080a:	00006697          	auipc	a3,0x6
ffffffffc020080e:	91e68693          	addi	a3,a3,-1762 # ffffffffc0206128 <buf+0x8>
    size_t total_cnt = 0;
ffffffffc0200812:	4501                	li	a0,0
        total_cnt += buddy_zone.free_area[i].nr_free;
ffffffffc0200814:	0007e703          	lwu	a4,0(a5)
    for (size_t i = 0; i < MAX_ORDER; i++) {
ffffffffc0200818:	07e1                	addi	a5,a5,24
        total_cnt += buddy_zone.free_area[i].nr_free;
ffffffffc020081a:	953a                	add	a0,a0,a4
    for (size_t i = 0; i < MAX_ORDER; i++) {
ffffffffc020081c:	fed79ce3          	bne	a5,a3,ffffffffc0200814 <buddy_nr_free_pages+0x12>
    }
    return total_cnt;
}
ffffffffc0200820:	8082                	ret

ffffffffc0200822 <buddy_system_pmm_init>:
static void buddy_system_pmm_init(void) {
ffffffffc0200822:	1141                	addi	sp,sp,-16
    cprintf("111111111111111111111111\n");
ffffffffc0200824:	00002517          	auipc	a0,0x2
ffffffffc0200828:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02021e0 <commands+0x4f8>
static void buddy_system_pmm_init(void) {
ffffffffc020082c:	e406                	sd	ra,8(sp)
    cprintf("111111111111111111111111\n");
ffffffffc020082e:	885ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200832:	00005797          	auipc	a5,0x5
ffffffffc0200836:	7de78793          	addi	a5,a5,2014 # ffffffffc0206010 <buddy_zone>
ffffffffc020083a:	00006717          	auipc	a4,0x6
ffffffffc020083e:	8de70713          	addi	a4,a4,-1826 # ffffffffc0206118 <buddy_zone+0x108>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200842:	e79c                	sd	a5,8(a5)
ffffffffc0200844:	e39c                	sd	a5,0(a5)
        buddy_zone.free_area[i].nr_free = 0;  // Properly access nr_free for buddy_zone
ffffffffc0200846:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc020084a:	07e1                	addi	a5,a5,24
ffffffffc020084c:	fee79be3          	bne	a5,a4,ffffffffc0200842 <buddy_system_pmm_init+0x20>
}
ffffffffc0200850:	60a2                	ld	ra,8(sp)
     cprintf("22222222222222222222\n");
ffffffffc0200852:	00002517          	auipc	a0,0x2
ffffffffc0200856:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0202200 <commands+0x518>
}
ffffffffc020085a:	0141                	addi	sp,sp,16
     cprintf("22222222222222222222\n");
ffffffffc020085c:	857ff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc0200860 <buddy_system_pmm_init_memmap>:
static void buddy_system_pmm_init_memmap(struct Page *base, size_t n) {
ffffffffc0200860:	7119                	addi	sp,sp,-128
ffffffffc0200862:	fc86                	sd	ra,120(sp)
ffffffffc0200864:	f8a2                	sd	s0,112(sp)
ffffffffc0200866:	f4a6                	sd	s1,104(sp)
ffffffffc0200868:	f0ca                	sd	s2,96(sp)
ffffffffc020086a:	ecce                	sd	s3,88(sp)
ffffffffc020086c:	e8d2                	sd	s4,80(sp)
ffffffffc020086e:	e4d6                	sd	s5,72(sp)
ffffffffc0200870:	e0da                	sd	s6,64(sp)
ffffffffc0200872:	fc5e                	sd	s7,56(sp)
ffffffffc0200874:	f862                	sd	s8,48(sp)
ffffffffc0200876:	f466                	sd	s9,40(sp)
ffffffffc0200878:	f06a                	sd	s10,32(sp)
ffffffffc020087a:	ec6e                	sd	s11,24(sp)
    assert(n > 0);
ffffffffc020087c:	2e058163          	beqz	a1,ffffffffc0200b5e <buddy_system_pmm_init_memmap+0x2fe>
ffffffffc0200880:	892a                	mv	s2,a0
    cprintf("3333333333333333333333\n");
ffffffffc0200882:	00002517          	auipc	a0,0x2
ffffffffc0200886:	9d650513          	addi	a0,a0,-1578 # ffffffffc0202258 <commands+0x570>
ffffffffc020088a:	84ae                	mv	s1,a1
ffffffffc020088c:	827ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (; p != base + n; p++) {
ffffffffc0200890:	00249693          	slli	a3,s1,0x2
ffffffffc0200894:	96a6                	add	a3,a3,s1
ffffffffc0200896:	068e                	slli	a3,a3,0x3
ffffffffc0200898:	96ca                	add	a3,a3,s2
ffffffffc020089a:	87ca                	mv	a5,s2
ffffffffc020089c:	02d90063          	beq	s2,a3,ffffffffc02008bc <buddy_system_pmm_init_memmap+0x5c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02008a0:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02008a2:	8b05                	andi	a4,a4,1
ffffffffc02008a4:	28070d63          	beqz	a4,ffffffffc0200b3e <buddy_system_pmm_init_memmap+0x2de>
        p->flags = p->property = 0;
ffffffffc02008a8:	0007a823          	sw	zero,16(a5)
ffffffffc02008ac:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008b0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc02008b4:	02878793          	addi	a5,a5,40
ffffffffc02008b8:	fed794e3          	bne	a5,a3,ffffffffc02008a0 <buddy_system_pmm_init_memmap+0x40>
    buddy_zone.n_sum += n;
ffffffffc02008bc:	00005d17          	auipc	s10,0x5
ffffffffc02008c0:	754d0d13          	addi	s10,s10,1876 # ffffffffc0206010 <buddy_zone>
ffffffffc02008c4:	108d3783          	ld	a5,264(s10)
    int n_now = n;
ffffffffc02008c8:	0004841b          	sext.w	s0,s1
    buddy_zone.n_sum += n;
ffffffffc02008cc:	94be                	add	s1,s1,a5
ffffffffc02008ce:	109d3423          	sd	s1,264(s10)
    while (n_now != 0) {
ffffffffc02008d2:	cc79                	beqz	s0,ffffffffc02009b0 <buddy_system_pmm_init_memmap+0x150>
        return res >> 1;
ffffffffc02008d4:	57fd                	li	a5,-1
ffffffffc02008d6:	8385                	srli	a5,a5,0x1
ffffffffc02008d8:	00006d97          	auipc	s11,0x6
ffffffffc02008dc:	828d8d93          	addi	s11,s11,-2008 # ffffffffc0206100 <buddy_zone+0xf0>
                cprintf("now_page_before: %p\n", now_page);
ffffffffc02008e0:	00002c97          	auipc	s9,0x2
ffffffffc02008e4:	9e0c8c93          	addi	s9,s9,-1568 # ffffffffc02022c0 <commands+0x5d8>
                cprintf("now_page_after: %p\n", now_page);
ffffffffc02008e8:	00002c17          	auipc	s8,0x2
ffffffffc02008ec:	9f0c0c13          	addi	s8,s8,-1552 # ffffffffc02022d8 <commands+0x5f0>
                cprintf("Size of struct Page: %u bytes\n", (unsigned int)sizeof(struct Page));
ffffffffc02008f0:	00002b97          	auipc	s7,0x2
ffffffffc02008f4:	a00b8b93          	addi	s7,s7,-1536 # ffffffffc02022f0 <commands+0x608>
        return res >> 1;
ffffffffc02008f8:	e03e                	sd	a5,0(sp)
    if(n==1)//这个是为了照顾最后n=1的情况
ffffffffc02008fa:	4785                	li	a5,1
        int n_temp = getdown2(n_now);
ffffffffc02008fc:	8a22                	mv	s4,s0
    if(n==1)//这个是为了照顾最后n=1的情况
ffffffffc02008fe:	20f40163          	beq	s0,a5,ffffffffc0200b00 <buddy_system_pmm_init_memmap+0x2a0>
    if (n & (n - 1)) return 0;
ffffffffc0200902:	fff40793          	addi	a5,s0,-1
ffffffffc0200906:	8fe1                	and	a5,a5,s0
ffffffffc0200908:	1e078063          	beqz	a5,ffffffffc0200ae8 <buddy_system_pmm_init_memmap+0x288>
    size_t res = 1;
ffffffffc020090c:	4785                	li	a5,1
            n = n >> 1;
ffffffffc020090e:	001a5a13          	srli	s4,s4,0x1
            res = res << 1;
ffffffffc0200912:	873e                	mv	a4,a5
ffffffffc0200914:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200916:	fe0a1ce3          	bnez	s4,ffffffffc020090e <buddy_system_pmm_init_memmap+0xae>
        return res >> 1;
ffffffffc020091a:	6782                	ld	a5,0(sp)
        cprintf("n_now: %d\n", n_now);  // 打印 n_now 的值
ffffffffc020091c:	85a2                	mv	a1,s0
ffffffffc020091e:	00002517          	auipc	a0,0x2
ffffffffc0200922:	98250513          	addi	a0,a0,-1662 # ffffffffc02022a0 <commands+0x5b8>
        return res >> 1;
ffffffffc0200926:	00f77a33          	and	s4,a4,a5
        int n_temp = getdown2(n_now);
ffffffffc020092a:	000a099b          	sext.w	s3,s4
        cprintf("n_now: %d\n", n_now);  // 打印 n_now 的值
ffffffffc020092e:	f84ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    while (n >> 1)
ffffffffc0200932:	0019d793          	srli	a5,s3,0x1
        int order = getorder(n_temp);
ffffffffc0200936:	8b4e                	mv	s6,s3
    while (n >> 1)
ffffffffc0200938:	24078363          	beqz	a5,ffffffffc0200b7e <buddy_system_pmm_init_memmap+0x31e>
ffffffffc020093c:	4581                	li	a1,0
ffffffffc020093e:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200940:	2585                	addiw	a1,a1,1
    while (n >> 1)
ffffffffc0200942:	fff5                	bnez	a5,ffffffffc020093e <buddy_system_pmm_init_memmap+0xde>
        int order = getorder(n_temp);
ffffffffc0200944:	0005849b          	sext.w	s1,a1
        cprintf("order: %d\n", order);  // 打印 order 的值
ffffffffc0200948:	85a6                	mv	a1,s1
ffffffffc020094a:	00002517          	auipc	a0,0x2
ffffffffc020094e:	96650513          	addi	a0,a0,-1690 # ffffffffc02022b0 <commands+0x5c8>
ffffffffc0200952:	f60ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        if (order == MAX_ORDER - 1) {
ffffffffc0200956:	47a5                	li	a5,9
ffffffffc0200958:	0a97c263          	blt	a5,s1,ffffffffc02009fc <buddy_system_pmm_init_memmap+0x19c>
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc020095c:	00149793          	slli	a5,s1,0x1
            now_page += n_temp; // 更新当前页指针
ffffffffc0200960:	002b1a93          	slli	s5,s6,0x2
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200964:	009786b3          	add	a3,a5,s1
            now_page += n_temp; // 更新当前页指针
ffffffffc0200968:	9ada                	add	s5,s5,s6
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc020096a:	068e                	slli	a3,a3,0x3
            now_page += n_temp; // 更新当前页指针
ffffffffc020096c:	0a8e                	slli	s5,s5,0x3
            now_page->property = n_temp;
ffffffffc020096e:	2a01                	sext.w	s4,s4
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200970:	96ea                	add	a3,a3,s10
            now_page += n_temp; // 更新当前页指针
ffffffffc0200972:	9956                	add	s2,s2,s5
            n_now -= n_temp;
ffffffffc0200974:	4134043b          	subw	s0,s0,s3
            now_page->property = n_temp;
ffffffffc0200978:	01492823          	sw	s4,16(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020097c:	4709                	li	a4,2
ffffffffc020097e:	00890613          	addi	a2,s2,8
ffffffffc0200982:	40e6302f          	amoor.d	zero,a4,(a2)
            buddy_zone.free_area[order].nr_free += n_temp;
ffffffffc0200986:	00978733          	add	a4,a5,s1
ffffffffc020098a:	070e                	slli	a4,a4,0x3
ffffffffc020098c:	976a                	add	a4,a4,s10
ffffffffc020098e:	4b10                	lw	a2,16(a4)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200990:	671c                	ld	a5,8(a4)
                list_add(free_list_order, &now_page->page_link);
ffffffffc0200992:	01890593          	addi	a1,s2,24
            buddy_zone.free_area[order].nr_free += n_temp;
ffffffffc0200996:	01460a3b          	addw	s4,a2,s4
ffffffffc020099a:	01472823          	sw	s4,16(a4)
            if (list_empty(free_list_order)) {
ffffffffc020099e:	04f69163          	bne	a3,a5,ffffffffc02009e0 <buddy_system_pmm_init_memmap+0x180>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02009a2:	e28c                	sd	a1,0(a3)
ffffffffc02009a4:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02009a6:	02d93023          	sd	a3,32(s2)
    elm->prev = prev;
ffffffffc02009aa:	00d93c23          	sd	a3,24(s2)
    while (n_now != 0) {
ffffffffc02009ae:	f431                	bnez	s0,ffffffffc02008fa <buddy_system_pmm_init_memmap+0x9a>
}
ffffffffc02009b0:	7446                	ld	s0,112(sp)
ffffffffc02009b2:	70e6                	ld	ra,120(sp)
ffffffffc02009b4:	74a6                	ld	s1,104(sp)
ffffffffc02009b6:	7906                	ld	s2,96(sp)
ffffffffc02009b8:	69e6                	ld	s3,88(sp)
ffffffffc02009ba:	6a46                	ld	s4,80(sp)
ffffffffc02009bc:	6aa6                	ld	s5,72(sp)
ffffffffc02009be:	6b06                	ld	s6,64(sp)
ffffffffc02009c0:	7be2                	ld	s7,56(sp)
ffffffffc02009c2:	7c42                	ld	s8,48(sp)
ffffffffc02009c4:	7ca2                	ld	s9,40(sp)
ffffffffc02009c6:	7d02                	ld	s10,32(sp)
ffffffffc02009c8:	6de2                	ld	s11,24(sp)
    cprintf("44444444444444444444444444\n");
ffffffffc02009ca:	00002517          	auipc	a0,0x2
ffffffffc02009ce:	8b650513          	addi	a0,a0,-1866 # ffffffffc0202280 <commands+0x598>
}
ffffffffc02009d2:	6109                	addi	sp,sp,128
    cprintf("44444444444444444444444444\n");
ffffffffc02009d4:	edeff06f          	j	ffffffffc02000b2 <cprintf>
    return listelm->next;
ffffffffc02009d8:	6798                	ld	a4,8(a5)
                    } else if (list_next(le) == free_list_order) {
ffffffffc02009da:	14e68963          	beq	a3,a4,ffffffffc0200b2c <buddy_system_pmm_init_memmap+0x2cc>
ffffffffc02009de:	87ba                	mv	a5,a4
                    struct Page *page = le2page(le, page_link);
ffffffffc02009e0:	fe878713          	addi	a4,a5,-24
                    if (now_page < page) {
ffffffffc02009e4:	fee97ae3          	bgeu	s2,a4,ffffffffc02009d8 <buddy_system_pmm_init_memmap+0x178>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02009e8:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02009ea:	e38c                	sd	a1,0(a5)
ffffffffc02009ec:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02009ee:	02f93023          	sd	a5,32(s2)
    elm->prev = prev;
ffffffffc02009f2:	00e93c23          	sd	a4,24(s2)
    while (n_now != 0) {
ffffffffc02009f6:	f00412e3          	bnez	s0,ffffffffc02008fa <buddy_system_pmm_init_memmap+0x9a>
ffffffffc02009fa:	bf5d                	j	ffffffffc02009b0 <buddy_system_pmm_init_memmap+0x150>
            int num_blocks = n_now / max_block_size; // 计算需要的最大块数
ffffffffc02009fc:	41f4579b          	sraiw	a5,s0,0x1f
ffffffffc0200a00:	c43e                	sw	a5,8(sp)
ffffffffc0200a02:	0167d79b          	srliw	a5,a5,0x16
ffffffffc0200a06:	9fa1                	addw	a5,a5,s0
ffffffffc0200a08:	40a7d79b          	sraiw	a5,a5,0xa
ffffffffc0200a0c:	0007899b          	sext.w	s3,a5
ffffffffc0200a10:	c64e                	sw	s3,12(sp)
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200a12:	3ff00793          	li	a5,1023
ffffffffc0200a16:	0a87df63          	bge	a5,s0,ffffffffc0200ad4 <buddy_system_pmm_init_memmap+0x274>
ffffffffc0200a1a:	8a4a                	mv	s4,s2
ffffffffc0200a1c:	4481                	li	s1,0
                now_page->property = max_block_size; // 每个块的页数
ffffffffc0200a1e:	40000b13          	li	s6,1024
ffffffffc0200a22:	4a89                	li	s5,2
ffffffffc0200a24:	a81d                	j	ffffffffc0200a5a <buddy_system_pmm_init_memmap+0x1fa>
    prev->next = next->prev = elm;
ffffffffc0200a26:	0ebd3823          	sd	a1,240(s10)
ffffffffc0200a2a:	0ebd3c23          	sd	a1,248(s10)
    elm->next = next;
ffffffffc0200a2e:	03ba3023          	sd	s11,32(s4)
    elm->prev = prev;
ffffffffc0200a32:	01ba3c23          	sd	s11,24(s4)
                cprintf("now_page_before: %p\n", now_page);
ffffffffc0200a36:	85d2                	mv	a1,s4
ffffffffc0200a38:	8566                	mv	a0,s9
ffffffffc0200a3a:	e78ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                now_page += max_block_size; // 更新当前页指针
ffffffffc0200a3e:	67a9                	lui	a5,0xa
ffffffffc0200a40:	9a3e                	add	s4,s4,a5
                cprintf("now_page_after: %p\n", now_page);
ffffffffc0200a42:	85d2                	mv	a1,s4
ffffffffc0200a44:	8562                	mv	a0,s8
ffffffffc0200a46:	e6cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200a4a:	2485                	addiw	s1,s1,1
                cprintf("Size of struct Page: %u bytes\n", (unsigned int)sizeof(struct Page));
ffffffffc0200a4c:	02800593          	li	a1,40
ffffffffc0200a50:	855e                	mv	a0,s7
ffffffffc0200a52:	e60ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200a56:	0734d063          	bge	s1,s3,ffffffffc0200ab6 <buddy_system_pmm_init_memmap+0x256>
                now_page->property = max_block_size; // 每个块的页数
ffffffffc0200a5a:	016a2823          	sw	s6,16(s4)
ffffffffc0200a5e:	008a0793          	addi	a5,s4,8
ffffffffc0200a62:	4157b02f          	amoor.d	zero,s5,(a5)
                buddy_zone.free_area[MAX_ORDER - 1].nr_free += max_block_size; // 更新 free_area 中的块数
ffffffffc0200a66:	100d2683          	lw	a3,256(s10)
    return list->next == list;
ffffffffc0200a6a:	0f8d3783          	ld	a5,248(s10)
ffffffffc0200a6e:	018a0593          	addi	a1,s4,24
ffffffffc0200a72:	4006869b          	addiw	a3,a3,1024
ffffffffc0200a76:	10dd2023          	sw	a3,256(s10)
                if (list_empty(free_list_order)) {
ffffffffc0200a7a:	fbb786e3          	beq	a5,s11,ffffffffc0200a26 <buddy_system_pmm_init_memmap+0x1c6>
                        struct Page *page = le2page(le, page_link);
ffffffffc0200a7e:	fe878693          	addi	a3,a5,-24 # 9fe8 <kern_entry-0xffffffffc01f6018>
                        if (now_page < page) {
ffffffffc0200a82:	00da6a63          	bltu	s4,a3,ffffffffc0200a96 <buddy_system_pmm_init_memmap+0x236>
    return listelm->next;
ffffffffc0200a86:	6794                	ld	a3,8(a5)
                        } else if (list_next(le) == free_list_order) {
ffffffffc0200a88:	01b68f63          	beq	a3,s11,ffffffffc0200aa6 <buddy_system_pmm_init_memmap+0x246>
ffffffffc0200a8c:	87b6                	mv	a5,a3
                        struct Page *page = le2page(le, page_link);
ffffffffc0200a8e:	fe878693          	addi	a3,a5,-24
                        if (now_page < page) {
ffffffffc0200a92:	feda7ae3          	bgeu	s4,a3,ffffffffc0200a86 <buddy_system_pmm_init_memmap+0x226>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200a96:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200a98:	e38c                	sd	a1,0(a5)
ffffffffc0200a9a:	e68c                	sd	a1,8(a3)
    elm->next = next;
ffffffffc0200a9c:	02fa3023          	sd	a5,32(s4)
    elm->prev = prev;
ffffffffc0200aa0:	00da3c23          	sd	a3,24(s4)
}
ffffffffc0200aa4:	bf49                	j	ffffffffc0200a36 <buddy_system_pmm_init_memmap+0x1d6>
    prev->next = next->prev = elm;
ffffffffc0200aa6:	0ebd3823          	sd	a1,240(s10)
ffffffffc0200aaa:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200aac:	03ba3023          	sd	s11,32(s4)
    elm->prev = prev;
ffffffffc0200ab0:	00fa3c23          	sd	a5,24(s4)
}
ffffffffc0200ab4:	b749                	j	ffffffffc0200a36 <buddy_system_pmm_init_memmap+0x1d6>
                now_page += max_block_size; // 更新当前页指针
ffffffffc0200ab6:	3ff00713          	li	a4,1023
ffffffffc0200aba:	67a9                	lui	a5,0xa
ffffffffc0200abc:	00875b63          	bge	a4,s0,ffffffffc0200ad2 <buddy_system_pmm_init_memmap+0x272>
ffffffffc0200ac0:	47b2                	lw	a5,12(sp)
ffffffffc0200ac2:	37fd                	addiw	a5,a5,-1
ffffffffc0200ac4:	1782                	slli	a5,a5,0x20
ffffffffc0200ac6:	9381                	srli	a5,a5,0x20
ffffffffc0200ac8:	0785                	addi	a5,a5,1
ffffffffc0200aca:	00279713          	slli	a4,a5,0x2
ffffffffc0200ace:	97ba                	add	a5,a5,a4
ffffffffc0200ad0:	07b6                	slli	a5,a5,0xd
ffffffffc0200ad2:	993e                	add	s2,s2,a5
            n_now -= num_blocks * max_block_size; // 更新剩余页数
ffffffffc0200ad4:	47a2                	lw	a5,8(sp)
ffffffffc0200ad6:	0167d79b          	srliw	a5,a5,0x16
ffffffffc0200ada:	9c3d                	addw	s0,s0,a5
ffffffffc0200adc:	3ff47413          	andi	s0,s0,1023
ffffffffc0200ae0:	9c1d                	subw	s0,s0,a5
    while (n_now != 0) {
ffffffffc0200ae2:	e0041ce3          	bnez	s0,ffffffffc02008fa <buddy_system_pmm_init_memmap+0x9a>
ffffffffc0200ae6:	b5e9                	j	ffffffffc02009b0 <buddy_system_pmm_init_memmap+0x150>
        cprintf("n_now: %d\n", n_now);  // 打印 n_now 的值
ffffffffc0200ae8:	85a2                	mv	a1,s0
ffffffffc0200aea:	00001517          	auipc	a0,0x1
ffffffffc0200aee:	7b650513          	addi	a0,a0,1974 # ffffffffc02022a0 <commands+0x5b8>
ffffffffc0200af2:	dc0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    while (n >> 1)
ffffffffc0200af6:	8b22                	mv	s6,s0
ffffffffc0200af8:	00145793          	srli	a5,s0,0x1
ffffffffc0200afc:	89a2                	mv	s3,s0
ffffffffc0200afe:	bd3d                	j	ffffffffc020093c <buddy_system_pmm_init_memmap+0xdc>
        cprintf("n_now: %d\n", n_now);  // 打印 n_now 的值
ffffffffc0200b00:	4585                	li	a1,1
ffffffffc0200b02:	00001517          	auipc	a0,0x1
ffffffffc0200b06:	79e50513          	addi	a0,a0,1950 # ffffffffc02022a0 <commands+0x5b8>
ffffffffc0200b0a:	da8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200b0e:	4a05                	li	s4,1
ffffffffc0200b10:	02800a93          	li	s5,40
        int n_temp = getdown2(n_now);
ffffffffc0200b14:	4985                	li	s3,1
        cprintf("order: %d\n", order);  // 打印 order 的值
ffffffffc0200b16:	4581                	li	a1,0
ffffffffc0200b18:	00001517          	auipc	a0,0x1
ffffffffc0200b1c:	79850513          	addi	a0,a0,1944 # ffffffffc02022b0 <commands+0x5c8>
ffffffffc0200b20:	d92ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        int order = getorder(n_temp);
ffffffffc0200b24:	4481                	li	s1,0
        cprintf("order: %d\n", order);  // 打印 order 的值
ffffffffc0200b26:	86ea                	mv	a3,s10
ffffffffc0200b28:	4781                	li	a5,0
ffffffffc0200b2a:	b5a1                	j	ffffffffc0200972 <buddy_system_pmm_init_memmap+0x112>
    prev->next = next->prev = elm;
ffffffffc0200b2c:	e28c                	sd	a1,0(a3)
ffffffffc0200b2e:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200b30:	02d93023          	sd	a3,32(s2)
    elm->prev = prev;
ffffffffc0200b34:	00f93c23          	sd	a5,24(s2)
    while (n_now != 0) {
ffffffffc0200b38:	dc0411e3          	bnez	s0,ffffffffc02008fa <buddy_system_pmm_init_memmap+0x9a>
ffffffffc0200b3c:	bd95                	j	ffffffffc02009b0 <buddy_system_pmm_init_memmap+0x150>
        assert(PageReserved(p));
ffffffffc0200b3e:	00001697          	auipc	a3,0x1
ffffffffc0200b42:	73268693          	addi	a3,a3,1842 # ffffffffc0202270 <commands+0x588>
ffffffffc0200b46:	00001617          	auipc	a2,0x1
ffffffffc0200b4a:	6da60613          	addi	a2,a2,1754 # ffffffffc0202220 <commands+0x538>
ffffffffc0200b4e:	09600593          	li	a1,150
ffffffffc0200b52:	00001517          	auipc	a0,0x1
ffffffffc0200b56:	6e650513          	addi	a0,a0,1766 # ffffffffc0202238 <commands+0x550>
ffffffffc0200b5a:	853ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200b5e:	00001697          	auipc	a3,0x1
ffffffffc0200b62:	6ba68693          	addi	a3,a3,1722 # ffffffffc0202218 <commands+0x530>
ffffffffc0200b66:	00001617          	auipc	a2,0x1
ffffffffc0200b6a:	6ba60613          	addi	a2,a2,1722 # ffffffffc0202220 <commands+0x538>
ffffffffc0200b6e:	09200593          	li	a1,146
ffffffffc0200b72:	00001517          	auipc	a0,0x1
ffffffffc0200b76:	6c650513          	addi	a0,a0,1734 # ffffffffc0202238 <commands+0x550>
ffffffffc0200b7a:	833ff0ef          	jal	ra,ffffffffc02003ac <__panic>
            now_page += n_temp; // 更新当前页指针
ffffffffc0200b7e:	02800a93          	li	s5,40
ffffffffc0200b82:	03598ab3          	mul	s5,s3,s5
            now_page->property = n_temp;
ffffffffc0200b86:	8a4e                	mv	s4,s3
ffffffffc0200b88:	b779                	j	ffffffffc0200b16 <buddy_system_pmm_init_memmap+0x2b6>

ffffffffc0200b8a <buddy_system_pmm_free_pages>:
static void buddy_system_pmm_free_pages(struct Page *base, size_t n) {
ffffffffc0200b8a:	7175                	addi	sp,sp,-144
ffffffffc0200b8c:	e506                	sd	ra,136(sp)
ffffffffc0200b8e:	e122                	sd	s0,128(sp)
ffffffffc0200b90:	fca6                	sd	s1,120(sp)
ffffffffc0200b92:	f8ca                	sd	s2,112(sp)
ffffffffc0200b94:	f4ce                	sd	s3,104(sp)
ffffffffc0200b96:	f0d2                	sd	s4,96(sp)
ffffffffc0200b98:	ecd6                	sd	s5,88(sp)
ffffffffc0200b9a:	e8da                	sd	s6,80(sp)
ffffffffc0200b9c:	e4de                	sd	s7,72(sp)
ffffffffc0200b9e:	e0e2                	sd	s8,64(sp)
ffffffffc0200ba0:	fc66                	sd	s9,56(sp)
ffffffffc0200ba2:	f86a                	sd	s10,48(sp)
ffffffffc0200ba4:	f46e                	sd	s11,40(sp)
    assert(n > 0);
ffffffffc0200ba6:	22058663          	beqz	a1,ffffffffc0200dd2 <buddy_system_pmm_free_pages+0x248>
    if(n==1)
ffffffffc0200baa:	4785                	li	a5,1
ffffffffc0200bac:	8daa                	mv	s11,a0
ffffffffc0200bae:	20f58063          	beq	a1,a5,ffffffffc0200dae <buddy_system_pmm_free_pages+0x224>
    if (n & (n - 1)) return 0;
ffffffffc0200bb2:	fff58793          	addi	a5,a1,-1
ffffffffc0200bb6:	8fed                	and	a5,a5,a1
ffffffffc0200bb8:	12078b63          	beqz	a5,ffffffffc0200cee <buddy_system_pmm_free_pages+0x164>
    size_t res = 1;
ffffffffc0200bbc:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200bbe:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200bc0:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200bc2:	fdf5                	bnez	a1,ffffffffc0200bbe <buddy_system_pmm_free_pages+0x34>
    while (n >> 1)
ffffffffc0200bc4:	86be                	mv	a3,a5
ffffffffc0200bc6:	8385                	srli	a5,a5,0x1
ffffffffc0200bc8:	20068163          	beqz	a3,ffffffffc0200dca <buddy_system_pmm_free_pages+0x240>
    size_t res = 1;
ffffffffc0200bcc:	4481                	li	s1,0
    while (n >> 1)
ffffffffc0200bce:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200bd0:	2485                	addiw	s1,s1,1
    while (n >> 1)
ffffffffc0200bd2:	fff5                	bnez	a5,ffffffffc0200bce <buddy_system_pmm_free_pages+0x44>
    list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200bd4:	00149993          	slli	s3,s1,0x1
ffffffffc0200bd8:	99a6                	add	s3,s3,s1
    p->property = 1 << order;
ffffffffc0200bda:	4785                	li	a5,1
    list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200bdc:	00005717          	auipc	a4,0x5
ffffffffc0200be0:	43470713          	addi	a4,a4,1076 # ffffffffc0206010 <buddy_zone>
    p->property = 1 << order;
ffffffffc0200be4:	009797bb          	sllw	a5,a5,s1
    list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200be8:	098e                	slli	s3,s3,0x3
ffffffffc0200bea:	e43a                	sd	a4,8(sp)
ffffffffc0200bec:	99ba                	add	s3,s3,a4
    p->property = 1 << order;
ffffffffc0200bee:	00fda823          	sw	a5,16(s11)
    int order = getorder(getup2(n));
ffffffffc0200bf2:	2481                	sext.w	s1,s1
ffffffffc0200bf4:	4789                	li	a5,2
ffffffffc0200bf6:	008d8713          	addi	a4,s11,8
ffffffffc0200bfa:	40f7302f          	amoor.d	zero,a5,(a4)
    while (order < MAX_ORDER - 1) { // 修正为最大 order - 1
ffffffffc0200bfe:	47a5                	li	a5,9
ffffffffc0200c00:	1497ce63          	blt	a5,s1,ffffffffc0200d5c <buddy_system_pmm_free_pages+0x1d2>
ffffffffc0200c04:	0014879b          	addiw	a5,s1,1
ffffffffc0200c08:	00179c93          	slli	s9,a5,0x1
ffffffffc0200c0c:	9cbe                	add	s9,s9,a5
ffffffffc0200c0e:	67a2                	ld	a5,8(sp)
ffffffffc0200c10:	0c8e                	slli	s9,s9,0x3
            cprintf("first页: %p\n", (uintptr_t)p);
ffffffffc0200c12:	00001c17          	auipc	s8,0x1
ffffffffc0200c16:	706c0c13          	addi	s8,s8,1798 # ffffffffc0202318 <commands+0x630>
ffffffffc0200c1a:	97e6                	add	a5,a5,s9
ffffffffc0200c1c:	e83e                	sd	a5,16(sp)
            cprintf("second页: %p\n", (uintptr_t)current_page);
ffffffffc0200c1e:	00001b97          	auipc	s7,0x1
ffffffffc0200c22:	70ab8b93          	addi	s7,s7,1802 # ffffffffc0202328 <commands+0x640>
            cprintf("p 和 current_page 之间的差值 (16进制): %lx\n", (uintptr_t)p - (uintptr_t)current_page);
ffffffffc0200c26:	00001b17          	auipc	s6,0x1
ffffffffc0200c2a:	712b0b13          	addi	s6,s6,1810 # ffffffffc0202338 <commands+0x650>
            cprintf("page_size (16进制): %lx\n", page_size);
ffffffffc0200c2e:	00001a97          	auipc	s5,0x1
ffffffffc0200c32:	742a8a93          	addi	s5,s5,1858 # ffffffffc0202370 <commands+0x688>
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200c36:	4785                	li	a5,1
    return list->next == list;
ffffffffc0200c38:	0089bc83          	ld	s9,8(s3)
ffffffffc0200c3c:	00979d3b          	sllw	s10,a5,s1
ffffffffc0200c40:	ce6a                	sw	s10,28(sp)
        if (list_empty(free_list_order)) {
ffffffffc0200c42:	053c8a63          	beq	s9,s3,ffffffffc0200c96 <buddy_system_pmm_free_pages+0x10c>
            if ((uintptr_t)current_page == (uintptr_t)p + page_size * block_size) {
ffffffffc0200c46:	002d1913          	slli	s2,s10,0x2
ffffffffc0200c4a:	996a                	add	s2,s2,s10
ffffffffc0200c4c:	090e                	slli	s2,s2,0x3
ffffffffc0200c4e:	012d8a33          	add	s4,s11,s2
ffffffffc0200c52:	a011                	j	ffffffffc0200c56 <buddy_system_pmm_free_pages+0xcc>
ffffffffc0200c54:	8cb6                	mv	s9,a3
            cprintf("first页: %p\n", (uintptr_t)p);
ffffffffc0200c56:	85ee                	mv	a1,s11
ffffffffc0200c58:	8562                	mv	a0,s8
            struct Page *current_page = le2page(le, page_link);
ffffffffc0200c5a:	fe8c8413          	addi	s0,s9,-24
            cprintf("first页: %p\n", (uintptr_t)p);
ffffffffc0200c5e:	c54ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("second页: %p\n", (uintptr_t)current_page);
ffffffffc0200c62:	85a2                	mv	a1,s0
ffffffffc0200c64:	855e                	mv	a0,s7
ffffffffc0200c66:	c4cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("p 和 current_page 之间的差值 (16进制): %lx\n", (uintptr_t)p - (uintptr_t)current_page);
ffffffffc0200c6a:	408d85b3          	sub	a1,s11,s0
ffffffffc0200c6e:	855a                	mv	a0,s6
ffffffffc0200c70:	c42ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("page_size (16进制): %lx\n", page_size);
ffffffffc0200c74:	02800593          	li	a1,40
ffffffffc0200c78:	8556                	mv	a0,s5
ffffffffc0200c7a:	c38ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            if ((uintptr_t)current_page == (uintptr_t)p + page_size * block_size) {
ffffffffc0200c7e:	07440b63          	beq	s0,s4,ffffffffc0200cf4 <buddy_system_pmm_free_pages+0x16a>
            } else if ((uintptr_t)p == (uintptr_t)current_page + block_size * page_size) {
ffffffffc0200c82:	012406b3          	add	a3,s0,s2
ffffffffc0200c86:	0edd8a63          	beq	s11,a3,ffffffffc0200d7a <buddy_system_pmm_free_pages+0x1f0>
    return listelm->next;
ffffffffc0200c8a:	008cb683          	ld	a3,8(s9)
            if(le==list_next(le))
ffffffffc0200c8e:	01968463          	beq	a3,s9,ffffffffc0200c96 <buddy_system_pmm_free_pages+0x10c>
        for (le = list_next(free_list_order); le != free_list_order; le = list_next(le)) {
ffffffffc0200c92:	fd3691e3          	bne	a3,s3,ffffffffc0200c54 <buddy_system_pmm_free_pages+0xca>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c96:	6422                	ld	s0,8(sp)
ffffffffc0200c98:	00149793          	slli	a5,s1,0x1
ffffffffc0200c9c:	97a6                	add	a5,a5,s1
ffffffffc0200c9e:	078e                	slli	a5,a5,0x3
ffffffffc0200ca0:	97a2                	add	a5,a5,s0
ffffffffc0200ca2:	678c                	ld	a1,8(a5)
            buddy_zone.n_sum += (1 << order);
ffffffffc0200ca4:	10843683          	ld	a3,264(s0)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200ca8:	4b90                	lw	a2,16(a5)
            list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
ffffffffc0200caa:	018d8513          	addi	a0,s11,24
    prev->next = next->prev = elm;
ffffffffc0200cae:	e188                	sd	a0,0(a1)
ffffffffc0200cb0:	e788                	sd	a0,8(a5)
    elm->next = next;
ffffffffc0200cb2:	02bdb023          	sd	a1,32(s11)
    elm->prev = prev;
ffffffffc0200cb6:	00fdbc23          	sd	a5,24(s11)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200cba:	01a6073b          	addw	a4,a2,s10
            buddy_zone.n_sum += (1 << order);
ffffffffc0200cbe:	9d36                	add	s10,s10,a3
ffffffffc0200cc0:	11a43423          	sd	s10,264(s0)
}
ffffffffc0200cc4:	640a                	ld	s0,128(sp)
ffffffffc0200cc6:	60aa                	ld	ra,136(sp)
ffffffffc0200cc8:	74e6                	ld	s1,120(sp)
ffffffffc0200cca:	7946                	ld	s2,112(sp)
ffffffffc0200ccc:	79a6                	ld	s3,104(sp)
ffffffffc0200cce:	7a06                	ld	s4,96(sp)
ffffffffc0200cd0:	6ae6                	ld	s5,88(sp)
ffffffffc0200cd2:	6b46                	ld	s6,80(sp)
ffffffffc0200cd4:	6ba6                	ld	s7,72(sp)
ffffffffc0200cd6:	6c06                	ld	s8,64(sp)
ffffffffc0200cd8:	7ce2                	ld	s9,56(sp)
ffffffffc0200cda:	7d42                	ld	s10,48(sp)
ffffffffc0200cdc:	7da2                	ld	s11,40(sp)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200cde:	cb98                	sw	a4,16(a5)
            cprintf("return\n");
ffffffffc0200ce0:	00001517          	auipc	a0,0x1
ffffffffc0200ce4:	63050513          	addi	a0,a0,1584 # ffffffffc0202310 <commands+0x628>
}
ffffffffc0200ce8:	6149                	addi	sp,sp,144
            cprintf("return\n");
ffffffffc0200cea:	bc8ff06f          	j	ffffffffc02000b2 <cprintf>
    while (n >> 1)
ffffffffc0200cee:	0015d793          	srli	a5,a1,0x1
ffffffffc0200cf2:	bde9                	j	ffffffffc0200bcc <buddy_system_pmm_free_pages+0x42>
                p->property += current_page->property;
ffffffffc0200cf4:	010da683          	lw	a3,16(s11)
ffffffffc0200cf8:	ff8ca603          	lw	a2,-8(s9)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200cfc:	ff0c8793          	addi	a5,s9,-16
ffffffffc0200d00:	5775                	li	a4,-3
ffffffffc0200d02:	9eb1                	addw	a3,a3,a2
ffffffffc0200d04:	00dda823          	sw	a3,16(s11)
ffffffffc0200d08:	60e7b02f          	amoand.d	zero,a4,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d0c:	000cb683          	ld	a3,0(s9)
ffffffffc0200d10:	008cb783          	ld	a5,8(s9)
                cprintf("merge\n");
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	67c50513          	addi	a0,a0,1660 # ffffffffc0202390 <commands+0x6a8>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d1c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200d1e:	e394                	sd	a3,0(a5)
ffffffffc0200d20:	b92ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        buddy_zone.free_area[order].nr_free -= (1 << order);
ffffffffc0200d24:	6442                	ld	s0,16(sp)
        buddy_zone.n_sum -= (1 << order);
ffffffffc0200d26:	6622                	ld	a2,8(sp)
        buddy_zone.free_area[order].nr_free -= (1 << order);
ffffffffc0200d28:	45f2                	lw	a1,28(sp)
ffffffffc0200d2a:	ff842683          	lw	a3,-8(s0)
        buddy_zone.n_sum -= (1 << order);
ffffffffc0200d2e:	10863783          	ld	a5,264(a2)
        cprintf("jixu\n");
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	66650513          	addi	a0,a0,1638 # ffffffffc0202398 <commands+0x6b0>
        buddy_zone.free_area[order].nr_free -= (1 << order);
ffffffffc0200d3a:	9e8d                	subw	a3,a3,a1
        buddy_zone.n_sum -= (1 << order);
ffffffffc0200d3c:	41a78d33          	sub	s10,a5,s10
        buddy_zone.free_area[order].nr_free -= (1 << order);
ffffffffc0200d40:	fed42c23          	sw	a3,-8(s0)
        buddy_zone.n_sum -= (1 << order);
ffffffffc0200d44:	11a63423          	sd	s10,264(a2)
        cprintf("jixu\n");
ffffffffc0200d48:	b6aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    while (order < MAX_ORDER - 1) { // 修正为最大 order - 1
ffffffffc0200d4c:	01840713          	addi	a4,s0,24
        order++;
ffffffffc0200d50:	2485                	addiw	s1,s1,1
    while (order < MAX_ORDER - 1) { // 修正为最大 order - 1
ffffffffc0200d52:	47a9                	li	a5,10
ffffffffc0200d54:	e83a                	sd	a4,16(sp)
ffffffffc0200d56:	89a2                	mv	s3,s0
ffffffffc0200d58:	ecf49fe3          	bne	s1,a5,ffffffffc0200c36 <buddy_system_pmm_free_pages+0xac>
}
ffffffffc0200d5c:	60aa                	ld	ra,136(sp)
ffffffffc0200d5e:	640a                	ld	s0,128(sp)
ffffffffc0200d60:	74e6                	ld	s1,120(sp)
ffffffffc0200d62:	7946                	ld	s2,112(sp)
ffffffffc0200d64:	79a6                	ld	s3,104(sp)
ffffffffc0200d66:	7a06                	ld	s4,96(sp)
ffffffffc0200d68:	6ae6                	ld	s5,88(sp)
ffffffffc0200d6a:	6b46                	ld	s6,80(sp)
ffffffffc0200d6c:	6ba6                	ld	s7,72(sp)
ffffffffc0200d6e:	6c06                	ld	s8,64(sp)
ffffffffc0200d70:	7ce2                	ld	s9,56(sp)
ffffffffc0200d72:	7d42                	ld	s10,48(sp)
ffffffffc0200d74:	7da2                	ld	s11,40(sp)
ffffffffc0200d76:	6149                	addi	sp,sp,144
ffffffffc0200d78:	8082                	ret
                current_page->property += p->property;
ffffffffc0200d7a:	ff8ca683          	lw	a3,-8(s9)
ffffffffc0200d7e:	010da603          	lw	a2,16(s11)
ffffffffc0200d82:	008d8793          	addi	a5,s11,8
ffffffffc0200d86:	5775                	li	a4,-3
ffffffffc0200d88:	9eb1                	addw	a3,a3,a2
ffffffffc0200d8a:	fedcac23          	sw	a3,-8(s9)
ffffffffc0200d8e:	60e7b02f          	amoand.d	zero,a4,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d92:	018db683          	ld	a3,24(s11)
ffffffffc0200d96:	020db783          	ld	a5,32(s11)
                cprintf("merge\n");
ffffffffc0200d9a:	00001517          	auipc	a0,0x1
ffffffffc0200d9e:	5f650513          	addi	a0,a0,1526 # ffffffffc0202390 <commands+0x6a8>
            struct Page *current_page = le2page(le, page_link);
ffffffffc0200da2:	8da2                	mv	s11,s0
    prev->next = next;
ffffffffc0200da4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200da6:	e394                	sd	a3,0(a5)
                cprintf("merge\n");
ffffffffc0200da8:	b0aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        if (!merged) {
ffffffffc0200dac:	bfa5                	j	ffffffffc0200d24 <buddy_system_pmm_free_pages+0x19a>
    p->property = 1 << order;
ffffffffc0200dae:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200db0:	4789                	li	a5,2
ffffffffc0200db2:	008d8713          	addi	a4,s11,8
ffffffffc0200db6:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0200dba:	00005797          	auipc	a5,0x5
ffffffffc0200dbe:	25678793          	addi	a5,a5,598 # ffffffffc0206010 <buddy_zone>
ffffffffc0200dc2:	e43e                	sd	a5,8(sp)
ffffffffc0200dc4:	4481                	li	s1,0
ffffffffc0200dc6:	89be                	mv	s3,a5
ffffffffc0200dc8:	bd35                	j	ffffffffc0200c04 <buddy_system_pmm_free_pages+0x7a>
ffffffffc0200dca:	4785                	li	a5,1
ffffffffc0200dcc:	00fda823          	sw	a5,16(s11)
ffffffffc0200dd0:	b7c5                	j	ffffffffc0200db0 <buddy_system_pmm_free_pages+0x226>
    assert(n > 0);
ffffffffc0200dd2:	00001697          	auipc	a3,0x1
ffffffffc0200dd6:	44668693          	addi	a3,a3,1094 # ffffffffc0202218 <commands+0x530>
ffffffffc0200dda:	00001617          	auipc	a2,0x1
ffffffffc0200dde:	44660613          	addi	a2,a2,1094 # ffffffffc0202220 <commands+0x538>
ffffffffc0200de2:	12400593          	li	a1,292
ffffffffc0200de6:	00001517          	auipc	a0,0x1
ffffffffc0200dea:	45250513          	addi	a0,a0,1106 # ffffffffc0202238 <commands+0x550>
ffffffffc0200dee:	dbeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200df2 <buddy_system_pmm_alloc_pages>:
static struct Page * buddy_system_pmm_alloc_pages(size_t n) {
ffffffffc0200df2:	715d                	addi	sp,sp,-80
ffffffffc0200df4:	e486                	sd	ra,72(sp)
ffffffffc0200df6:	e0a2                	sd	s0,64(sp)
ffffffffc0200df8:	fc26                	sd	s1,56(sp)
ffffffffc0200dfa:	f84a                	sd	s2,48(sp)
ffffffffc0200dfc:	f44e                	sd	s3,40(sp)
ffffffffc0200dfe:	f052                	sd	s4,32(sp)
ffffffffc0200e00:	ec56                	sd	s5,24(sp)
ffffffffc0200e02:	e85a                	sd	s6,16(sp)
ffffffffc0200e04:	e45e                	sd	s7,8(sp)
    assert(n > 0);
ffffffffc0200e06:	16050363          	beqz	a0,ffffffffc0200f6c <buddy_system_pmm_alloc_pages+0x17a>
    if (n > buddy_zone.n_sum) {
ffffffffc0200e0a:	00005997          	auipc	s3,0x5
ffffffffc0200e0e:	20698993          	addi	s3,s3,518 # ffffffffc0206010 <buddy_zone>
ffffffffc0200e12:	1089b783          	ld	a5,264(s3)
        return NULL;
ffffffffc0200e16:	4401                	li	s0,0
    if (n > buddy_zone.n_sum) {
ffffffffc0200e18:	06a7e463          	bltu	a5,a0,ffffffffc0200e80 <buddy_system_pmm_alloc_pages+0x8e>
    if(n==1)
ffffffffc0200e1c:	4785                	li	a5,1
ffffffffc0200e1e:	08f50063          	beq	a0,a5,ffffffffc0200e9e <buddy_system_pmm_alloc_pages+0xac>
    if (n & (n - 1)) return 0;
ffffffffc0200e22:	fff50793          	addi	a5,a0,-1
ffffffffc0200e26:	8fe9                	and	a5,a5,a0
ffffffffc0200e28:	cba5                	beqz	a5,ffffffffc0200e98 <buddy_system_pmm_alloc_pages+0xa6>
    size_t res = 1;
ffffffffc0200e2a:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200e2c:	8105                	srli	a0,a0,0x1
            res = res << 1;
ffffffffc0200e2e:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200e30:	fd75                	bnez	a0,ffffffffc0200e2c <buddy_system_pmm_alloc_pages+0x3a>
    while (n >> 1)
ffffffffc0200e32:	873e                	mv	a4,a5
ffffffffc0200e34:	8385                	srli	a5,a5,0x1
ffffffffc0200e36:	c725                	beqz	a4,ffffffffc0200e9e <buddy_system_pmm_alloc_pages+0xac>
    size_t res = 1;
ffffffffc0200e38:	4701                	li	a4,0
    while (n >> 1)
ffffffffc0200e3a:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200e3c:	2705                	addiw	a4,a4,1
    while (n >> 1)
ffffffffc0200e3e:	fff5                	bnez	a5,ffffffffc0200e3a <buddy_system_pmm_alloc_pages+0x48>
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc0200e40:	47ad                	li	a5,11
    int order_needed = getorder(getup2(n)); // 找到需要的最小阶层
ffffffffc0200e42:	00070b9b          	sext.w	s7,a4
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc0200e46:	02e7c663          	blt	a5,a4,ffffffffc0200e72 <buddy_system_pmm_alloc_pages+0x80>
        if (buddy_zone.free_area[order].nr_free / (1 << order) > 0) {
ffffffffc0200e4a:	001b9793          	slli	a5,s7,0x1
ffffffffc0200e4e:	97de                	add	a5,a5,s7
ffffffffc0200e50:	078e                	slli	a5,a5,0x3
ffffffffc0200e52:	97ce                	add	a5,a5,s3
ffffffffc0200e54:	4b98                	lw	a4,16(a5)
ffffffffc0200e56:	845e                	mv	s0,s7
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc0200e58:	46b1                	li	a3,12
        if (buddy_zone.free_area[order].nr_free / (1 << order) > 0) {
ffffffffc0200e5a:	0177573b          	srlw	a4,a4,s7
ffffffffc0200e5e:	c719                	beqz	a4,ffffffffc0200e6c <buddy_system_pmm_alloc_pages+0x7a>
ffffffffc0200e60:	a089                	j	ffffffffc0200ea2 <buddy_system_pmm_alloc_pages+0xb0>
ffffffffc0200e62:	5798                	lw	a4,40(a5)
ffffffffc0200e64:	07e1                	addi	a5,a5,24
ffffffffc0200e66:	0087573b          	srlw	a4,a4,s0
ffffffffc0200e6a:	ef05                	bnez	a4,ffffffffc0200ea2 <buddy_system_pmm_alloc_pages+0xb0>
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc0200e6c:	2405                	addiw	s0,s0,1
ffffffffc0200e6e:	fed41ae3          	bne	s0,a3,ffffffffc0200e62 <buddy_system_pmm_alloc_pages+0x70>
    cprintf("6666666666666666666666666\n");
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	57650513          	addi	a0,a0,1398 # ffffffffc02023e8 <commands+0x700>
ffffffffc0200e7a:	a38ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return NULL; // 如果没有合适的块
ffffffffc0200e7e:	4401                	li	s0,0
}
ffffffffc0200e80:	60a6                	ld	ra,72(sp)
ffffffffc0200e82:	8522                	mv	a0,s0
ffffffffc0200e84:	6406                	ld	s0,64(sp)
ffffffffc0200e86:	74e2                	ld	s1,56(sp)
ffffffffc0200e88:	7942                	ld	s2,48(sp)
ffffffffc0200e8a:	79a2                	ld	s3,40(sp)
ffffffffc0200e8c:	7a02                	ld	s4,32(sp)
ffffffffc0200e8e:	6ae2                	ld	s5,24(sp)
ffffffffc0200e90:	6b42                	ld	s6,16(sp)
ffffffffc0200e92:	6ba2                	ld	s7,8(sp)
ffffffffc0200e94:	6161                	addi	sp,sp,80
ffffffffc0200e96:	8082                	ret
    while (n >> 1)
ffffffffc0200e98:	00155793          	srli	a5,a0,0x1
ffffffffc0200e9c:	bf71                	j	ffffffffc0200e38 <buddy_system_pmm_alloc_pages+0x46>
    int order_needed = getorder(getup2(n)); // 找到需要的最小阶层
ffffffffc0200e9e:	4b81                	li	s7,0
ffffffffc0200ea0:	b76d                	j	ffffffffc0200e4a <buddy_system_pmm_alloc_pages+0x58>
    return listelm->next;
ffffffffc0200ea2:	00141913          	slli	s2,s0,0x1
ffffffffc0200ea6:	9922                	add	s2,s2,s0
ffffffffc0200ea8:	090e                	slli	s2,s2,0x3
ffffffffc0200eaa:	01298b33          	add	s6,s3,s2
ffffffffc0200eae:	008b3a83          	ld	s5,8(s6)
            cprintf("删除的页: %p\n", p);
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	4ee50513          	addi	a0,a0,1262 # ffffffffc02023a0 <commands+0x6b8>
            buddy_zone.free_area[order].nr_free-=(1<<order);
ffffffffc0200eba:	4a05                	li	s4,1
            struct Page *p = le2page(le, page_link);
ffffffffc0200ebc:	fe8a8493          	addi	s1,s5,-24
            cprintf("删除的页: %p\n", p);
ffffffffc0200ec0:	85a6                	mv	a1,s1
ffffffffc0200ec2:	9f0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ec6:	008ab703          	ld	a4,8(s5)
ffffffffc0200eca:	000ab683          	ld	a3,0(s5)
            buddy_zone.free_area[order].nr_free-=(1<<order);
ffffffffc0200ece:	010b2783          	lw	a5,16(s6)
ffffffffc0200ed2:	008a163b          	sllw	a2,s4,s0
    prev->next = next;
ffffffffc0200ed6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200ed8:	e314                	sd	a3,0(a4)
ffffffffc0200eda:	9f91                	subw	a5,a5,a2
ffffffffc0200edc:	00fb2823          	sw	a5,16(s6)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ee0:	ff0a8713          	addi	a4,s5,-16
ffffffffc0200ee4:	57f5                	li	a5,-3
ffffffffc0200ee6:	60f7302f          	amoand.d	zero,a5,(a4)
            int n_more=(1<<order)-(1<<order_needed);
ffffffffc0200eea:	017a1a3b          	sllw	s4,s4,s7
            while (order > order_needed) {
ffffffffc0200eee:	048bdd63          	bge	s7,s0,ffffffffc0200f48 <buddy_system_pmm_alloc_pages+0x156>
ffffffffc0200ef2:	1921                	addi	s2,s2,-24
ffffffffc0200ef4:	994e                	add	s2,s2,s3
                cprintf("多余的页: %p\n", buddy);
ffffffffc0200ef6:	00001b17          	auipc	s6,0x1
ffffffffc0200efa:	4c2b0b13          	addi	s6,s6,1218 # ffffffffc02023b8 <commands+0x6d0>
                buddy->property = 1 << order;
ffffffffc0200efe:	4a85                	li	s5,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f00:	4989                	li	s3,2
                cprintf("多余的页: %p\n", buddy);
ffffffffc0200f02:	85a6                	mv	a1,s1
ffffffffc0200f04:	855a                	mv	a0,s6
ffffffffc0200f06:	9acff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                order--;
ffffffffc0200f0a:	347d                	addiw	s0,s0,-1
                buddy->property = 1 << order;
ffffffffc0200f0c:	008a963b          	sllw	a2,s5,s0
ffffffffc0200f10:	c890                	sw	a2,16(s1)
ffffffffc0200f12:	00848793          	addi	a5,s1,8
ffffffffc0200f16:	4137b02f          	amoor.d	zero,s3,(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f1a:	00893583          	ld	a1,8(s2)
                buddy_zone.free_area[order].nr_free+=1<<order;
ffffffffc0200f1e:	01092703          	lw	a4,16(s2)
                list_add(&buddy_zone.free_area[order].free_list, &buddy->page_link);
ffffffffc0200f22:	01848793          	addi	a5,s1,24
    prev->next = next->prev = elm;
ffffffffc0200f26:	e19c                	sd	a5,0(a1)
ffffffffc0200f28:	00f93423          	sd	a5,8(s2)
                buddy += (1 << order);
ffffffffc0200f2c:	00261793          	slli	a5,a2,0x2
    elm->prev = prev;
ffffffffc0200f30:	0124bc23          	sd	s2,24(s1)
    elm->next = next;
ffffffffc0200f34:	f08c                	sd	a1,32(s1)
ffffffffc0200f36:	97b2                	add	a5,a5,a2
                buddy_zone.free_area[order].nr_free+=1<<order;
ffffffffc0200f38:	9f31                	addw	a4,a4,a2
                buddy += (1 << order);
ffffffffc0200f3a:	078e                	slli	a5,a5,0x3
                buddy_zone.free_area[order].nr_free+=1<<order;
ffffffffc0200f3c:	00e92823          	sw	a4,16(s2)
                buddy += (1 << order);
ffffffffc0200f40:	94be                	add	s1,s1,a5
            while (order > order_needed) {
ffffffffc0200f42:	1921                	addi	s2,s2,-24
ffffffffc0200f44:	fb741fe3          	bne	s0,s7,ffffffffc0200f02 <buddy_system_pmm_alloc_pages+0x110>
            p=buddy+(1<<order_needed);
ffffffffc0200f48:	002a1413          	slli	s0,s4,0x2
ffffffffc0200f4c:	9452                	add	s0,s0,s4
ffffffffc0200f4e:	040e                	slli	s0,s0,0x3
ffffffffc0200f50:	9426                	add	s0,s0,s1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200f52:	57f5                	li	a5,-3
ffffffffc0200f54:	00840713          	addi	a4,s0,8
ffffffffc0200f58:	60f7302f          	amoand.d	zero,a5,(a4)
            cprintf("分配的页: %p\n", buddy);
ffffffffc0200f5c:	00001517          	auipc	a0,0x1
ffffffffc0200f60:	47450513          	addi	a0,a0,1140 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200f64:	85a6                	mv	a1,s1
ffffffffc0200f66:	94cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            return p;
ffffffffc0200f6a:	bf19                	j	ffffffffc0200e80 <buddy_system_pmm_alloc_pages+0x8e>
    assert(n > 0);
ffffffffc0200f6c:	00001697          	auipc	a3,0x1
ffffffffc0200f70:	2ac68693          	addi	a3,a3,684 # ffffffffc0202218 <commands+0x530>
ffffffffc0200f74:	00001617          	auipc	a2,0x1
ffffffffc0200f78:	2ac60613          	addi	a2,a2,684 # ffffffffc0202220 <commands+0x538>
ffffffffc0200f7c:	0f200593          	li	a1,242
ffffffffc0200f80:	00001517          	auipc	a0,0x1
ffffffffc0200f84:	2b850513          	addi	a0,a0,696 # ffffffffc0202238 <commands+0x550>
ffffffffc0200f88:	c24ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f8c <buddy_check_0>:
static void buddy_check_0(void) {
ffffffffc0200f8c:	c8010113          	addi	sp,sp,-896

#define ALLOC_PAGE_NUM 100

    cprintf("[buddy_check_0] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
ffffffffc0200f90:	00001517          	auipc	a0,0x1
ffffffffc0200f94:	47850513          	addi	a0,a0,1144 # ffffffffc0202408 <commands+0x720>
static void buddy_check_0(void) {
ffffffffc0200f98:	36113c23          	sd	ra,888(sp)
ffffffffc0200f9c:	36813823          	sd	s0,880(sp)
ffffffffc0200fa0:	36913423          	sd	s1,872(sp)
ffffffffc0200fa4:	37213023          	sd	s2,864(sp)
ffffffffc0200fa8:	35313c23          	sd	s3,856(sp)
ffffffffc0200fac:	35613023          	sd	s6,832(sp)
ffffffffc0200fb0:	33713c23          	sd	s7,824(sp)
ffffffffc0200fb4:	35413823          	sd	s4,848(sp)
ffffffffc0200fb8:	35513423          	sd	s5,840(sp)
ffffffffc0200fbc:	33813823          	sd	s8,816(sp)
ffffffffc0200fc0:	33913423          	sd	s9,808(sp)
ffffffffc0200fc4:	33a13023          	sd	s10,800(sp)
    cprintf("[buddy_check_0] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
ffffffffc0200fc8:	8eaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    size_t initial_nr_free_pages = nr_free_pages();
ffffffffc0200fcc:	368000ef          	jal	ra,ffffffffc0201334 <nr_free_pages>
    cprintf("initial_nr_free_pages %d\n", initial_nr_free_pages);  // 打印 order 的值
ffffffffc0200fd0:	85aa                	mv	a1,a0
    size_t initial_nr_free_pages = nr_free_pages();
ffffffffc0200fd2:	8baa                	mv	s7,a0
    cprintf("initial_nr_free_pages %d\n", initial_nr_free_pages);  // 打印 order 的值
ffffffffc0200fd4:	00001517          	auipc	a0,0x1
ffffffffc0200fd8:	47c50513          	addi	a0,a0,1148 # ffffffffc0202450 <commands+0x768>
ffffffffc0200fdc:	8d6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[buddy_check_0] before alloc: ");
ffffffffc0200fe0:	00001517          	auipc	a0,0x1
ffffffffc0200fe4:	49050513          	addi	a0,a0,1168 # ffffffffc0202470 <commands+0x788>
ffffffffc0200fe8:	8caff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	4a450513          	addi	a0,a0,1188 # ffffffffc0202490 <commands+0x7a8>
ffffffffc0200ff4:	00005b17          	auipc	s6,0x5
ffffffffc0200ff8:	11cb0b13          	addi	s6,s6,284 # ffffffffc0206110 <buddy_zone+0x100>
ffffffffc0200ffc:	8b6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0201000:	84da                	mv	s1,s6
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201002:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201004:	00001997          	auipc	s3,0x1
ffffffffc0201008:	4a498993          	addi	s3,s3,1188 # ffffffffc02024a8 <commands+0x7c0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020100c:	597d                	li	s2,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020100e:	408c                	lw	a1,0(s1)
ffffffffc0201010:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201012:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201014:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201018:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020101a:	898ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020101e:	ff2418e3          	bne	s0,s2,ffffffffc020100e <buddy_check_0+0x82>
    cprintf("\n");
ffffffffc0201022:	00001517          	auipc	a0,0x1
ffffffffc0201026:	1d650513          	addi	a0,a0,470 # ffffffffc02021f8 <commands+0x510>
ffffffffc020102a:	888ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();


    cprintf("[buddy_check_0] trying to alloc %d * 1 pages\n", ALLOC_PAGE_NUM);
ffffffffc020102e:	06400593          	li	a1,100
ffffffffc0201032:	00001517          	auipc	a0,0x1
ffffffffc0201036:	47e50513          	addi	a0,a0,1150 # ffffffffc02024b0 <commands+0x7c8>
ffffffffc020103a:	8a0a                	mv	s4,sp
ffffffffc020103c:	876ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    struct Page *pages[ALLOC_PAGE_NUM];

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc0201040:	32010a93          	addi	s5,sp,800
    cprintf("[buddy_check_0] trying to alloc %d * 1 pages\n", ALLOC_PAGE_NUM);
ffffffffc0201044:	8452                	mv	s0,s4
        pages[i] = alloc_pages(1);
        assert(pages[i] != NULL);
        cprintf("[buddy_check_0] after alloc: ");
ffffffffc0201046:	00001497          	auipc	s1,0x1
ffffffffc020104a:	4b248493          	addi	s1,s1,1202 # ffffffffc02024f8 <commands+0x810>
        pages[i] = alloc_pages(1);
ffffffffc020104e:	4505                	li	a0,1
ffffffffc0201050:	266000ef          	jal	ra,ffffffffc02012b6 <alloc_pages>
ffffffffc0201054:	e008                	sd	a0,0(s0)
        assert(pages[i] != NULL);
ffffffffc0201056:	1e050563          	beqz	a0,ffffffffc0201240 <buddy_check_0+0x2b4>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc020105a:	0421                	addi	s0,s0,8
        cprintf("[buddy_check_0] after alloc: ");
ffffffffc020105c:	8526                	mv	a0,s1
ffffffffc020105e:	854ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc0201062:	ff5416e3          	bne	s0,s5,ffffffffc020104e <buddy_check_0+0xc2>
ffffffffc0201066:	00005497          	auipc	s1,0x5
ffffffffc020106a:	09a48493          	addi	s1,s1,154 # ffffffffc0206100 <buddy_zone+0xf0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020106e:	49a9                	li	s3,10
        cprintf("[dbg_buddy] order %2d list: %016x --> \n", order, le);
ffffffffc0201070:	00001d17          	auipc	s10,0x1
ffffffffc0201074:	4a8d0d13          	addi	s10,s10,1192 # ffffffffc0202518 <commands+0x830>
            cprintf("    %016lx (property: %d) --> \n", (size_t)page, page->property);
ffffffffc0201078:	00001917          	auipc	s2,0x1
ffffffffc020107c:	4c890913          	addi	s2,s2,1224 # ffffffffc0202540 <commands+0x858>
        cprintf("    NULL\n\n"); // 加入换行
ffffffffc0201080:	00001c97          	auipc	s9,0x1
ffffffffc0201084:	4e0c8c93          	addi	s9,s9,1248 # ffffffffc0202560 <commands+0x878>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201088:	5c7d                	li	s8,-1
        cprintf("[dbg_buddy] order %2d list: %016x --> \n", order, le);
ffffffffc020108a:	8626                	mv	a2,s1
ffffffffc020108c:	85ce                	mv	a1,s3
ffffffffc020108e:	856a                	mv	a0,s10
ffffffffc0201090:	822ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return listelm->next;
ffffffffc0201094:	6480                	ld	s0,8(s1)
        while ((le = list_next(le)) != &buddy_zone.free_area[order].free_list) {
ffffffffc0201096:	00848c63          	beq	s1,s0,ffffffffc02010ae <buddy_check_0+0x122>
            cprintf("    %016lx (property: %d) --> \n", (size_t)page, page->property);
ffffffffc020109a:	ff842603          	lw	a2,-8(s0)
ffffffffc020109e:	fe840593          	addi	a1,s0,-24
ffffffffc02010a2:	854a                	mv	a0,s2
ffffffffc02010a4:	80eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02010a8:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != &buddy_zone.free_area[order].free_list) {
ffffffffc02010aa:	fe9418e3          	bne	s0,s1,ffffffffc020109a <buddy_check_0+0x10e>
        cprintf("    NULL\n\n"); // 加入换行
ffffffffc02010ae:	8566                	mv	a0,s9
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010b0:	39fd                	addiw	s3,s3,-1
        cprintf("    NULL\n\n"); // 加入换行
ffffffffc02010b2:	800ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010b6:	14a1                	addi	s1,s1,-24
ffffffffc02010b8:	fd8999e3          	bne	s3,s8,ffffffffc020108a <buddy_check_0+0xfe>
    cprintf("[dbg_buddy] block count: \n");
ffffffffc02010bc:	00001517          	auipc	a0,0x1
ffffffffc02010c0:	4b450513          	addi	a0,a0,1204 # ffffffffc0202570 <commands+0x888>
ffffffffc02010c4:	feffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02010c8:	00005497          	auipc	s1,0x5
ffffffffc02010cc:	04848493          	addi	s1,s1,72 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010d0:	4429                	li	s0,10
        cprintf("    order %2d: %2d blocks\n", order, buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02010d2:	00001997          	auipc	s3,0x1
ffffffffc02010d6:	4be98993          	addi	s3,s3,1214 # ffffffffc0202590 <commands+0x8a8>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010da:	597d                	li	s2,-1
        cprintf("    order %2d: %2d blocks\n", order, buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02010dc:	4090                	lw	a2,0(s1)
ffffffffc02010de:	85a2                	mv	a1,s0
ffffffffc02010e0:	854e                	mv	a0,s3
ffffffffc02010e2:	0086563b          	srlw	a2,a2,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010e6:	347d                	addiw	s0,s0,-1
        cprintf("    order %2d: %2d blocks\n", order, buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02010e8:	fcbfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010ec:	14a1                	addi	s1,s1,-24
ffffffffc02010ee:	ff2417e3          	bne	s0,s2,ffffffffc02010dc <buddy_check_0+0x150>
    cprintf("\n");
ffffffffc02010f2:	00001517          	auipc	a0,0x1
ffffffffc02010f6:	10650513          	addi	a0,a0,262 # ffffffffc02021f8 <commands+0x510>
ffffffffc02010fa:	fb9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        // dbg_buddy();
    }
        dbg_buddy1();
    assert(nr_free_pages() == initial_nr_free_pages - ALLOC_PAGE_NUM);
ffffffffc02010fe:	236000ef          	jal	ra,ffffffffc0201334 <nr_free_pages>
ffffffffc0201102:	f9cb8793          	addi	a5,s7,-100
ffffffffc0201106:	16f51d63          	bne	a0,a5,ffffffffc0201280 <buddy_check_0+0x2f4>

    cprintf("[buddy_check_0] after alloc:  ");
ffffffffc020110a:	00001517          	auipc	a0,0x1
ffffffffc020110e:	4e650513          	addi	a0,a0,1254 # ffffffffc02025f0 <commands+0x908>
ffffffffc0201112:	fa1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0201116:	00001517          	auipc	a0,0x1
ffffffffc020111a:	37a50513          	addi	a0,a0,890 # ffffffffc0202490 <commands+0x7a8>
ffffffffc020111e:	f95fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0201122:	00005497          	auipc	s1,0x5
ffffffffc0201126:	fee48493          	addi	s1,s1,-18 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020112a:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020112c:	00001997          	auipc	s3,0x1
ffffffffc0201130:	37c98993          	addi	s3,s3,892 # ffffffffc02024a8 <commands+0x7c0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201134:	597d                	li	s2,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201136:	408c                	lw	a1,0(s1)
ffffffffc0201138:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020113a:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020113c:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201140:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201142:	f71fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201146:	ff2418e3          	bne	s0,s2,ffffffffc0201136 <buddy_check_0+0x1aa>
    cprintf("\n");
ffffffffc020114a:	00001517          	auipc	a0,0x1
ffffffffc020114e:	0ae50513          	addi	a0,a0,174 # ffffffffc02021f8 <commands+0x510>
ffffffffc0201152:	f61fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
        free_pages(pages[i], 1);
        cprintf("[buddy_check_0] after free: ");
ffffffffc0201156:	00001d17          	auipc	s10,0x1
ffffffffc020115a:	4bad0d13          	addi	s10,s10,1210 # ffffffffc0202610 <commands+0x928>
    cprintf("[dbg_buddy] block: ");
ffffffffc020115e:	00001c97          	auipc	s9,0x1
ffffffffc0201162:	332c8c93          	addi	s9,s9,818 # ffffffffc0202490 <commands+0x7a8>
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201166:	00001997          	auipc	s3,0x1
ffffffffc020116a:	34298993          	addi	s3,s3,834 # ffffffffc02024a8 <commands+0x7c0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020116e:	597d                	li	s2,-1
    cprintf("\n");
ffffffffc0201170:	00001c17          	auipc	s8,0x1
ffffffffc0201174:	088c0c13          	addi	s8,s8,136 # ffffffffc02021f8 <commands+0x510>
        free_pages(pages[i], 1);
ffffffffc0201178:	000a3503          	ld	a0,0(s4)
ffffffffc020117c:	4585                	li	a1,1
    cprintf("[dbg_buddy] block: ");
ffffffffc020117e:	84da                	mv	s1,s6
        free_pages(pages[i], 1);
ffffffffc0201180:	174000ef          	jal	ra,ffffffffc02012f4 <free_pages>
        cprintf("[buddy_check_0] after free: ");
ffffffffc0201184:	856a                	mv	a0,s10
ffffffffc0201186:	f2dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc020118a:	8566                	mv	a0,s9
ffffffffc020118c:	f27fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201190:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201192:	408c                	lw	a1,0(s1)
ffffffffc0201194:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201196:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201198:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020119c:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020119e:	f15fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011a2:	ff2418e3          	bne	s0,s2,ffffffffc0201192 <buddy_check_0+0x206>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc02011a6:	0a21                	addi	s4,s4,8
    cprintf("\n");
ffffffffc02011a8:	8562                	mv	a0,s8
ffffffffc02011aa:	f09fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc02011ae:	fd5a15e3          	bne	s4,s5,ffffffffc0201178 <buddy_check_0+0x1ec>
        dbg_buddy();
    }

    assert(nr_free_pages() == initial_nr_free_pages);
ffffffffc02011b2:	182000ef          	jal	ra,ffffffffc0201334 <nr_free_pages>
ffffffffc02011b6:	0b751563          	bne	a0,s7,ffffffffc0201260 <buddy_check_0+0x2d4>

    cprintf("[buddy_check_0] after free:   ");
ffffffffc02011ba:	00001517          	auipc	a0,0x1
ffffffffc02011be:	4a650513          	addi	a0,a0,1190 # ffffffffc0202660 <commands+0x978>
ffffffffc02011c2:	ef1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc02011c6:	00001517          	auipc	a0,0x1
ffffffffc02011ca:	2ca50513          	addi	a0,a0,714 # ffffffffc0202490 <commands+0x7a8>
ffffffffc02011ce:	ee5fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011d2:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011d4:	00001917          	auipc	s2,0x1
ffffffffc02011d8:	2d490913          	addi	s2,s2,724 # ffffffffc02024a8 <commands+0x7c0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011dc:	54fd                	li	s1,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011de:	000b2583          	lw	a1,0(s6)
ffffffffc02011e2:	854a                	mv	a0,s2
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011e4:	1b21                	addi	s6,s6,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011e6:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011ea:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011ec:	ec7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011f0:	fe9417e3          	bne	s0,s1,ffffffffc02011de <buddy_check_0+0x252>
    cprintf("\n");
ffffffffc02011f4:	00001517          	auipc	a0,0x1
ffffffffc02011f8:	00450513          	addi	a0,a0,4 # ffffffffc02021f8 <commands+0x510>
ffffffffc02011fc:	eb7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();

    cprintf("[buddy_check_0] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
}
ffffffffc0201200:	37013403          	ld	s0,880(sp)
ffffffffc0201204:	37813083          	ld	ra,888(sp)
ffffffffc0201208:	36813483          	ld	s1,872(sp)
ffffffffc020120c:	36013903          	ld	s2,864(sp)
ffffffffc0201210:	35813983          	ld	s3,856(sp)
ffffffffc0201214:	35013a03          	ld	s4,848(sp)
ffffffffc0201218:	34813a83          	ld	s5,840(sp)
ffffffffc020121c:	34013b03          	ld	s6,832(sp)
ffffffffc0201220:	33813b83          	ld	s7,824(sp)
ffffffffc0201224:	33013c03          	ld	s8,816(sp)
ffffffffc0201228:	32813c83          	ld	s9,808(sp)
ffffffffc020122c:	32013d03          	ld	s10,800(sp)
    cprintf("[buddy_check_0] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
ffffffffc0201230:	00001517          	auipc	a0,0x1
ffffffffc0201234:	45050513          	addi	a0,a0,1104 # ffffffffc0202680 <commands+0x998>
}
ffffffffc0201238:	38010113          	addi	sp,sp,896
    cprintf("[buddy_check_0] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
ffffffffc020123c:	e77fe06f          	j	ffffffffc02000b2 <cprintf>
        assert(pages[i] != NULL);
ffffffffc0201240:	00001697          	auipc	a3,0x1
ffffffffc0201244:	2a068693          	addi	a3,a3,672 # ffffffffc02024e0 <commands+0x7f8>
ffffffffc0201248:	00001617          	auipc	a2,0x1
ffffffffc020124c:	fd860613          	addi	a2,a2,-40 # ffffffffc0202220 <commands+0x538>
ffffffffc0201250:	21d00593          	li	a1,541
ffffffffc0201254:	00001517          	auipc	a0,0x1
ffffffffc0201258:	fe450513          	addi	a0,a0,-28 # ffffffffc0202238 <commands+0x550>
ffffffffc020125c:	950ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == initial_nr_free_pages);
ffffffffc0201260:	00001697          	auipc	a3,0x1
ffffffffc0201264:	3d068693          	addi	a3,a3,976 # ffffffffc0202630 <commands+0x948>
ffffffffc0201268:	00001617          	auipc	a2,0x1
ffffffffc020126c:	fb860613          	addi	a2,a2,-72 # ffffffffc0202220 <commands+0x538>
ffffffffc0201270:	22d00593          	li	a1,557
ffffffffc0201274:	00001517          	auipc	a0,0x1
ffffffffc0201278:	fc450513          	addi	a0,a0,-60 # ffffffffc0202238 <commands+0x550>
ffffffffc020127c:	930ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == initial_nr_free_pages - ALLOC_PAGE_NUM);
ffffffffc0201280:	00001697          	auipc	a3,0x1
ffffffffc0201284:	33068693          	addi	a3,a3,816 # ffffffffc02025b0 <commands+0x8c8>
ffffffffc0201288:	00001617          	auipc	a2,0x1
ffffffffc020128c:	f9860613          	addi	a2,a2,-104 # ffffffffc0202220 <commands+0x538>
ffffffffc0201290:	22200593          	li	a1,546
ffffffffc0201294:	00001517          	auipc	a0,0x1
ffffffffc0201298:	fa450513          	addi	a0,a0,-92 # ffffffffc0202238 <commands+0x550>
ffffffffc020129c:	910ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012a0 <buddy_check>:
//     assert(nr_free_pages() == initial_nr_free_pages);

//     cprintf("[buddy_check_1] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");
// }

static void buddy_check(void) {
ffffffffc02012a0:	1141                	addi	sp,sp,-16
    cprintf("11111111111");
ffffffffc02012a2:	00001517          	auipc	a0,0x1
ffffffffc02012a6:	42650513          	addi	a0,a0,1062 # ffffffffc02026c8 <commands+0x9e0>
static void buddy_check(void) {
ffffffffc02012aa:	e406                	sd	ra,8(sp)
    cprintf("11111111111");
ffffffffc02012ac:	e07fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    buddy_check_0();
    // buddy_check_1();
}
ffffffffc02012b0:	60a2                	ld	ra,8(sp)
ffffffffc02012b2:	0141                	addi	sp,sp,16
    buddy_check_0();
ffffffffc02012b4:	b9e1                	j	ffffffffc0200f8c <buddy_check_0>

ffffffffc02012b6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012b6:	100027f3          	csrr	a5,sstatus
ffffffffc02012ba:	8b89                	andi	a5,a5,2
ffffffffc02012bc:	e799                	bnez	a5,ffffffffc02012ca <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012be:	00005797          	auipc	a5,0x5
ffffffffc02012c2:	2827b783          	ld	a5,642(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc02012c6:	6f9c                	ld	a5,24(a5)
ffffffffc02012c8:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02012ca:	1141                	addi	sp,sp,-16
ffffffffc02012cc:	e406                	sd	ra,8(sp)
ffffffffc02012ce:	e022                	sd	s0,0(sp)
ffffffffc02012d0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012d2:	98cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012d6:	00005797          	auipc	a5,0x5
ffffffffc02012da:	26a7b783          	ld	a5,618(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc02012de:	6f9c                	ld	a5,24(a5)
ffffffffc02012e0:	8522                	mv	a0,s0
ffffffffc02012e2:	9782                	jalr	a5
ffffffffc02012e4:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02012e6:	972ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012ea:	60a2                	ld	ra,8(sp)
ffffffffc02012ec:	8522                	mv	a0,s0
ffffffffc02012ee:	6402                	ld	s0,0(sp)
ffffffffc02012f0:	0141                	addi	sp,sp,16
ffffffffc02012f2:	8082                	ret

ffffffffc02012f4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012f4:	100027f3          	csrr	a5,sstatus
ffffffffc02012f8:	8b89                	andi	a5,a5,2
ffffffffc02012fa:	e799                	bnez	a5,ffffffffc0201308 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02012fc:	00005797          	auipc	a5,0x5
ffffffffc0201300:	2447b783          	ld	a5,580(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc0201304:	739c                	ld	a5,32(a5)
ffffffffc0201306:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201308:	1101                	addi	sp,sp,-32
ffffffffc020130a:	ec06                	sd	ra,24(sp)
ffffffffc020130c:	e822                	sd	s0,16(sp)
ffffffffc020130e:	e426                	sd	s1,8(sp)
ffffffffc0201310:	842a                	mv	s0,a0
ffffffffc0201312:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201314:	94aff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201318:	00005797          	auipc	a5,0x5
ffffffffc020131c:	2287b783          	ld	a5,552(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc0201320:	739c                	ld	a5,32(a5)
ffffffffc0201322:	85a6                	mv	a1,s1
ffffffffc0201324:	8522                	mv	a0,s0
ffffffffc0201326:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201328:	6442                	ld	s0,16(sp)
ffffffffc020132a:	60e2                	ld	ra,24(sp)
ffffffffc020132c:	64a2                	ld	s1,8(sp)
ffffffffc020132e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201330:	928ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201334 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201334:	100027f3          	csrr	a5,sstatus
ffffffffc0201338:	8b89                	andi	a5,a5,2
ffffffffc020133a:	e799                	bnez	a5,ffffffffc0201348 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020133c:	00005797          	auipc	a5,0x5
ffffffffc0201340:	2047b783          	ld	a5,516(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc0201344:	779c                	ld	a5,40(a5)
ffffffffc0201346:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201348:	1141                	addi	sp,sp,-16
ffffffffc020134a:	e406                	sd	ra,8(sp)
ffffffffc020134c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020134e:	910ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201352:	00005797          	auipc	a5,0x5
ffffffffc0201356:	1ee7b783          	ld	a5,494(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc020135a:	779c                	ld	a5,40(a5)
ffffffffc020135c:	9782                	jalr	a5
ffffffffc020135e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201360:	8f8ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201364:	60a2                	ld	ra,8(sp)
ffffffffc0201366:	8522                	mv	a0,s0
ffffffffc0201368:	6402                	ld	s0,0(sp)
ffffffffc020136a:	0141                	addi	sp,sp,16
ffffffffc020136c:	8082                	ret

ffffffffc020136e <pmm_init>:
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020136e:	7179                	addi	sp,sp,-48
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201370:	00001797          	auipc	a5,0x1
ffffffffc0201374:	38878793          	addi	a5,a5,904 # ffffffffc02026f8 <buddy_system_pmm_manager>
void pmm_init(void) {
ffffffffc0201378:	e84a                	sd	s2,16(sp)
    cprintf("11111111111111\n");
ffffffffc020137a:	00001517          	auipc	a0,0x1
ffffffffc020137e:	3b650513          	addi	a0,a0,950 # ffffffffc0202730 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201382:	00005917          	auipc	s2,0x5
ffffffffc0201386:	1be90913          	addi	s2,s2,446 # ffffffffc0206540 <pmm_manager>
void pmm_init(void) {
ffffffffc020138a:	f406                	sd	ra,40(sp)
ffffffffc020138c:	f022                	sd	s0,32(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc020138e:	00f93023          	sd	a5,0(s2)
void pmm_init(void) {
ffffffffc0201392:	ec26                	sd	s1,24(sp)
ffffffffc0201394:	e44e                	sd	s3,8(sp)
ffffffffc0201396:	e052                	sd	s4,0(sp)
    cprintf("11111111111111\n");
ffffffffc0201398:	d1bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020139c:	00093783          	ld	a5,0(s2)
ffffffffc02013a0:	00001517          	auipc	a0,0x1
ffffffffc02013a4:	3a050513          	addi	a0,a0,928 # ffffffffc0202740 <buddy_system_pmm_manager+0x48>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013a8:	00005417          	auipc	s0,0x5
ffffffffc02013ac:	1b040413          	addi	s0,s0,432 # ffffffffc0206558 <va_pa_offset>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013b0:	638c                	ld	a1,0(a5)
ffffffffc02013b2:	d01fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02013b6:	00093783          	ld	a5,0(s2)
ffffffffc02013ba:	679c                	ld	a5,8(a5)
ffffffffc02013bc:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013be:	57f5                	li	a5,-3
ffffffffc02013c0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013c2:	00001517          	auipc	a0,0x1
ffffffffc02013c6:	39650513          	addi	a0,a0,918 # ffffffffc0202758 <buddy_system_pmm_manager+0x60>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013ca:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02013cc:	ce7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013d0:	46c5                	li	a3,17
ffffffffc02013d2:	06ee                	slli	a3,a3,0x1b
ffffffffc02013d4:	40100613          	li	a2,1025
ffffffffc02013d8:	16fd                	addi	a3,a3,-1
ffffffffc02013da:	07e005b7          	lui	a1,0x7e00
ffffffffc02013de:	0656                	slli	a2,a2,0x15
ffffffffc02013e0:	00001517          	auipc	a0,0x1
ffffffffc02013e4:	39050513          	addi	a0,a0,912 # ffffffffc0202770 <buddy_system_pmm_manager+0x78>
ffffffffc02013e8:	ccbfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013ec:	777d                	lui	a4,0xfffff
ffffffffc02013ee:	00006797          	auipc	a5,0x6
ffffffffc02013f2:	17978793          	addi	a5,a5,377 # ffffffffc0207567 <end+0xfff>
ffffffffc02013f6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02013f8:	00005517          	auipc	a0,0x5
ffffffffc02013fc:	13850513          	addi	a0,a0,312 # ffffffffc0206530 <npage>
ffffffffc0201400:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201404:	00005597          	auipc	a1,0x5
ffffffffc0201408:	13458593          	addi	a1,a1,308 # ffffffffc0206538 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020140c:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020140e:	e19c                	sd	a5,0(a1)
ffffffffc0201410:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201412:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201414:	4885                	li	a7,1
ffffffffc0201416:	fff80837          	lui	a6,0xfff80
ffffffffc020141a:	a011                	j	ffffffffc020141e <pmm_init+0xb0>
        SetPageReserved(pages + i);
ffffffffc020141c:	619c                	ld	a5,0(a1)
ffffffffc020141e:	97b6                	add	a5,a5,a3
ffffffffc0201420:	07a1                	addi	a5,a5,8
ffffffffc0201422:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201426:	611c                	ld	a5,0(a0)
ffffffffc0201428:	0705                	addi	a4,a4,1
ffffffffc020142a:	02868693          	addi	a3,a3,40
ffffffffc020142e:	01078633          	add	a2,a5,a6
ffffffffc0201432:	fec765e3          	bltu	a4,a2,ffffffffc020141c <pmm_init+0xae>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201436:	6190                	ld	a2,0(a1)
ffffffffc0201438:	00279713          	slli	a4,a5,0x2
ffffffffc020143c:	973e                	add	a4,a4,a5
ffffffffc020143e:	fec006b7          	lui	a3,0xfec00
ffffffffc0201442:	070e                	slli	a4,a4,0x3
ffffffffc0201444:	96b2                	add	a3,a3,a2
ffffffffc0201446:	96ba                	add	a3,a3,a4
ffffffffc0201448:	c0200737          	lui	a4,0xc0200
ffffffffc020144c:	0ae6ec63          	bltu	a3,a4,ffffffffc0201504 <pmm_init+0x196>
ffffffffc0201450:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201452:	49c5                	li	s3,17
ffffffffc0201454:	09ee                	slli	s3,s3,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201456:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201458:	0536ec63          	bltu	a3,s3,ffffffffc02014b0 <pmm_init+0x142>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020145c:	00093783          	ld	a5,0(s2)
ffffffffc0201460:	7b9c                	ld	a5,48(a5)
ffffffffc0201462:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201464:	00001517          	auipc	a0,0x1
ffffffffc0201468:	3a450513          	addi	a0,a0,932 # ffffffffc0202808 <buddy_system_pmm_manager+0x110>
ffffffffc020146c:	c47fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201470:	00004597          	auipc	a1,0x4
ffffffffc0201474:	b9058593          	addi	a1,a1,-1136 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201478:	00005797          	auipc	a5,0x5
ffffffffc020147c:	0cb7bc23          	sd	a1,216(a5) # ffffffffc0206550 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201480:	c02007b7          	lui	a5,0xc0200
ffffffffc0201484:	08f5ec63          	bltu	a1,a5,ffffffffc020151c <pmm_init+0x1ae>
ffffffffc0201488:	6010                	ld	a2,0(s0)
}
ffffffffc020148a:	7402                	ld	s0,32(sp)
ffffffffc020148c:	70a2                	ld	ra,40(sp)
ffffffffc020148e:	64e2                	ld	s1,24(sp)
ffffffffc0201490:	6942                	ld	s2,16(sp)
ffffffffc0201492:	69a2                	ld	s3,8(sp)
ffffffffc0201494:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201496:	40c58633          	sub	a2,a1,a2
ffffffffc020149a:	00005797          	auipc	a5,0x5
ffffffffc020149e:	0ac7b723          	sd	a2,174(a5) # ffffffffc0206548 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014a2:	00001517          	auipc	a0,0x1
ffffffffc02014a6:	38650513          	addi	a0,a0,902 # ffffffffc0202828 <buddy_system_pmm_manager+0x130>
}
ffffffffc02014aa:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014ac:	c07fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014b0:	6485                	lui	s1,0x1
ffffffffc02014b2:	14fd                	addi	s1,s1,-1
ffffffffc02014b4:	96a6                	add	a3,a3,s1
ffffffffc02014b6:	74fd                	lui	s1,0xfffff
ffffffffc02014b8:	8cf5                	and	s1,s1,a3
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014ba:	00c4da13          	srli	s4,s1,0xc
ffffffffc02014be:	02fa7763          	bgeu	s4,a5,ffffffffc02014ec <pmm_init+0x17e>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02014c2:	9852                	add	a6,a6,s4
ffffffffc02014c4:	00281a13          	slli	s4,a6,0x2
ffffffffc02014c8:	9a42                	add	s4,s4,a6
ffffffffc02014ca:	0a0e                	slli	s4,s4,0x3
    cprintf("222222222222\n");
ffffffffc02014cc:	00001517          	auipc	a0,0x1
ffffffffc02014d0:	d3c50513          	addi	a0,a0,-708 # ffffffffc0202208 <commands+0x520>
ffffffffc02014d4:	9a32                	add	s4,s4,a2
ffffffffc02014d6:	bddfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init_memmap(base, n);
ffffffffc02014da:	00093783          	ld	a5,0(s2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014de:	409985b3          	sub	a1,s3,s1
    pmm_manager->init_memmap(base, n);
ffffffffc02014e2:	81b1                	srli	a1,a1,0xc
ffffffffc02014e4:	6b9c                	ld	a5,16(a5)
ffffffffc02014e6:	8552                	mv	a0,s4
ffffffffc02014e8:	9782                	jalr	a5
}
ffffffffc02014ea:	bf8d                	j	ffffffffc020145c <pmm_init+0xee>
        panic("pa2page called with invalid pa");
ffffffffc02014ec:	00001617          	auipc	a2,0x1
ffffffffc02014f0:	2ec60613          	addi	a2,a2,748 # ffffffffc02027d8 <buddy_system_pmm_manager+0xe0>
ffffffffc02014f4:	06b00593          	li	a1,107
ffffffffc02014f8:	00001517          	auipc	a0,0x1
ffffffffc02014fc:	30050513          	addi	a0,a0,768 # ffffffffc02027f8 <buddy_system_pmm_manager+0x100>
ffffffffc0201500:	eadfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201504:	00001617          	auipc	a2,0x1
ffffffffc0201508:	29c60613          	addi	a2,a2,668 # ffffffffc02027a0 <buddy_system_pmm_manager+0xa8>
ffffffffc020150c:	07500593          	li	a1,117
ffffffffc0201510:	00001517          	auipc	a0,0x1
ffffffffc0201514:	2b850513          	addi	a0,a0,696 # ffffffffc02027c8 <buddy_system_pmm_manager+0xd0>
ffffffffc0201518:	e95fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020151c:	86ae                	mv	a3,a1
ffffffffc020151e:	00001617          	auipc	a2,0x1
ffffffffc0201522:	28260613          	addi	a2,a2,642 # ffffffffc02027a0 <buddy_system_pmm_manager+0xa8>
ffffffffc0201526:	09000593          	li	a1,144
ffffffffc020152a:	00001517          	auipc	a0,0x1
ffffffffc020152e:	29e50513          	addi	a0,a0,670 # ffffffffc02027c8 <buddy_system_pmm_manager+0xd0>
ffffffffc0201532:	e7bfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201536 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201536:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020153a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020153c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201540:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201542:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201546:	f022                	sd	s0,32(sp)
ffffffffc0201548:	ec26                	sd	s1,24(sp)
ffffffffc020154a:	e84a                	sd	s2,16(sp)
ffffffffc020154c:	f406                	sd	ra,40(sp)
ffffffffc020154e:	e44e                	sd	s3,8(sp)
ffffffffc0201550:	84aa                	mv	s1,a0
ffffffffc0201552:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201554:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201558:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020155a:	03067e63          	bgeu	a2,a6,ffffffffc0201596 <printnum+0x60>
ffffffffc020155e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201560:	00805763          	blez	s0,ffffffffc020156e <printnum+0x38>
ffffffffc0201564:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201566:	85ca                	mv	a1,s2
ffffffffc0201568:	854e                	mv	a0,s3
ffffffffc020156a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020156c:	fc65                	bnez	s0,ffffffffc0201564 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020156e:	1a02                	slli	s4,s4,0x20
ffffffffc0201570:	00001797          	auipc	a5,0x1
ffffffffc0201574:	2f878793          	addi	a5,a5,760 # ffffffffc0202868 <buddy_system_pmm_manager+0x170>
ffffffffc0201578:	020a5a13          	srli	s4,s4,0x20
ffffffffc020157c:	9a3e                	add	s4,s4,a5
}
ffffffffc020157e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201580:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201584:	70a2                	ld	ra,40(sp)
ffffffffc0201586:	69a2                	ld	s3,8(sp)
ffffffffc0201588:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020158a:	85ca                	mv	a1,s2
ffffffffc020158c:	87a6                	mv	a5,s1
}
ffffffffc020158e:	6942                	ld	s2,16(sp)
ffffffffc0201590:	64e2                	ld	s1,24(sp)
ffffffffc0201592:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201594:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201596:	03065633          	divu	a2,a2,a6
ffffffffc020159a:	8722                	mv	a4,s0
ffffffffc020159c:	f9bff0ef          	jal	ra,ffffffffc0201536 <printnum>
ffffffffc02015a0:	b7f9                	j	ffffffffc020156e <printnum+0x38>

ffffffffc02015a2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015a2:	7119                	addi	sp,sp,-128
ffffffffc02015a4:	f4a6                	sd	s1,104(sp)
ffffffffc02015a6:	f0ca                	sd	s2,96(sp)
ffffffffc02015a8:	ecce                	sd	s3,88(sp)
ffffffffc02015aa:	e8d2                	sd	s4,80(sp)
ffffffffc02015ac:	e4d6                	sd	s5,72(sp)
ffffffffc02015ae:	e0da                	sd	s6,64(sp)
ffffffffc02015b0:	fc5e                	sd	s7,56(sp)
ffffffffc02015b2:	f06a                	sd	s10,32(sp)
ffffffffc02015b4:	fc86                	sd	ra,120(sp)
ffffffffc02015b6:	f8a2                	sd	s0,112(sp)
ffffffffc02015b8:	f862                	sd	s8,48(sp)
ffffffffc02015ba:	f466                	sd	s9,40(sp)
ffffffffc02015bc:	ec6e                	sd	s11,24(sp)
ffffffffc02015be:	892a                	mv	s2,a0
ffffffffc02015c0:	84ae                	mv	s1,a1
ffffffffc02015c2:	8d32                	mv	s10,a2
ffffffffc02015c4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015c6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015ca:	5b7d                	li	s6,-1
ffffffffc02015cc:	00001a97          	auipc	s5,0x1
ffffffffc02015d0:	2d0a8a93          	addi	s5,s5,720 # ffffffffc020289c <buddy_system_pmm_manager+0x1a4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015d4:	00001b97          	auipc	s7,0x1
ffffffffc02015d8:	4a4b8b93          	addi	s7,s7,1188 # ffffffffc0202a78 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015dc:	000d4503          	lbu	a0,0(s10)
ffffffffc02015e0:	001d0413          	addi	s0,s10,1
ffffffffc02015e4:	01350a63          	beq	a0,s3,ffffffffc02015f8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02015e8:	c121                	beqz	a0,ffffffffc0201628 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02015ea:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015ec:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02015ee:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015f0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02015f4:	ff351ae3          	bne	a0,s3,ffffffffc02015e8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015f8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02015fc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201600:	4c81                	li	s9,0
ffffffffc0201602:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201604:	5c7d                	li	s8,-1
ffffffffc0201606:	5dfd                	li	s11,-1
ffffffffc0201608:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020160c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020160e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201612:	0ff5f593          	zext.b	a1,a1
ffffffffc0201616:	00140d13          	addi	s10,s0,1
ffffffffc020161a:	04b56263          	bltu	a0,a1,ffffffffc020165e <vprintfmt+0xbc>
ffffffffc020161e:	058a                	slli	a1,a1,0x2
ffffffffc0201620:	95d6                	add	a1,a1,s5
ffffffffc0201622:	4194                	lw	a3,0(a1)
ffffffffc0201624:	96d6                	add	a3,a3,s5
ffffffffc0201626:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201628:	70e6                	ld	ra,120(sp)
ffffffffc020162a:	7446                	ld	s0,112(sp)
ffffffffc020162c:	74a6                	ld	s1,104(sp)
ffffffffc020162e:	7906                	ld	s2,96(sp)
ffffffffc0201630:	69e6                	ld	s3,88(sp)
ffffffffc0201632:	6a46                	ld	s4,80(sp)
ffffffffc0201634:	6aa6                	ld	s5,72(sp)
ffffffffc0201636:	6b06                	ld	s6,64(sp)
ffffffffc0201638:	7be2                	ld	s7,56(sp)
ffffffffc020163a:	7c42                	ld	s8,48(sp)
ffffffffc020163c:	7ca2                	ld	s9,40(sp)
ffffffffc020163e:	7d02                	ld	s10,32(sp)
ffffffffc0201640:	6de2                	ld	s11,24(sp)
ffffffffc0201642:	6109                	addi	sp,sp,128
ffffffffc0201644:	8082                	ret
            padc = '0';
ffffffffc0201646:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201648:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164c:	846a                	mv	s0,s10
ffffffffc020164e:	00140d13          	addi	s10,s0,1
ffffffffc0201652:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201656:	0ff5f593          	zext.b	a1,a1
ffffffffc020165a:	fcb572e3          	bgeu	a0,a1,ffffffffc020161e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020165e:	85a6                	mv	a1,s1
ffffffffc0201660:	02500513          	li	a0,37
ffffffffc0201664:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201666:	fff44783          	lbu	a5,-1(s0)
ffffffffc020166a:	8d22                	mv	s10,s0
ffffffffc020166c:	f73788e3          	beq	a5,s3,ffffffffc02015dc <vprintfmt+0x3a>
ffffffffc0201670:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201674:	1d7d                	addi	s10,s10,-1
ffffffffc0201676:	ff379de3          	bne	a5,s3,ffffffffc0201670 <vprintfmt+0xce>
ffffffffc020167a:	b78d                	j	ffffffffc02015dc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020167c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201680:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201684:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201686:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020168a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020168e:	02d86463          	bltu	a6,a3,ffffffffc02016b6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201692:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201696:	002c169b          	slliw	a3,s8,0x2
ffffffffc020169a:	0186873b          	addw	a4,a3,s8
ffffffffc020169e:	0017171b          	slliw	a4,a4,0x1
ffffffffc02016a2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02016a4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02016a8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02016aa:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02016ae:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016b2:	fed870e3          	bgeu	a6,a3,ffffffffc0201692 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02016b6:	f40ddce3          	bgez	s11,ffffffffc020160e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02016ba:	8de2                	mv	s11,s8
ffffffffc02016bc:	5c7d                	li	s8,-1
ffffffffc02016be:	bf81                	j	ffffffffc020160e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02016c0:	fffdc693          	not	a3,s11
ffffffffc02016c4:	96fd                	srai	a3,a3,0x3f
ffffffffc02016c6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ca:	00144603          	lbu	a2,1(s0)
ffffffffc02016ce:	2d81                	sext.w	s11,s11
ffffffffc02016d0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016d2:	bf35                	j	ffffffffc020160e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02016d4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016d8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02016dc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016de:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02016e0:	bfd9                	j	ffffffffc02016b6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02016e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016e8:	01174463          	blt	a4,a7,ffffffffc02016f0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02016ec:	1a088e63          	beqz	a7,ffffffffc02018a8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02016f0:	000a3603          	ld	a2,0(s4)
ffffffffc02016f4:	46c1                	li	a3,16
ffffffffc02016f6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02016f8:	2781                	sext.w	a5,a5
ffffffffc02016fa:	876e                	mv	a4,s11
ffffffffc02016fc:	85a6                	mv	a1,s1
ffffffffc02016fe:	854a                	mv	a0,s2
ffffffffc0201700:	e37ff0ef          	jal	ra,ffffffffc0201536 <printnum>
            break;
ffffffffc0201704:	bde1                	j	ffffffffc02015dc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201706:	000a2503          	lw	a0,0(s4)
ffffffffc020170a:	85a6                	mv	a1,s1
ffffffffc020170c:	0a21                	addi	s4,s4,8
ffffffffc020170e:	9902                	jalr	s2
            break;
ffffffffc0201710:	b5f1                	j	ffffffffc02015dc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201712:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201714:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201718:	01174463          	blt	a4,a7,ffffffffc0201720 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020171c:	18088163          	beqz	a7,ffffffffc020189e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201720:	000a3603          	ld	a2,0(s4)
ffffffffc0201724:	46a9                	li	a3,10
ffffffffc0201726:	8a2e                	mv	s4,a1
ffffffffc0201728:	bfc1                	j	ffffffffc02016f8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020172a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020172e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201730:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201732:	bdf1                	j	ffffffffc020160e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201734:	85a6                	mv	a1,s1
ffffffffc0201736:	02500513          	li	a0,37
ffffffffc020173a:	9902                	jalr	s2
            break;
ffffffffc020173c:	b545                	j	ffffffffc02015dc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020173e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201742:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201744:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201746:	b5e1                	j	ffffffffc020160e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201748:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020174a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020174e:	01174463          	blt	a4,a7,ffffffffc0201756 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201752:	14088163          	beqz	a7,ffffffffc0201894 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201756:	000a3603          	ld	a2,0(s4)
ffffffffc020175a:	46a1                	li	a3,8
ffffffffc020175c:	8a2e                	mv	s4,a1
ffffffffc020175e:	bf69                	j	ffffffffc02016f8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201760:	03000513          	li	a0,48
ffffffffc0201764:	85a6                	mv	a1,s1
ffffffffc0201766:	e03e                	sd	a5,0(sp)
ffffffffc0201768:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020176a:	85a6                	mv	a1,s1
ffffffffc020176c:	07800513          	li	a0,120
ffffffffc0201770:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201772:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201774:	6782                	ld	a5,0(sp)
ffffffffc0201776:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201778:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020177c:	bfb5                	j	ffffffffc02016f8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020177e:	000a3403          	ld	s0,0(s4)
ffffffffc0201782:	008a0713          	addi	a4,s4,8
ffffffffc0201786:	e03a                	sd	a4,0(sp)
ffffffffc0201788:	14040263          	beqz	s0,ffffffffc02018cc <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020178c:	0fb05763          	blez	s11,ffffffffc020187a <vprintfmt+0x2d8>
ffffffffc0201790:	02d00693          	li	a3,45
ffffffffc0201794:	0cd79163          	bne	a5,a3,ffffffffc0201856 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201798:	00044783          	lbu	a5,0(s0)
ffffffffc020179c:	0007851b          	sext.w	a0,a5
ffffffffc02017a0:	cf85                	beqz	a5,ffffffffc02017d8 <vprintfmt+0x236>
ffffffffc02017a2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017a6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017aa:	000c4563          	bltz	s8,ffffffffc02017b4 <vprintfmt+0x212>
ffffffffc02017ae:	3c7d                	addiw	s8,s8,-1
ffffffffc02017b0:	036c0263          	beq	s8,s6,ffffffffc02017d4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02017b4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017b6:	0e0c8e63          	beqz	s9,ffffffffc02018b2 <vprintfmt+0x310>
ffffffffc02017ba:	3781                	addiw	a5,a5,-32
ffffffffc02017bc:	0ef47b63          	bgeu	s0,a5,ffffffffc02018b2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02017c0:	03f00513          	li	a0,63
ffffffffc02017c4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017c6:	000a4783          	lbu	a5,0(s4)
ffffffffc02017ca:	3dfd                	addiw	s11,s11,-1
ffffffffc02017cc:	0a05                	addi	s4,s4,1
ffffffffc02017ce:	0007851b          	sext.w	a0,a5
ffffffffc02017d2:	ffe1                	bnez	a5,ffffffffc02017aa <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02017d4:	01b05963          	blez	s11,ffffffffc02017e6 <vprintfmt+0x244>
ffffffffc02017d8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017da:	85a6                	mv	a1,s1
ffffffffc02017dc:	02000513          	li	a0,32
ffffffffc02017e0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017e2:	fe0d9be3          	bnez	s11,ffffffffc02017d8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017e6:	6a02                	ld	s4,0(sp)
ffffffffc02017e8:	bbd5                	j	ffffffffc02015dc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017ea:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017ec:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02017f0:	01174463          	blt	a4,a7,ffffffffc02017f8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02017f4:	08088d63          	beqz	a7,ffffffffc020188e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02017f8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02017fc:	0a044d63          	bltz	s0,ffffffffc02018b6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201800:	8622                	mv	a2,s0
ffffffffc0201802:	8a66                	mv	s4,s9
ffffffffc0201804:	46a9                	li	a3,10
ffffffffc0201806:	bdcd                	j	ffffffffc02016f8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201808:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020180c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020180e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201810:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201814:	8fb5                	xor	a5,a5,a3
ffffffffc0201816:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020181a:	02d74163          	blt	a4,a3,ffffffffc020183c <vprintfmt+0x29a>
ffffffffc020181e:	00369793          	slli	a5,a3,0x3
ffffffffc0201822:	97de                	add	a5,a5,s7
ffffffffc0201824:	639c                	ld	a5,0(a5)
ffffffffc0201826:	cb99                	beqz	a5,ffffffffc020183c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201828:	86be                	mv	a3,a5
ffffffffc020182a:	00001617          	auipc	a2,0x1
ffffffffc020182e:	06e60613          	addi	a2,a2,110 # ffffffffc0202898 <buddy_system_pmm_manager+0x1a0>
ffffffffc0201832:	85a6                	mv	a1,s1
ffffffffc0201834:	854a                	mv	a0,s2
ffffffffc0201836:	0ce000ef          	jal	ra,ffffffffc0201904 <printfmt>
ffffffffc020183a:	b34d                	j	ffffffffc02015dc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020183c:	00001617          	auipc	a2,0x1
ffffffffc0201840:	04c60613          	addi	a2,a2,76 # ffffffffc0202888 <buddy_system_pmm_manager+0x190>
ffffffffc0201844:	85a6                	mv	a1,s1
ffffffffc0201846:	854a                	mv	a0,s2
ffffffffc0201848:	0bc000ef          	jal	ra,ffffffffc0201904 <printfmt>
ffffffffc020184c:	bb41                	j	ffffffffc02015dc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020184e:	00001417          	auipc	s0,0x1
ffffffffc0201852:	03240413          	addi	s0,s0,50 # ffffffffc0202880 <buddy_system_pmm_manager+0x188>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201856:	85e2                	mv	a1,s8
ffffffffc0201858:	8522                	mv	a0,s0
ffffffffc020185a:	e43e                	sd	a5,8(sp)
ffffffffc020185c:	1cc000ef          	jal	ra,ffffffffc0201a28 <strnlen>
ffffffffc0201860:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201864:	01b05b63          	blez	s11,ffffffffc020187a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201868:	67a2                	ld	a5,8(sp)
ffffffffc020186a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020186e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201870:	85a6                	mv	a1,s1
ffffffffc0201872:	8552                	mv	a0,s4
ffffffffc0201874:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201876:	fe0d9ce3          	bnez	s11,ffffffffc020186e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020187a:	00044783          	lbu	a5,0(s0)
ffffffffc020187e:	00140a13          	addi	s4,s0,1
ffffffffc0201882:	0007851b          	sext.w	a0,a5
ffffffffc0201886:	d3a5                	beqz	a5,ffffffffc02017e6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201888:	05e00413          	li	s0,94
ffffffffc020188c:	bf39                	j	ffffffffc02017aa <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020188e:	000a2403          	lw	s0,0(s4)
ffffffffc0201892:	b7ad                	j	ffffffffc02017fc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201894:	000a6603          	lwu	a2,0(s4)
ffffffffc0201898:	46a1                	li	a3,8
ffffffffc020189a:	8a2e                	mv	s4,a1
ffffffffc020189c:	bdb1                	j	ffffffffc02016f8 <vprintfmt+0x156>
ffffffffc020189e:	000a6603          	lwu	a2,0(s4)
ffffffffc02018a2:	46a9                	li	a3,10
ffffffffc02018a4:	8a2e                	mv	s4,a1
ffffffffc02018a6:	bd89                	j	ffffffffc02016f8 <vprintfmt+0x156>
ffffffffc02018a8:	000a6603          	lwu	a2,0(s4)
ffffffffc02018ac:	46c1                	li	a3,16
ffffffffc02018ae:	8a2e                	mv	s4,a1
ffffffffc02018b0:	b5a1                	j	ffffffffc02016f8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02018b2:	9902                	jalr	s2
ffffffffc02018b4:	bf09                	j	ffffffffc02017c6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02018b6:	85a6                	mv	a1,s1
ffffffffc02018b8:	02d00513          	li	a0,45
ffffffffc02018bc:	e03e                	sd	a5,0(sp)
ffffffffc02018be:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018c0:	6782                	ld	a5,0(sp)
ffffffffc02018c2:	8a66                	mv	s4,s9
ffffffffc02018c4:	40800633          	neg	a2,s0
ffffffffc02018c8:	46a9                	li	a3,10
ffffffffc02018ca:	b53d                	j	ffffffffc02016f8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02018cc:	03b05163          	blez	s11,ffffffffc02018ee <vprintfmt+0x34c>
ffffffffc02018d0:	02d00693          	li	a3,45
ffffffffc02018d4:	f6d79de3          	bne	a5,a3,ffffffffc020184e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02018d8:	00001417          	auipc	s0,0x1
ffffffffc02018dc:	fa840413          	addi	s0,s0,-88 # ffffffffc0202880 <buddy_system_pmm_manager+0x188>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018e0:	02800793          	li	a5,40
ffffffffc02018e4:	02800513          	li	a0,40
ffffffffc02018e8:	00140a13          	addi	s4,s0,1
ffffffffc02018ec:	bd6d                	j	ffffffffc02017a6 <vprintfmt+0x204>
ffffffffc02018ee:	00001a17          	auipc	s4,0x1
ffffffffc02018f2:	f93a0a13          	addi	s4,s4,-109 # ffffffffc0202881 <buddy_system_pmm_manager+0x189>
ffffffffc02018f6:	02800513          	li	a0,40
ffffffffc02018fa:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018fe:	05e00413          	li	s0,94
ffffffffc0201902:	b565                	j	ffffffffc02017aa <vprintfmt+0x208>

ffffffffc0201904 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201904:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201906:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020190a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020190c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020190e:	ec06                	sd	ra,24(sp)
ffffffffc0201910:	f83a                	sd	a4,48(sp)
ffffffffc0201912:	fc3e                	sd	a5,56(sp)
ffffffffc0201914:	e0c2                	sd	a6,64(sp)
ffffffffc0201916:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201918:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020191a:	c89ff0ef          	jal	ra,ffffffffc02015a2 <vprintfmt>
}
ffffffffc020191e:	60e2                	ld	ra,24(sp)
ffffffffc0201920:	6161                	addi	sp,sp,80
ffffffffc0201922:	8082                	ret

ffffffffc0201924 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201924:	715d                	addi	sp,sp,-80
ffffffffc0201926:	e486                	sd	ra,72(sp)
ffffffffc0201928:	e0a6                	sd	s1,64(sp)
ffffffffc020192a:	fc4a                	sd	s2,56(sp)
ffffffffc020192c:	f84e                	sd	s3,48(sp)
ffffffffc020192e:	f452                	sd	s4,40(sp)
ffffffffc0201930:	f056                	sd	s5,32(sp)
ffffffffc0201932:	ec5a                	sd	s6,24(sp)
ffffffffc0201934:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201936:	c901                	beqz	a0,ffffffffc0201946 <readline+0x22>
ffffffffc0201938:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020193a:	00001517          	auipc	a0,0x1
ffffffffc020193e:	f5e50513          	addi	a0,a0,-162 # ffffffffc0202898 <buddy_system_pmm_manager+0x1a0>
ffffffffc0201942:	f70fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201946:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201948:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020194a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020194c:	4aa9                	li	s5,10
ffffffffc020194e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201950:	00004b97          	auipc	s7,0x4
ffffffffc0201954:	7d0b8b93          	addi	s7,s7,2000 # ffffffffc0206120 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201958:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020195c:	fcefe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201960:	00054a63          	bltz	a0,ffffffffc0201974 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201964:	00a95a63          	bge	s2,a0,ffffffffc0201978 <readline+0x54>
ffffffffc0201968:	029a5263          	bge	s4,s1,ffffffffc020198c <readline+0x68>
        c = getchar();
ffffffffc020196c:	fbefe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201970:	fe055ae3          	bgez	a0,ffffffffc0201964 <readline+0x40>
            return NULL;
ffffffffc0201974:	4501                	li	a0,0
ffffffffc0201976:	a091                	j	ffffffffc02019ba <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201978:	03351463          	bne	a0,s3,ffffffffc02019a0 <readline+0x7c>
ffffffffc020197c:	e8a9                	bnez	s1,ffffffffc02019ce <readline+0xaa>
        c = getchar();
ffffffffc020197e:	facfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201982:	fe0549e3          	bltz	a0,ffffffffc0201974 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201986:	fea959e3          	bge	s2,a0,ffffffffc0201978 <readline+0x54>
ffffffffc020198a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020198c:	e42a                	sd	a0,8(sp)
ffffffffc020198e:	f5afe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201992:	6522                	ld	a0,8(sp)
ffffffffc0201994:	009b87b3          	add	a5,s7,s1
ffffffffc0201998:	2485                	addiw	s1,s1,1
ffffffffc020199a:	00a78023          	sb	a0,0(a5)
ffffffffc020199e:	bf7d                	j	ffffffffc020195c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02019a0:	01550463          	beq	a0,s5,ffffffffc02019a8 <readline+0x84>
ffffffffc02019a4:	fb651ce3          	bne	a0,s6,ffffffffc020195c <readline+0x38>
            cputchar(c);
ffffffffc02019a8:	f40fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02019ac:	00004517          	auipc	a0,0x4
ffffffffc02019b0:	77450513          	addi	a0,a0,1908 # ffffffffc0206120 <buf>
ffffffffc02019b4:	94aa                	add	s1,s1,a0
ffffffffc02019b6:	00048023          	sb	zero,0(s1) # fffffffffffff000 <end+0x3fdf8a98>
            return buf;
        }
    }
}
ffffffffc02019ba:	60a6                	ld	ra,72(sp)
ffffffffc02019bc:	6486                	ld	s1,64(sp)
ffffffffc02019be:	7962                	ld	s2,56(sp)
ffffffffc02019c0:	79c2                	ld	s3,48(sp)
ffffffffc02019c2:	7a22                	ld	s4,40(sp)
ffffffffc02019c4:	7a82                	ld	s5,32(sp)
ffffffffc02019c6:	6b62                	ld	s6,24(sp)
ffffffffc02019c8:	6bc2                	ld	s7,16(sp)
ffffffffc02019ca:	6161                	addi	sp,sp,80
ffffffffc02019cc:	8082                	ret
            cputchar(c);
ffffffffc02019ce:	4521                	li	a0,8
ffffffffc02019d0:	f18fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02019d4:	34fd                	addiw	s1,s1,-1
ffffffffc02019d6:	b759                	j	ffffffffc020195c <readline+0x38>

ffffffffc02019d8 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02019d8:	4781                	li	a5,0
ffffffffc02019da:	00004717          	auipc	a4,0x4
ffffffffc02019de:	62e73703          	ld	a4,1582(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02019e2:	88ba                	mv	a7,a4
ffffffffc02019e4:	852a                	mv	a0,a0
ffffffffc02019e6:	85be                	mv	a1,a5
ffffffffc02019e8:	863e                	mv	a2,a5
ffffffffc02019ea:	00000073          	ecall
ffffffffc02019ee:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02019f0:	8082                	ret

ffffffffc02019f2 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02019f2:	4781                	li	a5,0
ffffffffc02019f4:	00005717          	auipc	a4,0x5
ffffffffc02019f8:	b6c73703          	ld	a4,-1172(a4) # ffffffffc0206560 <SBI_SET_TIMER>
ffffffffc02019fc:	88ba                	mv	a7,a4
ffffffffc02019fe:	852a                	mv	a0,a0
ffffffffc0201a00:	85be                	mv	a1,a5
ffffffffc0201a02:	863e                	mv	a2,a5
ffffffffc0201a04:	00000073          	ecall
ffffffffc0201a08:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201a0a:	8082                	ret

ffffffffc0201a0c <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201a0c:	4501                	li	a0,0
ffffffffc0201a0e:	00004797          	auipc	a5,0x4
ffffffffc0201a12:	5f27b783          	ld	a5,1522(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201a16:	88be                	mv	a7,a5
ffffffffc0201a18:	852a                	mv	a0,a0
ffffffffc0201a1a:	85aa                	mv	a1,a0
ffffffffc0201a1c:	862a                	mv	a2,a0
ffffffffc0201a1e:	00000073          	ecall
ffffffffc0201a22:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a24:	2501                	sext.w	a0,a0
ffffffffc0201a26:	8082                	ret

ffffffffc0201a28 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201a28:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a2a:	e589                	bnez	a1,ffffffffc0201a34 <strnlen+0xc>
ffffffffc0201a2c:	a811                	j	ffffffffc0201a40 <strnlen+0x18>
        cnt ++;
ffffffffc0201a2e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a30:	00f58863          	beq	a1,a5,ffffffffc0201a40 <strnlen+0x18>
ffffffffc0201a34:	00f50733          	add	a4,a0,a5
ffffffffc0201a38:	00074703          	lbu	a4,0(a4)
ffffffffc0201a3c:	fb6d                	bnez	a4,ffffffffc0201a2e <strnlen+0x6>
ffffffffc0201a3e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a40:	852e                	mv	a0,a1
ffffffffc0201a42:	8082                	ret

ffffffffc0201a44 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a44:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a48:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a4c:	cb89                	beqz	a5,ffffffffc0201a5e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a4e:	0505                	addi	a0,a0,1
ffffffffc0201a50:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a52:	fee789e3          	beq	a5,a4,ffffffffc0201a44 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a56:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a5a:	9d19                	subw	a0,a0,a4
ffffffffc0201a5c:	8082                	ret
ffffffffc0201a5e:	4501                	li	a0,0
ffffffffc0201a60:	bfed                	j	ffffffffc0201a5a <strcmp+0x16>

ffffffffc0201a62 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a62:	00054783          	lbu	a5,0(a0)
ffffffffc0201a66:	c799                	beqz	a5,ffffffffc0201a74 <strchr+0x12>
        if (*s == c) {
ffffffffc0201a68:	00f58763          	beq	a1,a5,ffffffffc0201a76 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201a6c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201a70:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201a72:	fbfd                	bnez	a5,ffffffffc0201a68 <strchr+0x6>
    }
    return NULL;
ffffffffc0201a74:	4501                	li	a0,0
}
ffffffffc0201a76:	8082                	ret

ffffffffc0201a78 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a78:	ca01                	beqz	a2,ffffffffc0201a88 <memset+0x10>
ffffffffc0201a7a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a7c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a7e:	0785                	addi	a5,a5,1
ffffffffc0201a80:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a84:	fec79de3          	bne	a5,a2,ffffffffc0201a7e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a88:	8082                	ret
