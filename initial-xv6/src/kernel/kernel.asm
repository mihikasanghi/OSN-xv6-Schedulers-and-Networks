
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a4010113          	addi	sp,sp,-1472 # 80008a40 <stack0>
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
    80000056:	8ae70713          	addi	a4,a4,-1874 # 80008900 <timer_scratch>
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
    80000068:	0bc78793          	addi	a5,a5,188 # 80006120 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb46f>
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
    80000130:	57a080e7          	jalr	1402(ra) # 800026a6 <either_copyin>
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
    8000018e:	8b650513          	addi	a0,a0,-1866 # 80010a40 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8a648493          	addi	s1,s1,-1882 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	93690913          	addi	s2,s2,-1738 # 80010ad8 <cons+0x98>
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
    800001cc:	328080e7          	jalr	808(ra) # 800024f0 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	066080e7          	jalr	102(ra) # 8000223c <sleep>
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
    80000216:	43e080e7          	jalr	1086(ra) # 80002650 <either_copyout>
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
    8000022a:	81a50513          	addi	a0,a0,-2022 # 80010a40 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	80450513          	addi	a0,a0,-2044 # 80010a40 <cons>
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
    80000276:	86f72323          	sw	a5,-1946(a4) # 80010ad8 <cons+0x98>
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
    800002d0:	77450513          	addi	a0,a0,1908 # 80010a40 <cons>
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
    800002f6:	40a080e7          	jalr	1034(ra) # 800026fc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	74650513          	addi	a0,a0,1862 # 80010a40 <cons>
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
    80000322:	72270713          	addi	a4,a4,1826 # 80010a40 <cons>
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
    8000034c:	6f878793          	addi	a5,a5,1784 # 80010a40 <cons>
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
    8000037a:	7627a783          	lw	a5,1890(a5) # 80010ad8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6b670713          	addi	a4,a4,1718 # 80010a40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6a648493          	addi	s1,s1,1702 # 80010a40 <cons>
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
    800003da:	66a70713          	addi	a4,a4,1642 # 80010a40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72a23          	sw	a5,1780(a4) # 80010ae0 <cons+0xa0>
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
    80000416:	62e78793          	addi	a5,a5,1582 # 80010a40 <cons>
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
    8000043a:	6ac7a323          	sw	a2,1702(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	69a50513          	addi	a0,a0,1690 # 80010ad8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	e5a080e7          	jalr	-422(ra) # 800022a0 <wakeup>
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
    80000464:	5e050513          	addi	a0,a0,1504 # 80010a40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	d8078793          	addi	a5,a5,-640 # 800221f8 <devsw>
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
    8000054e:	5a07ab23          	sw	zero,1462(a5) # 80010b00 <pr+0x18>
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
    80000582:	34f72123          	sw	a5,834(a4) # 800088c0 <panicked>
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
    800005be:	546dad83          	lw	s11,1350(s11) # 80010b00 <pr+0x18>
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
    800005fc:	4f050513          	addi	a0,a0,1264 # 80010ae8 <pr>
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
    8000075a:	39250513          	addi	a0,a0,914 # 80010ae8 <pr>
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
    80000776:	37648493          	addi	s1,s1,886 # 80010ae8 <pr>
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
    800007d6:	33650513          	addi	a0,a0,822 # 80010b08 <uart_tx_lock>
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
    80000802:	0c27a783          	lw	a5,194(a5) # 800088c0 <panicked>
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
    8000083a:	0927b783          	ld	a5,146(a5) # 800088c8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	09273703          	ld	a4,146(a4) # 800088d0 <uart_tx_w>
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
    80000864:	2a8a0a13          	addi	s4,s4,680 # 80010b08 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	06048493          	addi	s1,s1,96 # 800088c8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	06098993          	addi	s3,s3,96 # 800088d0 <uart_tx_w>
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
    80000896:	a0e080e7          	jalr	-1522(ra) # 800022a0 <wakeup>
    
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
    800008d2:	23a50513          	addi	a0,a0,570 # 80010b08 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fe27a783          	lw	a5,-30(a5) # 800088c0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fe873703          	ld	a4,-24(a4) # 800088d0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fd87b783          	ld	a5,-40(a5) # 800088c8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	20c98993          	addi	s3,s3,524 # 80010b08 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fc448493          	addi	s1,s1,-60 # 800088c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fc490913          	addi	s2,s2,-60 # 800088d0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	920080e7          	jalr	-1760(ra) # 8000223c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1d648493          	addi	s1,s1,470 # 80010b08 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7b523          	sd	a4,-118(a5) # 800088d0 <uart_tx_w>
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
    800009c0:	14c48493          	addi	s1,s1,332 # 80010b08 <uart_tx_lock>
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
    80000a02:	99278793          	addi	a5,a5,-1646 # 80023390 <end>
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
    80000a22:	12290913          	addi	s2,s2,290 # 80010b40 <kmem>
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
    80000abe:	08650513          	addi	a0,a0,134 # 80010b40 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	8c250513          	addi	a0,a0,-1854 # 80023390 <end>
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
    80000af4:	05048493          	addi	s1,s1,80 # 80010b40 <kmem>
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
    80000b0c:	03850513          	addi	a0,a0,56 # 80010b40 <kmem>
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
    80000b38:	00c50513          	addi	a0,a0,12 # 80010b40 <kmem>
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
    80000e8c:	a5070713          	addi	a4,a4,-1456 # 800088d8 <started>
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
    80000ec2:	b2e080e7          	jalr	-1234(ra) # 800029ec <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	29a080e7          	jalr	666(ra) # 80006160 <plicinithart>
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
    80000f3a:	a8e080e7          	jalr	-1394(ra) # 800029c4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	aae080e7          	jalr	-1362(ra) # 800029ec <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	204080e7          	jalr	516(ra) # 8000614a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	212080e7          	jalr	530(ra) # 80006160 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	3b8080e7          	jalr	952(ra) # 8000330e <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	a5c080e7          	jalr	-1444(ra) # 800039ba <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	9fa080e7          	jalr	-1542(ra) # 80004960 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	2fa080e7          	jalr	762(ra) # 80006268 <virtio_disk_init>
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
    80000f90:	94f72623          	sw	a5,-1716(a4) # 800088d8 <started>
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
    80000fa4:	9407b783          	ld	a5,-1728(a5) # 800088e0 <kernel_pagetable>
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
    80001260:	68a7b223          	sd	a0,1668(a5) # 800088e0 <kernel_pagetable>
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
    80001848:	94c70713          	addi	a4,a4,-1716 # 80011190 <mlfq+0x200>
    8000184c:	00010617          	auipc	a2,0x10
    80001850:	16460613          	addi	a2,a2,356 # 800119b0 <proc+0x200>
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
    80001886:	70e70713          	addi	a4,a4,1806 # 80010f90 <mlfq>
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
    800018a4:	6f080813          	addi	a6,a6,1776 # 80010f90 <mlfq>
    800018a8:	97c2                	add	a5,a5,a6
    800018aa:	972e                	add	a4,a4,a1
    800018ac:	36fd                	addiw	a3,a3,-1
    800018ae:	1682                	slli	a3,a3,0x20
    800018b0:	9281                	srli	a3,a3,0x20
    800018b2:	9736                	add	a4,a4,a3
    800018b4:	070e                	slli	a4,a4,0x3
    800018b6:	0000f697          	auipc	a3,0xf
    800018ba:	6e268693          	addi	a3,a3,1762 # 80010f98 <mlfq+0x8>
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
    800018d2:	0227a783          	lw	a5,34(a5) # 800088f0 <ticks>
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
    800018ee:	6a668693          	addi	a3,a3,1702 # 80010f90 <mlfq>
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
    8000192e:	66670713          	addi	a4,a4,1638 # 80010f90 <mlfq>
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
    80001978:	61c80813          	addi	a6,a6,1564 # 80010f90 <mlfq>
    8000197c:	97c2                	add	a5,a5,a6
    8000197e:	36fd                	addiw	a3,a3,-1
    80001980:	40e6873b          	subw	a4,a3,a4
    80001984:	1702                	slli	a4,a4,0x20
    80001986:	9301                	srli	a4,a4,0x20
    80001988:	9732                	add	a4,a4,a2
    8000198a:	070e                	slli	a4,a4,0x3
    8000198c:	0000f697          	auipc	a3,0xf
    80001990:	60c68693          	addi	a3,a3,1548 # 80010f98 <mlfq+0x8>
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
    800019a8:	5ec70713          	addi	a4,a4,1516 # 80010f90 <mlfq>
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
    800019f4:	dc048493          	addi	s1,s1,-576 # 800117b0 <proc>
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
    80001a0e:	5a6a0a13          	addi	s4,s4,1446 # 80017fb0 <tickslock>
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
    80001a90:	0d450513          	addi	a0,a0,212 # 80010b60 <pid_lock>
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	0b2080e7          	jalr	178(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a9c:	00006597          	auipc	a1,0x6
    80001aa0:	74c58593          	addi	a1,a1,1868 # 800081e8 <digits+0x1a8>
    80001aa4:	0000f517          	auipc	a0,0xf
    80001aa8:	0d450513          	addi	a0,a0,212 # 80010b78 <wait_lock>
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	09a080e7          	jalr	154(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ab4:	00010497          	auipc	s1,0x10
    80001ab8:	cfc48493          	addi	s1,s1,-772 # 800117b0 <proc>
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
    80001ada:	4da98993          	addi	s3,s3,1242 # 80017fb0 <tickslock>
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
    80001b44:	05050513          	addi	a0,a0,80 # 80010b90 <cpus>
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
    80001b6c:	ff870713          	addi	a4,a4,-8 # 80010b60 <pid_lock>
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
    80001ba4:	cc07a783          	lw	a5,-832(a5) # 80008860 <first.1>
    80001ba8:	eb89                	bnez	a5,80001bba <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001baa:	00001097          	auipc	ra,0x1
    80001bae:	e5a080e7          	jalr	-422(ra) # 80002a04 <usertrapret>
}
    80001bb2:	60a2                	ld	ra,8(sp)
    80001bb4:	6402                	ld	s0,0(sp)
    80001bb6:	0141                	addi	sp,sp,16
    80001bb8:	8082                	ret
    first = 0;
    80001bba:	00007797          	auipc	a5,0x7
    80001bbe:	ca07a323          	sw	zero,-858(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001bc2:	4505                	li	a0,1
    80001bc4:	00002097          	auipc	ra,0x2
    80001bc8:	d76080e7          	jalr	-650(ra) # 8000393a <fsinit>
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
    80001bde:	f8690913          	addi	s2,s2,-122 # 80010b60 <pid_lock>
    80001be2:	854a                	mv	a0,s2
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	ff2080e7          	jalr	-14(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001bec:	00007797          	auipc	a5,0x7
    80001bf0:	c7878793          	addi	a5,a5,-904 # 80008864 <nextpid>
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
    80001d6a:	a4a48493          	addi	s1,s1,-1462 # 800117b0 <proc>
    80001d6e:	00016917          	auipc	s2,0x16
    80001d72:	24290913          	addi	s2,s2,578 # 80017fb0 <tickslock>
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
    80001dc8:	b2c72703          	lw	a4,-1236(a4) # 800088f0 <ticks>
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
    80001e26:	ace7a783          	lw	a5,-1330(a5) # 800088f0 <ticks>
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
    80001e84:	a6a7b423          	sd	a0,-1432(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e88:	03400613          	li	a2,52
    80001e8c:	00007597          	auipc	a1,0x7
    80001e90:	9e458593          	addi	a1,a1,-1564 # 80008870 <initcode>
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
    80001ece:	492080e7          	jalr	1170(ra) # 8000435c <namei>
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
    80001ffe:	9f8080e7          	jalr	-1544(ra) # 800049f2 <filedup>
    80002002:	00a93023          	sd	a0,0(s2)
    80002006:	b7e5                	j	80001fee <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002008:	160ab503          	ld	a0,352(s5)
    8000200c:	00002097          	auipc	ra,0x2
    80002010:	b6c080e7          	jalr	-1172(ra) # 80003b78 <idup>
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
    8000203c:	b4048493          	addi	s1,s1,-1216 # 80010b78 <wait_lock>
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
    8000208a:	7139                	addi	sp,sp,-64
    8000208c:	fc06                	sd	ra,56(sp)
    8000208e:	f822                	sd	s0,48(sp)
    80002090:	f426                	sd	s1,40(sp)
    80002092:	f04a                	sd	s2,32(sp)
    80002094:	ec4e                	sd	s3,24(sp)
    80002096:	e852                	sd	s4,16(sp)
    80002098:	e456                	sd	s5,8(sp)
    8000209a:	e05a                	sd	s6,0(sp)
    8000209c:	0080                	addi	s0,sp,64
    8000209e:	8792                	mv	a5,tp
  int id = r_tp();
    800020a0:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020a2:	00779a93          	slli	s5,a5,0x7
    800020a6:	0000f717          	auipc	a4,0xf
    800020aa:	aba70713          	addi	a4,a4,-1350 # 80010b60 <pid_lock>
    800020ae:	9756                	add	a4,a4,s5
    800020b0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800020b4:	0000f717          	auipc	a4,0xf
    800020b8:	ae470713          	addi	a4,a4,-1308 # 80010b98 <cpus+0x8>
    800020bc:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    800020be:	498d                	li	s3,3
        p->state = RUNNING;
    800020c0:	4b11                	li	s6,4
        c->proc = p;
    800020c2:	079e                	slli	a5,a5,0x7
    800020c4:	0000fa17          	auipc	s4,0xf
    800020c8:	a9ca0a13          	addi	s4,s4,-1380 # 80010b60 <pid_lock>
    800020cc:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800020ce:	00016917          	auipc	s2,0x16
    800020d2:	ee290913          	addi	s2,s2,-286 # 80017fb0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020da:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020de:	10079073          	csrw	sstatus,a5
    800020e2:	0000f497          	auipc	s1,0xf
    800020e6:	6ce48493          	addi	s1,s1,1742 # 800117b0 <proc>
    800020ea:	a811                	j	800020fe <scheduler+0x74>
      release(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	b9c080e7          	jalr	-1124(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020f6:	1a048493          	addi	s1,s1,416
    800020fa:	fd248ee3          	beq	s1,s2,800020d6 <scheduler+0x4c>
      acquire(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	ad6080e7          	jalr	-1322(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80002108:	54dc                	lw	a5,44(s1)
    8000210a:	ff3791e3          	bne	a5,s3,800020ec <scheduler+0x62>
        p->state = RUNNING;
    8000210e:	0364a623          	sw	s6,44(s1)
        c->proc = p;
    80002112:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002116:	07048593          	addi	a1,s1,112
    8000211a:	8556                	mv	a0,s5
    8000211c:	00001097          	auipc	ra,0x1
    80002120:	83e080e7          	jalr	-1986(ra) # 8000295a <swtch>
        c->proc = 0;
    80002124:	020a3823          	sd	zero,48(s4)
    80002128:	b7d1                	j	800020ec <scheduler+0x62>

000000008000212a <sched>:
{
    8000212a:	7179                	addi	sp,sp,-48
    8000212c:	f406                	sd	ra,40(sp)
    8000212e:	f022                	sd	s0,32(sp)
    80002130:	ec26                	sd	s1,24(sp)
    80002132:	e84a                	sd	s2,16(sp)
    80002134:	e44e                	sd	s3,8(sp)
    80002136:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002138:	00000097          	auipc	ra,0x0
    8000213c:	a18080e7          	jalr	-1512(ra) # 80001b50 <myproc>
    80002140:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	a1a080e7          	jalr	-1510(ra) # 80000b5c <holding>
    8000214a:	c93d                	beqz	a0,800021c0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000214c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000214e:	2781                	sext.w	a5,a5
    80002150:	079e                	slli	a5,a5,0x7
    80002152:	0000f717          	auipc	a4,0xf
    80002156:	a0e70713          	addi	a4,a4,-1522 # 80010b60 <pid_lock>
    8000215a:	97ba                	add	a5,a5,a4
    8000215c:	0a87a703          	lw	a4,168(a5)
    80002160:	4785                	li	a5,1
    80002162:	06f71763          	bne	a4,a5,800021d0 <sched+0xa6>
  if (p->state == RUNNING)
    80002166:	54d8                	lw	a4,44(s1)
    80002168:	4791                	li	a5,4
    8000216a:	06f70b63          	beq	a4,a5,800021e0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000216e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002172:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002174:	efb5                	bnez	a5,800021f0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002176:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002178:	0000f917          	auipc	s2,0xf
    8000217c:	9e890913          	addi	s2,s2,-1560 # 80010b60 <pid_lock>
    80002180:	2781                	sext.w	a5,a5
    80002182:	079e                	slli	a5,a5,0x7
    80002184:	97ca                	add	a5,a5,s2
    80002186:	0ac7a983          	lw	s3,172(a5)
    8000218a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000218c:	2781                	sext.w	a5,a5
    8000218e:	079e                	slli	a5,a5,0x7
    80002190:	0000f597          	auipc	a1,0xf
    80002194:	a0858593          	addi	a1,a1,-1528 # 80010b98 <cpus+0x8>
    80002198:	95be                	add	a1,a1,a5
    8000219a:	07048513          	addi	a0,s1,112
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	7bc080e7          	jalr	1980(ra) # 8000295a <swtch>
    800021a6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021a8:	2781                	sext.w	a5,a5
    800021aa:	079e                	slli	a5,a5,0x7
    800021ac:	97ca                	add	a5,a5,s2
    800021ae:	0b37a623          	sw	s3,172(a5)
}
    800021b2:	70a2                	ld	ra,40(sp)
    800021b4:	7402                	ld	s0,32(sp)
    800021b6:	64e2                	ld	s1,24(sp)
    800021b8:	6942                	ld	s2,16(sp)
    800021ba:	69a2                	ld	s3,8(sp)
    800021bc:	6145                	addi	sp,sp,48
    800021be:	8082                	ret
    panic("sched p->lock");
    800021c0:	00006517          	auipc	a0,0x6
    800021c4:	05850513          	addi	a0,a0,88 # 80008218 <digits+0x1d8>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	376080e7          	jalr	886(ra) # 8000053e <panic>
    panic("sched locks");
    800021d0:	00006517          	auipc	a0,0x6
    800021d4:	05850513          	addi	a0,a0,88 # 80008228 <digits+0x1e8>
    800021d8:	ffffe097          	auipc	ra,0xffffe
    800021dc:	366080e7          	jalr	870(ra) # 8000053e <panic>
    panic("sched running");
    800021e0:	00006517          	auipc	a0,0x6
    800021e4:	05850513          	addi	a0,a0,88 # 80008238 <digits+0x1f8>
    800021e8:	ffffe097          	auipc	ra,0xffffe
    800021ec:	356080e7          	jalr	854(ra) # 8000053e <panic>
    panic("sched interruptible");
    800021f0:	00006517          	auipc	a0,0x6
    800021f4:	05850513          	addi	a0,a0,88 # 80008248 <digits+0x208>
    800021f8:	ffffe097          	auipc	ra,0xffffe
    800021fc:	346080e7          	jalr	838(ra) # 8000053e <panic>

0000000080002200 <yield>:
{
    80002200:	1101                	addi	sp,sp,-32
    80002202:	ec06                	sd	ra,24(sp)
    80002204:	e822                	sd	s0,16(sp)
    80002206:	e426                	sd	s1,8(sp)
    80002208:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	946080e7          	jalr	-1722(ra) # 80001b50 <myproc>
    80002212:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	9c2080e7          	jalr	-1598(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000221c:	478d                	li	a5,3
    8000221e:	d4dc                	sw	a5,44(s1)
  sched();
    80002220:	00000097          	auipc	ra,0x0
    80002224:	f0a080e7          	jalr	-246(ra) # 8000212a <sched>
  release(&p->lock);
    80002228:	8526                	mv	a0,s1
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	a60080e7          	jalr	-1440(ra) # 80000c8a <release>
}
    80002232:	60e2                	ld	ra,24(sp)
    80002234:	6442                	ld	s0,16(sp)
    80002236:	64a2                	ld	s1,8(sp)
    80002238:	6105                	addi	sp,sp,32
    8000223a:	8082                	ret

000000008000223c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000223c:	7179                	addi	sp,sp,-48
    8000223e:	f406                	sd	ra,40(sp)
    80002240:	f022                	sd	s0,32(sp)
    80002242:	ec26                	sd	s1,24(sp)
    80002244:	e84a                	sd	s2,16(sp)
    80002246:	e44e                	sd	s3,8(sp)
    80002248:	1800                	addi	s0,sp,48
    8000224a:	89aa                	mv	s3,a0
    8000224c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000224e:	00000097          	auipc	ra,0x0
    80002252:	902080e7          	jalr	-1790(ra) # 80001b50 <myproc>
    80002256:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	97e080e7          	jalr	-1666(ra) # 80000bd6 <acquire>
  release(lk);
    80002260:	854a                	mv	a0,s2
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	a28080e7          	jalr	-1496(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000226a:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000226e:	4789                	li	a5,2
    80002270:	d4dc                	sw	a5,44(s1)

  sched();
    80002272:	00000097          	auipc	ra,0x0
    80002276:	eb8080e7          	jalr	-328(ra) # 8000212a <sched>

  // Tidy up.
  p->chan = 0;
    8000227a:	0204b823          	sd	zero,48(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	a0a080e7          	jalr	-1526(ra) # 80000c8a <release>
  acquire(lk);
    80002288:	854a                	mv	a0,s2
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	94c080e7          	jalr	-1716(ra) # 80000bd6 <acquire>
}
    80002292:	70a2                	ld	ra,40(sp)
    80002294:	7402                	ld	s0,32(sp)
    80002296:	64e2                	ld	s1,24(sp)
    80002298:	6942                	ld	s2,16(sp)
    8000229a:	69a2                	ld	s3,8(sp)
    8000229c:	6145                	addi	sp,sp,48
    8000229e:	8082                	ret

00000000800022a0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800022a0:	7139                	addi	sp,sp,-64
    800022a2:	fc06                	sd	ra,56(sp)
    800022a4:	f822                	sd	s0,48(sp)
    800022a6:	f426                	sd	s1,40(sp)
    800022a8:	f04a                	sd	s2,32(sp)
    800022aa:	ec4e                	sd	s3,24(sp)
    800022ac:	e852                	sd	s4,16(sp)
    800022ae:	e456                	sd	s5,8(sp)
    800022b0:	0080                	addi	s0,sp,64
    800022b2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800022b4:	0000f497          	auipc	s1,0xf
    800022b8:	4fc48493          	addi	s1,s1,1276 # 800117b0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800022bc:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800022be:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800022c0:	00016917          	auipc	s2,0x16
    800022c4:	cf090913          	addi	s2,s2,-784 # 80017fb0 <tickslock>
    800022c8:	a811                	j	800022dc <wakeup+0x3c>
      }
      release(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	9be080e7          	jalr	-1602(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022d4:	1a048493          	addi	s1,s1,416
    800022d8:	03248663          	beq	s1,s2,80002304 <wakeup+0x64>
    if (p != myproc())
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	874080e7          	jalr	-1932(ra) # 80001b50 <myproc>
    800022e4:	fea488e3          	beq	s1,a0,800022d4 <wakeup+0x34>
      acquire(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	8ec080e7          	jalr	-1812(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800022f2:	54dc                	lw	a5,44(s1)
    800022f4:	fd379be3          	bne	a5,s3,800022ca <wakeup+0x2a>
    800022f8:	789c                	ld	a5,48(s1)
    800022fa:	fd4798e3          	bne	a5,s4,800022ca <wakeup+0x2a>
        p->state = RUNNABLE;
    800022fe:	0354a623          	sw	s5,44(s1)
    80002302:	b7e1                	j	800022ca <wakeup+0x2a>
    }
  }
}
    80002304:	70e2                	ld	ra,56(sp)
    80002306:	7442                	ld	s0,48(sp)
    80002308:	74a2                	ld	s1,40(sp)
    8000230a:	7902                	ld	s2,32(sp)
    8000230c:	69e2                	ld	s3,24(sp)
    8000230e:	6a42                	ld	s4,16(sp)
    80002310:	6aa2                	ld	s5,8(sp)
    80002312:	6121                	addi	sp,sp,64
    80002314:	8082                	ret

0000000080002316 <reparent>:
{
    80002316:	7179                	addi	sp,sp,-48
    80002318:	f406                	sd	ra,40(sp)
    8000231a:	f022                	sd	s0,32(sp)
    8000231c:	ec26                	sd	s1,24(sp)
    8000231e:	e84a                	sd	s2,16(sp)
    80002320:	e44e                	sd	s3,8(sp)
    80002322:	e052                	sd	s4,0(sp)
    80002324:	1800                	addi	s0,sp,48
    80002326:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002328:	0000f497          	auipc	s1,0xf
    8000232c:	48848493          	addi	s1,s1,1160 # 800117b0 <proc>
      pp->parent = initproc;
    80002330:	00006a17          	auipc	s4,0x6
    80002334:	5b8a0a13          	addi	s4,s4,1464 # 800088e8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002338:	00016997          	auipc	s3,0x16
    8000233c:	c7898993          	addi	s3,s3,-904 # 80017fb0 <tickslock>
    80002340:	a029                	j	8000234a <reparent+0x34>
    80002342:	1a048493          	addi	s1,s1,416
    80002346:	01348d63          	beq	s1,s3,80002360 <reparent+0x4a>
    if (pp->parent == p)
    8000234a:	64bc                	ld	a5,72(s1)
    8000234c:	ff279be3          	bne	a5,s2,80002342 <reparent+0x2c>
      pp->parent = initproc;
    80002350:	000a3503          	ld	a0,0(s4)
    80002354:	e4a8                	sd	a0,72(s1)
      wakeup(initproc);
    80002356:	00000097          	auipc	ra,0x0
    8000235a:	f4a080e7          	jalr	-182(ra) # 800022a0 <wakeup>
    8000235e:	b7d5                	j	80002342 <reparent+0x2c>
}
    80002360:	70a2                	ld	ra,40(sp)
    80002362:	7402                	ld	s0,32(sp)
    80002364:	64e2                	ld	s1,24(sp)
    80002366:	6942                	ld	s2,16(sp)
    80002368:	69a2                	ld	s3,8(sp)
    8000236a:	6a02                	ld	s4,0(sp)
    8000236c:	6145                	addi	sp,sp,48
    8000236e:	8082                	ret

0000000080002370 <exit>:
{
    80002370:	7179                	addi	sp,sp,-48
    80002372:	f406                	sd	ra,40(sp)
    80002374:	f022                	sd	s0,32(sp)
    80002376:	ec26                	sd	s1,24(sp)
    80002378:	e84a                	sd	s2,16(sp)
    8000237a:	e44e                	sd	s3,8(sp)
    8000237c:	e052                	sd	s4,0(sp)
    8000237e:	1800                	addi	s0,sp,48
    80002380:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	7ce080e7          	jalr	1998(ra) # 80001b50 <myproc>
    8000238a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000238c:	00006797          	auipc	a5,0x6
    80002390:	55c7b783          	ld	a5,1372(a5) # 800088e8 <initproc>
    80002394:	0e050493          	addi	s1,a0,224
    80002398:	16050913          	addi	s2,a0,352
    8000239c:	02a79363          	bne	a5,a0,800023c2 <exit+0x52>
    panic("init exiting");
    800023a0:	00006517          	auipc	a0,0x6
    800023a4:	ec050513          	addi	a0,a0,-320 # 80008260 <digits+0x220>
    800023a8:	ffffe097          	auipc	ra,0xffffe
    800023ac:	196080e7          	jalr	406(ra) # 8000053e <panic>
      fileclose(f);
    800023b0:	00002097          	auipc	ra,0x2
    800023b4:	694080e7          	jalr	1684(ra) # 80004a44 <fileclose>
      p->ofile[fd] = 0;
    800023b8:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800023bc:	04a1                	addi	s1,s1,8
    800023be:	01248563          	beq	s1,s2,800023c8 <exit+0x58>
    if (p->ofile[fd])
    800023c2:	6088                	ld	a0,0(s1)
    800023c4:	f575                	bnez	a0,800023b0 <exit+0x40>
    800023c6:	bfdd                	j	800023bc <exit+0x4c>
  begin_op();
    800023c8:	00002097          	auipc	ra,0x2
    800023cc:	1b0080e7          	jalr	432(ra) # 80004578 <begin_op>
  iput(p->cwd);
    800023d0:	1609b503          	ld	a0,352(s3)
    800023d4:	00002097          	auipc	ra,0x2
    800023d8:	99c080e7          	jalr	-1636(ra) # 80003d70 <iput>
  end_op();
    800023dc:	00002097          	auipc	ra,0x2
    800023e0:	21c080e7          	jalr	540(ra) # 800045f8 <end_op>
  p->cwd = 0;
    800023e4:	1609b023          	sd	zero,352(s3)
  acquire(&wait_lock);
    800023e8:	0000e497          	auipc	s1,0xe
    800023ec:	79048493          	addi	s1,s1,1936 # 80010b78 <wait_lock>
    800023f0:	8526                	mv	a0,s1
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	7e4080e7          	jalr	2020(ra) # 80000bd6 <acquire>
  reparent(p);
    800023fa:	854e                	mv	a0,s3
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	f1a080e7          	jalr	-230(ra) # 80002316 <reparent>
  wakeup(p->parent);
    80002404:	0489b503          	ld	a0,72(s3)
    80002408:	00000097          	auipc	ra,0x0
    8000240c:	e98080e7          	jalr	-360(ra) # 800022a0 <wakeup>
  acquire(&p->lock);
    80002410:	854e                	mv	a0,s3
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	7c4080e7          	jalr	1988(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000241a:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    8000241e:	4795                	li	a5,5
    80002420:	02f9a623          	sw	a5,44(s3)
  p->etime = ticks;
    80002424:	00006797          	auipc	a5,0x6
    80002428:	4cc7a783          	lw	a5,1228(a5) # 800088f0 <ticks>
    8000242c:	18f9a023          	sw	a5,384(s3)
  release(&wait_lock);
    80002430:	8526                	mv	a0,s1
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
  sched();
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	cf0080e7          	jalr	-784(ra) # 8000212a <sched>
  panic("zombie exit");
    80002442:	00006517          	auipc	a0,0x6
    80002446:	e2e50513          	addi	a0,a0,-466 # 80008270 <digits+0x230>
    8000244a:	ffffe097          	auipc	ra,0xffffe
    8000244e:	0f4080e7          	jalr	244(ra) # 8000053e <panic>

0000000080002452 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002452:	7179                	addi	sp,sp,-48
    80002454:	f406                	sd	ra,40(sp)
    80002456:	f022                	sd	s0,32(sp)
    80002458:	ec26                	sd	s1,24(sp)
    8000245a:	e84a                	sd	s2,16(sp)
    8000245c:	e44e                	sd	s3,8(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002462:	0000f497          	auipc	s1,0xf
    80002466:	34e48493          	addi	s1,s1,846 # 800117b0 <proc>
    8000246a:	00016997          	auipc	s3,0x16
    8000246e:	b4698993          	addi	s3,s3,-1210 # 80017fb0 <tickslock>
  {
    acquire(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	762080e7          	jalr	1890(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    8000247c:	40bc                	lw	a5,64(s1)
    8000247e:	01278d63          	beq	a5,s2,80002498 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	806080e7          	jalr	-2042(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000248c:	1a048493          	addi	s1,s1,416
    80002490:	ff3491e3          	bne	s1,s3,80002472 <kill+0x20>
  }
  return -1;
    80002494:	557d                	li	a0,-1
    80002496:	a829                	j	800024b0 <kill+0x5e>
      p->killed = 1;
    80002498:	4785                	li	a5,1
    8000249a:	dc9c                	sw	a5,56(s1)
      if (p->state == SLEEPING)
    8000249c:	54d8                	lw	a4,44(s1)
    8000249e:	4789                	li	a5,2
    800024a0:	00f70f63          	beq	a4,a5,800024be <kill+0x6c>
      release(&p->lock);
    800024a4:	8526                	mv	a0,s1
    800024a6:	ffffe097          	auipc	ra,0xffffe
    800024aa:	7e4080e7          	jalr	2020(ra) # 80000c8a <release>
      return 0;
    800024ae:	4501                	li	a0,0
}
    800024b0:	70a2                	ld	ra,40(sp)
    800024b2:	7402                	ld	s0,32(sp)
    800024b4:	64e2                	ld	s1,24(sp)
    800024b6:	6942                	ld	s2,16(sp)
    800024b8:	69a2                	ld	s3,8(sp)
    800024ba:	6145                	addi	sp,sp,48
    800024bc:	8082                	ret
        p->state = RUNNABLE;
    800024be:	478d                	li	a5,3
    800024c0:	d4dc                	sw	a5,44(s1)
    800024c2:	b7cd                	j	800024a4 <kill+0x52>

00000000800024c4 <setkilled>:

void setkilled(struct proc *p)
{
    800024c4:	1101                	addi	sp,sp,-32
    800024c6:	ec06                	sd	ra,24(sp)
    800024c8:	e822                	sd	s0,16(sp)
    800024ca:	e426                	sd	s1,8(sp)
    800024cc:	1000                	addi	s0,sp,32
    800024ce:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	706080e7          	jalr	1798(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800024d8:	4785                	li	a5,1
    800024da:	dc9c                	sw	a5,56(s1)
  release(&p->lock);
    800024dc:	8526                	mv	a0,s1
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	7ac080e7          	jalr	1964(ra) # 80000c8a <release>
}
    800024e6:	60e2                	ld	ra,24(sp)
    800024e8:	6442                	ld	s0,16(sp)
    800024ea:	64a2                	ld	s1,8(sp)
    800024ec:	6105                	addi	sp,sp,32
    800024ee:	8082                	ret

00000000800024f0 <killed>:

int killed(struct proc *p)
{
    800024f0:	1101                	addi	sp,sp,-32
    800024f2:	ec06                	sd	ra,24(sp)
    800024f4:	e822                	sd	s0,16(sp)
    800024f6:	e426                	sd	s1,8(sp)
    800024f8:	e04a                	sd	s2,0(sp)
    800024fa:	1000                	addi	s0,sp,32
    800024fc:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	6d8080e7          	jalr	1752(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002506:	0384a903          	lw	s2,56(s1)
  release(&p->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	77e080e7          	jalr	1918(ra) # 80000c8a <release>
  return k;
}
    80002514:	854a                	mv	a0,s2
    80002516:	60e2                	ld	ra,24(sp)
    80002518:	6442                	ld	s0,16(sp)
    8000251a:	64a2                	ld	s1,8(sp)
    8000251c:	6902                	ld	s2,0(sp)
    8000251e:	6105                	addi	sp,sp,32
    80002520:	8082                	ret

0000000080002522 <wait>:
{
    80002522:	715d                	addi	sp,sp,-80
    80002524:	e486                	sd	ra,72(sp)
    80002526:	e0a2                	sd	s0,64(sp)
    80002528:	fc26                	sd	s1,56(sp)
    8000252a:	f84a                	sd	s2,48(sp)
    8000252c:	f44e                	sd	s3,40(sp)
    8000252e:	f052                	sd	s4,32(sp)
    80002530:	ec56                	sd	s5,24(sp)
    80002532:	e85a                	sd	s6,16(sp)
    80002534:	e45e                	sd	s7,8(sp)
    80002536:	e062                	sd	s8,0(sp)
    80002538:	0880                	addi	s0,sp,80
    8000253a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	614080e7          	jalr	1556(ra) # 80001b50 <myproc>
    80002544:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002546:	0000e517          	auipc	a0,0xe
    8000254a:	63250513          	addi	a0,a0,1586 # 80010b78 <wait_lock>
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	688080e7          	jalr	1672(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002556:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002558:	4a15                	li	s4,5
        havekids = 1;
    8000255a:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000255c:	00016997          	auipc	s3,0x16
    80002560:	a5498993          	addi	s3,s3,-1452 # 80017fb0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002564:	0000ec17          	auipc	s8,0xe
    80002568:	614c0c13          	addi	s8,s8,1556 # 80010b78 <wait_lock>
    havekids = 0;
    8000256c:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000256e:	0000f497          	auipc	s1,0xf
    80002572:	24248493          	addi	s1,s1,578 # 800117b0 <proc>
    80002576:	a0bd                	j	800025e4 <wait+0xc2>
          pid = pp->pid;
    80002578:	0404a983          	lw	s3,64(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000257c:	000b0e63          	beqz	s6,80002598 <wait+0x76>
    80002580:	4691                	li	a3,4
    80002582:	03c48613          	addi	a2,s1,60
    80002586:	85da                	mv	a1,s6
    80002588:	06093503          	ld	a0,96(s2)
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	0e4080e7          	jalr	228(ra) # 80001670 <copyout>
    80002594:	02054563          	bltz	a0,800025be <wait+0x9c>
          freeproc(pp);
    80002598:	8526                	mv	a0,s1
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	768080e7          	jalr	1896(ra) # 80001d02 <freeproc>
          release(&pp->lock);
    800025a2:	8526                	mv	a0,s1
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	6e6080e7          	jalr	1766(ra) # 80000c8a <release>
          release(&wait_lock);
    800025ac:	0000e517          	auipc	a0,0xe
    800025b0:	5cc50513          	addi	a0,a0,1484 # 80010b78 <wait_lock>
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	6d6080e7          	jalr	1750(ra) # 80000c8a <release>
          return pid;
    800025bc:	a0b5                	j	80002628 <wait+0x106>
            release(&pp->lock);
    800025be:	8526                	mv	a0,s1
    800025c0:	ffffe097          	auipc	ra,0xffffe
    800025c4:	6ca080e7          	jalr	1738(ra) # 80000c8a <release>
            release(&wait_lock);
    800025c8:	0000e517          	auipc	a0,0xe
    800025cc:	5b050513          	addi	a0,a0,1456 # 80010b78 <wait_lock>
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	6ba080e7          	jalr	1722(ra) # 80000c8a <release>
            return -1;
    800025d8:	59fd                	li	s3,-1
    800025da:	a0b9                	j	80002628 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800025dc:	1a048493          	addi	s1,s1,416
    800025e0:	03348463          	beq	s1,s3,80002608 <wait+0xe6>
      if (pp->parent == p)
    800025e4:	64bc                	ld	a5,72(s1)
    800025e6:	ff279be3          	bne	a5,s2,800025dc <wait+0xba>
        acquire(&pp->lock);
    800025ea:	8526                	mv	a0,s1
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	5ea080e7          	jalr	1514(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    800025f4:	54dc                	lw	a5,44(s1)
    800025f6:	f94781e3          	beq	a5,s4,80002578 <wait+0x56>
        release(&pp->lock);
    800025fa:	8526                	mv	a0,s1
    800025fc:	ffffe097          	auipc	ra,0xffffe
    80002600:	68e080e7          	jalr	1678(ra) # 80000c8a <release>
        havekids = 1;
    80002604:	8756                	mv	a4,s5
    80002606:	bfd9                	j	800025dc <wait+0xba>
    if (!havekids || killed(p))
    80002608:	c719                	beqz	a4,80002616 <wait+0xf4>
    8000260a:	854a                	mv	a0,s2
    8000260c:	00000097          	auipc	ra,0x0
    80002610:	ee4080e7          	jalr	-284(ra) # 800024f0 <killed>
    80002614:	c51d                	beqz	a0,80002642 <wait+0x120>
      release(&wait_lock);
    80002616:	0000e517          	auipc	a0,0xe
    8000261a:	56250513          	addi	a0,a0,1378 # 80010b78 <wait_lock>
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	66c080e7          	jalr	1644(ra) # 80000c8a <release>
      return -1;
    80002626:	59fd                	li	s3,-1
}
    80002628:	854e                	mv	a0,s3
    8000262a:	60a6                	ld	ra,72(sp)
    8000262c:	6406                	ld	s0,64(sp)
    8000262e:	74e2                	ld	s1,56(sp)
    80002630:	7942                	ld	s2,48(sp)
    80002632:	79a2                	ld	s3,40(sp)
    80002634:	7a02                	ld	s4,32(sp)
    80002636:	6ae2                	ld	s5,24(sp)
    80002638:	6b42                	ld	s6,16(sp)
    8000263a:	6ba2                	ld	s7,8(sp)
    8000263c:	6c02                	ld	s8,0(sp)
    8000263e:	6161                	addi	sp,sp,80
    80002640:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002642:	85e2                	mv	a1,s8
    80002644:	854a                	mv	a0,s2
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	bf6080e7          	jalr	-1034(ra) # 8000223c <sleep>
    havekids = 0;
    8000264e:	bf39                	j	8000256c <wait+0x4a>

0000000080002650 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002650:	7179                	addi	sp,sp,-48
    80002652:	f406                	sd	ra,40(sp)
    80002654:	f022                	sd	s0,32(sp)
    80002656:	ec26                	sd	s1,24(sp)
    80002658:	e84a                	sd	s2,16(sp)
    8000265a:	e44e                	sd	s3,8(sp)
    8000265c:	e052                	sd	s4,0(sp)
    8000265e:	1800                	addi	s0,sp,48
    80002660:	84aa                	mv	s1,a0
    80002662:	892e                	mv	s2,a1
    80002664:	89b2                	mv	s3,a2
    80002666:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002668:	fffff097          	auipc	ra,0xfffff
    8000266c:	4e8080e7          	jalr	1256(ra) # 80001b50 <myproc>
  if (user_dst)
    80002670:	c08d                	beqz	s1,80002692 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002672:	86d2                	mv	a3,s4
    80002674:	864e                	mv	a2,s3
    80002676:	85ca                	mv	a1,s2
    80002678:	7128                	ld	a0,96(a0)
    8000267a:	fffff097          	auipc	ra,0xfffff
    8000267e:	ff6080e7          	jalr	-10(ra) # 80001670 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002682:	70a2                	ld	ra,40(sp)
    80002684:	7402                	ld	s0,32(sp)
    80002686:	64e2                	ld	s1,24(sp)
    80002688:	6942                	ld	s2,16(sp)
    8000268a:	69a2                	ld	s3,8(sp)
    8000268c:	6a02                	ld	s4,0(sp)
    8000268e:	6145                	addi	sp,sp,48
    80002690:	8082                	ret
    memmove((char *)dst, src, len);
    80002692:	000a061b          	sext.w	a2,s4
    80002696:	85ce                	mv	a1,s3
    80002698:	854a                	mv	a0,s2
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	694080e7          	jalr	1684(ra) # 80000d2e <memmove>
    return 0;
    800026a2:	8526                	mv	a0,s1
    800026a4:	bff9                	j	80002682 <either_copyout+0x32>

00000000800026a6 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026a6:	7179                	addi	sp,sp,-48
    800026a8:	f406                	sd	ra,40(sp)
    800026aa:	f022                	sd	s0,32(sp)
    800026ac:	ec26                	sd	s1,24(sp)
    800026ae:	e84a                	sd	s2,16(sp)
    800026b0:	e44e                	sd	s3,8(sp)
    800026b2:	e052                	sd	s4,0(sp)
    800026b4:	1800                	addi	s0,sp,48
    800026b6:	892a                	mv	s2,a0
    800026b8:	84ae                	mv	s1,a1
    800026ba:	89b2                	mv	s3,a2
    800026bc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026be:	fffff097          	auipc	ra,0xfffff
    800026c2:	492080e7          	jalr	1170(ra) # 80001b50 <myproc>
  if (user_src)
    800026c6:	c08d                	beqz	s1,800026e8 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800026c8:	86d2                	mv	a3,s4
    800026ca:	864e                	mv	a2,s3
    800026cc:	85ca                	mv	a1,s2
    800026ce:	7128                	ld	a0,96(a0)
    800026d0:	fffff097          	auipc	ra,0xfffff
    800026d4:	02c080e7          	jalr	44(ra) # 800016fc <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800026d8:	70a2                	ld	ra,40(sp)
    800026da:	7402                	ld	s0,32(sp)
    800026dc:	64e2                	ld	s1,24(sp)
    800026de:	6942                	ld	s2,16(sp)
    800026e0:	69a2                	ld	s3,8(sp)
    800026e2:	6a02                	ld	s4,0(sp)
    800026e4:	6145                	addi	sp,sp,48
    800026e6:	8082                	ret
    memmove(dst, (char *)src, len);
    800026e8:	000a061b          	sext.w	a2,s4
    800026ec:	85ce                	mv	a1,s3
    800026ee:	854a                	mv	a0,s2
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	63e080e7          	jalr	1598(ra) # 80000d2e <memmove>
    return 0;
    800026f8:	8526                	mv	a0,s1
    800026fa:	bff9                	j	800026d8 <either_copyin+0x32>

00000000800026fc <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800026fc:	715d                	addi	sp,sp,-80
    800026fe:	e486                	sd	ra,72(sp)
    80002700:	e0a2                	sd	s0,64(sp)
    80002702:	fc26                	sd	s1,56(sp)
    80002704:	f84a                	sd	s2,48(sp)
    80002706:	f44e                	sd	s3,40(sp)
    80002708:	f052                	sd	s4,32(sp)
    8000270a:	ec56                	sd	s5,24(sp)
    8000270c:	e85a                	sd	s6,16(sp)
    8000270e:	e45e                	sd	s7,8(sp)
    80002710:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002712:	00006517          	auipc	a0,0x6
    80002716:	9b650513          	addi	a0,a0,-1610 # 800080c8 <digits+0x88>
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	e6e080e7          	jalr	-402(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002722:	0000f497          	auipc	s1,0xf
    80002726:	1f648493          	addi	s1,s1,502 # 80011918 <proc+0x168>
    8000272a:	00016917          	auipc	s2,0x16
    8000272e:	9ee90913          	addi	s2,s2,-1554 # 80018118 <bcache+0x150>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002732:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002734:	00006997          	auipc	s3,0x6
    80002738:	b4c98993          	addi	s3,s3,-1204 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000273c:	00006a97          	auipc	s5,0x6
    80002740:	b4ca8a93          	addi	s5,s5,-1204 # 80008288 <digits+0x248>
    printf("\n");
    80002744:	00006a17          	auipc	s4,0x6
    80002748:	984a0a13          	addi	s4,s4,-1660 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000274c:	00006b97          	auipc	s7,0x6
    80002750:	b7cb8b93          	addi	s7,s7,-1156 # 800082c8 <states.0>
    80002754:	a00d                	j	80002776 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002756:	ed86a583          	lw	a1,-296(a3)
    8000275a:	8556                	mv	a0,s5
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	e2c080e7          	jalr	-468(ra) # 80000588 <printf>
    printf("\n");
    80002764:	8552                	mv	a0,s4
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	e22080e7          	jalr	-478(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000276e:	1a048493          	addi	s1,s1,416
    80002772:	03248163          	beq	s1,s2,80002794 <procdump+0x98>
    if (p->state == UNUSED)
    80002776:	86a6                	mv	a3,s1
    80002778:	ec44a783          	lw	a5,-316(s1)
    8000277c:	dbed                	beqz	a5,8000276e <procdump+0x72>
      state = "???";
    8000277e:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002780:	fcfb6be3          	bltu	s6,a5,80002756 <procdump+0x5a>
    80002784:	1782                	slli	a5,a5,0x20
    80002786:	9381                	srli	a5,a5,0x20
    80002788:	078e                	slli	a5,a5,0x3
    8000278a:	97de                	add	a5,a5,s7
    8000278c:	6390                	ld	a2,0(a5)
    8000278e:	f661                	bnez	a2,80002756 <procdump+0x5a>
      state = "???";
    80002790:	864e                	mv	a2,s3
    80002792:	b7d1                	j	80002756 <procdump+0x5a>
  }
}
    80002794:	60a6                	ld	ra,72(sp)
    80002796:	6406                	ld	s0,64(sp)
    80002798:	74e2                	ld	s1,56(sp)
    8000279a:	7942                	ld	s2,48(sp)
    8000279c:	79a2                	ld	s3,40(sp)
    8000279e:	7a02                	ld	s4,32(sp)
    800027a0:	6ae2                	ld	s5,24(sp)
    800027a2:	6b42                	ld	s6,16(sp)
    800027a4:	6ba2                	ld	s7,8(sp)
    800027a6:	6161                	addi	sp,sp,80
    800027a8:	8082                	ret

00000000800027aa <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800027aa:	711d                	addi	sp,sp,-96
    800027ac:	ec86                	sd	ra,88(sp)
    800027ae:	e8a2                	sd	s0,80(sp)
    800027b0:	e4a6                	sd	s1,72(sp)
    800027b2:	e0ca                	sd	s2,64(sp)
    800027b4:	fc4e                	sd	s3,56(sp)
    800027b6:	f852                	sd	s4,48(sp)
    800027b8:	f456                	sd	s5,40(sp)
    800027ba:	f05a                	sd	s6,32(sp)
    800027bc:	ec5e                	sd	s7,24(sp)
    800027be:	e862                	sd	s8,16(sp)
    800027c0:	e466                	sd	s9,8(sp)
    800027c2:	e06a                	sd	s10,0(sp)
    800027c4:	1080                	addi	s0,sp,96
    800027c6:	8b2a                	mv	s6,a0
    800027c8:	8bae                	mv	s7,a1
    800027ca:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800027cc:	fffff097          	auipc	ra,0xfffff
    800027d0:	384080e7          	jalr	900(ra) # 80001b50 <myproc>
    800027d4:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800027d6:	0000e517          	auipc	a0,0xe
    800027da:	3a250513          	addi	a0,a0,930 # 80010b78 <wait_lock>
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	3f8080e7          	jalr	1016(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800027e6:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800027e8:	4a15                	li	s4,5
        havekids = 1;
    800027ea:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800027ec:	00015997          	auipc	s3,0x15
    800027f0:	7c498993          	addi	s3,s3,1988 # 80017fb0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027f4:	0000ed17          	auipc	s10,0xe
    800027f8:	384d0d13          	addi	s10,s10,900 # 80010b78 <wait_lock>
    havekids = 0;
    800027fc:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800027fe:	0000f497          	auipc	s1,0xf
    80002802:	fb248493          	addi	s1,s1,-78 # 800117b0 <proc>
    80002806:	a059                	j	8000288c <waitx+0xe2>
          pid = np->pid;
    80002808:	0404a983          	lw	s3,64(s1)
          *rtime = np->rtime;
    8000280c:	1784a703          	lw	a4,376(s1)
    80002810:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002814:	17c4a783          	lw	a5,380(s1)
    80002818:	9f3d                	addw	a4,a4,a5
    8000281a:	1804a783          	lw	a5,384(s1)
    8000281e:	9f99                	subw	a5,a5,a4
    80002820:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002824:	000b0e63          	beqz	s6,80002840 <waitx+0x96>
    80002828:	4691                	li	a3,4
    8000282a:	03c48613          	addi	a2,s1,60
    8000282e:	85da                	mv	a1,s6
    80002830:	06093503          	ld	a0,96(s2)
    80002834:	fffff097          	auipc	ra,0xfffff
    80002838:	e3c080e7          	jalr	-452(ra) # 80001670 <copyout>
    8000283c:	02054563          	bltz	a0,80002866 <waitx+0xbc>
          freeproc(np);
    80002840:	8526                	mv	a0,s1
    80002842:	fffff097          	auipc	ra,0xfffff
    80002846:	4c0080e7          	jalr	1216(ra) # 80001d02 <freeproc>
          release(&np->lock);
    8000284a:	8526                	mv	a0,s1
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	43e080e7          	jalr	1086(ra) # 80000c8a <release>
          release(&wait_lock);
    80002854:	0000e517          	auipc	a0,0xe
    80002858:	32450513          	addi	a0,a0,804 # 80010b78 <wait_lock>
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	42e080e7          	jalr	1070(ra) # 80000c8a <release>
          return pid;
    80002864:	a09d                	j	800028ca <waitx+0x120>
            release(&np->lock);
    80002866:	8526                	mv	a0,s1
    80002868:	ffffe097          	auipc	ra,0xffffe
    8000286c:	422080e7          	jalr	1058(ra) # 80000c8a <release>
            release(&wait_lock);
    80002870:	0000e517          	auipc	a0,0xe
    80002874:	30850513          	addi	a0,a0,776 # 80010b78 <wait_lock>
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	412080e7          	jalr	1042(ra) # 80000c8a <release>
            return -1;
    80002880:	59fd                	li	s3,-1
    80002882:	a0a1                	j	800028ca <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002884:	1a048493          	addi	s1,s1,416
    80002888:	03348463          	beq	s1,s3,800028b0 <waitx+0x106>
      if (np->parent == p)
    8000288c:	64bc                	ld	a5,72(s1)
    8000288e:	ff279be3          	bne	a5,s2,80002884 <waitx+0xda>
        acquire(&np->lock);
    80002892:	8526                	mv	a0,s1
    80002894:	ffffe097          	auipc	ra,0xffffe
    80002898:	342080e7          	jalr	834(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000289c:	54dc                	lw	a5,44(s1)
    8000289e:	f74785e3          	beq	a5,s4,80002808 <waitx+0x5e>
        release(&np->lock);
    800028a2:	8526                	mv	a0,s1
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	3e6080e7          	jalr	998(ra) # 80000c8a <release>
        havekids = 1;
    800028ac:	8756                	mv	a4,s5
    800028ae:	bfd9                	j	80002884 <waitx+0xda>
    if (!havekids || p->killed)
    800028b0:	c701                	beqz	a4,800028b8 <waitx+0x10e>
    800028b2:	03892783          	lw	a5,56(s2)
    800028b6:	cb8d                	beqz	a5,800028e8 <waitx+0x13e>
      release(&wait_lock);
    800028b8:	0000e517          	auipc	a0,0xe
    800028bc:	2c050513          	addi	a0,a0,704 # 80010b78 <wait_lock>
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	3ca080e7          	jalr	970(ra) # 80000c8a <release>
      return -1;
    800028c8:	59fd                	li	s3,-1
  }
}
    800028ca:	854e                	mv	a0,s3
    800028cc:	60e6                	ld	ra,88(sp)
    800028ce:	6446                	ld	s0,80(sp)
    800028d0:	64a6                	ld	s1,72(sp)
    800028d2:	6906                	ld	s2,64(sp)
    800028d4:	79e2                	ld	s3,56(sp)
    800028d6:	7a42                	ld	s4,48(sp)
    800028d8:	7aa2                	ld	s5,40(sp)
    800028da:	7b02                	ld	s6,32(sp)
    800028dc:	6be2                	ld	s7,24(sp)
    800028de:	6c42                	ld	s8,16(sp)
    800028e0:	6ca2                	ld	s9,8(sp)
    800028e2:	6d02                	ld	s10,0(sp)
    800028e4:	6125                	addi	sp,sp,96
    800028e6:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028e8:	85ea                	mv	a1,s10
    800028ea:	854a                	mv	a0,s2
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	950080e7          	jalr	-1712(ra) # 8000223c <sleep>
    havekids = 0;
    800028f4:	b721                	j	800027fc <waitx+0x52>

00000000800028f6 <update_time>:

void update_time()
{
    800028f6:	7179                	addi	sp,sp,-48
    800028f8:	f406                	sd	ra,40(sp)
    800028fa:	f022                	sd	s0,32(sp)
    800028fc:	ec26                	sd	s1,24(sp)
    800028fe:	e84a                	sd	s2,16(sp)
    80002900:	e44e                	sd	s3,8(sp)
    80002902:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002904:	0000f497          	auipc	s1,0xf
    80002908:	eac48493          	addi	s1,s1,-340 # 800117b0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000290c:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    8000290e:	00015917          	auipc	s2,0x15
    80002912:	6a290913          	addi	s2,s2,1698 # 80017fb0 <tickslock>
    80002916:	a811                	j	8000292a <update_time+0x34>
    {
      p->rtime++;
      p->timeToNextQueue--;
    }
    release(&p->lock);
    80002918:	8526                	mv	a0,s1
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	370080e7          	jalr	880(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002922:	1a048493          	addi	s1,s1,416
    80002926:	03248363          	beq	s1,s2,8000294c <update_time+0x56>
    acquire(&p->lock);
    8000292a:	8526                	mv	a0,s1
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	2aa080e7          	jalr	682(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002934:	54dc                	lw	a5,44(s1)
    80002936:	ff3791e3          	bne	a5,s3,80002918 <update_time+0x22>
      p->rtime++;
    8000293a:	1784a783          	lw	a5,376(s1)
    8000293e:	2785                	addiw	a5,a5,1
    80002940:	16f4ac23          	sw	a5,376(s1)
      p->timeToNextQueue--;
    80002944:	50dc                	lw	a5,36(s1)
    80002946:	37fd                	addiw	a5,a5,-1
    80002948:	d0dc                	sw	a5,36(s1)
    8000294a:	b7f9                	j	80002918 <update_time+0x22>
  }
    8000294c:	70a2                	ld	ra,40(sp)
    8000294e:	7402                	ld	s0,32(sp)
    80002950:	64e2                	ld	s1,24(sp)
    80002952:	6942                	ld	s2,16(sp)
    80002954:	69a2                	ld	s3,8(sp)
    80002956:	6145                	addi	sp,sp,48
    80002958:	8082                	ret

000000008000295a <swtch>:
    8000295a:	00153023          	sd	ra,0(a0)
    8000295e:	00253423          	sd	sp,8(a0)
    80002962:	e900                	sd	s0,16(a0)
    80002964:	ed04                	sd	s1,24(a0)
    80002966:	03253023          	sd	s2,32(a0)
    8000296a:	03353423          	sd	s3,40(a0)
    8000296e:	03453823          	sd	s4,48(a0)
    80002972:	03553c23          	sd	s5,56(a0)
    80002976:	05653023          	sd	s6,64(a0)
    8000297a:	05753423          	sd	s7,72(a0)
    8000297e:	05853823          	sd	s8,80(a0)
    80002982:	05953c23          	sd	s9,88(a0)
    80002986:	07a53023          	sd	s10,96(a0)
    8000298a:	07b53423          	sd	s11,104(a0)
    8000298e:	0005b083          	ld	ra,0(a1)
    80002992:	0085b103          	ld	sp,8(a1)
    80002996:	6980                	ld	s0,16(a1)
    80002998:	6d84                	ld	s1,24(a1)
    8000299a:	0205b903          	ld	s2,32(a1)
    8000299e:	0285b983          	ld	s3,40(a1)
    800029a2:	0305ba03          	ld	s4,48(a1)
    800029a6:	0385ba83          	ld	s5,56(a1)
    800029aa:	0405bb03          	ld	s6,64(a1)
    800029ae:	0485bb83          	ld	s7,72(a1)
    800029b2:	0505bc03          	ld	s8,80(a1)
    800029b6:	0585bc83          	ld	s9,88(a1)
    800029ba:	0605bd03          	ld	s10,96(a1)
    800029be:	0685bd83          	ld	s11,104(a1)
    800029c2:	8082                	ret

00000000800029c4 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800029c4:	1141                	addi	sp,sp,-16
    800029c6:	e406                	sd	ra,8(sp)
    800029c8:	e022                	sd	s0,0(sp)
    800029ca:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029cc:	00006597          	auipc	a1,0x6
    800029d0:	92c58593          	addi	a1,a1,-1748 # 800082f8 <states.0+0x30>
    800029d4:	00015517          	auipc	a0,0x15
    800029d8:	5dc50513          	addi	a0,a0,1500 # 80017fb0 <tickslock>
    800029dc:	ffffe097          	auipc	ra,0xffffe
    800029e0:	16a080e7          	jalr	362(ra) # 80000b46 <initlock>
}
    800029e4:	60a2                	ld	ra,8(sp)
    800029e6:	6402                	ld	s0,0(sp)
    800029e8:	0141                	addi	sp,sp,16
    800029ea:	8082                	ret

00000000800029ec <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800029ec:	1141                	addi	sp,sp,-16
    800029ee:	e422                	sd	s0,8(sp)
    800029f0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f2:	00003797          	auipc	a5,0x3
    800029f6:	69e78793          	addi	a5,a5,1694 # 80006090 <kernelvec>
    800029fa:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029fe:	6422                	ld	s0,8(sp)
    80002a00:	0141                	addi	sp,sp,16
    80002a02:	8082                	ret

0000000080002a04 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002a04:	1141                	addi	sp,sp,-16
    80002a06:	e406                	sd	ra,8(sp)
    80002a08:	e022                	sd	s0,0(sp)
    80002a0a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a0c:	fffff097          	auipc	ra,0xfffff
    80002a10:	144080e7          	jalr	324(ra) # 80001b50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a1a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a1e:	00004617          	auipc	a2,0x4
    80002a22:	5e260613          	addi	a2,a2,1506 # 80007000 <_trampoline>
    80002a26:	00004697          	auipc	a3,0x4
    80002a2a:	5da68693          	addi	a3,a3,1498 # 80007000 <_trampoline>
    80002a2e:	8e91                	sub	a3,a3,a2
    80002a30:	040007b7          	lui	a5,0x4000
    80002a34:	17fd                	addi	a5,a5,-1
    80002a36:	07b2                	slli	a5,a5,0xc
    80002a38:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a3a:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a3e:	7538                	ld	a4,104(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a40:	180026f3          	csrr	a3,satp
    80002a44:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a46:	7538                	ld	a4,104(a0)
    80002a48:	6934                	ld	a3,80(a0)
    80002a4a:	6585                	lui	a1,0x1
    80002a4c:	96ae                	add	a3,a3,a1
    80002a4e:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a50:	7538                	ld	a4,104(a0)
    80002a52:	00000697          	auipc	a3,0x0
    80002a56:	13e68693          	addi	a3,a3,318 # 80002b90 <usertrap>
    80002a5a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002a5c:	7538                	ld	a4,104(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a5e:	8692                	mv	a3,tp
    80002a60:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a62:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a66:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a6a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a6e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a72:	7538                	ld	a4,104(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a74:	6f18                	ld	a4,24(a4)
    80002a76:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a7a:	7128                	ld	a0,96(a0)
    80002a7c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a7e:	00004717          	auipc	a4,0x4
    80002a82:	61e70713          	addi	a4,a4,1566 # 8000709c <userret>
    80002a86:	8f11                	sub	a4,a4,a2
    80002a88:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a8a:	577d                	li	a4,-1
    80002a8c:	177e                	slli	a4,a4,0x3f
    80002a8e:	8d59                	or	a0,a0,a4
    80002a90:	9782                	jalr	a5
}
    80002a92:	60a2                	ld	ra,8(sp)
    80002a94:	6402                	ld	s0,0(sp)
    80002a96:	0141                	addi	sp,sp,16
    80002a98:	8082                	ret

0000000080002a9a <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002a9a:	1101                	addi	sp,sp,-32
    80002a9c:	ec06                	sd	ra,24(sp)
    80002a9e:	e822                	sd	s0,16(sp)
    80002aa0:	e426                	sd	s1,8(sp)
    80002aa2:	e04a                	sd	s2,0(sp)
    80002aa4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002aa6:	00015917          	auipc	s2,0x15
    80002aaa:	50a90913          	addi	s2,s2,1290 # 80017fb0 <tickslock>
    80002aae:	854a                	mv	a0,s2
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	126080e7          	jalr	294(ra) # 80000bd6 <acquire>
  ticks++;
    80002ab8:	00006497          	auipc	s1,0x6
    80002abc:	e3848493          	addi	s1,s1,-456 # 800088f0 <ticks>
    80002ac0:	409c                	lw	a5,0(s1)
    80002ac2:	2785                	addiw	a5,a5,1
    80002ac4:	c09c                	sw	a5,0(s1)
  update_time();
    80002ac6:	00000097          	auipc	ra,0x0
    80002aca:	e30080e7          	jalr	-464(ra) # 800028f6 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002ace:	8526                	mv	a0,s1
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	7d0080e7          	jalr	2000(ra) # 800022a0 <wakeup>
  release(&tickslock);
    80002ad8:	854a                	mv	a0,s2
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	1b0080e7          	jalr	432(ra) # 80000c8a <release>
}
    80002ae2:	60e2                	ld	ra,24(sp)
    80002ae4:	6442                	ld	s0,16(sp)
    80002ae6:	64a2                	ld	s1,8(sp)
    80002ae8:	6902                	ld	s2,0(sp)
    80002aea:	6105                	addi	sp,sp,32
    80002aec:	8082                	ret

0000000080002aee <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002aee:	1101                	addi	sp,sp,-32
    80002af0:	ec06                	sd	ra,24(sp)
    80002af2:	e822                	sd	s0,16(sp)
    80002af4:	e426                	sd	s1,8(sp)
    80002af6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002afc:	00074d63          	bltz	a4,80002b16 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002b00:	57fd                	li	a5,-1
    80002b02:	17fe                	slli	a5,a5,0x3f
    80002b04:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002b06:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002b08:	06f70363          	beq	a4,a5,80002b6e <devintr+0x80>
  }
}
    80002b0c:	60e2                	ld	ra,24(sp)
    80002b0e:	6442                	ld	s0,16(sp)
    80002b10:	64a2                	ld	s1,8(sp)
    80002b12:	6105                	addi	sp,sp,32
    80002b14:	8082                	ret
      (scause & 0xff) == 9)
    80002b16:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002b1a:	46a5                	li	a3,9
    80002b1c:	fed792e3          	bne	a5,a3,80002b00 <devintr+0x12>
    int irq = plic_claim();
    80002b20:	00003097          	auipc	ra,0x3
    80002b24:	678080e7          	jalr	1656(ra) # 80006198 <plic_claim>
    80002b28:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002b2a:	47a9                	li	a5,10
    80002b2c:	02f50763          	beq	a0,a5,80002b5a <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002b30:	4785                	li	a5,1
    80002b32:	02f50963          	beq	a0,a5,80002b64 <devintr+0x76>
    return 1;
    80002b36:	4505                	li	a0,1
    else if (irq)
    80002b38:	d8f1                	beqz	s1,80002b0c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b3a:	85a6                	mv	a1,s1
    80002b3c:	00005517          	auipc	a0,0x5
    80002b40:	7c450513          	addi	a0,a0,1988 # 80008300 <states.0+0x38>
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	a44080e7          	jalr	-1468(ra) # 80000588 <printf>
      plic_complete(irq);
    80002b4c:	8526                	mv	a0,s1
    80002b4e:	00003097          	auipc	ra,0x3
    80002b52:	66e080e7          	jalr	1646(ra) # 800061bc <plic_complete>
    return 1;
    80002b56:	4505                	li	a0,1
    80002b58:	bf55                	j	80002b0c <devintr+0x1e>
      uartintr();
    80002b5a:	ffffe097          	auipc	ra,0xffffe
    80002b5e:	e40080e7          	jalr	-448(ra) # 8000099a <uartintr>
    80002b62:	b7ed                	j	80002b4c <devintr+0x5e>
      virtio_disk_intr();
    80002b64:	00004097          	auipc	ra,0x4
    80002b68:	b24080e7          	jalr	-1244(ra) # 80006688 <virtio_disk_intr>
    80002b6c:	b7c5                	j	80002b4c <devintr+0x5e>
    if (cpuid() == 0)
    80002b6e:	fffff097          	auipc	ra,0xfffff
    80002b72:	fb6080e7          	jalr	-74(ra) # 80001b24 <cpuid>
    80002b76:	c901                	beqz	a0,80002b86 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b78:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b7c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b7e:	14479073          	csrw	sip,a5
    return 2;
    80002b82:	4509                	li	a0,2
    80002b84:	b761                	j	80002b0c <devintr+0x1e>
      clockintr();
    80002b86:	00000097          	auipc	ra,0x0
    80002b8a:	f14080e7          	jalr	-236(ra) # 80002a9a <clockintr>
    80002b8e:	b7ed                	j	80002b78 <devintr+0x8a>

0000000080002b90 <usertrap>:
{
    80002b90:	1101                	addi	sp,sp,-32
    80002b92:	ec06                	sd	ra,24(sp)
    80002b94:	e822                	sd	s0,16(sp)
    80002b96:	e426                	sd	s1,8(sp)
    80002b98:	e04a                	sd	s2,0(sp)
    80002b9a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002ba0:	1007f793          	andi	a5,a5,256
    80002ba4:	e3b1                	bnez	a5,80002be8 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ba6:	00003797          	auipc	a5,0x3
    80002baa:	4ea78793          	addi	a5,a5,1258 # 80006090 <kernelvec>
    80002bae:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	f9e080e7          	jalr	-98(ra) # 80001b50 <myproc>
    80002bba:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bbc:	753c                	ld	a5,104(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bbe:	14102773          	csrr	a4,sepc
    80002bc2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bc4:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002bc8:	47a1                	li	a5,8
    80002bca:	02f70763          	beq	a4,a5,80002bf8 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002bce:	00000097          	auipc	ra,0x0
    80002bd2:	f20080e7          	jalr	-224(ra) # 80002aee <devintr>
    80002bd6:	892a                	mv	s2,a0
    80002bd8:	c92d                	beqz	a0,80002c4a <usertrap+0xba>
  if (killed(p))
    80002bda:	8526                	mv	a0,s1
    80002bdc:	00000097          	auipc	ra,0x0
    80002be0:	914080e7          	jalr	-1772(ra) # 800024f0 <killed>
    80002be4:	c555                	beqz	a0,80002c90 <usertrap+0x100>
    80002be6:	a045                	j	80002c86 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002be8:	00005517          	auipc	a0,0x5
    80002bec:	73850513          	addi	a0,a0,1848 # 80008320 <states.0+0x58>
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	94e080e7          	jalr	-1714(ra) # 8000053e <panic>
    if (killed(p))
    80002bf8:	00000097          	auipc	ra,0x0
    80002bfc:	8f8080e7          	jalr	-1800(ra) # 800024f0 <killed>
    80002c00:	ed1d                	bnez	a0,80002c3e <usertrap+0xae>
    p->trapframe->epc += 4;
    80002c02:	74b8                	ld	a4,104(s1)
    80002c04:	6f1c                	ld	a5,24(a4)
    80002c06:	0791                	addi	a5,a5,4
    80002c08:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c0e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c12:	10079073          	csrw	sstatus,a5
    syscall();
    80002c16:	00000097          	auipc	ra,0x0
    80002c1a:	320080e7          	jalr	800(ra) # 80002f36 <syscall>
  if (killed(p))
    80002c1e:	8526                	mv	a0,s1
    80002c20:	00000097          	auipc	ra,0x0
    80002c24:	8d0080e7          	jalr	-1840(ra) # 800024f0 <killed>
    80002c28:	ed31                	bnez	a0,80002c84 <usertrap+0xf4>
  usertrapret();
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	dda080e7          	jalr	-550(ra) # 80002a04 <usertrapret>
}
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	64a2                	ld	s1,8(sp)
    80002c38:	6902                	ld	s2,0(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret
      exit(-1);
    80002c3e:	557d                	li	a0,-1
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	730080e7          	jalr	1840(ra) # 80002370 <exit>
    80002c48:	bf6d                	j	80002c02 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c4a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c4e:	40b0                	lw	a2,64(s1)
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	6f050513          	addi	a0,a0,1776 # 80008340 <states.0+0x78>
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	930080e7          	jalr	-1744(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c60:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c64:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c68:	00005517          	auipc	a0,0x5
    80002c6c:	70850513          	addi	a0,a0,1800 # 80008370 <states.0+0xa8>
    80002c70:	ffffe097          	auipc	ra,0xffffe
    80002c74:	918080e7          	jalr	-1768(ra) # 80000588 <printf>
    setkilled(p);
    80002c78:	8526                	mv	a0,s1
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	84a080e7          	jalr	-1974(ra) # 800024c4 <setkilled>
    80002c82:	bf71                	j	80002c1e <usertrap+0x8e>
  if (killed(p))
    80002c84:	4901                	li	s2,0
    exit(-1);
    80002c86:	557d                	li	a0,-1
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	6e8080e7          	jalr	1768(ra) # 80002370 <exit>
  if (which_dev == 2)
    80002c90:	4789                	li	a5,2
    80002c92:	f8f91ce3          	bne	s2,a5,80002c2a <usertrap+0x9a>
    if (p->interval > 0)
    80002c96:	18c4a783          	lw	a5,396(s1)
    80002c9a:	00f05e63          	blez	a5,80002cb6 <usertrap+0x126>
      if (p->signalstatus == 0)
    80002c9e:	1944a703          	lw	a4,404(s1)
    80002ca2:	eb11                	bnez	a4,80002cb6 <usertrap+0x126>
        p->tickscurrently += 1;
    80002ca4:	1904a703          	lw	a4,400(s1)
    80002ca8:	2705                	addiw	a4,a4,1
    80002caa:	0007069b          	sext.w	a3,a4
        if (p->interval <= p->tickscurrently)
    80002cae:	00f6d963          	bge	a3,a5,80002cc0 <usertrap+0x130>
        p->tickscurrently += 1;
    80002cb2:	18e4a823          	sw	a4,400(s1)
    yield();
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	54a080e7          	jalr	1354(ra) # 80002200 <yield>
    80002cbe:	b7b5                	j	80002c2a <usertrap+0x9a>
          p->tickscurrently = 0;
    80002cc0:	1804a823          	sw	zero,400(s1)
          p->signalstatus = 1;
    80002cc4:	4785                	li	a5,1
    80002cc6:	18f4aa23          	sw	a5,404(s1)
          p->trapframealarm = kalloc();
    80002cca:	ffffe097          	auipc	ra,0xffffe
    80002cce:	e1c080e7          	jalr	-484(ra) # 80000ae6 <kalloc>
    80002cd2:	18a4bc23          	sd	a0,408(s1)
          memmove(p->trapframealarm, p->trapframe, PGSIZE);
    80002cd6:	6605                	lui	a2,0x1
    80002cd8:	74ac                	ld	a1,104(s1)
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	054080e7          	jalr	84(ra) # 80000d2e <memmove>
          p->trapframe->epc = p->handler;
    80002ce2:	74bc                	ld	a5,104(s1)
    80002ce4:	1884e703          	lwu	a4,392(s1)
    80002ce8:	ef98                	sd	a4,24(a5)
    80002cea:	b7f1                	j	80002cb6 <usertrap+0x126>

0000000080002cec <kerneltrap>:
{
    80002cec:	7179                	addi	sp,sp,-48
    80002cee:	f406                	sd	ra,40(sp)
    80002cf0:	f022                	sd	s0,32(sp)
    80002cf2:	ec26                	sd	s1,24(sp)
    80002cf4:	e84a                	sd	s2,16(sp)
    80002cf6:	e44e                	sd	s3,8(sp)
    80002cf8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cfa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfe:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d02:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002d06:	1004f793          	andi	a5,s1,256
    80002d0a:	cb85                	beqz	a5,80002d3a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d10:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002d12:	ef85                	bnez	a5,80002d4a <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	dda080e7          	jalr	-550(ra) # 80002aee <devintr>
    80002d1c:	cd1d                	beqz	a0,80002d5a <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d1e:	4789                	li	a5,2
    80002d20:	06f50a63          	beq	a0,a5,80002d94 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d24:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d28:	10049073          	csrw	sstatus,s1
}
    80002d2c:	70a2                	ld	ra,40(sp)
    80002d2e:	7402                	ld	s0,32(sp)
    80002d30:	64e2                	ld	s1,24(sp)
    80002d32:	6942                	ld	s2,16(sp)
    80002d34:	69a2                	ld	s3,8(sp)
    80002d36:	6145                	addi	sp,sp,48
    80002d38:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d3a:	00005517          	auipc	a0,0x5
    80002d3e:	65650513          	addi	a0,a0,1622 # 80008390 <states.0+0xc8>
    80002d42:	ffffd097          	auipc	ra,0xffffd
    80002d46:	7fc080e7          	jalr	2044(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002d4a:	00005517          	auipc	a0,0x5
    80002d4e:	66e50513          	addi	a0,a0,1646 # 800083b8 <states.0+0xf0>
    80002d52:	ffffd097          	auipc	ra,0xffffd
    80002d56:	7ec080e7          	jalr	2028(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002d5a:	85ce                	mv	a1,s3
    80002d5c:	00005517          	auipc	a0,0x5
    80002d60:	67c50513          	addi	a0,a0,1660 # 800083d8 <states.0+0x110>
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	824080e7          	jalr	-2012(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d6c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d70:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d74:	00005517          	auipc	a0,0x5
    80002d78:	67450513          	addi	a0,a0,1652 # 800083e8 <states.0+0x120>
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	80c080e7          	jalr	-2036(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d84:	00005517          	auipc	a0,0x5
    80002d88:	67c50513          	addi	a0,a0,1660 # 80008400 <states.0+0x138>
    80002d8c:	ffffd097          	auipc	ra,0xffffd
    80002d90:	7b2080e7          	jalr	1970(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	dbc080e7          	jalr	-580(ra) # 80001b50 <myproc>
    80002d9c:	d541                	beqz	a0,80002d24 <kerneltrap+0x38>
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	db2080e7          	jalr	-590(ra) # 80001b50 <myproc>
    80002da6:	5558                	lw	a4,44(a0)
    80002da8:	4791                	li	a5,4
    80002daa:	f6f71de3          	bne	a4,a5,80002d24 <kerneltrap+0x38>
    yield();
    80002dae:	fffff097          	auipc	ra,0xfffff
    80002db2:	452080e7          	jalr	1106(ra) # 80002200 <yield>
    80002db6:	b7bd                	j	80002d24 <kerneltrap+0x38>

0000000080002db8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002db8:	1101                	addi	sp,sp,-32
    80002dba:	ec06                	sd	ra,24(sp)
    80002dbc:	e822                	sd	s0,16(sp)
    80002dbe:	e426                	sd	s1,8(sp)
    80002dc0:	1000                	addi	s0,sp,32
    80002dc2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	d8c080e7          	jalr	-628(ra) # 80001b50 <myproc>
  switch (n) {
    80002dcc:	4795                	li	a5,5
    80002dce:	0497e163          	bltu	a5,s1,80002e10 <argraw+0x58>
    80002dd2:	048a                	slli	s1,s1,0x2
    80002dd4:	00005717          	auipc	a4,0x5
    80002dd8:	66470713          	addi	a4,a4,1636 # 80008438 <states.0+0x170>
    80002ddc:	94ba                	add	s1,s1,a4
    80002dde:	409c                	lw	a5,0(s1)
    80002de0:	97ba                	add	a5,a5,a4
    80002de2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002de4:	753c                	ld	a5,104(a0)
    80002de6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002de8:	60e2                	ld	ra,24(sp)
    80002dea:	6442                	ld	s0,16(sp)
    80002dec:	64a2                	ld	s1,8(sp)
    80002dee:	6105                	addi	sp,sp,32
    80002df0:	8082                	ret
    return p->trapframe->a1;
    80002df2:	753c                	ld	a5,104(a0)
    80002df4:	7fa8                	ld	a0,120(a5)
    80002df6:	bfcd                	j	80002de8 <argraw+0x30>
    return p->trapframe->a2;
    80002df8:	753c                	ld	a5,104(a0)
    80002dfa:	63c8                	ld	a0,128(a5)
    80002dfc:	b7f5                	j	80002de8 <argraw+0x30>
    return p->trapframe->a3;
    80002dfe:	753c                	ld	a5,104(a0)
    80002e00:	67c8                	ld	a0,136(a5)
    80002e02:	b7dd                	j	80002de8 <argraw+0x30>
    return p->trapframe->a4;
    80002e04:	753c                	ld	a5,104(a0)
    80002e06:	6bc8                	ld	a0,144(a5)
    80002e08:	b7c5                	j	80002de8 <argraw+0x30>
    return p->trapframe->a5;
    80002e0a:	753c                	ld	a5,104(a0)
    80002e0c:	6fc8                	ld	a0,152(a5)
    80002e0e:	bfe9                	j	80002de8 <argraw+0x30>
  panic("argraw");
    80002e10:	00005517          	auipc	a0,0x5
    80002e14:	60050513          	addi	a0,a0,1536 # 80008410 <states.0+0x148>
    80002e18:	ffffd097          	auipc	ra,0xffffd
    80002e1c:	726080e7          	jalr	1830(ra) # 8000053e <panic>

0000000080002e20 <fetchaddr>:
{
    80002e20:	1101                	addi	sp,sp,-32
    80002e22:	ec06                	sd	ra,24(sp)
    80002e24:	e822                	sd	s0,16(sp)
    80002e26:	e426                	sd	s1,8(sp)
    80002e28:	e04a                	sd	s2,0(sp)
    80002e2a:	1000                	addi	s0,sp,32
    80002e2c:	84aa                	mv	s1,a0
    80002e2e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	d20080e7          	jalr	-736(ra) # 80001b50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e38:	6d3c                	ld	a5,88(a0)
    80002e3a:	02f4f863          	bgeu	s1,a5,80002e6a <fetchaddr+0x4a>
    80002e3e:	00848713          	addi	a4,s1,8
    80002e42:	02e7e663          	bltu	a5,a4,80002e6e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e46:	46a1                	li	a3,8
    80002e48:	8626                	mv	a2,s1
    80002e4a:	85ca                	mv	a1,s2
    80002e4c:	7128                	ld	a0,96(a0)
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	8ae080e7          	jalr	-1874(ra) # 800016fc <copyin>
    80002e56:	00a03533          	snez	a0,a0
    80002e5a:	40a00533          	neg	a0,a0
}
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	64a2                	ld	s1,8(sp)
    80002e64:	6902                	ld	s2,0(sp)
    80002e66:	6105                	addi	sp,sp,32
    80002e68:	8082                	ret
    return -1;
    80002e6a:	557d                	li	a0,-1
    80002e6c:	bfcd                	j	80002e5e <fetchaddr+0x3e>
    80002e6e:	557d                	li	a0,-1
    80002e70:	b7fd                	j	80002e5e <fetchaddr+0x3e>

0000000080002e72 <fetchstr>:
{
    80002e72:	7179                	addi	sp,sp,-48
    80002e74:	f406                	sd	ra,40(sp)
    80002e76:	f022                	sd	s0,32(sp)
    80002e78:	ec26                	sd	s1,24(sp)
    80002e7a:	e84a                	sd	s2,16(sp)
    80002e7c:	e44e                	sd	s3,8(sp)
    80002e7e:	1800                	addi	s0,sp,48
    80002e80:	892a                	mv	s2,a0
    80002e82:	84ae                	mv	s1,a1
    80002e84:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	cca080e7          	jalr	-822(ra) # 80001b50 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e8e:	86ce                	mv	a3,s3
    80002e90:	864a                	mv	a2,s2
    80002e92:	85a6                	mv	a1,s1
    80002e94:	7128                	ld	a0,96(a0)
    80002e96:	fffff097          	auipc	ra,0xfffff
    80002e9a:	8f4080e7          	jalr	-1804(ra) # 8000178a <copyinstr>
    80002e9e:	00054e63          	bltz	a0,80002eba <fetchstr+0x48>
  return strlen(buf);
    80002ea2:	8526                	mv	a0,s1
    80002ea4:	ffffe097          	auipc	ra,0xffffe
    80002ea8:	faa080e7          	jalr	-86(ra) # 80000e4e <strlen>
}
    80002eac:	70a2                	ld	ra,40(sp)
    80002eae:	7402                	ld	s0,32(sp)
    80002eb0:	64e2                	ld	s1,24(sp)
    80002eb2:	6942                	ld	s2,16(sp)
    80002eb4:	69a2                	ld	s3,8(sp)
    80002eb6:	6145                	addi	sp,sp,48
    80002eb8:	8082                	ret
    return -1;
    80002eba:	557d                	li	a0,-1
    80002ebc:	bfc5                	j	80002eac <fetchstr+0x3a>

0000000080002ebe <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ebe:	1101                	addi	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	e426                	sd	s1,8(sp)
    80002ec6:	1000                	addi	s0,sp,32
    80002ec8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eca:	00000097          	auipc	ra,0x0
    80002ece:	eee080e7          	jalr	-274(ra) # 80002db8 <argraw>
    80002ed2:	c088                	sw	a0,0(s1)
}
    80002ed4:	60e2                	ld	ra,24(sp)
    80002ed6:	6442                	ld	s0,16(sp)
    80002ed8:	64a2                	ld	s1,8(sp)
    80002eda:	6105                	addi	sp,sp,32
    80002edc:	8082                	ret

0000000080002ede <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ede:	1101                	addi	sp,sp,-32
    80002ee0:	ec06                	sd	ra,24(sp)
    80002ee2:	e822                	sd	s0,16(sp)
    80002ee4:	e426                	sd	s1,8(sp)
    80002ee6:	1000                	addi	s0,sp,32
    80002ee8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eea:	00000097          	auipc	ra,0x0
    80002eee:	ece080e7          	jalr	-306(ra) # 80002db8 <argraw>
    80002ef2:	e088                	sd	a0,0(s1)
}
    80002ef4:	60e2                	ld	ra,24(sp)
    80002ef6:	6442                	ld	s0,16(sp)
    80002ef8:	64a2                	ld	s1,8(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret

0000000080002efe <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002efe:	7179                	addi	sp,sp,-48
    80002f00:	f406                	sd	ra,40(sp)
    80002f02:	f022                	sd	s0,32(sp)
    80002f04:	ec26                	sd	s1,24(sp)
    80002f06:	e84a                	sd	s2,16(sp)
    80002f08:	1800                	addi	s0,sp,48
    80002f0a:	84ae                	mv	s1,a1
    80002f0c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f0e:	fd840593          	addi	a1,s0,-40
    80002f12:	00000097          	auipc	ra,0x0
    80002f16:	fcc080e7          	jalr	-52(ra) # 80002ede <argaddr>
  return fetchstr(addr, buf, max);
    80002f1a:	864a                	mv	a2,s2
    80002f1c:	85a6                	mv	a1,s1
    80002f1e:	fd843503          	ld	a0,-40(s0)
    80002f22:	00000097          	auipc	ra,0x0
    80002f26:	f50080e7          	jalr	-176(ra) # 80002e72 <fetchstr>
}
    80002f2a:	70a2                	ld	ra,40(sp)
    80002f2c:	7402                	ld	s0,32(sp)
    80002f2e:	64e2                	ld	s1,24(sp)
    80002f30:	6942                	ld	s2,16(sp)
    80002f32:	6145                	addi	sp,sp,48
    80002f34:	8082                	ret

0000000080002f36 <syscall>:

int readcallcount = 0;

void
syscall(void)
{
    80002f36:	1101                	addi	sp,sp,-32
    80002f38:	ec06                	sd	ra,24(sp)
    80002f3a:	e822                	sd	s0,16(sp)
    80002f3c:	e426                	sd	s1,8(sp)
    80002f3e:	e04a                	sd	s2,0(sp)
    80002f40:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f42:	fffff097          	auipc	ra,0xfffff
    80002f46:	c0e080e7          	jalr	-1010(ra) # 80001b50 <myproc>
    80002f4a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f4c:	06853903          	ld	s2,104(a0)
    80002f50:	0a893783          	ld	a5,168(s2)
    80002f54:	0007869b          	sext.w	a3,a5
  if(num == SYS_read)
    80002f58:	4715                	li	a4,5
    80002f5a:	04e68663          	beq	a3,a4,80002fa6 <syscall+0x70>
  {
    readcallcount += 1;
  }
  else if(num == SYS_getreadcount)
    80002f5e:	475d                	li	a4,23
    80002f60:	06e68963          	beq	a3,a4,80002fd2 <syscall+0x9c>
  {
    p->readcount = readcallcount;
  }
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f64:	37fd                	addiw	a5,a5,-1
    80002f66:	4761                	li	a4,24
    80002f68:	00f76b63          	bltu	a4,a5,80002f7e <syscall+0x48>
    80002f6c:	00369713          	slli	a4,a3,0x3
    80002f70:	00005797          	auipc	a5,0x5
    80002f74:	4e078793          	addi	a5,a5,1248 # 80008450 <syscalls>
    80002f78:	97ba                	add	a5,a5,a4
    80002f7a:	639c                	ld	a5,0(a5)
    80002f7c:	e7b9                	bnez	a5,80002fca <syscall+0x94>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f7e:	16848613          	addi	a2,s1,360
    80002f82:	40ac                	lw	a1,64(s1)
    80002f84:	00005517          	auipc	a0,0x5
    80002f88:	49450513          	addi	a0,a0,1172 # 80008418 <states.0+0x150>
    80002f8c:	ffffd097          	auipc	ra,0xffffd
    80002f90:	5fc080e7          	jalr	1532(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f94:	74bc                	ld	a5,104(s1)
    80002f96:	577d                	li	a4,-1
    80002f98:	fbb8                	sd	a4,112(a5)
  }
}
    80002f9a:	60e2                	ld	ra,24(sp)
    80002f9c:	6442                	ld	s0,16(sp)
    80002f9e:	64a2                	ld	s1,8(sp)
    80002fa0:	6902                	ld	s2,0(sp)
    80002fa2:	6105                	addi	sp,sp,32
    80002fa4:	8082                	ret
    readcallcount += 1;
    80002fa6:	00006617          	auipc	a2,0x6
    80002faa:	94e60613          	addi	a2,a2,-1714 # 800088f4 <readcallcount>
    80002fae:	4218                	lw	a4,0(a2)
    80002fb0:	2705                	addiw	a4,a4,1
    80002fb2:	c218                	sw	a4,0(a2)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002fb4:	37fd                	addiw	a5,a5,-1
    80002fb6:	4761                	li	a4,24
    80002fb8:	fcf763e3          	bltu	a4,a5,80002f7e <syscall+0x48>
    80002fbc:	068e                	slli	a3,a3,0x3
    80002fbe:	00005797          	auipc	a5,0x5
    80002fc2:	49278793          	addi	a5,a5,1170 # 80008450 <syscalls>
    80002fc6:	96be                	add	a3,a3,a5
    80002fc8:	629c                	ld	a5,0(a3)
    p->trapframe->a0 = syscalls[num]();
    80002fca:	9782                	jalr	a5
    80002fcc:	06a93823          	sd	a0,112(s2)
    80002fd0:	b7e9                	j	80002f9a <syscall+0x64>
    p->readcount = readcallcount;
    80002fd2:	00006717          	auipc	a4,0x6
    80002fd6:	92272703          	lw	a4,-1758(a4) # 800088f4 <readcallcount>
    80002fda:	18e52223          	sw	a4,388(a0)
    80002fde:	bfd9                	j	80002fb4 <syscall+0x7e>

0000000080002fe0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002fe0:	1101                	addi	sp,sp,-32
    80002fe2:	ec06                	sd	ra,24(sp)
    80002fe4:	e822                	sd	s0,16(sp)
    80002fe6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002fe8:	fec40593          	addi	a1,s0,-20
    80002fec:	4501                	li	a0,0
    80002fee:	00000097          	auipc	ra,0x0
    80002ff2:	ed0080e7          	jalr	-304(ra) # 80002ebe <argint>
  exit(n);
    80002ff6:	fec42503          	lw	a0,-20(s0)
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	376080e7          	jalr	886(ra) # 80002370 <exit>
  return 0; // not reached
}
    80003002:	4501                	li	a0,0
    80003004:	60e2                	ld	ra,24(sp)
    80003006:	6442                	ld	s0,16(sp)
    80003008:	6105                	addi	sp,sp,32
    8000300a:	8082                	ret

000000008000300c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000300c:	1141                	addi	sp,sp,-16
    8000300e:	e406                	sd	ra,8(sp)
    80003010:	e022                	sd	s0,0(sp)
    80003012:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	b3c080e7          	jalr	-1220(ra) # 80001b50 <myproc>
}
    8000301c:	4128                	lw	a0,64(a0)
    8000301e:	60a2                	ld	ra,8(sp)
    80003020:	6402                	ld	s0,0(sp)
    80003022:	0141                	addi	sp,sp,16
    80003024:	8082                	ret

0000000080003026 <sys_fork>:

uint64
sys_fork(void)
{
    80003026:	1141                	addi	sp,sp,-16
    80003028:	e406                	sd	ra,8(sp)
    8000302a:	e022                	sd	s0,0(sp)
    8000302c:	0800                	addi	s0,sp,16
  return fork();
    8000302e:	fffff097          	auipc	ra,0xfffff
    80003032:	f1c080e7          	jalr	-228(ra) # 80001f4a <fork>
}
    80003036:	60a2                	ld	ra,8(sp)
    80003038:	6402                	ld	s0,0(sp)
    8000303a:	0141                	addi	sp,sp,16
    8000303c:	8082                	ret

000000008000303e <sys_wait>:

uint64
sys_wait(void)
{
    8000303e:	1101                	addi	sp,sp,-32
    80003040:	ec06                	sd	ra,24(sp)
    80003042:	e822                	sd	s0,16(sp)
    80003044:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003046:	fe840593          	addi	a1,s0,-24
    8000304a:	4501                	li	a0,0
    8000304c:	00000097          	auipc	ra,0x0
    80003050:	e92080e7          	jalr	-366(ra) # 80002ede <argaddr>
  return wait(p);
    80003054:	fe843503          	ld	a0,-24(s0)
    80003058:	fffff097          	auipc	ra,0xfffff
    8000305c:	4ca080e7          	jalr	1226(ra) # 80002522 <wait>
}
    80003060:	60e2                	ld	ra,24(sp)
    80003062:	6442                	ld	s0,16(sp)
    80003064:	6105                	addi	sp,sp,32
    80003066:	8082                	ret

0000000080003068 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003068:	7179                	addi	sp,sp,-48
    8000306a:	f406                	sd	ra,40(sp)
    8000306c:	f022                	sd	s0,32(sp)
    8000306e:	ec26                	sd	s1,24(sp)
    80003070:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003072:	fdc40593          	addi	a1,s0,-36
    80003076:	4501                	li	a0,0
    80003078:	00000097          	auipc	ra,0x0
    8000307c:	e46080e7          	jalr	-442(ra) # 80002ebe <argint>
  addr = myproc()->sz;
    80003080:	fffff097          	auipc	ra,0xfffff
    80003084:	ad0080e7          	jalr	-1328(ra) # 80001b50 <myproc>
    80003088:	6d24                	ld	s1,88(a0)
  if (growproc(n) < 0)
    8000308a:	fdc42503          	lw	a0,-36(s0)
    8000308e:	fffff097          	auipc	ra,0xfffff
    80003092:	e60080e7          	jalr	-416(ra) # 80001eee <growproc>
    80003096:	00054863          	bltz	a0,800030a6 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000309a:	8526                	mv	a0,s1
    8000309c:	70a2                	ld	ra,40(sp)
    8000309e:	7402                	ld	s0,32(sp)
    800030a0:	64e2                	ld	s1,24(sp)
    800030a2:	6145                	addi	sp,sp,48
    800030a4:	8082                	ret
    return -1;
    800030a6:	54fd                	li	s1,-1
    800030a8:	bfcd                	j	8000309a <sys_sbrk+0x32>

00000000800030aa <sys_sleep>:

uint64
sys_sleep(void)
{
    800030aa:	7139                	addi	sp,sp,-64
    800030ac:	fc06                	sd	ra,56(sp)
    800030ae:	f822                	sd	s0,48(sp)
    800030b0:	f426                	sd	s1,40(sp)
    800030b2:	f04a                	sd	s2,32(sp)
    800030b4:	ec4e                	sd	s3,24(sp)
    800030b6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800030b8:	fcc40593          	addi	a1,s0,-52
    800030bc:	4501                	li	a0,0
    800030be:	00000097          	auipc	ra,0x0
    800030c2:	e00080e7          	jalr	-512(ra) # 80002ebe <argint>
  acquire(&tickslock);
    800030c6:	00015517          	auipc	a0,0x15
    800030ca:	eea50513          	addi	a0,a0,-278 # 80017fb0 <tickslock>
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	b08080e7          	jalr	-1272(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800030d6:	00006917          	auipc	s2,0x6
    800030da:	81a92903          	lw	s2,-2022(s2) # 800088f0 <ticks>
  while (ticks - ticks0 < n)
    800030de:	fcc42783          	lw	a5,-52(s0)
    800030e2:	cf9d                	beqz	a5,80003120 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800030e4:	00015997          	auipc	s3,0x15
    800030e8:	ecc98993          	addi	s3,s3,-308 # 80017fb0 <tickslock>
    800030ec:	00006497          	auipc	s1,0x6
    800030f0:	80448493          	addi	s1,s1,-2044 # 800088f0 <ticks>
    if (killed(myproc()))
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	a5c080e7          	jalr	-1444(ra) # 80001b50 <myproc>
    800030fc:	fffff097          	auipc	ra,0xfffff
    80003100:	3f4080e7          	jalr	1012(ra) # 800024f0 <killed>
    80003104:	ed15                	bnez	a0,80003140 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003106:	85ce                	mv	a1,s3
    80003108:	8526                	mv	a0,s1
    8000310a:	fffff097          	auipc	ra,0xfffff
    8000310e:	132080e7          	jalr	306(ra) # 8000223c <sleep>
  while (ticks - ticks0 < n)
    80003112:	409c                	lw	a5,0(s1)
    80003114:	412787bb          	subw	a5,a5,s2
    80003118:	fcc42703          	lw	a4,-52(s0)
    8000311c:	fce7ece3          	bltu	a5,a4,800030f4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003120:	00015517          	auipc	a0,0x15
    80003124:	e9050513          	addi	a0,a0,-368 # 80017fb0 <tickslock>
    80003128:	ffffe097          	auipc	ra,0xffffe
    8000312c:	b62080e7          	jalr	-1182(ra) # 80000c8a <release>
  return 0;
    80003130:	4501                	li	a0,0
}
    80003132:	70e2                	ld	ra,56(sp)
    80003134:	7442                	ld	s0,48(sp)
    80003136:	74a2                	ld	s1,40(sp)
    80003138:	7902                	ld	s2,32(sp)
    8000313a:	69e2                	ld	s3,24(sp)
    8000313c:	6121                	addi	sp,sp,64
    8000313e:	8082                	ret
      release(&tickslock);
    80003140:	00015517          	auipc	a0,0x15
    80003144:	e7050513          	addi	a0,a0,-400 # 80017fb0 <tickslock>
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	b42080e7          	jalr	-1214(ra) # 80000c8a <release>
      return -1;
    80003150:	557d                	li	a0,-1
    80003152:	b7c5                	j	80003132 <sys_sleep+0x88>

0000000080003154 <sys_kill>:

uint64
sys_kill(void)
{
    80003154:	1101                	addi	sp,sp,-32
    80003156:	ec06                	sd	ra,24(sp)
    80003158:	e822                	sd	s0,16(sp)
    8000315a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000315c:	fec40593          	addi	a1,s0,-20
    80003160:	4501                	li	a0,0
    80003162:	00000097          	auipc	ra,0x0
    80003166:	d5c080e7          	jalr	-676(ra) # 80002ebe <argint>
  return kill(pid);
    8000316a:	fec42503          	lw	a0,-20(s0)
    8000316e:	fffff097          	auipc	ra,0xfffff
    80003172:	2e4080e7          	jalr	740(ra) # 80002452 <kill>
}
    80003176:	60e2                	ld	ra,24(sp)
    80003178:	6442                	ld	s0,16(sp)
    8000317a:	6105                	addi	sp,sp,32
    8000317c:	8082                	ret

000000008000317e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000317e:	1101                	addi	sp,sp,-32
    80003180:	ec06                	sd	ra,24(sp)
    80003182:	e822                	sd	s0,16(sp)
    80003184:	e426                	sd	s1,8(sp)
    80003186:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003188:	00015517          	auipc	a0,0x15
    8000318c:	e2850513          	addi	a0,a0,-472 # 80017fb0 <tickslock>
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	a46080e7          	jalr	-1466(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003198:	00005497          	auipc	s1,0x5
    8000319c:	7584a483          	lw	s1,1880(s1) # 800088f0 <ticks>
  release(&tickslock);
    800031a0:	00015517          	auipc	a0,0x15
    800031a4:	e1050513          	addi	a0,a0,-496 # 80017fb0 <tickslock>
    800031a8:	ffffe097          	auipc	ra,0xffffe
    800031ac:	ae2080e7          	jalr	-1310(ra) # 80000c8a <release>
  return xticks;
}
    800031b0:	02049513          	slli	a0,s1,0x20
    800031b4:	9101                	srli	a0,a0,0x20
    800031b6:	60e2                	ld	ra,24(sp)
    800031b8:	6442                	ld	s0,16(sp)
    800031ba:	64a2                	ld	s1,8(sp)
    800031bc:	6105                	addi	sp,sp,32
    800031be:	8082                	ret

00000000800031c0 <sys_waitx>:

uint64
sys_waitx(void)
{
    800031c0:	7139                	addi	sp,sp,-64
    800031c2:	fc06                	sd	ra,56(sp)
    800031c4:	f822                	sd	s0,48(sp)
    800031c6:	f426                	sd	s1,40(sp)
    800031c8:	f04a                	sd	s2,32(sp)
    800031ca:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800031cc:	fd840593          	addi	a1,s0,-40
    800031d0:	4501                	li	a0,0
    800031d2:	00000097          	auipc	ra,0x0
    800031d6:	d0c080e7          	jalr	-756(ra) # 80002ede <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800031da:	fd040593          	addi	a1,s0,-48
    800031de:	4505                	li	a0,1
    800031e0:	00000097          	auipc	ra,0x0
    800031e4:	cfe080e7          	jalr	-770(ra) # 80002ede <argaddr>
  argaddr(2, &addr2);
    800031e8:	fc840593          	addi	a1,s0,-56
    800031ec:	4509                	li	a0,2
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	cf0080e7          	jalr	-784(ra) # 80002ede <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800031f6:	fc040613          	addi	a2,s0,-64
    800031fa:	fc440593          	addi	a1,s0,-60
    800031fe:	fd843503          	ld	a0,-40(s0)
    80003202:	fffff097          	auipc	ra,0xfffff
    80003206:	5a8080e7          	jalr	1448(ra) # 800027aa <waitx>
    8000320a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000320c:	fffff097          	auipc	ra,0xfffff
    80003210:	944080e7          	jalr	-1724(ra) # 80001b50 <myproc>
    80003214:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003216:	4691                	li	a3,4
    80003218:	fc440613          	addi	a2,s0,-60
    8000321c:	fd043583          	ld	a1,-48(s0)
    80003220:	7128                	ld	a0,96(a0)
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	44e080e7          	jalr	1102(ra) # 80001670 <copyout>
    return -1;
    8000322a:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000322c:	00054f63          	bltz	a0,8000324a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003230:	4691                	li	a3,4
    80003232:	fc040613          	addi	a2,s0,-64
    80003236:	fc843583          	ld	a1,-56(s0)
    8000323a:	70a8                	ld	a0,96(s1)
    8000323c:	ffffe097          	auipc	ra,0xffffe
    80003240:	434080e7          	jalr	1076(ra) # 80001670 <copyout>
    80003244:	00054a63          	bltz	a0,80003258 <sys_waitx+0x98>
    return -1;
  return ret;
    80003248:	87ca                	mv	a5,s2
}
    8000324a:	853e                	mv	a0,a5
    8000324c:	70e2                	ld	ra,56(sp)
    8000324e:	7442                	ld	s0,48(sp)
    80003250:	74a2                	ld	s1,40(sp)
    80003252:	7902                	ld	s2,32(sp)
    80003254:	6121                	addi	sp,sp,64
    80003256:	8082                	ret
    return -1;
    80003258:	57fd                	li	a5,-1
    8000325a:	bfc5                	j	8000324a <sys_waitx+0x8a>

000000008000325c <sys_getreadcount>:

// getreadcount()

uint64
sys_getreadcount(void)
{
    8000325c:	1141                	addi	sp,sp,-16
    8000325e:	e406                	sd	ra,8(sp)
    80003260:	e022                	sd	s0,0(sp)
    80003262:	0800                	addi	s0,sp,16
  return myproc()->readcount;
    80003264:	fffff097          	auipc	ra,0xfffff
    80003268:	8ec080e7          	jalr	-1812(ra) # 80001b50 <myproc>
}
    8000326c:	18452503          	lw	a0,388(a0)
    80003270:	60a2                	ld	ra,8(sp)
    80003272:	6402                	ld	s0,0(sp)
    80003274:	0141                	addi	sp,sp,16
    80003276:	8082                	ret

0000000080003278 <sys_sigalarm>:

// sigalarm()

uint64
sys_sigalarm(void)
{
    80003278:	1101                	addi	sp,sp,-32
    8000327a:	ec06                	sd	ra,24(sp)
    8000327c:	e822                	sd	s0,16(sp)
    8000327e:	1000                	addi	s0,sp,32
  uint64 handler2;
  argaddr(1,&handler2);
    80003280:	fe840593          	addi	a1,s0,-24
    80003284:	4505                	li	a0,1
    80003286:	00000097          	auipc	ra,0x0
    8000328a:	c58080e7          	jalr	-936(ra) # 80002ede <argaddr>

  int interval;
  argint(0,&interval);
    8000328e:	fe440593          	addi	a1,s0,-28
    80003292:	4501                	li	a0,0
    80003294:	00000097          	auipc	ra,0x0
    80003298:	c2a080e7          	jalr	-982(ra) # 80002ebe <argint>

  struct proc* p = myproc();
    8000329c:	fffff097          	auipc	ra,0xfffff
    800032a0:	8b4080e7          	jalr	-1868(ra) # 80001b50 <myproc>

  p->interval=interval;
    800032a4:	fe442783          	lw	a5,-28(s0)
    800032a8:	18f52623          	sw	a5,396(a0)
  p->handler=handler2;
    800032ac:	fe843783          	ld	a5,-24(s0)
    800032b0:	18f52423          	sw	a5,392(a0)

  return 0;
}
    800032b4:	4501                	li	a0,0
    800032b6:	60e2                	ld	ra,24(sp)
    800032b8:	6442                	ld	s0,16(sp)
    800032ba:	6105                	addi	sp,sp,32
    800032bc:	8082                	ret

00000000800032be <sys_sigreturn>:

// sigreturn()

uint64
sys_sigreturn(void)
{
    800032be:	1101                	addi	sp,sp,-32
    800032c0:	ec06                	sd	ra,24(sp)
    800032c2:	e822                	sd	s0,16(sp)
    800032c4:	e426                	sd	s1,8(sp)
    800032c6:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    800032c8:	fffff097          	auipc	ra,0xfffff
    800032cc:	888080e7          	jalr	-1912(ra) # 80001b50 <myproc>
    800032d0:	84aa                	mv	s1,a0

  memmove(p->trapframe,p->trapframealarm,PGSIZE);
    800032d2:	6605                	lui	a2,0x1
    800032d4:	19853583          	ld	a1,408(a0)
    800032d8:	7528                	ld	a0,104(a0)
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	a54080e7          	jalr	-1452(ra) # 80000d2e <memmove>
  kfree(p->trapframealarm);
    800032e2:	1984b503          	ld	a0,408(s1)
    800032e6:	ffffd097          	auipc	ra,0xffffd
    800032ea:	704080e7          	jalr	1796(ra) # 800009ea <kfree>

  p->tickscurrently=0;
    800032ee:	1804a823          	sw	zero,400(s1)
  p->signalstatus=0;
    800032f2:	1804aa23          	sw	zero,404(s1)
  p->trapframealarm=0;
    800032f6:	1804bc23          	sd	zero,408(s1)

  usertrapret();
    800032fa:	fffff097          	auipc	ra,0xfffff
    800032fe:	70a080e7          	jalr	1802(ra) # 80002a04 <usertrapret>
  return 0;
    80003302:	4501                	li	a0,0
    80003304:	60e2                	ld	ra,24(sp)
    80003306:	6442                	ld	s0,16(sp)
    80003308:	64a2                	ld	s1,8(sp)
    8000330a:	6105                	addi	sp,sp,32
    8000330c:	8082                	ret

000000008000330e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000330e:	7179                	addi	sp,sp,-48
    80003310:	f406                	sd	ra,40(sp)
    80003312:	f022                	sd	s0,32(sp)
    80003314:	ec26                	sd	s1,24(sp)
    80003316:	e84a                	sd	s2,16(sp)
    80003318:	e44e                	sd	s3,8(sp)
    8000331a:	e052                	sd	s4,0(sp)
    8000331c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000331e:	00005597          	auipc	a1,0x5
    80003322:	20258593          	addi	a1,a1,514 # 80008520 <syscalls+0xd0>
    80003326:	00015517          	auipc	a0,0x15
    8000332a:	ca250513          	addi	a0,a0,-862 # 80017fc8 <bcache>
    8000332e:	ffffe097          	auipc	ra,0xffffe
    80003332:	818080e7          	jalr	-2024(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003336:	0001d797          	auipc	a5,0x1d
    8000333a:	c9278793          	addi	a5,a5,-878 # 8001ffc8 <bcache+0x8000>
    8000333e:	0001d717          	auipc	a4,0x1d
    80003342:	ef270713          	addi	a4,a4,-270 # 80020230 <bcache+0x8268>
    80003346:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000334a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000334e:	00015497          	auipc	s1,0x15
    80003352:	c9248493          	addi	s1,s1,-878 # 80017fe0 <bcache+0x18>
    b->next = bcache.head.next;
    80003356:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003358:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000335a:	00005a17          	auipc	s4,0x5
    8000335e:	1cea0a13          	addi	s4,s4,462 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    80003362:	2b893783          	ld	a5,696(s2)
    80003366:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003368:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000336c:	85d2                	mv	a1,s4
    8000336e:	01048513          	addi	a0,s1,16
    80003372:	00001097          	auipc	ra,0x1
    80003376:	4c4080e7          	jalr	1220(ra) # 80004836 <initsleeplock>
    bcache.head.next->prev = b;
    8000337a:	2b893783          	ld	a5,696(s2)
    8000337e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003380:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003384:	45848493          	addi	s1,s1,1112
    80003388:	fd349de3          	bne	s1,s3,80003362 <binit+0x54>
  }
}
    8000338c:	70a2                	ld	ra,40(sp)
    8000338e:	7402                	ld	s0,32(sp)
    80003390:	64e2                	ld	s1,24(sp)
    80003392:	6942                	ld	s2,16(sp)
    80003394:	69a2                	ld	s3,8(sp)
    80003396:	6a02                	ld	s4,0(sp)
    80003398:	6145                	addi	sp,sp,48
    8000339a:	8082                	ret

000000008000339c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000339c:	7179                	addi	sp,sp,-48
    8000339e:	f406                	sd	ra,40(sp)
    800033a0:	f022                	sd	s0,32(sp)
    800033a2:	ec26                	sd	s1,24(sp)
    800033a4:	e84a                	sd	s2,16(sp)
    800033a6:	e44e                	sd	s3,8(sp)
    800033a8:	1800                	addi	s0,sp,48
    800033aa:	892a                	mv	s2,a0
    800033ac:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033ae:	00015517          	auipc	a0,0x15
    800033b2:	c1a50513          	addi	a0,a0,-998 # 80017fc8 <bcache>
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	820080e7          	jalr	-2016(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033be:	0001d497          	auipc	s1,0x1d
    800033c2:	ec24b483          	ld	s1,-318(s1) # 80020280 <bcache+0x82b8>
    800033c6:	0001d797          	auipc	a5,0x1d
    800033ca:	e6a78793          	addi	a5,a5,-406 # 80020230 <bcache+0x8268>
    800033ce:	02f48f63          	beq	s1,a5,8000340c <bread+0x70>
    800033d2:	873e                	mv	a4,a5
    800033d4:	a021                	j	800033dc <bread+0x40>
    800033d6:	68a4                	ld	s1,80(s1)
    800033d8:	02e48a63          	beq	s1,a4,8000340c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800033dc:	449c                	lw	a5,8(s1)
    800033de:	ff279ce3          	bne	a5,s2,800033d6 <bread+0x3a>
    800033e2:	44dc                	lw	a5,12(s1)
    800033e4:	ff3799e3          	bne	a5,s3,800033d6 <bread+0x3a>
      b->refcnt++;
    800033e8:	40bc                	lw	a5,64(s1)
    800033ea:	2785                	addiw	a5,a5,1
    800033ec:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033ee:	00015517          	auipc	a0,0x15
    800033f2:	bda50513          	addi	a0,a0,-1062 # 80017fc8 <bcache>
    800033f6:	ffffe097          	auipc	ra,0xffffe
    800033fa:	894080e7          	jalr	-1900(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800033fe:	01048513          	addi	a0,s1,16
    80003402:	00001097          	auipc	ra,0x1
    80003406:	46e080e7          	jalr	1134(ra) # 80004870 <acquiresleep>
      return b;
    8000340a:	a8b9                	j	80003468 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000340c:	0001d497          	auipc	s1,0x1d
    80003410:	e6c4b483          	ld	s1,-404(s1) # 80020278 <bcache+0x82b0>
    80003414:	0001d797          	auipc	a5,0x1d
    80003418:	e1c78793          	addi	a5,a5,-484 # 80020230 <bcache+0x8268>
    8000341c:	00f48863          	beq	s1,a5,8000342c <bread+0x90>
    80003420:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003422:	40bc                	lw	a5,64(s1)
    80003424:	cf81                	beqz	a5,8000343c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003426:	64a4                	ld	s1,72(s1)
    80003428:	fee49de3          	bne	s1,a4,80003422 <bread+0x86>
  panic("bget: no buffers");
    8000342c:	00005517          	auipc	a0,0x5
    80003430:	10450513          	addi	a0,a0,260 # 80008530 <syscalls+0xe0>
    80003434:	ffffd097          	auipc	ra,0xffffd
    80003438:	10a080e7          	jalr	266(ra) # 8000053e <panic>
      b->dev = dev;
    8000343c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003440:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003444:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003448:	4785                	li	a5,1
    8000344a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000344c:	00015517          	auipc	a0,0x15
    80003450:	b7c50513          	addi	a0,a0,-1156 # 80017fc8 <bcache>
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	836080e7          	jalr	-1994(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000345c:	01048513          	addi	a0,s1,16
    80003460:	00001097          	auipc	ra,0x1
    80003464:	410080e7          	jalr	1040(ra) # 80004870 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003468:	409c                	lw	a5,0(s1)
    8000346a:	cb89                	beqz	a5,8000347c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000346c:	8526                	mv	a0,s1
    8000346e:	70a2                	ld	ra,40(sp)
    80003470:	7402                	ld	s0,32(sp)
    80003472:	64e2                	ld	s1,24(sp)
    80003474:	6942                	ld	s2,16(sp)
    80003476:	69a2                	ld	s3,8(sp)
    80003478:	6145                	addi	sp,sp,48
    8000347a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000347c:	4581                	li	a1,0
    8000347e:	8526                	mv	a0,s1
    80003480:	00003097          	auipc	ra,0x3
    80003484:	fd4080e7          	jalr	-44(ra) # 80006454 <virtio_disk_rw>
    b->valid = 1;
    80003488:	4785                	li	a5,1
    8000348a:	c09c                	sw	a5,0(s1)
  return b;
    8000348c:	b7c5                	j	8000346c <bread+0xd0>

000000008000348e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000348e:	1101                	addi	sp,sp,-32
    80003490:	ec06                	sd	ra,24(sp)
    80003492:	e822                	sd	s0,16(sp)
    80003494:	e426                	sd	s1,8(sp)
    80003496:	1000                	addi	s0,sp,32
    80003498:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000349a:	0541                	addi	a0,a0,16
    8000349c:	00001097          	auipc	ra,0x1
    800034a0:	46e080e7          	jalr	1134(ra) # 8000490a <holdingsleep>
    800034a4:	cd01                	beqz	a0,800034bc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034a6:	4585                	li	a1,1
    800034a8:	8526                	mv	a0,s1
    800034aa:	00003097          	auipc	ra,0x3
    800034ae:	faa080e7          	jalr	-86(ra) # 80006454 <virtio_disk_rw>
}
    800034b2:	60e2                	ld	ra,24(sp)
    800034b4:	6442                	ld	s0,16(sp)
    800034b6:	64a2                	ld	s1,8(sp)
    800034b8:	6105                	addi	sp,sp,32
    800034ba:	8082                	ret
    panic("bwrite");
    800034bc:	00005517          	auipc	a0,0x5
    800034c0:	08c50513          	addi	a0,a0,140 # 80008548 <syscalls+0xf8>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	07a080e7          	jalr	122(ra) # 8000053e <panic>

00000000800034cc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034cc:	1101                	addi	sp,sp,-32
    800034ce:	ec06                	sd	ra,24(sp)
    800034d0:	e822                	sd	s0,16(sp)
    800034d2:	e426                	sd	s1,8(sp)
    800034d4:	e04a                	sd	s2,0(sp)
    800034d6:	1000                	addi	s0,sp,32
    800034d8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034da:	01050913          	addi	s2,a0,16
    800034de:	854a                	mv	a0,s2
    800034e0:	00001097          	auipc	ra,0x1
    800034e4:	42a080e7          	jalr	1066(ra) # 8000490a <holdingsleep>
    800034e8:	c92d                	beqz	a0,8000355a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800034ea:	854a                	mv	a0,s2
    800034ec:	00001097          	auipc	ra,0x1
    800034f0:	3da080e7          	jalr	986(ra) # 800048c6 <releasesleep>

  acquire(&bcache.lock);
    800034f4:	00015517          	auipc	a0,0x15
    800034f8:	ad450513          	addi	a0,a0,-1324 # 80017fc8 <bcache>
    800034fc:	ffffd097          	auipc	ra,0xffffd
    80003500:	6da080e7          	jalr	1754(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003504:	40bc                	lw	a5,64(s1)
    80003506:	37fd                	addiw	a5,a5,-1
    80003508:	0007871b          	sext.w	a4,a5
    8000350c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000350e:	eb05                	bnez	a4,8000353e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003510:	68bc                	ld	a5,80(s1)
    80003512:	64b8                	ld	a4,72(s1)
    80003514:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003516:	64bc                	ld	a5,72(s1)
    80003518:	68b8                	ld	a4,80(s1)
    8000351a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000351c:	0001d797          	auipc	a5,0x1d
    80003520:	aac78793          	addi	a5,a5,-1364 # 8001ffc8 <bcache+0x8000>
    80003524:	2b87b703          	ld	a4,696(a5)
    80003528:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000352a:	0001d717          	auipc	a4,0x1d
    8000352e:	d0670713          	addi	a4,a4,-762 # 80020230 <bcache+0x8268>
    80003532:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003534:	2b87b703          	ld	a4,696(a5)
    80003538:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000353a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000353e:	00015517          	auipc	a0,0x15
    80003542:	a8a50513          	addi	a0,a0,-1398 # 80017fc8 <bcache>
    80003546:	ffffd097          	auipc	ra,0xffffd
    8000354a:	744080e7          	jalr	1860(ra) # 80000c8a <release>
}
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	64a2                	ld	s1,8(sp)
    80003554:	6902                	ld	s2,0(sp)
    80003556:	6105                	addi	sp,sp,32
    80003558:	8082                	ret
    panic("brelse");
    8000355a:	00005517          	auipc	a0,0x5
    8000355e:	ff650513          	addi	a0,a0,-10 # 80008550 <syscalls+0x100>
    80003562:	ffffd097          	auipc	ra,0xffffd
    80003566:	fdc080e7          	jalr	-36(ra) # 8000053e <panic>

000000008000356a <bpin>:

void
bpin(struct buf *b) {
    8000356a:	1101                	addi	sp,sp,-32
    8000356c:	ec06                	sd	ra,24(sp)
    8000356e:	e822                	sd	s0,16(sp)
    80003570:	e426                	sd	s1,8(sp)
    80003572:	1000                	addi	s0,sp,32
    80003574:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003576:	00015517          	auipc	a0,0x15
    8000357a:	a5250513          	addi	a0,a0,-1454 # 80017fc8 <bcache>
    8000357e:	ffffd097          	auipc	ra,0xffffd
    80003582:	658080e7          	jalr	1624(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003586:	40bc                	lw	a5,64(s1)
    80003588:	2785                	addiw	a5,a5,1
    8000358a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000358c:	00015517          	auipc	a0,0x15
    80003590:	a3c50513          	addi	a0,a0,-1476 # 80017fc8 <bcache>
    80003594:	ffffd097          	auipc	ra,0xffffd
    80003598:	6f6080e7          	jalr	1782(ra) # 80000c8a <release>
}
    8000359c:	60e2                	ld	ra,24(sp)
    8000359e:	6442                	ld	s0,16(sp)
    800035a0:	64a2                	ld	s1,8(sp)
    800035a2:	6105                	addi	sp,sp,32
    800035a4:	8082                	ret

00000000800035a6 <bunpin>:

void
bunpin(struct buf *b) {
    800035a6:	1101                	addi	sp,sp,-32
    800035a8:	ec06                	sd	ra,24(sp)
    800035aa:	e822                	sd	s0,16(sp)
    800035ac:	e426                	sd	s1,8(sp)
    800035ae:	1000                	addi	s0,sp,32
    800035b0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035b2:	00015517          	auipc	a0,0x15
    800035b6:	a1650513          	addi	a0,a0,-1514 # 80017fc8 <bcache>
    800035ba:	ffffd097          	auipc	ra,0xffffd
    800035be:	61c080e7          	jalr	1564(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800035c2:	40bc                	lw	a5,64(s1)
    800035c4:	37fd                	addiw	a5,a5,-1
    800035c6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035c8:	00015517          	auipc	a0,0x15
    800035cc:	a0050513          	addi	a0,a0,-1536 # 80017fc8 <bcache>
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	6ba080e7          	jalr	1722(ra) # 80000c8a <release>
}
    800035d8:	60e2                	ld	ra,24(sp)
    800035da:	6442                	ld	s0,16(sp)
    800035dc:	64a2                	ld	s1,8(sp)
    800035de:	6105                	addi	sp,sp,32
    800035e0:	8082                	ret

00000000800035e2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035e2:	1101                	addi	sp,sp,-32
    800035e4:	ec06                	sd	ra,24(sp)
    800035e6:	e822                	sd	s0,16(sp)
    800035e8:	e426                	sd	s1,8(sp)
    800035ea:	e04a                	sd	s2,0(sp)
    800035ec:	1000                	addi	s0,sp,32
    800035ee:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035f0:	00d5d59b          	srliw	a1,a1,0xd
    800035f4:	0001d797          	auipc	a5,0x1d
    800035f8:	0b07a783          	lw	a5,176(a5) # 800206a4 <sb+0x1c>
    800035fc:	9dbd                	addw	a1,a1,a5
    800035fe:	00000097          	auipc	ra,0x0
    80003602:	d9e080e7          	jalr	-610(ra) # 8000339c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003606:	0074f713          	andi	a4,s1,7
    8000360a:	4785                	li	a5,1
    8000360c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003610:	14ce                	slli	s1,s1,0x33
    80003612:	90d9                	srli	s1,s1,0x36
    80003614:	00950733          	add	a4,a0,s1
    80003618:	05874703          	lbu	a4,88(a4)
    8000361c:	00e7f6b3          	and	a3,a5,a4
    80003620:	c69d                	beqz	a3,8000364e <bfree+0x6c>
    80003622:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003624:	94aa                	add	s1,s1,a0
    80003626:	fff7c793          	not	a5,a5
    8000362a:	8ff9                	and	a5,a5,a4
    8000362c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003630:	00001097          	auipc	ra,0x1
    80003634:	120080e7          	jalr	288(ra) # 80004750 <log_write>
  brelse(bp);
    80003638:	854a                	mv	a0,s2
    8000363a:	00000097          	auipc	ra,0x0
    8000363e:	e92080e7          	jalr	-366(ra) # 800034cc <brelse>
}
    80003642:	60e2                	ld	ra,24(sp)
    80003644:	6442                	ld	s0,16(sp)
    80003646:	64a2                	ld	s1,8(sp)
    80003648:	6902                	ld	s2,0(sp)
    8000364a:	6105                	addi	sp,sp,32
    8000364c:	8082                	ret
    panic("freeing free block");
    8000364e:	00005517          	auipc	a0,0x5
    80003652:	f0a50513          	addi	a0,a0,-246 # 80008558 <syscalls+0x108>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	ee8080e7          	jalr	-280(ra) # 8000053e <panic>

000000008000365e <balloc>:
{
    8000365e:	711d                	addi	sp,sp,-96
    80003660:	ec86                	sd	ra,88(sp)
    80003662:	e8a2                	sd	s0,80(sp)
    80003664:	e4a6                	sd	s1,72(sp)
    80003666:	e0ca                	sd	s2,64(sp)
    80003668:	fc4e                	sd	s3,56(sp)
    8000366a:	f852                	sd	s4,48(sp)
    8000366c:	f456                	sd	s5,40(sp)
    8000366e:	f05a                	sd	s6,32(sp)
    80003670:	ec5e                	sd	s7,24(sp)
    80003672:	e862                	sd	s8,16(sp)
    80003674:	e466                	sd	s9,8(sp)
    80003676:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003678:	0001d797          	auipc	a5,0x1d
    8000367c:	0147a783          	lw	a5,20(a5) # 8002068c <sb+0x4>
    80003680:	10078163          	beqz	a5,80003782 <balloc+0x124>
    80003684:	8baa                	mv	s7,a0
    80003686:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003688:	0001db17          	auipc	s6,0x1d
    8000368c:	000b0b13          	mv	s6,s6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003690:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003692:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003694:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003696:	6c89                	lui	s9,0x2
    80003698:	a061                	j	80003720 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000369a:	974a                	add	a4,a4,s2
    8000369c:	8fd5                	or	a5,a5,a3
    8000369e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800036a2:	854a                	mv	a0,s2
    800036a4:	00001097          	auipc	ra,0x1
    800036a8:	0ac080e7          	jalr	172(ra) # 80004750 <log_write>
        brelse(bp);
    800036ac:	854a                	mv	a0,s2
    800036ae:	00000097          	auipc	ra,0x0
    800036b2:	e1e080e7          	jalr	-482(ra) # 800034cc <brelse>
  bp = bread(dev, bno);
    800036b6:	85a6                	mv	a1,s1
    800036b8:	855e                	mv	a0,s7
    800036ba:	00000097          	auipc	ra,0x0
    800036be:	ce2080e7          	jalr	-798(ra) # 8000339c <bread>
    800036c2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036c4:	40000613          	li	a2,1024
    800036c8:	4581                	li	a1,0
    800036ca:	05850513          	addi	a0,a0,88
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	604080e7          	jalr	1540(ra) # 80000cd2 <memset>
  log_write(bp);
    800036d6:	854a                	mv	a0,s2
    800036d8:	00001097          	auipc	ra,0x1
    800036dc:	078080e7          	jalr	120(ra) # 80004750 <log_write>
  brelse(bp);
    800036e0:	854a                	mv	a0,s2
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	dea080e7          	jalr	-534(ra) # 800034cc <brelse>
}
    800036ea:	8526                	mv	a0,s1
    800036ec:	60e6                	ld	ra,88(sp)
    800036ee:	6446                	ld	s0,80(sp)
    800036f0:	64a6                	ld	s1,72(sp)
    800036f2:	6906                	ld	s2,64(sp)
    800036f4:	79e2                	ld	s3,56(sp)
    800036f6:	7a42                	ld	s4,48(sp)
    800036f8:	7aa2                	ld	s5,40(sp)
    800036fa:	7b02                	ld	s6,32(sp)
    800036fc:	6be2                	ld	s7,24(sp)
    800036fe:	6c42                	ld	s8,16(sp)
    80003700:	6ca2                	ld	s9,8(sp)
    80003702:	6125                	addi	sp,sp,96
    80003704:	8082                	ret
    brelse(bp);
    80003706:	854a                	mv	a0,s2
    80003708:	00000097          	auipc	ra,0x0
    8000370c:	dc4080e7          	jalr	-572(ra) # 800034cc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003710:	015c87bb          	addw	a5,s9,s5
    80003714:	00078a9b          	sext.w	s5,a5
    80003718:	004b2703          	lw	a4,4(s6) # 8002068c <sb+0x4>
    8000371c:	06eaf363          	bgeu	s5,a4,80003782 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003720:	41fad79b          	sraiw	a5,s5,0x1f
    80003724:	0137d79b          	srliw	a5,a5,0x13
    80003728:	015787bb          	addw	a5,a5,s5
    8000372c:	40d7d79b          	sraiw	a5,a5,0xd
    80003730:	01cb2583          	lw	a1,28(s6)
    80003734:	9dbd                	addw	a1,a1,a5
    80003736:	855e                	mv	a0,s7
    80003738:	00000097          	auipc	ra,0x0
    8000373c:	c64080e7          	jalr	-924(ra) # 8000339c <bread>
    80003740:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003742:	004b2503          	lw	a0,4(s6)
    80003746:	000a849b          	sext.w	s1,s5
    8000374a:	8662                	mv	a2,s8
    8000374c:	faa4fde3          	bgeu	s1,a0,80003706 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003750:	41f6579b          	sraiw	a5,a2,0x1f
    80003754:	01d7d69b          	srliw	a3,a5,0x1d
    80003758:	00c6873b          	addw	a4,a3,a2
    8000375c:	00777793          	andi	a5,a4,7
    80003760:	9f95                	subw	a5,a5,a3
    80003762:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003766:	4037571b          	sraiw	a4,a4,0x3
    8000376a:	00e906b3          	add	a3,s2,a4
    8000376e:	0586c683          	lbu	a3,88(a3)
    80003772:	00d7f5b3          	and	a1,a5,a3
    80003776:	d195                	beqz	a1,8000369a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003778:	2605                	addiw	a2,a2,1
    8000377a:	2485                	addiw	s1,s1,1
    8000377c:	fd4618e3          	bne	a2,s4,8000374c <balloc+0xee>
    80003780:	b759                	j	80003706 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003782:	00005517          	auipc	a0,0x5
    80003786:	dee50513          	addi	a0,a0,-530 # 80008570 <syscalls+0x120>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	dfe080e7          	jalr	-514(ra) # 80000588 <printf>
  return 0;
    80003792:	4481                	li	s1,0
    80003794:	bf99                	j	800036ea <balloc+0x8c>

0000000080003796 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003796:	7179                	addi	sp,sp,-48
    80003798:	f406                	sd	ra,40(sp)
    8000379a:	f022                	sd	s0,32(sp)
    8000379c:	ec26                	sd	s1,24(sp)
    8000379e:	e84a                	sd	s2,16(sp)
    800037a0:	e44e                	sd	s3,8(sp)
    800037a2:	e052                	sd	s4,0(sp)
    800037a4:	1800                	addi	s0,sp,48
    800037a6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037a8:	47ad                	li	a5,11
    800037aa:	02b7e763          	bltu	a5,a1,800037d8 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800037ae:	02059493          	slli	s1,a1,0x20
    800037b2:	9081                	srli	s1,s1,0x20
    800037b4:	048a                	slli	s1,s1,0x2
    800037b6:	94aa                	add	s1,s1,a0
    800037b8:	0504a903          	lw	s2,80(s1)
    800037bc:	06091e63          	bnez	s2,80003838 <bmap+0xa2>
      addr = balloc(ip->dev);
    800037c0:	4108                	lw	a0,0(a0)
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	e9c080e7          	jalr	-356(ra) # 8000365e <balloc>
    800037ca:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037ce:	06090563          	beqz	s2,80003838 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800037d2:	0524a823          	sw	s2,80(s1)
    800037d6:	a08d                	j	80003838 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037d8:	ff45849b          	addiw	s1,a1,-12
    800037dc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037e0:	0ff00793          	li	a5,255
    800037e4:	08e7e563          	bltu	a5,a4,8000386e <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800037e8:	08052903          	lw	s2,128(a0)
    800037ec:	00091d63          	bnez	s2,80003806 <bmap+0x70>
      addr = balloc(ip->dev);
    800037f0:	4108                	lw	a0,0(a0)
    800037f2:	00000097          	auipc	ra,0x0
    800037f6:	e6c080e7          	jalr	-404(ra) # 8000365e <balloc>
    800037fa:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037fe:	02090d63          	beqz	s2,80003838 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003802:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003806:	85ca                	mv	a1,s2
    80003808:	0009a503          	lw	a0,0(s3)
    8000380c:	00000097          	auipc	ra,0x0
    80003810:	b90080e7          	jalr	-1136(ra) # 8000339c <bread>
    80003814:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003816:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000381a:	02049593          	slli	a1,s1,0x20
    8000381e:	9181                	srli	a1,a1,0x20
    80003820:	058a                	slli	a1,a1,0x2
    80003822:	00b784b3          	add	s1,a5,a1
    80003826:	0004a903          	lw	s2,0(s1)
    8000382a:	02090063          	beqz	s2,8000384a <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000382e:	8552                	mv	a0,s4
    80003830:	00000097          	auipc	ra,0x0
    80003834:	c9c080e7          	jalr	-868(ra) # 800034cc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003838:	854a                	mv	a0,s2
    8000383a:	70a2                	ld	ra,40(sp)
    8000383c:	7402                	ld	s0,32(sp)
    8000383e:	64e2                	ld	s1,24(sp)
    80003840:	6942                	ld	s2,16(sp)
    80003842:	69a2                	ld	s3,8(sp)
    80003844:	6a02                	ld	s4,0(sp)
    80003846:	6145                	addi	sp,sp,48
    80003848:	8082                	ret
      addr = balloc(ip->dev);
    8000384a:	0009a503          	lw	a0,0(s3)
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	e10080e7          	jalr	-496(ra) # 8000365e <balloc>
    80003856:	0005091b          	sext.w	s2,a0
      if(addr){
    8000385a:	fc090ae3          	beqz	s2,8000382e <bmap+0x98>
        a[bn] = addr;
    8000385e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003862:	8552                	mv	a0,s4
    80003864:	00001097          	auipc	ra,0x1
    80003868:	eec080e7          	jalr	-276(ra) # 80004750 <log_write>
    8000386c:	b7c9                	j	8000382e <bmap+0x98>
  panic("bmap: out of range");
    8000386e:	00005517          	auipc	a0,0x5
    80003872:	d1a50513          	addi	a0,a0,-742 # 80008588 <syscalls+0x138>
    80003876:	ffffd097          	auipc	ra,0xffffd
    8000387a:	cc8080e7          	jalr	-824(ra) # 8000053e <panic>

000000008000387e <iget>:
{
    8000387e:	7179                	addi	sp,sp,-48
    80003880:	f406                	sd	ra,40(sp)
    80003882:	f022                	sd	s0,32(sp)
    80003884:	ec26                	sd	s1,24(sp)
    80003886:	e84a                	sd	s2,16(sp)
    80003888:	e44e                	sd	s3,8(sp)
    8000388a:	e052                	sd	s4,0(sp)
    8000388c:	1800                	addi	s0,sp,48
    8000388e:	89aa                	mv	s3,a0
    80003890:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003892:	0001d517          	auipc	a0,0x1d
    80003896:	e1650513          	addi	a0,a0,-490 # 800206a8 <itable>
    8000389a:	ffffd097          	auipc	ra,0xffffd
    8000389e:	33c080e7          	jalr	828(ra) # 80000bd6 <acquire>
  empty = 0;
    800038a2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038a4:	0001d497          	auipc	s1,0x1d
    800038a8:	e1c48493          	addi	s1,s1,-484 # 800206c0 <itable+0x18>
    800038ac:	0001f697          	auipc	a3,0x1f
    800038b0:	8a468693          	addi	a3,a3,-1884 # 80022150 <log>
    800038b4:	a039                	j	800038c2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038b6:	02090b63          	beqz	s2,800038ec <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038ba:	08848493          	addi	s1,s1,136
    800038be:	02d48a63          	beq	s1,a3,800038f2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038c2:	449c                	lw	a5,8(s1)
    800038c4:	fef059e3          	blez	a5,800038b6 <iget+0x38>
    800038c8:	4098                	lw	a4,0(s1)
    800038ca:	ff3716e3          	bne	a4,s3,800038b6 <iget+0x38>
    800038ce:	40d8                	lw	a4,4(s1)
    800038d0:	ff4713e3          	bne	a4,s4,800038b6 <iget+0x38>
      ip->ref++;
    800038d4:	2785                	addiw	a5,a5,1
    800038d6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038d8:	0001d517          	auipc	a0,0x1d
    800038dc:	dd050513          	addi	a0,a0,-560 # 800206a8 <itable>
    800038e0:	ffffd097          	auipc	ra,0xffffd
    800038e4:	3aa080e7          	jalr	938(ra) # 80000c8a <release>
      return ip;
    800038e8:	8926                	mv	s2,s1
    800038ea:	a03d                	j	80003918 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038ec:	f7f9                	bnez	a5,800038ba <iget+0x3c>
    800038ee:	8926                	mv	s2,s1
    800038f0:	b7e9                	j	800038ba <iget+0x3c>
  if(empty == 0)
    800038f2:	02090c63          	beqz	s2,8000392a <iget+0xac>
  ip->dev = dev;
    800038f6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038fa:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038fe:	4785                	li	a5,1
    80003900:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003904:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003908:	0001d517          	auipc	a0,0x1d
    8000390c:	da050513          	addi	a0,a0,-608 # 800206a8 <itable>
    80003910:	ffffd097          	auipc	ra,0xffffd
    80003914:	37a080e7          	jalr	890(ra) # 80000c8a <release>
}
    80003918:	854a                	mv	a0,s2
    8000391a:	70a2                	ld	ra,40(sp)
    8000391c:	7402                	ld	s0,32(sp)
    8000391e:	64e2                	ld	s1,24(sp)
    80003920:	6942                	ld	s2,16(sp)
    80003922:	69a2                	ld	s3,8(sp)
    80003924:	6a02                	ld	s4,0(sp)
    80003926:	6145                	addi	sp,sp,48
    80003928:	8082                	ret
    panic("iget: no inodes");
    8000392a:	00005517          	auipc	a0,0x5
    8000392e:	c7650513          	addi	a0,a0,-906 # 800085a0 <syscalls+0x150>
    80003932:	ffffd097          	auipc	ra,0xffffd
    80003936:	c0c080e7          	jalr	-1012(ra) # 8000053e <panic>

000000008000393a <fsinit>:
fsinit(int dev) {
    8000393a:	7179                	addi	sp,sp,-48
    8000393c:	f406                	sd	ra,40(sp)
    8000393e:	f022                	sd	s0,32(sp)
    80003940:	ec26                	sd	s1,24(sp)
    80003942:	e84a                	sd	s2,16(sp)
    80003944:	e44e                	sd	s3,8(sp)
    80003946:	1800                	addi	s0,sp,48
    80003948:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000394a:	4585                	li	a1,1
    8000394c:	00000097          	auipc	ra,0x0
    80003950:	a50080e7          	jalr	-1456(ra) # 8000339c <bread>
    80003954:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003956:	0001d997          	auipc	s3,0x1d
    8000395a:	d3298993          	addi	s3,s3,-718 # 80020688 <sb>
    8000395e:	02000613          	li	a2,32
    80003962:	05850593          	addi	a1,a0,88
    80003966:	854e                	mv	a0,s3
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	3c6080e7          	jalr	966(ra) # 80000d2e <memmove>
  brelse(bp);
    80003970:	8526                	mv	a0,s1
    80003972:	00000097          	auipc	ra,0x0
    80003976:	b5a080e7          	jalr	-1190(ra) # 800034cc <brelse>
  if(sb.magic != FSMAGIC)
    8000397a:	0009a703          	lw	a4,0(s3)
    8000397e:	102037b7          	lui	a5,0x10203
    80003982:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003986:	02f71263          	bne	a4,a5,800039aa <fsinit+0x70>
  initlog(dev, &sb);
    8000398a:	0001d597          	auipc	a1,0x1d
    8000398e:	cfe58593          	addi	a1,a1,-770 # 80020688 <sb>
    80003992:	854a                	mv	a0,s2
    80003994:	00001097          	auipc	ra,0x1
    80003998:	b40080e7          	jalr	-1216(ra) # 800044d4 <initlog>
}
    8000399c:	70a2                	ld	ra,40(sp)
    8000399e:	7402                	ld	s0,32(sp)
    800039a0:	64e2                	ld	s1,24(sp)
    800039a2:	6942                	ld	s2,16(sp)
    800039a4:	69a2                	ld	s3,8(sp)
    800039a6:	6145                	addi	sp,sp,48
    800039a8:	8082                	ret
    panic("invalid file system");
    800039aa:	00005517          	auipc	a0,0x5
    800039ae:	c0650513          	addi	a0,a0,-1018 # 800085b0 <syscalls+0x160>
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	b8c080e7          	jalr	-1140(ra) # 8000053e <panic>

00000000800039ba <iinit>:
{
    800039ba:	7179                	addi	sp,sp,-48
    800039bc:	f406                	sd	ra,40(sp)
    800039be:	f022                	sd	s0,32(sp)
    800039c0:	ec26                	sd	s1,24(sp)
    800039c2:	e84a                	sd	s2,16(sp)
    800039c4:	e44e                	sd	s3,8(sp)
    800039c6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039c8:	00005597          	auipc	a1,0x5
    800039cc:	c0058593          	addi	a1,a1,-1024 # 800085c8 <syscalls+0x178>
    800039d0:	0001d517          	auipc	a0,0x1d
    800039d4:	cd850513          	addi	a0,a0,-808 # 800206a8 <itable>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	16e080e7          	jalr	366(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800039e0:	0001d497          	auipc	s1,0x1d
    800039e4:	cf048493          	addi	s1,s1,-784 # 800206d0 <itable+0x28>
    800039e8:	0001e997          	auipc	s3,0x1e
    800039ec:	77898993          	addi	s3,s3,1912 # 80022160 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039f0:	00005917          	auipc	s2,0x5
    800039f4:	be090913          	addi	s2,s2,-1056 # 800085d0 <syscalls+0x180>
    800039f8:	85ca                	mv	a1,s2
    800039fa:	8526                	mv	a0,s1
    800039fc:	00001097          	auipc	ra,0x1
    80003a00:	e3a080e7          	jalr	-454(ra) # 80004836 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a04:	08848493          	addi	s1,s1,136
    80003a08:	ff3498e3          	bne	s1,s3,800039f8 <iinit+0x3e>
}
    80003a0c:	70a2                	ld	ra,40(sp)
    80003a0e:	7402                	ld	s0,32(sp)
    80003a10:	64e2                	ld	s1,24(sp)
    80003a12:	6942                	ld	s2,16(sp)
    80003a14:	69a2                	ld	s3,8(sp)
    80003a16:	6145                	addi	sp,sp,48
    80003a18:	8082                	ret

0000000080003a1a <ialloc>:
{
    80003a1a:	715d                	addi	sp,sp,-80
    80003a1c:	e486                	sd	ra,72(sp)
    80003a1e:	e0a2                	sd	s0,64(sp)
    80003a20:	fc26                	sd	s1,56(sp)
    80003a22:	f84a                	sd	s2,48(sp)
    80003a24:	f44e                	sd	s3,40(sp)
    80003a26:	f052                	sd	s4,32(sp)
    80003a28:	ec56                	sd	s5,24(sp)
    80003a2a:	e85a                	sd	s6,16(sp)
    80003a2c:	e45e                	sd	s7,8(sp)
    80003a2e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a30:	0001d717          	auipc	a4,0x1d
    80003a34:	c6472703          	lw	a4,-924(a4) # 80020694 <sb+0xc>
    80003a38:	4785                	li	a5,1
    80003a3a:	04e7fa63          	bgeu	a5,a4,80003a8e <ialloc+0x74>
    80003a3e:	8aaa                	mv	s5,a0
    80003a40:	8bae                	mv	s7,a1
    80003a42:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a44:	0001da17          	auipc	s4,0x1d
    80003a48:	c44a0a13          	addi	s4,s4,-956 # 80020688 <sb>
    80003a4c:	00048b1b          	sext.w	s6,s1
    80003a50:	0044d793          	srli	a5,s1,0x4
    80003a54:	018a2583          	lw	a1,24(s4)
    80003a58:	9dbd                	addw	a1,a1,a5
    80003a5a:	8556                	mv	a0,s5
    80003a5c:	00000097          	auipc	ra,0x0
    80003a60:	940080e7          	jalr	-1728(ra) # 8000339c <bread>
    80003a64:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a66:	05850993          	addi	s3,a0,88
    80003a6a:	00f4f793          	andi	a5,s1,15
    80003a6e:	079a                	slli	a5,a5,0x6
    80003a70:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a72:	00099783          	lh	a5,0(s3)
    80003a76:	c3a1                	beqz	a5,80003ab6 <ialloc+0x9c>
    brelse(bp);
    80003a78:	00000097          	auipc	ra,0x0
    80003a7c:	a54080e7          	jalr	-1452(ra) # 800034cc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a80:	0485                	addi	s1,s1,1
    80003a82:	00ca2703          	lw	a4,12(s4)
    80003a86:	0004879b          	sext.w	a5,s1
    80003a8a:	fce7e1e3          	bltu	a5,a4,80003a4c <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a8e:	00005517          	auipc	a0,0x5
    80003a92:	b4a50513          	addi	a0,a0,-1206 # 800085d8 <syscalls+0x188>
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	af2080e7          	jalr	-1294(ra) # 80000588 <printf>
  return 0;
    80003a9e:	4501                	li	a0,0
}
    80003aa0:	60a6                	ld	ra,72(sp)
    80003aa2:	6406                	ld	s0,64(sp)
    80003aa4:	74e2                	ld	s1,56(sp)
    80003aa6:	7942                	ld	s2,48(sp)
    80003aa8:	79a2                	ld	s3,40(sp)
    80003aaa:	7a02                	ld	s4,32(sp)
    80003aac:	6ae2                	ld	s5,24(sp)
    80003aae:	6b42                	ld	s6,16(sp)
    80003ab0:	6ba2                	ld	s7,8(sp)
    80003ab2:	6161                	addi	sp,sp,80
    80003ab4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ab6:	04000613          	li	a2,64
    80003aba:	4581                	li	a1,0
    80003abc:	854e                	mv	a0,s3
    80003abe:	ffffd097          	auipc	ra,0xffffd
    80003ac2:	214080e7          	jalr	532(ra) # 80000cd2 <memset>
      dip->type = type;
    80003ac6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003aca:	854a                	mv	a0,s2
    80003acc:	00001097          	auipc	ra,0x1
    80003ad0:	c84080e7          	jalr	-892(ra) # 80004750 <log_write>
      brelse(bp);
    80003ad4:	854a                	mv	a0,s2
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	9f6080e7          	jalr	-1546(ra) # 800034cc <brelse>
      return iget(dev, inum);
    80003ade:	85da                	mv	a1,s6
    80003ae0:	8556                	mv	a0,s5
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	d9c080e7          	jalr	-612(ra) # 8000387e <iget>
    80003aea:	bf5d                	j	80003aa0 <ialloc+0x86>

0000000080003aec <iupdate>:
{
    80003aec:	1101                	addi	sp,sp,-32
    80003aee:	ec06                	sd	ra,24(sp)
    80003af0:	e822                	sd	s0,16(sp)
    80003af2:	e426                	sd	s1,8(sp)
    80003af4:	e04a                	sd	s2,0(sp)
    80003af6:	1000                	addi	s0,sp,32
    80003af8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003afa:	415c                	lw	a5,4(a0)
    80003afc:	0047d79b          	srliw	a5,a5,0x4
    80003b00:	0001d597          	auipc	a1,0x1d
    80003b04:	ba05a583          	lw	a1,-1120(a1) # 800206a0 <sb+0x18>
    80003b08:	9dbd                	addw	a1,a1,a5
    80003b0a:	4108                	lw	a0,0(a0)
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	890080e7          	jalr	-1904(ra) # 8000339c <bread>
    80003b14:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b16:	05850793          	addi	a5,a0,88
    80003b1a:	40c8                	lw	a0,4(s1)
    80003b1c:	893d                	andi	a0,a0,15
    80003b1e:	051a                	slli	a0,a0,0x6
    80003b20:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b22:	04449703          	lh	a4,68(s1)
    80003b26:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b2a:	04649703          	lh	a4,70(s1)
    80003b2e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b32:	04849703          	lh	a4,72(s1)
    80003b36:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b3a:	04a49703          	lh	a4,74(s1)
    80003b3e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b42:	44f8                	lw	a4,76(s1)
    80003b44:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b46:	03400613          	li	a2,52
    80003b4a:	05048593          	addi	a1,s1,80
    80003b4e:	0531                	addi	a0,a0,12
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	1de080e7          	jalr	478(ra) # 80000d2e <memmove>
  log_write(bp);
    80003b58:	854a                	mv	a0,s2
    80003b5a:	00001097          	auipc	ra,0x1
    80003b5e:	bf6080e7          	jalr	-1034(ra) # 80004750 <log_write>
  brelse(bp);
    80003b62:	854a                	mv	a0,s2
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	968080e7          	jalr	-1688(ra) # 800034cc <brelse>
}
    80003b6c:	60e2                	ld	ra,24(sp)
    80003b6e:	6442                	ld	s0,16(sp)
    80003b70:	64a2                	ld	s1,8(sp)
    80003b72:	6902                	ld	s2,0(sp)
    80003b74:	6105                	addi	sp,sp,32
    80003b76:	8082                	ret

0000000080003b78 <idup>:
{
    80003b78:	1101                	addi	sp,sp,-32
    80003b7a:	ec06                	sd	ra,24(sp)
    80003b7c:	e822                	sd	s0,16(sp)
    80003b7e:	e426                	sd	s1,8(sp)
    80003b80:	1000                	addi	s0,sp,32
    80003b82:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b84:	0001d517          	auipc	a0,0x1d
    80003b88:	b2450513          	addi	a0,a0,-1244 # 800206a8 <itable>
    80003b8c:	ffffd097          	auipc	ra,0xffffd
    80003b90:	04a080e7          	jalr	74(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003b94:	449c                	lw	a5,8(s1)
    80003b96:	2785                	addiw	a5,a5,1
    80003b98:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b9a:	0001d517          	auipc	a0,0x1d
    80003b9e:	b0e50513          	addi	a0,a0,-1266 # 800206a8 <itable>
    80003ba2:	ffffd097          	auipc	ra,0xffffd
    80003ba6:	0e8080e7          	jalr	232(ra) # 80000c8a <release>
}
    80003baa:	8526                	mv	a0,s1
    80003bac:	60e2                	ld	ra,24(sp)
    80003bae:	6442                	ld	s0,16(sp)
    80003bb0:	64a2                	ld	s1,8(sp)
    80003bb2:	6105                	addi	sp,sp,32
    80003bb4:	8082                	ret

0000000080003bb6 <ilock>:
{
    80003bb6:	1101                	addi	sp,sp,-32
    80003bb8:	ec06                	sd	ra,24(sp)
    80003bba:	e822                	sd	s0,16(sp)
    80003bbc:	e426                	sd	s1,8(sp)
    80003bbe:	e04a                	sd	s2,0(sp)
    80003bc0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bc2:	c115                	beqz	a0,80003be6 <ilock+0x30>
    80003bc4:	84aa                	mv	s1,a0
    80003bc6:	451c                	lw	a5,8(a0)
    80003bc8:	00f05f63          	blez	a5,80003be6 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003bcc:	0541                	addi	a0,a0,16
    80003bce:	00001097          	auipc	ra,0x1
    80003bd2:	ca2080e7          	jalr	-862(ra) # 80004870 <acquiresleep>
  if(ip->valid == 0){
    80003bd6:	40bc                	lw	a5,64(s1)
    80003bd8:	cf99                	beqz	a5,80003bf6 <ilock+0x40>
}
    80003bda:	60e2                	ld	ra,24(sp)
    80003bdc:	6442                	ld	s0,16(sp)
    80003bde:	64a2                	ld	s1,8(sp)
    80003be0:	6902                	ld	s2,0(sp)
    80003be2:	6105                	addi	sp,sp,32
    80003be4:	8082                	ret
    panic("ilock");
    80003be6:	00005517          	auipc	a0,0x5
    80003bea:	a0a50513          	addi	a0,a0,-1526 # 800085f0 <syscalls+0x1a0>
    80003bee:	ffffd097          	auipc	ra,0xffffd
    80003bf2:	950080e7          	jalr	-1712(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bf6:	40dc                	lw	a5,4(s1)
    80003bf8:	0047d79b          	srliw	a5,a5,0x4
    80003bfc:	0001d597          	auipc	a1,0x1d
    80003c00:	aa45a583          	lw	a1,-1372(a1) # 800206a0 <sb+0x18>
    80003c04:	9dbd                	addw	a1,a1,a5
    80003c06:	4088                	lw	a0,0(s1)
    80003c08:	fffff097          	auipc	ra,0xfffff
    80003c0c:	794080e7          	jalr	1940(ra) # 8000339c <bread>
    80003c10:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c12:	05850593          	addi	a1,a0,88
    80003c16:	40dc                	lw	a5,4(s1)
    80003c18:	8bbd                	andi	a5,a5,15
    80003c1a:	079a                	slli	a5,a5,0x6
    80003c1c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c1e:	00059783          	lh	a5,0(a1)
    80003c22:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c26:	00259783          	lh	a5,2(a1)
    80003c2a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c2e:	00459783          	lh	a5,4(a1)
    80003c32:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c36:	00659783          	lh	a5,6(a1)
    80003c3a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c3e:	459c                	lw	a5,8(a1)
    80003c40:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c42:	03400613          	li	a2,52
    80003c46:	05b1                	addi	a1,a1,12
    80003c48:	05048513          	addi	a0,s1,80
    80003c4c:	ffffd097          	auipc	ra,0xffffd
    80003c50:	0e2080e7          	jalr	226(ra) # 80000d2e <memmove>
    brelse(bp);
    80003c54:	854a                	mv	a0,s2
    80003c56:	00000097          	auipc	ra,0x0
    80003c5a:	876080e7          	jalr	-1930(ra) # 800034cc <brelse>
    ip->valid = 1;
    80003c5e:	4785                	li	a5,1
    80003c60:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c62:	04449783          	lh	a5,68(s1)
    80003c66:	fbb5                	bnez	a5,80003bda <ilock+0x24>
      panic("ilock: no type");
    80003c68:	00005517          	auipc	a0,0x5
    80003c6c:	99050513          	addi	a0,a0,-1648 # 800085f8 <syscalls+0x1a8>
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	8ce080e7          	jalr	-1842(ra) # 8000053e <panic>

0000000080003c78 <iunlock>:
{
    80003c78:	1101                	addi	sp,sp,-32
    80003c7a:	ec06                	sd	ra,24(sp)
    80003c7c:	e822                	sd	s0,16(sp)
    80003c7e:	e426                	sd	s1,8(sp)
    80003c80:	e04a                	sd	s2,0(sp)
    80003c82:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c84:	c905                	beqz	a0,80003cb4 <iunlock+0x3c>
    80003c86:	84aa                	mv	s1,a0
    80003c88:	01050913          	addi	s2,a0,16
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	00001097          	auipc	ra,0x1
    80003c92:	c7c080e7          	jalr	-900(ra) # 8000490a <holdingsleep>
    80003c96:	cd19                	beqz	a0,80003cb4 <iunlock+0x3c>
    80003c98:	449c                	lw	a5,8(s1)
    80003c9a:	00f05d63          	blez	a5,80003cb4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	00001097          	auipc	ra,0x1
    80003ca4:	c26080e7          	jalr	-986(ra) # 800048c6 <releasesleep>
}
    80003ca8:	60e2                	ld	ra,24(sp)
    80003caa:	6442                	ld	s0,16(sp)
    80003cac:	64a2                	ld	s1,8(sp)
    80003cae:	6902                	ld	s2,0(sp)
    80003cb0:	6105                	addi	sp,sp,32
    80003cb2:	8082                	ret
    panic("iunlock");
    80003cb4:	00005517          	auipc	a0,0x5
    80003cb8:	95450513          	addi	a0,a0,-1708 # 80008608 <syscalls+0x1b8>
    80003cbc:	ffffd097          	auipc	ra,0xffffd
    80003cc0:	882080e7          	jalr	-1918(ra) # 8000053e <panic>

0000000080003cc4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cc4:	7179                	addi	sp,sp,-48
    80003cc6:	f406                	sd	ra,40(sp)
    80003cc8:	f022                	sd	s0,32(sp)
    80003cca:	ec26                	sd	s1,24(sp)
    80003ccc:	e84a                	sd	s2,16(sp)
    80003cce:	e44e                	sd	s3,8(sp)
    80003cd0:	e052                	sd	s4,0(sp)
    80003cd2:	1800                	addi	s0,sp,48
    80003cd4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cd6:	05050493          	addi	s1,a0,80
    80003cda:	08050913          	addi	s2,a0,128
    80003cde:	a021                	j	80003ce6 <itrunc+0x22>
    80003ce0:	0491                	addi	s1,s1,4
    80003ce2:	01248d63          	beq	s1,s2,80003cfc <itrunc+0x38>
    if(ip->addrs[i]){
    80003ce6:	408c                	lw	a1,0(s1)
    80003ce8:	dde5                	beqz	a1,80003ce0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cea:	0009a503          	lw	a0,0(s3)
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	8f4080e7          	jalr	-1804(ra) # 800035e2 <bfree>
      ip->addrs[i] = 0;
    80003cf6:	0004a023          	sw	zero,0(s1)
    80003cfa:	b7dd                	j	80003ce0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cfc:	0809a583          	lw	a1,128(s3)
    80003d00:	e185                	bnez	a1,80003d20 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d02:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d06:	854e                	mv	a0,s3
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	de4080e7          	jalr	-540(ra) # 80003aec <iupdate>
}
    80003d10:	70a2                	ld	ra,40(sp)
    80003d12:	7402                	ld	s0,32(sp)
    80003d14:	64e2                	ld	s1,24(sp)
    80003d16:	6942                	ld	s2,16(sp)
    80003d18:	69a2                	ld	s3,8(sp)
    80003d1a:	6a02                	ld	s4,0(sp)
    80003d1c:	6145                	addi	sp,sp,48
    80003d1e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d20:	0009a503          	lw	a0,0(s3)
    80003d24:	fffff097          	auipc	ra,0xfffff
    80003d28:	678080e7          	jalr	1656(ra) # 8000339c <bread>
    80003d2c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d2e:	05850493          	addi	s1,a0,88
    80003d32:	45850913          	addi	s2,a0,1112
    80003d36:	a021                	j	80003d3e <itrunc+0x7a>
    80003d38:	0491                	addi	s1,s1,4
    80003d3a:	01248b63          	beq	s1,s2,80003d50 <itrunc+0x8c>
      if(a[j])
    80003d3e:	408c                	lw	a1,0(s1)
    80003d40:	dde5                	beqz	a1,80003d38 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d42:	0009a503          	lw	a0,0(s3)
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	89c080e7          	jalr	-1892(ra) # 800035e2 <bfree>
    80003d4e:	b7ed                	j	80003d38 <itrunc+0x74>
    brelse(bp);
    80003d50:	8552                	mv	a0,s4
    80003d52:	fffff097          	auipc	ra,0xfffff
    80003d56:	77a080e7          	jalr	1914(ra) # 800034cc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d5a:	0809a583          	lw	a1,128(s3)
    80003d5e:	0009a503          	lw	a0,0(s3)
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	880080e7          	jalr	-1920(ra) # 800035e2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d6a:	0809a023          	sw	zero,128(s3)
    80003d6e:	bf51                	j	80003d02 <itrunc+0x3e>

0000000080003d70 <iput>:
{
    80003d70:	1101                	addi	sp,sp,-32
    80003d72:	ec06                	sd	ra,24(sp)
    80003d74:	e822                	sd	s0,16(sp)
    80003d76:	e426                	sd	s1,8(sp)
    80003d78:	e04a                	sd	s2,0(sp)
    80003d7a:	1000                	addi	s0,sp,32
    80003d7c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d7e:	0001d517          	auipc	a0,0x1d
    80003d82:	92a50513          	addi	a0,a0,-1750 # 800206a8 <itable>
    80003d86:	ffffd097          	auipc	ra,0xffffd
    80003d8a:	e50080e7          	jalr	-432(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d8e:	4498                	lw	a4,8(s1)
    80003d90:	4785                	li	a5,1
    80003d92:	02f70363          	beq	a4,a5,80003db8 <iput+0x48>
  ip->ref--;
    80003d96:	449c                	lw	a5,8(s1)
    80003d98:	37fd                	addiw	a5,a5,-1
    80003d9a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d9c:	0001d517          	auipc	a0,0x1d
    80003da0:	90c50513          	addi	a0,a0,-1780 # 800206a8 <itable>
    80003da4:	ffffd097          	auipc	ra,0xffffd
    80003da8:	ee6080e7          	jalr	-282(ra) # 80000c8a <release>
}
    80003dac:	60e2                	ld	ra,24(sp)
    80003dae:	6442                	ld	s0,16(sp)
    80003db0:	64a2                	ld	s1,8(sp)
    80003db2:	6902                	ld	s2,0(sp)
    80003db4:	6105                	addi	sp,sp,32
    80003db6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003db8:	40bc                	lw	a5,64(s1)
    80003dba:	dff1                	beqz	a5,80003d96 <iput+0x26>
    80003dbc:	04a49783          	lh	a5,74(s1)
    80003dc0:	fbf9                	bnez	a5,80003d96 <iput+0x26>
    acquiresleep(&ip->lock);
    80003dc2:	01048913          	addi	s2,s1,16
    80003dc6:	854a                	mv	a0,s2
    80003dc8:	00001097          	auipc	ra,0x1
    80003dcc:	aa8080e7          	jalr	-1368(ra) # 80004870 <acquiresleep>
    release(&itable.lock);
    80003dd0:	0001d517          	auipc	a0,0x1d
    80003dd4:	8d850513          	addi	a0,a0,-1832 # 800206a8 <itable>
    80003dd8:	ffffd097          	auipc	ra,0xffffd
    80003ddc:	eb2080e7          	jalr	-334(ra) # 80000c8a <release>
    itrunc(ip);
    80003de0:	8526                	mv	a0,s1
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	ee2080e7          	jalr	-286(ra) # 80003cc4 <itrunc>
    ip->type = 0;
    80003dea:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003dee:	8526                	mv	a0,s1
    80003df0:	00000097          	auipc	ra,0x0
    80003df4:	cfc080e7          	jalr	-772(ra) # 80003aec <iupdate>
    ip->valid = 0;
    80003df8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003dfc:	854a                	mv	a0,s2
    80003dfe:	00001097          	auipc	ra,0x1
    80003e02:	ac8080e7          	jalr	-1336(ra) # 800048c6 <releasesleep>
    acquire(&itable.lock);
    80003e06:	0001d517          	auipc	a0,0x1d
    80003e0a:	8a250513          	addi	a0,a0,-1886 # 800206a8 <itable>
    80003e0e:	ffffd097          	auipc	ra,0xffffd
    80003e12:	dc8080e7          	jalr	-568(ra) # 80000bd6 <acquire>
    80003e16:	b741                	j	80003d96 <iput+0x26>

0000000080003e18 <iunlockput>:
{
    80003e18:	1101                	addi	sp,sp,-32
    80003e1a:	ec06                	sd	ra,24(sp)
    80003e1c:	e822                	sd	s0,16(sp)
    80003e1e:	e426                	sd	s1,8(sp)
    80003e20:	1000                	addi	s0,sp,32
    80003e22:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e24:	00000097          	auipc	ra,0x0
    80003e28:	e54080e7          	jalr	-428(ra) # 80003c78 <iunlock>
  iput(ip);
    80003e2c:	8526                	mv	a0,s1
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	f42080e7          	jalr	-190(ra) # 80003d70 <iput>
}
    80003e36:	60e2                	ld	ra,24(sp)
    80003e38:	6442                	ld	s0,16(sp)
    80003e3a:	64a2                	ld	s1,8(sp)
    80003e3c:	6105                	addi	sp,sp,32
    80003e3e:	8082                	ret

0000000080003e40 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e40:	1141                	addi	sp,sp,-16
    80003e42:	e422                	sd	s0,8(sp)
    80003e44:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e46:	411c                	lw	a5,0(a0)
    80003e48:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e4a:	415c                	lw	a5,4(a0)
    80003e4c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e4e:	04451783          	lh	a5,68(a0)
    80003e52:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e56:	04a51783          	lh	a5,74(a0)
    80003e5a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e5e:	04c56783          	lwu	a5,76(a0)
    80003e62:	e99c                	sd	a5,16(a1)
}
    80003e64:	6422                	ld	s0,8(sp)
    80003e66:	0141                	addi	sp,sp,16
    80003e68:	8082                	ret

0000000080003e6a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e6a:	457c                	lw	a5,76(a0)
    80003e6c:	0ed7e963          	bltu	a5,a3,80003f5e <readi+0xf4>
{
    80003e70:	7159                	addi	sp,sp,-112
    80003e72:	f486                	sd	ra,104(sp)
    80003e74:	f0a2                	sd	s0,96(sp)
    80003e76:	eca6                	sd	s1,88(sp)
    80003e78:	e8ca                	sd	s2,80(sp)
    80003e7a:	e4ce                	sd	s3,72(sp)
    80003e7c:	e0d2                	sd	s4,64(sp)
    80003e7e:	fc56                	sd	s5,56(sp)
    80003e80:	f85a                	sd	s6,48(sp)
    80003e82:	f45e                	sd	s7,40(sp)
    80003e84:	f062                	sd	s8,32(sp)
    80003e86:	ec66                	sd	s9,24(sp)
    80003e88:	e86a                	sd	s10,16(sp)
    80003e8a:	e46e                	sd	s11,8(sp)
    80003e8c:	1880                	addi	s0,sp,112
    80003e8e:	8b2a                	mv	s6,a0
    80003e90:	8bae                	mv	s7,a1
    80003e92:	8a32                	mv	s4,a2
    80003e94:	84b6                	mv	s1,a3
    80003e96:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e98:	9f35                	addw	a4,a4,a3
    return 0;
    80003e9a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e9c:	0ad76063          	bltu	a4,a3,80003f3c <readi+0xd2>
  if(off + n > ip->size)
    80003ea0:	00e7f463          	bgeu	a5,a4,80003ea8 <readi+0x3e>
    n = ip->size - off;
    80003ea4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ea8:	0a0a8963          	beqz	s5,80003f5a <readi+0xf0>
    80003eac:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003eae:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003eb2:	5c7d                	li	s8,-1
    80003eb4:	a82d                	j	80003eee <readi+0x84>
    80003eb6:	020d1d93          	slli	s11,s10,0x20
    80003eba:	020ddd93          	srli	s11,s11,0x20
    80003ebe:	05890793          	addi	a5,s2,88
    80003ec2:	86ee                	mv	a3,s11
    80003ec4:	963e                	add	a2,a2,a5
    80003ec6:	85d2                	mv	a1,s4
    80003ec8:	855e                	mv	a0,s7
    80003eca:	ffffe097          	auipc	ra,0xffffe
    80003ece:	786080e7          	jalr	1926(ra) # 80002650 <either_copyout>
    80003ed2:	05850d63          	beq	a0,s8,80003f2c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ed6:	854a                	mv	a0,s2
    80003ed8:	fffff097          	auipc	ra,0xfffff
    80003edc:	5f4080e7          	jalr	1524(ra) # 800034cc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ee0:	013d09bb          	addw	s3,s10,s3
    80003ee4:	009d04bb          	addw	s1,s10,s1
    80003ee8:	9a6e                	add	s4,s4,s11
    80003eea:	0559f763          	bgeu	s3,s5,80003f38 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003eee:	00a4d59b          	srliw	a1,s1,0xa
    80003ef2:	855a                	mv	a0,s6
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	8a2080e7          	jalr	-1886(ra) # 80003796 <bmap>
    80003efc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f00:	cd85                	beqz	a1,80003f38 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f02:	000b2503          	lw	a0,0(s6)
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	496080e7          	jalr	1174(ra) # 8000339c <bread>
    80003f0e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f10:	3ff4f613          	andi	a2,s1,1023
    80003f14:	40cc87bb          	subw	a5,s9,a2
    80003f18:	413a873b          	subw	a4,s5,s3
    80003f1c:	8d3e                	mv	s10,a5
    80003f1e:	2781                	sext.w	a5,a5
    80003f20:	0007069b          	sext.w	a3,a4
    80003f24:	f8f6f9e3          	bgeu	a3,a5,80003eb6 <readi+0x4c>
    80003f28:	8d3a                	mv	s10,a4
    80003f2a:	b771                	j	80003eb6 <readi+0x4c>
      brelse(bp);
    80003f2c:	854a                	mv	a0,s2
    80003f2e:	fffff097          	auipc	ra,0xfffff
    80003f32:	59e080e7          	jalr	1438(ra) # 800034cc <brelse>
      tot = -1;
    80003f36:	59fd                	li	s3,-1
  }
  return tot;
    80003f38:	0009851b          	sext.w	a0,s3
}
    80003f3c:	70a6                	ld	ra,104(sp)
    80003f3e:	7406                	ld	s0,96(sp)
    80003f40:	64e6                	ld	s1,88(sp)
    80003f42:	6946                	ld	s2,80(sp)
    80003f44:	69a6                	ld	s3,72(sp)
    80003f46:	6a06                	ld	s4,64(sp)
    80003f48:	7ae2                	ld	s5,56(sp)
    80003f4a:	7b42                	ld	s6,48(sp)
    80003f4c:	7ba2                	ld	s7,40(sp)
    80003f4e:	7c02                	ld	s8,32(sp)
    80003f50:	6ce2                	ld	s9,24(sp)
    80003f52:	6d42                	ld	s10,16(sp)
    80003f54:	6da2                	ld	s11,8(sp)
    80003f56:	6165                	addi	sp,sp,112
    80003f58:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f5a:	89d6                	mv	s3,s5
    80003f5c:	bff1                	j	80003f38 <readi+0xce>
    return 0;
    80003f5e:	4501                	li	a0,0
}
    80003f60:	8082                	ret

0000000080003f62 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f62:	457c                	lw	a5,76(a0)
    80003f64:	10d7e863          	bltu	a5,a3,80004074 <writei+0x112>
{
    80003f68:	7159                	addi	sp,sp,-112
    80003f6a:	f486                	sd	ra,104(sp)
    80003f6c:	f0a2                	sd	s0,96(sp)
    80003f6e:	eca6                	sd	s1,88(sp)
    80003f70:	e8ca                	sd	s2,80(sp)
    80003f72:	e4ce                	sd	s3,72(sp)
    80003f74:	e0d2                	sd	s4,64(sp)
    80003f76:	fc56                	sd	s5,56(sp)
    80003f78:	f85a                	sd	s6,48(sp)
    80003f7a:	f45e                	sd	s7,40(sp)
    80003f7c:	f062                	sd	s8,32(sp)
    80003f7e:	ec66                	sd	s9,24(sp)
    80003f80:	e86a                	sd	s10,16(sp)
    80003f82:	e46e                	sd	s11,8(sp)
    80003f84:	1880                	addi	s0,sp,112
    80003f86:	8aaa                	mv	s5,a0
    80003f88:	8bae                	mv	s7,a1
    80003f8a:	8a32                	mv	s4,a2
    80003f8c:	8936                	mv	s2,a3
    80003f8e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f90:	00e687bb          	addw	a5,a3,a4
    80003f94:	0ed7e263          	bltu	a5,a3,80004078 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f98:	00043737          	lui	a4,0x43
    80003f9c:	0ef76063          	bltu	a4,a5,8000407c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fa0:	0c0b0863          	beqz	s6,80004070 <writei+0x10e>
    80003fa4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fa6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003faa:	5c7d                	li	s8,-1
    80003fac:	a091                	j	80003ff0 <writei+0x8e>
    80003fae:	020d1d93          	slli	s11,s10,0x20
    80003fb2:	020ddd93          	srli	s11,s11,0x20
    80003fb6:	05848793          	addi	a5,s1,88
    80003fba:	86ee                	mv	a3,s11
    80003fbc:	8652                	mv	a2,s4
    80003fbe:	85de                	mv	a1,s7
    80003fc0:	953e                	add	a0,a0,a5
    80003fc2:	ffffe097          	auipc	ra,0xffffe
    80003fc6:	6e4080e7          	jalr	1764(ra) # 800026a6 <either_copyin>
    80003fca:	07850263          	beq	a0,s8,8000402e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003fce:	8526                	mv	a0,s1
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	780080e7          	jalr	1920(ra) # 80004750 <log_write>
    brelse(bp);
    80003fd8:	8526                	mv	a0,s1
    80003fda:	fffff097          	auipc	ra,0xfffff
    80003fde:	4f2080e7          	jalr	1266(ra) # 800034cc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fe2:	013d09bb          	addw	s3,s10,s3
    80003fe6:	012d093b          	addw	s2,s10,s2
    80003fea:	9a6e                	add	s4,s4,s11
    80003fec:	0569f663          	bgeu	s3,s6,80004038 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003ff0:	00a9559b          	srliw	a1,s2,0xa
    80003ff4:	8556                	mv	a0,s5
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	7a0080e7          	jalr	1952(ra) # 80003796 <bmap>
    80003ffe:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004002:	c99d                	beqz	a1,80004038 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004004:	000aa503          	lw	a0,0(s5)
    80004008:	fffff097          	auipc	ra,0xfffff
    8000400c:	394080e7          	jalr	916(ra) # 8000339c <bread>
    80004010:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004012:	3ff97513          	andi	a0,s2,1023
    80004016:	40ac87bb          	subw	a5,s9,a0
    8000401a:	413b073b          	subw	a4,s6,s3
    8000401e:	8d3e                	mv	s10,a5
    80004020:	2781                	sext.w	a5,a5
    80004022:	0007069b          	sext.w	a3,a4
    80004026:	f8f6f4e3          	bgeu	a3,a5,80003fae <writei+0x4c>
    8000402a:	8d3a                	mv	s10,a4
    8000402c:	b749                	j	80003fae <writei+0x4c>
      brelse(bp);
    8000402e:	8526                	mv	a0,s1
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	49c080e7          	jalr	1180(ra) # 800034cc <brelse>
  }

  if(off > ip->size)
    80004038:	04caa783          	lw	a5,76(s5)
    8000403c:	0127f463          	bgeu	a5,s2,80004044 <writei+0xe2>
    ip->size = off;
    80004040:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004044:	8556                	mv	a0,s5
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	aa6080e7          	jalr	-1370(ra) # 80003aec <iupdate>

  return tot;
    8000404e:	0009851b          	sext.w	a0,s3
}
    80004052:	70a6                	ld	ra,104(sp)
    80004054:	7406                	ld	s0,96(sp)
    80004056:	64e6                	ld	s1,88(sp)
    80004058:	6946                	ld	s2,80(sp)
    8000405a:	69a6                	ld	s3,72(sp)
    8000405c:	6a06                	ld	s4,64(sp)
    8000405e:	7ae2                	ld	s5,56(sp)
    80004060:	7b42                	ld	s6,48(sp)
    80004062:	7ba2                	ld	s7,40(sp)
    80004064:	7c02                	ld	s8,32(sp)
    80004066:	6ce2                	ld	s9,24(sp)
    80004068:	6d42                	ld	s10,16(sp)
    8000406a:	6da2                	ld	s11,8(sp)
    8000406c:	6165                	addi	sp,sp,112
    8000406e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004070:	89da                	mv	s3,s6
    80004072:	bfc9                	j	80004044 <writei+0xe2>
    return -1;
    80004074:	557d                	li	a0,-1
}
    80004076:	8082                	ret
    return -1;
    80004078:	557d                	li	a0,-1
    8000407a:	bfe1                	j	80004052 <writei+0xf0>
    return -1;
    8000407c:	557d                	li	a0,-1
    8000407e:	bfd1                	j	80004052 <writei+0xf0>

0000000080004080 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004080:	1141                	addi	sp,sp,-16
    80004082:	e406                	sd	ra,8(sp)
    80004084:	e022                	sd	s0,0(sp)
    80004086:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004088:	4639                	li	a2,14
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	d18080e7          	jalr	-744(ra) # 80000da2 <strncmp>
}
    80004092:	60a2                	ld	ra,8(sp)
    80004094:	6402                	ld	s0,0(sp)
    80004096:	0141                	addi	sp,sp,16
    80004098:	8082                	ret

000000008000409a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000409a:	7139                	addi	sp,sp,-64
    8000409c:	fc06                	sd	ra,56(sp)
    8000409e:	f822                	sd	s0,48(sp)
    800040a0:	f426                	sd	s1,40(sp)
    800040a2:	f04a                	sd	s2,32(sp)
    800040a4:	ec4e                	sd	s3,24(sp)
    800040a6:	e852                	sd	s4,16(sp)
    800040a8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040aa:	04451703          	lh	a4,68(a0)
    800040ae:	4785                	li	a5,1
    800040b0:	00f71a63          	bne	a4,a5,800040c4 <dirlookup+0x2a>
    800040b4:	892a                	mv	s2,a0
    800040b6:	89ae                	mv	s3,a1
    800040b8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ba:	457c                	lw	a5,76(a0)
    800040bc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040be:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040c0:	e79d                	bnez	a5,800040ee <dirlookup+0x54>
    800040c2:	a8a5                	j	8000413a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040c4:	00004517          	auipc	a0,0x4
    800040c8:	54c50513          	addi	a0,a0,1356 # 80008610 <syscalls+0x1c0>
    800040cc:	ffffc097          	auipc	ra,0xffffc
    800040d0:	472080e7          	jalr	1138(ra) # 8000053e <panic>
      panic("dirlookup read");
    800040d4:	00004517          	auipc	a0,0x4
    800040d8:	55450513          	addi	a0,a0,1364 # 80008628 <syscalls+0x1d8>
    800040dc:	ffffc097          	auipc	ra,0xffffc
    800040e0:	462080e7          	jalr	1122(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e4:	24c1                	addiw	s1,s1,16
    800040e6:	04c92783          	lw	a5,76(s2)
    800040ea:	04f4f763          	bgeu	s1,a5,80004138 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040ee:	4741                	li	a4,16
    800040f0:	86a6                	mv	a3,s1
    800040f2:	fc040613          	addi	a2,s0,-64
    800040f6:	4581                	li	a1,0
    800040f8:	854a                	mv	a0,s2
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	d70080e7          	jalr	-656(ra) # 80003e6a <readi>
    80004102:	47c1                	li	a5,16
    80004104:	fcf518e3          	bne	a0,a5,800040d4 <dirlookup+0x3a>
    if(de.inum == 0)
    80004108:	fc045783          	lhu	a5,-64(s0)
    8000410c:	dfe1                	beqz	a5,800040e4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000410e:	fc240593          	addi	a1,s0,-62
    80004112:	854e                	mv	a0,s3
    80004114:	00000097          	auipc	ra,0x0
    80004118:	f6c080e7          	jalr	-148(ra) # 80004080 <namecmp>
    8000411c:	f561                	bnez	a0,800040e4 <dirlookup+0x4a>
      if(poff)
    8000411e:	000a0463          	beqz	s4,80004126 <dirlookup+0x8c>
        *poff = off;
    80004122:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004126:	fc045583          	lhu	a1,-64(s0)
    8000412a:	00092503          	lw	a0,0(s2)
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	750080e7          	jalr	1872(ra) # 8000387e <iget>
    80004136:	a011                	j	8000413a <dirlookup+0xa0>
  return 0;
    80004138:	4501                	li	a0,0
}
    8000413a:	70e2                	ld	ra,56(sp)
    8000413c:	7442                	ld	s0,48(sp)
    8000413e:	74a2                	ld	s1,40(sp)
    80004140:	7902                	ld	s2,32(sp)
    80004142:	69e2                	ld	s3,24(sp)
    80004144:	6a42                	ld	s4,16(sp)
    80004146:	6121                	addi	sp,sp,64
    80004148:	8082                	ret

000000008000414a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000414a:	711d                	addi	sp,sp,-96
    8000414c:	ec86                	sd	ra,88(sp)
    8000414e:	e8a2                	sd	s0,80(sp)
    80004150:	e4a6                	sd	s1,72(sp)
    80004152:	e0ca                	sd	s2,64(sp)
    80004154:	fc4e                	sd	s3,56(sp)
    80004156:	f852                	sd	s4,48(sp)
    80004158:	f456                	sd	s5,40(sp)
    8000415a:	f05a                	sd	s6,32(sp)
    8000415c:	ec5e                	sd	s7,24(sp)
    8000415e:	e862                	sd	s8,16(sp)
    80004160:	e466                	sd	s9,8(sp)
    80004162:	1080                	addi	s0,sp,96
    80004164:	84aa                	mv	s1,a0
    80004166:	8aae                	mv	s5,a1
    80004168:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000416a:	00054703          	lbu	a4,0(a0)
    8000416e:	02f00793          	li	a5,47
    80004172:	02f70363          	beq	a4,a5,80004198 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004176:	ffffe097          	auipc	ra,0xffffe
    8000417a:	9da080e7          	jalr	-1574(ra) # 80001b50 <myproc>
    8000417e:	16053503          	ld	a0,352(a0)
    80004182:	00000097          	auipc	ra,0x0
    80004186:	9f6080e7          	jalr	-1546(ra) # 80003b78 <idup>
    8000418a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000418c:	02f00913          	li	s2,47
  len = path - s;
    80004190:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004192:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004194:	4b85                	li	s7,1
    80004196:	a865                	j	8000424e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004198:	4585                	li	a1,1
    8000419a:	4505                	li	a0,1
    8000419c:	fffff097          	auipc	ra,0xfffff
    800041a0:	6e2080e7          	jalr	1762(ra) # 8000387e <iget>
    800041a4:	89aa                	mv	s3,a0
    800041a6:	b7dd                	j	8000418c <namex+0x42>
      iunlockput(ip);
    800041a8:	854e                	mv	a0,s3
    800041aa:	00000097          	auipc	ra,0x0
    800041ae:	c6e080e7          	jalr	-914(ra) # 80003e18 <iunlockput>
      return 0;
    800041b2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041b4:	854e                	mv	a0,s3
    800041b6:	60e6                	ld	ra,88(sp)
    800041b8:	6446                	ld	s0,80(sp)
    800041ba:	64a6                	ld	s1,72(sp)
    800041bc:	6906                	ld	s2,64(sp)
    800041be:	79e2                	ld	s3,56(sp)
    800041c0:	7a42                	ld	s4,48(sp)
    800041c2:	7aa2                	ld	s5,40(sp)
    800041c4:	7b02                	ld	s6,32(sp)
    800041c6:	6be2                	ld	s7,24(sp)
    800041c8:	6c42                	ld	s8,16(sp)
    800041ca:	6ca2                	ld	s9,8(sp)
    800041cc:	6125                	addi	sp,sp,96
    800041ce:	8082                	ret
      iunlock(ip);
    800041d0:	854e                	mv	a0,s3
    800041d2:	00000097          	auipc	ra,0x0
    800041d6:	aa6080e7          	jalr	-1370(ra) # 80003c78 <iunlock>
      return ip;
    800041da:	bfe9                	j	800041b4 <namex+0x6a>
      iunlockput(ip);
    800041dc:	854e                	mv	a0,s3
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	c3a080e7          	jalr	-966(ra) # 80003e18 <iunlockput>
      return 0;
    800041e6:	89e6                	mv	s3,s9
    800041e8:	b7f1                	j	800041b4 <namex+0x6a>
  len = path - s;
    800041ea:	40b48633          	sub	a2,s1,a1
    800041ee:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800041f2:	099c5463          	bge	s8,s9,8000427a <namex+0x130>
    memmove(name, s, DIRSIZ);
    800041f6:	4639                	li	a2,14
    800041f8:	8552                	mv	a0,s4
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	b34080e7          	jalr	-1228(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004202:	0004c783          	lbu	a5,0(s1)
    80004206:	01279763          	bne	a5,s2,80004214 <namex+0xca>
    path++;
    8000420a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000420c:	0004c783          	lbu	a5,0(s1)
    80004210:	ff278de3          	beq	a5,s2,8000420a <namex+0xc0>
    ilock(ip);
    80004214:	854e                	mv	a0,s3
    80004216:	00000097          	auipc	ra,0x0
    8000421a:	9a0080e7          	jalr	-1632(ra) # 80003bb6 <ilock>
    if(ip->type != T_DIR){
    8000421e:	04499783          	lh	a5,68(s3)
    80004222:	f97793e3          	bne	a5,s7,800041a8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004226:	000a8563          	beqz	s5,80004230 <namex+0xe6>
    8000422a:	0004c783          	lbu	a5,0(s1)
    8000422e:	d3cd                	beqz	a5,800041d0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004230:	865a                	mv	a2,s6
    80004232:	85d2                	mv	a1,s4
    80004234:	854e                	mv	a0,s3
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	e64080e7          	jalr	-412(ra) # 8000409a <dirlookup>
    8000423e:	8caa                	mv	s9,a0
    80004240:	dd51                	beqz	a0,800041dc <namex+0x92>
    iunlockput(ip);
    80004242:	854e                	mv	a0,s3
    80004244:	00000097          	auipc	ra,0x0
    80004248:	bd4080e7          	jalr	-1068(ra) # 80003e18 <iunlockput>
    ip = next;
    8000424c:	89e6                	mv	s3,s9
  while(*path == '/')
    8000424e:	0004c783          	lbu	a5,0(s1)
    80004252:	05279763          	bne	a5,s2,800042a0 <namex+0x156>
    path++;
    80004256:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004258:	0004c783          	lbu	a5,0(s1)
    8000425c:	ff278de3          	beq	a5,s2,80004256 <namex+0x10c>
  if(*path == 0)
    80004260:	c79d                	beqz	a5,8000428e <namex+0x144>
    path++;
    80004262:	85a6                	mv	a1,s1
  len = path - s;
    80004264:	8cda                	mv	s9,s6
    80004266:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004268:	01278963          	beq	a5,s2,8000427a <namex+0x130>
    8000426c:	dfbd                	beqz	a5,800041ea <namex+0xa0>
    path++;
    8000426e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004270:	0004c783          	lbu	a5,0(s1)
    80004274:	ff279ce3          	bne	a5,s2,8000426c <namex+0x122>
    80004278:	bf8d                	j	800041ea <namex+0xa0>
    memmove(name, s, len);
    8000427a:	2601                	sext.w	a2,a2
    8000427c:	8552                	mv	a0,s4
    8000427e:	ffffd097          	auipc	ra,0xffffd
    80004282:	ab0080e7          	jalr	-1360(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004286:	9cd2                	add	s9,s9,s4
    80004288:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000428c:	bf9d                	j	80004202 <namex+0xb8>
  if(nameiparent){
    8000428e:	f20a83e3          	beqz	s5,800041b4 <namex+0x6a>
    iput(ip);
    80004292:	854e                	mv	a0,s3
    80004294:	00000097          	auipc	ra,0x0
    80004298:	adc080e7          	jalr	-1316(ra) # 80003d70 <iput>
    return 0;
    8000429c:	4981                	li	s3,0
    8000429e:	bf19                	j	800041b4 <namex+0x6a>
  if(*path == 0)
    800042a0:	d7fd                	beqz	a5,8000428e <namex+0x144>
  while(*path != '/' && *path != 0)
    800042a2:	0004c783          	lbu	a5,0(s1)
    800042a6:	85a6                	mv	a1,s1
    800042a8:	b7d1                	j	8000426c <namex+0x122>

00000000800042aa <dirlink>:
{
    800042aa:	7139                	addi	sp,sp,-64
    800042ac:	fc06                	sd	ra,56(sp)
    800042ae:	f822                	sd	s0,48(sp)
    800042b0:	f426                	sd	s1,40(sp)
    800042b2:	f04a                	sd	s2,32(sp)
    800042b4:	ec4e                	sd	s3,24(sp)
    800042b6:	e852                	sd	s4,16(sp)
    800042b8:	0080                	addi	s0,sp,64
    800042ba:	892a                	mv	s2,a0
    800042bc:	8a2e                	mv	s4,a1
    800042be:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042c0:	4601                	li	a2,0
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	dd8080e7          	jalr	-552(ra) # 8000409a <dirlookup>
    800042ca:	e93d                	bnez	a0,80004340 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042cc:	04c92483          	lw	s1,76(s2)
    800042d0:	c49d                	beqz	s1,800042fe <dirlink+0x54>
    800042d2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042d4:	4741                	li	a4,16
    800042d6:	86a6                	mv	a3,s1
    800042d8:	fc040613          	addi	a2,s0,-64
    800042dc:	4581                	li	a1,0
    800042de:	854a                	mv	a0,s2
    800042e0:	00000097          	auipc	ra,0x0
    800042e4:	b8a080e7          	jalr	-1142(ra) # 80003e6a <readi>
    800042e8:	47c1                	li	a5,16
    800042ea:	06f51163          	bne	a0,a5,8000434c <dirlink+0xa2>
    if(de.inum == 0)
    800042ee:	fc045783          	lhu	a5,-64(s0)
    800042f2:	c791                	beqz	a5,800042fe <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042f4:	24c1                	addiw	s1,s1,16
    800042f6:	04c92783          	lw	a5,76(s2)
    800042fa:	fcf4ede3          	bltu	s1,a5,800042d4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042fe:	4639                	li	a2,14
    80004300:	85d2                	mv	a1,s4
    80004302:	fc240513          	addi	a0,s0,-62
    80004306:	ffffd097          	auipc	ra,0xffffd
    8000430a:	ad8080e7          	jalr	-1320(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000430e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004312:	4741                	li	a4,16
    80004314:	86a6                	mv	a3,s1
    80004316:	fc040613          	addi	a2,s0,-64
    8000431a:	4581                	li	a1,0
    8000431c:	854a                	mv	a0,s2
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	c44080e7          	jalr	-956(ra) # 80003f62 <writei>
    80004326:	1541                	addi	a0,a0,-16
    80004328:	00a03533          	snez	a0,a0
    8000432c:	40a00533          	neg	a0,a0
}
    80004330:	70e2                	ld	ra,56(sp)
    80004332:	7442                	ld	s0,48(sp)
    80004334:	74a2                	ld	s1,40(sp)
    80004336:	7902                	ld	s2,32(sp)
    80004338:	69e2                	ld	s3,24(sp)
    8000433a:	6a42                	ld	s4,16(sp)
    8000433c:	6121                	addi	sp,sp,64
    8000433e:	8082                	ret
    iput(ip);
    80004340:	00000097          	auipc	ra,0x0
    80004344:	a30080e7          	jalr	-1488(ra) # 80003d70 <iput>
    return -1;
    80004348:	557d                	li	a0,-1
    8000434a:	b7dd                	j	80004330 <dirlink+0x86>
      panic("dirlink read");
    8000434c:	00004517          	auipc	a0,0x4
    80004350:	2ec50513          	addi	a0,a0,748 # 80008638 <syscalls+0x1e8>
    80004354:	ffffc097          	auipc	ra,0xffffc
    80004358:	1ea080e7          	jalr	490(ra) # 8000053e <panic>

000000008000435c <namei>:

struct inode*
namei(char *path)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004364:	fe040613          	addi	a2,s0,-32
    80004368:	4581                	li	a1,0
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	de0080e7          	jalr	-544(ra) # 8000414a <namex>
}
    80004372:	60e2                	ld	ra,24(sp)
    80004374:	6442                	ld	s0,16(sp)
    80004376:	6105                	addi	sp,sp,32
    80004378:	8082                	ret

000000008000437a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000437a:	1141                	addi	sp,sp,-16
    8000437c:	e406                	sd	ra,8(sp)
    8000437e:	e022                	sd	s0,0(sp)
    80004380:	0800                	addi	s0,sp,16
    80004382:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004384:	4585                	li	a1,1
    80004386:	00000097          	auipc	ra,0x0
    8000438a:	dc4080e7          	jalr	-572(ra) # 8000414a <namex>
}
    8000438e:	60a2                	ld	ra,8(sp)
    80004390:	6402                	ld	s0,0(sp)
    80004392:	0141                	addi	sp,sp,16
    80004394:	8082                	ret

0000000080004396 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004396:	1101                	addi	sp,sp,-32
    80004398:	ec06                	sd	ra,24(sp)
    8000439a:	e822                	sd	s0,16(sp)
    8000439c:	e426                	sd	s1,8(sp)
    8000439e:	e04a                	sd	s2,0(sp)
    800043a0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043a2:	0001e917          	auipc	s2,0x1e
    800043a6:	dae90913          	addi	s2,s2,-594 # 80022150 <log>
    800043aa:	01892583          	lw	a1,24(s2)
    800043ae:	02892503          	lw	a0,40(s2)
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	fea080e7          	jalr	-22(ra) # 8000339c <bread>
    800043ba:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043bc:	02c92683          	lw	a3,44(s2)
    800043c0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043c2:	02d05763          	blez	a3,800043f0 <write_head+0x5a>
    800043c6:	0001e797          	auipc	a5,0x1e
    800043ca:	dba78793          	addi	a5,a5,-582 # 80022180 <log+0x30>
    800043ce:	05c50713          	addi	a4,a0,92
    800043d2:	36fd                	addiw	a3,a3,-1
    800043d4:	1682                	slli	a3,a3,0x20
    800043d6:	9281                	srli	a3,a3,0x20
    800043d8:	068a                	slli	a3,a3,0x2
    800043da:	0001e617          	auipc	a2,0x1e
    800043de:	daa60613          	addi	a2,a2,-598 # 80022184 <log+0x34>
    800043e2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800043e4:	4390                	lw	a2,0(a5)
    800043e6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043e8:	0791                	addi	a5,a5,4
    800043ea:	0711                	addi	a4,a4,4
    800043ec:	fed79ce3          	bne	a5,a3,800043e4 <write_head+0x4e>
  }
  bwrite(buf);
    800043f0:	8526                	mv	a0,s1
    800043f2:	fffff097          	auipc	ra,0xfffff
    800043f6:	09c080e7          	jalr	156(ra) # 8000348e <bwrite>
  brelse(buf);
    800043fa:	8526                	mv	a0,s1
    800043fc:	fffff097          	auipc	ra,0xfffff
    80004400:	0d0080e7          	jalr	208(ra) # 800034cc <brelse>
}
    80004404:	60e2                	ld	ra,24(sp)
    80004406:	6442                	ld	s0,16(sp)
    80004408:	64a2                	ld	s1,8(sp)
    8000440a:	6902                	ld	s2,0(sp)
    8000440c:	6105                	addi	sp,sp,32
    8000440e:	8082                	ret

0000000080004410 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004410:	0001e797          	auipc	a5,0x1e
    80004414:	d6c7a783          	lw	a5,-660(a5) # 8002217c <log+0x2c>
    80004418:	0af05d63          	blez	a5,800044d2 <install_trans+0xc2>
{
    8000441c:	7139                	addi	sp,sp,-64
    8000441e:	fc06                	sd	ra,56(sp)
    80004420:	f822                	sd	s0,48(sp)
    80004422:	f426                	sd	s1,40(sp)
    80004424:	f04a                	sd	s2,32(sp)
    80004426:	ec4e                	sd	s3,24(sp)
    80004428:	e852                	sd	s4,16(sp)
    8000442a:	e456                	sd	s5,8(sp)
    8000442c:	e05a                	sd	s6,0(sp)
    8000442e:	0080                	addi	s0,sp,64
    80004430:	8b2a                	mv	s6,a0
    80004432:	0001ea97          	auipc	s5,0x1e
    80004436:	d4ea8a93          	addi	s5,s5,-690 # 80022180 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000443a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000443c:	0001e997          	auipc	s3,0x1e
    80004440:	d1498993          	addi	s3,s3,-748 # 80022150 <log>
    80004444:	a00d                	j	80004466 <install_trans+0x56>
    brelse(lbuf);
    80004446:	854a                	mv	a0,s2
    80004448:	fffff097          	auipc	ra,0xfffff
    8000444c:	084080e7          	jalr	132(ra) # 800034cc <brelse>
    brelse(dbuf);
    80004450:	8526                	mv	a0,s1
    80004452:	fffff097          	auipc	ra,0xfffff
    80004456:	07a080e7          	jalr	122(ra) # 800034cc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000445a:	2a05                	addiw	s4,s4,1
    8000445c:	0a91                	addi	s5,s5,4
    8000445e:	02c9a783          	lw	a5,44(s3)
    80004462:	04fa5e63          	bge	s4,a5,800044be <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004466:	0189a583          	lw	a1,24(s3)
    8000446a:	014585bb          	addw	a1,a1,s4
    8000446e:	2585                	addiw	a1,a1,1
    80004470:	0289a503          	lw	a0,40(s3)
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	f28080e7          	jalr	-216(ra) # 8000339c <bread>
    8000447c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000447e:	000aa583          	lw	a1,0(s5)
    80004482:	0289a503          	lw	a0,40(s3)
    80004486:	fffff097          	auipc	ra,0xfffff
    8000448a:	f16080e7          	jalr	-234(ra) # 8000339c <bread>
    8000448e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004490:	40000613          	li	a2,1024
    80004494:	05890593          	addi	a1,s2,88
    80004498:	05850513          	addi	a0,a0,88
    8000449c:	ffffd097          	auipc	ra,0xffffd
    800044a0:	892080e7          	jalr	-1902(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800044a4:	8526                	mv	a0,s1
    800044a6:	fffff097          	auipc	ra,0xfffff
    800044aa:	fe8080e7          	jalr	-24(ra) # 8000348e <bwrite>
    if(recovering == 0)
    800044ae:	f80b1ce3          	bnez	s6,80004446 <install_trans+0x36>
      bunpin(dbuf);
    800044b2:	8526                	mv	a0,s1
    800044b4:	fffff097          	auipc	ra,0xfffff
    800044b8:	0f2080e7          	jalr	242(ra) # 800035a6 <bunpin>
    800044bc:	b769                	j	80004446 <install_trans+0x36>
}
    800044be:	70e2                	ld	ra,56(sp)
    800044c0:	7442                	ld	s0,48(sp)
    800044c2:	74a2                	ld	s1,40(sp)
    800044c4:	7902                	ld	s2,32(sp)
    800044c6:	69e2                	ld	s3,24(sp)
    800044c8:	6a42                	ld	s4,16(sp)
    800044ca:	6aa2                	ld	s5,8(sp)
    800044cc:	6b02                	ld	s6,0(sp)
    800044ce:	6121                	addi	sp,sp,64
    800044d0:	8082                	ret
    800044d2:	8082                	ret

00000000800044d4 <initlog>:
{
    800044d4:	7179                	addi	sp,sp,-48
    800044d6:	f406                	sd	ra,40(sp)
    800044d8:	f022                	sd	s0,32(sp)
    800044da:	ec26                	sd	s1,24(sp)
    800044dc:	e84a                	sd	s2,16(sp)
    800044de:	e44e                	sd	s3,8(sp)
    800044e0:	1800                	addi	s0,sp,48
    800044e2:	892a                	mv	s2,a0
    800044e4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044e6:	0001e497          	auipc	s1,0x1e
    800044ea:	c6a48493          	addi	s1,s1,-918 # 80022150 <log>
    800044ee:	00004597          	auipc	a1,0x4
    800044f2:	15a58593          	addi	a1,a1,346 # 80008648 <syscalls+0x1f8>
    800044f6:	8526                	mv	a0,s1
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	64e080e7          	jalr	1614(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004500:	0149a583          	lw	a1,20(s3)
    80004504:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004506:	0109a783          	lw	a5,16(s3)
    8000450a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000450c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004510:	854a                	mv	a0,s2
    80004512:	fffff097          	auipc	ra,0xfffff
    80004516:	e8a080e7          	jalr	-374(ra) # 8000339c <bread>
  log.lh.n = lh->n;
    8000451a:	4d34                	lw	a3,88(a0)
    8000451c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000451e:	02d05563          	blez	a3,80004548 <initlog+0x74>
    80004522:	05c50793          	addi	a5,a0,92
    80004526:	0001e717          	auipc	a4,0x1e
    8000452a:	c5a70713          	addi	a4,a4,-934 # 80022180 <log+0x30>
    8000452e:	36fd                	addiw	a3,a3,-1
    80004530:	1682                	slli	a3,a3,0x20
    80004532:	9281                	srli	a3,a3,0x20
    80004534:	068a                	slli	a3,a3,0x2
    80004536:	06050613          	addi	a2,a0,96
    8000453a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000453c:	4390                	lw	a2,0(a5)
    8000453e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004540:	0791                	addi	a5,a5,4
    80004542:	0711                	addi	a4,a4,4
    80004544:	fed79ce3          	bne	a5,a3,8000453c <initlog+0x68>
  brelse(buf);
    80004548:	fffff097          	auipc	ra,0xfffff
    8000454c:	f84080e7          	jalr	-124(ra) # 800034cc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004550:	4505                	li	a0,1
    80004552:	00000097          	auipc	ra,0x0
    80004556:	ebe080e7          	jalr	-322(ra) # 80004410 <install_trans>
  log.lh.n = 0;
    8000455a:	0001e797          	auipc	a5,0x1e
    8000455e:	c207a123          	sw	zero,-990(a5) # 8002217c <log+0x2c>
  write_head(); // clear the log
    80004562:	00000097          	auipc	ra,0x0
    80004566:	e34080e7          	jalr	-460(ra) # 80004396 <write_head>
}
    8000456a:	70a2                	ld	ra,40(sp)
    8000456c:	7402                	ld	s0,32(sp)
    8000456e:	64e2                	ld	s1,24(sp)
    80004570:	6942                	ld	s2,16(sp)
    80004572:	69a2                	ld	s3,8(sp)
    80004574:	6145                	addi	sp,sp,48
    80004576:	8082                	ret

0000000080004578 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004578:	1101                	addi	sp,sp,-32
    8000457a:	ec06                	sd	ra,24(sp)
    8000457c:	e822                	sd	s0,16(sp)
    8000457e:	e426                	sd	s1,8(sp)
    80004580:	e04a                	sd	s2,0(sp)
    80004582:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004584:	0001e517          	auipc	a0,0x1e
    80004588:	bcc50513          	addi	a0,a0,-1076 # 80022150 <log>
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	64a080e7          	jalr	1610(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004594:	0001e497          	auipc	s1,0x1e
    80004598:	bbc48493          	addi	s1,s1,-1092 # 80022150 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000459c:	4979                	li	s2,30
    8000459e:	a039                	j	800045ac <begin_op+0x34>
      sleep(&log, &log.lock);
    800045a0:	85a6                	mv	a1,s1
    800045a2:	8526                	mv	a0,s1
    800045a4:	ffffe097          	auipc	ra,0xffffe
    800045a8:	c98080e7          	jalr	-872(ra) # 8000223c <sleep>
    if(log.committing){
    800045ac:	50dc                	lw	a5,36(s1)
    800045ae:	fbed                	bnez	a5,800045a0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045b0:	509c                	lw	a5,32(s1)
    800045b2:	0017871b          	addiw	a4,a5,1
    800045b6:	0007069b          	sext.w	a3,a4
    800045ba:	0027179b          	slliw	a5,a4,0x2
    800045be:	9fb9                	addw	a5,a5,a4
    800045c0:	0017979b          	slliw	a5,a5,0x1
    800045c4:	54d8                	lw	a4,44(s1)
    800045c6:	9fb9                	addw	a5,a5,a4
    800045c8:	00f95963          	bge	s2,a5,800045da <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045cc:	85a6                	mv	a1,s1
    800045ce:	8526                	mv	a0,s1
    800045d0:	ffffe097          	auipc	ra,0xffffe
    800045d4:	c6c080e7          	jalr	-916(ra) # 8000223c <sleep>
    800045d8:	bfd1                	j	800045ac <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045da:	0001e517          	auipc	a0,0x1e
    800045de:	b7650513          	addi	a0,a0,-1162 # 80022150 <log>
    800045e2:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	6a6080e7          	jalr	1702(ra) # 80000c8a <release>
      break;
    }
  }
}
    800045ec:	60e2                	ld	ra,24(sp)
    800045ee:	6442                	ld	s0,16(sp)
    800045f0:	64a2                	ld	s1,8(sp)
    800045f2:	6902                	ld	s2,0(sp)
    800045f4:	6105                	addi	sp,sp,32
    800045f6:	8082                	ret

00000000800045f8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045f8:	7139                	addi	sp,sp,-64
    800045fa:	fc06                	sd	ra,56(sp)
    800045fc:	f822                	sd	s0,48(sp)
    800045fe:	f426                	sd	s1,40(sp)
    80004600:	f04a                	sd	s2,32(sp)
    80004602:	ec4e                	sd	s3,24(sp)
    80004604:	e852                	sd	s4,16(sp)
    80004606:	e456                	sd	s5,8(sp)
    80004608:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000460a:	0001e497          	auipc	s1,0x1e
    8000460e:	b4648493          	addi	s1,s1,-1210 # 80022150 <log>
    80004612:	8526                	mv	a0,s1
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	5c2080e7          	jalr	1474(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000461c:	509c                	lw	a5,32(s1)
    8000461e:	37fd                	addiw	a5,a5,-1
    80004620:	0007891b          	sext.w	s2,a5
    80004624:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004626:	50dc                	lw	a5,36(s1)
    80004628:	e7b9                	bnez	a5,80004676 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000462a:	04091e63          	bnez	s2,80004686 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000462e:	0001e497          	auipc	s1,0x1e
    80004632:	b2248493          	addi	s1,s1,-1246 # 80022150 <log>
    80004636:	4785                	li	a5,1
    80004638:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000463a:	8526                	mv	a0,s1
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	64e080e7          	jalr	1614(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004644:	54dc                	lw	a5,44(s1)
    80004646:	06f04763          	bgtz	a5,800046b4 <end_op+0xbc>
    acquire(&log.lock);
    8000464a:	0001e497          	auipc	s1,0x1e
    8000464e:	b0648493          	addi	s1,s1,-1274 # 80022150 <log>
    80004652:	8526                	mv	a0,s1
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	582080e7          	jalr	1410(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000465c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004660:	8526                	mv	a0,s1
    80004662:	ffffe097          	auipc	ra,0xffffe
    80004666:	c3e080e7          	jalr	-962(ra) # 800022a0 <wakeup>
    release(&log.lock);
    8000466a:	8526                	mv	a0,s1
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	61e080e7          	jalr	1566(ra) # 80000c8a <release>
}
    80004674:	a03d                	j	800046a2 <end_op+0xaa>
    panic("log.committing");
    80004676:	00004517          	auipc	a0,0x4
    8000467a:	fda50513          	addi	a0,a0,-38 # 80008650 <syscalls+0x200>
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	ec0080e7          	jalr	-320(ra) # 8000053e <panic>
    wakeup(&log);
    80004686:	0001e497          	auipc	s1,0x1e
    8000468a:	aca48493          	addi	s1,s1,-1334 # 80022150 <log>
    8000468e:	8526                	mv	a0,s1
    80004690:	ffffe097          	auipc	ra,0xffffe
    80004694:	c10080e7          	jalr	-1008(ra) # 800022a0 <wakeup>
  release(&log.lock);
    80004698:	8526                	mv	a0,s1
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	5f0080e7          	jalr	1520(ra) # 80000c8a <release>
}
    800046a2:	70e2                	ld	ra,56(sp)
    800046a4:	7442                	ld	s0,48(sp)
    800046a6:	74a2                	ld	s1,40(sp)
    800046a8:	7902                	ld	s2,32(sp)
    800046aa:	69e2                	ld	s3,24(sp)
    800046ac:	6a42                	ld	s4,16(sp)
    800046ae:	6aa2                	ld	s5,8(sp)
    800046b0:	6121                	addi	sp,sp,64
    800046b2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800046b4:	0001ea97          	auipc	s5,0x1e
    800046b8:	acca8a93          	addi	s5,s5,-1332 # 80022180 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046bc:	0001ea17          	auipc	s4,0x1e
    800046c0:	a94a0a13          	addi	s4,s4,-1388 # 80022150 <log>
    800046c4:	018a2583          	lw	a1,24(s4)
    800046c8:	012585bb          	addw	a1,a1,s2
    800046cc:	2585                	addiw	a1,a1,1
    800046ce:	028a2503          	lw	a0,40(s4)
    800046d2:	fffff097          	auipc	ra,0xfffff
    800046d6:	cca080e7          	jalr	-822(ra) # 8000339c <bread>
    800046da:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046dc:	000aa583          	lw	a1,0(s5)
    800046e0:	028a2503          	lw	a0,40(s4)
    800046e4:	fffff097          	auipc	ra,0xfffff
    800046e8:	cb8080e7          	jalr	-840(ra) # 8000339c <bread>
    800046ec:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046ee:	40000613          	li	a2,1024
    800046f2:	05850593          	addi	a1,a0,88
    800046f6:	05848513          	addi	a0,s1,88
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	634080e7          	jalr	1588(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004702:	8526                	mv	a0,s1
    80004704:	fffff097          	auipc	ra,0xfffff
    80004708:	d8a080e7          	jalr	-630(ra) # 8000348e <bwrite>
    brelse(from);
    8000470c:	854e                	mv	a0,s3
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	dbe080e7          	jalr	-578(ra) # 800034cc <brelse>
    brelse(to);
    80004716:	8526                	mv	a0,s1
    80004718:	fffff097          	auipc	ra,0xfffff
    8000471c:	db4080e7          	jalr	-588(ra) # 800034cc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004720:	2905                	addiw	s2,s2,1
    80004722:	0a91                	addi	s5,s5,4
    80004724:	02ca2783          	lw	a5,44(s4)
    80004728:	f8f94ee3          	blt	s2,a5,800046c4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000472c:	00000097          	auipc	ra,0x0
    80004730:	c6a080e7          	jalr	-918(ra) # 80004396 <write_head>
    install_trans(0); // Now install writes to home locations
    80004734:	4501                	li	a0,0
    80004736:	00000097          	auipc	ra,0x0
    8000473a:	cda080e7          	jalr	-806(ra) # 80004410 <install_trans>
    log.lh.n = 0;
    8000473e:	0001e797          	auipc	a5,0x1e
    80004742:	a207af23          	sw	zero,-1474(a5) # 8002217c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004746:	00000097          	auipc	ra,0x0
    8000474a:	c50080e7          	jalr	-944(ra) # 80004396 <write_head>
    8000474e:	bdf5                	j	8000464a <end_op+0x52>

0000000080004750 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004750:	1101                	addi	sp,sp,-32
    80004752:	ec06                	sd	ra,24(sp)
    80004754:	e822                	sd	s0,16(sp)
    80004756:	e426                	sd	s1,8(sp)
    80004758:	e04a                	sd	s2,0(sp)
    8000475a:	1000                	addi	s0,sp,32
    8000475c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000475e:	0001e917          	auipc	s2,0x1e
    80004762:	9f290913          	addi	s2,s2,-1550 # 80022150 <log>
    80004766:	854a                	mv	a0,s2
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	46e080e7          	jalr	1134(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004770:	02c92603          	lw	a2,44(s2)
    80004774:	47f5                	li	a5,29
    80004776:	06c7c563          	blt	a5,a2,800047e0 <log_write+0x90>
    8000477a:	0001e797          	auipc	a5,0x1e
    8000477e:	9f27a783          	lw	a5,-1550(a5) # 8002216c <log+0x1c>
    80004782:	37fd                	addiw	a5,a5,-1
    80004784:	04f65e63          	bge	a2,a5,800047e0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004788:	0001e797          	auipc	a5,0x1e
    8000478c:	9e87a783          	lw	a5,-1560(a5) # 80022170 <log+0x20>
    80004790:	06f05063          	blez	a5,800047f0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004794:	4781                	li	a5,0
    80004796:	06c05563          	blez	a2,80004800 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000479a:	44cc                	lw	a1,12(s1)
    8000479c:	0001e717          	auipc	a4,0x1e
    800047a0:	9e470713          	addi	a4,a4,-1564 # 80022180 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047a4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047a6:	4314                	lw	a3,0(a4)
    800047a8:	04b68c63          	beq	a3,a1,80004800 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047ac:	2785                	addiw	a5,a5,1
    800047ae:	0711                	addi	a4,a4,4
    800047b0:	fef61be3          	bne	a2,a5,800047a6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047b4:	0621                	addi	a2,a2,8
    800047b6:	060a                	slli	a2,a2,0x2
    800047b8:	0001e797          	auipc	a5,0x1e
    800047bc:	99878793          	addi	a5,a5,-1640 # 80022150 <log>
    800047c0:	963e                	add	a2,a2,a5
    800047c2:	44dc                	lw	a5,12(s1)
    800047c4:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047c6:	8526                	mv	a0,s1
    800047c8:	fffff097          	auipc	ra,0xfffff
    800047cc:	da2080e7          	jalr	-606(ra) # 8000356a <bpin>
    log.lh.n++;
    800047d0:	0001e717          	auipc	a4,0x1e
    800047d4:	98070713          	addi	a4,a4,-1664 # 80022150 <log>
    800047d8:	575c                	lw	a5,44(a4)
    800047da:	2785                	addiw	a5,a5,1
    800047dc:	d75c                	sw	a5,44(a4)
    800047de:	a835                	j	8000481a <log_write+0xca>
    panic("too big a transaction");
    800047e0:	00004517          	auipc	a0,0x4
    800047e4:	e8050513          	addi	a0,a0,-384 # 80008660 <syscalls+0x210>
    800047e8:	ffffc097          	auipc	ra,0xffffc
    800047ec:	d56080e7          	jalr	-682(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800047f0:	00004517          	auipc	a0,0x4
    800047f4:	e8850513          	addi	a0,a0,-376 # 80008678 <syscalls+0x228>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	d46080e7          	jalr	-698(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004800:	00878713          	addi	a4,a5,8
    80004804:	00271693          	slli	a3,a4,0x2
    80004808:	0001e717          	auipc	a4,0x1e
    8000480c:	94870713          	addi	a4,a4,-1720 # 80022150 <log>
    80004810:	9736                	add	a4,a4,a3
    80004812:	44d4                	lw	a3,12(s1)
    80004814:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004816:	faf608e3          	beq	a2,a5,800047c6 <log_write+0x76>
  }
  release(&log.lock);
    8000481a:	0001e517          	auipc	a0,0x1e
    8000481e:	93650513          	addi	a0,a0,-1738 # 80022150 <log>
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	468080e7          	jalr	1128(ra) # 80000c8a <release>
}
    8000482a:	60e2                	ld	ra,24(sp)
    8000482c:	6442                	ld	s0,16(sp)
    8000482e:	64a2                	ld	s1,8(sp)
    80004830:	6902                	ld	s2,0(sp)
    80004832:	6105                	addi	sp,sp,32
    80004834:	8082                	ret

0000000080004836 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004836:	1101                	addi	sp,sp,-32
    80004838:	ec06                	sd	ra,24(sp)
    8000483a:	e822                	sd	s0,16(sp)
    8000483c:	e426                	sd	s1,8(sp)
    8000483e:	e04a                	sd	s2,0(sp)
    80004840:	1000                	addi	s0,sp,32
    80004842:	84aa                	mv	s1,a0
    80004844:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004846:	00004597          	auipc	a1,0x4
    8000484a:	e5258593          	addi	a1,a1,-430 # 80008698 <syscalls+0x248>
    8000484e:	0521                	addi	a0,a0,8
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	2f6080e7          	jalr	758(ra) # 80000b46 <initlock>
  lk->name = name;
    80004858:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000485c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004860:	0204a423          	sw	zero,40(s1)
}
    80004864:	60e2                	ld	ra,24(sp)
    80004866:	6442                	ld	s0,16(sp)
    80004868:	64a2                	ld	s1,8(sp)
    8000486a:	6902                	ld	s2,0(sp)
    8000486c:	6105                	addi	sp,sp,32
    8000486e:	8082                	ret

0000000080004870 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004870:	1101                	addi	sp,sp,-32
    80004872:	ec06                	sd	ra,24(sp)
    80004874:	e822                	sd	s0,16(sp)
    80004876:	e426                	sd	s1,8(sp)
    80004878:	e04a                	sd	s2,0(sp)
    8000487a:	1000                	addi	s0,sp,32
    8000487c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000487e:	00850913          	addi	s2,a0,8
    80004882:	854a                	mv	a0,s2
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	352080e7          	jalr	850(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000488c:	409c                	lw	a5,0(s1)
    8000488e:	cb89                	beqz	a5,800048a0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004890:	85ca                	mv	a1,s2
    80004892:	8526                	mv	a0,s1
    80004894:	ffffe097          	auipc	ra,0xffffe
    80004898:	9a8080e7          	jalr	-1624(ra) # 8000223c <sleep>
  while (lk->locked) {
    8000489c:	409c                	lw	a5,0(s1)
    8000489e:	fbed                	bnez	a5,80004890 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048a0:	4785                	li	a5,1
    800048a2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048a4:	ffffd097          	auipc	ra,0xffffd
    800048a8:	2ac080e7          	jalr	684(ra) # 80001b50 <myproc>
    800048ac:	413c                	lw	a5,64(a0)
    800048ae:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048b0:	854a                	mv	a0,s2
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	3d8080e7          	jalr	984(ra) # 80000c8a <release>
}
    800048ba:	60e2                	ld	ra,24(sp)
    800048bc:	6442                	ld	s0,16(sp)
    800048be:	64a2                	ld	s1,8(sp)
    800048c0:	6902                	ld	s2,0(sp)
    800048c2:	6105                	addi	sp,sp,32
    800048c4:	8082                	ret

00000000800048c6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048c6:	1101                	addi	sp,sp,-32
    800048c8:	ec06                	sd	ra,24(sp)
    800048ca:	e822                	sd	s0,16(sp)
    800048cc:	e426                	sd	s1,8(sp)
    800048ce:	e04a                	sd	s2,0(sp)
    800048d0:	1000                	addi	s0,sp,32
    800048d2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048d4:	00850913          	addi	s2,a0,8
    800048d8:	854a                	mv	a0,s2
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	2fc080e7          	jalr	764(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800048e2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048e6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048ea:	8526                	mv	a0,s1
    800048ec:	ffffe097          	auipc	ra,0xffffe
    800048f0:	9b4080e7          	jalr	-1612(ra) # 800022a0 <wakeup>
  release(&lk->lk);
    800048f4:	854a                	mv	a0,s2
    800048f6:	ffffc097          	auipc	ra,0xffffc
    800048fa:	394080e7          	jalr	916(ra) # 80000c8a <release>
}
    800048fe:	60e2                	ld	ra,24(sp)
    80004900:	6442                	ld	s0,16(sp)
    80004902:	64a2                	ld	s1,8(sp)
    80004904:	6902                	ld	s2,0(sp)
    80004906:	6105                	addi	sp,sp,32
    80004908:	8082                	ret

000000008000490a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000490a:	7179                	addi	sp,sp,-48
    8000490c:	f406                	sd	ra,40(sp)
    8000490e:	f022                	sd	s0,32(sp)
    80004910:	ec26                	sd	s1,24(sp)
    80004912:	e84a                	sd	s2,16(sp)
    80004914:	e44e                	sd	s3,8(sp)
    80004916:	1800                	addi	s0,sp,48
    80004918:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000491a:	00850913          	addi	s2,a0,8
    8000491e:	854a                	mv	a0,s2
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	2b6080e7          	jalr	694(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004928:	409c                	lw	a5,0(s1)
    8000492a:	ef99                	bnez	a5,80004948 <holdingsleep+0x3e>
    8000492c:	4481                	li	s1,0
  release(&lk->lk);
    8000492e:	854a                	mv	a0,s2
    80004930:	ffffc097          	auipc	ra,0xffffc
    80004934:	35a080e7          	jalr	858(ra) # 80000c8a <release>
  return r;
}
    80004938:	8526                	mv	a0,s1
    8000493a:	70a2                	ld	ra,40(sp)
    8000493c:	7402                	ld	s0,32(sp)
    8000493e:	64e2                	ld	s1,24(sp)
    80004940:	6942                	ld	s2,16(sp)
    80004942:	69a2                	ld	s3,8(sp)
    80004944:	6145                	addi	sp,sp,48
    80004946:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004948:	0284a983          	lw	s3,40(s1)
    8000494c:	ffffd097          	auipc	ra,0xffffd
    80004950:	204080e7          	jalr	516(ra) # 80001b50 <myproc>
    80004954:	4124                	lw	s1,64(a0)
    80004956:	413484b3          	sub	s1,s1,s3
    8000495a:	0014b493          	seqz	s1,s1
    8000495e:	bfc1                	j	8000492e <holdingsleep+0x24>

0000000080004960 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004960:	1141                	addi	sp,sp,-16
    80004962:	e406                	sd	ra,8(sp)
    80004964:	e022                	sd	s0,0(sp)
    80004966:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004968:	00004597          	auipc	a1,0x4
    8000496c:	d4058593          	addi	a1,a1,-704 # 800086a8 <syscalls+0x258>
    80004970:	0001e517          	auipc	a0,0x1e
    80004974:	92850513          	addi	a0,a0,-1752 # 80022298 <ftable>
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	1ce080e7          	jalr	462(ra) # 80000b46 <initlock>
}
    80004980:	60a2                	ld	ra,8(sp)
    80004982:	6402                	ld	s0,0(sp)
    80004984:	0141                	addi	sp,sp,16
    80004986:	8082                	ret

0000000080004988 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004988:	1101                	addi	sp,sp,-32
    8000498a:	ec06                	sd	ra,24(sp)
    8000498c:	e822                	sd	s0,16(sp)
    8000498e:	e426                	sd	s1,8(sp)
    80004990:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004992:	0001e517          	auipc	a0,0x1e
    80004996:	90650513          	addi	a0,a0,-1786 # 80022298 <ftable>
    8000499a:	ffffc097          	auipc	ra,0xffffc
    8000499e:	23c080e7          	jalr	572(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049a2:	0001e497          	auipc	s1,0x1e
    800049a6:	90e48493          	addi	s1,s1,-1778 # 800222b0 <ftable+0x18>
    800049aa:	0001f717          	auipc	a4,0x1f
    800049ae:	8a670713          	addi	a4,a4,-1882 # 80023250 <disk>
    if(f->ref == 0){
    800049b2:	40dc                	lw	a5,4(s1)
    800049b4:	cf99                	beqz	a5,800049d2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049b6:	02848493          	addi	s1,s1,40
    800049ba:	fee49ce3          	bne	s1,a4,800049b2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049be:	0001e517          	auipc	a0,0x1e
    800049c2:	8da50513          	addi	a0,a0,-1830 # 80022298 <ftable>
    800049c6:	ffffc097          	auipc	ra,0xffffc
    800049ca:	2c4080e7          	jalr	708(ra) # 80000c8a <release>
  return 0;
    800049ce:	4481                	li	s1,0
    800049d0:	a819                	j	800049e6 <filealloc+0x5e>
      f->ref = 1;
    800049d2:	4785                	li	a5,1
    800049d4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049d6:	0001e517          	auipc	a0,0x1e
    800049da:	8c250513          	addi	a0,a0,-1854 # 80022298 <ftable>
    800049de:	ffffc097          	auipc	ra,0xffffc
    800049e2:	2ac080e7          	jalr	684(ra) # 80000c8a <release>
}
    800049e6:	8526                	mv	a0,s1
    800049e8:	60e2                	ld	ra,24(sp)
    800049ea:	6442                	ld	s0,16(sp)
    800049ec:	64a2                	ld	s1,8(sp)
    800049ee:	6105                	addi	sp,sp,32
    800049f0:	8082                	ret

00000000800049f2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049f2:	1101                	addi	sp,sp,-32
    800049f4:	ec06                	sd	ra,24(sp)
    800049f6:	e822                	sd	s0,16(sp)
    800049f8:	e426                	sd	s1,8(sp)
    800049fa:	1000                	addi	s0,sp,32
    800049fc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049fe:	0001e517          	auipc	a0,0x1e
    80004a02:	89a50513          	addi	a0,a0,-1894 # 80022298 <ftable>
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	1d0080e7          	jalr	464(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a0e:	40dc                	lw	a5,4(s1)
    80004a10:	02f05263          	blez	a5,80004a34 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a14:	2785                	addiw	a5,a5,1
    80004a16:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a18:	0001e517          	auipc	a0,0x1e
    80004a1c:	88050513          	addi	a0,a0,-1920 # 80022298 <ftable>
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	26a080e7          	jalr	618(ra) # 80000c8a <release>
  return f;
}
    80004a28:	8526                	mv	a0,s1
    80004a2a:	60e2                	ld	ra,24(sp)
    80004a2c:	6442                	ld	s0,16(sp)
    80004a2e:	64a2                	ld	s1,8(sp)
    80004a30:	6105                	addi	sp,sp,32
    80004a32:	8082                	ret
    panic("filedup");
    80004a34:	00004517          	auipc	a0,0x4
    80004a38:	c7c50513          	addi	a0,a0,-900 # 800086b0 <syscalls+0x260>
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	b02080e7          	jalr	-1278(ra) # 8000053e <panic>

0000000080004a44 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a44:	7139                	addi	sp,sp,-64
    80004a46:	fc06                	sd	ra,56(sp)
    80004a48:	f822                	sd	s0,48(sp)
    80004a4a:	f426                	sd	s1,40(sp)
    80004a4c:	f04a                	sd	s2,32(sp)
    80004a4e:	ec4e                	sd	s3,24(sp)
    80004a50:	e852                	sd	s4,16(sp)
    80004a52:	e456                	sd	s5,8(sp)
    80004a54:	0080                	addi	s0,sp,64
    80004a56:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a58:	0001e517          	auipc	a0,0x1e
    80004a5c:	84050513          	addi	a0,a0,-1984 # 80022298 <ftable>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	176080e7          	jalr	374(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a68:	40dc                	lw	a5,4(s1)
    80004a6a:	06f05163          	blez	a5,80004acc <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a6e:	37fd                	addiw	a5,a5,-1
    80004a70:	0007871b          	sext.w	a4,a5
    80004a74:	c0dc                	sw	a5,4(s1)
    80004a76:	06e04363          	bgtz	a4,80004adc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a7a:	0004a903          	lw	s2,0(s1)
    80004a7e:	0094ca83          	lbu	s5,9(s1)
    80004a82:	0104ba03          	ld	s4,16(s1)
    80004a86:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a8a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a8e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a92:	0001e517          	auipc	a0,0x1e
    80004a96:	80650513          	addi	a0,a0,-2042 # 80022298 <ftable>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	1f0080e7          	jalr	496(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004aa2:	4785                	li	a5,1
    80004aa4:	04f90d63          	beq	s2,a5,80004afe <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004aa8:	3979                	addiw	s2,s2,-2
    80004aaa:	4785                	li	a5,1
    80004aac:	0527e063          	bltu	a5,s2,80004aec <fileclose+0xa8>
    begin_op();
    80004ab0:	00000097          	auipc	ra,0x0
    80004ab4:	ac8080e7          	jalr	-1336(ra) # 80004578 <begin_op>
    iput(ff.ip);
    80004ab8:	854e                	mv	a0,s3
    80004aba:	fffff097          	auipc	ra,0xfffff
    80004abe:	2b6080e7          	jalr	694(ra) # 80003d70 <iput>
    end_op();
    80004ac2:	00000097          	auipc	ra,0x0
    80004ac6:	b36080e7          	jalr	-1226(ra) # 800045f8 <end_op>
    80004aca:	a00d                	j	80004aec <fileclose+0xa8>
    panic("fileclose");
    80004acc:	00004517          	auipc	a0,0x4
    80004ad0:	bec50513          	addi	a0,a0,-1044 # 800086b8 <syscalls+0x268>
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	a6a080e7          	jalr	-1430(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004adc:	0001d517          	auipc	a0,0x1d
    80004ae0:	7bc50513          	addi	a0,a0,1980 # 80022298 <ftable>
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	1a6080e7          	jalr	422(ra) # 80000c8a <release>
  }
}
    80004aec:	70e2                	ld	ra,56(sp)
    80004aee:	7442                	ld	s0,48(sp)
    80004af0:	74a2                	ld	s1,40(sp)
    80004af2:	7902                	ld	s2,32(sp)
    80004af4:	69e2                	ld	s3,24(sp)
    80004af6:	6a42                	ld	s4,16(sp)
    80004af8:	6aa2                	ld	s5,8(sp)
    80004afa:	6121                	addi	sp,sp,64
    80004afc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004afe:	85d6                	mv	a1,s5
    80004b00:	8552                	mv	a0,s4
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	34c080e7          	jalr	844(ra) # 80004e4e <pipeclose>
    80004b0a:	b7cd                	j	80004aec <fileclose+0xa8>

0000000080004b0c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b0c:	715d                	addi	sp,sp,-80
    80004b0e:	e486                	sd	ra,72(sp)
    80004b10:	e0a2                	sd	s0,64(sp)
    80004b12:	fc26                	sd	s1,56(sp)
    80004b14:	f84a                	sd	s2,48(sp)
    80004b16:	f44e                	sd	s3,40(sp)
    80004b18:	0880                	addi	s0,sp,80
    80004b1a:	84aa                	mv	s1,a0
    80004b1c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b1e:	ffffd097          	auipc	ra,0xffffd
    80004b22:	032080e7          	jalr	50(ra) # 80001b50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b26:	409c                	lw	a5,0(s1)
    80004b28:	37f9                	addiw	a5,a5,-2
    80004b2a:	4705                	li	a4,1
    80004b2c:	04f76763          	bltu	a4,a5,80004b7a <filestat+0x6e>
    80004b30:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b32:	6c88                	ld	a0,24(s1)
    80004b34:	fffff097          	auipc	ra,0xfffff
    80004b38:	082080e7          	jalr	130(ra) # 80003bb6 <ilock>
    stati(f->ip, &st);
    80004b3c:	fb840593          	addi	a1,s0,-72
    80004b40:	6c88                	ld	a0,24(s1)
    80004b42:	fffff097          	auipc	ra,0xfffff
    80004b46:	2fe080e7          	jalr	766(ra) # 80003e40 <stati>
    iunlock(f->ip);
    80004b4a:	6c88                	ld	a0,24(s1)
    80004b4c:	fffff097          	auipc	ra,0xfffff
    80004b50:	12c080e7          	jalr	300(ra) # 80003c78 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b54:	46e1                	li	a3,24
    80004b56:	fb840613          	addi	a2,s0,-72
    80004b5a:	85ce                	mv	a1,s3
    80004b5c:	06093503          	ld	a0,96(s2)
    80004b60:	ffffd097          	auipc	ra,0xffffd
    80004b64:	b10080e7          	jalr	-1264(ra) # 80001670 <copyout>
    80004b68:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b6c:	60a6                	ld	ra,72(sp)
    80004b6e:	6406                	ld	s0,64(sp)
    80004b70:	74e2                	ld	s1,56(sp)
    80004b72:	7942                	ld	s2,48(sp)
    80004b74:	79a2                	ld	s3,40(sp)
    80004b76:	6161                	addi	sp,sp,80
    80004b78:	8082                	ret
  return -1;
    80004b7a:	557d                	li	a0,-1
    80004b7c:	bfc5                	j	80004b6c <filestat+0x60>

0000000080004b7e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b7e:	7179                	addi	sp,sp,-48
    80004b80:	f406                	sd	ra,40(sp)
    80004b82:	f022                	sd	s0,32(sp)
    80004b84:	ec26                	sd	s1,24(sp)
    80004b86:	e84a                	sd	s2,16(sp)
    80004b88:	e44e                	sd	s3,8(sp)
    80004b8a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b8c:	00854783          	lbu	a5,8(a0)
    80004b90:	c3d5                	beqz	a5,80004c34 <fileread+0xb6>
    80004b92:	84aa                	mv	s1,a0
    80004b94:	89ae                	mv	s3,a1
    80004b96:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b98:	411c                	lw	a5,0(a0)
    80004b9a:	4705                	li	a4,1
    80004b9c:	04e78963          	beq	a5,a4,80004bee <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ba0:	470d                	li	a4,3
    80004ba2:	04e78d63          	beq	a5,a4,80004bfc <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ba6:	4709                	li	a4,2
    80004ba8:	06e79e63          	bne	a5,a4,80004c24 <fileread+0xa6>
    ilock(f->ip);
    80004bac:	6d08                	ld	a0,24(a0)
    80004bae:	fffff097          	auipc	ra,0xfffff
    80004bb2:	008080e7          	jalr	8(ra) # 80003bb6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bb6:	874a                	mv	a4,s2
    80004bb8:	5094                	lw	a3,32(s1)
    80004bba:	864e                	mv	a2,s3
    80004bbc:	4585                	li	a1,1
    80004bbe:	6c88                	ld	a0,24(s1)
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	2aa080e7          	jalr	682(ra) # 80003e6a <readi>
    80004bc8:	892a                	mv	s2,a0
    80004bca:	00a05563          	blez	a0,80004bd4 <fileread+0x56>
      f->off += r;
    80004bce:	509c                	lw	a5,32(s1)
    80004bd0:	9fa9                	addw	a5,a5,a0
    80004bd2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004bd4:	6c88                	ld	a0,24(s1)
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	0a2080e7          	jalr	162(ra) # 80003c78 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004bde:	854a                	mv	a0,s2
    80004be0:	70a2                	ld	ra,40(sp)
    80004be2:	7402                	ld	s0,32(sp)
    80004be4:	64e2                	ld	s1,24(sp)
    80004be6:	6942                	ld	s2,16(sp)
    80004be8:	69a2                	ld	s3,8(sp)
    80004bea:	6145                	addi	sp,sp,48
    80004bec:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004bee:	6908                	ld	a0,16(a0)
    80004bf0:	00000097          	auipc	ra,0x0
    80004bf4:	3c6080e7          	jalr	966(ra) # 80004fb6 <piperead>
    80004bf8:	892a                	mv	s2,a0
    80004bfa:	b7d5                	j	80004bde <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bfc:	02451783          	lh	a5,36(a0)
    80004c00:	03079693          	slli	a3,a5,0x30
    80004c04:	92c1                	srli	a3,a3,0x30
    80004c06:	4725                	li	a4,9
    80004c08:	02d76863          	bltu	a4,a3,80004c38 <fileread+0xba>
    80004c0c:	0792                	slli	a5,a5,0x4
    80004c0e:	0001d717          	auipc	a4,0x1d
    80004c12:	5ea70713          	addi	a4,a4,1514 # 800221f8 <devsw>
    80004c16:	97ba                	add	a5,a5,a4
    80004c18:	639c                	ld	a5,0(a5)
    80004c1a:	c38d                	beqz	a5,80004c3c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c1c:	4505                	li	a0,1
    80004c1e:	9782                	jalr	a5
    80004c20:	892a                	mv	s2,a0
    80004c22:	bf75                	j	80004bde <fileread+0x60>
    panic("fileread");
    80004c24:	00004517          	auipc	a0,0x4
    80004c28:	aa450513          	addi	a0,a0,-1372 # 800086c8 <syscalls+0x278>
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	912080e7          	jalr	-1774(ra) # 8000053e <panic>
    return -1;
    80004c34:	597d                	li	s2,-1
    80004c36:	b765                	j	80004bde <fileread+0x60>
      return -1;
    80004c38:	597d                	li	s2,-1
    80004c3a:	b755                	j	80004bde <fileread+0x60>
    80004c3c:	597d                	li	s2,-1
    80004c3e:	b745                	j	80004bde <fileread+0x60>

0000000080004c40 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c40:	715d                	addi	sp,sp,-80
    80004c42:	e486                	sd	ra,72(sp)
    80004c44:	e0a2                	sd	s0,64(sp)
    80004c46:	fc26                	sd	s1,56(sp)
    80004c48:	f84a                	sd	s2,48(sp)
    80004c4a:	f44e                	sd	s3,40(sp)
    80004c4c:	f052                	sd	s4,32(sp)
    80004c4e:	ec56                	sd	s5,24(sp)
    80004c50:	e85a                	sd	s6,16(sp)
    80004c52:	e45e                	sd	s7,8(sp)
    80004c54:	e062                	sd	s8,0(sp)
    80004c56:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c58:	00954783          	lbu	a5,9(a0)
    80004c5c:	10078663          	beqz	a5,80004d68 <filewrite+0x128>
    80004c60:	892a                	mv	s2,a0
    80004c62:	8aae                	mv	s5,a1
    80004c64:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c66:	411c                	lw	a5,0(a0)
    80004c68:	4705                	li	a4,1
    80004c6a:	02e78263          	beq	a5,a4,80004c8e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c6e:	470d                	li	a4,3
    80004c70:	02e78663          	beq	a5,a4,80004c9c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c74:	4709                	li	a4,2
    80004c76:	0ee79163          	bne	a5,a4,80004d58 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c7a:	0ac05d63          	blez	a2,80004d34 <filewrite+0xf4>
    int i = 0;
    80004c7e:	4981                	li	s3,0
    80004c80:	6b05                	lui	s6,0x1
    80004c82:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c86:	6b85                	lui	s7,0x1
    80004c88:	c00b8b9b          	addiw	s7,s7,-1024
    80004c8c:	a861                	j	80004d24 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c8e:	6908                	ld	a0,16(a0)
    80004c90:	00000097          	auipc	ra,0x0
    80004c94:	22e080e7          	jalr	558(ra) # 80004ebe <pipewrite>
    80004c98:	8a2a                	mv	s4,a0
    80004c9a:	a045                	j	80004d3a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c9c:	02451783          	lh	a5,36(a0)
    80004ca0:	03079693          	slli	a3,a5,0x30
    80004ca4:	92c1                	srli	a3,a3,0x30
    80004ca6:	4725                	li	a4,9
    80004ca8:	0cd76263          	bltu	a4,a3,80004d6c <filewrite+0x12c>
    80004cac:	0792                	slli	a5,a5,0x4
    80004cae:	0001d717          	auipc	a4,0x1d
    80004cb2:	54a70713          	addi	a4,a4,1354 # 800221f8 <devsw>
    80004cb6:	97ba                	add	a5,a5,a4
    80004cb8:	679c                	ld	a5,8(a5)
    80004cba:	cbdd                	beqz	a5,80004d70 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004cbc:	4505                	li	a0,1
    80004cbe:	9782                	jalr	a5
    80004cc0:	8a2a                	mv	s4,a0
    80004cc2:	a8a5                	j	80004d3a <filewrite+0xfa>
    80004cc4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004cc8:	00000097          	auipc	ra,0x0
    80004ccc:	8b0080e7          	jalr	-1872(ra) # 80004578 <begin_op>
      ilock(f->ip);
    80004cd0:	01893503          	ld	a0,24(s2)
    80004cd4:	fffff097          	auipc	ra,0xfffff
    80004cd8:	ee2080e7          	jalr	-286(ra) # 80003bb6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004cdc:	8762                	mv	a4,s8
    80004cde:	02092683          	lw	a3,32(s2)
    80004ce2:	01598633          	add	a2,s3,s5
    80004ce6:	4585                	li	a1,1
    80004ce8:	01893503          	ld	a0,24(s2)
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	276080e7          	jalr	630(ra) # 80003f62 <writei>
    80004cf4:	84aa                	mv	s1,a0
    80004cf6:	00a05763          	blez	a0,80004d04 <filewrite+0xc4>
        f->off += r;
    80004cfa:	02092783          	lw	a5,32(s2)
    80004cfe:	9fa9                	addw	a5,a5,a0
    80004d00:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d04:	01893503          	ld	a0,24(s2)
    80004d08:	fffff097          	auipc	ra,0xfffff
    80004d0c:	f70080e7          	jalr	-144(ra) # 80003c78 <iunlock>
      end_op();
    80004d10:	00000097          	auipc	ra,0x0
    80004d14:	8e8080e7          	jalr	-1816(ra) # 800045f8 <end_op>

      if(r != n1){
    80004d18:	009c1f63          	bne	s8,s1,80004d36 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d1c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d20:	0149db63          	bge	s3,s4,80004d36 <filewrite+0xf6>
      int n1 = n - i;
    80004d24:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d28:	84be                	mv	s1,a5
    80004d2a:	2781                	sext.w	a5,a5
    80004d2c:	f8fb5ce3          	bge	s6,a5,80004cc4 <filewrite+0x84>
    80004d30:	84de                	mv	s1,s7
    80004d32:	bf49                	j	80004cc4 <filewrite+0x84>
    int i = 0;
    80004d34:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d36:	013a1f63          	bne	s4,s3,80004d54 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d3a:	8552                	mv	a0,s4
    80004d3c:	60a6                	ld	ra,72(sp)
    80004d3e:	6406                	ld	s0,64(sp)
    80004d40:	74e2                	ld	s1,56(sp)
    80004d42:	7942                	ld	s2,48(sp)
    80004d44:	79a2                	ld	s3,40(sp)
    80004d46:	7a02                	ld	s4,32(sp)
    80004d48:	6ae2                	ld	s5,24(sp)
    80004d4a:	6b42                	ld	s6,16(sp)
    80004d4c:	6ba2                	ld	s7,8(sp)
    80004d4e:	6c02                	ld	s8,0(sp)
    80004d50:	6161                	addi	sp,sp,80
    80004d52:	8082                	ret
    ret = (i == n ? n : -1);
    80004d54:	5a7d                	li	s4,-1
    80004d56:	b7d5                	j	80004d3a <filewrite+0xfa>
    panic("filewrite");
    80004d58:	00004517          	auipc	a0,0x4
    80004d5c:	98050513          	addi	a0,a0,-1664 # 800086d8 <syscalls+0x288>
    80004d60:	ffffb097          	auipc	ra,0xffffb
    80004d64:	7de080e7          	jalr	2014(ra) # 8000053e <panic>
    return -1;
    80004d68:	5a7d                	li	s4,-1
    80004d6a:	bfc1                	j	80004d3a <filewrite+0xfa>
      return -1;
    80004d6c:	5a7d                	li	s4,-1
    80004d6e:	b7f1                	j	80004d3a <filewrite+0xfa>
    80004d70:	5a7d                	li	s4,-1
    80004d72:	b7e1                	j	80004d3a <filewrite+0xfa>

0000000080004d74 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d74:	7179                	addi	sp,sp,-48
    80004d76:	f406                	sd	ra,40(sp)
    80004d78:	f022                	sd	s0,32(sp)
    80004d7a:	ec26                	sd	s1,24(sp)
    80004d7c:	e84a                	sd	s2,16(sp)
    80004d7e:	e44e                	sd	s3,8(sp)
    80004d80:	e052                	sd	s4,0(sp)
    80004d82:	1800                	addi	s0,sp,48
    80004d84:	84aa                	mv	s1,a0
    80004d86:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d88:	0005b023          	sd	zero,0(a1)
    80004d8c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d90:	00000097          	auipc	ra,0x0
    80004d94:	bf8080e7          	jalr	-1032(ra) # 80004988 <filealloc>
    80004d98:	e088                	sd	a0,0(s1)
    80004d9a:	c551                	beqz	a0,80004e26 <pipealloc+0xb2>
    80004d9c:	00000097          	auipc	ra,0x0
    80004da0:	bec080e7          	jalr	-1044(ra) # 80004988 <filealloc>
    80004da4:	00aa3023          	sd	a0,0(s4)
    80004da8:	c92d                	beqz	a0,80004e1a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004daa:	ffffc097          	auipc	ra,0xffffc
    80004dae:	d3c080e7          	jalr	-708(ra) # 80000ae6 <kalloc>
    80004db2:	892a                	mv	s2,a0
    80004db4:	c125                	beqz	a0,80004e14 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004db6:	4985                	li	s3,1
    80004db8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004dbc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004dc0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004dc4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004dc8:	00004597          	auipc	a1,0x4
    80004dcc:	92058593          	addi	a1,a1,-1760 # 800086e8 <syscalls+0x298>
    80004dd0:	ffffc097          	auipc	ra,0xffffc
    80004dd4:	d76080e7          	jalr	-650(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004dd8:	609c                	ld	a5,0(s1)
    80004dda:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004dde:	609c                	ld	a5,0(s1)
    80004de0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004de4:	609c                	ld	a5,0(s1)
    80004de6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004dea:	609c                	ld	a5,0(s1)
    80004dec:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004df0:	000a3783          	ld	a5,0(s4)
    80004df4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004df8:	000a3783          	ld	a5,0(s4)
    80004dfc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e00:	000a3783          	ld	a5,0(s4)
    80004e04:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e08:	000a3783          	ld	a5,0(s4)
    80004e0c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e10:	4501                	li	a0,0
    80004e12:	a025                	j	80004e3a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e14:	6088                	ld	a0,0(s1)
    80004e16:	e501                	bnez	a0,80004e1e <pipealloc+0xaa>
    80004e18:	a039                	j	80004e26 <pipealloc+0xb2>
    80004e1a:	6088                	ld	a0,0(s1)
    80004e1c:	c51d                	beqz	a0,80004e4a <pipealloc+0xd6>
    fileclose(*f0);
    80004e1e:	00000097          	auipc	ra,0x0
    80004e22:	c26080e7          	jalr	-986(ra) # 80004a44 <fileclose>
  if(*f1)
    80004e26:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e2a:	557d                	li	a0,-1
  if(*f1)
    80004e2c:	c799                	beqz	a5,80004e3a <pipealloc+0xc6>
    fileclose(*f1);
    80004e2e:	853e                	mv	a0,a5
    80004e30:	00000097          	auipc	ra,0x0
    80004e34:	c14080e7          	jalr	-1004(ra) # 80004a44 <fileclose>
  return -1;
    80004e38:	557d                	li	a0,-1
}
    80004e3a:	70a2                	ld	ra,40(sp)
    80004e3c:	7402                	ld	s0,32(sp)
    80004e3e:	64e2                	ld	s1,24(sp)
    80004e40:	6942                	ld	s2,16(sp)
    80004e42:	69a2                	ld	s3,8(sp)
    80004e44:	6a02                	ld	s4,0(sp)
    80004e46:	6145                	addi	sp,sp,48
    80004e48:	8082                	ret
  return -1;
    80004e4a:	557d                	li	a0,-1
    80004e4c:	b7fd                	j	80004e3a <pipealloc+0xc6>

0000000080004e4e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e4e:	1101                	addi	sp,sp,-32
    80004e50:	ec06                	sd	ra,24(sp)
    80004e52:	e822                	sd	s0,16(sp)
    80004e54:	e426                	sd	s1,8(sp)
    80004e56:	e04a                	sd	s2,0(sp)
    80004e58:	1000                	addi	s0,sp,32
    80004e5a:	84aa                	mv	s1,a0
    80004e5c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e5e:	ffffc097          	auipc	ra,0xffffc
    80004e62:	d78080e7          	jalr	-648(ra) # 80000bd6 <acquire>
  if(writable){
    80004e66:	02090d63          	beqz	s2,80004ea0 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e6a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e6e:	21848513          	addi	a0,s1,536
    80004e72:	ffffd097          	auipc	ra,0xffffd
    80004e76:	42e080e7          	jalr	1070(ra) # 800022a0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e7a:	2204b783          	ld	a5,544(s1)
    80004e7e:	eb95                	bnez	a5,80004eb2 <pipeclose+0x64>
    release(&pi->lock);
    80004e80:	8526                	mv	a0,s1
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	e08080e7          	jalr	-504(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	b5e080e7          	jalr	-1186(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004e94:	60e2                	ld	ra,24(sp)
    80004e96:	6442                	ld	s0,16(sp)
    80004e98:	64a2                	ld	s1,8(sp)
    80004e9a:	6902                	ld	s2,0(sp)
    80004e9c:	6105                	addi	sp,sp,32
    80004e9e:	8082                	ret
    pi->readopen = 0;
    80004ea0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ea4:	21c48513          	addi	a0,s1,540
    80004ea8:	ffffd097          	auipc	ra,0xffffd
    80004eac:	3f8080e7          	jalr	1016(ra) # 800022a0 <wakeup>
    80004eb0:	b7e9                	j	80004e7a <pipeclose+0x2c>
    release(&pi->lock);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	dd6080e7          	jalr	-554(ra) # 80000c8a <release>
}
    80004ebc:	bfe1                	j	80004e94 <pipeclose+0x46>

0000000080004ebe <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ebe:	711d                	addi	sp,sp,-96
    80004ec0:	ec86                	sd	ra,88(sp)
    80004ec2:	e8a2                	sd	s0,80(sp)
    80004ec4:	e4a6                	sd	s1,72(sp)
    80004ec6:	e0ca                	sd	s2,64(sp)
    80004ec8:	fc4e                	sd	s3,56(sp)
    80004eca:	f852                	sd	s4,48(sp)
    80004ecc:	f456                	sd	s5,40(sp)
    80004ece:	f05a                	sd	s6,32(sp)
    80004ed0:	ec5e                	sd	s7,24(sp)
    80004ed2:	e862                	sd	s8,16(sp)
    80004ed4:	1080                	addi	s0,sp,96
    80004ed6:	84aa                	mv	s1,a0
    80004ed8:	8aae                	mv	s5,a1
    80004eda:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004edc:	ffffd097          	auipc	ra,0xffffd
    80004ee0:	c74080e7          	jalr	-908(ra) # 80001b50 <myproc>
    80004ee4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	cee080e7          	jalr	-786(ra) # 80000bd6 <acquire>
  while(i < n){
    80004ef0:	0b405663          	blez	s4,80004f9c <pipewrite+0xde>
  int i = 0;
    80004ef4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ef6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ef8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004efc:	21c48b93          	addi	s7,s1,540
    80004f00:	a089                	j	80004f42 <pipewrite+0x84>
      release(&pi->lock);
    80004f02:	8526                	mv	a0,s1
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	d86080e7          	jalr	-634(ra) # 80000c8a <release>
      return -1;
    80004f0c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f0e:	854a                	mv	a0,s2
    80004f10:	60e6                	ld	ra,88(sp)
    80004f12:	6446                	ld	s0,80(sp)
    80004f14:	64a6                	ld	s1,72(sp)
    80004f16:	6906                	ld	s2,64(sp)
    80004f18:	79e2                	ld	s3,56(sp)
    80004f1a:	7a42                	ld	s4,48(sp)
    80004f1c:	7aa2                	ld	s5,40(sp)
    80004f1e:	7b02                	ld	s6,32(sp)
    80004f20:	6be2                	ld	s7,24(sp)
    80004f22:	6c42                	ld	s8,16(sp)
    80004f24:	6125                	addi	sp,sp,96
    80004f26:	8082                	ret
      wakeup(&pi->nread);
    80004f28:	8562                	mv	a0,s8
    80004f2a:	ffffd097          	auipc	ra,0xffffd
    80004f2e:	376080e7          	jalr	886(ra) # 800022a0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f32:	85a6                	mv	a1,s1
    80004f34:	855e                	mv	a0,s7
    80004f36:	ffffd097          	auipc	ra,0xffffd
    80004f3a:	306080e7          	jalr	774(ra) # 8000223c <sleep>
  while(i < n){
    80004f3e:	07495063          	bge	s2,s4,80004f9e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f42:	2204a783          	lw	a5,544(s1)
    80004f46:	dfd5                	beqz	a5,80004f02 <pipewrite+0x44>
    80004f48:	854e                	mv	a0,s3
    80004f4a:	ffffd097          	auipc	ra,0xffffd
    80004f4e:	5a6080e7          	jalr	1446(ra) # 800024f0 <killed>
    80004f52:	f945                	bnez	a0,80004f02 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f54:	2184a783          	lw	a5,536(s1)
    80004f58:	21c4a703          	lw	a4,540(s1)
    80004f5c:	2007879b          	addiw	a5,a5,512
    80004f60:	fcf704e3          	beq	a4,a5,80004f28 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f64:	4685                	li	a3,1
    80004f66:	01590633          	add	a2,s2,s5
    80004f6a:	faf40593          	addi	a1,s0,-81
    80004f6e:	0609b503          	ld	a0,96(s3)
    80004f72:	ffffc097          	auipc	ra,0xffffc
    80004f76:	78a080e7          	jalr	1930(ra) # 800016fc <copyin>
    80004f7a:	03650263          	beq	a0,s6,80004f9e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f7e:	21c4a783          	lw	a5,540(s1)
    80004f82:	0017871b          	addiw	a4,a5,1
    80004f86:	20e4ae23          	sw	a4,540(s1)
    80004f8a:	1ff7f793          	andi	a5,a5,511
    80004f8e:	97a6                	add	a5,a5,s1
    80004f90:	faf44703          	lbu	a4,-81(s0)
    80004f94:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f98:	2905                	addiw	s2,s2,1
    80004f9a:	b755                	j	80004f3e <pipewrite+0x80>
  int i = 0;
    80004f9c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004f9e:	21848513          	addi	a0,s1,536
    80004fa2:	ffffd097          	auipc	ra,0xffffd
    80004fa6:	2fe080e7          	jalr	766(ra) # 800022a0 <wakeup>
  release(&pi->lock);
    80004faa:	8526                	mv	a0,s1
    80004fac:	ffffc097          	auipc	ra,0xffffc
    80004fb0:	cde080e7          	jalr	-802(ra) # 80000c8a <release>
  return i;
    80004fb4:	bfa9                	j	80004f0e <pipewrite+0x50>

0000000080004fb6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004fb6:	715d                	addi	sp,sp,-80
    80004fb8:	e486                	sd	ra,72(sp)
    80004fba:	e0a2                	sd	s0,64(sp)
    80004fbc:	fc26                	sd	s1,56(sp)
    80004fbe:	f84a                	sd	s2,48(sp)
    80004fc0:	f44e                	sd	s3,40(sp)
    80004fc2:	f052                	sd	s4,32(sp)
    80004fc4:	ec56                	sd	s5,24(sp)
    80004fc6:	e85a                	sd	s6,16(sp)
    80004fc8:	0880                	addi	s0,sp,80
    80004fca:	84aa                	mv	s1,a0
    80004fcc:	892e                	mv	s2,a1
    80004fce:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004fd0:	ffffd097          	auipc	ra,0xffffd
    80004fd4:	b80080e7          	jalr	-1152(ra) # 80001b50 <myproc>
    80004fd8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004fda:	8526                	mv	a0,s1
    80004fdc:	ffffc097          	auipc	ra,0xffffc
    80004fe0:	bfa080e7          	jalr	-1030(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fe4:	2184a703          	lw	a4,536(s1)
    80004fe8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fec:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ff0:	02f71763          	bne	a4,a5,8000501e <piperead+0x68>
    80004ff4:	2244a783          	lw	a5,548(s1)
    80004ff8:	c39d                	beqz	a5,8000501e <piperead+0x68>
    if(killed(pr)){
    80004ffa:	8552                	mv	a0,s4
    80004ffc:	ffffd097          	auipc	ra,0xffffd
    80005000:	4f4080e7          	jalr	1268(ra) # 800024f0 <killed>
    80005004:	e941                	bnez	a0,80005094 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005006:	85a6                	mv	a1,s1
    80005008:	854e                	mv	a0,s3
    8000500a:	ffffd097          	auipc	ra,0xffffd
    8000500e:	232080e7          	jalr	562(ra) # 8000223c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005012:	2184a703          	lw	a4,536(s1)
    80005016:	21c4a783          	lw	a5,540(s1)
    8000501a:	fcf70de3          	beq	a4,a5,80004ff4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000501e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005020:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005022:	05505363          	blez	s5,80005068 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80005026:	2184a783          	lw	a5,536(s1)
    8000502a:	21c4a703          	lw	a4,540(s1)
    8000502e:	02f70d63          	beq	a4,a5,80005068 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005032:	0017871b          	addiw	a4,a5,1
    80005036:	20e4ac23          	sw	a4,536(s1)
    8000503a:	1ff7f793          	andi	a5,a5,511
    8000503e:	97a6                	add	a5,a5,s1
    80005040:	0187c783          	lbu	a5,24(a5)
    80005044:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005048:	4685                	li	a3,1
    8000504a:	fbf40613          	addi	a2,s0,-65
    8000504e:	85ca                	mv	a1,s2
    80005050:	060a3503          	ld	a0,96(s4)
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	61c080e7          	jalr	1564(ra) # 80001670 <copyout>
    8000505c:	01650663          	beq	a0,s6,80005068 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005060:	2985                	addiw	s3,s3,1
    80005062:	0905                	addi	s2,s2,1
    80005064:	fd3a91e3          	bne	s5,s3,80005026 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005068:	21c48513          	addi	a0,s1,540
    8000506c:	ffffd097          	auipc	ra,0xffffd
    80005070:	234080e7          	jalr	564(ra) # 800022a0 <wakeup>
  release(&pi->lock);
    80005074:	8526                	mv	a0,s1
    80005076:	ffffc097          	auipc	ra,0xffffc
    8000507a:	c14080e7          	jalr	-1004(ra) # 80000c8a <release>
  return i;
}
    8000507e:	854e                	mv	a0,s3
    80005080:	60a6                	ld	ra,72(sp)
    80005082:	6406                	ld	s0,64(sp)
    80005084:	74e2                	ld	s1,56(sp)
    80005086:	7942                	ld	s2,48(sp)
    80005088:	79a2                	ld	s3,40(sp)
    8000508a:	7a02                	ld	s4,32(sp)
    8000508c:	6ae2                	ld	s5,24(sp)
    8000508e:	6b42                	ld	s6,16(sp)
    80005090:	6161                	addi	sp,sp,80
    80005092:	8082                	ret
      release(&pi->lock);
    80005094:	8526                	mv	a0,s1
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	bf4080e7          	jalr	-1036(ra) # 80000c8a <release>
      return -1;
    8000509e:	59fd                	li	s3,-1
    800050a0:	bff9                	j	8000507e <piperead+0xc8>

00000000800050a2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050a2:	1141                	addi	sp,sp,-16
    800050a4:	e422                	sd	s0,8(sp)
    800050a6:	0800                	addi	s0,sp,16
    800050a8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050aa:	8905                	andi	a0,a0,1
    800050ac:	c111                	beqz	a0,800050b0 <flags2perm+0xe>
      perm = PTE_X;
    800050ae:	4521                	li	a0,8
    if(flags & 0x2)
    800050b0:	8b89                	andi	a5,a5,2
    800050b2:	c399                	beqz	a5,800050b8 <flags2perm+0x16>
      perm |= PTE_W;
    800050b4:	00456513          	ori	a0,a0,4
    return perm;
}
    800050b8:	6422                	ld	s0,8(sp)
    800050ba:	0141                	addi	sp,sp,16
    800050bc:	8082                	ret

00000000800050be <exec>:

int
exec(char *path, char **argv)
{
    800050be:	de010113          	addi	sp,sp,-544
    800050c2:	20113c23          	sd	ra,536(sp)
    800050c6:	20813823          	sd	s0,528(sp)
    800050ca:	20913423          	sd	s1,520(sp)
    800050ce:	21213023          	sd	s2,512(sp)
    800050d2:	ffce                	sd	s3,504(sp)
    800050d4:	fbd2                	sd	s4,496(sp)
    800050d6:	f7d6                	sd	s5,488(sp)
    800050d8:	f3da                	sd	s6,480(sp)
    800050da:	efde                	sd	s7,472(sp)
    800050dc:	ebe2                	sd	s8,464(sp)
    800050de:	e7e6                	sd	s9,456(sp)
    800050e0:	e3ea                	sd	s10,448(sp)
    800050e2:	ff6e                	sd	s11,440(sp)
    800050e4:	1400                	addi	s0,sp,544
    800050e6:	892a                	mv	s2,a0
    800050e8:	dea43423          	sd	a0,-536(s0)
    800050ec:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800050f0:	ffffd097          	auipc	ra,0xffffd
    800050f4:	a60080e7          	jalr	-1440(ra) # 80001b50 <myproc>
    800050f8:	84aa                	mv	s1,a0

  begin_op();
    800050fa:	fffff097          	auipc	ra,0xfffff
    800050fe:	47e080e7          	jalr	1150(ra) # 80004578 <begin_op>

  if((ip = namei(path)) == 0){
    80005102:	854a                	mv	a0,s2
    80005104:	fffff097          	auipc	ra,0xfffff
    80005108:	258080e7          	jalr	600(ra) # 8000435c <namei>
    8000510c:	c93d                	beqz	a0,80005182 <exec+0xc4>
    8000510e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005110:	fffff097          	auipc	ra,0xfffff
    80005114:	aa6080e7          	jalr	-1370(ra) # 80003bb6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005118:	04000713          	li	a4,64
    8000511c:	4681                	li	a3,0
    8000511e:	e5040613          	addi	a2,s0,-432
    80005122:	4581                	li	a1,0
    80005124:	8556                	mv	a0,s5
    80005126:	fffff097          	auipc	ra,0xfffff
    8000512a:	d44080e7          	jalr	-700(ra) # 80003e6a <readi>
    8000512e:	04000793          	li	a5,64
    80005132:	00f51a63          	bne	a0,a5,80005146 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005136:	e5042703          	lw	a4,-432(s0)
    8000513a:	464c47b7          	lui	a5,0x464c4
    8000513e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005142:	04f70663          	beq	a4,a5,8000518e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005146:	8556                	mv	a0,s5
    80005148:	fffff097          	auipc	ra,0xfffff
    8000514c:	cd0080e7          	jalr	-816(ra) # 80003e18 <iunlockput>
    end_op();
    80005150:	fffff097          	auipc	ra,0xfffff
    80005154:	4a8080e7          	jalr	1192(ra) # 800045f8 <end_op>
  }
  return -1;
    80005158:	557d                	li	a0,-1
}
    8000515a:	21813083          	ld	ra,536(sp)
    8000515e:	21013403          	ld	s0,528(sp)
    80005162:	20813483          	ld	s1,520(sp)
    80005166:	20013903          	ld	s2,512(sp)
    8000516a:	79fe                	ld	s3,504(sp)
    8000516c:	7a5e                	ld	s4,496(sp)
    8000516e:	7abe                	ld	s5,488(sp)
    80005170:	7b1e                	ld	s6,480(sp)
    80005172:	6bfe                	ld	s7,472(sp)
    80005174:	6c5e                	ld	s8,464(sp)
    80005176:	6cbe                	ld	s9,456(sp)
    80005178:	6d1e                	ld	s10,448(sp)
    8000517a:	7dfa                	ld	s11,440(sp)
    8000517c:	22010113          	addi	sp,sp,544
    80005180:	8082                	ret
    end_op();
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	476080e7          	jalr	1142(ra) # 800045f8 <end_op>
    return -1;
    8000518a:	557d                	li	a0,-1
    8000518c:	b7f9                	j	8000515a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000518e:	8526                	mv	a0,s1
    80005190:	ffffd097          	auipc	ra,0xffffd
    80005194:	a84080e7          	jalr	-1404(ra) # 80001c14 <proc_pagetable>
    80005198:	8b2a                	mv	s6,a0
    8000519a:	d555                	beqz	a0,80005146 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000519c:	e7042783          	lw	a5,-400(s0)
    800051a0:	e8845703          	lhu	a4,-376(s0)
    800051a4:	c735                	beqz	a4,80005210 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051a6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051a8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800051ac:	6a05                	lui	s4,0x1
    800051ae:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800051b2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800051b6:	6d85                	lui	s11,0x1
    800051b8:	7d7d                	lui	s10,0xfffff
    800051ba:	a481                	j	800053fa <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051bc:	00003517          	auipc	a0,0x3
    800051c0:	53450513          	addi	a0,a0,1332 # 800086f0 <syscalls+0x2a0>
    800051c4:	ffffb097          	auipc	ra,0xffffb
    800051c8:	37a080e7          	jalr	890(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051cc:	874a                	mv	a4,s2
    800051ce:	009c86bb          	addw	a3,s9,s1
    800051d2:	4581                	li	a1,0
    800051d4:	8556                	mv	a0,s5
    800051d6:	fffff097          	auipc	ra,0xfffff
    800051da:	c94080e7          	jalr	-876(ra) # 80003e6a <readi>
    800051de:	2501                	sext.w	a0,a0
    800051e0:	1aa91a63          	bne	s2,a0,80005394 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800051e4:	009d84bb          	addw	s1,s11,s1
    800051e8:	013d09bb          	addw	s3,s10,s3
    800051ec:	1f74f763          	bgeu	s1,s7,800053da <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    800051f0:	02049593          	slli	a1,s1,0x20
    800051f4:	9181                	srli	a1,a1,0x20
    800051f6:	95e2                	add	a1,a1,s8
    800051f8:	855a                	mv	a0,s6
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	e6a080e7          	jalr	-406(ra) # 80001064 <walkaddr>
    80005202:	862a                	mv	a2,a0
    if(pa == 0)
    80005204:	dd45                	beqz	a0,800051bc <exec+0xfe>
      n = PGSIZE;
    80005206:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005208:	fd49f2e3          	bgeu	s3,s4,800051cc <exec+0x10e>
      n = sz - i;
    8000520c:	894e                	mv	s2,s3
    8000520e:	bf7d                	j	800051cc <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005210:	4901                	li	s2,0
  iunlockput(ip);
    80005212:	8556                	mv	a0,s5
    80005214:	fffff097          	auipc	ra,0xfffff
    80005218:	c04080e7          	jalr	-1020(ra) # 80003e18 <iunlockput>
  end_op();
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	3dc080e7          	jalr	988(ra) # 800045f8 <end_op>
  p = myproc();
    80005224:	ffffd097          	auipc	ra,0xffffd
    80005228:	92c080e7          	jalr	-1748(ra) # 80001b50 <myproc>
    8000522c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000522e:	05853d03          	ld	s10,88(a0)
  sz = PGROUNDUP(sz);
    80005232:	6785                	lui	a5,0x1
    80005234:	17fd                	addi	a5,a5,-1
    80005236:	993e                	add	s2,s2,a5
    80005238:	77fd                	lui	a5,0xfffff
    8000523a:	00f977b3          	and	a5,s2,a5
    8000523e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005242:	4691                	li	a3,4
    80005244:	6609                	lui	a2,0x2
    80005246:	963e                	add	a2,a2,a5
    80005248:	85be                	mv	a1,a5
    8000524a:	855a                	mv	a0,s6
    8000524c:	ffffc097          	auipc	ra,0xffffc
    80005250:	1cc080e7          	jalr	460(ra) # 80001418 <uvmalloc>
    80005254:	8c2a                	mv	s8,a0
  ip = 0;
    80005256:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005258:	12050e63          	beqz	a0,80005394 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000525c:	75f9                	lui	a1,0xffffe
    8000525e:	95aa                	add	a1,a1,a0
    80005260:	855a                	mv	a0,s6
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	3dc080e7          	jalr	988(ra) # 8000163e <uvmclear>
  stackbase = sp - PGSIZE;
    8000526a:	7afd                	lui	s5,0xfffff
    8000526c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000526e:	df043783          	ld	a5,-528(s0)
    80005272:	6388                	ld	a0,0(a5)
    80005274:	c925                	beqz	a0,800052e4 <exec+0x226>
    80005276:	e9040993          	addi	s3,s0,-368
    8000527a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000527e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005280:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005282:	ffffc097          	auipc	ra,0xffffc
    80005286:	bcc080e7          	jalr	-1076(ra) # 80000e4e <strlen>
    8000528a:	0015079b          	addiw	a5,a0,1
    8000528e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005292:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005296:	13596663          	bltu	s2,s5,800053c2 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000529a:	df043d83          	ld	s11,-528(s0)
    8000529e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800052a2:	8552                	mv	a0,s4
    800052a4:	ffffc097          	auipc	ra,0xffffc
    800052a8:	baa080e7          	jalr	-1110(ra) # 80000e4e <strlen>
    800052ac:	0015069b          	addiw	a3,a0,1
    800052b0:	8652                	mv	a2,s4
    800052b2:	85ca                	mv	a1,s2
    800052b4:	855a                	mv	a0,s6
    800052b6:	ffffc097          	auipc	ra,0xffffc
    800052ba:	3ba080e7          	jalr	954(ra) # 80001670 <copyout>
    800052be:	10054663          	bltz	a0,800053ca <exec+0x30c>
    ustack[argc] = sp;
    800052c2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052c6:	0485                	addi	s1,s1,1
    800052c8:	008d8793          	addi	a5,s11,8
    800052cc:	def43823          	sd	a5,-528(s0)
    800052d0:	008db503          	ld	a0,8(s11)
    800052d4:	c911                	beqz	a0,800052e8 <exec+0x22a>
    if(argc >= MAXARG)
    800052d6:	09a1                	addi	s3,s3,8
    800052d8:	fb3c95e3          	bne	s9,s3,80005282 <exec+0x1c4>
  sz = sz1;
    800052dc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052e0:	4a81                	li	s5,0
    800052e2:	a84d                	j	80005394 <exec+0x2d6>
  sp = sz;
    800052e4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052e6:	4481                	li	s1,0
  ustack[argc] = 0;
    800052e8:	00349793          	slli	a5,s1,0x3
    800052ec:	f9040713          	addi	a4,s0,-112
    800052f0:	97ba                	add	a5,a5,a4
    800052f2:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdbb70>
  sp -= (argc+1) * sizeof(uint64);
    800052f6:	00148693          	addi	a3,s1,1
    800052fa:	068e                	slli	a3,a3,0x3
    800052fc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005300:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005304:	01597663          	bgeu	s2,s5,80005310 <exec+0x252>
  sz = sz1;
    80005308:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000530c:	4a81                	li	s5,0
    8000530e:	a059                	j	80005394 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005310:	e9040613          	addi	a2,s0,-368
    80005314:	85ca                	mv	a1,s2
    80005316:	855a                	mv	a0,s6
    80005318:	ffffc097          	auipc	ra,0xffffc
    8000531c:	358080e7          	jalr	856(ra) # 80001670 <copyout>
    80005320:	0a054963          	bltz	a0,800053d2 <exec+0x314>
  p->trapframe->a1 = sp;
    80005324:	068bb783          	ld	a5,104(s7) # 1068 <_entry-0x7fffef98>
    80005328:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000532c:	de843783          	ld	a5,-536(s0)
    80005330:	0007c703          	lbu	a4,0(a5)
    80005334:	cf11                	beqz	a4,80005350 <exec+0x292>
    80005336:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005338:	02f00693          	li	a3,47
    8000533c:	a039                	j	8000534a <exec+0x28c>
      last = s+1;
    8000533e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005342:	0785                	addi	a5,a5,1
    80005344:	fff7c703          	lbu	a4,-1(a5)
    80005348:	c701                	beqz	a4,80005350 <exec+0x292>
    if(*s == '/')
    8000534a:	fed71ce3          	bne	a4,a3,80005342 <exec+0x284>
    8000534e:	bfc5                	j	8000533e <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005350:	4641                	li	a2,16
    80005352:	de843583          	ld	a1,-536(s0)
    80005356:	168b8513          	addi	a0,s7,360
    8000535a:	ffffc097          	auipc	ra,0xffffc
    8000535e:	ac2080e7          	jalr	-1342(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005362:	060bb503          	ld	a0,96(s7)
  p->pagetable = pagetable;
    80005366:	076bb023          	sd	s6,96(s7)
  p->sz = sz;
    8000536a:	058bbc23          	sd	s8,88(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000536e:	068bb783          	ld	a5,104(s7)
    80005372:	e6843703          	ld	a4,-408(s0)
    80005376:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005378:	068bb783          	ld	a5,104(s7)
    8000537c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005380:	85ea                	mv	a1,s10
    80005382:	ffffd097          	auipc	ra,0xffffd
    80005386:	92e080e7          	jalr	-1746(ra) # 80001cb0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000538a:	0004851b          	sext.w	a0,s1
    8000538e:	b3f1                	j	8000515a <exec+0x9c>
    80005390:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005394:	df843583          	ld	a1,-520(s0)
    80005398:	855a                	mv	a0,s6
    8000539a:	ffffd097          	auipc	ra,0xffffd
    8000539e:	916080e7          	jalr	-1770(ra) # 80001cb0 <proc_freepagetable>
  if(ip){
    800053a2:	da0a92e3          	bnez	s5,80005146 <exec+0x88>
  return -1;
    800053a6:	557d                	li	a0,-1
    800053a8:	bb4d                	j	8000515a <exec+0x9c>
    800053aa:	df243c23          	sd	s2,-520(s0)
    800053ae:	b7dd                	j	80005394 <exec+0x2d6>
    800053b0:	df243c23          	sd	s2,-520(s0)
    800053b4:	b7c5                	j	80005394 <exec+0x2d6>
    800053b6:	df243c23          	sd	s2,-520(s0)
    800053ba:	bfe9                	j	80005394 <exec+0x2d6>
    800053bc:	df243c23          	sd	s2,-520(s0)
    800053c0:	bfd1                	j	80005394 <exec+0x2d6>
  sz = sz1;
    800053c2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053c6:	4a81                	li	s5,0
    800053c8:	b7f1                	j	80005394 <exec+0x2d6>
  sz = sz1;
    800053ca:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053ce:	4a81                	li	s5,0
    800053d0:	b7d1                	j	80005394 <exec+0x2d6>
  sz = sz1;
    800053d2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053d6:	4a81                	li	s5,0
    800053d8:	bf75                	j	80005394 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053da:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053de:	e0843783          	ld	a5,-504(s0)
    800053e2:	0017869b          	addiw	a3,a5,1
    800053e6:	e0d43423          	sd	a3,-504(s0)
    800053ea:	e0043783          	ld	a5,-512(s0)
    800053ee:	0387879b          	addiw	a5,a5,56
    800053f2:	e8845703          	lhu	a4,-376(s0)
    800053f6:	e0e6dee3          	bge	a3,a4,80005212 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053fa:	2781                	sext.w	a5,a5
    800053fc:	e0f43023          	sd	a5,-512(s0)
    80005400:	03800713          	li	a4,56
    80005404:	86be                	mv	a3,a5
    80005406:	e1840613          	addi	a2,s0,-488
    8000540a:	4581                	li	a1,0
    8000540c:	8556                	mv	a0,s5
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	a5c080e7          	jalr	-1444(ra) # 80003e6a <readi>
    80005416:	03800793          	li	a5,56
    8000541a:	f6f51be3          	bne	a0,a5,80005390 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    8000541e:	e1842783          	lw	a5,-488(s0)
    80005422:	4705                	li	a4,1
    80005424:	fae79de3          	bne	a5,a4,800053de <exec+0x320>
    if(ph.memsz < ph.filesz)
    80005428:	e4043483          	ld	s1,-448(s0)
    8000542c:	e3843783          	ld	a5,-456(s0)
    80005430:	f6f4ede3          	bltu	s1,a5,800053aa <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005434:	e2843783          	ld	a5,-472(s0)
    80005438:	94be                	add	s1,s1,a5
    8000543a:	f6f4ebe3          	bltu	s1,a5,800053b0 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    8000543e:	de043703          	ld	a4,-544(s0)
    80005442:	8ff9                	and	a5,a5,a4
    80005444:	fbad                	bnez	a5,800053b6 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005446:	e1c42503          	lw	a0,-484(s0)
    8000544a:	00000097          	auipc	ra,0x0
    8000544e:	c58080e7          	jalr	-936(ra) # 800050a2 <flags2perm>
    80005452:	86aa                	mv	a3,a0
    80005454:	8626                	mv	a2,s1
    80005456:	85ca                	mv	a1,s2
    80005458:	855a                	mv	a0,s6
    8000545a:	ffffc097          	auipc	ra,0xffffc
    8000545e:	fbe080e7          	jalr	-66(ra) # 80001418 <uvmalloc>
    80005462:	dea43c23          	sd	a0,-520(s0)
    80005466:	d939                	beqz	a0,800053bc <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005468:	e2843c03          	ld	s8,-472(s0)
    8000546c:	e2042c83          	lw	s9,-480(s0)
    80005470:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005474:	f60b83e3          	beqz	s7,800053da <exec+0x31c>
    80005478:	89de                	mv	s3,s7
    8000547a:	4481                	li	s1,0
    8000547c:	bb95                	j	800051f0 <exec+0x132>

000000008000547e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000547e:	7179                	addi	sp,sp,-48
    80005480:	f406                	sd	ra,40(sp)
    80005482:	f022                	sd	s0,32(sp)
    80005484:	ec26                	sd	s1,24(sp)
    80005486:	e84a                	sd	s2,16(sp)
    80005488:	1800                	addi	s0,sp,48
    8000548a:	892e                	mv	s2,a1
    8000548c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000548e:	fdc40593          	addi	a1,s0,-36
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	a2c080e7          	jalr	-1492(ra) # 80002ebe <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000549a:	fdc42703          	lw	a4,-36(s0)
    8000549e:	47bd                	li	a5,15
    800054a0:	02e7eb63          	bltu	a5,a4,800054d6 <argfd+0x58>
    800054a4:	ffffc097          	auipc	ra,0xffffc
    800054a8:	6ac080e7          	jalr	1708(ra) # 80001b50 <myproc>
    800054ac:	fdc42703          	lw	a4,-36(s0)
    800054b0:	01c70793          	addi	a5,a4,28
    800054b4:	078e                	slli	a5,a5,0x3
    800054b6:	953e                	add	a0,a0,a5
    800054b8:	611c                	ld	a5,0(a0)
    800054ba:	c385                	beqz	a5,800054da <argfd+0x5c>
    return -1;
  if(pfd)
    800054bc:	00090463          	beqz	s2,800054c4 <argfd+0x46>
    *pfd = fd;
    800054c0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054c4:	4501                	li	a0,0
  if(pf)
    800054c6:	c091                	beqz	s1,800054ca <argfd+0x4c>
    *pf = f;
    800054c8:	e09c                	sd	a5,0(s1)
}
    800054ca:	70a2                	ld	ra,40(sp)
    800054cc:	7402                	ld	s0,32(sp)
    800054ce:	64e2                	ld	s1,24(sp)
    800054d0:	6942                	ld	s2,16(sp)
    800054d2:	6145                	addi	sp,sp,48
    800054d4:	8082                	ret
    return -1;
    800054d6:	557d                	li	a0,-1
    800054d8:	bfcd                	j	800054ca <argfd+0x4c>
    800054da:	557d                	li	a0,-1
    800054dc:	b7fd                	j	800054ca <argfd+0x4c>

00000000800054de <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800054de:	1101                	addi	sp,sp,-32
    800054e0:	ec06                	sd	ra,24(sp)
    800054e2:	e822                	sd	s0,16(sp)
    800054e4:	e426                	sd	s1,8(sp)
    800054e6:	1000                	addi	s0,sp,32
    800054e8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800054ea:	ffffc097          	auipc	ra,0xffffc
    800054ee:	666080e7          	jalr	1638(ra) # 80001b50 <myproc>
    800054f2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800054f4:	0e050793          	addi	a5,a0,224
    800054f8:	4501                	li	a0,0
    800054fa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054fc:	6398                	ld	a4,0(a5)
    800054fe:	cb19                	beqz	a4,80005514 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005500:	2505                	addiw	a0,a0,1
    80005502:	07a1                	addi	a5,a5,8
    80005504:	fed51ce3          	bne	a0,a3,800054fc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005508:	557d                	li	a0,-1
}
    8000550a:	60e2                	ld	ra,24(sp)
    8000550c:	6442                	ld	s0,16(sp)
    8000550e:	64a2                	ld	s1,8(sp)
    80005510:	6105                	addi	sp,sp,32
    80005512:	8082                	ret
      p->ofile[fd] = f;
    80005514:	01c50793          	addi	a5,a0,28
    80005518:	078e                	slli	a5,a5,0x3
    8000551a:	963e                	add	a2,a2,a5
    8000551c:	e204                	sd	s1,0(a2)
      return fd;
    8000551e:	b7f5                	j	8000550a <fdalloc+0x2c>

0000000080005520 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005520:	715d                	addi	sp,sp,-80
    80005522:	e486                	sd	ra,72(sp)
    80005524:	e0a2                	sd	s0,64(sp)
    80005526:	fc26                	sd	s1,56(sp)
    80005528:	f84a                	sd	s2,48(sp)
    8000552a:	f44e                	sd	s3,40(sp)
    8000552c:	f052                	sd	s4,32(sp)
    8000552e:	ec56                	sd	s5,24(sp)
    80005530:	e85a                	sd	s6,16(sp)
    80005532:	0880                	addi	s0,sp,80
    80005534:	8b2e                	mv	s6,a1
    80005536:	89b2                	mv	s3,a2
    80005538:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000553a:	fb040593          	addi	a1,s0,-80
    8000553e:	fffff097          	auipc	ra,0xfffff
    80005542:	e3c080e7          	jalr	-452(ra) # 8000437a <nameiparent>
    80005546:	84aa                	mv	s1,a0
    80005548:	14050f63          	beqz	a0,800056a6 <create+0x186>
    return 0;

  ilock(dp);
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	66a080e7          	jalr	1642(ra) # 80003bb6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005554:	4601                	li	a2,0
    80005556:	fb040593          	addi	a1,s0,-80
    8000555a:	8526                	mv	a0,s1
    8000555c:	fffff097          	auipc	ra,0xfffff
    80005560:	b3e080e7          	jalr	-1218(ra) # 8000409a <dirlookup>
    80005564:	8aaa                	mv	s5,a0
    80005566:	c931                	beqz	a0,800055ba <create+0x9a>
    iunlockput(dp);
    80005568:	8526                	mv	a0,s1
    8000556a:	fffff097          	auipc	ra,0xfffff
    8000556e:	8ae080e7          	jalr	-1874(ra) # 80003e18 <iunlockput>
    ilock(ip);
    80005572:	8556                	mv	a0,s5
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	642080e7          	jalr	1602(ra) # 80003bb6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000557c:	000b059b          	sext.w	a1,s6
    80005580:	4789                	li	a5,2
    80005582:	02f59563          	bne	a1,a5,800055ac <create+0x8c>
    80005586:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdbcb4>
    8000558a:	37f9                	addiw	a5,a5,-2
    8000558c:	17c2                	slli	a5,a5,0x30
    8000558e:	93c1                	srli	a5,a5,0x30
    80005590:	4705                	li	a4,1
    80005592:	00f76d63          	bltu	a4,a5,800055ac <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005596:	8556                	mv	a0,s5
    80005598:	60a6                	ld	ra,72(sp)
    8000559a:	6406                	ld	s0,64(sp)
    8000559c:	74e2                	ld	s1,56(sp)
    8000559e:	7942                	ld	s2,48(sp)
    800055a0:	79a2                	ld	s3,40(sp)
    800055a2:	7a02                	ld	s4,32(sp)
    800055a4:	6ae2                	ld	s5,24(sp)
    800055a6:	6b42                	ld	s6,16(sp)
    800055a8:	6161                	addi	sp,sp,80
    800055aa:	8082                	ret
    iunlockput(ip);
    800055ac:	8556                	mv	a0,s5
    800055ae:	fffff097          	auipc	ra,0xfffff
    800055b2:	86a080e7          	jalr	-1942(ra) # 80003e18 <iunlockput>
    return 0;
    800055b6:	4a81                	li	s5,0
    800055b8:	bff9                	j	80005596 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055ba:	85da                	mv	a1,s6
    800055bc:	4088                	lw	a0,0(s1)
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	45c080e7          	jalr	1116(ra) # 80003a1a <ialloc>
    800055c6:	8a2a                	mv	s4,a0
    800055c8:	c539                	beqz	a0,80005616 <create+0xf6>
  ilock(ip);
    800055ca:	ffffe097          	auipc	ra,0xffffe
    800055ce:	5ec080e7          	jalr	1516(ra) # 80003bb6 <ilock>
  ip->major = major;
    800055d2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800055d6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800055da:	4905                	li	s2,1
    800055dc:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800055e0:	8552                	mv	a0,s4
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	50a080e7          	jalr	1290(ra) # 80003aec <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055ea:	000b059b          	sext.w	a1,s6
    800055ee:	03258b63          	beq	a1,s2,80005624 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800055f2:	004a2603          	lw	a2,4(s4)
    800055f6:	fb040593          	addi	a1,s0,-80
    800055fa:	8526                	mv	a0,s1
    800055fc:	fffff097          	auipc	ra,0xfffff
    80005600:	cae080e7          	jalr	-850(ra) # 800042aa <dirlink>
    80005604:	06054f63          	bltz	a0,80005682 <create+0x162>
  iunlockput(dp);
    80005608:	8526                	mv	a0,s1
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	80e080e7          	jalr	-2034(ra) # 80003e18 <iunlockput>
  return ip;
    80005612:	8ad2                	mv	s5,s4
    80005614:	b749                	j	80005596 <create+0x76>
    iunlockput(dp);
    80005616:	8526                	mv	a0,s1
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	800080e7          	jalr	-2048(ra) # 80003e18 <iunlockput>
    return 0;
    80005620:	8ad2                	mv	s5,s4
    80005622:	bf95                	j	80005596 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005624:	004a2603          	lw	a2,4(s4)
    80005628:	00003597          	auipc	a1,0x3
    8000562c:	0e858593          	addi	a1,a1,232 # 80008710 <syscalls+0x2c0>
    80005630:	8552                	mv	a0,s4
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	c78080e7          	jalr	-904(ra) # 800042aa <dirlink>
    8000563a:	04054463          	bltz	a0,80005682 <create+0x162>
    8000563e:	40d0                	lw	a2,4(s1)
    80005640:	00003597          	auipc	a1,0x3
    80005644:	0d858593          	addi	a1,a1,216 # 80008718 <syscalls+0x2c8>
    80005648:	8552                	mv	a0,s4
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	c60080e7          	jalr	-928(ra) # 800042aa <dirlink>
    80005652:	02054863          	bltz	a0,80005682 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005656:	004a2603          	lw	a2,4(s4)
    8000565a:	fb040593          	addi	a1,s0,-80
    8000565e:	8526                	mv	a0,s1
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	c4a080e7          	jalr	-950(ra) # 800042aa <dirlink>
    80005668:	00054d63          	bltz	a0,80005682 <create+0x162>
    dp->nlink++;  // for ".."
    8000566c:	04a4d783          	lhu	a5,74(s1)
    80005670:	2785                	addiw	a5,a5,1
    80005672:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	474080e7          	jalr	1140(ra) # 80003aec <iupdate>
    80005680:	b761                	j	80005608 <create+0xe8>
  ip->nlink = 0;
    80005682:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005686:	8552                	mv	a0,s4
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	464080e7          	jalr	1124(ra) # 80003aec <iupdate>
  iunlockput(ip);
    80005690:	8552                	mv	a0,s4
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	786080e7          	jalr	1926(ra) # 80003e18 <iunlockput>
  iunlockput(dp);
    8000569a:	8526                	mv	a0,s1
    8000569c:	ffffe097          	auipc	ra,0xffffe
    800056a0:	77c080e7          	jalr	1916(ra) # 80003e18 <iunlockput>
  return 0;
    800056a4:	bdcd                	j	80005596 <create+0x76>
    return 0;
    800056a6:	8aaa                	mv	s5,a0
    800056a8:	b5fd                	j	80005596 <create+0x76>

00000000800056aa <sys_dup>:
{
    800056aa:	7179                	addi	sp,sp,-48
    800056ac:	f406                	sd	ra,40(sp)
    800056ae:	f022                	sd	s0,32(sp)
    800056b0:	ec26                	sd	s1,24(sp)
    800056b2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056b4:	fd840613          	addi	a2,s0,-40
    800056b8:	4581                	li	a1,0
    800056ba:	4501                	li	a0,0
    800056bc:	00000097          	auipc	ra,0x0
    800056c0:	dc2080e7          	jalr	-574(ra) # 8000547e <argfd>
    return -1;
    800056c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056c6:	02054363          	bltz	a0,800056ec <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800056ca:	fd843503          	ld	a0,-40(s0)
    800056ce:	00000097          	auipc	ra,0x0
    800056d2:	e10080e7          	jalr	-496(ra) # 800054de <fdalloc>
    800056d6:	84aa                	mv	s1,a0
    return -1;
    800056d8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056da:	00054963          	bltz	a0,800056ec <sys_dup+0x42>
  filedup(f);
    800056de:	fd843503          	ld	a0,-40(s0)
    800056e2:	fffff097          	auipc	ra,0xfffff
    800056e6:	310080e7          	jalr	784(ra) # 800049f2 <filedup>
  return fd;
    800056ea:	87a6                	mv	a5,s1
}
    800056ec:	853e                	mv	a0,a5
    800056ee:	70a2                	ld	ra,40(sp)
    800056f0:	7402                	ld	s0,32(sp)
    800056f2:	64e2                	ld	s1,24(sp)
    800056f4:	6145                	addi	sp,sp,48
    800056f6:	8082                	ret

00000000800056f8 <sys_read>:
{
    800056f8:	7179                	addi	sp,sp,-48
    800056fa:	f406                	sd	ra,40(sp)
    800056fc:	f022                	sd	s0,32(sp)
    800056fe:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005700:	fd840593          	addi	a1,s0,-40
    80005704:	4505                	li	a0,1
    80005706:	ffffd097          	auipc	ra,0xffffd
    8000570a:	7d8080e7          	jalr	2008(ra) # 80002ede <argaddr>
  argint(2, &n);
    8000570e:	fe440593          	addi	a1,s0,-28
    80005712:	4509                	li	a0,2
    80005714:	ffffd097          	auipc	ra,0xffffd
    80005718:	7aa080e7          	jalr	1962(ra) # 80002ebe <argint>
  if(argfd(0, 0, &f) < 0)
    8000571c:	fe840613          	addi	a2,s0,-24
    80005720:	4581                	li	a1,0
    80005722:	4501                	li	a0,0
    80005724:	00000097          	auipc	ra,0x0
    80005728:	d5a080e7          	jalr	-678(ra) # 8000547e <argfd>
    8000572c:	87aa                	mv	a5,a0
    return -1;
    8000572e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005730:	0007cc63          	bltz	a5,80005748 <sys_read+0x50>
  return fileread(f, p, n);
    80005734:	fe442603          	lw	a2,-28(s0)
    80005738:	fd843583          	ld	a1,-40(s0)
    8000573c:	fe843503          	ld	a0,-24(s0)
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	43e080e7          	jalr	1086(ra) # 80004b7e <fileread>
}
    80005748:	70a2                	ld	ra,40(sp)
    8000574a:	7402                	ld	s0,32(sp)
    8000574c:	6145                	addi	sp,sp,48
    8000574e:	8082                	ret

0000000080005750 <sys_write>:
{
    80005750:	7179                	addi	sp,sp,-48
    80005752:	f406                	sd	ra,40(sp)
    80005754:	f022                	sd	s0,32(sp)
    80005756:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005758:	fd840593          	addi	a1,s0,-40
    8000575c:	4505                	li	a0,1
    8000575e:	ffffd097          	auipc	ra,0xffffd
    80005762:	780080e7          	jalr	1920(ra) # 80002ede <argaddr>
  argint(2, &n);
    80005766:	fe440593          	addi	a1,s0,-28
    8000576a:	4509                	li	a0,2
    8000576c:	ffffd097          	auipc	ra,0xffffd
    80005770:	752080e7          	jalr	1874(ra) # 80002ebe <argint>
  if(argfd(0, 0, &f) < 0)
    80005774:	fe840613          	addi	a2,s0,-24
    80005778:	4581                	li	a1,0
    8000577a:	4501                	li	a0,0
    8000577c:	00000097          	auipc	ra,0x0
    80005780:	d02080e7          	jalr	-766(ra) # 8000547e <argfd>
    80005784:	87aa                	mv	a5,a0
    return -1;
    80005786:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005788:	0007cc63          	bltz	a5,800057a0 <sys_write+0x50>
  return filewrite(f, p, n);
    8000578c:	fe442603          	lw	a2,-28(s0)
    80005790:	fd843583          	ld	a1,-40(s0)
    80005794:	fe843503          	ld	a0,-24(s0)
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	4a8080e7          	jalr	1192(ra) # 80004c40 <filewrite>
}
    800057a0:	70a2                	ld	ra,40(sp)
    800057a2:	7402                	ld	s0,32(sp)
    800057a4:	6145                	addi	sp,sp,48
    800057a6:	8082                	ret

00000000800057a8 <sys_close>:
{
    800057a8:	1101                	addi	sp,sp,-32
    800057aa:	ec06                	sd	ra,24(sp)
    800057ac:	e822                	sd	s0,16(sp)
    800057ae:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057b0:	fe040613          	addi	a2,s0,-32
    800057b4:	fec40593          	addi	a1,s0,-20
    800057b8:	4501                	li	a0,0
    800057ba:	00000097          	auipc	ra,0x0
    800057be:	cc4080e7          	jalr	-828(ra) # 8000547e <argfd>
    return -1;
    800057c2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057c4:	02054463          	bltz	a0,800057ec <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800057c8:	ffffc097          	auipc	ra,0xffffc
    800057cc:	388080e7          	jalr	904(ra) # 80001b50 <myproc>
    800057d0:	fec42783          	lw	a5,-20(s0)
    800057d4:	07f1                	addi	a5,a5,28
    800057d6:	078e                	slli	a5,a5,0x3
    800057d8:	97aa                	add	a5,a5,a0
    800057da:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800057de:	fe043503          	ld	a0,-32(s0)
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	262080e7          	jalr	610(ra) # 80004a44 <fileclose>
  return 0;
    800057ea:	4781                	li	a5,0
}
    800057ec:	853e                	mv	a0,a5
    800057ee:	60e2                	ld	ra,24(sp)
    800057f0:	6442                	ld	s0,16(sp)
    800057f2:	6105                	addi	sp,sp,32
    800057f4:	8082                	ret

00000000800057f6 <sys_fstat>:
{
    800057f6:	1101                	addi	sp,sp,-32
    800057f8:	ec06                	sd	ra,24(sp)
    800057fa:	e822                	sd	s0,16(sp)
    800057fc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057fe:	fe040593          	addi	a1,s0,-32
    80005802:	4505                	li	a0,1
    80005804:	ffffd097          	auipc	ra,0xffffd
    80005808:	6da080e7          	jalr	1754(ra) # 80002ede <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000580c:	fe840613          	addi	a2,s0,-24
    80005810:	4581                	li	a1,0
    80005812:	4501                	li	a0,0
    80005814:	00000097          	auipc	ra,0x0
    80005818:	c6a080e7          	jalr	-918(ra) # 8000547e <argfd>
    8000581c:	87aa                	mv	a5,a0
    return -1;
    8000581e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005820:	0007ca63          	bltz	a5,80005834 <sys_fstat+0x3e>
  return filestat(f, st);
    80005824:	fe043583          	ld	a1,-32(s0)
    80005828:	fe843503          	ld	a0,-24(s0)
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	2e0080e7          	jalr	736(ra) # 80004b0c <filestat>
}
    80005834:	60e2                	ld	ra,24(sp)
    80005836:	6442                	ld	s0,16(sp)
    80005838:	6105                	addi	sp,sp,32
    8000583a:	8082                	ret

000000008000583c <sys_link>:
{
    8000583c:	7169                	addi	sp,sp,-304
    8000583e:	f606                	sd	ra,296(sp)
    80005840:	f222                	sd	s0,288(sp)
    80005842:	ee26                	sd	s1,280(sp)
    80005844:	ea4a                	sd	s2,272(sp)
    80005846:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005848:	08000613          	li	a2,128
    8000584c:	ed040593          	addi	a1,s0,-304
    80005850:	4501                	li	a0,0
    80005852:	ffffd097          	auipc	ra,0xffffd
    80005856:	6ac080e7          	jalr	1708(ra) # 80002efe <argstr>
    return -1;
    8000585a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000585c:	10054e63          	bltz	a0,80005978 <sys_link+0x13c>
    80005860:	08000613          	li	a2,128
    80005864:	f5040593          	addi	a1,s0,-176
    80005868:	4505                	li	a0,1
    8000586a:	ffffd097          	auipc	ra,0xffffd
    8000586e:	694080e7          	jalr	1684(ra) # 80002efe <argstr>
    return -1;
    80005872:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005874:	10054263          	bltz	a0,80005978 <sys_link+0x13c>
  begin_op();
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	d00080e7          	jalr	-768(ra) # 80004578 <begin_op>
  if((ip = namei(old)) == 0){
    80005880:	ed040513          	addi	a0,s0,-304
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	ad8080e7          	jalr	-1320(ra) # 8000435c <namei>
    8000588c:	84aa                	mv	s1,a0
    8000588e:	c551                	beqz	a0,8000591a <sys_link+0xde>
  ilock(ip);
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	326080e7          	jalr	806(ra) # 80003bb6 <ilock>
  if(ip->type == T_DIR){
    80005898:	04449703          	lh	a4,68(s1)
    8000589c:	4785                	li	a5,1
    8000589e:	08f70463          	beq	a4,a5,80005926 <sys_link+0xea>
  ip->nlink++;
    800058a2:	04a4d783          	lhu	a5,74(s1)
    800058a6:	2785                	addiw	a5,a5,1
    800058a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058ac:	8526                	mv	a0,s1
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	23e080e7          	jalr	574(ra) # 80003aec <iupdate>
  iunlock(ip);
    800058b6:	8526                	mv	a0,s1
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	3c0080e7          	jalr	960(ra) # 80003c78 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058c0:	fd040593          	addi	a1,s0,-48
    800058c4:	f5040513          	addi	a0,s0,-176
    800058c8:	fffff097          	auipc	ra,0xfffff
    800058cc:	ab2080e7          	jalr	-1358(ra) # 8000437a <nameiparent>
    800058d0:	892a                	mv	s2,a0
    800058d2:	c935                	beqz	a0,80005946 <sys_link+0x10a>
  ilock(dp);
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	2e2080e7          	jalr	738(ra) # 80003bb6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800058dc:	00092703          	lw	a4,0(s2)
    800058e0:	409c                	lw	a5,0(s1)
    800058e2:	04f71d63          	bne	a4,a5,8000593c <sys_link+0x100>
    800058e6:	40d0                	lw	a2,4(s1)
    800058e8:	fd040593          	addi	a1,s0,-48
    800058ec:	854a                	mv	a0,s2
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	9bc080e7          	jalr	-1604(ra) # 800042aa <dirlink>
    800058f6:	04054363          	bltz	a0,8000593c <sys_link+0x100>
  iunlockput(dp);
    800058fa:	854a                	mv	a0,s2
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	51c080e7          	jalr	1308(ra) # 80003e18 <iunlockput>
  iput(ip);
    80005904:	8526                	mv	a0,s1
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	46a080e7          	jalr	1130(ra) # 80003d70 <iput>
  end_op();
    8000590e:	fffff097          	auipc	ra,0xfffff
    80005912:	cea080e7          	jalr	-790(ra) # 800045f8 <end_op>
  return 0;
    80005916:	4781                	li	a5,0
    80005918:	a085                	j	80005978 <sys_link+0x13c>
    end_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	cde080e7          	jalr	-802(ra) # 800045f8 <end_op>
    return -1;
    80005922:	57fd                	li	a5,-1
    80005924:	a891                	j	80005978 <sys_link+0x13c>
    iunlockput(ip);
    80005926:	8526                	mv	a0,s1
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	4f0080e7          	jalr	1264(ra) # 80003e18 <iunlockput>
    end_op();
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	cc8080e7          	jalr	-824(ra) # 800045f8 <end_op>
    return -1;
    80005938:	57fd                	li	a5,-1
    8000593a:	a83d                	j	80005978 <sys_link+0x13c>
    iunlockput(dp);
    8000593c:	854a                	mv	a0,s2
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	4da080e7          	jalr	1242(ra) # 80003e18 <iunlockput>
  ilock(ip);
    80005946:	8526                	mv	a0,s1
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	26e080e7          	jalr	622(ra) # 80003bb6 <ilock>
  ip->nlink--;
    80005950:	04a4d783          	lhu	a5,74(s1)
    80005954:	37fd                	addiw	a5,a5,-1
    80005956:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000595a:	8526                	mv	a0,s1
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	190080e7          	jalr	400(ra) # 80003aec <iupdate>
  iunlockput(ip);
    80005964:	8526                	mv	a0,s1
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	4b2080e7          	jalr	1202(ra) # 80003e18 <iunlockput>
  end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	c8a080e7          	jalr	-886(ra) # 800045f8 <end_op>
  return -1;
    80005976:	57fd                	li	a5,-1
}
    80005978:	853e                	mv	a0,a5
    8000597a:	70b2                	ld	ra,296(sp)
    8000597c:	7412                	ld	s0,288(sp)
    8000597e:	64f2                	ld	s1,280(sp)
    80005980:	6952                	ld	s2,272(sp)
    80005982:	6155                	addi	sp,sp,304
    80005984:	8082                	ret

0000000080005986 <sys_unlink>:
{
    80005986:	7151                	addi	sp,sp,-240
    80005988:	f586                	sd	ra,232(sp)
    8000598a:	f1a2                	sd	s0,224(sp)
    8000598c:	eda6                	sd	s1,216(sp)
    8000598e:	e9ca                	sd	s2,208(sp)
    80005990:	e5ce                	sd	s3,200(sp)
    80005992:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005994:	08000613          	li	a2,128
    80005998:	f3040593          	addi	a1,s0,-208
    8000599c:	4501                	li	a0,0
    8000599e:	ffffd097          	auipc	ra,0xffffd
    800059a2:	560080e7          	jalr	1376(ra) # 80002efe <argstr>
    800059a6:	18054163          	bltz	a0,80005b28 <sys_unlink+0x1a2>
  begin_op();
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	bce080e7          	jalr	-1074(ra) # 80004578 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059b2:	fb040593          	addi	a1,s0,-80
    800059b6:	f3040513          	addi	a0,s0,-208
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	9c0080e7          	jalr	-1600(ra) # 8000437a <nameiparent>
    800059c2:	84aa                	mv	s1,a0
    800059c4:	c979                	beqz	a0,80005a9a <sys_unlink+0x114>
  ilock(dp);
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	1f0080e7          	jalr	496(ra) # 80003bb6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800059ce:	00003597          	auipc	a1,0x3
    800059d2:	d4258593          	addi	a1,a1,-702 # 80008710 <syscalls+0x2c0>
    800059d6:	fb040513          	addi	a0,s0,-80
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	6a6080e7          	jalr	1702(ra) # 80004080 <namecmp>
    800059e2:	14050a63          	beqz	a0,80005b36 <sys_unlink+0x1b0>
    800059e6:	00003597          	auipc	a1,0x3
    800059ea:	d3258593          	addi	a1,a1,-718 # 80008718 <syscalls+0x2c8>
    800059ee:	fb040513          	addi	a0,s0,-80
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	68e080e7          	jalr	1678(ra) # 80004080 <namecmp>
    800059fa:	12050e63          	beqz	a0,80005b36 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059fe:	f2c40613          	addi	a2,s0,-212
    80005a02:	fb040593          	addi	a1,s0,-80
    80005a06:	8526                	mv	a0,s1
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	692080e7          	jalr	1682(ra) # 8000409a <dirlookup>
    80005a10:	892a                	mv	s2,a0
    80005a12:	12050263          	beqz	a0,80005b36 <sys_unlink+0x1b0>
  ilock(ip);
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	1a0080e7          	jalr	416(ra) # 80003bb6 <ilock>
  if(ip->nlink < 1)
    80005a1e:	04a91783          	lh	a5,74(s2)
    80005a22:	08f05263          	blez	a5,80005aa6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a26:	04491703          	lh	a4,68(s2)
    80005a2a:	4785                	li	a5,1
    80005a2c:	08f70563          	beq	a4,a5,80005ab6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a30:	4641                	li	a2,16
    80005a32:	4581                	li	a1,0
    80005a34:	fc040513          	addi	a0,s0,-64
    80005a38:	ffffb097          	auipc	ra,0xffffb
    80005a3c:	29a080e7          	jalr	666(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a40:	4741                	li	a4,16
    80005a42:	f2c42683          	lw	a3,-212(s0)
    80005a46:	fc040613          	addi	a2,s0,-64
    80005a4a:	4581                	li	a1,0
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	514080e7          	jalr	1300(ra) # 80003f62 <writei>
    80005a56:	47c1                	li	a5,16
    80005a58:	0af51563          	bne	a0,a5,80005b02 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a5c:	04491703          	lh	a4,68(s2)
    80005a60:	4785                	li	a5,1
    80005a62:	0af70863          	beq	a4,a5,80005b12 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a66:	8526                	mv	a0,s1
    80005a68:	ffffe097          	auipc	ra,0xffffe
    80005a6c:	3b0080e7          	jalr	944(ra) # 80003e18 <iunlockput>
  ip->nlink--;
    80005a70:	04a95783          	lhu	a5,74(s2)
    80005a74:	37fd                	addiw	a5,a5,-1
    80005a76:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a7a:	854a                	mv	a0,s2
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	070080e7          	jalr	112(ra) # 80003aec <iupdate>
  iunlockput(ip);
    80005a84:	854a                	mv	a0,s2
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	392080e7          	jalr	914(ra) # 80003e18 <iunlockput>
  end_op();
    80005a8e:	fffff097          	auipc	ra,0xfffff
    80005a92:	b6a080e7          	jalr	-1174(ra) # 800045f8 <end_op>
  return 0;
    80005a96:	4501                	li	a0,0
    80005a98:	a84d                	j	80005b4a <sys_unlink+0x1c4>
    end_op();
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	b5e080e7          	jalr	-1186(ra) # 800045f8 <end_op>
    return -1;
    80005aa2:	557d                	li	a0,-1
    80005aa4:	a05d                	j	80005b4a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005aa6:	00003517          	auipc	a0,0x3
    80005aaa:	c7a50513          	addi	a0,a0,-902 # 80008720 <syscalls+0x2d0>
    80005aae:	ffffb097          	auipc	ra,0xffffb
    80005ab2:	a90080e7          	jalr	-1392(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ab6:	04c92703          	lw	a4,76(s2)
    80005aba:	02000793          	li	a5,32
    80005abe:	f6e7f9e3          	bgeu	a5,a4,80005a30 <sys_unlink+0xaa>
    80005ac2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ac6:	4741                	li	a4,16
    80005ac8:	86ce                	mv	a3,s3
    80005aca:	f1840613          	addi	a2,s0,-232
    80005ace:	4581                	li	a1,0
    80005ad0:	854a                	mv	a0,s2
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	398080e7          	jalr	920(ra) # 80003e6a <readi>
    80005ada:	47c1                	li	a5,16
    80005adc:	00f51b63          	bne	a0,a5,80005af2 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ae0:	f1845783          	lhu	a5,-232(s0)
    80005ae4:	e7a1                	bnez	a5,80005b2c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ae6:	29c1                	addiw	s3,s3,16
    80005ae8:	04c92783          	lw	a5,76(s2)
    80005aec:	fcf9ede3          	bltu	s3,a5,80005ac6 <sys_unlink+0x140>
    80005af0:	b781                	j	80005a30 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005af2:	00003517          	auipc	a0,0x3
    80005af6:	c4650513          	addi	a0,a0,-954 # 80008738 <syscalls+0x2e8>
    80005afa:	ffffb097          	auipc	ra,0xffffb
    80005afe:	a44080e7          	jalr	-1468(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005b02:	00003517          	auipc	a0,0x3
    80005b06:	c4e50513          	addi	a0,a0,-946 # 80008750 <syscalls+0x300>
    80005b0a:	ffffb097          	auipc	ra,0xffffb
    80005b0e:	a34080e7          	jalr	-1484(ra) # 8000053e <panic>
    dp->nlink--;
    80005b12:	04a4d783          	lhu	a5,74(s1)
    80005b16:	37fd                	addiw	a5,a5,-1
    80005b18:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	fce080e7          	jalr	-50(ra) # 80003aec <iupdate>
    80005b26:	b781                	j	80005a66 <sys_unlink+0xe0>
    return -1;
    80005b28:	557d                	li	a0,-1
    80005b2a:	a005                	j	80005b4a <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b2c:	854a                	mv	a0,s2
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	2ea080e7          	jalr	746(ra) # 80003e18 <iunlockput>
  iunlockput(dp);
    80005b36:	8526                	mv	a0,s1
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	2e0080e7          	jalr	736(ra) # 80003e18 <iunlockput>
  end_op();
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	ab8080e7          	jalr	-1352(ra) # 800045f8 <end_op>
  return -1;
    80005b48:	557d                	li	a0,-1
}
    80005b4a:	70ae                	ld	ra,232(sp)
    80005b4c:	740e                	ld	s0,224(sp)
    80005b4e:	64ee                	ld	s1,216(sp)
    80005b50:	694e                	ld	s2,208(sp)
    80005b52:	69ae                	ld	s3,200(sp)
    80005b54:	616d                	addi	sp,sp,240
    80005b56:	8082                	ret

0000000080005b58 <sys_open>:

uint64
sys_open(void)
{
    80005b58:	7131                	addi	sp,sp,-192
    80005b5a:	fd06                	sd	ra,184(sp)
    80005b5c:	f922                	sd	s0,176(sp)
    80005b5e:	f526                	sd	s1,168(sp)
    80005b60:	f14a                	sd	s2,160(sp)
    80005b62:	ed4e                	sd	s3,152(sp)
    80005b64:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b66:	f4c40593          	addi	a1,s0,-180
    80005b6a:	4505                	li	a0,1
    80005b6c:	ffffd097          	auipc	ra,0xffffd
    80005b70:	352080e7          	jalr	850(ra) # 80002ebe <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b74:	08000613          	li	a2,128
    80005b78:	f5040593          	addi	a1,s0,-176
    80005b7c:	4501                	li	a0,0
    80005b7e:	ffffd097          	auipc	ra,0xffffd
    80005b82:	380080e7          	jalr	896(ra) # 80002efe <argstr>
    80005b86:	87aa                	mv	a5,a0
    return -1;
    80005b88:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b8a:	0a07c963          	bltz	a5,80005c3c <sys_open+0xe4>

  begin_op();
    80005b8e:	fffff097          	auipc	ra,0xfffff
    80005b92:	9ea080e7          	jalr	-1558(ra) # 80004578 <begin_op>

  if(omode & O_CREATE){
    80005b96:	f4c42783          	lw	a5,-180(s0)
    80005b9a:	2007f793          	andi	a5,a5,512
    80005b9e:	cfc5                	beqz	a5,80005c56 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005ba0:	4681                	li	a3,0
    80005ba2:	4601                	li	a2,0
    80005ba4:	4589                	li	a1,2
    80005ba6:	f5040513          	addi	a0,s0,-176
    80005baa:	00000097          	auipc	ra,0x0
    80005bae:	976080e7          	jalr	-1674(ra) # 80005520 <create>
    80005bb2:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bb4:	c959                	beqz	a0,80005c4a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bb6:	04449703          	lh	a4,68(s1)
    80005bba:	478d                	li	a5,3
    80005bbc:	00f71763          	bne	a4,a5,80005bca <sys_open+0x72>
    80005bc0:	0464d703          	lhu	a4,70(s1)
    80005bc4:	47a5                	li	a5,9
    80005bc6:	0ce7ed63          	bltu	a5,a4,80005ca0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bca:	fffff097          	auipc	ra,0xfffff
    80005bce:	dbe080e7          	jalr	-578(ra) # 80004988 <filealloc>
    80005bd2:	89aa                	mv	s3,a0
    80005bd4:	10050363          	beqz	a0,80005cda <sys_open+0x182>
    80005bd8:	00000097          	auipc	ra,0x0
    80005bdc:	906080e7          	jalr	-1786(ra) # 800054de <fdalloc>
    80005be0:	892a                	mv	s2,a0
    80005be2:	0e054763          	bltz	a0,80005cd0 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005be6:	04449703          	lh	a4,68(s1)
    80005bea:	478d                	li	a5,3
    80005bec:	0cf70563          	beq	a4,a5,80005cb6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005bf0:	4789                	li	a5,2
    80005bf2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005bf6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005bfa:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005bfe:	f4c42783          	lw	a5,-180(s0)
    80005c02:	0017c713          	xori	a4,a5,1
    80005c06:	8b05                	andi	a4,a4,1
    80005c08:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c0c:	0037f713          	andi	a4,a5,3
    80005c10:	00e03733          	snez	a4,a4
    80005c14:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c18:	4007f793          	andi	a5,a5,1024
    80005c1c:	c791                	beqz	a5,80005c28 <sys_open+0xd0>
    80005c1e:	04449703          	lh	a4,68(s1)
    80005c22:	4789                	li	a5,2
    80005c24:	0af70063          	beq	a4,a5,80005cc4 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c28:	8526                	mv	a0,s1
    80005c2a:	ffffe097          	auipc	ra,0xffffe
    80005c2e:	04e080e7          	jalr	78(ra) # 80003c78 <iunlock>
  end_op();
    80005c32:	fffff097          	auipc	ra,0xfffff
    80005c36:	9c6080e7          	jalr	-1594(ra) # 800045f8 <end_op>

  return fd;
    80005c3a:	854a                	mv	a0,s2
}
    80005c3c:	70ea                	ld	ra,184(sp)
    80005c3e:	744a                	ld	s0,176(sp)
    80005c40:	74aa                	ld	s1,168(sp)
    80005c42:	790a                	ld	s2,160(sp)
    80005c44:	69ea                	ld	s3,152(sp)
    80005c46:	6129                	addi	sp,sp,192
    80005c48:	8082                	ret
      end_op();
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	9ae080e7          	jalr	-1618(ra) # 800045f8 <end_op>
      return -1;
    80005c52:	557d                	li	a0,-1
    80005c54:	b7e5                	j	80005c3c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c56:	f5040513          	addi	a0,s0,-176
    80005c5a:	ffffe097          	auipc	ra,0xffffe
    80005c5e:	702080e7          	jalr	1794(ra) # 8000435c <namei>
    80005c62:	84aa                	mv	s1,a0
    80005c64:	c905                	beqz	a0,80005c94 <sys_open+0x13c>
    ilock(ip);
    80005c66:	ffffe097          	auipc	ra,0xffffe
    80005c6a:	f50080e7          	jalr	-176(ra) # 80003bb6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c6e:	04449703          	lh	a4,68(s1)
    80005c72:	4785                	li	a5,1
    80005c74:	f4f711e3          	bne	a4,a5,80005bb6 <sys_open+0x5e>
    80005c78:	f4c42783          	lw	a5,-180(s0)
    80005c7c:	d7b9                	beqz	a5,80005bca <sys_open+0x72>
      iunlockput(ip);
    80005c7e:	8526                	mv	a0,s1
    80005c80:	ffffe097          	auipc	ra,0xffffe
    80005c84:	198080e7          	jalr	408(ra) # 80003e18 <iunlockput>
      end_op();
    80005c88:	fffff097          	auipc	ra,0xfffff
    80005c8c:	970080e7          	jalr	-1680(ra) # 800045f8 <end_op>
      return -1;
    80005c90:	557d                	li	a0,-1
    80005c92:	b76d                	j	80005c3c <sys_open+0xe4>
      end_op();
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	964080e7          	jalr	-1692(ra) # 800045f8 <end_op>
      return -1;
    80005c9c:	557d                	li	a0,-1
    80005c9e:	bf79                	j	80005c3c <sys_open+0xe4>
    iunlockput(ip);
    80005ca0:	8526                	mv	a0,s1
    80005ca2:	ffffe097          	auipc	ra,0xffffe
    80005ca6:	176080e7          	jalr	374(ra) # 80003e18 <iunlockput>
    end_op();
    80005caa:	fffff097          	auipc	ra,0xfffff
    80005cae:	94e080e7          	jalr	-1714(ra) # 800045f8 <end_op>
    return -1;
    80005cb2:	557d                	li	a0,-1
    80005cb4:	b761                	j	80005c3c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005cb6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cba:	04649783          	lh	a5,70(s1)
    80005cbe:	02f99223          	sh	a5,36(s3)
    80005cc2:	bf25                	j	80005bfa <sys_open+0xa2>
    itrunc(ip);
    80005cc4:	8526                	mv	a0,s1
    80005cc6:	ffffe097          	auipc	ra,0xffffe
    80005cca:	ffe080e7          	jalr	-2(ra) # 80003cc4 <itrunc>
    80005cce:	bfa9                	j	80005c28 <sys_open+0xd0>
      fileclose(f);
    80005cd0:	854e                	mv	a0,s3
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	d72080e7          	jalr	-654(ra) # 80004a44 <fileclose>
    iunlockput(ip);
    80005cda:	8526                	mv	a0,s1
    80005cdc:	ffffe097          	auipc	ra,0xffffe
    80005ce0:	13c080e7          	jalr	316(ra) # 80003e18 <iunlockput>
    end_op();
    80005ce4:	fffff097          	auipc	ra,0xfffff
    80005ce8:	914080e7          	jalr	-1772(ra) # 800045f8 <end_op>
    return -1;
    80005cec:	557d                	li	a0,-1
    80005cee:	b7b9                	j	80005c3c <sys_open+0xe4>

0000000080005cf0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005cf0:	7175                	addi	sp,sp,-144
    80005cf2:	e506                	sd	ra,136(sp)
    80005cf4:	e122                	sd	s0,128(sp)
    80005cf6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	880080e7          	jalr	-1920(ra) # 80004578 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d00:	08000613          	li	a2,128
    80005d04:	f7040593          	addi	a1,s0,-144
    80005d08:	4501                	li	a0,0
    80005d0a:	ffffd097          	auipc	ra,0xffffd
    80005d0e:	1f4080e7          	jalr	500(ra) # 80002efe <argstr>
    80005d12:	02054963          	bltz	a0,80005d44 <sys_mkdir+0x54>
    80005d16:	4681                	li	a3,0
    80005d18:	4601                	li	a2,0
    80005d1a:	4585                	li	a1,1
    80005d1c:	f7040513          	addi	a0,s0,-144
    80005d20:	00000097          	auipc	ra,0x0
    80005d24:	800080e7          	jalr	-2048(ra) # 80005520 <create>
    80005d28:	cd11                	beqz	a0,80005d44 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	0ee080e7          	jalr	238(ra) # 80003e18 <iunlockput>
  end_op();
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	8c6080e7          	jalr	-1850(ra) # 800045f8 <end_op>
  return 0;
    80005d3a:	4501                	li	a0,0
}
    80005d3c:	60aa                	ld	ra,136(sp)
    80005d3e:	640a                	ld	s0,128(sp)
    80005d40:	6149                	addi	sp,sp,144
    80005d42:	8082                	ret
    end_op();
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	8b4080e7          	jalr	-1868(ra) # 800045f8 <end_op>
    return -1;
    80005d4c:	557d                	li	a0,-1
    80005d4e:	b7fd                	j	80005d3c <sys_mkdir+0x4c>

0000000080005d50 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d50:	7135                	addi	sp,sp,-160
    80005d52:	ed06                	sd	ra,152(sp)
    80005d54:	e922                	sd	s0,144(sp)
    80005d56:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d58:	fffff097          	auipc	ra,0xfffff
    80005d5c:	820080e7          	jalr	-2016(ra) # 80004578 <begin_op>
  argint(1, &major);
    80005d60:	f6c40593          	addi	a1,s0,-148
    80005d64:	4505                	li	a0,1
    80005d66:	ffffd097          	auipc	ra,0xffffd
    80005d6a:	158080e7          	jalr	344(ra) # 80002ebe <argint>
  argint(2, &minor);
    80005d6e:	f6840593          	addi	a1,s0,-152
    80005d72:	4509                	li	a0,2
    80005d74:	ffffd097          	auipc	ra,0xffffd
    80005d78:	14a080e7          	jalr	330(ra) # 80002ebe <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d7c:	08000613          	li	a2,128
    80005d80:	f7040593          	addi	a1,s0,-144
    80005d84:	4501                	li	a0,0
    80005d86:	ffffd097          	auipc	ra,0xffffd
    80005d8a:	178080e7          	jalr	376(ra) # 80002efe <argstr>
    80005d8e:	02054b63          	bltz	a0,80005dc4 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d92:	f6841683          	lh	a3,-152(s0)
    80005d96:	f6c41603          	lh	a2,-148(s0)
    80005d9a:	458d                	li	a1,3
    80005d9c:	f7040513          	addi	a0,s0,-144
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	780080e7          	jalr	1920(ra) # 80005520 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005da8:	cd11                	beqz	a0,80005dc4 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005daa:	ffffe097          	auipc	ra,0xffffe
    80005dae:	06e080e7          	jalr	110(ra) # 80003e18 <iunlockput>
  end_op();
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	846080e7          	jalr	-1978(ra) # 800045f8 <end_op>
  return 0;
    80005dba:	4501                	li	a0,0
}
    80005dbc:	60ea                	ld	ra,152(sp)
    80005dbe:	644a                	ld	s0,144(sp)
    80005dc0:	610d                	addi	sp,sp,160
    80005dc2:	8082                	ret
    end_op();
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	834080e7          	jalr	-1996(ra) # 800045f8 <end_op>
    return -1;
    80005dcc:	557d                	li	a0,-1
    80005dce:	b7fd                	j	80005dbc <sys_mknod+0x6c>

0000000080005dd0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005dd0:	7135                	addi	sp,sp,-160
    80005dd2:	ed06                	sd	ra,152(sp)
    80005dd4:	e922                	sd	s0,144(sp)
    80005dd6:	e526                	sd	s1,136(sp)
    80005dd8:	e14a                	sd	s2,128(sp)
    80005dda:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ddc:	ffffc097          	auipc	ra,0xffffc
    80005de0:	d74080e7          	jalr	-652(ra) # 80001b50 <myproc>
    80005de4:	892a                	mv	s2,a0
  
  begin_op();
    80005de6:	ffffe097          	auipc	ra,0xffffe
    80005dea:	792080e7          	jalr	1938(ra) # 80004578 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005dee:	08000613          	li	a2,128
    80005df2:	f6040593          	addi	a1,s0,-160
    80005df6:	4501                	li	a0,0
    80005df8:	ffffd097          	auipc	ra,0xffffd
    80005dfc:	106080e7          	jalr	262(ra) # 80002efe <argstr>
    80005e00:	04054b63          	bltz	a0,80005e56 <sys_chdir+0x86>
    80005e04:	f6040513          	addi	a0,s0,-160
    80005e08:	ffffe097          	auipc	ra,0xffffe
    80005e0c:	554080e7          	jalr	1364(ra) # 8000435c <namei>
    80005e10:	84aa                	mv	s1,a0
    80005e12:	c131                	beqz	a0,80005e56 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e14:	ffffe097          	auipc	ra,0xffffe
    80005e18:	da2080e7          	jalr	-606(ra) # 80003bb6 <ilock>
  if(ip->type != T_DIR){
    80005e1c:	04449703          	lh	a4,68(s1)
    80005e20:	4785                	li	a5,1
    80005e22:	04f71063          	bne	a4,a5,80005e62 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e26:	8526                	mv	a0,s1
    80005e28:	ffffe097          	auipc	ra,0xffffe
    80005e2c:	e50080e7          	jalr	-432(ra) # 80003c78 <iunlock>
  iput(p->cwd);
    80005e30:	16093503          	ld	a0,352(s2)
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	f3c080e7          	jalr	-196(ra) # 80003d70 <iput>
  end_op();
    80005e3c:	ffffe097          	auipc	ra,0xffffe
    80005e40:	7bc080e7          	jalr	1980(ra) # 800045f8 <end_op>
  p->cwd = ip;
    80005e44:	16993023          	sd	s1,352(s2)
  return 0;
    80005e48:	4501                	li	a0,0
}
    80005e4a:	60ea                	ld	ra,152(sp)
    80005e4c:	644a                	ld	s0,144(sp)
    80005e4e:	64aa                	ld	s1,136(sp)
    80005e50:	690a                	ld	s2,128(sp)
    80005e52:	610d                	addi	sp,sp,160
    80005e54:	8082                	ret
    end_op();
    80005e56:	ffffe097          	auipc	ra,0xffffe
    80005e5a:	7a2080e7          	jalr	1954(ra) # 800045f8 <end_op>
    return -1;
    80005e5e:	557d                	li	a0,-1
    80005e60:	b7ed                	j	80005e4a <sys_chdir+0x7a>
    iunlockput(ip);
    80005e62:	8526                	mv	a0,s1
    80005e64:	ffffe097          	auipc	ra,0xffffe
    80005e68:	fb4080e7          	jalr	-76(ra) # 80003e18 <iunlockput>
    end_op();
    80005e6c:	ffffe097          	auipc	ra,0xffffe
    80005e70:	78c080e7          	jalr	1932(ra) # 800045f8 <end_op>
    return -1;
    80005e74:	557d                	li	a0,-1
    80005e76:	bfd1                	j	80005e4a <sys_chdir+0x7a>

0000000080005e78 <sys_exec>:

uint64
sys_exec(void)
{
    80005e78:	7145                	addi	sp,sp,-464
    80005e7a:	e786                	sd	ra,456(sp)
    80005e7c:	e3a2                	sd	s0,448(sp)
    80005e7e:	ff26                	sd	s1,440(sp)
    80005e80:	fb4a                	sd	s2,432(sp)
    80005e82:	f74e                	sd	s3,424(sp)
    80005e84:	f352                	sd	s4,416(sp)
    80005e86:	ef56                	sd	s5,408(sp)
    80005e88:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e8a:	e3840593          	addi	a1,s0,-456
    80005e8e:	4505                	li	a0,1
    80005e90:	ffffd097          	auipc	ra,0xffffd
    80005e94:	04e080e7          	jalr	78(ra) # 80002ede <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e98:	08000613          	li	a2,128
    80005e9c:	f4040593          	addi	a1,s0,-192
    80005ea0:	4501                	li	a0,0
    80005ea2:	ffffd097          	auipc	ra,0xffffd
    80005ea6:	05c080e7          	jalr	92(ra) # 80002efe <argstr>
    80005eaa:	87aa                	mv	a5,a0
    return -1;
    80005eac:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005eae:	0c07c263          	bltz	a5,80005f72 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005eb2:	10000613          	li	a2,256
    80005eb6:	4581                	li	a1,0
    80005eb8:	e4040513          	addi	a0,s0,-448
    80005ebc:	ffffb097          	auipc	ra,0xffffb
    80005ec0:	e16080e7          	jalr	-490(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ec4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ec8:	89a6                	mv	s3,s1
    80005eca:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ecc:	02000a13          	li	s4,32
    80005ed0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ed4:	00391793          	slli	a5,s2,0x3
    80005ed8:	e3040593          	addi	a1,s0,-464
    80005edc:	e3843503          	ld	a0,-456(s0)
    80005ee0:	953e                	add	a0,a0,a5
    80005ee2:	ffffd097          	auipc	ra,0xffffd
    80005ee6:	f3e080e7          	jalr	-194(ra) # 80002e20 <fetchaddr>
    80005eea:	02054a63          	bltz	a0,80005f1e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005eee:	e3043783          	ld	a5,-464(s0)
    80005ef2:	c3b9                	beqz	a5,80005f38 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ef4:	ffffb097          	auipc	ra,0xffffb
    80005ef8:	bf2080e7          	jalr	-1038(ra) # 80000ae6 <kalloc>
    80005efc:	85aa                	mv	a1,a0
    80005efe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f02:	cd11                	beqz	a0,80005f1e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f04:	6605                	lui	a2,0x1
    80005f06:	e3043503          	ld	a0,-464(s0)
    80005f0a:	ffffd097          	auipc	ra,0xffffd
    80005f0e:	f68080e7          	jalr	-152(ra) # 80002e72 <fetchstr>
    80005f12:	00054663          	bltz	a0,80005f1e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f16:	0905                	addi	s2,s2,1
    80005f18:	09a1                	addi	s3,s3,8
    80005f1a:	fb491be3          	bne	s2,s4,80005ed0 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f1e:	10048913          	addi	s2,s1,256
    80005f22:	6088                	ld	a0,0(s1)
    80005f24:	c531                	beqz	a0,80005f70 <sys_exec+0xf8>
    kfree(argv[i]);
    80005f26:	ffffb097          	auipc	ra,0xffffb
    80005f2a:	ac4080e7          	jalr	-1340(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f2e:	04a1                	addi	s1,s1,8
    80005f30:	ff2499e3          	bne	s1,s2,80005f22 <sys_exec+0xaa>
  return -1;
    80005f34:	557d                	li	a0,-1
    80005f36:	a835                	j	80005f72 <sys_exec+0xfa>
      argv[i] = 0;
    80005f38:	0a8e                	slli	s5,s5,0x3
    80005f3a:	fc040793          	addi	a5,s0,-64
    80005f3e:	9abe                	add	s5,s5,a5
    80005f40:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f44:	e4040593          	addi	a1,s0,-448
    80005f48:	f4040513          	addi	a0,s0,-192
    80005f4c:	fffff097          	auipc	ra,0xfffff
    80005f50:	172080e7          	jalr	370(ra) # 800050be <exec>
    80005f54:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f56:	10048993          	addi	s3,s1,256
    80005f5a:	6088                	ld	a0,0(s1)
    80005f5c:	c901                	beqz	a0,80005f6c <sys_exec+0xf4>
    kfree(argv[i]);
    80005f5e:	ffffb097          	auipc	ra,0xffffb
    80005f62:	a8c080e7          	jalr	-1396(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f66:	04a1                	addi	s1,s1,8
    80005f68:	ff3499e3          	bne	s1,s3,80005f5a <sys_exec+0xe2>
  return ret;
    80005f6c:	854a                	mv	a0,s2
    80005f6e:	a011                	j	80005f72 <sys_exec+0xfa>
  return -1;
    80005f70:	557d                	li	a0,-1
}
    80005f72:	60be                	ld	ra,456(sp)
    80005f74:	641e                	ld	s0,448(sp)
    80005f76:	74fa                	ld	s1,440(sp)
    80005f78:	795a                	ld	s2,432(sp)
    80005f7a:	79ba                	ld	s3,424(sp)
    80005f7c:	7a1a                	ld	s4,416(sp)
    80005f7e:	6afa                	ld	s5,408(sp)
    80005f80:	6179                	addi	sp,sp,464
    80005f82:	8082                	ret

0000000080005f84 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f84:	7139                	addi	sp,sp,-64
    80005f86:	fc06                	sd	ra,56(sp)
    80005f88:	f822                	sd	s0,48(sp)
    80005f8a:	f426                	sd	s1,40(sp)
    80005f8c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f8e:	ffffc097          	auipc	ra,0xffffc
    80005f92:	bc2080e7          	jalr	-1086(ra) # 80001b50 <myproc>
    80005f96:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f98:	fd840593          	addi	a1,s0,-40
    80005f9c:	4501                	li	a0,0
    80005f9e:	ffffd097          	auipc	ra,0xffffd
    80005fa2:	f40080e7          	jalr	-192(ra) # 80002ede <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005fa6:	fc840593          	addi	a1,s0,-56
    80005faa:	fd040513          	addi	a0,s0,-48
    80005fae:	fffff097          	auipc	ra,0xfffff
    80005fb2:	dc6080e7          	jalr	-570(ra) # 80004d74 <pipealloc>
    return -1;
    80005fb6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005fb8:	0c054463          	bltz	a0,80006080 <sys_pipe+0xfc>
  fd0 = -1;
    80005fbc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fc0:	fd043503          	ld	a0,-48(s0)
    80005fc4:	fffff097          	auipc	ra,0xfffff
    80005fc8:	51a080e7          	jalr	1306(ra) # 800054de <fdalloc>
    80005fcc:	fca42223          	sw	a0,-60(s0)
    80005fd0:	08054b63          	bltz	a0,80006066 <sys_pipe+0xe2>
    80005fd4:	fc843503          	ld	a0,-56(s0)
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	506080e7          	jalr	1286(ra) # 800054de <fdalloc>
    80005fe0:	fca42023          	sw	a0,-64(s0)
    80005fe4:	06054863          	bltz	a0,80006054 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fe8:	4691                	li	a3,4
    80005fea:	fc440613          	addi	a2,s0,-60
    80005fee:	fd843583          	ld	a1,-40(s0)
    80005ff2:	70a8                	ld	a0,96(s1)
    80005ff4:	ffffb097          	auipc	ra,0xffffb
    80005ff8:	67c080e7          	jalr	1660(ra) # 80001670 <copyout>
    80005ffc:	02054063          	bltz	a0,8000601c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006000:	4691                	li	a3,4
    80006002:	fc040613          	addi	a2,s0,-64
    80006006:	fd843583          	ld	a1,-40(s0)
    8000600a:	0591                	addi	a1,a1,4
    8000600c:	70a8                	ld	a0,96(s1)
    8000600e:	ffffb097          	auipc	ra,0xffffb
    80006012:	662080e7          	jalr	1634(ra) # 80001670 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006016:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006018:	06055463          	bgez	a0,80006080 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000601c:	fc442783          	lw	a5,-60(s0)
    80006020:	07f1                	addi	a5,a5,28
    80006022:	078e                	slli	a5,a5,0x3
    80006024:	97a6                	add	a5,a5,s1
    80006026:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000602a:	fc042503          	lw	a0,-64(s0)
    8000602e:	0571                	addi	a0,a0,28
    80006030:	050e                	slli	a0,a0,0x3
    80006032:	94aa                	add	s1,s1,a0
    80006034:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006038:	fd043503          	ld	a0,-48(s0)
    8000603c:	fffff097          	auipc	ra,0xfffff
    80006040:	a08080e7          	jalr	-1528(ra) # 80004a44 <fileclose>
    fileclose(wf);
    80006044:	fc843503          	ld	a0,-56(s0)
    80006048:	fffff097          	auipc	ra,0xfffff
    8000604c:	9fc080e7          	jalr	-1540(ra) # 80004a44 <fileclose>
    return -1;
    80006050:	57fd                	li	a5,-1
    80006052:	a03d                	j	80006080 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006054:	fc442783          	lw	a5,-60(s0)
    80006058:	0007c763          	bltz	a5,80006066 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000605c:	07f1                	addi	a5,a5,28
    8000605e:	078e                	slli	a5,a5,0x3
    80006060:	94be                	add	s1,s1,a5
    80006062:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006066:	fd043503          	ld	a0,-48(s0)
    8000606a:	fffff097          	auipc	ra,0xfffff
    8000606e:	9da080e7          	jalr	-1574(ra) # 80004a44 <fileclose>
    fileclose(wf);
    80006072:	fc843503          	ld	a0,-56(s0)
    80006076:	fffff097          	auipc	ra,0xfffff
    8000607a:	9ce080e7          	jalr	-1586(ra) # 80004a44 <fileclose>
    return -1;
    8000607e:	57fd                	li	a5,-1
}
    80006080:	853e                	mv	a0,a5
    80006082:	70e2                	ld	ra,56(sp)
    80006084:	7442                	ld	s0,48(sp)
    80006086:	74a2                	ld	s1,40(sp)
    80006088:	6121                	addi	sp,sp,64
    8000608a:	8082                	ret
    8000608c:	0000                	unimp
	...

0000000080006090 <kernelvec>:
    80006090:	7111                	addi	sp,sp,-256
    80006092:	e006                	sd	ra,0(sp)
    80006094:	e40a                	sd	sp,8(sp)
    80006096:	e80e                	sd	gp,16(sp)
    80006098:	ec12                	sd	tp,24(sp)
    8000609a:	f016                	sd	t0,32(sp)
    8000609c:	f41a                	sd	t1,40(sp)
    8000609e:	f81e                	sd	t2,48(sp)
    800060a0:	fc22                	sd	s0,56(sp)
    800060a2:	e0a6                	sd	s1,64(sp)
    800060a4:	e4aa                	sd	a0,72(sp)
    800060a6:	e8ae                	sd	a1,80(sp)
    800060a8:	ecb2                	sd	a2,88(sp)
    800060aa:	f0b6                	sd	a3,96(sp)
    800060ac:	f4ba                	sd	a4,104(sp)
    800060ae:	f8be                	sd	a5,112(sp)
    800060b0:	fcc2                	sd	a6,120(sp)
    800060b2:	e146                	sd	a7,128(sp)
    800060b4:	e54a                	sd	s2,136(sp)
    800060b6:	e94e                	sd	s3,144(sp)
    800060b8:	ed52                	sd	s4,152(sp)
    800060ba:	f156                	sd	s5,160(sp)
    800060bc:	f55a                	sd	s6,168(sp)
    800060be:	f95e                	sd	s7,176(sp)
    800060c0:	fd62                	sd	s8,184(sp)
    800060c2:	e1e6                	sd	s9,192(sp)
    800060c4:	e5ea                	sd	s10,200(sp)
    800060c6:	e9ee                	sd	s11,208(sp)
    800060c8:	edf2                	sd	t3,216(sp)
    800060ca:	f1f6                	sd	t4,224(sp)
    800060cc:	f5fa                	sd	t5,232(sp)
    800060ce:	f9fe                	sd	t6,240(sp)
    800060d0:	c1dfc0ef          	jal	ra,80002cec <kerneltrap>
    800060d4:	6082                	ld	ra,0(sp)
    800060d6:	6122                	ld	sp,8(sp)
    800060d8:	61c2                	ld	gp,16(sp)
    800060da:	7282                	ld	t0,32(sp)
    800060dc:	7322                	ld	t1,40(sp)
    800060de:	73c2                	ld	t2,48(sp)
    800060e0:	7462                	ld	s0,56(sp)
    800060e2:	6486                	ld	s1,64(sp)
    800060e4:	6526                	ld	a0,72(sp)
    800060e6:	65c6                	ld	a1,80(sp)
    800060e8:	6666                	ld	a2,88(sp)
    800060ea:	7686                	ld	a3,96(sp)
    800060ec:	7726                	ld	a4,104(sp)
    800060ee:	77c6                	ld	a5,112(sp)
    800060f0:	7866                	ld	a6,120(sp)
    800060f2:	688a                	ld	a7,128(sp)
    800060f4:	692a                	ld	s2,136(sp)
    800060f6:	69ca                	ld	s3,144(sp)
    800060f8:	6a6a                	ld	s4,152(sp)
    800060fa:	7a8a                	ld	s5,160(sp)
    800060fc:	7b2a                	ld	s6,168(sp)
    800060fe:	7bca                	ld	s7,176(sp)
    80006100:	7c6a                	ld	s8,184(sp)
    80006102:	6c8e                	ld	s9,192(sp)
    80006104:	6d2e                	ld	s10,200(sp)
    80006106:	6dce                	ld	s11,208(sp)
    80006108:	6e6e                	ld	t3,216(sp)
    8000610a:	7e8e                	ld	t4,224(sp)
    8000610c:	7f2e                	ld	t5,232(sp)
    8000610e:	7fce                	ld	t6,240(sp)
    80006110:	6111                	addi	sp,sp,256
    80006112:	10200073          	sret
    80006116:	00000013          	nop
    8000611a:	00000013          	nop
    8000611e:	0001                	nop

0000000080006120 <timervec>:
    80006120:	34051573          	csrrw	a0,mscratch,a0
    80006124:	e10c                	sd	a1,0(a0)
    80006126:	e510                	sd	a2,8(a0)
    80006128:	e914                	sd	a3,16(a0)
    8000612a:	6d0c                	ld	a1,24(a0)
    8000612c:	7110                	ld	a2,32(a0)
    8000612e:	6194                	ld	a3,0(a1)
    80006130:	96b2                	add	a3,a3,a2
    80006132:	e194                	sd	a3,0(a1)
    80006134:	4589                	li	a1,2
    80006136:	14459073          	csrw	sip,a1
    8000613a:	6914                	ld	a3,16(a0)
    8000613c:	6510                	ld	a2,8(a0)
    8000613e:	610c                	ld	a1,0(a0)
    80006140:	34051573          	csrrw	a0,mscratch,a0
    80006144:	30200073          	mret
	...

000000008000614a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000614a:	1141                	addi	sp,sp,-16
    8000614c:	e422                	sd	s0,8(sp)
    8000614e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006150:	0c0007b7          	lui	a5,0xc000
    80006154:	4705                	li	a4,1
    80006156:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006158:	c3d8                	sw	a4,4(a5)
}
    8000615a:	6422                	ld	s0,8(sp)
    8000615c:	0141                	addi	sp,sp,16
    8000615e:	8082                	ret

0000000080006160 <plicinithart>:

void
plicinithart(void)
{
    80006160:	1141                	addi	sp,sp,-16
    80006162:	e406                	sd	ra,8(sp)
    80006164:	e022                	sd	s0,0(sp)
    80006166:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006168:	ffffc097          	auipc	ra,0xffffc
    8000616c:	9bc080e7          	jalr	-1604(ra) # 80001b24 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006170:	0085171b          	slliw	a4,a0,0x8
    80006174:	0c0027b7          	lui	a5,0xc002
    80006178:	97ba                	add	a5,a5,a4
    8000617a:	40200713          	li	a4,1026
    8000617e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006182:	00d5151b          	slliw	a0,a0,0xd
    80006186:	0c2017b7          	lui	a5,0xc201
    8000618a:	953e                	add	a0,a0,a5
    8000618c:	00052023          	sw	zero,0(a0)
}
    80006190:	60a2                	ld	ra,8(sp)
    80006192:	6402                	ld	s0,0(sp)
    80006194:	0141                	addi	sp,sp,16
    80006196:	8082                	ret

0000000080006198 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006198:	1141                	addi	sp,sp,-16
    8000619a:	e406                	sd	ra,8(sp)
    8000619c:	e022                	sd	s0,0(sp)
    8000619e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061a0:	ffffc097          	auipc	ra,0xffffc
    800061a4:	984080e7          	jalr	-1660(ra) # 80001b24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061a8:	00d5179b          	slliw	a5,a0,0xd
    800061ac:	0c201537          	lui	a0,0xc201
    800061b0:	953e                	add	a0,a0,a5
  return irq;
}
    800061b2:	4148                	lw	a0,4(a0)
    800061b4:	60a2                	ld	ra,8(sp)
    800061b6:	6402                	ld	s0,0(sp)
    800061b8:	0141                	addi	sp,sp,16
    800061ba:	8082                	ret

00000000800061bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061bc:	1101                	addi	sp,sp,-32
    800061be:	ec06                	sd	ra,24(sp)
    800061c0:	e822                	sd	s0,16(sp)
    800061c2:	e426                	sd	s1,8(sp)
    800061c4:	1000                	addi	s0,sp,32
    800061c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061c8:	ffffc097          	auipc	ra,0xffffc
    800061cc:	95c080e7          	jalr	-1700(ra) # 80001b24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800061d0:	00d5151b          	slliw	a0,a0,0xd
    800061d4:	0c2017b7          	lui	a5,0xc201
    800061d8:	97aa                	add	a5,a5,a0
    800061da:	c3c4                	sw	s1,4(a5)
}
    800061dc:	60e2                	ld	ra,24(sp)
    800061de:	6442                	ld	s0,16(sp)
    800061e0:	64a2                	ld	s1,8(sp)
    800061e2:	6105                	addi	sp,sp,32
    800061e4:	8082                	ret

00000000800061e6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800061e6:	1141                	addi	sp,sp,-16
    800061e8:	e406                	sd	ra,8(sp)
    800061ea:	e022                	sd	s0,0(sp)
    800061ec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061ee:	479d                	li	a5,7
    800061f0:	04a7cc63          	blt	a5,a0,80006248 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800061f4:	0001d797          	auipc	a5,0x1d
    800061f8:	05c78793          	addi	a5,a5,92 # 80023250 <disk>
    800061fc:	97aa                	add	a5,a5,a0
    800061fe:	0187c783          	lbu	a5,24(a5)
    80006202:	ebb9                	bnez	a5,80006258 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006204:	00451613          	slli	a2,a0,0x4
    80006208:	0001d797          	auipc	a5,0x1d
    8000620c:	04878793          	addi	a5,a5,72 # 80023250 <disk>
    80006210:	6394                	ld	a3,0(a5)
    80006212:	96b2                	add	a3,a3,a2
    80006214:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006218:	6398                	ld	a4,0(a5)
    8000621a:	9732                	add	a4,a4,a2
    8000621c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006220:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006224:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006228:	953e                	add	a0,a0,a5
    8000622a:	4785                	li	a5,1
    8000622c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006230:	0001d517          	auipc	a0,0x1d
    80006234:	03850513          	addi	a0,a0,56 # 80023268 <disk+0x18>
    80006238:	ffffc097          	auipc	ra,0xffffc
    8000623c:	068080e7          	jalr	104(ra) # 800022a0 <wakeup>
}
    80006240:	60a2                	ld	ra,8(sp)
    80006242:	6402                	ld	s0,0(sp)
    80006244:	0141                	addi	sp,sp,16
    80006246:	8082                	ret
    panic("free_desc 1");
    80006248:	00002517          	auipc	a0,0x2
    8000624c:	51850513          	addi	a0,a0,1304 # 80008760 <syscalls+0x310>
    80006250:	ffffa097          	auipc	ra,0xffffa
    80006254:	2ee080e7          	jalr	750(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006258:	00002517          	auipc	a0,0x2
    8000625c:	51850513          	addi	a0,a0,1304 # 80008770 <syscalls+0x320>
    80006260:	ffffa097          	auipc	ra,0xffffa
    80006264:	2de080e7          	jalr	734(ra) # 8000053e <panic>

0000000080006268 <virtio_disk_init>:
{
    80006268:	1101                	addi	sp,sp,-32
    8000626a:	ec06                	sd	ra,24(sp)
    8000626c:	e822                	sd	s0,16(sp)
    8000626e:	e426                	sd	s1,8(sp)
    80006270:	e04a                	sd	s2,0(sp)
    80006272:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006274:	00002597          	auipc	a1,0x2
    80006278:	50c58593          	addi	a1,a1,1292 # 80008780 <syscalls+0x330>
    8000627c:	0001d517          	auipc	a0,0x1d
    80006280:	0fc50513          	addi	a0,a0,252 # 80023378 <disk+0x128>
    80006284:	ffffb097          	auipc	ra,0xffffb
    80006288:	8c2080e7          	jalr	-1854(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000628c:	100017b7          	lui	a5,0x10001
    80006290:	4398                	lw	a4,0(a5)
    80006292:	2701                	sext.w	a4,a4
    80006294:	747277b7          	lui	a5,0x74727
    80006298:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000629c:	14f71c63          	bne	a4,a5,800063f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062a0:	100017b7          	lui	a5,0x10001
    800062a4:	43dc                	lw	a5,4(a5)
    800062a6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062a8:	4709                	li	a4,2
    800062aa:	14e79563          	bne	a5,a4,800063f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062ae:	100017b7          	lui	a5,0x10001
    800062b2:	479c                	lw	a5,8(a5)
    800062b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062b6:	12e79f63          	bne	a5,a4,800063f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062ba:	100017b7          	lui	a5,0x10001
    800062be:	47d8                	lw	a4,12(a5)
    800062c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062c2:	554d47b7          	lui	a5,0x554d4
    800062c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062ca:	12f71563          	bne	a4,a5,800063f4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ce:	100017b7          	lui	a5,0x10001
    800062d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062d6:	4705                	li	a4,1
    800062d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062da:	470d                	li	a4,3
    800062dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800062de:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062e0:	c7ffe737          	lui	a4,0xc7ffe
    800062e4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb3cf>
    800062e8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062ea:	2701                	sext.w	a4,a4
    800062ec:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ee:	472d                	li	a4,11
    800062f0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800062f2:	5bbc                	lw	a5,112(a5)
    800062f4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800062f8:	8ba1                	andi	a5,a5,8
    800062fa:	10078563          	beqz	a5,80006404 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062fe:	100017b7          	lui	a5,0x10001
    80006302:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006306:	43fc                	lw	a5,68(a5)
    80006308:	2781                	sext.w	a5,a5
    8000630a:	10079563          	bnez	a5,80006414 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000630e:	100017b7          	lui	a5,0x10001
    80006312:	5bdc                	lw	a5,52(a5)
    80006314:	2781                	sext.w	a5,a5
  if(max == 0)
    80006316:	10078763          	beqz	a5,80006424 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000631a:	471d                	li	a4,7
    8000631c:	10f77c63          	bgeu	a4,a5,80006434 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006320:	ffffa097          	auipc	ra,0xffffa
    80006324:	7c6080e7          	jalr	1990(ra) # 80000ae6 <kalloc>
    80006328:	0001d497          	auipc	s1,0x1d
    8000632c:	f2848493          	addi	s1,s1,-216 # 80023250 <disk>
    80006330:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006332:	ffffa097          	auipc	ra,0xffffa
    80006336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000633a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000633c:	ffffa097          	auipc	ra,0xffffa
    80006340:	7aa080e7          	jalr	1962(ra) # 80000ae6 <kalloc>
    80006344:	87aa                	mv	a5,a0
    80006346:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006348:	6088                	ld	a0,0(s1)
    8000634a:	cd6d                	beqz	a0,80006444 <virtio_disk_init+0x1dc>
    8000634c:	0001d717          	auipc	a4,0x1d
    80006350:	f0c73703          	ld	a4,-244(a4) # 80023258 <disk+0x8>
    80006354:	cb65                	beqz	a4,80006444 <virtio_disk_init+0x1dc>
    80006356:	c7fd                	beqz	a5,80006444 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006358:	6605                	lui	a2,0x1
    8000635a:	4581                	li	a1,0
    8000635c:	ffffb097          	auipc	ra,0xffffb
    80006360:	976080e7          	jalr	-1674(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006364:	0001d497          	auipc	s1,0x1d
    80006368:	eec48493          	addi	s1,s1,-276 # 80023250 <disk>
    8000636c:	6605                	lui	a2,0x1
    8000636e:	4581                	li	a1,0
    80006370:	6488                	ld	a0,8(s1)
    80006372:	ffffb097          	auipc	ra,0xffffb
    80006376:	960080e7          	jalr	-1696(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000637a:	6605                	lui	a2,0x1
    8000637c:	4581                	li	a1,0
    8000637e:	6888                	ld	a0,16(s1)
    80006380:	ffffb097          	auipc	ra,0xffffb
    80006384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006388:	100017b7          	lui	a5,0x10001
    8000638c:	4721                	li	a4,8
    8000638e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006390:	4098                	lw	a4,0(s1)
    80006392:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006396:	40d8                	lw	a4,4(s1)
    80006398:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000639c:	6498                	ld	a4,8(s1)
    8000639e:	0007069b          	sext.w	a3,a4
    800063a2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063a6:	9701                	srai	a4,a4,0x20
    800063a8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063ac:	6898                	ld	a4,16(s1)
    800063ae:	0007069b          	sext.w	a3,a4
    800063b2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063b6:	9701                	srai	a4,a4,0x20
    800063b8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063bc:	4705                	li	a4,1
    800063be:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800063c0:	00e48c23          	sb	a4,24(s1)
    800063c4:	00e48ca3          	sb	a4,25(s1)
    800063c8:	00e48d23          	sb	a4,26(s1)
    800063cc:	00e48da3          	sb	a4,27(s1)
    800063d0:	00e48e23          	sb	a4,28(s1)
    800063d4:	00e48ea3          	sb	a4,29(s1)
    800063d8:	00e48f23          	sb	a4,30(s1)
    800063dc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800063e0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800063e4:	0727a823          	sw	s2,112(a5)
}
    800063e8:	60e2                	ld	ra,24(sp)
    800063ea:	6442                	ld	s0,16(sp)
    800063ec:	64a2                	ld	s1,8(sp)
    800063ee:	6902                	ld	s2,0(sp)
    800063f0:	6105                	addi	sp,sp,32
    800063f2:	8082                	ret
    panic("could not find virtio disk");
    800063f4:	00002517          	auipc	a0,0x2
    800063f8:	39c50513          	addi	a0,a0,924 # 80008790 <syscalls+0x340>
    800063fc:	ffffa097          	auipc	ra,0xffffa
    80006400:	142080e7          	jalr	322(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006404:	00002517          	auipc	a0,0x2
    80006408:	3ac50513          	addi	a0,a0,940 # 800087b0 <syscalls+0x360>
    8000640c:	ffffa097          	auipc	ra,0xffffa
    80006410:	132080e7          	jalr	306(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006414:	00002517          	auipc	a0,0x2
    80006418:	3bc50513          	addi	a0,a0,956 # 800087d0 <syscalls+0x380>
    8000641c:	ffffa097          	auipc	ra,0xffffa
    80006420:	122080e7          	jalr	290(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006424:	00002517          	auipc	a0,0x2
    80006428:	3cc50513          	addi	a0,a0,972 # 800087f0 <syscalls+0x3a0>
    8000642c:	ffffa097          	auipc	ra,0xffffa
    80006430:	112080e7          	jalr	274(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006434:	00002517          	auipc	a0,0x2
    80006438:	3dc50513          	addi	a0,a0,988 # 80008810 <syscalls+0x3c0>
    8000643c:	ffffa097          	auipc	ra,0xffffa
    80006440:	102080e7          	jalr	258(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006444:	00002517          	auipc	a0,0x2
    80006448:	3ec50513          	addi	a0,a0,1004 # 80008830 <syscalls+0x3e0>
    8000644c:	ffffa097          	auipc	ra,0xffffa
    80006450:	0f2080e7          	jalr	242(ra) # 8000053e <panic>

0000000080006454 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006454:	7119                	addi	sp,sp,-128
    80006456:	fc86                	sd	ra,120(sp)
    80006458:	f8a2                	sd	s0,112(sp)
    8000645a:	f4a6                	sd	s1,104(sp)
    8000645c:	f0ca                	sd	s2,96(sp)
    8000645e:	ecce                	sd	s3,88(sp)
    80006460:	e8d2                	sd	s4,80(sp)
    80006462:	e4d6                	sd	s5,72(sp)
    80006464:	e0da                	sd	s6,64(sp)
    80006466:	fc5e                	sd	s7,56(sp)
    80006468:	f862                	sd	s8,48(sp)
    8000646a:	f466                	sd	s9,40(sp)
    8000646c:	f06a                	sd	s10,32(sp)
    8000646e:	ec6e                	sd	s11,24(sp)
    80006470:	0100                	addi	s0,sp,128
    80006472:	8aaa                	mv	s5,a0
    80006474:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006476:	00c52d03          	lw	s10,12(a0)
    8000647a:	001d1d1b          	slliw	s10,s10,0x1
    8000647e:	1d02                	slli	s10,s10,0x20
    80006480:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006484:	0001d517          	auipc	a0,0x1d
    80006488:	ef450513          	addi	a0,a0,-268 # 80023378 <disk+0x128>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	74a080e7          	jalr	1866(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006494:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006496:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006498:	0001db97          	auipc	s7,0x1d
    8000649c:	db8b8b93          	addi	s7,s7,-584 # 80023250 <disk>
  for(int i = 0; i < 3; i++){
    800064a0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064a2:	0001dc97          	auipc	s9,0x1d
    800064a6:	ed6c8c93          	addi	s9,s9,-298 # 80023378 <disk+0x128>
    800064aa:	a08d                	j	8000650c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800064ac:	00fb8733          	add	a4,s7,a5
    800064b0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064b4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064b6:	0207c563          	bltz	a5,800064e0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800064ba:	2905                	addiw	s2,s2,1
    800064bc:	0611                	addi	a2,a2,4
    800064be:	05690c63          	beq	s2,s6,80006516 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800064c2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064c4:	0001d717          	auipc	a4,0x1d
    800064c8:	d8c70713          	addi	a4,a4,-628 # 80023250 <disk>
    800064cc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064ce:	01874683          	lbu	a3,24(a4)
    800064d2:	fee9                	bnez	a3,800064ac <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800064d4:	2785                	addiw	a5,a5,1
    800064d6:	0705                	addi	a4,a4,1
    800064d8:	fe979be3          	bne	a5,s1,800064ce <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800064dc:	57fd                	li	a5,-1
    800064de:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800064e0:	01205d63          	blez	s2,800064fa <virtio_disk_rw+0xa6>
    800064e4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800064e6:	000a2503          	lw	a0,0(s4)
    800064ea:	00000097          	auipc	ra,0x0
    800064ee:	cfc080e7          	jalr	-772(ra) # 800061e6 <free_desc>
      for(int j = 0; j < i; j++)
    800064f2:	2d85                	addiw	s11,s11,1
    800064f4:	0a11                	addi	s4,s4,4
    800064f6:	ffb918e3          	bne	s2,s11,800064e6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064fa:	85e6                	mv	a1,s9
    800064fc:	0001d517          	auipc	a0,0x1d
    80006500:	d6c50513          	addi	a0,a0,-660 # 80023268 <disk+0x18>
    80006504:	ffffc097          	auipc	ra,0xffffc
    80006508:	d38080e7          	jalr	-712(ra) # 8000223c <sleep>
  for(int i = 0; i < 3; i++){
    8000650c:	f8040a13          	addi	s4,s0,-128
{
    80006510:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006512:	894e                	mv	s2,s3
    80006514:	b77d                	j	800064c2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006516:	f8042583          	lw	a1,-128(s0)
    8000651a:	00a58793          	addi	a5,a1,10
    8000651e:	0792                	slli	a5,a5,0x4

  if(write)
    80006520:	0001d617          	auipc	a2,0x1d
    80006524:	d3060613          	addi	a2,a2,-720 # 80023250 <disk>
    80006528:	00f60733          	add	a4,a2,a5
    8000652c:	018036b3          	snez	a3,s8
    80006530:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006532:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006536:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000653a:	f6078693          	addi	a3,a5,-160
    8000653e:	6218                	ld	a4,0(a2)
    80006540:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006542:	00878513          	addi	a0,a5,8
    80006546:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006548:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000654a:	6208                	ld	a0,0(a2)
    8000654c:	96aa                	add	a3,a3,a0
    8000654e:	4741                	li	a4,16
    80006550:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006552:	4705                	li	a4,1
    80006554:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006558:	f8442703          	lw	a4,-124(s0)
    8000655c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006560:	0712                	slli	a4,a4,0x4
    80006562:	953a                	add	a0,a0,a4
    80006564:	058a8693          	addi	a3,s5,88
    80006568:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000656a:	6208                	ld	a0,0(a2)
    8000656c:	972a                	add	a4,a4,a0
    8000656e:	40000693          	li	a3,1024
    80006572:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006574:	001c3c13          	seqz	s8,s8
    80006578:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000657a:	001c6c13          	ori	s8,s8,1
    8000657e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006582:	f8842603          	lw	a2,-120(s0)
    80006586:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000658a:	0001d697          	auipc	a3,0x1d
    8000658e:	cc668693          	addi	a3,a3,-826 # 80023250 <disk>
    80006592:	00258713          	addi	a4,a1,2
    80006596:	0712                	slli	a4,a4,0x4
    80006598:	9736                	add	a4,a4,a3
    8000659a:	587d                	li	a6,-1
    8000659c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065a0:	0612                	slli	a2,a2,0x4
    800065a2:	9532                	add	a0,a0,a2
    800065a4:	f9078793          	addi	a5,a5,-112
    800065a8:	97b6                	add	a5,a5,a3
    800065aa:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800065ac:	629c                	ld	a5,0(a3)
    800065ae:	97b2                	add	a5,a5,a2
    800065b0:	4605                	li	a2,1
    800065b2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065b4:	4509                	li	a0,2
    800065b6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800065ba:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065be:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065c2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065c6:	6698                	ld	a4,8(a3)
    800065c8:	00275783          	lhu	a5,2(a4)
    800065cc:	8b9d                	andi	a5,a5,7
    800065ce:	0786                	slli	a5,a5,0x1
    800065d0:	97ba                	add	a5,a5,a4
    800065d2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800065d6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065da:	6698                	ld	a4,8(a3)
    800065dc:	00275783          	lhu	a5,2(a4)
    800065e0:	2785                	addiw	a5,a5,1
    800065e2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065e6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065ea:	100017b7          	lui	a5,0x10001
    800065ee:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065f2:	004aa783          	lw	a5,4(s5)
    800065f6:	02c79163          	bne	a5,a2,80006618 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800065fa:	0001d917          	auipc	s2,0x1d
    800065fe:	d7e90913          	addi	s2,s2,-642 # 80023378 <disk+0x128>
  while(b->disk == 1) {
    80006602:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006604:	85ca                	mv	a1,s2
    80006606:	8556                	mv	a0,s5
    80006608:	ffffc097          	auipc	ra,0xffffc
    8000660c:	c34080e7          	jalr	-972(ra) # 8000223c <sleep>
  while(b->disk == 1) {
    80006610:	004aa783          	lw	a5,4(s5)
    80006614:	fe9788e3          	beq	a5,s1,80006604 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006618:	f8042903          	lw	s2,-128(s0)
    8000661c:	00290793          	addi	a5,s2,2
    80006620:	00479713          	slli	a4,a5,0x4
    80006624:	0001d797          	auipc	a5,0x1d
    80006628:	c2c78793          	addi	a5,a5,-980 # 80023250 <disk>
    8000662c:	97ba                	add	a5,a5,a4
    8000662e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006632:	0001d997          	auipc	s3,0x1d
    80006636:	c1e98993          	addi	s3,s3,-994 # 80023250 <disk>
    8000663a:	00491713          	slli	a4,s2,0x4
    8000663e:	0009b783          	ld	a5,0(s3)
    80006642:	97ba                	add	a5,a5,a4
    80006644:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006648:	854a                	mv	a0,s2
    8000664a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000664e:	00000097          	auipc	ra,0x0
    80006652:	b98080e7          	jalr	-1128(ra) # 800061e6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006656:	8885                	andi	s1,s1,1
    80006658:	f0ed                	bnez	s1,8000663a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000665a:	0001d517          	auipc	a0,0x1d
    8000665e:	d1e50513          	addi	a0,a0,-738 # 80023378 <disk+0x128>
    80006662:	ffffa097          	auipc	ra,0xffffa
    80006666:	628080e7          	jalr	1576(ra) # 80000c8a <release>
}
    8000666a:	70e6                	ld	ra,120(sp)
    8000666c:	7446                	ld	s0,112(sp)
    8000666e:	74a6                	ld	s1,104(sp)
    80006670:	7906                	ld	s2,96(sp)
    80006672:	69e6                	ld	s3,88(sp)
    80006674:	6a46                	ld	s4,80(sp)
    80006676:	6aa6                	ld	s5,72(sp)
    80006678:	6b06                	ld	s6,64(sp)
    8000667a:	7be2                	ld	s7,56(sp)
    8000667c:	7c42                	ld	s8,48(sp)
    8000667e:	7ca2                	ld	s9,40(sp)
    80006680:	7d02                	ld	s10,32(sp)
    80006682:	6de2                	ld	s11,24(sp)
    80006684:	6109                	addi	sp,sp,128
    80006686:	8082                	ret

0000000080006688 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006688:	1101                	addi	sp,sp,-32
    8000668a:	ec06                	sd	ra,24(sp)
    8000668c:	e822                	sd	s0,16(sp)
    8000668e:	e426                	sd	s1,8(sp)
    80006690:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006692:	0001d497          	auipc	s1,0x1d
    80006696:	bbe48493          	addi	s1,s1,-1090 # 80023250 <disk>
    8000669a:	0001d517          	auipc	a0,0x1d
    8000669e:	cde50513          	addi	a0,a0,-802 # 80023378 <disk+0x128>
    800066a2:	ffffa097          	auipc	ra,0xffffa
    800066a6:	534080e7          	jalr	1332(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066aa:	10001737          	lui	a4,0x10001
    800066ae:	533c                	lw	a5,96(a4)
    800066b0:	8b8d                	andi	a5,a5,3
    800066b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066b8:	689c                	ld	a5,16(s1)
    800066ba:	0204d703          	lhu	a4,32(s1)
    800066be:	0027d783          	lhu	a5,2(a5)
    800066c2:	04f70863          	beq	a4,a5,80006712 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066c6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066ca:	6898                	ld	a4,16(s1)
    800066cc:	0204d783          	lhu	a5,32(s1)
    800066d0:	8b9d                	andi	a5,a5,7
    800066d2:	078e                	slli	a5,a5,0x3
    800066d4:	97ba                	add	a5,a5,a4
    800066d6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066d8:	00278713          	addi	a4,a5,2
    800066dc:	0712                	slli	a4,a4,0x4
    800066de:	9726                	add	a4,a4,s1
    800066e0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800066e4:	e721                	bnez	a4,8000672c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066e6:	0789                	addi	a5,a5,2
    800066e8:	0792                	slli	a5,a5,0x4
    800066ea:	97a6                	add	a5,a5,s1
    800066ec:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800066ee:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800066f2:	ffffc097          	auipc	ra,0xffffc
    800066f6:	bae080e7          	jalr	-1106(ra) # 800022a0 <wakeup>

    disk.used_idx += 1;
    800066fa:	0204d783          	lhu	a5,32(s1)
    800066fe:	2785                	addiw	a5,a5,1
    80006700:	17c2                	slli	a5,a5,0x30
    80006702:	93c1                	srli	a5,a5,0x30
    80006704:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006708:	6898                	ld	a4,16(s1)
    8000670a:	00275703          	lhu	a4,2(a4)
    8000670e:	faf71ce3          	bne	a4,a5,800066c6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006712:	0001d517          	auipc	a0,0x1d
    80006716:	c6650513          	addi	a0,a0,-922 # 80023378 <disk+0x128>
    8000671a:	ffffa097          	auipc	ra,0xffffa
    8000671e:	570080e7          	jalr	1392(ra) # 80000c8a <release>
}
    80006722:	60e2                	ld	ra,24(sp)
    80006724:	6442                	ld	s0,16(sp)
    80006726:	64a2                	ld	s1,8(sp)
    80006728:	6105                	addi	sp,sp,32
    8000672a:	8082                	ret
      panic("virtio_disk_intr status");
    8000672c:	00002517          	auipc	a0,0x2
    80006730:	11c50513          	addi	a0,a0,284 # 80008848 <syscalls+0x3f8>
    80006734:	ffffa097          	auipc	ra,0xffffa
    80006738:	e0a080e7          	jalr	-502(ra) # 8000053e <panic>
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
