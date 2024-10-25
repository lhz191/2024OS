
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
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44660613          	addi	a2,a2,1094 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	209010ef          	jal	ra,ffffffffc0201a52 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	a1650513          	addi	a0,a0,-1514 # ffffffffc0201a68 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	2fc010ef          	jal	ra,ffffffffc0201362 <pmm_init>

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
ffffffffc02000a6:	4bc010ef          	jal	ra,ffffffffc0201562 <vprintfmt>
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
ffffffffc02000dc:	486010ef          	jal	ra,ffffffffc0201562 <vprintfmt>
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
ffffffffc0200140:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201a88 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	95650513          	addi	a0,a0,-1706 # ffffffffc0201aa8 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	90658593          	addi	a1,a1,-1786 # ffffffffc0201a64 <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	96250513          	addi	a0,a0,-1694 # ffffffffc0201ac8 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201ae8 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2fa58593          	addi	a1,a1,762 # ffffffffc0206480 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201b08 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6e558593          	addi	a1,a1,1765 # ffffffffc020687f <end+0x3ff>
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
ffffffffc02001c0:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201b28 <etext+0xc4>
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
ffffffffc02001ce:	98e60613          	addi	a2,a2,-1650 # ffffffffc0201b58 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201b70 <etext+0x10c>
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
ffffffffc02001ea:	9a260613          	addi	a2,a2,-1630 # ffffffffc0201b88 <etext+0x124>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	9ba58593          	addi	a1,a1,-1606 # ffffffffc0201ba8 <etext+0x144>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0201bb0 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0201bc0 <etext+0x15c>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	9dc58593          	addi	a1,a1,-1572 # ffffffffc0201be8 <etext+0x184>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	99c50513          	addi	a0,a0,-1636 # ffffffffc0201bb0 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	9d860613          	addi	a2,a2,-1576 # ffffffffc0201bf8 <etext+0x194>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	9f058593          	addi	a1,a1,-1552 # ffffffffc0201c18 <etext+0x1b4>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	98050513          	addi	a0,a0,-1664 # ffffffffc0201bb0 <etext+0x14c>
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
ffffffffc020026e:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201c28 <etext+0x1c4>
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
ffffffffc0200290:	9c450513          	addi	a0,a0,-1596 # ffffffffc0201c50 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	a1ec0c13          	addi	s8,s8,-1506 # ffffffffc0201cc0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	9ce90913          	addi	s2,s2,-1586 # ffffffffc0201c78 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	9ce48493          	addi	s1,s1,-1586 # ffffffffc0201c80 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	9ccb0b13          	addi	s6,s6,-1588 # ffffffffc0201c88 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	8e4a0a13          	addi	s4,s4,-1820 # ffffffffc0201ba8 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	614010ef          	jal	ra,ffffffffc02018e4 <readline>
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
ffffffffc02002ea:	9dad0d13          	addi	s10,s10,-1574 # ffffffffc0201cc0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	72a010ef          	jal	ra,ffffffffc0201a1e <strcmp>
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
ffffffffc0200308:	716010ef          	jal	ra,ffffffffc0201a1e <strcmp>
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
ffffffffc0200346:	6f6010ef          	jal	ra,ffffffffc0201a3c <strchr>
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
ffffffffc0200384:	6b8010ef          	jal	ra,ffffffffc0201a3c <strchr>
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
ffffffffc02003a2:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201ca8 <etext+0x244>
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
ffffffffc02003b0:	08430313          	addi	t1,t1,132 # ffffffffc0206430 <is_panic>
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
ffffffffc02003de:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201d08 <commands+0x48>
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
ffffffffc02003f4:	76050513          	addi	a0,a0,1888 # ffffffffc0201b50 <etext+0xec>
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
ffffffffc0200420:	592010ef          	jal	ra,ffffffffc02019b2 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201d28 <commands+0x68>
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
ffffffffc0200446:	56c0106f          	j	ffffffffc02019b2 <sbi_set_timer>

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
ffffffffc0200450:	5480106f          	j	ffffffffc0201998 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5780106f          	j	ffffffffc02019cc <sbi_console_getchar>

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
ffffffffc020046c:	38078793          	addi	a5,a5,896 # ffffffffc02007e8 <__alltraps>
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
ffffffffc0200482:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201d48 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201d60 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0201d78 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201d90 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	8f050513          	addi	a0,a0,-1808 # ffffffffc0201da8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201dc0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	90450513          	addi	a0,a0,-1788 # ffffffffc0201dd8 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	90e50513          	addi	a0,a0,-1778 # ffffffffc0201df0 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	91850513          	addi	a0,a0,-1768 # ffffffffc0201e08 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	92250513          	addi	a0,a0,-1758 # ffffffffc0201e20 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	92c50513          	addi	a0,a0,-1748 # ffffffffc0201e38 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	93650513          	addi	a0,a0,-1738 # ffffffffc0201e50 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	94050513          	addi	a0,a0,-1728 # ffffffffc0201e68 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201e80 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	95450513          	addi	a0,a0,-1708 # ffffffffc0201e98 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201eb0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	96850513          	addi	a0,a0,-1688 # ffffffffc0201ec8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	97250513          	addi	a0,a0,-1678 # ffffffffc0201ee0 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	97c50513          	addi	a0,a0,-1668 # ffffffffc0201ef8 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	98650513          	addi	a0,a0,-1658 # ffffffffc0201f10 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	99050513          	addi	a0,a0,-1648 # ffffffffc0201f28 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201f40 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201f58 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0201f70 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0201f88 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201fa0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0201fb8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201fd0 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0201fe8 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0202000 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	9f450513          	addi	a0,a0,-1548 # ffffffffc0202018 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0202030 <commands+0x370>
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
ffffffffc020064e:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0202048 <commands+0x388>
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
ffffffffc0200666:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0202060 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	a0650513          	addi	a0,a0,-1530 # ffffffffc0202078 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0202090 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	a1250513          	addi	a0,a0,-1518 # ffffffffc02020a8 <commands+0x3e8>
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
ffffffffc02006b4:	ad870713          	addi	a4,a4,-1320 # ffffffffc0202188 <commands+0x4c8>
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
ffffffffc02006c6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0202120 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a3450513          	addi	a0,a0,-1484 # ffffffffc0202100 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	9ea50513          	addi	a0,a0,-1558 # ffffffffc02020c0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a6050513          	addi	a0,a0,-1440 # ffffffffc0202140 <commands+0x480>
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
ffffffffc02006f6:	d4668693          	addi	a3,a3,-698 # ffffffffc0206438 <ticks>
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
ffffffffc0200714:	a5850513          	addi	a0,a0,-1448 # ffffffffc0202168 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	9c650513          	addi	a0,a0,-1594 # ffffffffc02020e0 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200726:	06400593          	li	a1,100
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0202158 <commands+0x498>
ffffffffc0200732:	981ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                PRINT_NUM++;
ffffffffc0200736:	00006717          	auipc	a4,0x6
ffffffffc020073a:	d0a70713          	addi	a4,a4,-758 # ffffffffc0206440 <PRINT_NUM>
ffffffffc020073e:	431c                	lw	a5,0(a4)
            	if(PRINT_NUM == 10){
ffffffffc0200740:	46a9                	li	a3,10
                PRINT_NUM++;
ffffffffc0200742:	0017861b          	addiw	a2,a5,1
ffffffffc0200746:	c310                	sw	a2,0(a4)
            	if(PRINT_NUM == 10){
ffffffffc0200748:	fcd611e3          	bne	a2,a3,ffffffffc020070a <interrupt_handler+0x68>
}
ffffffffc020074c:	60a2                	ld	ra,8(sp)
ffffffffc020074e:	0141                	addi	sp,sp,16
            	   sbi_shutdown();
ffffffffc0200750:	2980106f          	j	ffffffffc02019e8 <sbi_shutdown>

ffffffffc0200754 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200754:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200758:	1141                	addi	sp,sp,-16
ffffffffc020075a:	e022                	sd	s0,0(sp)
ffffffffc020075c:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc020075e:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200760:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200762:	04e78663          	beq	a5,a4,ffffffffc02007ae <exception_handler+0x5a>
ffffffffc0200766:	02f76c63          	bltu	a4,a5,ffffffffc020079e <exception_handler+0x4a>
ffffffffc020076a:	4709                	li	a4,2
ffffffffc020076c:	02e79563          	bne	a5,a4,ffffffffc0200796 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2113997: */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction \n");
ffffffffc0200770:	00002517          	auipc	a0,0x2
ffffffffc0200774:	a4850513          	addi	a0,a0,-1464 # ffffffffc02021b8 <commands+0x4f8>
ffffffffc0200778:	93bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction exception at 0x%016llx\n", tf->epc);//采用0x%016llx格式化字符串，用于打印16位十六进制数，这个位置是异常指令的地址,以tf->epc作为参数。
ffffffffc020077c:	10843583          	ld	a1,264(s0)
ffffffffc0200780:	00002517          	auipc	a0,0x2
ffffffffc0200784:	a6050513          	addi	a0,a0,-1440 # ffffffffc02021e0 <commands+0x520>
ffffffffc0200788:	92bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            //%016llx中的%表示格式化指示符的开始，0表示空位补零，16表示总宽度为 16 个字符，llx表示以长长整型十六进制数形式输出。
            tf->epc += 4;//指令长度都为4个字节
ffffffffc020078c:	10843783          	ld	a5,264(s0)
ffffffffc0200790:	0791                	addi	a5,a5,4
ffffffffc0200792:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200796:	60a2                	ld	ra,8(sp)
ffffffffc0200798:	6402                	ld	s0,0(sp)
ffffffffc020079a:	0141                	addi	sp,sp,16
ffffffffc020079c:	8082                	ret
    switch (tf->cause) {
ffffffffc020079e:	17f1                	addi	a5,a5,-4
ffffffffc02007a0:	471d                	li	a4,7
ffffffffc02007a2:	fef77ae3          	bgeu	a4,a5,ffffffffc0200796 <exception_handler+0x42>
}
ffffffffc02007a6:	6402                	ld	s0,0(sp)
ffffffffc02007a8:	60a2                	ld	ra,8(sp)
ffffffffc02007aa:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc02007ac:	bd59                	j	ffffffffc0200642 <print_trapframe>
            cprintf("Exception type: breakpoint \n");
ffffffffc02007ae:	00002517          	auipc	a0,0x2
ffffffffc02007b2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0202210 <commands+0x550>
ffffffffc02007b6:	8fdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc02007ba:	10843583          	ld	a1,264(s0)
ffffffffc02007be:	00002517          	auipc	a0,0x2
ffffffffc02007c2:	a7250513          	addi	a0,a0,-1422 # ffffffffc0202230 <commands+0x570>
ffffffffc02007c6:	8edff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc += 2;//ebreak指令长度为2个字节，为了4字节对齐
ffffffffc02007ca:	10843783          	ld	a5,264(s0)
}
ffffffffc02007ce:	60a2                	ld	ra,8(sp)
            tf->epc += 2;//ebreak指令长度为2个字节，为了4字节对齐
ffffffffc02007d0:	0789                	addi	a5,a5,2
ffffffffc02007d2:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007d6:	6402                	ld	s0,0(sp)
ffffffffc02007d8:	0141                	addi	sp,sp,16
ffffffffc02007da:	8082                	ret

ffffffffc02007dc <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007dc:	11853783          	ld	a5,280(a0)
ffffffffc02007e0:	0007c363          	bltz	a5,ffffffffc02007e6 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007e4:	bf85                	j	ffffffffc0200754 <exception_handler>
        interrupt_handler(tf);
ffffffffc02007e6:	bd75                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc02007e8 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007e8:	14011073          	csrw	sscratch,sp
ffffffffc02007ec:	712d                	addi	sp,sp,-288
ffffffffc02007ee:	e002                	sd	zero,0(sp)
ffffffffc02007f0:	e406                	sd	ra,8(sp)
ffffffffc02007f2:	ec0e                	sd	gp,24(sp)
ffffffffc02007f4:	f012                	sd	tp,32(sp)
ffffffffc02007f6:	f416                	sd	t0,40(sp)
ffffffffc02007f8:	f81a                	sd	t1,48(sp)
ffffffffc02007fa:	fc1e                	sd	t2,56(sp)
ffffffffc02007fc:	e0a2                	sd	s0,64(sp)
ffffffffc02007fe:	e4a6                	sd	s1,72(sp)
ffffffffc0200800:	e8aa                	sd	a0,80(sp)
ffffffffc0200802:	ecae                	sd	a1,88(sp)
ffffffffc0200804:	f0b2                	sd	a2,96(sp)
ffffffffc0200806:	f4b6                	sd	a3,104(sp)
ffffffffc0200808:	f8ba                	sd	a4,112(sp)
ffffffffc020080a:	fcbe                	sd	a5,120(sp)
ffffffffc020080c:	e142                	sd	a6,128(sp)
ffffffffc020080e:	e546                	sd	a7,136(sp)
ffffffffc0200810:	e94a                	sd	s2,144(sp)
ffffffffc0200812:	ed4e                	sd	s3,152(sp)
ffffffffc0200814:	f152                	sd	s4,160(sp)
ffffffffc0200816:	f556                	sd	s5,168(sp)
ffffffffc0200818:	f95a                	sd	s6,176(sp)
ffffffffc020081a:	fd5e                	sd	s7,184(sp)
ffffffffc020081c:	e1e2                	sd	s8,192(sp)
ffffffffc020081e:	e5e6                	sd	s9,200(sp)
ffffffffc0200820:	e9ea                	sd	s10,208(sp)
ffffffffc0200822:	edee                	sd	s11,216(sp)
ffffffffc0200824:	f1f2                	sd	t3,224(sp)
ffffffffc0200826:	f5f6                	sd	t4,232(sp)
ffffffffc0200828:	f9fa                	sd	t5,240(sp)
ffffffffc020082a:	fdfe                	sd	t6,248(sp)
ffffffffc020082c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200830:	100024f3          	csrr	s1,sstatus
ffffffffc0200834:	14102973          	csrr	s2,sepc
ffffffffc0200838:	143029f3          	csrr	s3,stval
ffffffffc020083c:	14202a73          	csrr	s4,scause
ffffffffc0200840:	e822                	sd	s0,16(sp)
ffffffffc0200842:	e226                	sd	s1,256(sp)
ffffffffc0200844:	e64a                	sd	s2,264(sp)
ffffffffc0200846:	ea4e                	sd	s3,272(sp)
ffffffffc0200848:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020084a:	850a                	mv	a0,sp
    jal trap
