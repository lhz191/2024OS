
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
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	21f010ef          	jal	ra,ffffffffc0201a68 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0201a80 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	32c010ef          	jal	ra,ffffffffc0201392 <pmm_init>

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
ffffffffc02000a6:	4ec010ef          	jal	ra,ffffffffc0201592 <vprintfmt>
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
ffffffffc02000dc:	4b6010ef          	jal	ra,ffffffffc0201592 <vprintfmt>
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
ffffffffc0200140:	96450513          	addi	a0,a0,-1692 # ffffffffc0201aa0 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201ac0 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	91c58593          	addi	a1,a1,-1764 # ffffffffc0201a7a <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201ae0 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	98650513          	addi	a0,a0,-1658 # ffffffffc0201b00 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	99250513          	addi	a0,a0,-1646 # ffffffffc0201b20 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
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
ffffffffc02001c0:	98450513          	addi	a0,a0,-1660 # ffffffffc0201b40 <etext+0xc6>
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
ffffffffc02001ce:	9a660613          	addi	a2,a2,-1626 # ffffffffc0201b70 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	9b250513          	addi	a0,a0,-1614 # ffffffffc0201b88 <etext+0x10e>
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
ffffffffc02001ea:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0201ba0 <etext+0x126>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	9d258593          	addi	a1,a1,-1582 # ffffffffc0201bc0 <etext+0x146>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	9d250513          	addi	a0,a0,-1582 # ffffffffc0201bc8 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	9d460613          	addi	a2,a2,-1580 # ffffffffc0201bd8 <etext+0x15e>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	9f458593          	addi	a1,a1,-1548 # ffffffffc0201c00 <etext+0x186>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	9b450513          	addi	a0,a0,-1612 # ffffffffc0201bc8 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	9f060613          	addi	a2,a2,-1552 # ffffffffc0201c10 <etext+0x196>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	a0858593          	addi	a1,a1,-1528 # ffffffffc0201c30 <etext+0x1b6>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	99850513          	addi	a0,a0,-1640 # ffffffffc0201bc8 <etext+0x14e>
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
ffffffffc020026e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201c40 <etext+0x1c6>
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
ffffffffc0200290:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0201c68 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	a36c0c13          	addi	s8,s8,-1482 # ffffffffc0201cd8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	9e690913          	addi	s2,s2,-1562 # ffffffffc0201c90 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	9e648493          	addi	s1,s1,-1562 # ffffffffc0201c98 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	9e4b0b13          	addi	s6,s6,-1564 # ffffffffc0201ca0 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	8fca0a13          	addi	s4,s4,-1796 # ffffffffc0201bc0 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	644010ef          	jal	ra,ffffffffc0201914 <readline>
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
ffffffffc02002ea:	9f2d0d13          	addi	s10,s10,-1550 # ffffffffc0201cd8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	740010ef          	jal	ra,ffffffffc0201a34 <strcmp>
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
ffffffffc0200308:	72c010ef          	jal	ra,ffffffffc0201a34 <strcmp>
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
ffffffffc0200346:	70c010ef          	jal	ra,ffffffffc0201a52 <strchr>
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
ffffffffc0200384:	6ce010ef          	jal	ra,ffffffffc0201a52 <strchr>
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
ffffffffc02003a2:	92250513          	addi	a0,a0,-1758 # ffffffffc0201cc0 <etext+0x246>
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
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
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
ffffffffc02003de:	94650513          	addi	a0,a0,-1722 # ffffffffc0201d20 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	77850513          	addi	a0,a0,1912 # ffffffffc0201b68 <etext+0xee>
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
ffffffffc0200420:	5c2010ef          	jal	ra,ffffffffc02019e2 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	91250513          	addi	a0,a0,-1774 # ffffffffc0201d40 <commands+0x68>
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
ffffffffc0200446:	59c0106f          	j	ffffffffc02019e2 <sbi_set_timer>

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
ffffffffc0200450:	5780106f          	j	ffffffffc02019c8 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5a80106f          	j	ffffffffc02019fc <sbi_console_getchar>

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
ffffffffc0200482:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201d60 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201d78 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201d90 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201da8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	90850513          	addi	a0,a0,-1784 # ffffffffc0201dc0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	91250513          	addi	a0,a0,-1774 # ffffffffc0201dd8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201df0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	92650513          	addi	a0,a0,-1754 # ffffffffc0201e08 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	93050513          	addi	a0,a0,-1744 # ffffffffc0201e20 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201e38 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	94450513          	addi	a0,a0,-1724 # ffffffffc0201e50 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201e68 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	95850513          	addi	a0,a0,-1704 # ffffffffc0201e80 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	96250513          	addi	a0,a0,-1694 # ffffffffc0201e98 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201eb0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	97650513          	addi	a0,a0,-1674 # ffffffffc0201ec8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	98050513          	addi	a0,a0,-1664 # ffffffffc0201ee0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201ef8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	99450513          	addi	a0,a0,-1644 # ffffffffc0201f10 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	99e50513          	addi	a0,a0,-1634 # ffffffffc0201f28 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0201f40 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	9b250513          	addi	a0,a0,-1614 # ffffffffc0201f58 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0201f70 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9c650513          	addi	a0,a0,-1594 # ffffffffc0201f88 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9d050513          	addi	a0,a0,-1584 # ffffffffc0201fa0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9da50513          	addi	a0,a0,-1574 # ffffffffc0201fb8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9e450513          	addi	a0,a0,-1564 # ffffffffc0201fd0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0201fe8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0202000 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0202018 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0202030 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	a1250513          	addi	a0,a0,-1518 # ffffffffc0202048 <commands+0x370>
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
ffffffffc020064e:	a1650513          	addi	a0,a0,-1514 # ffffffffc0202060 <commands+0x388>
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
ffffffffc0200666:	a1650513          	addi	a0,a0,-1514 # ffffffffc0202078 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0202090 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	a2650513          	addi	a0,a0,-1498 # ffffffffc02020a8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc02020c0 <commands+0x3e8>
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
ffffffffc02006b4:	af070713          	addi	a4,a4,-1296 # ffffffffc02021a0 <commands+0x4c8>
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
ffffffffc02006c6:	a7650513          	addi	a0,a0,-1418 # ffffffffc0202138 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0202118 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	a0250513          	addi	a0,a0,-1534 # ffffffffc02020d8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a7850513          	addi	a0,a0,-1416 # ffffffffc0202158 <commands+0x480>
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
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
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
ffffffffc0200714:	a7050513          	addi	a0,a0,-1424 # ffffffffc0202180 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	9de50513          	addi	a0,a0,-1570 # ffffffffc02020f8 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	a4450513          	addi	a0,a0,-1468 # ffffffffc0202170 <commands+0x498>
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

