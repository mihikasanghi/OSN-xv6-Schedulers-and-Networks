
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a5010113          	addi	sp,sp,-1456 # 80008a50 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	28c78793          	addi	a5,a5,652 # 800062f0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb45f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	65e080e7          	jalr	1630(ra) # 8000278a <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	990080e7          	jalr	-1648(ra) # 80001b50 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	40c080e7          	jalr	1036(ra) # 800025d4 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	13e080e7          	jalr	318(ra) # 80002314 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	522080e7          	jalr	1314(ra) # 80002734 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	4ee080e7          	jalr	1262(ra) # 800027e0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	f32080e7          	jalr	-206(ra) # 80002378 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	d9078793          	addi	a5,a5,-624 # 80022208 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5c07a323          	sw	zero,1478(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72923          	sw	a5,850(a4) # 800088d0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	556dad83          	lw	s11,1366(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	50050513          	addi	a0,a0,1280 # 80010af8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3a250513          	addi	a0,a0,930 # 80010af8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	38648493          	addi	s1,s1,902 # 80010af8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	34650513          	addi	a0,a0,838 # 80010b18 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0d27a783          	lw	a5,210(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0a27b783          	ld	a5,162(a5) # 800088d8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0a273703          	ld	a4,162(a4) # 800088e0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2b8a0a13          	addi	s4,s4,696 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	07048493          	addi	s1,s1,112 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	07098993          	addi	s3,s3,112 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	ae6080e7          	jalr	-1306(ra) # 80002378 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	24a50513          	addi	a0,a0,586 # 80010b18 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	ff27a783          	lw	a5,-14(a5) # 800088d0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	ff873703          	ld	a4,-8(a4) # 800088e0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fe87b783          	ld	a5,-24(a5) # 800088d8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fd448493          	addi	s1,s1,-44 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fd490913          	addi	s2,s2,-44 # 800088e0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	9f8080e7          	jalr	-1544(ra) # 80002314 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1e648493          	addi	s1,s1,486 # 80010b18 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7bd23          	sd	a4,-102(a5) # 800088e0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	15c48493          	addi	s1,s1,348 # 80010b18 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00023797          	auipc	a5,0x23
    80000a02:	9a278793          	addi	a5,a5,-1630 # 800233a0 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	13290913          	addi	s2,s2,306 # 80010b50 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	8d250513          	addi	a0,a0,-1838 # 800233a0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	fc4080e7          	jalr	-60(ra) # 80001b34 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	f92080e7          	jalr	-110(ra) # 80001b34 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	f86080e7          	jalr	-122(ra) # 80001b34 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	f6e080e7          	jalr	-146(ra) # 80001b34 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	f2e080e7          	jalr	-210(ra) # 80001b34 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	f02080e7          	jalr	-254(ra) # 80001b34 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	ca4080e7          	jalr	-860(ra) # 80001b24 <cpuid>
    userinit();      // first user process
    createMyMLFQ();  // create MLFQ queues
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	c88080e7          	jalr	-888(ra) # 80001b24 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0e0080e7          	jalr	224(ra) # 80000f96 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	c12080e7          	jalr	-1006(ra) # 80002ad0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	46a080e7          	jalr	1130(ra) # 80006330 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	1bc080e7          	jalr	444(ra) # 8000208a <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	32e080e7          	jalr	814(ra) # 8000124c <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	070080e7          	jalr	112(ra) # 80000f96 <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	b42080e7          	jalr	-1214(ra) # 80001a70 <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	b72080e7          	jalr	-1166(ra) # 80002aa8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	b92080e7          	jalr	-1134(ra) # 80002ad0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	3d4080e7          	jalr	980(ra) # 8000631a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	3e2080e7          	jalr	994(ra) # 80006330 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	580080e7          	jalr	1408(ra) # 800034d6 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	c24080e7          	jalr	-988(ra) # 80003b82 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	bc2080e7          	jalr	-1086(ra) # 80004b28 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	4ca080e7          	jalr	1226(ra) # 80006438 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	ef6080e7          	jalr	-266(ra) # 80001e6c <userinit>
    createMyMLFQ();  // create MLFQ queues
    80000f7e:	00001097          	auipc	ra,0x1
    80000f82:	8c0080e7          	jalr	-1856(ra) # 8000183e <createMyMLFQ>
    __sync_synchronize();
    80000f86:	0ff0000f          	fence
    started = 1;
    80000f8a:	4785                	li	a5,1
    80000f8c:	00008717          	auipc	a4,0x8
    80000f90:	94f72e23          	sw	a5,-1700(a4) # 800088e8 <started>
    80000f94:	bf2d                	j	80000ece <main+0x56>

0000000080000f96 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f96:	1141                	addi	sp,sp,-16
    80000f98:	e422                	sd	s0,8(sp)
    80000f9a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa0:	00008797          	auipc	a5,0x8
    80000fa4:	9507b783          	ld	a5,-1712(a5) # 800088f0 <kernel_pagetable>
    80000fa8:	83b1                	srli	a5,a5,0xc
    80000faa:	577d                	li	a4,-1
    80000fac:	177e                	slli	a4,a4,0x3f
    80000fae:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb0:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fb4:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb8:	6422                	ld	s0,8(sp)
    80000fba:	0141                	addi	sp,sp,16
    80000fbc:	8082                	ret

0000000080000fbe <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fbe:	7139                	addi	sp,sp,-64
    80000fc0:	fc06                	sd	ra,56(sp)
    80000fc2:	f822                	sd	s0,48(sp)
    80000fc4:	f426                	sd	s1,40(sp)
    80000fc6:	f04a                	sd	s2,32(sp)
    80000fc8:	ec4e                	sd	s3,24(sp)
    80000fca:	e852                	sd	s4,16(sp)
    80000fcc:	e456                	sd	s5,8(sp)
    80000fce:	e05a                	sd	s6,0(sp)
    80000fd0:	0080                	addi	s0,sp,64
    80000fd2:	84aa                	mv	s1,a0
    80000fd4:	89ae                	mv	s3,a1
    80000fd6:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd8:	57fd                	li	a5,-1
    80000fda:	83e9                	srli	a5,a5,0x1a
    80000fdc:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fde:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe0:	04b7f263          	bgeu	a5,a1,80001024 <walk+0x66>
    panic("walk");
    80000fe4:	00007517          	auipc	a0,0x7
    80000fe8:	0ec50513          	addi	a0,a0,236 # 800080d0 <digits+0x90>
    80000fec:	fffff097          	auipc	ra,0xfffff
    80000ff0:	552080e7          	jalr	1362(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff4:	060a8663          	beqz	s5,80001060 <walk+0xa2>
    80000ff8:	00000097          	auipc	ra,0x0
    80000ffc:	aee080e7          	jalr	-1298(ra) # 80000ae6 <kalloc>
    80001000:	84aa                	mv	s1,a0
    80001002:	c529                	beqz	a0,8000104c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001004:	6605                	lui	a2,0x1
    80001006:	4581                	li	a1,0
    80001008:	00000097          	auipc	ra,0x0
    8000100c:	cca080e7          	jalr	-822(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001010:	00c4d793          	srli	a5,s1,0xc
    80001014:	07aa                	slli	a5,a5,0xa
    80001016:	0017e793          	ori	a5,a5,1
    8000101a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000101e:	3a5d                	addiw	s4,s4,-9
    80001020:	036a0063          	beq	s4,s6,80001040 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001024:	0149d933          	srl	s2,s3,s4
    80001028:	1ff97913          	andi	s2,s2,511
    8000102c:	090e                	slli	s2,s2,0x3
    8000102e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001030:	00093483          	ld	s1,0(s2)
    80001034:	0014f793          	andi	a5,s1,1
    80001038:	dfd5                	beqz	a5,80000ff4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103a:	80a9                	srli	s1,s1,0xa
    8000103c:	04b2                	slli	s1,s1,0xc
    8000103e:	b7c5                	j	8000101e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001040:	00c9d513          	srli	a0,s3,0xc
    80001044:	1ff57513          	andi	a0,a0,511
    80001048:	050e                	slli	a0,a0,0x3
    8000104a:	9526                	add	a0,a0,s1
}
    8000104c:	70e2                	ld	ra,56(sp)
    8000104e:	7442                	ld	s0,48(sp)
    80001050:	74a2                	ld	s1,40(sp)
    80001052:	7902                	ld	s2,32(sp)
    80001054:	69e2                	ld	s3,24(sp)
    80001056:	6a42                	ld	s4,16(sp)
    80001058:	6aa2                	ld	s5,8(sp)
    8000105a:	6b02                	ld	s6,0(sp)
    8000105c:	6121                	addi	sp,sp,64
    8000105e:	8082                	ret
        return 0;
    80001060:	4501                	li	a0,0
    80001062:	b7ed                	j	8000104c <walk+0x8e>

0000000080001064 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001064:	57fd                	li	a5,-1
    80001066:	83e9                	srli	a5,a5,0x1a
    80001068:	00b7f463          	bgeu	a5,a1,80001070 <walkaddr+0xc>
    return 0;
    8000106c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000106e:	8082                	ret
{
    80001070:	1141                	addi	sp,sp,-16
    80001072:	e406                	sd	ra,8(sp)
    80001074:	e022                	sd	s0,0(sp)
    80001076:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001078:	4601                	li	a2,0
    8000107a:	00000097          	auipc	ra,0x0
    8000107e:	f44080e7          	jalr	-188(ra) # 80000fbe <walk>
  if(pte == 0)
    80001082:	c105                	beqz	a0,800010a2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001084:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001086:	0117f693          	andi	a3,a5,17
    8000108a:	4745                	li	a4,17
    return 0;
    8000108c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000108e:	00e68663          	beq	a3,a4,8000109a <walkaddr+0x36>
}
    80001092:	60a2                	ld	ra,8(sp)
    80001094:	6402                	ld	s0,0(sp)
    80001096:	0141                	addi	sp,sp,16
    80001098:	8082                	ret
  pa = PTE2PA(*pte);
    8000109a:	00a7d513          	srli	a0,a5,0xa
    8000109e:	0532                	slli	a0,a0,0xc
  return pa;
    800010a0:	bfcd                	j	80001092 <walkaddr+0x2e>
    return 0;
    800010a2:	4501                	li	a0,0
    800010a4:	b7fd                	j	80001092 <walkaddr+0x2e>

00000000800010a6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a6:	715d                	addi	sp,sp,-80
    800010a8:	e486                	sd	ra,72(sp)
    800010aa:	e0a2                	sd	s0,64(sp)
    800010ac:	fc26                	sd	s1,56(sp)
    800010ae:	f84a                	sd	s2,48(sp)
    800010b0:	f44e                	sd	s3,40(sp)
    800010b2:	f052                	sd	s4,32(sp)
    800010b4:	ec56                	sd	s5,24(sp)
    800010b6:	e85a                	sd	s6,16(sp)
    800010b8:	e45e                	sd	s7,8(sp)
    800010ba:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010bc:	c639                	beqz	a2,8000110a <mappages+0x64>
    800010be:	8aaa                	mv	s5,a0
    800010c0:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010c2:	77fd                	lui	a5,0xfffff
    800010c4:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c8:	15fd                	addi	a1,a1,-1
    800010ca:	00c589b3          	add	s3,a1,a2
    800010ce:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010d2:	8952                	mv	s2,s4
    800010d4:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d8:	6b85                	lui	s7,0x1
    800010da:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010de:	4605                	li	a2,1
    800010e0:	85ca                	mv	a1,s2
    800010e2:	8556                	mv	a0,s5
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	eda080e7          	jalr	-294(ra) # 80000fbe <walk>
    800010ec:	cd1d                	beqz	a0,8000112a <mappages+0x84>
    if(*pte & PTE_V)
    800010ee:	611c                	ld	a5,0(a0)
    800010f0:	8b85                	andi	a5,a5,1
    800010f2:	e785                	bnez	a5,8000111a <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f4:	80b1                	srli	s1,s1,0xc
    800010f6:	04aa                	slli	s1,s1,0xa
    800010f8:	0164e4b3          	or	s1,s1,s6
    800010fc:	0014e493          	ori	s1,s1,1
    80001100:	e104                	sd	s1,0(a0)
    if(a == last)
    80001102:	05390063          	beq	s2,s3,80001142 <mappages+0x9c>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001108:	bfc9                	j	800010da <mappages+0x34>
    panic("mappages: size");
    8000110a:	00007517          	auipc	a0,0x7
    8000110e:	fce50513          	addi	a0,a0,-50 # 800080d8 <digits+0x98>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	42c080e7          	jalr	1068(ra) # 8000053e <panic>
      panic("mappages: remap");
    8000111a:	00007517          	auipc	a0,0x7
    8000111e:	fce50513          	addi	a0,a0,-50 # 800080e8 <digits+0xa8>
    80001122:	fffff097          	auipc	ra,0xfffff
    80001126:	41c080e7          	jalr	1052(ra) # 8000053e <panic>
      return -1;
    8000112a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000112c:	60a6                	ld	ra,72(sp)
    8000112e:	6406                	ld	s0,64(sp)
    80001130:	74e2                	ld	s1,56(sp)
    80001132:	7942                	ld	s2,48(sp)
    80001134:	79a2                	ld	s3,40(sp)
    80001136:	7a02                	ld	s4,32(sp)
    80001138:	6ae2                	ld	s5,24(sp)
    8000113a:	6b42                	ld	s6,16(sp)
    8000113c:	6ba2                	ld	s7,8(sp)
    8000113e:	6161                	addi	sp,sp,80
    80001140:	8082                	ret
  return 0;
    80001142:	4501                	li	a0,0
    80001144:	b7e5                	j	8000112c <mappages+0x86>

0000000080001146 <kvmmap>:
{
    80001146:	1141                	addi	sp,sp,-16
    80001148:	e406                	sd	ra,8(sp)
    8000114a:	e022                	sd	s0,0(sp)
    8000114c:	0800                	addi	s0,sp,16
    8000114e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001150:	86b2                	mv	a3,a2
    80001152:	863e                	mv	a2,a5
    80001154:	00000097          	auipc	ra,0x0
    80001158:	f52080e7          	jalr	-174(ra) # 800010a6 <mappages>
    8000115c:	e509                	bnez	a0,80001166 <kvmmap+0x20>
}
    8000115e:	60a2                	ld	ra,8(sp)
    80001160:	6402                	ld	s0,0(sp)
    80001162:	0141                	addi	sp,sp,16
    80001164:	8082                	ret
    panic("kvmmap");
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	f9250513          	addi	a0,a0,-110 # 800080f8 <digits+0xb8>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	3d0080e7          	jalr	976(ra) # 8000053e <panic>

0000000080001176 <kvmmake>:
{
    80001176:	1101                	addi	sp,sp,-32
    80001178:	ec06                	sd	ra,24(sp)
    8000117a:	e822                	sd	s0,16(sp)
    8000117c:	e426                	sd	s1,8(sp)
    8000117e:	e04a                	sd	s2,0(sp)
    80001180:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001182:	00000097          	auipc	ra,0x0
    80001186:	964080e7          	jalr	-1692(ra) # 80000ae6 <kalloc>
    8000118a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118c:	6605                	lui	a2,0x1
    8000118e:	4581                	li	a1,0
    80001190:	00000097          	auipc	ra,0x0
    80001194:	b42080e7          	jalr	-1214(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001198:	4719                	li	a4,6
    8000119a:	6685                	lui	a3,0x1
    8000119c:	10000637          	lui	a2,0x10000
    800011a0:	100005b7          	lui	a1,0x10000
    800011a4:	8526                	mv	a0,s1
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	fa0080e7          	jalr	-96(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011ae:	4719                	li	a4,6
    800011b0:	6685                	lui	a3,0x1
    800011b2:	10001637          	lui	a2,0x10001
    800011b6:	100015b7          	lui	a1,0x10001
    800011ba:	8526                	mv	a0,s1
    800011bc:	00000097          	auipc	ra,0x0
    800011c0:	f8a080e7          	jalr	-118(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c4:	4719                	li	a4,6
    800011c6:	004006b7          	lui	a3,0x400
    800011ca:	0c000637          	lui	a2,0xc000
    800011ce:	0c0005b7          	lui	a1,0xc000
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	f72080e7          	jalr	-142(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011dc:	00007917          	auipc	s2,0x7
    800011e0:	e2490913          	addi	s2,s2,-476 # 80008000 <etext>
    800011e4:	4729                	li	a4,10
    800011e6:	80007697          	auipc	a3,0x80007
    800011ea:	e1a68693          	addi	a3,a3,-486 # 8000 <_entry-0x7fff8000>
    800011ee:	4605                	li	a2,1
    800011f0:	067e                	slli	a2,a2,0x1f
    800011f2:	85b2                	mv	a1,a2
    800011f4:	8526                	mv	a0,s1
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	f50080e7          	jalr	-176(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011fe:	4719                	li	a4,6
    80001200:	46c5                	li	a3,17
    80001202:	06ee                	slli	a3,a3,0x1b
    80001204:	412686b3          	sub	a3,a3,s2
    80001208:	864a                	mv	a2,s2
    8000120a:	85ca                	mv	a1,s2
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f38080e7          	jalr	-200(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001216:	4729                	li	a4,10
    80001218:	6685                	lui	a3,0x1
    8000121a:	00006617          	auipc	a2,0x6
    8000121e:	de660613          	addi	a2,a2,-538 # 80007000 <_trampoline>
    80001222:	040005b7          	lui	a1,0x4000
    80001226:	15fd                	addi	a1,a1,-1
    80001228:	05b2                	slli	a1,a1,0xc
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	f1a080e7          	jalr	-230(ra) # 80001146 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	7a4080e7          	jalr	1956(ra) # 800019da <proc_mapstacks>
}
    8000123e:	8526                	mv	a0,s1
    80001240:	60e2                	ld	ra,24(sp)
    80001242:	6442                	ld	s0,16(sp)
    80001244:	64a2                	ld	s1,8(sp)
    80001246:	6902                	ld	s2,0(sp)
    80001248:	6105                	addi	sp,sp,32
    8000124a:	8082                	ret

000000008000124c <kvminit>:
{
    8000124c:	1141                	addi	sp,sp,-16
    8000124e:	e406                	sd	ra,8(sp)
    80001250:	e022                	sd	s0,0(sp)
    80001252:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001254:	00000097          	auipc	ra,0x0
    80001258:	f22080e7          	jalr	-222(ra) # 80001176 <kvmmake>
    8000125c:	00007797          	auipc	a5,0x7
    80001260:	68a7ba23          	sd	a0,1684(a5) # 800088f0 <kernel_pagetable>
}
    80001264:	60a2                	ld	ra,8(sp)
    80001266:	6402                	ld	s0,0(sp)
    80001268:	0141                	addi	sp,sp,16
    8000126a:	8082                	ret

000000008000126c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000126c:	715d                	addi	sp,sp,-80
    8000126e:	e486                	sd	ra,72(sp)
    80001270:	e0a2                	sd	s0,64(sp)
    80001272:	fc26                	sd	s1,56(sp)
    80001274:	f84a                	sd	s2,48(sp)
    80001276:	f44e                	sd	s3,40(sp)
    80001278:	f052                	sd	s4,32(sp)
    8000127a:	ec56                	sd	s5,24(sp)
    8000127c:	e85a                	sd	s6,16(sp)
    8000127e:	e45e                	sd	s7,8(sp)
    80001280:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001282:	03459793          	slli	a5,a1,0x34
    80001286:	e795                	bnez	a5,800012b2 <uvmunmap+0x46>
    80001288:	8a2a                	mv	s4,a0
    8000128a:	892e                	mv	s2,a1
    8000128c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	0632                	slli	a2,a2,0xc
    80001290:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001294:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001296:	6b05                	lui	s6,0x1
    80001298:	0735e263          	bltu	a1,s3,800012fc <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000129c:	60a6                	ld	ra,72(sp)
    8000129e:	6406                	ld	s0,64(sp)
    800012a0:	74e2                	ld	s1,56(sp)
    800012a2:	7942                	ld	s2,48(sp)
    800012a4:	79a2                	ld	s3,40(sp)
    800012a6:	7a02                	ld	s4,32(sp)
    800012a8:	6ae2                	ld	s5,24(sp)
    800012aa:	6b42                	ld	s6,16(sp)
    800012ac:	6ba2                	ld	s7,8(sp)
    800012ae:	6161                	addi	sp,sp,80
    800012b0:	8082                	ret
    panic("uvmunmap: not aligned");
    800012b2:	00007517          	auipc	a0,0x7
    800012b6:	e4e50513          	addi	a0,a0,-434 # 80008100 <digits+0xc0>
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	284080e7          	jalr	644(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012c2:	00007517          	auipc	a0,0x7
    800012c6:	e5650513          	addi	a0,a0,-426 # 80008118 <digits+0xd8>
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	274080e7          	jalr	628(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e5650513          	addi	a0,a0,-426 # 80008128 <digits+0xe8>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	264080e7          	jalr	612(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012e2:	00007517          	auipc	a0,0x7
    800012e6:	e5e50513          	addi	a0,a0,-418 # 80008140 <digits+0x100>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	254080e7          	jalr	596(ra) # 8000053e <panic>
    *pte = 0;
    800012f2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f6:	995a                	add	s2,s2,s6
    800012f8:	fb3972e3          	bgeu	s2,s3,8000129c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012fc:	4601                	li	a2,0
    800012fe:	85ca                	mv	a1,s2
    80001300:	8552                	mv	a0,s4
    80001302:	00000097          	auipc	ra,0x0
    80001306:	cbc080e7          	jalr	-836(ra) # 80000fbe <walk>
    8000130a:	84aa                	mv	s1,a0
    8000130c:	d95d                	beqz	a0,800012c2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000130e:	6108                	ld	a0,0(a0)
    80001310:	00157793          	andi	a5,a0,1
    80001314:	dfdd                	beqz	a5,800012d2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001316:	3ff57793          	andi	a5,a0,1023
    8000131a:	fd7784e3          	beq	a5,s7,800012e2 <uvmunmap+0x76>
    if(do_free){
    8000131e:	fc0a8ae3          	beqz	s5,800012f2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001322:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001324:	0532                	slli	a0,a0,0xc
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	6c4080e7          	jalr	1732(ra) # 800009ea <kfree>
    8000132e:	b7d1                	j	800012f2 <uvmunmap+0x86>

0000000080001330 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001330:	1101                	addi	sp,sp,-32
    80001332:	ec06                	sd	ra,24(sp)
    80001334:	e822                	sd	s0,16(sp)
    80001336:	e426                	sd	s1,8(sp)
    80001338:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133a:	fffff097          	auipc	ra,0xfffff
    8000133e:	7ac080e7          	jalr	1964(ra) # 80000ae6 <kalloc>
    80001342:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001344:	c519                	beqz	a0,80001352 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001346:	6605                	lui	a2,0x1
    80001348:	4581                	li	a1,0
    8000134a:	00000097          	auipc	ra,0x0
    8000134e:	988080e7          	jalr	-1656(ra) # 80000cd2 <memset>
  return pagetable;
}
    80001352:	8526                	mv	a0,s1
    80001354:	60e2                	ld	ra,24(sp)
    80001356:	6442                	ld	s0,16(sp)
    80001358:	64a2                	ld	s1,8(sp)
    8000135a:	6105                	addi	sp,sp,32
    8000135c:	8082                	ret

000000008000135e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000135e:	7179                	addi	sp,sp,-48
    80001360:	f406                	sd	ra,40(sp)
    80001362:	f022                	sd	s0,32(sp)
    80001364:	ec26                	sd	s1,24(sp)
    80001366:	e84a                	sd	s2,16(sp)
    80001368:	e44e                	sd	s3,8(sp)
    8000136a:	e052                	sd	s4,0(sp)
    8000136c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000136e:	6785                	lui	a5,0x1
    80001370:	04f67863          	bgeu	a2,a5,800013c0 <uvmfirst+0x62>
    80001374:	8a2a                	mv	s4,a0
    80001376:	89ae                	mv	s3,a1
    80001378:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	76c080e7          	jalr	1900(ra) # 80000ae6 <kalloc>
    80001382:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	94a080e7          	jalr	-1718(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001390:	4779                	li	a4,30
    80001392:	86ca                	mv	a3,s2
    80001394:	6605                	lui	a2,0x1
    80001396:	4581                	li	a1,0
    80001398:	8552                	mv	a0,s4
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	d0c080e7          	jalr	-756(ra) # 800010a6 <mappages>
  memmove(mem, src, sz);
    800013a2:	8626                	mv	a2,s1
    800013a4:	85ce                	mv	a1,s3
    800013a6:	854a                	mv	a0,s2
    800013a8:	00000097          	auipc	ra,0x0
    800013ac:	986080e7          	jalr	-1658(ra) # 80000d2e <memmove>
}
    800013b0:	70a2                	ld	ra,40(sp)
    800013b2:	7402                	ld	s0,32(sp)
    800013b4:	64e2                	ld	s1,24(sp)
    800013b6:	6942                	ld	s2,16(sp)
    800013b8:	69a2                	ld	s3,8(sp)
    800013ba:	6a02                	ld	s4,0(sp)
    800013bc:	6145                	addi	sp,sp,48
    800013be:	8082                	ret
    panic("uvmfirst: more than a page");
    800013c0:	00007517          	auipc	a0,0x7
    800013c4:	d9850513          	addi	a0,a0,-616 # 80008158 <digits+0x118>
    800013c8:	fffff097          	auipc	ra,0xfffff
    800013cc:	176080e7          	jalr	374(ra) # 8000053e <panic>

00000000800013d0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d0:	1101                	addi	sp,sp,-32
    800013d2:	ec06                	sd	ra,24(sp)
    800013d4:	e822                	sd	s0,16(sp)
    800013d6:	e426                	sd	s1,8(sp)
    800013d8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013da:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013dc:	00b67d63          	bgeu	a2,a1,800013f6 <uvmdealloc+0x26>
    800013e0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013e2:	6785                	lui	a5,0x1
    800013e4:	17fd                	addi	a5,a5,-1
    800013e6:	00f60733          	add	a4,a2,a5
    800013ea:	767d                	lui	a2,0xfffff
    800013ec:	8f71                	and	a4,a4,a2
    800013ee:	97ae                	add	a5,a5,a1
    800013f0:	8ff1                	and	a5,a5,a2
    800013f2:	00f76863          	bltu	a4,a5,80001402 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f6:	8526                	mv	a0,s1
    800013f8:	60e2                	ld	ra,24(sp)
    800013fa:	6442                	ld	s0,16(sp)
    800013fc:	64a2                	ld	s1,8(sp)
    800013fe:	6105                	addi	sp,sp,32
    80001400:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001402:	8f99                	sub	a5,a5,a4
    80001404:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001406:	4685                	li	a3,1
    80001408:	0007861b          	sext.w	a2,a5
    8000140c:	85ba                	mv	a1,a4
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	e5e080e7          	jalr	-418(ra) # 8000126c <uvmunmap>
    80001416:	b7c5                	j	800013f6 <uvmdealloc+0x26>

0000000080001418 <uvmalloc>:
  if(newsz < oldsz)
    80001418:	0ab66563          	bltu	a2,a1,800014c2 <uvmalloc+0xaa>
{
    8000141c:	7139                	addi	sp,sp,-64
    8000141e:	fc06                	sd	ra,56(sp)
    80001420:	f822                	sd	s0,48(sp)
    80001422:	f426                	sd	s1,40(sp)
    80001424:	f04a                	sd	s2,32(sp)
    80001426:	ec4e                	sd	s3,24(sp)
    80001428:	e852                	sd	s4,16(sp)
    8000142a:	e456                	sd	s5,8(sp)
    8000142c:	e05a                	sd	s6,0(sp)
    8000142e:	0080                	addi	s0,sp,64
    80001430:	8aaa                	mv	s5,a0
    80001432:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001434:	6985                	lui	s3,0x1
    80001436:	19fd                	addi	s3,s3,-1
    80001438:	95ce                	add	a1,a1,s3
    8000143a:	79fd                	lui	s3,0xfffff
    8000143c:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001440:	08c9f363          	bgeu	s3,a2,800014c6 <uvmalloc+0xae>
    80001444:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001446:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000144a:	fffff097          	auipc	ra,0xfffff
    8000144e:	69c080e7          	jalr	1692(ra) # 80000ae6 <kalloc>
    80001452:	84aa                	mv	s1,a0
    if(mem == 0){
    80001454:	c51d                	beqz	a0,80001482 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001456:	6605                	lui	a2,0x1
    80001458:	4581                	li	a1,0
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	878080e7          	jalr	-1928(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001462:	875a                	mv	a4,s6
    80001464:	86a6                	mv	a3,s1
    80001466:	6605                	lui	a2,0x1
    80001468:	85ca                	mv	a1,s2
    8000146a:	8556                	mv	a0,s5
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	c3a080e7          	jalr	-966(ra) # 800010a6 <mappages>
    80001474:	e90d                	bnez	a0,800014a6 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001476:	6785                	lui	a5,0x1
    80001478:	993e                	add	s2,s2,a5
    8000147a:	fd4968e3          	bltu	s2,s4,8000144a <uvmalloc+0x32>
  return newsz;
    8000147e:	8552                	mv	a0,s4
    80001480:	a809                	j	80001492 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001482:	864e                	mv	a2,s3
    80001484:	85ca                	mv	a1,s2
    80001486:	8556                	mv	a0,s5
    80001488:	00000097          	auipc	ra,0x0
    8000148c:	f48080e7          	jalr	-184(ra) # 800013d0 <uvmdealloc>
      return 0;
    80001490:	4501                	li	a0,0
}
    80001492:	70e2                	ld	ra,56(sp)
    80001494:	7442                	ld	s0,48(sp)
    80001496:	74a2                	ld	s1,40(sp)
    80001498:	7902                	ld	s2,32(sp)
    8000149a:	69e2                	ld	s3,24(sp)
    8000149c:	6a42                	ld	s4,16(sp)
    8000149e:	6aa2                	ld	s5,8(sp)
    800014a0:	6b02                	ld	s6,0(sp)
    800014a2:	6121                	addi	sp,sp,64
    800014a4:	8082                	ret
      kfree(mem);
    800014a6:	8526                	mv	a0,s1
    800014a8:	fffff097          	auipc	ra,0xfffff
    800014ac:	542080e7          	jalr	1346(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b0:	864e                	mv	a2,s3
    800014b2:	85ca                	mv	a1,s2
    800014b4:	8556                	mv	a0,s5
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	f1a080e7          	jalr	-230(ra) # 800013d0 <uvmdealloc>
      return 0;
    800014be:	4501                	li	a0,0
    800014c0:	bfc9                	j	80001492 <uvmalloc+0x7a>
    return oldsz;
    800014c2:	852e                	mv	a0,a1
}
    800014c4:	8082                	ret
  return newsz;
    800014c6:	8532                	mv	a0,a2
    800014c8:	b7e9                	j	80001492 <uvmalloc+0x7a>

00000000800014ca <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ca:	7179                	addi	sp,sp,-48
    800014cc:	f406                	sd	ra,40(sp)
    800014ce:	f022                	sd	s0,32(sp)
    800014d0:	ec26                	sd	s1,24(sp)
    800014d2:	e84a                	sd	s2,16(sp)
    800014d4:	e44e                	sd	s3,8(sp)
    800014d6:	e052                	sd	s4,0(sp)
    800014d8:	1800                	addi	s0,sp,48
    800014da:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014dc:	84aa                	mv	s1,a0
    800014de:	6905                	lui	s2,0x1
    800014e0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e2:	4985                	li	s3,1
    800014e4:	a821                	j	800014fc <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e8:	0532                	slli	a0,a0,0xc
    800014ea:	00000097          	auipc	ra,0x0
    800014ee:	fe0080e7          	jalr	-32(ra) # 800014ca <freewalk>
      pagetable[i] = 0;
    800014f2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f6:	04a1                	addi	s1,s1,8
    800014f8:	03248163          	beq	s1,s2,8000151a <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fc:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fe:	00f57793          	andi	a5,a0,15
    80001502:	ff3782e3          	beq	a5,s3,800014e6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001506:	8905                	andi	a0,a0,1
    80001508:	d57d                	beqz	a0,800014f6 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150a:	00007517          	auipc	a0,0x7
    8000150e:	c6e50513          	addi	a0,a0,-914 # 80008178 <digits+0x138>
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	02c080e7          	jalr	44(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151a:	8552                	mv	a0,s4
    8000151c:	fffff097          	auipc	ra,0xfffff
    80001520:	4ce080e7          	jalr	1230(ra) # 800009ea <kfree>
}
    80001524:	70a2                	ld	ra,40(sp)
    80001526:	7402                	ld	s0,32(sp)
    80001528:	64e2                	ld	s1,24(sp)
    8000152a:	6942                	ld	s2,16(sp)
    8000152c:	69a2                	ld	s3,8(sp)
    8000152e:	6a02                	ld	s4,0(sp)
    80001530:	6145                	addi	sp,sp,48
    80001532:	8082                	ret

0000000080001534 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001534:	1101                	addi	sp,sp,-32
    80001536:	ec06                	sd	ra,24(sp)
    80001538:	e822                	sd	s0,16(sp)
    8000153a:	e426                	sd	s1,8(sp)
    8000153c:	1000                	addi	s0,sp,32
    8000153e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001540:	e999                	bnez	a1,80001556 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001542:	8526                	mv	a0,s1
    80001544:	00000097          	auipc	ra,0x0
    80001548:	f86080e7          	jalr	-122(ra) # 800014ca <freewalk>
}
    8000154c:	60e2                	ld	ra,24(sp)
    8000154e:	6442                	ld	s0,16(sp)
    80001550:	64a2                	ld	s1,8(sp)
    80001552:	6105                	addi	sp,sp,32
    80001554:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001556:	6605                	lui	a2,0x1
    80001558:	167d                	addi	a2,a2,-1
    8000155a:	962e                	add	a2,a2,a1
    8000155c:	4685                	li	a3,1
    8000155e:	8231                	srli	a2,a2,0xc
    80001560:	4581                	li	a1,0
    80001562:	00000097          	auipc	ra,0x0
    80001566:	d0a080e7          	jalr	-758(ra) # 8000126c <uvmunmap>
    8000156a:	bfe1                	j	80001542 <uvmfree+0xe>

000000008000156c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156c:	c679                	beqz	a2,8000163a <uvmcopy+0xce>
{
    8000156e:	715d                	addi	sp,sp,-80
    80001570:	e486                	sd	ra,72(sp)
    80001572:	e0a2                	sd	s0,64(sp)
    80001574:	fc26                	sd	s1,56(sp)
    80001576:	f84a                	sd	s2,48(sp)
    80001578:	f44e                	sd	s3,40(sp)
    8000157a:	f052                	sd	s4,32(sp)
    8000157c:	ec56                	sd	s5,24(sp)
    8000157e:	e85a                	sd	s6,16(sp)
    80001580:	e45e                	sd	s7,8(sp)
    80001582:	0880                	addi	s0,sp,80
    80001584:	8b2a                	mv	s6,a0
    80001586:	8aae                	mv	s5,a1
    80001588:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158c:	4601                	li	a2,0
    8000158e:	85ce                	mv	a1,s3
    80001590:	855a                	mv	a0,s6
    80001592:	00000097          	auipc	ra,0x0
    80001596:	a2c080e7          	jalr	-1492(ra) # 80000fbe <walk>
    8000159a:	c531                	beqz	a0,800015e6 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159c:	6118                	ld	a4,0(a0)
    8000159e:	00177793          	andi	a5,a4,1
    800015a2:	cbb1                	beqz	a5,800015f6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a4:	00a75593          	srli	a1,a4,0xa
    800015a8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ac:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b0:	fffff097          	auipc	ra,0xfffff
    800015b4:	536080e7          	jalr	1334(ra) # 80000ae6 <kalloc>
    800015b8:	892a                	mv	s2,a0
    800015ba:	c939                	beqz	a0,80001610 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015bc:	6605                	lui	a2,0x1
    800015be:	85de                	mv	a1,s7
    800015c0:	fffff097          	auipc	ra,0xfffff
    800015c4:	76e080e7          	jalr	1902(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c8:	8726                	mv	a4,s1
    800015ca:	86ca                	mv	a3,s2
    800015cc:	6605                	lui	a2,0x1
    800015ce:	85ce                	mv	a1,s3
    800015d0:	8556                	mv	a0,s5
    800015d2:	00000097          	auipc	ra,0x0
    800015d6:	ad4080e7          	jalr	-1324(ra) # 800010a6 <mappages>
    800015da:	e515                	bnez	a0,80001606 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015dc:	6785                	lui	a5,0x1
    800015de:	99be                	add	s3,s3,a5
    800015e0:	fb49e6e3          	bltu	s3,s4,8000158c <uvmcopy+0x20>
    800015e4:	a081                	j	80001624 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e6:	00007517          	auipc	a0,0x7
    800015ea:	ba250513          	addi	a0,a0,-1118 # 80008188 <digits+0x148>
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	f50080e7          	jalr	-176(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f6:	00007517          	auipc	a0,0x7
    800015fa:	bb250513          	addi	a0,a0,-1102 # 800081a8 <digits+0x168>
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	f40080e7          	jalr	-192(ra) # 8000053e <panic>
      kfree(mem);
    80001606:	854a                	mv	a0,s2
    80001608:	fffff097          	auipc	ra,0xfffff
    8000160c:	3e2080e7          	jalr	994(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001610:	4685                	li	a3,1
    80001612:	00c9d613          	srli	a2,s3,0xc
    80001616:	4581                	li	a1,0
    80001618:	8556                	mv	a0,s5
    8000161a:	00000097          	auipc	ra,0x0
    8000161e:	c52080e7          	jalr	-942(ra) # 8000126c <uvmunmap>
  return -1;
    80001622:	557d                	li	a0,-1
}
    80001624:	60a6                	ld	ra,72(sp)
    80001626:	6406                	ld	s0,64(sp)
    80001628:	74e2                	ld	s1,56(sp)
    8000162a:	7942                	ld	s2,48(sp)
    8000162c:	79a2                	ld	s3,40(sp)
    8000162e:	7a02                	ld	s4,32(sp)
    80001630:	6ae2                	ld	s5,24(sp)
    80001632:	6b42                	ld	s6,16(sp)
    80001634:	6ba2                	ld	s7,8(sp)
    80001636:	6161                	addi	sp,sp,80
    80001638:	8082                	ret
  return 0;
    8000163a:	4501                	li	a0,0
}
    8000163c:	8082                	ret

000000008000163e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163e:	1141                	addi	sp,sp,-16
    80001640:	e406                	sd	ra,8(sp)
    80001642:	e022                	sd	s0,0(sp)
    80001644:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001646:	4601                	li	a2,0
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	976080e7          	jalr	-1674(ra) # 80000fbe <walk>
  if(pte == 0)
    80001650:	c901                	beqz	a0,80001660 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001652:	611c                	ld	a5,0(a0)
    80001654:	9bbd                	andi	a5,a5,-17
    80001656:	e11c                	sd	a5,0(a0)
}
    80001658:	60a2                	ld	ra,8(sp)
    8000165a:	6402                	ld	s0,0(sp)
    8000165c:	0141                	addi	sp,sp,16
    8000165e:	8082                	ret
    panic("uvmclear");
    80001660:	00007517          	auipc	a0,0x7
    80001664:	b6850513          	addi	a0,a0,-1176 # 800081c8 <digits+0x188>
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	ed6080e7          	jalr	-298(ra) # 8000053e <panic>

0000000080001670 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001670:	c6bd                	beqz	a3,800016de <copyout+0x6e>
{
    80001672:	715d                	addi	sp,sp,-80
    80001674:	e486                	sd	ra,72(sp)
    80001676:	e0a2                	sd	s0,64(sp)
    80001678:	fc26                	sd	s1,56(sp)
    8000167a:	f84a                	sd	s2,48(sp)
    8000167c:	f44e                	sd	s3,40(sp)
    8000167e:	f052                	sd	s4,32(sp)
    80001680:	ec56                	sd	s5,24(sp)
    80001682:	e85a                	sd	s6,16(sp)
    80001684:	e45e                	sd	s7,8(sp)
    80001686:	e062                	sd	s8,0(sp)
    80001688:	0880                	addi	s0,sp,80
    8000168a:	8b2a                	mv	s6,a0
    8000168c:	8c2e                	mv	s8,a1
    8000168e:	8a32                	mv	s4,a2
    80001690:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001692:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001694:	6a85                	lui	s5,0x1
    80001696:	a015                	j	800016ba <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001698:	9562                	add	a0,a0,s8
    8000169a:	0004861b          	sext.w	a2,s1
    8000169e:	85d2                	mv	a1,s4
    800016a0:	41250533          	sub	a0,a0,s2
    800016a4:	fffff097          	auipc	ra,0xfffff
    800016a8:	68a080e7          	jalr	1674(ra) # 80000d2e <memmove>

    len -= n;
    800016ac:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b0:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b6:	02098263          	beqz	s3,800016da <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016be:	85ca                	mv	a1,s2
    800016c0:	855a                	mv	a0,s6
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	9a2080e7          	jalr	-1630(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800016ca:	cd01                	beqz	a0,800016e2 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016cc:	418904b3          	sub	s1,s2,s8
    800016d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d2:	fc99f3e3          	bgeu	s3,s1,80001698 <copyout+0x28>
    800016d6:	84ce                	mv	s1,s3
    800016d8:	b7c1                	j	80001698 <copyout+0x28>
  }
  return 0;
    800016da:	4501                	li	a0,0
    800016dc:	a021                	j	800016e4 <copyout+0x74>
    800016de:	4501                	li	a0,0
}
    800016e0:	8082                	ret
      return -1;
    800016e2:	557d                	li	a0,-1
}
    800016e4:	60a6                	ld	ra,72(sp)
    800016e6:	6406                	ld	s0,64(sp)
    800016e8:	74e2                	ld	s1,56(sp)
    800016ea:	7942                	ld	s2,48(sp)
    800016ec:	79a2                	ld	s3,40(sp)
    800016ee:	7a02                	ld	s4,32(sp)
    800016f0:	6ae2                	ld	s5,24(sp)
    800016f2:	6b42                	ld	s6,16(sp)
    800016f4:	6ba2                	ld	s7,8(sp)
    800016f6:	6c02                	ld	s8,0(sp)
    800016f8:	6161                	addi	sp,sp,80
    800016fa:	8082                	ret

00000000800016fc <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fc:	caa5                	beqz	a3,8000176c <copyin+0x70>
{
    800016fe:	715d                	addi	sp,sp,-80
    80001700:	e486                	sd	ra,72(sp)
    80001702:	e0a2                	sd	s0,64(sp)
    80001704:	fc26                	sd	s1,56(sp)
    80001706:	f84a                	sd	s2,48(sp)
    80001708:	f44e                	sd	s3,40(sp)
    8000170a:	f052                	sd	s4,32(sp)
    8000170c:	ec56                	sd	s5,24(sp)
    8000170e:	e85a                	sd	s6,16(sp)
    80001710:	e45e                	sd	s7,8(sp)
    80001712:	e062                	sd	s8,0(sp)
    80001714:	0880                	addi	s0,sp,80
    80001716:	8b2a                	mv	s6,a0
    80001718:	8a2e                	mv	s4,a1
    8000171a:	8c32                	mv	s8,a2
    8000171c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001720:	6a85                	lui	s5,0x1
    80001722:	a01d                	j	80001748 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001724:	018505b3          	add	a1,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412585b3          	sub	a1,a1,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	5fc080e7          	jalr	1532(ra) # 80000d2e <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	914080e7          	jalr	-1772(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f2e3          	bgeu	s3,s1,80001724 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	bf7d                	j	80001724 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x76>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	882080e7          	jalr	-1918(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <createMyMLFQ>:
int priorityTimeValues[] = {1, 3, 9, 15};

struct myMLFQ mlfq[4];

void createMyMLFQ()
{
    8000183e:	1141                	addi	sp,sp,-16
    80001840:	e422                	sd	s0,8(sp)
    80001842:	0800                	addi	s0,sp,16
  // Iterate through each priority level in the multi-level feedback queue (mlfq)
  for (int i = 0; i < 4; i++)
    80001844:	00010717          	auipc	a4,0x10
    80001848:	95c70713          	addi	a4,a4,-1700 # 800111a0 <mlfq+0x200>
    8000184c:	00010617          	auipc	a2,0x10
    80001850:	17460613          	addi	a2,a2,372 # 800119c0 <proc+0x200>
  {
    // Initialize the last index of the current priority queue to -1, indicating it's empty
    mlfq[i].last = -1;
    80001854:	56fd                	li	a3,-1
    80001856:	c314                	sw	a3,0(a4)

    // Iterate through each potential process slot in the current priority queue
    for (int j = 0; j < NPROC; j++)
    80001858:	e0070793          	addi	a5,a4,-512
    {
      // Initialize each process slot to null (using void pointer)
      mlfq[i].procs[j] = (void *)0;
    8000185c:	0007b023          	sd	zero,0(a5)
    for (int j = 0; j < NPROC; j++)
    80001860:	07a1                	addi	a5,a5,8
    80001862:	fee79de3          	bne	a5,a4,8000185c <createMyMLFQ+0x1e>
  for (int i = 0; i < 4; i++)
    80001866:	20870713          	addi	a4,a4,520
    8000186a:	fec716e3          	bne	a4,a2,80001856 <createMyMLFQ+0x18>
    }
  }
}
    8000186e:	6422                	ld	s0,8(sp)
    80001870:	0141                	addi	sp,sp,16
    80001872:	8082                	ret

0000000080001874 <push>:

void push(struct proc *p, int priorNum)
{
    80001874:	1141                	addi	sp,sp,-16
    80001876:	e422                	sd	s0,8(sp)
    80001878:	0800                	addi	s0,sp,16
  // Iterate through all processes in the current priority queue
  for (int i = 0; i < mlfq[priorNum].last; i++)
    8000187a:	00659793          	slli	a5,a1,0x6
    8000187e:	97ae                	add	a5,a5,a1
    80001880:	078e                	slli	a5,a5,0x3
    80001882:	0000f717          	auipc	a4,0xf
    80001886:	71e70713          	addi	a4,a4,1822 # 80010fa0 <mlfq>
    8000188a:	97ba                	add	a5,a5,a4
    8000188c:	2007a683          	lw	a3,512(a5)
    80001890:	02d05f63          	blez	a3,800018ce <push+0x5a>
  {
    // Check if the process is already in the queue by comparing PIDs
    if (mlfq[priorNum].procs[i]->pid == p->pid)
    80001894:	4130                	lw	a2,64(a0)
    80001896:	00659713          	slli	a4,a1,0x6
    8000189a:	00b707b3          	add	a5,a4,a1
    8000189e:	078e                	slli	a5,a5,0x3
    800018a0:	0000f817          	auipc	a6,0xf
    800018a4:	70080813          	addi	a6,a6,1792 # 80010fa0 <mlfq>
    800018a8:	97c2                	add	a5,a5,a6
    800018aa:	972e                	add	a4,a4,a1
    800018ac:	36fd                	addiw	a3,a3,-1
    800018ae:	1682                	slli	a3,a3,0x20
    800018b0:	9281                	srli	a3,a3,0x20
    800018b2:	9736                	add	a4,a4,a3
    800018b4:	070e                	slli	a4,a4,0x3
    800018b6:	0000f697          	auipc	a3,0xf
    800018ba:	6f268693          	addi	a3,a3,1778 # 80010fa8 <mlfq+0x8>
    800018be:	9736                	add	a4,a4,a3
    800018c0:	6394                	ld	a3,0(a5)
    800018c2:	42b4                	lw	a3,64(a3)
    800018c4:	04c68963          	beq	a3,a2,80001916 <push+0xa2>
  for (int i = 0; i < mlfq[priorNum].last; i++)
    800018c8:	07a1                	addi	a5,a5,8
    800018ca:	fee79be3          	bne	a5,a4,800018c0 <push+0x4c>
      return;
    }
  }

  // Update the tick count when the process entered the queue
  p->queueEnteredAt = ticks;
    800018ce:	00007797          	auipc	a5,0x7
    800018d2:	0327a783          	lw	a5,50(a5) # 80008900 <ticks>
    800018d6:	cd5c                	sw	a5,28(a0)
  // Set the priority level of the process
  p->priority = priorNum;
    800018d8:	cd0c                	sw	a1,24(a0)
  // Mark the process as queued
  p->queued = 1;
    800018da:	4785                	li	a5,1
    800018dc:	d11c                	sw	a5,32(a0)
  // Set the time the process has been in the queue,
  // assuming a time quantum that is three times the priority level plus one
  p->timeInQueue = (priorNum + 1) * 3;
    800018de:	0015871b          	addiw	a4,a1,1
    800018e2:	0017179b          	slliw	a5,a4,0x1
    800018e6:	9fb9                	addw	a5,a5,a4
    800018e8:	d51c                	sw	a5,40(a0)
  // Increment the index of the last process in the priority queue
  mlfq[priorNum].last++;
    800018ea:	0000f697          	auipc	a3,0xf
    800018ee:	6b668693          	addi	a3,a3,1718 # 80010fa0 <mlfq>
    800018f2:	00659793          	slli	a5,a1,0x6
    800018f6:	00b78733          	add	a4,a5,a1
    800018fa:	070e                	slli	a4,a4,0x3
    800018fc:	9736                	add	a4,a4,a3
    800018fe:	20072603          	lw	a2,512(a4)
    80001902:	2605                	addiw	a2,a2,1
    80001904:	0006081b          	sext.w	a6,a2
    80001908:	20c72023          	sw	a2,512(a4)
  // Add the process to the end of the priority queue
  mlfq[priorNum].procs[mlfq[priorNum].last] = p;
    8000190c:	97ae                	add	a5,a5,a1
    8000190e:	97c2                	add	a5,a5,a6
    80001910:	078e                	slli	a5,a5,0x3
    80001912:	97b6                	add	a5,a5,a3
    80001914:	e388                	sd	a0,0(a5)

  return;
}
    80001916:	6422                	ld	s0,8(sp)
    80001918:	0141                	addi	sp,sp,16
    8000191a:	8082                	ret

000000008000191c <erase>:

void erase(struct proc *p, int priorNum)
{
    8000191c:	1141                	addi	sp,sp,-16
    8000191e:	e422                	sd	s0,8(sp)
    80001920:	0800                	addi	s0,sp,16
  // Initialize a variable to store the index of the process in the queue
  int indexOfProcess = -1;

  // Iterate through all processes in the priority queue
  for (int i = 0; i <= mlfq[priorNum].last; i++)
    80001922:	00659793          	slli	a5,a1,0x6
    80001926:	97ae                	add	a5,a5,a1
    80001928:	078e                	slli	a5,a5,0x3
    8000192a:	0000f717          	auipc	a4,0xf
    8000192e:	67670713          	addi	a4,a4,1654 # 80010fa0 <mlfq>
    80001932:	97ba                	add	a5,a5,a4
    80001934:	2007a683          	lw	a3,512(a5)
    80001938:	0806ce63          	bltz	a3,800019d4 <erase+0xb8>
  {
    // Check if the process is already in the queue by comparing PIDs
    if (p->pid == mlfq[priorNum].procs[i]->pid)
    8000193c:	04052803          	lw	a6,64(a0)
    80001940:	00659793          	slli	a5,a1,0x6
    80001944:	97ae                	add	a5,a5,a1
    80001946:	078e                	slli	a5,a5,0x3
    80001948:	97ba                	add	a5,a5,a4
  for (int i = 0; i <= mlfq[priorNum].last; i++)
    8000194a:	4701                	li	a4,0
    if (p->pid == mlfq[priorNum].procs[i]->pid)
    8000194c:	6390                	ld	a2,0(a5)
    8000194e:	4230                	lw	a2,64(a2)
    80001950:	01060763          	beq	a2,a6,8000195e <erase+0x42>
  for (int i = 0; i <= mlfq[priorNum].last; i++)
    80001954:	2705                	addiw	a4,a4,1
    80001956:	07a1                	addi	a5,a5,8
    80001958:	fee6dae3          	bge	a3,a4,8000194c <erase+0x30>
    8000195c:	a8a5                	j	800019d4 <erase+0xb8>
      break;
    }
  }

  // Check if the process was not found in the queue
  if (indexOfProcess == -1)
    8000195e:	57fd                	li	a5,-1
    80001960:	06f70a63          	beq	a4,a5,800019d4 <erase+0xb8>
    // If not found, exit the function early
    return;
  }

  // Shift all processes in the queue down to overwrite the removed process
  for (int i = indexOfProcess; i < mlfq[priorNum].last; i++)
    80001964:	02d75e63          	bge	a4,a3,800019a0 <erase+0x84>
    80001968:	00659613          	slli	a2,a1,0x6
    8000196c:	962e                	add	a2,a2,a1
    8000196e:	963a                	add	a2,a2,a4
    80001970:	00361793          	slli	a5,a2,0x3
    80001974:	0000f817          	auipc	a6,0xf
    80001978:	62c80813          	addi	a6,a6,1580 # 80010fa0 <mlfq>
    8000197c:	97c2                	add	a5,a5,a6
    8000197e:	36fd                	addiw	a3,a3,-1
    80001980:	40e6873b          	subw	a4,a3,a4
    80001984:	1702                	slli	a4,a4,0x20
    80001986:	9301                	srli	a4,a4,0x20
    80001988:	9732                	add	a4,a4,a2
    8000198a:	070e                	slli	a4,a4,0x3
    8000198c:	0000f697          	auipc	a3,0xf
    80001990:	61c68693          	addi	a3,a3,1564 # 80010fa8 <mlfq+0x8>
    80001994:	9736                	add	a4,a4,a3
  {
    mlfq[priorNum].procs[i] = mlfq[priorNum].procs[i + 1];
    80001996:	6794                	ld	a3,8(a5)
    80001998:	e394                	sd	a3,0(a5)
  for (int i = indexOfProcess; i < mlfq[priorNum].last; i++)
    8000199a:	07a1                	addi	a5,a5,8
    8000199c:	fee79de3          	bne	a5,a4,80001996 <erase+0x7a>
  }

  // Mark the process as not queued
  p->queued = 0;
    800019a0:	02052023          	sw	zero,32(a0)
  // Set the last process in the queue to null after the shift
  mlfq[priorNum].procs[mlfq[priorNum].last] = (void *)0;
    800019a4:	0000f717          	auipc	a4,0xf
    800019a8:	5fc70713          	addi	a4,a4,1532 # 80010fa0 <mlfq>
    800019ac:	00659793          	slli	a5,a1,0x6
    800019b0:	00b786b3          	add	a3,a5,a1
    800019b4:	068e                	slli	a3,a3,0x3
    800019b6:	96ba                	add	a3,a3,a4
    800019b8:	2006a683          	lw	a3,512(a3)
    800019bc:	95be                	add	a1,a1,a5
    800019be:	00d587b3          	add	a5,a1,a3
    800019c2:	078e                	slli	a5,a5,0x3
    800019c4:	97ba                	add	a5,a5,a4
    800019c6:	0007b023          	sd	zero,0(a5)
  // Decrement the index of the last process in the priority queue
  mlfq[priorNum].last--;
    800019ca:	058e                	slli	a1,a1,0x3
    800019cc:	95ba                	add	a1,a1,a4
    800019ce:	36fd                	addiw	a3,a3,-1
    800019d0:	20d5a023          	sw	a3,512(a1) # 4000200 <_entry-0x7bfffe00>
}
    800019d4:	6422                	ld	s0,8(sp)
    800019d6:	0141                	addi	sp,sp,16
    800019d8:	8082                	ret

00000000800019da <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800019da:	7139                	addi	sp,sp,-64
    800019dc:	fc06                	sd	ra,56(sp)
    800019de:	f822                	sd	s0,48(sp)
    800019e0:	f426                	sd	s1,40(sp)
    800019e2:	f04a                	sd	s2,32(sp)
    800019e4:	ec4e                	sd	s3,24(sp)
    800019e6:	e852                	sd	s4,16(sp)
    800019e8:	e456                	sd	s5,8(sp)
    800019ea:	e05a                	sd	s6,0(sp)
    800019ec:	0080                	addi	s0,sp,64
    800019ee:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019f0:	00010497          	auipc	s1,0x10
    800019f4:	dd048493          	addi	s1,s1,-560 # 800117c0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800019f8:	8b26                	mv	s6,s1
    800019fa:	00006a97          	auipc	s5,0x6
    800019fe:	606a8a93          	addi	s5,s5,1542 # 80008000 <etext>
    80001a02:	04000937          	lui	s2,0x4000
    80001a06:	197d                	addi	s2,s2,-1
    80001a08:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a0a:	00016a17          	auipc	s4,0x16
    80001a0e:	5b6a0a13          	addi	s4,s4,1462 # 80017fc0 <tickslock>
    char *pa = kalloc();
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	0d4080e7          	jalr	212(ra) # 80000ae6 <kalloc>
    80001a1a:	862a                	mv	a2,a0
    if (pa == 0)
    80001a1c:	c131                	beqz	a0,80001a60 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001a1e:	416485b3          	sub	a1,s1,s6
    80001a22:	8595                	srai	a1,a1,0x5
    80001a24:	000ab783          	ld	a5,0(s5)
    80001a28:	02f585b3          	mul	a1,a1,a5
    80001a2c:	2585                	addiw	a1,a1,1
    80001a2e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a32:	4719                	li	a4,6
    80001a34:	6685                	lui	a3,0x1
    80001a36:	40b905b3          	sub	a1,s2,a1
    80001a3a:	854e                	mv	a0,s3
    80001a3c:	fffff097          	auipc	ra,0xfffff
    80001a40:	70a080e7          	jalr	1802(ra) # 80001146 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a44:	1a048493          	addi	s1,s1,416
    80001a48:	fd4495e3          	bne	s1,s4,80001a12 <proc_mapstacks+0x38>
  }
}
    80001a4c:	70e2                	ld	ra,56(sp)
    80001a4e:	7442                	ld	s0,48(sp)
    80001a50:	74a2                	ld	s1,40(sp)
    80001a52:	7902                	ld	s2,32(sp)
    80001a54:	69e2                	ld	s3,24(sp)
    80001a56:	6a42                	ld	s4,16(sp)
    80001a58:	6aa2                	ld	s5,8(sp)
    80001a5a:	6b02                	ld	s6,0(sp)
    80001a5c:	6121                	addi	sp,sp,64
    80001a5e:	8082                	ret
      panic("kalloc");
    80001a60:	00006517          	auipc	a0,0x6
    80001a64:	77850513          	addi	a0,a0,1912 # 800081d8 <digits+0x198>
    80001a68:	fffff097          	auipc	ra,0xfffff
    80001a6c:	ad6080e7          	jalr	-1322(ra) # 8000053e <panic>

0000000080001a70 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a70:	7139                	addi	sp,sp,-64
    80001a72:	fc06                	sd	ra,56(sp)
    80001a74:	f822                	sd	s0,48(sp)
    80001a76:	f426                	sd	s1,40(sp)
    80001a78:	f04a                	sd	s2,32(sp)
    80001a7a:	ec4e                	sd	s3,24(sp)
    80001a7c:	e852                	sd	s4,16(sp)
    80001a7e:	e456                	sd	s5,8(sp)
    80001a80:	e05a                	sd	s6,0(sp)
    80001a82:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a84:	00006597          	auipc	a1,0x6
    80001a88:	75c58593          	addi	a1,a1,1884 # 800081e0 <digits+0x1a0>
    80001a8c:	0000f517          	auipc	a0,0xf
    80001a90:	0e450513          	addi	a0,a0,228 # 80010b70 <pid_lock>
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	0b2080e7          	jalr	178(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a9c:	00006597          	auipc	a1,0x6
    80001aa0:	74c58593          	addi	a1,a1,1868 # 800081e8 <digits+0x1a8>
    80001aa4:	0000f517          	auipc	a0,0xf
    80001aa8:	0e450513          	addi	a0,a0,228 # 80010b88 <wait_lock>
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	09a080e7          	jalr	154(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ab4:	00010497          	auipc	s1,0x10
    80001ab8:	d0c48493          	addi	s1,s1,-756 # 800117c0 <proc>
  {
    initlock(&p->lock, "proc");
    80001abc:	00006b17          	auipc	s6,0x6
    80001ac0:	73cb0b13          	addi	s6,s6,1852 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001ac4:	8aa6                	mv	s5,s1
    80001ac6:	00006a17          	auipc	s4,0x6
    80001aca:	53aa0a13          	addi	s4,s4,1338 # 80008000 <etext>
    80001ace:	04000937          	lui	s2,0x4000
    80001ad2:	197d                	addi	s2,s2,-1
    80001ad4:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001ad6:	00016997          	auipc	s3,0x16
    80001ada:	4ea98993          	addi	s3,s3,1258 # 80017fc0 <tickslock>
    initlock(&p->lock, "proc");
    80001ade:	85da                	mv	a1,s6
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	064080e7          	jalr	100(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001aea:	0204a623          	sw	zero,44(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001aee:	415487b3          	sub	a5,s1,s5
    80001af2:	8795                	srai	a5,a5,0x5
    80001af4:	000a3703          	ld	a4,0(s4)
    80001af8:	02e787b3          	mul	a5,a5,a4
    80001afc:	2785                	addiw	a5,a5,1
    80001afe:	00d7979b          	slliw	a5,a5,0xd
    80001b02:	40f907b3          	sub	a5,s2,a5
    80001b06:	e8bc                	sd	a5,80(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001b08:	1a048493          	addi	s1,s1,416
    80001b0c:	fd3499e3          	bne	s1,s3,80001ade <procinit+0x6e>
  }
}
    80001b10:	70e2                	ld	ra,56(sp)
    80001b12:	7442                	ld	s0,48(sp)
    80001b14:	74a2                	ld	s1,40(sp)
    80001b16:	7902                	ld	s2,32(sp)
    80001b18:	69e2                	ld	s3,24(sp)
    80001b1a:	6a42                	ld	s4,16(sp)
    80001b1c:	6aa2                	ld	s5,8(sp)
    80001b1e:	6b02                	ld	s6,0(sp)
    80001b20:	6121                	addi	sp,sp,64
    80001b22:	8082                	ret

0000000080001b24 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001b24:	1141                	addi	sp,sp,-16
    80001b26:	e422                	sd	s0,8(sp)
    80001b28:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b2a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b2c:	2501                	sext.w	a0,a0
    80001b2e:	6422                	ld	s0,8(sp)
    80001b30:	0141                	addi	sp,sp,16
    80001b32:	8082                	ret

0000000080001b34 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b34:	1141                	addi	sp,sp,-16
    80001b36:	e422                	sd	s0,8(sp)
    80001b38:	0800                	addi	s0,sp,16
    80001b3a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b3c:	2781                	sext.w	a5,a5
    80001b3e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b40:	0000f517          	auipc	a0,0xf
    80001b44:	06050513          	addi	a0,a0,96 # 80010ba0 <cpus>
    80001b48:	953e                	add	a0,a0,a5
    80001b4a:	6422                	ld	s0,8(sp)
    80001b4c:	0141                	addi	sp,sp,16
    80001b4e:	8082                	ret

0000000080001b50 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	1000                	addi	s0,sp,32
  push_off();
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	030080e7          	jalr	48(ra) # 80000b8a <push_off>
    80001b62:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b64:	2781                	sext.w	a5,a5
    80001b66:	079e                	slli	a5,a5,0x7
    80001b68:	0000f717          	auipc	a4,0xf
    80001b6c:	00870713          	addi	a4,a4,8 # 80010b70 <pid_lock>
    80001b70:	97ba                	add	a5,a5,a4
    80001b72:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	0b6080e7          	jalr	182(ra) # 80000c2a <pop_off>
  return p;
}
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b88:	1141                	addi	sp,sp,-16
    80001b8a:	e406                	sd	ra,8(sp)
    80001b8c:	e022                	sd	s0,0(sp)
    80001b8e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	fc0080e7          	jalr	-64(ra) # 80001b50 <myproc>
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	0f2080e7          	jalr	242(ra) # 80000c8a <release>

  if (first)
    80001ba0:	00007797          	auipc	a5,0x7
    80001ba4:	cd07a783          	lw	a5,-816(a5) # 80008870 <first.1>
    80001ba8:	eb89                	bnez	a5,80001bba <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001baa:	00001097          	auipc	ra,0x1
    80001bae:	f3e080e7          	jalr	-194(ra) # 80002ae8 <usertrapret>
}
    80001bb2:	60a2                	ld	ra,8(sp)
    80001bb4:	6402                	ld	s0,0(sp)
    80001bb6:	0141                	addi	sp,sp,16
    80001bb8:	8082                	ret
    first = 0;
    80001bba:	00007797          	auipc	a5,0x7
    80001bbe:	ca07ab23          	sw	zero,-842(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001bc2:	4505                	li	a0,1
    80001bc4:	00002097          	auipc	ra,0x2
    80001bc8:	f3e080e7          	jalr	-194(ra) # 80003b02 <fsinit>
    80001bcc:	bff9                	j	80001baa <forkret+0x22>

0000000080001bce <allocpid>:
{
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	e04a                	sd	s2,0(sp)
    80001bd8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bda:	0000f917          	auipc	s2,0xf
    80001bde:	f9690913          	addi	s2,s2,-106 # 80010b70 <pid_lock>
    80001be2:	854a                	mv	a0,s2
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	ff2080e7          	jalr	-14(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001bec:	00007797          	auipc	a5,0x7
    80001bf0:	c8878793          	addi	a5,a5,-888 # 80008874 <nextpid>
    80001bf4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bf6:	0014871b          	addiw	a4,s1,1
    80001bfa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bfc:	854a                	mv	a0,s2
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	08c080e7          	jalr	140(ra) # 80000c8a <release>
}
    80001c06:	8526                	mv	a0,s1
    80001c08:	60e2                	ld	ra,24(sp)
    80001c0a:	6442                	ld	s0,16(sp)
    80001c0c:	64a2                	ld	s1,8(sp)
    80001c0e:	6902                	ld	s2,0(sp)
    80001c10:	6105                	addi	sp,sp,32
    80001c12:	8082                	ret

0000000080001c14 <proc_pagetable>:
{
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	e04a                	sd	s2,0(sp)
    80001c1e:	1000                	addi	s0,sp,32
    80001c20:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	70e080e7          	jalr	1806(ra) # 80001330 <uvmcreate>
    80001c2a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001c2c:	c121                	beqz	a0,80001c6c <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c2e:	4729                	li	a4,10
    80001c30:	00005697          	auipc	a3,0x5
    80001c34:	3d068693          	addi	a3,a3,976 # 80007000 <_trampoline>
    80001c38:	6605                	lui	a2,0x1
    80001c3a:	040005b7          	lui	a1,0x4000
    80001c3e:	15fd                	addi	a1,a1,-1
    80001c40:	05b2                	slli	a1,a1,0xc
    80001c42:	fffff097          	auipc	ra,0xfffff
    80001c46:	464080e7          	jalr	1124(ra) # 800010a6 <mappages>
    80001c4a:	02054863          	bltz	a0,80001c7a <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c4e:	4719                	li	a4,6
    80001c50:	06893683          	ld	a3,104(s2)
    80001c54:	6605                	lui	a2,0x1
    80001c56:	020005b7          	lui	a1,0x2000
    80001c5a:	15fd                	addi	a1,a1,-1
    80001c5c:	05b6                	slli	a1,a1,0xd
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	446080e7          	jalr	1094(ra) # 800010a6 <mappages>
    80001c68:	02054163          	bltz	a0,80001c8a <proc_pagetable+0x76>
}
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	60e2                	ld	ra,24(sp)
    80001c70:	6442                	ld	s0,16(sp)
    80001c72:	64a2                	ld	s1,8(sp)
    80001c74:	6902                	ld	s2,0(sp)
    80001c76:	6105                	addi	sp,sp,32
    80001c78:	8082                	ret
    uvmfree(pagetable, 0);
    80001c7a:	4581                	li	a1,0
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	00000097          	auipc	ra,0x0
    80001c82:	8b6080e7          	jalr	-1866(ra) # 80001534 <uvmfree>
    return 0;
    80001c86:	4481                	li	s1,0
    80001c88:	b7d5                	j	80001c6c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c8a:	4681                	li	a3,0
    80001c8c:	4605                	li	a2,1
    80001c8e:	040005b7          	lui	a1,0x4000
    80001c92:	15fd                	addi	a1,a1,-1
    80001c94:	05b2                	slli	a1,a1,0xc
    80001c96:	8526                	mv	a0,s1
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	5d4080e7          	jalr	1492(ra) # 8000126c <uvmunmap>
    uvmfree(pagetable, 0);
    80001ca0:	4581                	li	a1,0
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	00000097          	auipc	ra,0x0
    80001ca8:	890080e7          	jalr	-1904(ra) # 80001534 <uvmfree>
    return 0;
    80001cac:	4481                	li	s1,0
    80001cae:	bf7d                	j	80001c6c <proc_pagetable+0x58>

0000000080001cb0 <proc_freepagetable>:
{
    80001cb0:	1101                	addi	sp,sp,-32
    80001cb2:	ec06                	sd	ra,24(sp)
    80001cb4:	e822                	sd	s0,16(sp)
    80001cb6:	e426                	sd	s1,8(sp)
    80001cb8:	e04a                	sd	s2,0(sp)
    80001cba:	1000                	addi	s0,sp,32
    80001cbc:	84aa                	mv	s1,a0
    80001cbe:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cc0:	4681                	li	a3,0
    80001cc2:	4605                	li	a2,1
    80001cc4:	040005b7          	lui	a1,0x4000
    80001cc8:	15fd                	addi	a1,a1,-1
    80001cca:	05b2                	slli	a1,a1,0xc
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	5a0080e7          	jalr	1440(ra) # 8000126c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cd4:	4681                	li	a3,0
    80001cd6:	4605                	li	a2,1
    80001cd8:	020005b7          	lui	a1,0x2000
    80001cdc:	15fd                	addi	a1,a1,-1
    80001cde:	05b6                	slli	a1,a1,0xd
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	58a080e7          	jalr	1418(ra) # 8000126c <uvmunmap>
  uvmfree(pagetable, sz);
    80001cea:	85ca                	mv	a1,s2
    80001cec:	8526                	mv	a0,s1
    80001cee:	00000097          	auipc	ra,0x0
    80001cf2:	846080e7          	jalr	-1978(ra) # 80001534 <uvmfree>
}
    80001cf6:	60e2                	ld	ra,24(sp)
    80001cf8:	6442                	ld	s0,16(sp)
    80001cfa:	64a2                	ld	s1,8(sp)
    80001cfc:	6902                	ld	s2,0(sp)
    80001cfe:	6105                	addi	sp,sp,32
    80001d00:	8082                	ret

0000000080001d02 <freeproc>:
{
    80001d02:	1101                	addi	sp,sp,-32
    80001d04:	ec06                	sd	ra,24(sp)
    80001d06:	e822                	sd	s0,16(sp)
    80001d08:	e426                	sd	s1,8(sp)
    80001d0a:	1000                	addi	s0,sp,32
    80001d0c:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001d0e:	7528                	ld	a0,104(a0)
    80001d10:	c509                	beqz	a0,80001d1a <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	cd8080e7          	jalr	-808(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001d1a:	0604b423          	sd	zero,104(s1)
  if (p->pagetable)
    80001d1e:	70a8                	ld	a0,96(s1)
    80001d20:	c511                	beqz	a0,80001d2c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d22:	6cac                	ld	a1,88(s1)
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	f8c080e7          	jalr	-116(ra) # 80001cb0 <proc_freepagetable>
  p->pagetable = 0;
    80001d2c:	0604b023          	sd	zero,96(s1)
  p->sz = 0;
    80001d30:	0404bc23          	sd	zero,88(s1)
  p->pid = 0;
    80001d34:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001d38:	0404b423          	sd	zero,72(s1)
  p->name[0] = 0;
    80001d3c:	16048423          	sb	zero,360(s1)
  p->chan = 0;
    80001d40:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001d44:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001d48:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001d4c:	0204a623          	sw	zero,44(s1)
}
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6105                	addi	sp,sp,32
    80001d58:	8082                	ret

0000000080001d5a <allocproc>:
{
    80001d5a:	1101                	addi	sp,sp,-32
    80001d5c:	ec06                	sd	ra,24(sp)
    80001d5e:	e822                	sd	s0,16(sp)
    80001d60:	e426                	sd	s1,8(sp)
    80001d62:	e04a                	sd	s2,0(sp)
    80001d64:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001d66:	00010497          	auipc	s1,0x10
    80001d6a:	a5a48493          	addi	s1,s1,-1446 # 800117c0 <proc>
    80001d6e:	00016917          	auipc	s2,0x16
    80001d72:	25290913          	addi	s2,s2,594 # 80017fc0 <tickslock>
    acquire(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	e5e080e7          	jalr	-418(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001d80:	54dc                	lw	a5,44(s1)
    80001d82:	cf81                	beqz	a5,80001d9a <allocproc+0x40>
      release(&p->lock);
    80001d84:	8526                	mv	a0,s1
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	f04080e7          	jalr	-252(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d8e:	1a048493          	addi	s1,s1,416
    80001d92:	ff2492e3          	bne	s1,s2,80001d76 <allocproc+0x1c>
  return 0;
    80001d96:	4481                	li	s1,0
    80001d98:	a859                	j	80001e2e <allocproc+0xd4>
  p->pid = allocpid();
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	e34080e7          	jalr	-460(ra) # 80001bce <allocpid>
    80001da2:	c0a8                	sw	a0,64(s1)
  p->state = USED;
    80001da4:	4785                	li	a5,1
    80001da6:	d4dc                	sw	a5,44(s1)
  p->readcount = 0;
    80001da8:	1804a223          	sw	zero,388(s1)
  p->handler = 0;
    80001dac:	1804a423          	sw	zero,392(s1)
  p->interval = 0;
    80001db0:	1804a623          	sw	zero,396(s1)
  p->tickscurrently = 0;
    80001db4:	1804a823          	sw	zero,400(s1)
  p->signalstatus = 0;
    80001db8:	1804aa23          	sw	zero,404(s1)
  p->trapframealarm = 0;
    80001dbc:	1804bc23          	sd	zero,408(s1)
  p->priority = 0;
    80001dc0:	0004ac23          	sw	zero,24(s1)
  p->queueEnteredAt = ticks;
    80001dc4:	00007717          	auipc	a4,0x7
    80001dc8:	b3c72703          	lw	a4,-1220(a4) # 80008900 <ticks>
    80001dcc:	ccd8                	sw	a4,28(s1)
  p->queued = 0;
    80001dce:	0204a023          	sw	zero,32(s1)
  p->timeToNextQueue = 1;
    80001dd2:	d0dc                	sw	a5,36(s1)
  p->timeInQueue = 0;
    80001dd4:	0204a423          	sw	zero,40(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	d0e080e7          	jalr	-754(ra) # 80000ae6 <kalloc>
    80001de0:	892a                	mv	s2,a0
    80001de2:	f4a8                	sd	a0,104(s1)
    80001de4:	cd21                	beqz	a0,80001e3c <allocproc+0xe2>
  p->pagetable = proc_pagetable(p);
    80001de6:	8526                	mv	a0,s1
    80001de8:	00000097          	auipc	ra,0x0
    80001dec:	e2c080e7          	jalr	-468(ra) # 80001c14 <proc_pagetable>
    80001df0:	892a                	mv	s2,a0
    80001df2:	f0a8                	sd	a0,96(s1)
  if (p->pagetable == 0)
    80001df4:	c125                	beqz	a0,80001e54 <allocproc+0xfa>
  memset(&p->context, 0, sizeof(p->context));
    80001df6:	07000613          	li	a2,112
    80001dfa:	4581                	li	a1,0
    80001dfc:	07048513          	addi	a0,s1,112
    80001e00:	fffff097          	auipc	ra,0xfffff
    80001e04:	ed2080e7          	jalr	-302(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001e08:	00000797          	auipc	a5,0x0
    80001e0c:	d8078793          	addi	a5,a5,-640 # 80001b88 <forkret>
    80001e10:	f8bc                	sd	a5,112(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e12:	68bc                	ld	a5,80(s1)
    80001e14:	6705                	lui	a4,0x1
    80001e16:	97ba                	add	a5,a5,a4
    80001e18:	fcbc                	sd	a5,120(s1)
  p->rtime = 0;
    80001e1a:	1604ac23          	sw	zero,376(s1)
  p->etime = 0;
    80001e1e:	1804a023          	sw	zero,384(s1)
  p->ctime = ticks;
    80001e22:	00007797          	auipc	a5,0x7
    80001e26:	ade7a783          	lw	a5,-1314(a5) # 80008900 <ticks>
    80001e2a:	16f4ae23          	sw	a5,380(s1)
}
    80001e2e:	8526                	mv	a0,s1
    80001e30:	60e2                	ld	ra,24(sp)
    80001e32:	6442                	ld	s0,16(sp)
    80001e34:	64a2                	ld	s1,8(sp)
    80001e36:	6902                	ld	s2,0(sp)
    80001e38:	6105                	addi	sp,sp,32
    80001e3a:	8082                	ret
    freeproc(p);
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	00000097          	auipc	ra,0x0
    80001e42:	ec4080e7          	jalr	-316(ra) # 80001d02 <freeproc>
    release(&p->lock);
    80001e46:	8526                	mv	a0,s1
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	e42080e7          	jalr	-446(ra) # 80000c8a <release>
    return 0;
    80001e50:	84ca                	mv	s1,s2
    80001e52:	bff1                	j	80001e2e <allocproc+0xd4>
    freeproc(p);
    80001e54:	8526                	mv	a0,s1
    80001e56:	00000097          	auipc	ra,0x0
    80001e5a:	eac080e7          	jalr	-340(ra) # 80001d02 <freeproc>
    release(&p->lock);
    80001e5e:	8526                	mv	a0,s1
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	e2a080e7          	jalr	-470(ra) # 80000c8a <release>
    return 0;
    80001e68:	84ca                	mv	s1,s2
    80001e6a:	b7d1                	j	80001e2e <allocproc+0xd4>

0000000080001e6c <userinit>:
{
    80001e6c:	1101                	addi	sp,sp,-32
    80001e6e:	ec06                	sd	ra,24(sp)
    80001e70:	e822                	sd	s0,16(sp)
    80001e72:	e426                	sd	s1,8(sp)
    80001e74:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e76:	00000097          	auipc	ra,0x0
    80001e7a:	ee4080e7          	jalr	-284(ra) # 80001d5a <allocproc>
    80001e7e:	84aa                	mv	s1,a0
  initproc = p;
    80001e80:	00007797          	auipc	a5,0x7
    80001e84:	a6a7bc23          	sd	a0,-1416(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e88:	03400613          	li	a2,52
    80001e8c:	00007597          	auipc	a1,0x7
    80001e90:	9f458593          	addi	a1,a1,-1548 # 80008880 <initcode>
    80001e94:	7128                	ld	a0,96(a0)
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	4c8080e7          	jalr	1224(ra) # 8000135e <uvmfirst>
  p->sz = PGSIZE;
    80001e9e:	6785                	lui	a5,0x1
    80001ea0:	ecbc                	sd	a5,88(s1)
  p->trapframe->epc = 0;     // user program counter
    80001ea2:	74b8                	ld	a4,104(s1)
    80001ea4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001ea8:	74b8                	ld	a4,104(s1)
    80001eaa:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001eac:	4641                	li	a2,16
    80001eae:	00006597          	auipc	a1,0x6
    80001eb2:	35258593          	addi	a1,a1,850 # 80008200 <digits+0x1c0>
    80001eb6:	16848513          	addi	a0,s1,360
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	f62080e7          	jalr	-158(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001ec2:	00006517          	auipc	a0,0x6
    80001ec6:	34e50513          	addi	a0,a0,846 # 80008210 <digits+0x1d0>
    80001eca:	00002097          	auipc	ra,0x2
    80001ece:	65a080e7          	jalr	1626(ra) # 80004524 <namei>
    80001ed2:	16a4b023          	sd	a0,352(s1)
  p->state = RUNNABLE;
    80001ed6:	478d                	li	a5,3
    80001ed8:	d4dc                	sw	a5,44(s1)
  release(&p->lock);
    80001eda:	8526                	mv	a0,s1
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	dae080e7          	jalr	-594(ra) # 80000c8a <release>
}
    80001ee4:	60e2                	ld	ra,24(sp)
    80001ee6:	6442                	ld	s0,16(sp)
    80001ee8:	64a2                	ld	s1,8(sp)
    80001eea:	6105                	addi	sp,sp,32
    80001eec:	8082                	ret

0000000080001eee <growproc>:
{
    80001eee:	1101                	addi	sp,sp,-32
    80001ef0:	ec06                	sd	ra,24(sp)
    80001ef2:	e822                	sd	s0,16(sp)
    80001ef4:	e426                	sd	s1,8(sp)
    80001ef6:	e04a                	sd	s2,0(sp)
    80001ef8:	1000                	addi	s0,sp,32
    80001efa:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	c54080e7          	jalr	-940(ra) # 80001b50 <myproc>
    80001f04:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f06:	6d2c                	ld	a1,88(a0)
  if (n > 0)
    80001f08:	01204c63          	bgtz	s2,80001f20 <growproc+0x32>
  else if (n < 0)
    80001f0c:	02094663          	bltz	s2,80001f38 <growproc+0x4a>
  p->sz = sz;
    80001f10:	ecac                	sd	a1,88(s1)
  return 0;
    80001f12:	4501                	li	a0,0
}
    80001f14:	60e2                	ld	ra,24(sp)
    80001f16:	6442                	ld	s0,16(sp)
    80001f18:	64a2                	ld	s1,8(sp)
    80001f1a:	6902                	ld	s2,0(sp)
    80001f1c:	6105                	addi	sp,sp,32
    80001f1e:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f20:	4691                	li	a3,4
    80001f22:	00b90633          	add	a2,s2,a1
    80001f26:	7128                	ld	a0,96(a0)
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	4f0080e7          	jalr	1264(ra) # 80001418 <uvmalloc>
    80001f30:	85aa                	mv	a1,a0
    80001f32:	fd79                	bnez	a0,80001f10 <growproc+0x22>
      return -1;
    80001f34:	557d                	li	a0,-1
    80001f36:	bff9                	j	80001f14 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f38:	00b90633          	add	a2,s2,a1
    80001f3c:	7128                	ld	a0,96(a0)
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	492080e7          	jalr	1170(ra) # 800013d0 <uvmdealloc>
    80001f46:	85aa                	mv	a1,a0
    80001f48:	b7e1                	j	80001f10 <growproc+0x22>

0000000080001f4a <fork>:
{
    80001f4a:	7139                	addi	sp,sp,-64
    80001f4c:	fc06                	sd	ra,56(sp)
    80001f4e:	f822                	sd	s0,48(sp)
    80001f50:	f426                	sd	s1,40(sp)
    80001f52:	f04a                	sd	s2,32(sp)
    80001f54:	ec4e                	sd	s3,24(sp)
    80001f56:	e852                	sd	s4,16(sp)
    80001f58:	e456                	sd	s5,8(sp)
    80001f5a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f5c:	00000097          	auipc	ra,0x0
    80001f60:	bf4080e7          	jalr	-1036(ra) # 80001b50 <myproc>
    80001f64:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001f66:	00000097          	auipc	ra,0x0
    80001f6a:	df4080e7          	jalr	-524(ra) # 80001d5a <allocproc>
    80001f6e:	10050c63          	beqz	a0,80002086 <fork+0x13c>
    80001f72:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001f74:	058ab603          	ld	a2,88(s5)
    80001f78:	712c                	ld	a1,96(a0)
    80001f7a:	060ab503          	ld	a0,96(s5)
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	5ee080e7          	jalr	1518(ra) # 8000156c <uvmcopy>
    80001f86:	04054863          	bltz	a0,80001fd6 <fork+0x8c>
  np->sz = p->sz;
    80001f8a:	058ab783          	ld	a5,88(s5)
    80001f8e:	04fa3c23          	sd	a5,88(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f92:	068ab683          	ld	a3,104(s5)
    80001f96:	87b6                	mv	a5,a3
    80001f98:	068a3703          	ld	a4,104(s4)
    80001f9c:	12068693          	addi	a3,a3,288
    80001fa0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001fa4:	6788                	ld	a0,8(a5)
    80001fa6:	6b8c                	ld	a1,16(a5)
    80001fa8:	6f90                	ld	a2,24(a5)
    80001faa:	01073023          	sd	a6,0(a4)
    80001fae:	e708                	sd	a0,8(a4)
    80001fb0:	eb0c                	sd	a1,16(a4)
    80001fb2:	ef10                	sd	a2,24(a4)
    80001fb4:	02078793          	addi	a5,a5,32
    80001fb8:	02070713          	addi	a4,a4,32
    80001fbc:	fed792e3          	bne	a5,a3,80001fa0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001fc0:	068a3783          	ld	a5,104(s4)
    80001fc4:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001fc8:	0e0a8493          	addi	s1,s5,224
    80001fcc:	0e0a0913          	addi	s2,s4,224
    80001fd0:	160a8993          	addi	s3,s5,352
    80001fd4:	a00d                	j	80001ff6 <fork+0xac>
    freeproc(np);
    80001fd6:	8552                	mv	a0,s4
    80001fd8:	00000097          	auipc	ra,0x0
    80001fdc:	d2a080e7          	jalr	-726(ra) # 80001d02 <freeproc>
    release(&np->lock);
    80001fe0:	8552                	mv	a0,s4
    80001fe2:	fffff097          	auipc	ra,0xfffff
    80001fe6:	ca8080e7          	jalr	-856(ra) # 80000c8a <release>
    return -1;
    80001fea:	597d                	li	s2,-1
    80001fec:	a059                	j	80002072 <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001fee:	04a1                	addi	s1,s1,8
    80001ff0:	0921                	addi	s2,s2,8
    80001ff2:	01348b63          	beq	s1,s3,80002008 <fork+0xbe>
    if (p->ofile[i])
    80001ff6:	6088                	ld	a0,0(s1)
    80001ff8:	d97d                	beqz	a0,80001fee <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ffa:	00003097          	auipc	ra,0x3
    80001ffe:	bc0080e7          	jalr	-1088(ra) # 80004bba <filedup>
    80002002:	00a93023          	sd	a0,0(s2)
    80002006:	b7e5                	j	80001fee <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002008:	160ab503          	ld	a0,352(s5)
    8000200c:	00002097          	auipc	ra,0x2
    80002010:	d34080e7          	jalr	-716(ra) # 80003d40 <idup>
    80002014:	16aa3023          	sd	a0,352(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002018:	4641                	li	a2,16
    8000201a:	168a8593          	addi	a1,s5,360
    8000201e:	168a0513          	addi	a0,s4,360
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	dfa080e7          	jalr	-518(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    8000202a:	040a2903          	lw	s2,64(s4)
  release(&np->lock);
    8000202e:	8552                	mv	a0,s4
    80002030:	fffff097          	auipc	ra,0xfffff
    80002034:	c5a080e7          	jalr	-934(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80002038:	0000f497          	auipc	s1,0xf
    8000203c:	b5048493          	addi	s1,s1,-1200 # 80010b88 <wait_lock>
    80002040:	8526                	mv	a0,s1
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	b94080e7          	jalr	-1132(ra) # 80000bd6 <acquire>
  np->parent = p;
    8000204a:	055a3423          	sd	s5,72(s4)
  release(&wait_lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	c3a080e7          	jalr	-966(ra) # 80000c8a <release>
  acquire(&np->lock);
    80002058:	8552                	mv	a0,s4
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	b7c080e7          	jalr	-1156(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80002062:	478d                	li	a5,3
    80002064:	02fa2623          	sw	a5,44(s4)
  release(&np->lock);
    80002068:	8552                	mv	a0,s4
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	c20080e7          	jalr	-992(ra) # 80000c8a <release>
}
    80002072:	854a                	mv	a0,s2
    80002074:	70e2                	ld	ra,56(sp)
    80002076:	7442                	ld	s0,48(sp)
    80002078:	74a2                	ld	s1,40(sp)
    8000207a:	7902                	ld	s2,32(sp)
    8000207c:	69e2                	ld	s3,24(sp)
    8000207e:	6a42                	ld	s4,16(sp)
    80002080:	6aa2                	ld	s5,8(sp)
    80002082:	6121                	addi	sp,sp,64
    80002084:	8082                	ret
    return -1;
    80002086:	597d                	li	s2,-1
    80002088:	b7ed                	j	80002072 <fork+0x128>

000000008000208a <scheduler>:
{
    8000208a:	7159                	addi	sp,sp,-112
    8000208c:	f486                	sd	ra,104(sp)
    8000208e:	f0a2                	sd	s0,96(sp)
    80002090:	eca6                	sd	s1,88(sp)
    80002092:	e8ca                	sd	s2,80(sp)
    80002094:	e4ce                	sd	s3,72(sp)
    80002096:	e0d2                	sd	s4,64(sp)
    80002098:	fc56                	sd	s5,56(sp)
    8000209a:	f85a                	sd	s6,48(sp)
    8000209c:	f45e                	sd	s7,40(sp)
    8000209e:	f062                	sd	s8,32(sp)
    800020a0:	ec66                	sd	s9,24(sp)
    800020a2:	e86a                	sd	s10,16(sp)
    800020a4:	e46e                	sd	s11,8(sp)
    800020a6:	1880                	addi	s0,sp,112
    800020a8:	8792                	mv	a5,tp
  int id = r_tp();
    800020aa:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020ac:	00779d93          	slli	s11,a5,0x7
    800020b0:	0000f717          	auipc	a4,0xf
    800020b4:	ac070713          	addi	a4,a4,-1344 # 80010b70 <pid_lock>
    800020b8:	976e                	add	a4,a4,s11
    800020ba:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &nectProcessToRun->context);
    800020be:	0000f717          	auipc	a4,0xf
    800020c2:	aea70713          	addi	a4,a4,-1302 # 80010ba8 <cpus+0x8>
    800020c6:	9dba                	add	s11,s11,a4
      if (p->state == RUNNABLE && ticks - p->queueEnteredAt >= 30 && p->priority > 0)
    800020c8:	00007b97          	auipc	s7,0x7
    800020cc:	838b8b93          	addi	s7,s7,-1992 # 80008900 <ticks>
    800020d0:	4b75                	li	s6,29
    for (p = proc; p < &proc[NPROC]; p++)
    800020d2:	00016997          	auipc	s3,0x16
    800020d6:	eee98993          	addi	s3,s3,-274 # 80017fc0 <tickslock>
      c->proc = nectProcessToRun;
    800020da:	079e                	slli	a5,a5,0x7
    800020dc:	0000fd17          	auipc	s10,0xf
    800020e0:	a94d0d13          	addi	s10,s10,-1388 # 80010b70 <pid_lock>
    800020e4:	9d3e                	add	s10,s10,a5
    800020e6:	a865                	j	8000219e <scheduler+0x114>
      if (p->state == RUNNABLE && !p->queued)
    800020e8:	509c                	lw	a5,32(s1)
    800020ea:	cfa9                	beqz	a5,80002144 <scheduler+0xba>
      release(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	b9c080e7          	jalr	-1124(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020f6:	1a048493          	addi	s1,s1,416
    800020fa:	05348c63          	beq	s1,s3,80002152 <scheduler+0xc8>
      acquire(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	ad6080e7          	jalr	-1322(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE && ticks - p->queueEnteredAt >= 30 && p->priority > 0)
    80002108:	54dc                	lw	a5,44(s1)
    8000210a:	ff2791e3          	bne	a5,s2,800020ec <scheduler+0x62>
    8000210e:	000ba783          	lw	a5,0(s7)
    80002112:	4cd8                	lw	a4,28(s1)
    80002114:	9f99                	subw	a5,a5,a4
    80002116:	fcfb79e3          	bgeu	s6,a5,800020e8 <scheduler+0x5e>
    8000211a:	4c8c                	lw	a1,24(s1)
    8000211c:	fcb056e3          	blez	a1,800020e8 <scheduler+0x5e>
        erase(p, p->priority);
    80002120:	8526                	mv	a0,s1
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	7fa080e7          	jalr	2042(ra) # 8000191c <erase>
        p->priority--;
    8000212a:	4c8c                	lw	a1,24(s1)
    8000212c:	35fd                	addiw	a1,a1,-1
    8000212e:	cc8c                	sw	a1,24(s1)
        push(p, p->priority);
    80002130:	2581                	sext.w	a1,a1
    80002132:	8526                	mv	a0,s1
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	740080e7          	jalr	1856(ra) # 80001874 <push>
      if (p->state == RUNNABLE && !p->queued)
    8000213c:	54dc                	lw	a5,44(s1)
    8000213e:	fb2785e3          	beq	a5,s2,800020e8 <scheduler+0x5e>
    80002142:	b76d                	j	800020ec <scheduler+0x62>
        push(p, p->priority);
    80002144:	4c8c                	lw	a1,24(s1)
    80002146:	8526                	mv	a0,s1
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	72c080e7          	jalr	1836(ra) # 80001874 <push>
    80002150:	bf71                	j	800020ec <scheduler+0x62>
    80002152:	0000fc17          	auipc	s8,0xf
    80002156:	e4ec0c13          	addi	s8,s8,-434 # 80010fa0 <mlfq>
    for (int i = 0; i < 4 && !nectProcessToRun; i++)
    8000215a:	4a81                	li	s5,0
    8000215c:	4c91                	li	s9,4
    8000215e:	a08d                	j	800021c0 <scheduler+0x136>
    80002160:	012a9363          	bne	s5,s2,80002166 <scheduler+0xdc>
    if (nectProcessToRun)
    80002164:	cc95                	beqz	s1,800021a0 <scheduler+0x116>
      nectProcessToRun->state = RUNNING;
    80002166:	4791                	li	a5,4
    80002168:	d4dc                	sw	a5,44(s1)
      nectProcessToRun->timeToNextQueue = priorityTimeValues[nectProcessToRun->priority];
    8000216a:	4c9c                	lw	a5,24(s1)
    8000216c:	00279713          	slli	a4,a5,0x2
    80002170:	00006797          	auipc	a5,0x6
    80002174:	71078793          	addi	a5,a5,1808 # 80008880 <initcode>
    80002178:	97ba                	add	a5,a5,a4
    8000217a:	5f9c                	lw	a5,56(a5)
    8000217c:	d0dc                	sw	a5,36(s1)
      c->proc = nectProcessToRun;
    8000217e:	029d3823          	sd	s1,48(s10)
      swtch(&c->context, &nectProcessToRun->context);
    80002182:	07048593          	addi	a1,s1,112
    80002186:	856e                	mv	a0,s11
    80002188:	00001097          	auipc	ra,0x1
    8000218c:	8b6080e7          	jalr	-1866(ra) # 80002a3e <swtch>
      c->proc = 0;
    80002190:	020d3823          	sd	zero,48(s10)
      release(&nectProcessToRun->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	af4080e7          	jalr	-1292(ra) # 80000c8a <release>
      if (p->state == RUNNABLE && ticks - p->queueEnteredAt >= 30 && p->priority > 0)
    8000219e:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021a4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800021a8:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800021ac:	0000f497          	auipc	s1,0xf
    800021b0:	61448493          	addi	s1,s1,1556 # 800117c0 <proc>
    800021b4:	b7a9                	j	800020fe <scheduler+0x74>
    for (int i = 0; i < 4 && !nectProcessToRun; i++)
    800021b6:	2a85                	addiw	s5,s5,1
    800021b8:	059a8363          	beq	s5,s9,800021fe <scheduler+0x174>
    800021bc:	208c0c13          	addi	s8,s8,520
      while (mlfq[i].last > -1)
    800021c0:	8a62                	mv	s4,s8
    800021c2:	200c2783          	lw	a5,512(s8)
    800021c6:	fe07c8e3          	bltz	a5,800021b6 <scheduler+0x12c>
        p = mlfq[i].procs[0];
    800021ca:	000a3483          	ld	s1,0(s4)
        erase(p, i);
    800021ce:	85d6                	mv	a1,s5
    800021d0:	8526                	mv	a0,s1
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	74a080e7          	jalr	1866(ra) # 8000191c <erase>
        acquire(&p->lock);
    800021da:	8526                	mv	a0,s1
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	9fa080e7          	jalr	-1542(ra) # 80000bd6 <acquire>
        if (p->state == RUNNABLE)
    800021e4:	54dc                	lw	a5,44(s1)
    800021e6:	f7278de3          	beq	a5,s2,80002160 <scheduler+0xd6>
        release(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a9e080e7          	jalr	-1378(ra) # 80000c8a <release>
      while (mlfq[i].last > -1)
    800021f4:	200a2783          	lw	a5,512(s4)
    800021f8:	fc07d9e3          	bgez	a5,800021ca <scheduler+0x140>
    800021fc:	bf6d                	j	800021b6 <scheduler+0x12c>
    for (int i = 0; i < 4 && !nectProcessToRun; i++)
    800021fe:	4481                	li	s1,0
    80002200:	b795                	j	80002164 <scheduler+0xda>

0000000080002202 <sched>:
{
    80002202:	7179                	addi	sp,sp,-48
    80002204:	f406                	sd	ra,40(sp)
    80002206:	f022                	sd	s0,32(sp)
    80002208:	ec26                	sd	s1,24(sp)
    8000220a:	e84a                	sd	s2,16(sp)
    8000220c:	e44e                	sd	s3,8(sp)
    8000220e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002210:	00000097          	auipc	ra,0x0
    80002214:	940080e7          	jalr	-1728(ra) # 80001b50 <myproc>
    80002218:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	942080e7          	jalr	-1726(ra) # 80000b5c <holding>
    80002222:	c93d                	beqz	a0,80002298 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002224:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002226:	2781                	sext.w	a5,a5
    80002228:	079e                	slli	a5,a5,0x7
    8000222a:	0000f717          	auipc	a4,0xf
    8000222e:	94670713          	addi	a4,a4,-1722 # 80010b70 <pid_lock>
    80002232:	97ba                	add	a5,a5,a4
    80002234:	0a87a703          	lw	a4,168(a5)
    80002238:	4785                	li	a5,1
    8000223a:	06f71763          	bne	a4,a5,800022a8 <sched+0xa6>
  if (p->state == RUNNING)
    8000223e:	54d8                	lw	a4,44(s1)
    80002240:	4791                	li	a5,4
    80002242:	06f70b63          	beq	a4,a5,800022b8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002246:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000224a:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000224c:	efb5                	bnez	a5,800022c8 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000224e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002250:	0000f917          	auipc	s2,0xf
    80002254:	92090913          	addi	s2,s2,-1760 # 80010b70 <pid_lock>
    80002258:	2781                	sext.w	a5,a5
    8000225a:	079e                	slli	a5,a5,0x7
    8000225c:	97ca                	add	a5,a5,s2
    8000225e:	0ac7a983          	lw	s3,172(a5)
    80002262:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002264:	2781                	sext.w	a5,a5
    80002266:	079e                	slli	a5,a5,0x7
    80002268:	0000f597          	auipc	a1,0xf
    8000226c:	94058593          	addi	a1,a1,-1728 # 80010ba8 <cpus+0x8>
    80002270:	95be                	add	a1,a1,a5
    80002272:	07048513          	addi	a0,s1,112
    80002276:	00000097          	auipc	ra,0x0
    8000227a:	7c8080e7          	jalr	1992(ra) # 80002a3e <swtch>
    8000227e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002280:	2781                	sext.w	a5,a5
    80002282:	079e                	slli	a5,a5,0x7
    80002284:	97ca                	add	a5,a5,s2
    80002286:	0b37a623          	sw	s3,172(a5)
}
    8000228a:	70a2                	ld	ra,40(sp)
    8000228c:	7402                	ld	s0,32(sp)
    8000228e:	64e2                	ld	s1,24(sp)
    80002290:	6942                	ld	s2,16(sp)
    80002292:	69a2                	ld	s3,8(sp)
    80002294:	6145                	addi	sp,sp,48
    80002296:	8082                	ret
    panic("sched p->lock");
    80002298:	00006517          	auipc	a0,0x6
    8000229c:	f8050513          	addi	a0,a0,-128 # 80008218 <digits+0x1d8>
    800022a0:	ffffe097          	auipc	ra,0xffffe
    800022a4:	29e080e7          	jalr	670(ra) # 8000053e <panic>
    panic("sched locks");
    800022a8:	00006517          	auipc	a0,0x6
    800022ac:	f8050513          	addi	a0,a0,-128 # 80008228 <digits+0x1e8>
    800022b0:	ffffe097          	auipc	ra,0xffffe
    800022b4:	28e080e7          	jalr	654(ra) # 8000053e <panic>
    panic("sched running");
    800022b8:	00006517          	auipc	a0,0x6
    800022bc:	f8050513          	addi	a0,a0,-128 # 80008238 <digits+0x1f8>
    800022c0:	ffffe097          	auipc	ra,0xffffe
    800022c4:	27e080e7          	jalr	638(ra) # 8000053e <panic>
    panic("sched interruptible");
    800022c8:	00006517          	auipc	a0,0x6
    800022cc:	f8050513          	addi	a0,a0,-128 # 80008248 <digits+0x208>
    800022d0:	ffffe097          	auipc	ra,0xffffe
    800022d4:	26e080e7          	jalr	622(ra) # 8000053e <panic>

00000000800022d8 <yield>:
{
    800022d8:	1101                	addi	sp,sp,-32
    800022da:	ec06                	sd	ra,24(sp)
    800022dc:	e822                	sd	s0,16(sp)
    800022de:	e426                	sd	s1,8(sp)
    800022e0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022e2:	00000097          	auipc	ra,0x0
    800022e6:	86e080e7          	jalr	-1938(ra) # 80001b50 <myproc>
    800022ea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	8ea080e7          	jalr	-1814(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800022f4:	478d                	li	a5,3
    800022f6:	d4dc                	sw	a5,44(s1)
  sched();
    800022f8:	00000097          	auipc	ra,0x0
    800022fc:	f0a080e7          	jalr	-246(ra) # 80002202 <sched>
  release(&p->lock);
    80002300:	8526                	mv	a0,s1
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000230a:	60e2                	ld	ra,24(sp)
    8000230c:	6442                	ld	s0,16(sp)
    8000230e:	64a2                	ld	s1,8(sp)
    80002310:	6105                	addi	sp,sp,32
    80002312:	8082                	ret

0000000080002314 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002314:	7179                	addi	sp,sp,-48
    80002316:	f406                	sd	ra,40(sp)
    80002318:	f022                	sd	s0,32(sp)
    8000231a:	ec26                	sd	s1,24(sp)
    8000231c:	e84a                	sd	s2,16(sp)
    8000231e:	e44e                	sd	s3,8(sp)
    80002320:	1800                	addi	s0,sp,48
    80002322:	89aa                	mv	s3,a0
    80002324:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002326:	00000097          	auipc	ra,0x0
    8000232a:	82a080e7          	jalr	-2006(ra) # 80001b50 <myproc>
    8000232e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	8a6080e7          	jalr	-1882(ra) # 80000bd6 <acquire>
  release(lk);
    80002338:	854a                	mv	a0,s2
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	950080e7          	jalr	-1712(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002342:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    80002346:	4789                	li	a5,2
    80002348:	d4dc                	sw	a5,44(s1)

  sched();
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	eb8080e7          	jalr	-328(ra) # 80002202 <sched>

  // Tidy up.
  p->chan = 0;
    80002352:	0204b823          	sd	zero,48(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	932080e7          	jalr	-1742(ra) # 80000c8a <release>
  acquire(lk);
    80002360:	854a                	mv	a0,s2
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	874080e7          	jalr	-1932(ra) # 80000bd6 <acquire>
}
    8000236a:	70a2                	ld	ra,40(sp)
    8000236c:	7402                	ld	s0,32(sp)
    8000236e:	64e2                	ld	s1,24(sp)
    80002370:	6942                	ld	s2,16(sp)
    80002372:	69a2                	ld	s3,8(sp)
    80002374:	6145                	addi	sp,sp,48
    80002376:	8082                	ret

0000000080002378 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002378:	7139                	addi	sp,sp,-64
    8000237a:	fc06                	sd	ra,56(sp)
    8000237c:	f822                	sd	s0,48(sp)
    8000237e:	f426                	sd	s1,40(sp)
    80002380:	f04a                	sd	s2,32(sp)
    80002382:	ec4e                	sd	s3,24(sp)
    80002384:	e852                	sd	s4,16(sp)
    80002386:	e456                	sd	s5,8(sp)
    80002388:	0080                	addi	s0,sp,64
    8000238a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000238c:	0000f497          	auipc	s1,0xf
    80002390:	43448493          	addi	s1,s1,1076 # 800117c0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002394:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002396:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002398:	00016917          	auipc	s2,0x16
    8000239c:	c2890913          	addi	s2,s2,-984 # 80017fc0 <tickslock>
    800023a0:	a811                	j	800023b4 <wakeup+0x3c>
      }
      release(&p->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	8e6080e7          	jalr	-1818(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023ac:	1a048493          	addi	s1,s1,416
    800023b0:	03248663          	beq	s1,s2,800023dc <wakeup+0x64>
    if (p != myproc())
    800023b4:	fffff097          	auipc	ra,0xfffff
    800023b8:	79c080e7          	jalr	1948(ra) # 80001b50 <myproc>
    800023bc:	fea488e3          	beq	s1,a0,800023ac <wakeup+0x34>
      acquire(&p->lock);
    800023c0:	8526                	mv	a0,s1
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	814080e7          	jalr	-2028(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800023ca:	54dc                	lw	a5,44(s1)
    800023cc:	fd379be3          	bne	a5,s3,800023a2 <wakeup+0x2a>
    800023d0:	789c                	ld	a5,48(s1)
    800023d2:	fd4798e3          	bne	a5,s4,800023a2 <wakeup+0x2a>
        p->state = RUNNABLE;
    800023d6:	0354a623          	sw	s5,44(s1)
    800023da:	b7e1                	j	800023a2 <wakeup+0x2a>
    }
  }
}
    800023dc:	70e2                	ld	ra,56(sp)
    800023de:	7442                	ld	s0,48(sp)
    800023e0:	74a2                	ld	s1,40(sp)
    800023e2:	7902                	ld	s2,32(sp)
    800023e4:	69e2                	ld	s3,24(sp)
    800023e6:	6a42                	ld	s4,16(sp)
    800023e8:	6aa2                	ld	s5,8(sp)
    800023ea:	6121                	addi	sp,sp,64
    800023ec:	8082                	ret

00000000800023ee <reparent>:
{
    800023ee:	7179                	addi	sp,sp,-48
    800023f0:	f406                	sd	ra,40(sp)
    800023f2:	f022                	sd	s0,32(sp)
    800023f4:	ec26                	sd	s1,24(sp)
    800023f6:	e84a                	sd	s2,16(sp)
    800023f8:	e44e                	sd	s3,8(sp)
    800023fa:	e052                	sd	s4,0(sp)
    800023fc:	1800                	addi	s0,sp,48
    800023fe:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002400:	0000f497          	auipc	s1,0xf
    80002404:	3c048493          	addi	s1,s1,960 # 800117c0 <proc>
      pp->parent = initproc;
    80002408:	00006a17          	auipc	s4,0x6
    8000240c:	4f0a0a13          	addi	s4,s4,1264 # 800088f8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002410:	00016997          	auipc	s3,0x16
    80002414:	bb098993          	addi	s3,s3,-1104 # 80017fc0 <tickslock>
    80002418:	a029                	j	80002422 <reparent+0x34>
    8000241a:	1a048493          	addi	s1,s1,416
    8000241e:	01348d63          	beq	s1,s3,80002438 <reparent+0x4a>
    if (pp->parent == p)
    80002422:	64bc                	ld	a5,72(s1)
    80002424:	ff279be3          	bne	a5,s2,8000241a <reparent+0x2c>
      pp->parent = initproc;
    80002428:	000a3503          	ld	a0,0(s4)
    8000242c:	e4a8                	sd	a0,72(s1)
      wakeup(initproc);
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	f4a080e7          	jalr	-182(ra) # 80002378 <wakeup>
    80002436:	b7d5                	j	8000241a <reparent+0x2c>
}
    80002438:	70a2                	ld	ra,40(sp)
    8000243a:	7402                	ld	s0,32(sp)
    8000243c:	64e2                	ld	s1,24(sp)
    8000243e:	6942                	ld	s2,16(sp)
    80002440:	69a2                	ld	s3,8(sp)
    80002442:	6a02                	ld	s4,0(sp)
    80002444:	6145                	addi	sp,sp,48
    80002446:	8082                	ret

0000000080002448 <exit>:
{
    80002448:	7179                	addi	sp,sp,-48
    8000244a:	f406                	sd	ra,40(sp)
    8000244c:	f022                	sd	s0,32(sp)
    8000244e:	ec26                	sd	s1,24(sp)
    80002450:	e84a                	sd	s2,16(sp)
    80002452:	e44e                	sd	s3,8(sp)
    80002454:	e052                	sd	s4,0(sp)
    80002456:	1800                	addi	s0,sp,48
    80002458:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	6f6080e7          	jalr	1782(ra) # 80001b50 <myproc>
    80002462:	89aa                	mv	s3,a0
  if (p == initproc)
    80002464:	00006797          	auipc	a5,0x6
    80002468:	4947b783          	ld	a5,1172(a5) # 800088f8 <initproc>
    8000246c:	0e050493          	addi	s1,a0,224
    80002470:	16050913          	addi	s2,a0,352
    80002474:	02a79363          	bne	a5,a0,8000249a <exit+0x52>
    panic("init exiting");
    80002478:	00006517          	auipc	a0,0x6
    8000247c:	de850513          	addi	a0,a0,-536 # 80008260 <digits+0x220>
    80002480:	ffffe097          	auipc	ra,0xffffe
    80002484:	0be080e7          	jalr	190(ra) # 8000053e <panic>
      fileclose(f);
    80002488:	00002097          	auipc	ra,0x2
    8000248c:	784080e7          	jalr	1924(ra) # 80004c0c <fileclose>
      p->ofile[fd] = 0;
    80002490:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002494:	04a1                	addi	s1,s1,8
    80002496:	01248563          	beq	s1,s2,800024a0 <exit+0x58>
    if (p->ofile[fd])
    8000249a:	6088                	ld	a0,0(s1)
    8000249c:	f575                	bnez	a0,80002488 <exit+0x40>
    8000249e:	bfdd                	j	80002494 <exit+0x4c>
  begin_op();
    800024a0:	00002097          	auipc	ra,0x2
    800024a4:	2a0080e7          	jalr	672(ra) # 80004740 <begin_op>
  iput(p->cwd);
    800024a8:	1609b503          	ld	a0,352(s3)
    800024ac:	00002097          	auipc	ra,0x2
    800024b0:	a8c080e7          	jalr	-1396(ra) # 80003f38 <iput>
  end_op();
    800024b4:	00002097          	auipc	ra,0x2
    800024b8:	30c080e7          	jalr	780(ra) # 800047c0 <end_op>
  p->cwd = 0;
    800024bc:	1609b023          	sd	zero,352(s3)
  acquire(&wait_lock);
    800024c0:	0000e497          	auipc	s1,0xe
    800024c4:	6c848493          	addi	s1,s1,1736 # 80010b88 <wait_lock>
    800024c8:	8526                	mv	a0,s1
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	70c080e7          	jalr	1804(ra) # 80000bd6 <acquire>
  reparent(p);
    800024d2:	854e                	mv	a0,s3
    800024d4:	00000097          	auipc	ra,0x0
    800024d8:	f1a080e7          	jalr	-230(ra) # 800023ee <reparent>
  wakeup(p->parent);
    800024dc:	0489b503          	ld	a0,72(s3)
    800024e0:	00000097          	auipc	ra,0x0
    800024e4:	e98080e7          	jalr	-360(ra) # 80002378 <wakeup>
  acquire(&p->lock);
    800024e8:	854e                	mv	a0,s3
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	6ec080e7          	jalr	1772(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800024f2:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800024f6:	4795                	li	a5,5
    800024f8:	02f9a623          	sw	a5,44(s3)
  p->etime = ticks;
    800024fc:	00006797          	auipc	a5,0x6
    80002500:	4047a783          	lw	a5,1028(a5) # 80008900 <ticks>
    80002504:	18f9a023          	sw	a5,384(s3)
  release(&wait_lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	780080e7          	jalr	1920(ra) # 80000c8a <release>
  sched();
    80002512:	00000097          	auipc	ra,0x0
    80002516:	cf0080e7          	jalr	-784(ra) # 80002202 <sched>
  panic("zombie exit");
    8000251a:	00006517          	auipc	a0,0x6
    8000251e:	d5650513          	addi	a0,a0,-682 # 80008270 <digits+0x230>
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	01c080e7          	jalr	28(ra) # 8000053e <panic>

000000008000252a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000252a:	7179                	addi	sp,sp,-48
    8000252c:	f406                	sd	ra,40(sp)
    8000252e:	f022                	sd	s0,32(sp)
    80002530:	ec26                	sd	s1,24(sp)
    80002532:	e84a                	sd	s2,16(sp)
    80002534:	e44e                	sd	s3,8(sp)
    80002536:	1800                	addi	s0,sp,48
    80002538:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000253a:	0000f497          	auipc	s1,0xf
    8000253e:	28648493          	addi	s1,s1,646 # 800117c0 <proc>
    80002542:	00016997          	auipc	s3,0x16
    80002546:	a7e98993          	addi	s3,s3,-1410 # 80017fc0 <tickslock>
  {
    acquire(&p->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	68a080e7          	jalr	1674(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002554:	40bc                	lw	a5,64(s1)
    80002556:	01278d63          	beq	a5,s2,80002570 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	72e080e7          	jalr	1838(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002564:	1a048493          	addi	s1,s1,416
    80002568:	ff3491e3          	bne	s1,s3,8000254a <kill+0x20>
  }
  return -1;
    8000256c:	557d                	li	a0,-1
    8000256e:	a01d                	j	80002594 <kill+0x6a>
      p->killed = 1;
    80002570:	4785                	li	a5,1
    80002572:	dc9c                	sw	a5,56(s1)
      erase(p, p->priority);
    80002574:	4c8c                	lw	a1,24(s1)
    80002576:	8526                	mv	a0,s1
    80002578:	fffff097          	auipc	ra,0xfffff
    8000257c:	3a4080e7          	jalr	932(ra) # 8000191c <erase>
      if (p->state == SLEEPING)
    80002580:	54d8                	lw	a4,44(s1)
    80002582:	4789                	li	a5,2
    80002584:	00f70f63          	beq	a4,a5,800025a2 <kill+0x78>
      release(&p->lock);
    80002588:	8526                	mv	a0,s1
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	700080e7          	jalr	1792(ra) # 80000c8a <release>
      return 0;
    80002592:	4501                	li	a0,0
}
    80002594:	70a2                	ld	ra,40(sp)
    80002596:	7402                	ld	s0,32(sp)
    80002598:	64e2                	ld	s1,24(sp)
    8000259a:	6942                	ld	s2,16(sp)
    8000259c:	69a2                	ld	s3,8(sp)
    8000259e:	6145                	addi	sp,sp,48
    800025a0:	8082                	ret
        p->state = RUNNABLE;
    800025a2:	478d                	li	a5,3
    800025a4:	d4dc                	sw	a5,44(s1)
    800025a6:	b7cd                	j	80002588 <kill+0x5e>

00000000800025a8 <setkilled>:

void setkilled(struct proc *p)
{
    800025a8:	1101                	addi	sp,sp,-32
    800025aa:	ec06                	sd	ra,24(sp)
    800025ac:	e822                	sd	s0,16(sp)
    800025ae:	e426                	sd	s1,8(sp)
    800025b0:	1000                	addi	s0,sp,32
    800025b2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	622080e7          	jalr	1570(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800025bc:	4785                	li	a5,1
    800025be:	dc9c                	sw	a5,56(s1)
  release(&p->lock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	6c8080e7          	jalr	1736(ra) # 80000c8a <release>
}
    800025ca:	60e2                	ld	ra,24(sp)
    800025cc:	6442                	ld	s0,16(sp)
    800025ce:	64a2                	ld	s1,8(sp)
    800025d0:	6105                	addi	sp,sp,32
    800025d2:	8082                	ret

00000000800025d4 <killed>:

int killed(struct proc *p)
{
    800025d4:	1101                	addi	sp,sp,-32
    800025d6:	ec06                	sd	ra,24(sp)
    800025d8:	e822                	sd	s0,16(sp)
    800025da:	e426                	sd	s1,8(sp)
    800025dc:	e04a                	sd	s2,0(sp)
    800025de:	1000                	addi	s0,sp,32
    800025e0:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	5f4080e7          	jalr	1524(ra) # 80000bd6 <acquire>
  k = p->killed;
    800025ea:	0384a903          	lw	s2,56(s1)
  release(&p->lock);
    800025ee:	8526                	mv	a0,s1
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	69a080e7          	jalr	1690(ra) # 80000c8a <release>
  return k;
}
    800025f8:	854a                	mv	a0,s2
    800025fa:	60e2                	ld	ra,24(sp)
    800025fc:	6442                	ld	s0,16(sp)
    800025fe:	64a2                	ld	s1,8(sp)
    80002600:	6902                	ld	s2,0(sp)
    80002602:	6105                	addi	sp,sp,32
    80002604:	8082                	ret

0000000080002606 <wait>:
{
    80002606:	715d                	addi	sp,sp,-80
    80002608:	e486                	sd	ra,72(sp)
    8000260a:	e0a2                	sd	s0,64(sp)
    8000260c:	fc26                	sd	s1,56(sp)
    8000260e:	f84a                	sd	s2,48(sp)
    80002610:	f44e                	sd	s3,40(sp)
    80002612:	f052                	sd	s4,32(sp)
    80002614:	ec56                	sd	s5,24(sp)
    80002616:	e85a                	sd	s6,16(sp)
    80002618:	e45e                	sd	s7,8(sp)
    8000261a:	e062                	sd	s8,0(sp)
    8000261c:	0880                	addi	s0,sp,80
    8000261e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002620:	fffff097          	auipc	ra,0xfffff
    80002624:	530080e7          	jalr	1328(ra) # 80001b50 <myproc>
    80002628:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000262a:	0000e517          	auipc	a0,0xe
    8000262e:	55e50513          	addi	a0,a0,1374 # 80010b88 <wait_lock>
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	5a4080e7          	jalr	1444(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000263a:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    8000263c:	4a15                	li	s4,5
        havekids = 1;
    8000263e:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002640:	00016997          	auipc	s3,0x16
    80002644:	98098993          	addi	s3,s3,-1664 # 80017fc0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002648:	0000ec17          	auipc	s8,0xe
    8000264c:	540c0c13          	addi	s8,s8,1344 # 80010b88 <wait_lock>
    havekids = 0;
    80002650:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002652:	0000f497          	auipc	s1,0xf
    80002656:	16e48493          	addi	s1,s1,366 # 800117c0 <proc>
    8000265a:	a0bd                	j	800026c8 <wait+0xc2>
          pid = pp->pid;
    8000265c:	0404a983          	lw	s3,64(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002660:	000b0e63          	beqz	s6,8000267c <wait+0x76>
    80002664:	4691                	li	a3,4
    80002666:	03c48613          	addi	a2,s1,60
    8000266a:	85da                	mv	a1,s6
    8000266c:	06093503          	ld	a0,96(s2)
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	000080e7          	jalr	ra # 80001670 <copyout>
    80002678:	02054563          	bltz	a0,800026a2 <wait+0x9c>
          freeproc(pp);
    8000267c:	8526                	mv	a0,s1
    8000267e:	fffff097          	auipc	ra,0xfffff
    80002682:	684080e7          	jalr	1668(ra) # 80001d02 <freeproc>
          release(&pp->lock);
    80002686:	8526                	mv	a0,s1
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	602080e7          	jalr	1538(ra) # 80000c8a <release>
          release(&wait_lock);
    80002690:	0000e517          	auipc	a0,0xe
    80002694:	4f850513          	addi	a0,a0,1272 # 80010b88 <wait_lock>
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	5f2080e7          	jalr	1522(ra) # 80000c8a <release>
          return pid;
    800026a0:	a0b5                	j	8000270c <wait+0x106>
            release(&pp->lock);
    800026a2:	8526                	mv	a0,s1
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	5e6080e7          	jalr	1510(ra) # 80000c8a <release>
            release(&wait_lock);
    800026ac:	0000e517          	auipc	a0,0xe
    800026b0:	4dc50513          	addi	a0,a0,1244 # 80010b88 <wait_lock>
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	5d6080e7          	jalr	1494(ra) # 80000c8a <release>
            return -1;
    800026bc:	59fd                	li	s3,-1
    800026be:	a0b9                	j	8000270c <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800026c0:	1a048493          	addi	s1,s1,416
    800026c4:	03348463          	beq	s1,s3,800026ec <wait+0xe6>
      if (pp->parent == p)
    800026c8:	64bc                	ld	a5,72(s1)
    800026ca:	ff279be3          	bne	a5,s2,800026c0 <wait+0xba>
        acquire(&pp->lock);
    800026ce:	8526                	mv	a0,s1
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	506080e7          	jalr	1286(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    800026d8:	54dc                	lw	a5,44(s1)
    800026da:	f94781e3          	beq	a5,s4,8000265c <wait+0x56>
        release(&pp->lock);
    800026de:	8526                	mv	a0,s1
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	5aa080e7          	jalr	1450(ra) # 80000c8a <release>
        havekids = 1;
    800026e8:	8756                	mv	a4,s5
    800026ea:	bfd9                	j	800026c0 <wait+0xba>
    if (!havekids || killed(p))
    800026ec:	c719                	beqz	a4,800026fa <wait+0xf4>
    800026ee:	854a                	mv	a0,s2
    800026f0:	00000097          	auipc	ra,0x0
    800026f4:	ee4080e7          	jalr	-284(ra) # 800025d4 <killed>
    800026f8:	c51d                	beqz	a0,80002726 <wait+0x120>
      release(&wait_lock);
    800026fa:	0000e517          	auipc	a0,0xe
    800026fe:	48e50513          	addi	a0,a0,1166 # 80010b88 <wait_lock>
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	588080e7          	jalr	1416(ra) # 80000c8a <release>
      return -1;
    8000270a:	59fd                	li	s3,-1
}
    8000270c:	854e                	mv	a0,s3
    8000270e:	60a6                	ld	ra,72(sp)
    80002710:	6406                	ld	s0,64(sp)
    80002712:	74e2                	ld	s1,56(sp)
    80002714:	7942                	ld	s2,48(sp)
    80002716:	79a2                	ld	s3,40(sp)
    80002718:	7a02                	ld	s4,32(sp)
    8000271a:	6ae2                	ld	s5,24(sp)
    8000271c:	6b42                	ld	s6,16(sp)
    8000271e:	6ba2                	ld	s7,8(sp)
    80002720:	6c02                	ld	s8,0(sp)
    80002722:	6161                	addi	sp,sp,80
    80002724:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002726:	85e2                	mv	a1,s8
    80002728:	854a                	mv	a0,s2
    8000272a:	00000097          	auipc	ra,0x0
    8000272e:	bea080e7          	jalr	-1046(ra) # 80002314 <sleep>
    havekids = 0;
    80002732:	bf39                	j	80002650 <wait+0x4a>

0000000080002734 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002734:	7179                	addi	sp,sp,-48
    80002736:	f406                	sd	ra,40(sp)
    80002738:	f022                	sd	s0,32(sp)
    8000273a:	ec26                	sd	s1,24(sp)
    8000273c:	e84a                	sd	s2,16(sp)
    8000273e:	e44e                	sd	s3,8(sp)
    80002740:	e052                	sd	s4,0(sp)
    80002742:	1800                	addi	s0,sp,48
    80002744:	84aa                	mv	s1,a0
    80002746:	892e                	mv	s2,a1
    80002748:	89b2                	mv	s3,a2
    8000274a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000274c:	fffff097          	auipc	ra,0xfffff
    80002750:	404080e7          	jalr	1028(ra) # 80001b50 <myproc>
  if (user_dst)
    80002754:	c08d                	beqz	s1,80002776 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002756:	86d2                	mv	a3,s4
    80002758:	864e                	mv	a2,s3
    8000275a:	85ca                	mv	a1,s2
    8000275c:	7128                	ld	a0,96(a0)
    8000275e:	fffff097          	auipc	ra,0xfffff
    80002762:	f12080e7          	jalr	-238(ra) # 80001670 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002766:	70a2                	ld	ra,40(sp)
    80002768:	7402                	ld	s0,32(sp)
    8000276a:	64e2                	ld	s1,24(sp)
    8000276c:	6942                	ld	s2,16(sp)
    8000276e:	69a2                	ld	s3,8(sp)
    80002770:	6a02                	ld	s4,0(sp)
    80002772:	6145                	addi	sp,sp,48
    80002774:	8082                	ret
    memmove((char *)dst, src, len);
    80002776:	000a061b          	sext.w	a2,s4
    8000277a:	85ce                	mv	a1,s3
    8000277c:	854a                	mv	a0,s2
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	5b0080e7          	jalr	1456(ra) # 80000d2e <memmove>
    return 0;
    80002786:	8526                	mv	a0,s1
    80002788:	bff9                	j	80002766 <either_copyout+0x32>

000000008000278a <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000278a:	7179                	addi	sp,sp,-48
    8000278c:	f406                	sd	ra,40(sp)
    8000278e:	f022                	sd	s0,32(sp)
    80002790:	ec26                	sd	s1,24(sp)
    80002792:	e84a                	sd	s2,16(sp)
    80002794:	e44e                	sd	s3,8(sp)
    80002796:	e052                	sd	s4,0(sp)
    80002798:	1800                	addi	s0,sp,48
    8000279a:	892a                	mv	s2,a0
    8000279c:	84ae                	mv	s1,a1
    8000279e:	89b2                	mv	s3,a2
    800027a0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027a2:	fffff097          	auipc	ra,0xfffff
    800027a6:	3ae080e7          	jalr	942(ra) # 80001b50 <myproc>
  if (user_src)
    800027aa:	c08d                	beqz	s1,800027cc <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800027ac:	86d2                	mv	a3,s4
    800027ae:	864e                	mv	a2,s3
    800027b0:	85ca                	mv	a1,s2
    800027b2:	7128                	ld	a0,96(a0)
    800027b4:	fffff097          	auipc	ra,0xfffff
    800027b8:	f48080e7          	jalr	-184(ra) # 800016fc <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800027bc:	70a2                	ld	ra,40(sp)
    800027be:	7402                	ld	s0,32(sp)
    800027c0:	64e2                	ld	s1,24(sp)
    800027c2:	6942                	ld	s2,16(sp)
    800027c4:	69a2                	ld	s3,8(sp)
    800027c6:	6a02                	ld	s4,0(sp)
    800027c8:	6145                	addi	sp,sp,48
    800027ca:	8082                	ret
    memmove(dst, (char *)src, len);
    800027cc:	000a061b          	sext.w	a2,s4
    800027d0:	85ce                	mv	a1,s3
    800027d2:	854a                	mv	a0,s2
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	55a080e7          	jalr	1370(ra) # 80000d2e <memmove>
    return 0;
    800027dc:	8526                	mv	a0,s1
    800027de:	bff9                	j	800027bc <either_copyin+0x32>

00000000800027e0 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800027e0:	715d                	addi	sp,sp,-80
    800027e2:	e486                	sd	ra,72(sp)
    800027e4:	e0a2                	sd	s0,64(sp)
    800027e6:	fc26                	sd	s1,56(sp)
    800027e8:	f84a                	sd	s2,48(sp)
    800027ea:	f44e                	sd	s3,40(sp)
    800027ec:	f052                	sd	s4,32(sp)
    800027ee:	ec56                	sd	s5,24(sp)
    800027f0:	e85a                	sd	s6,16(sp)
    800027f2:	e45e                	sd	s7,8(sp)
    800027f4:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800027f6:	00006517          	auipc	a0,0x6
    800027fa:	8d250513          	addi	a0,a0,-1838 # 800080c8 <digits+0x88>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	d8a080e7          	jalr	-630(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002806:	0000f497          	auipc	s1,0xf
    8000280a:	12248493          	addi	s1,s1,290 # 80011928 <proc+0x168>
    8000280e:	00016917          	auipc	s2,0x16
    80002812:	91a90913          	addi	s2,s2,-1766 # 80018128 <bcache+0x150>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002816:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002818:	00006997          	auipc	s3,0x6
    8000281c:	a6898993          	addi	s3,s3,-1432 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002820:	00006a97          	auipc	s5,0x6
    80002824:	a68a8a93          	addi	s5,s5,-1432 # 80008288 <digits+0x248>
    printf("\n");
    80002828:	00006a17          	auipc	s4,0x6
    8000282c:	8a0a0a13          	addi	s4,s4,-1888 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002830:	00006b97          	auipc	s7,0x6
    80002834:	a98b8b93          	addi	s7,s7,-1384 # 800082c8 <states.0>
    80002838:	a00d                	j	8000285a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000283a:	ed86a583          	lw	a1,-296(a3)
    8000283e:	8556                	mv	a0,s5
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	d48080e7          	jalr	-696(ra) # 80000588 <printf>
    printf("\n");
    80002848:	8552                	mv	a0,s4
    8000284a:	ffffe097          	auipc	ra,0xffffe
    8000284e:	d3e080e7          	jalr	-706(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002852:	1a048493          	addi	s1,s1,416
    80002856:	03248163          	beq	s1,s2,80002878 <procdump+0x98>
    if (p->state == UNUSED)
    8000285a:	86a6                	mv	a3,s1
    8000285c:	ec44a783          	lw	a5,-316(s1)
    80002860:	dbed                	beqz	a5,80002852 <procdump+0x72>
      state = "???";
    80002862:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002864:	fcfb6be3          	bltu	s6,a5,8000283a <procdump+0x5a>
    80002868:	1782                	slli	a5,a5,0x20
    8000286a:	9381                	srli	a5,a5,0x20
    8000286c:	078e                	slli	a5,a5,0x3
    8000286e:	97de                	add	a5,a5,s7
    80002870:	6390                	ld	a2,0(a5)
    80002872:	f661                	bnez	a2,8000283a <procdump+0x5a>
      state = "???";
    80002874:	864e                	mv	a2,s3
    80002876:	b7d1                	j	8000283a <procdump+0x5a>
  }
}
    80002878:	60a6                	ld	ra,72(sp)
    8000287a:	6406                	ld	s0,64(sp)
    8000287c:	74e2                	ld	s1,56(sp)
    8000287e:	7942                	ld	s2,48(sp)
    80002880:	79a2                	ld	s3,40(sp)
    80002882:	7a02                	ld	s4,32(sp)
    80002884:	6ae2                	ld	s5,24(sp)
    80002886:	6b42                	ld	s6,16(sp)
    80002888:	6ba2                	ld	s7,8(sp)
    8000288a:	6161                	addi	sp,sp,80
    8000288c:	8082                	ret

000000008000288e <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    8000288e:	711d                	addi	sp,sp,-96
    80002890:	ec86                	sd	ra,88(sp)
    80002892:	e8a2                	sd	s0,80(sp)
    80002894:	e4a6                	sd	s1,72(sp)
    80002896:	e0ca                	sd	s2,64(sp)
    80002898:	fc4e                	sd	s3,56(sp)
    8000289a:	f852                	sd	s4,48(sp)
    8000289c:	f456                	sd	s5,40(sp)
    8000289e:	f05a                	sd	s6,32(sp)
    800028a0:	ec5e                	sd	s7,24(sp)
    800028a2:	e862                	sd	s8,16(sp)
    800028a4:	e466                	sd	s9,8(sp)
    800028a6:	e06a                	sd	s10,0(sp)
    800028a8:	1080                	addi	s0,sp,96
    800028aa:	8b2a                	mv	s6,a0
    800028ac:	8bae                	mv	s7,a1
    800028ae:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800028b0:	fffff097          	auipc	ra,0xfffff
    800028b4:	2a0080e7          	jalr	672(ra) # 80001b50 <myproc>
    800028b8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800028ba:	0000e517          	auipc	a0,0xe
    800028be:	2ce50513          	addi	a0,a0,718 # 80010b88 <wait_lock>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	314080e7          	jalr	788(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800028ca:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800028cc:	4a15                	li	s4,5
        havekids = 1;
    800028ce:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800028d0:	00015997          	auipc	s3,0x15
    800028d4:	6f098993          	addi	s3,s3,1776 # 80017fc0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028d8:	0000ed17          	auipc	s10,0xe
    800028dc:	2b0d0d13          	addi	s10,s10,688 # 80010b88 <wait_lock>
    havekids = 0;
    800028e0:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800028e2:	0000f497          	auipc	s1,0xf
    800028e6:	ede48493          	addi	s1,s1,-290 # 800117c0 <proc>
    800028ea:	a059                	j	80002970 <waitx+0xe2>
          pid = np->pid;
    800028ec:	0404a983          	lw	s3,64(s1)
          *rtime = np->rtime;
    800028f0:	1784a703          	lw	a4,376(s1)
    800028f4:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800028f8:	17c4a783          	lw	a5,380(s1)
    800028fc:	9f3d                	addw	a4,a4,a5
    800028fe:	1804a783          	lw	a5,384(s1)
    80002902:	9f99                	subw	a5,a5,a4
    80002904:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002908:	000b0e63          	beqz	s6,80002924 <waitx+0x96>
    8000290c:	4691                	li	a3,4
    8000290e:	03c48613          	addi	a2,s1,60
    80002912:	85da                	mv	a1,s6
    80002914:	06093503          	ld	a0,96(s2)
    80002918:	fffff097          	auipc	ra,0xfffff
    8000291c:	d58080e7          	jalr	-680(ra) # 80001670 <copyout>
    80002920:	02054563          	bltz	a0,8000294a <waitx+0xbc>
          freeproc(np);
    80002924:	8526                	mv	a0,s1
    80002926:	fffff097          	auipc	ra,0xfffff
    8000292a:	3dc080e7          	jalr	988(ra) # 80001d02 <freeproc>
          release(&np->lock);
    8000292e:	8526                	mv	a0,s1
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	35a080e7          	jalr	858(ra) # 80000c8a <release>
          release(&wait_lock);
    80002938:	0000e517          	auipc	a0,0xe
    8000293c:	25050513          	addi	a0,a0,592 # 80010b88 <wait_lock>
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	34a080e7          	jalr	842(ra) # 80000c8a <release>
          return pid;
    80002948:	a09d                	j	800029ae <waitx+0x120>
            release(&np->lock);
    8000294a:	8526                	mv	a0,s1
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	33e080e7          	jalr	830(ra) # 80000c8a <release>
            release(&wait_lock);
    80002954:	0000e517          	auipc	a0,0xe
    80002958:	23450513          	addi	a0,a0,564 # 80010b88 <wait_lock>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	32e080e7          	jalr	814(ra) # 80000c8a <release>
            return -1;
    80002964:	59fd                	li	s3,-1
    80002966:	a0a1                	j	800029ae <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002968:	1a048493          	addi	s1,s1,416
    8000296c:	03348463          	beq	s1,s3,80002994 <waitx+0x106>
      if (np->parent == p)
    80002970:	64bc                	ld	a5,72(s1)
    80002972:	ff279be3          	bne	a5,s2,80002968 <waitx+0xda>
        acquire(&np->lock);
    80002976:	8526                	mv	a0,s1
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	25e080e7          	jalr	606(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    80002980:	54dc                	lw	a5,44(s1)
    80002982:	f74785e3          	beq	a5,s4,800028ec <waitx+0x5e>
        release(&np->lock);
    80002986:	8526                	mv	a0,s1
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	302080e7          	jalr	770(ra) # 80000c8a <release>
        havekids = 1;
    80002990:	8756                	mv	a4,s5
    80002992:	bfd9                	j	80002968 <waitx+0xda>
    if (!havekids || p->killed)
    80002994:	c701                	beqz	a4,8000299c <waitx+0x10e>
    80002996:	03892783          	lw	a5,56(s2)
    8000299a:	cb8d                	beqz	a5,800029cc <waitx+0x13e>
      release(&wait_lock);
    8000299c:	0000e517          	auipc	a0,0xe
    800029a0:	1ec50513          	addi	a0,a0,492 # 80010b88 <wait_lock>
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	2e6080e7          	jalr	742(ra) # 80000c8a <release>
      return -1;
    800029ac:	59fd                	li	s3,-1
  }
}
    800029ae:	854e                	mv	a0,s3
    800029b0:	60e6                	ld	ra,88(sp)
    800029b2:	6446                	ld	s0,80(sp)
    800029b4:	64a6                	ld	s1,72(sp)
    800029b6:	6906                	ld	s2,64(sp)
    800029b8:	79e2                	ld	s3,56(sp)
    800029ba:	7a42                	ld	s4,48(sp)
    800029bc:	7aa2                	ld	s5,40(sp)
    800029be:	7b02                	ld	s6,32(sp)
    800029c0:	6be2                	ld	s7,24(sp)
    800029c2:	6c42                	ld	s8,16(sp)
    800029c4:	6ca2                	ld	s9,8(sp)
    800029c6:	6d02                	ld	s10,0(sp)
    800029c8:	6125                	addi	sp,sp,96
    800029ca:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800029cc:	85ea                	mv	a1,s10
    800029ce:	854a                	mv	a0,s2
    800029d0:	00000097          	auipc	ra,0x0
    800029d4:	944080e7          	jalr	-1724(ra) # 80002314 <sleep>
    havekids = 0;
    800029d8:	b721                	j	800028e0 <waitx+0x52>

00000000800029da <update_time>:

void update_time()
{
    800029da:	7179                	addi	sp,sp,-48
    800029dc:	f406                	sd	ra,40(sp)
    800029de:	f022                	sd	s0,32(sp)
    800029e0:	ec26                	sd	s1,24(sp)
    800029e2:	e84a                	sd	s2,16(sp)
    800029e4:	e44e                	sd	s3,8(sp)
    800029e6:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800029e8:	0000f497          	auipc	s1,0xf
    800029ec:	dd848493          	addi	s1,s1,-552 # 800117c0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800029f0:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    800029f2:	00015917          	auipc	s2,0x15
    800029f6:	5ce90913          	addi	s2,s2,1486 # 80017fc0 <tickslock>
    800029fa:	a811                	j	80002a0e <update_time+0x34>
    {
      p->rtime++;
      p->timeToNextQueue--;
    }
    release(&p->lock);
    800029fc:	8526                	mv	a0,s1
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	28c080e7          	jalr	652(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a06:	1a048493          	addi	s1,s1,416
    80002a0a:	03248363          	beq	s1,s2,80002a30 <update_time+0x56>
    acquire(&p->lock);
    80002a0e:	8526                	mv	a0,s1
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	1c6080e7          	jalr	454(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002a18:	54dc                	lw	a5,44(s1)
    80002a1a:	ff3791e3          	bne	a5,s3,800029fc <update_time+0x22>
      p->rtime++;
    80002a1e:	1784a783          	lw	a5,376(s1)
    80002a22:	2785                	addiw	a5,a5,1
    80002a24:	16f4ac23          	sw	a5,376(s1)
      p->timeToNextQueue--;
    80002a28:	50dc                	lw	a5,36(s1)
    80002a2a:	37fd                	addiw	a5,a5,-1
    80002a2c:	d0dc                	sw	a5,36(s1)
    80002a2e:	b7f9                	j	800029fc <update_time+0x22>
  }
    80002a30:	70a2                	ld	ra,40(sp)
    80002a32:	7402                	ld	s0,32(sp)
    80002a34:	64e2                	ld	s1,24(sp)
    80002a36:	6942                	ld	s2,16(sp)
    80002a38:	69a2                	ld	s3,8(sp)
    80002a3a:	6145                	addi	sp,sp,48
    80002a3c:	8082                	ret

0000000080002a3e <swtch>:
    80002a3e:	00153023          	sd	ra,0(a0)
    80002a42:	00253423          	sd	sp,8(a0)
    80002a46:	e900                	sd	s0,16(a0)
    80002a48:	ed04                	sd	s1,24(a0)
    80002a4a:	03253023          	sd	s2,32(a0)
    80002a4e:	03353423          	sd	s3,40(a0)
    80002a52:	03453823          	sd	s4,48(a0)
    80002a56:	03553c23          	sd	s5,56(a0)
    80002a5a:	05653023          	sd	s6,64(a0)
    80002a5e:	05753423          	sd	s7,72(a0)
    80002a62:	05853823          	sd	s8,80(a0)
    80002a66:	05953c23          	sd	s9,88(a0)
    80002a6a:	07a53023          	sd	s10,96(a0)
    80002a6e:	07b53423          	sd	s11,104(a0)
    80002a72:	0005b083          	ld	ra,0(a1)
    80002a76:	0085b103          	ld	sp,8(a1)
    80002a7a:	6980                	ld	s0,16(a1)
    80002a7c:	6d84                	ld	s1,24(a1)
    80002a7e:	0205b903          	ld	s2,32(a1)
    80002a82:	0285b983          	ld	s3,40(a1)
    80002a86:	0305ba03          	ld	s4,48(a1)
    80002a8a:	0385ba83          	ld	s5,56(a1)
    80002a8e:	0405bb03          	ld	s6,64(a1)
    80002a92:	0485bb83          	ld	s7,72(a1)
    80002a96:	0505bc03          	ld	s8,80(a1)
    80002a9a:	0585bc83          	ld	s9,88(a1)
    80002a9e:	0605bd03          	ld	s10,96(a1)
    80002aa2:	0685bd83          	ld	s11,104(a1)
    80002aa6:	8082                	ret

0000000080002aa8 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002aa8:	1141                	addi	sp,sp,-16
    80002aaa:	e406                	sd	ra,8(sp)
    80002aac:	e022                	sd	s0,0(sp)
    80002aae:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ab0:	00006597          	auipc	a1,0x6
    80002ab4:	84858593          	addi	a1,a1,-1976 # 800082f8 <states.0+0x30>
    80002ab8:	00015517          	auipc	a0,0x15
    80002abc:	50850513          	addi	a0,a0,1288 # 80017fc0 <tickslock>
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	086080e7          	jalr	134(ra) # 80000b46 <initlock>
}
    80002ac8:	60a2                	ld	ra,8(sp)
    80002aca:	6402                	ld	s0,0(sp)
    80002acc:	0141                	addi	sp,sp,16
    80002ace:	8082                	ret

0000000080002ad0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002ad0:	1141                	addi	sp,sp,-16
    80002ad2:	e422                	sd	s0,8(sp)
    80002ad4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ad6:	00003797          	auipc	a5,0x3
    80002ada:	78a78793          	addi	a5,a5,1930 # 80006260 <kernelvec>
    80002ade:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ae2:	6422                	ld	s0,8(sp)
    80002ae4:	0141                	addi	sp,sp,16
    80002ae6:	8082                	ret

0000000080002ae8 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002ae8:	1141                	addi	sp,sp,-16
    80002aea:	e406                	sd	ra,8(sp)
    80002aec:	e022                	sd	s0,0(sp)
    80002aee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002af0:	fffff097          	auipc	ra,0xfffff
    80002af4:	060080e7          	jalr	96(ra) # 80001b50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002afc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002afe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b02:	00004617          	auipc	a2,0x4
    80002b06:	4fe60613          	addi	a2,a2,1278 # 80007000 <_trampoline>
    80002b0a:	00004697          	auipc	a3,0x4
    80002b0e:	4f668693          	addi	a3,a3,1270 # 80007000 <_trampoline>
    80002b12:	8e91                	sub	a3,a3,a2
    80002b14:	040007b7          	lui	a5,0x4000
    80002b18:	17fd                	addi	a5,a5,-1
    80002b1a:	07b2                	slli	a5,a5,0xc
    80002b1c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b1e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b22:	7538                	ld	a4,104(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b24:	180026f3          	csrr	a3,satp
    80002b28:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b2a:	7538                	ld	a4,104(a0)
    80002b2c:	6934                	ld	a3,80(a0)
    80002b2e:	6585                	lui	a1,0x1
    80002b30:	96ae                	add	a3,a3,a1
    80002b32:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b34:	7538                	ld	a4,104(a0)
    80002b36:	00000697          	auipc	a3,0x0
    80002b3a:	13e68693          	addi	a3,a3,318 # 80002c74 <usertrap>
    80002b3e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002b40:	7538                	ld	a4,104(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b42:	8692                	mv	a3,tp
    80002b44:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b46:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b4a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b4e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b52:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b56:	7538                	ld	a4,104(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b58:	6f18                	ld	a4,24(a4)
    80002b5a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b5e:	7128                	ld	a0,96(a0)
    80002b60:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b62:	00004717          	auipc	a4,0x4
    80002b66:	53a70713          	addi	a4,a4,1338 # 8000709c <userret>
    80002b6a:	8f11                	sub	a4,a4,a2
    80002b6c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b6e:	577d                	li	a4,-1
    80002b70:	177e                	slli	a4,a4,0x3f
    80002b72:	8d59                	or	a0,a0,a4
    80002b74:	9782                	jalr	a5
}
    80002b76:	60a2                	ld	ra,8(sp)
    80002b78:	6402                	ld	s0,0(sp)
    80002b7a:	0141                	addi	sp,sp,16
    80002b7c:	8082                	ret

0000000080002b7e <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002b7e:	1101                	addi	sp,sp,-32
    80002b80:	ec06                	sd	ra,24(sp)
    80002b82:	e822                	sd	s0,16(sp)
    80002b84:	e426                	sd	s1,8(sp)
    80002b86:	e04a                	sd	s2,0(sp)
    80002b88:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b8a:	00015917          	auipc	s2,0x15
    80002b8e:	43690913          	addi	s2,s2,1078 # 80017fc0 <tickslock>
    80002b92:	854a                	mv	a0,s2
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	042080e7          	jalr	66(ra) # 80000bd6 <acquire>
  ticks++;
    80002b9c:	00006497          	auipc	s1,0x6
    80002ba0:	d6448493          	addi	s1,s1,-668 # 80008900 <ticks>
    80002ba4:	409c                	lw	a5,0(s1)
    80002ba6:	2785                	addiw	a5,a5,1
    80002ba8:	c09c                	sw	a5,0(s1)
  update_time();
    80002baa:	00000097          	auipc	ra,0x0
    80002bae:	e30080e7          	jalr	-464(ra) # 800029da <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002bb2:	8526                	mv	a0,s1
    80002bb4:	fffff097          	auipc	ra,0xfffff
    80002bb8:	7c4080e7          	jalr	1988(ra) # 80002378 <wakeup>
  release(&tickslock);
    80002bbc:	854a                	mv	a0,s2
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	0cc080e7          	jalr	204(ra) # 80000c8a <release>
}
    80002bc6:	60e2                	ld	ra,24(sp)
    80002bc8:	6442                	ld	s0,16(sp)
    80002bca:	64a2                	ld	s1,8(sp)
    80002bcc:	6902                	ld	s2,0(sp)
    80002bce:	6105                	addi	sp,sp,32
    80002bd0:	8082                	ret

0000000080002bd2 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002bd2:	1101                	addi	sp,sp,-32
    80002bd4:	ec06                	sd	ra,24(sp)
    80002bd6:	e822                	sd	s0,16(sp)
    80002bd8:	e426                	sd	s1,8(sp)
    80002bda:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bdc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002be0:	00074d63          	bltz	a4,80002bfa <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002be4:	57fd                	li	a5,-1
    80002be6:	17fe                	slli	a5,a5,0x3f
    80002be8:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002bea:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002bec:	06f70363          	beq	a4,a5,80002c52 <devintr+0x80>
  }
}
    80002bf0:	60e2                	ld	ra,24(sp)
    80002bf2:	6442                	ld	s0,16(sp)
    80002bf4:	64a2                	ld	s1,8(sp)
    80002bf6:	6105                	addi	sp,sp,32
    80002bf8:	8082                	ret
      (scause & 0xff) == 9)
    80002bfa:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002bfe:	46a5                	li	a3,9
    80002c00:	fed792e3          	bne	a5,a3,80002be4 <devintr+0x12>
    int irq = plic_claim();
    80002c04:	00003097          	auipc	ra,0x3
    80002c08:	764080e7          	jalr	1892(ra) # 80006368 <plic_claim>
    80002c0c:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002c0e:	47a9                	li	a5,10
    80002c10:	02f50763          	beq	a0,a5,80002c3e <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002c14:	4785                	li	a5,1
    80002c16:	02f50963          	beq	a0,a5,80002c48 <devintr+0x76>
    return 1;
    80002c1a:	4505                	li	a0,1
    else if (irq)
    80002c1c:	d8f1                	beqz	s1,80002bf0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c1e:	85a6                	mv	a1,s1
    80002c20:	00005517          	auipc	a0,0x5
    80002c24:	6e050513          	addi	a0,a0,1760 # 80008300 <states.0+0x38>
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	960080e7          	jalr	-1696(ra) # 80000588 <printf>
      plic_complete(irq);
    80002c30:	8526                	mv	a0,s1
    80002c32:	00003097          	auipc	ra,0x3
    80002c36:	75a080e7          	jalr	1882(ra) # 8000638c <plic_complete>
    return 1;
    80002c3a:	4505                	li	a0,1
    80002c3c:	bf55                	j	80002bf0 <devintr+0x1e>
      uartintr();
    80002c3e:	ffffe097          	auipc	ra,0xffffe
    80002c42:	d5c080e7          	jalr	-676(ra) # 8000099a <uartintr>
    80002c46:	b7ed                	j	80002c30 <devintr+0x5e>
      virtio_disk_intr();
    80002c48:	00004097          	auipc	ra,0x4
    80002c4c:	c10080e7          	jalr	-1008(ra) # 80006858 <virtio_disk_intr>
    80002c50:	b7c5                	j	80002c30 <devintr+0x5e>
    if (cpuid() == 0)
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	ed2080e7          	jalr	-302(ra) # 80001b24 <cpuid>
    80002c5a:	c901                	beqz	a0,80002c6a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c5c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c60:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c62:	14479073          	csrw	sip,a5
    return 2;
    80002c66:	4509                	li	a0,2
    80002c68:	b761                	j	80002bf0 <devintr+0x1e>
      clockintr();
    80002c6a:	00000097          	auipc	ra,0x0
    80002c6e:	f14080e7          	jalr	-236(ra) # 80002b7e <clockintr>
    80002c72:	b7ed                	j	80002c5c <devintr+0x8a>

0000000080002c74 <usertrap>:
{
    80002c74:	1101                	addi	sp,sp,-32
    80002c76:	ec06                	sd	ra,24(sp)
    80002c78:	e822                	sd	s0,16(sp)
    80002c7a:	e426                	sd	s1,8(sp)
    80002c7c:	e04a                	sd	s2,0(sp)
    80002c7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c80:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002c84:	1007f793          	andi	a5,a5,256
    80002c88:	e3b1                	bnez	a5,80002ccc <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c8a:	00003797          	auipc	a5,0x3
    80002c8e:	5d678793          	addi	a5,a5,1494 # 80006260 <kernelvec>
    80002c92:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	eba080e7          	jalr	-326(ra) # 80001b50 <myproc>
    80002c9e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ca0:	753c                	ld	a5,104(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ca2:	14102773          	csrr	a4,sepc
    80002ca6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca8:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002cac:	47a1                	li	a5,8
    80002cae:	02f70763          	beq	a4,a5,80002cdc <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	f20080e7          	jalr	-224(ra) # 80002bd2 <devintr>
    80002cba:	892a                	mv	s2,a0
    80002cbc:	c151                	beqz	a0,80002d40 <usertrap+0xcc>
  if (killed(p))
    80002cbe:	8526                	mv	a0,s1
    80002cc0:	00000097          	auipc	ra,0x0
    80002cc4:	914080e7          	jalr	-1772(ra) # 800025d4 <killed>
    80002cc8:	c929                	beqz	a0,80002d1a <usertrap+0xa6>
    80002cca:	a099                	j	80002d10 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ccc:	00005517          	auipc	a0,0x5
    80002cd0:	65450513          	addi	a0,a0,1620 # 80008320 <states.0+0x58>
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	86a080e7          	jalr	-1942(ra) # 8000053e <panic>
    if (killed(p))
    80002cdc:	00000097          	auipc	ra,0x0
    80002ce0:	8f8080e7          	jalr	-1800(ra) # 800025d4 <killed>
    80002ce4:	e921                	bnez	a0,80002d34 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002ce6:	74b8                	ld	a4,104(s1)
    80002ce8:	6f1c                	ld	a5,24(a4)
    80002cea:	0791                	addi	a5,a5,4
    80002cec:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cf2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cf6:	10079073          	csrw	sstatus,a5
    syscall();
    80002cfa:	00000097          	auipc	ra,0x0
    80002cfe:	404080e7          	jalr	1028(ra) # 800030fe <syscall>
  if (killed(p))
    80002d02:	8526                	mv	a0,s1
    80002d04:	00000097          	auipc	ra,0x0
    80002d08:	8d0080e7          	jalr	-1840(ra) # 800025d4 <killed>
    80002d0c:	c911                	beqz	a0,80002d20 <usertrap+0xac>
    80002d0e:	4901                	li	s2,0
    exit(-1);
    80002d10:	557d                	li	a0,-1
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	736080e7          	jalr	1846(ra) # 80002448 <exit>
  if (which_dev == 2)
    80002d1a:	4789                	li	a5,2
    80002d1c:	04f90f63          	beq	s2,a5,80002d7a <usertrap+0x106>
  usertrapret();
    80002d20:	00000097          	auipc	ra,0x0
    80002d24:	dc8080e7          	jalr	-568(ra) # 80002ae8 <usertrapret>
}
    80002d28:	60e2                	ld	ra,24(sp)
    80002d2a:	6442                	ld	s0,16(sp)
    80002d2c:	64a2                	ld	s1,8(sp)
    80002d2e:	6902                	ld	s2,0(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret
      exit(-1);
    80002d34:	557d                	li	a0,-1
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	712080e7          	jalr	1810(ra) # 80002448 <exit>
    80002d3e:	b765                	j	80002ce6 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d40:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d44:	40b0                	lw	a2,64(s1)
    80002d46:	00005517          	auipc	a0,0x5
    80002d4a:	5fa50513          	addi	a0,a0,1530 # 80008340 <states.0+0x78>
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	83a080e7          	jalr	-1990(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d56:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d5a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d5e:	00005517          	auipc	a0,0x5
    80002d62:	61250513          	addi	a0,a0,1554 # 80008370 <states.0+0xa8>
    80002d66:	ffffe097          	auipc	ra,0xffffe
    80002d6a:	822080e7          	jalr	-2014(ra) # 80000588 <printf>
    setkilled(p);
    80002d6e:	8526                	mv	a0,s1
    80002d70:	00000097          	auipc	ra,0x0
    80002d74:	838080e7          	jalr	-1992(ra) # 800025a8 <setkilled>
    80002d78:	b769                	j	80002d02 <usertrap+0x8e>
    struct cpu *c = mycpu();
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	dba080e7          	jalr	-582(ra) # 80001b34 <mycpu>
    80002d82:	892a                	mv	s2,a0
    printf("%d ", c->proc->priority);
    80002d84:	611c                	ld	a5,0(a0)
    80002d86:	4f8c                	lw	a1,24(a5)
    80002d88:	00005517          	auipc	a0,0x5
    80002d8c:	60850513          	addi	a0,a0,1544 # 80008390 <states.0+0xc8>
    80002d90:	ffffd097          	auipc	ra,0xffffd
    80002d94:	7f8080e7          	jalr	2040(ra) # 80000588 <printf>
    printf("%d %d \n", c->proc->ctime, c->proc->pid);
    80002d98:	00093783          	ld	a5,0(s2)
    80002d9c:	43b0                	lw	a2,64(a5)
    80002d9e:	17c7a583          	lw	a1,380(a5)
    80002da2:	00005517          	auipc	a0,0x5
    80002da6:	5f650513          	addi	a0,a0,1526 # 80008398 <states.0+0xd0>
    80002daa:	ffffd097          	auipc	ra,0xffffd
    80002dae:	7de080e7          	jalr	2014(ra) # 80000588 <printf>
    if (p->interval > 0)
    80002db2:	18c4a783          	lw	a5,396(s1)
    80002db6:	00f05e63          	blez	a5,80002dd2 <usertrap+0x15e>
      if (p->signalstatus == 0)
    80002dba:	1944a703          	lw	a4,404(s1)
    80002dbe:	eb11                	bnez	a4,80002dd2 <usertrap+0x15e>
        p->tickscurrently += 1;
    80002dc0:	1904a703          	lw	a4,400(s1)
    80002dc4:	2705                	addiw	a4,a4,1
    80002dc6:	0007069b          	sext.w	a3,a4
        if (p->interval <= p->tickscurrently)
    80002dca:	04f6da63          	bge	a3,a5,80002e1e <usertrap+0x1aa>
        p->tickscurrently += 1;
    80002dce:	18e4a823          	sw	a4,400(s1)
    for (int i = 0; i < p->priority; i++)
    80002dd2:	4c8c                	lw	a1,24(s1)
    80002dd4:	02b05c63          	blez	a1,80002e0c <usertrap+0x198>
    80002dd8:	0000e797          	auipc	a5,0xe
    80002ddc:	3c878793          	addi	a5,a5,968 # 800111a0 <mlfq+0x200>
    80002de0:	fff5869b          	addiw	a3,a1,-1
    80002de4:	02069713          	slli	a4,a3,0x20
    80002de8:	9301                	srli	a4,a4,0x20
    80002dea:	00671693          	slli	a3,a4,0x6
    80002dee:	96ba                	add	a3,a3,a4
    80002df0:	068e                	slli	a3,a3,0x3
    80002df2:	0000e717          	auipc	a4,0xe
    80002df6:	5b670713          	addi	a4,a4,1462 # 800113a8 <mlfq+0x408>
    80002dfa:	96ba                	add	a3,a3,a4
      if (mlfq[i].last != -1)
    80002dfc:	567d                	li	a2,-1
    80002dfe:	4398                	lw	a4,0(a5)
    80002e00:	04c71563          	bne	a4,a2,80002e4a <usertrap+0x1d6>
    for (int i = 0; i < p->priority; i++)
    80002e04:	20878793          	addi	a5,a5,520
    80002e08:	fed79be3          	bne	a5,a3,80002dfe <usertrap+0x18a>
    if (p->timeToNextQueue <= 0)
    80002e0c:	50dc                	lw	a5,36(s1)
    80002e0e:	f0f049e3          	bgtz	a5,80002d20 <usertrap+0xac>
      if (p->priority < 3)
    80002e12:	4789                	li	a5,2
    80002e14:	02b7ce63          	blt	a5,a1,80002e50 <usertrap+0x1dc>
        p->priority++;
    80002e18:	2585                	addiw	a1,a1,1
    80002e1a:	cc8c                	sw	a1,24(s1)
    80002e1c:	a815                	j	80002e50 <usertrap+0x1dc>
          p->tickscurrently = 0;
    80002e1e:	1804a823          	sw	zero,400(s1)
          p->signalstatus = 1;
    80002e22:	4785                	li	a5,1
    80002e24:	18f4aa23          	sw	a5,404(s1)
          p->trapframealarm = kalloc();
    80002e28:	ffffe097          	auipc	ra,0xffffe
    80002e2c:	cbe080e7          	jalr	-834(ra) # 80000ae6 <kalloc>
    80002e30:	18a4bc23          	sd	a0,408(s1)
          memmove(p->trapframealarm, p->trapframe, PGSIZE);
    80002e34:	6605                	lui	a2,0x1
    80002e36:	74ac                	ld	a1,104(s1)
    80002e38:	ffffe097          	auipc	ra,0xffffe
    80002e3c:	ef6080e7          	jalr	-266(ra) # 80000d2e <memmove>
          p->trapframe->epc = p->handler;
    80002e40:	74bc                	ld	a5,104(s1)
    80002e42:	1884e703          	lwu	a4,392(s1)
    80002e46:	ef98                	sd	a4,24(a5)
    80002e48:	b769                	j	80002dd2 <usertrap+0x15e>
    if (p->timeToNextQueue <= 0)
    80002e4a:	50dc                	lw	a5,36(s1)
    80002e4c:	fcf053e3          	blez	a5,80002e12 <usertrap+0x19e>
      yield();
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	488080e7          	jalr	1160(ra) # 800022d8 <yield>
    80002e58:	b5e1                	j	80002d20 <usertrap+0xac>

0000000080002e5a <kerneltrap>:
{
    80002e5a:	7179                	addi	sp,sp,-48
    80002e5c:	f406                	sd	ra,40(sp)
    80002e5e:	f022                	sd	s0,32(sp)
    80002e60:	ec26                	sd	s1,24(sp)
    80002e62:	e84a                	sd	s2,16(sp)
    80002e64:	e44e                	sd	s3,8(sp)
    80002e66:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e68:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e6c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e70:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002e74:	1004f793          	andi	a5,s1,256
    80002e78:	cb85                	beqz	a5,80002ea8 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e7a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e7e:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002e80:	ef85                	bnez	a5,80002eb8 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002e82:	00000097          	auipc	ra,0x0
    80002e86:	d50080e7          	jalr	-688(ra) # 80002bd2 <devintr>
    80002e8a:	cd1d                	beqz	a0,80002ec8 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e8c:	4789                	li	a5,2
    80002e8e:	06f50a63          	beq	a0,a5,80002f02 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e92:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e96:	10049073          	csrw	sstatus,s1
}
    80002e9a:	70a2                	ld	ra,40(sp)
    80002e9c:	7402                	ld	s0,32(sp)
    80002e9e:	64e2                	ld	s1,24(sp)
    80002ea0:	6942                	ld	s2,16(sp)
    80002ea2:	69a2                	ld	s3,8(sp)
    80002ea4:	6145                	addi	sp,sp,48
    80002ea6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ea8:	00005517          	auipc	a0,0x5
    80002eac:	4f850513          	addi	a0,a0,1272 # 800083a0 <states.0+0xd8>
    80002eb0:	ffffd097          	auipc	ra,0xffffd
    80002eb4:	68e080e7          	jalr	1678(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002eb8:	00005517          	auipc	a0,0x5
    80002ebc:	51050513          	addi	a0,a0,1296 # 800083c8 <states.0+0x100>
    80002ec0:	ffffd097          	auipc	ra,0xffffd
    80002ec4:	67e080e7          	jalr	1662(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002ec8:	85ce                	mv	a1,s3
    80002eca:	00005517          	auipc	a0,0x5
    80002ece:	51e50513          	addi	a0,a0,1310 # 800083e8 <states.0+0x120>
    80002ed2:	ffffd097          	auipc	ra,0xffffd
    80002ed6:	6b6080e7          	jalr	1718(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002eda:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ede:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ee2:	00005517          	auipc	a0,0x5
    80002ee6:	51650513          	addi	a0,a0,1302 # 800083f8 <states.0+0x130>
    80002eea:	ffffd097          	auipc	ra,0xffffd
    80002eee:	69e080e7          	jalr	1694(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002ef2:	00005517          	auipc	a0,0x5
    80002ef6:	51e50513          	addi	a0,a0,1310 # 80008410 <states.0+0x148>
    80002efa:	ffffd097          	auipc	ra,0xffffd
    80002efe:	644080e7          	jalr	1604(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f02:	fffff097          	auipc	ra,0xfffff
    80002f06:	c4e080e7          	jalr	-946(ra) # 80001b50 <myproc>
    80002f0a:	d541                	beqz	a0,80002e92 <kerneltrap+0x38>
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	c44080e7          	jalr	-956(ra) # 80001b50 <myproc>
    80002f14:	5558                	lw	a4,44(a0)
    80002f16:	4791                	li	a5,4
    80002f18:	f6f71de3          	bne	a4,a5,80002e92 <kerneltrap+0x38>
    struct proc *p = myproc();
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	c34080e7          	jalr	-972(ra) # 80001b50 <myproc>
    for (int i = 0; i < p->priority; i++)
    80002f24:	4d0c                	lw	a1,24(a0)
    80002f26:	02b05c63          	blez	a1,80002f5e <kerneltrap+0x104>
    80002f2a:	0000e797          	auipc	a5,0xe
    80002f2e:	27678793          	addi	a5,a5,630 # 800111a0 <mlfq+0x200>
    80002f32:	fff5869b          	addiw	a3,a1,-1
    80002f36:	02069713          	slli	a4,a3,0x20
    80002f3a:	9301                	srli	a4,a4,0x20
    80002f3c:	00671693          	slli	a3,a4,0x6
    80002f40:	96ba                	add	a3,a3,a4
    80002f42:	068e                	slli	a3,a3,0x3
    80002f44:	0000e717          	auipc	a4,0xe
    80002f48:	46470713          	addi	a4,a4,1124 # 800113a8 <mlfq+0x408>
    80002f4c:	96ba                	add	a3,a3,a4
      if (mlfq[i].last != -1)
    80002f4e:	567d                	li	a2,-1
    80002f50:	4398                	lw	a4,0(a5)
    80002f52:	00c71f63          	bne	a4,a2,80002f70 <kerneltrap+0x116>
    for (int i = 0; i < p->priority; i++)
    80002f56:	20878793          	addi	a5,a5,520
    80002f5a:	fed79be3          	bne	a5,a3,80002f50 <kerneltrap+0xf6>
    if (p->timeToNextQueue <= 0)
    80002f5e:	515c                	lw	a5,36(a0)
    80002f60:	f2f049e3          	bgtz	a5,80002e92 <kerneltrap+0x38>
      if (p->priority < 3)
    80002f64:	4789                	li	a5,2
    80002f66:	00b7c863          	blt	a5,a1,80002f76 <kerneltrap+0x11c>
        p->priority++;
    80002f6a:	2585                	addiw	a1,a1,1
    80002f6c:	cd0c                	sw	a1,24(a0)
    80002f6e:	a021                	j	80002f76 <kerneltrap+0x11c>
    if (p->timeToNextQueue <= 0)
    80002f70:	515c                	lw	a5,36(a0)
    80002f72:	fef059e3          	blez	a5,80002f64 <kerneltrap+0x10a>
      yield();
    80002f76:	fffff097          	auipc	ra,0xfffff
    80002f7a:	362080e7          	jalr	866(ra) # 800022d8 <yield>
    80002f7e:	bf11                	j	80002e92 <kerneltrap+0x38>

0000000080002f80 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f80:	1101                	addi	sp,sp,-32
    80002f82:	ec06                	sd	ra,24(sp)
    80002f84:	e822                	sd	s0,16(sp)
    80002f86:	e426                	sd	s1,8(sp)
    80002f88:	1000                	addi	s0,sp,32
    80002f8a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f8c:	fffff097          	auipc	ra,0xfffff
    80002f90:	bc4080e7          	jalr	-1084(ra) # 80001b50 <myproc>
  switch (n) {
    80002f94:	4795                	li	a5,5
    80002f96:	0497e163          	bltu	a5,s1,80002fd8 <argraw+0x58>
    80002f9a:	048a                	slli	s1,s1,0x2
    80002f9c:	00005717          	auipc	a4,0x5
    80002fa0:	4ac70713          	addi	a4,a4,1196 # 80008448 <states.0+0x180>
    80002fa4:	94ba                	add	s1,s1,a4
    80002fa6:	409c                	lw	a5,0(s1)
    80002fa8:	97ba                	add	a5,a5,a4
    80002faa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002fac:	753c                	ld	a5,104(a0)
    80002fae:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002fb0:	60e2                	ld	ra,24(sp)
    80002fb2:	6442                	ld	s0,16(sp)
    80002fb4:	64a2                	ld	s1,8(sp)
    80002fb6:	6105                	addi	sp,sp,32
    80002fb8:	8082                	ret
    return p->trapframe->a1;
    80002fba:	753c                	ld	a5,104(a0)
    80002fbc:	7fa8                	ld	a0,120(a5)
    80002fbe:	bfcd                	j	80002fb0 <argraw+0x30>
    return p->trapframe->a2;
    80002fc0:	753c                	ld	a5,104(a0)
    80002fc2:	63c8                	ld	a0,128(a5)
    80002fc4:	b7f5                	j	80002fb0 <argraw+0x30>
    return p->trapframe->a3;
    80002fc6:	753c                	ld	a5,104(a0)
    80002fc8:	67c8                	ld	a0,136(a5)
    80002fca:	b7dd                	j	80002fb0 <argraw+0x30>
    return p->trapframe->a4;
    80002fcc:	753c                	ld	a5,104(a0)
    80002fce:	6bc8                	ld	a0,144(a5)
    80002fd0:	b7c5                	j	80002fb0 <argraw+0x30>
    return p->trapframe->a5;
    80002fd2:	753c                	ld	a5,104(a0)
    80002fd4:	6fc8                	ld	a0,152(a5)
    80002fd6:	bfe9                	j	80002fb0 <argraw+0x30>
  panic("argraw");
    80002fd8:	00005517          	auipc	a0,0x5
    80002fdc:	44850513          	addi	a0,a0,1096 # 80008420 <states.0+0x158>
    80002fe0:	ffffd097          	auipc	ra,0xffffd
    80002fe4:	55e080e7          	jalr	1374(ra) # 8000053e <panic>

0000000080002fe8 <fetchaddr>:
{
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	e426                	sd	s1,8(sp)
    80002ff0:	e04a                	sd	s2,0(sp)
    80002ff2:	1000                	addi	s0,sp,32
    80002ff4:	84aa                	mv	s1,a0
    80002ff6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ff8:	fffff097          	auipc	ra,0xfffff
    80002ffc:	b58080e7          	jalr	-1192(ra) # 80001b50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003000:	6d3c                	ld	a5,88(a0)
    80003002:	02f4f863          	bgeu	s1,a5,80003032 <fetchaddr+0x4a>
    80003006:	00848713          	addi	a4,s1,8
    8000300a:	02e7e663          	bltu	a5,a4,80003036 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000300e:	46a1                	li	a3,8
    80003010:	8626                	mv	a2,s1
    80003012:	85ca                	mv	a1,s2
    80003014:	7128                	ld	a0,96(a0)
    80003016:	ffffe097          	auipc	ra,0xffffe
    8000301a:	6e6080e7          	jalr	1766(ra) # 800016fc <copyin>
    8000301e:	00a03533          	snez	a0,a0
    80003022:	40a00533          	neg	a0,a0
}
    80003026:	60e2                	ld	ra,24(sp)
    80003028:	6442                	ld	s0,16(sp)
    8000302a:	64a2                	ld	s1,8(sp)
    8000302c:	6902                	ld	s2,0(sp)
    8000302e:	6105                	addi	sp,sp,32
    80003030:	8082                	ret
    return -1;
    80003032:	557d                	li	a0,-1
    80003034:	bfcd                	j	80003026 <fetchaddr+0x3e>
    80003036:	557d                	li	a0,-1
    80003038:	b7fd                	j	80003026 <fetchaddr+0x3e>

000000008000303a <fetchstr>:
{
    8000303a:	7179                	addi	sp,sp,-48
    8000303c:	f406                	sd	ra,40(sp)
    8000303e:	f022                	sd	s0,32(sp)
    80003040:	ec26                	sd	s1,24(sp)
    80003042:	e84a                	sd	s2,16(sp)
    80003044:	e44e                	sd	s3,8(sp)
    80003046:	1800                	addi	s0,sp,48
    80003048:	892a                	mv	s2,a0
    8000304a:	84ae                	mv	s1,a1
    8000304c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000304e:	fffff097          	auipc	ra,0xfffff
    80003052:	b02080e7          	jalr	-1278(ra) # 80001b50 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003056:	86ce                	mv	a3,s3
    80003058:	864a                	mv	a2,s2
    8000305a:	85a6                	mv	a1,s1
    8000305c:	7128                	ld	a0,96(a0)
    8000305e:	ffffe097          	auipc	ra,0xffffe
    80003062:	72c080e7          	jalr	1836(ra) # 8000178a <copyinstr>
    80003066:	00054e63          	bltz	a0,80003082 <fetchstr+0x48>
  return strlen(buf);
    8000306a:	8526                	mv	a0,s1
    8000306c:	ffffe097          	auipc	ra,0xffffe
    80003070:	de2080e7          	jalr	-542(ra) # 80000e4e <strlen>
}
    80003074:	70a2                	ld	ra,40(sp)
    80003076:	7402                	ld	s0,32(sp)
    80003078:	64e2                	ld	s1,24(sp)
    8000307a:	6942                	ld	s2,16(sp)
    8000307c:	69a2                	ld	s3,8(sp)
    8000307e:	6145                	addi	sp,sp,48
    80003080:	8082                	ret
    return -1;
    80003082:	557d                	li	a0,-1
    80003084:	bfc5                	j	80003074 <fetchstr+0x3a>

0000000080003086 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003086:	1101                	addi	sp,sp,-32
    80003088:	ec06                	sd	ra,24(sp)
    8000308a:	e822                	sd	s0,16(sp)
    8000308c:	e426                	sd	s1,8(sp)
    8000308e:	1000                	addi	s0,sp,32
    80003090:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003092:	00000097          	auipc	ra,0x0
    80003096:	eee080e7          	jalr	-274(ra) # 80002f80 <argraw>
    8000309a:	c088                	sw	a0,0(s1)
}
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	64a2                	ld	s1,8(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret

00000000800030a6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800030a6:	1101                	addi	sp,sp,-32
    800030a8:	ec06                	sd	ra,24(sp)
    800030aa:	e822                	sd	s0,16(sp)
    800030ac:	e426                	sd	s1,8(sp)
    800030ae:	1000                	addi	s0,sp,32
    800030b0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030b2:	00000097          	auipc	ra,0x0
    800030b6:	ece080e7          	jalr	-306(ra) # 80002f80 <argraw>
    800030ba:	e088                	sd	a0,0(s1)
}
    800030bc:	60e2                	ld	ra,24(sp)
    800030be:	6442                	ld	s0,16(sp)
    800030c0:	64a2                	ld	s1,8(sp)
    800030c2:	6105                	addi	sp,sp,32
    800030c4:	8082                	ret

00000000800030c6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800030c6:	7179                	addi	sp,sp,-48
    800030c8:	f406                	sd	ra,40(sp)
    800030ca:	f022                	sd	s0,32(sp)
    800030cc:	ec26                	sd	s1,24(sp)
    800030ce:	e84a                	sd	s2,16(sp)
    800030d0:	1800                	addi	s0,sp,48
    800030d2:	84ae                	mv	s1,a1
    800030d4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030d6:	fd840593          	addi	a1,s0,-40
    800030da:	00000097          	auipc	ra,0x0
    800030de:	fcc080e7          	jalr	-52(ra) # 800030a6 <argaddr>
  return fetchstr(addr, buf, max);
    800030e2:	864a                	mv	a2,s2
    800030e4:	85a6                	mv	a1,s1
    800030e6:	fd843503          	ld	a0,-40(s0)
    800030ea:	00000097          	auipc	ra,0x0
    800030ee:	f50080e7          	jalr	-176(ra) # 8000303a <fetchstr>
}
    800030f2:	70a2                	ld	ra,40(sp)
    800030f4:	7402                	ld	s0,32(sp)
    800030f6:	64e2                	ld	s1,24(sp)
    800030f8:	6942                	ld	s2,16(sp)
    800030fa:	6145                	addi	sp,sp,48
    800030fc:	8082                	ret

00000000800030fe <syscall>:

int readcallcount = 0;

void
syscall(void)
{
    800030fe:	1101                	addi	sp,sp,-32
    80003100:	ec06                	sd	ra,24(sp)
    80003102:	e822                	sd	s0,16(sp)
    80003104:	e426                	sd	s1,8(sp)
    80003106:	e04a                	sd	s2,0(sp)
    80003108:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000310a:	fffff097          	auipc	ra,0xfffff
    8000310e:	a46080e7          	jalr	-1466(ra) # 80001b50 <myproc>
    80003112:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003114:	06853903          	ld	s2,104(a0)
    80003118:	0a893783          	ld	a5,168(s2)
    8000311c:	0007869b          	sext.w	a3,a5
  if(num == SYS_read)
    80003120:	4715                	li	a4,5
    80003122:	04e68663          	beq	a3,a4,8000316e <syscall+0x70>
  {
    readcallcount += 1;
  }
  else if(num == SYS_getreadcount)
    80003126:	475d                	li	a4,23
    80003128:	06e68963          	beq	a3,a4,8000319a <syscall+0x9c>
  {
    p->readcount = readcallcount;
  }
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000312c:	37fd                	addiw	a5,a5,-1
    8000312e:	4761                	li	a4,24
    80003130:	00f76b63          	bltu	a4,a5,80003146 <syscall+0x48>
    80003134:	00369713          	slli	a4,a3,0x3
    80003138:	00005797          	auipc	a5,0x5
    8000313c:	32878793          	addi	a5,a5,808 # 80008460 <syscalls>
    80003140:	97ba                	add	a5,a5,a4
    80003142:	639c                	ld	a5,0(a5)
    80003144:	e7b9                	bnez	a5,80003192 <syscall+0x94>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003146:	16848613          	addi	a2,s1,360
    8000314a:	40ac                	lw	a1,64(s1)
    8000314c:	00005517          	auipc	a0,0x5
    80003150:	2dc50513          	addi	a0,a0,732 # 80008428 <states.0+0x160>
    80003154:	ffffd097          	auipc	ra,0xffffd
    80003158:	434080e7          	jalr	1076(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000315c:	74bc                	ld	a5,104(s1)
    8000315e:	577d                	li	a4,-1
    80003160:	fbb8                	sd	a4,112(a5)
  }
}
    80003162:	60e2                	ld	ra,24(sp)
    80003164:	6442                	ld	s0,16(sp)
    80003166:	64a2                	ld	s1,8(sp)
    80003168:	6902                	ld	s2,0(sp)
    8000316a:	6105                	addi	sp,sp,32
    8000316c:	8082                	ret
    readcallcount += 1;
    8000316e:	00005617          	auipc	a2,0x5
    80003172:	79660613          	addi	a2,a2,1942 # 80008904 <readcallcount>
    80003176:	4218                	lw	a4,0(a2)
    80003178:	2705                	addiw	a4,a4,1
    8000317a:	c218                	sw	a4,0(a2)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000317c:	37fd                	addiw	a5,a5,-1
    8000317e:	4761                	li	a4,24
    80003180:	fcf763e3          	bltu	a4,a5,80003146 <syscall+0x48>
    80003184:	068e                	slli	a3,a3,0x3
    80003186:	00005797          	auipc	a5,0x5
    8000318a:	2da78793          	addi	a5,a5,730 # 80008460 <syscalls>
    8000318e:	96be                	add	a3,a3,a5
    80003190:	629c                	ld	a5,0(a3)
    p->trapframe->a0 = syscalls[num]();
    80003192:	9782                	jalr	a5
    80003194:	06a93823          	sd	a0,112(s2)
    80003198:	b7e9                	j	80003162 <syscall+0x64>
    p->readcount = readcallcount;
    8000319a:	00005717          	auipc	a4,0x5
    8000319e:	76a72703          	lw	a4,1898(a4) # 80008904 <readcallcount>
    800031a2:	18e52223          	sw	a4,388(a0)
    800031a6:	bfd9                	j	8000317c <syscall+0x7e>

00000000800031a8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800031a8:	1101                	addi	sp,sp,-32
    800031aa:	ec06                	sd	ra,24(sp)
    800031ac:	e822                	sd	s0,16(sp)
    800031ae:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800031b0:	fec40593          	addi	a1,s0,-20
    800031b4:	4501                	li	a0,0
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	ed0080e7          	jalr	-304(ra) # 80003086 <argint>
  exit(n);
    800031be:	fec42503          	lw	a0,-20(s0)
    800031c2:	fffff097          	auipc	ra,0xfffff
    800031c6:	286080e7          	jalr	646(ra) # 80002448 <exit>
  return 0; // not reached
}
    800031ca:	4501                	li	a0,0
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	6105                	addi	sp,sp,32
    800031d2:	8082                	ret

00000000800031d4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800031d4:	1141                	addi	sp,sp,-16
    800031d6:	e406                	sd	ra,8(sp)
    800031d8:	e022                	sd	s0,0(sp)
    800031da:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	974080e7          	jalr	-1676(ra) # 80001b50 <myproc>
}
    800031e4:	4128                	lw	a0,64(a0)
    800031e6:	60a2                	ld	ra,8(sp)
    800031e8:	6402                	ld	s0,0(sp)
    800031ea:	0141                	addi	sp,sp,16
    800031ec:	8082                	ret

00000000800031ee <sys_fork>:

uint64
sys_fork(void)
{
    800031ee:	1141                	addi	sp,sp,-16
    800031f0:	e406                	sd	ra,8(sp)
    800031f2:	e022                	sd	s0,0(sp)
    800031f4:	0800                	addi	s0,sp,16
  return fork();
    800031f6:	fffff097          	auipc	ra,0xfffff
    800031fa:	d54080e7          	jalr	-684(ra) # 80001f4a <fork>
}
    800031fe:	60a2                	ld	ra,8(sp)
    80003200:	6402                	ld	s0,0(sp)
    80003202:	0141                	addi	sp,sp,16
    80003204:	8082                	ret

0000000080003206 <sys_wait>:

uint64
sys_wait(void)
{
    80003206:	1101                	addi	sp,sp,-32
    80003208:	ec06                	sd	ra,24(sp)
    8000320a:	e822                	sd	s0,16(sp)
    8000320c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000320e:	fe840593          	addi	a1,s0,-24
    80003212:	4501                	li	a0,0
    80003214:	00000097          	auipc	ra,0x0
    80003218:	e92080e7          	jalr	-366(ra) # 800030a6 <argaddr>
  return wait(p);
    8000321c:	fe843503          	ld	a0,-24(s0)
    80003220:	fffff097          	auipc	ra,0xfffff
    80003224:	3e6080e7          	jalr	998(ra) # 80002606 <wait>
}
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	6105                	addi	sp,sp,32
    8000322e:	8082                	ret

0000000080003230 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003230:	7179                	addi	sp,sp,-48
    80003232:	f406                	sd	ra,40(sp)
    80003234:	f022                	sd	s0,32(sp)
    80003236:	ec26                	sd	s1,24(sp)
    80003238:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000323a:	fdc40593          	addi	a1,s0,-36
    8000323e:	4501                	li	a0,0
    80003240:	00000097          	auipc	ra,0x0
    80003244:	e46080e7          	jalr	-442(ra) # 80003086 <argint>
  addr = myproc()->sz;
    80003248:	fffff097          	auipc	ra,0xfffff
    8000324c:	908080e7          	jalr	-1784(ra) # 80001b50 <myproc>
    80003250:	6d24                	ld	s1,88(a0)
  if (growproc(n) < 0)
    80003252:	fdc42503          	lw	a0,-36(s0)
    80003256:	fffff097          	auipc	ra,0xfffff
    8000325a:	c98080e7          	jalr	-872(ra) # 80001eee <growproc>
    8000325e:	00054863          	bltz	a0,8000326e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003262:	8526                	mv	a0,s1
    80003264:	70a2                	ld	ra,40(sp)
    80003266:	7402                	ld	s0,32(sp)
    80003268:	64e2                	ld	s1,24(sp)
    8000326a:	6145                	addi	sp,sp,48
    8000326c:	8082                	ret
    return -1;
    8000326e:	54fd                	li	s1,-1
    80003270:	bfcd                	j	80003262 <sys_sbrk+0x32>

0000000080003272 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003272:	7139                	addi	sp,sp,-64
    80003274:	fc06                	sd	ra,56(sp)
    80003276:	f822                	sd	s0,48(sp)
    80003278:	f426                	sd	s1,40(sp)
    8000327a:	f04a                	sd	s2,32(sp)
    8000327c:	ec4e                	sd	s3,24(sp)
    8000327e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003280:	fcc40593          	addi	a1,s0,-52
    80003284:	4501                	li	a0,0
    80003286:	00000097          	auipc	ra,0x0
    8000328a:	e00080e7          	jalr	-512(ra) # 80003086 <argint>
  acquire(&tickslock);
    8000328e:	00015517          	auipc	a0,0x15
    80003292:	d3250513          	addi	a0,a0,-718 # 80017fc0 <tickslock>
    80003296:	ffffe097          	auipc	ra,0xffffe
    8000329a:	940080e7          	jalr	-1728(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    8000329e:	00005917          	auipc	s2,0x5
    800032a2:	66292903          	lw	s2,1634(s2) # 80008900 <ticks>
  while (ticks - ticks0 < n)
    800032a6:	fcc42783          	lw	a5,-52(s0)
    800032aa:	cf9d                	beqz	a5,800032e8 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800032ac:	00015997          	auipc	s3,0x15
    800032b0:	d1498993          	addi	s3,s3,-748 # 80017fc0 <tickslock>
    800032b4:	00005497          	auipc	s1,0x5
    800032b8:	64c48493          	addi	s1,s1,1612 # 80008900 <ticks>
    if (killed(myproc()))
    800032bc:	fffff097          	auipc	ra,0xfffff
    800032c0:	894080e7          	jalr	-1900(ra) # 80001b50 <myproc>
    800032c4:	fffff097          	auipc	ra,0xfffff
    800032c8:	310080e7          	jalr	784(ra) # 800025d4 <killed>
    800032cc:	ed15                	bnez	a0,80003308 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800032ce:	85ce                	mv	a1,s3
    800032d0:	8526                	mv	a0,s1
    800032d2:	fffff097          	auipc	ra,0xfffff
    800032d6:	042080e7          	jalr	66(ra) # 80002314 <sleep>
  while (ticks - ticks0 < n)
    800032da:	409c                	lw	a5,0(s1)
    800032dc:	412787bb          	subw	a5,a5,s2
    800032e0:	fcc42703          	lw	a4,-52(s0)
    800032e4:	fce7ece3          	bltu	a5,a4,800032bc <sys_sleep+0x4a>
  }
  release(&tickslock);
    800032e8:	00015517          	auipc	a0,0x15
    800032ec:	cd850513          	addi	a0,a0,-808 # 80017fc0 <tickslock>
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	99a080e7          	jalr	-1638(ra) # 80000c8a <release>
  return 0;
    800032f8:	4501                	li	a0,0
}
    800032fa:	70e2                	ld	ra,56(sp)
    800032fc:	7442                	ld	s0,48(sp)
    800032fe:	74a2                	ld	s1,40(sp)
    80003300:	7902                	ld	s2,32(sp)
    80003302:	69e2                	ld	s3,24(sp)
    80003304:	6121                	addi	sp,sp,64
    80003306:	8082                	ret
      release(&tickslock);
    80003308:	00015517          	auipc	a0,0x15
    8000330c:	cb850513          	addi	a0,a0,-840 # 80017fc0 <tickslock>
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	97a080e7          	jalr	-1670(ra) # 80000c8a <release>
      return -1;
    80003318:	557d                	li	a0,-1
    8000331a:	b7c5                	j	800032fa <sys_sleep+0x88>

000000008000331c <sys_kill>:

uint64
sys_kill(void)
{
    8000331c:	1101                	addi	sp,sp,-32
    8000331e:	ec06                	sd	ra,24(sp)
    80003320:	e822                	sd	s0,16(sp)
    80003322:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003324:	fec40593          	addi	a1,s0,-20
    80003328:	4501                	li	a0,0
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	d5c080e7          	jalr	-676(ra) # 80003086 <argint>
  return kill(pid);
    80003332:	fec42503          	lw	a0,-20(s0)
    80003336:	fffff097          	auipc	ra,0xfffff
    8000333a:	1f4080e7          	jalr	500(ra) # 8000252a <kill>
}
    8000333e:	60e2                	ld	ra,24(sp)
    80003340:	6442                	ld	s0,16(sp)
    80003342:	6105                	addi	sp,sp,32
    80003344:	8082                	ret

0000000080003346 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003346:	1101                	addi	sp,sp,-32
    80003348:	ec06                	sd	ra,24(sp)
    8000334a:	e822                	sd	s0,16(sp)
    8000334c:	e426                	sd	s1,8(sp)
    8000334e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003350:	00015517          	auipc	a0,0x15
    80003354:	c7050513          	addi	a0,a0,-912 # 80017fc0 <tickslock>
    80003358:	ffffe097          	auipc	ra,0xffffe
    8000335c:	87e080e7          	jalr	-1922(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003360:	00005497          	auipc	s1,0x5
    80003364:	5a04a483          	lw	s1,1440(s1) # 80008900 <ticks>
  release(&tickslock);
    80003368:	00015517          	auipc	a0,0x15
    8000336c:	c5850513          	addi	a0,a0,-936 # 80017fc0 <tickslock>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	91a080e7          	jalr	-1766(ra) # 80000c8a <release>
  return xticks;
}
    80003378:	02049513          	slli	a0,s1,0x20
    8000337c:	9101                	srli	a0,a0,0x20
    8000337e:	60e2                	ld	ra,24(sp)
    80003380:	6442                	ld	s0,16(sp)
    80003382:	64a2                	ld	s1,8(sp)
    80003384:	6105                	addi	sp,sp,32
    80003386:	8082                	ret

0000000080003388 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003388:	7139                	addi	sp,sp,-64
    8000338a:	fc06                	sd	ra,56(sp)
    8000338c:	f822                	sd	s0,48(sp)
    8000338e:	f426                	sd	s1,40(sp)
    80003390:	f04a                	sd	s2,32(sp)
    80003392:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003394:	fd840593          	addi	a1,s0,-40
    80003398:	4501                	li	a0,0
    8000339a:	00000097          	auipc	ra,0x0
    8000339e:	d0c080e7          	jalr	-756(ra) # 800030a6 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800033a2:	fd040593          	addi	a1,s0,-48
    800033a6:	4505                	li	a0,1
    800033a8:	00000097          	auipc	ra,0x0
    800033ac:	cfe080e7          	jalr	-770(ra) # 800030a6 <argaddr>
  argaddr(2, &addr2);
    800033b0:	fc840593          	addi	a1,s0,-56
    800033b4:	4509                	li	a0,2
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	cf0080e7          	jalr	-784(ra) # 800030a6 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800033be:	fc040613          	addi	a2,s0,-64
    800033c2:	fc440593          	addi	a1,s0,-60
    800033c6:	fd843503          	ld	a0,-40(s0)
    800033ca:	fffff097          	auipc	ra,0xfffff
    800033ce:	4c4080e7          	jalr	1220(ra) # 8000288e <waitx>
    800033d2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800033d4:	ffffe097          	auipc	ra,0xffffe
    800033d8:	77c080e7          	jalr	1916(ra) # 80001b50 <myproc>
    800033dc:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800033de:	4691                	li	a3,4
    800033e0:	fc440613          	addi	a2,s0,-60
    800033e4:	fd043583          	ld	a1,-48(s0)
    800033e8:	7128                	ld	a0,96(a0)
    800033ea:	ffffe097          	auipc	ra,0xffffe
    800033ee:	286080e7          	jalr	646(ra) # 80001670 <copyout>
    return -1;
    800033f2:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800033f4:	00054f63          	bltz	a0,80003412 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800033f8:	4691                	li	a3,4
    800033fa:	fc040613          	addi	a2,s0,-64
    800033fe:	fc843583          	ld	a1,-56(s0)
    80003402:	70a8                	ld	a0,96(s1)
    80003404:	ffffe097          	auipc	ra,0xffffe
    80003408:	26c080e7          	jalr	620(ra) # 80001670 <copyout>
    8000340c:	00054a63          	bltz	a0,80003420 <sys_waitx+0x98>
    return -1;
  return ret;
    80003410:	87ca                	mv	a5,s2
}
    80003412:	853e                	mv	a0,a5
    80003414:	70e2                	ld	ra,56(sp)
    80003416:	7442                	ld	s0,48(sp)
    80003418:	74a2                	ld	s1,40(sp)
    8000341a:	7902                	ld	s2,32(sp)
    8000341c:	6121                	addi	sp,sp,64
    8000341e:	8082                	ret
    return -1;
    80003420:	57fd                	li	a5,-1
    80003422:	bfc5                	j	80003412 <sys_waitx+0x8a>

0000000080003424 <sys_getreadcount>:

// getreadcount()

uint64
sys_getreadcount(void)
{
    80003424:	1141                	addi	sp,sp,-16
    80003426:	e406                	sd	ra,8(sp)
    80003428:	e022                	sd	s0,0(sp)
    8000342a:	0800                	addi	s0,sp,16
  return myproc()->readcount;
    8000342c:	ffffe097          	auipc	ra,0xffffe
    80003430:	724080e7          	jalr	1828(ra) # 80001b50 <myproc>
}
    80003434:	18452503          	lw	a0,388(a0)
    80003438:	60a2                	ld	ra,8(sp)
    8000343a:	6402                	ld	s0,0(sp)
    8000343c:	0141                	addi	sp,sp,16
    8000343e:	8082                	ret

0000000080003440 <sys_sigalarm>:

// sigalarm()

uint64
sys_sigalarm(void)
{
    80003440:	1101                	addi	sp,sp,-32
    80003442:	ec06                	sd	ra,24(sp)
    80003444:	e822                	sd	s0,16(sp)
    80003446:	1000                	addi	s0,sp,32
  uint64 handler2;
  argaddr(1,&handler2);
    80003448:	fe840593          	addi	a1,s0,-24
    8000344c:	4505                	li	a0,1
    8000344e:	00000097          	auipc	ra,0x0
    80003452:	c58080e7          	jalr	-936(ra) # 800030a6 <argaddr>

  int interval;
  argint(0,&interval);
    80003456:	fe440593          	addi	a1,s0,-28
    8000345a:	4501                	li	a0,0
    8000345c:	00000097          	auipc	ra,0x0
    80003460:	c2a080e7          	jalr	-982(ra) # 80003086 <argint>

  struct proc* p = myproc();
    80003464:	ffffe097          	auipc	ra,0xffffe
    80003468:	6ec080e7          	jalr	1772(ra) # 80001b50 <myproc>

  p->interval=interval;
    8000346c:	fe442783          	lw	a5,-28(s0)
    80003470:	18f52623          	sw	a5,396(a0)
  p->handler=handler2;
    80003474:	fe843783          	ld	a5,-24(s0)
    80003478:	18f52423          	sw	a5,392(a0)

  return 0;
}
    8000347c:	4501                	li	a0,0
    8000347e:	60e2                	ld	ra,24(sp)
    80003480:	6442                	ld	s0,16(sp)
    80003482:	6105                	addi	sp,sp,32
    80003484:	8082                	ret

0000000080003486 <sys_sigreturn>:

// sigreturn()

uint64
sys_sigreturn(void)
{
    80003486:	1101                	addi	sp,sp,-32
    80003488:	ec06                	sd	ra,24(sp)
    8000348a:	e822                	sd	s0,16(sp)
    8000348c:	e426                	sd	s1,8(sp)
    8000348e:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    80003490:	ffffe097          	auipc	ra,0xffffe
    80003494:	6c0080e7          	jalr	1728(ra) # 80001b50 <myproc>
    80003498:	84aa                	mv	s1,a0

  memmove(p->trapframe,p->trapframealarm,PGSIZE);
    8000349a:	6605                	lui	a2,0x1
    8000349c:	19853583          	ld	a1,408(a0)
    800034a0:	7528                	ld	a0,104(a0)
    800034a2:	ffffe097          	auipc	ra,0xffffe
    800034a6:	88c080e7          	jalr	-1908(ra) # 80000d2e <memmove>
  kfree(p->trapframealarm);
    800034aa:	1984b503          	ld	a0,408(s1)
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	53c080e7          	jalr	1340(ra) # 800009ea <kfree>

  p->tickscurrently=0;
    800034b6:	1804a823          	sw	zero,400(s1)
  p->signalstatus=0;
    800034ba:	1804aa23          	sw	zero,404(s1)
  p->trapframealarm=0;
    800034be:	1804bc23          	sd	zero,408(s1)

  usertrapret();
    800034c2:	fffff097          	auipc	ra,0xfffff
    800034c6:	626080e7          	jalr	1574(ra) # 80002ae8 <usertrapret>
  return 0;
    800034ca:	4501                	li	a0,0
    800034cc:	60e2                	ld	ra,24(sp)
    800034ce:	6442                	ld	s0,16(sp)
    800034d0:	64a2                	ld	s1,8(sp)
    800034d2:	6105                	addi	sp,sp,32
    800034d4:	8082                	ret

00000000800034d6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800034d6:	7179                	addi	sp,sp,-48
    800034d8:	f406                	sd	ra,40(sp)
    800034da:	f022                	sd	s0,32(sp)
    800034dc:	ec26                	sd	s1,24(sp)
    800034de:	e84a                	sd	s2,16(sp)
    800034e0:	e44e                	sd	s3,8(sp)
    800034e2:	e052                	sd	s4,0(sp)
    800034e4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800034e6:	00005597          	auipc	a1,0x5
    800034ea:	04a58593          	addi	a1,a1,74 # 80008530 <syscalls+0xd0>
    800034ee:	00015517          	auipc	a0,0x15
    800034f2:	aea50513          	addi	a0,a0,-1302 # 80017fd8 <bcache>
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	650080e7          	jalr	1616(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034fe:	0001d797          	auipc	a5,0x1d
    80003502:	ada78793          	addi	a5,a5,-1318 # 8001ffd8 <bcache+0x8000>
    80003506:	0001d717          	auipc	a4,0x1d
    8000350a:	d3a70713          	addi	a4,a4,-710 # 80020240 <bcache+0x8268>
    8000350e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003512:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003516:	00015497          	auipc	s1,0x15
    8000351a:	ada48493          	addi	s1,s1,-1318 # 80017ff0 <bcache+0x18>
    b->next = bcache.head.next;
    8000351e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003520:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003522:	00005a17          	auipc	s4,0x5
    80003526:	016a0a13          	addi	s4,s4,22 # 80008538 <syscalls+0xd8>
    b->next = bcache.head.next;
    8000352a:	2b893783          	ld	a5,696(s2)
    8000352e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003530:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003534:	85d2                	mv	a1,s4
    80003536:	01048513          	addi	a0,s1,16
    8000353a:	00001097          	auipc	ra,0x1
    8000353e:	4c4080e7          	jalr	1220(ra) # 800049fe <initsleeplock>
    bcache.head.next->prev = b;
    80003542:	2b893783          	ld	a5,696(s2)
    80003546:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003548:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000354c:	45848493          	addi	s1,s1,1112
    80003550:	fd349de3          	bne	s1,s3,8000352a <binit+0x54>
  }
}
    80003554:	70a2                	ld	ra,40(sp)
    80003556:	7402                	ld	s0,32(sp)
    80003558:	64e2                	ld	s1,24(sp)
    8000355a:	6942                	ld	s2,16(sp)
    8000355c:	69a2                	ld	s3,8(sp)
    8000355e:	6a02                	ld	s4,0(sp)
    80003560:	6145                	addi	sp,sp,48
    80003562:	8082                	ret

0000000080003564 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003564:	7179                	addi	sp,sp,-48
    80003566:	f406                	sd	ra,40(sp)
    80003568:	f022                	sd	s0,32(sp)
    8000356a:	ec26                	sd	s1,24(sp)
    8000356c:	e84a                	sd	s2,16(sp)
    8000356e:	e44e                	sd	s3,8(sp)
    80003570:	1800                	addi	s0,sp,48
    80003572:	892a                	mv	s2,a0
    80003574:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003576:	00015517          	auipc	a0,0x15
    8000357a:	a6250513          	addi	a0,a0,-1438 # 80017fd8 <bcache>
    8000357e:	ffffd097          	auipc	ra,0xffffd
    80003582:	658080e7          	jalr	1624(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003586:	0001d497          	auipc	s1,0x1d
    8000358a:	d0a4b483          	ld	s1,-758(s1) # 80020290 <bcache+0x82b8>
    8000358e:	0001d797          	auipc	a5,0x1d
    80003592:	cb278793          	addi	a5,a5,-846 # 80020240 <bcache+0x8268>
    80003596:	02f48f63          	beq	s1,a5,800035d4 <bread+0x70>
    8000359a:	873e                	mv	a4,a5
    8000359c:	a021                	j	800035a4 <bread+0x40>
    8000359e:	68a4                	ld	s1,80(s1)
    800035a0:	02e48a63          	beq	s1,a4,800035d4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035a4:	449c                	lw	a5,8(s1)
    800035a6:	ff279ce3          	bne	a5,s2,8000359e <bread+0x3a>
    800035aa:	44dc                	lw	a5,12(s1)
    800035ac:	ff3799e3          	bne	a5,s3,8000359e <bread+0x3a>
      b->refcnt++;
    800035b0:	40bc                	lw	a5,64(s1)
    800035b2:	2785                	addiw	a5,a5,1
    800035b4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035b6:	00015517          	auipc	a0,0x15
    800035ba:	a2250513          	addi	a0,a0,-1502 # 80017fd8 <bcache>
    800035be:	ffffd097          	auipc	ra,0xffffd
    800035c2:	6cc080e7          	jalr	1740(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800035c6:	01048513          	addi	a0,s1,16
    800035ca:	00001097          	auipc	ra,0x1
    800035ce:	46e080e7          	jalr	1134(ra) # 80004a38 <acquiresleep>
      return b;
    800035d2:	a8b9                	j	80003630 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035d4:	0001d497          	auipc	s1,0x1d
    800035d8:	cb44b483          	ld	s1,-844(s1) # 80020288 <bcache+0x82b0>
    800035dc:	0001d797          	auipc	a5,0x1d
    800035e0:	c6478793          	addi	a5,a5,-924 # 80020240 <bcache+0x8268>
    800035e4:	00f48863          	beq	s1,a5,800035f4 <bread+0x90>
    800035e8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800035ea:	40bc                	lw	a5,64(s1)
    800035ec:	cf81                	beqz	a5,80003604 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035ee:	64a4                	ld	s1,72(s1)
    800035f0:	fee49de3          	bne	s1,a4,800035ea <bread+0x86>
  panic("bget: no buffers");
    800035f4:	00005517          	auipc	a0,0x5
    800035f8:	f4c50513          	addi	a0,a0,-180 # 80008540 <syscalls+0xe0>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	f42080e7          	jalr	-190(ra) # 8000053e <panic>
      b->dev = dev;
    80003604:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003608:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000360c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003610:	4785                	li	a5,1
    80003612:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003614:	00015517          	auipc	a0,0x15
    80003618:	9c450513          	addi	a0,a0,-1596 # 80017fd8 <bcache>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	66e080e7          	jalr	1646(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003624:	01048513          	addi	a0,s1,16
    80003628:	00001097          	auipc	ra,0x1
    8000362c:	410080e7          	jalr	1040(ra) # 80004a38 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003630:	409c                	lw	a5,0(s1)
    80003632:	cb89                	beqz	a5,80003644 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003634:	8526                	mv	a0,s1
    80003636:	70a2                	ld	ra,40(sp)
    80003638:	7402                	ld	s0,32(sp)
    8000363a:	64e2                	ld	s1,24(sp)
    8000363c:	6942                	ld	s2,16(sp)
    8000363e:	69a2                	ld	s3,8(sp)
    80003640:	6145                	addi	sp,sp,48
    80003642:	8082                	ret
    virtio_disk_rw(b, 0);
    80003644:	4581                	li	a1,0
    80003646:	8526                	mv	a0,s1
    80003648:	00003097          	auipc	ra,0x3
    8000364c:	fdc080e7          	jalr	-36(ra) # 80006624 <virtio_disk_rw>
    b->valid = 1;
    80003650:	4785                	li	a5,1
    80003652:	c09c                	sw	a5,0(s1)
  return b;
    80003654:	b7c5                	j	80003634 <bread+0xd0>

0000000080003656 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003656:	1101                	addi	sp,sp,-32
    80003658:	ec06                	sd	ra,24(sp)
    8000365a:	e822                	sd	s0,16(sp)
    8000365c:	e426                	sd	s1,8(sp)
    8000365e:	1000                	addi	s0,sp,32
    80003660:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003662:	0541                	addi	a0,a0,16
    80003664:	00001097          	auipc	ra,0x1
    80003668:	46e080e7          	jalr	1134(ra) # 80004ad2 <holdingsleep>
    8000366c:	cd01                	beqz	a0,80003684 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000366e:	4585                	li	a1,1
    80003670:	8526                	mv	a0,s1
    80003672:	00003097          	auipc	ra,0x3
    80003676:	fb2080e7          	jalr	-78(ra) # 80006624 <virtio_disk_rw>
}
    8000367a:	60e2                	ld	ra,24(sp)
    8000367c:	6442                	ld	s0,16(sp)
    8000367e:	64a2                	ld	s1,8(sp)
    80003680:	6105                	addi	sp,sp,32
    80003682:	8082                	ret
    panic("bwrite");
    80003684:	00005517          	auipc	a0,0x5
    80003688:	ed450513          	addi	a0,a0,-300 # 80008558 <syscalls+0xf8>
    8000368c:	ffffd097          	auipc	ra,0xffffd
    80003690:	eb2080e7          	jalr	-334(ra) # 8000053e <panic>

0000000080003694 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003694:	1101                	addi	sp,sp,-32
    80003696:	ec06                	sd	ra,24(sp)
    80003698:	e822                	sd	s0,16(sp)
    8000369a:	e426                	sd	s1,8(sp)
    8000369c:	e04a                	sd	s2,0(sp)
    8000369e:	1000                	addi	s0,sp,32
    800036a0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036a2:	01050913          	addi	s2,a0,16
    800036a6:	854a                	mv	a0,s2
    800036a8:	00001097          	auipc	ra,0x1
    800036ac:	42a080e7          	jalr	1066(ra) # 80004ad2 <holdingsleep>
    800036b0:	c92d                	beqz	a0,80003722 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800036b2:	854a                	mv	a0,s2
    800036b4:	00001097          	auipc	ra,0x1
    800036b8:	3da080e7          	jalr	986(ra) # 80004a8e <releasesleep>

  acquire(&bcache.lock);
    800036bc:	00015517          	auipc	a0,0x15
    800036c0:	91c50513          	addi	a0,a0,-1764 # 80017fd8 <bcache>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	512080e7          	jalr	1298(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800036cc:	40bc                	lw	a5,64(s1)
    800036ce:	37fd                	addiw	a5,a5,-1
    800036d0:	0007871b          	sext.w	a4,a5
    800036d4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800036d6:	eb05                	bnez	a4,80003706 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800036d8:	68bc                	ld	a5,80(s1)
    800036da:	64b8                	ld	a4,72(s1)
    800036dc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800036de:	64bc                	ld	a5,72(s1)
    800036e0:	68b8                	ld	a4,80(s1)
    800036e2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800036e4:	0001d797          	auipc	a5,0x1d
    800036e8:	8f478793          	addi	a5,a5,-1804 # 8001ffd8 <bcache+0x8000>
    800036ec:	2b87b703          	ld	a4,696(a5)
    800036f0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036f2:	0001d717          	auipc	a4,0x1d
    800036f6:	b4e70713          	addi	a4,a4,-1202 # 80020240 <bcache+0x8268>
    800036fa:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036fc:	2b87b703          	ld	a4,696(a5)
    80003700:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003702:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003706:	00015517          	auipc	a0,0x15
    8000370a:	8d250513          	addi	a0,a0,-1838 # 80017fd8 <bcache>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	57c080e7          	jalr	1404(ra) # 80000c8a <release>
}
    80003716:	60e2                	ld	ra,24(sp)
    80003718:	6442                	ld	s0,16(sp)
    8000371a:	64a2                	ld	s1,8(sp)
    8000371c:	6902                	ld	s2,0(sp)
    8000371e:	6105                	addi	sp,sp,32
    80003720:	8082                	ret
    panic("brelse");
    80003722:	00005517          	auipc	a0,0x5
    80003726:	e3e50513          	addi	a0,a0,-450 # 80008560 <syscalls+0x100>
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	e14080e7          	jalr	-492(ra) # 8000053e <panic>

0000000080003732 <bpin>:

void
bpin(struct buf *b) {
    80003732:	1101                	addi	sp,sp,-32
    80003734:	ec06                	sd	ra,24(sp)
    80003736:	e822                	sd	s0,16(sp)
    80003738:	e426                	sd	s1,8(sp)
    8000373a:	1000                	addi	s0,sp,32
    8000373c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000373e:	00015517          	auipc	a0,0x15
    80003742:	89a50513          	addi	a0,a0,-1894 # 80017fd8 <bcache>
    80003746:	ffffd097          	auipc	ra,0xffffd
    8000374a:	490080e7          	jalr	1168(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000374e:	40bc                	lw	a5,64(s1)
    80003750:	2785                	addiw	a5,a5,1
    80003752:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003754:	00015517          	auipc	a0,0x15
    80003758:	88450513          	addi	a0,a0,-1916 # 80017fd8 <bcache>
    8000375c:	ffffd097          	auipc	ra,0xffffd
    80003760:	52e080e7          	jalr	1326(ra) # 80000c8a <release>
}
    80003764:	60e2                	ld	ra,24(sp)
    80003766:	6442                	ld	s0,16(sp)
    80003768:	64a2                	ld	s1,8(sp)
    8000376a:	6105                	addi	sp,sp,32
    8000376c:	8082                	ret

000000008000376e <bunpin>:

void
bunpin(struct buf *b) {
    8000376e:	1101                	addi	sp,sp,-32
    80003770:	ec06                	sd	ra,24(sp)
    80003772:	e822                	sd	s0,16(sp)
    80003774:	e426                	sd	s1,8(sp)
    80003776:	1000                	addi	s0,sp,32
    80003778:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000377a:	00015517          	auipc	a0,0x15
    8000377e:	85e50513          	addi	a0,a0,-1954 # 80017fd8 <bcache>
    80003782:	ffffd097          	auipc	ra,0xffffd
    80003786:	454080e7          	jalr	1108(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000378a:	40bc                	lw	a5,64(s1)
    8000378c:	37fd                	addiw	a5,a5,-1
    8000378e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003790:	00015517          	auipc	a0,0x15
    80003794:	84850513          	addi	a0,a0,-1976 # 80017fd8 <bcache>
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	4f2080e7          	jalr	1266(ra) # 80000c8a <release>
}
    800037a0:	60e2                	ld	ra,24(sp)
    800037a2:	6442                	ld	s0,16(sp)
    800037a4:	64a2                	ld	s1,8(sp)
    800037a6:	6105                	addi	sp,sp,32
    800037a8:	8082                	ret

00000000800037aa <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037aa:	1101                	addi	sp,sp,-32
    800037ac:	ec06                	sd	ra,24(sp)
    800037ae:	e822                	sd	s0,16(sp)
    800037b0:	e426                	sd	s1,8(sp)
    800037b2:	e04a                	sd	s2,0(sp)
    800037b4:	1000                	addi	s0,sp,32
    800037b6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800037b8:	00d5d59b          	srliw	a1,a1,0xd
    800037bc:	0001d797          	auipc	a5,0x1d
    800037c0:	ef87a783          	lw	a5,-264(a5) # 800206b4 <sb+0x1c>
    800037c4:	9dbd                	addw	a1,a1,a5
    800037c6:	00000097          	auipc	ra,0x0
    800037ca:	d9e080e7          	jalr	-610(ra) # 80003564 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037ce:	0074f713          	andi	a4,s1,7
    800037d2:	4785                	li	a5,1
    800037d4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800037d8:	14ce                	slli	s1,s1,0x33
    800037da:	90d9                	srli	s1,s1,0x36
    800037dc:	00950733          	add	a4,a0,s1
    800037e0:	05874703          	lbu	a4,88(a4)
    800037e4:	00e7f6b3          	and	a3,a5,a4
    800037e8:	c69d                	beqz	a3,80003816 <bfree+0x6c>
    800037ea:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800037ec:	94aa                	add	s1,s1,a0
    800037ee:	fff7c793          	not	a5,a5
    800037f2:	8ff9                	and	a5,a5,a4
    800037f4:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800037f8:	00001097          	auipc	ra,0x1
    800037fc:	120080e7          	jalr	288(ra) # 80004918 <log_write>
  brelse(bp);
    80003800:	854a                	mv	a0,s2
    80003802:	00000097          	auipc	ra,0x0
    80003806:	e92080e7          	jalr	-366(ra) # 80003694 <brelse>
}
    8000380a:	60e2                	ld	ra,24(sp)
    8000380c:	6442                	ld	s0,16(sp)
    8000380e:	64a2                	ld	s1,8(sp)
    80003810:	6902                	ld	s2,0(sp)
    80003812:	6105                	addi	sp,sp,32
    80003814:	8082                	ret
    panic("freeing free block");
    80003816:	00005517          	auipc	a0,0x5
    8000381a:	d5250513          	addi	a0,a0,-686 # 80008568 <syscalls+0x108>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	d20080e7          	jalr	-736(ra) # 8000053e <panic>

0000000080003826 <balloc>:
{
    80003826:	711d                	addi	sp,sp,-96
    80003828:	ec86                	sd	ra,88(sp)
    8000382a:	e8a2                	sd	s0,80(sp)
    8000382c:	e4a6                	sd	s1,72(sp)
    8000382e:	e0ca                	sd	s2,64(sp)
    80003830:	fc4e                	sd	s3,56(sp)
    80003832:	f852                	sd	s4,48(sp)
    80003834:	f456                	sd	s5,40(sp)
    80003836:	f05a                	sd	s6,32(sp)
    80003838:	ec5e                	sd	s7,24(sp)
    8000383a:	e862                	sd	s8,16(sp)
    8000383c:	e466                	sd	s9,8(sp)
    8000383e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003840:	0001d797          	auipc	a5,0x1d
    80003844:	e5c7a783          	lw	a5,-420(a5) # 8002069c <sb+0x4>
    80003848:	10078163          	beqz	a5,8000394a <balloc+0x124>
    8000384c:	8baa                	mv	s7,a0
    8000384e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003850:	0001db17          	auipc	s6,0x1d
    80003854:	e48b0b13          	addi	s6,s6,-440 # 80020698 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003858:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000385a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000385c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000385e:	6c89                	lui	s9,0x2
    80003860:	a061                	j	800038e8 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003862:	974a                	add	a4,a4,s2
    80003864:	8fd5                	or	a5,a5,a3
    80003866:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000386a:	854a                	mv	a0,s2
    8000386c:	00001097          	auipc	ra,0x1
    80003870:	0ac080e7          	jalr	172(ra) # 80004918 <log_write>
        brelse(bp);
    80003874:	854a                	mv	a0,s2
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	e1e080e7          	jalr	-482(ra) # 80003694 <brelse>
  bp = bread(dev, bno);
    8000387e:	85a6                	mv	a1,s1
    80003880:	855e                	mv	a0,s7
    80003882:	00000097          	auipc	ra,0x0
    80003886:	ce2080e7          	jalr	-798(ra) # 80003564 <bread>
    8000388a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000388c:	40000613          	li	a2,1024
    80003890:	4581                	li	a1,0
    80003892:	05850513          	addi	a0,a0,88
    80003896:	ffffd097          	auipc	ra,0xffffd
    8000389a:	43c080e7          	jalr	1084(ra) # 80000cd2 <memset>
  log_write(bp);
    8000389e:	854a                	mv	a0,s2
    800038a0:	00001097          	auipc	ra,0x1
    800038a4:	078080e7          	jalr	120(ra) # 80004918 <log_write>
  brelse(bp);
    800038a8:	854a                	mv	a0,s2
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	dea080e7          	jalr	-534(ra) # 80003694 <brelse>
}
    800038b2:	8526                	mv	a0,s1
    800038b4:	60e6                	ld	ra,88(sp)
    800038b6:	6446                	ld	s0,80(sp)
    800038b8:	64a6                	ld	s1,72(sp)
    800038ba:	6906                	ld	s2,64(sp)
    800038bc:	79e2                	ld	s3,56(sp)
    800038be:	7a42                	ld	s4,48(sp)
    800038c0:	7aa2                	ld	s5,40(sp)
    800038c2:	7b02                	ld	s6,32(sp)
    800038c4:	6be2                	ld	s7,24(sp)
    800038c6:	6c42                	ld	s8,16(sp)
    800038c8:	6ca2                	ld	s9,8(sp)
    800038ca:	6125                	addi	sp,sp,96
    800038cc:	8082                	ret
    brelse(bp);
    800038ce:	854a                	mv	a0,s2
    800038d0:	00000097          	auipc	ra,0x0
    800038d4:	dc4080e7          	jalr	-572(ra) # 80003694 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800038d8:	015c87bb          	addw	a5,s9,s5
    800038dc:	00078a9b          	sext.w	s5,a5
    800038e0:	004b2703          	lw	a4,4(s6)
    800038e4:	06eaf363          	bgeu	s5,a4,8000394a <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800038e8:	41fad79b          	sraiw	a5,s5,0x1f
    800038ec:	0137d79b          	srliw	a5,a5,0x13
    800038f0:	015787bb          	addw	a5,a5,s5
    800038f4:	40d7d79b          	sraiw	a5,a5,0xd
    800038f8:	01cb2583          	lw	a1,28(s6)
    800038fc:	9dbd                	addw	a1,a1,a5
    800038fe:	855e                	mv	a0,s7
    80003900:	00000097          	auipc	ra,0x0
    80003904:	c64080e7          	jalr	-924(ra) # 80003564 <bread>
    80003908:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000390a:	004b2503          	lw	a0,4(s6)
    8000390e:	000a849b          	sext.w	s1,s5
    80003912:	8662                	mv	a2,s8
    80003914:	faa4fde3          	bgeu	s1,a0,800038ce <balloc+0xa8>
      m = 1 << (bi % 8);
    80003918:	41f6579b          	sraiw	a5,a2,0x1f
    8000391c:	01d7d69b          	srliw	a3,a5,0x1d
    80003920:	00c6873b          	addw	a4,a3,a2
    80003924:	00777793          	andi	a5,a4,7
    80003928:	9f95                	subw	a5,a5,a3
    8000392a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000392e:	4037571b          	sraiw	a4,a4,0x3
    80003932:	00e906b3          	add	a3,s2,a4
    80003936:	0586c683          	lbu	a3,88(a3)
    8000393a:	00d7f5b3          	and	a1,a5,a3
    8000393e:	d195                	beqz	a1,80003862 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003940:	2605                	addiw	a2,a2,1
    80003942:	2485                	addiw	s1,s1,1
    80003944:	fd4618e3          	bne	a2,s4,80003914 <balloc+0xee>
    80003948:	b759                	j	800038ce <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000394a:	00005517          	auipc	a0,0x5
    8000394e:	c3650513          	addi	a0,a0,-970 # 80008580 <syscalls+0x120>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	c36080e7          	jalr	-970(ra) # 80000588 <printf>
  return 0;
    8000395a:	4481                	li	s1,0
    8000395c:	bf99                	j	800038b2 <balloc+0x8c>

000000008000395e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000395e:	7179                	addi	sp,sp,-48
    80003960:	f406                	sd	ra,40(sp)
    80003962:	f022                	sd	s0,32(sp)
    80003964:	ec26                	sd	s1,24(sp)
    80003966:	e84a                	sd	s2,16(sp)
    80003968:	e44e                	sd	s3,8(sp)
    8000396a:	e052                	sd	s4,0(sp)
    8000396c:	1800                	addi	s0,sp,48
    8000396e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003970:	47ad                	li	a5,11
    80003972:	02b7e763          	bltu	a5,a1,800039a0 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003976:	02059493          	slli	s1,a1,0x20
    8000397a:	9081                	srli	s1,s1,0x20
    8000397c:	048a                	slli	s1,s1,0x2
    8000397e:	94aa                	add	s1,s1,a0
    80003980:	0504a903          	lw	s2,80(s1)
    80003984:	06091e63          	bnez	s2,80003a00 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003988:	4108                	lw	a0,0(a0)
    8000398a:	00000097          	auipc	ra,0x0
    8000398e:	e9c080e7          	jalr	-356(ra) # 80003826 <balloc>
    80003992:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003996:	06090563          	beqz	s2,80003a00 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000399a:	0524a823          	sw	s2,80(s1)
    8000399e:	a08d                	j	80003a00 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039a0:	ff45849b          	addiw	s1,a1,-12
    800039a4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039a8:	0ff00793          	li	a5,255
    800039ac:	08e7e563          	bltu	a5,a4,80003a36 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800039b0:	08052903          	lw	s2,128(a0)
    800039b4:	00091d63          	bnez	s2,800039ce <bmap+0x70>
      addr = balloc(ip->dev);
    800039b8:	4108                	lw	a0,0(a0)
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	e6c080e7          	jalr	-404(ra) # 80003826 <balloc>
    800039c2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039c6:	02090d63          	beqz	s2,80003a00 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800039ca:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800039ce:	85ca                	mv	a1,s2
    800039d0:	0009a503          	lw	a0,0(s3)
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	b90080e7          	jalr	-1136(ra) # 80003564 <bread>
    800039dc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800039de:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800039e2:	02049593          	slli	a1,s1,0x20
    800039e6:	9181                	srli	a1,a1,0x20
    800039e8:	058a                	slli	a1,a1,0x2
    800039ea:	00b784b3          	add	s1,a5,a1
    800039ee:	0004a903          	lw	s2,0(s1)
    800039f2:	02090063          	beqz	s2,80003a12 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800039f6:	8552                	mv	a0,s4
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	c9c080e7          	jalr	-868(ra) # 80003694 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a00:	854a                	mv	a0,s2
    80003a02:	70a2                	ld	ra,40(sp)
    80003a04:	7402                	ld	s0,32(sp)
    80003a06:	64e2                	ld	s1,24(sp)
    80003a08:	6942                	ld	s2,16(sp)
    80003a0a:	69a2                	ld	s3,8(sp)
    80003a0c:	6a02                	ld	s4,0(sp)
    80003a0e:	6145                	addi	sp,sp,48
    80003a10:	8082                	ret
      addr = balloc(ip->dev);
    80003a12:	0009a503          	lw	a0,0(s3)
    80003a16:	00000097          	auipc	ra,0x0
    80003a1a:	e10080e7          	jalr	-496(ra) # 80003826 <balloc>
    80003a1e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003a22:	fc090ae3          	beqz	s2,800039f6 <bmap+0x98>
        a[bn] = addr;
    80003a26:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a2a:	8552                	mv	a0,s4
    80003a2c:	00001097          	auipc	ra,0x1
    80003a30:	eec080e7          	jalr	-276(ra) # 80004918 <log_write>
    80003a34:	b7c9                	j	800039f6 <bmap+0x98>
  panic("bmap: out of range");
    80003a36:	00005517          	auipc	a0,0x5
    80003a3a:	b6250513          	addi	a0,a0,-1182 # 80008598 <syscalls+0x138>
    80003a3e:	ffffd097          	auipc	ra,0xffffd
    80003a42:	b00080e7          	jalr	-1280(ra) # 8000053e <panic>

0000000080003a46 <iget>:
{
    80003a46:	7179                	addi	sp,sp,-48
    80003a48:	f406                	sd	ra,40(sp)
    80003a4a:	f022                	sd	s0,32(sp)
    80003a4c:	ec26                	sd	s1,24(sp)
    80003a4e:	e84a                	sd	s2,16(sp)
    80003a50:	e44e                	sd	s3,8(sp)
    80003a52:	e052                	sd	s4,0(sp)
    80003a54:	1800                	addi	s0,sp,48
    80003a56:	89aa                	mv	s3,a0
    80003a58:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a5a:	0001d517          	auipc	a0,0x1d
    80003a5e:	c5e50513          	addi	a0,a0,-930 # 800206b8 <itable>
    80003a62:	ffffd097          	auipc	ra,0xffffd
    80003a66:	174080e7          	jalr	372(ra) # 80000bd6 <acquire>
  empty = 0;
    80003a6a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a6c:	0001d497          	auipc	s1,0x1d
    80003a70:	c6448493          	addi	s1,s1,-924 # 800206d0 <itable+0x18>
    80003a74:	0001e697          	auipc	a3,0x1e
    80003a78:	6ec68693          	addi	a3,a3,1772 # 80022160 <log>
    80003a7c:	a039                	j	80003a8a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a7e:	02090b63          	beqz	s2,80003ab4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a82:	08848493          	addi	s1,s1,136
    80003a86:	02d48a63          	beq	s1,a3,80003aba <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a8a:	449c                	lw	a5,8(s1)
    80003a8c:	fef059e3          	blez	a5,80003a7e <iget+0x38>
    80003a90:	4098                	lw	a4,0(s1)
    80003a92:	ff3716e3          	bne	a4,s3,80003a7e <iget+0x38>
    80003a96:	40d8                	lw	a4,4(s1)
    80003a98:	ff4713e3          	bne	a4,s4,80003a7e <iget+0x38>
      ip->ref++;
    80003a9c:	2785                	addiw	a5,a5,1
    80003a9e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003aa0:	0001d517          	auipc	a0,0x1d
    80003aa4:	c1850513          	addi	a0,a0,-1000 # 800206b8 <itable>
    80003aa8:	ffffd097          	auipc	ra,0xffffd
    80003aac:	1e2080e7          	jalr	482(ra) # 80000c8a <release>
      return ip;
    80003ab0:	8926                	mv	s2,s1
    80003ab2:	a03d                	j	80003ae0 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ab4:	f7f9                	bnez	a5,80003a82 <iget+0x3c>
    80003ab6:	8926                	mv	s2,s1
    80003ab8:	b7e9                	j	80003a82 <iget+0x3c>
  if(empty == 0)
    80003aba:	02090c63          	beqz	s2,80003af2 <iget+0xac>
  ip->dev = dev;
    80003abe:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003ac2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ac6:	4785                	li	a5,1
    80003ac8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003acc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ad0:	0001d517          	auipc	a0,0x1d
    80003ad4:	be850513          	addi	a0,a0,-1048 # 800206b8 <itable>
    80003ad8:	ffffd097          	auipc	ra,0xffffd
    80003adc:	1b2080e7          	jalr	434(ra) # 80000c8a <release>
}
    80003ae0:	854a                	mv	a0,s2
    80003ae2:	70a2                	ld	ra,40(sp)
    80003ae4:	7402                	ld	s0,32(sp)
    80003ae6:	64e2                	ld	s1,24(sp)
    80003ae8:	6942                	ld	s2,16(sp)
    80003aea:	69a2                	ld	s3,8(sp)
    80003aec:	6a02                	ld	s4,0(sp)
    80003aee:	6145                	addi	sp,sp,48
    80003af0:	8082                	ret
    panic("iget: no inodes");
    80003af2:	00005517          	auipc	a0,0x5
    80003af6:	abe50513          	addi	a0,a0,-1346 # 800085b0 <syscalls+0x150>
    80003afa:	ffffd097          	auipc	ra,0xffffd
    80003afe:	a44080e7          	jalr	-1468(ra) # 8000053e <panic>

0000000080003b02 <fsinit>:
fsinit(int dev) {
    80003b02:	7179                	addi	sp,sp,-48
    80003b04:	f406                	sd	ra,40(sp)
    80003b06:	f022                	sd	s0,32(sp)
    80003b08:	ec26                	sd	s1,24(sp)
    80003b0a:	e84a                	sd	s2,16(sp)
    80003b0c:	e44e                	sd	s3,8(sp)
    80003b0e:	1800                	addi	s0,sp,48
    80003b10:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b12:	4585                	li	a1,1
    80003b14:	00000097          	auipc	ra,0x0
    80003b18:	a50080e7          	jalr	-1456(ra) # 80003564 <bread>
    80003b1c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b1e:	0001d997          	auipc	s3,0x1d
    80003b22:	b7a98993          	addi	s3,s3,-1158 # 80020698 <sb>
    80003b26:	02000613          	li	a2,32
    80003b2a:	05850593          	addi	a1,a0,88
    80003b2e:	854e                	mv	a0,s3
    80003b30:	ffffd097          	auipc	ra,0xffffd
    80003b34:	1fe080e7          	jalr	510(ra) # 80000d2e <memmove>
  brelse(bp);
    80003b38:	8526                	mv	a0,s1
    80003b3a:	00000097          	auipc	ra,0x0
    80003b3e:	b5a080e7          	jalr	-1190(ra) # 80003694 <brelse>
  if(sb.magic != FSMAGIC)
    80003b42:	0009a703          	lw	a4,0(s3)
    80003b46:	102037b7          	lui	a5,0x10203
    80003b4a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b4e:	02f71263          	bne	a4,a5,80003b72 <fsinit+0x70>
  initlog(dev, &sb);
    80003b52:	0001d597          	auipc	a1,0x1d
    80003b56:	b4658593          	addi	a1,a1,-1210 # 80020698 <sb>
    80003b5a:	854a                	mv	a0,s2
    80003b5c:	00001097          	auipc	ra,0x1
    80003b60:	b40080e7          	jalr	-1216(ra) # 8000469c <initlog>
}
    80003b64:	70a2                	ld	ra,40(sp)
    80003b66:	7402                	ld	s0,32(sp)
    80003b68:	64e2                	ld	s1,24(sp)
    80003b6a:	6942                	ld	s2,16(sp)
    80003b6c:	69a2                	ld	s3,8(sp)
    80003b6e:	6145                	addi	sp,sp,48
    80003b70:	8082                	ret
    panic("invalid file system");
    80003b72:	00005517          	auipc	a0,0x5
    80003b76:	a4e50513          	addi	a0,a0,-1458 # 800085c0 <syscalls+0x160>
    80003b7a:	ffffd097          	auipc	ra,0xffffd
    80003b7e:	9c4080e7          	jalr	-1596(ra) # 8000053e <panic>

0000000080003b82 <iinit>:
{
    80003b82:	7179                	addi	sp,sp,-48
    80003b84:	f406                	sd	ra,40(sp)
    80003b86:	f022                	sd	s0,32(sp)
    80003b88:	ec26                	sd	s1,24(sp)
    80003b8a:	e84a                	sd	s2,16(sp)
    80003b8c:	e44e                	sd	s3,8(sp)
    80003b8e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b90:	00005597          	auipc	a1,0x5
    80003b94:	a4858593          	addi	a1,a1,-1464 # 800085d8 <syscalls+0x178>
    80003b98:	0001d517          	auipc	a0,0x1d
    80003b9c:	b2050513          	addi	a0,a0,-1248 # 800206b8 <itable>
    80003ba0:	ffffd097          	auipc	ra,0xffffd
    80003ba4:	fa6080e7          	jalr	-90(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ba8:	0001d497          	auipc	s1,0x1d
    80003bac:	b3848493          	addi	s1,s1,-1224 # 800206e0 <itable+0x28>
    80003bb0:	0001e997          	auipc	s3,0x1e
    80003bb4:	5c098993          	addi	s3,s3,1472 # 80022170 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003bb8:	00005917          	auipc	s2,0x5
    80003bbc:	a2890913          	addi	s2,s2,-1496 # 800085e0 <syscalls+0x180>
    80003bc0:	85ca                	mv	a1,s2
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	00001097          	auipc	ra,0x1
    80003bc8:	e3a080e7          	jalr	-454(ra) # 800049fe <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003bcc:	08848493          	addi	s1,s1,136
    80003bd0:	ff3498e3          	bne	s1,s3,80003bc0 <iinit+0x3e>
}
    80003bd4:	70a2                	ld	ra,40(sp)
    80003bd6:	7402                	ld	s0,32(sp)
    80003bd8:	64e2                	ld	s1,24(sp)
    80003bda:	6942                	ld	s2,16(sp)
    80003bdc:	69a2                	ld	s3,8(sp)
    80003bde:	6145                	addi	sp,sp,48
    80003be0:	8082                	ret

0000000080003be2 <ialloc>:
{
    80003be2:	715d                	addi	sp,sp,-80
    80003be4:	e486                	sd	ra,72(sp)
    80003be6:	e0a2                	sd	s0,64(sp)
    80003be8:	fc26                	sd	s1,56(sp)
    80003bea:	f84a                	sd	s2,48(sp)
    80003bec:	f44e                	sd	s3,40(sp)
    80003bee:	f052                	sd	s4,32(sp)
    80003bf0:	ec56                	sd	s5,24(sp)
    80003bf2:	e85a                	sd	s6,16(sp)
    80003bf4:	e45e                	sd	s7,8(sp)
    80003bf6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bf8:	0001d717          	auipc	a4,0x1d
    80003bfc:	aac72703          	lw	a4,-1364(a4) # 800206a4 <sb+0xc>
    80003c00:	4785                	li	a5,1
    80003c02:	04e7fa63          	bgeu	a5,a4,80003c56 <ialloc+0x74>
    80003c06:	8aaa                	mv	s5,a0
    80003c08:	8bae                	mv	s7,a1
    80003c0a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c0c:	0001da17          	auipc	s4,0x1d
    80003c10:	a8ca0a13          	addi	s4,s4,-1396 # 80020698 <sb>
    80003c14:	00048b1b          	sext.w	s6,s1
    80003c18:	0044d793          	srli	a5,s1,0x4
    80003c1c:	018a2583          	lw	a1,24(s4)
    80003c20:	9dbd                	addw	a1,a1,a5
    80003c22:	8556                	mv	a0,s5
    80003c24:	00000097          	auipc	ra,0x0
    80003c28:	940080e7          	jalr	-1728(ra) # 80003564 <bread>
    80003c2c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c2e:	05850993          	addi	s3,a0,88
    80003c32:	00f4f793          	andi	a5,s1,15
    80003c36:	079a                	slli	a5,a5,0x6
    80003c38:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c3a:	00099783          	lh	a5,0(s3)
    80003c3e:	c3a1                	beqz	a5,80003c7e <ialloc+0x9c>
    brelse(bp);
    80003c40:	00000097          	auipc	ra,0x0
    80003c44:	a54080e7          	jalr	-1452(ra) # 80003694 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c48:	0485                	addi	s1,s1,1
    80003c4a:	00ca2703          	lw	a4,12(s4)
    80003c4e:	0004879b          	sext.w	a5,s1
    80003c52:	fce7e1e3          	bltu	a5,a4,80003c14 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003c56:	00005517          	auipc	a0,0x5
    80003c5a:	99250513          	addi	a0,a0,-1646 # 800085e8 <syscalls+0x188>
    80003c5e:	ffffd097          	auipc	ra,0xffffd
    80003c62:	92a080e7          	jalr	-1750(ra) # 80000588 <printf>
  return 0;
    80003c66:	4501                	li	a0,0
}
    80003c68:	60a6                	ld	ra,72(sp)
    80003c6a:	6406                	ld	s0,64(sp)
    80003c6c:	74e2                	ld	s1,56(sp)
    80003c6e:	7942                	ld	s2,48(sp)
    80003c70:	79a2                	ld	s3,40(sp)
    80003c72:	7a02                	ld	s4,32(sp)
    80003c74:	6ae2                	ld	s5,24(sp)
    80003c76:	6b42                	ld	s6,16(sp)
    80003c78:	6ba2                	ld	s7,8(sp)
    80003c7a:	6161                	addi	sp,sp,80
    80003c7c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003c7e:	04000613          	li	a2,64
    80003c82:	4581                	li	a1,0
    80003c84:	854e                	mv	a0,s3
    80003c86:	ffffd097          	auipc	ra,0xffffd
    80003c8a:	04c080e7          	jalr	76(ra) # 80000cd2 <memset>
      dip->type = type;
    80003c8e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c92:	854a                	mv	a0,s2
    80003c94:	00001097          	auipc	ra,0x1
    80003c98:	c84080e7          	jalr	-892(ra) # 80004918 <log_write>
      brelse(bp);
    80003c9c:	854a                	mv	a0,s2
    80003c9e:	00000097          	auipc	ra,0x0
    80003ca2:	9f6080e7          	jalr	-1546(ra) # 80003694 <brelse>
      return iget(dev, inum);
    80003ca6:	85da                	mv	a1,s6
    80003ca8:	8556                	mv	a0,s5
    80003caa:	00000097          	auipc	ra,0x0
    80003cae:	d9c080e7          	jalr	-612(ra) # 80003a46 <iget>
    80003cb2:	bf5d                	j	80003c68 <ialloc+0x86>

0000000080003cb4 <iupdate>:
{
    80003cb4:	1101                	addi	sp,sp,-32
    80003cb6:	ec06                	sd	ra,24(sp)
    80003cb8:	e822                	sd	s0,16(sp)
    80003cba:	e426                	sd	s1,8(sp)
    80003cbc:	e04a                	sd	s2,0(sp)
    80003cbe:	1000                	addi	s0,sp,32
    80003cc0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cc2:	415c                	lw	a5,4(a0)
    80003cc4:	0047d79b          	srliw	a5,a5,0x4
    80003cc8:	0001d597          	auipc	a1,0x1d
    80003ccc:	9e85a583          	lw	a1,-1560(a1) # 800206b0 <sb+0x18>
    80003cd0:	9dbd                	addw	a1,a1,a5
    80003cd2:	4108                	lw	a0,0(a0)
    80003cd4:	00000097          	auipc	ra,0x0
    80003cd8:	890080e7          	jalr	-1904(ra) # 80003564 <bread>
    80003cdc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cde:	05850793          	addi	a5,a0,88
    80003ce2:	40c8                	lw	a0,4(s1)
    80003ce4:	893d                	andi	a0,a0,15
    80003ce6:	051a                	slli	a0,a0,0x6
    80003ce8:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003cea:	04449703          	lh	a4,68(s1)
    80003cee:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003cf2:	04649703          	lh	a4,70(s1)
    80003cf6:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003cfa:	04849703          	lh	a4,72(s1)
    80003cfe:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003d02:	04a49703          	lh	a4,74(s1)
    80003d06:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003d0a:	44f8                	lw	a4,76(s1)
    80003d0c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d0e:	03400613          	li	a2,52
    80003d12:	05048593          	addi	a1,s1,80
    80003d16:	0531                	addi	a0,a0,12
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	016080e7          	jalr	22(ra) # 80000d2e <memmove>
  log_write(bp);
    80003d20:	854a                	mv	a0,s2
    80003d22:	00001097          	auipc	ra,0x1
    80003d26:	bf6080e7          	jalr	-1034(ra) # 80004918 <log_write>
  brelse(bp);
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	968080e7          	jalr	-1688(ra) # 80003694 <brelse>
}
    80003d34:	60e2                	ld	ra,24(sp)
    80003d36:	6442                	ld	s0,16(sp)
    80003d38:	64a2                	ld	s1,8(sp)
    80003d3a:	6902                	ld	s2,0(sp)
    80003d3c:	6105                	addi	sp,sp,32
    80003d3e:	8082                	ret

0000000080003d40 <idup>:
{
    80003d40:	1101                	addi	sp,sp,-32
    80003d42:	ec06                	sd	ra,24(sp)
    80003d44:	e822                	sd	s0,16(sp)
    80003d46:	e426                	sd	s1,8(sp)
    80003d48:	1000                	addi	s0,sp,32
    80003d4a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d4c:	0001d517          	auipc	a0,0x1d
    80003d50:	96c50513          	addi	a0,a0,-1684 # 800206b8 <itable>
    80003d54:	ffffd097          	auipc	ra,0xffffd
    80003d58:	e82080e7          	jalr	-382(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003d5c:	449c                	lw	a5,8(s1)
    80003d5e:	2785                	addiw	a5,a5,1
    80003d60:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d62:	0001d517          	auipc	a0,0x1d
    80003d66:	95650513          	addi	a0,a0,-1706 # 800206b8 <itable>
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	f20080e7          	jalr	-224(ra) # 80000c8a <release>
}
    80003d72:	8526                	mv	a0,s1
    80003d74:	60e2                	ld	ra,24(sp)
    80003d76:	6442                	ld	s0,16(sp)
    80003d78:	64a2                	ld	s1,8(sp)
    80003d7a:	6105                	addi	sp,sp,32
    80003d7c:	8082                	ret

0000000080003d7e <ilock>:
{
    80003d7e:	1101                	addi	sp,sp,-32
    80003d80:	ec06                	sd	ra,24(sp)
    80003d82:	e822                	sd	s0,16(sp)
    80003d84:	e426                	sd	s1,8(sp)
    80003d86:	e04a                	sd	s2,0(sp)
    80003d88:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d8a:	c115                	beqz	a0,80003dae <ilock+0x30>
    80003d8c:	84aa                	mv	s1,a0
    80003d8e:	451c                	lw	a5,8(a0)
    80003d90:	00f05f63          	blez	a5,80003dae <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d94:	0541                	addi	a0,a0,16
    80003d96:	00001097          	auipc	ra,0x1
    80003d9a:	ca2080e7          	jalr	-862(ra) # 80004a38 <acquiresleep>
  if(ip->valid == 0){
    80003d9e:	40bc                	lw	a5,64(s1)
    80003da0:	cf99                	beqz	a5,80003dbe <ilock+0x40>
}
    80003da2:	60e2                	ld	ra,24(sp)
    80003da4:	6442                	ld	s0,16(sp)
    80003da6:	64a2                	ld	s1,8(sp)
    80003da8:	6902                	ld	s2,0(sp)
    80003daa:	6105                	addi	sp,sp,32
    80003dac:	8082                	ret
    panic("ilock");
    80003dae:	00005517          	auipc	a0,0x5
    80003db2:	85250513          	addi	a0,a0,-1966 # 80008600 <syscalls+0x1a0>
    80003db6:	ffffc097          	auipc	ra,0xffffc
    80003dba:	788080e7          	jalr	1928(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dbe:	40dc                	lw	a5,4(s1)
    80003dc0:	0047d79b          	srliw	a5,a5,0x4
    80003dc4:	0001d597          	auipc	a1,0x1d
    80003dc8:	8ec5a583          	lw	a1,-1812(a1) # 800206b0 <sb+0x18>
    80003dcc:	9dbd                	addw	a1,a1,a5
    80003dce:	4088                	lw	a0,0(s1)
    80003dd0:	fffff097          	auipc	ra,0xfffff
    80003dd4:	794080e7          	jalr	1940(ra) # 80003564 <bread>
    80003dd8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003dda:	05850593          	addi	a1,a0,88
    80003dde:	40dc                	lw	a5,4(s1)
    80003de0:	8bbd                	andi	a5,a5,15
    80003de2:	079a                	slli	a5,a5,0x6
    80003de4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003de6:	00059783          	lh	a5,0(a1)
    80003dea:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003dee:	00259783          	lh	a5,2(a1)
    80003df2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003df6:	00459783          	lh	a5,4(a1)
    80003dfa:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003dfe:	00659783          	lh	a5,6(a1)
    80003e02:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e06:	459c                	lw	a5,8(a1)
    80003e08:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e0a:	03400613          	li	a2,52
    80003e0e:	05b1                	addi	a1,a1,12
    80003e10:	05048513          	addi	a0,s1,80
    80003e14:	ffffd097          	auipc	ra,0xffffd
    80003e18:	f1a080e7          	jalr	-230(ra) # 80000d2e <memmove>
    brelse(bp);
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	876080e7          	jalr	-1930(ra) # 80003694 <brelse>
    ip->valid = 1;
    80003e26:	4785                	li	a5,1
    80003e28:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e2a:	04449783          	lh	a5,68(s1)
    80003e2e:	fbb5                	bnez	a5,80003da2 <ilock+0x24>
      panic("ilock: no type");
    80003e30:	00004517          	auipc	a0,0x4
    80003e34:	7d850513          	addi	a0,a0,2008 # 80008608 <syscalls+0x1a8>
    80003e38:	ffffc097          	auipc	ra,0xffffc
    80003e3c:	706080e7          	jalr	1798(ra) # 8000053e <panic>

0000000080003e40 <iunlock>:
{
    80003e40:	1101                	addi	sp,sp,-32
    80003e42:	ec06                	sd	ra,24(sp)
    80003e44:	e822                	sd	s0,16(sp)
    80003e46:	e426                	sd	s1,8(sp)
    80003e48:	e04a                	sd	s2,0(sp)
    80003e4a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e4c:	c905                	beqz	a0,80003e7c <iunlock+0x3c>
    80003e4e:	84aa                	mv	s1,a0
    80003e50:	01050913          	addi	s2,a0,16
    80003e54:	854a                	mv	a0,s2
    80003e56:	00001097          	auipc	ra,0x1
    80003e5a:	c7c080e7          	jalr	-900(ra) # 80004ad2 <holdingsleep>
    80003e5e:	cd19                	beqz	a0,80003e7c <iunlock+0x3c>
    80003e60:	449c                	lw	a5,8(s1)
    80003e62:	00f05d63          	blez	a5,80003e7c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e66:	854a                	mv	a0,s2
    80003e68:	00001097          	auipc	ra,0x1
    80003e6c:	c26080e7          	jalr	-986(ra) # 80004a8e <releasesleep>
}
    80003e70:	60e2                	ld	ra,24(sp)
    80003e72:	6442                	ld	s0,16(sp)
    80003e74:	64a2                	ld	s1,8(sp)
    80003e76:	6902                	ld	s2,0(sp)
    80003e78:	6105                	addi	sp,sp,32
    80003e7a:	8082                	ret
    panic("iunlock");
    80003e7c:	00004517          	auipc	a0,0x4
    80003e80:	79c50513          	addi	a0,a0,1948 # 80008618 <syscalls+0x1b8>
    80003e84:	ffffc097          	auipc	ra,0xffffc
    80003e88:	6ba080e7          	jalr	1722(ra) # 8000053e <panic>

0000000080003e8c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e8c:	7179                	addi	sp,sp,-48
    80003e8e:	f406                	sd	ra,40(sp)
    80003e90:	f022                	sd	s0,32(sp)
    80003e92:	ec26                	sd	s1,24(sp)
    80003e94:	e84a                	sd	s2,16(sp)
    80003e96:	e44e                	sd	s3,8(sp)
    80003e98:	e052                	sd	s4,0(sp)
    80003e9a:	1800                	addi	s0,sp,48
    80003e9c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e9e:	05050493          	addi	s1,a0,80
    80003ea2:	08050913          	addi	s2,a0,128
    80003ea6:	a021                	j	80003eae <itrunc+0x22>
    80003ea8:	0491                	addi	s1,s1,4
    80003eaa:	01248d63          	beq	s1,s2,80003ec4 <itrunc+0x38>
    if(ip->addrs[i]){
    80003eae:	408c                	lw	a1,0(s1)
    80003eb0:	dde5                	beqz	a1,80003ea8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003eb2:	0009a503          	lw	a0,0(s3)
    80003eb6:	00000097          	auipc	ra,0x0
    80003eba:	8f4080e7          	jalr	-1804(ra) # 800037aa <bfree>
      ip->addrs[i] = 0;
    80003ebe:	0004a023          	sw	zero,0(s1)
    80003ec2:	b7dd                	j	80003ea8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ec4:	0809a583          	lw	a1,128(s3)
    80003ec8:	e185                	bnez	a1,80003ee8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003eca:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ece:	854e                	mv	a0,s3
    80003ed0:	00000097          	auipc	ra,0x0
    80003ed4:	de4080e7          	jalr	-540(ra) # 80003cb4 <iupdate>
}
    80003ed8:	70a2                	ld	ra,40(sp)
    80003eda:	7402                	ld	s0,32(sp)
    80003edc:	64e2                	ld	s1,24(sp)
    80003ede:	6942                	ld	s2,16(sp)
    80003ee0:	69a2                	ld	s3,8(sp)
    80003ee2:	6a02                	ld	s4,0(sp)
    80003ee4:	6145                	addi	sp,sp,48
    80003ee6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ee8:	0009a503          	lw	a0,0(s3)
    80003eec:	fffff097          	auipc	ra,0xfffff
    80003ef0:	678080e7          	jalr	1656(ra) # 80003564 <bread>
    80003ef4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ef6:	05850493          	addi	s1,a0,88
    80003efa:	45850913          	addi	s2,a0,1112
    80003efe:	a021                	j	80003f06 <itrunc+0x7a>
    80003f00:	0491                	addi	s1,s1,4
    80003f02:	01248b63          	beq	s1,s2,80003f18 <itrunc+0x8c>
      if(a[j])
    80003f06:	408c                	lw	a1,0(s1)
    80003f08:	dde5                	beqz	a1,80003f00 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003f0a:	0009a503          	lw	a0,0(s3)
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	89c080e7          	jalr	-1892(ra) # 800037aa <bfree>
    80003f16:	b7ed                	j	80003f00 <itrunc+0x74>
    brelse(bp);
    80003f18:	8552                	mv	a0,s4
    80003f1a:	fffff097          	auipc	ra,0xfffff
    80003f1e:	77a080e7          	jalr	1914(ra) # 80003694 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f22:	0809a583          	lw	a1,128(s3)
    80003f26:	0009a503          	lw	a0,0(s3)
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	880080e7          	jalr	-1920(ra) # 800037aa <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f32:	0809a023          	sw	zero,128(s3)
    80003f36:	bf51                	j	80003eca <itrunc+0x3e>

0000000080003f38 <iput>:
{
    80003f38:	1101                	addi	sp,sp,-32
    80003f3a:	ec06                	sd	ra,24(sp)
    80003f3c:	e822                	sd	s0,16(sp)
    80003f3e:	e426                	sd	s1,8(sp)
    80003f40:	e04a                	sd	s2,0(sp)
    80003f42:	1000                	addi	s0,sp,32
    80003f44:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f46:	0001c517          	auipc	a0,0x1c
    80003f4a:	77250513          	addi	a0,a0,1906 # 800206b8 <itable>
    80003f4e:	ffffd097          	auipc	ra,0xffffd
    80003f52:	c88080e7          	jalr	-888(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f56:	4498                	lw	a4,8(s1)
    80003f58:	4785                	li	a5,1
    80003f5a:	02f70363          	beq	a4,a5,80003f80 <iput+0x48>
  ip->ref--;
    80003f5e:	449c                	lw	a5,8(s1)
    80003f60:	37fd                	addiw	a5,a5,-1
    80003f62:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f64:	0001c517          	auipc	a0,0x1c
    80003f68:	75450513          	addi	a0,a0,1876 # 800206b8 <itable>
    80003f6c:	ffffd097          	auipc	ra,0xffffd
    80003f70:	d1e080e7          	jalr	-738(ra) # 80000c8a <release>
}
    80003f74:	60e2                	ld	ra,24(sp)
    80003f76:	6442                	ld	s0,16(sp)
    80003f78:	64a2                	ld	s1,8(sp)
    80003f7a:	6902                	ld	s2,0(sp)
    80003f7c:	6105                	addi	sp,sp,32
    80003f7e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f80:	40bc                	lw	a5,64(s1)
    80003f82:	dff1                	beqz	a5,80003f5e <iput+0x26>
    80003f84:	04a49783          	lh	a5,74(s1)
    80003f88:	fbf9                	bnez	a5,80003f5e <iput+0x26>
    acquiresleep(&ip->lock);
    80003f8a:	01048913          	addi	s2,s1,16
    80003f8e:	854a                	mv	a0,s2
    80003f90:	00001097          	auipc	ra,0x1
    80003f94:	aa8080e7          	jalr	-1368(ra) # 80004a38 <acquiresleep>
    release(&itable.lock);
    80003f98:	0001c517          	auipc	a0,0x1c
    80003f9c:	72050513          	addi	a0,a0,1824 # 800206b8 <itable>
    80003fa0:	ffffd097          	auipc	ra,0xffffd
    80003fa4:	cea080e7          	jalr	-790(ra) # 80000c8a <release>
    itrunc(ip);
    80003fa8:	8526                	mv	a0,s1
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	ee2080e7          	jalr	-286(ra) # 80003e8c <itrunc>
    ip->type = 0;
    80003fb2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003fb6:	8526                	mv	a0,s1
    80003fb8:	00000097          	auipc	ra,0x0
    80003fbc:	cfc080e7          	jalr	-772(ra) # 80003cb4 <iupdate>
    ip->valid = 0;
    80003fc0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	00001097          	auipc	ra,0x1
    80003fca:	ac8080e7          	jalr	-1336(ra) # 80004a8e <releasesleep>
    acquire(&itable.lock);
    80003fce:	0001c517          	auipc	a0,0x1c
    80003fd2:	6ea50513          	addi	a0,a0,1770 # 800206b8 <itable>
    80003fd6:	ffffd097          	auipc	ra,0xffffd
    80003fda:	c00080e7          	jalr	-1024(ra) # 80000bd6 <acquire>
    80003fde:	b741                	j	80003f5e <iput+0x26>

0000000080003fe0 <iunlockput>:
{
    80003fe0:	1101                	addi	sp,sp,-32
    80003fe2:	ec06                	sd	ra,24(sp)
    80003fe4:	e822                	sd	s0,16(sp)
    80003fe6:	e426                	sd	s1,8(sp)
    80003fe8:	1000                	addi	s0,sp,32
    80003fea:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fec:	00000097          	auipc	ra,0x0
    80003ff0:	e54080e7          	jalr	-428(ra) # 80003e40 <iunlock>
  iput(ip);
    80003ff4:	8526                	mv	a0,s1
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	f42080e7          	jalr	-190(ra) # 80003f38 <iput>
}
    80003ffe:	60e2                	ld	ra,24(sp)
    80004000:	6442                	ld	s0,16(sp)
    80004002:	64a2                	ld	s1,8(sp)
    80004004:	6105                	addi	sp,sp,32
    80004006:	8082                	ret

0000000080004008 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004008:	1141                	addi	sp,sp,-16
    8000400a:	e422                	sd	s0,8(sp)
    8000400c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000400e:	411c                	lw	a5,0(a0)
    80004010:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004012:	415c                	lw	a5,4(a0)
    80004014:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004016:	04451783          	lh	a5,68(a0)
    8000401a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000401e:	04a51783          	lh	a5,74(a0)
    80004022:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004026:	04c56783          	lwu	a5,76(a0)
    8000402a:	e99c                	sd	a5,16(a1)
}
    8000402c:	6422                	ld	s0,8(sp)
    8000402e:	0141                	addi	sp,sp,16
    80004030:	8082                	ret

0000000080004032 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004032:	457c                	lw	a5,76(a0)
    80004034:	0ed7e963          	bltu	a5,a3,80004126 <readi+0xf4>
{
    80004038:	7159                	addi	sp,sp,-112
    8000403a:	f486                	sd	ra,104(sp)
    8000403c:	f0a2                	sd	s0,96(sp)
    8000403e:	eca6                	sd	s1,88(sp)
    80004040:	e8ca                	sd	s2,80(sp)
    80004042:	e4ce                	sd	s3,72(sp)
    80004044:	e0d2                	sd	s4,64(sp)
    80004046:	fc56                	sd	s5,56(sp)
    80004048:	f85a                	sd	s6,48(sp)
    8000404a:	f45e                	sd	s7,40(sp)
    8000404c:	f062                	sd	s8,32(sp)
    8000404e:	ec66                	sd	s9,24(sp)
    80004050:	e86a                	sd	s10,16(sp)
    80004052:	e46e                	sd	s11,8(sp)
    80004054:	1880                	addi	s0,sp,112
    80004056:	8b2a                	mv	s6,a0
    80004058:	8bae                	mv	s7,a1
    8000405a:	8a32                	mv	s4,a2
    8000405c:	84b6                	mv	s1,a3
    8000405e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004060:	9f35                	addw	a4,a4,a3
    return 0;
    80004062:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004064:	0ad76063          	bltu	a4,a3,80004104 <readi+0xd2>
  if(off + n > ip->size)
    80004068:	00e7f463          	bgeu	a5,a4,80004070 <readi+0x3e>
    n = ip->size - off;
    8000406c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004070:	0a0a8963          	beqz	s5,80004122 <readi+0xf0>
    80004074:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004076:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000407a:	5c7d                	li	s8,-1
    8000407c:	a82d                	j	800040b6 <readi+0x84>
    8000407e:	020d1d93          	slli	s11,s10,0x20
    80004082:	020ddd93          	srli	s11,s11,0x20
    80004086:	05890793          	addi	a5,s2,88
    8000408a:	86ee                	mv	a3,s11
    8000408c:	963e                	add	a2,a2,a5
    8000408e:	85d2                	mv	a1,s4
    80004090:	855e                	mv	a0,s7
    80004092:	ffffe097          	auipc	ra,0xffffe
    80004096:	6a2080e7          	jalr	1698(ra) # 80002734 <either_copyout>
    8000409a:	05850d63          	beq	a0,s8,800040f4 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000409e:	854a                	mv	a0,s2
    800040a0:	fffff097          	auipc	ra,0xfffff
    800040a4:	5f4080e7          	jalr	1524(ra) # 80003694 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040a8:	013d09bb          	addw	s3,s10,s3
    800040ac:	009d04bb          	addw	s1,s10,s1
    800040b0:	9a6e                	add	s4,s4,s11
    800040b2:	0559f763          	bgeu	s3,s5,80004100 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800040b6:	00a4d59b          	srliw	a1,s1,0xa
    800040ba:	855a                	mv	a0,s6
    800040bc:	00000097          	auipc	ra,0x0
    800040c0:	8a2080e7          	jalr	-1886(ra) # 8000395e <bmap>
    800040c4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800040c8:	cd85                	beqz	a1,80004100 <readi+0xce>
    bp = bread(ip->dev, addr);
    800040ca:	000b2503          	lw	a0,0(s6)
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	496080e7          	jalr	1174(ra) # 80003564 <bread>
    800040d6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040d8:	3ff4f613          	andi	a2,s1,1023
    800040dc:	40cc87bb          	subw	a5,s9,a2
    800040e0:	413a873b          	subw	a4,s5,s3
    800040e4:	8d3e                	mv	s10,a5
    800040e6:	2781                	sext.w	a5,a5
    800040e8:	0007069b          	sext.w	a3,a4
    800040ec:	f8f6f9e3          	bgeu	a3,a5,8000407e <readi+0x4c>
    800040f0:	8d3a                	mv	s10,a4
    800040f2:	b771                	j	8000407e <readi+0x4c>
      brelse(bp);
    800040f4:	854a                	mv	a0,s2
    800040f6:	fffff097          	auipc	ra,0xfffff
    800040fa:	59e080e7          	jalr	1438(ra) # 80003694 <brelse>
      tot = -1;
    800040fe:	59fd                	li	s3,-1
  }
  return tot;
    80004100:	0009851b          	sext.w	a0,s3
}
    80004104:	70a6                	ld	ra,104(sp)
    80004106:	7406                	ld	s0,96(sp)
    80004108:	64e6                	ld	s1,88(sp)
    8000410a:	6946                	ld	s2,80(sp)
    8000410c:	69a6                	ld	s3,72(sp)
    8000410e:	6a06                	ld	s4,64(sp)
    80004110:	7ae2                	ld	s5,56(sp)
    80004112:	7b42                	ld	s6,48(sp)
    80004114:	7ba2                	ld	s7,40(sp)
    80004116:	7c02                	ld	s8,32(sp)
    80004118:	6ce2                	ld	s9,24(sp)
    8000411a:	6d42                	ld	s10,16(sp)
    8000411c:	6da2                	ld	s11,8(sp)
    8000411e:	6165                	addi	sp,sp,112
    80004120:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004122:	89d6                	mv	s3,s5
    80004124:	bff1                	j	80004100 <readi+0xce>
    return 0;
    80004126:	4501                	li	a0,0
}
    80004128:	8082                	ret

000000008000412a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000412a:	457c                	lw	a5,76(a0)
    8000412c:	10d7e863          	bltu	a5,a3,8000423c <writei+0x112>
{
    80004130:	7159                	addi	sp,sp,-112
    80004132:	f486                	sd	ra,104(sp)
    80004134:	f0a2                	sd	s0,96(sp)
    80004136:	eca6                	sd	s1,88(sp)
    80004138:	e8ca                	sd	s2,80(sp)
    8000413a:	e4ce                	sd	s3,72(sp)
    8000413c:	e0d2                	sd	s4,64(sp)
    8000413e:	fc56                	sd	s5,56(sp)
    80004140:	f85a                	sd	s6,48(sp)
    80004142:	f45e                	sd	s7,40(sp)
    80004144:	f062                	sd	s8,32(sp)
    80004146:	ec66                	sd	s9,24(sp)
    80004148:	e86a                	sd	s10,16(sp)
    8000414a:	e46e                	sd	s11,8(sp)
    8000414c:	1880                	addi	s0,sp,112
    8000414e:	8aaa                	mv	s5,a0
    80004150:	8bae                	mv	s7,a1
    80004152:	8a32                	mv	s4,a2
    80004154:	8936                	mv	s2,a3
    80004156:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004158:	00e687bb          	addw	a5,a3,a4
    8000415c:	0ed7e263          	bltu	a5,a3,80004240 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004160:	00043737          	lui	a4,0x43
    80004164:	0ef76063          	bltu	a4,a5,80004244 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004168:	0c0b0863          	beqz	s6,80004238 <writei+0x10e>
    8000416c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000416e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004172:	5c7d                	li	s8,-1
    80004174:	a091                	j	800041b8 <writei+0x8e>
    80004176:	020d1d93          	slli	s11,s10,0x20
    8000417a:	020ddd93          	srli	s11,s11,0x20
    8000417e:	05848793          	addi	a5,s1,88
    80004182:	86ee                	mv	a3,s11
    80004184:	8652                	mv	a2,s4
    80004186:	85de                	mv	a1,s7
    80004188:	953e                	add	a0,a0,a5
    8000418a:	ffffe097          	auipc	ra,0xffffe
    8000418e:	600080e7          	jalr	1536(ra) # 8000278a <either_copyin>
    80004192:	07850263          	beq	a0,s8,800041f6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004196:	8526                	mv	a0,s1
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	780080e7          	jalr	1920(ra) # 80004918 <log_write>
    brelse(bp);
    800041a0:	8526                	mv	a0,s1
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	4f2080e7          	jalr	1266(ra) # 80003694 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041aa:	013d09bb          	addw	s3,s10,s3
    800041ae:	012d093b          	addw	s2,s10,s2
    800041b2:	9a6e                	add	s4,s4,s11
    800041b4:	0569f663          	bgeu	s3,s6,80004200 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800041b8:	00a9559b          	srliw	a1,s2,0xa
    800041bc:	8556                	mv	a0,s5
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	7a0080e7          	jalr	1952(ra) # 8000395e <bmap>
    800041c6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800041ca:	c99d                	beqz	a1,80004200 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800041cc:	000aa503          	lw	a0,0(s5)
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	394080e7          	jalr	916(ra) # 80003564 <bread>
    800041d8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041da:	3ff97513          	andi	a0,s2,1023
    800041de:	40ac87bb          	subw	a5,s9,a0
    800041e2:	413b073b          	subw	a4,s6,s3
    800041e6:	8d3e                	mv	s10,a5
    800041e8:	2781                	sext.w	a5,a5
    800041ea:	0007069b          	sext.w	a3,a4
    800041ee:	f8f6f4e3          	bgeu	a3,a5,80004176 <writei+0x4c>
    800041f2:	8d3a                	mv	s10,a4
    800041f4:	b749                	j	80004176 <writei+0x4c>
      brelse(bp);
    800041f6:	8526                	mv	a0,s1
    800041f8:	fffff097          	auipc	ra,0xfffff
    800041fc:	49c080e7          	jalr	1180(ra) # 80003694 <brelse>
  }

  if(off > ip->size)
    80004200:	04caa783          	lw	a5,76(s5)
    80004204:	0127f463          	bgeu	a5,s2,8000420c <writei+0xe2>
    ip->size = off;
    80004208:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000420c:	8556                	mv	a0,s5
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	aa6080e7          	jalr	-1370(ra) # 80003cb4 <iupdate>

  return tot;
    80004216:	0009851b          	sext.w	a0,s3
}
    8000421a:	70a6                	ld	ra,104(sp)
    8000421c:	7406                	ld	s0,96(sp)
    8000421e:	64e6                	ld	s1,88(sp)
    80004220:	6946                	ld	s2,80(sp)
    80004222:	69a6                	ld	s3,72(sp)
    80004224:	6a06                	ld	s4,64(sp)
    80004226:	7ae2                	ld	s5,56(sp)
    80004228:	7b42                	ld	s6,48(sp)
    8000422a:	7ba2                	ld	s7,40(sp)
    8000422c:	7c02                	ld	s8,32(sp)
    8000422e:	6ce2                	ld	s9,24(sp)
    80004230:	6d42                	ld	s10,16(sp)
    80004232:	6da2                	ld	s11,8(sp)
    80004234:	6165                	addi	sp,sp,112
    80004236:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004238:	89da                	mv	s3,s6
    8000423a:	bfc9                	j	8000420c <writei+0xe2>
    return -1;
    8000423c:	557d                	li	a0,-1
}
    8000423e:	8082                	ret
    return -1;
    80004240:	557d                	li	a0,-1
    80004242:	bfe1                	j	8000421a <writei+0xf0>
    return -1;
    80004244:	557d                	li	a0,-1
    80004246:	bfd1                	j	8000421a <writei+0xf0>

0000000080004248 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004248:	1141                	addi	sp,sp,-16
    8000424a:	e406                	sd	ra,8(sp)
    8000424c:	e022                	sd	s0,0(sp)
    8000424e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004250:	4639                	li	a2,14
    80004252:	ffffd097          	auipc	ra,0xffffd
    80004256:	b50080e7          	jalr	-1200(ra) # 80000da2 <strncmp>
}
    8000425a:	60a2                	ld	ra,8(sp)
    8000425c:	6402                	ld	s0,0(sp)
    8000425e:	0141                	addi	sp,sp,16
    80004260:	8082                	ret

0000000080004262 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004262:	7139                	addi	sp,sp,-64
    80004264:	fc06                	sd	ra,56(sp)
    80004266:	f822                	sd	s0,48(sp)
    80004268:	f426                	sd	s1,40(sp)
    8000426a:	f04a                	sd	s2,32(sp)
    8000426c:	ec4e                	sd	s3,24(sp)
    8000426e:	e852                	sd	s4,16(sp)
    80004270:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004272:	04451703          	lh	a4,68(a0)
    80004276:	4785                	li	a5,1
    80004278:	00f71a63          	bne	a4,a5,8000428c <dirlookup+0x2a>
    8000427c:	892a                	mv	s2,a0
    8000427e:	89ae                	mv	s3,a1
    80004280:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004282:	457c                	lw	a5,76(a0)
    80004284:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004286:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004288:	e79d                	bnez	a5,800042b6 <dirlookup+0x54>
    8000428a:	a8a5                	j	80004302 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000428c:	00004517          	auipc	a0,0x4
    80004290:	39450513          	addi	a0,a0,916 # 80008620 <syscalls+0x1c0>
    80004294:	ffffc097          	auipc	ra,0xffffc
    80004298:	2aa080e7          	jalr	682(ra) # 8000053e <panic>
      panic("dirlookup read");
    8000429c:	00004517          	auipc	a0,0x4
    800042a0:	39c50513          	addi	a0,a0,924 # 80008638 <syscalls+0x1d8>
    800042a4:	ffffc097          	auipc	ra,0xffffc
    800042a8:	29a080e7          	jalr	666(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042ac:	24c1                	addiw	s1,s1,16
    800042ae:	04c92783          	lw	a5,76(s2)
    800042b2:	04f4f763          	bgeu	s1,a5,80004300 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042b6:	4741                	li	a4,16
    800042b8:	86a6                	mv	a3,s1
    800042ba:	fc040613          	addi	a2,s0,-64
    800042be:	4581                	li	a1,0
    800042c0:	854a                	mv	a0,s2
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	d70080e7          	jalr	-656(ra) # 80004032 <readi>
    800042ca:	47c1                	li	a5,16
    800042cc:	fcf518e3          	bne	a0,a5,8000429c <dirlookup+0x3a>
    if(de.inum == 0)
    800042d0:	fc045783          	lhu	a5,-64(s0)
    800042d4:	dfe1                	beqz	a5,800042ac <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800042d6:	fc240593          	addi	a1,s0,-62
    800042da:	854e                	mv	a0,s3
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	f6c080e7          	jalr	-148(ra) # 80004248 <namecmp>
    800042e4:	f561                	bnez	a0,800042ac <dirlookup+0x4a>
      if(poff)
    800042e6:	000a0463          	beqz	s4,800042ee <dirlookup+0x8c>
        *poff = off;
    800042ea:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800042ee:	fc045583          	lhu	a1,-64(s0)
    800042f2:	00092503          	lw	a0,0(s2)
    800042f6:	fffff097          	auipc	ra,0xfffff
    800042fa:	750080e7          	jalr	1872(ra) # 80003a46 <iget>
    800042fe:	a011                	j	80004302 <dirlookup+0xa0>
  return 0;
    80004300:	4501                	li	a0,0
}
    80004302:	70e2                	ld	ra,56(sp)
    80004304:	7442                	ld	s0,48(sp)
    80004306:	74a2                	ld	s1,40(sp)
    80004308:	7902                	ld	s2,32(sp)
    8000430a:	69e2                	ld	s3,24(sp)
    8000430c:	6a42                	ld	s4,16(sp)
    8000430e:	6121                	addi	sp,sp,64
    80004310:	8082                	ret

0000000080004312 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004312:	711d                	addi	sp,sp,-96
    80004314:	ec86                	sd	ra,88(sp)
    80004316:	e8a2                	sd	s0,80(sp)
    80004318:	e4a6                	sd	s1,72(sp)
    8000431a:	e0ca                	sd	s2,64(sp)
    8000431c:	fc4e                	sd	s3,56(sp)
    8000431e:	f852                	sd	s4,48(sp)
    80004320:	f456                	sd	s5,40(sp)
    80004322:	f05a                	sd	s6,32(sp)
    80004324:	ec5e                	sd	s7,24(sp)
    80004326:	e862                	sd	s8,16(sp)
    80004328:	e466                	sd	s9,8(sp)
    8000432a:	1080                	addi	s0,sp,96
    8000432c:	84aa                	mv	s1,a0
    8000432e:	8aae                	mv	s5,a1
    80004330:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004332:	00054703          	lbu	a4,0(a0)
    80004336:	02f00793          	li	a5,47
    8000433a:	02f70363          	beq	a4,a5,80004360 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000433e:	ffffe097          	auipc	ra,0xffffe
    80004342:	812080e7          	jalr	-2030(ra) # 80001b50 <myproc>
    80004346:	16053503          	ld	a0,352(a0)
    8000434a:	00000097          	auipc	ra,0x0
    8000434e:	9f6080e7          	jalr	-1546(ra) # 80003d40 <idup>
    80004352:	89aa                	mv	s3,a0
  while(*path == '/')
    80004354:	02f00913          	li	s2,47
  len = path - s;
    80004358:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000435a:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000435c:	4b85                	li	s7,1
    8000435e:	a865                	j	80004416 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004360:	4585                	li	a1,1
    80004362:	4505                	li	a0,1
    80004364:	fffff097          	auipc	ra,0xfffff
    80004368:	6e2080e7          	jalr	1762(ra) # 80003a46 <iget>
    8000436c:	89aa                	mv	s3,a0
    8000436e:	b7dd                	j	80004354 <namex+0x42>
      iunlockput(ip);
    80004370:	854e                	mv	a0,s3
    80004372:	00000097          	auipc	ra,0x0
    80004376:	c6e080e7          	jalr	-914(ra) # 80003fe0 <iunlockput>
      return 0;
    8000437a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000437c:	854e                	mv	a0,s3
    8000437e:	60e6                	ld	ra,88(sp)
    80004380:	6446                	ld	s0,80(sp)
    80004382:	64a6                	ld	s1,72(sp)
    80004384:	6906                	ld	s2,64(sp)
    80004386:	79e2                	ld	s3,56(sp)
    80004388:	7a42                	ld	s4,48(sp)
    8000438a:	7aa2                	ld	s5,40(sp)
    8000438c:	7b02                	ld	s6,32(sp)
    8000438e:	6be2                	ld	s7,24(sp)
    80004390:	6c42                	ld	s8,16(sp)
    80004392:	6ca2                	ld	s9,8(sp)
    80004394:	6125                	addi	sp,sp,96
    80004396:	8082                	ret
      iunlock(ip);
    80004398:	854e                	mv	a0,s3
    8000439a:	00000097          	auipc	ra,0x0
    8000439e:	aa6080e7          	jalr	-1370(ra) # 80003e40 <iunlock>
      return ip;
    800043a2:	bfe9                	j	8000437c <namex+0x6a>
      iunlockput(ip);
    800043a4:	854e                	mv	a0,s3
    800043a6:	00000097          	auipc	ra,0x0
    800043aa:	c3a080e7          	jalr	-966(ra) # 80003fe0 <iunlockput>
      return 0;
    800043ae:	89e6                	mv	s3,s9
    800043b0:	b7f1                	j	8000437c <namex+0x6a>
  len = path - s;
    800043b2:	40b48633          	sub	a2,s1,a1
    800043b6:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800043ba:	099c5463          	bge	s8,s9,80004442 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800043be:	4639                	li	a2,14
    800043c0:	8552                	mv	a0,s4
    800043c2:	ffffd097          	auipc	ra,0xffffd
    800043c6:	96c080e7          	jalr	-1684(ra) # 80000d2e <memmove>
  while(*path == '/')
    800043ca:	0004c783          	lbu	a5,0(s1)
    800043ce:	01279763          	bne	a5,s2,800043dc <namex+0xca>
    path++;
    800043d2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043d4:	0004c783          	lbu	a5,0(s1)
    800043d8:	ff278de3          	beq	a5,s2,800043d2 <namex+0xc0>
    ilock(ip);
    800043dc:	854e                	mv	a0,s3
    800043de:	00000097          	auipc	ra,0x0
    800043e2:	9a0080e7          	jalr	-1632(ra) # 80003d7e <ilock>
    if(ip->type != T_DIR){
    800043e6:	04499783          	lh	a5,68(s3)
    800043ea:	f97793e3          	bne	a5,s7,80004370 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800043ee:	000a8563          	beqz	s5,800043f8 <namex+0xe6>
    800043f2:	0004c783          	lbu	a5,0(s1)
    800043f6:	d3cd                	beqz	a5,80004398 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800043f8:	865a                	mv	a2,s6
    800043fa:	85d2                	mv	a1,s4
    800043fc:	854e                	mv	a0,s3
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	e64080e7          	jalr	-412(ra) # 80004262 <dirlookup>
    80004406:	8caa                	mv	s9,a0
    80004408:	dd51                	beqz	a0,800043a4 <namex+0x92>
    iunlockput(ip);
    8000440a:	854e                	mv	a0,s3
    8000440c:	00000097          	auipc	ra,0x0
    80004410:	bd4080e7          	jalr	-1068(ra) # 80003fe0 <iunlockput>
    ip = next;
    80004414:	89e6                	mv	s3,s9
  while(*path == '/')
    80004416:	0004c783          	lbu	a5,0(s1)
    8000441a:	05279763          	bne	a5,s2,80004468 <namex+0x156>
    path++;
    8000441e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004420:	0004c783          	lbu	a5,0(s1)
    80004424:	ff278de3          	beq	a5,s2,8000441e <namex+0x10c>
  if(*path == 0)
    80004428:	c79d                	beqz	a5,80004456 <namex+0x144>
    path++;
    8000442a:	85a6                	mv	a1,s1
  len = path - s;
    8000442c:	8cda                	mv	s9,s6
    8000442e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004430:	01278963          	beq	a5,s2,80004442 <namex+0x130>
    80004434:	dfbd                	beqz	a5,800043b2 <namex+0xa0>
    path++;
    80004436:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004438:	0004c783          	lbu	a5,0(s1)
    8000443c:	ff279ce3          	bne	a5,s2,80004434 <namex+0x122>
    80004440:	bf8d                	j	800043b2 <namex+0xa0>
    memmove(name, s, len);
    80004442:	2601                	sext.w	a2,a2
    80004444:	8552                	mv	a0,s4
    80004446:	ffffd097          	auipc	ra,0xffffd
    8000444a:	8e8080e7          	jalr	-1816(ra) # 80000d2e <memmove>
    name[len] = 0;
    8000444e:	9cd2                	add	s9,s9,s4
    80004450:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004454:	bf9d                	j	800043ca <namex+0xb8>
  if(nameiparent){
    80004456:	f20a83e3          	beqz	s5,8000437c <namex+0x6a>
    iput(ip);
    8000445a:	854e                	mv	a0,s3
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	adc080e7          	jalr	-1316(ra) # 80003f38 <iput>
    return 0;
    80004464:	4981                	li	s3,0
    80004466:	bf19                	j	8000437c <namex+0x6a>
  if(*path == 0)
    80004468:	d7fd                	beqz	a5,80004456 <namex+0x144>
  while(*path != '/' && *path != 0)
    8000446a:	0004c783          	lbu	a5,0(s1)
    8000446e:	85a6                	mv	a1,s1
    80004470:	b7d1                	j	80004434 <namex+0x122>

0000000080004472 <dirlink>:
{
    80004472:	7139                	addi	sp,sp,-64
    80004474:	fc06                	sd	ra,56(sp)
    80004476:	f822                	sd	s0,48(sp)
    80004478:	f426                	sd	s1,40(sp)
    8000447a:	f04a                	sd	s2,32(sp)
    8000447c:	ec4e                	sd	s3,24(sp)
    8000447e:	e852                	sd	s4,16(sp)
    80004480:	0080                	addi	s0,sp,64
    80004482:	892a                	mv	s2,a0
    80004484:	8a2e                	mv	s4,a1
    80004486:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004488:	4601                	li	a2,0
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	dd8080e7          	jalr	-552(ra) # 80004262 <dirlookup>
    80004492:	e93d                	bnez	a0,80004508 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004494:	04c92483          	lw	s1,76(s2)
    80004498:	c49d                	beqz	s1,800044c6 <dirlink+0x54>
    8000449a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000449c:	4741                	li	a4,16
    8000449e:	86a6                	mv	a3,s1
    800044a0:	fc040613          	addi	a2,s0,-64
    800044a4:	4581                	li	a1,0
    800044a6:	854a                	mv	a0,s2
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	b8a080e7          	jalr	-1142(ra) # 80004032 <readi>
    800044b0:	47c1                	li	a5,16
    800044b2:	06f51163          	bne	a0,a5,80004514 <dirlink+0xa2>
    if(de.inum == 0)
    800044b6:	fc045783          	lhu	a5,-64(s0)
    800044ba:	c791                	beqz	a5,800044c6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044bc:	24c1                	addiw	s1,s1,16
    800044be:	04c92783          	lw	a5,76(s2)
    800044c2:	fcf4ede3          	bltu	s1,a5,8000449c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800044c6:	4639                	li	a2,14
    800044c8:	85d2                	mv	a1,s4
    800044ca:	fc240513          	addi	a0,s0,-62
    800044ce:	ffffd097          	auipc	ra,0xffffd
    800044d2:	910080e7          	jalr	-1776(ra) # 80000dde <strncpy>
  de.inum = inum;
    800044d6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044da:	4741                	li	a4,16
    800044dc:	86a6                	mv	a3,s1
    800044de:	fc040613          	addi	a2,s0,-64
    800044e2:	4581                	li	a1,0
    800044e4:	854a                	mv	a0,s2
    800044e6:	00000097          	auipc	ra,0x0
    800044ea:	c44080e7          	jalr	-956(ra) # 8000412a <writei>
    800044ee:	1541                	addi	a0,a0,-16
    800044f0:	00a03533          	snez	a0,a0
    800044f4:	40a00533          	neg	a0,a0
}
    800044f8:	70e2                	ld	ra,56(sp)
    800044fa:	7442                	ld	s0,48(sp)
    800044fc:	74a2                	ld	s1,40(sp)
    800044fe:	7902                	ld	s2,32(sp)
    80004500:	69e2                	ld	s3,24(sp)
    80004502:	6a42                	ld	s4,16(sp)
    80004504:	6121                	addi	sp,sp,64
    80004506:	8082                	ret
    iput(ip);
    80004508:	00000097          	auipc	ra,0x0
    8000450c:	a30080e7          	jalr	-1488(ra) # 80003f38 <iput>
    return -1;
    80004510:	557d                	li	a0,-1
    80004512:	b7dd                	j	800044f8 <dirlink+0x86>
      panic("dirlink read");
    80004514:	00004517          	auipc	a0,0x4
    80004518:	13450513          	addi	a0,a0,308 # 80008648 <syscalls+0x1e8>
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	022080e7          	jalr	34(ra) # 8000053e <panic>

0000000080004524 <namei>:

struct inode*
namei(char *path)
{
    80004524:	1101                	addi	sp,sp,-32
    80004526:	ec06                	sd	ra,24(sp)
    80004528:	e822                	sd	s0,16(sp)
    8000452a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000452c:	fe040613          	addi	a2,s0,-32
    80004530:	4581                	li	a1,0
    80004532:	00000097          	auipc	ra,0x0
    80004536:	de0080e7          	jalr	-544(ra) # 80004312 <namex>
}
    8000453a:	60e2                	ld	ra,24(sp)
    8000453c:	6442                	ld	s0,16(sp)
    8000453e:	6105                	addi	sp,sp,32
    80004540:	8082                	ret

0000000080004542 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004542:	1141                	addi	sp,sp,-16
    80004544:	e406                	sd	ra,8(sp)
    80004546:	e022                	sd	s0,0(sp)
    80004548:	0800                	addi	s0,sp,16
    8000454a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000454c:	4585                	li	a1,1
    8000454e:	00000097          	auipc	ra,0x0
    80004552:	dc4080e7          	jalr	-572(ra) # 80004312 <namex>
}
    80004556:	60a2                	ld	ra,8(sp)
    80004558:	6402                	ld	s0,0(sp)
    8000455a:	0141                	addi	sp,sp,16
    8000455c:	8082                	ret

000000008000455e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000455e:	1101                	addi	sp,sp,-32
    80004560:	ec06                	sd	ra,24(sp)
    80004562:	e822                	sd	s0,16(sp)
    80004564:	e426                	sd	s1,8(sp)
    80004566:	e04a                	sd	s2,0(sp)
    80004568:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000456a:	0001e917          	auipc	s2,0x1e
    8000456e:	bf690913          	addi	s2,s2,-1034 # 80022160 <log>
    80004572:	01892583          	lw	a1,24(s2)
    80004576:	02892503          	lw	a0,40(s2)
    8000457a:	fffff097          	auipc	ra,0xfffff
    8000457e:	fea080e7          	jalr	-22(ra) # 80003564 <bread>
    80004582:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004584:	02c92683          	lw	a3,44(s2)
    80004588:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000458a:	02d05763          	blez	a3,800045b8 <write_head+0x5a>
    8000458e:	0001e797          	auipc	a5,0x1e
    80004592:	c0278793          	addi	a5,a5,-1022 # 80022190 <log+0x30>
    80004596:	05c50713          	addi	a4,a0,92
    8000459a:	36fd                	addiw	a3,a3,-1
    8000459c:	1682                	slli	a3,a3,0x20
    8000459e:	9281                	srli	a3,a3,0x20
    800045a0:	068a                	slli	a3,a3,0x2
    800045a2:	0001e617          	auipc	a2,0x1e
    800045a6:	bf260613          	addi	a2,a2,-1038 # 80022194 <log+0x34>
    800045aa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800045ac:	4390                	lw	a2,0(a5)
    800045ae:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045b0:	0791                	addi	a5,a5,4
    800045b2:	0711                	addi	a4,a4,4
    800045b4:	fed79ce3          	bne	a5,a3,800045ac <write_head+0x4e>
  }
  bwrite(buf);
    800045b8:	8526                	mv	a0,s1
    800045ba:	fffff097          	auipc	ra,0xfffff
    800045be:	09c080e7          	jalr	156(ra) # 80003656 <bwrite>
  brelse(buf);
    800045c2:	8526                	mv	a0,s1
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	0d0080e7          	jalr	208(ra) # 80003694 <brelse>
}
    800045cc:	60e2                	ld	ra,24(sp)
    800045ce:	6442                	ld	s0,16(sp)
    800045d0:	64a2                	ld	s1,8(sp)
    800045d2:	6902                	ld	s2,0(sp)
    800045d4:	6105                	addi	sp,sp,32
    800045d6:	8082                	ret

00000000800045d8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800045d8:	0001e797          	auipc	a5,0x1e
    800045dc:	bb47a783          	lw	a5,-1100(a5) # 8002218c <log+0x2c>
    800045e0:	0af05d63          	blez	a5,8000469a <install_trans+0xc2>
{
    800045e4:	7139                	addi	sp,sp,-64
    800045e6:	fc06                	sd	ra,56(sp)
    800045e8:	f822                	sd	s0,48(sp)
    800045ea:	f426                	sd	s1,40(sp)
    800045ec:	f04a                	sd	s2,32(sp)
    800045ee:	ec4e                	sd	s3,24(sp)
    800045f0:	e852                	sd	s4,16(sp)
    800045f2:	e456                	sd	s5,8(sp)
    800045f4:	e05a                	sd	s6,0(sp)
    800045f6:	0080                	addi	s0,sp,64
    800045f8:	8b2a                	mv	s6,a0
    800045fa:	0001ea97          	auipc	s5,0x1e
    800045fe:	b96a8a93          	addi	s5,s5,-1130 # 80022190 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004602:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004604:	0001e997          	auipc	s3,0x1e
    80004608:	b5c98993          	addi	s3,s3,-1188 # 80022160 <log>
    8000460c:	a00d                	j	8000462e <install_trans+0x56>
    brelse(lbuf);
    8000460e:	854a                	mv	a0,s2
    80004610:	fffff097          	auipc	ra,0xfffff
    80004614:	084080e7          	jalr	132(ra) # 80003694 <brelse>
    brelse(dbuf);
    80004618:	8526                	mv	a0,s1
    8000461a:	fffff097          	auipc	ra,0xfffff
    8000461e:	07a080e7          	jalr	122(ra) # 80003694 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004622:	2a05                	addiw	s4,s4,1
    80004624:	0a91                	addi	s5,s5,4
    80004626:	02c9a783          	lw	a5,44(s3)
    8000462a:	04fa5e63          	bge	s4,a5,80004686 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000462e:	0189a583          	lw	a1,24(s3)
    80004632:	014585bb          	addw	a1,a1,s4
    80004636:	2585                	addiw	a1,a1,1
    80004638:	0289a503          	lw	a0,40(s3)
    8000463c:	fffff097          	auipc	ra,0xfffff
    80004640:	f28080e7          	jalr	-216(ra) # 80003564 <bread>
    80004644:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004646:	000aa583          	lw	a1,0(s5)
    8000464a:	0289a503          	lw	a0,40(s3)
    8000464e:	fffff097          	auipc	ra,0xfffff
    80004652:	f16080e7          	jalr	-234(ra) # 80003564 <bread>
    80004656:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004658:	40000613          	li	a2,1024
    8000465c:	05890593          	addi	a1,s2,88
    80004660:	05850513          	addi	a0,a0,88
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	6ca080e7          	jalr	1738(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000466c:	8526                	mv	a0,s1
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	fe8080e7          	jalr	-24(ra) # 80003656 <bwrite>
    if(recovering == 0)
    80004676:	f80b1ce3          	bnez	s6,8000460e <install_trans+0x36>
      bunpin(dbuf);
    8000467a:	8526                	mv	a0,s1
    8000467c:	fffff097          	auipc	ra,0xfffff
    80004680:	0f2080e7          	jalr	242(ra) # 8000376e <bunpin>
    80004684:	b769                	j	8000460e <install_trans+0x36>
}
    80004686:	70e2                	ld	ra,56(sp)
    80004688:	7442                	ld	s0,48(sp)
    8000468a:	74a2                	ld	s1,40(sp)
    8000468c:	7902                	ld	s2,32(sp)
    8000468e:	69e2                	ld	s3,24(sp)
    80004690:	6a42                	ld	s4,16(sp)
    80004692:	6aa2                	ld	s5,8(sp)
    80004694:	6b02                	ld	s6,0(sp)
    80004696:	6121                	addi	sp,sp,64
    80004698:	8082                	ret
    8000469a:	8082                	ret

000000008000469c <initlog>:
{
    8000469c:	7179                	addi	sp,sp,-48
    8000469e:	f406                	sd	ra,40(sp)
    800046a0:	f022                	sd	s0,32(sp)
    800046a2:	ec26                	sd	s1,24(sp)
    800046a4:	e84a                	sd	s2,16(sp)
    800046a6:	e44e                	sd	s3,8(sp)
    800046a8:	1800                	addi	s0,sp,48
    800046aa:	892a                	mv	s2,a0
    800046ac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800046ae:	0001e497          	auipc	s1,0x1e
    800046b2:	ab248493          	addi	s1,s1,-1358 # 80022160 <log>
    800046b6:	00004597          	auipc	a1,0x4
    800046ba:	fa258593          	addi	a1,a1,-94 # 80008658 <syscalls+0x1f8>
    800046be:	8526                	mv	a0,s1
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	486080e7          	jalr	1158(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800046c8:	0149a583          	lw	a1,20(s3)
    800046cc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800046ce:	0109a783          	lw	a5,16(s3)
    800046d2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800046d4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800046d8:	854a                	mv	a0,s2
    800046da:	fffff097          	auipc	ra,0xfffff
    800046de:	e8a080e7          	jalr	-374(ra) # 80003564 <bread>
  log.lh.n = lh->n;
    800046e2:	4d34                	lw	a3,88(a0)
    800046e4:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800046e6:	02d05563          	blez	a3,80004710 <initlog+0x74>
    800046ea:	05c50793          	addi	a5,a0,92
    800046ee:	0001e717          	auipc	a4,0x1e
    800046f2:	aa270713          	addi	a4,a4,-1374 # 80022190 <log+0x30>
    800046f6:	36fd                	addiw	a3,a3,-1
    800046f8:	1682                	slli	a3,a3,0x20
    800046fa:	9281                	srli	a3,a3,0x20
    800046fc:	068a                	slli	a3,a3,0x2
    800046fe:	06050613          	addi	a2,a0,96
    80004702:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004704:	4390                	lw	a2,0(a5)
    80004706:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004708:	0791                	addi	a5,a5,4
    8000470a:	0711                	addi	a4,a4,4
    8000470c:	fed79ce3          	bne	a5,a3,80004704 <initlog+0x68>
  brelse(buf);
    80004710:	fffff097          	auipc	ra,0xfffff
    80004714:	f84080e7          	jalr	-124(ra) # 80003694 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004718:	4505                	li	a0,1
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	ebe080e7          	jalr	-322(ra) # 800045d8 <install_trans>
  log.lh.n = 0;
    80004722:	0001e797          	auipc	a5,0x1e
    80004726:	a607a523          	sw	zero,-1430(a5) # 8002218c <log+0x2c>
  write_head(); // clear the log
    8000472a:	00000097          	auipc	ra,0x0
    8000472e:	e34080e7          	jalr	-460(ra) # 8000455e <write_head>
}
    80004732:	70a2                	ld	ra,40(sp)
    80004734:	7402                	ld	s0,32(sp)
    80004736:	64e2                	ld	s1,24(sp)
    80004738:	6942                	ld	s2,16(sp)
    8000473a:	69a2                	ld	s3,8(sp)
    8000473c:	6145                	addi	sp,sp,48
    8000473e:	8082                	ret

0000000080004740 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004740:	1101                	addi	sp,sp,-32
    80004742:	ec06                	sd	ra,24(sp)
    80004744:	e822                	sd	s0,16(sp)
    80004746:	e426                	sd	s1,8(sp)
    80004748:	e04a                	sd	s2,0(sp)
    8000474a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000474c:	0001e517          	auipc	a0,0x1e
    80004750:	a1450513          	addi	a0,a0,-1516 # 80022160 <log>
    80004754:	ffffc097          	auipc	ra,0xffffc
    80004758:	482080e7          	jalr	1154(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000475c:	0001e497          	auipc	s1,0x1e
    80004760:	a0448493          	addi	s1,s1,-1532 # 80022160 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004764:	4979                	li	s2,30
    80004766:	a039                	j	80004774 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004768:	85a6                	mv	a1,s1
    8000476a:	8526                	mv	a0,s1
    8000476c:	ffffe097          	auipc	ra,0xffffe
    80004770:	ba8080e7          	jalr	-1112(ra) # 80002314 <sleep>
    if(log.committing){
    80004774:	50dc                	lw	a5,36(s1)
    80004776:	fbed                	bnez	a5,80004768 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004778:	509c                	lw	a5,32(s1)
    8000477a:	0017871b          	addiw	a4,a5,1
    8000477e:	0007069b          	sext.w	a3,a4
    80004782:	0027179b          	slliw	a5,a4,0x2
    80004786:	9fb9                	addw	a5,a5,a4
    80004788:	0017979b          	slliw	a5,a5,0x1
    8000478c:	54d8                	lw	a4,44(s1)
    8000478e:	9fb9                	addw	a5,a5,a4
    80004790:	00f95963          	bge	s2,a5,800047a2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004794:	85a6                	mv	a1,s1
    80004796:	8526                	mv	a0,s1
    80004798:	ffffe097          	auipc	ra,0xffffe
    8000479c:	b7c080e7          	jalr	-1156(ra) # 80002314 <sleep>
    800047a0:	bfd1                	j	80004774 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800047a2:	0001e517          	auipc	a0,0x1e
    800047a6:	9be50513          	addi	a0,a0,-1602 # 80022160 <log>
    800047aa:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800047ac:	ffffc097          	auipc	ra,0xffffc
    800047b0:	4de080e7          	jalr	1246(ra) # 80000c8a <release>
      break;
    }
  }
}
    800047b4:	60e2                	ld	ra,24(sp)
    800047b6:	6442                	ld	s0,16(sp)
    800047b8:	64a2                	ld	s1,8(sp)
    800047ba:	6902                	ld	s2,0(sp)
    800047bc:	6105                	addi	sp,sp,32
    800047be:	8082                	ret

00000000800047c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800047c0:	7139                	addi	sp,sp,-64
    800047c2:	fc06                	sd	ra,56(sp)
    800047c4:	f822                	sd	s0,48(sp)
    800047c6:	f426                	sd	s1,40(sp)
    800047c8:	f04a                	sd	s2,32(sp)
    800047ca:	ec4e                	sd	s3,24(sp)
    800047cc:	e852                	sd	s4,16(sp)
    800047ce:	e456                	sd	s5,8(sp)
    800047d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800047d2:	0001e497          	auipc	s1,0x1e
    800047d6:	98e48493          	addi	s1,s1,-1650 # 80022160 <log>
    800047da:	8526                	mv	a0,s1
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	3fa080e7          	jalr	1018(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800047e4:	509c                	lw	a5,32(s1)
    800047e6:	37fd                	addiw	a5,a5,-1
    800047e8:	0007891b          	sext.w	s2,a5
    800047ec:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800047ee:	50dc                	lw	a5,36(s1)
    800047f0:	e7b9                	bnez	a5,8000483e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800047f2:	04091e63          	bnez	s2,8000484e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800047f6:	0001e497          	auipc	s1,0x1e
    800047fa:	96a48493          	addi	s1,s1,-1686 # 80022160 <log>
    800047fe:	4785                	li	a5,1
    80004800:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004802:	8526                	mv	a0,s1
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	486080e7          	jalr	1158(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000480c:	54dc                	lw	a5,44(s1)
    8000480e:	06f04763          	bgtz	a5,8000487c <end_op+0xbc>
    acquire(&log.lock);
    80004812:	0001e497          	auipc	s1,0x1e
    80004816:	94e48493          	addi	s1,s1,-1714 # 80022160 <log>
    8000481a:	8526                	mv	a0,s1
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	3ba080e7          	jalr	954(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004824:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004828:	8526                	mv	a0,s1
    8000482a:	ffffe097          	auipc	ra,0xffffe
    8000482e:	b4e080e7          	jalr	-1202(ra) # 80002378 <wakeup>
    release(&log.lock);
    80004832:	8526                	mv	a0,s1
    80004834:	ffffc097          	auipc	ra,0xffffc
    80004838:	456080e7          	jalr	1110(ra) # 80000c8a <release>
}
    8000483c:	a03d                	j	8000486a <end_op+0xaa>
    panic("log.committing");
    8000483e:	00004517          	auipc	a0,0x4
    80004842:	e2250513          	addi	a0,a0,-478 # 80008660 <syscalls+0x200>
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	cf8080e7          	jalr	-776(ra) # 8000053e <panic>
    wakeup(&log);
    8000484e:	0001e497          	auipc	s1,0x1e
    80004852:	91248493          	addi	s1,s1,-1774 # 80022160 <log>
    80004856:	8526                	mv	a0,s1
    80004858:	ffffe097          	auipc	ra,0xffffe
    8000485c:	b20080e7          	jalr	-1248(ra) # 80002378 <wakeup>
  release(&log.lock);
    80004860:	8526                	mv	a0,s1
    80004862:	ffffc097          	auipc	ra,0xffffc
    80004866:	428080e7          	jalr	1064(ra) # 80000c8a <release>
}
    8000486a:	70e2                	ld	ra,56(sp)
    8000486c:	7442                	ld	s0,48(sp)
    8000486e:	74a2                	ld	s1,40(sp)
    80004870:	7902                	ld	s2,32(sp)
    80004872:	69e2                	ld	s3,24(sp)
    80004874:	6a42                	ld	s4,16(sp)
    80004876:	6aa2                	ld	s5,8(sp)
    80004878:	6121                	addi	sp,sp,64
    8000487a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000487c:	0001ea97          	auipc	s5,0x1e
    80004880:	914a8a93          	addi	s5,s5,-1772 # 80022190 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004884:	0001ea17          	auipc	s4,0x1e
    80004888:	8dca0a13          	addi	s4,s4,-1828 # 80022160 <log>
    8000488c:	018a2583          	lw	a1,24(s4)
    80004890:	012585bb          	addw	a1,a1,s2
    80004894:	2585                	addiw	a1,a1,1
    80004896:	028a2503          	lw	a0,40(s4)
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	cca080e7          	jalr	-822(ra) # 80003564 <bread>
    800048a2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800048a4:	000aa583          	lw	a1,0(s5)
    800048a8:	028a2503          	lw	a0,40(s4)
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	cb8080e7          	jalr	-840(ra) # 80003564 <bread>
    800048b4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800048b6:	40000613          	li	a2,1024
    800048ba:	05850593          	addi	a1,a0,88
    800048be:	05848513          	addi	a0,s1,88
    800048c2:	ffffc097          	auipc	ra,0xffffc
    800048c6:	46c080e7          	jalr	1132(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800048ca:	8526                	mv	a0,s1
    800048cc:	fffff097          	auipc	ra,0xfffff
    800048d0:	d8a080e7          	jalr	-630(ra) # 80003656 <bwrite>
    brelse(from);
    800048d4:	854e                	mv	a0,s3
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	dbe080e7          	jalr	-578(ra) # 80003694 <brelse>
    brelse(to);
    800048de:	8526                	mv	a0,s1
    800048e0:	fffff097          	auipc	ra,0xfffff
    800048e4:	db4080e7          	jalr	-588(ra) # 80003694 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800048e8:	2905                	addiw	s2,s2,1
    800048ea:	0a91                	addi	s5,s5,4
    800048ec:	02ca2783          	lw	a5,44(s4)
    800048f0:	f8f94ee3          	blt	s2,a5,8000488c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800048f4:	00000097          	auipc	ra,0x0
    800048f8:	c6a080e7          	jalr	-918(ra) # 8000455e <write_head>
    install_trans(0); // Now install writes to home locations
    800048fc:	4501                	li	a0,0
    800048fe:	00000097          	auipc	ra,0x0
    80004902:	cda080e7          	jalr	-806(ra) # 800045d8 <install_trans>
    log.lh.n = 0;
    80004906:	0001e797          	auipc	a5,0x1e
    8000490a:	8807a323          	sw	zero,-1914(a5) # 8002218c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000490e:	00000097          	auipc	ra,0x0
    80004912:	c50080e7          	jalr	-944(ra) # 8000455e <write_head>
    80004916:	bdf5                	j	80004812 <end_op+0x52>

0000000080004918 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004918:	1101                	addi	sp,sp,-32
    8000491a:	ec06                	sd	ra,24(sp)
    8000491c:	e822                	sd	s0,16(sp)
    8000491e:	e426                	sd	s1,8(sp)
    80004920:	e04a                	sd	s2,0(sp)
    80004922:	1000                	addi	s0,sp,32
    80004924:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004926:	0001e917          	auipc	s2,0x1e
    8000492a:	83a90913          	addi	s2,s2,-1990 # 80022160 <log>
    8000492e:	854a                	mv	a0,s2
    80004930:	ffffc097          	auipc	ra,0xffffc
    80004934:	2a6080e7          	jalr	678(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004938:	02c92603          	lw	a2,44(s2)
    8000493c:	47f5                	li	a5,29
    8000493e:	06c7c563          	blt	a5,a2,800049a8 <log_write+0x90>
    80004942:	0001e797          	auipc	a5,0x1e
    80004946:	83a7a783          	lw	a5,-1990(a5) # 8002217c <log+0x1c>
    8000494a:	37fd                	addiw	a5,a5,-1
    8000494c:	04f65e63          	bge	a2,a5,800049a8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004950:	0001e797          	auipc	a5,0x1e
    80004954:	8307a783          	lw	a5,-2000(a5) # 80022180 <log+0x20>
    80004958:	06f05063          	blez	a5,800049b8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000495c:	4781                	li	a5,0
    8000495e:	06c05563          	blez	a2,800049c8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004962:	44cc                	lw	a1,12(s1)
    80004964:	0001e717          	auipc	a4,0x1e
    80004968:	82c70713          	addi	a4,a4,-2004 # 80022190 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000496c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000496e:	4314                	lw	a3,0(a4)
    80004970:	04b68c63          	beq	a3,a1,800049c8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004974:	2785                	addiw	a5,a5,1
    80004976:	0711                	addi	a4,a4,4
    80004978:	fef61be3          	bne	a2,a5,8000496e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000497c:	0621                	addi	a2,a2,8
    8000497e:	060a                	slli	a2,a2,0x2
    80004980:	0001d797          	auipc	a5,0x1d
    80004984:	7e078793          	addi	a5,a5,2016 # 80022160 <log>
    80004988:	963e                	add	a2,a2,a5
    8000498a:	44dc                	lw	a5,12(s1)
    8000498c:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000498e:	8526                	mv	a0,s1
    80004990:	fffff097          	auipc	ra,0xfffff
    80004994:	da2080e7          	jalr	-606(ra) # 80003732 <bpin>
    log.lh.n++;
    80004998:	0001d717          	auipc	a4,0x1d
    8000499c:	7c870713          	addi	a4,a4,1992 # 80022160 <log>
    800049a0:	575c                	lw	a5,44(a4)
    800049a2:	2785                	addiw	a5,a5,1
    800049a4:	d75c                	sw	a5,44(a4)
    800049a6:	a835                	j	800049e2 <log_write+0xca>
    panic("too big a transaction");
    800049a8:	00004517          	auipc	a0,0x4
    800049ac:	cc850513          	addi	a0,a0,-824 # 80008670 <syscalls+0x210>
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	b8e080e7          	jalr	-1138(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800049b8:	00004517          	auipc	a0,0x4
    800049bc:	cd050513          	addi	a0,a0,-816 # 80008688 <syscalls+0x228>
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	b7e080e7          	jalr	-1154(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800049c8:	00878713          	addi	a4,a5,8
    800049cc:	00271693          	slli	a3,a4,0x2
    800049d0:	0001d717          	auipc	a4,0x1d
    800049d4:	79070713          	addi	a4,a4,1936 # 80022160 <log>
    800049d8:	9736                	add	a4,a4,a3
    800049da:	44d4                	lw	a3,12(s1)
    800049dc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800049de:	faf608e3          	beq	a2,a5,8000498e <log_write+0x76>
  }
  release(&log.lock);
    800049e2:	0001d517          	auipc	a0,0x1d
    800049e6:	77e50513          	addi	a0,a0,1918 # 80022160 <log>
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	2a0080e7          	jalr	672(ra) # 80000c8a <release>
}
    800049f2:	60e2                	ld	ra,24(sp)
    800049f4:	6442                	ld	s0,16(sp)
    800049f6:	64a2                	ld	s1,8(sp)
    800049f8:	6902                	ld	s2,0(sp)
    800049fa:	6105                	addi	sp,sp,32
    800049fc:	8082                	ret

00000000800049fe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800049fe:	1101                	addi	sp,sp,-32
    80004a00:	ec06                	sd	ra,24(sp)
    80004a02:	e822                	sd	s0,16(sp)
    80004a04:	e426                	sd	s1,8(sp)
    80004a06:	e04a                	sd	s2,0(sp)
    80004a08:	1000                	addi	s0,sp,32
    80004a0a:	84aa                	mv	s1,a0
    80004a0c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a0e:	00004597          	auipc	a1,0x4
    80004a12:	c9a58593          	addi	a1,a1,-870 # 800086a8 <syscalls+0x248>
    80004a16:	0521                	addi	a0,a0,8
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	12e080e7          	jalr	302(ra) # 80000b46 <initlock>
  lk->name = name;
    80004a20:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a24:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a28:	0204a423          	sw	zero,40(s1)
}
    80004a2c:	60e2                	ld	ra,24(sp)
    80004a2e:	6442                	ld	s0,16(sp)
    80004a30:	64a2                	ld	s1,8(sp)
    80004a32:	6902                	ld	s2,0(sp)
    80004a34:	6105                	addi	sp,sp,32
    80004a36:	8082                	ret

0000000080004a38 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a38:	1101                	addi	sp,sp,-32
    80004a3a:	ec06                	sd	ra,24(sp)
    80004a3c:	e822                	sd	s0,16(sp)
    80004a3e:	e426                	sd	s1,8(sp)
    80004a40:	e04a                	sd	s2,0(sp)
    80004a42:	1000                	addi	s0,sp,32
    80004a44:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a46:	00850913          	addi	s2,a0,8
    80004a4a:	854a                	mv	a0,s2
    80004a4c:	ffffc097          	auipc	ra,0xffffc
    80004a50:	18a080e7          	jalr	394(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004a54:	409c                	lw	a5,0(s1)
    80004a56:	cb89                	beqz	a5,80004a68 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004a58:	85ca                	mv	a1,s2
    80004a5a:	8526                	mv	a0,s1
    80004a5c:	ffffe097          	auipc	ra,0xffffe
    80004a60:	8b8080e7          	jalr	-1864(ra) # 80002314 <sleep>
  while (lk->locked) {
    80004a64:	409c                	lw	a5,0(s1)
    80004a66:	fbed                	bnez	a5,80004a58 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a68:	4785                	li	a5,1
    80004a6a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a6c:	ffffd097          	auipc	ra,0xffffd
    80004a70:	0e4080e7          	jalr	228(ra) # 80001b50 <myproc>
    80004a74:	413c                	lw	a5,64(a0)
    80004a76:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a78:	854a                	mv	a0,s2
    80004a7a:	ffffc097          	auipc	ra,0xffffc
    80004a7e:	210080e7          	jalr	528(ra) # 80000c8a <release>
}
    80004a82:	60e2                	ld	ra,24(sp)
    80004a84:	6442                	ld	s0,16(sp)
    80004a86:	64a2                	ld	s1,8(sp)
    80004a88:	6902                	ld	s2,0(sp)
    80004a8a:	6105                	addi	sp,sp,32
    80004a8c:	8082                	ret

0000000080004a8e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a8e:	1101                	addi	sp,sp,-32
    80004a90:	ec06                	sd	ra,24(sp)
    80004a92:	e822                	sd	s0,16(sp)
    80004a94:	e426                	sd	s1,8(sp)
    80004a96:	e04a                	sd	s2,0(sp)
    80004a98:	1000                	addi	s0,sp,32
    80004a9a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a9c:	00850913          	addi	s2,a0,8
    80004aa0:	854a                	mv	a0,s2
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	134080e7          	jalr	308(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004aaa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004aae:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	ffffe097          	auipc	ra,0xffffe
    80004ab8:	8c4080e7          	jalr	-1852(ra) # 80002378 <wakeup>
  release(&lk->lk);
    80004abc:	854a                	mv	a0,s2
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	1cc080e7          	jalr	460(ra) # 80000c8a <release>
}
    80004ac6:	60e2                	ld	ra,24(sp)
    80004ac8:	6442                	ld	s0,16(sp)
    80004aca:	64a2                	ld	s1,8(sp)
    80004acc:	6902                	ld	s2,0(sp)
    80004ace:	6105                	addi	sp,sp,32
    80004ad0:	8082                	ret

0000000080004ad2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004ad2:	7179                	addi	sp,sp,-48
    80004ad4:	f406                	sd	ra,40(sp)
    80004ad6:	f022                	sd	s0,32(sp)
    80004ad8:	ec26                	sd	s1,24(sp)
    80004ada:	e84a                	sd	s2,16(sp)
    80004adc:	e44e                	sd	s3,8(sp)
    80004ade:	1800                	addi	s0,sp,48
    80004ae0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004ae2:	00850913          	addi	s2,a0,8
    80004ae6:	854a                	mv	a0,s2
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	0ee080e7          	jalr	238(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004af0:	409c                	lw	a5,0(s1)
    80004af2:	ef99                	bnez	a5,80004b10 <holdingsleep+0x3e>
    80004af4:	4481                	li	s1,0
  release(&lk->lk);
    80004af6:	854a                	mv	a0,s2
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	192080e7          	jalr	402(ra) # 80000c8a <release>
  return r;
}
    80004b00:	8526                	mv	a0,s1
    80004b02:	70a2                	ld	ra,40(sp)
    80004b04:	7402                	ld	s0,32(sp)
    80004b06:	64e2                	ld	s1,24(sp)
    80004b08:	6942                	ld	s2,16(sp)
    80004b0a:	69a2                	ld	s3,8(sp)
    80004b0c:	6145                	addi	sp,sp,48
    80004b0e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b10:	0284a983          	lw	s3,40(s1)
    80004b14:	ffffd097          	auipc	ra,0xffffd
    80004b18:	03c080e7          	jalr	60(ra) # 80001b50 <myproc>
    80004b1c:	4124                	lw	s1,64(a0)
    80004b1e:	413484b3          	sub	s1,s1,s3
    80004b22:	0014b493          	seqz	s1,s1
    80004b26:	bfc1                	j	80004af6 <holdingsleep+0x24>

0000000080004b28 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b28:	1141                	addi	sp,sp,-16
    80004b2a:	e406                	sd	ra,8(sp)
    80004b2c:	e022                	sd	s0,0(sp)
    80004b2e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b30:	00004597          	auipc	a1,0x4
    80004b34:	b8858593          	addi	a1,a1,-1144 # 800086b8 <syscalls+0x258>
    80004b38:	0001d517          	auipc	a0,0x1d
    80004b3c:	77050513          	addi	a0,a0,1904 # 800222a8 <ftable>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	006080e7          	jalr	6(ra) # 80000b46 <initlock>
}
    80004b48:	60a2                	ld	ra,8(sp)
    80004b4a:	6402                	ld	s0,0(sp)
    80004b4c:	0141                	addi	sp,sp,16
    80004b4e:	8082                	ret

0000000080004b50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b50:	1101                	addi	sp,sp,-32
    80004b52:	ec06                	sd	ra,24(sp)
    80004b54:	e822                	sd	s0,16(sp)
    80004b56:	e426                	sd	s1,8(sp)
    80004b58:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b5a:	0001d517          	auipc	a0,0x1d
    80004b5e:	74e50513          	addi	a0,a0,1870 # 800222a8 <ftable>
    80004b62:	ffffc097          	auipc	ra,0xffffc
    80004b66:	074080e7          	jalr	116(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b6a:	0001d497          	auipc	s1,0x1d
    80004b6e:	75648493          	addi	s1,s1,1878 # 800222c0 <ftable+0x18>
    80004b72:	0001e717          	auipc	a4,0x1e
    80004b76:	6ee70713          	addi	a4,a4,1774 # 80023260 <disk>
    if(f->ref == 0){
    80004b7a:	40dc                	lw	a5,4(s1)
    80004b7c:	cf99                	beqz	a5,80004b9a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b7e:	02848493          	addi	s1,s1,40
    80004b82:	fee49ce3          	bne	s1,a4,80004b7a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b86:	0001d517          	auipc	a0,0x1d
    80004b8a:	72250513          	addi	a0,a0,1826 # 800222a8 <ftable>
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	0fc080e7          	jalr	252(ra) # 80000c8a <release>
  return 0;
    80004b96:	4481                	li	s1,0
    80004b98:	a819                	j	80004bae <filealloc+0x5e>
      f->ref = 1;
    80004b9a:	4785                	li	a5,1
    80004b9c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b9e:	0001d517          	auipc	a0,0x1d
    80004ba2:	70a50513          	addi	a0,a0,1802 # 800222a8 <ftable>
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	0e4080e7          	jalr	228(ra) # 80000c8a <release>
}
    80004bae:	8526                	mv	a0,s1
    80004bb0:	60e2                	ld	ra,24(sp)
    80004bb2:	6442                	ld	s0,16(sp)
    80004bb4:	64a2                	ld	s1,8(sp)
    80004bb6:	6105                	addi	sp,sp,32
    80004bb8:	8082                	ret

0000000080004bba <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004bba:	1101                	addi	sp,sp,-32
    80004bbc:	ec06                	sd	ra,24(sp)
    80004bbe:	e822                	sd	s0,16(sp)
    80004bc0:	e426                	sd	s1,8(sp)
    80004bc2:	1000                	addi	s0,sp,32
    80004bc4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004bc6:	0001d517          	auipc	a0,0x1d
    80004bca:	6e250513          	addi	a0,a0,1762 # 800222a8 <ftable>
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	008080e7          	jalr	8(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004bd6:	40dc                	lw	a5,4(s1)
    80004bd8:	02f05263          	blez	a5,80004bfc <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004bdc:	2785                	addiw	a5,a5,1
    80004bde:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004be0:	0001d517          	auipc	a0,0x1d
    80004be4:	6c850513          	addi	a0,a0,1736 # 800222a8 <ftable>
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	0a2080e7          	jalr	162(ra) # 80000c8a <release>
  return f;
}
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	60e2                	ld	ra,24(sp)
    80004bf4:	6442                	ld	s0,16(sp)
    80004bf6:	64a2                	ld	s1,8(sp)
    80004bf8:	6105                	addi	sp,sp,32
    80004bfa:	8082                	ret
    panic("filedup");
    80004bfc:	00004517          	auipc	a0,0x4
    80004c00:	ac450513          	addi	a0,a0,-1340 # 800086c0 <syscalls+0x260>
    80004c04:	ffffc097          	auipc	ra,0xffffc
    80004c08:	93a080e7          	jalr	-1734(ra) # 8000053e <panic>

0000000080004c0c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c0c:	7139                	addi	sp,sp,-64
    80004c0e:	fc06                	sd	ra,56(sp)
    80004c10:	f822                	sd	s0,48(sp)
    80004c12:	f426                	sd	s1,40(sp)
    80004c14:	f04a                	sd	s2,32(sp)
    80004c16:	ec4e                	sd	s3,24(sp)
    80004c18:	e852                	sd	s4,16(sp)
    80004c1a:	e456                	sd	s5,8(sp)
    80004c1c:	0080                	addi	s0,sp,64
    80004c1e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c20:	0001d517          	auipc	a0,0x1d
    80004c24:	68850513          	addi	a0,a0,1672 # 800222a8 <ftable>
    80004c28:	ffffc097          	auipc	ra,0xffffc
    80004c2c:	fae080e7          	jalr	-82(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004c30:	40dc                	lw	a5,4(s1)
    80004c32:	06f05163          	blez	a5,80004c94 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004c36:	37fd                	addiw	a5,a5,-1
    80004c38:	0007871b          	sext.w	a4,a5
    80004c3c:	c0dc                	sw	a5,4(s1)
    80004c3e:	06e04363          	bgtz	a4,80004ca4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c42:	0004a903          	lw	s2,0(s1)
    80004c46:	0094ca83          	lbu	s5,9(s1)
    80004c4a:	0104ba03          	ld	s4,16(s1)
    80004c4e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c52:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c56:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c5a:	0001d517          	auipc	a0,0x1d
    80004c5e:	64e50513          	addi	a0,a0,1614 # 800222a8 <ftable>
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	028080e7          	jalr	40(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004c6a:	4785                	li	a5,1
    80004c6c:	04f90d63          	beq	s2,a5,80004cc6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c70:	3979                	addiw	s2,s2,-2
    80004c72:	4785                	li	a5,1
    80004c74:	0527e063          	bltu	a5,s2,80004cb4 <fileclose+0xa8>
    begin_op();
    80004c78:	00000097          	auipc	ra,0x0
    80004c7c:	ac8080e7          	jalr	-1336(ra) # 80004740 <begin_op>
    iput(ff.ip);
    80004c80:	854e                	mv	a0,s3
    80004c82:	fffff097          	auipc	ra,0xfffff
    80004c86:	2b6080e7          	jalr	694(ra) # 80003f38 <iput>
    end_op();
    80004c8a:	00000097          	auipc	ra,0x0
    80004c8e:	b36080e7          	jalr	-1226(ra) # 800047c0 <end_op>
    80004c92:	a00d                	j	80004cb4 <fileclose+0xa8>
    panic("fileclose");
    80004c94:	00004517          	auipc	a0,0x4
    80004c98:	a3450513          	addi	a0,a0,-1484 # 800086c8 <syscalls+0x268>
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	8a2080e7          	jalr	-1886(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004ca4:	0001d517          	auipc	a0,0x1d
    80004ca8:	60450513          	addi	a0,a0,1540 # 800222a8 <ftable>
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	fde080e7          	jalr	-34(ra) # 80000c8a <release>
  }
}
    80004cb4:	70e2                	ld	ra,56(sp)
    80004cb6:	7442                	ld	s0,48(sp)
    80004cb8:	74a2                	ld	s1,40(sp)
    80004cba:	7902                	ld	s2,32(sp)
    80004cbc:	69e2                	ld	s3,24(sp)
    80004cbe:	6a42                	ld	s4,16(sp)
    80004cc0:	6aa2                	ld	s5,8(sp)
    80004cc2:	6121                	addi	sp,sp,64
    80004cc4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004cc6:	85d6                	mv	a1,s5
    80004cc8:	8552                	mv	a0,s4
    80004cca:	00000097          	auipc	ra,0x0
    80004cce:	34c080e7          	jalr	844(ra) # 80005016 <pipeclose>
    80004cd2:	b7cd                	j	80004cb4 <fileclose+0xa8>

0000000080004cd4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004cd4:	715d                	addi	sp,sp,-80
    80004cd6:	e486                	sd	ra,72(sp)
    80004cd8:	e0a2                	sd	s0,64(sp)
    80004cda:	fc26                	sd	s1,56(sp)
    80004cdc:	f84a                	sd	s2,48(sp)
    80004cde:	f44e                	sd	s3,40(sp)
    80004ce0:	0880                	addi	s0,sp,80
    80004ce2:	84aa                	mv	s1,a0
    80004ce4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ce6:	ffffd097          	auipc	ra,0xffffd
    80004cea:	e6a080e7          	jalr	-406(ra) # 80001b50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004cee:	409c                	lw	a5,0(s1)
    80004cf0:	37f9                	addiw	a5,a5,-2
    80004cf2:	4705                	li	a4,1
    80004cf4:	04f76763          	bltu	a4,a5,80004d42 <filestat+0x6e>
    80004cf8:	892a                	mv	s2,a0
    ilock(f->ip);
    80004cfa:	6c88                	ld	a0,24(s1)
    80004cfc:	fffff097          	auipc	ra,0xfffff
    80004d00:	082080e7          	jalr	130(ra) # 80003d7e <ilock>
    stati(f->ip, &st);
    80004d04:	fb840593          	addi	a1,s0,-72
    80004d08:	6c88                	ld	a0,24(s1)
    80004d0a:	fffff097          	auipc	ra,0xfffff
    80004d0e:	2fe080e7          	jalr	766(ra) # 80004008 <stati>
    iunlock(f->ip);
    80004d12:	6c88                	ld	a0,24(s1)
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	12c080e7          	jalr	300(ra) # 80003e40 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d1c:	46e1                	li	a3,24
    80004d1e:	fb840613          	addi	a2,s0,-72
    80004d22:	85ce                	mv	a1,s3
    80004d24:	06093503          	ld	a0,96(s2)
    80004d28:	ffffd097          	auipc	ra,0xffffd
    80004d2c:	948080e7          	jalr	-1720(ra) # 80001670 <copyout>
    80004d30:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d34:	60a6                	ld	ra,72(sp)
    80004d36:	6406                	ld	s0,64(sp)
    80004d38:	74e2                	ld	s1,56(sp)
    80004d3a:	7942                	ld	s2,48(sp)
    80004d3c:	79a2                	ld	s3,40(sp)
    80004d3e:	6161                	addi	sp,sp,80
    80004d40:	8082                	ret
  return -1;
    80004d42:	557d                	li	a0,-1
    80004d44:	bfc5                	j	80004d34 <filestat+0x60>

0000000080004d46 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d46:	7179                	addi	sp,sp,-48
    80004d48:	f406                	sd	ra,40(sp)
    80004d4a:	f022                	sd	s0,32(sp)
    80004d4c:	ec26                	sd	s1,24(sp)
    80004d4e:	e84a                	sd	s2,16(sp)
    80004d50:	e44e                	sd	s3,8(sp)
    80004d52:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d54:	00854783          	lbu	a5,8(a0)
    80004d58:	c3d5                	beqz	a5,80004dfc <fileread+0xb6>
    80004d5a:	84aa                	mv	s1,a0
    80004d5c:	89ae                	mv	s3,a1
    80004d5e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d60:	411c                	lw	a5,0(a0)
    80004d62:	4705                	li	a4,1
    80004d64:	04e78963          	beq	a5,a4,80004db6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d68:	470d                	li	a4,3
    80004d6a:	04e78d63          	beq	a5,a4,80004dc4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d6e:	4709                	li	a4,2
    80004d70:	06e79e63          	bne	a5,a4,80004dec <fileread+0xa6>
    ilock(f->ip);
    80004d74:	6d08                	ld	a0,24(a0)
    80004d76:	fffff097          	auipc	ra,0xfffff
    80004d7a:	008080e7          	jalr	8(ra) # 80003d7e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d7e:	874a                	mv	a4,s2
    80004d80:	5094                	lw	a3,32(s1)
    80004d82:	864e                	mv	a2,s3
    80004d84:	4585                	li	a1,1
    80004d86:	6c88                	ld	a0,24(s1)
    80004d88:	fffff097          	auipc	ra,0xfffff
    80004d8c:	2aa080e7          	jalr	682(ra) # 80004032 <readi>
    80004d90:	892a                	mv	s2,a0
    80004d92:	00a05563          	blez	a0,80004d9c <fileread+0x56>
      f->off += r;
    80004d96:	509c                	lw	a5,32(s1)
    80004d98:	9fa9                	addw	a5,a5,a0
    80004d9a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d9c:	6c88                	ld	a0,24(s1)
    80004d9e:	fffff097          	auipc	ra,0xfffff
    80004da2:	0a2080e7          	jalr	162(ra) # 80003e40 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004da6:	854a                	mv	a0,s2
    80004da8:	70a2                	ld	ra,40(sp)
    80004daa:	7402                	ld	s0,32(sp)
    80004dac:	64e2                	ld	s1,24(sp)
    80004dae:	6942                	ld	s2,16(sp)
    80004db0:	69a2                	ld	s3,8(sp)
    80004db2:	6145                	addi	sp,sp,48
    80004db4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004db6:	6908                	ld	a0,16(a0)
    80004db8:	00000097          	auipc	ra,0x0
    80004dbc:	3c6080e7          	jalr	966(ra) # 8000517e <piperead>
    80004dc0:	892a                	mv	s2,a0
    80004dc2:	b7d5                	j	80004da6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004dc4:	02451783          	lh	a5,36(a0)
    80004dc8:	03079693          	slli	a3,a5,0x30
    80004dcc:	92c1                	srli	a3,a3,0x30
    80004dce:	4725                	li	a4,9
    80004dd0:	02d76863          	bltu	a4,a3,80004e00 <fileread+0xba>
    80004dd4:	0792                	slli	a5,a5,0x4
    80004dd6:	0001d717          	auipc	a4,0x1d
    80004dda:	43270713          	addi	a4,a4,1074 # 80022208 <devsw>
    80004dde:	97ba                	add	a5,a5,a4
    80004de0:	639c                	ld	a5,0(a5)
    80004de2:	c38d                	beqz	a5,80004e04 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004de4:	4505                	li	a0,1
    80004de6:	9782                	jalr	a5
    80004de8:	892a                	mv	s2,a0
    80004dea:	bf75                	j	80004da6 <fileread+0x60>
    panic("fileread");
    80004dec:	00004517          	auipc	a0,0x4
    80004df0:	8ec50513          	addi	a0,a0,-1812 # 800086d8 <syscalls+0x278>
    80004df4:	ffffb097          	auipc	ra,0xffffb
    80004df8:	74a080e7          	jalr	1866(ra) # 8000053e <panic>
    return -1;
    80004dfc:	597d                	li	s2,-1
    80004dfe:	b765                	j	80004da6 <fileread+0x60>
      return -1;
    80004e00:	597d                	li	s2,-1
    80004e02:	b755                	j	80004da6 <fileread+0x60>
    80004e04:	597d                	li	s2,-1
    80004e06:	b745                	j	80004da6 <fileread+0x60>

0000000080004e08 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e08:	715d                	addi	sp,sp,-80
    80004e0a:	e486                	sd	ra,72(sp)
    80004e0c:	e0a2                	sd	s0,64(sp)
    80004e0e:	fc26                	sd	s1,56(sp)
    80004e10:	f84a                	sd	s2,48(sp)
    80004e12:	f44e                	sd	s3,40(sp)
    80004e14:	f052                	sd	s4,32(sp)
    80004e16:	ec56                	sd	s5,24(sp)
    80004e18:	e85a                	sd	s6,16(sp)
    80004e1a:	e45e                	sd	s7,8(sp)
    80004e1c:	e062                	sd	s8,0(sp)
    80004e1e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e20:	00954783          	lbu	a5,9(a0)
    80004e24:	10078663          	beqz	a5,80004f30 <filewrite+0x128>
    80004e28:	892a                	mv	s2,a0
    80004e2a:	8aae                	mv	s5,a1
    80004e2c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e2e:	411c                	lw	a5,0(a0)
    80004e30:	4705                	li	a4,1
    80004e32:	02e78263          	beq	a5,a4,80004e56 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e36:	470d                	li	a4,3
    80004e38:	02e78663          	beq	a5,a4,80004e64 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e3c:	4709                	li	a4,2
    80004e3e:	0ee79163          	bne	a5,a4,80004f20 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e42:	0ac05d63          	blez	a2,80004efc <filewrite+0xf4>
    int i = 0;
    80004e46:	4981                	li	s3,0
    80004e48:	6b05                	lui	s6,0x1
    80004e4a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e4e:	6b85                	lui	s7,0x1
    80004e50:	c00b8b9b          	addiw	s7,s7,-1024
    80004e54:	a861                	j	80004eec <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004e56:	6908                	ld	a0,16(a0)
    80004e58:	00000097          	auipc	ra,0x0
    80004e5c:	22e080e7          	jalr	558(ra) # 80005086 <pipewrite>
    80004e60:	8a2a                	mv	s4,a0
    80004e62:	a045                	j	80004f02 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e64:	02451783          	lh	a5,36(a0)
    80004e68:	03079693          	slli	a3,a5,0x30
    80004e6c:	92c1                	srli	a3,a3,0x30
    80004e6e:	4725                	li	a4,9
    80004e70:	0cd76263          	bltu	a4,a3,80004f34 <filewrite+0x12c>
    80004e74:	0792                	slli	a5,a5,0x4
    80004e76:	0001d717          	auipc	a4,0x1d
    80004e7a:	39270713          	addi	a4,a4,914 # 80022208 <devsw>
    80004e7e:	97ba                	add	a5,a5,a4
    80004e80:	679c                	ld	a5,8(a5)
    80004e82:	cbdd                	beqz	a5,80004f38 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e84:	4505                	li	a0,1
    80004e86:	9782                	jalr	a5
    80004e88:	8a2a                	mv	s4,a0
    80004e8a:	a8a5                	j	80004f02 <filewrite+0xfa>
    80004e8c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e90:	00000097          	auipc	ra,0x0
    80004e94:	8b0080e7          	jalr	-1872(ra) # 80004740 <begin_op>
      ilock(f->ip);
    80004e98:	01893503          	ld	a0,24(s2)
    80004e9c:	fffff097          	auipc	ra,0xfffff
    80004ea0:	ee2080e7          	jalr	-286(ra) # 80003d7e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ea4:	8762                	mv	a4,s8
    80004ea6:	02092683          	lw	a3,32(s2)
    80004eaa:	01598633          	add	a2,s3,s5
    80004eae:	4585                	li	a1,1
    80004eb0:	01893503          	ld	a0,24(s2)
    80004eb4:	fffff097          	auipc	ra,0xfffff
    80004eb8:	276080e7          	jalr	630(ra) # 8000412a <writei>
    80004ebc:	84aa                	mv	s1,a0
    80004ebe:	00a05763          	blez	a0,80004ecc <filewrite+0xc4>
        f->off += r;
    80004ec2:	02092783          	lw	a5,32(s2)
    80004ec6:	9fa9                	addw	a5,a5,a0
    80004ec8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ecc:	01893503          	ld	a0,24(s2)
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	f70080e7          	jalr	-144(ra) # 80003e40 <iunlock>
      end_op();
    80004ed8:	00000097          	auipc	ra,0x0
    80004edc:	8e8080e7          	jalr	-1816(ra) # 800047c0 <end_op>

      if(r != n1){
    80004ee0:	009c1f63          	bne	s8,s1,80004efe <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004ee4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ee8:	0149db63          	bge	s3,s4,80004efe <filewrite+0xf6>
      int n1 = n - i;
    80004eec:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ef0:	84be                	mv	s1,a5
    80004ef2:	2781                	sext.w	a5,a5
    80004ef4:	f8fb5ce3          	bge	s6,a5,80004e8c <filewrite+0x84>
    80004ef8:	84de                	mv	s1,s7
    80004efa:	bf49                	j	80004e8c <filewrite+0x84>
    int i = 0;
    80004efc:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004efe:	013a1f63          	bne	s4,s3,80004f1c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f02:	8552                	mv	a0,s4
    80004f04:	60a6                	ld	ra,72(sp)
    80004f06:	6406                	ld	s0,64(sp)
    80004f08:	74e2                	ld	s1,56(sp)
    80004f0a:	7942                	ld	s2,48(sp)
    80004f0c:	79a2                	ld	s3,40(sp)
    80004f0e:	7a02                	ld	s4,32(sp)
    80004f10:	6ae2                	ld	s5,24(sp)
    80004f12:	6b42                	ld	s6,16(sp)
    80004f14:	6ba2                	ld	s7,8(sp)
    80004f16:	6c02                	ld	s8,0(sp)
    80004f18:	6161                	addi	sp,sp,80
    80004f1a:	8082                	ret
    ret = (i == n ? n : -1);
    80004f1c:	5a7d                	li	s4,-1
    80004f1e:	b7d5                	j	80004f02 <filewrite+0xfa>
    panic("filewrite");
    80004f20:	00003517          	auipc	a0,0x3
    80004f24:	7c850513          	addi	a0,a0,1992 # 800086e8 <syscalls+0x288>
    80004f28:	ffffb097          	auipc	ra,0xffffb
    80004f2c:	616080e7          	jalr	1558(ra) # 8000053e <panic>
    return -1;
    80004f30:	5a7d                	li	s4,-1
    80004f32:	bfc1                	j	80004f02 <filewrite+0xfa>
      return -1;
    80004f34:	5a7d                	li	s4,-1
    80004f36:	b7f1                	j	80004f02 <filewrite+0xfa>
    80004f38:	5a7d                	li	s4,-1
    80004f3a:	b7e1                	j	80004f02 <filewrite+0xfa>

0000000080004f3c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f3c:	7179                	addi	sp,sp,-48
    80004f3e:	f406                	sd	ra,40(sp)
    80004f40:	f022                	sd	s0,32(sp)
    80004f42:	ec26                	sd	s1,24(sp)
    80004f44:	e84a                	sd	s2,16(sp)
    80004f46:	e44e                	sd	s3,8(sp)
    80004f48:	e052                	sd	s4,0(sp)
    80004f4a:	1800                	addi	s0,sp,48
    80004f4c:	84aa                	mv	s1,a0
    80004f4e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f50:	0005b023          	sd	zero,0(a1)
    80004f54:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f58:	00000097          	auipc	ra,0x0
    80004f5c:	bf8080e7          	jalr	-1032(ra) # 80004b50 <filealloc>
    80004f60:	e088                	sd	a0,0(s1)
    80004f62:	c551                	beqz	a0,80004fee <pipealloc+0xb2>
    80004f64:	00000097          	auipc	ra,0x0
    80004f68:	bec080e7          	jalr	-1044(ra) # 80004b50 <filealloc>
    80004f6c:	00aa3023          	sd	a0,0(s4)
    80004f70:	c92d                	beqz	a0,80004fe2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f72:	ffffc097          	auipc	ra,0xffffc
    80004f76:	b74080e7          	jalr	-1164(ra) # 80000ae6 <kalloc>
    80004f7a:	892a                	mv	s2,a0
    80004f7c:	c125                	beqz	a0,80004fdc <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f7e:	4985                	li	s3,1
    80004f80:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f84:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f88:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f8c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f90:	00003597          	auipc	a1,0x3
    80004f94:	76858593          	addi	a1,a1,1896 # 800086f8 <syscalls+0x298>
    80004f98:	ffffc097          	auipc	ra,0xffffc
    80004f9c:	bae080e7          	jalr	-1106(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004fa0:	609c                	ld	a5,0(s1)
    80004fa2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004fa6:	609c                	ld	a5,0(s1)
    80004fa8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004fac:	609c                	ld	a5,0(s1)
    80004fae:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004fb2:	609c                	ld	a5,0(s1)
    80004fb4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004fb8:	000a3783          	ld	a5,0(s4)
    80004fbc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004fc0:	000a3783          	ld	a5,0(s4)
    80004fc4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004fc8:	000a3783          	ld	a5,0(s4)
    80004fcc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004fd0:	000a3783          	ld	a5,0(s4)
    80004fd4:	0127b823          	sd	s2,16(a5)
  return 0;
    80004fd8:	4501                	li	a0,0
    80004fda:	a025                	j	80005002 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004fdc:	6088                	ld	a0,0(s1)
    80004fde:	e501                	bnez	a0,80004fe6 <pipealloc+0xaa>
    80004fe0:	a039                	j	80004fee <pipealloc+0xb2>
    80004fe2:	6088                	ld	a0,0(s1)
    80004fe4:	c51d                	beqz	a0,80005012 <pipealloc+0xd6>
    fileclose(*f0);
    80004fe6:	00000097          	auipc	ra,0x0
    80004fea:	c26080e7          	jalr	-986(ra) # 80004c0c <fileclose>
  if(*f1)
    80004fee:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ff2:	557d                	li	a0,-1
  if(*f1)
    80004ff4:	c799                	beqz	a5,80005002 <pipealloc+0xc6>
    fileclose(*f1);
    80004ff6:	853e                	mv	a0,a5
    80004ff8:	00000097          	auipc	ra,0x0
    80004ffc:	c14080e7          	jalr	-1004(ra) # 80004c0c <fileclose>
  return -1;
    80005000:	557d                	li	a0,-1
}
    80005002:	70a2                	ld	ra,40(sp)
    80005004:	7402                	ld	s0,32(sp)
    80005006:	64e2                	ld	s1,24(sp)
    80005008:	6942                	ld	s2,16(sp)
    8000500a:	69a2                	ld	s3,8(sp)
    8000500c:	6a02                	ld	s4,0(sp)
    8000500e:	6145                	addi	sp,sp,48
    80005010:	8082                	ret
  return -1;
    80005012:	557d                	li	a0,-1
    80005014:	b7fd                	j	80005002 <pipealloc+0xc6>

0000000080005016 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005016:	1101                	addi	sp,sp,-32
    80005018:	ec06                	sd	ra,24(sp)
    8000501a:	e822                	sd	s0,16(sp)
    8000501c:	e426                	sd	s1,8(sp)
    8000501e:	e04a                	sd	s2,0(sp)
    80005020:	1000                	addi	s0,sp,32
    80005022:	84aa                	mv	s1,a0
    80005024:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	bb0080e7          	jalr	-1104(ra) # 80000bd6 <acquire>
  if(writable){
    8000502e:	02090d63          	beqz	s2,80005068 <pipeclose+0x52>
    pi->writeopen = 0;
    80005032:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005036:	21848513          	addi	a0,s1,536
    8000503a:	ffffd097          	auipc	ra,0xffffd
    8000503e:	33e080e7          	jalr	830(ra) # 80002378 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005042:	2204b783          	ld	a5,544(s1)
    80005046:	eb95                	bnez	a5,8000507a <pipeclose+0x64>
    release(&pi->lock);
    80005048:	8526                	mv	a0,s1
    8000504a:	ffffc097          	auipc	ra,0xffffc
    8000504e:	c40080e7          	jalr	-960(ra) # 80000c8a <release>
    kfree((char*)pi);
    80005052:	8526                	mv	a0,s1
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	996080e7          	jalr	-1642(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    8000505c:	60e2                	ld	ra,24(sp)
    8000505e:	6442                	ld	s0,16(sp)
    80005060:	64a2                	ld	s1,8(sp)
    80005062:	6902                	ld	s2,0(sp)
    80005064:	6105                	addi	sp,sp,32
    80005066:	8082                	ret
    pi->readopen = 0;
    80005068:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000506c:	21c48513          	addi	a0,s1,540
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	308080e7          	jalr	776(ra) # 80002378 <wakeup>
    80005078:	b7e9                	j	80005042 <pipeclose+0x2c>
    release(&pi->lock);
    8000507a:	8526                	mv	a0,s1
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	c0e080e7          	jalr	-1010(ra) # 80000c8a <release>
}
    80005084:	bfe1                	j	8000505c <pipeclose+0x46>

0000000080005086 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005086:	711d                	addi	sp,sp,-96
    80005088:	ec86                	sd	ra,88(sp)
    8000508a:	e8a2                	sd	s0,80(sp)
    8000508c:	e4a6                	sd	s1,72(sp)
    8000508e:	e0ca                	sd	s2,64(sp)
    80005090:	fc4e                	sd	s3,56(sp)
    80005092:	f852                	sd	s4,48(sp)
    80005094:	f456                	sd	s5,40(sp)
    80005096:	f05a                	sd	s6,32(sp)
    80005098:	ec5e                	sd	s7,24(sp)
    8000509a:	e862                	sd	s8,16(sp)
    8000509c:	1080                	addi	s0,sp,96
    8000509e:	84aa                	mv	s1,a0
    800050a0:	8aae                	mv	s5,a1
    800050a2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800050a4:	ffffd097          	auipc	ra,0xffffd
    800050a8:	aac080e7          	jalr	-1364(ra) # 80001b50 <myproc>
    800050ac:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800050ae:	8526                	mv	a0,s1
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	b26080e7          	jalr	-1242(ra) # 80000bd6 <acquire>
  while(i < n){
    800050b8:	0b405663          	blez	s4,80005164 <pipewrite+0xde>
  int i = 0;
    800050bc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050be:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800050c0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800050c4:	21c48b93          	addi	s7,s1,540
    800050c8:	a089                	j	8000510a <pipewrite+0x84>
      release(&pi->lock);
    800050ca:	8526                	mv	a0,s1
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	bbe080e7          	jalr	-1090(ra) # 80000c8a <release>
      return -1;
    800050d4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800050d6:	854a                	mv	a0,s2
    800050d8:	60e6                	ld	ra,88(sp)
    800050da:	6446                	ld	s0,80(sp)
    800050dc:	64a6                	ld	s1,72(sp)
    800050de:	6906                	ld	s2,64(sp)
    800050e0:	79e2                	ld	s3,56(sp)
    800050e2:	7a42                	ld	s4,48(sp)
    800050e4:	7aa2                	ld	s5,40(sp)
    800050e6:	7b02                	ld	s6,32(sp)
    800050e8:	6be2                	ld	s7,24(sp)
    800050ea:	6c42                	ld	s8,16(sp)
    800050ec:	6125                	addi	sp,sp,96
    800050ee:	8082                	ret
      wakeup(&pi->nread);
    800050f0:	8562                	mv	a0,s8
    800050f2:	ffffd097          	auipc	ra,0xffffd
    800050f6:	286080e7          	jalr	646(ra) # 80002378 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050fa:	85a6                	mv	a1,s1
    800050fc:	855e                	mv	a0,s7
    800050fe:	ffffd097          	auipc	ra,0xffffd
    80005102:	216080e7          	jalr	534(ra) # 80002314 <sleep>
  while(i < n){
    80005106:	07495063          	bge	s2,s4,80005166 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    8000510a:	2204a783          	lw	a5,544(s1)
    8000510e:	dfd5                	beqz	a5,800050ca <pipewrite+0x44>
    80005110:	854e                	mv	a0,s3
    80005112:	ffffd097          	auipc	ra,0xffffd
    80005116:	4c2080e7          	jalr	1218(ra) # 800025d4 <killed>
    8000511a:	f945                	bnez	a0,800050ca <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000511c:	2184a783          	lw	a5,536(s1)
    80005120:	21c4a703          	lw	a4,540(s1)
    80005124:	2007879b          	addiw	a5,a5,512
    80005128:	fcf704e3          	beq	a4,a5,800050f0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000512c:	4685                	li	a3,1
    8000512e:	01590633          	add	a2,s2,s5
    80005132:	faf40593          	addi	a1,s0,-81
    80005136:	0609b503          	ld	a0,96(s3)
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	5c2080e7          	jalr	1474(ra) # 800016fc <copyin>
    80005142:	03650263          	beq	a0,s6,80005166 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005146:	21c4a783          	lw	a5,540(s1)
    8000514a:	0017871b          	addiw	a4,a5,1
    8000514e:	20e4ae23          	sw	a4,540(s1)
    80005152:	1ff7f793          	andi	a5,a5,511
    80005156:	97a6                	add	a5,a5,s1
    80005158:	faf44703          	lbu	a4,-81(s0)
    8000515c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005160:	2905                	addiw	s2,s2,1
    80005162:	b755                	j	80005106 <pipewrite+0x80>
  int i = 0;
    80005164:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005166:	21848513          	addi	a0,s1,536
    8000516a:	ffffd097          	auipc	ra,0xffffd
    8000516e:	20e080e7          	jalr	526(ra) # 80002378 <wakeup>
  release(&pi->lock);
    80005172:	8526                	mv	a0,s1
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	b16080e7          	jalr	-1258(ra) # 80000c8a <release>
  return i;
    8000517c:	bfa9                	j	800050d6 <pipewrite+0x50>

000000008000517e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000517e:	715d                	addi	sp,sp,-80
    80005180:	e486                	sd	ra,72(sp)
    80005182:	e0a2                	sd	s0,64(sp)
    80005184:	fc26                	sd	s1,56(sp)
    80005186:	f84a                	sd	s2,48(sp)
    80005188:	f44e                	sd	s3,40(sp)
    8000518a:	f052                	sd	s4,32(sp)
    8000518c:	ec56                	sd	s5,24(sp)
    8000518e:	e85a                	sd	s6,16(sp)
    80005190:	0880                	addi	s0,sp,80
    80005192:	84aa                	mv	s1,a0
    80005194:	892e                	mv	s2,a1
    80005196:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005198:	ffffd097          	auipc	ra,0xffffd
    8000519c:	9b8080e7          	jalr	-1608(ra) # 80001b50 <myproc>
    800051a0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800051a2:	8526                	mv	a0,s1
    800051a4:	ffffc097          	auipc	ra,0xffffc
    800051a8:	a32080e7          	jalr	-1486(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051ac:	2184a703          	lw	a4,536(s1)
    800051b0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051b4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051b8:	02f71763          	bne	a4,a5,800051e6 <piperead+0x68>
    800051bc:	2244a783          	lw	a5,548(s1)
    800051c0:	c39d                	beqz	a5,800051e6 <piperead+0x68>
    if(killed(pr)){
    800051c2:	8552                	mv	a0,s4
    800051c4:	ffffd097          	auipc	ra,0xffffd
    800051c8:	410080e7          	jalr	1040(ra) # 800025d4 <killed>
    800051cc:	e941                	bnez	a0,8000525c <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800051ce:	85a6                	mv	a1,s1
    800051d0:	854e                	mv	a0,s3
    800051d2:	ffffd097          	auipc	ra,0xffffd
    800051d6:	142080e7          	jalr	322(ra) # 80002314 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800051da:	2184a703          	lw	a4,536(s1)
    800051de:	21c4a783          	lw	a5,540(s1)
    800051e2:	fcf70de3          	beq	a4,a5,800051bc <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051e6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051e8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051ea:	05505363          	blez	s5,80005230 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800051ee:	2184a783          	lw	a5,536(s1)
    800051f2:	21c4a703          	lw	a4,540(s1)
    800051f6:	02f70d63          	beq	a4,a5,80005230 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051fa:	0017871b          	addiw	a4,a5,1
    800051fe:	20e4ac23          	sw	a4,536(s1)
    80005202:	1ff7f793          	andi	a5,a5,511
    80005206:	97a6                	add	a5,a5,s1
    80005208:	0187c783          	lbu	a5,24(a5)
    8000520c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005210:	4685                	li	a3,1
    80005212:	fbf40613          	addi	a2,s0,-65
    80005216:	85ca                	mv	a1,s2
    80005218:	060a3503          	ld	a0,96(s4)
    8000521c:	ffffc097          	auipc	ra,0xffffc
    80005220:	454080e7          	jalr	1108(ra) # 80001670 <copyout>
    80005224:	01650663          	beq	a0,s6,80005230 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005228:	2985                	addiw	s3,s3,1
    8000522a:	0905                	addi	s2,s2,1
    8000522c:	fd3a91e3          	bne	s5,s3,800051ee <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005230:	21c48513          	addi	a0,s1,540
    80005234:	ffffd097          	auipc	ra,0xffffd
    80005238:	144080e7          	jalr	324(ra) # 80002378 <wakeup>
  release(&pi->lock);
    8000523c:	8526                	mv	a0,s1
    8000523e:	ffffc097          	auipc	ra,0xffffc
    80005242:	a4c080e7          	jalr	-1460(ra) # 80000c8a <release>
  return i;
}
    80005246:	854e                	mv	a0,s3
    80005248:	60a6                	ld	ra,72(sp)
    8000524a:	6406                	ld	s0,64(sp)
    8000524c:	74e2                	ld	s1,56(sp)
    8000524e:	7942                	ld	s2,48(sp)
    80005250:	79a2                	ld	s3,40(sp)
    80005252:	7a02                	ld	s4,32(sp)
    80005254:	6ae2                	ld	s5,24(sp)
    80005256:	6b42                	ld	s6,16(sp)
    80005258:	6161                	addi	sp,sp,80
    8000525a:	8082                	ret
      release(&pi->lock);
    8000525c:	8526                	mv	a0,s1
    8000525e:	ffffc097          	auipc	ra,0xffffc
    80005262:	a2c080e7          	jalr	-1492(ra) # 80000c8a <release>
      return -1;
    80005266:	59fd                	li	s3,-1
    80005268:	bff9                	j	80005246 <piperead+0xc8>

000000008000526a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000526a:	1141                	addi	sp,sp,-16
    8000526c:	e422                	sd	s0,8(sp)
    8000526e:	0800                	addi	s0,sp,16
    80005270:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005272:	8905                	andi	a0,a0,1
    80005274:	c111                	beqz	a0,80005278 <flags2perm+0xe>
      perm = PTE_X;
    80005276:	4521                	li	a0,8
    if(flags & 0x2)
    80005278:	8b89                	andi	a5,a5,2
    8000527a:	c399                	beqz	a5,80005280 <flags2perm+0x16>
      perm |= PTE_W;
    8000527c:	00456513          	ori	a0,a0,4
    return perm;
}
    80005280:	6422                	ld	s0,8(sp)
    80005282:	0141                	addi	sp,sp,16
    80005284:	8082                	ret

0000000080005286 <exec>:

int
exec(char *path, char **argv)
{
    80005286:	de010113          	addi	sp,sp,-544
    8000528a:	20113c23          	sd	ra,536(sp)
    8000528e:	20813823          	sd	s0,528(sp)
    80005292:	20913423          	sd	s1,520(sp)
    80005296:	21213023          	sd	s2,512(sp)
    8000529a:	ffce                	sd	s3,504(sp)
    8000529c:	fbd2                	sd	s4,496(sp)
    8000529e:	f7d6                	sd	s5,488(sp)
    800052a0:	f3da                	sd	s6,480(sp)
    800052a2:	efde                	sd	s7,472(sp)
    800052a4:	ebe2                	sd	s8,464(sp)
    800052a6:	e7e6                	sd	s9,456(sp)
    800052a8:	e3ea                	sd	s10,448(sp)
    800052aa:	ff6e                	sd	s11,440(sp)
    800052ac:	1400                	addi	s0,sp,544
    800052ae:	892a                	mv	s2,a0
    800052b0:	dea43423          	sd	a0,-536(s0)
    800052b4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800052b8:	ffffd097          	auipc	ra,0xffffd
    800052bc:	898080e7          	jalr	-1896(ra) # 80001b50 <myproc>
    800052c0:	84aa                	mv	s1,a0

  begin_op();
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	47e080e7          	jalr	1150(ra) # 80004740 <begin_op>

  if((ip = namei(path)) == 0){
    800052ca:	854a                	mv	a0,s2
    800052cc:	fffff097          	auipc	ra,0xfffff
    800052d0:	258080e7          	jalr	600(ra) # 80004524 <namei>
    800052d4:	c93d                	beqz	a0,8000534a <exec+0xc4>
    800052d6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	aa6080e7          	jalr	-1370(ra) # 80003d7e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800052e0:	04000713          	li	a4,64
    800052e4:	4681                	li	a3,0
    800052e6:	e5040613          	addi	a2,s0,-432
    800052ea:	4581                	li	a1,0
    800052ec:	8556                	mv	a0,s5
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	d44080e7          	jalr	-700(ra) # 80004032 <readi>
    800052f6:	04000793          	li	a5,64
    800052fa:	00f51a63          	bne	a0,a5,8000530e <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800052fe:	e5042703          	lw	a4,-432(s0)
    80005302:	464c47b7          	lui	a5,0x464c4
    80005306:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000530a:	04f70663          	beq	a4,a5,80005356 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000530e:	8556                	mv	a0,s5
    80005310:	fffff097          	auipc	ra,0xfffff
    80005314:	cd0080e7          	jalr	-816(ra) # 80003fe0 <iunlockput>
    end_op();
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	4a8080e7          	jalr	1192(ra) # 800047c0 <end_op>
  }
  return -1;
    80005320:	557d                	li	a0,-1
}
    80005322:	21813083          	ld	ra,536(sp)
    80005326:	21013403          	ld	s0,528(sp)
    8000532a:	20813483          	ld	s1,520(sp)
    8000532e:	20013903          	ld	s2,512(sp)
    80005332:	79fe                	ld	s3,504(sp)
    80005334:	7a5e                	ld	s4,496(sp)
    80005336:	7abe                	ld	s5,488(sp)
    80005338:	7b1e                	ld	s6,480(sp)
    8000533a:	6bfe                	ld	s7,472(sp)
    8000533c:	6c5e                	ld	s8,464(sp)
    8000533e:	6cbe                	ld	s9,456(sp)
    80005340:	6d1e                	ld	s10,448(sp)
    80005342:	7dfa                	ld	s11,440(sp)
    80005344:	22010113          	addi	sp,sp,544
    80005348:	8082                	ret
    end_op();
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	476080e7          	jalr	1142(ra) # 800047c0 <end_op>
    return -1;
    80005352:	557d                	li	a0,-1
    80005354:	b7f9                	j	80005322 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005356:	8526                	mv	a0,s1
    80005358:	ffffd097          	auipc	ra,0xffffd
    8000535c:	8bc080e7          	jalr	-1860(ra) # 80001c14 <proc_pagetable>
    80005360:	8b2a                	mv	s6,a0
    80005362:	d555                	beqz	a0,8000530e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005364:	e7042783          	lw	a5,-400(s0)
    80005368:	e8845703          	lhu	a4,-376(s0)
    8000536c:	c735                	beqz	a4,800053d8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000536e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005370:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005374:	6a05                	lui	s4,0x1
    80005376:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000537a:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000537e:	6d85                	lui	s11,0x1
    80005380:	7d7d                	lui	s10,0xfffff
    80005382:	a481                	j	800055c2 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005384:	00003517          	auipc	a0,0x3
    80005388:	37c50513          	addi	a0,a0,892 # 80008700 <syscalls+0x2a0>
    8000538c:	ffffb097          	auipc	ra,0xffffb
    80005390:	1b2080e7          	jalr	434(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005394:	874a                	mv	a4,s2
    80005396:	009c86bb          	addw	a3,s9,s1
    8000539a:	4581                	li	a1,0
    8000539c:	8556                	mv	a0,s5
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	c94080e7          	jalr	-876(ra) # 80004032 <readi>
    800053a6:	2501                	sext.w	a0,a0
    800053a8:	1aa91a63          	bne	s2,a0,8000555c <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800053ac:	009d84bb          	addw	s1,s11,s1
    800053b0:	013d09bb          	addw	s3,s10,s3
    800053b4:	1f74f763          	bgeu	s1,s7,800055a2 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    800053b8:	02049593          	slli	a1,s1,0x20
    800053bc:	9181                	srli	a1,a1,0x20
    800053be:	95e2                	add	a1,a1,s8
    800053c0:	855a                	mv	a0,s6
    800053c2:	ffffc097          	auipc	ra,0xffffc
    800053c6:	ca2080e7          	jalr	-862(ra) # 80001064 <walkaddr>
    800053ca:	862a                	mv	a2,a0
    if(pa == 0)
    800053cc:	dd45                	beqz	a0,80005384 <exec+0xfe>
      n = PGSIZE;
    800053ce:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800053d0:	fd49f2e3          	bgeu	s3,s4,80005394 <exec+0x10e>
      n = sz - i;
    800053d4:	894e                	mv	s2,s3
    800053d6:	bf7d                	j	80005394 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053d8:	4901                	li	s2,0
  iunlockput(ip);
    800053da:	8556                	mv	a0,s5
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	c04080e7          	jalr	-1020(ra) # 80003fe0 <iunlockput>
  end_op();
    800053e4:	fffff097          	auipc	ra,0xfffff
    800053e8:	3dc080e7          	jalr	988(ra) # 800047c0 <end_op>
  p = myproc();
    800053ec:	ffffc097          	auipc	ra,0xffffc
    800053f0:	764080e7          	jalr	1892(ra) # 80001b50 <myproc>
    800053f4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800053f6:	05853d03          	ld	s10,88(a0)
  sz = PGROUNDUP(sz);
    800053fa:	6785                	lui	a5,0x1
    800053fc:	17fd                	addi	a5,a5,-1
    800053fe:	993e                	add	s2,s2,a5
    80005400:	77fd                	lui	a5,0xfffff
    80005402:	00f977b3          	and	a5,s2,a5
    80005406:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000540a:	4691                	li	a3,4
    8000540c:	6609                	lui	a2,0x2
    8000540e:	963e                	add	a2,a2,a5
    80005410:	85be                	mv	a1,a5
    80005412:	855a                	mv	a0,s6
    80005414:	ffffc097          	auipc	ra,0xffffc
    80005418:	004080e7          	jalr	4(ra) # 80001418 <uvmalloc>
    8000541c:	8c2a                	mv	s8,a0
  ip = 0;
    8000541e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005420:	12050e63          	beqz	a0,8000555c <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005424:	75f9                	lui	a1,0xffffe
    80005426:	95aa                	add	a1,a1,a0
    80005428:	855a                	mv	a0,s6
    8000542a:	ffffc097          	auipc	ra,0xffffc
    8000542e:	214080e7          	jalr	532(ra) # 8000163e <uvmclear>
  stackbase = sp - PGSIZE;
    80005432:	7afd                	lui	s5,0xfffff
    80005434:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005436:	df043783          	ld	a5,-528(s0)
    8000543a:	6388                	ld	a0,0(a5)
    8000543c:	c925                	beqz	a0,800054ac <exec+0x226>
    8000543e:	e9040993          	addi	s3,s0,-368
    80005442:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005446:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005448:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000544a:	ffffc097          	auipc	ra,0xffffc
    8000544e:	a04080e7          	jalr	-1532(ra) # 80000e4e <strlen>
    80005452:	0015079b          	addiw	a5,a0,1
    80005456:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000545a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000545e:	13596663          	bltu	s2,s5,8000558a <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005462:	df043d83          	ld	s11,-528(s0)
    80005466:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000546a:	8552                	mv	a0,s4
    8000546c:	ffffc097          	auipc	ra,0xffffc
    80005470:	9e2080e7          	jalr	-1566(ra) # 80000e4e <strlen>
    80005474:	0015069b          	addiw	a3,a0,1
    80005478:	8652                	mv	a2,s4
    8000547a:	85ca                	mv	a1,s2
    8000547c:	855a                	mv	a0,s6
    8000547e:	ffffc097          	auipc	ra,0xffffc
    80005482:	1f2080e7          	jalr	498(ra) # 80001670 <copyout>
    80005486:	10054663          	bltz	a0,80005592 <exec+0x30c>
    ustack[argc] = sp;
    8000548a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000548e:	0485                	addi	s1,s1,1
    80005490:	008d8793          	addi	a5,s11,8
    80005494:	def43823          	sd	a5,-528(s0)
    80005498:	008db503          	ld	a0,8(s11)
    8000549c:	c911                	beqz	a0,800054b0 <exec+0x22a>
    if(argc >= MAXARG)
    8000549e:	09a1                	addi	s3,s3,8
    800054a0:	fb3c95e3          	bne	s9,s3,8000544a <exec+0x1c4>
  sz = sz1;
    800054a4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054a8:	4a81                	li	s5,0
    800054aa:	a84d                	j	8000555c <exec+0x2d6>
  sp = sz;
    800054ac:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800054ae:	4481                	li	s1,0
  ustack[argc] = 0;
    800054b0:	00349793          	slli	a5,s1,0x3
    800054b4:	f9040713          	addi	a4,s0,-112
    800054b8:	97ba                	add	a5,a5,a4
    800054ba:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdbb60>
  sp -= (argc+1) * sizeof(uint64);
    800054be:	00148693          	addi	a3,s1,1
    800054c2:	068e                	slli	a3,a3,0x3
    800054c4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800054c8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800054cc:	01597663          	bgeu	s2,s5,800054d8 <exec+0x252>
  sz = sz1;
    800054d0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800054d4:	4a81                	li	s5,0
    800054d6:	a059                	j	8000555c <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800054d8:	e9040613          	addi	a2,s0,-368
    800054dc:	85ca                	mv	a1,s2
    800054de:	855a                	mv	a0,s6
    800054e0:	ffffc097          	auipc	ra,0xffffc
    800054e4:	190080e7          	jalr	400(ra) # 80001670 <copyout>
    800054e8:	0a054963          	bltz	a0,8000559a <exec+0x314>
  p->trapframe->a1 = sp;
    800054ec:	068bb783          	ld	a5,104(s7) # 1068 <_entry-0x7fffef98>
    800054f0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800054f4:	de843783          	ld	a5,-536(s0)
    800054f8:	0007c703          	lbu	a4,0(a5)
    800054fc:	cf11                	beqz	a4,80005518 <exec+0x292>
    800054fe:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005500:	02f00693          	li	a3,47
    80005504:	a039                	j	80005512 <exec+0x28c>
      last = s+1;
    80005506:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000550a:	0785                	addi	a5,a5,1
    8000550c:	fff7c703          	lbu	a4,-1(a5)
    80005510:	c701                	beqz	a4,80005518 <exec+0x292>
    if(*s == '/')
    80005512:	fed71ce3          	bne	a4,a3,8000550a <exec+0x284>
    80005516:	bfc5                	j	80005506 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005518:	4641                	li	a2,16
    8000551a:	de843583          	ld	a1,-536(s0)
    8000551e:	168b8513          	addi	a0,s7,360
    80005522:	ffffc097          	auipc	ra,0xffffc
    80005526:	8fa080e7          	jalr	-1798(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000552a:	060bb503          	ld	a0,96(s7)
  p->pagetable = pagetable;
    8000552e:	076bb023          	sd	s6,96(s7)
  p->sz = sz;
    80005532:	058bbc23          	sd	s8,88(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005536:	068bb783          	ld	a5,104(s7)
    8000553a:	e6843703          	ld	a4,-408(s0)
    8000553e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005540:	068bb783          	ld	a5,104(s7)
    80005544:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005548:	85ea                	mv	a1,s10
    8000554a:	ffffc097          	auipc	ra,0xffffc
    8000554e:	766080e7          	jalr	1894(ra) # 80001cb0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005552:	0004851b          	sext.w	a0,s1
    80005556:	b3f1                	j	80005322 <exec+0x9c>
    80005558:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000555c:	df843583          	ld	a1,-520(s0)
    80005560:	855a                	mv	a0,s6
    80005562:	ffffc097          	auipc	ra,0xffffc
    80005566:	74e080e7          	jalr	1870(ra) # 80001cb0 <proc_freepagetable>
  if(ip){
    8000556a:	da0a92e3          	bnez	s5,8000530e <exec+0x88>
  return -1;
    8000556e:	557d                	li	a0,-1
    80005570:	bb4d                	j	80005322 <exec+0x9c>
    80005572:	df243c23          	sd	s2,-520(s0)
    80005576:	b7dd                	j	8000555c <exec+0x2d6>
    80005578:	df243c23          	sd	s2,-520(s0)
    8000557c:	b7c5                	j	8000555c <exec+0x2d6>
    8000557e:	df243c23          	sd	s2,-520(s0)
    80005582:	bfe9                	j	8000555c <exec+0x2d6>
    80005584:	df243c23          	sd	s2,-520(s0)
    80005588:	bfd1                	j	8000555c <exec+0x2d6>
  sz = sz1;
    8000558a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000558e:	4a81                	li	s5,0
    80005590:	b7f1                	j	8000555c <exec+0x2d6>
  sz = sz1;
    80005592:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005596:	4a81                	li	s5,0
    80005598:	b7d1                	j	8000555c <exec+0x2d6>
  sz = sz1;
    8000559a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000559e:	4a81                	li	s5,0
    800055a0:	bf75                	j	8000555c <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055a2:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055a6:	e0843783          	ld	a5,-504(s0)
    800055aa:	0017869b          	addiw	a3,a5,1
    800055ae:	e0d43423          	sd	a3,-504(s0)
    800055b2:	e0043783          	ld	a5,-512(s0)
    800055b6:	0387879b          	addiw	a5,a5,56
    800055ba:	e8845703          	lhu	a4,-376(s0)
    800055be:	e0e6dee3          	bge	a3,a4,800053da <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055c2:	2781                	sext.w	a5,a5
    800055c4:	e0f43023          	sd	a5,-512(s0)
    800055c8:	03800713          	li	a4,56
    800055cc:	86be                	mv	a3,a5
    800055ce:	e1840613          	addi	a2,s0,-488
    800055d2:	4581                	li	a1,0
    800055d4:	8556                	mv	a0,s5
    800055d6:	fffff097          	auipc	ra,0xfffff
    800055da:	a5c080e7          	jalr	-1444(ra) # 80004032 <readi>
    800055de:	03800793          	li	a5,56
    800055e2:	f6f51be3          	bne	a0,a5,80005558 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800055e6:	e1842783          	lw	a5,-488(s0)
    800055ea:	4705                	li	a4,1
    800055ec:	fae79de3          	bne	a5,a4,800055a6 <exec+0x320>
    if(ph.memsz < ph.filesz)
    800055f0:	e4043483          	ld	s1,-448(s0)
    800055f4:	e3843783          	ld	a5,-456(s0)
    800055f8:	f6f4ede3          	bltu	s1,a5,80005572 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055fc:	e2843783          	ld	a5,-472(s0)
    80005600:	94be                	add	s1,s1,a5
    80005602:	f6f4ebe3          	bltu	s1,a5,80005578 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80005606:	de043703          	ld	a4,-544(s0)
    8000560a:	8ff9                	and	a5,a5,a4
    8000560c:	fbad                	bnez	a5,8000557e <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000560e:	e1c42503          	lw	a0,-484(s0)
    80005612:	00000097          	auipc	ra,0x0
    80005616:	c58080e7          	jalr	-936(ra) # 8000526a <flags2perm>
    8000561a:	86aa                	mv	a3,a0
    8000561c:	8626                	mv	a2,s1
    8000561e:	85ca                	mv	a1,s2
    80005620:	855a                	mv	a0,s6
    80005622:	ffffc097          	auipc	ra,0xffffc
    80005626:	df6080e7          	jalr	-522(ra) # 80001418 <uvmalloc>
    8000562a:	dea43c23          	sd	a0,-520(s0)
    8000562e:	d939                	beqz	a0,80005584 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005630:	e2843c03          	ld	s8,-472(s0)
    80005634:	e2042c83          	lw	s9,-480(s0)
    80005638:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000563c:	f60b83e3          	beqz	s7,800055a2 <exec+0x31c>
    80005640:	89de                	mv	s3,s7
    80005642:	4481                	li	s1,0
    80005644:	bb95                	j	800053b8 <exec+0x132>

0000000080005646 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005646:	7179                	addi	sp,sp,-48
    80005648:	f406                	sd	ra,40(sp)
    8000564a:	f022                	sd	s0,32(sp)
    8000564c:	ec26                	sd	s1,24(sp)
    8000564e:	e84a                	sd	s2,16(sp)
    80005650:	1800                	addi	s0,sp,48
    80005652:	892e                	mv	s2,a1
    80005654:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005656:	fdc40593          	addi	a1,s0,-36
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	a2c080e7          	jalr	-1492(ra) # 80003086 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005662:	fdc42703          	lw	a4,-36(s0)
    80005666:	47bd                	li	a5,15
    80005668:	02e7eb63          	bltu	a5,a4,8000569e <argfd+0x58>
    8000566c:	ffffc097          	auipc	ra,0xffffc
    80005670:	4e4080e7          	jalr	1252(ra) # 80001b50 <myproc>
    80005674:	fdc42703          	lw	a4,-36(s0)
    80005678:	01c70793          	addi	a5,a4,28
    8000567c:	078e                	slli	a5,a5,0x3
    8000567e:	953e                	add	a0,a0,a5
    80005680:	611c                	ld	a5,0(a0)
    80005682:	c385                	beqz	a5,800056a2 <argfd+0x5c>
    return -1;
  if(pfd)
    80005684:	00090463          	beqz	s2,8000568c <argfd+0x46>
    *pfd = fd;
    80005688:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000568c:	4501                	li	a0,0
  if(pf)
    8000568e:	c091                	beqz	s1,80005692 <argfd+0x4c>
    *pf = f;
    80005690:	e09c                	sd	a5,0(s1)
}
    80005692:	70a2                	ld	ra,40(sp)
    80005694:	7402                	ld	s0,32(sp)
    80005696:	64e2                	ld	s1,24(sp)
    80005698:	6942                	ld	s2,16(sp)
    8000569a:	6145                	addi	sp,sp,48
    8000569c:	8082                	ret
    return -1;
    8000569e:	557d                	li	a0,-1
    800056a0:	bfcd                	j	80005692 <argfd+0x4c>
    800056a2:	557d                	li	a0,-1
    800056a4:	b7fd                	j	80005692 <argfd+0x4c>

00000000800056a6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800056a6:	1101                	addi	sp,sp,-32
    800056a8:	ec06                	sd	ra,24(sp)
    800056aa:	e822                	sd	s0,16(sp)
    800056ac:	e426                	sd	s1,8(sp)
    800056ae:	1000                	addi	s0,sp,32
    800056b0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800056b2:	ffffc097          	auipc	ra,0xffffc
    800056b6:	49e080e7          	jalr	1182(ra) # 80001b50 <myproc>
    800056ba:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800056bc:	0e050793          	addi	a5,a0,224
    800056c0:	4501                	li	a0,0
    800056c2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800056c4:	6398                	ld	a4,0(a5)
    800056c6:	cb19                	beqz	a4,800056dc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800056c8:	2505                	addiw	a0,a0,1
    800056ca:	07a1                	addi	a5,a5,8
    800056cc:	fed51ce3          	bne	a0,a3,800056c4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800056d0:	557d                	li	a0,-1
}
    800056d2:	60e2                	ld	ra,24(sp)
    800056d4:	6442                	ld	s0,16(sp)
    800056d6:	64a2                	ld	s1,8(sp)
    800056d8:	6105                	addi	sp,sp,32
    800056da:	8082                	ret
      p->ofile[fd] = f;
    800056dc:	01c50793          	addi	a5,a0,28
    800056e0:	078e                	slli	a5,a5,0x3
    800056e2:	963e                	add	a2,a2,a5
    800056e4:	e204                	sd	s1,0(a2)
      return fd;
    800056e6:	b7f5                	j	800056d2 <fdalloc+0x2c>

00000000800056e8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800056e8:	715d                	addi	sp,sp,-80
    800056ea:	e486                	sd	ra,72(sp)
    800056ec:	e0a2                	sd	s0,64(sp)
    800056ee:	fc26                	sd	s1,56(sp)
    800056f0:	f84a                	sd	s2,48(sp)
    800056f2:	f44e                	sd	s3,40(sp)
    800056f4:	f052                	sd	s4,32(sp)
    800056f6:	ec56                	sd	s5,24(sp)
    800056f8:	e85a                	sd	s6,16(sp)
    800056fa:	0880                	addi	s0,sp,80
    800056fc:	8b2e                	mv	s6,a1
    800056fe:	89b2                	mv	s3,a2
    80005700:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005702:	fb040593          	addi	a1,s0,-80
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	e3c080e7          	jalr	-452(ra) # 80004542 <nameiparent>
    8000570e:	84aa                	mv	s1,a0
    80005710:	14050f63          	beqz	a0,8000586e <create+0x186>
    return 0;

  ilock(dp);
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	66a080e7          	jalr	1642(ra) # 80003d7e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000571c:	4601                	li	a2,0
    8000571e:	fb040593          	addi	a1,s0,-80
    80005722:	8526                	mv	a0,s1
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	b3e080e7          	jalr	-1218(ra) # 80004262 <dirlookup>
    8000572c:	8aaa                	mv	s5,a0
    8000572e:	c931                	beqz	a0,80005782 <create+0x9a>
    iunlockput(dp);
    80005730:	8526                	mv	a0,s1
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	8ae080e7          	jalr	-1874(ra) # 80003fe0 <iunlockput>
    ilock(ip);
    8000573a:	8556                	mv	a0,s5
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	642080e7          	jalr	1602(ra) # 80003d7e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005744:	000b059b          	sext.w	a1,s6
    80005748:	4789                	li	a5,2
    8000574a:	02f59563          	bne	a1,a5,80005774 <create+0x8c>
    8000574e:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbca4>
    80005752:	37f9                	addiw	a5,a5,-2
    80005754:	17c2                	slli	a5,a5,0x30
    80005756:	93c1                	srli	a5,a5,0x30
    80005758:	4705                	li	a4,1
    8000575a:	00f76d63          	bltu	a4,a5,80005774 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000575e:	8556                	mv	a0,s5
    80005760:	60a6                	ld	ra,72(sp)
    80005762:	6406                	ld	s0,64(sp)
    80005764:	74e2                	ld	s1,56(sp)
    80005766:	7942                	ld	s2,48(sp)
    80005768:	79a2                	ld	s3,40(sp)
    8000576a:	7a02                	ld	s4,32(sp)
    8000576c:	6ae2                	ld	s5,24(sp)
    8000576e:	6b42                	ld	s6,16(sp)
    80005770:	6161                	addi	sp,sp,80
    80005772:	8082                	ret
    iunlockput(ip);
    80005774:	8556                	mv	a0,s5
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	86a080e7          	jalr	-1942(ra) # 80003fe0 <iunlockput>
    return 0;
    8000577e:	4a81                	li	s5,0
    80005780:	bff9                	j	8000575e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005782:	85da                	mv	a1,s6
    80005784:	4088                	lw	a0,0(s1)
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	45c080e7          	jalr	1116(ra) # 80003be2 <ialloc>
    8000578e:	8a2a                	mv	s4,a0
    80005790:	c539                	beqz	a0,800057de <create+0xf6>
  ilock(ip);
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	5ec080e7          	jalr	1516(ra) # 80003d7e <ilock>
  ip->major = major;
    8000579a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000579e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800057a2:	4905                	li	s2,1
    800057a4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800057a8:	8552                	mv	a0,s4
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	50a080e7          	jalr	1290(ra) # 80003cb4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800057b2:	000b059b          	sext.w	a1,s6
    800057b6:	03258b63          	beq	a1,s2,800057ec <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800057ba:	004a2603          	lw	a2,4(s4)
    800057be:	fb040593          	addi	a1,s0,-80
    800057c2:	8526                	mv	a0,s1
    800057c4:	fffff097          	auipc	ra,0xfffff
    800057c8:	cae080e7          	jalr	-850(ra) # 80004472 <dirlink>
    800057cc:	06054f63          	bltz	a0,8000584a <create+0x162>
  iunlockput(dp);
    800057d0:	8526                	mv	a0,s1
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	80e080e7          	jalr	-2034(ra) # 80003fe0 <iunlockput>
  return ip;
    800057da:	8ad2                	mv	s5,s4
    800057dc:	b749                	j	8000575e <create+0x76>
    iunlockput(dp);
    800057de:	8526                	mv	a0,s1
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	800080e7          	jalr	-2048(ra) # 80003fe0 <iunlockput>
    return 0;
    800057e8:	8ad2                	mv	s5,s4
    800057ea:	bf95                	j	8000575e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800057ec:	004a2603          	lw	a2,4(s4)
    800057f0:	00003597          	auipc	a1,0x3
    800057f4:	f3058593          	addi	a1,a1,-208 # 80008720 <syscalls+0x2c0>
    800057f8:	8552                	mv	a0,s4
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	c78080e7          	jalr	-904(ra) # 80004472 <dirlink>
    80005802:	04054463          	bltz	a0,8000584a <create+0x162>
    80005806:	40d0                	lw	a2,4(s1)
    80005808:	00003597          	auipc	a1,0x3
    8000580c:	f2058593          	addi	a1,a1,-224 # 80008728 <syscalls+0x2c8>
    80005810:	8552                	mv	a0,s4
    80005812:	fffff097          	auipc	ra,0xfffff
    80005816:	c60080e7          	jalr	-928(ra) # 80004472 <dirlink>
    8000581a:	02054863          	bltz	a0,8000584a <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000581e:	004a2603          	lw	a2,4(s4)
    80005822:	fb040593          	addi	a1,s0,-80
    80005826:	8526                	mv	a0,s1
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	c4a080e7          	jalr	-950(ra) # 80004472 <dirlink>
    80005830:	00054d63          	bltz	a0,8000584a <create+0x162>
    dp->nlink++;  // for ".."
    80005834:	04a4d783          	lhu	a5,74(s1)
    80005838:	2785                	addiw	a5,a5,1
    8000583a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000583e:	8526                	mv	a0,s1
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	474080e7          	jalr	1140(ra) # 80003cb4 <iupdate>
    80005848:	b761                	j	800057d0 <create+0xe8>
  ip->nlink = 0;
    8000584a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000584e:	8552                	mv	a0,s4
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	464080e7          	jalr	1124(ra) # 80003cb4 <iupdate>
  iunlockput(ip);
    80005858:	8552                	mv	a0,s4
    8000585a:	ffffe097          	auipc	ra,0xffffe
    8000585e:	786080e7          	jalr	1926(ra) # 80003fe0 <iunlockput>
  iunlockput(dp);
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	77c080e7          	jalr	1916(ra) # 80003fe0 <iunlockput>
  return 0;
    8000586c:	bdcd                	j	8000575e <create+0x76>
    return 0;
    8000586e:	8aaa                	mv	s5,a0
    80005870:	b5fd                	j	8000575e <create+0x76>

0000000080005872 <sys_dup>:
{
    80005872:	7179                	addi	sp,sp,-48
    80005874:	f406                	sd	ra,40(sp)
    80005876:	f022                	sd	s0,32(sp)
    80005878:	ec26                	sd	s1,24(sp)
    8000587a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000587c:	fd840613          	addi	a2,s0,-40
    80005880:	4581                	li	a1,0
    80005882:	4501                	li	a0,0
    80005884:	00000097          	auipc	ra,0x0
    80005888:	dc2080e7          	jalr	-574(ra) # 80005646 <argfd>
    return -1;
    8000588c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000588e:	02054363          	bltz	a0,800058b4 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005892:	fd843503          	ld	a0,-40(s0)
    80005896:	00000097          	auipc	ra,0x0
    8000589a:	e10080e7          	jalr	-496(ra) # 800056a6 <fdalloc>
    8000589e:	84aa                	mv	s1,a0
    return -1;
    800058a0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800058a2:	00054963          	bltz	a0,800058b4 <sys_dup+0x42>
  filedup(f);
    800058a6:	fd843503          	ld	a0,-40(s0)
    800058aa:	fffff097          	auipc	ra,0xfffff
    800058ae:	310080e7          	jalr	784(ra) # 80004bba <filedup>
  return fd;
    800058b2:	87a6                	mv	a5,s1
}
    800058b4:	853e                	mv	a0,a5
    800058b6:	70a2                	ld	ra,40(sp)
    800058b8:	7402                	ld	s0,32(sp)
    800058ba:	64e2                	ld	s1,24(sp)
    800058bc:	6145                	addi	sp,sp,48
    800058be:	8082                	ret

00000000800058c0 <sys_read>:
{
    800058c0:	7179                	addi	sp,sp,-48
    800058c2:	f406                	sd	ra,40(sp)
    800058c4:	f022                	sd	s0,32(sp)
    800058c6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800058c8:	fd840593          	addi	a1,s0,-40
    800058cc:	4505                	li	a0,1
    800058ce:	ffffd097          	auipc	ra,0xffffd
    800058d2:	7d8080e7          	jalr	2008(ra) # 800030a6 <argaddr>
  argint(2, &n);
    800058d6:	fe440593          	addi	a1,s0,-28
    800058da:	4509                	li	a0,2
    800058dc:	ffffd097          	auipc	ra,0xffffd
    800058e0:	7aa080e7          	jalr	1962(ra) # 80003086 <argint>
  if(argfd(0, 0, &f) < 0)
    800058e4:	fe840613          	addi	a2,s0,-24
    800058e8:	4581                	li	a1,0
    800058ea:	4501                	li	a0,0
    800058ec:	00000097          	auipc	ra,0x0
    800058f0:	d5a080e7          	jalr	-678(ra) # 80005646 <argfd>
    800058f4:	87aa                	mv	a5,a0
    return -1;
    800058f6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058f8:	0007cc63          	bltz	a5,80005910 <sys_read+0x50>
  return fileread(f, p, n);
    800058fc:	fe442603          	lw	a2,-28(s0)
    80005900:	fd843583          	ld	a1,-40(s0)
    80005904:	fe843503          	ld	a0,-24(s0)
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	43e080e7          	jalr	1086(ra) # 80004d46 <fileread>
}
    80005910:	70a2                	ld	ra,40(sp)
    80005912:	7402                	ld	s0,32(sp)
    80005914:	6145                	addi	sp,sp,48
    80005916:	8082                	ret

0000000080005918 <sys_write>:
{
    80005918:	7179                	addi	sp,sp,-48
    8000591a:	f406                	sd	ra,40(sp)
    8000591c:	f022                	sd	s0,32(sp)
    8000591e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005920:	fd840593          	addi	a1,s0,-40
    80005924:	4505                	li	a0,1
    80005926:	ffffd097          	auipc	ra,0xffffd
    8000592a:	780080e7          	jalr	1920(ra) # 800030a6 <argaddr>
  argint(2, &n);
    8000592e:	fe440593          	addi	a1,s0,-28
    80005932:	4509                	li	a0,2
    80005934:	ffffd097          	auipc	ra,0xffffd
    80005938:	752080e7          	jalr	1874(ra) # 80003086 <argint>
  if(argfd(0, 0, &f) < 0)
    8000593c:	fe840613          	addi	a2,s0,-24
    80005940:	4581                	li	a1,0
    80005942:	4501                	li	a0,0
    80005944:	00000097          	auipc	ra,0x0
    80005948:	d02080e7          	jalr	-766(ra) # 80005646 <argfd>
    8000594c:	87aa                	mv	a5,a0
    return -1;
    8000594e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005950:	0007cc63          	bltz	a5,80005968 <sys_write+0x50>
  return filewrite(f, p, n);
    80005954:	fe442603          	lw	a2,-28(s0)
    80005958:	fd843583          	ld	a1,-40(s0)
    8000595c:	fe843503          	ld	a0,-24(s0)
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	4a8080e7          	jalr	1192(ra) # 80004e08 <filewrite>
}
    80005968:	70a2                	ld	ra,40(sp)
    8000596a:	7402                	ld	s0,32(sp)
    8000596c:	6145                	addi	sp,sp,48
    8000596e:	8082                	ret

0000000080005970 <sys_close>:
{
    80005970:	1101                	addi	sp,sp,-32
    80005972:	ec06                	sd	ra,24(sp)
    80005974:	e822                	sd	s0,16(sp)
    80005976:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005978:	fe040613          	addi	a2,s0,-32
    8000597c:	fec40593          	addi	a1,s0,-20
    80005980:	4501                	li	a0,0
    80005982:	00000097          	auipc	ra,0x0
    80005986:	cc4080e7          	jalr	-828(ra) # 80005646 <argfd>
    return -1;
    8000598a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000598c:	02054463          	bltz	a0,800059b4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005990:	ffffc097          	auipc	ra,0xffffc
    80005994:	1c0080e7          	jalr	448(ra) # 80001b50 <myproc>
    80005998:	fec42783          	lw	a5,-20(s0)
    8000599c:	07f1                	addi	a5,a5,28
    8000599e:	078e                	slli	a5,a5,0x3
    800059a0:	97aa                	add	a5,a5,a0
    800059a2:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800059a6:	fe043503          	ld	a0,-32(s0)
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	262080e7          	jalr	610(ra) # 80004c0c <fileclose>
  return 0;
    800059b2:	4781                	li	a5,0
}
    800059b4:	853e                	mv	a0,a5
    800059b6:	60e2                	ld	ra,24(sp)
    800059b8:	6442                	ld	s0,16(sp)
    800059ba:	6105                	addi	sp,sp,32
    800059bc:	8082                	ret

00000000800059be <sys_fstat>:
{
    800059be:	1101                	addi	sp,sp,-32
    800059c0:	ec06                	sd	ra,24(sp)
    800059c2:	e822                	sd	s0,16(sp)
    800059c4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800059c6:	fe040593          	addi	a1,s0,-32
    800059ca:	4505                	li	a0,1
    800059cc:	ffffd097          	auipc	ra,0xffffd
    800059d0:	6da080e7          	jalr	1754(ra) # 800030a6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800059d4:	fe840613          	addi	a2,s0,-24
    800059d8:	4581                	li	a1,0
    800059da:	4501                	li	a0,0
    800059dc:	00000097          	auipc	ra,0x0
    800059e0:	c6a080e7          	jalr	-918(ra) # 80005646 <argfd>
    800059e4:	87aa                	mv	a5,a0
    return -1;
    800059e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059e8:	0007ca63          	bltz	a5,800059fc <sys_fstat+0x3e>
  return filestat(f, st);
    800059ec:	fe043583          	ld	a1,-32(s0)
    800059f0:	fe843503          	ld	a0,-24(s0)
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	2e0080e7          	jalr	736(ra) # 80004cd4 <filestat>
}
    800059fc:	60e2                	ld	ra,24(sp)
    800059fe:	6442                	ld	s0,16(sp)
    80005a00:	6105                	addi	sp,sp,32
    80005a02:	8082                	ret

0000000080005a04 <sys_link>:
{
    80005a04:	7169                	addi	sp,sp,-304
    80005a06:	f606                	sd	ra,296(sp)
    80005a08:	f222                	sd	s0,288(sp)
    80005a0a:	ee26                	sd	s1,280(sp)
    80005a0c:	ea4a                	sd	s2,272(sp)
    80005a0e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a10:	08000613          	li	a2,128
    80005a14:	ed040593          	addi	a1,s0,-304
    80005a18:	4501                	li	a0,0
    80005a1a:	ffffd097          	auipc	ra,0xffffd
    80005a1e:	6ac080e7          	jalr	1708(ra) # 800030c6 <argstr>
    return -1;
    80005a22:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a24:	10054e63          	bltz	a0,80005b40 <sys_link+0x13c>
    80005a28:	08000613          	li	a2,128
    80005a2c:	f5040593          	addi	a1,s0,-176
    80005a30:	4505                	li	a0,1
    80005a32:	ffffd097          	auipc	ra,0xffffd
    80005a36:	694080e7          	jalr	1684(ra) # 800030c6 <argstr>
    return -1;
    80005a3a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a3c:	10054263          	bltz	a0,80005b40 <sys_link+0x13c>
  begin_op();
    80005a40:	fffff097          	auipc	ra,0xfffff
    80005a44:	d00080e7          	jalr	-768(ra) # 80004740 <begin_op>
  if((ip = namei(old)) == 0){
    80005a48:	ed040513          	addi	a0,s0,-304
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	ad8080e7          	jalr	-1320(ra) # 80004524 <namei>
    80005a54:	84aa                	mv	s1,a0
    80005a56:	c551                	beqz	a0,80005ae2 <sys_link+0xde>
  ilock(ip);
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	326080e7          	jalr	806(ra) # 80003d7e <ilock>
  if(ip->type == T_DIR){
    80005a60:	04449703          	lh	a4,68(s1)
    80005a64:	4785                	li	a5,1
    80005a66:	08f70463          	beq	a4,a5,80005aee <sys_link+0xea>
  ip->nlink++;
    80005a6a:	04a4d783          	lhu	a5,74(s1)
    80005a6e:	2785                	addiw	a5,a5,1
    80005a70:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	23e080e7          	jalr	574(ra) # 80003cb4 <iupdate>
  iunlock(ip);
    80005a7e:	8526                	mv	a0,s1
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	3c0080e7          	jalr	960(ra) # 80003e40 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a88:	fd040593          	addi	a1,s0,-48
    80005a8c:	f5040513          	addi	a0,s0,-176
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	ab2080e7          	jalr	-1358(ra) # 80004542 <nameiparent>
    80005a98:	892a                	mv	s2,a0
    80005a9a:	c935                	beqz	a0,80005b0e <sys_link+0x10a>
  ilock(dp);
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	2e2080e7          	jalr	738(ra) # 80003d7e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005aa4:	00092703          	lw	a4,0(s2)
    80005aa8:	409c                	lw	a5,0(s1)
    80005aaa:	04f71d63          	bne	a4,a5,80005b04 <sys_link+0x100>
    80005aae:	40d0                	lw	a2,4(s1)
    80005ab0:	fd040593          	addi	a1,s0,-48
    80005ab4:	854a                	mv	a0,s2
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	9bc080e7          	jalr	-1604(ra) # 80004472 <dirlink>
    80005abe:	04054363          	bltz	a0,80005b04 <sys_link+0x100>
  iunlockput(dp);
    80005ac2:	854a                	mv	a0,s2
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	51c080e7          	jalr	1308(ra) # 80003fe0 <iunlockput>
  iput(ip);
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	46a080e7          	jalr	1130(ra) # 80003f38 <iput>
  end_op();
    80005ad6:	fffff097          	auipc	ra,0xfffff
    80005ada:	cea080e7          	jalr	-790(ra) # 800047c0 <end_op>
  return 0;
    80005ade:	4781                	li	a5,0
    80005ae0:	a085                	j	80005b40 <sys_link+0x13c>
    end_op();
    80005ae2:	fffff097          	auipc	ra,0xfffff
    80005ae6:	cde080e7          	jalr	-802(ra) # 800047c0 <end_op>
    return -1;
    80005aea:	57fd                	li	a5,-1
    80005aec:	a891                	j	80005b40 <sys_link+0x13c>
    iunlockput(ip);
    80005aee:	8526                	mv	a0,s1
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	4f0080e7          	jalr	1264(ra) # 80003fe0 <iunlockput>
    end_op();
    80005af8:	fffff097          	auipc	ra,0xfffff
    80005afc:	cc8080e7          	jalr	-824(ra) # 800047c0 <end_op>
    return -1;
    80005b00:	57fd                	li	a5,-1
    80005b02:	a83d                	j	80005b40 <sys_link+0x13c>
    iunlockput(dp);
    80005b04:	854a                	mv	a0,s2
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	4da080e7          	jalr	1242(ra) # 80003fe0 <iunlockput>
  ilock(ip);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	26e080e7          	jalr	622(ra) # 80003d7e <ilock>
  ip->nlink--;
    80005b18:	04a4d783          	lhu	a5,74(s1)
    80005b1c:	37fd                	addiw	a5,a5,-1
    80005b1e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b22:	8526                	mv	a0,s1
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	190080e7          	jalr	400(ra) # 80003cb4 <iupdate>
  iunlockput(ip);
    80005b2c:	8526                	mv	a0,s1
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	4b2080e7          	jalr	1202(ra) # 80003fe0 <iunlockput>
  end_op();
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	c8a080e7          	jalr	-886(ra) # 800047c0 <end_op>
  return -1;
    80005b3e:	57fd                	li	a5,-1
}
    80005b40:	853e                	mv	a0,a5
    80005b42:	70b2                	ld	ra,296(sp)
    80005b44:	7412                	ld	s0,288(sp)
    80005b46:	64f2                	ld	s1,280(sp)
    80005b48:	6952                	ld	s2,272(sp)
    80005b4a:	6155                	addi	sp,sp,304
    80005b4c:	8082                	ret

0000000080005b4e <sys_unlink>:
{
    80005b4e:	7151                	addi	sp,sp,-240
    80005b50:	f586                	sd	ra,232(sp)
    80005b52:	f1a2                	sd	s0,224(sp)
    80005b54:	eda6                	sd	s1,216(sp)
    80005b56:	e9ca                	sd	s2,208(sp)
    80005b58:	e5ce                	sd	s3,200(sp)
    80005b5a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b5c:	08000613          	li	a2,128
    80005b60:	f3040593          	addi	a1,s0,-208
    80005b64:	4501                	li	a0,0
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	560080e7          	jalr	1376(ra) # 800030c6 <argstr>
    80005b6e:	18054163          	bltz	a0,80005cf0 <sys_unlink+0x1a2>
  begin_op();
    80005b72:	fffff097          	auipc	ra,0xfffff
    80005b76:	bce080e7          	jalr	-1074(ra) # 80004740 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b7a:	fb040593          	addi	a1,s0,-80
    80005b7e:	f3040513          	addi	a0,s0,-208
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	9c0080e7          	jalr	-1600(ra) # 80004542 <nameiparent>
    80005b8a:	84aa                	mv	s1,a0
    80005b8c:	c979                	beqz	a0,80005c62 <sys_unlink+0x114>
  ilock(dp);
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	1f0080e7          	jalr	496(ra) # 80003d7e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b96:	00003597          	auipc	a1,0x3
    80005b9a:	b8a58593          	addi	a1,a1,-1142 # 80008720 <syscalls+0x2c0>
    80005b9e:	fb040513          	addi	a0,s0,-80
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	6a6080e7          	jalr	1702(ra) # 80004248 <namecmp>
    80005baa:	14050a63          	beqz	a0,80005cfe <sys_unlink+0x1b0>
    80005bae:	00003597          	auipc	a1,0x3
    80005bb2:	b7a58593          	addi	a1,a1,-1158 # 80008728 <syscalls+0x2c8>
    80005bb6:	fb040513          	addi	a0,s0,-80
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	68e080e7          	jalr	1678(ra) # 80004248 <namecmp>
    80005bc2:	12050e63          	beqz	a0,80005cfe <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005bc6:	f2c40613          	addi	a2,s0,-212
    80005bca:	fb040593          	addi	a1,s0,-80
    80005bce:	8526                	mv	a0,s1
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	692080e7          	jalr	1682(ra) # 80004262 <dirlookup>
    80005bd8:	892a                	mv	s2,a0
    80005bda:	12050263          	beqz	a0,80005cfe <sys_unlink+0x1b0>
  ilock(ip);
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	1a0080e7          	jalr	416(ra) # 80003d7e <ilock>
  if(ip->nlink < 1)
    80005be6:	04a91783          	lh	a5,74(s2)
    80005bea:	08f05263          	blez	a5,80005c6e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005bee:	04491703          	lh	a4,68(s2)
    80005bf2:	4785                	li	a5,1
    80005bf4:	08f70563          	beq	a4,a5,80005c7e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005bf8:	4641                	li	a2,16
    80005bfa:	4581                	li	a1,0
    80005bfc:	fc040513          	addi	a0,s0,-64
    80005c00:	ffffb097          	auipc	ra,0xffffb
    80005c04:	0d2080e7          	jalr	210(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c08:	4741                	li	a4,16
    80005c0a:	f2c42683          	lw	a3,-212(s0)
    80005c0e:	fc040613          	addi	a2,s0,-64
    80005c12:	4581                	li	a1,0
    80005c14:	8526                	mv	a0,s1
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	514080e7          	jalr	1300(ra) # 8000412a <writei>
    80005c1e:	47c1                	li	a5,16
    80005c20:	0af51563          	bne	a0,a5,80005cca <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005c24:	04491703          	lh	a4,68(s2)
    80005c28:	4785                	li	a5,1
    80005c2a:	0af70863          	beq	a4,a5,80005cda <sys_unlink+0x18c>
  iunlockput(dp);
    80005c2e:	8526                	mv	a0,s1
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	3b0080e7          	jalr	944(ra) # 80003fe0 <iunlockput>
  ip->nlink--;
    80005c38:	04a95783          	lhu	a5,74(s2)
    80005c3c:	37fd                	addiw	a5,a5,-1
    80005c3e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c42:	854a                	mv	a0,s2
    80005c44:	ffffe097          	auipc	ra,0xffffe
    80005c48:	070080e7          	jalr	112(ra) # 80003cb4 <iupdate>
  iunlockput(ip);
    80005c4c:	854a                	mv	a0,s2
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	392080e7          	jalr	914(ra) # 80003fe0 <iunlockput>
  end_op();
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	b6a080e7          	jalr	-1174(ra) # 800047c0 <end_op>
  return 0;
    80005c5e:	4501                	li	a0,0
    80005c60:	a84d                	j	80005d12 <sys_unlink+0x1c4>
    end_op();
    80005c62:	fffff097          	auipc	ra,0xfffff
    80005c66:	b5e080e7          	jalr	-1186(ra) # 800047c0 <end_op>
    return -1;
    80005c6a:	557d                	li	a0,-1
    80005c6c:	a05d                	j	80005d12 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c6e:	00003517          	auipc	a0,0x3
    80005c72:	ac250513          	addi	a0,a0,-1342 # 80008730 <syscalls+0x2d0>
    80005c76:	ffffb097          	auipc	ra,0xffffb
    80005c7a:	8c8080e7          	jalr	-1848(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c7e:	04c92703          	lw	a4,76(s2)
    80005c82:	02000793          	li	a5,32
    80005c86:	f6e7f9e3          	bgeu	a5,a4,80005bf8 <sys_unlink+0xaa>
    80005c8a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c8e:	4741                	li	a4,16
    80005c90:	86ce                	mv	a3,s3
    80005c92:	f1840613          	addi	a2,s0,-232
    80005c96:	4581                	li	a1,0
    80005c98:	854a                	mv	a0,s2
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	398080e7          	jalr	920(ra) # 80004032 <readi>
    80005ca2:	47c1                	li	a5,16
    80005ca4:	00f51b63          	bne	a0,a5,80005cba <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ca8:	f1845783          	lhu	a5,-232(s0)
    80005cac:	e7a1                	bnez	a5,80005cf4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005cae:	29c1                	addiw	s3,s3,16
    80005cb0:	04c92783          	lw	a5,76(s2)
    80005cb4:	fcf9ede3          	bltu	s3,a5,80005c8e <sys_unlink+0x140>
    80005cb8:	b781                	j	80005bf8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005cba:	00003517          	auipc	a0,0x3
    80005cbe:	a8e50513          	addi	a0,a0,-1394 # 80008748 <syscalls+0x2e8>
    80005cc2:	ffffb097          	auipc	ra,0xffffb
    80005cc6:	87c080e7          	jalr	-1924(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005cca:	00003517          	auipc	a0,0x3
    80005cce:	a9650513          	addi	a0,a0,-1386 # 80008760 <syscalls+0x300>
    80005cd2:	ffffb097          	auipc	ra,0xffffb
    80005cd6:	86c080e7          	jalr	-1940(ra) # 8000053e <panic>
    dp->nlink--;
    80005cda:	04a4d783          	lhu	a5,74(s1)
    80005cde:	37fd                	addiw	a5,a5,-1
    80005ce0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ce4:	8526                	mv	a0,s1
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	fce080e7          	jalr	-50(ra) # 80003cb4 <iupdate>
    80005cee:	b781                	j	80005c2e <sys_unlink+0xe0>
    return -1;
    80005cf0:	557d                	li	a0,-1
    80005cf2:	a005                	j	80005d12 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005cf4:	854a                	mv	a0,s2
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	2ea080e7          	jalr	746(ra) # 80003fe0 <iunlockput>
  iunlockput(dp);
    80005cfe:	8526                	mv	a0,s1
    80005d00:	ffffe097          	auipc	ra,0xffffe
    80005d04:	2e0080e7          	jalr	736(ra) # 80003fe0 <iunlockput>
  end_op();
    80005d08:	fffff097          	auipc	ra,0xfffff
    80005d0c:	ab8080e7          	jalr	-1352(ra) # 800047c0 <end_op>
  return -1;
    80005d10:	557d                	li	a0,-1
}
    80005d12:	70ae                	ld	ra,232(sp)
    80005d14:	740e                	ld	s0,224(sp)
    80005d16:	64ee                	ld	s1,216(sp)
    80005d18:	694e                	ld	s2,208(sp)
    80005d1a:	69ae                	ld	s3,200(sp)
    80005d1c:	616d                	addi	sp,sp,240
    80005d1e:	8082                	ret

0000000080005d20 <sys_open>:

uint64
sys_open(void)
{
    80005d20:	7131                	addi	sp,sp,-192
    80005d22:	fd06                	sd	ra,184(sp)
    80005d24:	f922                	sd	s0,176(sp)
    80005d26:	f526                	sd	s1,168(sp)
    80005d28:	f14a                	sd	s2,160(sp)
    80005d2a:	ed4e                	sd	s3,152(sp)
    80005d2c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d2e:	f4c40593          	addi	a1,s0,-180
    80005d32:	4505                	li	a0,1
    80005d34:	ffffd097          	auipc	ra,0xffffd
    80005d38:	352080e7          	jalr	850(ra) # 80003086 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d3c:	08000613          	li	a2,128
    80005d40:	f5040593          	addi	a1,s0,-176
    80005d44:	4501                	li	a0,0
    80005d46:	ffffd097          	auipc	ra,0xffffd
    80005d4a:	380080e7          	jalr	896(ra) # 800030c6 <argstr>
    80005d4e:	87aa                	mv	a5,a0
    return -1;
    80005d50:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d52:	0a07c963          	bltz	a5,80005e04 <sys_open+0xe4>

  begin_op();
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	9ea080e7          	jalr	-1558(ra) # 80004740 <begin_op>

  if(omode & O_CREATE){
    80005d5e:	f4c42783          	lw	a5,-180(s0)
    80005d62:	2007f793          	andi	a5,a5,512
    80005d66:	cfc5                	beqz	a5,80005e1e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005d68:	4681                	li	a3,0
    80005d6a:	4601                	li	a2,0
    80005d6c:	4589                	li	a1,2
    80005d6e:	f5040513          	addi	a0,s0,-176
    80005d72:	00000097          	auipc	ra,0x0
    80005d76:	976080e7          	jalr	-1674(ra) # 800056e8 <create>
    80005d7a:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d7c:	c959                	beqz	a0,80005e12 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d7e:	04449703          	lh	a4,68(s1)
    80005d82:	478d                	li	a5,3
    80005d84:	00f71763          	bne	a4,a5,80005d92 <sys_open+0x72>
    80005d88:	0464d703          	lhu	a4,70(s1)
    80005d8c:	47a5                	li	a5,9
    80005d8e:	0ce7ed63          	bltu	a5,a4,80005e68 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d92:	fffff097          	auipc	ra,0xfffff
    80005d96:	dbe080e7          	jalr	-578(ra) # 80004b50 <filealloc>
    80005d9a:	89aa                	mv	s3,a0
    80005d9c:	10050363          	beqz	a0,80005ea2 <sys_open+0x182>
    80005da0:	00000097          	auipc	ra,0x0
    80005da4:	906080e7          	jalr	-1786(ra) # 800056a6 <fdalloc>
    80005da8:	892a                	mv	s2,a0
    80005daa:	0e054763          	bltz	a0,80005e98 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005dae:	04449703          	lh	a4,68(s1)
    80005db2:	478d                	li	a5,3
    80005db4:	0cf70563          	beq	a4,a5,80005e7e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005db8:	4789                	li	a5,2
    80005dba:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005dbe:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005dc2:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005dc6:	f4c42783          	lw	a5,-180(s0)
    80005dca:	0017c713          	xori	a4,a5,1
    80005dce:	8b05                	andi	a4,a4,1
    80005dd0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005dd4:	0037f713          	andi	a4,a5,3
    80005dd8:	00e03733          	snez	a4,a4
    80005ddc:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005de0:	4007f793          	andi	a5,a5,1024
    80005de4:	c791                	beqz	a5,80005df0 <sys_open+0xd0>
    80005de6:	04449703          	lh	a4,68(s1)
    80005dea:	4789                	li	a5,2
    80005dec:	0af70063          	beq	a4,a5,80005e8c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005df0:	8526                	mv	a0,s1
    80005df2:	ffffe097          	auipc	ra,0xffffe
    80005df6:	04e080e7          	jalr	78(ra) # 80003e40 <iunlock>
  end_op();
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	9c6080e7          	jalr	-1594(ra) # 800047c0 <end_op>

  return fd;
    80005e02:	854a                	mv	a0,s2
}
    80005e04:	70ea                	ld	ra,184(sp)
    80005e06:	744a                	ld	s0,176(sp)
    80005e08:	74aa                	ld	s1,168(sp)
    80005e0a:	790a                	ld	s2,160(sp)
    80005e0c:	69ea                	ld	s3,152(sp)
    80005e0e:	6129                	addi	sp,sp,192
    80005e10:	8082                	ret
      end_op();
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	9ae080e7          	jalr	-1618(ra) # 800047c0 <end_op>
      return -1;
    80005e1a:	557d                	li	a0,-1
    80005e1c:	b7e5                	j	80005e04 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005e1e:	f5040513          	addi	a0,s0,-176
    80005e22:	ffffe097          	auipc	ra,0xffffe
    80005e26:	702080e7          	jalr	1794(ra) # 80004524 <namei>
    80005e2a:	84aa                	mv	s1,a0
    80005e2c:	c905                	beqz	a0,80005e5c <sys_open+0x13c>
    ilock(ip);
    80005e2e:	ffffe097          	auipc	ra,0xffffe
    80005e32:	f50080e7          	jalr	-176(ra) # 80003d7e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e36:	04449703          	lh	a4,68(s1)
    80005e3a:	4785                	li	a5,1
    80005e3c:	f4f711e3          	bne	a4,a5,80005d7e <sys_open+0x5e>
    80005e40:	f4c42783          	lw	a5,-180(s0)
    80005e44:	d7b9                	beqz	a5,80005d92 <sys_open+0x72>
      iunlockput(ip);
    80005e46:	8526                	mv	a0,s1
    80005e48:	ffffe097          	auipc	ra,0xffffe
    80005e4c:	198080e7          	jalr	408(ra) # 80003fe0 <iunlockput>
      end_op();
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	970080e7          	jalr	-1680(ra) # 800047c0 <end_op>
      return -1;
    80005e58:	557d                	li	a0,-1
    80005e5a:	b76d                	j	80005e04 <sys_open+0xe4>
      end_op();
    80005e5c:	fffff097          	auipc	ra,0xfffff
    80005e60:	964080e7          	jalr	-1692(ra) # 800047c0 <end_op>
      return -1;
    80005e64:	557d                	li	a0,-1
    80005e66:	bf79                	j	80005e04 <sys_open+0xe4>
    iunlockput(ip);
    80005e68:	8526                	mv	a0,s1
    80005e6a:	ffffe097          	auipc	ra,0xffffe
    80005e6e:	176080e7          	jalr	374(ra) # 80003fe0 <iunlockput>
    end_op();
    80005e72:	fffff097          	auipc	ra,0xfffff
    80005e76:	94e080e7          	jalr	-1714(ra) # 800047c0 <end_op>
    return -1;
    80005e7a:	557d                	li	a0,-1
    80005e7c:	b761                	j	80005e04 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e7e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e82:	04649783          	lh	a5,70(s1)
    80005e86:	02f99223          	sh	a5,36(s3)
    80005e8a:	bf25                	j	80005dc2 <sys_open+0xa2>
    itrunc(ip);
    80005e8c:	8526                	mv	a0,s1
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	ffe080e7          	jalr	-2(ra) # 80003e8c <itrunc>
    80005e96:	bfa9                	j	80005df0 <sys_open+0xd0>
      fileclose(f);
    80005e98:	854e                	mv	a0,s3
    80005e9a:	fffff097          	auipc	ra,0xfffff
    80005e9e:	d72080e7          	jalr	-654(ra) # 80004c0c <fileclose>
    iunlockput(ip);
    80005ea2:	8526                	mv	a0,s1
    80005ea4:	ffffe097          	auipc	ra,0xffffe
    80005ea8:	13c080e7          	jalr	316(ra) # 80003fe0 <iunlockput>
    end_op();
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	914080e7          	jalr	-1772(ra) # 800047c0 <end_op>
    return -1;
    80005eb4:	557d                	li	a0,-1
    80005eb6:	b7b9                	j	80005e04 <sys_open+0xe4>

0000000080005eb8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005eb8:	7175                	addi	sp,sp,-144
    80005eba:	e506                	sd	ra,136(sp)
    80005ebc:	e122                	sd	s0,128(sp)
    80005ebe:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ec0:	fffff097          	auipc	ra,0xfffff
    80005ec4:	880080e7          	jalr	-1920(ra) # 80004740 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ec8:	08000613          	li	a2,128
    80005ecc:	f7040593          	addi	a1,s0,-144
    80005ed0:	4501                	li	a0,0
    80005ed2:	ffffd097          	auipc	ra,0xffffd
    80005ed6:	1f4080e7          	jalr	500(ra) # 800030c6 <argstr>
    80005eda:	02054963          	bltz	a0,80005f0c <sys_mkdir+0x54>
    80005ede:	4681                	li	a3,0
    80005ee0:	4601                	li	a2,0
    80005ee2:	4585                	li	a1,1
    80005ee4:	f7040513          	addi	a0,s0,-144
    80005ee8:	00000097          	auipc	ra,0x0
    80005eec:	800080e7          	jalr	-2048(ra) # 800056e8 <create>
    80005ef0:	cd11                	beqz	a0,80005f0c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ef2:	ffffe097          	auipc	ra,0xffffe
    80005ef6:	0ee080e7          	jalr	238(ra) # 80003fe0 <iunlockput>
  end_op();
    80005efa:	fffff097          	auipc	ra,0xfffff
    80005efe:	8c6080e7          	jalr	-1850(ra) # 800047c0 <end_op>
  return 0;
    80005f02:	4501                	li	a0,0
}
    80005f04:	60aa                	ld	ra,136(sp)
    80005f06:	640a                	ld	s0,128(sp)
    80005f08:	6149                	addi	sp,sp,144
    80005f0a:	8082                	ret
    end_op();
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	8b4080e7          	jalr	-1868(ra) # 800047c0 <end_op>
    return -1;
    80005f14:	557d                	li	a0,-1
    80005f16:	b7fd                	j	80005f04 <sys_mkdir+0x4c>

0000000080005f18 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f18:	7135                	addi	sp,sp,-160
    80005f1a:	ed06                	sd	ra,152(sp)
    80005f1c:	e922                	sd	s0,144(sp)
    80005f1e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f20:	fffff097          	auipc	ra,0xfffff
    80005f24:	820080e7          	jalr	-2016(ra) # 80004740 <begin_op>
  argint(1, &major);
    80005f28:	f6c40593          	addi	a1,s0,-148
    80005f2c:	4505                	li	a0,1
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	158080e7          	jalr	344(ra) # 80003086 <argint>
  argint(2, &minor);
    80005f36:	f6840593          	addi	a1,s0,-152
    80005f3a:	4509                	li	a0,2
    80005f3c:	ffffd097          	auipc	ra,0xffffd
    80005f40:	14a080e7          	jalr	330(ra) # 80003086 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f44:	08000613          	li	a2,128
    80005f48:	f7040593          	addi	a1,s0,-144
    80005f4c:	4501                	li	a0,0
    80005f4e:	ffffd097          	auipc	ra,0xffffd
    80005f52:	178080e7          	jalr	376(ra) # 800030c6 <argstr>
    80005f56:	02054b63          	bltz	a0,80005f8c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f5a:	f6841683          	lh	a3,-152(s0)
    80005f5e:	f6c41603          	lh	a2,-148(s0)
    80005f62:	458d                	li	a1,3
    80005f64:	f7040513          	addi	a0,s0,-144
    80005f68:	fffff097          	auipc	ra,0xfffff
    80005f6c:	780080e7          	jalr	1920(ra) # 800056e8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f70:	cd11                	beqz	a0,80005f8c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	06e080e7          	jalr	110(ra) # 80003fe0 <iunlockput>
  end_op();
    80005f7a:	fffff097          	auipc	ra,0xfffff
    80005f7e:	846080e7          	jalr	-1978(ra) # 800047c0 <end_op>
  return 0;
    80005f82:	4501                	li	a0,0
}
    80005f84:	60ea                	ld	ra,152(sp)
    80005f86:	644a                	ld	s0,144(sp)
    80005f88:	610d                	addi	sp,sp,160
    80005f8a:	8082                	ret
    end_op();
    80005f8c:	fffff097          	auipc	ra,0xfffff
    80005f90:	834080e7          	jalr	-1996(ra) # 800047c0 <end_op>
    return -1;
    80005f94:	557d                	li	a0,-1
    80005f96:	b7fd                	j	80005f84 <sys_mknod+0x6c>

0000000080005f98 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f98:	7135                	addi	sp,sp,-160
    80005f9a:	ed06                	sd	ra,152(sp)
    80005f9c:	e922                	sd	s0,144(sp)
    80005f9e:	e526                	sd	s1,136(sp)
    80005fa0:	e14a                	sd	s2,128(sp)
    80005fa2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005fa4:	ffffc097          	auipc	ra,0xffffc
    80005fa8:	bac080e7          	jalr	-1108(ra) # 80001b50 <myproc>
    80005fac:	892a                	mv	s2,a0
  
  begin_op();
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	792080e7          	jalr	1938(ra) # 80004740 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005fb6:	08000613          	li	a2,128
    80005fba:	f6040593          	addi	a1,s0,-160
    80005fbe:	4501                	li	a0,0
    80005fc0:	ffffd097          	auipc	ra,0xffffd
    80005fc4:	106080e7          	jalr	262(ra) # 800030c6 <argstr>
    80005fc8:	04054b63          	bltz	a0,8000601e <sys_chdir+0x86>
    80005fcc:	f6040513          	addi	a0,s0,-160
    80005fd0:	ffffe097          	auipc	ra,0xffffe
    80005fd4:	554080e7          	jalr	1364(ra) # 80004524 <namei>
    80005fd8:	84aa                	mv	s1,a0
    80005fda:	c131                	beqz	a0,8000601e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005fdc:	ffffe097          	auipc	ra,0xffffe
    80005fe0:	da2080e7          	jalr	-606(ra) # 80003d7e <ilock>
  if(ip->type != T_DIR){
    80005fe4:	04449703          	lh	a4,68(s1)
    80005fe8:	4785                	li	a5,1
    80005fea:	04f71063          	bne	a4,a5,8000602a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005fee:	8526                	mv	a0,s1
    80005ff0:	ffffe097          	auipc	ra,0xffffe
    80005ff4:	e50080e7          	jalr	-432(ra) # 80003e40 <iunlock>
  iput(p->cwd);
    80005ff8:	16093503          	ld	a0,352(s2)
    80005ffc:	ffffe097          	auipc	ra,0xffffe
    80006000:	f3c080e7          	jalr	-196(ra) # 80003f38 <iput>
  end_op();
    80006004:	ffffe097          	auipc	ra,0xffffe
    80006008:	7bc080e7          	jalr	1980(ra) # 800047c0 <end_op>
  p->cwd = ip;
    8000600c:	16993023          	sd	s1,352(s2)
  return 0;
    80006010:	4501                	li	a0,0
}
    80006012:	60ea                	ld	ra,152(sp)
    80006014:	644a                	ld	s0,144(sp)
    80006016:	64aa                	ld	s1,136(sp)
    80006018:	690a                	ld	s2,128(sp)
    8000601a:	610d                	addi	sp,sp,160
    8000601c:	8082                	ret
    end_op();
    8000601e:	ffffe097          	auipc	ra,0xffffe
    80006022:	7a2080e7          	jalr	1954(ra) # 800047c0 <end_op>
    return -1;
    80006026:	557d                	li	a0,-1
    80006028:	b7ed                	j	80006012 <sys_chdir+0x7a>
    iunlockput(ip);
    8000602a:	8526                	mv	a0,s1
    8000602c:	ffffe097          	auipc	ra,0xffffe
    80006030:	fb4080e7          	jalr	-76(ra) # 80003fe0 <iunlockput>
    end_op();
    80006034:	ffffe097          	auipc	ra,0xffffe
    80006038:	78c080e7          	jalr	1932(ra) # 800047c0 <end_op>
    return -1;
    8000603c:	557d                	li	a0,-1
    8000603e:	bfd1                	j	80006012 <sys_chdir+0x7a>

0000000080006040 <sys_exec>:

uint64
sys_exec(void)
{
    80006040:	7145                	addi	sp,sp,-464
    80006042:	e786                	sd	ra,456(sp)
    80006044:	e3a2                	sd	s0,448(sp)
    80006046:	ff26                	sd	s1,440(sp)
    80006048:	fb4a                	sd	s2,432(sp)
    8000604a:	f74e                	sd	s3,424(sp)
    8000604c:	f352                	sd	s4,416(sp)
    8000604e:	ef56                	sd	s5,408(sp)
    80006050:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006052:	e3840593          	addi	a1,s0,-456
    80006056:	4505                	li	a0,1
    80006058:	ffffd097          	auipc	ra,0xffffd
    8000605c:	04e080e7          	jalr	78(ra) # 800030a6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006060:	08000613          	li	a2,128
    80006064:	f4040593          	addi	a1,s0,-192
    80006068:	4501                	li	a0,0
    8000606a:	ffffd097          	auipc	ra,0xffffd
    8000606e:	05c080e7          	jalr	92(ra) # 800030c6 <argstr>
    80006072:	87aa                	mv	a5,a0
    return -1;
    80006074:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006076:	0c07c263          	bltz	a5,8000613a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000607a:	10000613          	li	a2,256
    8000607e:	4581                	li	a1,0
    80006080:	e4040513          	addi	a0,s0,-448
    80006084:	ffffb097          	auipc	ra,0xffffb
    80006088:	c4e080e7          	jalr	-946(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000608c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006090:	89a6                	mv	s3,s1
    80006092:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006094:	02000a13          	li	s4,32
    80006098:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000609c:	00391793          	slli	a5,s2,0x3
    800060a0:	e3040593          	addi	a1,s0,-464
    800060a4:	e3843503          	ld	a0,-456(s0)
    800060a8:	953e                	add	a0,a0,a5
    800060aa:	ffffd097          	auipc	ra,0xffffd
    800060ae:	f3e080e7          	jalr	-194(ra) # 80002fe8 <fetchaddr>
    800060b2:	02054a63          	bltz	a0,800060e6 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800060b6:	e3043783          	ld	a5,-464(s0)
    800060ba:	c3b9                	beqz	a5,80006100 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800060bc:	ffffb097          	auipc	ra,0xffffb
    800060c0:	a2a080e7          	jalr	-1494(ra) # 80000ae6 <kalloc>
    800060c4:	85aa                	mv	a1,a0
    800060c6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800060ca:	cd11                	beqz	a0,800060e6 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800060cc:	6605                	lui	a2,0x1
    800060ce:	e3043503          	ld	a0,-464(s0)
    800060d2:	ffffd097          	auipc	ra,0xffffd
    800060d6:	f68080e7          	jalr	-152(ra) # 8000303a <fetchstr>
    800060da:	00054663          	bltz	a0,800060e6 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800060de:	0905                	addi	s2,s2,1
    800060e0:	09a1                	addi	s3,s3,8
    800060e2:	fb491be3          	bne	s2,s4,80006098 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060e6:	10048913          	addi	s2,s1,256
    800060ea:	6088                	ld	a0,0(s1)
    800060ec:	c531                	beqz	a0,80006138 <sys_exec+0xf8>
    kfree(argv[i]);
    800060ee:	ffffb097          	auipc	ra,0xffffb
    800060f2:	8fc080e7          	jalr	-1796(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060f6:	04a1                	addi	s1,s1,8
    800060f8:	ff2499e3          	bne	s1,s2,800060ea <sys_exec+0xaa>
  return -1;
    800060fc:	557d                	li	a0,-1
    800060fe:	a835                	j	8000613a <sys_exec+0xfa>
      argv[i] = 0;
    80006100:	0a8e                	slli	s5,s5,0x3
    80006102:	fc040793          	addi	a5,s0,-64
    80006106:	9abe                	add	s5,s5,a5
    80006108:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000610c:	e4040593          	addi	a1,s0,-448
    80006110:	f4040513          	addi	a0,s0,-192
    80006114:	fffff097          	auipc	ra,0xfffff
    80006118:	172080e7          	jalr	370(ra) # 80005286 <exec>
    8000611c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000611e:	10048993          	addi	s3,s1,256
    80006122:	6088                	ld	a0,0(s1)
    80006124:	c901                	beqz	a0,80006134 <sys_exec+0xf4>
    kfree(argv[i]);
    80006126:	ffffb097          	auipc	ra,0xffffb
    8000612a:	8c4080e7          	jalr	-1852(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000612e:	04a1                	addi	s1,s1,8
    80006130:	ff3499e3          	bne	s1,s3,80006122 <sys_exec+0xe2>
  return ret;
    80006134:	854a                	mv	a0,s2
    80006136:	a011                	j	8000613a <sys_exec+0xfa>
  return -1;
    80006138:	557d                	li	a0,-1
}
    8000613a:	60be                	ld	ra,456(sp)
    8000613c:	641e                	ld	s0,448(sp)
    8000613e:	74fa                	ld	s1,440(sp)
    80006140:	795a                	ld	s2,432(sp)
    80006142:	79ba                	ld	s3,424(sp)
    80006144:	7a1a                	ld	s4,416(sp)
    80006146:	6afa                	ld	s5,408(sp)
    80006148:	6179                	addi	sp,sp,464
    8000614a:	8082                	ret

000000008000614c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000614c:	7139                	addi	sp,sp,-64
    8000614e:	fc06                	sd	ra,56(sp)
    80006150:	f822                	sd	s0,48(sp)
    80006152:	f426                	sd	s1,40(sp)
    80006154:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006156:	ffffc097          	auipc	ra,0xffffc
    8000615a:	9fa080e7          	jalr	-1542(ra) # 80001b50 <myproc>
    8000615e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006160:	fd840593          	addi	a1,s0,-40
    80006164:	4501                	li	a0,0
    80006166:	ffffd097          	auipc	ra,0xffffd
    8000616a:	f40080e7          	jalr	-192(ra) # 800030a6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000616e:	fc840593          	addi	a1,s0,-56
    80006172:	fd040513          	addi	a0,s0,-48
    80006176:	fffff097          	auipc	ra,0xfffff
    8000617a:	dc6080e7          	jalr	-570(ra) # 80004f3c <pipealloc>
    return -1;
    8000617e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006180:	0c054463          	bltz	a0,80006248 <sys_pipe+0xfc>
  fd0 = -1;
    80006184:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006188:	fd043503          	ld	a0,-48(s0)
    8000618c:	fffff097          	auipc	ra,0xfffff
    80006190:	51a080e7          	jalr	1306(ra) # 800056a6 <fdalloc>
    80006194:	fca42223          	sw	a0,-60(s0)
    80006198:	08054b63          	bltz	a0,8000622e <sys_pipe+0xe2>
    8000619c:	fc843503          	ld	a0,-56(s0)
    800061a0:	fffff097          	auipc	ra,0xfffff
    800061a4:	506080e7          	jalr	1286(ra) # 800056a6 <fdalloc>
    800061a8:	fca42023          	sw	a0,-64(s0)
    800061ac:	06054863          	bltz	a0,8000621c <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061b0:	4691                	li	a3,4
    800061b2:	fc440613          	addi	a2,s0,-60
    800061b6:	fd843583          	ld	a1,-40(s0)
    800061ba:	70a8                	ld	a0,96(s1)
    800061bc:	ffffb097          	auipc	ra,0xffffb
    800061c0:	4b4080e7          	jalr	1204(ra) # 80001670 <copyout>
    800061c4:	02054063          	bltz	a0,800061e4 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800061c8:	4691                	li	a3,4
    800061ca:	fc040613          	addi	a2,s0,-64
    800061ce:	fd843583          	ld	a1,-40(s0)
    800061d2:	0591                	addi	a1,a1,4
    800061d4:	70a8                	ld	a0,96(s1)
    800061d6:	ffffb097          	auipc	ra,0xffffb
    800061da:	49a080e7          	jalr	1178(ra) # 80001670 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800061de:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061e0:	06055463          	bgez	a0,80006248 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800061e4:	fc442783          	lw	a5,-60(s0)
    800061e8:	07f1                	addi	a5,a5,28
    800061ea:	078e                	slli	a5,a5,0x3
    800061ec:	97a6                	add	a5,a5,s1
    800061ee:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800061f2:	fc042503          	lw	a0,-64(s0)
    800061f6:	0571                	addi	a0,a0,28
    800061f8:	050e                	slli	a0,a0,0x3
    800061fa:	94aa                	add	s1,s1,a0
    800061fc:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006200:	fd043503          	ld	a0,-48(s0)
    80006204:	fffff097          	auipc	ra,0xfffff
    80006208:	a08080e7          	jalr	-1528(ra) # 80004c0c <fileclose>
    fileclose(wf);
    8000620c:	fc843503          	ld	a0,-56(s0)
    80006210:	fffff097          	auipc	ra,0xfffff
    80006214:	9fc080e7          	jalr	-1540(ra) # 80004c0c <fileclose>
    return -1;
    80006218:	57fd                	li	a5,-1
    8000621a:	a03d                	j	80006248 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000621c:	fc442783          	lw	a5,-60(s0)
    80006220:	0007c763          	bltz	a5,8000622e <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006224:	07f1                	addi	a5,a5,28
    80006226:	078e                	slli	a5,a5,0x3
    80006228:	94be                	add	s1,s1,a5
    8000622a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000622e:	fd043503          	ld	a0,-48(s0)
    80006232:	fffff097          	auipc	ra,0xfffff
    80006236:	9da080e7          	jalr	-1574(ra) # 80004c0c <fileclose>
    fileclose(wf);
    8000623a:	fc843503          	ld	a0,-56(s0)
    8000623e:	fffff097          	auipc	ra,0xfffff
    80006242:	9ce080e7          	jalr	-1586(ra) # 80004c0c <fileclose>
    return -1;
    80006246:	57fd                	li	a5,-1
}
    80006248:	853e                	mv	a0,a5
    8000624a:	70e2                	ld	ra,56(sp)
    8000624c:	7442                	ld	s0,48(sp)
    8000624e:	74a2                	ld	s1,40(sp)
    80006250:	6121                	addi	sp,sp,64
    80006252:	8082                	ret
	...

0000000080006260 <kernelvec>:
    80006260:	7111                	addi	sp,sp,-256
    80006262:	e006                	sd	ra,0(sp)
    80006264:	e40a                	sd	sp,8(sp)
    80006266:	e80e                	sd	gp,16(sp)
    80006268:	ec12                	sd	tp,24(sp)
    8000626a:	f016                	sd	t0,32(sp)
    8000626c:	f41a                	sd	t1,40(sp)
    8000626e:	f81e                	sd	t2,48(sp)
    80006270:	fc22                	sd	s0,56(sp)
    80006272:	e0a6                	sd	s1,64(sp)
    80006274:	e4aa                	sd	a0,72(sp)
    80006276:	e8ae                	sd	a1,80(sp)
    80006278:	ecb2                	sd	a2,88(sp)
    8000627a:	f0b6                	sd	a3,96(sp)
    8000627c:	f4ba                	sd	a4,104(sp)
    8000627e:	f8be                	sd	a5,112(sp)
    80006280:	fcc2                	sd	a6,120(sp)
    80006282:	e146                	sd	a7,128(sp)
    80006284:	e54a                	sd	s2,136(sp)
    80006286:	e94e                	sd	s3,144(sp)
    80006288:	ed52                	sd	s4,152(sp)
    8000628a:	f156                	sd	s5,160(sp)
    8000628c:	f55a                	sd	s6,168(sp)
    8000628e:	f95e                	sd	s7,176(sp)
    80006290:	fd62                	sd	s8,184(sp)
    80006292:	e1e6                	sd	s9,192(sp)
    80006294:	e5ea                	sd	s10,200(sp)
    80006296:	e9ee                	sd	s11,208(sp)
    80006298:	edf2                	sd	t3,216(sp)
    8000629a:	f1f6                	sd	t4,224(sp)
    8000629c:	f5fa                	sd	t5,232(sp)
    8000629e:	f9fe                	sd	t6,240(sp)
    800062a0:	bbbfc0ef          	jal	ra,80002e5a <kerneltrap>
    800062a4:	6082                	ld	ra,0(sp)
    800062a6:	6122                	ld	sp,8(sp)
    800062a8:	61c2                	ld	gp,16(sp)
    800062aa:	7282                	ld	t0,32(sp)
    800062ac:	7322                	ld	t1,40(sp)
    800062ae:	73c2                	ld	t2,48(sp)
    800062b0:	7462                	ld	s0,56(sp)
    800062b2:	6486                	ld	s1,64(sp)
    800062b4:	6526                	ld	a0,72(sp)
    800062b6:	65c6                	ld	a1,80(sp)
    800062b8:	6666                	ld	a2,88(sp)
    800062ba:	7686                	ld	a3,96(sp)
    800062bc:	7726                	ld	a4,104(sp)
    800062be:	77c6                	ld	a5,112(sp)
    800062c0:	7866                	ld	a6,120(sp)
    800062c2:	688a                	ld	a7,128(sp)
    800062c4:	692a                	ld	s2,136(sp)
    800062c6:	69ca                	ld	s3,144(sp)
    800062c8:	6a6a                	ld	s4,152(sp)
    800062ca:	7a8a                	ld	s5,160(sp)
    800062cc:	7b2a                	ld	s6,168(sp)
    800062ce:	7bca                	ld	s7,176(sp)
    800062d0:	7c6a                	ld	s8,184(sp)
    800062d2:	6c8e                	ld	s9,192(sp)
    800062d4:	6d2e                	ld	s10,200(sp)
    800062d6:	6dce                	ld	s11,208(sp)
    800062d8:	6e6e                	ld	t3,216(sp)
    800062da:	7e8e                	ld	t4,224(sp)
    800062dc:	7f2e                	ld	t5,232(sp)
    800062de:	7fce                	ld	t6,240(sp)
    800062e0:	6111                	addi	sp,sp,256
    800062e2:	10200073          	sret
    800062e6:	00000013          	nop
    800062ea:	00000013          	nop
    800062ee:	0001                	nop

00000000800062f0 <timervec>:
    800062f0:	34051573          	csrrw	a0,mscratch,a0
    800062f4:	e10c                	sd	a1,0(a0)
    800062f6:	e510                	sd	a2,8(a0)
    800062f8:	e914                	sd	a3,16(a0)
    800062fa:	6d0c                	ld	a1,24(a0)
    800062fc:	7110                	ld	a2,32(a0)
    800062fe:	6194                	ld	a3,0(a1)
    80006300:	96b2                	add	a3,a3,a2
    80006302:	e194                	sd	a3,0(a1)
    80006304:	4589                	li	a1,2
    80006306:	14459073          	csrw	sip,a1
    8000630a:	6914                	ld	a3,16(a0)
    8000630c:	6510                	ld	a2,8(a0)
    8000630e:	610c                	ld	a1,0(a0)
    80006310:	34051573          	csrrw	a0,mscratch,a0
    80006314:	30200073          	mret
	...

000000008000631a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000631a:	1141                	addi	sp,sp,-16
    8000631c:	e422                	sd	s0,8(sp)
    8000631e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006320:	0c0007b7          	lui	a5,0xc000
    80006324:	4705                	li	a4,1
    80006326:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006328:	c3d8                	sw	a4,4(a5)
}
    8000632a:	6422                	ld	s0,8(sp)
    8000632c:	0141                	addi	sp,sp,16
    8000632e:	8082                	ret

0000000080006330 <plicinithart>:

void
plicinithart(void)
{
    80006330:	1141                	addi	sp,sp,-16
    80006332:	e406                	sd	ra,8(sp)
    80006334:	e022                	sd	s0,0(sp)
    80006336:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006338:	ffffb097          	auipc	ra,0xffffb
    8000633c:	7ec080e7          	jalr	2028(ra) # 80001b24 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006340:	0085171b          	slliw	a4,a0,0x8
    80006344:	0c0027b7          	lui	a5,0xc002
    80006348:	97ba                	add	a5,a5,a4
    8000634a:	40200713          	li	a4,1026
    8000634e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006352:	00d5151b          	slliw	a0,a0,0xd
    80006356:	0c2017b7          	lui	a5,0xc201
    8000635a:	953e                	add	a0,a0,a5
    8000635c:	00052023          	sw	zero,0(a0)
}
    80006360:	60a2                	ld	ra,8(sp)
    80006362:	6402                	ld	s0,0(sp)
    80006364:	0141                	addi	sp,sp,16
    80006366:	8082                	ret

0000000080006368 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006368:	1141                	addi	sp,sp,-16
    8000636a:	e406                	sd	ra,8(sp)
    8000636c:	e022                	sd	s0,0(sp)
    8000636e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006370:	ffffb097          	auipc	ra,0xffffb
    80006374:	7b4080e7          	jalr	1972(ra) # 80001b24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006378:	00d5179b          	slliw	a5,a0,0xd
    8000637c:	0c201537          	lui	a0,0xc201
    80006380:	953e                	add	a0,a0,a5
  return irq;
}
    80006382:	4148                	lw	a0,4(a0)
    80006384:	60a2                	ld	ra,8(sp)
    80006386:	6402                	ld	s0,0(sp)
    80006388:	0141                	addi	sp,sp,16
    8000638a:	8082                	ret

000000008000638c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000638c:	1101                	addi	sp,sp,-32
    8000638e:	ec06                	sd	ra,24(sp)
    80006390:	e822                	sd	s0,16(sp)
    80006392:	e426                	sd	s1,8(sp)
    80006394:	1000                	addi	s0,sp,32
    80006396:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006398:	ffffb097          	auipc	ra,0xffffb
    8000639c:	78c080e7          	jalr	1932(ra) # 80001b24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800063a0:	00d5151b          	slliw	a0,a0,0xd
    800063a4:	0c2017b7          	lui	a5,0xc201
    800063a8:	97aa                	add	a5,a5,a0
    800063aa:	c3c4                	sw	s1,4(a5)
}
    800063ac:	60e2                	ld	ra,24(sp)
    800063ae:	6442                	ld	s0,16(sp)
    800063b0:	64a2                	ld	s1,8(sp)
    800063b2:	6105                	addi	sp,sp,32
    800063b4:	8082                	ret

00000000800063b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800063b6:	1141                	addi	sp,sp,-16
    800063b8:	e406                	sd	ra,8(sp)
    800063ba:	e022                	sd	s0,0(sp)
    800063bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800063be:	479d                	li	a5,7
    800063c0:	04a7cc63          	blt	a5,a0,80006418 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800063c4:	0001d797          	auipc	a5,0x1d
    800063c8:	e9c78793          	addi	a5,a5,-356 # 80023260 <disk>
    800063cc:	97aa                	add	a5,a5,a0
    800063ce:	0187c783          	lbu	a5,24(a5)
    800063d2:	ebb9                	bnez	a5,80006428 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800063d4:	00451613          	slli	a2,a0,0x4
    800063d8:	0001d797          	auipc	a5,0x1d
    800063dc:	e8878793          	addi	a5,a5,-376 # 80023260 <disk>
    800063e0:	6394                	ld	a3,0(a5)
    800063e2:	96b2                	add	a3,a3,a2
    800063e4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800063e8:	6398                	ld	a4,0(a5)
    800063ea:	9732                	add	a4,a4,a2
    800063ec:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800063f0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800063f4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800063f8:	953e                	add	a0,a0,a5
    800063fa:	4785                	li	a5,1
    800063fc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006400:	0001d517          	auipc	a0,0x1d
    80006404:	e7850513          	addi	a0,a0,-392 # 80023278 <disk+0x18>
    80006408:	ffffc097          	auipc	ra,0xffffc
    8000640c:	f70080e7          	jalr	-144(ra) # 80002378 <wakeup>
}
    80006410:	60a2                	ld	ra,8(sp)
    80006412:	6402                	ld	s0,0(sp)
    80006414:	0141                	addi	sp,sp,16
    80006416:	8082                	ret
    panic("free_desc 1");
    80006418:	00002517          	auipc	a0,0x2
    8000641c:	35850513          	addi	a0,a0,856 # 80008770 <syscalls+0x310>
    80006420:	ffffa097          	auipc	ra,0xffffa
    80006424:	11e080e7          	jalr	286(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006428:	00002517          	auipc	a0,0x2
    8000642c:	35850513          	addi	a0,a0,856 # 80008780 <syscalls+0x320>
    80006430:	ffffa097          	auipc	ra,0xffffa
    80006434:	10e080e7          	jalr	270(ra) # 8000053e <panic>

0000000080006438 <virtio_disk_init>:
{
    80006438:	1101                	addi	sp,sp,-32
    8000643a:	ec06                	sd	ra,24(sp)
    8000643c:	e822                	sd	s0,16(sp)
    8000643e:	e426                	sd	s1,8(sp)
    80006440:	e04a                	sd	s2,0(sp)
    80006442:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006444:	00002597          	auipc	a1,0x2
    80006448:	34c58593          	addi	a1,a1,844 # 80008790 <syscalls+0x330>
    8000644c:	0001d517          	auipc	a0,0x1d
    80006450:	f3c50513          	addi	a0,a0,-196 # 80023388 <disk+0x128>
    80006454:	ffffa097          	auipc	ra,0xffffa
    80006458:	6f2080e7          	jalr	1778(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000645c:	100017b7          	lui	a5,0x10001
    80006460:	4398                	lw	a4,0(a5)
    80006462:	2701                	sext.w	a4,a4
    80006464:	747277b7          	lui	a5,0x74727
    80006468:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000646c:	14f71c63          	bne	a4,a5,800065c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006470:	100017b7          	lui	a5,0x10001
    80006474:	43dc                	lw	a5,4(a5)
    80006476:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006478:	4709                	li	a4,2
    8000647a:	14e79563          	bne	a5,a4,800065c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000647e:	100017b7          	lui	a5,0x10001
    80006482:	479c                	lw	a5,8(a5)
    80006484:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006486:	12e79f63          	bne	a5,a4,800065c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000648a:	100017b7          	lui	a5,0x10001
    8000648e:	47d8                	lw	a4,12(a5)
    80006490:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006492:	554d47b7          	lui	a5,0x554d4
    80006496:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000649a:	12f71563          	bne	a4,a5,800065c4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000649e:	100017b7          	lui	a5,0x10001
    800064a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064a6:	4705                	li	a4,1
    800064a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064aa:	470d                	li	a4,3
    800064ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800064ae:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800064b0:	c7ffe737          	lui	a4,0xc7ffe
    800064b4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb3bf>
    800064b8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800064ba:	2701                	sext.w	a4,a4
    800064bc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064be:	472d                	li	a4,11
    800064c0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800064c2:	5bbc                	lw	a5,112(a5)
    800064c4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800064c8:	8ba1                	andi	a5,a5,8
    800064ca:	10078563          	beqz	a5,800065d4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800064ce:	100017b7          	lui	a5,0x10001
    800064d2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800064d6:	43fc                	lw	a5,68(a5)
    800064d8:	2781                	sext.w	a5,a5
    800064da:	10079563          	bnez	a5,800065e4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800064de:	100017b7          	lui	a5,0x10001
    800064e2:	5bdc                	lw	a5,52(a5)
    800064e4:	2781                	sext.w	a5,a5
  if(max == 0)
    800064e6:	10078763          	beqz	a5,800065f4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800064ea:	471d                	li	a4,7
    800064ec:	10f77c63          	bgeu	a4,a5,80006604 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800064f0:	ffffa097          	auipc	ra,0xffffa
    800064f4:	5f6080e7          	jalr	1526(ra) # 80000ae6 <kalloc>
    800064f8:	0001d497          	auipc	s1,0x1d
    800064fc:	d6848493          	addi	s1,s1,-664 # 80023260 <disk>
    80006500:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006502:	ffffa097          	auipc	ra,0xffffa
    80006506:	5e4080e7          	jalr	1508(ra) # 80000ae6 <kalloc>
    8000650a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000650c:	ffffa097          	auipc	ra,0xffffa
    80006510:	5da080e7          	jalr	1498(ra) # 80000ae6 <kalloc>
    80006514:	87aa                	mv	a5,a0
    80006516:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006518:	6088                	ld	a0,0(s1)
    8000651a:	cd6d                	beqz	a0,80006614 <virtio_disk_init+0x1dc>
    8000651c:	0001d717          	auipc	a4,0x1d
    80006520:	d4c73703          	ld	a4,-692(a4) # 80023268 <disk+0x8>
    80006524:	cb65                	beqz	a4,80006614 <virtio_disk_init+0x1dc>
    80006526:	c7fd                	beqz	a5,80006614 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006528:	6605                	lui	a2,0x1
    8000652a:	4581                	li	a1,0
    8000652c:	ffffa097          	auipc	ra,0xffffa
    80006530:	7a6080e7          	jalr	1958(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006534:	0001d497          	auipc	s1,0x1d
    80006538:	d2c48493          	addi	s1,s1,-724 # 80023260 <disk>
    8000653c:	6605                	lui	a2,0x1
    8000653e:	4581                	li	a1,0
    80006540:	6488                	ld	a0,8(s1)
    80006542:	ffffa097          	auipc	ra,0xffffa
    80006546:	790080e7          	jalr	1936(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000654a:	6605                	lui	a2,0x1
    8000654c:	4581                	li	a1,0
    8000654e:	6888                	ld	a0,16(s1)
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	782080e7          	jalr	1922(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006558:	100017b7          	lui	a5,0x10001
    8000655c:	4721                	li	a4,8
    8000655e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006560:	4098                	lw	a4,0(s1)
    80006562:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006566:	40d8                	lw	a4,4(s1)
    80006568:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000656c:	6498                	ld	a4,8(s1)
    8000656e:	0007069b          	sext.w	a3,a4
    80006572:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006576:	9701                	srai	a4,a4,0x20
    80006578:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000657c:	6898                	ld	a4,16(s1)
    8000657e:	0007069b          	sext.w	a3,a4
    80006582:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006586:	9701                	srai	a4,a4,0x20
    80006588:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000658c:	4705                	li	a4,1
    8000658e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006590:	00e48c23          	sb	a4,24(s1)
    80006594:	00e48ca3          	sb	a4,25(s1)
    80006598:	00e48d23          	sb	a4,26(s1)
    8000659c:	00e48da3          	sb	a4,27(s1)
    800065a0:	00e48e23          	sb	a4,28(s1)
    800065a4:	00e48ea3          	sb	a4,29(s1)
    800065a8:	00e48f23          	sb	a4,30(s1)
    800065ac:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800065b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800065b4:	0727a823          	sw	s2,112(a5)
}
    800065b8:	60e2                	ld	ra,24(sp)
    800065ba:	6442                	ld	s0,16(sp)
    800065bc:	64a2                	ld	s1,8(sp)
    800065be:	6902                	ld	s2,0(sp)
    800065c0:	6105                	addi	sp,sp,32
    800065c2:	8082                	ret
    panic("could not find virtio disk");
    800065c4:	00002517          	auipc	a0,0x2
    800065c8:	1dc50513          	addi	a0,a0,476 # 800087a0 <syscalls+0x340>
    800065cc:	ffffa097          	auipc	ra,0xffffa
    800065d0:	f72080e7          	jalr	-142(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800065d4:	00002517          	auipc	a0,0x2
    800065d8:	1ec50513          	addi	a0,a0,492 # 800087c0 <syscalls+0x360>
    800065dc:	ffffa097          	auipc	ra,0xffffa
    800065e0:	f62080e7          	jalr	-158(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800065e4:	00002517          	auipc	a0,0x2
    800065e8:	1fc50513          	addi	a0,a0,508 # 800087e0 <syscalls+0x380>
    800065ec:	ffffa097          	auipc	ra,0xffffa
    800065f0:	f52080e7          	jalr	-174(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800065f4:	00002517          	auipc	a0,0x2
    800065f8:	20c50513          	addi	a0,a0,524 # 80008800 <syscalls+0x3a0>
    800065fc:	ffffa097          	auipc	ra,0xffffa
    80006600:	f42080e7          	jalr	-190(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006604:	00002517          	auipc	a0,0x2
    80006608:	21c50513          	addi	a0,a0,540 # 80008820 <syscalls+0x3c0>
    8000660c:	ffffa097          	auipc	ra,0xffffa
    80006610:	f32080e7          	jalr	-206(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006614:	00002517          	auipc	a0,0x2
    80006618:	22c50513          	addi	a0,a0,556 # 80008840 <syscalls+0x3e0>
    8000661c:	ffffa097          	auipc	ra,0xffffa
    80006620:	f22080e7          	jalr	-222(ra) # 8000053e <panic>

0000000080006624 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006624:	7119                	addi	sp,sp,-128
    80006626:	fc86                	sd	ra,120(sp)
    80006628:	f8a2                	sd	s0,112(sp)
    8000662a:	f4a6                	sd	s1,104(sp)
    8000662c:	f0ca                	sd	s2,96(sp)
    8000662e:	ecce                	sd	s3,88(sp)
    80006630:	e8d2                	sd	s4,80(sp)
    80006632:	e4d6                	sd	s5,72(sp)
    80006634:	e0da                	sd	s6,64(sp)
    80006636:	fc5e                	sd	s7,56(sp)
    80006638:	f862                	sd	s8,48(sp)
    8000663a:	f466                	sd	s9,40(sp)
    8000663c:	f06a                	sd	s10,32(sp)
    8000663e:	ec6e                	sd	s11,24(sp)
    80006640:	0100                	addi	s0,sp,128
    80006642:	8aaa                	mv	s5,a0
    80006644:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006646:	00c52d03          	lw	s10,12(a0)
    8000664a:	001d1d1b          	slliw	s10,s10,0x1
    8000664e:	1d02                	slli	s10,s10,0x20
    80006650:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006654:	0001d517          	auipc	a0,0x1d
    80006658:	d3450513          	addi	a0,a0,-716 # 80023388 <disk+0x128>
    8000665c:	ffffa097          	auipc	ra,0xffffa
    80006660:	57a080e7          	jalr	1402(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006664:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006666:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006668:	0001db97          	auipc	s7,0x1d
    8000666c:	bf8b8b93          	addi	s7,s7,-1032 # 80023260 <disk>
  for(int i = 0; i < 3; i++){
    80006670:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006672:	0001dc97          	auipc	s9,0x1d
    80006676:	d16c8c93          	addi	s9,s9,-746 # 80023388 <disk+0x128>
    8000667a:	a08d                	j	800066dc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000667c:	00fb8733          	add	a4,s7,a5
    80006680:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006684:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006686:	0207c563          	bltz	a5,800066b0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000668a:	2905                	addiw	s2,s2,1
    8000668c:	0611                	addi	a2,a2,4
    8000668e:	05690c63          	beq	s2,s6,800066e6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006692:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006694:	0001d717          	auipc	a4,0x1d
    80006698:	bcc70713          	addi	a4,a4,-1076 # 80023260 <disk>
    8000669c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000669e:	01874683          	lbu	a3,24(a4)
    800066a2:	fee9                	bnez	a3,8000667c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800066a4:	2785                	addiw	a5,a5,1
    800066a6:	0705                	addi	a4,a4,1
    800066a8:	fe979be3          	bne	a5,s1,8000669e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800066ac:	57fd                	li	a5,-1
    800066ae:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800066b0:	01205d63          	blez	s2,800066ca <virtio_disk_rw+0xa6>
    800066b4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800066b6:	000a2503          	lw	a0,0(s4)
    800066ba:	00000097          	auipc	ra,0x0
    800066be:	cfc080e7          	jalr	-772(ra) # 800063b6 <free_desc>
      for(int j = 0; j < i; j++)
    800066c2:	2d85                	addiw	s11,s11,1
    800066c4:	0a11                	addi	s4,s4,4
    800066c6:	ffb918e3          	bne	s2,s11,800066b6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800066ca:	85e6                	mv	a1,s9
    800066cc:	0001d517          	auipc	a0,0x1d
    800066d0:	bac50513          	addi	a0,a0,-1108 # 80023278 <disk+0x18>
    800066d4:	ffffc097          	auipc	ra,0xffffc
    800066d8:	c40080e7          	jalr	-960(ra) # 80002314 <sleep>
  for(int i = 0; i < 3; i++){
    800066dc:	f8040a13          	addi	s4,s0,-128
{
    800066e0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800066e2:	894e                	mv	s2,s3
    800066e4:	b77d                	j	80006692 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066e6:	f8042583          	lw	a1,-128(s0)
    800066ea:	00a58793          	addi	a5,a1,10
    800066ee:	0792                	slli	a5,a5,0x4

  if(write)
    800066f0:	0001d617          	auipc	a2,0x1d
    800066f4:	b7060613          	addi	a2,a2,-1168 # 80023260 <disk>
    800066f8:	00f60733          	add	a4,a2,a5
    800066fc:	018036b3          	snez	a3,s8
    80006700:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006702:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006706:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000670a:	f6078693          	addi	a3,a5,-160
    8000670e:	6218                	ld	a4,0(a2)
    80006710:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006712:	00878513          	addi	a0,a5,8
    80006716:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006718:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000671a:	6208                	ld	a0,0(a2)
    8000671c:	96aa                	add	a3,a3,a0
    8000671e:	4741                	li	a4,16
    80006720:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006722:	4705                	li	a4,1
    80006724:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006728:	f8442703          	lw	a4,-124(s0)
    8000672c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006730:	0712                	slli	a4,a4,0x4
    80006732:	953a                	add	a0,a0,a4
    80006734:	058a8693          	addi	a3,s5,88
    80006738:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000673a:	6208                	ld	a0,0(a2)
    8000673c:	972a                	add	a4,a4,a0
    8000673e:	40000693          	li	a3,1024
    80006742:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006744:	001c3c13          	seqz	s8,s8
    80006748:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000674a:	001c6c13          	ori	s8,s8,1
    8000674e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006752:	f8842603          	lw	a2,-120(s0)
    80006756:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000675a:	0001d697          	auipc	a3,0x1d
    8000675e:	b0668693          	addi	a3,a3,-1274 # 80023260 <disk>
    80006762:	00258713          	addi	a4,a1,2
    80006766:	0712                	slli	a4,a4,0x4
    80006768:	9736                	add	a4,a4,a3
    8000676a:	587d                	li	a6,-1
    8000676c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006770:	0612                	slli	a2,a2,0x4
    80006772:	9532                	add	a0,a0,a2
    80006774:	f9078793          	addi	a5,a5,-112
    80006778:	97b6                	add	a5,a5,a3
    8000677a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000677c:	629c                	ld	a5,0(a3)
    8000677e:	97b2                	add	a5,a5,a2
    80006780:	4605                	li	a2,1
    80006782:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006784:	4509                	li	a0,2
    80006786:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000678a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000678e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006792:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006796:	6698                	ld	a4,8(a3)
    80006798:	00275783          	lhu	a5,2(a4)
    8000679c:	8b9d                	andi	a5,a5,7
    8000679e:	0786                	slli	a5,a5,0x1
    800067a0:	97ba                	add	a5,a5,a4
    800067a2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800067a6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800067aa:	6698                	ld	a4,8(a3)
    800067ac:	00275783          	lhu	a5,2(a4)
    800067b0:	2785                	addiw	a5,a5,1
    800067b2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800067b6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800067ba:	100017b7          	lui	a5,0x10001
    800067be:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800067c2:	004aa783          	lw	a5,4(s5)
    800067c6:	02c79163          	bne	a5,a2,800067e8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800067ca:	0001d917          	auipc	s2,0x1d
    800067ce:	bbe90913          	addi	s2,s2,-1090 # 80023388 <disk+0x128>
  while(b->disk == 1) {
    800067d2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800067d4:	85ca                	mv	a1,s2
    800067d6:	8556                	mv	a0,s5
    800067d8:	ffffc097          	auipc	ra,0xffffc
    800067dc:	b3c080e7          	jalr	-1220(ra) # 80002314 <sleep>
  while(b->disk == 1) {
    800067e0:	004aa783          	lw	a5,4(s5)
    800067e4:	fe9788e3          	beq	a5,s1,800067d4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800067e8:	f8042903          	lw	s2,-128(s0)
    800067ec:	00290793          	addi	a5,s2,2
    800067f0:	00479713          	slli	a4,a5,0x4
    800067f4:	0001d797          	auipc	a5,0x1d
    800067f8:	a6c78793          	addi	a5,a5,-1428 # 80023260 <disk>
    800067fc:	97ba                	add	a5,a5,a4
    800067fe:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006802:	0001d997          	auipc	s3,0x1d
    80006806:	a5e98993          	addi	s3,s3,-1442 # 80023260 <disk>
    8000680a:	00491713          	slli	a4,s2,0x4
    8000680e:	0009b783          	ld	a5,0(s3)
    80006812:	97ba                	add	a5,a5,a4
    80006814:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006818:	854a                	mv	a0,s2
    8000681a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000681e:	00000097          	auipc	ra,0x0
    80006822:	b98080e7          	jalr	-1128(ra) # 800063b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006826:	8885                	andi	s1,s1,1
    80006828:	f0ed                	bnez	s1,8000680a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000682a:	0001d517          	auipc	a0,0x1d
    8000682e:	b5e50513          	addi	a0,a0,-1186 # 80023388 <disk+0x128>
    80006832:	ffffa097          	auipc	ra,0xffffa
    80006836:	458080e7          	jalr	1112(ra) # 80000c8a <release>
}
    8000683a:	70e6                	ld	ra,120(sp)
    8000683c:	7446                	ld	s0,112(sp)
    8000683e:	74a6                	ld	s1,104(sp)
    80006840:	7906                	ld	s2,96(sp)
    80006842:	69e6                	ld	s3,88(sp)
    80006844:	6a46                	ld	s4,80(sp)
    80006846:	6aa6                	ld	s5,72(sp)
    80006848:	6b06                	ld	s6,64(sp)
    8000684a:	7be2                	ld	s7,56(sp)
    8000684c:	7c42                	ld	s8,48(sp)
    8000684e:	7ca2                	ld	s9,40(sp)
    80006850:	7d02                	ld	s10,32(sp)
    80006852:	6de2                	ld	s11,24(sp)
    80006854:	6109                	addi	sp,sp,128
    80006856:	8082                	ret

0000000080006858 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006858:	1101                	addi	sp,sp,-32
    8000685a:	ec06                	sd	ra,24(sp)
    8000685c:	e822                	sd	s0,16(sp)
    8000685e:	e426                	sd	s1,8(sp)
    80006860:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006862:	0001d497          	auipc	s1,0x1d
    80006866:	9fe48493          	addi	s1,s1,-1538 # 80023260 <disk>
    8000686a:	0001d517          	auipc	a0,0x1d
    8000686e:	b1e50513          	addi	a0,a0,-1250 # 80023388 <disk+0x128>
    80006872:	ffffa097          	auipc	ra,0xffffa
    80006876:	364080e7          	jalr	868(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000687a:	10001737          	lui	a4,0x10001
    8000687e:	533c                	lw	a5,96(a4)
    80006880:	8b8d                	andi	a5,a5,3
    80006882:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006884:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006888:	689c                	ld	a5,16(s1)
    8000688a:	0204d703          	lhu	a4,32(s1)
    8000688e:	0027d783          	lhu	a5,2(a5)
    80006892:	04f70863          	beq	a4,a5,800068e2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006896:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000689a:	6898                	ld	a4,16(s1)
    8000689c:	0204d783          	lhu	a5,32(s1)
    800068a0:	8b9d                	andi	a5,a5,7
    800068a2:	078e                	slli	a5,a5,0x3
    800068a4:	97ba                	add	a5,a5,a4
    800068a6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068a8:	00278713          	addi	a4,a5,2
    800068ac:	0712                	slli	a4,a4,0x4
    800068ae:	9726                	add	a4,a4,s1
    800068b0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800068b4:	e721                	bnez	a4,800068fc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800068b6:	0789                	addi	a5,a5,2
    800068b8:	0792                	slli	a5,a5,0x4
    800068ba:	97a6                	add	a5,a5,s1
    800068bc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800068be:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800068c2:	ffffc097          	auipc	ra,0xffffc
    800068c6:	ab6080e7          	jalr	-1354(ra) # 80002378 <wakeup>

    disk.used_idx += 1;
    800068ca:	0204d783          	lhu	a5,32(s1)
    800068ce:	2785                	addiw	a5,a5,1
    800068d0:	17c2                	slli	a5,a5,0x30
    800068d2:	93c1                	srli	a5,a5,0x30
    800068d4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800068d8:	6898                	ld	a4,16(s1)
    800068da:	00275703          	lhu	a4,2(a4)
    800068de:	faf71ce3          	bne	a4,a5,80006896 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800068e2:	0001d517          	auipc	a0,0x1d
    800068e6:	aa650513          	addi	a0,a0,-1370 # 80023388 <disk+0x128>
    800068ea:	ffffa097          	auipc	ra,0xffffa
    800068ee:	3a0080e7          	jalr	928(ra) # 80000c8a <release>
}
    800068f2:	60e2                	ld	ra,24(sp)
    800068f4:	6442                	ld	s0,16(sp)
    800068f6:	64a2                	ld	s1,8(sp)
    800068f8:	6105                	addi	sp,sp,32
    800068fa:	8082                	ret
      panic("virtio_disk_intr status");
    800068fc:	00002517          	auipc	a0,0x2
    80006900:	f5c50513          	addi	a0,a0,-164 # 80008858 <syscalls+0x3f8>
    80006904:	ffffa097          	auipc	ra,0xffffa
    80006908:	c3a080e7          	jalr	-966(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