ffffffffc020084c:	f91ff0ef          	jal	ra,ffffffffc02007dc <trap>

ffffffffc0200850 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200850:	6492                	ld	s1,256(sp)
ffffffffc0200852:	6932                	ld	s2,264(sp)
ffffffffc0200854:	10049073          	csrw	sstatus,s1
ffffffffc0200858:	14191073          	csrw	sepc,s2
ffffffffc020085c:	60a2                	ld	ra,8(sp)
ffffffffc020085e:	61e2                	ld	gp,24(sp)
ffffffffc0200860:	7202                	ld	tp,32(sp)
ffffffffc0200862:	72a2                	ld	t0,40(sp)
ffffffffc0200864:	7342                	ld	t1,48(sp)
ffffffffc0200866:	73e2                	ld	t2,56(sp)
ffffffffc0200868:	6406                	ld	s0,64(sp)
ffffffffc020086a:	64a6                	ld	s1,72(sp)
ffffffffc020086c:	6546                	ld	a0,80(sp)
ffffffffc020086e:	65e6                	ld	a1,88(sp)
ffffffffc0200870:	7606                	ld	a2,96(sp)
ffffffffc0200872:	76a6                	ld	a3,104(sp)
ffffffffc0200874:	7746                	ld	a4,112(sp)
ffffffffc0200876:	77e6                	ld	a5,120(sp)
ffffffffc0200878:	680a                	ld	a6,128(sp)
ffffffffc020087a:	68aa                	ld	a7,136(sp)
ffffffffc020087c:	694a                	ld	s2,144(sp)
ffffffffc020087e:	69ea                	ld	s3,152(sp)
ffffffffc0200880:	7a0a                	ld	s4,160(sp)
ffffffffc0200882:	7aaa                	ld	s5,168(sp)
ffffffffc0200884:	7b4a                	ld	s6,176(sp)
ffffffffc0200886:	7bea                	ld	s7,184(sp)
ffffffffc0200888:	6c0e                	ld	s8,192(sp)
ffffffffc020088a:	6cae                	ld	s9,200(sp)
ffffffffc020088c:	6d4e                	ld	s10,208(sp)
ffffffffc020088e:	6dee                	ld	s11,216(sp)
ffffffffc0200890:	7e0e                	ld	t3,224(sp)
ffffffffc0200892:	7eae                	ld	t4,232(sp)
ffffffffc0200894:	7f4e                	ld	t5,240(sp)
ffffffffc0200896:	7fee                	ld	t6,248(sp)
ffffffffc0200898:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020089a:	10200073          	sret

ffffffffc020089e <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020089e:	00005797          	auipc	a5,0x5
ffffffffc02008a2:	77a78793          	addi	a5,a5,1914 # ffffffffc0206018 <free_area>
ffffffffc02008a6:	e79c                	sd	a5,8(a5)
ffffffffc02008a8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02008aa:	0007a823          	sw	zero,16(a5)
}
ffffffffc02008ae:	8082                	ret