ffffffffc0200802 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020081e:	715d                	addi	sp,sp,-80
ffffffffc0200820:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200822:	00005417          	auipc	s0,0x5
ffffffffc0200826:	7ee40413          	addi	s0,s0,2030 # ffffffffc0206010 <free_area>
ffffffffc020082a:	641c                	ld	a5,8(s0)
ffffffffc020082c:	e486                	sd	ra,72(sp)
ffffffffc020082e:	fc26                	sd	s1,56(sp)
ffffffffc0200830:	f84a                	sd	s2,48(sp)
ffffffffc0200832:	f44e                	sd	s3,40(sp)
ffffffffc0200834:	f052                	sd	s4,32(sp)
ffffffffc0200836:	ec56                	sd	s5,24(sp)
ffffffffc0200838:	e85a                	sd	s6,16(sp)
ffffffffc020083a:	e45e                	sd	s7,8(sp)
ffffffffc020083c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020083e:	2c878763          	beq	a5,s0,ffffffffc0200b0c <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200842:	4481                	li	s1,0
ffffffffc0200844:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200846:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020084a:	8b09                	andi	a4,a4,2
ffffffffc020084c:	2c070463          	beqz	a4,ffffffffc0200b14 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200850:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200854:	679c                	ld	a5,8(a5)
ffffffffc0200856:	2905                	addiw	s2,s2,1
ffffffffc0200858:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085a:	fe8796e3          	bne	a5,s0,ffffffffc0200846 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020085e:	89a6                	mv	s3,s1
ffffffffc0200860:	2f9000ef          	jal	ra,ffffffffc0201358 <nr_free_pages>
ffffffffc0200864:	71351863          	bne	a0,s3,ffffffffc0200f74 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200868:	4505                	li	a0,1
ffffffffc020086a:	271000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc020086e:	8a2a                	mv	s4,a0
ffffffffc0200870:	44050263          	beqz	a0,ffffffffc0200cb4 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200874:	4505                	li	a0,1
ffffffffc0200876:	265000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc020087a:	89aa                	mv	s3,a0
ffffffffc020087c:	70050c63          	beqz	a0,ffffffffc0200f94 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200880:	4505                	li	a0,1
ffffffffc0200882:	259000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200886:	8aaa                	mv	s5,a0
ffffffffc0200888:	4a050663          	beqz	a0,ffffffffc0200d34 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020088c:	2b3a0463          	beq	s4,s3,ffffffffc0200b34 <default_check+0x316>
ffffffffc0200890:	2aaa0263          	beq	s4,a0,ffffffffc0200b34 <default_check+0x316>
ffffffffc0200894:	2aa98063          	beq	s3,a0,ffffffffc0200b34 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200898:	000a2783          	lw	a5,0(s4)
ffffffffc020089c:	2a079c63          	bnez	a5,ffffffffc0200b54 <default_check+0x336>
ffffffffc02008a0:	0009a783          	lw	a5,0(s3)
ffffffffc02008a4:	2a079863          	bnez	a5,ffffffffc0200b54 <default_check+0x336>
ffffffffc02008a8:	411c                	lw	a5,0(a0)
ffffffffc02008aa:	2a079563          	bnez	a5,ffffffffc0200b54 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008ae:	00006797          	auipc	a5,0x6
ffffffffc02008b2:	b927b783          	ld	a5,-1134(a5) # ffffffffc0206440 <pages>
ffffffffc02008b6:	40fa0733          	sub	a4,s4,a5
ffffffffc02008ba:	870d                	srai	a4,a4,0x3
ffffffffc02008bc:	00002597          	auipc	a1,0x2
ffffffffc02008c0:	07c5b583          	ld	a1,124(a1) # ffffffffc0202938 <error_string+0x38>
ffffffffc02008c4:	02b70733          	mul	a4,a4,a1
ffffffffc02008c8:	00002617          	auipc	a2,0x2
ffffffffc02008cc:	07863603          	ld	a2,120(a2) # ffffffffc0202940 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008d0:	00006697          	auipc	a3,0x6
ffffffffc02008d4:	b686b683          	ld	a3,-1176(a3) # ffffffffc0206438 <npage>
ffffffffc02008d8:	06b2                	slli	a3,a3,0xc
ffffffffc02008da:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008dc:	0732                	slli	a4,a4,0xc
ffffffffc02008de:	28d77b63          	bgeu	a4,a3,ffffffffc0200b74 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e2:	40f98733          	sub	a4,s3,a5
ffffffffc02008e6:	870d                	srai	a4,a4,0x3
ffffffffc02008e8:	02b70733          	mul	a4,a4,a1
ffffffffc02008ec:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02008ee:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008f0:	4cd77263          	bgeu	a4,a3,ffffffffc0200db4 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f4:	40f507b3          	sub	a5,a0,a5
ffffffffc02008f8:	878d                	srai	a5,a5,0x3
ffffffffc02008fa:	02b787b3          	mul	a5,a5,a1
ffffffffc02008fe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200900:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200902:	30d7f963          	bgeu	a5,a3,ffffffffc0200c14 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200906:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200908:	00043c03          	ld	s8,0(s0)
ffffffffc020090c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200910:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200914:	e400                	sd	s0,8(s0)
ffffffffc0200916:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200918:	00005797          	auipc	a5,0x5
ffffffffc020091c:	7007a423          	sw	zero,1800(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200920:	1bb000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200924:	2c051863          	bnez	a0,ffffffffc0200bf4 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200928:	4585                	li	a1,1
ffffffffc020092a:	8552                	mv	a0,s4
ffffffffc020092c:	1ed000ef          	jal	ra,ffffffffc0201318 <free_pages>
    free_page(p1);
ffffffffc0200930:	4585                	li	a1,1
ffffffffc0200932:	854e                	mv	a0,s3
ffffffffc0200934:	1e5000ef          	jal	ra,ffffffffc0201318 <free_pages>
    free_page(p2);
ffffffffc0200938:	4585                	li	a1,1
ffffffffc020093a:	8556                	mv	a0,s5
ffffffffc020093c:	1dd000ef          	jal	ra,ffffffffc0201318 <free_pages>
    assert(nr_free == 3);
ffffffffc0200940:	4818                	lw	a4,16(s0)
ffffffffc0200942:	478d                	li	a5,3
ffffffffc0200944:	28f71863          	bne	a4,a5,ffffffffc0200bd4 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200948:	4505                	li	a0,1
ffffffffc020094a:	191000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc020094e:	89aa                	mv	s3,a0
ffffffffc0200950:	26050263          	beqz	a0,ffffffffc0200bb4 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200954:	4505                	li	a0,1
ffffffffc0200956:	185000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc020095a:	8aaa                	mv	s5,a0
ffffffffc020095c:	3a050c63          	beqz	a0,ffffffffc0200d14 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200960:	4505                	li	a0,1
ffffffffc0200962:	179000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200966:	8a2a                	mv	s4,a0
ffffffffc0200968:	38050663          	beqz	a0,ffffffffc0200cf4 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc020096c:	4505                	li	a0,1
ffffffffc020096e:	16d000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200972:	36051163          	bnez	a0,ffffffffc0200cd4 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200976:	4585                	li	a1,1
ffffffffc0200978:	854e                	mv	a0,s3
ffffffffc020097a:	19f000ef          	jal	ra,ffffffffc0201318 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020097e:	641c                	ld	a5,8(s0)
ffffffffc0200980:	20878a63          	beq	a5,s0,ffffffffc0200b94 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200984:	4505                	li	a0,1
ffffffffc0200986:	155000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc020098a:	30a99563          	bne	s3,a0,ffffffffc0200c94 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	14b000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200994:	2e051063          	bnez	a0,ffffffffc0200c74 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200998:	481c                	lw	a5,16(s0)
ffffffffc020099a:	2a079d63          	bnez	a5,ffffffffc0200c54 <default_check+0x436>
    free_page(p);
ffffffffc020099e:	854e                	mv	a0,s3
ffffffffc02009a0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009a2:	01843023          	sd	s8,0(s0)
ffffffffc02009a6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02009aa:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02009ae:	16b000ef          	jal	ra,ffffffffc0201318 <free_pages>
    free_page(p1);
ffffffffc02009b2:	4585                	li	a1,1
ffffffffc02009b4:	8556                	mv	a0,s5
ffffffffc02009b6:	163000ef          	jal	ra,ffffffffc0201318 <free_pages>
    free_page(p2);
ffffffffc02009ba:	4585                	li	a1,1
ffffffffc02009bc:	8552                	mv	a0,s4
ffffffffc02009be:	15b000ef          	jal	ra,ffffffffc0201318 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02009c2:	4515                	li	a0,5
ffffffffc02009c4:	117000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc02009c8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009ca:	26050563          	beqz	a0,ffffffffc0200c34 <default_check+0x416>
ffffffffc02009ce:	651c                	ld	a5,8(a0)
ffffffffc02009d0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02009d2:	8b85                	andi	a5,a5,1
ffffffffc02009d4:	54079063          	bnez	a5,ffffffffc0200f14 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02009d8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009da:	00043b03          	ld	s6,0(s0)
ffffffffc02009de:	00843a83          	ld	s5,8(s0)
ffffffffc02009e2:	e000                	sd	s0,0(s0)
ffffffffc02009e4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02009e6:	0f5000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc02009ea:	50051563          	bnez	a0,ffffffffc0200ef4 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02009ee:	05098a13          	addi	s4,s3,80
ffffffffc02009f2:	8552                	mv	a0,s4
ffffffffc02009f4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02009f6:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02009fa:	00005797          	auipc	a5,0x5
ffffffffc02009fe:	6207a323          	sw	zero,1574(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200a02:	117000ef          	jal	ra,ffffffffc0201318 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a06:	4511                	li	a0,4
ffffffffc0200a08:	0d3000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200a0c:	4c051463          	bnez	a0,ffffffffc0200ed4 <default_check+0x6b6>
ffffffffc0200a10:	0589b783          	ld	a5,88(s3)
ffffffffc0200a14:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200a16:	8b85                	andi	a5,a5,1
ffffffffc0200a18:	48078e63          	beqz	a5,ffffffffc0200eb4 <default_check+0x696>
ffffffffc0200a1c:	0609a703          	lw	a4,96(s3)
ffffffffc0200a20:	478d                	li	a5,3
ffffffffc0200a22:	48f71963          	bne	a4,a5,ffffffffc0200eb4 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200a26:	450d                	li	a0,3
ffffffffc0200a28:	0b3000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200a2c:	8c2a                	mv	s8,a0
ffffffffc0200a2e:	46050363          	beqz	a0,ffffffffc0200e94 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200a32:	4505                	li	a0,1
ffffffffc0200a34:	0a7000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200a38:	42051e63          	bnez	a0,ffffffffc0200e74 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200a3c:	418a1c63          	bne	s4,s8,ffffffffc0200e54 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200a40:	4585                	li	a1,1
ffffffffc0200a42:	854e                	mv	a0,s3
ffffffffc0200a44:	0d5000ef          	jal	ra,ffffffffc0201318 <free_pages>
    free_pages(p1, 3);
ffffffffc0200a48:	458d                	li	a1,3
ffffffffc0200a4a:	8552                	mv	a0,s4
ffffffffc0200a4c:	0cd000ef          	jal	ra,ffffffffc0201318 <free_pages>
ffffffffc0200a50:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200a54:	02898c13          	addi	s8,s3,40
ffffffffc0200a58:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200a5a:	8b85                	andi	a5,a5,1
ffffffffc0200a5c:	3c078c63          	beqz	a5,ffffffffc0200e34 <default_check+0x616>
ffffffffc0200a60:	0109a703          	lw	a4,16(s3)
ffffffffc0200a64:	4785                	li	a5,1
ffffffffc0200a66:	3cf71763          	bne	a4,a5,ffffffffc0200e34 <default_check+0x616>
ffffffffc0200a6a:	008a3783          	ld	a5,8(s4)
ffffffffc0200a6e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200a70:	8b85                	andi	a5,a5,1
ffffffffc0200a72:	3a078163          	beqz	a5,ffffffffc0200e14 <default_check+0x5f6>
ffffffffc0200a76:	010a2703          	lw	a4,16(s4)
ffffffffc0200a7a:	478d                	li	a5,3
ffffffffc0200a7c:	38f71c63          	bne	a4,a5,ffffffffc0200e14 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200a80:	4505                	li	a0,1
ffffffffc0200a82:	059000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200a86:	36a99763          	bne	s3,a0,ffffffffc0200df4 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200a8a:	4585                	li	a1,1
ffffffffc0200a8c:	08d000ef          	jal	ra,ffffffffc0201318 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200a90:	4509                	li	a0,2
ffffffffc0200a92:	049000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200a96:	32aa1f63          	bne	s4,a0,ffffffffc0200dd4 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200a9a:	4589                	li	a1,2
ffffffffc0200a9c:	07d000ef          	jal	ra,ffffffffc0201318 <free_pages>
    free_page(p2);
ffffffffc0200aa0:	4585                	li	a1,1
ffffffffc0200aa2:	8562                	mv	a0,s8
ffffffffc0200aa4:	075000ef          	jal	ra,ffffffffc0201318 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200aa8:	4515                	li	a0,5
ffffffffc0200aaa:	031000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200aae:	89aa                	mv	s3,a0
ffffffffc0200ab0:	48050263          	beqz	a0,ffffffffc0200f34 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200ab4:	4505                	li	a0,1
ffffffffc0200ab6:	025000ef          	jal	ra,ffffffffc02012da <alloc_pages>
ffffffffc0200aba:	2c051d63          	bnez	a0,ffffffffc0200d94 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200abe:	481c                	lw	a5,16(s0)
ffffffffc0200ac0:	2a079a63          	bnez	a5,ffffffffc0200d74 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200ac4:	4595                	li	a1,5
ffffffffc0200ac6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200ac8:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200acc:	01643023          	sd	s6,0(s0)
ffffffffc0200ad0:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200ad4:	045000ef          	jal	ra,ffffffffc0201318 <free_pages>
    return listelm->next;
ffffffffc0200ad8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ada:	00878963          	beq	a5,s0,ffffffffc0200aec <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200ade:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ae2:	679c                	ld	a5,8(a5)
ffffffffc0200ae4:	397d                	addiw	s2,s2,-1
ffffffffc0200ae6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ae8:	fe879be3          	bne	a5,s0,ffffffffc0200ade <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200aec:	26091463          	bnez	s2,ffffffffc0200d54 <default_check+0x536>
    assert(total == 0);
ffffffffc0200af0:	46049263          	bnez	s1,ffffffffc0200f54 <default_check+0x736>
}
ffffffffc0200af4:	60a6                	ld	ra,72(sp)
ffffffffc0200af6:	6406                	ld	s0,64(sp)
ffffffffc0200af8:	74e2                	ld	s1,56(sp)
ffffffffc0200afa:	7942                	ld	s2,48(sp)
ffffffffc0200afc:	79a2                	ld	s3,40(sp)
ffffffffc0200afe:	7a02                	ld	s4,32(sp)
ffffffffc0200b00:	6ae2                	ld	s5,24(sp)
ffffffffc0200b02:	6b42                	ld	s6,16(sp)
ffffffffc0200b04:	6ba2                	ld	s7,8(sp)
ffffffffc0200b06:	6c02                	ld	s8,0(sp)
ffffffffc0200b08:	6161                	addi	sp,sp,80
ffffffffc0200b0a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b0c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b0e:	4481                	li	s1,0
ffffffffc0200b10:	4901                	li	s2,0
ffffffffc0200b12:	b3b9                	j	ffffffffc0200860 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b14:	00001697          	auipc	a3,0x1
ffffffffc0200b18:	6bc68693          	addi	a3,a3,1724 # ffffffffc02021d0 <commands+0x4f8>
ffffffffc0200b1c:	00001617          	auipc	a2,0x1
ffffffffc0200b20:	6c460613          	addi	a2,a2,1732 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200b24:	0ef00593          	li	a1,239
ffffffffc0200b28:	00001517          	auipc	a0,0x1
ffffffffc0200b2c:	6d050513          	addi	a0,a0,1744 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200b30:	87dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b34:	00001697          	auipc	a3,0x1
ffffffffc0200b38:	75c68693          	addi	a3,a3,1884 # ffffffffc0202290 <commands+0x5b8>
ffffffffc0200b3c:	00001617          	auipc	a2,0x1
ffffffffc0200b40:	6a460613          	addi	a2,a2,1700 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200b44:	0bc00593          	li	a1,188
ffffffffc0200b48:	00001517          	auipc	a0,0x1
ffffffffc0200b4c:	6b050513          	addi	a0,a0,1712 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200b50:	85dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b54:	00001697          	auipc	a3,0x1
ffffffffc0200b58:	76468693          	addi	a3,a3,1892 # ffffffffc02022b8 <commands+0x5e0>
ffffffffc0200b5c:	00001617          	auipc	a2,0x1
ffffffffc0200b60:	68460613          	addi	a2,a2,1668 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200b64:	0bd00593          	li	a1,189
ffffffffc0200b68:	00001517          	auipc	a0,0x1
ffffffffc0200b6c:	69050513          	addi	a0,a0,1680 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200b70:	83dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b74:	00001697          	auipc	a3,0x1
ffffffffc0200b78:	78468693          	addi	a3,a3,1924 # ffffffffc02022f8 <commands+0x620>
ffffffffc0200b7c:	00001617          	auipc	a2,0x1
ffffffffc0200b80:	66460613          	addi	a2,a2,1636 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200b84:	0bf00593          	li	a1,191
ffffffffc0200b88:	00001517          	auipc	a0,0x1
ffffffffc0200b8c:	67050513          	addi	a0,a0,1648 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200b90:	81dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200b94:	00001697          	auipc	a3,0x1
ffffffffc0200b98:	7ec68693          	addi	a3,a3,2028 # ffffffffc0202380 <commands+0x6a8>
ffffffffc0200b9c:	00001617          	auipc	a2,0x1
ffffffffc0200ba0:	64460613          	addi	a2,a2,1604 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200ba4:	0d800593          	li	a1,216
ffffffffc0200ba8:	00001517          	auipc	a0,0x1
ffffffffc0200bac:	65050513          	addi	a0,a0,1616 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200bb0:	ffcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bb4:	00001697          	auipc	a3,0x1
ffffffffc0200bb8:	67c68693          	addi	a3,a3,1660 # ffffffffc0202230 <commands+0x558>
ffffffffc0200bbc:	00001617          	auipc	a2,0x1
ffffffffc0200bc0:	62460613          	addi	a2,a2,1572 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200bc4:	0d100593          	li	a1,209
ffffffffc0200bc8:	00001517          	auipc	a0,0x1
ffffffffc0200bcc:	63050513          	addi	a0,a0,1584 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200bd0:	fdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200bd4:	00001697          	auipc	a3,0x1
ffffffffc0200bd8:	79c68693          	addi	a3,a3,1948 # ffffffffc0202370 <commands+0x698>
ffffffffc0200bdc:	00001617          	auipc	a2,0x1
ffffffffc0200be0:	60460613          	addi	a2,a2,1540 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200be4:	0cf00593          	li	a1,207
ffffffffc0200be8:	00001517          	auipc	a0,0x1
ffffffffc0200bec:	61050513          	addi	a0,a0,1552 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200bf0:	fbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200bf4:	00001697          	auipc	a3,0x1
ffffffffc0200bf8:	76468693          	addi	a3,a3,1892 # ffffffffc0202358 <commands+0x680>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	5e460613          	addi	a2,a2,1508 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200c04:	0ca00593          	li	a1,202
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	5f050513          	addi	a0,a0,1520 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200c10:	f9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c14:	00001697          	auipc	a3,0x1
ffffffffc0200c18:	72468693          	addi	a3,a3,1828 # ffffffffc0202338 <commands+0x660>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	5c460613          	addi	a2,a2,1476 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200c24:	0c100593          	li	a1,193
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	5d050513          	addi	a0,a0,1488 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200c30:	f7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200c34:	00001697          	auipc	a3,0x1
ffffffffc0200c38:	79468693          	addi	a3,a3,1940 # ffffffffc02023c8 <commands+0x6f0>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	5a460613          	addi	a2,a2,1444 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200c44:	0f700593          	li	a1,247
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	5b050513          	addi	a0,a0,1456 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	76468693          	addi	a3,a3,1892 # ffffffffc02023b8 <commands+0x6e0>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	58460613          	addi	a2,a2,1412 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200c64:	0de00593          	li	a1,222
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	59050513          	addi	a0,a0,1424 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200c70:	f3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c74:	00001697          	auipc	a3,0x1
ffffffffc0200c78:	6e468693          	addi	a3,a3,1764 # ffffffffc0202358 <commands+0x680>
ffffffffc0200c7c:	00001617          	auipc	a2,0x1
ffffffffc0200c80:	56460613          	addi	a2,a2,1380 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200c84:	0dc00593          	li	a1,220
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	57050513          	addi	a0,a0,1392 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200c90:	f1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200c94:	00001697          	auipc	a3,0x1
ffffffffc0200c98:	70468693          	addi	a3,a3,1796 # ffffffffc0202398 <commands+0x6c0>
ffffffffc0200c9c:	00001617          	auipc	a2,0x1
ffffffffc0200ca0:	54460613          	addi	a2,a2,1348 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200ca4:	0db00593          	li	a1,219
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	55050513          	addi	a0,a0,1360 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200cb0:	efcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cb4:	00001697          	auipc	a3,0x1
ffffffffc0200cb8:	57c68693          	addi	a3,a3,1404 # ffffffffc0202230 <commands+0x558>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	52460613          	addi	a2,a2,1316 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200cc4:	0b800593          	li	a1,184
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	53050513          	addi	a0,a0,1328 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200cd0:	edcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	68468693          	addi	a3,a3,1668 # ffffffffc0202358 <commands+0x680>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	50460613          	addi	a2,a2,1284 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200ce4:	0d500593          	li	a1,213
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	51050513          	addi	a0,a0,1296 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200cf0:	ebcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	57c68693          	addi	a3,a3,1404 # ffffffffc0202270 <commands+0x598>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	4e460613          	addi	a2,a2,1252 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200d04:	0d300593          	li	a1,211
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	4f050513          	addi	a0,a0,1264 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200d10:	e9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d14:	00001697          	auipc	a3,0x1
ffffffffc0200d18:	53c68693          	addi	a3,a3,1340 # ffffffffc0202250 <commands+0x578>
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	4c460613          	addi	a2,a2,1220 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200d24:	0d200593          	li	a1,210
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	4d050513          	addi	a0,a0,1232 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200d30:	e7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d34:	00001697          	auipc	a3,0x1
ffffffffc0200d38:	53c68693          	addi	a3,a3,1340 # ffffffffc0202270 <commands+0x598>
ffffffffc0200d3c:	00001617          	auipc	a2,0x1
ffffffffc0200d40:	4a460613          	addi	a2,a2,1188 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200d44:	0ba00593          	li	a1,186
ffffffffc0200d48:	00001517          	auipc	a0,0x1
ffffffffc0200d4c:	4b050513          	addi	a0,a0,1200 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200d50:	e5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200d54:	00001697          	auipc	a3,0x1
ffffffffc0200d58:	7c468693          	addi	a3,a3,1988 # ffffffffc0202518 <commands+0x840>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	48460613          	addi	a2,a2,1156 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200d64:	12400593          	li	a1,292
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	49050513          	addi	a0,a0,1168 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200d70:	e3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d74:	00001697          	auipc	a3,0x1
ffffffffc0200d78:	64468693          	addi	a3,a3,1604 # ffffffffc02023b8 <commands+0x6e0>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	46460613          	addi	a2,a2,1124 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200d84:	11900593          	li	a1,281
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	47050513          	addi	a0,a0,1136 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200d90:	e1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	5c468693          	addi	a3,a3,1476 # ffffffffc0202358 <commands+0x680>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	44460613          	addi	a2,a2,1092 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200da4:	11700593          	li	a1,279
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	45050513          	addi	a0,a0,1104 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200db0:	dfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	56468693          	addi	a3,a3,1380 # ffffffffc0202318 <commands+0x640>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	42460613          	addi	a2,a2,1060 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200dc4:	0c000593          	li	a1,192
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	43050513          	addi	a0,a0,1072 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200dd0:	ddcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	70468693          	addi	a3,a3,1796 # ffffffffc02024d8 <commands+0x800>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	40460613          	addi	a2,a2,1028 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200de4:	11100593          	li	a1,273
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	41050513          	addi	a0,a0,1040 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200df0:	dbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	6c468693          	addi	a3,a3,1732 # ffffffffc02024b8 <commands+0x7e0>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	3e460613          	addi	a2,a2,996 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200e04:	10f00593          	li	a1,271
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	3f050513          	addi	a0,a0,1008 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200e10:	d9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	67c68693          	addi	a3,a3,1660 # ffffffffc0202490 <commands+0x7b8>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	3c460613          	addi	a2,a2,964 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200e24:	10d00593          	li	a1,269
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	3d050513          	addi	a0,a0,976 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200e30:	d7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e34:	00001697          	auipc	a3,0x1
ffffffffc0200e38:	63468693          	addi	a3,a3,1588 # ffffffffc0202468 <commands+0x790>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	3a460613          	addi	a2,a2,932 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200e44:	10c00593          	li	a1,268
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	3b050513          	addi	a0,a0,944 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200e50:	d5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p1);
ffffffffc0200e54:	00001697          	auipc	a3,0x1
ffffffffc0200e58:	60468693          	addi	a3,a3,1540 # ffffffffc0202458 <commands+0x780>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	38460613          	addi	a2,a2,900 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200e64:	10700593          	li	a1,263
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	39050513          	addi	a0,a0,912 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200e70:	d3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	4e468693          	addi	a3,a3,1252 # ffffffffc0202358 <commands+0x680>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	36460613          	addi	a2,a2,868 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200e84:	10600593          	li	a1,262
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	37050513          	addi	a0,a0,880 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200e90:	d1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	5a468693          	addi	a3,a3,1444 # ffffffffc0202438 <commands+0x760>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	34460613          	addi	a2,a2,836 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200ea4:	10500593          	li	a1,261
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	35050513          	addi	a0,a0,848 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200eb0:	cfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	55468693          	addi	a3,a3,1364 # ffffffffc0202408 <commands+0x730>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	32460613          	addi	a2,a2,804 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200ec4:	10400593          	li	a1,260
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	33050513          	addi	a0,a0,816 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200ed0:	cdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	51c68693          	addi	a3,a3,1308 # ffffffffc02023f0 <commands+0x718>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	30460613          	addi	a2,a2,772 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200ee4:	10300593          	li	a1,259
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	31050513          	addi	a0,a0,784 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200ef0:	cbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	46468693          	addi	a3,a3,1124 # ffffffffc0202358 <commands+0x680>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	2e460613          	addi	a2,a2,740 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200f04:	0fd00593          	li	a1,253
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	2f050513          	addi	a0,a0,752 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200f10:	c9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	4c468693          	addi	a3,a3,1220 # ffffffffc02023d8 <commands+0x700>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	2c460613          	addi	a2,a2,708 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200f24:	0f800593          	li	a1,248
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	2d050513          	addi	a0,a0,720 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200f30:	c7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	5c468693          	addi	a3,a3,1476 # ffffffffc02024f8 <commands+0x820>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	2a460613          	addi	a2,a2,676 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200f44:	11600593          	li	a1,278
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	2b050513          	addi	a0,a0,688 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200f50:	c5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	5d468693          	addi	a3,a3,1492 # ffffffffc0202528 <commands+0x850>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	28460613          	addi	a2,a2,644 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200f64:	12500593          	li	a1,293
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	29050513          	addi	a0,a0,656 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200f70:	c3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	29c68693          	addi	a3,a3,668 # ffffffffc0202210 <commands+0x538>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	26460613          	addi	a2,a2,612 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200f84:	0f200593          	li	a1,242
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	27050513          	addi	a0,a0,624 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200f90:	c1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	2bc68693          	addi	a3,a3,700 # ffffffffc0202250 <commands+0x578>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	24460613          	addi	a2,a2,580 # ffffffffc02021e0 <commands+0x508>
ffffffffc0200fa4:	0b900593          	li	a1,185
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	25050513          	addi	a0,a0,592 # ffffffffc02021f8 <commands+0x520>
ffffffffc0200fb0:	bfcff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200fb4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0200fb4:	1141                	addi	sp,sp,-16
ffffffffc0200fb6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fb8:	14058a63          	beqz	a1,ffffffffc020110c <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200fbc:	00259693          	slli	a3,a1,0x2
ffffffffc0200fc0:	96ae                	add	a3,a3,a1
ffffffffc0200fc2:	068e                	slli	a3,a3,0x3
ffffffffc0200fc4:	96aa                	add	a3,a3,a0
ffffffffc0200fc6:	87aa                	mv	a5,a0
ffffffffc0200fc8:	02d50263          	beq	a0,a3,ffffffffc0200fec <default_free_pages+0x38>
ffffffffc0200fcc:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fce:	8b05                	andi	a4,a4,1
ffffffffc0200fd0:	10071e63          	bnez	a4,ffffffffc02010ec <default_free_pages+0x138>
ffffffffc0200fd4:	6798                	ld	a4,8(a5)
ffffffffc0200fd6:	8b09                	andi	a4,a4,2
ffffffffc0200fd8:	10071a63          	bnez	a4,ffffffffc02010ec <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0200fdc:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fe0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fe4:	02878793          	addi	a5,a5,40
ffffffffc0200fe8:	fed792e3          	bne	a5,a3,ffffffffc0200fcc <default_free_pages+0x18>
    base->property = n;
