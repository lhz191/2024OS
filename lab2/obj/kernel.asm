
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
ffffffffc020004a:	343010ef          	jal	ra,ffffffffc0201b8c <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0201ba0 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	450010ef          	jal	ra,ffffffffc02014b6 <pmm_init>

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
ffffffffc02000a6:	610010ef          	jal	ra,ffffffffc02016b6 <vprintfmt>
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
ffffffffc02000dc:	5da010ef          	jal	ra,ffffffffc02016b6 <vprintfmt>
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
ffffffffc0200140:	a8450513          	addi	a0,a0,-1404 # ffffffffc0201bc0 <etext+0x22>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0201be0 <etext+0x42>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	a4058593          	addi	a1,a1,-1472 # ffffffffc0201b9e <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0201c00 <etext+0x62>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buddy_zone>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	aa650513          	addi	a0,a0,-1370 # ffffffffc0201c20 <etext+0x82>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	3e258593          	addi	a1,a1,994 # ffffffffc0206568 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	ab250513          	addi	a0,a0,-1358 # ffffffffc0201c40 <etext+0xa2>
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
ffffffffc02001c0:	aa450513          	addi	a0,a0,-1372 # ffffffffc0201c60 <etext+0xc2>
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
ffffffffc02001ce:	ac660613          	addi	a2,a2,-1338 # ffffffffc0201c90 <etext+0xf2>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	ad250513          	addi	a0,a0,-1326 # ffffffffc0201ca8 <etext+0x10a>
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
ffffffffc02001ea:	ada60613          	addi	a2,a2,-1318 # ffffffffc0201cc0 <etext+0x122>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	af258593          	addi	a1,a1,-1294 # ffffffffc0201ce0 <etext+0x142>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	af250513          	addi	a0,a0,-1294 # ffffffffc0201ce8 <etext+0x14a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	af460613          	addi	a2,a2,-1292 # ffffffffc0201cf8 <etext+0x15a>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	b1458593          	addi	a1,a1,-1260 # ffffffffc0201d20 <etext+0x182>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	ad450513          	addi	a0,a0,-1324 # ffffffffc0201ce8 <etext+0x14a>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	b1060613          	addi	a2,a2,-1264 # ffffffffc0201d30 <etext+0x192>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	b2858593          	addi	a1,a1,-1240 # ffffffffc0201d50 <etext+0x1b2>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	ab850513          	addi	a0,a0,-1352 # ffffffffc0201ce8 <etext+0x14a>
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
ffffffffc020026e:	af650513          	addi	a0,a0,-1290 # ffffffffc0201d60 <etext+0x1c2>
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
ffffffffc0200290:	afc50513          	addi	a0,a0,-1284 # ffffffffc0201d88 <etext+0x1ea>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	b56c0c13          	addi	s8,s8,-1194 # ffffffffc0201df8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	b0690913          	addi	s2,s2,-1274 # ffffffffc0201db0 <etext+0x212>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	b0648493          	addi	s1,s1,-1274 # ffffffffc0201db8 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	b04b0b13          	addi	s6,s6,-1276 # ffffffffc0201dc0 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	a1ca0a13          	addi	s4,s4,-1508 # ffffffffc0201ce0 <etext+0x142>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	768010ef          	jal	ra,ffffffffc0201a38 <readline>
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
ffffffffc02002ea:	b12d0d13          	addi	s10,s10,-1262 # ffffffffc0201df8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	065010ef          	jal	ra,ffffffffc0201b58 <strcmp>
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
ffffffffc0200308:	051010ef          	jal	ra,ffffffffc0201b58 <strcmp>
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
ffffffffc0200346:	031010ef          	jal	ra,ffffffffc0201b76 <strchr>
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
ffffffffc0200384:	7f2010ef          	jal	ra,ffffffffc0201b76 <strchr>
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
ffffffffc02003a2:	a4250513          	addi	a0,a0,-1470 # ffffffffc0201de0 <etext+0x242>
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
ffffffffc02003de:	a6650513          	addi	a0,a0,-1434 # ffffffffc0201e40 <commands+0x48>
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
ffffffffc02003f4:	89850513          	addi	a0,a0,-1896 # ffffffffc0201c88 <etext+0xea>
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
ffffffffc0200420:	6e6010ef          	jal	ra,ffffffffc0201b06 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	1007b123          	sd	zero,258(a5) # ffffffffc0206528 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	a3250513          	addi	a0,a0,-1486 # ffffffffc0201e60 <commands+0x68>
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
ffffffffc0200446:	6c00106f          	j	ffffffffc0201b06 <sbi_set_timer>

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
ffffffffc0200450:	69c0106f          	j	ffffffffc0201aec <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	6cc0106f          	j	ffffffffc0201b20 <sbi_console_getchar>

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
ffffffffc0200482:	a0250513          	addi	a0,a0,-1534 # ffffffffc0201e80 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0201e98 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	a1450513          	addi	a0,a0,-1516 # ffffffffc0201eb0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201ec8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	a2850513          	addi	a0,a0,-1496 # ffffffffc0201ee0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	a3250513          	addi	a0,a0,-1486 # ffffffffc0201ef8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0201f10 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201f28 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0201f40 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0201f58 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201f70 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201f88 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201fa0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201fb8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201fd0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	a9650513          	addi	a0,a0,-1386 # ffffffffc0201fe8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	aa050513          	addi	a0,a0,-1376 # ffffffffc0202000 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0202018 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	ab450513          	addi	a0,a0,-1356 # ffffffffc0202030 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0202048 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0202060 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	ad250513          	addi	a0,a0,-1326 # ffffffffc0202078 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	adc50513          	addi	a0,a0,-1316 # ffffffffc0202090 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	ae650513          	addi	a0,a0,-1306 # ffffffffc02020a8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	af050513          	addi	a0,a0,-1296 # ffffffffc02020c0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	afa50513          	addi	a0,a0,-1286 # ffffffffc02020d8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02020f0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0202108 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0202120 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0202138 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0202150 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0202168 <commands+0x370>
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
ffffffffc020064e:	b3650513          	addi	a0,a0,-1226 # ffffffffc0202180 <commands+0x388>
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
ffffffffc0200666:	b3650513          	addi	a0,a0,-1226 # ffffffffc0202198 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	b3e50513          	addi	a0,a0,-1218 # ffffffffc02021b0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	b4650513          	addi	a0,a0,-1210 # ffffffffc02021c8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02021e0 <commands+0x3e8>
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
ffffffffc02006b4:	c1070713          	addi	a4,a4,-1008 # ffffffffc02022c0 <commands+0x4c8>
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
ffffffffc02006c6:	b9650513          	addi	a0,a0,-1130 # ffffffffc0202258 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202238 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	b2250513          	addi	a0,a0,-1246 # ffffffffc02021f8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	b9850513          	addi	a0,a0,-1128 # ffffffffc0202278 <commands+0x480>
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
ffffffffc0200714:	b9050513          	addi	a0,a0,-1136 # ffffffffc02022a0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	afe50513          	addi	a0,a0,-1282 # ffffffffc0202218 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	b6450513          	addi	a0,a0,-1180 # ffffffffc0202290 <commands+0x498>
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

ffffffffc0200802 <buddy_system_pmm_init>:
buddy_zone_t buddy_zone;  // External declaration for buddy_zone

// Init function for buddy system
static void buddy_system_pmm_init(void) {
    // cprintf("111111111111111111111111\n");
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <buddy_zone>
ffffffffc020080a:	00006717          	auipc	a4,0x6
ffffffffc020080e:	90e70713          	addi	a4,a4,-1778 # ffffffffc0206118 <buddy_zone+0x108>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200812:	e79c                	sd	a5,8(a5)
ffffffffc0200814:	e39c                	sd	a5,0(a5)
        list_init(&buddy_zone.free_area[i].free_list);  // Initialize each free list
        buddy_zone.free_area[i].nr_free = 0;  // Properly access nr_free for buddy_zone
ffffffffc0200816:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc020081a:	07e1                	addi	a5,a5,24
ffffffffc020081c:	fee79be3          	bne	a5,a4,ffffffffc0200812 <buddy_system_pmm_init+0x10>
    }
    // buddy_zone.free_area[0].nr_free = 0;  // Properly access nr_free for buddy_zone
    //  cprintf("22222222222222222222\n");
}
ffffffffc0200820:	8082                	ret

ffffffffc0200822 <buddy_nr_free_pages>:
}