ffffffffc02008b0 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02008b0:	00005517          	auipc	a0,0x5
ffffffffc02008b4:	77856503          	lwu	a0,1912(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc02008b8:	8082                	ret

ffffffffc02008ba <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc02008ba:	c14d                	beqz	a0,ffffffffc020095c <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc02008bc:	00005697          	auipc	a3,0x5
ffffffffc02008c0:	75c68693          	addi	a3,a3,1884 # ffffffffc0206018 <free_area>
ffffffffc02008c4:	0106a803          	lw	a6,16(a3)
ffffffffc02008c8:	85aa                	mv	a1,a0
ffffffffc02008ca:	02081793          	slli	a5,a6,0x20
ffffffffc02008ce:	9381                	srli	a5,a5,0x20
ffffffffc02008d0:	08a7e463          	bltu	a5,a0,ffffffffc0200958 <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008d4:	669c                	ld	a5,8(a3)
    size_t min_size = nr_free + 1;
ffffffffc02008d6:	0018061b          	addiw	a2,a6,1
ffffffffc02008da:	1602                	slli	a2,a2,0x20
ffffffffc02008dc:	9201                	srli	a2,a2,0x20
    struct Page *page = NULL;
ffffffffc02008de:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008e0:	06d78b63          	beq	a5,a3,ffffffffc0200956 <best_fit_alloc_pages+0x9c>
        if (p->property < min_size && p->property >= n) {
ffffffffc02008e4:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02008e8:	00c77763          	bgeu	a4,a2,ffffffffc02008f6 <best_fit_alloc_pages+0x3c>
ffffffffc02008ec:	00b76563          	bltu	a4,a1,ffffffffc02008f6 <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc02008f0:	fe878513          	addi	a0,a5,-24
ffffffffc02008f4:	863a                	mv	a2,a4
ffffffffc02008f6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008f8:	fed796e3          	bne	a5,a3,ffffffffc02008e4 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc02008fc:	cd29                	beqz	a0,ffffffffc0200956 <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02008fe:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200900:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200902:	4910                	lw	a2,16(a0)
            p->property = page->property - n;
ffffffffc0200904:	0005889b          	sext.w	a7,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200908:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020090a:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc020090c:	02061793          	slli	a5,a2,0x20
ffffffffc0200910:	9381                	srli	a5,a5,0x20
ffffffffc0200912:	02f5f863          	bgeu	a1,a5,ffffffffc0200942 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200916:	00259793          	slli	a5,a1,0x2
ffffffffc020091a:	97ae                	add	a5,a5,a1
ffffffffc020091c:	078e                	slli	a5,a5,0x3
ffffffffc020091e:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200920:	4116063b          	subw	a2,a2,a7
ffffffffc0200924:	cb90                	sw	a2,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200926:	00878593          	addi	a1,a5,8
ffffffffc020092a:	4609                	li	a2,2
ffffffffc020092c:	40c5b02f          	amoor.d	zero,a2,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200930:	6710                	ld	a2,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200932:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc0200936:	0106a803          	lw	a6,16(a3)
    prev->next = next->prev = elm;
ffffffffc020093a:	e20c                	sd	a1,0(a2)
ffffffffc020093c:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc020093e:	f390                	sd	a2,32(a5)
    elm->prev = prev;
ffffffffc0200940:	ef98                	sd	a4,24(a5)
ffffffffc0200942:	4118083b          	subw	a6,a6,a7
ffffffffc0200946:	0106a823          	sw	a6,16(a3)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020094a:	57f5                	li	a5,-3
ffffffffc020094c:	00850713          	addi	a4,a0,8
ffffffffc0200950:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200954:	8082                	ret
}
ffffffffc0200956:	8082                	ret
        return NULL;
ffffffffc0200958:	4501                	li	a0,0
ffffffffc020095a:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc020095c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020095e:	00002697          	auipc	a3,0x2
ffffffffc0200962:	8f268693          	addi	a3,a3,-1806 # ffffffffc0202250 <commands+0x590>
ffffffffc0200966:	00002617          	auipc	a2,0x2
ffffffffc020096a:	8f260613          	addi	a2,a2,-1806 # ffffffffc0202258 <commands+0x598>
ffffffffc020096e:	06a00593          	li	a1,106
ffffffffc0200972:	00002517          	auipc	a0,0x2
ffffffffc0200976:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0202270 <commands+0x5b0>
best_fit_alloc_pages(size_t n) {
ffffffffc020097a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020097c:	a31ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200980 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200980:	715d                	addi	sp,sp,-80
ffffffffc0200982:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200984:	00005417          	auipc	s0,0x5
ffffffffc0200988:	69440413          	addi	s0,s0,1684 # ffffffffc0206018 <free_area>
ffffffffc020098c:	641c                	ld	a5,8(s0)
ffffffffc020098e:	e486                	sd	ra,72(sp)
ffffffffc0200990:	fc26                	sd	s1,56(sp)
ffffffffc0200992:	f84a                	sd	s2,48(sp)
ffffffffc0200994:	f44e                	sd	s3,40(sp)
ffffffffc0200996:	f052                	sd	s4,32(sp)
ffffffffc0200998:	ec56                	sd	s5,24(sp)
ffffffffc020099a:	e85a                	sd	s6,16(sp)
ffffffffc020099c:	e45e                	sd	s7,8(sp)
ffffffffc020099e:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009a0:	26878b63          	beq	a5,s0,ffffffffc0200c16 <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc02009a4:	4481                	li	s1,0
ffffffffc02009a6:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009a8:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02009ac:	8b09                	andi	a4,a4,2
ffffffffc02009ae:	26070863          	beqz	a4,ffffffffc0200c1e <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc02009b2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02009b6:	679c                	ld	a5,8(a5)
ffffffffc02009b8:	2905                	addiw	s2,s2,1
ffffffffc02009ba:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009bc:	fe8796e3          	bne	a5,s0,ffffffffc02009a8 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02009c0:	89a6                	mv	s3,s1
ffffffffc02009c2:	167000ef          	jal	ra,ffffffffc0201328 <nr_free_pages>
ffffffffc02009c6:	33351c63          	bne	a0,s3,ffffffffc0200cfe <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02009ca:	4505                	li	a0,1
ffffffffc02009cc:	0df000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc02009d0:	8a2a                	mv	s4,a0
ffffffffc02009d2:	36050663          	beqz	a0,ffffffffc0200d3e <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009d6:	4505                	li	a0,1
ffffffffc02009d8:	0d3000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc02009dc:	89aa                	mv	s3,a0
ffffffffc02009de:	34050063          	beqz	a0,ffffffffc0200d1e <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009e2:	4505                	li	a0,1
ffffffffc02009e4:	0c7000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc02009e8:	8aaa                	mv	s5,a0
ffffffffc02009ea:	2c050a63          	beqz	a0,ffffffffc0200cbe <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02009ee:	253a0863          	beq	s4,s3,ffffffffc0200c3e <best_fit_check+0x2be>
ffffffffc02009f2:	24aa0663          	beq	s4,a0,ffffffffc0200c3e <best_fit_check+0x2be>
ffffffffc02009f6:	24a98463          	beq	s3,a0,ffffffffc0200c3e <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02009fa:	000a2783          	lw	a5,0(s4)
ffffffffc02009fe:	26079063          	bnez	a5,ffffffffc0200c5e <best_fit_check+0x2de>
ffffffffc0200a02:	0009a783          	lw	a5,0(s3)
ffffffffc0200a06:	24079c63          	bnez	a5,ffffffffc0200c5e <best_fit_check+0x2de>
ffffffffc0200a0a:	411c                	lw	a5,0(a0)
ffffffffc0200a0c:	24079963          	bnez	a5,ffffffffc0200c5e <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a10:	00006797          	auipc	a5,0x6
ffffffffc0200a14:	a407b783          	ld	a5,-1472(a5) # ffffffffc0206450 <pages>
ffffffffc0200a18:	40fa0733          	sub	a4,s4,a5
ffffffffc0200a1c:	870d                	srai	a4,a4,0x3
ffffffffc0200a1e:	00002597          	auipc	a1,0x2
ffffffffc0200a22:	f225b583          	ld	a1,-222(a1) # ffffffffc0202940 <error_string+0x38>
ffffffffc0200a26:	02b70733          	mul	a4,a4,a1
ffffffffc0200a2a:	00002617          	auipc	a2,0x2
ffffffffc0200a2e:	f1e63603          	ld	a2,-226(a2) # ffffffffc0202948 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200a32:	00006697          	auipc	a3,0x6
ffffffffc0200a36:	a166b683          	ld	a3,-1514(a3) # ffffffffc0206448 <npage>
ffffffffc0200a3a:	06b2                	slli	a3,a3,0xc
ffffffffc0200a3c:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a3e:	0732                	slli	a4,a4,0xc
ffffffffc0200a40:	22d77f63          	bgeu	a4,a3,ffffffffc0200c7e <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a44:	40f98733          	sub	a4,s3,a5
ffffffffc0200a48:	870d                	srai	a4,a4,0x3
ffffffffc0200a4a:	02b70733          	mul	a4,a4,a1
ffffffffc0200a4e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a50:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a52:	3ed77663          	bgeu	a4,a3,ffffffffc0200e3e <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a56:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a5a:	878d                	srai	a5,a5,0x3
ffffffffc0200a5c:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a60:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a62:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a64:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200e1e <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200a68:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a6a:	00043c03          	ld	s8,0(s0)
ffffffffc0200a6e:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a72:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200a76:	e400                	sd	s0,8(s0)
ffffffffc0200a78:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200a7a:	00005797          	auipc	a5,0x5
ffffffffc0200a7e:	5a07a723          	sw	zero,1454(a5) # ffffffffc0206028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a82:	029000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200a86:	36051c63          	bnez	a0,ffffffffc0200dfe <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200a8a:	4585                	li	a1,1
ffffffffc0200a8c:	8552                	mv	a0,s4
ffffffffc0200a8e:	05b000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    free_page(p1);
ffffffffc0200a92:	4585                	li	a1,1
ffffffffc0200a94:	854e                	mv	a0,s3
ffffffffc0200a96:	053000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    free_page(p2);
ffffffffc0200a9a:	4585                	li	a1,1
ffffffffc0200a9c:	8556                	mv	a0,s5
ffffffffc0200a9e:	04b000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    assert(nr_free == 3);
ffffffffc0200aa2:	4818                	lw	a4,16(s0)
ffffffffc0200aa4:	478d                	li	a5,3
ffffffffc0200aa6:	32f71c63          	bne	a4,a5,ffffffffc0200dde <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200aaa:	4505                	li	a0,1
ffffffffc0200aac:	7fe000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200ab0:	89aa                	mv	s3,a0
ffffffffc0200ab2:	30050663          	beqz	a0,ffffffffc0200dbe <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ab6:	4505                	li	a0,1
ffffffffc0200ab8:	7f2000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200abc:	8aaa                	mv	s5,a0
ffffffffc0200abe:	2e050063          	beqz	a0,ffffffffc0200d9e <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ac2:	4505                	li	a0,1
ffffffffc0200ac4:	7e6000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200ac8:	8a2a                	mv	s4,a0
ffffffffc0200aca:	2a050a63          	beqz	a0,ffffffffc0200d7e <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200ace:	4505                	li	a0,1
ffffffffc0200ad0:	7da000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200ad4:	28051563          	bnez	a0,ffffffffc0200d5e <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200ad8:	4585                	li	a1,1
ffffffffc0200ada:	854e                	mv	a0,s3
ffffffffc0200adc:	00d000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ae0:	641c                	ld	a5,8(s0)
ffffffffc0200ae2:	1a878e63          	beq	a5,s0,ffffffffc0200c9e <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200ae6:	4505                	li	a0,1
ffffffffc0200ae8:	7c2000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200aec:	52a99963          	bne	s3,a0,ffffffffc020101e <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200af0:	4505                	li	a0,1
ffffffffc0200af2:	7b8000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200af6:	50051463          	bnez	a0,ffffffffc0200ffe <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200afa:	481c                	lw	a5,16(s0)
ffffffffc0200afc:	4e079163          	bnez	a5,ffffffffc0200fde <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200b00:	854e                	mv	a0,s3
ffffffffc0200b02:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200b04:	01843023          	sd	s8,0(s0)
ffffffffc0200b08:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200b0c:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200b10:	7d8000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    free_page(p1);
ffffffffc0200b14:	4585                	li	a1,1
ffffffffc0200b16:	8556                	mv	a0,s5
ffffffffc0200b18:	7d0000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    free_page(p2);
ffffffffc0200b1c:	4585                	li	a1,1
ffffffffc0200b1e:	8552                	mv	a0,s4
ffffffffc0200b20:	7c8000ef          	jal	ra,ffffffffc02012e8 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200b24:	4515                	li	a0,5
ffffffffc0200b26:	784000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200b2a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200b2c:	48050963          	beqz	a0,ffffffffc0200fbe <best_fit_check+0x63e>
ffffffffc0200b30:	651c                	ld	a5,8(a0)
ffffffffc0200b32:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200b34:	8b85                	andi	a5,a5,1
ffffffffc0200b36:	46079463          	bnez	a5,ffffffffc0200f9e <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b3a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b3c:	00043a83          	ld	s5,0(s0)
ffffffffc0200b40:	00843a03          	ld	s4,8(s0)
ffffffffc0200b44:	e000                	sd	s0,0(s0)
ffffffffc0200b46:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200b48:	762000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200b4c:	42051963          	bnez	a0,ffffffffc0200f7e <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b50:	4589                	li	a1,2
ffffffffc0200b52:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b56:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200b5a:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b5e:	00005797          	auipc	a5,0x5
ffffffffc0200b62:	4c07a523          	sw	zero,1226(a5) # ffffffffc0206028 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b66:	782000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b6a:	8562                	mv	a0,s8
ffffffffc0200b6c:	4585                	li	a1,1
ffffffffc0200b6e:	77a000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b72:	4511                	li	a0,4
ffffffffc0200b74:	736000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200b78:	3e051363          	bnez	a0,ffffffffc0200f5e <best_fit_check+0x5de>
ffffffffc0200b7c:	0309b783          	ld	a5,48(s3)
ffffffffc0200b80:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b82:	8b85                	andi	a5,a5,1
ffffffffc0200b84:	3a078d63          	beqz	a5,ffffffffc0200f3e <best_fit_check+0x5be>
ffffffffc0200b88:	0389a703          	lw	a4,56(s3)
ffffffffc0200b8c:	4789                	li	a5,2
ffffffffc0200b8e:	3af71863          	bne	a4,a5,ffffffffc0200f3e <best_fit_check+0x5be>

    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b92:	4505                	li	a0,1
ffffffffc0200b94:	716000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200b98:	8baa                	mv	s7,a0
ffffffffc0200b9a:	38050263          	beqz	a0,ffffffffc0200f1e <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b9e:	4509                	li	a0,2
ffffffffc0200ba0:	70a000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200ba4:	34050d63          	beqz	a0,ffffffffc0200efe <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200ba8:	337c1b63          	bne	s8,s7,ffffffffc0200ede <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200bac:	854e                	mv	a0,s3
ffffffffc0200bae:	4595                	li	a1,5
ffffffffc0200bb0:	738000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200bb4:	4515                	li	a0,5
ffffffffc0200bb6:	6f4000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200bba:	89aa                	mv	s3,a0
ffffffffc0200bbc:	30050163          	beqz	a0,ffffffffc0200ebe <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200bc0:	4505                	li	a0,1
ffffffffc0200bc2:	6e8000ef          	jal	ra,ffffffffc02012aa <alloc_pages>
ffffffffc0200bc6:	2c051c63          	bnez	a0,ffffffffc0200e9e <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200bca:	481c                	lw	a5,16(s0)
ffffffffc0200bcc:	2a079963          	bnez	a5,ffffffffc0200e7e <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200bd0:	4595                	li	a1,5
ffffffffc0200bd2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200bd4:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200bd8:	01543023          	sd	s5,0(s0)
ffffffffc0200bdc:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200be0:	708000ef          	jal	ra,ffffffffc02012e8 <free_pages>
    return listelm->next;
ffffffffc0200be4:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200be6:	00878963          	beq	a5,s0,ffffffffc0200bf8 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bea:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bee:	679c                	ld	a5,8(a5)
ffffffffc0200bf0:	397d                	addiw	s2,s2,-1
ffffffffc0200bf2:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bf4:	fe879be3          	bne	a5,s0,ffffffffc0200bea <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200bf8:	26091363          	bnez	s2,ffffffffc0200e5e <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200bfc:	e0ed                	bnez	s1,ffffffffc0200cde <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200bfe:	60a6                	ld	ra,72(sp)
ffffffffc0200c00:	6406                	ld	s0,64(sp)
ffffffffc0200c02:	74e2                	ld	s1,56(sp)
ffffffffc0200c04:	7942                	ld	s2,48(sp)
ffffffffc0200c06:	79a2                	ld	s3,40(sp)
ffffffffc0200c08:	7a02                	ld	s4,32(sp)
ffffffffc0200c0a:	6ae2                	ld	s5,24(sp)
ffffffffc0200c0c:	6b42                	ld	s6,16(sp)
ffffffffc0200c0e:	6ba2                	ld	s7,8(sp)
ffffffffc0200c10:	6c02                	ld	s8,0(sp)
ffffffffc0200c12:	6161                	addi	sp,sp,80
ffffffffc0200c14:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c16:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200c18:	4481                	li	s1,0
ffffffffc0200c1a:	4901                	li	s2,0
ffffffffc0200c1c:	b35d                	j	ffffffffc02009c2 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200c1e:	00001697          	auipc	a3,0x1
ffffffffc0200c22:	66a68693          	addi	a3,a3,1642 # ffffffffc0202288 <commands+0x5c8>
ffffffffc0200c26:	00001617          	auipc	a2,0x1
ffffffffc0200c2a:	63260613          	addi	a2,a2,1586 # ffffffffc0202258 <commands+0x598>
ffffffffc0200c2e:	10800593          	li	a1,264
ffffffffc0200c32:	00001517          	auipc	a0,0x1
ffffffffc0200c36:	63e50513          	addi	a0,a0,1598 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200c3a:	f72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c3e:	00001697          	auipc	a3,0x1
ffffffffc0200c42:	6da68693          	addi	a3,a3,1754 # ffffffffc0202318 <commands+0x658>
ffffffffc0200c46:	00001617          	auipc	a2,0x1
ffffffffc0200c4a:	61260613          	addi	a2,a2,1554 # ffffffffc0202258 <commands+0x598>
ffffffffc0200c4e:	0d400593          	li	a1,212
ffffffffc0200c52:	00001517          	auipc	a0,0x1
ffffffffc0200c56:	61e50513          	addi	a0,a0,1566 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200c5a:	f52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c5e:	00001697          	auipc	a3,0x1
ffffffffc0200c62:	6e268693          	addi	a3,a3,1762 # ffffffffc0202340 <commands+0x680>
ffffffffc0200c66:	00001617          	auipc	a2,0x1
ffffffffc0200c6a:	5f260613          	addi	a2,a2,1522 # ffffffffc0202258 <commands+0x598>
ffffffffc0200c6e:	0d500593          	li	a1,213
ffffffffc0200c72:	00001517          	auipc	a0,0x1
ffffffffc0200c76:	5fe50513          	addi	a0,a0,1534 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200c7a:	f32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c7e:	00001697          	auipc	a3,0x1
ffffffffc0200c82:	70268693          	addi	a3,a3,1794 # ffffffffc0202380 <commands+0x6c0>
ffffffffc0200c86:	00001617          	auipc	a2,0x1
ffffffffc0200c8a:	5d260613          	addi	a2,a2,1490 # ffffffffc0202258 <commands+0x598>
ffffffffc0200c8e:	0d700593          	li	a1,215
ffffffffc0200c92:	00001517          	auipc	a0,0x1
ffffffffc0200c96:	5de50513          	addi	a0,a0,1502 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200c9a:	f12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c9e:	00001697          	auipc	a3,0x1
ffffffffc0200ca2:	76a68693          	addi	a3,a3,1898 # ffffffffc0202408 <commands+0x748>
ffffffffc0200ca6:	00001617          	auipc	a2,0x1
ffffffffc0200caa:	5b260613          	addi	a2,a2,1458 # ffffffffc0202258 <commands+0x598>
ffffffffc0200cae:	0f000593          	li	a1,240
ffffffffc0200cb2:	00001517          	auipc	a0,0x1
ffffffffc0200cb6:	5be50513          	addi	a0,a0,1470 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200cba:	ef2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cbe:	00001697          	auipc	a3,0x1
ffffffffc0200cc2:	63a68693          	addi	a3,a3,1594 # ffffffffc02022f8 <commands+0x638>
ffffffffc0200cc6:	00001617          	auipc	a2,0x1
ffffffffc0200cca:	59260613          	addi	a2,a2,1426 # ffffffffc0202258 <commands+0x598>
ffffffffc0200cce:	0d200593          	li	a1,210
ffffffffc0200cd2:	00001517          	auipc	a0,0x1
ffffffffc0200cd6:	59e50513          	addi	a0,a0,1438 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200cda:	ed2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200cde:	00002697          	auipc	a3,0x2
ffffffffc0200ce2:	85a68693          	addi	a3,a3,-1958 # ffffffffc0202538 <commands+0x878>
ffffffffc0200ce6:	00001617          	auipc	a2,0x1
ffffffffc0200cea:	57260613          	addi	a2,a2,1394 # ffffffffc0202258 <commands+0x598>
ffffffffc0200cee:	14b00593          	li	a1,331
ffffffffc0200cf2:	00001517          	auipc	a0,0x1
ffffffffc0200cf6:	57e50513          	addi	a0,a0,1406 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200cfa:	eb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200cfe:	00001697          	auipc	a3,0x1
ffffffffc0200d02:	59a68693          	addi	a3,a3,1434 # ffffffffc0202298 <commands+0x5d8>
ffffffffc0200d06:	00001617          	auipc	a2,0x1
ffffffffc0200d0a:	55260613          	addi	a2,a2,1362 # ffffffffc0202258 <commands+0x598>
ffffffffc0200d0e:	10b00593          	li	a1,267
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	55e50513          	addi	a0,a0,1374 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200d1a:	e92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d1e:	00001697          	auipc	a3,0x1
ffffffffc0200d22:	5ba68693          	addi	a3,a3,1466 # ffffffffc02022d8 <commands+0x618>
ffffffffc0200d26:	00001617          	auipc	a2,0x1
ffffffffc0200d2a:	53260613          	addi	a2,a2,1330 # ffffffffc0202258 <commands+0x598>
ffffffffc0200d2e:	0d100593          	li	a1,209
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	53e50513          	addi	a0,a0,1342 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200d3a:	e72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d3e:	00001697          	auipc	a3,0x1
ffffffffc0200d42:	57a68693          	addi	a3,a3,1402 # ffffffffc02022b8 <commands+0x5f8>
ffffffffc0200d46:	00001617          	auipc	a2,0x1
ffffffffc0200d4a:	51260613          	addi	a2,a2,1298 # ffffffffc0202258 <commands+0x598>
ffffffffc0200d4e:	0d000593          	li	a1,208
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	51e50513          	addi	a0,a0,1310 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200d5a:	e52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	68268693          	addi	a3,a3,1666 # ffffffffc02023e0 <commands+0x720>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	4f260613          	addi	a2,a2,1266 # ffffffffc0202258 <commands+0x598>
ffffffffc0200d6e:	0ed00593          	li	a1,237
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	4fe50513          	addi	a0,a0,1278 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200d7a:	e32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	57a68693          	addi	a3,a3,1402 # ffffffffc02022f8 <commands+0x638>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	4d260613          	addi	a2,a2,1234 # ffffffffc0202258 <commands+0x598>
ffffffffc0200d8e:	0eb00593          	li	a1,235
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	4de50513          	addi	a0,a0,1246 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200d9a:	e12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d9e:	00001697          	auipc	a3,0x1
ffffffffc0200da2:	53a68693          	addi	a3,a3,1338 # ffffffffc02022d8 <commands+0x618>
ffffffffc0200da6:	00001617          	auipc	a2,0x1
ffffffffc0200daa:	4b260613          	addi	a2,a2,1202 # ffffffffc0202258 <commands+0x598>
ffffffffc0200dae:	0ea00593          	li	a1,234
ffffffffc0200db2:	00001517          	auipc	a0,0x1
ffffffffc0200db6:	4be50513          	addi	a0,a0,1214 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200dba:	df2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dbe:	00001697          	auipc	a3,0x1
ffffffffc0200dc2:	4fa68693          	addi	a3,a3,1274 # ffffffffc02022b8 <commands+0x5f8>
ffffffffc0200dc6:	00001617          	auipc	a2,0x1
ffffffffc0200dca:	49260613          	addi	a2,a2,1170 # ffffffffc0202258 <commands+0x598>
ffffffffc0200dce:	0e900593          	li	a1,233
ffffffffc0200dd2:	00001517          	auipc	a0,0x1
ffffffffc0200dd6:	49e50513          	addi	a0,a0,1182 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200dda:	dd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200dde:	00001697          	auipc	a3,0x1
ffffffffc0200de2:	61a68693          	addi	a3,a3,1562 # ffffffffc02023f8 <commands+0x738>
ffffffffc0200de6:	00001617          	auipc	a2,0x1
ffffffffc0200dea:	47260613          	addi	a2,a2,1138 # ffffffffc0202258 <commands+0x598>
ffffffffc0200dee:	0e700593          	li	a1,231
ffffffffc0200df2:	00001517          	auipc	a0,0x1
ffffffffc0200df6:	47e50513          	addi	a0,a0,1150 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200dfa:	db2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dfe:	00001697          	auipc	a3,0x1
ffffffffc0200e02:	5e268693          	addi	a3,a3,1506 # ffffffffc02023e0 <commands+0x720>
ffffffffc0200e06:	00001617          	auipc	a2,0x1
ffffffffc0200e0a:	45260613          	addi	a2,a2,1106 # ffffffffc0202258 <commands+0x598>
ffffffffc0200e0e:	0e200593          	li	a1,226
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	45e50513          	addi	a0,a0,1118 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200e1a:	d92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	5a268693          	addi	a3,a3,1442 # ffffffffc02023c0 <commands+0x700>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	43260613          	addi	a2,a2,1074 # ffffffffc0202258 <commands+0x598>
ffffffffc0200e2e:	0d900593          	li	a1,217
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	43e50513          	addi	a0,a0,1086 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200e3a:	d72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e3e:	00001697          	auipc	a3,0x1
ffffffffc0200e42:	56268693          	addi	a3,a3,1378 # ffffffffc02023a0 <commands+0x6e0>
ffffffffc0200e46:	00001617          	auipc	a2,0x1
ffffffffc0200e4a:	41260613          	addi	a2,a2,1042 # ffffffffc0202258 <commands+0x598>
ffffffffc0200e4e:	0d800593          	li	a1,216
ffffffffc0200e52:	00001517          	auipc	a0,0x1
ffffffffc0200e56:	41e50513          	addi	a0,a0,1054 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200e5a:	d52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e5e:	00001697          	auipc	a3,0x1
ffffffffc0200e62:	6ca68693          	addi	a3,a3,1738 # ffffffffc0202528 <commands+0x868>
ffffffffc0200e66:	00001617          	auipc	a2,0x1
ffffffffc0200e6a:	3f260613          	addi	a2,a2,1010 # ffffffffc0202258 <commands+0x598>
ffffffffc0200e6e:	14a00593          	li	a1,330
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	3fe50513          	addi	a0,a0,1022 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200e7a:	d32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e7e:	00001697          	auipc	a3,0x1
ffffffffc0200e82:	5c268693          	addi	a3,a3,1474 # ffffffffc0202440 <commands+0x780>
ffffffffc0200e86:	00001617          	auipc	a2,0x1
ffffffffc0200e8a:	3d260613          	addi	a2,a2,978 # ffffffffc0202258 <commands+0x598>
ffffffffc0200e8e:	13f00593          	li	a1,319
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	3de50513          	addi	a0,a0,990 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200e9a:	d12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e9e:	00001697          	auipc	a3,0x1
ffffffffc0200ea2:	54268693          	addi	a3,a3,1346 # ffffffffc02023e0 <commands+0x720>
ffffffffc0200ea6:	00001617          	auipc	a2,0x1
ffffffffc0200eaa:	3b260613          	addi	a2,a2,946 # ffffffffc0202258 <commands+0x598>
ffffffffc0200eae:	13900593          	li	a1,313
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	3be50513          	addi	a0,a0,958 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200eba:	cf2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ebe:	00001697          	auipc	a3,0x1
ffffffffc0200ec2:	64a68693          	addi	a3,a3,1610 # ffffffffc0202508 <commands+0x848>
ffffffffc0200ec6:	00001617          	auipc	a2,0x1
ffffffffc0200eca:	39260613          	addi	a2,a2,914 # ffffffffc0202258 <commands+0x598>
ffffffffc0200ece:	13800593          	li	a1,312
ffffffffc0200ed2:	00001517          	auipc	a0,0x1
ffffffffc0200ed6:	39e50513          	addi	a0,a0,926 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200eda:	cd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ede:	00001697          	auipc	a3,0x1
ffffffffc0200ee2:	61a68693          	addi	a3,a3,1562 # ffffffffc02024f8 <commands+0x838>
ffffffffc0200ee6:	00001617          	auipc	a2,0x1
ffffffffc0200eea:	37260613          	addi	a2,a2,882 # ffffffffc0202258 <commands+0x598>
ffffffffc0200eee:	13000593          	li	a1,304
ffffffffc0200ef2:	00001517          	auipc	a0,0x1
ffffffffc0200ef6:	37e50513          	addi	a0,a0,894 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200efa:	cb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200efe:	00001697          	auipc	a3,0x1
ffffffffc0200f02:	5e268693          	addi	a3,a3,1506 # ffffffffc02024e0 <commands+0x820>
ffffffffc0200f06:	00001617          	auipc	a2,0x1
ffffffffc0200f0a:	35260613          	addi	a2,a2,850 # ffffffffc0202258 <commands+0x598>
ffffffffc0200f0e:	12f00593          	li	a1,303
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	35e50513          	addi	a0,a0,862 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200f1a:	c92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f1e:	00001697          	auipc	a3,0x1
ffffffffc0200f22:	5a268693          	addi	a3,a3,1442 # ffffffffc02024c0 <commands+0x800>
ffffffffc0200f26:	00001617          	auipc	a2,0x1
ffffffffc0200f2a:	33260613          	addi	a2,a2,818 # ffffffffc0202258 <commands+0x598>
ffffffffc0200f2e:	12e00593          	li	a1,302
ffffffffc0200f32:	00001517          	auipc	a0,0x1
ffffffffc0200f36:	33e50513          	addi	a0,a0,830 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200f3a:	c72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f3e:	00001697          	auipc	a3,0x1
ffffffffc0200f42:	55268693          	addi	a3,a3,1362 # ffffffffc0202490 <commands+0x7d0>
ffffffffc0200f46:	00001617          	auipc	a2,0x1
ffffffffc0200f4a:	31260613          	addi	a2,a2,786 # ffffffffc0202258 <commands+0x598>
ffffffffc0200f4e:	12b00593          	li	a1,299
ffffffffc0200f52:	00001517          	auipc	a0,0x1
ffffffffc0200f56:	31e50513          	addi	a0,a0,798 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200f5a:	c52ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f5e:	00001697          	auipc	a3,0x1
ffffffffc0200f62:	51a68693          	addi	a3,a3,1306 # ffffffffc0202478 <commands+0x7b8>
ffffffffc0200f66:	00001617          	auipc	a2,0x1
ffffffffc0200f6a:	2f260613          	addi	a2,a2,754 # ffffffffc0202258 <commands+0x598>
ffffffffc0200f6e:	12a00593          	li	a1,298
ffffffffc0200f72:	00001517          	auipc	a0,0x1
ffffffffc0200f76:	2fe50513          	addi	a0,a0,766 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200f7a:	c32ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f7e:	00001697          	auipc	a3,0x1
ffffffffc0200f82:	46268693          	addi	a3,a3,1122 # ffffffffc02023e0 <commands+0x720>
ffffffffc0200f86:	00001617          	auipc	a2,0x1
ffffffffc0200f8a:	2d260613          	addi	a2,a2,722 # ffffffffc0202258 <commands+0x598>
ffffffffc0200f8e:	11e00593          	li	a1,286
ffffffffc0200f92:	00001517          	auipc	a0,0x1
ffffffffc0200f96:	2de50513          	addi	a0,a0,734 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200f9a:	c12ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f9e:	00001697          	auipc	a3,0x1
ffffffffc0200fa2:	4c268693          	addi	a3,a3,1218 # ffffffffc0202460 <commands+0x7a0>
ffffffffc0200fa6:	00001617          	auipc	a2,0x1
ffffffffc0200faa:	2b260613          	addi	a2,a2,690 # ffffffffc0202258 <commands+0x598>
ffffffffc0200fae:	11500593          	li	a1,277
ffffffffc0200fb2:	00001517          	auipc	a0,0x1
ffffffffc0200fb6:	2be50513          	addi	a0,a0,702 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200fba:	bf2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200fbe:	00001697          	auipc	a3,0x1
ffffffffc0200fc2:	49268693          	addi	a3,a3,1170 # ffffffffc0202450 <commands+0x790>
ffffffffc0200fc6:	00001617          	auipc	a2,0x1
ffffffffc0200fca:	29260613          	addi	a2,a2,658 # ffffffffc0202258 <commands+0x598>
ffffffffc0200fce:	11400593          	li	a1,276
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	29e50513          	addi	a0,a0,670 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200fda:	bd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200fde:	00001697          	auipc	a3,0x1
ffffffffc0200fe2:	46268693          	addi	a3,a3,1122 # ffffffffc0202440 <commands+0x780>
ffffffffc0200fe6:	00001617          	auipc	a2,0x1
ffffffffc0200fea:	27260613          	addi	a2,a2,626 # ffffffffc0202258 <commands+0x598>
ffffffffc0200fee:	0f600593          	li	a1,246
ffffffffc0200ff2:	00001517          	auipc	a0,0x1
ffffffffc0200ff6:	27e50513          	addi	a0,a0,638 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0200ffa:	bb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ffe:	00001697          	auipc	a3,0x1
ffffffffc0201002:	3e268693          	addi	a3,a3,994 # ffffffffc02023e0 <commands+0x720>
ffffffffc0201006:	00001617          	auipc	a2,0x1
ffffffffc020100a:	25260613          	addi	a2,a2,594 # ffffffffc0202258 <commands+0x598>
ffffffffc020100e:	0f400593          	li	a1,244
ffffffffc0201012:	00001517          	auipc	a0,0x1
ffffffffc0201016:	25e50513          	addi	a0,a0,606 # ffffffffc0202270 <commands+0x5b0>
ffffffffc020101a:	b92ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020101e:	00001697          	auipc	a3,0x1
ffffffffc0201022:	40268693          	addi	a3,a3,1026 # ffffffffc0202420 <commands+0x760>
ffffffffc0201026:	00001617          	auipc	a2,0x1
ffffffffc020102a:	23260613          	addi	a2,a2,562 # ffffffffc0202258 <commands+0x598>
ffffffffc020102e:	0f300593          	li	a1,243
ffffffffc0201032:	00001517          	auipc	a0,0x1
ffffffffc0201036:	23e50513          	addi	a0,a0,574 # ffffffffc0202270 <commands+0x5b0>
ffffffffc020103a:	b72ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020103e <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc020103e:	1141                	addi	sp,sp,-16
ffffffffc0201040:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201042:	14058a63          	beqz	a1,ffffffffc0201196 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0201046:	00259693          	slli	a3,a1,0x2
ffffffffc020104a:	96ae                	add	a3,a3,a1
ffffffffc020104c:	068e                	slli	a3,a3,0x3
ffffffffc020104e:	96aa                	add	a3,a3,a0
ffffffffc0201050:	87aa                	mv	a5,a0
ffffffffc0201052:	02d50263          	beq	a0,a3,ffffffffc0201076 <best_fit_free_pages+0x38>
ffffffffc0201056:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201058:	8b05                	andi	a4,a4,1
ffffffffc020105a:	10071e63          	bnez	a4,ffffffffc0201176 <best_fit_free_pages+0x138>
ffffffffc020105e:	6798                	ld	a4,8(a5)
ffffffffc0201060:	8b09                	andi	a4,a4,2
ffffffffc0201062:	10071a63          	bnez	a4,ffffffffc0201176 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0201066:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020106a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020106e:	02878793          	addi	a5,a5,40
ffffffffc0201072:	fed792e3          	bne	a5,a3,ffffffffc0201056 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0201076:	2581                	sext.w	a1,a1
ffffffffc0201078:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020107a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020107e:	4789                	li	a5,2
ffffffffc0201080:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201084:	00005697          	auipc	a3,0x5
ffffffffc0201088:	f9468693          	addi	a3,a3,-108 # ffffffffc0206018 <free_area>
ffffffffc020108c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020108e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201090:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201094:	9db9                	addw	a1,a1,a4
ffffffffc0201096:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201098:	0ad78863          	beq	a5,a3,ffffffffc0201148 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc020109c:	fe878713          	addi	a4,a5,-24
ffffffffc02010a0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02010a4:	4581                	li	a1,0
            if (base < page) {
ffffffffc02010a6:	00e56a63          	bltu	a0,a4,ffffffffc02010ba <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc02010aa:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010ac:	06d70263          	beq	a4,a3,ffffffffc0201110 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02010b0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010b2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010b6:	fee57ae3          	bgeu	a0,a4,ffffffffc02010aa <best_fit_free_pages+0x6c>
ffffffffc02010ba:	c199                	beqz	a1,ffffffffc02010c0 <best_fit_free_pages+0x82>
ffffffffc02010bc:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010c0:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010c2:	e390                	sd	a2,0(a5)
ffffffffc02010c4:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010c8:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02010ca:	02d70063          	beq	a4,a3,ffffffffc02010ea <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02010ce:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02010d2:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc02010d6:	02081613          	slli	a2,a6,0x20
ffffffffc02010da:	9201                	srli	a2,a2,0x20
ffffffffc02010dc:	00261793          	slli	a5,a2,0x2
ffffffffc02010e0:	97b2                	add	a5,a5,a2
ffffffffc02010e2:	078e                	slli	a5,a5,0x3
ffffffffc02010e4:	97ae                	add	a5,a5,a1
ffffffffc02010e6:	02f50f63          	beq	a0,a5,ffffffffc0201124 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc02010ea:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02010ec:	00d70f63          	beq	a4,a3,ffffffffc020110a <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02010f0:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02010f2:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02010f6:	02059613          	slli	a2,a1,0x20
ffffffffc02010fa:	9201                	srli	a2,a2,0x20
ffffffffc02010fc:	00261793          	slli	a5,a2,0x2
ffffffffc0201100:	97b2                	add	a5,a5,a2
ffffffffc0201102:	078e                	slli	a5,a5,0x3
ffffffffc0201104:	97aa                	add	a5,a5,a0
ffffffffc0201106:	04f68863          	beq	a3,a5,ffffffffc0201156 <best_fit_free_pages+0x118>
}
ffffffffc020110a:	60a2                	ld	ra,8(sp)
ffffffffc020110c:	0141                	addi	sp,sp,16
ffffffffc020110e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201110:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201112:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201114:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201116:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201118:	02d70563          	beq	a4,a3,ffffffffc0201142 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc020111c:	8832                	mv	a6,a2
ffffffffc020111e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201120:	87ba                	mv	a5,a4
ffffffffc0201122:	bf41                	j	ffffffffc02010b2 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc0201124:	491c                	lw	a5,16(a0)
ffffffffc0201126:	0107883b          	addw	a6,a5,a6
ffffffffc020112a:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020112e:	57f5                	li	a5,-3
ffffffffc0201130:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201134:	6d10                	ld	a2,24(a0)
ffffffffc0201136:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0201138:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc020113a:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc020113c:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc020113e:	e390                	sd	a2,0(a5)
ffffffffc0201140:	b775                	j	ffffffffc02010ec <best_fit_free_pages+0xae>
ffffffffc0201142:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201144:	873e                	mv	a4,a5
ffffffffc0201146:	b761                	j	ffffffffc02010ce <best_fit_free_pages+0x90>
}
ffffffffc0201148:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020114a:	e390                	sd	a2,0(a5)
ffffffffc020114c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020114e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201150:	ed1c                	sd	a5,24(a0)
ffffffffc0201152:	0141                	addi	sp,sp,16
ffffffffc0201154:	8082                	ret
            base->property += p->property;
ffffffffc0201156:	ff872783          	lw	a5,-8(a4)
ffffffffc020115a:	ff070693          	addi	a3,a4,-16
ffffffffc020115e:	9dbd                	addw	a1,a1,a5
ffffffffc0201160:	c90c                	sw	a1,16(a0)
ffffffffc0201162:	57f5                	li	a5,-3
ffffffffc0201164:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201168:	6314                	ld	a3,0(a4)
ffffffffc020116a:	671c                	ld	a5,8(a4)
}
ffffffffc020116c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020116e:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201170:	e394                	sd	a3,0(a5)
ffffffffc0201172:	0141                	addi	sp,sp,16
ffffffffc0201174:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201176:	00001697          	auipc	a3,0x1
ffffffffc020117a:	3d268693          	addi	a3,a3,978 # ffffffffc0202548 <commands+0x888>
ffffffffc020117e:	00001617          	auipc	a2,0x1
ffffffffc0201182:	0da60613          	addi	a2,a2,218 # ffffffffc0202258 <commands+0x598>
ffffffffc0201186:	09100593          	li	a1,145
ffffffffc020118a:	00001517          	auipc	a0,0x1
ffffffffc020118e:	0e650513          	addi	a0,a0,230 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0201192:	a1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201196:	00001697          	auipc	a3,0x1
ffffffffc020119a:	0ba68693          	addi	a3,a3,186 # ffffffffc0202250 <commands+0x590>
ffffffffc020119e:	00001617          	auipc	a2,0x1
ffffffffc02011a2:	0ba60613          	addi	a2,a2,186 # ffffffffc0202258 <commands+0x598>
ffffffffc02011a6:	08e00593          	li	a1,142
ffffffffc02011aa:	00001517          	auipc	a0,0x1
ffffffffc02011ae:	0c650513          	addi	a0,a0,198 # ffffffffc0202270 <commands+0x5b0>
ffffffffc02011b2:	9faff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011b6 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011b6:	1141                	addi	sp,sp,-16
ffffffffc02011b8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011ba:	c9e1                	beqz	a1,ffffffffc020128a <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02011bc:	00259693          	slli	a3,a1,0x2
ffffffffc02011c0:	96ae                	add	a3,a3,a1
ffffffffc02011c2:	068e                	slli	a3,a3,0x3
ffffffffc02011c4:	96aa                	add	a3,a3,a0
ffffffffc02011c6:	87aa                	mv	a5,a0
ffffffffc02011c8:	00d50f63          	beq	a0,a3,ffffffffc02011e6 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011cc:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02011ce:	8b05                	andi	a4,a4,1
ffffffffc02011d0:	cf49                	beqz	a4,ffffffffc020126a <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02011d2:	0007a823          	sw	zero,16(a5)
ffffffffc02011d6:	0007b423          	sd	zero,8(a5)
ffffffffc02011da:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011de:	02878793          	addi	a5,a5,40
ffffffffc02011e2:	fed795e3          	bne	a5,a3,ffffffffc02011cc <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc02011e6:	2581                	sext.w	a1,a1
ffffffffc02011e8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011ea:	4789                	li	a5,2
ffffffffc02011ec:	00850713          	addi	a4,a0,8
ffffffffc02011f0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02011f4:	00005697          	auipc	a3,0x5
ffffffffc02011f8:	e2468693          	addi	a3,a3,-476 # ffffffffc0206018 <free_area>
ffffffffc02011fc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02011fe:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201200:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201204:	9db9                	addw	a1,a1,a4
ffffffffc0201206:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201208:	04d78a63          	beq	a5,a3,ffffffffc020125c <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020120c:	fe878713          	addi	a4,a5,-24
ffffffffc0201210:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201214:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201216:	00e56a63          	bltu	a0,a4,ffffffffc020122a <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc020121a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020121c:	02d70263          	beq	a4,a3,ffffffffc0201240 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201220:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201222:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201226:	fee57ae3          	bgeu	a0,a4,ffffffffc020121a <best_fit_init_memmap+0x64>
ffffffffc020122a:	c199                	beqz	a1,ffffffffc0201230 <best_fit_init_memmap+0x7a>
ffffffffc020122c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201230:	6398                	ld	a4,0(a5)
}
ffffffffc0201232:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201234:	e390                	sd	a2,0(a5)
ffffffffc0201236:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201238:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020123a:	ed18                	sd	a4,24(a0)
ffffffffc020123c:	0141                	addi	sp,sp,16
ffffffffc020123e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201240:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201242:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201244:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201246:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201248:	00d70663          	beq	a4,a3,ffffffffc0201254 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020124c:	8832                	mv	a6,a2
ffffffffc020124e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201250:	87ba                	mv	a5,a4
ffffffffc0201252:	bfc1                	j	ffffffffc0201222 <best_fit_init_memmap+0x6c>
}
ffffffffc0201254:	60a2                	ld	ra,8(sp)
ffffffffc0201256:	e290                	sd	a2,0(a3)
ffffffffc0201258:	0141                	addi	sp,sp,16
ffffffffc020125a:	8082                	ret
ffffffffc020125c:	60a2                	ld	ra,8(sp)
ffffffffc020125e:	e390                	sd	a2,0(a5)
ffffffffc0201260:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201262:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201264:	ed1c                	sd	a5,24(a0)
ffffffffc0201266:	0141                	addi	sp,sp,16
ffffffffc0201268:	8082                	ret
        assert(PageReserved(p));