ffffffffc0200fec:	2581                	sext.w	a1,a1
ffffffffc0200fee:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200ff0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ff4:	4789                	li	a5,2
ffffffffc0200ff6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0200ffa:	00005697          	auipc	a3,0x5
ffffffffc0200ffe:	01668693          	addi	a3,a3,22 # ffffffffc0206010 <free_area>
ffffffffc0201002:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201004:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201006:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020100a:	9db9                	addw	a1,a1,a4
ffffffffc020100c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020100e:	0ad78863          	beq	a5,a3,ffffffffc02010be <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201012:	fe878713          	addi	a4,a5,-24
ffffffffc0201016:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020101a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020101c:	00e56a63          	bltu	a0,a4,ffffffffc0201030 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0201020:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201022:	06d70263          	beq	a4,a3,ffffffffc0201086 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201026:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201028:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020102c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201020 <default_free_pages+0x6c>
ffffffffc0201030:	c199                	beqz	a1,ffffffffc0201036 <default_free_pages+0x82>
ffffffffc0201032:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201036:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201038:	e390                	sd	a2,0(a5)
ffffffffc020103a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020103c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020103e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201040:	02d70063          	beq	a4,a3,ffffffffc0201060 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201044:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201048:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc020104c:	02081613          	slli	a2,a6,0x20
ffffffffc0201050:	9201                	srli	a2,a2,0x20
ffffffffc0201052:	00261793          	slli	a5,a2,0x2
ffffffffc0201056:	97b2                	add	a5,a5,a2
ffffffffc0201058:	078e                	slli	a5,a5,0x3
ffffffffc020105a:	97ae                	add	a5,a5,a1
ffffffffc020105c:	02f50f63          	beq	a0,a5,ffffffffc020109a <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0201060:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201062:	00d70f63          	beq	a4,a3,ffffffffc0201080 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201066:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201068:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020106c:	02059613          	slli	a2,a1,0x20
ffffffffc0201070:	9201                	srli	a2,a2,0x20
ffffffffc0201072:	00261793          	slli	a5,a2,0x2
ffffffffc0201076:	97b2                	add	a5,a5,a2
ffffffffc0201078:	078e                	slli	a5,a5,0x3
ffffffffc020107a:	97aa                	add	a5,a5,a0
ffffffffc020107c:	04f68863          	beq	a3,a5,ffffffffc02010cc <default_free_pages+0x118>
}
ffffffffc0201080:	60a2                	ld	ra,8(sp)
ffffffffc0201082:	0141                	addi	sp,sp,16
ffffffffc0201084:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201086:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201088:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020108a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020108c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020108e:	02d70563          	beq	a4,a3,ffffffffc02010b8 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201092:	8832                	mv	a6,a2
ffffffffc0201094:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201096:	87ba                	mv	a5,a4
ffffffffc0201098:	bf41                	j	ffffffffc0201028 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020109a:	491c                	lw	a5,16(a0)
ffffffffc020109c:	0107883b          	addw	a6,a5,a6
ffffffffc02010a0:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010a4:	57f5                	li	a5,-3
ffffffffc02010a6:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010aa:	6d10                	ld	a2,24(a0)
ffffffffc02010ac:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02010ae:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02010b0:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010b2:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010b4:	e390                	sd	a2,0(a5)
ffffffffc02010b6:	b775                	j	ffffffffc0201062 <default_free_pages+0xae>
ffffffffc02010b8:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010ba:	873e                	mv	a4,a5
ffffffffc02010bc:	b761                	j	ffffffffc0201044 <default_free_pages+0x90>
}
ffffffffc02010be:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02010c0:	e390                	sd	a2,0(a5)
ffffffffc02010c2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010c4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010c6:	ed1c                	sd	a5,24(a0)
ffffffffc02010c8:	0141                	addi	sp,sp,16
ffffffffc02010ca:	8082                	ret
            base->property += p->property;