static size_t buddy_nr_free_pages(void) {
    size_t total_cnt = 0;
    for (size_t i = 0; i < MAX_ORDER; i++) {
ffffffffc0200822:	00005797          	auipc	a5,0x5
ffffffffc0200826:	7fe78793          	addi	a5,a5,2046 # ffffffffc0206020 <buddy_zone+0x10>
ffffffffc020082a:	00006697          	auipc	a3,0x6
ffffffffc020082e:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0206128 <buf+0x8>
    size_t total_cnt = 0;
ffffffffc0200832:	4501                	li	a0,0
        total_cnt += buddy_zone.free_area[i].nr_free;
ffffffffc0200834:	0007e703          	lwu	a4,0(a5)
    for (size_t i = 0; i < MAX_ORDER; i++) {
ffffffffc0200838:	07e1                	addi	a5,a5,24
        total_cnt += buddy_zone.free_area[i].nr_free;
ffffffffc020083a:	953a                	add	a0,a0,a4
    for (size_t i = 0; i < MAX_ORDER; i++) {
ffffffffc020083c:	fed79ce3          	bne	a5,a3,ffffffffc0200834 <buddy_nr_free_pages+0x12>
    }
    return total_cnt;
}
ffffffffc0200840:	8082                	ret

ffffffffc0200842 <buddy_system_pmm_alloc_pages>:
static struct Page * buddy_system_pmm_alloc_pages(size_t n) {
ffffffffc0200842:	715d                	addi	sp,sp,-80
ffffffffc0200844:	e486                	sd	ra,72(sp)
ffffffffc0200846:	e0a2                	sd	s0,64(sp)
ffffffffc0200848:	fc26                	sd	s1,56(sp)
ffffffffc020084a:	f84a                	sd	s2,48(sp)
ffffffffc020084c:	f44e                	sd	s3,40(sp)
ffffffffc020084e:	f052                	sd	s4,32(sp)
ffffffffc0200850:	ec56                	sd	s5,24(sp)
ffffffffc0200852:	e85a                	sd	s6,16(sp)
ffffffffc0200854:	e45e                	sd	s7,8(sp)
    assert(n > 0);
ffffffffc0200856:	1c050863          	beqz	a0,ffffffffc0200a26 <buddy_system_pmm_alloc_pages+0x1e4>
    if (n > buddy_zone.n_sum) {
ffffffffc020085a:	00005a97          	auipc	s5,0x5
ffffffffc020085e:	7b6a8a93          	addi	s5,s5,1974 # ffffffffc0206010 <buddy_zone>
ffffffffc0200862:	108ab783          	ld	a5,264(s5)
ffffffffc0200866:	892a                	mv	s2,a0
        return NULL;
ffffffffc0200868:	4481                	li	s1,0
    if (n > buddy_zone.n_sum) {
ffffffffc020086a:	04a7ef63          	bltu	a5,a0,ffffffffc02008c8 <buddy_system_pmm_alloc_pages+0x86>
    if(n==1)
ffffffffc020086e:	4785                	li	a5,1
ffffffffc0200870:	06f50b63          	beq	a0,a5,ffffffffc02008e6 <buddy_system_pmm_alloc_pages+0xa4>
    if (n & (n - 1)) return 0;
ffffffffc0200874:	fff50793          	addi	a5,a0,-1
ffffffffc0200878:	8fe9                	and	a5,a5,a0
ffffffffc020087a:	c3bd                	beqz	a5,ffffffffc02008e0 <buddy_system_pmm_alloc_pages+0x9e>
ffffffffc020087c:	86aa                	mv	a3,a0
    size_t res = 1;
ffffffffc020087e:	4705                	li	a4,1
            n = n >> 1;
ffffffffc0200880:	8285                	srli	a3,a3,0x1
            res = res << 1;
ffffffffc0200882:	0706                	slli	a4,a4,0x1
        while (n)
ffffffffc0200884:	fef5                	bnez	a3,ffffffffc0200880 <buddy_system_pmm_alloc_pages+0x3e>
    while (n >> 1)
ffffffffc0200886:	00175793          	srli	a5,a4,0x1
ffffffffc020088a:	cf31                	beqz	a4,ffffffffc02008e6 <buddy_system_pmm_alloc_pages+0xa4>
    size_t res = 1;
ffffffffc020088c:	4701                	li	a4,0
    while (n >> 1)
ffffffffc020088e:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200890:	2705                	addiw	a4,a4,1
    while (n >> 1)
ffffffffc0200892:	fff5                	bnez	a5,ffffffffc020088e <buddy_system_pmm_alloc_pages+0x4c>
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc0200894:	47ad                	li	a5,11
    int order_needed = getorder(getup2(n)); // 找到需要的最小阶层
ffffffffc0200896:	0007099b          	sext.w	s3,a4
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc020089a:	02e7c663          	blt	a5,a4,ffffffffc02008c6 <buddy_system_pmm_alloc_pages+0x84>
        if (buddy_zone.free_area[order].nr_free / (1 << order) > 0) {
ffffffffc020089e:	00199793          	slli	a5,s3,0x1
ffffffffc02008a2:	97ce                	add	a5,a5,s3
ffffffffc02008a4:	078e                	slli	a5,a5,0x3
ffffffffc02008a6:	97d6                	add	a5,a5,s5
ffffffffc02008a8:	4b94                	lw	a3,16(a5)
ffffffffc02008aa:	844e                	mv	s0,s3
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc02008ac:	4631                	li	a2,12
        if (buddy_zone.free_area[order].nr_free / (1 << order) > 0) {
ffffffffc02008ae:	0136d73b          	srlw	a4,a3,s3
ffffffffc02008b2:	c719                	beqz	a4,ffffffffc02008c0 <buddy_system_pmm_alloc_pages+0x7e>
ffffffffc02008b4:	a81d                	j	ffffffffc02008ea <buddy_system_pmm_alloc_pages+0xa8>
ffffffffc02008b6:	5794                	lw	a3,40(a5)
ffffffffc02008b8:	07e1                	addi	a5,a5,24
ffffffffc02008ba:	0086d73b          	srlw	a4,a3,s0
ffffffffc02008be:	e715                	bnez	a4,ffffffffc02008ea <buddy_system_pmm_alloc_pages+0xa8>
    for (int order = order_needed; order <= MAX_ORDER; order++) {
ffffffffc02008c0:	2405                	addiw	s0,s0,1
ffffffffc02008c2:	fec41ae3          	bne	s0,a2,ffffffffc02008b6 <buddy_system_pmm_alloc_pages+0x74>
        return NULL;
ffffffffc02008c6:	4481                	li	s1,0
}
ffffffffc02008c8:	60a6                	ld	ra,72(sp)
ffffffffc02008ca:	6406                	ld	s0,64(sp)
ffffffffc02008cc:	7942                	ld	s2,48(sp)
ffffffffc02008ce:	79a2                	ld	s3,40(sp)
ffffffffc02008d0:	7a02                	ld	s4,32(sp)
ffffffffc02008d2:	6ae2                	ld	s5,24(sp)
ffffffffc02008d4:	6b42                	ld	s6,16(sp)
ffffffffc02008d6:	6ba2                	ld	s7,8(sp)
ffffffffc02008d8:	8526                	mv	a0,s1
ffffffffc02008da:	74e2                	ld	s1,56(sp)
ffffffffc02008dc:	6161                	addi	sp,sp,80
ffffffffc02008de:	8082                	ret
    while (n >> 1)
ffffffffc02008e0:	00155793          	srli	a5,a0,0x1
ffffffffc02008e4:	b765                	j	ffffffffc020088c <buddy_system_pmm_alloc_pages+0x4a>
    int order_needed = getorder(getup2(n)); // 找到需要的最小阶层
ffffffffc02008e6:	4981                	li	s3,0
ffffffffc02008e8:	bf5d                	j	ffffffffc020089e <buddy_system_pmm_alloc_pages+0x5c>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008ea:	00141713          	slli	a4,s0,0x1
ffffffffc02008ee:	00870a33          	add	s4,a4,s0
ffffffffc02008f2:	0a0e                	slli	s4,s4,0x3
ffffffffc02008f4:	014a8633          	add	a2,s5,s4
ffffffffc02008f8:	00863b03          	ld	s6,8(a2)
            buddy_zone.free_area[order].nr_free-=(1<<order);
ffffffffc02008fc:	4785                	li	a5,1
ffffffffc02008fe:	00879bbb          	sllw	s7,a5,s0
    __list_del(listelm->prev, listelm->next);
ffffffffc0200902:	000b3503          	ld	a0,0(s6)
ffffffffc0200906:	008b3583          	ld	a1,8(s6)
ffffffffc020090a:	417686bb          	subw	a3,a3,s7
            struct Page *p = le2page(le, page_link);
ffffffffc020090e:	fe8b0493          	addi	s1,s6,-24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200912:	e50c                	sd	a1,8(a0)
    next->prev = prev;
ffffffffc0200914:	e188                	sd	a0,0(a1)
            buddy_zone.free_area[order].nr_free-=(1<<order);
ffffffffc0200916:	ca14                	sw	a3,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200918:	57f5                	li	a5,-3
ffffffffc020091a:	ff0b0693          	addi	a3,s6,-16
ffffffffc020091e:	60f6b02f          	amoand.d	zero,a5,(a3)
    if(n==1)
ffffffffc0200922:	4785                	li	a5,1
ffffffffc0200924:	0af90263          	beq	s2,a5,ffffffffc02009c8 <buddy_system_pmm_alloc_pages+0x186>
    if (n & (n - 1)) return 0;
ffffffffc0200928:	fff90793          	addi	a5,s2,-1
ffffffffc020092c:	0127f7b3          	and	a5,a5,s2
ffffffffc0200930:	cfc1                	beqz	a5,ffffffffc02009c8 <buddy_system_pmm_alloc_pages+0x186>
                cprintf("begin");
ffffffffc0200932:	00002517          	auipc	a0,0x2
ffffffffc0200936:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0202330 <commands+0x538>
ffffffffc020093a:	f78ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("order: %d\n", order);  // 打印 n 的值
ffffffffc020093e:	85a2                	mv	a1,s0
ffffffffc0200940:	00002517          	auipc	a0,0x2
ffffffffc0200944:	9f850513          	addi	a0,a0,-1544 # ffffffffc0202338 <commands+0x540>
ffffffffc0200948:	f6aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("n: %d\n", n);  // 打印 n 的值
ffffffffc020094c:	85ca                	mv	a1,s2
ffffffffc020094e:	00002517          	auipc	a0,0x2
ffffffffc0200952:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0202348 <commands+0x550>
                while ((1 << order) > 2 * n) {
ffffffffc0200956:	0906                	slli	s2,s2,0x1
                cprintf("n: %d\n", n);  // 打印 n 的值
ffffffffc0200958:	f5aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                while ((1 << order) > 2 * n) {
ffffffffc020095c:	07797063          	bgeu	s2,s7,ffffffffc02009bc <buddy_system_pmm_alloc_pages+0x17a>
ffffffffc0200960:	fd0a0713          	addi	a4,s4,-48
ffffffffc0200964:	9756                	add	a4,a4,s5
            struct Page *p = le2page(le, page_link);
ffffffffc0200966:	8826                	mv	a6,s1
                    struct Page *split_buddy = p + (1 << (order-1));
ffffffffc0200968:	4505                	li	a0,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020096a:	4e09                	li	t3,2
ffffffffc020096c:	ffe4069b          	addiw	a3,s0,-2
ffffffffc0200970:	00d5163b          	sllw	a2,a0,a3
                    order--;
ffffffffc0200974:	347d                	addiw	s0,s0,-1
                    p+=1<<order;
ffffffffc0200976:	008515bb          	sllw	a1,a0,s0
                    struct Page *split_buddy = p + (1 << (order-1));
ffffffffc020097a:	00261793          	slli	a5,a2,0x2
ffffffffc020097e:	86b2                	mv	a3,a2
ffffffffc0200980:	97b2                	add	a5,a5,a2
                    p+=1<<order;
ffffffffc0200982:	00259613          	slli	a2,a1,0x2
ffffffffc0200986:	962e                	add	a2,a2,a1
                    struct Page *split_buddy = p + (1 << (order-1));
ffffffffc0200988:	078e                	slli	a5,a5,0x3
ffffffffc020098a:	97c2                	add	a5,a5,a6
                    p+=1<<order;
ffffffffc020098c:	060e                	slli	a2,a2,0x3
ffffffffc020098e:	9832                	add	a6,a6,a2
                    split_buddy->property = 1 << (order-1);
ffffffffc0200990:	cb94                	sw	a3,16(a5)
ffffffffc0200992:	00878613          	addi	a2,a5,8
ffffffffc0200996:	41c6302f          	amoor.d	zero,t3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020099a:	00873883          	ld	a7,8(a4)
                    buddy_zone.free_area[order-1].nr_free+=(1<<(order-1));
ffffffffc020099e:	4b10                	lw	a2,16(a4)
                    list_add(&buddy_zone.free_area[order-1].free_list, &split_buddy->page_link);
ffffffffc02009a0:	01878313          	addi	t1,a5,24
    prev->next = next->prev = elm;
ffffffffc02009a4:	0068b023          	sd	t1,0(a7)
ffffffffc02009a8:	00673423          	sd	t1,8(a4)
    elm->prev = prev;
ffffffffc02009ac:	ef98                	sd	a4,24(a5)
    elm->next = next;
ffffffffc02009ae:	0317b023          	sd	a7,32(a5)
                    buddy_zone.free_area[order-1].nr_free+=(1<<(order-1));
ffffffffc02009b2:	9eb1                	addw	a3,a3,a2
ffffffffc02009b4:	cb14                	sw	a3,16(a4)
                while ((1 << order) > 2 * n) {
ffffffffc02009b6:	1721                	addi	a4,a4,-24
ffffffffc02009b8:	fab96ae3          	bltu	s2,a1,ffffffffc020096c <buddy_system_pmm_alloc_pages+0x12a>
                p->property=1<<order_copy;
ffffffffc02009bc:	4785                	li	a5,1
ffffffffc02009be:	013799bb          	sllw	s3,a5,s3
ffffffffc02009c2:	ff3b2c23          	sw	s3,-8(s6)
                return p;
ffffffffc02009c6:	b709                	j	ffffffffc02008c8 <buddy_system_pmm_alloc_pages+0x86>
            int n_more=(1<<order)-(1<<order_needed);
ffffffffc02009c8:	4305                	li	t1,1
ffffffffc02009ca:	01331e3b          	sllw	t3,t1,s3
ffffffffc02009ce:	8372                	mv	t1,t3
            while (order > order_needed) {
ffffffffc02009d0:	0489d363          	bge	s3,s0,ffffffffc0200a16 <buddy_system_pmm_alloc_pages+0x1d4>
ffffffffc02009d4:	008707b3          	add	a5,a4,s0
ffffffffc02009d8:	078e                	slli	a5,a5,0x3
ffffffffc02009da:	17a1                	addi	a5,a5,-24
ffffffffc02009dc:	97d6                	add	a5,a5,s5
                buddy->property = 1 << order;
ffffffffc02009de:	4885                	li	a7,1
ffffffffc02009e0:	4809                	li	a6,2
                order--;
ffffffffc02009e2:	347d                	addiw	s0,s0,-1
                buddy->property = 1 << order;
ffffffffc02009e4:	008895bb          	sllw	a1,a7,s0
ffffffffc02009e8:	c88c                	sw	a1,16(s1)
ffffffffc02009ea:	00848713          	addi	a4,s1,8
ffffffffc02009ee:	4107302f          	amoor.d	zero,a6,(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc02009f2:	6788                	ld	a0,8(a5)
                buddy_zone.free_area[order].nr_free+=1<<order;
ffffffffc02009f4:	4b94                	lw	a3,16(a5)
                list_add(&buddy_zone.free_area[order].free_list, &buddy->page_link);
ffffffffc02009f6:	01848713          	addi	a4,s1,24
    prev->next = next->prev = elm;
ffffffffc02009fa:	e118                	sd	a4,0(a0)
ffffffffc02009fc:	e798                	sd	a4,8(a5)
                buddy += (1 << order);
ffffffffc02009fe:	00259713          	slli	a4,a1,0x2
    elm->prev = prev;
ffffffffc0200a02:	ec9c                	sd	a5,24(s1)
    elm->next = next;
ffffffffc0200a04:	f088                	sd	a0,32(s1)
ffffffffc0200a06:	972e                	add	a4,a4,a1
                buddy_zone.free_area[order].nr_free+=1<<order;
ffffffffc0200a08:	9ead                	addw	a3,a3,a1
                buddy += (1 << order);
ffffffffc0200a0a:	070e                	slli	a4,a4,0x3
                buddy_zone.free_area[order].nr_free+=1<<order;
ffffffffc0200a0c:	cb94                	sw	a3,16(a5)
                buddy += (1 << order);
ffffffffc0200a0e:	94ba                	add	s1,s1,a4
            while (order > order_needed) {
ffffffffc0200a10:	17a1                	addi	a5,a5,-24
ffffffffc0200a12:	fc8998e3          	bne	s3,s0,ffffffffc02009e2 <buddy_system_pmm_alloc_pages+0x1a0>
            p=buddy+(1<<order_needed);
ffffffffc0200a16:	002e1793          	slli	a5,t3,0x2
ffffffffc0200a1a:	97f2                	add	a5,a5,t3
ffffffffc0200a1c:	078e                	slli	a5,a5,0x3
ffffffffc0200a1e:	94be                	add	s1,s1,a5
            p->property=1<<order_copy;
ffffffffc0200a20:	0064a823          	sw	t1,16(s1)
            return p;
ffffffffc0200a24:	b555                	j	ffffffffc02008c8 <buddy_system_pmm_alloc_pages+0x86>
    assert(n > 0);
ffffffffc0200a26:	00002697          	auipc	a3,0x2
ffffffffc0200a2a:	8ca68693          	addi	a3,a3,-1846 # ffffffffc02022f0 <commands+0x4f8>
ffffffffc0200a2e:	00002617          	auipc	a2,0x2
ffffffffc0200a32:	8ca60613          	addi	a2,a2,-1846 # ffffffffc02022f8 <commands+0x500>
ffffffffc0200a36:	0f200593          	li	a1,242
ffffffffc0200a3a:	00002517          	auipc	a0,0x2
ffffffffc0200a3e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0202310 <commands+0x518>
ffffffffc0200a42:	96bff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a46 <buddy_system_pmm_init_memmap>:
static void buddy_system_pmm_init_memmap(struct Page *base, size_t n) {
ffffffffc0200a46:	7179                	addi	sp,sp,-48
ffffffffc0200a48:	f406                	sd	ra,40(sp)
ffffffffc0200a4a:	f022                	sd	s0,32(sp)
ffffffffc0200a4c:	ec26                	sd	s1,24(sp)
ffffffffc0200a4e:	e84a                	sd	s2,16(sp)
ffffffffc0200a50:	e44e                	sd	s3,8(sp)
ffffffffc0200a52:	e052                	sd	s4,0(sp)
    assert(n > 0);
ffffffffc0200a54:	22058f63          	beqz	a1,ffffffffc0200c92 <buddy_system_pmm_init_memmap+0x24c>
    for (; p != base + n; p++) {
ffffffffc0200a58:	00259693          	slli	a3,a1,0x2
ffffffffc0200a5c:	96ae                	add	a3,a3,a1
ffffffffc0200a5e:	068e                	slli	a3,a3,0x3
ffffffffc0200a60:	96aa                	add	a3,a3,a0
ffffffffc0200a62:	87aa                	mv	a5,a0
ffffffffc0200a64:	02d50063          	beq	a0,a3,ffffffffc0200a84 <buddy_system_pmm_init_memmap+0x3e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a68:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200a6a:	8b05                	andi	a4,a4,1
ffffffffc0200a6c:	20070363          	beqz	a4,ffffffffc0200c72 <buddy_system_pmm_init_memmap+0x22c>
        p->flags = p->property = 0;
ffffffffc0200a70:	0007a823          	sw	zero,16(a5)
ffffffffc0200a74:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a78:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc0200a7c:	02878793          	addi	a5,a5,40
ffffffffc0200a80:	fed794e3          	bne	a5,a3,ffffffffc0200a68 <buddy_system_pmm_init_memmap+0x22>
    buddy_zone.n_sum += n;
ffffffffc0200a84:	00005817          	auipc	a6,0x5
ffffffffc0200a88:	58c80813          	addi	a6,a6,1420 # ffffffffc0206010 <buddy_zone>
ffffffffc0200a8c:	10883783          	ld	a5,264(a6)
    int n_now = n;
ffffffffc0200a90:	0005889b          	sext.w	a7,a1
    buddy_zone.n_sum += n;
ffffffffc0200a94:	95be                	add	a1,a1,a5
ffffffffc0200a96:	10b83423          	sd	a1,264(a6)
    while (n_now != 0) {
ffffffffc0200a9a:	0a088c63          	beqz	a7,ffffffffc0200b52 <buddy_system_pmm_init_memmap+0x10c>
        return res >> 1;
ffffffffc0200a9e:	52fd                	li	t0,-1
    if(n==1)//这个是为了照顾最后n=1的情况
ffffffffc0200aa0:	4f85                	li	t6,1
ffffffffc0200aa2:	02800493          	li	s1,40
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200aa6:	4e09                	li	t3,2
        if (order == MAX_ORDER - 1) {
ffffffffc0200aa8:	43a5                	li	t2,9
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200aaa:	3ff00413          	li	s0,1023
ffffffffc0200aae:	00005617          	auipc	a2,0x5
ffffffffc0200ab2:	65260613          	addi	a2,a2,1618 # ffffffffc0206100 <buddy_zone+0xf0>
                now_page->property = max_block_size; // 每个块的页数
ffffffffc0200ab6:	40000f13          	li	t5,1024
                now_page += max_block_size; // 更新当前页指针
ffffffffc0200aba:	6ea9                	lui	t4,0xa
        return res >> 1;
ffffffffc0200abc:	0012d293          	srli	t0,t0,0x1
        int n_temp = getdown2(n_now);
ffffffffc0200ac0:	86c6                	mv	a3,a7
    if(n==1)//这个是为了照顾最后n=1的情况
ffffffffc0200ac2:	19f88263          	beq	a7,t6,ffffffffc0200c46 <buddy_system_pmm_init_memmap+0x200>
    if (n & (n - 1)) return 0;
ffffffffc0200ac6:	fff88793          	addi	a5,a7,-1
ffffffffc0200aca:	0117f7b3          	and	a5,a5,a7
ffffffffc0200ace:	18078463          	beqz	a5,ffffffffc0200c56 <buddy_system_pmm_init_memmap+0x210>
    size_t res = 1;
ffffffffc0200ad2:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200ad4:	8285                	srli	a3,a3,0x1
            res = res << 1;
ffffffffc0200ad6:	873e                	mv	a4,a5
ffffffffc0200ad8:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200ada:	feed                	bnez	a3,ffffffffc0200ad4 <buddy_system_pmm_init_memmap+0x8e>
        return res >> 1;
ffffffffc0200adc:	005776b3          	and	a3,a4,t0
        int n_temp = getdown2(n_now);
ffffffffc0200ae0:	0006891b          	sext.w	s2,a3
    while (n >> 1)
ffffffffc0200ae4:	00195793          	srli	a5,s2,0x1
        int order = getorder(n_temp);
ffffffffc0200ae8:	8a4a                	mv	s4,s2
    while (n >> 1)
ffffffffc0200aea:	1c078463          	beqz	a5,ffffffffc0200cb2 <buddy_system_pmm_init_memmap+0x26c>
ffffffffc0200aee:	4701                	li	a4,0
ffffffffc0200af0:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200af2:	2705                	addiw	a4,a4,1
    while (n >> 1)
ffffffffc0200af4:	fff5                	bnez	a5,ffffffffc0200af0 <buddy_system_pmm_init_memmap+0xaa>
        int order = getorder(n_temp);
ffffffffc0200af6:	0007099b          	sext.w	s3,a4
        if (order == MAX_ORDER - 1) {
ffffffffc0200afa:	08e3c663          	blt	t2,a4,ffffffffc0200b86 <buddy_system_pmm_init_memmap+0x140>
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200afe:	00199793          	slli	a5,s3,0x1
            now_page += n_temp; // 更新当前页指针
ffffffffc0200b02:	002a1313          	slli	t1,s4,0x2
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200b06:	013785b3          	add	a1,a5,s3
            now_page += n_temp; // 更新当前页指针
ffffffffc0200b0a:	9352                	add	t1,t1,s4
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200b0c:	058e                	slli	a1,a1,0x3
            now_page += n_temp; // 更新当前页指针
ffffffffc0200b0e:	030e                	slli	t1,t1,0x3
            now_page->property = n_temp;
ffffffffc0200b10:	00068a1b          	sext.w	s4,a3
            list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200b14:	95c2                	add	a1,a1,a6
            now_page += n_temp; // 更新当前页指针
ffffffffc0200b16:	951a                	add	a0,a0,t1
            n_now -= n_temp;
ffffffffc0200b18:	412888bb          	subw	a7,a7,s2
            now_page->property = n_temp;
ffffffffc0200b1c:	01452823          	sw	s4,16(a0)
ffffffffc0200b20:	00850713          	addi	a4,a0,8
ffffffffc0200b24:	41c7302f          	amoor.d	zero,t3,(a4)
            buddy_zone.free_area[order].nr_free += n_temp;
ffffffffc0200b28:	01378733          	add	a4,a5,s3
ffffffffc0200b2c:	070e                	slli	a4,a4,0x3
ffffffffc0200b2e:	9742                	add	a4,a4,a6
ffffffffc0200b30:	4b14                	lw	a3,16(a4)
    return list->next == list;
ffffffffc0200b32:	671c                	ld	a5,8(a4)
                list_add(free_list_order, &now_page->page_link);
ffffffffc0200b34:	01850313          	addi	t1,a0,24
            buddy_zone.free_area[order].nr_free += n_temp;
ffffffffc0200b38:	014686bb          	addw	a3,a3,s4
ffffffffc0200b3c:	cb14                	sw	a3,16(a4)
            if (list_empty(free_list_order)) {
ffffffffc0200b3e:	02b79663          	bne	a5,a1,ffffffffc0200b6a <buddy_system_pmm_init_memmap+0x124>
    prev->next = next->prev = elm;
ffffffffc0200b42:	0065b023          	sd	t1,0(a1)
ffffffffc0200b46:	00673423          	sd	t1,8(a4)
    elm->next = next;
ffffffffc0200b4a:	f10c                	sd	a1,32(a0)
    elm->prev = prev;
ffffffffc0200b4c:	ed0c                	sd	a1,24(a0)
    while (n_now != 0) {
ffffffffc0200b4e:	f60899e3          	bnez	a7,ffffffffc0200ac0 <buddy_system_pmm_init_memmap+0x7a>
}
ffffffffc0200b52:	70a2                	ld	ra,40(sp)
ffffffffc0200b54:	7402                	ld	s0,32(sp)
ffffffffc0200b56:	64e2                	ld	s1,24(sp)
ffffffffc0200b58:	6942                	ld	s2,16(sp)
ffffffffc0200b5a:	69a2                	ld	s3,8(sp)
ffffffffc0200b5c:	6a02                	ld	s4,0(sp)
ffffffffc0200b5e:	6145                	addi	sp,sp,48
ffffffffc0200b60:	8082                	ret
    return listelm->next;
ffffffffc0200b62:	6798                	ld	a4,8(a5)
                    } else if (list_next(le) == free_list_order) {
ffffffffc0200b64:	0eb70e63          	beq	a4,a1,ffffffffc0200c60 <buddy_system_pmm_init_memmap+0x21a>
ffffffffc0200b68:	87ba                	mv	a5,a4
                    struct Page *page = le2page(le, page_link);
ffffffffc0200b6a:	fe878713          	addi	a4,a5,-24
                    if (now_page < page) {
ffffffffc0200b6e:	fee57ae3          	bgeu	a0,a4,ffffffffc0200b62 <buddy_system_pmm_init_memmap+0x11c>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200b72:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200b74:	0067b023          	sd	t1,0(a5)
ffffffffc0200b78:	00673423          	sd	t1,8(a4)
    elm->next = next;
ffffffffc0200b7c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200b7e:	ed18                	sd	a4,24(a0)
    while (n_now != 0) {
ffffffffc0200b80:	f40890e3          	bnez	a7,ffffffffc0200ac0 <buddy_system_pmm_init_memmap+0x7a>
ffffffffc0200b84:	b7f9                	j	ffffffffc0200b52 <buddy_system_pmm_init_memmap+0x10c>
            int num_blocks = n_now / max_block_size; // 计算需要的最大块数
ffffffffc0200b86:	41f8d99b          	sraiw	s3,a7,0x1f
ffffffffc0200b8a:	0169d91b          	srliw	s2,s3,0x16
ffffffffc0200b8e:	0119093b          	addw	s2,s2,a7
ffffffffc0200b92:	40a95a1b          	sraiw	s4,s2,0xa
ffffffffc0200b96:	8952                	mv	s2,s4
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200b98:	09145563          	bge	s0,a7,ffffffffc0200c22 <buddy_system_pmm_init_memmap+0x1dc>
ffffffffc0200b9c:	86aa                	mv	a3,a0
ffffffffc0200b9e:	4581                	li	a1,0
ffffffffc0200ba0:	a819                	j	ffffffffc0200bb6 <buddy_system_pmm_init_memmap+0x170>
    prev->next = next->prev = elm;
ffffffffc0200ba2:	0e683823          	sd	t1,240(a6)
ffffffffc0200ba6:	0e683c23          	sd	t1,248(a6)
    elm->next = next;
ffffffffc0200baa:	f290                	sd	a2,32(a3)
    elm->prev = prev;
ffffffffc0200bac:	ee90                	sd	a2,24(a3)
ffffffffc0200bae:	2585                	addiw	a1,a1,1
                now_page += max_block_size; // 更新当前页指针
ffffffffc0200bb0:	96f6                	add	a3,a3,t4
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200bb2:	0545db63          	bge	a1,s4,ffffffffc0200c08 <buddy_system_pmm_init_memmap+0x1c2>
                now_page->property = max_block_size; // 每个块的页数
ffffffffc0200bb6:	01e6a823          	sw	t5,16(a3)
ffffffffc0200bba:	00868793          	addi	a5,a3,8
ffffffffc0200bbe:	41c7b02f          	amoor.d	zero,t3,(a5)
                buddy_zone.free_area[MAX_ORDER - 1].nr_free += max_block_size; // 更新 free_area 中的块数
ffffffffc0200bc2:	10082703          	lw	a4,256(a6)
    return list->next == list;
ffffffffc0200bc6:	0f883783          	ld	a5,248(a6)
ffffffffc0200bca:	01868313          	addi	t1,a3,24
ffffffffc0200bce:	4007071b          	addiw	a4,a4,1024
ffffffffc0200bd2:	10e82023          	sw	a4,256(a6)
                if (list_empty(free_list_order)) {
ffffffffc0200bd6:	fcc786e3          	beq	a5,a2,ffffffffc0200ba2 <buddy_system_pmm_init_memmap+0x15c>
                        struct Page *page = le2page(le, page_link);
ffffffffc0200bda:	fe878713          	addi	a4,a5,-24
                        if (now_page < page) {
ffffffffc0200bde:	00e6ea63          	bltu	a3,a4,ffffffffc0200bf2 <buddy_system_pmm_init_memmap+0x1ac>
    return listelm->next;
ffffffffc0200be2:	6798                	ld	a4,8(a5)
                        } else if (list_next(le) == free_list_order) {
ffffffffc0200be4:	04c70a63          	beq	a4,a2,ffffffffc0200c38 <buddy_system_pmm_init_memmap+0x1f2>
ffffffffc0200be8:	87ba                	mv	a5,a4
                        struct Page *page = le2page(le, page_link);
ffffffffc0200bea:	fe878713          	addi	a4,a5,-24
                        if (now_page < page) {
ffffffffc0200bee:	fee6fae3          	bgeu	a3,a4,ffffffffc0200be2 <buddy_system_pmm_init_memmap+0x19c>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200bf2:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200bf4:	0067b023          	sd	t1,0(a5)
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200bf8:	2585                	addiw	a1,a1,1
ffffffffc0200bfa:	00673423          	sd	t1,8(a4)
    elm->next = next;
ffffffffc0200bfe:	f29c                	sd	a5,32(a3)
    elm->prev = prev;
ffffffffc0200c00:	ee98                	sd	a4,24(a3)
                now_page += max_block_size; // 更新当前页指针
ffffffffc0200c02:	96f6                	add	a3,a3,t4
            for (int i = 0; i < num_blocks; i++) {
ffffffffc0200c04:	fb45c9e3          	blt	a1,s4,ffffffffc0200bb6 <buddy_system_pmm_init_memmap+0x170>
                now_page += max_block_size; // 更新当前页指针
ffffffffc0200c08:	67a9                	lui	a5,0xa
ffffffffc0200c0a:	01145b63          	bge	s0,a7,ffffffffc0200c20 <buddy_system_pmm_init_memmap+0x1da>
ffffffffc0200c0e:	fff9079b          	addiw	a5,s2,-1
ffffffffc0200c12:	1782                	slli	a5,a5,0x20
ffffffffc0200c14:	9381                	srli	a5,a5,0x20
ffffffffc0200c16:	0785                	addi	a5,a5,1
ffffffffc0200c18:	00279713          	slli	a4,a5,0x2
ffffffffc0200c1c:	97ba                	add	a5,a5,a4
ffffffffc0200c1e:	07b6                	slli	a5,a5,0xd
ffffffffc0200c20:	953e                	add	a0,a0,a5
            n_now -= num_blocks * max_block_size; // 更新剩余页数
ffffffffc0200c22:	0169d99b          	srliw	s3,s3,0x16
ffffffffc0200c26:	011988bb          	addw	a7,s3,a7
ffffffffc0200c2a:	3ff8f893          	andi	a7,a7,1023
ffffffffc0200c2e:	413888bb          	subw	a7,a7,s3
    while (n_now != 0) {
ffffffffc0200c32:	e80897e3          	bnez	a7,ffffffffc0200ac0 <buddy_system_pmm_init_memmap+0x7a>
ffffffffc0200c36:	bf31                	j	ffffffffc0200b52 <buddy_system_pmm_init_memmap+0x10c>
    prev->next = next->prev = elm;
ffffffffc0200c38:	0e683823          	sd	t1,240(a6)
ffffffffc0200c3c:	0067b423          	sd	t1,8(a5) # a008 <kern_entry-0xffffffffc01f5ff8>
    elm->next = next;
ffffffffc0200c40:	f290                	sd	a2,32(a3)
    elm->prev = prev;
ffffffffc0200c42:	ee9c                	sd	a5,24(a3)
}
ffffffffc0200c44:	b7ad                	j	ffffffffc0200bae <buddy_system_pmm_init_memmap+0x168>
ffffffffc0200c46:	4a05                	li	s4,1
ffffffffc0200c48:	02800313          	li	t1,40
        int n_temp = getdown2(n_now);
ffffffffc0200c4c:	4905                	li	s2,1
        if (order == MAX_ORDER - 1) {
ffffffffc0200c4e:	85c2                	mv	a1,a6
        int order = getorder(n_temp);
ffffffffc0200c50:	4981                	li	s3,0
ffffffffc0200c52:	4781                	li	a5,0
ffffffffc0200c54:	b5c9                	j	ffffffffc0200b16 <buddy_system_pmm_init_memmap+0xd0>
    while (n >> 1)
ffffffffc0200c56:	0018d793          	srli	a5,a7,0x1
ffffffffc0200c5a:	8946                	mv	s2,a7
ffffffffc0200c5c:	8a46                	mv	s4,a7
ffffffffc0200c5e:	bd41                	j	ffffffffc0200aee <buddy_system_pmm_init_memmap+0xa8>
    prev->next = next->prev = elm;
ffffffffc0200c60:	0065b023          	sd	t1,0(a1)
ffffffffc0200c64:	0067b423          	sd	t1,8(a5)
    elm->next = next;
ffffffffc0200c68:	f10c                	sd	a1,32(a0)
    elm->prev = prev;
ffffffffc0200c6a:	ed1c                	sd	a5,24(a0)
    while (n_now != 0) {
ffffffffc0200c6c:	e4089ae3          	bnez	a7,ffffffffc0200ac0 <buddy_system_pmm_init_memmap+0x7a>
ffffffffc0200c70:	b5cd                	j	ffffffffc0200b52 <buddy_system_pmm_init_memmap+0x10c>
        assert(PageReserved(p));
ffffffffc0200c72:	00001697          	auipc	a3,0x1
ffffffffc0200c76:	6de68693          	addi	a3,a3,1758 # ffffffffc0202350 <commands+0x558>
ffffffffc0200c7a:	00001617          	auipc	a2,0x1
ffffffffc0200c7e:	67e60613          	addi	a2,a2,1662 # ffffffffc02022f8 <commands+0x500>
ffffffffc0200c82:	09600593          	li	a1,150
ffffffffc0200c86:	00001517          	auipc	a0,0x1
ffffffffc0200c8a:	68a50513          	addi	a0,a0,1674 # ffffffffc0202310 <commands+0x518>
ffffffffc0200c8e:	f1eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200c92:	00001697          	auipc	a3,0x1
ffffffffc0200c96:	65e68693          	addi	a3,a3,1630 # ffffffffc02022f0 <commands+0x4f8>
ffffffffc0200c9a:	00001617          	auipc	a2,0x1
ffffffffc0200c9e:	65e60613          	addi	a2,a2,1630 # ffffffffc02022f8 <commands+0x500>
ffffffffc0200ca2:	09200593          	li	a1,146
ffffffffc0200ca6:	00001517          	auipc	a0,0x1
ffffffffc0200caa:	66a50513          	addi	a0,a0,1642 # ffffffffc0202310 <commands+0x518>
ffffffffc0200cae:	efeff0ef          	jal	ra,ffffffffc02003ac <__panic>
            now_page += n_temp; // 更新当前页指针
ffffffffc0200cb2:	02990333          	mul	t1,s2,s1
ffffffffc0200cb6:	bf61                	j	ffffffffc0200c4e <buddy_system_pmm_init_memmap+0x208>

ffffffffc0200cb8 <buddy_system_pmm_free_pages>:
    assert(n > 0);
ffffffffc0200cb8:	18058463          	beqz	a1,ffffffffc0200e40 <buddy_system_pmm_free_pages+0x188>
    if(n==1)
ffffffffc0200cbc:	4785                	li	a5,1
ffffffffc0200cbe:	16f58163          	beq	a1,a5,ffffffffc0200e20 <buddy_system_pmm_free_pages+0x168>
    if (n & (n - 1)) return 0;
ffffffffc0200cc2:	fff58793          	addi	a5,a1,-1
ffffffffc0200cc6:	8fed                	and	a5,a5,a1
ffffffffc0200cc8:	cfdd                	beqz	a5,ffffffffc0200d86 <buddy_system_pmm_free_pages+0xce>
    size_t res = 1;
ffffffffc0200cca:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200ccc:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200cce:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200cd0:	fdf5                	bnez	a1,ffffffffc0200ccc <buddy_system_pmm_free_pages+0x14>
    while (n >> 1)
ffffffffc0200cd2:	873e                	mv	a4,a5
ffffffffc0200cd4:	8385                	srli	a5,a5,0x1
ffffffffc0200cd6:	16070263          	beqz	a4,ffffffffc0200e3a <buddy_system_pmm_free_pages+0x182>
    size_t res = 1;
ffffffffc0200cda:	4701                	li	a4,0
    while (n >> 1)
ffffffffc0200cdc:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200cde:	2705                	addiw	a4,a4,1
    while (n >> 1)
ffffffffc0200ce0:	fff5                	bnez	a5,ffffffffc0200cdc <buddy_system_pmm_free_pages+0x24>
    list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200ce2:	00171593          	slli	a1,a4,0x1
ffffffffc0200ce6:	95ba                	add	a1,a1,a4
    p->property = 1 << order;
ffffffffc0200ce8:	4785                	li	a5,1
ffffffffc0200cea:	00e797bb          	sllw	a5,a5,a4
    list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200cee:	00005e97          	auipc	t4,0x5
ffffffffc0200cf2:	322e8e93          	addi	t4,t4,802 # ffffffffc0206010 <buddy_zone>
ffffffffc0200cf6:	058e                	slli	a1,a1,0x3
    int order = getorder(getup2(n));
ffffffffc0200cf8:	0007081b          	sext.w	a6,a4
    p->property = 1 << order;
ffffffffc0200cfc:	c91c                	sw	a5,16(a0)
    list_entry_t *free_list_order = &buddy_zone.free_area[order].free_list;
ffffffffc0200cfe:	95f6                	add	a1,a1,t4
ffffffffc0200d00:	4789                	li	a5,2
ffffffffc0200d02:	00850713          	addi	a4,a0,8
ffffffffc0200d06:	40f7302f          	amoor.d	zero,a5,(a4)
    while (order < MAX_ORDER - 1) { // 修正为最大 order - 1
ffffffffc0200d0a:	47a5                	li	a5,9
ffffffffc0200d0c:	0b07ce63          	blt	a5,a6,ffffffffc0200dc8 <buddy_system_pmm_free_pages+0x110>
ffffffffc0200d10:	0018079b          	addiw	a5,a6,1
ffffffffc0200d14:	00179313          	slli	t1,a5,0x1
ffffffffc0200d18:	933e                	add	t1,t1,a5
ffffffffc0200d1a:	030e                	slli	t1,t1,0x3
ffffffffc0200d1c:	9376                	add	t1,t1,t4
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200d1e:	4f85                	li	t6,1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200d20:	53f5                	li	t2,-3
    while (order < MAX_ORDER - 1) { // 修正为最大 order - 1
ffffffffc0200d22:	42a9                	li	t0,10
    return list->next == list;
ffffffffc0200d24:	659c                	ld	a5,8(a1)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200d26:	010f9e3b          	sllw	t3,t6,a6
ffffffffc0200d2a:	8f72                	mv	t5,t3
        if (list_empty(free_list_order)) {
ffffffffc0200d2c:	02b78763          	beq	a5,a1,ffffffffc0200d5a <buddy_system_pmm_free_pages+0xa2>
            if ((uintptr_t)current_page == (uintptr_t)p + page_size * block_size) {
ffffffffc0200d30:	002e1613          	slli	a2,t3,0x2
ffffffffc0200d34:	9672                	add	a2,a2,t3
ffffffffc0200d36:	060e                	slli	a2,a2,0x3
ffffffffc0200d38:	00c508b3          	add	a7,a0,a2
ffffffffc0200d3c:	a011                	j	ffffffffc0200d40 <buddy_system_pmm_free_pages+0x88>
ffffffffc0200d3e:	87ba                	mv	a5,a4
            struct Page *current_page = le2page(le, page_link);
ffffffffc0200d40:	fe878713          	addi	a4,a5,-24
            if ((uintptr_t)current_page == (uintptr_t)p + page_size * block_size) {
ffffffffc0200d44:	04e88463          	beq	a7,a4,ffffffffc0200d8c <buddy_system_pmm_free_pages+0xd4>
            } else if ((uintptr_t)p == (uintptr_t)current_page + block_size * page_size) {
ffffffffc0200d48:	00c706b3          	add	a3,a4,a2
ffffffffc0200d4c:	06d50f63          	beq	a0,a3,ffffffffc0200dca <buddy_system_pmm_free_pages+0x112>
    return listelm->next;
ffffffffc0200d50:	6798                	ld	a4,8(a5)
            if(le==list_next(le))
ffffffffc0200d52:	08f70c63          	beq	a4,a5,ffffffffc0200dea <buddy_system_pmm_free_pages+0x132>
        for (le = list_next(free_list_order); le != free_list_order; le = list_next(le)) {
ffffffffc0200d56:	feb714e3          	bne	a4,a1,ffffffffc0200d3e <buddy_system_pmm_free_pages+0x86>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d5a:	00181793          	slli	a5,a6,0x1
ffffffffc0200d5e:	97c2                	add	a5,a5,a6
ffffffffc0200d60:	078e                	slli	a5,a5,0x3
ffffffffc0200d62:	97f6                	add	a5,a5,t4
ffffffffc0200d64:	6790                	ld	a2,8(a5)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200d66:	4b94                	lw	a3,16(a5)
            buddy_zone.n_sum += (1 << order);
ffffffffc0200d68:	108eb703          	ld	a4,264(t4)
            list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
ffffffffc0200d6c:	01850593          	addi	a1,a0,24
    prev->next = next->prev = elm;
ffffffffc0200d70:	e20c                	sd	a1,0(a2)
ffffffffc0200d72:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200d74:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc0200d76:	ed1c                	sd	a5,24(a0)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200d78:	01c686bb          	addw	a3,a3,t3
            buddy_zone.n_sum += (1 << order);
ffffffffc0200d7c:	9e3a                	add	t3,t3,a4
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200d7e:	cb94                	sw	a3,16(a5)
            buddy_zone.n_sum += (1 << order);
ffffffffc0200d80:	11ceb423          	sd	t3,264(t4)
            return;
ffffffffc0200d84:	8082                	ret
    while (n >> 1)
ffffffffc0200d86:	0015d793          	srli	a5,a1,0x1
ffffffffc0200d8a:	bf81                	j	ffffffffc0200cda <buddy_system_pmm_free_pages+0x22>
                p->property += current_page->property;
ffffffffc0200d8c:	4918                	lw	a4,16(a0)
ffffffffc0200d8e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0200d92:	9f35                	addw	a4,a4,a3
ffffffffc0200d94:	c918                	sw	a4,16(a0)
ffffffffc0200d96:	ff078713          	addi	a4,a5,-16
ffffffffc0200d9a:	6077302f          	amoand.d	zero,t2,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d9e:	6398                	ld	a4,0(a5)
ffffffffc0200da0:	679c                	ld	a5,8(a5)
    prev->next = next;
ffffffffc0200da2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200da4:	e398                	sd	a4,0(a5)
        buddy_zone.free_area[order].nr_free -= (1 << order);
ffffffffc0200da6:	ff832703          	lw	a4,-8(t1)
        buddy_zone.n_sum -= (1 << order);
ffffffffc0200daa:	108eb783          	ld	a5,264(t4)
        order++;
ffffffffc0200dae:	2805                	addiw	a6,a6,1
        buddy_zone.free_area[order].nr_free -= (1 << order);
ffffffffc0200db0:	41e70f3b          	subw	t5,a4,t5
ffffffffc0200db4:	ffe32c23          	sw	t5,-8(t1)
        buddy_zone.n_sum -= (1 << order);
ffffffffc0200db8:	41c78e33          	sub	t3,a5,t3
ffffffffc0200dbc:	11ceb423          	sd	t3,264(t4)
    while (order < MAX_ORDER - 1) { // 修正为最大 order - 1
ffffffffc0200dc0:	859a                	mv	a1,t1
ffffffffc0200dc2:	0361                	addi	t1,t1,24
ffffffffc0200dc4:	f65810e3          	bne	a6,t0,ffffffffc0200d24 <buddy_system_pmm_free_pages+0x6c>
ffffffffc0200dc8:	8082                	ret
                current_page->property += p->property;
ffffffffc0200dca:	ff87a683          	lw	a3,-8(a5)
ffffffffc0200dce:	4910                	lw	a2,16(a0)
ffffffffc0200dd0:	9eb1                	addw	a3,a3,a2
ffffffffc0200dd2:	fed7ac23          	sw	a3,-8(a5)
ffffffffc0200dd6:	00850793          	addi	a5,a0,8
ffffffffc0200dda:	6077b02f          	amoand.d	zero,t2,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200dde:	6d14                	ld	a3,24(a0)
ffffffffc0200de0:	711c                	ld	a5,32(a0)
            struct Page *current_page = le2page(le, page_link);
ffffffffc0200de2:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0200de4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200de6:	e394                	sd	a3,0(a5)
        if (!merged) {
ffffffffc0200de8:	bf7d                	j	ffffffffc0200da6 <buddy_system_pmm_free_pages+0xee>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200dea:	00181793          	slli	a5,a6,0x1
ffffffffc0200dee:	97c2                	add	a5,a5,a6
ffffffffc0200df0:	078e                	slli	a5,a5,0x3
ffffffffc0200df2:	97f6                	add	a5,a5,t4
ffffffffc0200df4:	6790                	ld	a2,8(a5)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200df6:	4b94                	lw	a3,16(a5)
            list_add(&buddy_zone.free_area[order].free_list, &p->page_link);
ffffffffc0200df8:	01850593          	addi	a1,a0,24
            buddy_zone.n_sum += (1 << order);
ffffffffc0200dfc:	108eb703          	ld	a4,264(t4)
    prev->next = next->prev = elm;
ffffffffc0200e00:	e20c                	sd	a1,0(a2)
ffffffffc0200e02:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0200e04:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc0200e06:	ed1c                	sd	a5,24(a0)
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200e08:	01c686bb          	addw	a3,a3,t3
            cprintf("return\n");
ffffffffc0200e0c:	00001517          	auipc	a0,0x1
ffffffffc0200e10:	55450513          	addi	a0,a0,1364 # ffffffffc0202360 <commands+0x568>
            buddy_zone.n_sum += (1 << order);
ffffffffc0200e14:	9e3a                	add	t3,t3,a4
            buddy_zone.free_area[order].nr_free += (1 << order);
ffffffffc0200e16:	cb94                	sw	a3,16(a5)
            buddy_zone.n_sum += (1 << order);
ffffffffc0200e18:	11ceb423          	sd	t3,264(t4)
            cprintf("return\n");
ffffffffc0200e1c:	a96ff06f          	j	ffffffffc02000b2 <cprintf>
    p->property = 1 << order;
ffffffffc0200e20:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e22:	4789                	li	a5,2
ffffffffc0200e24:	00850713          	addi	a4,a0,8
ffffffffc0200e28:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0200e2c:	00005e97          	auipc	t4,0x5
ffffffffc0200e30:	1e4e8e93          	addi	t4,t4,484 # ffffffffc0206010 <buddy_zone>
ffffffffc0200e34:	85f6                	mv	a1,t4
ffffffffc0200e36:	4801                	li	a6,0
ffffffffc0200e38:	bde1                	j	ffffffffc0200d10 <buddy_system_pmm_free_pages+0x58>
ffffffffc0200e3a:	4785                	li	a5,1
ffffffffc0200e3c:	c91c                	sw	a5,16(a0)
ffffffffc0200e3e:	b7d5                	j	ffffffffc0200e22 <buddy_system_pmm_free_pages+0x16a>
static void buddy_system_pmm_free_pages(struct Page *base, size_t n) {
ffffffffc0200e40:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200e42:	00001697          	auipc	a3,0x1
ffffffffc0200e46:	4ae68693          	addi	a3,a3,1198 # ffffffffc02022f0 <commands+0x4f8>
ffffffffc0200e4a:	00001617          	auipc	a2,0x1
ffffffffc0200e4e:	4ae60613          	addi	a2,a2,1198 # ffffffffc02022f8 <commands+0x500>
ffffffffc0200e52:	14d00593          	li	a1,333
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0202310 <commands+0x518>
static void buddy_system_pmm_free_pages(struct Page *base, size_t n) {
ffffffffc0200e5e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e60:	d4cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e64 <buddy_system_pmm_check>:

static void buddy_system_pmm_check(void) {
ffffffffc0200e64:	c8010113          	addi	sp,sp,-896

#define ALLOC_PAGE_NUM 100

    cprintf("[buddy_check] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	50050513          	addi	a0,a0,1280 # ffffffffc0202368 <commands+0x570>
static void buddy_system_pmm_check(void) {
ffffffffc0200e70:	36113c23          	sd	ra,888(sp)
ffffffffc0200e74:	36813823          	sd	s0,880(sp)
ffffffffc0200e78:	36913423          	sd	s1,872(sp)
ffffffffc0200e7c:	37213023          	sd	s2,864(sp)
ffffffffc0200e80:	35313c23          	sd	s3,856(sp)
ffffffffc0200e84:	35613023          	sd	s6,832(sp)
ffffffffc0200e88:	33713c23          	sd	s7,824(sp)
ffffffffc0200e8c:	35413823          	sd	s4,848(sp)
ffffffffc0200e90:	35513423          	sd	s5,840(sp)
ffffffffc0200e94:	33813823          	sd	s8,816(sp)
ffffffffc0200e98:	33913423          	sd	s9,808(sp)
ffffffffc0200e9c:	33a13023          	sd	s10,800(sp)
    cprintf("[buddy_check] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
ffffffffc0200ea0:	a12ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    size_t initial_nr_free_pages = nr_free_pages();
ffffffffc0200ea4:	5d8000ef          	jal	ra,ffffffffc020147c <nr_free_pages>
    cprintf("initial_nr_free_pages %d\n", initial_nr_free_pages);  // 打印 order 的值
ffffffffc0200ea8:	85aa                	mv	a1,a0
    size_t initial_nr_free_pages = nr_free_pages();
ffffffffc0200eaa:	8baa                	mv	s7,a0
    cprintf("initial_nr_free_pages %d\n", initial_nr_free_pages);  // 打印 order 的值
ffffffffc0200eac:	00001517          	auipc	a0,0x1
ffffffffc0200eb0:	4fc50513          	addi	a0,a0,1276 # ffffffffc02023a8 <commands+0x5b0>
ffffffffc0200eb4:	9feff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[buddy_check] before alloc: ");
ffffffffc0200eb8:	00001517          	auipc	a0,0x1
ffffffffc0200ebc:	51050513          	addi	a0,a0,1296 # ffffffffc02023c8 <commands+0x5d0>
ffffffffc0200ec0:	9f2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0200ec4:	00001517          	auipc	a0,0x1
ffffffffc0200ec8:	52450513          	addi	a0,a0,1316 # ffffffffc02023e8 <commands+0x5f0>
ffffffffc0200ecc:	00005b17          	auipc	s6,0x5
ffffffffc0200ed0:	244b0b13          	addi	s6,s6,580 # ffffffffc0206110 <buddy_zone+0x100>
ffffffffc0200ed4:	9deff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200ed8:	84da                	mv	s1,s6
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200eda:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0200edc:	00001997          	auipc	s3,0x1
ffffffffc0200ee0:	52498993          	addi	s3,s3,1316 # ffffffffc0202400 <commands+0x608>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200ee4:	597d                	li	s2,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0200ee6:	408c                	lw	a1,0(s1)
ffffffffc0200ee8:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200eea:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0200eec:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200ef0:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0200ef2:	9c0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200ef6:	ff2418e3          	bne	s0,s2,ffffffffc0200ee6 <buddy_system_pmm_check+0x82>
    cprintf("\n");
ffffffffc0200efa:	00001517          	auipc	a0,0x1
ffffffffc0200efe:	d8e50513          	addi	a0,a0,-626 # ffffffffc0201c88 <etext+0xea>
ffffffffc0200f02:	9b0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();


    cprintf("[buddy_check] trying to alloc %d * 1 pages\n", ALLOC_PAGE_NUM);
ffffffffc0200f06:	06400593          	li	a1,100
ffffffffc0200f0a:	00001517          	auipc	a0,0x1
ffffffffc0200f0e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0202408 <commands+0x610>
ffffffffc0200f12:	8a0a                	mv	s4,sp
ffffffffc0200f14:	99eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    struct Page *pages[ALLOC_PAGE_NUM];

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc0200f18:	32010a93          	addi	s5,sp,800
    cprintf("[buddy_check] trying to alloc %d * 1 pages\n", ALLOC_PAGE_NUM);
ffffffffc0200f1c:	8452                	mv	s0,s4
        pages[i] = alloc_pages(1);
        assert(pages[i] != NULL);
        cprintf("[buddy_check] after alloc: ");
ffffffffc0200f1e:	00001497          	auipc	s1,0x1
ffffffffc0200f22:	53248493          	addi	s1,s1,1330 # ffffffffc0202450 <commands+0x658>
        pages[i] = alloc_pages(1);
ffffffffc0200f26:	4505                	li	a0,1
ffffffffc0200f28:	4d6000ef          	jal	ra,ffffffffc02013fe <alloc_pages>
ffffffffc0200f2c:	e008                	sd	a0,0(s0)
        assert(pages[i] != NULL);
ffffffffc0200f2e:	36050663          	beqz	a0,ffffffffc020129a <buddy_system_pmm_check+0x436>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc0200f32:	0421                	addi	s0,s0,8
        cprintf("[buddy_check] after alloc: ");
ffffffffc0200f34:	8526                	mv	a0,s1
ffffffffc0200f36:	97cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc0200f3a:	ff5416e3          	bne	s0,s5,ffffffffc0200f26 <buddy_system_pmm_check+0xc2>
ffffffffc0200f3e:	00005497          	auipc	s1,0x5
ffffffffc0200f42:	1c248493          	addi	s1,s1,450 # ffffffffc0206100 <buddy_zone+0xf0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200f46:	49a9                	li	s3,10
        cprintf("[dbg_buddy] order %2d list: %016x --> \n", order, le);
ffffffffc0200f48:	00001d17          	auipc	s10,0x1
ffffffffc0200f4c:	528d0d13          	addi	s10,s10,1320 # ffffffffc0202470 <commands+0x678>
            cprintf("    %016lx (property: %d) --> \n", (size_t)page, page->property);
ffffffffc0200f50:	00001917          	auipc	s2,0x1
ffffffffc0200f54:	54890913          	addi	s2,s2,1352 # ffffffffc0202498 <commands+0x6a0>
        cprintf("    NULL\n\n"); // 加入换行
ffffffffc0200f58:	00001c97          	auipc	s9,0x1
ffffffffc0200f5c:	560c8c93          	addi	s9,s9,1376 # ffffffffc02024b8 <commands+0x6c0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200f60:	5c7d                	li	s8,-1
        cprintf("[dbg_buddy] order %2d list: %016x --> \n", order, le);
ffffffffc0200f62:	8626                	mv	a2,s1
ffffffffc0200f64:	85ce                	mv	a1,s3
ffffffffc0200f66:	856a                	mv	a0,s10
ffffffffc0200f68:	94aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return listelm->next;
ffffffffc0200f6c:	6480                	ld	s0,8(s1)
        while ((le = list_next(le)) != &buddy_zone.free_area[order].free_list) {
ffffffffc0200f6e:	00848c63          	beq	s1,s0,ffffffffc0200f86 <buddy_system_pmm_check+0x122>
            cprintf("    %016lx (property: %d) --> \n", (size_t)page, page->property);
ffffffffc0200f72:	ff842603          	lw	a2,-8(s0)
ffffffffc0200f76:	fe840593          	addi	a1,s0,-24
ffffffffc0200f7a:	854a                	mv	a0,s2
ffffffffc0200f7c:	936ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200f80:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != &buddy_zone.free_area[order].free_list) {
ffffffffc0200f82:	fe9418e3          	bne	s0,s1,ffffffffc0200f72 <buddy_system_pmm_check+0x10e>
        cprintf("    NULL\n\n"); // 加入换行
ffffffffc0200f86:	8566                	mv	a0,s9
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200f88:	39fd                	addiw	s3,s3,-1
        cprintf("    NULL\n\n"); // 加入换行
ffffffffc0200f8a:	928ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200f8e:	14a1                	addi	s1,s1,-24
ffffffffc0200f90:	fd8999e3          	bne	s3,s8,ffffffffc0200f62 <buddy_system_pmm_check+0xfe>
    cprintf("[dbg_buddy] block count: \n");
ffffffffc0200f94:	00001517          	auipc	a0,0x1
ffffffffc0200f98:	53450513          	addi	a0,a0,1332 # ffffffffc02024c8 <commands+0x6d0>
ffffffffc0200f9c:	916ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200fa0:	00005497          	auipc	s1,0x5
ffffffffc0200fa4:	17048493          	addi	s1,s1,368 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200fa8:	4429                	li	s0,10
        cprintf("    order %2d: %2d blocks\n", order, buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0200faa:	00001997          	auipc	s3,0x1
ffffffffc0200fae:	53e98993          	addi	s3,s3,1342 # ffffffffc02024e8 <commands+0x6f0>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200fb2:	597d                	li	s2,-1
        cprintf("    order %2d: %2d blocks\n", order, buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0200fb4:	4090                	lw	a2,0(s1)
ffffffffc0200fb6:	85a2                	mv	a1,s0
ffffffffc0200fb8:	854e                	mv	a0,s3
ffffffffc0200fba:	0086563b          	srlw	a2,a2,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200fbe:	347d                	addiw	s0,s0,-1
        cprintf("    order %2d: %2d blocks\n", order, buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0200fc0:	8f2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0200fc4:	14a1                	addi	s1,s1,-24
ffffffffc0200fc6:	ff2417e3          	bne	s0,s2,ffffffffc0200fb4 <buddy_system_pmm_check+0x150>
    cprintf("\n");
ffffffffc0200fca:	00001517          	auipc	a0,0x1
ffffffffc0200fce:	cbe50513          	addi	a0,a0,-834 # ffffffffc0201c88 <etext+0xea>
ffffffffc0200fd2:	8e0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        // dbg_buddy();
    }
        dbg_buddy1();
    assert(nr_free_pages() == initial_nr_free_pages - ALLOC_PAGE_NUM);
ffffffffc0200fd6:	4a6000ef          	jal	ra,ffffffffc020147c <nr_free_pages>
ffffffffc0200fda:	f9cb8793          	addi	a5,s7,-100
ffffffffc0200fde:	3ef51e63          	bne	a0,a5,ffffffffc02013da <buddy_system_pmm_check+0x576>

    cprintf("[buddy_check] after alloc:  ");
ffffffffc0200fe2:	00001517          	auipc	a0,0x1
ffffffffc0200fe6:	56650513          	addi	a0,a0,1382 # ffffffffc0202548 <commands+0x750>
ffffffffc0200fea:	8c8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0200fee:	00001517          	auipc	a0,0x1
ffffffffc0200ff2:	3fa50513          	addi	a0,a0,1018 # ffffffffc02023e8 <commands+0x5f0>
ffffffffc0200ff6:	8bcff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200ffa:	00005497          	auipc	s1,0x5
ffffffffc0200ffe:	11648493          	addi	s1,s1,278 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201002:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201004:	00001997          	auipc	s3,0x1
ffffffffc0201008:	3fc98993          	addi	s3,s3,1020 # ffffffffc0202400 <commands+0x608>
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
ffffffffc020101e:	ff2418e3          	bne	s0,s2,ffffffffc020100e <buddy_system_pmm_check+0x1aa>
    cprintf("\n");
ffffffffc0201022:	00001517          	auipc	a0,0x1
ffffffffc0201026:	c6650513          	addi	a0,a0,-922 # ffffffffc0201c88 <etext+0xea>
ffffffffc020102a:	888ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();

    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
        free_pages(pages[i], 1);
        cprintf("[buddy_check] after free: ");
ffffffffc020102e:	00001d17          	auipc	s10,0x1
ffffffffc0201032:	53ad0d13          	addi	s10,s10,1338 # ffffffffc0202568 <commands+0x770>
    cprintf("[dbg_buddy] block: ");
ffffffffc0201036:	00001c97          	auipc	s9,0x1
ffffffffc020103a:	3b2c8c93          	addi	s9,s9,946 # ffffffffc02023e8 <commands+0x5f0>
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020103e:	00001997          	auipc	s3,0x1
ffffffffc0201042:	3c298993          	addi	s3,s3,962 # ffffffffc0202400 <commands+0x608>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201046:	597d                	li	s2,-1
    cprintf("\n");
ffffffffc0201048:	00001c17          	auipc	s8,0x1
ffffffffc020104c:	c40c0c13          	addi	s8,s8,-960 # ffffffffc0201c88 <etext+0xea>
        free_pages(pages[i], 1);
ffffffffc0201050:	000a3503          	ld	a0,0(s4)
ffffffffc0201054:	4585                	li	a1,1
    cprintf("[dbg_buddy] block: ");
ffffffffc0201056:	84da                	mv	s1,s6
        free_pages(pages[i], 1);
ffffffffc0201058:	3e4000ef          	jal	ra,ffffffffc020143c <free_pages>
        cprintf("[buddy_check] after free: ");
ffffffffc020105c:	856a                	mv	a0,s10
ffffffffc020105e:	854ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0201062:	8566                	mv	a0,s9
ffffffffc0201064:	84eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201068:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020106a:	408c                	lw	a1,0(s1)
ffffffffc020106c:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020106e:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201070:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201074:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201076:	83cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020107a:	ff2418e3          	bne	s0,s2,ffffffffc020106a <buddy_system_pmm_check+0x206>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc020107e:	0a21                	addi	s4,s4,8
    cprintf("\n");
ffffffffc0201080:	8562                	mv	a0,s8
ffffffffc0201082:	830ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = 0; i < ALLOC_PAGE_NUM; i++) {
ffffffffc0201086:	fd5a15e3          	bne	s4,s5,ffffffffc0201050 <buddy_system_pmm_check+0x1ec>
        dbg_buddy();
    }

    assert(nr_free_pages() == initial_nr_free_pages);
ffffffffc020108a:	3f2000ef          	jal	ra,ffffffffc020147c <nr_free_pages>
ffffffffc020108e:	33751663          	bne	a0,s7,ffffffffc02013ba <buddy_system_pmm_check+0x556>

    cprintf("[buddy_check] after free:   ");
ffffffffc0201092:	00001517          	auipc	a0,0x1
ffffffffc0201096:	52650513          	addi	a0,a0,1318 # ffffffffc02025b8 <commands+0x7c0>
ffffffffc020109a:	818ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc020109e:	00001517          	auipc	a0,0x1
ffffffffc02010a2:	34a50513          	addi	a0,a0,842 # ffffffffc02023e8 <commands+0x5f0>
ffffffffc02010a6:	80cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02010aa:	00005497          	auipc	s1,0x5
ffffffffc02010ae:	06648493          	addi	s1,s1,102 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010b2:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02010b4:	00001997          	auipc	s3,0x1
ffffffffc02010b8:	34c98993          	addi	s3,s3,844 # ffffffffc0202400 <commands+0x608>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010bc:	597d                	li	s2,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02010be:	408c                	lw	a1,0(s1)
ffffffffc02010c0:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010c2:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02010c4:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010c8:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02010ca:	fe9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02010ce:	ff2418e3          	bne	s0,s2,ffffffffc02010be <buddy_system_pmm_check+0x25a>
    cprintf("\n");
ffffffffc02010d2:	00001517          	auipc	a0,0x1
ffffffffc02010d6:	bb650513          	addi	a0,a0,-1098 # ffffffffc0201c88 <etext+0xea>
ffffffffc02010da:	fd9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();
        struct Page* p1 = alloc_pages(513);
ffffffffc02010de:	20100513          	li	a0,513
ffffffffc02010e2:	31c000ef          	jal	ra,ffffffffc02013fe <alloc_pages>
    assert(p1 != NULL);
ffffffffc02010e6:	2a050a63          	beqz	a0,ffffffffc020139a <buddy_system_pmm_check+0x536>
    assert(p1->property == 1024);
ffffffffc02010ea:	4918                	lw	a4,16(a0)
ffffffffc02010ec:	40000793          	li	a5,1024
ffffffffc02010f0:	28f71563          	bne	a4,a5,ffffffffc020137a <buddy_system_pmm_check+0x516>
    cprintf("[buddy_check] after alloc 513 pages: ");
ffffffffc02010f4:	00001517          	auipc	a0,0x1
ffffffffc02010f8:	50c50513          	addi	a0,a0,1292 # ffffffffc0202600 <commands+0x808>
ffffffffc02010fc:	fb7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	2e850513          	addi	a0,a0,744 # ffffffffc02023e8 <commands+0x5f0>
ffffffffc0201108:	fabfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020110c:	00005497          	auipc	s1,0x5
ffffffffc0201110:	00448493          	addi	s1,s1,4 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201114:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201116:	00001997          	auipc	s3,0x1
ffffffffc020111a:	2ea98993          	addi	s3,s3,746 # ffffffffc0202400 <commands+0x608>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020111e:	597d                	li	s2,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201120:	408c                	lw	a1,0(s1)
ffffffffc0201122:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201124:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201126:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020112a:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020112c:	f87fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201130:	ff2418e3          	bne	s0,s2,ffffffffc0201120 <buddy_system_pmm_check+0x2bc>
    cprintf("\n");
ffffffffc0201134:	00001517          	auipc	a0,0x1
ffffffffc0201138:	b5450513          	addi	a0,a0,-1196 # ffffffffc0201c88 <etext+0xea>
ffffffffc020113c:	f77fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();

    struct Page* p2 = alloc_pages(79);
ffffffffc0201140:	04f00513          	li	a0,79
ffffffffc0201144:	2ba000ef          	jal	ra,ffffffffc02013fe <alloc_pages>
    assert(p2 != NULL);
ffffffffc0201148:	20050963          	beqz	a0,ffffffffc020135a <buddy_system_pmm_check+0x4f6>
    assert(p2->property == 128);
ffffffffc020114c:	4918                	lw	a4,16(a0)
ffffffffc020114e:	08000793          	li	a5,128
ffffffffc0201152:	1ef71463          	bne	a4,a5,ffffffffc020133a <buddy_system_pmm_check+0x4d6>
    cprintf("[buddy_check] after alloc 79 pages:  ");
ffffffffc0201156:	00001517          	auipc	a0,0x1
ffffffffc020115a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0202650 <commands+0x858>
ffffffffc020115e:	f55fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0201162:	00001517          	auipc	a0,0x1
ffffffffc0201166:	28650513          	addi	a0,a0,646 # ffffffffc02023e8 <commands+0x5f0>
ffffffffc020116a:	f49fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020116e:	00005497          	auipc	s1,0x5
ffffffffc0201172:	fa248493          	addi	s1,s1,-94 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201176:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201178:	00001997          	auipc	s3,0x1
ffffffffc020117c:	28898993          	addi	s3,s3,648 # ffffffffc0202400 <commands+0x608>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201180:	597d                	li	s2,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201182:	408c                	lw	a1,0(s1)
ffffffffc0201184:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201186:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201188:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020118c:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020118e:	f25fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201192:	ff2418e3          	bne	s0,s2,ffffffffc0201182 <buddy_system_pmm_check+0x31e>
    cprintf("\n");
ffffffffc0201196:	00001517          	auipc	a0,0x1
ffffffffc020119a:	af250513          	addi	a0,a0,-1294 # ffffffffc0201c88 <etext+0xea>
ffffffffc020119e:	f15fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();

    struct Page* p3 = alloc_pages(37);
ffffffffc02011a2:	02500513          	li	a0,37
ffffffffc02011a6:	258000ef          	jal	ra,ffffffffc02013fe <alloc_pages>
    assert(p3 != NULL);
ffffffffc02011aa:	16050863          	beqz	a0,ffffffffc020131a <buddy_system_pmm_check+0x4b6>
    assert(p3->property == 64);
ffffffffc02011ae:	4918                	lw	a4,16(a0)
ffffffffc02011b0:	04000793          	li	a5,64
ffffffffc02011b4:	14f71363          	bne	a4,a5,ffffffffc02012fa <buddy_system_pmm_check+0x496>
    cprintf("[buddy_check] after alloc 37 pages:  ");
ffffffffc02011b8:	00001517          	auipc	a0,0x1
ffffffffc02011bc:	4e850513          	addi	a0,a0,1256 # ffffffffc02026a0 <commands+0x8a8>
ffffffffc02011c0:	ef3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc02011c4:	00001517          	auipc	a0,0x1
ffffffffc02011c8:	22450513          	addi	a0,a0,548 # ffffffffc02023e8 <commands+0x5f0>
ffffffffc02011cc:	ee7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02011d0:	00005497          	auipc	s1,0x5
ffffffffc02011d4:	f4048493          	addi	s1,s1,-192 # ffffffffc0206110 <buddy_zone+0x100>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011d8:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011da:	00001997          	auipc	s3,0x1
ffffffffc02011de:	22698993          	addi	s3,s3,550 # ffffffffc0202400 <commands+0x608>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011e2:	597d                	li	s2,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011e4:	408c                	lw	a1,0(s1)
ffffffffc02011e6:	854e                	mv	a0,s3
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011e8:	14a1                	addi	s1,s1,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011ea:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011ee:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc02011f0:	ec3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc02011f4:	ff2418e3          	bne	s0,s2,ffffffffc02011e4 <buddy_system_pmm_check+0x380>
    cprintf("\n");
ffffffffc02011f8:	00001517          	auipc	a0,0x1
ffffffffc02011fc:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201c88 <etext+0xea>
ffffffffc0201200:	eb3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();

    struct Page* p4 = alloc_pages(3);
ffffffffc0201204:	450d                	li	a0,3
ffffffffc0201206:	1f8000ef          	jal	ra,ffffffffc02013fe <alloc_pages>
    assert(p4 != NULL);
ffffffffc020120a:	c961                	beqz	a0,ffffffffc02012da <buddy_system_pmm_check+0x476>
    assert(p4->property == 4);
ffffffffc020120c:	4918                	lw	a4,16(a0)
ffffffffc020120e:	4791                	li	a5,4
ffffffffc0201210:	0af71563          	bne	a4,a5,ffffffffc02012ba <buddy_system_pmm_check+0x456>
    cprintf("[buddy_check] after alloc 3 pages:   ");
ffffffffc0201214:	00001517          	auipc	a0,0x1
ffffffffc0201218:	4dc50513          	addi	a0,a0,1244 # ffffffffc02026f0 <commands+0x8f8>
ffffffffc020121c:	e97fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("[dbg_buddy] block: ");
ffffffffc0201220:	00001517          	auipc	a0,0x1
ffffffffc0201224:	1c850513          	addi	a0,a0,456 # ffffffffc02023e8 <commands+0x5f0>
ffffffffc0201228:	e8bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020122c:	4429                	li	s0,10
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc020122e:	00001917          	auipc	s2,0x1
ffffffffc0201232:	1d290913          	addi	s2,s2,466 # ffffffffc0202400 <commands+0x608>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201236:	54fd                	li	s1,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201238:	000b2583          	lw	a1,0(s6)
ffffffffc020123c:	854a                	mv	a0,s2
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020123e:	1b21                	addi	s6,s6,-24
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201240:	0085d5bb          	srlw	a1,a1,s0
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc0201244:	347d                	addiw	s0,s0,-1
        cprintf("%2d ", buddy_zone.free_area[order].nr_free / (1 << order));
ffffffffc0201246:	e6dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int order = MAX_ORDER - 1; order >= 0; order--) {
ffffffffc020124a:	fe9417e3          	bne	s0,s1,ffffffffc0201238 <buddy_system_pmm_check+0x3d4>
    cprintf("\n");
ffffffffc020124e:	00001517          	auipc	a0,0x1
ffffffffc0201252:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201c88 <etext+0xea>
ffffffffc0201256:	e5dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    dbg_buddy();
    cprintf("[buddy_check] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
}
ffffffffc020125a:	37013403          	ld	s0,880(sp)
ffffffffc020125e:	37813083          	ld	ra,888(sp)
ffffffffc0201262:	36813483          	ld	s1,872(sp)
ffffffffc0201266:	36013903          	ld	s2,864(sp)
ffffffffc020126a:	35813983          	ld	s3,856(sp)
ffffffffc020126e:	35013a03          	ld	s4,848(sp)
ffffffffc0201272:	34813a83          	ld	s5,840(sp)
ffffffffc0201276:	34013b03          	ld	s6,832(sp)
ffffffffc020127a:	33813b83          	ld	s7,824(sp)
ffffffffc020127e:	33013c03          	ld	s8,816(sp)
ffffffffc0201282:	32813c83          	ld	s9,808(sp)
ffffffffc0201286:	32013d03          	ld	s10,800(sp)
    cprintf("[buddy_check] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
ffffffffc020128a:	00001517          	auipc	a0,0x1
ffffffffc020128e:	48e50513          	addi	a0,a0,1166 # ffffffffc0202718 <commands+0x920>
}
ffffffffc0201292:	38010113          	addi	sp,sp,896
    cprintf("[buddy_check] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");       
ffffffffc0201296:	e1dfe06f          	j	ffffffffc02000b2 <cprintf>
        assert(pages[i] != NULL);
ffffffffc020129a:	00001697          	auipc	a3,0x1
ffffffffc020129e:	19e68693          	addi	a3,a3,414 # ffffffffc0202438 <commands+0x640>
ffffffffc02012a2:	00001617          	auipc	a2,0x1
ffffffffc02012a6:	05660613          	addi	a2,a2,86 # ffffffffc02022f8 <commands+0x500>
ffffffffc02012aa:	1c100593          	li	a1,449
ffffffffc02012ae:	00001517          	auipc	a0,0x1
ffffffffc02012b2:	06250513          	addi	a0,a0,98 # ffffffffc0202310 <commands+0x518>
ffffffffc02012b6:	8f6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p4->property == 4);
ffffffffc02012ba:	00001697          	auipc	a3,0x1
ffffffffc02012be:	41e68693          	addi	a3,a3,1054 # ffffffffc02026d8 <commands+0x8e0>
ffffffffc02012c2:	00001617          	auipc	a2,0x1
ffffffffc02012c6:	03660613          	addi	a2,a2,54 # ffffffffc02022f8 <commands+0x500>
ffffffffc02012ca:	1e900593          	li	a1,489
ffffffffc02012ce:	00001517          	auipc	a0,0x1
ffffffffc02012d2:	04250513          	addi	a0,a0,66 # ffffffffc0202310 <commands+0x518>
ffffffffc02012d6:	8d6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p4 != NULL);
ffffffffc02012da:	00001697          	auipc	a3,0x1
ffffffffc02012de:	3ee68693          	addi	a3,a3,1006 # ffffffffc02026c8 <commands+0x8d0>
ffffffffc02012e2:	00001617          	auipc	a2,0x1
ffffffffc02012e6:	01660613          	addi	a2,a2,22 # ffffffffc02022f8 <commands+0x500>
ffffffffc02012ea:	1e800593          	li	a1,488
ffffffffc02012ee:	00001517          	auipc	a0,0x1
ffffffffc02012f2:	02250513          	addi	a0,a0,34 # ffffffffc0202310 <commands+0x518>
ffffffffc02012f6:	8b6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p3->property == 64);
ffffffffc02012fa:	00001697          	auipc	a3,0x1
ffffffffc02012fe:	38e68693          	addi	a3,a3,910 # ffffffffc0202688 <commands+0x890>
ffffffffc0201302:	00001617          	auipc	a2,0x1
ffffffffc0201306:	ff660613          	addi	a2,a2,-10 # ffffffffc02022f8 <commands+0x500>
ffffffffc020130a:	1e300593          	li	a1,483
ffffffffc020130e:	00001517          	auipc	a0,0x1
ffffffffc0201312:	00250513          	addi	a0,a0,2 # ffffffffc0202310 <commands+0x518>
ffffffffc0201316:	896ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p3 != NULL);
ffffffffc020131a:	00001697          	auipc	a3,0x1
ffffffffc020131e:	35e68693          	addi	a3,a3,862 # ffffffffc0202678 <commands+0x880>
ffffffffc0201322:	00001617          	auipc	a2,0x1
ffffffffc0201326:	fd660613          	addi	a2,a2,-42 # ffffffffc02022f8 <commands+0x500>
ffffffffc020132a:	1e200593          	li	a1,482
ffffffffc020132e:	00001517          	auipc	a0,0x1
ffffffffc0201332:	fe250513          	addi	a0,a0,-30 # ffffffffc0202310 <commands+0x518>
ffffffffc0201336:	876ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2->property == 128);
ffffffffc020133a:	00001697          	auipc	a3,0x1
ffffffffc020133e:	2fe68693          	addi	a3,a3,766 # ffffffffc0202638 <commands+0x840>
ffffffffc0201342:	00001617          	auipc	a2,0x1
ffffffffc0201346:	fb660613          	addi	a2,a2,-74 # ffffffffc02022f8 <commands+0x500>
ffffffffc020134a:	1dd00593          	li	a1,477
ffffffffc020134e:	00001517          	auipc	a0,0x1
ffffffffc0201352:	fc250513          	addi	a0,a0,-62 # ffffffffc0202310 <commands+0x518>
ffffffffc0201356:	856ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 != NULL);
ffffffffc020135a:	00001697          	auipc	a3,0x1
ffffffffc020135e:	2ce68693          	addi	a3,a3,718 # ffffffffc0202628 <commands+0x830>
ffffffffc0201362:	00001617          	auipc	a2,0x1
ffffffffc0201366:	f9660613          	addi	a2,a2,-106 # ffffffffc02022f8 <commands+0x500>
ffffffffc020136a:	1dc00593          	li	a1,476
ffffffffc020136e:	00001517          	auipc	a0,0x1
ffffffffc0201372:	fa250513          	addi	a0,a0,-94 # ffffffffc0202310 <commands+0x518>
ffffffffc0201376:	836ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->property == 1024);
ffffffffc020137a:	00001697          	auipc	a3,0x1
ffffffffc020137e:	26e68693          	addi	a3,a3,622 # ffffffffc02025e8 <commands+0x7f0>
ffffffffc0201382:	00001617          	auipc	a2,0x1
ffffffffc0201386:	f7660613          	addi	a2,a2,-138 # ffffffffc02022f8 <commands+0x500>
ffffffffc020138a:	1d700593          	li	a1,471
ffffffffc020138e:	00001517          	auipc	a0,0x1
ffffffffc0201392:	f8250513          	addi	a0,a0,-126 # ffffffffc0202310 <commands+0x518>
ffffffffc0201396:	816ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 != NULL);
ffffffffc020139a:	00001697          	auipc	a3,0x1
ffffffffc020139e:	23e68693          	addi	a3,a3,574 # ffffffffc02025d8 <commands+0x7e0>
ffffffffc02013a2:	00001617          	auipc	a2,0x1
ffffffffc02013a6:	f5660613          	addi	a2,a2,-170 # ffffffffc02022f8 <commands+0x500>
ffffffffc02013aa:	1d600593          	li	a1,470
ffffffffc02013ae:	00001517          	auipc	a0,0x1
ffffffffc02013b2:	f6250513          	addi	a0,a0,-158 # ffffffffc0202310 <commands+0x518>
ffffffffc02013b6:	ff7fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == initial_nr_free_pages);
ffffffffc02013ba:	00001697          	auipc	a3,0x1
ffffffffc02013be:	1ce68693          	addi	a3,a3,462 # ffffffffc0202588 <commands+0x790>
ffffffffc02013c2:	00001617          	auipc	a2,0x1
ffffffffc02013c6:	f3660613          	addi	a2,a2,-202 # ffffffffc02022f8 <commands+0x500>
ffffffffc02013ca:	1d100593          	li	a1,465
ffffffffc02013ce:	00001517          	auipc	a0,0x1
ffffffffc02013d2:	f4250513          	addi	a0,a0,-190 # ffffffffc0202310 <commands+0x518>
ffffffffc02013d6:	fd7fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == initial_nr_free_pages - ALLOC_PAGE_NUM);
ffffffffc02013da:	00001697          	auipc	a3,0x1
ffffffffc02013de:	12e68693          	addi	a3,a3,302 # ffffffffc0202508 <commands+0x710>
ffffffffc02013e2:	00001617          	auipc	a2,0x1
ffffffffc02013e6:	f1660613          	addi	a2,a2,-234 # ffffffffc02022f8 <commands+0x500>
ffffffffc02013ea:	1c600593          	li	a1,454
ffffffffc02013ee:	00001517          	auipc	a0,0x1
ffffffffc02013f2:	f2250513          	addi	a0,a0,-222 # ffffffffc0202310 <commands+0x518>
ffffffffc02013f6:	fb7fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02013fa <buddy_check>:

static void buddy_check(void) {
    // cprintf("11111111111");
    buddy_system_pmm_check();
ffffffffc02013fa:	a6bff06f          	j	ffffffffc0200e64 <buddy_system_pmm_check>

ffffffffc02013fe <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013fe:	100027f3          	csrr	a5,sstatus
ffffffffc0201402:	8b89                	andi	a5,a5,2
ffffffffc0201404:	e799                	bnez	a5,ffffffffc0201412 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201406:	00005797          	auipc	a5,0x5
ffffffffc020140a:	13a7b783          	ld	a5,314(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc020140e:	6f9c                	ld	a5,24(a5)
ffffffffc0201410:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201412:	1141                	addi	sp,sp,-16
ffffffffc0201414:	e406                	sd	ra,8(sp)
ffffffffc0201416:	e022                	sd	s0,0(sp)
ffffffffc0201418:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020141a:	844ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020141e:	00005797          	auipc	a5,0x5
ffffffffc0201422:	1227b783          	ld	a5,290(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc0201426:	6f9c                	ld	a5,24(a5)
ffffffffc0201428:	8522                	mv	a0,s0
ffffffffc020142a:	9782                	jalr	a5
ffffffffc020142c:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020142e:	82aff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201432:	60a2                	ld	ra,8(sp)
ffffffffc0201434:	8522                	mv	a0,s0
ffffffffc0201436:	6402                	ld	s0,0(sp)
ffffffffc0201438:	0141                	addi	sp,sp,16
ffffffffc020143a:	8082                	ret

ffffffffc020143c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020143c:	100027f3          	csrr	a5,sstatus
ffffffffc0201440:	8b89                	andi	a5,a5,2
ffffffffc0201442:	e799                	bnez	a5,ffffffffc0201450 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201444:	00005797          	auipc	a5,0x5
ffffffffc0201448:	0fc7b783          	ld	a5,252(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc020144c:	739c                	ld	a5,32(a5)
ffffffffc020144e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201450:	1101                	addi	sp,sp,-32
ffffffffc0201452:	ec06                	sd	ra,24(sp)
ffffffffc0201454:	e822                	sd	s0,16(sp)
ffffffffc0201456:	e426                	sd	s1,8(sp)
ffffffffc0201458:	842a                	mv	s0,a0
ffffffffc020145a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020145c:	802ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201460:	00005797          	auipc	a5,0x5
ffffffffc0201464:	0e07b783          	ld	a5,224(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc0201468:	739c                	ld	a5,32(a5)
ffffffffc020146a:	85a6                	mv	a1,s1
ffffffffc020146c:	8522                	mv	a0,s0
ffffffffc020146e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201470:	6442                	ld	s0,16(sp)
ffffffffc0201472:	60e2                	ld	ra,24(sp)
ffffffffc0201474:	64a2                	ld	s1,8(sp)
ffffffffc0201476:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201478:	fe1fe06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc020147c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020147c:	100027f3          	csrr	a5,sstatus
ffffffffc0201480:	8b89                	andi	a5,a5,2
ffffffffc0201482:	e799                	bnez	a5,ffffffffc0201490 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201484:	00005797          	auipc	a5,0x5
ffffffffc0201488:	0bc7b783          	ld	a5,188(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc020148c:	779c                	ld	a5,40(a5)
ffffffffc020148e:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201490:	1141                	addi	sp,sp,-16
ffffffffc0201492:	e406                	sd	ra,8(sp)
ffffffffc0201494:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201496:	fc9fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020149a:	00005797          	auipc	a5,0x5
ffffffffc020149e:	0a67b783          	ld	a5,166(a5) # ffffffffc0206540 <pmm_manager>
ffffffffc02014a2:	779c                	ld	a5,40(a5)
ffffffffc02014a4:	9782                	jalr	a5
ffffffffc02014a6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02014a8:	fb1fe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02014ac:	60a2                	ld	ra,8(sp)
ffffffffc02014ae:	8522                	mv	a0,s0
ffffffffc02014b0:	6402                	ld	s0,0(sp)
ffffffffc02014b2:	0141                	addi	sp,sp,16
ffffffffc02014b4:	8082                	ret

ffffffffc02014b6 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02014b6:	00001797          	auipc	a5,0x1
ffffffffc02014ba:	2c278793          	addi	a5,a5,706 # ffffffffc0202778 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014be:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02014c0:	1101                	addi	sp,sp,-32
ffffffffc02014c2:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014c4:	00001517          	auipc	a0,0x1
ffffffffc02014c8:	2ec50513          	addi	a0,a0,748 # ffffffffc02027b0 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02014cc:	00005497          	auipc	s1,0x5
ffffffffc02014d0:	07448493          	addi	s1,s1,116 # ffffffffc0206540 <pmm_manager>
void pmm_init(void) {
ffffffffc02014d4:	ec06                	sd	ra,24(sp)
ffffffffc02014d6:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02014d8:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014da:	bd9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02014de:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014e0:	00005417          	auipc	s0,0x5
ffffffffc02014e4:	07840413          	addi	s0,s0,120 # ffffffffc0206558 <va_pa_offset>
    pmm_manager->init();
ffffffffc02014e8:	679c                	ld	a5,8(a5)
ffffffffc02014ea:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014ec:	57f5                	li	a5,-3
ffffffffc02014ee:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02014f0:	00001517          	auipc	a0,0x1
ffffffffc02014f4:	2d850513          	addi	a0,a0,728 # ffffffffc02027c8 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014f8:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02014fa:	bb9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02014fe:	46c5                	li	a3,17
ffffffffc0201500:	06ee                	slli	a3,a3,0x1b
ffffffffc0201502:	40100613          	li	a2,1025
ffffffffc0201506:	16fd                	addi	a3,a3,-1
ffffffffc0201508:	07e005b7          	lui	a1,0x7e00
ffffffffc020150c:	0656                	slli	a2,a2,0x15
ffffffffc020150e:	00001517          	auipc	a0,0x1
ffffffffc0201512:	2d250513          	addi	a0,a0,722 # ffffffffc02027e0 <buddy_system_pmm_manager+0x68>
ffffffffc0201516:	b9dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020151a:	777d                	lui	a4,0xfffff
ffffffffc020151c:	00006797          	auipc	a5,0x6
ffffffffc0201520:	04b78793          	addi	a5,a5,75 # ffffffffc0207567 <end+0xfff>
ffffffffc0201524:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201526:	00005517          	auipc	a0,0x5
ffffffffc020152a:	00a50513          	addi	a0,a0,10 # ffffffffc0206530 <npage>
ffffffffc020152e:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201532:	00005597          	auipc	a1,0x5
ffffffffc0201536:	00658593          	addi	a1,a1,6 # ffffffffc0206538 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020153a:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020153c:	e19c                	sd	a5,0(a1)
ffffffffc020153e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201540:	4701                	li	a4,0
ffffffffc0201542:	4885                	li	a7,1
ffffffffc0201544:	fff80837          	lui	a6,0xfff80
ffffffffc0201548:	a011                	j	ffffffffc020154c <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020154a:	619c                	ld	a5,0(a1)
ffffffffc020154c:	97b6                	add	a5,a5,a3
ffffffffc020154e:	07a1                	addi	a5,a5,8
ffffffffc0201550:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201554:	611c                	ld	a5,0(a0)
ffffffffc0201556:	0705                	addi	a4,a4,1
ffffffffc0201558:	02868693          	addi	a3,a3,40
ffffffffc020155c:	01078633          	add	a2,a5,a6
ffffffffc0201560:	fec765e3          	bltu	a4,a2,ffffffffc020154a <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201564:	6190                	ld	a2,0(a1)
ffffffffc0201566:	00279713          	slli	a4,a5,0x2
ffffffffc020156a:	973e                	add	a4,a4,a5
ffffffffc020156c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201570:	070e                	slli	a4,a4,0x3
ffffffffc0201572:	96b2                	add	a3,a3,a2
ffffffffc0201574:	96ba                	add	a3,a3,a4
ffffffffc0201576:	c0200737          	lui	a4,0xc0200
ffffffffc020157a:	08e6ef63          	bltu	a3,a4,ffffffffc0201618 <pmm_init+0x162>
ffffffffc020157e:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201580:	45c5                	li	a1,17
ffffffffc0201582:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201584:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201586:	04b6e863          	bltu	a3,a1,ffffffffc02015d6 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020158a:	609c                	ld	a5,0(s1)
ffffffffc020158c:	7b9c                	ld	a5,48(a5)
ffffffffc020158e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201590:	00001517          	auipc	a0,0x1
ffffffffc0201594:	2e850513          	addi	a0,a0,744 # ffffffffc0202878 <buddy_system_pmm_manager+0x100>
ffffffffc0201598:	b1bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020159c:	00004597          	auipc	a1,0x4
ffffffffc02015a0:	a6458593          	addi	a1,a1,-1436 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02015a4:	00005797          	auipc	a5,0x5
ffffffffc02015a8:	fab7b623          	sd	a1,-84(a5) # ffffffffc0206550 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02015ac:	c02007b7          	lui	a5,0xc0200
ffffffffc02015b0:	08f5e063          	bltu	a1,a5,ffffffffc0201630 <pmm_init+0x17a>
ffffffffc02015b4:	6010                	ld	a2,0(s0)
}
ffffffffc02015b6:	6442                	ld	s0,16(sp)
ffffffffc02015b8:	60e2                	ld	ra,24(sp)
ffffffffc02015ba:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02015bc:	40c58633          	sub	a2,a1,a2
ffffffffc02015c0:	00005797          	auipc	a5,0x5
ffffffffc02015c4:	f8c7b423          	sd	a2,-120(a5) # ffffffffc0206548 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015c8:	00001517          	auipc	a0,0x1
ffffffffc02015cc:	2d050513          	addi	a0,a0,720 # ffffffffc0202898 <buddy_system_pmm_manager+0x120>
}
ffffffffc02015d0:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015d2:	ae1fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02015d6:	6705                	lui	a4,0x1
ffffffffc02015d8:	177d                	addi	a4,a4,-1
ffffffffc02015da:	96ba                	add	a3,a3,a4
ffffffffc02015dc:	777d                	lui	a4,0xfffff
ffffffffc02015de:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02015e0:	00c6d513          	srli	a0,a3,0xc
ffffffffc02015e4:	00f57e63          	bgeu	a0,a5,ffffffffc0201600 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02015e8:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02015ea:	982a                	add	a6,a6,a0
ffffffffc02015ec:	00281513          	slli	a0,a6,0x2
ffffffffc02015f0:	9542                	add	a0,a0,a6
ffffffffc02015f2:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02015f4:	8d95                	sub	a1,a1,a3
ffffffffc02015f6:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02015f8:	81b1                	srli	a1,a1,0xc
ffffffffc02015fa:	9532                	add	a0,a0,a2
ffffffffc02015fc:	9782                	jalr	a5
}
ffffffffc02015fe:	b771                	j	ffffffffc020158a <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201600:	00001617          	auipc	a2,0x1
ffffffffc0201604:	24860613          	addi	a2,a2,584 # ffffffffc0202848 <buddy_system_pmm_manager+0xd0>
ffffffffc0201608:	06b00593          	li	a1,107
ffffffffc020160c:	00001517          	auipc	a0,0x1
ffffffffc0201610:	25c50513          	addi	a0,a0,604 # ffffffffc0202868 <buddy_system_pmm_manager+0xf0>
ffffffffc0201614:	d99fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201618:	00001617          	auipc	a2,0x1
ffffffffc020161c:	1f860613          	addi	a2,a2,504 # ffffffffc0202810 <buddy_system_pmm_manager+0x98>
ffffffffc0201620:	07200593          	li	a1,114
ffffffffc0201624:	00001517          	auipc	a0,0x1
ffffffffc0201628:	21450513          	addi	a0,a0,532 # ffffffffc0202838 <buddy_system_pmm_manager+0xc0>
ffffffffc020162c:	d81fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201630:	86ae                	mv	a3,a1
ffffffffc0201632:	00001617          	auipc	a2,0x1
ffffffffc0201636:	1de60613          	addi	a2,a2,478 # ffffffffc0202810 <buddy_system_pmm_manager+0x98>
ffffffffc020163a:	08d00593          	li	a1,141
ffffffffc020163e:	00001517          	auipc	a0,0x1
ffffffffc0201642:	1fa50513          	addi	a0,a0,506 # ffffffffc0202838 <buddy_system_pmm_manager+0xc0>
ffffffffc0201646:	d67fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020164a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020164a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020164e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201650:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201654:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201656:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020165a:	f022                	sd	s0,32(sp)
ffffffffc020165c:	ec26                	sd	s1,24(sp)
ffffffffc020165e:	e84a                	sd	s2,16(sp)
ffffffffc0201660:	f406                	sd	ra,40(sp)
ffffffffc0201662:	e44e                	sd	s3,8(sp)
ffffffffc0201664:	84aa                	mv	s1,a0
ffffffffc0201666:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201668:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020166c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020166e:	03067e63          	bgeu	a2,a6,ffffffffc02016aa <printnum+0x60>
ffffffffc0201672:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201674:	00805763          	blez	s0,ffffffffc0201682 <printnum+0x38>
ffffffffc0201678:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020167a:	85ca                	mv	a1,s2
ffffffffc020167c:	854e                	mv	a0,s3
ffffffffc020167e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201680:	fc65                	bnez	s0,ffffffffc0201678 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201682:	1a02                	slli	s4,s4,0x20
ffffffffc0201684:	00001797          	auipc	a5,0x1
ffffffffc0201688:	25478793          	addi	a5,a5,596 # ffffffffc02028d8 <buddy_system_pmm_manager+0x160>
ffffffffc020168c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201690:	9a3e                	add	s4,s4,a5
}
ffffffffc0201692:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201694:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201698:	70a2                	ld	ra,40(sp)
ffffffffc020169a:	69a2                	ld	s3,8(sp)
ffffffffc020169c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020169e:	85ca                	mv	a1,s2
ffffffffc02016a0:	87a6                	mv	a5,s1
}
ffffffffc02016a2:	6942                	ld	s2,16(sp)
ffffffffc02016a4:	64e2                	ld	s1,24(sp)
ffffffffc02016a6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016a8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02016aa:	03065633          	divu	a2,a2,a6
ffffffffc02016ae:	8722                	mv	a4,s0
ffffffffc02016b0:	f9bff0ef          	jal	ra,ffffffffc020164a <printnum>
ffffffffc02016b4:	b7f9                	j	ffffffffc0201682 <printnum+0x38>

ffffffffc02016b6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02016b6:	7119                	addi	sp,sp,-128
ffffffffc02016b8:	f4a6                	sd	s1,104(sp)
ffffffffc02016ba:	f0ca                	sd	s2,96(sp)
ffffffffc02016bc:	ecce                	sd	s3,88(sp)
ffffffffc02016be:	e8d2                	sd	s4,80(sp)
ffffffffc02016c0:	e4d6                	sd	s5,72(sp)
ffffffffc02016c2:	e0da                	sd	s6,64(sp)
ffffffffc02016c4:	fc5e                	sd	s7,56(sp)
ffffffffc02016c6:	f06a                	sd	s10,32(sp)
ffffffffc02016c8:	fc86                	sd	ra,120(sp)
ffffffffc02016ca:	f8a2                	sd	s0,112(sp)
ffffffffc02016cc:	f862                	sd	s8,48(sp)
ffffffffc02016ce:	f466                	sd	s9,40(sp)
ffffffffc02016d0:	ec6e                	sd	s11,24(sp)
ffffffffc02016d2:	892a                	mv	s2,a0
ffffffffc02016d4:	84ae                	mv	s1,a1
ffffffffc02016d6:	8d32                	mv	s10,a2
ffffffffc02016d8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016da:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016de:	5b7d                	li	s6,-1
ffffffffc02016e0:	00001a97          	auipc	s5,0x1
ffffffffc02016e4:	22ca8a93          	addi	s5,s5,556 # ffffffffc020290c <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016e8:	00001b97          	auipc	s7,0x1
ffffffffc02016ec:	400b8b93          	addi	s7,s7,1024 # ffffffffc0202ae8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016f0:	000d4503          	lbu	a0,0(s10)
ffffffffc02016f4:	001d0413          	addi	s0,s10,1
ffffffffc02016f8:	01350a63          	beq	a0,s3,ffffffffc020170c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02016fc:	c121                	beqz	a0,ffffffffc020173c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02016fe:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201700:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201702:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201704:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201708:	ff351ae3          	bne	a0,s3,ffffffffc02016fc <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020170c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201710:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201714:	4c81                	li	s9,0
ffffffffc0201716:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201718:	5c7d                	li	s8,-1
ffffffffc020171a:	5dfd                	li	s11,-1
ffffffffc020171c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201720:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201722:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201726:	0ff5f593          	zext.b	a1,a1
ffffffffc020172a:	00140d13          	addi	s10,s0,1
ffffffffc020172e:	04b56263          	bltu	a0,a1,ffffffffc0201772 <vprintfmt+0xbc>
ffffffffc0201732:	058a                	slli	a1,a1,0x2
ffffffffc0201734:	95d6                	add	a1,a1,s5
ffffffffc0201736:	4194                	lw	a3,0(a1)
ffffffffc0201738:	96d6                	add	a3,a3,s5
ffffffffc020173a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020173c:	70e6                	ld	ra,120(sp)
ffffffffc020173e:	7446                	ld	s0,112(sp)
ffffffffc0201740:	74a6                	ld	s1,104(sp)
ffffffffc0201742:	7906                	ld	s2,96(sp)
ffffffffc0201744:	69e6                	ld	s3,88(sp)
ffffffffc0201746:	6a46                	ld	s4,80(sp)
ffffffffc0201748:	6aa6                	ld	s5,72(sp)
ffffffffc020174a:	6b06                	ld	s6,64(sp)
ffffffffc020174c:	7be2                	ld	s7,56(sp)
ffffffffc020174e:	7c42                	ld	s8,48(sp)
ffffffffc0201750:	7ca2                	ld	s9,40(sp)
ffffffffc0201752:	7d02                	ld	s10,32(sp)
ffffffffc0201754:	6de2                	ld	s11,24(sp)
ffffffffc0201756:	6109                	addi	sp,sp,128
ffffffffc0201758:	8082                	ret
            padc = '0';
ffffffffc020175a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020175c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201760:	846a                	mv	s0,s10
ffffffffc0201762:	00140d13          	addi	s10,s0,1
ffffffffc0201766:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020176a:	0ff5f593          	zext.b	a1,a1
ffffffffc020176e:	fcb572e3          	bgeu	a0,a1,ffffffffc0201732 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201772:	85a6                	mv	a1,s1
ffffffffc0201774:	02500513          	li	a0,37
ffffffffc0201778:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020177a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020177e:	8d22                	mv	s10,s0
ffffffffc0201780:	f73788e3          	beq	a5,s3,ffffffffc02016f0 <vprintfmt+0x3a>
ffffffffc0201784:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201788:	1d7d                	addi	s10,s10,-1
ffffffffc020178a:	ff379de3          	bne	a5,s3,ffffffffc0201784 <vprintfmt+0xce>
ffffffffc020178e:	b78d                	j	ffffffffc02016f0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201790:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201794:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201798:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020179a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020179e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017a2:	02d86463          	bltu	a6,a3,ffffffffc02017ca <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02017a6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02017aa:	002c169b          	slliw	a3,s8,0x2
ffffffffc02017ae:	0186873b          	addw	a4,a3,s8
ffffffffc02017b2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02017b6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02017b8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02017bc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02017be:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02017c2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017c6:	fed870e3          	bgeu	a6,a3,ffffffffc02017a6 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02017ca:	f40ddce3          	bgez	s11,ffffffffc0201722 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02017ce:	8de2                	mv	s11,s8
ffffffffc02017d0:	5c7d                	li	s8,-1
ffffffffc02017d2:	bf81                	j	ffffffffc0201722 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02017d4:	fffdc693          	not	a3,s11
ffffffffc02017d8:	96fd                	srai	a3,a3,0x3f
ffffffffc02017da:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017de:	00144603          	lbu	a2,1(s0)
ffffffffc02017e2:	2d81                	sext.w	s11,s11
ffffffffc02017e4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017e6:	bf35                	j	ffffffffc0201722 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02017e8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ec:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02017f0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017f2:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02017f4:	bfd9                	j	ffffffffc02017ca <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02017f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017f8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02017fc:	01174463          	blt	a4,a7,ffffffffc0201804 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201800:	1a088e63          	beqz	a7,ffffffffc02019bc <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201804:	000a3603          	ld	a2,0(s4)
ffffffffc0201808:	46c1                	li	a3,16
ffffffffc020180a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020180c:	2781                	sext.w	a5,a5
ffffffffc020180e:	876e                	mv	a4,s11
ffffffffc0201810:	85a6                	mv	a1,s1
ffffffffc0201812:	854a                	mv	a0,s2
ffffffffc0201814:	e37ff0ef          	jal	ra,ffffffffc020164a <printnum>
            break;
ffffffffc0201818:	bde1                	j	ffffffffc02016f0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020181a:	000a2503          	lw	a0,0(s4)
ffffffffc020181e:	85a6                	mv	a1,s1
ffffffffc0201820:	0a21                	addi	s4,s4,8
ffffffffc0201822:	9902                	jalr	s2
            break;
ffffffffc0201824:	b5f1                	j	ffffffffc02016f0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201826:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201828:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020182c:	01174463          	blt	a4,a7,ffffffffc0201834 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201830:	18088163          	beqz	a7,ffffffffc02019b2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201834:	000a3603          	ld	a2,0(s4)
ffffffffc0201838:	46a9                	li	a3,10
ffffffffc020183a:	8a2e                	mv	s4,a1
ffffffffc020183c:	bfc1                	j	ffffffffc020180c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020183e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201842:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201844:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201846:	bdf1                	j	ffffffffc0201722 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201848:	85a6                	mv	a1,s1
ffffffffc020184a:	02500513          	li	a0,37
ffffffffc020184e:	9902                	jalr	s2
            break;
ffffffffc0201850:	b545                	j	ffffffffc02016f0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201852:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201856:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201858:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020185a:	b5e1                	j	ffffffffc0201722 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020185c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020185e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201862:	01174463          	blt	a4,a7,ffffffffc020186a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201866:	14088163          	beqz	a7,ffffffffc02019a8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020186a:	000a3603          	ld	a2,0(s4)
ffffffffc020186e:	46a1                	li	a3,8
ffffffffc0201870:	8a2e                	mv	s4,a1
ffffffffc0201872:	bf69                	j	ffffffffc020180c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201874:	03000513          	li	a0,48
ffffffffc0201878:	85a6                	mv	a1,s1
ffffffffc020187a:	e03e                	sd	a5,0(sp)
ffffffffc020187c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020187e:	85a6                	mv	a1,s1
ffffffffc0201880:	07800513          	li	a0,120
ffffffffc0201884:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201886:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201888:	6782                	ld	a5,0(sp)
ffffffffc020188a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020188c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201890:	bfb5                	j	ffffffffc020180c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201892:	000a3403          	ld	s0,0(s4)
ffffffffc0201896:	008a0713          	addi	a4,s4,8
ffffffffc020189a:	e03a                	sd	a4,0(sp)
ffffffffc020189c:	14040263          	beqz	s0,ffffffffc02019e0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02018a0:	0fb05763          	blez	s11,ffffffffc020198e <vprintfmt+0x2d8>
ffffffffc02018a4:	02d00693          	li	a3,45
ffffffffc02018a8:	0cd79163          	bne	a5,a3,ffffffffc020196a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018ac:	00044783          	lbu	a5,0(s0)
ffffffffc02018b0:	0007851b          	sext.w	a0,a5
ffffffffc02018b4:	cf85                	beqz	a5,ffffffffc02018ec <vprintfmt+0x236>
ffffffffc02018b6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018ba:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018be:	000c4563          	bltz	s8,ffffffffc02018c8 <vprintfmt+0x212>
ffffffffc02018c2:	3c7d                	addiw	s8,s8,-1
ffffffffc02018c4:	036c0263          	beq	s8,s6,ffffffffc02018e8 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02018c8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018ca:	0e0c8e63          	beqz	s9,ffffffffc02019c6 <vprintfmt+0x310>
ffffffffc02018ce:	3781                	addiw	a5,a5,-32
ffffffffc02018d0:	0ef47b63          	bgeu	s0,a5,ffffffffc02019c6 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02018d4:	03f00513          	li	a0,63
ffffffffc02018d8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018da:	000a4783          	lbu	a5,0(s4)
ffffffffc02018de:	3dfd                	addiw	s11,s11,-1
ffffffffc02018e0:	0a05                	addi	s4,s4,1
ffffffffc02018e2:	0007851b          	sext.w	a0,a5
ffffffffc02018e6:	ffe1                	bnez	a5,ffffffffc02018be <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02018e8:	01b05963          	blez	s11,ffffffffc02018fa <vprintfmt+0x244>
ffffffffc02018ec:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018ee:	85a6                	mv	a1,s1
ffffffffc02018f0:	02000513          	li	a0,32
ffffffffc02018f4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018f6:	fe0d9be3          	bnez	s11,ffffffffc02018ec <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02018fa:	6a02                	ld	s4,0(sp)
ffffffffc02018fc:	bbd5                	j	ffffffffc02016f0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018fe:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201900:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201904:	01174463          	blt	a4,a7,ffffffffc020190c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201908:	08088d63          	beqz	a7,ffffffffc02019a2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020190c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201910:	0a044d63          	bltz	s0,ffffffffc02019ca <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201914:	8622                	mv	a2,s0
ffffffffc0201916:	8a66                	mv	s4,s9
ffffffffc0201918:	46a9                	li	a3,10
ffffffffc020191a:	bdcd                	j	ffffffffc020180c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020191c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201920:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201922:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201924:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201928:	8fb5                	xor	a5,a5,a3
ffffffffc020192a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020192e:	02d74163          	blt	a4,a3,ffffffffc0201950 <vprintfmt+0x29a>
ffffffffc0201932:	00369793          	slli	a5,a3,0x3
ffffffffc0201936:	97de                	add	a5,a5,s7
ffffffffc0201938:	639c                	ld	a5,0(a5)
ffffffffc020193a:	cb99                	beqz	a5,ffffffffc0201950 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020193c:	86be                	mv	a3,a5
ffffffffc020193e:	00001617          	auipc	a2,0x1
ffffffffc0201942:	fca60613          	addi	a2,a2,-54 # ffffffffc0202908 <buddy_system_pmm_manager+0x190>
ffffffffc0201946:	85a6                	mv	a1,s1
ffffffffc0201948:	854a                	mv	a0,s2
ffffffffc020194a:	0ce000ef          	jal	ra,ffffffffc0201a18 <printfmt>
ffffffffc020194e:	b34d                	j	ffffffffc02016f0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201950:	00001617          	auipc	a2,0x1
ffffffffc0201954:	fa860613          	addi	a2,a2,-88 # ffffffffc02028f8 <buddy_system_pmm_manager+0x180>
ffffffffc0201958:	85a6                	mv	a1,s1
ffffffffc020195a:	854a                	mv	a0,s2
ffffffffc020195c:	0bc000ef          	jal	ra,ffffffffc0201a18 <printfmt>
ffffffffc0201960:	bb41                	j	ffffffffc02016f0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201962:	00001417          	auipc	s0,0x1
ffffffffc0201966:	f8e40413          	addi	s0,s0,-114 # ffffffffc02028f0 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020196a:	85e2                	mv	a1,s8
ffffffffc020196c:	8522                	mv	a0,s0
ffffffffc020196e:	e43e                	sd	a5,8(sp)
ffffffffc0201970:	1cc000ef          	jal	ra,ffffffffc0201b3c <strnlen>
ffffffffc0201974:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201978:	01b05b63          	blez	s11,ffffffffc020198e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020197c:	67a2                	ld	a5,8(sp)
ffffffffc020197e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201982:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201984:	85a6                	mv	a1,s1
ffffffffc0201986:	8552                	mv	a0,s4
ffffffffc0201988:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020198a:	fe0d9ce3          	bnez	s11,ffffffffc0201982 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020198e:	00044783          	lbu	a5,0(s0)
ffffffffc0201992:	00140a13          	addi	s4,s0,1
ffffffffc0201996:	0007851b          	sext.w	a0,a5
ffffffffc020199a:	d3a5                	beqz	a5,ffffffffc02018fa <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020199c:	05e00413          	li	s0,94
ffffffffc02019a0:	bf39                	j	ffffffffc02018be <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02019a2:	000a2403          	lw	s0,0(s4)
ffffffffc02019a6:	b7ad                	j	ffffffffc0201910 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02019a8:	000a6603          	lwu	a2,0(s4)
ffffffffc02019ac:	46a1                	li	a3,8
ffffffffc02019ae:	8a2e                	mv	s4,a1
ffffffffc02019b0:	bdb1                	j	ffffffffc020180c <vprintfmt+0x156>
ffffffffc02019b2:	000a6603          	lwu	a2,0(s4)
ffffffffc02019b6:	46a9                	li	a3,10
ffffffffc02019b8:	8a2e                	mv	s4,a1
ffffffffc02019ba:	bd89                	j	ffffffffc020180c <vprintfmt+0x156>
ffffffffc02019bc:	000a6603          	lwu	a2,0(s4)
ffffffffc02019c0:	46c1                	li	a3,16
ffffffffc02019c2:	8a2e                	mv	s4,a1
ffffffffc02019c4:	b5a1                	j	ffffffffc020180c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02019c6:	9902                	jalr	s2
ffffffffc02019c8:	bf09                	j	ffffffffc02018da <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02019ca:	85a6                	mv	a1,s1
ffffffffc02019cc:	02d00513          	li	a0,45
ffffffffc02019d0:	e03e                	sd	a5,0(sp)
ffffffffc02019d2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02019d4:	6782                	ld	a5,0(sp)
ffffffffc02019d6:	8a66                	mv	s4,s9
ffffffffc02019d8:	40800633          	neg	a2,s0
ffffffffc02019dc:	46a9                	li	a3,10
ffffffffc02019de:	b53d                	j	ffffffffc020180c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02019e0:	03b05163          	blez	s11,ffffffffc0201a02 <vprintfmt+0x34c>
ffffffffc02019e4:	02d00693          	li	a3,45
ffffffffc02019e8:	f6d79de3          	bne	a5,a3,ffffffffc0201962 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02019ec:	00001417          	auipc	s0,0x1
ffffffffc02019f0:	f0440413          	addi	s0,s0,-252 # ffffffffc02028f0 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019f4:	02800793          	li	a5,40
ffffffffc02019f8:	02800513          	li	a0,40
ffffffffc02019fc:	00140a13          	addi	s4,s0,1
ffffffffc0201a00:	bd6d                	j	ffffffffc02018ba <vprintfmt+0x204>
ffffffffc0201a02:	00001a17          	auipc	s4,0x1
ffffffffc0201a06:	eefa0a13          	addi	s4,s4,-273 # ffffffffc02028f1 <buddy_system_pmm_manager+0x179>
ffffffffc0201a0a:	02800513          	li	a0,40
ffffffffc0201a0e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a12:	05e00413          	li	s0,94
ffffffffc0201a16:	b565                	j	ffffffffc02018be <vprintfmt+0x208>

ffffffffc0201a18 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a18:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a1a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a1e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a20:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a22:	ec06                	sd	ra,24(sp)
ffffffffc0201a24:	f83a                	sd	a4,48(sp)
ffffffffc0201a26:	fc3e                	sd	a5,56(sp)
ffffffffc0201a28:	e0c2                	sd	a6,64(sp)
ffffffffc0201a2a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a2c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a2e:	c89ff0ef          	jal	ra,ffffffffc02016b6 <vprintfmt>
}
ffffffffc0201a32:	60e2                	ld	ra,24(sp)
ffffffffc0201a34:	6161                	addi	sp,sp,80
ffffffffc0201a36:	8082                	ret

ffffffffc0201a38 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a38:	715d                	addi	sp,sp,-80
ffffffffc0201a3a:	e486                	sd	ra,72(sp)
ffffffffc0201a3c:	e0a6                	sd	s1,64(sp)
ffffffffc0201a3e:	fc4a                	sd	s2,56(sp)
ffffffffc0201a40:	f84e                	sd	s3,48(sp)
ffffffffc0201a42:	f452                	sd	s4,40(sp)
ffffffffc0201a44:	f056                	sd	s5,32(sp)
ffffffffc0201a46:	ec5a                	sd	s6,24(sp)
ffffffffc0201a48:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201a4a:	c901                	beqz	a0,ffffffffc0201a5a <readline+0x22>
ffffffffc0201a4c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201a4e:	00001517          	auipc	a0,0x1
ffffffffc0201a52:	eba50513          	addi	a0,a0,-326 # ffffffffc0202908 <buddy_system_pmm_manager+0x190>
ffffffffc0201a56:	e5cfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201a5a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a5c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201a5e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201a60:	4aa9                	li	s5,10
ffffffffc0201a62:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201a64:	00004b97          	auipc	s7,0x4
ffffffffc0201a68:	6bcb8b93          	addi	s7,s7,1724 # ffffffffc0206120 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a6c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a70:	ebafe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201a74:	00054a63          	bltz	a0,ffffffffc0201a88 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a78:	00a95a63          	bge	s2,a0,ffffffffc0201a8c <readline+0x54>
ffffffffc0201a7c:	029a5263          	bge	s4,s1,ffffffffc0201aa0 <readline+0x68>
        c = getchar();
ffffffffc0201a80:	eaafe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201a84:	fe055ae3          	bgez	a0,ffffffffc0201a78 <readline+0x40>
            return NULL;
ffffffffc0201a88:	4501                	li	a0,0
ffffffffc0201a8a:	a091                	j	ffffffffc0201ace <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201a8c:	03351463          	bne	a0,s3,ffffffffc0201ab4 <readline+0x7c>
ffffffffc0201a90:	e8a9                	bnez	s1,ffffffffc0201ae2 <readline+0xaa>
        c = getchar();
ffffffffc0201a92:	e98fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201a96:	fe0549e3          	bltz	a0,ffffffffc0201a88 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a9a:	fea959e3          	bge	s2,a0,ffffffffc0201a8c <readline+0x54>
ffffffffc0201a9e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201aa0:	e42a                	sd	a0,8(sp)
ffffffffc0201aa2:	e46fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201aa6:	6522                	ld	a0,8(sp)
ffffffffc0201aa8:	009b87b3          	add	a5,s7,s1
ffffffffc0201aac:	2485                	addiw	s1,s1,1
ffffffffc0201aae:	00a78023          	sb	a0,0(a5)
ffffffffc0201ab2:	bf7d                	j	ffffffffc0201a70 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ab4:	01550463          	beq	a0,s5,ffffffffc0201abc <readline+0x84>
ffffffffc0201ab8:	fb651ce3          	bne	a0,s6,ffffffffc0201a70 <readline+0x38>
            cputchar(c);
ffffffffc0201abc:	e2cfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201ac0:	00004517          	auipc	a0,0x4
ffffffffc0201ac4:	66050513          	addi	a0,a0,1632 # ffffffffc0206120 <buf>
ffffffffc0201ac8:	94aa                	add	s1,s1,a0
ffffffffc0201aca:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201ace:	60a6                	ld	ra,72(sp)
ffffffffc0201ad0:	6486                	ld	s1,64(sp)
ffffffffc0201ad2:	7962                	ld	s2,56(sp)
ffffffffc0201ad4:	79c2                	ld	s3,48(sp)
ffffffffc0201ad6:	7a22                	ld	s4,40(sp)
ffffffffc0201ad8:	7a82                	ld	s5,32(sp)
ffffffffc0201ada:	6b62                	ld	s6,24(sp)
ffffffffc0201adc:	6bc2                	ld	s7,16(sp)
ffffffffc0201ade:	6161                	addi	sp,sp,80
ffffffffc0201ae0:	8082                	ret
            cputchar(c);
ffffffffc0201ae2:	4521                	li	a0,8
ffffffffc0201ae4:	e04fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201ae8:	34fd                	addiw	s1,s1,-1
ffffffffc0201aea:	b759                	j	ffffffffc0201a70 <readline+0x38>

ffffffffc0201aec <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201aec:	4781                	li	a5,0
ffffffffc0201aee:	00004717          	auipc	a4,0x4
ffffffffc0201af2:	51a73703          	ld	a4,1306(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201af6:	88ba                	mv	a7,a4
ffffffffc0201af8:	852a                	mv	a0,a0
ffffffffc0201afa:	85be                	mv	a1,a5
ffffffffc0201afc:	863e                	mv	a2,a5
ffffffffc0201afe:	00000073          	ecall
ffffffffc0201b02:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201b04:	8082                	ret

ffffffffc0201b06 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201b06:	4781                	li	a5,0
ffffffffc0201b08:	00005717          	auipc	a4,0x5
ffffffffc0201b0c:	a5873703          	ld	a4,-1448(a4) # ffffffffc0206560 <SBI_SET_TIMER>
ffffffffc0201b10:	88ba                	mv	a7,a4
ffffffffc0201b12:	852a                	mv	a0,a0
ffffffffc0201b14:	85be                	mv	a1,a5
ffffffffc0201b16:	863e                	mv	a2,a5
ffffffffc0201b18:	00000073          	ecall
ffffffffc0201b1c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201b1e:	8082                	ret

ffffffffc0201b20 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201b20:	4501                	li	a0,0
ffffffffc0201b22:	00004797          	auipc	a5,0x4
ffffffffc0201b26:	4de7b783          	ld	a5,1246(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201b2a:	88be                	mv	a7,a5
ffffffffc0201b2c:	852a                	mv	a0,a0
ffffffffc0201b2e:	85aa                	mv	a1,a0
ffffffffc0201b30:	862a                	mv	a2,a0
ffffffffc0201b32:	00000073          	ecall
ffffffffc0201b36:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b38:	2501                	sext.w	a0,a0
ffffffffc0201b3a:	8082                	ret

ffffffffc0201b3c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201b3c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b3e:	e589                	bnez	a1,ffffffffc0201b48 <strnlen+0xc>
ffffffffc0201b40:	a811                	j	ffffffffc0201b54 <strnlen+0x18>
        cnt ++;
ffffffffc0201b42:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b44:	00f58863          	beq	a1,a5,ffffffffc0201b54 <strnlen+0x18>
ffffffffc0201b48:	00f50733          	add	a4,a0,a5
ffffffffc0201b4c:	00074703          	lbu	a4,0(a4)
ffffffffc0201b50:	fb6d                	bnez	a4,ffffffffc0201b42 <strnlen+0x6>
ffffffffc0201b52:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201b54:	852e                	mv	a0,a1
ffffffffc0201b56:	8082                	ret

ffffffffc0201b58 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b58:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b5c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b60:	cb89                	beqz	a5,ffffffffc0201b72 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201b62:	0505                	addi	a0,a0,1
ffffffffc0201b64:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b66:	fee789e3          	beq	a5,a4,ffffffffc0201b58 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b6a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201b6e:	9d19                	subw	a0,a0,a4
ffffffffc0201b70:	8082                	ret
ffffffffc0201b72:	4501                	li	a0,0
ffffffffc0201b74:	bfed                	j	ffffffffc0201b6e <strcmp+0x16>

ffffffffc0201b76 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201b76:	00054783          	lbu	a5,0(a0)
ffffffffc0201b7a:	c799                	beqz	a5,ffffffffc0201b88 <strchr+0x12>
        if (*s == c) {
ffffffffc0201b7c:	00f58763          	beq	a1,a5,ffffffffc0201b8a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201b80:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201b84:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201b86:	fbfd                	bnez	a5,ffffffffc0201b7c <strchr+0x6>
    }
    return NULL;
ffffffffc0201b88:	4501                	li	a0,0
}
ffffffffc0201b8a:	8082                	ret

ffffffffc0201b8c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201b8c:	ca01                	beqz	a2,ffffffffc0201b9c <memset+0x10>
ffffffffc0201b8e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201b90:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201b92:	0785                	addi	a5,a5,1
ffffffffc0201b94:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201b98:	fec79de3          	bne	a5,a2,ffffffffc0201b92 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b9c:	8082                	ret