ffffffffc020126a:	00001697          	auipc	a3,0x1
ffffffffc020126e:	30668693          	addi	a3,a3,774 # ffffffffc0202570 <commands+0x8b0>
ffffffffc0201272:	00001617          	auipc	a2,0x1
ffffffffc0201276:	fe660613          	addi	a2,a2,-26 # ffffffffc0202258 <commands+0x598>
ffffffffc020127a:	04a00593          	li	a1,74
ffffffffc020127e:	00001517          	auipc	a0,0x1
ffffffffc0201282:	ff250513          	addi	a0,a0,-14 # ffffffffc0202270 <commands+0x5b0>
ffffffffc0201286:	926ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020128a:	00001697          	auipc	a3,0x1
ffffffffc020128e:	fc668693          	addi	a3,a3,-58 # ffffffffc0202250 <commands+0x590>
ffffffffc0201292:	00001617          	auipc	a2,0x1
ffffffffc0201296:	fc660613          	addi	a2,a2,-58 # ffffffffc0202258 <commands+0x598>
ffffffffc020129a:	04700593          	li	a1,71
ffffffffc020129e:	00001517          	auipc	a0,0x1
ffffffffc02012a2:	fd250513          	addi	a0,a0,-46 # ffffffffc0202270 <commands+0x5b0>
ffffffffc02012a6:	906ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012aa <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012aa:	100027f3          	csrr	a5,sstatus
ffffffffc02012ae:	8b89                	andi	a5,a5,2
ffffffffc02012b0:	e799                	bnez	a5,ffffffffc02012be <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012b2:	00005797          	auipc	a5,0x5
ffffffffc02012b6:	1a67b783          	ld	a5,422(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02012ba:	6f9c                	ld	a5,24(a5)
ffffffffc02012bc:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02012be:	1141                	addi	sp,sp,-16
ffffffffc02012c0:	e406                	sd	ra,8(sp)
ffffffffc02012c2:	e022                	sd	s0,0(sp)
ffffffffc02012c4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012c6:	998ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012ca:	00005797          	auipc	a5,0x5
ffffffffc02012ce:	18e7b783          	ld	a5,398(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02012d2:	6f9c                	ld	a5,24(a5)
ffffffffc02012d4:	8522                	mv	a0,s0
ffffffffc02012d6:	9782                	jalr	a5
ffffffffc02012d8:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02012da:	97eff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012de:	60a2                	ld	ra,8(sp)
ffffffffc02012e0:	8522                	mv	a0,s0
ffffffffc02012e2:	6402                	ld	s0,0(sp)
ffffffffc02012e4:	0141                	addi	sp,sp,16
ffffffffc02012e6:	8082                	ret

ffffffffc02012e8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012e8:	100027f3          	csrr	a5,sstatus
ffffffffc02012ec:	8b89                	andi	a5,a5,2
ffffffffc02012ee:	e799                	bnez	a5,ffffffffc02012fc <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02012f0:	00005797          	auipc	a5,0x5
ffffffffc02012f4:	1687b783          	ld	a5,360(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc02012f8:	739c                	ld	a5,32(a5)
ffffffffc02012fa:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02012fc:	1101                	addi	sp,sp,-32
ffffffffc02012fe:	ec06                	sd	ra,24(sp)
ffffffffc0201300:	e822                	sd	s0,16(sp)
ffffffffc0201302:	e426                	sd	s1,8(sp)
ffffffffc0201304:	842a                	mv	s0,a0
ffffffffc0201306:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201308:	956ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020130c:	00005797          	auipc	a5,0x5
ffffffffc0201310:	14c7b783          	ld	a5,332(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201314:	739c                	ld	a5,32(a5)
ffffffffc0201316:	85a6                	mv	a1,s1
ffffffffc0201318:	8522                	mv	a0,s0
ffffffffc020131a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020131c:	6442                	ld	s0,16(sp)
ffffffffc020131e:	60e2                	ld	ra,24(sp)
ffffffffc0201320:	64a2                	ld	s1,8(sp)
ffffffffc0201322:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201324:	934ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201328 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201328:	100027f3          	csrr	a5,sstatus
ffffffffc020132c:	8b89                	andi	a5,a5,2
ffffffffc020132e:	e799                	bnez	a5,ffffffffc020133c <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201330:	00005797          	auipc	a5,0x5
ffffffffc0201334:	1287b783          	ld	a5,296(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc0201338:	779c                	ld	a5,40(a5)
ffffffffc020133a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020133c:	1141                	addi	sp,sp,-16
ffffffffc020133e:	e406                	sd	ra,8(sp)
ffffffffc0201340:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201342:	91cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201346:	00005797          	auipc	a5,0x5
ffffffffc020134a:	1127b783          	ld	a5,274(a5) # ffffffffc0206458 <pmm_manager>
ffffffffc020134e:	779c                	ld	a5,40(a5)
ffffffffc0201350:	9782                	jalr	a5
ffffffffc0201352:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201354:	904ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201358:	60a2                	ld	ra,8(sp)
ffffffffc020135a:	8522                	mv	a0,s0
ffffffffc020135c:	6402                	ld	s0,0(sp)
ffffffffc020135e:	0141                	addi	sp,sp,16
ffffffffc0201360:	8082                	ret

ffffffffc0201362 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201362:	00001797          	auipc	a5,0x1
ffffffffc0201366:	23678793          	addi	a5,a5,566 # ffffffffc0202598 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020136a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020136c:	1101                	addi	sp,sp,-32
ffffffffc020136e:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201370:	00001517          	auipc	a0,0x1
ffffffffc0201374:	26050513          	addi	a0,a0,608 # ffffffffc02025d0 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201378:	00005497          	auipc	s1,0x5
ffffffffc020137c:	0e048493          	addi	s1,s1,224 # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0201380:	ec06                	sd	ra,24(sp)
ffffffffc0201382:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201384:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201386:	d2dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020138a:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020138c:	00005417          	auipc	s0,0x5
ffffffffc0201390:	0e440413          	addi	s0,s0,228 # ffffffffc0206470 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201394:	679c                	ld	a5,8(a5)
ffffffffc0201396:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201398:	57f5                	li	a5,-3
ffffffffc020139a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020139c:	00001517          	auipc	a0,0x1
ffffffffc02013a0:	24c50513          	addi	a0,a0,588 # ffffffffc02025e8 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013a4:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02013a6:	d0dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013aa:	46c5                	li	a3,17
ffffffffc02013ac:	06ee                	slli	a3,a3,0x1b
ffffffffc02013ae:	40100613          	li	a2,1025
ffffffffc02013b2:	16fd                	addi	a3,a3,-1
ffffffffc02013b4:	07e005b7          	lui	a1,0x7e00
ffffffffc02013b8:	0656                	slli	a2,a2,0x15
ffffffffc02013ba:	00001517          	auipc	a0,0x1
ffffffffc02013be:	24650513          	addi	a0,a0,582 # ffffffffc0202600 <best_fit_pmm_manager+0x68>
ffffffffc02013c2:	cf1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013c6:	777d                	lui	a4,0xfffff
ffffffffc02013c8:	00006797          	auipc	a5,0x6
ffffffffc02013cc:	0b778793          	addi	a5,a5,183 # ffffffffc020747f <end+0xfff>
ffffffffc02013d0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02013d2:	00005517          	auipc	a0,0x5
ffffffffc02013d6:	07650513          	addi	a0,a0,118 # ffffffffc0206448 <npage>
ffffffffc02013da:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013de:	00005597          	auipc	a1,0x5
ffffffffc02013e2:	07258593          	addi	a1,a1,114 # ffffffffc0206450 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02013e6:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013e8:	e19c                	sd	a5,0(a1)
ffffffffc02013ea:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013ec:	4701                	li	a4,0
ffffffffc02013ee:	4885                	li	a7,1
ffffffffc02013f0:	fff80837          	lui	a6,0xfff80
ffffffffc02013f4:	a011                	j	ffffffffc02013f8 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02013f6:	619c                	ld	a5,0(a1)
ffffffffc02013f8:	97b6                	add	a5,a5,a3
ffffffffc02013fa:	07a1                	addi	a5,a5,8
ffffffffc02013fc:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201400:	611c                	ld	a5,0(a0)
ffffffffc0201402:	0705                	addi	a4,a4,1
ffffffffc0201404:	02868693          	addi	a3,a3,40
ffffffffc0201408:	01078633          	add	a2,a5,a6
ffffffffc020140c:	fec765e3          	bltu	a4,a2,ffffffffc02013f6 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201410:	6190                	ld	a2,0(a1)
ffffffffc0201412:	00279713          	slli	a4,a5,0x2
ffffffffc0201416:	973e                	add	a4,a4,a5
ffffffffc0201418:	fec006b7          	lui	a3,0xfec00
ffffffffc020141c:	070e                	slli	a4,a4,0x3
ffffffffc020141e:	96b2                	add	a3,a3,a2
ffffffffc0201420:	96ba                	add	a3,a3,a4
ffffffffc0201422:	c0200737          	lui	a4,0xc0200
ffffffffc0201426:	08e6ef63          	bltu	a3,a4,ffffffffc02014c4 <pmm_init+0x162>
ffffffffc020142a:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020142c:	45c5                	li	a1,17
ffffffffc020142e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201430:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201432:	04b6e863          	bltu	a3,a1,ffffffffc0201482 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201436:	609c                	ld	a5,0(s1)
ffffffffc0201438:	7b9c                	ld	a5,48(a5)
ffffffffc020143a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020143c:	00001517          	auipc	a0,0x1
ffffffffc0201440:	25c50513          	addi	a0,a0,604 # ffffffffc0202698 <best_fit_pmm_manager+0x100>
ffffffffc0201444:	c6ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201448:	00004597          	auipc	a1,0x4
ffffffffc020144c:	bb858593          	addi	a1,a1,-1096 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201450:	00005797          	auipc	a5,0x5
ffffffffc0201454:	00b7bc23          	sd	a1,24(a5) # ffffffffc0206468 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201458:	c02007b7          	lui	a5,0xc0200
ffffffffc020145c:	08f5e063          	bltu	a1,a5,ffffffffc02014dc <pmm_init+0x17a>
ffffffffc0201460:	6010                	ld	a2,0(s0)
}
ffffffffc0201462:	6442                	ld	s0,16(sp)
ffffffffc0201464:	60e2                	ld	ra,24(sp)
ffffffffc0201466:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201468:	40c58633          	sub	a2,a1,a2
ffffffffc020146c:	00005797          	auipc	a5,0x5
ffffffffc0201470:	fec7ba23          	sd	a2,-12(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201474:	00001517          	auipc	a0,0x1
ffffffffc0201478:	24450513          	addi	a0,a0,580 # ffffffffc02026b8 <best_fit_pmm_manager+0x120>
}
ffffffffc020147c:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020147e:	c35fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201482:	6705                	lui	a4,0x1
ffffffffc0201484:	177d                	addi	a4,a4,-1
ffffffffc0201486:	96ba                	add	a3,a3,a4
ffffffffc0201488:	777d                	lui	a4,0xfffff
ffffffffc020148a:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020148c:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201490:	00f57e63          	bgeu	a0,a5,ffffffffc02014ac <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201494:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201496:	982a                	add	a6,a6,a0
ffffffffc0201498:	00281513          	slli	a0,a6,0x2
ffffffffc020149c:	9542                	add	a0,a0,a6
ffffffffc020149e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014a0:	8d95                	sub	a1,a1,a3
ffffffffc02014a2:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014a4:	81b1                	srli	a1,a1,0xc
ffffffffc02014a6:	9532                	add	a0,a0,a2
ffffffffc02014a8:	9782                	jalr	a5
}
ffffffffc02014aa:	b771                	j	ffffffffc0201436 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02014ac:	00001617          	auipc	a2,0x1
ffffffffc02014b0:	1bc60613          	addi	a2,a2,444 # ffffffffc0202668 <best_fit_pmm_manager+0xd0>
ffffffffc02014b4:	06b00593          	li	a1,107
ffffffffc02014b8:	00001517          	auipc	a0,0x1
ffffffffc02014bc:	1d050513          	addi	a0,a0,464 # ffffffffc0202688 <best_fit_pmm_manager+0xf0>
ffffffffc02014c0:	eedfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014c4:	00001617          	auipc	a2,0x1
ffffffffc02014c8:	16c60613          	addi	a2,a2,364 # ffffffffc0202630 <best_fit_pmm_manager+0x98>
ffffffffc02014cc:	07200593          	li	a1,114
ffffffffc02014d0:	00001517          	auipc	a0,0x1
ffffffffc02014d4:	18850513          	addi	a0,a0,392 # ffffffffc0202658 <best_fit_pmm_manager+0xc0>
ffffffffc02014d8:	ed5fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014dc:	86ae                	mv	a3,a1
ffffffffc02014de:	00001617          	auipc	a2,0x1
ffffffffc02014e2:	15260613          	addi	a2,a2,338 # ffffffffc0202630 <best_fit_pmm_manager+0x98>
ffffffffc02014e6:	08d00593          	li	a1,141
ffffffffc02014ea:	00001517          	auipc	a0,0x1
ffffffffc02014ee:	16e50513          	addi	a0,a0,366 # ffffffffc0202658 <best_fit_pmm_manager+0xc0>
ffffffffc02014f2:	ebbfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02014f6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02014f6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014fa:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02014fc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201500:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201502:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201506:	f022                	sd	s0,32(sp)
ffffffffc0201508:	ec26                	sd	s1,24(sp)
ffffffffc020150a:	e84a                	sd	s2,16(sp)
ffffffffc020150c:	f406                	sd	ra,40(sp)
ffffffffc020150e:	e44e                	sd	s3,8(sp)
ffffffffc0201510:	84aa                	mv	s1,a0
ffffffffc0201512:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201514:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201518:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020151a:	03067e63          	bgeu	a2,a6,ffffffffc0201556 <printnum+0x60>
ffffffffc020151e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201520:	00805763          	blez	s0,ffffffffc020152e <printnum+0x38>
ffffffffc0201524:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201526:	85ca                	mv	a1,s2
ffffffffc0201528:	854e                	mv	a0,s3
ffffffffc020152a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020152c:	fc65                	bnez	s0,ffffffffc0201524 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020152e:	1a02                	slli	s4,s4,0x20
ffffffffc0201530:	00001797          	auipc	a5,0x1
ffffffffc0201534:	1c878793          	addi	a5,a5,456 # ffffffffc02026f8 <best_fit_pmm_manager+0x160>
ffffffffc0201538:	020a5a13          	srli	s4,s4,0x20
ffffffffc020153c:	9a3e                	add	s4,s4,a5
}
ffffffffc020153e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201540:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201544:	70a2                	ld	ra,40(sp)
ffffffffc0201546:	69a2                	ld	s3,8(sp)
ffffffffc0201548:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020154a:	85ca                	mv	a1,s2
ffffffffc020154c:	87a6                	mv	a5,s1
}
ffffffffc020154e:	6942                	ld	s2,16(sp)
ffffffffc0201550:	64e2                	ld	s1,24(sp)
ffffffffc0201552:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201554:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201556:	03065633          	divu	a2,a2,a6
ffffffffc020155a:	8722                	mv	a4,s0
ffffffffc020155c:	f9bff0ef          	jal	ra,ffffffffc02014f6 <printnum>
ffffffffc0201560:	b7f9                	j	ffffffffc020152e <printnum+0x38>

ffffffffc0201562 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201562:	7119                	addi	sp,sp,-128
ffffffffc0201564:	f4a6                	sd	s1,104(sp)
ffffffffc0201566:	f0ca                	sd	s2,96(sp)
ffffffffc0201568:	ecce                	sd	s3,88(sp)
ffffffffc020156a:	e8d2                	sd	s4,80(sp)
ffffffffc020156c:	e4d6                	sd	s5,72(sp)
ffffffffc020156e:	e0da                	sd	s6,64(sp)
ffffffffc0201570:	fc5e                	sd	s7,56(sp)
ffffffffc0201572:	f06a                	sd	s10,32(sp)
ffffffffc0201574:	fc86                	sd	ra,120(sp)
ffffffffc0201576:	f8a2                	sd	s0,112(sp)
ffffffffc0201578:	f862                	sd	s8,48(sp)
ffffffffc020157a:	f466                	sd	s9,40(sp)
ffffffffc020157c:	ec6e                	sd	s11,24(sp)
ffffffffc020157e:	892a                	mv	s2,a0
ffffffffc0201580:	84ae                	mv	s1,a1
ffffffffc0201582:	8d32                	mv	s10,a2
ffffffffc0201584:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201586:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020158a:	5b7d                	li	s6,-1
ffffffffc020158c:	00001a97          	auipc	s5,0x1
ffffffffc0201590:	1a0a8a93          	addi	s5,s5,416 # ffffffffc020272c <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201594:	00001b97          	auipc	s7,0x1
ffffffffc0201598:	374b8b93          	addi	s7,s7,884 # ffffffffc0202908 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020159c:	000d4503          	lbu	a0,0(s10)
ffffffffc02015a0:	001d0413          	addi	s0,s10,1
ffffffffc02015a4:	01350a63          	beq	a0,s3,ffffffffc02015b8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02015a8:	c121                	beqz	a0,ffffffffc02015e8 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02015aa:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015ac:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02015ae:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015b0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02015b4:	ff351ae3          	bne	a0,s3,ffffffffc02015a8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02015bc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02015c0:	4c81                	li	s9,0
ffffffffc02015c2:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02015c4:	5c7d                	li	s8,-1
ffffffffc02015c6:	5dfd                	li	s11,-1
ffffffffc02015c8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02015cc:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ce:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015d2:	0ff5f593          	zext.b	a1,a1
ffffffffc02015d6:	00140d13          	addi	s10,s0,1
ffffffffc02015da:	04b56263          	bltu	a0,a1,ffffffffc020161e <vprintfmt+0xbc>
ffffffffc02015de:	058a                	slli	a1,a1,0x2
ffffffffc02015e0:	95d6                	add	a1,a1,s5
ffffffffc02015e2:	4194                	lw	a3,0(a1)
ffffffffc02015e4:	96d6                	add	a3,a3,s5
ffffffffc02015e6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02015e8:	70e6                	ld	ra,120(sp)
ffffffffc02015ea:	7446                	ld	s0,112(sp)
ffffffffc02015ec:	74a6                	ld	s1,104(sp)
ffffffffc02015ee:	7906                	ld	s2,96(sp)
ffffffffc02015f0:	69e6                	ld	s3,88(sp)
ffffffffc02015f2:	6a46                	ld	s4,80(sp)
ffffffffc02015f4:	6aa6                	ld	s5,72(sp)
ffffffffc02015f6:	6b06                	ld	s6,64(sp)
ffffffffc02015f8:	7be2                	ld	s7,56(sp)
ffffffffc02015fa:	7c42                	ld	s8,48(sp)
ffffffffc02015fc:	7ca2                	ld	s9,40(sp)
ffffffffc02015fe:	7d02                	ld	s10,32(sp)
ffffffffc0201600:	6de2                	ld	s11,24(sp)
ffffffffc0201602:	6109                	addi	sp,sp,128
ffffffffc0201604:	8082                	ret
            padc = '0';
ffffffffc0201606:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201608:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020160c:	846a                	mv	s0,s10
ffffffffc020160e:	00140d13          	addi	s10,s0,1
ffffffffc0201612:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201616:	0ff5f593          	zext.b	a1,a1
ffffffffc020161a:	fcb572e3          	bgeu	a0,a1,ffffffffc02015de <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020161e:	85a6                	mv	a1,s1
ffffffffc0201620:	02500513          	li	a0,37
ffffffffc0201624:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201626:	fff44783          	lbu	a5,-1(s0)
ffffffffc020162a:	8d22                	mv	s10,s0
ffffffffc020162c:	f73788e3          	beq	a5,s3,ffffffffc020159c <vprintfmt+0x3a>
ffffffffc0201630:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201634:	1d7d                	addi	s10,s10,-1
ffffffffc0201636:	ff379de3          	bne	a5,s3,ffffffffc0201630 <vprintfmt+0xce>
ffffffffc020163a:	b78d                	j	ffffffffc020159c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020163c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201640:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201644:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201646:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020164a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020164e:	02d86463          	bltu	a6,a3,ffffffffc0201676 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201652:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201656:	002c169b          	slliw	a3,s8,0x2
ffffffffc020165a:	0186873b          	addw	a4,a3,s8
ffffffffc020165e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201662:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201664:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201668:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020166a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020166e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201672:	fed870e3          	bgeu	a6,a3,ffffffffc0201652 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201676:	f40ddce3          	bgez	s11,ffffffffc02015ce <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020167a:	8de2                	mv	s11,s8
ffffffffc020167c:	5c7d                	li	s8,-1
ffffffffc020167e:	bf81                	j	ffffffffc02015ce <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201680:	fffdc693          	not	a3,s11
ffffffffc0201684:	96fd                	srai	a3,a3,0x3f
ffffffffc0201686:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020168a:	00144603          	lbu	a2,1(s0)
ffffffffc020168e:	2d81                	sext.w	s11,s11
ffffffffc0201690:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201692:	bf35                	j	ffffffffc02015ce <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201694:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201698:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020169c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020169e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02016a0:	bfd9                	j	ffffffffc0201676 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02016a2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016a4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016a8:	01174463          	blt	a4,a7,ffffffffc02016b0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02016ac:	1a088e63          	beqz	a7,ffffffffc0201868 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02016b0:	000a3603          	ld	a2,0(s4)
ffffffffc02016b4:	46c1                	li	a3,16
ffffffffc02016b6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02016b8:	2781                	sext.w	a5,a5
ffffffffc02016ba:	876e                	mv	a4,s11
ffffffffc02016bc:	85a6                	mv	a1,s1
ffffffffc02016be:	854a                	mv	a0,s2
ffffffffc02016c0:	e37ff0ef          	jal	ra,ffffffffc02014f6 <printnum>
            break;
ffffffffc02016c4:	bde1                	j	ffffffffc020159c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02016c6:	000a2503          	lw	a0,0(s4)
ffffffffc02016ca:	85a6                	mv	a1,s1
ffffffffc02016cc:	0a21                	addi	s4,s4,8
ffffffffc02016ce:	9902                	jalr	s2
            break;
ffffffffc02016d0:	b5f1                	j	ffffffffc020159c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016d2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016d4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016d8:	01174463          	blt	a4,a7,ffffffffc02016e0 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02016dc:	18088163          	beqz	a7,ffffffffc020185e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02016e0:	000a3603          	ld	a2,0(s4)
ffffffffc02016e4:	46a9                	li	a3,10
ffffffffc02016e6:	8a2e                	mv	s4,a1
ffffffffc02016e8:	bfc1                	j	ffffffffc02016b8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ea:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016ee:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016f2:	bdf1                	j	ffffffffc02015ce <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02016f4:	85a6                	mv	a1,s1
ffffffffc02016f6:	02500513          	li	a0,37
ffffffffc02016fa:	9902                	jalr	s2
            break;
ffffffffc02016fc:	b545                	j	ffffffffc020159c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016fe:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201702:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201704:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201706:	b5e1                	j	ffffffffc02015ce <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201708:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020170a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020170e:	01174463          	blt	a4,a7,ffffffffc0201716 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201712:	14088163          	beqz	a7,ffffffffc0201854 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201716:	000a3603          	ld	a2,0(s4)
ffffffffc020171a:	46a1                	li	a3,8
ffffffffc020171c:	8a2e                	mv	s4,a1
ffffffffc020171e:	bf69                	j	ffffffffc02016b8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201720:	03000513          	li	a0,48
ffffffffc0201724:	85a6                	mv	a1,s1
ffffffffc0201726:	e03e                	sd	a5,0(sp)
ffffffffc0201728:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020172a:	85a6                	mv	a1,s1
ffffffffc020172c:	07800513          	li	a0,120
ffffffffc0201730:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201732:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201734:	6782                	ld	a5,0(sp)
ffffffffc0201736:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201738:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020173c:	bfb5                	j	ffffffffc02016b8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020173e:	000a3403          	ld	s0,0(s4)
ffffffffc0201742:	008a0713          	addi	a4,s4,8
ffffffffc0201746:	e03a                	sd	a4,0(sp)
ffffffffc0201748:	14040263          	beqz	s0,ffffffffc020188c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020174c:	0fb05763          	blez	s11,ffffffffc020183a <vprintfmt+0x2d8>
ffffffffc0201750:	02d00693          	li	a3,45
ffffffffc0201754:	0cd79163          	bne	a5,a3,ffffffffc0201816 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201758:	00044783          	lbu	a5,0(s0)
ffffffffc020175c:	0007851b          	sext.w	a0,a5
ffffffffc0201760:	cf85                	beqz	a5,ffffffffc0201798 <vprintfmt+0x236>
ffffffffc0201762:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201766:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020176a:	000c4563          	bltz	s8,ffffffffc0201774 <vprintfmt+0x212>
ffffffffc020176e:	3c7d                	addiw	s8,s8,-1
ffffffffc0201770:	036c0263          	beq	s8,s6,ffffffffc0201794 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201774:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201776:	0e0c8e63          	beqz	s9,ffffffffc0201872 <vprintfmt+0x310>
ffffffffc020177a:	3781                	addiw	a5,a5,-32
ffffffffc020177c:	0ef47b63          	bgeu	s0,a5,ffffffffc0201872 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201780:	03f00513          	li	a0,63
ffffffffc0201784:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201786:	000a4783          	lbu	a5,0(s4)
ffffffffc020178a:	3dfd                	addiw	s11,s11,-1
ffffffffc020178c:	0a05                	addi	s4,s4,1
ffffffffc020178e:	0007851b          	sext.w	a0,a5
ffffffffc0201792:	ffe1                	bnez	a5,ffffffffc020176a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201794:	01b05963          	blez	s11,ffffffffc02017a6 <vprintfmt+0x244>
ffffffffc0201798:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020179a:	85a6                	mv	a1,s1
ffffffffc020179c:	02000513          	li	a0,32
ffffffffc02017a0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017a2:	fe0d9be3          	bnez	s11,ffffffffc0201798 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017a6:	6a02                	ld	s4,0(sp)
ffffffffc02017a8:	bbd5                	j	ffffffffc020159c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017ac:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02017b0:	01174463          	blt	a4,a7,ffffffffc02017b8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02017b4:	08088d63          	beqz	a7,ffffffffc020184e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02017b8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02017bc:	0a044d63          	bltz	s0,ffffffffc0201876 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02017c0:	8622                	mv	a2,s0
ffffffffc02017c2:	8a66                	mv	s4,s9
ffffffffc02017c4:	46a9                	li	a3,10
ffffffffc02017c6:	bdcd                	j	ffffffffc02016b8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02017c8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017cc:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017ce:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02017d0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017d4:	8fb5                	xor	a5,a5,a3
ffffffffc02017d6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017da:	02d74163          	blt	a4,a3,ffffffffc02017fc <vprintfmt+0x29a>
ffffffffc02017de:	00369793          	slli	a5,a3,0x3
ffffffffc02017e2:	97de                	add	a5,a5,s7
ffffffffc02017e4:	639c                	ld	a5,0(a5)
ffffffffc02017e6:	cb99                	beqz	a5,ffffffffc02017fc <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017e8:	86be                	mv	a3,a5
ffffffffc02017ea:	00001617          	auipc	a2,0x1
ffffffffc02017ee:	f3e60613          	addi	a2,a2,-194 # ffffffffc0202728 <best_fit_pmm_manager+0x190>
ffffffffc02017f2:	85a6                	mv	a1,s1
ffffffffc02017f4:	854a                	mv	a0,s2
ffffffffc02017f6:	0ce000ef          	jal	ra,ffffffffc02018c4 <printfmt>
ffffffffc02017fa:	b34d                	j	ffffffffc020159c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02017fc:	00001617          	auipc	a2,0x1
ffffffffc0201800:	f1c60613          	addi	a2,a2,-228 # ffffffffc0202718 <best_fit_pmm_manager+0x180>
ffffffffc0201804:	85a6                	mv	a1,s1
ffffffffc0201806:	854a                	mv	a0,s2
ffffffffc0201808:	0bc000ef          	jal	ra,ffffffffc02018c4 <printfmt>
ffffffffc020180c:	bb41                	j	ffffffffc020159c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020180e:	00001417          	auipc	s0,0x1
ffffffffc0201812:	f0240413          	addi	s0,s0,-254 # ffffffffc0202710 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201816:	85e2                	mv	a1,s8
ffffffffc0201818:	8522                	mv	a0,s0
ffffffffc020181a:	e43e                	sd	a5,8(sp)
ffffffffc020181c:	1e6000ef          	jal	ra,ffffffffc0201a02 <strnlen>
ffffffffc0201820:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201824:	01b05b63          	blez	s11,ffffffffc020183a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201828:	67a2                	ld	a5,8(sp)
ffffffffc020182a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020182e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201830:	85a6                	mv	a1,s1
ffffffffc0201832:	8552                	mv	a0,s4
ffffffffc0201834:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201836:	fe0d9ce3          	bnez	s11,ffffffffc020182e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020183a:	00044783          	lbu	a5,0(s0)
ffffffffc020183e:	00140a13          	addi	s4,s0,1
ffffffffc0201842:	0007851b          	sext.w	a0,a5
ffffffffc0201846:	d3a5                	beqz	a5,ffffffffc02017a6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201848:	05e00413          	li	s0,94
ffffffffc020184c:	bf39                	j	ffffffffc020176a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020184e:	000a2403          	lw	s0,0(s4)
ffffffffc0201852:	b7ad                	j	ffffffffc02017bc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201854:	000a6603          	lwu	a2,0(s4)
ffffffffc0201858:	46a1                	li	a3,8
ffffffffc020185a:	8a2e                	mv	s4,a1
ffffffffc020185c:	bdb1                	j	ffffffffc02016b8 <vprintfmt+0x156>
ffffffffc020185e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201862:	46a9                	li	a3,10
ffffffffc0201864:	8a2e                	mv	s4,a1
ffffffffc0201866:	bd89                	j	ffffffffc02016b8 <vprintfmt+0x156>
ffffffffc0201868:	000a6603          	lwu	a2,0(s4)
ffffffffc020186c:	46c1                	li	a3,16
ffffffffc020186e:	8a2e                	mv	s4,a1
ffffffffc0201870:	b5a1                	j	ffffffffc02016b8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201872:	9902                	jalr	s2
ffffffffc0201874:	bf09                	j	ffffffffc0201786 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201876:	85a6                	mv	a1,s1
ffffffffc0201878:	02d00513          	li	a0,45
ffffffffc020187c:	e03e                	sd	a5,0(sp)
ffffffffc020187e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201880:	6782                	ld	a5,0(sp)
ffffffffc0201882:	8a66                	mv	s4,s9
ffffffffc0201884:	40800633          	neg	a2,s0
ffffffffc0201888:	46a9                	li	a3,10
ffffffffc020188a:	b53d                	j	ffffffffc02016b8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020188c:	03b05163          	blez	s11,ffffffffc02018ae <vprintfmt+0x34c>
ffffffffc0201890:	02d00693          	li	a3,45
ffffffffc0201894:	f6d79de3          	bne	a5,a3,ffffffffc020180e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201898:	00001417          	auipc	s0,0x1
ffffffffc020189c:	e7840413          	addi	s0,s0,-392 # ffffffffc0202710 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a0:	02800793          	li	a5,40
ffffffffc02018a4:	02800513          	li	a0,40
ffffffffc02018a8:	00140a13          	addi	s4,s0,1
ffffffffc02018ac:	bd6d                	j	ffffffffc0201766 <vprintfmt+0x204>
ffffffffc02018ae:	00001a17          	auipc	s4,0x1
ffffffffc02018b2:	e63a0a13          	addi	s4,s4,-413 # ffffffffc0202711 <best_fit_pmm_manager+0x179>
ffffffffc02018b6:	02800513          	li	a0,40
ffffffffc02018ba:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018be:	05e00413          	li	s0,94
ffffffffc02018c2:	b565                	j	ffffffffc020176a <vprintfmt+0x208>

ffffffffc02018c4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018c4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02018c6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018ca:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018cc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018ce:	ec06                	sd	ra,24(sp)
ffffffffc02018d0:	f83a                	sd	a4,48(sp)
ffffffffc02018d2:	fc3e                	sd	a5,56(sp)
ffffffffc02018d4:	e0c2                	sd	a6,64(sp)
ffffffffc02018d6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02018d8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018da:	c89ff0ef          	jal	ra,ffffffffc0201562 <vprintfmt>
}
ffffffffc02018de:	60e2                	ld	ra,24(sp)
ffffffffc02018e0:	6161                	addi	sp,sp,80
ffffffffc02018e2:	8082                	ret