ffffffffc02010cc:	ff872783          	lw	a5,-8(a4)
ffffffffc02010d0:	ff070693          	addi	a3,a4,-16
ffffffffc02010d4:	9dbd                	addw	a1,a1,a5
ffffffffc02010d6:	c90c                	sw	a1,16(a0)
ffffffffc02010d8:	57f5                	li	a5,-3
ffffffffc02010da:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010de:	6314                	ld	a3,0(a4)
ffffffffc02010e0:	671c                	ld	a5,8(a4)
}
ffffffffc02010e2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010e4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02010e6:	e394                	sd	a3,0(a5)
ffffffffc02010e8:	0141                	addi	sp,sp,16
ffffffffc02010ea:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010ec:	00001697          	auipc	a3,0x1
ffffffffc02010f0:	45468693          	addi	a3,a3,1108 # ffffffffc0202540 <commands+0x868>
ffffffffc02010f4:	00001617          	auipc	a2,0x1
ffffffffc02010f8:	0ec60613          	addi	a2,a2,236 # ffffffffc02021e0 <commands+0x508>
ffffffffc02010fc:	08200593          	li	a1,130
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	0f850513          	addi	a0,a0,248 # ffffffffc02021f8 <commands+0x520>
ffffffffc0201108:	aa4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020110c:	00001697          	auipc	a3,0x1
ffffffffc0201110:	42c68693          	addi	a3,a3,1068 # ffffffffc0202538 <commands+0x860>
ffffffffc0201114:	00001617          	auipc	a2,0x1
ffffffffc0201118:	0cc60613          	addi	a2,a2,204 # ffffffffc02021e0 <commands+0x508>
ffffffffc020111c:	07f00593          	li	a1,127
ffffffffc0201120:	00001517          	auipc	a0,0x1
ffffffffc0201124:	0d850513          	addi	a0,a0,216 # ffffffffc02021f8 <commands+0x520>
ffffffffc0201128:	a84ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020112c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020112c:	c959                	beqz	a0,ffffffffc02011c2 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020112e:	00005597          	auipc	a1,0x5
ffffffffc0201132:	ee258593          	addi	a1,a1,-286 # ffffffffc0206010 <free_area>
ffffffffc0201136:	0105a803          	lw	a6,16(a1)
ffffffffc020113a:	862a                	mv	a2,a0
ffffffffc020113c:	02081793          	slli	a5,a6,0x20
ffffffffc0201140:	9381                	srli	a5,a5,0x20
ffffffffc0201142:	00a7ee63          	bltu	a5,a0,ffffffffc020115e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201146:	87ae                	mv	a5,a1
ffffffffc0201148:	a801                	j	ffffffffc0201158 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020114a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020114e:	02071693          	slli	a3,a4,0x20
ffffffffc0201152:	9281                	srli	a3,a3,0x20
ffffffffc0201154:	00c6f763          	bgeu	a3,a2,ffffffffc0201162 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201158:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020115a:	feb798e3          	bne	a5,a1,ffffffffc020114a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020115e:	4501                	li	a0,0
}
ffffffffc0201160:	8082                	ret
    return listelm->prev;
ffffffffc0201162:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201166:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020116a:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020116e:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201172:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201176:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020117a:	02d67b63          	bgeu	a2,a3,ffffffffc02011b0 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020117e:	00261693          	slli	a3,a2,0x2
ffffffffc0201182:	96b2                	add	a3,a3,a2
ffffffffc0201184:	068e                	slli	a3,a3,0x3
ffffffffc0201186:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201188:	41c7073b          	subw	a4,a4,t3
ffffffffc020118c:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020118e:	00868613          	addi	a2,a3,8
ffffffffc0201192:	4709                	li	a4,2
ffffffffc0201194:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201198:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020119c:	01868613          	addi	a2,a3,24
        nr_free -= n;