ffffffffc02018e4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02018e4:	715d                	addi	sp,sp,-80
ffffffffc02018e6:	e486                	sd	ra,72(sp)
ffffffffc02018e8:	e0a6                	sd	s1,64(sp)
ffffffffc02018ea:	fc4a                	sd	s2,56(sp)
ffffffffc02018ec:	f84e                	sd	s3,48(sp)
ffffffffc02018ee:	f452                	sd	s4,40(sp)
ffffffffc02018f0:	f056                	sd	s5,32(sp)
ffffffffc02018f2:	ec5a                	sd	s6,24(sp)
ffffffffc02018f4:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02018f6:	c901                	beqz	a0,ffffffffc0201906 <readline+0x22>
ffffffffc02018f8:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02018fa:	00001517          	auipc	a0,0x1
ffffffffc02018fe:	e2e50513          	addi	a0,a0,-466 # ffffffffc0202728 <best_fit_pmm_manager+0x190>
ffffffffc0201902:	fb0fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201906:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201908:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020190a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020190c:	4aa9                	li	s5,10
ffffffffc020190e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201910:	00004b97          	auipc	s7,0x4
ffffffffc0201914:	720b8b93          	addi	s7,s7,1824 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201918:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020191c:	80ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201920:	00054a63          	bltz	a0,ffffffffc0201934 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201924:	00a95a63          	bge	s2,a0,ffffffffc0201938 <readline+0x54>
ffffffffc0201928:	029a5263          	bge	s4,s1,ffffffffc020194c <readline+0x68>
        c = getchar();
ffffffffc020192c:	ffefe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201930:	fe055ae3          	bgez	a0,ffffffffc0201924 <readline+0x40>
            return NULL;
ffffffffc0201934:	4501                	li	a0,0
ffffffffc0201936:	a091                	j	ffffffffc020197a <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201938:	03351463          	bne	a0,s3,ffffffffc0201960 <readline+0x7c>
ffffffffc020193c:	e8a9                	bnez	s1,ffffffffc020198e <readline+0xaa>
        c = getchar();
ffffffffc020193e:	fecfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201942:	fe0549e3          	bltz	a0,ffffffffc0201934 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201946:	fea959e3          	bge	s2,a0,ffffffffc0201938 <readline+0x54>
ffffffffc020194a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020194c:	e42a                	sd	a0,8(sp)
ffffffffc020194e:	f9afe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201952:	6522                	ld	a0,8(sp)
ffffffffc0201954:	009b87b3          	add	a5,s7,s1
ffffffffc0201958:	2485                	addiw	s1,s1,1
ffffffffc020195a:	00a78023          	sb	a0,0(a5)
ffffffffc020195e:	bf7d                	j	ffffffffc020191c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201960:	01550463          	beq	a0,s5,ffffffffc0201968 <readline+0x84>
ffffffffc0201964:	fb651ce3          	bne	a0,s6,ffffffffc020191c <readline+0x38>
            cputchar(c);