ffffffffc02011a0:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02011a4:	e310                	sd	a2,0(a4)
ffffffffc02011a6:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02011aa:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc02011ac:	0116bc23          	sd	a7,24(a3)
ffffffffc02011b0:	41c8083b          	subw	a6,a6,t3
ffffffffc02011b4:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02011b8:	5775                	li	a4,-3
ffffffffc02011ba:	17c1                	addi	a5,a5,-16
ffffffffc02011bc:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02011c0:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02011c2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02011c4:	00001697          	auipc	a3,0x1
ffffffffc02011c8:	37468693          	addi	a3,a3,884 # ffffffffc0202538 <commands+0x860>
ffffffffc02011cc:	00001617          	auipc	a2,0x1
ffffffffc02011d0:	01460613          	addi	a2,a2,20 # ffffffffc02021e0 <commands+0x508>
ffffffffc02011d4:	06100593          	li	a1,97
ffffffffc02011d8:	00001517          	auipc	a0,0x1
ffffffffc02011dc:	02050513          	addi	a0,a0,32 # ffffffffc02021f8 <commands+0x520>
default_alloc_pages(size_t n) {
ffffffffc02011e0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011e2:	9caff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011e6 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02011e6:	1141                	addi	sp,sp,-16
ffffffffc02011e8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011ea:	c9e1                	beqz	a1,ffffffffc02012ba <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02011ec:	00259693          	slli	a3,a1,0x2
ffffffffc02011f0:	96ae                	add	a3,a3,a1
ffffffffc02011f2:	068e                	slli	a3,a3,0x3
ffffffffc02011f4:	96aa                	add	a3,a3,a0
ffffffffc02011f6:	87aa                	mv	a5,a0
ffffffffc02011f8:	00d50f63          	beq	a0,a3,ffffffffc0201216 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011fc:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02011fe:	8b05                	andi	a4,a4,1
ffffffffc0201200:	cf49                	beqz	a4,ffffffffc020129a <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201202:	0007a823          	sw	zero,16(a5)
ffffffffc0201206:	0007b423          	sd	zero,8(a5)
ffffffffc020120a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020120e:	02878793          	addi	a5,a5,40
ffffffffc0201212:	fed795e3          	bne	a5,a3,ffffffffc02011fc <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201216:	2581                	sext.w	a1,a1
ffffffffc0201218:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020121a:	4789                	li	a5,2
ffffffffc020121c:	00850713          	addi	a4,a0,8
ffffffffc0201220:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201224:	00005697          	auipc	a3,0x5
ffffffffc0201228:	dec68693          	addi	a3,a3,-532 # ffffffffc0206010 <free_area>
ffffffffc020122c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020122e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201230:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201234:	9db9                	addw	a1,a1,a4
ffffffffc0201236:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201238:	04d78a63          	beq	a5,a3,ffffffffc020128c <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020123c:	fe878713          	addi	a4,a5,-24
ffffffffc0201240:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201244:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201246:	00e56a63          	bltu	a0,a4,ffffffffc020125a <default_init_memmap+0x74>
    return listelm->next;
ffffffffc020124a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020124c:	02d70263          	beq	a4,a3,ffffffffc0201270 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201250:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201252:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201256:	fee57ae3          	bgeu	a0,a4,ffffffffc020124a <default_init_memmap+0x64>
ffffffffc020125a:	c199                	beqz	a1,ffffffffc0201260 <default_init_memmap+0x7a>
ffffffffc020125c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201260:	6398                	ld	a4,0(a5)
}
ffffffffc0201262:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201264:	e390                	sd	a2,0(a5)
ffffffffc0201266:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201268:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020126a:	ed18                	sd	a4,24(a0)
ffffffffc020126c:	0141                	addi	sp,sp,16
ffffffffc020126e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201270:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201272:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201274:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201276:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201278:	00d70663          	beq	a4,a3,ffffffffc0201284 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020127c:	8832                	mv	a6,a2
ffffffffc020127e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201280:	87ba                	mv	a5,a4
ffffffffc0201282:	bfc1                	j	ffffffffc0201252 <default_init_memmap+0x6c>
}
ffffffffc0201284:	60a2                	ld	ra,8(sp)
ffffffffc0201286:	e290                	sd	a2,0(a3)
ffffffffc0201288:	0141                	addi	sp,sp,16
ffffffffc020128a:	8082                	ret
ffffffffc020128c:	60a2                	ld	ra,8(sp)
ffffffffc020128e:	e390                	sd	a2,0(a5)
ffffffffc0201290:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201292:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201294:	ed1c                	sd	a5,24(a0)
ffffffffc0201296:	0141                	addi	sp,sp,16
ffffffffc0201298:	8082                	ret
        assert(PageReserved(p));
ffffffffc020129a:	00001697          	auipc	a3,0x1
ffffffffc020129e:	2ce68693          	addi	a3,a3,718 # ffffffffc0202568 <commands+0x890>
ffffffffc02012a2:	00001617          	auipc	a2,0x1
ffffffffc02012a6:	f3e60613          	addi	a2,a2,-194 # ffffffffc02021e0 <commands+0x508>
ffffffffc02012aa:	04800593          	li	a1,72
ffffffffc02012ae:	00001517          	auipc	a0,0x1
ffffffffc02012b2:	f4a50513          	addi	a0,a0,-182 # ffffffffc02021f8 <commands+0x520>
ffffffffc02012b6:	8f6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02012ba:	00001697          	auipc	a3,0x1
ffffffffc02012be:	27e68693          	addi	a3,a3,638 # ffffffffc0202538 <commands+0x860>
ffffffffc02012c2:	00001617          	auipc	a2,0x1
ffffffffc02012c6:	f1e60613          	addi	a2,a2,-226 # ffffffffc02021e0 <commands+0x508>
ffffffffc02012ca:	04500593          	li	a1,69
ffffffffc02012ce:	00001517          	auipc	a0,0x1
ffffffffc02012d2:	f2a50513          	addi	a0,a0,-214 # ffffffffc02021f8 <commands+0x520>
ffffffffc02012d6:	8d6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012da <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012da:	100027f3          	csrr	a5,sstatus
ffffffffc02012de:	8b89                	andi	a5,a5,2
ffffffffc02012e0:	e799                	bnez	a5,ffffffffc02012ee <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012e2:	00005797          	auipc	a5,0x5
ffffffffc02012e6:	1667b783          	ld	a5,358(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012ea:	6f9c                	ld	a5,24(a5)
ffffffffc02012ec:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02012ee:	1141                	addi	sp,sp,-16
ffffffffc02012f0:	e406                	sd	ra,8(sp)
ffffffffc02012f2:	e022                	sd	s0,0(sp)
ffffffffc02012f4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012f6:	968ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012fa:	00005797          	auipc	a5,0x5
ffffffffc02012fe:	14e7b783          	ld	a5,334(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201302:	6f9c                	ld	a5,24(a5)
ffffffffc0201304:	8522                	mv	a0,s0
ffffffffc0201306:	9782                	jalr	a5
ffffffffc0201308:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020130a:	94eff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020130e:	60a2                	ld	ra,8(sp)
ffffffffc0201310:	8522                	mv	a0,s0
ffffffffc0201312:	6402                	ld	s0,0(sp)
ffffffffc0201314:	0141                	addi	sp,sp,16
ffffffffc0201316:	8082                	ret

ffffffffc0201318 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201318:	100027f3          	csrr	a5,sstatus
ffffffffc020131c:	8b89                	andi	a5,a5,2
ffffffffc020131e:	e799                	bnez	a5,ffffffffc020132c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201320:	00005797          	auipc	a5,0x5
ffffffffc0201324:	1287b783          	ld	a5,296(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201328:	739c                	ld	a5,32(a5)
ffffffffc020132a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020132c:	1101                	addi	sp,sp,-32
ffffffffc020132e:	ec06                	sd	ra,24(sp)
ffffffffc0201330:	e822                	sd	s0,16(sp)
ffffffffc0201332:	e426                	sd	s1,8(sp)
ffffffffc0201334:	842a                	mv	s0,a0
ffffffffc0201336:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201338:	926ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020133c:	00005797          	auipc	a5,0x5
ffffffffc0201340:	10c7b783          	ld	a5,268(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201344:	739c                	ld	a5,32(a5)
ffffffffc0201346:	85a6                	mv	a1,s1
ffffffffc0201348:	8522                	mv	a0,s0
ffffffffc020134a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020134c:	6442                	ld	s0,16(sp)
ffffffffc020134e:	60e2                	ld	ra,24(sp)
ffffffffc0201350:	64a2                	ld	s1,8(sp)
ffffffffc0201352:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201354:	904ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201358 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201358:	100027f3          	csrr	a5,sstatus
ffffffffc020135c:	8b89                	andi	a5,a5,2
ffffffffc020135e:	e799                	bnez	a5,ffffffffc020136c <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201360:	00005797          	auipc	a5,0x5
ffffffffc0201364:	0e87b783          	ld	a5,232(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201368:	779c                	ld	a5,40(a5)
ffffffffc020136a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020136c:	1141                	addi	sp,sp,-16
ffffffffc020136e:	e406                	sd	ra,8(sp)
ffffffffc0201370:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201372:	8ecff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201376:	00005797          	auipc	a5,0x5
ffffffffc020137a:	0d27b783          	ld	a5,210(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020137e:	779c                	ld	a5,40(a5)
ffffffffc0201380:	9782                	jalr	a5
ffffffffc0201382:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201384:	8d4ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201388:	60a2                	ld	ra,8(sp)
ffffffffc020138a:	8522                	mv	a0,s0
ffffffffc020138c:	6402                	ld	s0,0(sp)
ffffffffc020138e:	0141                	addi	sp,sp,16
ffffffffc0201390:	8082                	ret

ffffffffc0201392 <pmm_init>:
    pmm_manager=&default_pmm_manager;
ffffffffc0201392:	00001797          	auipc	a5,0x1
ffffffffc0201396:	1fe78793          	addi	a5,a5,510 # ffffffffc0202590 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020139a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020139c:	1101                	addi	sp,sp,-32
ffffffffc020139e:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013a0:	00001517          	auipc	a0,0x1
ffffffffc02013a4:	22850513          	addi	a0,a0,552 # ffffffffc02025c8 <default_pmm_manager+0x38>
    pmm_manager=&default_pmm_manager;
ffffffffc02013a8:	00005497          	auipc	s1,0x5
ffffffffc02013ac:	0a048493          	addi	s1,s1,160 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02013b0:	ec06                	sd	ra,24(sp)
ffffffffc02013b2:	e822                	sd	s0,16(sp)
    pmm_manager=&default_pmm_manager;
ffffffffc02013b4:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013b6:	cfdfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02013ba:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013bc:	00005417          	auipc	s0,0x5
ffffffffc02013c0:	0a440413          	addi	s0,s0,164 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02013c4:	679c                	ld	a5,8(a5)
ffffffffc02013c6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013c8:	57f5                	li	a5,-3
ffffffffc02013ca:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013cc:	00001517          	auipc	a0,0x1
ffffffffc02013d0:	21450513          	addi	a0,a0,532 # ffffffffc02025e0 <default_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013d4:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02013d6:	cddfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013da:	46c5                	li	a3,17
ffffffffc02013dc:	06ee                	slli	a3,a3,0x1b
ffffffffc02013de:	40100613          	li	a2,1025
ffffffffc02013e2:	16fd                	addi	a3,a3,-1
ffffffffc02013e4:	07e005b7          	lui	a1,0x7e00
ffffffffc02013e8:	0656                	slli	a2,a2,0x15
ffffffffc02013ea:	00001517          	auipc	a0,0x1
ffffffffc02013ee:	20e50513          	addi	a0,a0,526 # ffffffffc02025f8 <default_pmm_manager+0x68>
ffffffffc02013f2:	cc1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013f6:	777d                	lui	a4,0xfffff
ffffffffc02013f8:	00006797          	auipc	a5,0x6
ffffffffc02013fc:	07778793          	addi	a5,a5,119 # ffffffffc020746f <end+0xfff>
ffffffffc0201400:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201402:	00005517          	auipc	a0,0x5
ffffffffc0201406:	03650513          	addi	a0,a0,54 # ffffffffc0206438 <npage>
ffffffffc020140a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020140e:	00005597          	auipc	a1,0x5
ffffffffc0201412:	03258593          	addi	a1,a1,50 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201416:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201418:	e19c                	sd	a5,0(a1)
ffffffffc020141a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020141c:	4701                	li	a4,0
ffffffffc020141e:	4885                	li	a7,1
ffffffffc0201420:	fff80837          	lui	a6,0xfff80
ffffffffc0201424:	a011                	j	ffffffffc0201428 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201426:	619c                	ld	a5,0(a1)
ffffffffc0201428:	97b6                	add	a5,a5,a3
ffffffffc020142a:	07a1                	addi	a5,a5,8
ffffffffc020142c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201430:	611c                	ld	a5,0(a0)
ffffffffc0201432:	0705                	addi	a4,a4,1
ffffffffc0201434:	02868693          	addi	a3,a3,40
ffffffffc0201438:	01078633          	add	a2,a5,a6
ffffffffc020143c:	fec765e3          	bltu	a4,a2,ffffffffc0201426 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201440:	6190                	ld	a2,0(a1)
ffffffffc0201442:	00279713          	slli	a4,a5,0x2
ffffffffc0201446:	973e                	add	a4,a4,a5
ffffffffc0201448:	fec006b7          	lui	a3,0xfec00
ffffffffc020144c:	070e                	slli	a4,a4,0x3
ffffffffc020144e:	96b2                	add	a3,a3,a2
ffffffffc0201450:	96ba                	add	a3,a3,a4
ffffffffc0201452:	c0200737          	lui	a4,0xc0200
ffffffffc0201456:	08e6ef63          	bltu	a3,a4,ffffffffc02014f4 <pmm_init+0x162>
ffffffffc020145a:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020145c:	45c5                	li	a1,17
ffffffffc020145e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201460:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201462:	04b6e863          	bltu	a3,a1,ffffffffc02014b2 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201466:	609c                	ld	a5,0(s1)
ffffffffc0201468:	7b9c                	ld	a5,48(a5)
ffffffffc020146a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020146c:	00001517          	auipc	a0,0x1
ffffffffc0201470:	22450513          	addi	a0,a0,548 # ffffffffc0202690 <default_pmm_manager+0x100>
ffffffffc0201474:	c3ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201478:	00004597          	auipc	a1,0x4
ffffffffc020147c:	b8858593          	addi	a1,a1,-1144 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201480:	00005797          	auipc	a5,0x5
ffffffffc0201484:	fcb7bc23          	sd	a1,-40(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201488:	c02007b7          	lui	a5,0xc0200
ffffffffc020148c:	08f5e063          	bltu	a1,a5,ffffffffc020150c <pmm_init+0x17a>
ffffffffc0201490:	6010                	ld	a2,0(s0)
}
ffffffffc0201492:	6442                	ld	s0,16(sp)
ffffffffc0201494:	60e2                	ld	ra,24(sp)
ffffffffc0201496:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201498:	40c58633          	sub	a2,a1,a2
ffffffffc020149c:	00005797          	auipc	a5,0x5
ffffffffc02014a0:	fac7ba23          	sd	a2,-76(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014a4:	00001517          	auipc	a0,0x1
ffffffffc02014a8:	20c50513          	addi	a0,a0,524 # ffffffffc02026b0 <default_pmm_manager+0x120>
}
ffffffffc02014ac:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014ae:	c05fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014b2:	6705                	lui	a4,0x1
ffffffffc02014b4:	177d                	addi	a4,a4,-1
ffffffffc02014b6:	96ba                	add	a3,a3,a4
ffffffffc02014b8:	777d                	lui	a4,0xfffff
ffffffffc02014ba:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014bc:	00c6d513          	srli	a0,a3,0xc
ffffffffc02014c0:	00f57e63          	bgeu	a0,a5,ffffffffc02014dc <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02014c4:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02014c6:	982a                	add	a6,a6,a0
ffffffffc02014c8:	00281513          	slli	a0,a6,0x2
ffffffffc02014cc:	9542                	add	a0,a0,a6
ffffffffc02014ce:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014d0:	8d95                	sub	a1,a1,a3
ffffffffc02014d2:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014d4:	81b1                	srli	a1,a1,0xc
ffffffffc02014d6:	9532                	add	a0,a0,a2
ffffffffc02014d8:	9782                	jalr	a5
}
ffffffffc02014da:	b771                	j	ffffffffc0201466 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02014dc:	00001617          	auipc	a2,0x1
ffffffffc02014e0:	18460613          	addi	a2,a2,388 # ffffffffc0202660 <default_pmm_manager+0xd0>
ffffffffc02014e4:	06b00593          	li	a1,107
ffffffffc02014e8:	00001517          	auipc	a0,0x1
ffffffffc02014ec:	19850513          	addi	a0,a0,408 # ffffffffc0202680 <default_pmm_manager+0xf0>
ffffffffc02014f0:	ebdfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014f4:	00001617          	auipc	a2,0x1
ffffffffc02014f8:	13460613          	addi	a2,a2,308 # ffffffffc0202628 <default_pmm_manager+0x98>
ffffffffc02014fc:	07200593          	li	a1,114
ffffffffc0201500:	00001517          	auipc	a0,0x1
ffffffffc0201504:	15050513          	addi	a0,a0,336 # ffffffffc0202650 <default_pmm_manager+0xc0>
ffffffffc0201508:	ea5fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020150c:	86ae                	mv	a3,a1
ffffffffc020150e:	00001617          	auipc	a2,0x1
ffffffffc0201512:	11a60613          	addi	a2,a2,282 # ffffffffc0202628 <default_pmm_manager+0x98>
ffffffffc0201516:	08d00593          	li	a1,141
ffffffffc020151a:	00001517          	auipc	a0,0x1
ffffffffc020151e:	13650513          	addi	a0,a0,310 # ffffffffc0202650 <default_pmm_manager+0xc0>
ffffffffc0201522:	e8bfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201526 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201526:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020152a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020152c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201530:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201532:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201536:	f022                	sd	s0,32(sp)
ffffffffc0201538:	ec26                	sd	s1,24(sp)
ffffffffc020153a:	e84a                	sd	s2,16(sp)
ffffffffc020153c:	f406                	sd	ra,40(sp)
ffffffffc020153e:	e44e                	sd	s3,8(sp)
ffffffffc0201540:	84aa                	mv	s1,a0
ffffffffc0201542:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201544:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201548:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020154a:	03067e63          	bgeu	a2,a6,ffffffffc0201586 <printnum+0x60>
ffffffffc020154e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201550:	00805763          	blez	s0,ffffffffc020155e <printnum+0x38>
ffffffffc0201554:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201556:	85ca                	mv	a1,s2
ffffffffc0201558:	854e                	mv	a0,s3
ffffffffc020155a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020155c:	fc65                	bnez	s0,ffffffffc0201554 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020155e:	1a02                	slli	s4,s4,0x20
ffffffffc0201560:	00001797          	auipc	a5,0x1
ffffffffc0201564:	19078793          	addi	a5,a5,400 # ffffffffc02026f0 <default_pmm_manager+0x160>
ffffffffc0201568:	020a5a13          	srli	s4,s4,0x20
ffffffffc020156c:	9a3e                	add	s4,s4,a5
}
ffffffffc020156e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201570:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201574:	70a2                	ld	ra,40(sp)
ffffffffc0201576:	69a2                	ld	s3,8(sp)
ffffffffc0201578:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020157a:	85ca                	mv	a1,s2
ffffffffc020157c:	87a6                	mv	a5,s1
}
ffffffffc020157e:	6942                	ld	s2,16(sp)
ffffffffc0201580:	64e2                	ld	s1,24(sp)
ffffffffc0201582:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201584:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201586:	03065633          	divu	a2,a2,a6
ffffffffc020158a:	8722                	mv	a4,s0
ffffffffc020158c:	f9bff0ef          	jal	ra,ffffffffc0201526 <printnum>
ffffffffc0201590:	b7f9                	j	ffffffffc020155e <printnum+0x38>

ffffffffc0201592 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201592:	7119                	addi	sp,sp,-128
ffffffffc0201594:	f4a6                	sd	s1,104(sp)
ffffffffc0201596:	f0ca                	sd	s2,96(sp)
ffffffffc0201598:	ecce                	sd	s3,88(sp)
ffffffffc020159a:	e8d2                	sd	s4,80(sp)
ffffffffc020159c:	e4d6                	sd	s5,72(sp)
ffffffffc020159e:	e0da                	sd	s6,64(sp)
ffffffffc02015a0:	fc5e                	sd	s7,56(sp)
ffffffffc02015a2:	f06a                	sd	s10,32(sp)
ffffffffc02015a4:	fc86                	sd	ra,120(sp)
ffffffffc02015a6:	f8a2                	sd	s0,112(sp)
ffffffffc02015a8:	f862                	sd	s8,48(sp)
ffffffffc02015aa:	f466                	sd	s9,40(sp)
ffffffffc02015ac:	ec6e                	sd	s11,24(sp)
ffffffffc02015ae:	892a                	mv	s2,a0
ffffffffc02015b0:	84ae                	mv	s1,a1
ffffffffc02015b2:	8d32                	mv	s10,a2
ffffffffc02015b4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015b6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015ba:	5b7d                	li	s6,-1
ffffffffc02015bc:	00001a97          	auipc	s5,0x1
ffffffffc02015c0:	168a8a93          	addi	s5,s5,360 # ffffffffc0202724 <default_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015c4:	00001b97          	auipc	s7,0x1
ffffffffc02015c8:	33cb8b93          	addi	s7,s7,828 # ffffffffc0202900 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015cc:	000d4503          	lbu	a0,0(s10)
ffffffffc02015d0:	001d0413          	addi	s0,s10,1
ffffffffc02015d4:	01350a63          	beq	a0,s3,ffffffffc02015e8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02015d8:	c121                	beqz	a0,ffffffffc0201618 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02015da:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015dc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02015de:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015e0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02015e4:	ff351ae3          	bne	a0,s3,ffffffffc02015d8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015e8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02015ec:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02015f0:	4c81                	li	s9,0
ffffffffc02015f2:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02015f4:	5c7d                	li	s8,-1
ffffffffc02015f6:	5dfd                	li	s11,-1
ffffffffc02015f8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02015fc:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015fe:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201602:	0ff5f593          	zext.b	a1,a1
ffffffffc0201606:	00140d13          	addi	s10,s0,1
ffffffffc020160a:	04b56263          	bltu	a0,a1,ffffffffc020164e <vprintfmt+0xbc>
ffffffffc020160e:	058a                	slli	a1,a1,0x2
ffffffffc0201610:	95d6                	add	a1,a1,s5
ffffffffc0201612:	4194                	lw	a3,0(a1)
ffffffffc0201614:	96d6                	add	a3,a3,s5
ffffffffc0201616:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201618:	70e6                	ld	ra,120(sp)
ffffffffc020161a:	7446                	ld	s0,112(sp)
ffffffffc020161c:	74a6                	ld	s1,104(sp)
ffffffffc020161e:	7906                	ld	s2,96(sp)
ffffffffc0201620:	69e6                	ld	s3,88(sp)
ffffffffc0201622:	6a46                	ld	s4,80(sp)
ffffffffc0201624:	6aa6                	ld	s5,72(sp)
ffffffffc0201626:	6b06                	ld	s6,64(sp)
ffffffffc0201628:	7be2                	ld	s7,56(sp)
ffffffffc020162a:	7c42                	ld	s8,48(sp)
ffffffffc020162c:	7ca2                	ld	s9,40(sp)
ffffffffc020162e:	7d02                	ld	s10,32(sp)
ffffffffc0201630:	6de2                	ld	s11,24(sp)
ffffffffc0201632:	6109                	addi	sp,sp,128
ffffffffc0201634:	8082                	ret
            padc = '0';
ffffffffc0201636:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201638:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020163c:	846a                	mv	s0,s10
ffffffffc020163e:	00140d13          	addi	s10,s0,1
ffffffffc0201642:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201646:	0ff5f593          	zext.b	a1,a1
ffffffffc020164a:	fcb572e3          	bgeu	a0,a1,ffffffffc020160e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020164e:	85a6                	mv	a1,s1
ffffffffc0201650:	02500513          	li	a0,37
ffffffffc0201654:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201656:	fff44783          	lbu	a5,-1(s0)
ffffffffc020165a:	8d22                	mv	s10,s0
ffffffffc020165c:	f73788e3          	beq	a5,s3,ffffffffc02015cc <vprintfmt+0x3a>
ffffffffc0201660:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201664:	1d7d                	addi	s10,s10,-1
ffffffffc0201666:	ff379de3          	bne	a5,s3,ffffffffc0201660 <vprintfmt+0xce>
ffffffffc020166a:	b78d                	j	ffffffffc02015cc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020166c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201670:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201674:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201676:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020167a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020167e:	02d86463          	bltu	a6,a3,ffffffffc02016a6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201682:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201686:	002c169b          	slliw	a3,s8,0x2
ffffffffc020168a:	0186873b          	addw	a4,a3,s8
ffffffffc020168e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201692:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201694:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201698:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020169a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020169e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016a2:	fed870e3          	bgeu	a6,a3,ffffffffc0201682 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02016a6:	f40ddce3          	bgez	s11,ffffffffc02015fe <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02016aa:	8de2                	mv	s11,s8
ffffffffc02016ac:	5c7d                	li	s8,-1
ffffffffc02016ae:	bf81                	j	ffffffffc02015fe <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02016b0:	fffdc693          	not	a3,s11
ffffffffc02016b4:	96fd                	srai	a3,a3,0x3f
ffffffffc02016b6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ba:	00144603          	lbu	a2,1(s0)
ffffffffc02016be:	2d81                	sext.w	s11,s11
ffffffffc02016c0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016c2:	bf35                	j	ffffffffc02015fe <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02016c4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016c8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02016cc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ce:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02016d0:	bfd9                	j	ffffffffc02016a6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02016d2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016d4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016d8:	01174463          	blt	a4,a7,ffffffffc02016e0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02016dc:	1a088e63          	beqz	a7,ffffffffc0201898 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02016e0:	000a3603          	ld	a2,0(s4)
ffffffffc02016e4:	46c1                	li	a3,16
ffffffffc02016e6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02016e8:	2781                	sext.w	a5,a5
ffffffffc02016ea:	876e                	mv	a4,s11
ffffffffc02016ec:	85a6                	mv	a1,s1
ffffffffc02016ee:	854a                	mv	a0,s2
ffffffffc02016f0:	e37ff0ef          	jal	ra,ffffffffc0201526 <printnum>
            break;
ffffffffc02016f4:	bde1                	j	ffffffffc02015cc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02016f6:	000a2503          	lw	a0,0(s4)
ffffffffc02016fa:	85a6                	mv	a1,s1
ffffffffc02016fc:	0a21                	addi	s4,s4,8
ffffffffc02016fe:	9902                	jalr	s2
            break;
ffffffffc0201700:	b5f1                	j	ffffffffc02015cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201702:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201704:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201708:	01174463          	blt	a4,a7,ffffffffc0201710 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020170c:	18088163          	beqz	a7,ffffffffc020188e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201710:	000a3603          	ld	a2,0(s4)
ffffffffc0201714:	46a9                	li	a3,10
ffffffffc0201716:	8a2e                	mv	s4,a1
ffffffffc0201718:	bfc1                	j	ffffffffc02016e8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020171a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020171e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201720:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201722:	bdf1                	j	ffffffffc02015fe <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201724:	85a6                	mv	a1,s1
ffffffffc0201726:	02500513          	li	a0,37
ffffffffc020172a:	9902                	jalr	s2
            break;
ffffffffc020172c:	b545                	j	ffffffffc02015cc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020172e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201732:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201734:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201736:	b5e1                	j	ffffffffc02015fe <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201738:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020173a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020173e:	01174463          	blt	a4,a7,ffffffffc0201746 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201742:	14088163          	beqz	a7,ffffffffc0201884 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201746:	000a3603          	ld	a2,0(s4)
ffffffffc020174a:	46a1                	li	a3,8
ffffffffc020174c:	8a2e                	mv	s4,a1
ffffffffc020174e:	bf69                	j	ffffffffc02016e8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201750:	03000513          	li	a0,48
ffffffffc0201754:	85a6                	mv	a1,s1
ffffffffc0201756:	e03e                	sd	a5,0(sp)
ffffffffc0201758:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020175a:	85a6                	mv	a1,s1
ffffffffc020175c:	07800513          	li	a0,120
ffffffffc0201760:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201762:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201764:	6782                	ld	a5,0(sp)
ffffffffc0201766:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201768:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020176c:	bfb5                	j	ffffffffc02016e8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020176e:	000a3403          	ld	s0,0(s4)
ffffffffc0201772:	008a0713          	addi	a4,s4,8
ffffffffc0201776:	e03a                	sd	a4,0(sp)
ffffffffc0201778:	14040263          	beqz	s0,ffffffffc02018bc <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020177c:	0fb05763          	blez	s11,ffffffffc020186a <vprintfmt+0x2d8>
ffffffffc0201780:	02d00693          	li	a3,45
ffffffffc0201784:	0cd79163          	bne	a5,a3,ffffffffc0201846 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201788:	00044783          	lbu	a5,0(s0)
ffffffffc020178c:	0007851b          	sext.w	a0,a5
ffffffffc0201790:	cf85                	beqz	a5,ffffffffc02017c8 <vprintfmt+0x236>
ffffffffc0201792:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201796:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020179a:	000c4563          	bltz	s8,ffffffffc02017a4 <vprintfmt+0x212>
ffffffffc020179e:	3c7d                	addiw	s8,s8,-1
ffffffffc02017a0:	036c0263          	beq	s8,s6,ffffffffc02017c4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02017a4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017a6:	0e0c8e63          	beqz	s9,ffffffffc02018a2 <vprintfmt+0x310>
ffffffffc02017aa:	3781                	addiw	a5,a5,-32
ffffffffc02017ac:	0ef47b63          	bgeu	s0,a5,ffffffffc02018a2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02017b0:	03f00513          	li	a0,63
ffffffffc02017b4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017b6:	000a4783          	lbu	a5,0(s4)
ffffffffc02017ba:	3dfd                	addiw	s11,s11,-1
ffffffffc02017bc:	0a05                	addi	s4,s4,1
ffffffffc02017be:	0007851b          	sext.w	a0,a5
ffffffffc02017c2:	ffe1                	bnez	a5,ffffffffc020179a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02017c4:	01b05963          	blez	s11,ffffffffc02017d6 <vprintfmt+0x244>
ffffffffc02017c8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017ca:	85a6                	mv	a1,s1
ffffffffc02017cc:	02000513          	li	a0,32
ffffffffc02017d0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017d2:	fe0d9be3          	bnez	s11,ffffffffc02017c8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017d6:	6a02                	ld	s4,0(sp)
ffffffffc02017d8:	bbd5                	j	ffffffffc02015cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017da:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017dc:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02017e0:	01174463          	blt	a4,a7,ffffffffc02017e8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02017e4:	08088d63          	beqz	a7,ffffffffc020187e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02017e8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02017ec:	0a044d63          	bltz	s0,ffffffffc02018a6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02017f0:	8622                	mv	a2,s0
ffffffffc02017f2:	8a66                	mv	s4,s9
ffffffffc02017f4:	46a9                	li	a3,10
ffffffffc02017f6:	bdcd                	j	ffffffffc02016e8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02017f8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017fc:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017fe:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201800:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201804:	8fb5                	xor	a5,a5,a3
ffffffffc0201806:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020180a:	02d74163          	blt	a4,a3,ffffffffc020182c <vprintfmt+0x29a>
ffffffffc020180e:	00369793          	slli	a5,a3,0x3
ffffffffc0201812:	97de                	add	a5,a5,s7
ffffffffc0201814:	639c                	ld	a5,0(a5)
ffffffffc0201816:	cb99                	beqz	a5,ffffffffc020182c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201818:	86be                	mv	a3,a5
ffffffffc020181a:	00001617          	auipc	a2,0x1
ffffffffc020181e:	f0660613          	addi	a2,a2,-250 # ffffffffc0202720 <default_pmm_manager+0x190>
ffffffffc0201822:	85a6                	mv	a1,s1
ffffffffc0201824:	854a                	mv	a0,s2
ffffffffc0201826:	0ce000ef          	jal	ra,ffffffffc02018f4 <printfmt>
ffffffffc020182a:	b34d                	j	ffffffffc02015cc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020182c:	00001617          	auipc	a2,0x1
ffffffffc0201830:	ee460613          	addi	a2,a2,-284 # ffffffffc0202710 <default_pmm_manager+0x180>
ffffffffc0201834:	85a6                	mv	a1,s1
ffffffffc0201836:	854a                	mv	a0,s2
ffffffffc0201838:	0bc000ef          	jal	ra,ffffffffc02018f4 <printfmt>
ffffffffc020183c:	bb41                	j	ffffffffc02015cc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020183e:	00001417          	auipc	s0,0x1
ffffffffc0201842:	eca40413          	addi	s0,s0,-310 # ffffffffc0202708 <default_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201846:	85e2                	mv	a1,s8
ffffffffc0201848:	8522                	mv	a0,s0
ffffffffc020184a:	e43e                	sd	a5,8(sp)
ffffffffc020184c:	1cc000ef          	jal	ra,ffffffffc0201a18 <strnlen>
ffffffffc0201850:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201854:	01b05b63          	blez	s11,ffffffffc020186a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201858:	67a2                	ld	a5,8(sp)
ffffffffc020185a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020185e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201860:	85a6                	mv	a1,s1
ffffffffc0201862:	8552                	mv	a0,s4
ffffffffc0201864:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201866:	fe0d9ce3          	bnez	s11,ffffffffc020185e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020186a:	00044783          	lbu	a5,0(s0)
ffffffffc020186e:	00140a13          	addi	s4,s0,1
ffffffffc0201872:	0007851b          	sext.w	a0,a5
ffffffffc0201876:	d3a5                	beqz	a5,ffffffffc02017d6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201878:	05e00413          	li	s0,94
ffffffffc020187c:	bf39                	j	ffffffffc020179a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020187e:	000a2403          	lw	s0,0(s4)
ffffffffc0201882:	b7ad                	j	ffffffffc02017ec <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201884:	000a6603          	lwu	a2,0(s4)
ffffffffc0201888:	46a1                	li	a3,8
ffffffffc020188a:	8a2e                	mv	s4,a1
ffffffffc020188c:	bdb1                	j	ffffffffc02016e8 <vprintfmt+0x156>
ffffffffc020188e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201892:	46a9                	li	a3,10
ffffffffc0201894:	8a2e                	mv	s4,a1
ffffffffc0201896:	bd89                	j	ffffffffc02016e8 <vprintfmt+0x156>
ffffffffc0201898:	000a6603          	lwu	a2,0(s4)
ffffffffc020189c:	46c1                	li	a3,16
ffffffffc020189e:	8a2e                	mv	s4,a1
ffffffffc02018a0:	b5a1                	j	ffffffffc02016e8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02018a2:	9902                	jalr	s2
ffffffffc02018a4:	bf09                	j	ffffffffc02017b6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02018a6:	85a6                	mv	a1,s1
ffffffffc02018a8:	02d00513          	li	a0,45
ffffffffc02018ac:	e03e                	sd	a5,0(sp)
ffffffffc02018ae:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018b0:	6782                	ld	a5,0(sp)
ffffffffc02018b2:	8a66                	mv	s4,s9
ffffffffc02018b4:	40800633          	neg	a2,s0
ffffffffc02018b8:	46a9                	li	a3,10
ffffffffc02018ba:	b53d                	j	ffffffffc02016e8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02018bc:	03b05163          	blez	s11,ffffffffc02018de <vprintfmt+0x34c>
ffffffffc02018c0:	02d00693          	li	a3,45
ffffffffc02018c4:	f6d79de3          	bne	a5,a3,ffffffffc020183e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02018c8:	00001417          	auipc	s0,0x1
ffffffffc02018cc:	e4040413          	addi	s0,s0,-448 # ffffffffc0202708 <default_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018d0:	02800793          	li	a5,40
ffffffffc02018d4:	02800513          	li	a0,40
ffffffffc02018d8:	00140a13          	addi	s4,s0,1
ffffffffc02018dc:	bd6d                	j	ffffffffc0201796 <vprintfmt+0x204>
ffffffffc02018de:	00001a17          	auipc	s4,0x1
ffffffffc02018e2:	e2ba0a13          	addi	s4,s4,-469 # ffffffffc0202709 <default_pmm_manager+0x179>
ffffffffc02018e6:	02800513          	li	a0,40
ffffffffc02018ea:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018ee:	05e00413          	li	s0,94
ffffffffc02018f2:	b565                	j	ffffffffc020179a <vprintfmt+0x208>

ffffffffc02018f4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018f4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02018f6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018fa:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018fc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018fe:	ec06                	sd	ra,24(sp)
ffffffffc0201900:	f83a                	sd	a4,48(sp)
ffffffffc0201902:	fc3e                	sd	a5,56(sp)
ffffffffc0201904:	e0c2                	sd	a6,64(sp)
ffffffffc0201906:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201908:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020190a:	c89ff0ef          	jal	ra,ffffffffc0201592 <vprintfmt>
}
ffffffffc020190e:	60e2                	ld	ra,24(sp)
ffffffffc0201910:	6161                	addi	sp,sp,80
ffffffffc0201912:	8082                	ret

ffffffffc0201914 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201914:	715d                	addi	sp,sp,-80
ffffffffc0201916:	e486                	sd	ra,72(sp)
ffffffffc0201918:	e0a6                	sd	s1,64(sp)
ffffffffc020191a:	fc4a                	sd	s2,56(sp)
ffffffffc020191c:	f84e                	sd	s3,48(sp)
ffffffffc020191e:	f452                	sd	s4,40(sp)
ffffffffc0201920:	f056                	sd	s5,32(sp)
ffffffffc0201922:	ec5a                	sd	s6,24(sp)
ffffffffc0201924:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201926:	c901                	beqz	a0,ffffffffc0201936 <readline+0x22>
ffffffffc0201928:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020192a:	00001517          	auipc	a0,0x1
ffffffffc020192e:	df650513          	addi	a0,a0,-522 # ffffffffc0202720 <default_pmm_manager+0x190>
ffffffffc0201932:	f80fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201936:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201938:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020193a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020193c:	4aa9                	li	s5,10
ffffffffc020193e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201940:	00004b97          	auipc	s7,0x4
ffffffffc0201944:	6e8b8b93          	addi	s7,s7,1768 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201948:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020194c:	fdefe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201950:	00054a63          	bltz	a0,ffffffffc0201964 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201954:	00a95a63          	bge	s2,a0,ffffffffc0201968 <readline+0x54>
ffffffffc0201958:	029a5263          	bge	s4,s1,ffffffffc020197c <readline+0x68>
        c = getchar();
ffffffffc020195c:	fcefe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201960:	fe055ae3          	bgez	a0,ffffffffc0201954 <readline+0x40>
            return NULL;
ffffffffc0201964:	4501                	li	a0,0
ffffffffc0201966:	a091                	j	ffffffffc02019aa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201968:	03351463          	bne	a0,s3,ffffffffc0201990 <readline+0x7c>
ffffffffc020196c:	e8a9                	bnez	s1,ffffffffc02019be <readline+0xaa>
        c = getchar();
ffffffffc020196e:	fbcfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201972:	fe0549e3          	bltz	a0,ffffffffc0201964 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201976:	fea959e3          	bge	s2,a0,ffffffffc0201968 <readline+0x54>
ffffffffc020197a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020197c:	e42a                	sd	a0,8(sp)
ffffffffc020197e:	f6afe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201982:	6522                	ld	a0,8(sp)
ffffffffc0201984:	009b87b3          	add	a5,s7,s1
ffffffffc0201988:	2485                	addiw	s1,s1,1
ffffffffc020198a:	00a78023          	sb	a0,0(a5)
ffffffffc020198e:	bf7d                	j	ffffffffc020194c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201990:	01550463          	beq	a0,s5,ffffffffc0201998 <readline+0x84>
ffffffffc0201994:	fb651ce3          	bne	a0,s6,ffffffffc020194c <readline+0x38>
            cputchar(c);
ffffffffc0201998:	f50fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020199c:	00004517          	auipc	a0,0x4
ffffffffc02019a0:	68c50513          	addi	a0,a0,1676 # ffffffffc0206028 <buf>
ffffffffc02019a4:	94aa                	add	s1,s1,a0
ffffffffc02019a6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019aa:	60a6                	ld	ra,72(sp)
ffffffffc02019ac:	6486                	ld	s1,64(sp)
ffffffffc02019ae:	7962                	ld	s2,56(sp)
ffffffffc02019b0:	79c2                	ld	s3,48(sp)
ffffffffc02019b2:	7a22                	ld	s4,40(sp)
ffffffffc02019b4:	7a82                	ld	s5,32(sp)
ffffffffc02019b6:	6b62                	ld	s6,24(sp)
ffffffffc02019b8:	6bc2                	ld	s7,16(sp)
ffffffffc02019ba:	6161                	addi	sp,sp,80
ffffffffc02019bc:	8082                	ret
            cputchar(c);
ffffffffc02019be:	4521                	li	a0,8
ffffffffc02019c0:	f28fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02019c4:	34fd                	addiw	s1,s1,-1
ffffffffc02019c6:	b759                	j	ffffffffc020194c <readline+0x38>

ffffffffc02019c8 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02019c8:	4781                	li	a5,0
ffffffffc02019ca:	00004717          	auipc	a4,0x4
ffffffffc02019ce:	63e73703          	ld	a4,1598(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02019d2:	88ba                	mv	a7,a4
ffffffffc02019d4:	852a                	mv	a0,a0
ffffffffc02019d6:	85be                	mv	a1,a5
ffffffffc02019d8:	863e                	mv	a2,a5
ffffffffc02019da:	00000073          	ecall
ffffffffc02019de:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02019e0:	8082                	ret

ffffffffc02019e2 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02019e2:	4781                	li	a5,0
ffffffffc02019e4:	00005717          	auipc	a4,0x5
ffffffffc02019e8:	a8473703          	ld	a4,-1404(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc02019ec:	88ba                	mv	a7,a4
ffffffffc02019ee:	852a                	mv	a0,a0
ffffffffc02019f0:	85be                	mv	a1,a5
ffffffffc02019f2:	863e                	mv	a2,a5
ffffffffc02019f4:	00000073          	ecall
ffffffffc02019f8:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02019fa:	8082                	ret

ffffffffc02019fc <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02019fc:	4501                	li	a0,0
ffffffffc02019fe:	00004797          	auipc	a5,0x4
ffffffffc0201a02:	6027b783          	ld	a5,1538(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201a06:	88be                	mv	a7,a5
ffffffffc0201a08:	852a                	mv	a0,a0
ffffffffc0201a0a:	85aa                	mv	a1,a0
ffffffffc0201a0c:	862a                	mv	a2,a0
ffffffffc0201a0e:	00000073          	ecall
ffffffffc0201a12:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a14:	2501                	sext.w	a0,a0
ffffffffc0201a16:	8082                	ret

ffffffffc0201a18 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201a18:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a1a:	e589                	bnez	a1,ffffffffc0201a24 <strnlen+0xc>
ffffffffc0201a1c:	a811                	j	ffffffffc0201a30 <strnlen+0x18>
        cnt ++;
ffffffffc0201a1e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a20:	00f58863          	beq	a1,a5,ffffffffc0201a30 <strnlen+0x18>
ffffffffc0201a24:	00f50733          	add	a4,a0,a5
ffffffffc0201a28:	00074703          	lbu	a4,0(a4)
ffffffffc0201a2c:	fb6d                	bnez	a4,ffffffffc0201a1e <strnlen+0x6>
ffffffffc0201a2e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a30:	852e                	mv	a0,a1
ffffffffc0201a32:	8082                	ret

ffffffffc0201a34 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a34:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a38:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a3c:	cb89                	beqz	a5,ffffffffc0201a4e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a3e:	0505                	addi	a0,a0,1
ffffffffc0201a40:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a42:	fee789e3          	beq	a5,a4,ffffffffc0201a34 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a46:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a4a:	9d19                	subw	a0,a0,a4
ffffffffc0201a4c:	8082                	ret
ffffffffc0201a4e:	4501                	li	a0,0
ffffffffc0201a50:	bfed                	j	ffffffffc0201a4a <strcmp+0x16>

ffffffffc0201a52 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a52:	00054783          	lbu	a5,0(a0)
ffffffffc0201a56:	c799                	beqz	a5,ffffffffc0201a64 <strchr+0x12>
        if (*s == c) {
ffffffffc0201a58:	00f58763          	beq	a1,a5,ffffffffc0201a66 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201a5c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201a60:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201a62:	fbfd                	bnez	a5,ffffffffc0201a58 <strchr+0x6>
    }
    return NULL;
ffffffffc0201a64:	4501                	li	a0,0
}
ffffffffc0201a66:	8082                	ret

ffffffffc0201a68 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a68:	ca01                	beqz	a2,ffffffffc0201a78 <memset+0x10>
ffffffffc0201a6a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a6c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a6e:	0785                	addi	a5,a5,1
ffffffffc0201a70:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a74:	fec79de3          	bne	a5,a2,ffffffffc0201a6e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a78:	8082                	ret