ffffffffc0201968:	f80fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020196c:	00004517          	auipc	a0,0x4
ffffffffc0201970:	6c450513          	addi	a0,a0,1732 # ffffffffc0206030 <buf>
ffffffffc0201974:	94aa                	add	s1,s1,a0
ffffffffc0201976:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020197a:	60a6                	ld	ra,72(sp)
ffffffffc020197c:	6486                	ld	s1,64(sp)
ffffffffc020197e:	7962                	ld	s2,56(sp)
ffffffffc0201980:	79c2                	ld	s3,48(sp)
ffffffffc0201982:	7a22                	ld	s4,40(sp)
ffffffffc0201984:	7a82                	ld	s5,32(sp)
ffffffffc0201986:	6b62                	ld	s6,24(sp)
ffffffffc0201988:	6bc2                	ld	s7,16(sp)
ffffffffc020198a:	6161                	addi	sp,sp,80
ffffffffc020198c:	8082                	ret
            cputchar(c);
ffffffffc020198e:	4521                	li	a0,8
ffffffffc0201990:	f58fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201994:	34fd                	addiw	s1,s1,-1
ffffffffc0201996:	b759                	j	ffffffffc020191c <readline+0x38>

ffffffffc0201998 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201998:	4781                	li	a5,0
ffffffffc020199a:	00004717          	auipc	a4,0x4
ffffffffc020199e:	66e73703          	ld	a4,1646(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02019a2:	88ba                	mv	a7,a4
ffffffffc02019a4:	852a                	mv	a0,a0
ffffffffc02019a6:	85be                	mv	a1,a5
ffffffffc02019a8:	863e                	mv	a2,a5
ffffffffc02019aa:	00000073          	ecall
ffffffffc02019ae:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02019b0:	8082                	ret

ffffffffc02019b2 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02019b2:	4781                	li	a5,0
ffffffffc02019b4:	00005717          	auipc	a4,0x5
ffffffffc02019b8:	ac473703          	ld	a4,-1340(a4) # ffffffffc0206478 <SBI_SET_TIMER>
ffffffffc02019bc:	88ba                	mv	a7,a4
ffffffffc02019be:	852a                	mv	a0,a0
ffffffffc02019c0:	85be                	mv	a1,a5
ffffffffc02019c2:	863e                	mv	a2,a5
ffffffffc02019c4:	00000073          	ecall
ffffffffc02019c8:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02019ca:	8082                	ret

ffffffffc02019cc <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02019cc:	4501                	li	a0,0
ffffffffc02019ce:	00004797          	auipc	a5,0x4
ffffffffc02019d2:	6327b783          	ld	a5,1586(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02019d6:	88be                	mv	a7,a5
ffffffffc02019d8:	852a                	mv	a0,a0
ffffffffc02019da:	85aa                	mv	a1,a0
ffffffffc02019dc:	862a                	mv	a2,a0
ffffffffc02019de:	00000073          	ecall
ffffffffc02019e2:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc02019e4:	2501                	sext.w	a0,a0
ffffffffc02019e6:	8082                	ret

ffffffffc02019e8 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc02019e8:	4781                	li	a5,0
ffffffffc02019ea:	00004717          	auipc	a4,0x4
ffffffffc02019ee:	62673703          	ld	a4,1574(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc02019f2:	88ba                	mv	a7,a4
ffffffffc02019f4:	853e                	mv	a0,a5
ffffffffc02019f6:	85be                	mv	a1,a5
ffffffffc02019f8:	863e                	mv	a2,a5
ffffffffc02019fa:	00000073          	ecall
ffffffffc02019fe:	87aa                	mv	a5,a0

void sbi_shutdown(void){
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201a00:	8082                	ret

ffffffffc0201a02 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201a02:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a04:	e589                	bnez	a1,ffffffffc0201a0e <strnlen+0xc>
ffffffffc0201a06:	a811                	j	ffffffffc0201a1a <strnlen+0x18>
        cnt ++;
ffffffffc0201a08:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a0a:	00f58863          	beq	a1,a5,ffffffffc0201a1a <strnlen+0x18>
ffffffffc0201a0e:	00f50733          	add	a4,a0,a5
ffffffffc0201a12:	00074703          	lbu	a4,0(a4)
ffffffffc0201a16:	fb6d                	bnez	a4,ffffffffc0201a08 <strnlen+0x6>
ffffffffc0201a18:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a1a:	852e                	mv	a0,a1
ffffffffc0201a1c:	8082                	ret

ffffffffc0201a1e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a1e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a22:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a26:	cb89                	beqz	a5,ffffffffc0201a38 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a28:	0505                	addi	a0,a0,1
ffffffffc0201a2a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a2c:	fee789e3          	beq	a5,a4,ffffffffc0201a1e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a30:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a34:	9d19                	subw	a0,a0,a4
ffffffffc0201a36:	8082                	ret
ffffffffc0201a38:	4501                	li	a0,0
ffffffffc0201a3a:	bfed                	j	ffffffffc0201a34 <strcmp+0x16>

ffffffffc0201a3c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a3c:	00054783          	lbu	a5,0(a0)
ffffffffc0201a40:	c799                	beqz	a5,ffffffffc0201a4e <strchr+0x12>
        if (*s == c) {
ffffffffc0201a42:	00f58763          	beq	a1,a5,ffffffffc0201a50 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201a46:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201a4a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201a4c:	fbfd                	bnez	a5,ffffffffc0201a42 <strchr+0x6>
    }
    return NULL;
ffffffffc0201a4e:	4501                	li	a0,0
}
ffffffffc0201a50:	8082                	ret

ffffffffc0201a52 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a52:	ca01                	beqz	a2,ffffffffc0201a62 <memset+0x10>
ffffffffc0201a54:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a56:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a58:	0785                	addi	a5,a5,1
ffffffffc0201a5a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a5e:	fec79de3          	bne	a5,a2,ffffffffc0201a58 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a62:	8082                	ret
