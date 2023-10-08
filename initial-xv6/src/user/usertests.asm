
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <killstatus>:
  }
}

// test if child is killed (status = -1)
void killstatus(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
      exit(1);
    }
  }
  exit(0);
#endif
}
       6:	6422                	ld	s0,8(sp)
       8:	0141                	addi	sp,sp,16
       a:	8082                	ret

000000000000000c <copyinstr1>:
{
       c:	1141                	addi	sp,sp,-16
       e:	e406                	sd	ra,8(sp)
      10:	e022                	sd	s0,0(sp)
      12:	0800                	addi	s0,sp,16
    int fd = open((char *)addr, O_CREATE | O_WRONLY);
      14:	20100593          	li	a1,513
      18:	4505                	li	a0,1
      1a:	057e                	slli	a0,a0,0x1f
      1c:	00006097          	auipc	ra,0x6
      20:	b54080e7          	jalr	-1196(ra) # 5b70 <open>
    if (fd >= 0)
      24:	02055063          	bgez	a0,44 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE | O_WRONLY);
      28:	20100593          	li	a1,513
      2c:	557d                	li	a0,-1
      2e:	00006097          	auipc	ra,0x6
      32:	b42080e7          	jalr	-1214(ra) # 5b70 <open>
    uint64 addr = addrs[ai];
      36:	55fd                	li	a1,-1
    if (fd >= 0)
      38:	00055863          	bgez	a0,48 <copyinstr1+0x3c>
}
      3c:	60a2                	ld	ra,8(sp)
      3e:	6402                	ld	s0,0(sp)
      40:	0141                	addi	sp,sp,16
      42:	8082                	ret
    uint64 addr = addrs[ai];
      44:	4585                	li	a1,1
      46:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      48:	862a                	mv	a2,a0
      4a:	00006517          	auipc	a0,0x6
      4e:	04650513          	addi	a0,a0,70 # 6090 <malloc+0x10a>
      52:	00006097          	auipc	ra,0x6
      56:	e76080e7          	jalr	-394(ra) # 5ec8 <printf>
      exit(1);
      5a:	4505                	li	a0,1
      5c:	00006097          	auipc	ra,0x6
      60:	ad4080e7          	jalr	-1324(ra) # 5b30 <exit>

0000000000000064 <bsstest>:
char uninit[10000];
void bsstest(char *s)
{
  int i;

  for (i = 0; i < sizeof(uninit); i++)
      64:	0000a797          	auipc	a5,0xa
      68:	50478793          	addi	a5,a5,1284 # a568 <uninit>
      6c:	0000d697          	auipc	a3,0xd
      70:	c0c68693          	addi	a3,a3,-1012 # cc78 <buf>
  {
    if (uninit[i] != '\0')
      74:	0007c703          	lbu	a4,0(a5)
      78:	e709                	bnez	a4,82 <bsstest+0x1e>
  for (i = 0; i < sizeof(uninit); i++)
      7a:	0785                	addi	a5,a5,1
      7c:	fed79ce3          	bne	a5,a3,74 <bsstest+0x10>
      80:	8082                	ret
{
      82:	1141                	addi	sp,sp,-16
      84:	e406                	sd	ra,8(sp)
      86:	e022                	sd	s0,0(sp)
      88:	0800                	addi	s0,sp,16
    {
      printf("%s: bss test failed\n", s);
      8a:	85aa                	mv	a1,a0
      8c:	00006517          	auipc	a0,0x6
      90:	02450513          	addi	a0,a0,36 # 60b0 <malloc+0x12a>
      94:	00006097          	auipc	ra,0x6
      98:	e34080e7          	jalr	-460(ra) # 5ec8 <printf>
      exit(1);
      9c:	4505                	li	a0,1
      9e:	00006097          	auipc	ra,0x6
      a2:	a92080e7          	jalr	-1390(ra) # 5b30 <exit>

00000000000000a6 <opentest>:
{
      a6:	1101                	addi	sp,sp,-32
      a8:	ec06                	sd	ra,24(sp)
      aa:	e822                	sd	s0,16(sp)
      ac:	e426                	sd	s1,8(sp)
      ae:	1000                	addi	s0,sp,32
      b0:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      b2:	4581                	li	a1,0
      b4:	00006517          	auipc	a0,0x6
      b8:	01450513          	addi	a0,a0,20 # 60c8 <malloc+0x142>
      bc:	00006097          	auipc	ra,0x6
      c0:	ab4080e7          	jalr	-1356(ra) # 5b70 <open>
  if (fd < 0)
      c4:	02054663          	bltz	a0,f0 <opentest+0x4a>
  close(fd);
      c8:	00006097          	auipc	ra,0x6
      cc:	a90080e7          	jalr	-1392(ra) # 5b58 <close>
  fd = open("doesnotexist", 0);
      d0:	4581                	li	a1,0
      d2:	00006517          	auipc	a0,0x6
      d6:	01650513          	addi	a0,a0,22 # 60e8 <malloc+0x162>
      da:	00006097          	auipc	ra,0x6
      de:	a96080e7          	jalr	-1386(ra) # 5b70 <open>
  if (fd >= 0)
      e2:	02055563          	bgez	a0,10c <opentest+0x66>
}
      e6:	60e2                	ld	ra,24(sp)
      e8:	6442                	ld	s0,16(sp)
      ea:	64a2                	ld	s1,8(sp)
      ec:	6105                	addi	sp,sp,32
      ee:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f0:	85a6                	mv	a1,s1
      f2:	00006517          	auipc	a0,0x6
      f6:	fde50513          	addi	a0,a0,-34 # 60d0 <malloc+0x14a>
      fa:	00006097          	auipc	ra,0x6
      fe:	dce080e7          	jalr	-562(ra) # 5ec8 <printf>
    exit(1);
     102:	4505                	li	a0,1
     104:	00006097          	auipc	ra,0x6
     108:	a2c080e7          	jalr	-1492(ra) # 5b30 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     10c:	85a6                	mv	a1,s1
     10e:	00006517          	auipc	a0,0x6
     112:	fea50513          	addi	a0,a0,-22 # 60f8 <malloc+0x172>
     116:	00006097          	auipc	ra,0x6
     11a:	db2080e7          	jalr	-590(ra) # 5ec8 <printf>
    exit(1);
     11e:	4505                	li	a0,1
     120:	00006097          	auipc	ra,0x6
     124:	a10080e7          	jalr	-1520(ra) # 5b30 <exit>

0000000000000128 <truncate2>:
{
     128:	7179                	addi	sp,sp,-48
     12a:	f406                	sd	ra,40(sp)
     12c:	f022                	sd	s0,32(sp)
     12e:	ec26                	sd	s1,24(sp)
     130:	e84a                	sd	s2,16(sp)
     132:	e44e                	sd	s3,8(sp)
     134:	1800                	addi	s0,sp,48
     136:	89aa                	mv	s3,a0
  unlink("truncfile");
     138:	00006517          	auipc	a0,0x6
     13c:	fe850513          	addi	a0,a0,-24 # 6120 <malloc+0x19a>
     140:	00006097          	auipc	ra,0x6
     144:	a40080e7          	jalr	-1472(ra) # 5b80 <unlink>
  int fd1 = open("truncfile", O_CREATE | O_TRUNC | O_WRONLY);
     148:	60100593          	li	a1,1537
     14c:	00006517          	auipc	a0,0x6
     150:	fd450513          	addi	a0,a0,-44 # 6120 <malloc+0x19a>
     154:	00006097          	auipc	ra,0x6
     158:	a1c080e7          	jalr	-1508(ra) # 5b70 <open>
     15c:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     15e:	4611                	li	a2,4
     160:	00006597          	auipc	a1,0x6
     164:	fd058593          	addi	a1,a1,-48 # 6130 <malloc+0x1aa>
     168:	00006097          	auipc	ra,0x6
     16c:	9e8080e7          	jalr	-1560(ra) # 5b50 <write>
  int fd2 = open("truncfile", O_TRUNC | O_WRONLY);
     170:	40100593          	li	a1,1025
     174:	00006517          	auipc	a0,0x6
     178:	fac50513          	addi	a0,a0,-84 # 6120 <malloc+0x19a>
     17c:	00006097          	auipc	ra,0x6
     180:	9f4080e7          	jalr	-1548(ra) # 5b70 <open>
     184:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     186:	4605                	li	a2,1
     188:	00006597          	auipc	a1,0x6
     18c:	fb058593          	addi	a1,a1,-80 # 6138 <malloc+0x1b2>
     190:	8526                	mv	a0,s1
     192:	00006097          	auipc	ra,0x6
     196:	9be080e7          	jalr	-1602(ra) # 5b50 <write>
  if (n != -1)
     19a:	57fd                	li	a5,-1
     19c:	02f51b63          	bne	a0,a5,1d2 <truncate2+0xaa>
  unlink("truncfile");
     1a0:	00006517          	auipc	a0,0x6
     1a4:	f8050513          	addi	a0,a0,-128 # 6120 <malloc+0x19a>
     1a8:	00006097          	auipc	ra,0x6
     1ac:	9d8080e7          	jalr	-1576(ra) # 5b80 <unlink>
  close(fd1);
     1b0:	8526                	mv	a0,s1
     1b2:	00006097          	auipc	ra,0x6
     1b6:	9a6080e7          	jalr	-1626(ra) # 5b58 <close>
  close(fd2);
     1ba:	854a                	mv	a0,s2
     1bc:	00006097          	auipc	ra,0x6
     1c0:	99c080e7          	jalr	-1636(ra) # 5b58 <close>
}
     1c4:	70a2                	ld	ra,40(sp)
     1c6:	7402                	ld	s0,32(sp)
     1c8:	64e2                	ld	s1,24(sp)
     1ca:	6942                	ld	s2,16(sp)
     1cc:	69a2                	ld	s3,8(sp)
     1ce:	6145                	addi	sp,sp,48
     1d0:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1d2:	862a                	mv	a2,a0
     1d4:	85ce                	mv	a1,s3
     1d6:	00006517          	auipc	a0,0x6
     1da:	f6a50513          	addi	a0,a0,-150 # 6140 <malloc+0x1ba>
     1de:	00006097          	auipc	ra,0x6
     1e2:	cea080e7          	jalr	-790(ra) # 5ec8 <printf>
    exit(1);
     1e6:	4505                	li	a0,1
     1e8:	00006097          	auipc	ra,0x6
     1ec:	948080e7          	jalr	-1720(ra) # 5b30 <exit>

00000000000001f0 <createtest>:
{
     1f0:	7179                	addi	sp,sp,-48
     1f2:	f406                	sd	ra,40(sp)
     1f4:	f022                	sd	s0,32(sp)
     1f6:	ec26                	sd	s1,24(sp)
     1f8:	e84a                	sd	s2,16(sp)
     1fa:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1fc:	06100793          	li	a5,97
     200:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     204:	fc040d23          	sb	zero,-38(s0)
     208:	03000493          	li	s1,48
  for (i = 0; i < N; i++)
     20c:	06400913          	li	s2,100
    name[1] = '0' + i;
     210:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE | O_RDWR);
     214:	20200593          	li	a1,514
     218:	fd840513          	addi	a0,s0,-40
     21c:	00006097          	auipc	ra,0x6
     220:	954080e7          	jalr	-1708(ra) # 5b70 <open>
    close(fd);
     224:	00006097          	auipc	ra,0x6
     228:	934080e7          	jalr	-1740(ra) # 5b58 <close>
  for (i = 0; i < N; i++)
     22c:	2485                	addiw	s1,s1,1
     22e:	0ff4f493          	andi	s1,s1,255
     232:	fd249fe3          	bne	s1,s2,210 <createtest+0x20>
  name[0] = 'a';
     236:	06100793          	li	a5,97
     23a:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     23e:	fc040d23          	sb	zero,-38(s0)
     242:	03000493          	li	s1,48
  for (i = 0; i < N; i++)
     246:	06400913          	li	s2,100
    name[1] = '0' + i;
     24a:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     24e:	fd840513          	addi	a0,s0,-40
     252:	00006097          	auipc	ra,0x6
     256:	92e080e7          	jalr	-1746(ra) # 5b80 <unlink>
  for (i = 0; i < N; i++)
     25a:	2485                	addiw	s1,s1,1
     25c:	0ff4f493          	andi	s1,s1,255
     260:	ff2495e3          	bne	s1,s2,24a <createtest+0x5a>
}
     264:	70a2                	ld	ra,40(sp)
     266:	7402                	ld	s0,32(sp)
     268:	64e2                	ld	s1,24(sp)
     26a:	6942                	ld	s2,16(sp)
     26c:	6145                	addi	sp,sp,48
     26e:	8082                	ret

0000000000000270 <bigwrite>:
{
     270:	715d                	addi	sp,sp,-80
     272:	e486                	sd	ra,72(sp)
     274:	e0a2                	sd	s0,64(sp)
     276:	fc26                	sd	s1,56(sp)
     278:	f84a                	sd	s2,48(sp)
     27a:	f44e                	sd	s3,40(sp)
     27c:	f052                	sd	s4,32(sp)
     27e:	ec56                	sd	s5,24(sp)
     280:	e85a                	sd	s6,16(sp)
     282:	e45e                	sd	s7,8(sp)
     284:	0880                	addi	s0,sp,80
     286:	8baa                	mv	s7,a0
  unlink("bigwrite");
     288:	00006517          	auipc	a0,0x6
     28c:	ee050513          	addi	a0,a0,-288 # 6168 <malloc+0x1e2>
     290:	00006097          	auipc	ra,0x6
     294:	8f0080e7          	jalr	-1808(ra) # 5b80 <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     298:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     29c:	00006a97          	auipc	s5,0x6
     2a0:	ecca8a93          	addi	s5,s5,-308 # 6168 <malloc+0x1e2>
      int cc = write(fd, buf, sz);
     2a4:	0000da17          	auipc	s4,0xd
     2a8:	9d4a0a13          	addi	s4,s4,-1580 # cc78 <buf>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     2ac:	6b0d                	lui	s6,0x3
     2ae:	1c9b0b13          	addi	s6,s6,457 # 31c9 <fourteen+0x199>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2b2:	20200593          	li	a1,514
     2b6:	8556                	mv	a0,s5
     2b8:	00006097          	auipc	ra,0x6
     2bc:	8b8080e7          	jalr	-1864(ra) # 5b70 <open>
     2c0:	892a                	mv	s2,a0
    if (fd < 0)
     2c2:	04054d63          	bltz	a0,31c <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2c6:	8626                	mv	a2,s1
     2c8:	85d2                	mv	a1,s4
     2ca:	00006097          	auipc	ra,0x6
     2ce:	886080e7          	jalr	-1914(ra) # 5b50 <write>
     2d2:	89aa                	mv	s3,a0
      if (cc != sz)
     2d4:	06a49463          	bne	s1,a0,33c <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2d8:	8626                	mv	a2,s1
     2da:	85d2                	mv	a1,s4
     2dc:	854a                	mv	a0,s2
     2de:	00006097          	auipc	ra,0x6
     2e2:	872080e7          	jalr	-1934(ra) # 5b50 <write>
      if (cc != sz)
     2e6:	04951963          	bne	a0,s1,338 <bigwrite+0xc8>
    close(fd);
     2ea:	854a                	mv	a0,s2
     2ec:	00006097          	auipc	ra,0x6
     2f0:	86c080e7          	jalr	-1940(ra) # 5b58 <close>
    unlink("bigwrite");
     2f4:	8556                	mv	a0,s5
     2f6:	00006097          	auipc	ra,0x6
     2fa:	88a080e7          	jalr	-1910(ra) # 5b80 <unlink>
  for (sz = 499; sz < (MAXOPBLOCKS + 2) * BSIZE; sz += 471)
     2fe:	1d74849b          	addiw	s1,s1,471
     302:	fb6498e3          	bne	s1,s6,2b2 <bigwrite+0x42>
}
     306:	60a6                	ld	ra,72(sp)
     308:	6406                	ld	s0,64(sp)
     30a:	74e2                	ld	s1,56(sp)
     30c:	7942                	ld	s2,48(sp)
     30e:	79a2                	ld	s3,40(sp)
     310:	7a02                	ld	s4,32(sp)
     312:	6ae2                	ld	s5,24(sp)
     314:	6b42                	ld	s6,16(sp)
     316:	6ba2                	ld	s7,8(sp)
     318:	6161                	addi	sp,sp,80
     31a:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     31c:	85de                	mv	a1,s7
     31e:	00006517          	auipc	a0,0x6
     322:	e5a50513          	addi	a0,a0,-422 # 6178 <malloc+0x1f2>
     326:	00006097          	auipc	ra,0x6
     32a:	ba2080e7          	jalr	-1118(ra) # 5ec8 <printf>
      exit(1);
     32e:	4505                	li	a0,1
     330:	00006097          	auipc	ra,0x6
     334:	800080e7          	jalr	-2048(ra) # 5b30 <exit>
     338:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     33a:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     33c:	86ce                	mv	a3,s3
     33e:	8626                	mv	a2,s1
     340:	85de                	mv	a1,s7
     342:	00006517          	auipc	a0,0x6
     346:	e5650513          	addi	a0,a0,-426 # 6198 <malloc+0x212>
     34a:	00006097          	auipc	ra,0x6
     34e:	b7e080e7          	jalr	-1154(ra) # 5ec8 <printf>
        exit(1);
     352:	4505                	li	a0,1
     354:	00005097          	auipc	ra,0x5
     358:	7dc080e7          	jalr	2012(ra) # 5b30 <exit>

000000000000035c <badwrite>:
// a block to be allocated for a file that is then not freed when the
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void badwrite(char *s)
{
     35c:	7179                	addi	sp,sp,-48
     35e:	f406                	sd	ra,40(sp)
     360:	f022                	sd	s0,32(sp)
     362:	ec26                	sd	s1,24(sp)
     364:	e84a                	sd	s2,16(sp)
     366:	e44e                	sd	s3,8(sp)
     368:	e052                	sd	s4,0(sp)
     36a:	1800                	addi	s0,sp,48
  int assumed_free = 600;

  unlink("junk");
     36c:	00006517          	auipc	a0,0x6
     370:	e4450513          	addi	a0,a0,-444 # 61b0 <malloc+0x22a>
     374:	00006097          	auipc	ra,0x6
     378:	80c080e7          	jalr	-2036(ra) # 5b80 <unlink>
     37c:	25800913          	li	s2,600
  for (int i = 0; i < assumed_free; i++)
  {
    int fd = open("junk", O_CREATE | O_WRONLY);
     380:	00006997          	auipc	s3,0x6
     384:	e3098993          	addi	s3,s3,-464 # 61b0 <malloc+0x22a>
    if (fd < 0)
    {
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char *)0xffffffffffL, 1);
     388:	5a7d                	li	s4,-1
     38a:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE | O_WRONLY);
     38e:	20100593          	li	a1,513
     392:	854e                	mv	a0,s3
     394:	00005097          	auipc	ra,0x5
     398:	7dc080e7          	jalr	2012(ra) # 5b70 <open>
     39c:	84aa                	mv	s1,a0
    if (fd < 0)
     39e:	06054b63          	bltz	a0,414 <badwrite+0xb8>
    write(fd, (char *)0xffffffffffL, 1);
     3a2:	4605                	li	a2,1
     3a4:	85d2                	mv	a1,s4
     3a6:	00005097          	auipc	ra,0x5
     3aa:	7aa080e7          	jalr	1962(ra) # 5b50 <write>
    close(fd);
     3ae:	8526                	mv	a0,s1
     3b0:	00005097          	auipc	ra,0x5
     3b4:	7a8080e7          	jalr	1960(ra) # 5b58 <close>
    unlink("junk");
     3b8:	854e                	mv	a0,s3
     3ba:	00005097          	auipc	ra,0x5
     3be:	7c6080e7          	jalr	1990(ra) # 5b80 <unlink>
  for (int i = 0; i < assumed_free; i++)
     3c2:	397d                	addiw	s2,s2,-1
     3c4:	fc0915e3          	bnez	s2,38e <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE | O_WRONLY);
     3c8:	20100593          	li	a1,513
     3cc:	00006517          	auipc	a0,0x6
     3d0:	de450513          	addi	a0,a0,-540 # 61b0 <malloc+0x22a>
     3d4:	00005097          	auipc	ra,0x5
     3d8:	79c080e7          	jalr	1948(ra) # 5b70 <open>
     3dc:	84aa                	mv	s1,a0
  if (fd < 0)
     3de:	04054863          	bltz	a0,42e <badwrite+0xd2>
  {
    printf("open junk failed\n");
    exit(1);
  }
  if (write(fd, "x", 1) != 1)
     3e2:	4605                	li	a2,1
     3e4:	00006597          	auipc	a1,0x6
     3e8:	d5458593          	addi	a1,a1,-684 # 6138 <malloc+0x1b2>
     3ec:	00005097          	auipc	ra,0x5
     3f0:	764080e7          	jalr	1892(ra) # 5b50 <write>
     3f4:	4785                	li	a5,1
     3f6:	04f50963          	beq	a0,a5,448 <badwrite+0xec>
  {
    printf("write failed\n");
     3fa:	00006517          	auipc	a0,0x6
     3fe:	dd650513          	addi	a0,a0,-554 # 61d0 <malloc+0x24a>
     402:	00006097          	auipc	ra,0x6
     406:	ac6080e7          	jalr	-1338(ra) # 5ec8 <printf>
    exit(1);
     40a:	4505                	li	a0,1
     40c:	00005097          	auipc	ra,0x5
     410:	724080e7          	jalr	1828(ra) # 5b30 <exit>
      printf("open junk failed\n");
     414:	00006517          	auipc	a0,0x6
     418:	da450513          	addi	a0,a0,-604 # 61b8 <malloc+0x232>
     41c:	00006097          	auipc	ra,0x6
     420:	aac080e7          	jalr	-1364(ra) # 5ec8 <printf>
      exit(1);
     424:	4505                	li	a0,1
     426:	00005097          	auipc	ra,0x5
     42a:	70a080e7          	jalr	1802(ra) # 5b30 <exit>
    printf("open junk failed\n");
     42e:	00006517          	auipc	a0,0x6
     432:	d8a50513          	addi	a0,a0,-630 # 61b8 <malloc+0x232>
     436:	00006097          	auipc	ra,0x6
     43a:	a92080e7          	jalr	-1390(ra) # 5ec8 <printf>
    exit(1);
     43e:	4505                	li	a0,1
     440:	00005097          	auipc	ra,0x5
     444:	6f0080e7          	jalr	1776(ra) # 5b30 <exit>
  }
  close(fd);
     448:	8526                	mv	a0,s1
     44a:	00005097          	auipc	ra,0x5
     44e:	70e080e7          	jalr	1806(ra) # 5b58 <close>
  unlink("junk");
     452:	00006517          	auipc	a0,0x6
     456:	d5e50513          	addi	a0,a0,-674 # 61b0 <malloc+0x22a>
     45a:	00005097          	auipc	ra,0x5
     45e:	726080e7          	jalr	1830(ra) # 5b80 <unlink>

  exit(0);
     462:	4501                	li	a0,0
     464:	00005097          	auipc	ra,0x5
     468:	6cc080e7          	jalr	1740(ra) # 5b30 <exit>

000000000000046c <outofinodes>:
    unlink(name);
  }
}

void outofinodes(char *s)
{
     46c:	715d                	addi	sp,sp,-80
     46e:	e486                	sd	ra,72(sp)
     470:	e0a2                	sd	s0,64(sp)
     472:	fc26                	sd	s1,56(sp)
     474:	f84a                	sd	s2,48(sp)
     476:	f44e                	sd	s3,40(sp)
     478:	0880                	addi	s0,sp,80
  int nzz = 32 * 32;
  for (int i = 0; i < nzz; i++)
     47a:	4481                	li	s1,0
  {
    char name[32];
    name[0] = 'z';
     47c:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
     480:	40000993          	li	s3,1024
    name[0] = 'z';
     484:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     488:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     48c:	41f4d79b          	sraiw	a5,s1,0x1f
     490:	01b7d71b          	srliw	a4,a5,0x1b
     494:	009707bb          	addw	a5,a4,s1
     498:	4057d69b          	sraiw	a3,a5,0x5
     49c:	0306869b          	addiw	a3,a3,48
     4a0:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     4a4:	8bfd                	andi	a5,a5,31
     4a6:	9f99                	subw	a5,a5,a4
     4a8:	0307879b          	addiw	a5,a5,48
     4ac:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4b0:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4b4:	fb040513          	addi	a0,s0,-80
     4b8:	00005097          	auipc	ra,0x5
     4bc:	6c8080e7          	jalr	1736(ra) # 5b80 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
     4c0:	60200593          	li	a1,1538
     4c4:	fb040513          	addi	a0,s0,-80
     4c8:	00005097          	auipc	ra,0x5
     4cc:	6a8080e7          	jalr	1704(ra) # 5b70 <open>
    if (fd < 0)
     4d0:	00054963          	bltz	a0,4e2 <outofinodes+0x76>
    {
      // failure is eventually expected.
      break;
    }
    close(fd);
     4d4:	00005097          	auipc	ra,0x5
     4d8:	684080e7          	jalr	1668(ra) # 5b58 <close>
  for (int i = 0; i < nzz; i++)
     4dc:	2485                	addiw	s1,s1,1
     4de:	fb3493e3          	bne	s1,s3,484 <outofinodes+0x18>
     4e2:	4481                	li	s1,0
  }

  for (int i = 0; i < nzz; i++)
  {
    char name[32];
    name[0] = 'z';
     4e4:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
     4e8:	40000993          	li	s3,1024
    name[0] = 'z';
     4ec:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4f0:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4f4:	41f4d79b          	sraiw	a5,s1,0x1f
     4f8:	01b7d71b          	srliw	a4,a5,0x1b
     4fc:	009707bb          	addw	a5,a4,s1
     500:	4057d69b          	sraiw	a3,a5,0x5
     504:	0306869b          	addiw	a3,a3,48
     508:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     50c:	8bfd                	andi	a5,a5,31
     50e:	9f99                	subw	a5,a5,a4
     510:	0307879b          	addiw	a5,a5,48
     514:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     518:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     51c:	fb040513          	addi	a0,s0,-80
     520:	00005097          	auipc	ra,0x5
     524:	660080e7          	jalr	1632(ra) # 5b80 <unlink>
  for (int i = 0; i < nzz; i++)
     528:	2485                	addiw	s1,s1,1
     52a:	fd3491e3          	bne	s1,s3,4ec <outofinodes+0x80>
  }
}
     52e:	60a6                	ld	ra,72(sp)
     530:	6406                	ld	s0,64(sp)
     532:	74e2                	ld	s1,56(sp)
     534:	7942                	ld	s2,48(sp)
     536:	79a2                	ld	s3,40(sp)
     538:	6161                	addi	sp,sp,80
     53a:	8082                	ret

000000000000053c <copyin>:
{
     53c:	715d                	addi	sp,sp,-80
     53e:	e486                	sd	ra,72(sp)
     540:	e0a2                	sd	s0,64(sp)
     542:	fc26                	sd	s1,56(sp)
     544:	f84a                	sd	s2,48(sp)
     546:	f44e                	sd	s3,40(sp)
     548:	f052                	sd	s4,32(sp)
     54a:	0880                	addi	s0,sp,80
  uint64 addrs[] = {0x80000000LL, 0xffffffffffffffff};
     54c:	4785                	li	a5,1
     54e:	07fe                	slli	a5,a5,0x1f
     550:	fcf43023          	sd	a5,-64(s0)
     554:	57fd                	li	a5,-1
     556:	fcf43423          	sd	a5,-56(s0)
  for (int ai = 0; ai < 2; ai++)
     55a:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     55e:	00006a17          	auipc	s4,0x6
     562:	c82a0a13          	addi	s4,s4,-894 # 61e0 <malloc+0x25a>
    uint64 addr = addrs[ai];
     566:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE | O_WRONLY);
     56a:	20100593          	li	a1,513
     56e:	8552                	mv	a0,s4
     570:	00005097          	auipc	ra,0x5
     574:	600080e7          	jalr	1536(ra) # 5b70 <open>
     578:	84aa                	mv	s1,a0
    if (fd < 0)
     57a:	08054863          	bltz	a0,60a <copyin+0xce>
    int n = write(fd, (void *)addr, 8192);
     57e:	6609                	lui	a2,0x2
     580:	85ce                	mv	a1,s3
     582:	00005097          	auipc	ra,0x5
     586:	5ce080e7          	jalr	1486(ra) # 5b50 <write>
    if (n >= 0)
     58a:	08055d63          	bgez	a0,624 <copyin+0xe8>
    close(fd);
     58e:	8526                	mv	a0,s1
     590:	00005097          	auipc	ra,0x5
     594:	5c8080e7          	jalr	1480(ra) # 5b58 <close>
    unlink("copyin1");
     598:	8552                	mv	a0,s4
     59a:	00005097          	auipc	ra,0x5
     59e:	5e6080e7          	jalr	1510(ra) # 5b80 <unlink>
    n = write(1, (char *)addr, 8192);
     5a2:	6609                	lui	a2,0x2
     5a4:	85ce                	mv	a1,s3
     5a6:	4505                	li	a0,1
     5a8:	00005097          	auipc	ra,0x5
     5ac:	5a8080e7          	jalr	1448(ra) # 5b50 <write>
    if (n > 0)
     5b0:	08a04963          	bgtz	a0,642 <copyin+0x106>
    if (pipe(fds) < 0)
     5b4:	fb840513          	addi	a0,s0,-72
     5b8:	00005097          	auipc	ra,0x5
     5bc:	588080e7          	jalr	1416(ra) # 5b40 <pipe>
     5c0:	0a054063          	bltz	a0,660 <copyin+0x124>
    n = write(fds[1], (char *)addr, 8192);
     5c4:	6609                	lui	a2,0x2
     5c6:	85ce                	mv	a1,s3
     5c8:	fbc42503          	lw	a0,-68(s0)
     5cc:	00005097          	auipc	ra,0x5
     5d0:	584080e7          	jalr	1412(ra) # 5b50 <write>
    if (n > 0)
     5d4:	0aa04363          	bgtz	a0,67a <copyin+0x13e>
    close(fds[0]);
     5d8:	fb842503          	lw	a0,-72(s0)
     5dc:	00005097          	auipc	ra,0x5
     5e0:	57c080e7          	jalr	1404(ra) # 5b58 <close>
    close(fds[1]);
     5e4:	fbc42503          	lw	a0,-68(s0)
     5e8:	00005097          	auipc	ra,0x5
     5ec:	570080e7          	jalr	1392(ra) # 5b58 <close>
  for (int ai = 0; ai < 2; ai++)
     5f0:	0921                	addi	s2,s2,8
     5f2:	fd040793          	addi	a5,s0,-48
     5f6:	f6f918e3          	bne	s2,a5,566 <copyin+0x2a>
}
     5fa:	60a6                	ld	ra,72(sp)
     5fc:	6406                	ld	s0,64(sp)
     5fe:	74e2                	ld	s1,56(sp)
     600:	7942                	ld	s2,48(sp)
     602:	79a2                	ld	s3,40(sp)
     604:	7a02                	ld	s4,32(sp)
     606:	6161                	addi	sp,sp,80
     608:	8082                	ret
      printf("open(copyin1) failed\n");
     60a:	00006517          	auipc	a0,0x6
     60e:	bde50513          	addi	a0,a0,-1058 # 61e8 <malloc+0x262>
     612:	00006097          	auipc	ra,0x6
     616:	8b6080e7          	jalr	-1866(ra) # 5ec8 <printf>
      exit(1);
     61a:	4505                	li	a0,1
     61c:	00005097          	auipc	ra,0x5
     620:	514080e7          	jalr	1300(ra) # 5b30 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     624:	862a                	mv	a2,a0
     626:	85ce                	mv	a1,s3
     628:	00006517          	auipc	a0,0x6
     62c:	bd850513          	addi	a0,a0,-1064 # 6200 <malloc+0x27a>
     630:	00006097          	auipc	ra,0x6
     634:	898080e7          	jalr	-1896(ra) # 5ec8 <printf>
      exit(1);
     638:	4505                	li	a0,1
     63a:	00005097          	auipc	ra,0x5
     63e:	4f6080e7          	jalr	1270(ra) # 5b30 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     642:	862a                	mv	a2,a0
     644:	85ce                	mv	a1,s3
     646:	00006517          	auipc	a0,0x6
     64a:	bea50513          	addi	a0,a0,-1046 # 6230 <malloc+0x2aa>
     64e:	00006097          	auipc	ra,0x6
     652:	87a080e7          	jalr	-1926(ra) # 5ec8 <printf>
      exit(1);
     656:	4505                	li	a0,1
     658:	00005097          	auipc	ra,0x5
     65c:	4d8080e7          	jalr	1240(ra) # 5b30 <exit>
      printf("pipe() failed\n");
     660:	00006517          	auipc	a0,0x6
     664:	c0050513          	addi	a0,a0,-1024 # 6260 <malloc+0x2da>
     668:	00006097          	auipc	ra,0x6
     66c:	860080e7          	jalr	-1952(ra) # 5ec8 <printf>
      exit(1);
     670:	4505                	li	a0,1
     672:	00005097          	auipc	ra,0x5
     676:	4be080e7          	jalr	1214(ra) # 5b30 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     67a:	862a                	mv	a2,a0
     67c:	85ce                	mv	a1,s3
     67e:	00006517          	auipc	a0,0x6
     682:	bf250513          	addi	a0,a0,-1038 # 6270 <malloc+0x2ea>
     686:	00006097          	auipc	ra,0x6
     68a:	842080e7          	jalr	-1982(ra) # 5ec8 <printf>
      exit(1);
     68e:	4505                	li	a0,1
     690:	00005097          	auipc	ra,0x5
     694:	4a0080e7          	jalr	1184(ra) # 5b30 <exit>

0000000000000698 <copyout>:
{
     698:	711d                	addi	sp,sp,-96
     69a:	ec86                	sd	ra,88(sp)
     69c:	e8a2                	sd	s0,80(sp)
     69e:	e4a6                	sd	s1,72(sp)
     6a0:	e0ca                	sd	s2,64(sp)
     6a2:	fc4e                	sd	s3,56(sp)
     6a4:	f852                	sd	s4,48(sp)
     6a6:	f456                	sd	s5,40(sp)
     6a8:	1080                	addi	s0,sp,96
  uint64 addrs[] = {0x80000000LL, 0xffffffffffffffff};
     6aa:	4785                	li	a5,1
     6ac:	07fe                	slli	a5,a5,0x1f
     6ae:	faf43823          	sd	a5,-80(s0)
     6b2:	57fd                	li	a5,-1
     6b4:	faf43c23          	sd	a5,-72(s0)
  for (int ai = 0; ai < 2; ai++)
     6b8:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     6bc:	00006a17          	auipc	s4,0x6
     6c0:	be4a0a13          	addi	s4,s4,-1052 # 62a0 <malloc+0x31a>
    n = write(fds[1], "x", 1);
     6c4:	00006a97          	auipc	s5,0x6
     6c8:	a74a8a93          	addi	s5,s5,-1420 # 6138 <malloc+0x1b2>
    uint64 addr = addrs[ai];
     6cc:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6d0:	4581                	li	a1,0
     6d2:	8552                	mv	a0,s4
     6d4:	00005097          	auipc	ra,0x5
     6d8:	49c080e7          	jalr	1180(ra) # 5b70 <open>
     6dc:	84aa                	mv	s1,a0
    if (fd < 0)
     6de:	08054663          	bltz	a0,76a <copyout+0xd2>
    int n = read(fd, (void *)addr, 8192);
     6e2:	6609                	lui	a2,0x2
     6e4:	85ce                	mv	a1,s3
     6e6:	00005097          	auipc	ra,0x5
     6ea:	462080e7          	jalr	1122(ra) # 5b48 <read>
    if (n > 0)
     6ee:	08a04b63          	bgtz	a0,784 <copyout+0xec>
    close(fd);
     6f2:	8526                	mv	a0,s1
     6f4:	00005097          	auipc	ra,0x5
     6f8:	464080e7          	jalr	1124(ra) # 5b58 <close>
    if (pipe(fds) < 0)
     6fc:	fa840513          	addi	a0,s0,-88
     700:	00005097          	auipc	ra,0x5
     704:	440080e7          	jalr	1088(ra) # 5b40 <pipe>
     708:	08054d63          	bltz	a0,7a2 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     70c:	4605                	li	a2,1
     70e:	85d6                	mv	a1,s5
     710:	fac42503          	lw	a0,-84(s0)
     714:	00005097          	auipc	ra,0x5
     718:	43c080e7          	jalr	1084(ra) # 5b50 <write>
    if (n != 1)
     71c:	4785                	li	a5,1
     71e:	08f51f63          	bne	a0,a5,7bc <copyout+0x124>
    n = read(fds[0], (void *)addr, 8192);
     722:	6609                	lui	a2,0x2
     724:	85ce                	mv	a1,s3
     726:	fa842503          	lw	a0,-88(s0)
     72a:	00005097          	auipc	ra,0x5
     72e:	41e080e7          	jalr	1054(ra) # 5b48 <read>
    if (n > 0)
     732:	0aa04263          	bgtz	a0,7d6 <copyout+0x13e>
    close(fds[0]);
     736:	fa842503          	lw	a0,-88(s0)
     73a:	00005097          	auipc	ra,0x5
     73e:	41e080e7          	jalr	1054(ra) # 5b58 <close>
    close(fds[1]);
     742:	fac42503          	lw	a0,-84(s0)
     746:	00005097          	auipc	ra,0x5
     74a:	412080e7          	jalr	1042(ra) # 5b58 <close>
  for (int ai = 0; ai < 2; ai++)
     74e:	0921                	addi	s2,s2,8
     750:	fc040793          	addi	a5,s0,-64
     754:	f6f91ce3          	bne	s2,a5,6cc <copyout+0x34>
}
     758:	60e6                	ld	ra,88(sp)
     75a:	6446                	ld	s0,80(sp)
     75c:	64a6                	ld	s1,72(sp)
     75e:	6906                	ld	s2,64(sp)
     760:	79e2                	ld	s3,56(sp)
     762:	7a42                	ld	s4,48(sp)
     764:	7aa2                	ld	s5,40(sp)
     766:	6125                	addi	sp,sp,96
     768:	8082                	ret
      printf("open(README) failed\n");
     76a:	00006517          	auipc	a0,0x6
     76e:	b3e50513          	addi	a0,a0,-1218 # 62a8 <malloc+0x322>
     772:	00005097          	auipc	ra,0x5
     776:	756080e7          	jalr	1878(ra) # 5ec8 <printf>
      exit(1);
     77a:	4505                	li	a0,1
     77c:	00005097          	auipc	ra,0x5
     780:	3b4080e7          	jalr	948(ra) # 5b30 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     784:	862a                	mv	a2,a0
     786:	85ce                	mv	a1,s3
     788:	00006517          	auipc	a0,0x6
     78c:	b3850513          	addi	a0,a0,-1224 # 62c0 <malloc+0x33a>
     790:	00005097          	auipc	ra,0x5
     794:	738080e7          	jalr	1848(ra) # 5ec8 <printf>
      exit(1);
     798:	4505                	li	a0,1
     79a:	00005097          	auipc	ra,0x5
     79e:	396080e7          	jalr	918(ra) # 5b30 <exit>
      printf("pipe() failed\n");
     7a2:	00006517          	auipc	a0,0x6
     7a6:	abe50513          	addi	a0,a0,-1346 # 6260 <malloc+0x2da>
     7aa:	00005097          	auipc	ra,0x5
     7ae:	71e080e7          	jalr	1822(ra) # 5ec8 <printf>
      exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00005097          	auipc	ra,0x5
     7b8:	37c080e7          	jalr	892(ra) # 5b30 <exit>
      printf("pipe write failed\n");
     7bc:	00006517          	auipc	a0,0x6
     7c0:	b3450513          	addi	a0,a0,-1228 # 62f0 <malloc+0x36a>
     7c4:	00005097          	auipc	ra,0x5
     7c8:	704080e7          	jalr	1796(ra) # 5ec8 <printf>
      exit(1);
     7cc:	4505                	li	a0,1
     7ce:	00005097          	auipc	ra,0x5
     7d2:	362080e7          	jalr	866(ra) # 5b30 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7d6:	862a                	mv	a2,a0
     7d8:	85ce                	mv	a1,s3
     7da:	00006517          	auipc	a0,0x6
     7de:	b2e50513          	addi	a0,a0,-1234 # 6308 <malloc+0x382>
     7e2:	00005097          	auipc	ra,0x5
     7e6:	6e6080e7          	jalr	1766(ra) # 5ec8 <printf>
      exit(1);
     7ea:	4505                	li	a0,1
     7ec:	00005097          	auipc	ra,0x5
     7f0:	344080e7          	jalr	836(ra) # 5b30 <exit>

00000000000007f4 <truncate1>:
{
     7f4:	711d                	addi	sp,sp,-96
     7f6:	ec86                	sd	ra,88(sp)
     7f8:	e8a2                	sd	s0,80(sp)
     7fa:	e4a6                	sd	s1,72(sp)
     7fc:	e0ca                	sd	s2,64(sp)
     7fe:	fc4e                	sd	s3,56(sp)
     800:	f852                	sd	s4,48(sp)
     802:	f456                	sd	s5,40(sp)
     804:	1080                	addi	s0,sp,96
     806:	8aaa                	mv	s5,a0
  unlink("truncfile");
     808:	00006517          	auipc	a0,0x6
     80c:	91850513          	addi	a0,a0,-1768 # 6120 <malloc+0x19a>
     810:	00005097          	auipc	ra,0x5
     814:	370080e7          	jalr	880(ra) # 5b80 <unlink>
  int fd1 = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
     818:	60100593          	li	a1,1537
     81c:	00006517          	auipc	a0,0x6
     820:	90450513          	addi	a0,a0,-1788 # 6120 <malloc+0x19a>
     824:	00005097          	auipc	ra,0x5
     828:	34c080e7          	jalr	844(ra) # 5b70 <open>
     82c:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     82e:	4611                	li	a2,4
     830:	00006597          	auipc	a1,0x6
     834:	90058593          	addi	a1,a1,-1792 # 6130 <malloc+0x1aa>
     838:	00005097          	auipc	ra,0x5
     83c:	318080e7          	jalr	792(ra) # 5b50 <write>
  close(fd1);
     840:	8526                	mv	a0,s1
     842:	00005097          	auipc	ra,0x5
     846:	316080e7          	jalr	790(ra) # 5b58 <close>
  int fd2 = open("truncfile", O_RDONLY);
     84a:	4581                	li	a1,0
     84c:	00006517          	auipc	a0,0x6
     850:	8d450513          	addi	a0,a0,-1836 # 6120 <malloc+0x19a>
     854:	00005097          	auipc	ra,0x5
     858:	31c080e7          	jalr	796(ra) # 5b70 <open>
     85c:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     85e:	02000613          	li	a2,32
     862:	fa040593          	addi	a1,s0,-96
     866:	00005097          	auipc	ra,0x5
     86a:	2e2080e7          	jalr	738(ra) # 5b48 <read>
  if (n != 4)
     86e:	4791                	li	a5,4
     870:	0cf51e63          	bne	a0,a5,94c <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY | O_TRUNC);
     874:	40100593          	li	a1,1025
     878:	00006517          	auipc	a0,0x6
     87c:	8a850513          	addi	a0,a0,-1880 # 6120 <malloc+0x19a>
     880:	00005097          	auipc	ra,0x5
     884:	2f0080e7          	jalr	752(ra) # 5b70 <open>
     888:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     88a:	4581                	li	a1,0
     88c:	00006517          	auipc	a0,0x6
     890:	89450513          	addi	a0,a0,-1900 # 6120 <malloc+0x19a>
     894:	00005097          	auipc	ra,0x5
     898:	2dc080e7          	jalr	732(ra) # 5b70 <open>
     89c:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     89e:	02000613          	li	a2,32
     8a2:	fa040593          	addi	a1,s0,-96
     8a6:	00005097          	auipc	ra,0x5
     8aa:	2a2080e7          	jalr	674(ra) # 5b48 <read>
     8ae:	8a2a                	mv	s4,a0
  if (n != 0)
     8b0:	ed4d                	bnez	a0,96a <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8b2:	02000613          	li	a2,32
     8b6:	fa040593          	addi	a1,s0,-96
     8ba:	8526                	mv	a0,s1
     8bc:	00005097          	auipc	ra,0x5
     8c0:	28c080e7          	jalr	652(ra) # 5b48 <read>
     8c4:	8a2a                	mv	s4,a0
  if (n != 0)
     8c6:	e971                	bnez	a0,99a <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8c8:	4619                	li	a2,6
     8ca:	00006597          	auipc	a1,0x6
     8ce:	ace58593          	addi	a1,a1,-1330 # 6398 <malloc+0x412>
     8d2:	854e                	mv	a0,s3
     8d4:	00005097          	auipc	ra,0x5
     8d8:	27c080e7          	jalr	636(ra) # 5b50 <write>
  n = read(fd3, buf, sizeof(buf));
     8dc:	02000613          	li	a2,32
     8e0:	fa040593          	addi	a1,s0,-96
     8e4:	854a                	mv	a0,s2
     8e6:	00005097          	auipc	ra,0x5
     8ea:	262080e7          	jalr	610(ra) # 5b48 <read>
  if (n != 6)
     8ee:	4799                	li	a5,6
     8f0:	0cf51d63          	bne	a0,a5,9ca <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     8f4:	02000613          	li	a2,32
     8f8:	fa040593          	addi	a1,s0,-96
     8fc:	8526                	mv	a0,s1
     8fe:	00005097          	auipc	ra,0x5
     902:	24a080e7          	jalr	586(ra) # 5b48 <read>
  if (n != 2)
     906:	4789                	li	a5,2
     908:	0ef51063          	bne	a0,a5,9e8 <truncate1+0x1f4>
  unlink("truncfile");
     90c:	00006517          	auipc	a0,0x6
     910:	81450513          	addi	a0,a0,-2028 # 6120 <malloc+0x19a>
     914:	00005097          	auipc	ra,0x5
     918:	26c080e7          	jalr	620(ra) # 5b80 <unlink>
  close(fd1);
     91c:	854e                	mv	a0,s3
     91e:	00005097          	auipc	ra,0x5
     922:	23a080e7          	jalr	570(ra) # 5b58 <close>
  close(fd2);
     926:	8526                	mv	a0,s1
     928:	00005097          	auipc	ra,0x5
     92c:	230080e7          	jalr	560(ra) # 5b58 <close>
  close(fd3);
     930:	854a                	mv	a0,s2
     932:	00005097          	auipc	ra,0x5
     936:	226080e7          	jalr	550(ra) # 5b58 <close>
}
     93a:	60e6                	ld	ra,88(sp)
     93c:	6446                	ld	s0,80(sp)
     93e:	64a6                	ld	s1,72(sp)
     940:	6906                	ld	s2,64(sp)
     942:	79e2                	ld	s3,56(sp)
     944:	7a42                	ld	s4,48(sp)
     946:	7aa2                	ld	s5,40(sp)
     948:	6125                	addi	sp,sp,96
     94a:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     94c:	862a                	mv	a2,a0
     94e:	85d6                	mv	a1,s5
     950:	00006517          	auipc	a0,0x6
     954:	9e850513          	addi	a0,a0,-1560 # 6338 <malloc+0x3b2>
     958:	00005097          	auipc	ra,0x5
     95c:	570080e7          	jalr	1392(ra) # 5ec8 <printf>
    exit(1);
     960:	4505                	li	a0,1
     962:	00005097          	auipc	ra,0x5
     966:	1ce080e7          	jalr	462(ra) # 5b30 <exit>
    printf("aaa fd3=%d\n", fd3);
     96a:	85ca                	mv	a1,s2
     96c:	00006517          	auipc	a0,0x6
     970:	9ec50513          	addi	a0,a0,-1556 # 6358 <malloc+0x3d2>
     974:	00005097          	auipc	ra,0x5
     978:	554080e7          	jalr	1364(ra) # 5ec8 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     97c:	8652                	mv	a2,s4
     97e:	85d6                	mv	a1,s5
     980:	00006517          	auipc	a0,0x6
     984:	9e850513          	addi	a0,a0,-1560 # 6368 <malloc+0x3e2>
     988:	00005097          	auipc	ra,0x5
     98c:	540080e7          	jalr	1344(ra) # 5ec8 <printf>
    exit(1);
     990:	4505                	li	a0,1
     992:	00005097          	auipc	ra,0x5
     996:	19e080e7          	jalr	414(ra) # 5b30 <exit>
    printf("bbb fd2=%d\n", fd2);
     99a:	85a6                	mv	a1,s1
     99c:	00006517          	auipc	a0,0x6
     9a0:	9ec50513          	addi	a0,a0,-1556 # 6388 <malloc+0x402>
     9a4:	00005097          	auipc	ra,0x5
     9a8:	524080e7          	jalr	1316(ra) # 5ec8 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9ac:	8652                	mv	a2,s4
     9ae:	85d6                	mv	a1,s5
     9b0:	00006517          	auipc	a0,0x6
     9b4:	9b850513          	addi	a0,a0,-1608 # 6368 <malloc+0x3e2>
     9b8:	00005097          	auipc	ra,0x5
     9bc:	510080e7          	jalr	1296(ra) # 5ec8 <printf>
    exit(1);
     9c0:	4505                	li	a0,1
     9c2:	00005097          	auipc	ra,0x5
     9c6:	16e080e7          	jalr	366(ra) # 5b30 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9ca:	862a                	mv	a2,a0
     9cc:	85d6                	mv	a1,s5
     9ce:	00006517          	auipc	a0,0x6
     9d2:	9d250513          	addi	a0,a0,-1582 # 63a0 <malloc+0x41a>
     9d6:	00005097          	auipc	ra,0x5
     9da:	4f2080e7          	jalr	1266(ra) # 5ec8 <printf>
    exit(1);
     9de:	4505                	li	a0,1
     9e0:	00005097          	auipc	ra,0x5
     9e4:	150080e7          	jalr	336(ra) # 5b30 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     9e8:	862a                	mv	a2,a0
     9ea:	85d6                	mv	a1,s5
     9ec:	00006517          	auipc	a0,0x6
     9f0:	9d450513          	addi	a0,a0,-1580 # 63c0 <malloc+0x43a>
     9f4:	00005097          	auipc	ra,0x5
     9f8:	4d4080e7          	jalr	1236(ra) # 5ec8 <printf>
    exit(1);
     9fc:	4505                	li	a0,1
     9fe:	00005097          	auipc	ra,0x5
     a02:	132080e7          	jalr	306(ra) # 5b30 <exit>

0000000000000a06 <writetest>:
{
     a06:	7139                	addi	sp,sp,-64
     a08:	fc06                	sd	ra,56(sp)
     a0a:	f822                	sd	s0,48(sp)
     a0c:	f426                	sd	s1,40(sp)
     a0e:	f04a                	sd	s2,32(sp)
     a10:	ec4e                	sd	s3,24(sp)
     a12:	e852                	sd	s4,16(sp)
     a14:	e456                	sd	s5,8(sp)
     a16:	e05a                	sd	s6,0(sp)
     a18:	0080                	addi	s0,sp,64
     a1a:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE | O_RDWR);
     a1c:	20200593          	li	a1,514
     a20:	00006517          	auipc	a0,0x6
     a24:	9c050513          	addi	a0,a0,-1600 # 63e0 <malloc+0x45a>
     a28:	00005097          	auipc	ra,0x5
     a2c:	148080e7          	jalr	328(ra) # 5b70 <open>
  if (fd < 0)
     a30:	0a054d63          	bltz	a0,aea <writetest+0xe4>
     a34:	892a                	mv	s2,a0
     a36:	4481                	li	s1,0
    if (write(fd, "aaaaaaaaaa", SZ) != SZ)
     a38:	00006997          	auipc	s3,0x6
     a3c:	9d098993          	addi	s3,s3,-1584 # 6408 <malloc+0x482>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ)
     a40:	00006a97          	auipc	s5,0x6
     a44:	a00a8a93          	addi	s5,s5,-1536 # 6440 <malloc+0x4ba>
  for (i = 0; i < N; i++)
     a48:	06400a13          	li	s4,100
    if (write(fd, "aaaaaaaaaa", SZ) != SZ)
     a4c:	4629                	li	a2,10
     a4e:	85ce                	mv	a1,s3
     a50:	854a                	mv	a0,s2
     a52:	00005097          	auipc	ra,0x5
     a56:	0fe080e7          	jalr	254(ra) # 5b50 <write>
     a5a:	47a9                	li	a5,10
     a5c:	0af51563          	bne	a0,a5,b06 <writetest+0x100>
    if (write(fd, "bbbbbbbbbb", SZ) != SZ)
     a60:	4629                	li	a2,10
     a62:	85d6                	mv	a1,s5
     a64:	854a                	mv	a0,s2
     a66:	00005097          	auipc	ra,0x5
     a6a:	0ea080e7          	jalr	234(ra) # 5b50 <write>
     a6e:	47a9                	li	a5,10
     a70:	0af51a63          	bne	a0,a5,b24 <writetest+0x11e>
  for (i = 0; i < N; i++)
     a74:	2485                	addiw	s1,s1,1
     a76:	fd449be3          	bne	s1,s4,a4c <writetest+0x46>
  close(fd);
     a7a:	854a                	mv	a0,s2
     a7c:	00005097          	auipc	ra,0x5
     a80:	0dc080e7          	jalr	220(ra) # 5b58 <close>
  fd = open("small", O_RDONLY);
     a84:	4581                	li	a1,0
     a86:	00006517          	auipc	a0,0x6
     a8a:	95a50513          	addi	a0,a0,-1702 # 63e0 <malloc+0x45a>
     a8e:	00005097          	auipc	ra,0x5
     a92:	0e2080e7          	jalr	226(ra) # 5b70 <open>
     a96:	84aa                	mv	s1,a0
  if (fd < 0)
     a98:	0a054563          	bltz	a0,b42 <writetest+0x13c>
  i = read(fd, buf, N * SZ * 2);
     a9c:	7d000613          	li	a2,2000
     aa0:	0000c597          	auipc	a1,0xc
     aa4:	1d858593          	addi	a1,a1,472 # cc78 <buf>
     aa8:	00005097          	auipc	ra,0x5
     aac:	0a0080e7          	jalr	160(ra) # 5b48 <read>
  if (i != N * SZ * 2)
     ab0:	7d000793          	li	a5,2000
     ab4:	0af51563          	bne	a0,a5,b5e <writetest+0x158>
  close(fd);
     ab8:	8526                	mv	a0,s1
     aba:	00005097          	auipc	ra,0x5
     abe:	09e080e7          	jalr	158(ra) # 5b58 <close>
  if (unlink("small") < 0)
     ac2:	00006517          	auipc	a0,0x6
     ac6:	91e50513          	addi	a0,a0,-1762 # 63e0 <malloc+0x45a>
     aca:	00005097          	auipc	ra,0x5
     ace:	0b6080e7          	jalr	182(ra) # 5b80 <unlink>
     ad2:	0a054463          	bltz	a0,b7a <writetest+0x174>
}
     ad6:	70e2                	ld	ra,56(sp)
     ad8:	7442                	ld	s0,48(sp)
     ada:	74a2                	ld	s1,40(sp)
     adc:	7902                	ld	s2,32(sp)
     ade:	69e2                	ld	s3,24(sp)
     ae0:	6a42                	ld	s4,16(sp)
     ae2:	6aa2                	ld	s5,8(sp)
     ae4:	6b02                	ld	s6,0(sp)
     ae6:	6121                	addi	sp,sp,64
     ae8:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     aea:	85da                	mv	a1,s6
     aec:	00006517          	auipc	a0,0x6
     af0:	8fc50513          	addi	a0,a0,-1796 # 63e8 <malloc+0x462>
     af4:	00005097          	auipc	ra,0x5
     af8:	3d4080e7          	jalr	980(ra) # 5ec8 <printf>
    exit(1);
     afc:	4505                	li	a0,1
     afe:	00005097          	auipc	ra,0x5
     b02:	032080e7          	jalr	50(ra) # 5b30 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     b06:	8626                	mv	a2,s1
     b08:	85da                	mv	a1,s6
     b0a:	00006517          	auipc	a0,0x6
     b0e:	90e50513          	addi	a0,a0,-1778 # 6418 <malloc+0x492>
     b12:	00005097          	auipc	ra,0x5
     b16:	3b6080e7          	jalr	950(ra) # 5ec8 <printf>
      exit(1);
     b1a:	4505                	li	a0,1
     b1c:	00005097          	auipc	ra,0x5
     b20:	014080e7          	jalr	20(ra) # 5b30 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b24:	8626                	mv	a2,s1
     b26:	85da                	mv	a1,s6
     b28:	00006517          	auipc	a0,0x6
     b2c:	92850513          	addi	a0,a0,-1752 # 6450 <malloc+0x4ca>
     b30:	00005097          	auipc	ra,0x5
     b34:	398080e7          	jalr	920(ra) # 5ec8 <printf>
      exit(1);
     b38:	4505                	li	a0,1
     b3a:	00005097          	auipc	ra,0x5
     b3e:	ff6080e7          	jalr	-10(ra) # 5b30 <exit>
    printf("%s: error: open small failed!\n", s);
     b42:	85da                	mv	a1,s6
     b44:	00006517          	auipc	a0,0x6
     b48:	93450513          	addi	a0,a0,-1740 # 6478 <malloc+0x4f2>
     b4c:	00005097          	auipc	ra,0x5
     b50:	37c080e7          	jalr	892(ra) # 5ec8 <printf>
    exit(1);
     b54:	4505                	li	a0,1
     b56:	00005097          	auipc	ra,0x5
     b5a:	fda080e7          	jalr	-38(ra) # 5b30 <exit>
    printf("%s: read failed\n", s);
     b5e:	85da                	mv	a1,s6
     b60:	00006517          	auipc	a0,0x6
     b64:	93850513          	addi	a0,a0,-1736 # 6498 <malloc+0x512>
     b68:	00005097          	auipc	ra,0x5
     b6c:	360080e7          	jalr	864(ra) # 5ec8 <printf>
    exit(1);
     b70:	4505                	li	a0,1
     b72:	00005097          	auipc	ra,0x5
     b76:	fbe080e7          	jalr	-66(ra) # 5b30 <exit>
    printf("%s: unlink small failed\n", s);
     b7a:	85da                	mv	a1,s6
     b7c:	00006517          	auipc	a0,0x6
     b80:	93450513          	addi	a0,a0,-1740 # 64b0 <malloc+0x52a>
     b84:	00005097          	auipc	ra,0x5
     b88:	344080e7          	jalr	836(ra) # 5ec8 <printf>
    exit(1);
     b8c:	4505                	li	a0,1
     b8e:	00005097          	auipc	ra,0x5
     b92:	fa2080e7          	jalr	-94(ra) # 5b30 <exit>

0000000000000b96 <writebig>:
{
     b96:	7139                	addi	sp,sp,-64
     b98:	fc06                	sd	ra,56(sp)
     b9a:	f822                	sd	s0,48(sp)
     b9c:	f426                	sd	s1,40(sp)
     b9e:	f04a                	sd	s2,32(sp)
     ba0:	ec4e                	sd	s3,24(sp)
     ba2:	e852                	sd	s4,16(sp)
     ba4:	e456                	sd	s5,8(sp)
     ba6:	0080                	addi	s0,sp,64
     ba8:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE | O_RDWR);
     baa:	20200593          	li	a1,514
     bae:	00006517          	auipc	a0,0x6
     bb2:	92250513          	addi	a0,a0,-1758 # 64d0 <malloc+0x54a>
     bb6:	00005097          	auipc	ra,0x5
     bba:	fba080e7          	jalr	-70(ra) # 5b70 <open>
     bbe:	89aa                	mv	s3,a0
  for (i = 0; i < MAXFILE; i++)
     bc0:	4481                	li	s1,0
    ((int *)buf)[0] = i;
     bc2:	0000c917          	auipc	s2,0xc
     bc6:	0b690913          	addi	s2,s2,182 # cc78 <buf>
  for (i = 0; i < MAXFILE; i++)
     bca:	10c00a13          	li	s4,268
  if (fd < 0)
     bce:	06054c63          	bltz	a0,c46 <writebig+0xb0>
    ((int *)buf)[0] = i;
     bd2:	00992023          	sw	s1,0(s2)
    if (write(fd, buf, BSIZE) != BSIZE)
     bd6:	40000613          	li	a2,1024
     bda:	85ca                	mv	a1,s2
     bdc:	854e                	mv	a0,s3
     bde:	00005097          	auipc	ra,0x5
     be2:	f72080e7          	jalr	-142(ra) # 5b50 <write>
     be6:	40000793          	li	a5,1024
     bea:	06f51c63          	bne	a0,a5,c62 <writebig+0xcc>
  for (i = 0; i < MAXFILE; i++)
     bee:	2485                	addiw	s1,s1,1
     bf0:	ff4491e3          	bne	s1,s4,bd2 <writebig+0x3c>
  close(fd);
     bf4:	854e                	mv	a0,s3
     bf6:	00005097          	auipc	ra,0x5
     bfa:	f62080e7          	jalr	-158(ra) # 5b58 <close>
  fd = open("big", O_RDONLY);
     bfe:	4581                	li	a1,0
     c00:	00006517          	auipc	a0,0x6
     c04:	8d050513          	addi	a0,a0,-1840 # 64d0 <malloc+0x54a>
     c08:	00005097          	auipc	ra,0x5
     c0c:	f68080e7          	jalr	-152(ra) # 5b70 <open>
     c10:	89aa                	mv	s3,a0
  n = 0;
     c12:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c14:	0000c917          	auipc	s2,0xc
     c18:	06490913          	addi	s2,s2,100 # cc78 <buf>
  if (fd < 0)
     c1c:	06054263          	bltz	a0,c80 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c20:	40000613          	li	a2,1024
     c24:	85ca                	mv	a1,s2
     c26:	854e                	mv	a0,s3
     c28:	00005097          	auipc	ra,0x5
     c2c:	f20080e7          	jalr	-224(ra) # 5b48 <read>
    if (i == 0)
     c30:	c535                	beqz	a0,c9c <writebig+0x106>
    else if (i != BSIZE)
     c32:	40000793          	li	a5,1024
     c36:	0af51f63          	bne	a0,a5,cf4 <writebig+0x15e>
    if (((int *)buf)[0] != n)
     c3a:	00092683          	lw	a3,0(s2)
     c3e:	0c969a63          	bne	a3,s1,d12 <writebig+0x17c>
    n++;
     c42:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c44:	bff1                	j	c20 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c46:	85d6                	mv	a1,s5
     c48:	00006517          	auipc	a0,0x6
     c4c:	89050513          	addi	a0,a0,-1904 # 64d8 <malloc+0x552>
     c50:	00005097          	auipc	ra,0x5
     c54:	278080e7          	jalr	632(ra) # 5ec8 <printf>
    exit(1);
     c58:	4505                	li	a0,1
     c5a:	00005097          	auipc	ra,0x5
     c5e:	ed6080e7          	jalr	-298(ra) # 5b30 <exit>
      printf("%s: error: write big file failed\n", s, i);
     c62:	8626                	mv	a2,s1
     c64:	85d6                	mv	a1,s5
     c66:	00006517          	auipc	a0,0x6
     c6a:	89250513          	addi	a0,a0,-1902 # 64f8 <malloc+0x572>
     c6e:	00005097          	auipc	ra,0x5
     c72:	25a080e7          	jalr	602(ra) # 5ec8 <printf>
      exit(1);
     c76:	4505                	li	a0,1
     c78:	00005097          	auipc	ra,0x5
     c7c:	eb8080e7          	jalr	-328(ra) # 5b30 <exit>
    printf("%s: error: open big failed!\n", s);
     c80:	85d6                	mv	a1,s5
     c82:	00006517          	auipc	a0,0x6
     c86:	89e50513          	addi	a0,a0,-1890 # 6520 <malloc+0x59a>
     c8a:	00005097          	auipc	ra,0x5
     c8e:	23e080e7          	jalr	574(ra) # 5ec8 <printf>
    exit(1);
     c92:	4505                	li	a0,1
     c94:	00005097          	auipc	ra,0x5
     c98:	e9c080e7          	jalr	-356(ra) # 5b30 <exit>
      if (n == MAXFILE - 1)
     c9c:	10b00793          	li	a5,267
     ca0:	02f48a63          	beq	s1,a5,cd4 <writebig+0x13e>
  close(fd);
     ca4:	854e                	mv	a0,s3
     ca6:	00005097          	auipc	ra,0x5
     caa:	eb2080e7          	jalr	-334(ra) # 5b58 <close>
  if (unlink("big") < 0)
     cae:	00006517          	auipc	a0,0x6
     cb2:	82250513          	addi	a0,a0,-2014 # 64d0 <malloc+0x54a>
     cb6:	00005097          	auipc	ra,0x5
     cba:	eca080e7          	jalr	-310(ra) # 5b80 <unlink>
     cbe:	06054963          	bltz	a0,d30 <writebig+0x19a>
}
     cc2:	70e2                	ld	ra,56(sp)
     cc4:	7442                	ld	s0,48(sp)
     cc6:	74a2                	ld	s1,40(sp)
     cc8:	7902                	ld	s2,32(sp)
     cca:	69e2                	ld	s3,24(sp)
     ccc:	6a42                	ld	s4,16(sp)
     cce:	6aa2                	ld	s5,8(sp)
     cd0:	6121                	addi	sp,sp,64
     cd2:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cd4:	10b00613          	li	a2,267
     cd8:	85d6                	mv	a1,s5
     cda:	00006517          	auipc	a0,0x6
     cde:	86650513          	addi	a0,a0,-1946 # 6540 <malloc+0x5ba>
     ce2:	00005097          	auipc	ra,0x5
     ce6:	1e6080e7          	jalr	486(ra) # 5ec8 <printf>
        exit(1);
     cea:	4505                	li	a0,1
     cec:	00005097          	auipc	ra,0x5
     cf0:	e44080e7          	jalr	-444(ra) # 5b30 <exit>
      printf("%s: read failed %d\n", s, i);
     cf4:	862a                	mv	a2,a0
     cf6:	85d6                	mv	a1,s5
     cf8:	00006517          	auipc	a0,0x6
     cfc:	87050513          	addi	a0,a0,-1936 # 6568 <malloc+0x5e2>
     d00:	00005097          	auipc	ra,0x5
     d04:	1c8080e7          	jalr	456(ra) # 5ec8 <printf>
      exit(1);
     d08:	4505                	li	a0,1
     d0a:	00005097          	auipc	ra,0x5
     d0e:	e26080e7          	jalr	-474(ra) # 5b30 <exit>
      printf("%s: read content of block %d is %d\n", s,
     d12:	8626                	mv	a2,s1
     d14:	85d6                	mv	a1,s5
     d16:	00006517          	auipc	a0,0x6
     d1a:	86a50513          	addi	a0,a0,-1942 # 6580 <malloc+0x5fa>
     d1e:	00005097          	auipc	ra,0x5
     d22:	1aa080e7          	jalr	426(ra) # 5ec8 <printf>
      exit(1);
     d26:	4505                	li	a0,1
     d28:	00005097          	auipc	ra,0x5
     d2c:	e08080e7          	jalr	-504(ra) # 5b30 <exit>
    printf("%s: unlink big failed\n", s);
     d30:	85d6                	mv	a1,s5
     d32:	00006517          	auipc	a0,0x6
     d36:	87650513          	addi	a0,a0,-1930 # 65a8 <malloc+0x622>
     d3a:	00005097          	auipc	ra,0x5
     d3e:	18e080e7          	jalr	398(ra) # 5ec8 <printf>
    exit(1);
     d42:	4505                	li	a0,1
     d44:	00005097          	auipc	ra,0x5
     d48:	dec080e7          	jalr	-532(ra) # 5b30 <exit>

0000000000000d4c <unlinkread>:
{
     d4c:	7179                	addi	sp,sp,-48
     d4e:	f406                	sd	ra,40(sp)
     d50:	f022                	sd	s0,32(sp)
     d52:	ec26                	sd	s1,24(sp)
     d54:	e84a                	sd	s2,16(sp)
     d56:	e44e                	sd	s3,8(sp)
     d58:	1800                	addi	s0,sp,48
     d5a:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d5c:	20200593          	li	a1,514
     d60:	00006517          	auipc	a0,0x6
     d64:	86050513          	addi	a0,a0,-1952 # 65c0 <malloc+0x63a>
     d68:	00005097          	auipc	ra,0x5
     d6c:	e08080e7          	jalr	-504(ra) # 5b70 <open>
  if (fd < 0)
     d70:	0e054563          	bltz	a0,e5a <unlinkread+0x10e>
     d74:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d76:	4615                	li	a2,5
     d78:	00006597          	auipc	a1,0x6
     d7c:	87858593          	addi	a1,a1,-1928 # 65f0 <malloc+0x66a>
     d80:	00005097          	auipc	ra,0x5
     d84:	dd0080e7          	jalr	-560(ra) # 5b50 <write>
  close(fd);
     d88:	8526                	mv	a0,s1
     d8a:	00005097          	auipc	ra,0x5
     d8e:	dce080e7          	jalr	-562(ra) # 5b58 <close>
  fd = open("unlinkread", O_RDWR);
     d92:	4589                	li	a1,2
     d94:	00006517          	auipc	a0,0x6
     d98:	82c50513          	addi	a0,a0,-2004 # 65c0 <malloc+0x63a>
     d9c:	00005097          	auipc	ra,0x5
     da0:	dd4080e7          	jalr	-556(ra) # 5b70 <open>
     da4:	84aa                	mv	s1,a0
  if (fd < 0)
     da6:	0c054863          	bltz	a0,e76 <unlinkread+0x12a>
  if (unlink("unlinkread") != 0)
     daa:	00006517          	auipc	a0,0x6
     dae:	81650513          	addi	a0,a0,-2026 # 65c0 <malloc+0x63a>
     db2:	00005097          	auipc	ra,0x5
     db6:	dce080e7          	jalr	-562(ra) # 5b80 <unlink>
     dba:	ed61                	bnez	a0,e92 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     dbc:	20200593          	li	a1,514
     dc0:	00006517          	auipc	a0,0x6
     dc4:	80050513          	addi	a0,a0,-2048 # 65c0 <malloc+0x63a>
     dc8:	00005097          	auipc	ra,0x5
     dcc:	da8080e7          	jalr	-600(ra) # 5b70 <open>
     dd0:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dd2:	460d                	li	a2,3
     dd4:	00006597          	auipc	a1,0x6
     dd8:	86458593          	addi	a1,a1,-1948 # 6638 <malloc+0x6b2>
     ddc:	00005097          	auipc	ra,0x5
     de0:	d74080e7          	jalr	-652(ra) # 5b50 <write>
  close(fd1);
     de4:	854a                	mv	a0,s2
     de6:	00005097          	auipc	ra,0x5
     dea:	d72080e7          	jalr	-654(ra) # 5b58 <close>
  if (read(fd, buf, sizeof(buf)) != SZ)
     dee:	660d                	lui	a2,0x3
     df0:	0000c597          	auipc	a1,0xc
     df4:	e8858593          	addi	a1,a1,-376 # cc78 <buf>
     df8:	8526                	mv	a0,s1
     dfa:	00005097          	auipc	ra,0x5
     dfe:	d4e080e7          	jalr	-690(ra) # 5b48 <read>
     e02:	4795                	li	a5,5
     e04:	0af51563          	bne	a0,a5,eae <unlinkread+0x162>
  if (buf[0] != 'h')
     e08:	0000c717          	auipc	a4,0xc
     e0c:	e7074703          	lbu	a4,-400(a4) # cc78 <buf>
     e10:	06800793          	li	a5,104
     e14:	0af71b63          	bne	a4,a5,eca <unlinkread+0x17e>
  if (write(fd, buf, 10) != 10)
     e18:	4629                	li	a2,10
     e1a:	0000c597          	auipc	a1,0xc
     e1e:	e5e58593          	addi	a1,a1,-418 # cc78 <buf>
     e22:	8526                	mv	a0,s1
     e24:	00005097          	auipc	ra,0x5
     e28:	d2c080e7          	jalr	-724(ra) # 5b50 <write>
     e2c:	47a9                	li	a5,10
     e2e:	0af51c63          	bne	a0,a5,ee6 <unlinkread+0x19a>
  close(fd);
     e32:	8526                	mv	a0,s1
     e34:	00005097          	auipc	ra,0x5
     e38:	d24080e7          	jalr	-732(ra) # 5b58 <close>
  unlink("unlinkread");
     e3c:	00005517          	auipc	a0,0x5
     e40:	78450513          	addi	a0,a0,1924 # 65c0 <malloc+0x63a>
     e44:	00005097          	auipc	ra,0x5
     e48:	d3c080e7          	jalr	-708(ra) # 5b80 <unlink>
}
     e4c:	70a2                	ld	ra,40(sp)
     e4e:	7402                	ld	s0,32(sp)
     e50:	64e2                	ld	s1,24(sp)
     e52:	6942                	ld	s2,16(sp)
     e54:	69a2                	ld	s3,8(sp)
     e56:	6145                	addi	sp,sp,48
     e58:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e5a:	85ce                	mv	a1,s3
     e5c:	00005517          	auipc	a0,0x5
     e60:	77450513          	addi	a0,a0,1908 # 65d0 <malloc+0x64a>
     e64:	00005097          	auipc	ra,0x5
     e68:	064080e7          	jalr	100(ra) # 5ec8 <printf>
    exit(1);
     e6c:	4505                	li	a0,1
     e6e:	00005097          	auipc	ra,0x5
     e72:	cc2080e7          	jalr	-830(ra) # 5b30 <exit>
    printf("%s: open unlinkread failed\n", s);
     e76:	85ce                	mv	a1,s3
     e78:	00005517          	auipc	a0,0x5
     e7c:	78050513          	addi	a0,a0,1920 # 65f8 <malloc+0x672>
     e80:	00005097          	auipc	ra,0x5
     e84:	048080e7          	jalr	72(ra) # 5ec8 <printf>
    exit(1);
     e88:	4505                	li	a0,1
     e8a:	00005097          	auipc	ra,0x5
     e8e:	ca6080e7          	jalr	-858(ra) # 5b30 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     e92:	85ce                	mv	a1,s3
     e94:	00005517          	auipc	a0,0x5
     e98:	78450513          	addi	a0,a0,1924 # 6618 <malloc+0x692>
     e9c:	00005097          	auipc	ra,0x5
     ea0:	02c080e7          	jalr	44(ra) # 5ec8 <printf>
    exit(1);
     ea4:	4505                	li	a0,1
     ea6:	00005097          	auipc	ra,0x5
     eaa:	c8a080e7          	jalr	-886(ra) # 5b30 <exit>
    printf("%s: unlinkread read failed", s);
     eae:	85ce                	mv	a1,s3
     eb0:	00005517          	auipc	a0,0x5
     eb4:	79050513          	addi	a0,a0,1936 # 6640 <malloc+0x6ba>
     eb8:	00005097          	auipc	ra,0x5
     ebc:	010080e7          	jalr	16(ra) # 5ec8 <printf>
    exit(1);
     ec0:	4505                	li	a0,1
     ec2:	00005097          	auipc	ra,0x5
     ec6:	c6e080e7          	jalr	-914(ra) # 5b30 <exit>
    printf("%s: unlinkread wrong data\n", s);
     eca:	85ce                	mv	a1,s3
     ecc:	00005517          	auipc	a0,0x5
     ed0:	79450513          	addi	a0,a0,1940 # 6660 <malloc+0x6da>
     ed4:	00005097          	auipc	ra,0x5
     ed8:	ff4080e7          	jalr	-12(ra) # 5ec8 <printf>
    exit(1);
     edc:	4505                	li	a0,1
     ede:	00005097          	auipc	ra,0x5
     ee2:	c52080e7          	jalr	-942(ra) # 5b30 <exit>
    printf("%s: unlinkread write failed\n", s);
     ee6:	85ce                	mv	a1,s3
     ee8:	00005517          	auipc	a0,0x5
     eec:	79850513          	addi	a0,a0,1944 # 6680 <malloc+0x6fa>
     ef0:	00005097          	auipc	ra,0x5
     ef4:	fd8080e7          	jalr	-40(ra) # 5ec8 <printf>
    exit(1);
     ef8:	4505                	li	a0,1
     efa:	00005097          	auipc	ra,0x5
     efe:	c36080e7          	jalr	-970(ra) # 5b30 <exit>

0000000000000f02 <linktest>:
{
     f02:	1101                	addi	sp,sp,-32
     f04:	ec06                	sd	ra,24(sp)
     f06:	e822                	sd	s0,16(sp)
     f08:	e426                	sd	s1,8(sp)
     f0a:	e04a                	sd	s2,0(sp)
     f0c:	1000                	addi	s0,sp,32
     f0e:	892a                	mv	s2,a0
  unlink("lf1");
     f10:	00005517          	auipc	a0,0x5
     f14:	79050513          	addi	a0,a0,1936 # 66a0 <malloc+0x71a>
     f18:	00005097          	auipc	ra,0x5
     f1c:	c68080e7          	jalr	-920(ra) # 5b80 <unlink>
  unlink("lf2");
     f20:	00005517          	auipc	a0,0x5
     f24:	78850513          	addi	a0,a0,1928 # 66a8 <malloc+0x722>
     f28:	00005097          	auipc	ra,0x5
     f2c:	c58080e7          	jalr	-936(ra) # 5b80 <unlink>
  fd = open("lf1", O_CREATE | O_RDWR);
     f30:	20200593          	li	a1,514
     f34:	00005517          	auipc	a0,0x5
     f38:	76c50513          	addi	a0,a0,1900 # 66a0 <malloc+0x71a>
     f3c:	00005097          	auipc	ra,0x5
     f40:	c34080e7          	jalr	-972(ra) # 5b70 <open>
  if (fd < 0)
     f44:	10054763          	bltz	a0,1052 <linktest+0x150>
     f48:	84aa                	mv	s1,a0
  if (write(fd, "hello", SZ) != SZ)
     f4a:	4615                	li	a2,5
     f4c:	00005597          	auipc	a1,0x5
     f50:	6a458593          	addi	a1,a1,1700 # 65f0 <malloc+0x66a>
     f54:	00005097          	auipc	ra,0x5
     f58:	bfc080e7          	jalr	-1028(ra) # 5b50 <write>
     f5c:	4795                	li	a5,5
     f5e:	10f51863          	bne	a0,a5,106e <linktest+0x16c>
  close(fd);
     f62:	8526                	mv	a0,s1
     f64:	00005097          	auipc	ra,0x5
     f68:	bf4080e7          	jalr	-1036(ra) # 5b58 <close>
  if (link("lf1", "lf2") < 0)
     f6c:	00005597          	auipc	a1,0x5
     f70:	73c58593          	addi	a1,a1,1852 # 66a8 <malloc+0x722>
     f74:	00005517          	auipc	a0,0x5
     f78:	72c50513          	addi	a0,a0,1836 # 66a0 <malloc+0x71a>
     f7c:	00005097          	auipc	ra,0x5
     f80:	c14080e7          	jalr	-1004(ra) # 5b90 <link>
     f84:	10054363          	bltz	a0,108a <linktest+0x188>
  unlink("lf1");
     f88:	00005517          	auipc	a0,0x5
     f8c:	71850513          	addi	a0,a0,1816 # 66a0 <malloc+0x71a>
     f90:	00005097          	auipc	ra,0x5
     f94:	bf0080e7          	jalr	-1040(ra) # 5b80 <unlink>
  if (open("lf1", 0) >= 0)
     f98:	4581                	li	a1,0
     f9a:	00005517          	auipc	a0,0x5
     f9e:	70650513          	addi	a0,a0,1798 # 66a0 <malloc+0x71a>
     fa2:	00005097          	auipc	ra,0x5
     fa6:	bce080e7          	jalr	-1074(ra) # 5b70 <open>
     faa:	0e055e63          	bgez	a0,10a6 <linktest+0x1a4>
  fd = open("lf2", 0);
     fae:	4581                	li	a1,0
     fb0:	00005517          	auipc	a0,0x5
     fb4:	6f850513          	addi	a0,a0,1784 # 66a8 <malloc+0x722>
     fb8:	00005097          	auipc	ra,0x5
     fbc:	bb8080e7          	jalr	-1096(ra) # 5b70 <open>
     fc0:	84aa                	mv	s1,a0
  if (fd < 0)
     fc2:	10054063          	bltz	a0,10c2 <linktest+0x1c0>
  if (read(fd, buf, sizeof(buf)) != SZ)
     fc6:	660d                	lui	a2,0x3
     fc8:	0000c597          	auipc	a1,0xc
     fcc:	cb058593          	addi	a1,a1,-848 # cc78 <buf>
     fd0:	00005097          	auipc	ra,0x5
     fd4:	b78080e7          	jalr	-1160(ra) # 5b48 <read>
     fd8:	4795                	li	a5,5
     fda:	10f51263          	bne	a0,a5,10de <linktest+0x1dc>
  close(fd);
     fde:	8526                	mv	a0,s1
     fe0:	00005097          	auipc	ra,0x5
     fe4:	b78080e7          	jalr	-1160(ra) # 5b58 <close>
  if (link("lf2", "lf2") >= 0)
     fe8:	00005597          	auipc	a1,0x5
     fec:	6c058593          	addi	a1,a1,1728 # 66a8 <malloc+0x722>
     ff0:	852e                	mv	a0,a1
     ff2:	00005097          	auipc	ra,0x5
     ff6:	b9e080e7          	jalr	-1122(ra) # 5b90 <link>
     ffa:	10055063          	bgez	a0,10fa <linktest+0x1f8>
  unlink("lf2");
     ffe:	00005517          	auipc	a0,0x5
    1002:	6aa50513          	addi	a0,a0,1706 # 66a8 <malloc+0x722>
    1006:	00005097          	auipc	ra,0x5
    100a:	b7a080e7          	jalr	-1158(ra) # 5b80 <unlink>
  if (link("lf2", "lf1") >= 0)
    100e:	00005597          	auipc	a1,0x5
    1012:	69258593          	addi	a1,a1,1682 # 66a0 <malloc+0x71a>
    1016:	00005517          	auipc	a0,0x5
    101a:	69250513          	addi	a0,a0,1682 # 66a8 <malloc+0x722>
    101e:	00005097          	auipc	ra,0x5
    1022:	b72080e7          	jalr	-1166(ra) # 5b90 <link>
    1026:	0e055863          	bgez	a0,1116 <linktest+0x214>
  if (link(".", "lf1") >= 0)
    102a:	00005597          	auipc	a1,0x5
    102e:	67658593          	addi	a1,a1,1654 # 66a0 <malloc+0x71a>
    1032:	00005517          	auipc	a0,0x5
    1036:	77e50513          	addi	a0,a0,1918 # 67b0 <malloc+0x82a>
    103a:	00005097          	auipc	ra,0x5
    103e:	b56080e7          	jalr	-1194(ra) # 5b90 <link>
    1042:	0e055863          	bgez	a0,1132 <linktest+0x230>
}
    1046:	60e2                	ld	ra,24(sp)
    1048:	6442                	ld	s0,16(sp)
    104a:	64a2                	ld	s1,8(sp)
    104c:	6902                	ld	s2,0(sp)
    104e:	6105                	addi	sp,sp,32
    1050:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1052:	85ca                	mv	a1,s2
    1054:	00005517          	auipc	a0,0x5
    1058:	65c50513          	addi	a0,a0,1628 # 66b0 <malloc+0x72a>
    105c:	00005097          	auipc	ra,0x5
    1060:	e6c080e7          	jalr	-404(ra) # 5ec8 <printf>
    exit(1);
    1064:	4505                	li	a0,1
    1066:	00005097          	auipc	ra,0x5
    106a:	aca080e7          	jalr	-1334(ra) # 5b30 <exit>
    printf("%s: write lf1 failed\n", s);
    106e:	85ca                	mv	a1,s2
    1070:	00005517          	auipc	a0,0x5
    1074:	65850513          	addi	a0,a0,1624 # 66c8 <malloc+0x742>
    1078:	00005097          	auipc	ra,0x5
    107c:	e50080e7          	jalr	-432(ra) # 5ec8 <printf>
    exit(1);
    1080:	4505                	li	a0,1
    1082:	00005097          	auipc	ra,0x5
    1086:	aae080e7          	jalr	-1362(ra) # 5b30 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    108a:	85ca                	mv	a1,s2
    108c:	00005517          	auipc	a0,0x5
    1090:	65450513          	addi	a0,a0,1620 # 66e0 <malloc+0x75a>
    1094:	00005097          	auipc	ra,0x5
    1098:	e34080e7          	jalr	-460(ra) # 5ec8 <printf>
    exit(1);
    109c:	4505                	li	a0,1
    109e:	00005097          	auipc	ra,0x5
    10a2:	a92080e7          	jalr	-1390(ra) # 5b30 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    10a6:	85ca                	mv	a1,s2
    10a8:	00005517          	auipc	a0,0x5
    10ac:	65850513          	addi	a0,a0,1624 # 6700 <malloc+0x77a>
    10b0:	00005097          	auipc	ra,0x5
    10b4:	e18080e7          	jalr	-488(ra) # 5ec8 <printf>
    exit(1);
    10b8:	4505                	li	a0,1
    10ba:	00005097          	auipc	ra,0x5
    10be:	a76080e7          	jalr	-1418(ra) # 5b30 <exit>
    printf("%s: open lf2 failed\n", s);
    10c2:	85ca                	mv	a1,s2
    10c4:	00005517          	auipc	a0,0x5
    10c8:	66c50513          	addi	a0,a0,1644 # 6730 <malloc+0x7aa>
    10cc:	00005097          	auipc	ra,0x5
    10d0:	dfc080e7          	jalr	-516(ra) # 5ec8 <printf>
    exit(1);
    10d4:	4505                	li	a0,1
    10d6:	00005097          	auipc	ra,0x5
    10da:	a5a080e7          	jalr	-1446(ra) # 5b30 <exit>
    printf("%s: read lf2 failed\n", s);
    10de:	85ca                	mv	a1,s2
    10e0:	00005517          	auipc	a0,0x5
    10e4:	66850513          	addi	a0,a0,1640 # 6748 <malloc+0x7c2>
    10e8:	00005097          	auipc	ra,0x5
    10ec:	de0080e7          	jalr	-544(ra) # 5ec8 <printf>
    exit(1);
    10f0:	4505                	li	a0,1
    10f2:	00005097          	auipc	ra,0x5
    10f6:	a3e080e7          	jalr	-1474(ra) # 5b30 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    10fa:	85ca                	mv	a1,s2
    10fc:	00005517          	auipc	a0,0x5
    1100:	66450513          	addi	a0,a0,1636 # 6760 <malloc+0x7da>
    1104:	00005097          	auipc	ra,0x5
    1108:	dc4080e7          	jalr	-572(ra) # 5ec8 <printf>
    exit(1);
    110c:	4505                	li	a0,1
    110e:	00005097          	auipc	ra,0x5
    1112:	a22080e7          	jalr	-1502(ra) # 5b30 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    1116:	85ca                	mv	a1,s2
    1118:	00005517          	auipc	a0,0x5
    111c:	67050513          	addi	a0,a0,1648 # 6788 <malloc+0x802>
    1120:	00005097          	auipc	ra,0x5
    1124:	da8080e7          	jalr	-600(ra) # 5ec8 <printf>
    exit(1);
    1128:	4505                	li	a0,1
    112a:	00005097          	auipc	ra,0x5
    112e:	a06080e7          	jalr	-1530(ra) # 5b30 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1132:	85ca                	mv	a1,s2
    1134:	00005517          	auipc	a0,0x5
    1138:	68450513          	addi	a0,a0,1668 # 67b8 <malloc+0x832>
    113c:	00005097          	auipc	ra,0x5
    1140:	d8c080e7          	jalr	-628(ra) # 5ec8 <printf>
    exit(1);
    1144:	4505                	li	a0,1
    1146:	00005097          	auipc	ra,0x5
    114a:	9ea080e7          	jalr	-1558(ra) # 5b30 <exit>

000000000000114e <validatetest>:
{
    114e:	7139                	addi	sp,sp,-64
    1150:	fc06                	sd	ra,56(sp)
    1152:	f822                	sd	s0,48(sp)
    1154:	f426                	sd	s1,40(sp)
    1156:	f04a                	sd	s2,32(sp)
    1158:	ec4e                	sd	s3,24(sp)
    115a:	e852                	sd	s4,16(sp)
    115c:	e456                	sd	s5,8(sp)
    115e:	e05a                	sd	s6,0(sp)
    1160:	0080                	addi	s0,sp,64
    1162:	8b2a                	mv	s6,a0
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    1164:	4481                	li	s1,0
    if (link("nosuchfile", (char *)p) != -1)
    1166:	00005997          	auipc	s3,0x5
    116a:	67298993          	addi	s3,s3,1650 # 67d8 <malloc+0x852>
    116e:	597d                	li	s2,-1
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    1170:	6a85                	lui	s5,0x1
    1172:	00114a37          	lui	s4,0x114
    if (link("nosuchfile", (char *)p) != -1)
    1176:	85a6                	mv	a1,s1
    1178:	854e                	mv	a0,s3
    117a:	00005097          	auipc	ra,0x5
    117e:	a16080e7          	jalr	-1514(ra) # 5b90 <link>
    1182:	01251f63          	bne	a0,s2,11a0 <validatetest+0x52>
  for (p = 0; p <= (uint)hi; p += PGSIZE)
    1186:	94d6                	add	s1,s1,s5
    1188:	ff4497e3          	bne	s1,s4,1176 <validatetest+0x28>
}
    118c:	70e2                	ld	ra,56(sp)
    118e:	7442                	ld	s0,48(sp)
    1190:	74a2                	ld	s1,40(sp)
    1192:	7902                	ld	s2,32(sp)
    1194:	69e2                	ld	s3,24(sp)
    1196:	6a42                	ld	s4,16(sp)
    1198:	6aa2                	ld	s5,8(sp)
    119a:	6b02                	ld	s6,0(sp)
    119c:	6121                	addi	sp,sp,64
    119e:	8082                	ret
      printf("%s: link should not succeed\n", s);
    11a0:	85da                	mv	a1,s6
    11a2:	00005517          	auipc	a0,0x5
    11a6:	64650513          	addi	a0,a0,1606 # 67e8 <malloc+0x862>
    11aa:	00005097          	auipc	ra,0x5
    11ae:	d1e080e7          	jalr	-738(ra) # 5ec8 <printf>
      exit(1);
    11b2:	4505                	li	a0,1
    11b4:	00005097          	auipc	ra,0x5
    11b8:	97c080e7          	jalr	-1668(ra) # 5b30 <exit>

00000000000011bc <bigdir>:
{
    11bc:	715d                	addi	sp,sp,-80
    11be:	e486                	sd	ra,72(sp)
    11c0:	e0a2                	sd	s0,64(sp)
    11c2:	fc26                	sd	s1,56(sp)
    11c4:	f84a                	sd	s2,48(sp)
    11c6:	f44e                	sd	s3,40(sp)
    11c8:	f052                	sd	s4,32(sp)
    11ca:	ec56                	sd	s5,24(sp)
    11cc:	e85a                	sd	s6,16(sp)
    11ce:	0880                	addi	s0,sp,80
    11d0:	89aa                	mv	s3,a0
  unlink("bd");
    11d2:	00005517          	auipc	a0,0x5
    11d6:	63650513          	addi	a0,a0,1590 # 6808 <malloc+0x882>
    11da:	00005097          	auipc	ra,0x5
    11de:	9a6080e7          	jalr	-1626(ra) # 5b80 <unlink>
  fd = open("bd", O_CREATE);
    11e2:	20000593          	li	a1,512
    11e6:	00005517          	auipc	a0,0x5
    11ea:	62250513          	addi	a0,a0,1570 # 6808 <malloc+0x882>
    11ee:	00005097          	auipc	ra,0x5
    11f2:	982080e7          	jalr	-1662(ra) # 5b70 <open>
  if (fd < 0)
    11f6:	0c054963          	bltz	a0,12c8 <bigdir+0x10c>
  close(fd);
    11fa:	00005097          	auipc	ra,0x5
    11fe:	95e080e7          	jalr	-1698(ra) # 5b58 <close>
  for (i = 0; i < N; i++)
    1202:	4901                	li	s2,0
    name[0] = 'x';
    1204:	07800a93          	li	s5,120
    if (link("bd", name) != 0)
    1208:	00005a17          	auipc	s4,0x5
    120c:	600a0a13          	addi	s4,s4,1536 # 6808 <malloc+0x882>
  for (i = 0; i < N; i++)
    1210:	1f400b13          	li	s6,500
    name[0] = 'x';
    1214:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    1218:	41f9579b          	sraiw	a5,s2,0x1f
    121c:	01a7d71b          	srliw	a4,a5,0x1a
    1220:	012707bb          	addw	a5,a4,s2
    1224:	4067d69b          	sraiw	a3,a5,0x6
    1228:	0306869b          	addiw	a3,a3,48
    122c:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1230:	03f7f793          	andi	a5,a5,63
    1234:	9f99                	subw	a5,a5,a4
    1236:	0307879b          	addiw	a5,a5,48
    123a:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    123e:	fa0409a3          	sb	zero,-77(s0)
    if (link("bd", name) != 0)
    1242:	fb040593          	addi	a1,s0,-80
    1246:	8552                	mv	a0,s4
    1248:	00005097          	auipc	ra,0x5
    124c:	948080e7          	jalr	-1720(ra) # 5b90 <link>
    1250:	84aa                	mv	s1,a0
    1252:	e949                	bnez	a0,12e4 <bigdir+0x128>
  for (i = 0; i < N; i++)
    1254:	2905                	addiw	s2,s2,1
    1256:	fb691fe3          	bne	s2,s6,1214 <bigdir+0x58>
  unlink("bd");
    125a:	00005517          	auipc	a0,0x5
    125e:	5ae50513          	addi	a0,a0,1454 # 6808 <malloc+0x882>
    1262:	00005097          	auipc	ra,0x5
    1266:	91e080e7          	jalr	-1762(ra) # 5b80 <unlink>
    name[0] = 'x';
    126a:	07800913          	li	s2,120
  for (i = 0; i < N; i++)
    126e:	1f400a13          	li	s4,500
    name[0] = 'x';
    1272:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1276:	41f4d79b          	sraiw	a5,s1,0x1f
    127a:	01a7d71b          	srliw	a4,a5,0x1a
    127e:	009707bb          	addw	a5,a4,s1
    1282:	4067d69b          	sraiw	a3,a5,0x6
    1286:	0306869b          	addiw	a3,a3,48
    128a:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    128e:	03f7f793          	andi	a5,a5,63
    1292:	9f99                	subw	a5,a5,a4
    1294:	0307879b          	addiw	a5,a5,48
    1298:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    129c:	fa0409a3          	sb	zero,-77(s0)
    if (unlink(name) != 0)
    12a0:	fb040513          	addi	a0,s0,-80
    12a4:	00005097          	auipc	ra,0x5
    12a8:	8dc080e7          	jalr	-1828(ra) # 5b80 <unlink>
    12ac:	ed21                	bnez	a0,1304 <bigdir+0x148>
  for (i = 0; i < N; i++)
    12ae:	2485                	addiw	s1,s1,1
    12b0:	fd4491e3          	bne	s1,s4,1272 <bigdir+0xb6>
}
    12b4:	60a6                	ld	ra,72(sp)
    12b6:	6406                	ld	s0,64(sp)
    12b8:	74e2                	ld	s1,56(sp)
    12ba:	7942                	ld	s2,48(sp)
    12bc:	79a2                	ld	s3,40(sp)
    12be:	7a02                	ld	s4,32(sp)
    12c0:	6ae2                	ld	s5,24(sp)
    12c2:	6b42                	ld	s6,16(sp)
    12c4:	6161                	addi	sp,sp,80
    12c6:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12c8:	85ce                	mv	a1,s3
    12ca:	00005517          	auipc	a0,0x5
    12ce:	54650513          	addi	a0,a0,1350 # 6810 <malloc+0x88a>
    12d2:	00005097          	auipc	ra,0x5
    12d6:	bf6080e7          	jalr	-1034(ra) # 5ec8 <printf>
    exit(1);
    12da:	4505                	li	a0,1
    12dc:	00005097          	auipc	ra,0x5
    12e0:	854080e7          	jalr	-1964(ra) # 5b30 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12e4:	fb040613          	addi	a2,s0,-80
    12e8:	85ce                	mv	a1,s3
    12ea:	00005517          	auipc	a0,0x5
    12ee:	54650513          	addi	a0,a0,1350 # 6830 <malloc+0x8aa>
    12f2:	00005097          	auipc	ra,0x5
    12f6:	bd6080e7          	jalr	-1066(ra) # 5ec8 <printf>
      exit(1);
    12fa:	4505                	li	a0,1
    12fc:	00005097          	auipc	ra,0x5
    1300:	834080e7          	jalr	-1996(ra) # 5b30 <exit>
      printf("%s: bigdir unlink failed", s);
    1304:	85ce                	mv	a1,s3
    1306:	00005517          	auipc	a0,0x5
    130a:	54a50513          	addi	a0,a0,1354 # 6850 <malloc+0x8ca>
    130e:	00005097          	auipc	ra,0x5
    1312:	bba080e7          	jalr	-1094(ra) # 5ec8 <printf>
      exit(1);
    1316:	4505                	li	a0,1
    1318:	00005097          	auipc	ra,0x5
    131c:	818080e7          	jalr	-2024(ra) # 5b30 <exit>

0000000000001320 <pgbug>:
{
    1320:	7179                	addi	sp,sp,-48
    1322:	f406                	sd	ra,40(sp)
    1324:	f022                	sd	s0,32(sp)
    1326:	ec26                	sd	s1,24(sp)
    1328:	1800                	addi	s0,sp,48
  argv[0] = 0;
    132a:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    132e:	00008497          	auipc	s1,0x8
    1332:	cd248493          	addi	s1,s1,-814 # 9000 <big>
    1336:	fd840593          	addi	a1,s0,-40
    133a:	6088                	ld	a0,0(s1)
    133c:	00005097          	auipc	ra,0x5
    1340:	82c080e7          	jalr	-2004(ra) # 5b68 <exec>
  pipe(big);
    1344:	6088                	ld	a0,0(s1)
    1346:	00004097          	auipc	ra,0x4
    134a:	7fa080e7          	jalr	2042(ra) # 5b40 <pipe>
  exit(0);
    134e:	4501                	li	a0,0
    1350:	00004097          	auipc	ra,0x4
    1354:	7e0080e7          	jalr	2016(ra) # 5b30 <exit>

0000000000001358 <badarg>:
{
    1358:	7139                	addi	sp,sp,-64
    135a:	fc06                	sd	ra,56(sp)
    135c:	f822                	sd	s0,48(sp)
    135e:	f426                	sd	s1,40(sp)
    1360:	f04a                	sd	s2,32(sp)
    1362:	ec4e                	sd	s3,24(sp)
    1364:	0080                	addi	s0,sp,64
    1366:	64b1                	lui	s1,0xc
    1368:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char *)0xffffffff;
    136c:	597d                	li	s2,-1
    136e:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    1372:	00005997          	auipc	s3,0x5
    1376:	d5698993          	addi	s3,s3,-682 # 60c8 <malloc+0x142>
    argv[0] = (char *)0xffffffff;
    137a:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    137e:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1382:	fc040593          	addi	a1,s0,-64
    1386:	854e                	mv	a0,s3
    1388:	00004097          	auipc	ra,0x4
    138c:	7e0080e7          	jalr	2016(ra) # 5b68 <exec>
  for (int i = 0; i < 50000; i++)
    1390:	34fd                	addiw	s1,s1,-1
    1392:	f4e5                	bnez	s1,137a <badarg+0x22>
  exit(0);
    1394:	4501                	li	a0,0
    1396:	00004097          	auipc	ra,0x4
    139a:	79a080e7          	jalr	1946(ra) # 5b30 <exit>

000000000000139e <copyinstr2>:
{
    139e:	7155                	addi	sp,sp,-208
    13a0:	e586                	sd	ra,200(sp)
    13a2:	e1a2                	sd	s0,192(sp)
    13a4:	0980                	addi	s0,sp,208
  for (int i = 0; i < MAXPATH; i++)
    13a6:	f6840793          	addi	a5,s0,-152
    13aa:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13ae:	07800713          	li	a4,120
    13b2:	00e78023          	sb	a4,0(a5)
  for (int i = 0; i < MAXPATH; i++)
    13b6:	0785                	addi	a5,a5,1
    13b8:	fed79de3          	bne	a5,a3,13b2 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13bc:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13c0:	f6840513          	addi	a0,s0,-152
    13c4:	00004097          	auipc	ra,0x4
    13c8:	7bc080e7          	jalr	1980(ra) # 5b80 <unlink>
  if (ret != -1)
    13cc:	57fd                	li	a5,-1
    13ce:	0ef51063          	bne	a0,a5,14ae <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13d2:	20100593          	li	a1,513
    13d6:	f6840513          	addi	a0,s0,-152
    13da:	00004097          	auipc	ra,0x4
    13de:	796080e7          	jalr	1942(ra) # 5b70 <open>
  if (fd != -1)
    13e2:	57fd                	li	a5,-1
    13e4:	0ef51563          	bne	a0,a5,14ce <copyinstr2+0x130>
  ret = link(b, b);
    13e8:	f6840593          	addi	a1,s0,-152
    13ec:	852e                	mv	a0,a1
    13ee:	00004097          	auipc	ra,0x4
    13f2:	7a2080e7          	jalr	1954(ra) # 5b90 <link>
  if (ret != -1)
    13f6:	57fd                	li	a5,-1
    13f8:	0ef51b63          	bne	a0,a5,14ee <copyinstr2+0x150>
  char *args[] = {"xx", 0};
    13fc:	00006797          	auipc	a5,0x6
    1400:	6ac78793          	addi	a5,a5,1708 # 7aa8 <malloc+0x1b22>
    1404:	f4f43c23          	sd	a5,-168(s0)
    1408:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    140c:	f5840593          	addi	a1,s0,-168
    1410:	f6840513          	addi	a0,s0,-152
    1414:	00004097          	auipc	ra,0x4
    1418:	754080e7          	jalr	1876(ra) # 5b68 <exec>
  if (ret != -1)
    141c:	57fd                	li	a5,-1
    141e:	0ef51963          	bne	a0,a5,1510 <copyinstr2+0x172>
  int pid = fork();
    1422:	00004097          	auipc	ra,0x4
    1426:	706080e7          	jalr	1798(ra) # 5b28 <fork>
  if (pid < 0)
    142a:	10054363          	bltz	a0,1530 <copyinstr2+0x192>
  if (pid == 0)
    142e:	12051463          	bnez	a0,1556 <copyinstr2+0x1b8>
    1432:	00008797          	auipc	a5,0x8
    1436:	12e78793          	addi	a5,a5,302 # 9560 <big.0>
    143a:	00009697          	auipc	a3,0x9
    143e:	12668693          	addi	a3,a3,294 # a560 <big.0+0x1000>
      big[i] = 'x';
    1442:	07800713          	li	a4,120
    1446:	00e78023          	sb	a4,0(a5)
    for (int i = 0; i < PGSIZE; i++)
    144a:	0785                	addi	a5,a5,1
    144c:	fed79de3          	bne	a5,a3,1446 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1450:	00009797          	auipc	a5,0x9
    1454:	10078823          	sb	zero,272(a5) # a560 <big.0+0x1000>
    char *args2[] = {big, big, big, 0};
    1458:	00007797          	auipc	a5,0x7
    145c:	05078793          	addi	a5,a5,80 # 84a8 <malloc+0x2522>
    1460:	6390                	ld	a2,0(a5)
    1462:	6794                	ld	a3,8(a5)
    1464:	6b98                	ld	a4,16(a5)
    1466:	6f9c                	ld	a5,24(a5)
    1468:	f2c43823          	sd	a2,-208(s0)
    146c:	f2d43c23          	sd	a3,-200(s0)
    1470:	f4e43023          	sd	a4,-192(s0)
    1474:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1478:	f3040593          	addi	a1,s0,-208
    147c:	00005517          	auipc	a0,0x5
    1480:	c4c50513          	addi	a0,a0,-948 # 60c8 <malloc+0x142>
    1484:	00004097          	auipc	ra,0x4
    1488:	6e4080e7          	jalr	1764(ra) # 5b68 <exec>
    if (ret != -1)
    148c:	57fd                	li	a5,-1
    148e:	0af50e63          	beq	a0,a5,154a <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1492:	55fd                	li	a1,-1
    1494:	00005517          	auipc	a0,0x5
    1498:	46450513          	addi	a0,a0,1124 # 68f8 <malloc+0x972>
    149c:	00005097          	auipc	ra,0x5
    14a0:	a2c080e7          	jalr	-1492(ra) # 5ec8 <printf>
      exit(1);
    14a4:	4505                	li	a0,1
    14a6:	00004097          	auipc	ra,0x4
    14aa:	68a080e7          	jalr	1674(ra) # 5b30 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14ae:	862a                	mv	a2,a0
    14b0:	f6840593          	addi	a1,s0,-152
    14b4:	00005517          	auipc	a0,0x5
    14b8:	3bc50513          	addi	a0,a0,956 # 6870 <malloc+0x8ea>
    14bc:	00005097          	auipc	ra,0x5
    14c0:	a0c080e7          	jalr	-1524(ra) # 5ec8 <printf>
    exit(1);
    14c4:	4505                	li	a0,1
    14c6:	00004097          	auipc	ra,0x4
    14ca:	66a080e7          	jalr	1642(ra) # 5b30 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14ce:	862a                	mv	a2,a0
    14d0:	f6840593          	addi	a1,s0,-152
    14d4:	00005517          	auipc	a0,0x5
    14d8:	3bc50513          	addi	a0,a0,956 # 6890 <malloc+0x90a>
    14dc:	00005097          	auipc	ra,0x5
    14e0:	9ec080e7          	jalr	-1556(ra) # 5ec8 <printf>
    exit(1);
    14e4:	4505                	li	a0,1
    14e6:	00004097          	auipc	ra,0x4
    14ea:	64a080e7          	jalr	1610(ra) # 5b30 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    14ee:	86aa                	mv	a3,a0
    14f0:	f6840613          	addi	a2,s0,-152
    14f4:	85b2                	mv	a1,a2
    14f6:	00005517          	auipc	a0,0x5
    14fa:	3ba50513          	addi	a0,a0,954 # 68b0 <malloc+0x92a>
    14fe:	00005097          	auipc	ra,0x5
    1502:	9ca080e7          	jalr	-1590(ra) # 5ec8 <printf>
    exit(1);
    1506:	4505                	li	a0,1
    1508:	00004097          	auipc	ra,0x4
    150c:	628080e7          	jalr	1576(ra) # 5b30 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1510:	567d                	li	a2,-1
    1512:	f6840593          	addi	a1,s0,-152
    1516:	00005517          	auipc	a0,0x5
    151a:	3c250513          	addi	a0,a0,962 # 68d8 <malloc+0x952>
    151e:	00005097          	auipc	ra,0x5
    1522:	9aa080e7          	jalr	-1622(ra) # 5ec8 <printf>
    exit(1);
    1526:	4505                	li	a0,1
    1528:	00004097          	auipc	ra,0x4
    152c:	608080e7          	jalr	1544(ra) # 5b30 <exit>
    printf("fork failed\n");
    1530:	00006517          	auipc	a0,0x6
    1534:	82850513          	addi	a0,a0,-2008 # 6d58 <malloc+0xdd2>
    1538:	00005097          	auipc	ra,0x5
    153c:	990080e7          	jalr	-1648(ra) # 5ec8 <printf>
    exit(1);
    1540:	4505                	li	a0,1
    1542:	00004097          	auipc	ra,0x4
    1546:	5ee080e7          	jalr	1518(ra) # 5b30 <exit>
    exit(747); // OK
    154a:	2eb00513          	li	a0,747
    154e:	00004097          	auipc	ra,0x4
    1552:	5e2080e7          	jalr	1506(ra) # 5b30 <exit>
  int st = 0;
    1556:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    155a:	f5440513          	addi	a0,s0,-172
    155e:	00004097          	auipc	ra,0x4
    1562:	5da080e7          	jalr	1498(ra) # 5b38 <wait>
  if (st != 747)
    1566:	f5442703          	lw	a4,-172(s0)
    156a:	2eb00793          	li	a5,747
    156e:	00f71663          	bne	a4,a5,157a <copyinstr2+0x1dc>
}
    1572:	60ae                	ld	ra,200(sp)
    1574:	640e                	ld	s0,192(sp)
    1576:	6169                	addi	sp,sp,208
    1578:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    157a:	00005517          	auipc	a0,0x5
    157e:	3a650513          	addi	a0,a0,934 # 6920 <malloc+0x99a>
    1582:	00005097          	auipc	ra,0x5
    1586:	946080e7          	jalr	-1722(ra) # 5ec8 <printf>
    exit(1);
    158a:	4505                	li	a0,1
    158c:	00004097          	auipc	ra,0x4
    1590:	5a4080e7          	jalr	1444(ra) # 5b30 <exit>

0000000000001594 <truncate3>:
{
    1594:	7159                	addi	sp,sp,-112
    1596:	f486                	sd	ra,104(sp)
    1598:	f0a2                	sd	s0,96(sp)
    159a:	eca6                	sd	s1,88(sp)
    159c:	e8ca                	sd	s2,80(sp)
    159e:	e4ce                	sd	s3,72(sp)
    15a0:	e0d2                	sd	s4,64(sp)
    15a2:	fc56                	sd	s5,56(sp)
    15a4:	1880                	addi	s0,sp,112
    15a6:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE | O_TRUNC | O_WRONLY));
    15a8:	60100593          	li	a1,1537
    15ac:	00005517          	auipc	a0,0x5
    15b0:	b7450513          	addi	a0,a0,-1164 # 6120 <malloc+0x19a>
    15b4:	00004097          	auipc	ra,0x4
    15b8:	5bc080e7          	jalr	1468(ra) # 5b70 <open>
    15bc:	00004097          	auipc	ra,0x4
    15c0:	59c080e7          	jalr	1436(ra) # 5b58 <close>
  pid = fork();
    15c4:	00004097          	auipc	ra,0x4
    15c8:	564080e7          	jalr	1380(ra) # 5b28 <fork>
  if (pid < 0)
    15cc:	08054063          	bltz	a0,164c <truncate3+0xb8>
  if (pid == 0)
    15d0:	e969                	bnez	a0,16a2 <truncate3+0x10e>
    15d2:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15d6:	00005a17          	auipc	s4,0x5
    15da:	b4aa0a13          	addi	s4,s4,-1206 # 6120 <malloc+0x19a>
      int n = write(fd, "1234567890", 10);
    15de:	00005a97          	auipc	s5,0x5
    15e2:	3a2a8a93          	addi	s5,s5,930 # 6980 <malloc+0x9fa>
      int fd = open("truncfile", O_WRONLY);
    15e6:	4585                	li	a1,1
    15e8:	8552                	mv	a0,s4
    15ea:	00004097          	auipc	ra,0x4
    15ee:	586080e7          	jalr	1414(ra) # 5b70 <open>
    15f2:	84aa                	mv	s1,a0
      if (fd < 0)
    15f4:	06054a63          	bltz	a0,1668 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    15f8:	4629                	li	a2,10
    15fa:	85d6                	mv	a1,s5
    15fc:	00004097          	auipc	ra,0x4
    1600:	554080e7          	jalr	1364(ra) # 5b50 <write>
      if (n != 10)
    1604:	47a9                	li	a5,10
    1606:	06f51f63          	bne	a0,a5,1684 <truncate3+0xf0>
      close(fd);
    160a:	8526                	mv	a0,s1
    160c:	00004097          	auipc	ra,0x4
    1610:	54c080e7          	jalr	1356(ra) # 5b58 <close>
      fd = open("truncfile", O_RDONLY);
    1614:	4581                	li	a1,0
    1616:	8552                	mv	a0,s4
    1618:	00004097          	auipc	ra,0x4
    161c:	558080e7          	jalr	1368(ra) # 5b70 <open>
    1620:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1622:	02000613          	li	a2,32
    1626:	f9840593          	addi	a1,s0,-104
    162a:	00004097          	auipc	ra,0x4
    162e:	51e080e7          	jalr	1310(ra) # 5b48 <read>
      close(fd);
    1632:	8526                	mv	a0,s1
    1634:	00004097          	auipc	ra,0x4
    1638:	524080e7          	jalr	1316(ra) # 5b58 <close>
    for (int i = 0; i < 100; i++)
    163c:	39fd                	addiw	s3,s3,-1
    163e:	fa0994e3          	bnez	s3,15e6 <truncate3+0x52>
    exit(0);
    1642:	4501                	li	a0,0
    1644:	00004097          	auipc	ra,0x4
    1648:	4ec080e7          	jalr	1260(ra) # 5b30 <exit>
    printf("%s: fork failed\n", s);
    164c:	85ca                	mv	a1,s2
    164e:	00005517          	auipc	a0,0x5
    1652:	30250513          	addi	a0,a0,770 # 6950 <malloc+0x9ca>
    1656:	00005097          	auipc	ra,0x5
    165a:	872080e7          	jalr	-1934(ra) # 5ec8 <printf>
    exit(1);
    165e:	4505                	li	a0,1
    1660:	00004097          	auipc	ra,0x4
    1664:	4d0080e7          	jalr	1232(ra) # 5b30 <exit>
        printf("%s: open failed\n", s);
    1668:	85ca                	mv	a1,s2
    166a:	00005517          	auipc	a0,0x5
    166e:	2fe50513          	addi	a0,a0,766 # 6968 <malloc+0x9e2>
    1672:	00005097          	auipc	ra,0x5
    1676:	856080e7          	jalr	-1962(ra) # 5ec8 <printf>
        exit(1);
    167a:	4505                	li	a0,1
    167c:	00004097          	auipc	ra,0x4
    1680:	4b4080e7          	jalr	1204(ra) # 5b30 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1684:	862a                	mv	a2,a0
    1686:	85ca                	mv	a1,s2
    1688:	00005517          	auipc	a0,0x5
    168c:	30850513          	addi	a0,a0,776 # 6990 <malloc+0xa0a>
    1690:	00005097          	auipc	ra,0x5
    1694:	838080e7          	jalr	-1992(ra) # 5ec8 <printf>
        exit(1);
    1698:	4505                	li	a0,1
    169a:	00004097          	auipc	ra,0x4
    169e:	496080e7          	jalr	1174(ra) # 5b30 <exit>
    16a2:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    16a6:	00005a17          	auipc	s4,0x5
    16aa:	a7aa0a13          	addi	s4,s4,-1414 # 6120 <malloc+0x19a>
    int n = write(fd, "xxx", 3);
    16ae:	00005a97          	auipc	s5,0x5
    16b2:	302a8a93          	addi	s5,s5,770 # 69b0 <malloc+0xa2a>
    int fd = open("truncfile", O_CREATE | O_WRONLY | O_TRUNC);
    16b6:	60100593          	li	a1,1537
    16ba:	8552                	mv	a0,s4
    16bc:	00004097          	auipc	ra,0x4
    16c0:	4b4080e7          	jalr	1204(ra) # 5b70 <open>
    16c4:	84aa                	mv	s1,a0
    if (fd < 0)
    16c6:	04054763          	bltz	a0,1714 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    16ca:	460d                	li	a2,3
    16cc:	85d6                	mv	a1,s5
    16ce:	00004097          	auipc	ra,0x4
    16d2:	482080e7          	jalr	1154(ra) # 5b50 <write>
    if (n != 3)
    16d6:	478d                	li	a5,3
    16d8:	04f51c63          	bne	a0,a5,1730 <truncate3+0x19c>
    close(fd);
    16dc:	8526                	mv	a0,s1
    16de:	00004097          	auipc	ra,0x4
    16e2:	47a080e7          	jalr	1146(ra) # 5b58 <close>
  for (int i = 0; i < 150; i++)
    16e6:	39fd                	addiw	s3,s3,-1
    16e8:	fc0997e3          	bnez	s3,16b6 <truncate3+0x122>
  wait(&xstatus);
    16ec:	fbc40513          	addi	a0,s0,-68
    16f0:	00004097          	auipc	ra,0x4
    16f4:	448080e7          	jalr	1096(ra) # 5b38 <wait>
  unlink("truncfile");
    16f8:	00005517          	auipc	a0,0x5
    16fc:	a2850513          	addi	a0,a0,-1496 # 6120 <malloc+0x19a>
    1700:	00004097          	auipc	ra,0x4
    1704:	480080e7          	jalr	1152(ra) # 5b80 <unlink>
  exit(xstatus);
    1708:	fbc42503          	lw	a0,-68(s0)
    170c:	00004097          	auipc	ra,0x4
    1710:	424080e7          	jalr	1060(ra) # 5b30 <exit>
      printf("%s: open failed\n", s);
    1714:	85ca                	mv	a1,s2
    1716:	00005517          	auipc	a0,0x5
    171a:	25250513          	addi	a0,a0,594 # 6968 <malloc+0x9e2>
    171e:	00004097          	auipc	ra,0x4
    1722:	7aa080e7          	jalr	1962(ra) # 5ec8 <printf>
      exit(1);
    1726:	4505                	li	a0,1
    1728:	00004097          	auipc	ra,0x4
    172c:	408080e7          	jalr	1032(ra) # 5b30 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1730:	862a                	mv	a2,a0
    1732:	85ca                	mv	a1,s2
    1734:	00005517          	auipc	a0,0x5
    1738:	28450513          	addi	a0,a0,644 # 69b8 <malloc+0xa32>
    173c:	00004097          	auipc	ra,0x4
    1740:	78c080e7          	jalr	1932(ra) # 5ec8 <printf>
      exit(1);
    1744:	4505                	li	a0,1
    1746:	00004097          	auipc	ra,0x4
    174a:	3ea080e7          	jalr	1002(ra) # 5b30 <exit>

000000000000174e <exectest>:
{
    174e:	715d                	addi	sp,sp,-80
    1750:	e486                	sd	ra,72(sp)
    1752:	e0a2                	sd	s0,64(sp)
    1754:	fc26                	sd	s1,56(sp)
    1756:	f84a                	sd	s2,48(sp)
    1758:	0880                	addi	s0,sp,80
    175a:	892a                	mv	s2,a0
  char *echoargv[] = {"echo", "OK", 0};
    175c:	00005797          	auipc	a5,0x5
    1760:	96c78793          	addi	a5,a5,-1684 # 60c8 <malloc+0x142>
    1764:	fcf43023          	sd	a5,-64(s0)
    1768:	00005797          	auipc	a5,0x5
    176c:	27078793          	addi	a5,a5,624 # 69d8 <malloc+0xa52>
    1770:	fcf43423          	sd	a5,-56(s0)
    1774:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1778:	00005517          	auipc	a0,0x5
    177c:	26850513          	addi	a0,a0,616 # 69e0 <malloc+0xa5a>
    1780:	00004097          	auipc	ra,0x4
    1784:	400080e7          	jalr	1024(ra) # 5b80 <unlink>
  pid = fork();
    1788:	00004097          	auipc	ra,0x4
    178c:	3a0080e7          	jalr	928(ra) # 5b28 <fork>
  if (pid < 0)
    1790:	04054663          	bltz	a0,17dc <exectest+0x8e>
    1794:	84aa                	mv	s1,a0
  if (pid == 0)
    1796:	e959                	bnez	a0,182c <exectest+0xde>
    close(1);
    1798:	4505                	li	a0,1
    179a:	00004097          	auipc	ra,0x4
    179e:	3be080e7          	jalr	958(ra) # 5b58 <close>
    fd = open("echo-ok", O_CREATE | O_WRONLY);
    17a2:	20100593          	li	a1,513
    17a6:	00005517          	auipc	a0,0x5
    17aa:	23a50513          	addi	a0,a0,570 # 69e0 <malloc+0xa5a>
    17ae:	00004097          	auipc	ra,0x4
    17b2:	3c2080e7          	jalr	962(ra) # 5b70 <open>
    if (fd < 0)
    17b6:	04054163          	bltz	a0,17f8 <exectest+0xaa>
    if (fd != 1)
    17ba:	4785                	li	a5,1
    17bc:	04f50c63          	beq	a0,a5,1814 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    17c0:	85ca                	mv	a1,s2
    17c2:	00005517          	auipc	a0,0x5
    17c6:	23e50513          	addi	a0,a0,574 # 6a00 <malloc+0xa7a>
    17ca:	00004097          	auipc	ra,0x4
    17ce:	6fe080e7          	jalr	1790(ra) # 5ec8 <printf>
      exit(1);
    17d2:	4505                	li	a0,1
    17d4:	00004097          	auipc	ra,0x4
    17d8:	35c080e7          	jalr	860(ra) # 5b30 <exit>
    printf("%s: fork failed\n", s);
    17dc:	85ca                	mv	a1,s2
    17de:	00005517          	auipc	a0,0x5
    17e2:	17250513          	addi	a0,a0,370 # 6950 <malloc+0x9ca>
    17e6:	00004097          	auipc	ra,0x4
    17ea:	6e2080e7          	jalr	1762(ra) # 5ec8 <printf>
    exit(1);
    17ee:	4505                	li	a0,1
    17f0:	00004097          	auipc	ra,0x4
    17f4:	340080e7          	jalr	832(ra) # 5b30 <exit>
      printf("%s: create failed\n", s);
    17f8:	85ca                	mv	a1,s2
    17fa:	00005517          	auipc	a0,0x5
    17fe:	1ee50513          	addi	a0,a0,494 # 69e8 <malloc+0xa62>
    1802:	00004097          	auipc	ra,0x4
    1806:	6c6080e7          	jalr	1734(ra) # 5ec8 <printf>
      exit(1);
    180a:	4505                	li	a0,1
    180c:	00004097          	auipc	ra,0x4
    1810:	324080e7          	jalr	804(ra) # 5b30 <exit>
    if (exec("echo", echoargv) < 0)
    1814:	fc040593          	addi	a1,s0,-64
    1818:	00005517          	auipc	a0,0x5
    181c:	8b050513          	addi	a0,a0,-1872 # 60c8 <malloc+0x142>
    1820:	00004097          	auipc	ra,0x4
    1824:	348080e7          	jalr	840(ra) # 5b68 <exec>
    1828:	02054163          	bltz	a0,184a <exectest+0xfc>
  if (wait(&xstatus) != pid)
    182c:	fdc40513          	addi	a0,s0,-36
    1830:	00004097          	auipc	ra,0x4
    1834:	308080e7          	jalr	776(ra) # 5b38 <wait>
    1838:	02951763          	bne	a0,s1,1866 <exectest+0x118>
  if (xstatus != 0)
    183c:	fdc42503          	lw	a0,-36(s0)
    1840:	cd0d                	beqz	a0,187a <exectest+0x12c>
    exit(xstatus);
    1842:	00004097          	auipc	ra,0x4
    1846:	2ee080e7          	jalr	750(ra) # 5b30 <exit>
      printf("%s: exec echo failed\n", s);
    184a:	85ca                	mv	a1,s2
    184c:	00005517          	auipc	a0,0x5
    1850:	1c450513          	addi	a0,a0,452 # 6a10 <malloc+0xa8a>
    1854:	00004097          	auipc	ra,0x4
    1858:	674080e7          	jalr	1652(ra) # 5ec8 <printf>
      exit(1);
    185c:	4505                	li	a0,1
    185e:	00004097          	auipc	ra,0x4
    1862:	2d2080e7          	jalr	722(ra) # 5b30 <exit>
    printf("%s: wait failed!\n", s);
    1866:	85ca                	mv	a1,s2
    1868:	00005517          	auipc	a0,0x5
    186c:	1c050513          	addi	a0,a0,448 # 6a28 <malloc+0xaa2>
    1870:	00004097          	auipc	ra,0x4
    1874:	658080e7          	jalr	1624(ra) # 5ec8 <printf>
    1878:	b7d1                	j	183c <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    187a:	4581                	li	a1,0
    187c:	00005517          	auipc	a0,0x5
    1880:	16450513          	addi	a0,a0,356 # 69e0 <malloc+0xa5a>
    1884:	00004097          	auipc	ra,0x4
    1888:	2ec080e7          	jalr	748(ra) # 5b70 <open>
  if (fd < 0)
    188c:	02054a63          	bltz	a0,18c0 <exectest+0x172>
  if (read(fd, buf, 2) != 2)
    1890:	4609                	li	a2,2
    1892:	fb840593          	addi	a1,s0,-72
    1896:	00004097          	auipc	ra,0x4
    189a:	2b2080e7          	jalr	690(ra) # 5b48 <read>
    189e:	4789                	li	a5,2
    18a0:	02f50e63          	beq	a0,a5,18dc <exectest+0x18e>
    printf("%s: read failed\n", s);
    18a4:	85ca                	mv	a1,s2
    18a6:	00005517          	auipc	a0,0x5
    18aa:	bf250513          	addi	a0,a0,-1038 # 6498 <malloc+0x512>
    18ae:	00004097          	auipc	ra,0x4
    18b2:	61a080e7          	jalr	1562(ra) # 5ec8 <printf>
    exit(1);
    18b6:	4505                	li	a0,1
    18b8:	00004097          	auipc	ra,0x4
    18bc:	278080e7          	jalr	632(ra) # 5b30 <exit>
    printf("%s: open failed\n", s);
    18c0:	85ca                	mv	a1,s2
    18c2:	00005517          	auipc	a0,0x5
    18c6:	0a650513          	addi	a0,a0,166 # 6968 <malloc+0x9e2>
    18ca:	00004097          	auipc	ra,0x4
    18ce:	5fe080e7          	jalr	1534(ra) # 5ec8 <printf>
    exit(1);
    18d2:	4505                	li	a0,1
    18d4:	00004097          	auipc	ra,0x4
    18d8:	25c080e7          	jalr	604(ra) # 5b30 <exit>
  unlink("echo-ok");
    18dc:	00005517          	auipc	a0,0x5
    18e0:	10450513          	addi	a0,a0,260 # 69e0 <malloc+0xa5a>
    18e4:	00004097          	auipc	ra,0x4
    18e8:	29c080e7          	jalr	668(ra) # 5b80 <unlink>
  if (buf[0] == 'O' && buf[1] == 'K')
    18ec:	fb844703          	lbu	a4,-72(s0)
    18f0:	04f00793          	li	a5,79
    18f4:	00f71863          	bne	a4,a5,1904 <exectest+0x1b6>
    18f8:	fb944703          	lbu	a4,-71(s0)
    18fc:	04b00793          	li	a5,75
    1900:	02f70063          	beq	a4,a5,1920 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1904:	85ca                	mv	a1,s2
    1906:	00005517          	auipc	a0,0x5
    190a:	13a50513          	addi	a0,a0,314 # 6a40 <malloc+0xaba>
    190e:	00004097          	auipc	ra,0x4
    1912:	5ba080e7          	jalr	1466(ra) # 5ec8 <printf>
    exit(1);
    1916:	4505                	li	a0,1
    1918:	00004097          	auipc	ra,0x4
    191c:	218080e7          	jalr	536(ra) # 5b30 <exit>
    exit(0);
    1920:	4501                	li	a0,0
    1922:	00004097          	auipc	ra,0x4
    1926:	20e080e7          	jalr	526(ra) # 5b30 <exit>

000000000000192a <pipe1>:
{
    192a:	711d                	addi	sp,sp,-96
    192c:	ec86                	sd	ra,88(sp)
    192e:	e8a2                	sd	s0,80(sp)
    1930:	e4a6                	sd	s1,72(sp)
    1932:	e0ca                	sd	s2,64(sp)
    1934:	fc4e                	sd	s3,56(sp)
    1936:	f852                	sd	s4,48(sp)
    1938:	f456                	sd	s5,40(sp)
    193a:	f05a                	sd	s6,32(sp)
    193c:	ec5e                	sd	s7,24(sp)
    193e:	1080                	addi	s0,sp,96
    1940:	892a                	mv	s2,a0
  if (pipe(fds) != 0)
    1942:	fa840513          	addi	a0,s0,-88
    1946:	00004097          	auipc	ra,0x4
    194a:	1fa080e7          	jalr	506(ra) # 5b40 <pipe>
    194e:	ed25                	bnez	a0,19c6 <pipe1+0x9c>
    1950:	84aa                	mv	s1,a0
  pid = fork();
    1952:	00004097          	auipc	ra,0x4
    1956:	1d6080e7          	jalr	470(ra) # 5b28 <fork>
    195a:	8a2a                	mv	s4,a0
  if (pid == 0)
    195c:	c159                	beqz	a0,19e2 <pipe1+0xb8>
  else if (pid > 0)
    195e:	16a05e63          	blez	a0,1ada <pipe1+0x1b0>
    close(fds[1]);
    1962:	fac42503          	lw	a0,-84(s0)
    1966:	00004097          	auipc	ra,0x4
    196a:	1f2080e7          	jalr	498(ra) # 5b58 <close>
    total = 0;
    196e:	8a26                	mv	s4,s1
    cc = 1;
    1970:	4985                	li	s3,1
    while ((n = read(fds[0], buf, cc)) > 0)
    1972:	0000ba97          	auipc	s5,0xb
    1976:	306a8a93          	addi	s5,s5,774 # cc78 <buf>
      if (cc > sizeof(buf))
    197a:	6b0d                	lui	s6,0x3
    while ((n = read(fds[0], buf, cc)) > 0)
    197c:	864e                	mv	a2,s3
    197e:	85d6                	mv	a1,s5
    1980:	fa842503          	lw	a0,-88(s0)
    1984:	00004097          	auipc	ra,0x4
    1988:	1c4080e7          	jalr	452(ra) # 5b48 <read>
    198c:	10a05263          	blez	a0,1a90 <pipe1+0x166>
      for (i = 0; i < n; i++)
    1990:	0000b717          	auipc	a4,0xb
    1994:	2e870713          	addi	a4,a4,744 # cc78 <buf>
    1998:	00a4863b          	addw	a2,s1,a0
        if ((buf[i] & 0xff) != (seq++ & 0xff))
    199c:	00074683          	lbu	a3,0(a4)
    19a0:	0ff4f793          	andi	a5,s1,255
    19a4:	2485                	addiw	s1,s1,1
    19a6:	0cf69163          	bne	a3,a5,1a68 <pipe1+0x13e>
      for (i = 0; i < n; i++)
    19aa:	0705                	addi	a4,a4,1
    19ac:	fec498e3          	bne	s1,a2,199c <pipe1+0x72>
      total += n;
    19b0:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19b4:	0019979b          	slliw	a5,s3,0x1
    19b8:	0007899b          	sext.w	s3,a5
      if (cc > sizeof(buf))
    19bc:	013b7363          	bgeu	s6,s3,19c2 <pipe1+0x98>
        cc = sizeof(buf);
    19c0:	89da                	mv	s3,s6
        if ((buf[i] & 0xff) != (seq++ & 0xff))
    19c2:	84b2                	mv	s1,a2
    19c4:	bf65                	j	197c <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    19c6:	85ca                	mv	a1,s2
    19c8:	00005517          	auipc	a0,0x5
    19cc:	09050513          	addi	a0,a0,144 # 6a58 <malloc+0xad2>
    19d0:	00004097          	auipc	ra,0x4
    19d4:	4f8080e7          	jalr	1272(ra) # 5ec8 <printf>
    exit(1);
    19d8:	4505                	li	a0,1
    19da:	00004097          	auipc	ra,0x4
    19de:	156080e7          	jalr	342(ra) # 5b30 <exit>
    close(fds[0]);
    19e2:	fa842503          	lw	a0,-88(s0)
    19e6:	00004097          	auipc	ra,0x4
    19ea:	172080e7          	jalr	370(ra) # 5b58 <close>
    for (n = 0; n < N; n++)
    19ee:	0000bb17          	auipc	s6,0xb
    19f2:	28ab0b13          	addi	s6,s6,650 # cc78 <buf>
    19f6:	416004bb          	negw	s1,s6
    19fa:	0ff4f493          	andi	s1,s1,255
    19fe:	409b0993          	addi	s3,s6,1033
      if (write(fds[1], buf, SZ) != SZ)
    1a02:	8bda                	mv	s7,s6
    for (n = 0; n < N; n++)
    1a04:	6a85                	lui	s5,0x1
    1a06:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x8f>
{
    1a0a:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a0c:	0097873b          	addw	a4,a5,s1
    1a10:	00e78023          	sb	a4,0(a5)
      for (i = 0; i < SZ; i++)
    1a14:	0785                	addi	a5,a5,1
    1a16:	fef99be3          	bne	s3,a5,1a0c <pipe1+0xe2>
        buf[i] = seq++;
    1a1a:	409a0a1b          	addiw	s4,s4,1033
      if (write(fds[1], buf, SZ) != SZ)
    1a1e:	40900613          	li	a2,1033
    1a22:	85de                	mv	a1,s7
    1a24:	fac42503          	lw	a0,-84(s0)
    1a28:	00004097          	auipc	ra,0x4
    1a2c:	128080e7          	jalr	296(ra) # 5b50 <write>
    1a30:	40900793          	li	a5,1033
    1a34:	00f51c63          	bne	a0,a5,1a4c <pipe1+0x122>
    for (n = 0; n < N; n++)
    1a38:	24a5                	addiw	s1,s1,9
    1a3a:	0ff4f493          	andi	s1,s1,255
    1a3e:	fd5a16e3          	bne	s4,s5,1a0a <pipe1+0xe0>
    exit(0);
    1a42:	4501                	li	a0,0
    1a44:	00004097          	auipc	ra,0x4
    1a48:	0ec080e7          	jalr	236(ra) # 5b30 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a4c:	85ca                	mv	a1,s2
    1a4e:	00005517          	auipc	a0,0x5
    1a52:	02250513          	addi	a0,a0,34 # 6a70 <malloc+0xaea>
    1a56:	00004097          	auipc	ra,0x4
    1a5a:	472080e7          	jalr	1138(ra) # 5ec8 <printf>
        exit(1);
    1a5e:	4505                	li	a0,1
    1a60:	00004097          	auipc	ra,0x4
    1a64:	0d0080e7          	jalr	208(ra) # 5b30 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a68:	85ca                	mv	a1,s2
    1a6a:	00005517          	auipc	a0,0x5
    1a6e:	01e50513          	addi	a0,a0,30 # 6a88 <malloc+0xb02>
    1a72:	00004097          	auipc	ra,0x4
    1a76:	456080e7          	jalr	1110(ra) # 5ec8 <printf>
}
    1a7a:	60e6                	ld	ra,88(sp)
    1a7c:	6446                	ld	s0,80(sp)
    1a7e:	64a6                	ld	s1,72(sp)
    1a80:	6906                	ld	s2,64(sp)
    1a82:	79e2                	ld	s3,56(sp)
    1a84:	7a42                	ld	s4,48(sp)
    1a86:	7aa2                	ld	s5,40(sp)
    1a88:	7b02                	ld	s6,32(sp)
    1a8a:	6be2                	ld	s7,24(sp)
    1a8c:	6125                	addi	sp,sp,96
    1a8e:	8082                	ret
    if (total != N * SZ)
    1a90:	6785                	lui	a5,0x1
    1a92:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x8f>
    1a96:	02fa0063          	beq	s4,a5,1ab6 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1a9a:	85d2                	mv	a1,s4
    1a9c:	00005517          	auipc	a0,0x5
    1aa0:	00450513          	addi	a0,a0,4 # 6aa0 <malloc+0xb1a>
    1aa4:	00004097          	auipc	ra,0x4
    1aa8:	424080e7          	jalr	1060(ra) # 5ec8 <printf>
      exit(1);
    1aac:	4505                	li	a0,1
    1aae:	00004097          	auipc	ra,0x4
    1ab2:	082080e7          	jalr	130(ra) # 5b30 <exit>
    close(fds[0]);
    1ab6:	fa842503          	lw	a0,-88(s0)
    1aba:	00004097          	auipc	ra,0x4
    1abe:	09e080e7          	jalr	158(ra) # 5b58 <close>
    wait(&xstatus);
    1ac2:	fa440513          	addi	a0,s0,-92
    1ac6:	00004097          	auipc	ra,0x4
    1aca:	072080e7          	jalr	114(ra) # 5b38 <wait>
    exit(xstatus);
    1ace:	fa442503          	lw	a0,-92(s0)
    1ad2:	00004097          	auipc	ra,0x4
    1ad6:	05e080e7          	jalr	94(ra) # 5b30 <exit>
    printf("%s: fork() failed\n", s);
    1ada:	85ca                	mv	a1,s2
    1adc:	00005517          	auipc	a0,0x5
    1ae0:	fe450513          	addi	a0,a0,-28 # 6ac0 <malloc+0xb3a>
    1ae4:	00004097          	auipc	ra,0x4
    1ae8:	3e4080e7          	jalr	996(ra) # 5ec8 <printf>
    exit(1);
    1aec:	4505                	li	a0,1
    1aee:	00004097          	auipc	ra,0x4
    1af2:	042080e7          	jalr	66(ra) # 5b30 <exit>

0000000000001af6 <exitwait>:
{
    1af6:	7139                	addi	sp,sp,-64
    1af8:	fc06                	sd	ra,56(sp)
    1afa:	f822                	sd	s0,48(sp)
    1afc:	f426                	sd	s1,40(sp)
    1afe:	f04a                	sd	s2,32(sp)
    1b00:	ec4e                	sd	s3,24(sp)
    1b02:	e852                	sd	s4,16(sp)
    1b04:	0080                	addi	s0,sp,64
    1b06:	8a2a                	mv	s4,a0
  for (i = 0; i < 100; i++)
    1b08:	4901                	li	s2,0
    1b0a:	06400993          	li	s3,100
    pid = fork();
    1b0e:	00004097          	auipc	ra,0x4
    1b12:	01a080e7          	jalr	26(ra) # 5b28 <fork>
    1b16:	84aa                	mv	s1,a0
    if (pid < 0)
    1b18:	02054a63          	bltz	a0,1b4c <exitwait+0x56>
    if (pid)
    1b1c:	c151                	beqz	a0,1ba0 <exitwait+0xaa>
      if (wait(&xstate) != pid)
    1b1e:	fcc40513          	addi	a0,s0,-52
    1b22:	00004097          	auipc	ra,0x4
    1b26:	016080e7          	jalr	22(ra) # 5b38 <wait>
    1b2a:	02951f63          	bne	a0,s1,1b68 <exitwait+0x72>
      if (i != xstate)
    1b2e:	fcc42783          	lw	a5,-52(s0)
    1b32:	05279963          	bne	a5,s2,1b84 <exitwait+0x8e>
  for (i = 0; i < 100; i++)
    1b36:	2905                	addiw	s2,s2,1
    1b38:	fd391be3          	bne	s2,s3,1b0e <exitwait+0x18>
}
    1b3c:	70e2                	ld	ra,56(sp)
    1b3e:	7442                	ld	s0,48(sp)
    1b40:	74a2                	ld	s1,40(sp)
    1b42:	7902                	ld	s2,32(sp)
    1b44:	69e2                	ld	s3,24(sp)
    1b46:	6a42                	ld	s4,16(sp)
    1b48:	6121                	addi	sp,sp,64
    1b4a:	8082                	ret
      printf("%s: fork failed\n", s);
    1b4c:	85d2                	mv	a1,s4
    1b4e:	00005517          	auipc	a0,0x5
    1b52:	e0250513          	addi	a0,a0,-510 # 6950 <malloc+0x9ca>
    1b56:	00004097          	auipc	ra,0x4
    1b5a:	372080e7          	jalr	882(ra) # 5ec8 <printf>
      exit(1);
    1b5e:	4505                	li	a0,1
    1b60:	00004097          	auipc	ra,0x4
    1b64:	fd0080e7          	jalr	-48(ra) # 5b30 <exit>
        printf("%s: wait wrong pid\n", s);
    1b68:	85d2                	mv	a1,s4
    1b6a:	00005517          	auipc	a0,0x5
    1b6e:	f6e50513          	addi	a0,a0,-146 # 6ad8 <malloc+0xb52>
    1b72:	00004097          	auipc	ra,0x4
    1b76:	356080e7          	jalr	854(ra) # 5ec8 <printf>
        exit(1);
    1b7a:	4505                	li	a0,1
    1b7c:	00004097          	auipc	ra,0x4
    1b80:	fb4080e7          	jalr	-76(ra) # 5b30 <exit>
        printf("%s: wait wrong exit status\n", s);
    1b84:	85d2                	mv	a1,s4
    1b86:	00005517          	auipc	a0,0x5
    1b8a:	f6a50513          	addi	a0,a0,-150 # 6af0 <malloc+0xb6a>
    1b8e:	00004097          	auipc	ra,0x4
    1b92:	33a080e7          	jalr	826(ra) # 5ec8 <printf>
        exit(1);
    1b96:	4505                	li	a0,1
    1b98:	00004097          	auipc	ra,0x4
    1b9c:	f98080e7          	jalr	-104(ra) # 5b30 <exit>
      exit(i);
    1ba0:	854a                	mv	a0,s2
    1ba2:	00004097          	auipc	ra,0x4
    1ba6:	f8e080e7          	jalr	-114(ra) # 5b30 <exit>

0000000000001baa <twochildren>:
{
    1baa:	1101                	addi	sp,sp,-32
    1bac:	ec06                	sd	ra,24(sp)
    1bae:	e822                	sd	s0,16(sp)
    1bb0:	e426                	sd	s1,8(sp)
    1bb2:	e04a                	sd	s2,0(sp)
    1bb4:	1000                	addi	s0,sp,32
    1bb6:	892a                	mv	s2,a0
    1bb8:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bbc:	00004097          	auipc	ra,0x4
    1bc0:	f6c080e7          	jalr	-148(ra) # 5b28 <fork>
    if (pid1 < 0)
    1bc4:	02054c63          	bltz	a0,1bfc <twochildren+0x52>
    if (pid1 == 0)
    1bc8:	c921                	beqz	a0,1c18 <twochildren+0x6e>
      int pid2 = fork();
    1bca:	00004097          	auipc	ra,0x4
    1bce:	f5e080e7          	jalr	-162(ra) # 5b28 <fork>
      if (pid2 < 0)
    1bd2:	04054763          	bltz	a0,1c20 <twochildren+0x76>
      if (pid2 == 0)
    1bd6:	c13d                	beqz	a0,1c3c <twochildren+0x92>
        wait(0);
    1bd8:	4501                	li	a0,0
    1bda:	00004097          	auipc	ra,0x4
    1bde:	f5e080e7          	jalr	-162(ra) # 5b38 <wait>
        wait(0);
    1be2:	4501                	li	a0,0
    1be4:	00004097          	auipc	ra,0x4
    1be8:	f54080e7          	jalr	-172(ra) # 5b38 <wait>
  for (int i = 0; i < 1000; i++)
    1bec:	34fd                	addiw	s1,s1,-1
    1bee:	f4f9                	bnez	s1,1bbc <twochildren+0x12>
}
    1bf0:	60e2                	ld	ra,24(sp)
    1bf2:	6442                	ld	s0,16(sp)
    1bf4:	64a2                	ld	s1,8(sp)
    1bf6:	6902                	ld	s2,0(sp)
    1bf8:	6105                	addi	sp,sp,32
    1bfa:	8082                	ret
      printf("%s: fork failed\n", s);
    1bfc:	85ca                	mv	a1,s2
    1bfe:	00005517          	auipc	a0,0x5
    1c02:	d5250513          	addi	a0,a0,-686 # 6950 <malloc+0x9ca>
    1c06:	00004097          	auipc	ra,0x4
    1c0a:	2c2080e7          	jalr	706(ra) # 5ec8 <printf>
      exit(1);
    1c0e:	4505                	li	a0,1
    1c10:	00004097          	auipc	ra,0x4
    1c14:	f20080e7          	jalr	-224(ra) # 5b30 <exit>
      exit(0);
    1c18:	00004097          	auipc	ra,0x4
    1c1c:	f18080e7          	jalr	-232(ra) # 5b30 <exit>
        printf("%s: fork failed\n", s);
    1c20:	85ca                	mv	a1,s2
    1c22:	00005517          	auipc	a0,0x5
    1c26:	d2e50513          	addi	a0,a0,-722 # 6950 <malloc+0x9ca>
    1c2a:	00004097          	auipc	ra,0x4
    1c2e:	29e080e7          	jalr	670(ra) # 5ec8 <printf>
        exit(1);
    1c32:	4505                	li	a0,1
    1c34:	00004097          	auipc	ra,0x4
    1c38:	efc080e7          	jalr	-260(ra) # 5b30 <exit>
        exit(0);
    1c3c:	00004097          	auipc	ra,0x4
    1c40:	ef4080e7          	jalr	-268(ra) # 5b30 <exit>

0000000000001c44 <forkfork>:
{
    1c44:	7179                	addi	sp,sp,-48
    1c46:	f406                	sd	ra,40(sp)
    1c48:	f022                	sd	s0,32(sp)
    1c4a:	ec26                	sd	s1,24(sp)
    1c4c:	1800                	addi	s0,sp,48
    1c4e:	84aa                	mv	s1,a0
    int pid = fork();
    1c50:	00004097          	auipc	ra,0x4
    1c54:	ed8080e7          	jalr	-296(ra) # 5b28 <fork>
    if (pid < 0)
    1c58:	04054163          	bltz	a0,1c9a <forkfork+0x56>
    if (pid == 0)
    1c5c:	cd29                	beqz	a0,1cb6 <forkfork+0x72>
    int pid = fork();
    1c5e:	00004097          	auipc	ra,0x4
    1c62:	eca080e7          	jalr	-310(ra) # 5b28 <fork>
    if (pid < 0)
    1c66:	02054a63          	bltz	a0,1c9a <forkfork+0x56>
    if (pid == 0)
    1c6a:	c531                	beqz	a0,1cb6 <forkfork+0x72>
    wait(&xstatus);
    1c6c:	fdc40513          	addi	a0,s0,-36
    1c70:	00004097          	auipc	ra,0x4
    1c74:	ec8080e7          	jalr	-312(ra) # 5b38 <wait>
    if (xstatus != 0)
    1c78:	fdc42783          	lw	a5,-36(s0)
    1c7c:	ebbd                	bnez	a5,1cf2 <forkfork+0xae>
    wait(&xstatus);
    1c7e:	fdc40513          	addi	a0,s0,-36
    1c82:	00004097          	auipc	ra,0x4
    1c86:	eb6080e7          	jalr	-330(ra) # 5b38 <wait>
    if (xstatus != 0)
    1c8a:	fdc42783          	lw	a5,-36(s0)
    1c8e:	e3b5                	bnez	a5,1cf2 <forkfork+0xae>
}
    1c90:	70a2                	ld	ra,40(sp)
    1c92:	7402                	ld	s0,32(sp)
    1c94:	64e2                	ld	s1,24(sp)
    1c96:	6145                	addi	sp,sp,48
    1c98:	8082                	ret
      printf("%s: fork failed", s);
    1c9a:	85a6                	mv	a1,s1
    1c9c:	00005517          	auipc	a0,0x5
    1ca0:	e7450513          	addi	a0,a0,-396 # 6b10 <malloc+0xb8a>
    1ca4:	00004097          	auipc	ra,0x4
    1ca8:	224080e7          	jalr	548(ra) # 5ec8 <printf>
      exit(1);
    1cac:	4505                	li	a0,1
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	e82080e7          	jalr	-382(ra) # 5b30 <exit>
{
    1cb6:	0c800493          	li	s1,200
        int pid1 = fork();
    1cba:	00004097          	auipc	ra,0x4
    1cbe:	e6e080e7          	jalr	-402(ra) # 5b28 <fork>
        if (pid1 < 0)
    1cc2:	00054f63          	bltz	a0,1ce0 <forkfork+0x9c>
        if (pid1 == 0)
    1cc6:	c115                	beqz	a0,1cea <forkfork+0xa6>
        wait(0);
    1cc8:	4501                	li	a0,0
    1cca:	00004097          	auipc	ra,0x4
    1cce:	e6e080e7          	jalr	-402(ra) # 5b38 <wait>
      for (int j = 0; j < 200; j++)
    1cd2:	34fd                	addiw	s1,s1,-1
    1cd4:	f0fd                	bnez	s1,1cba <forkfork+0x76>
      exit(0);
    1cd6:	4501                	li	a0,0
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	e58080e7          	jalr	-424(ra) # 5b30 <exit>
          exit(1);
    1ce0:	4505                	li	a0,1
    1ce2:	00004097          	auipc	ra,0x4
    1ce6:	e4e080e7          	jalr	-434(ra) # 5b30 <exit>
          exit(0);
    1cea:	00004097          	auipc	ra,0x4
    1cee:	e46080e7          	jalr	-442(ra) # 5b30 <exit>
      printf("%s: fork in child failed", s);
    1cf2:	85a6                	mv	a1,s1
    1cf4:	00005517          	auipc	a0,0x5
    1cf8:	e2c50513          	addi	a0,a0,-468 # 6b20 <malloc+0xb9a>
    1cfc:	00004097          	auipc	ra,0x4
    1d00:	1cc080e7          	jalr	460(ra) # 5ec8 <printf>
      exit(1);
    1d04:	4505                	li	a0,1
    1d06:	00004097          	auipc	ra,0x4
    1d0a:	e2a080e7          	jalr	-470(ra) # 5b30 <exit>

0000000000001d0e <reparent2>:
{
    1d0e:	1101                	addi	sp,sp,-32
    1d10:	ec06                	sd	ra,24(sp)
    1d12:	e822                	sd	s0,16(sp)
    1d14:	e426                	sd	s1,8(sp)
    1d16:	1000                	addi	s0,sp,32
    1d18:	32000493          	li	s1,800
    int pid1 = fork();
    1d1c:	00004097          	auipc	ra,0x4
    1d20:	e0c080e7          	jalr	-500(ra) # 5b28 <fork>
    if (pid1 < 0)
    1d24:	00054f63          	bltz	a0,1d42 <reparent2+0x34>
    if (pid1 == 0)
    1d28:	c915                	beqz	a0,1d5c <reparent2+0x4e>
    wait(0);
    1d2a:	4501                	li	a0,0
    1d2c:	00004097          	auipc	ra,0x4
    1d30:	e0c080e7          	jalr	-500(ra) # 5b38 <wait>
  for (int i = 0; i < 800; i++)
    1d34:	34fd                	addiw	s1,s1,-1
    1d36:	f0fd                	bnez	s1,1d1c <reparent2+0xe>
  exit(0);
    1d38:	4501                	li	a0,0
    1d3a:	00004097          	auipc	ra,0x4
    1d3e:	df6080e7          	jalr	-522(ra) # 5b30 <exit>
      printf("fork failed\n");
    1d42:	00005517          	auipc	a0,0x5
    1d46:	01650513          	addi	a0,a0,22 # 6d58 <malloc+0xdd2>
    1d4a:	00004097          	auipc	ra,0x4
    1d4e:	17e080e7          	jalr	382(ra) # 5ec8 <printf>
      exit(1);
    1d52:	4505                	li	a0,1
    1d54:	00004097          	auipc	ra,0x4
    1d58:	ddc080e7          	jalr	-548(ra) # 5b30 <exit>
      fork();
    1d5c:	00004097          	auipc	ra,0x4
    1d60:	dcc080e7          	jalr	-564(ra) # 5b28 <fork>
      fork();
    1d64:	00004097          	auipc	ra,0x4
    1d68:	dc4080e7          	jalr	-572(ra) # 5b28 <fork>
      exit(0);
    1d6c:	4501                	li	a0,0
    1d6e:	00004097          	auipc	ra,0x4
    1d72:	dc2080e7          	jalr	-574(ra) # 5b30 <exit>

0000000000001d76 <createdelete>:
{
    1d76:	7175                	addi	sp,sp,-144
    1d78:	e506                	sd	ra,136(sp)
    1d7a:	e122                	sd	s0,128(sp)
    1d7c:	fca6                	sd	s1,120(sp)
    1d7e:	f8ca                	sd	s2,112(sp)
    1d80:	f4ce                	sd	s3,104(sp)
    1d82:	f0d2                	sd	s4,96(sp)
    1d84:	ecd6                	sd	s5,88(sp)
    1d86:	e8da                	sd	s6,80(sp)
    1d88:	e4de                	sd	s7,72(sp)
    1d8a:	e0e2                	sd	s8,64(sp)
    1d8c:	fc66                	sd	s9,56(sp)
    1d8e:	0900                	addi	s0,sp,144
    1d90:	8caa                	mv	s9,a0
  for (pi = 0; pi < NCHILD; pi++)
    1d92:	4901                	li	s2,0
    1d94:	4991                	li	s3,4
    pid = fork();
    1d96:	00004097          	auipc	ra,0x4
    1d9a:	d92080e7          	jalr	-622(ra) # 5b28 <fork>
    1d9e:	84aa                	mv	s1,a0
    if (pid < 0)
    1da0:	02054f63          	bltz	a0,1dde <createdelete+0x68>
    if (pid == 0)
    1da4:	c939                	beqz	a0,1dfa <createdelete+0x84>
  for (pi = 0; pi < NCHILD; pi++)
    1da6:	2905                	addiw	s2,s2,1
    1da8:	ff3917e3          	bne	s2,s3,1d96 <createdelete+0x20>
    1dac:	4491                	li	s1,4
    wait(&xstatus);
    1dae:	f7c40513          	addi	a0,s0,-132
    1db2:	00004097          	auipc	ra,0x4
    1db6:	d86080e7          	jalr	-634(ra) # 5b38 <wait>
    if (xstatus != 0)
    1dba:	f7c42903          	lw	s2,-132(s0)
    1dbe:	0e091263          	bnez	s2,1ea2 <createdelete+0x12c>
  for (pi = 0; pi < NCHILD; pi++)
    1dc2:	34fd                	addiw	s1,s1,-1
    1dc4:	f4ed                	bnez	s1,1dae <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1dc6:	f8040123          	sb	zero,-126(s0)
    1dca:	03000993          	li	s3,48
    1dce:	5a7d                	li	s4,-1
    1dd0:	07000c13          	li	s8,112
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1dd4:	4b21                	li	s6,8
      if ((i == 0 || i >= N / 2) && fd < 0)
    1dd6:	4ba5                	li	s7,9
    for (pi = 0; pi < NCHILD; pi++)
    1dd8:	07400a93          	li	s5,116
    1ddc:	a29d                	j	1f42 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1dde:	85e6                	mv	a1,s9
    1de0:	00005517          	auipc	a0,0x5
    1de4:	f7850513          	addi	a0,a0,-136 # 6d58 <malloc+0xdd2>
    1de8:	00004097          	auipc	ra,0x4
    1dec:	0e0080e7          	jalr	224(ra) # 5ec8 <printf>
      exit(1);
    1df0:	4505                	li	a0,1
    1df2:	00004097          	auipc	ra,0x4
    1df6:	d3e080e7          	jalr	-706(ra) # 5b30 <exit>
      name[0] = 'p' + pi;
    1dfa:	0709091b          	addiw	s2,s2,112
    1dfe:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1e02:	f8040123          	sb	zero,-126(s0)
      for (i = 0; i < N; i++)
    1e06:	4951                	li	s2,20
    1e08:	a015                	j	1e2c <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1e0a:	85e6                	mv	a1,s9
    1e0c:	00005517          	auipc	a0,0x5
    1e10:	bdc50513          	addi	a0,a0,-1060 # 69e8 <malloc+0xa62>
    1e14:	00004097          	auipc	ra,0x4
    1e18:	0b4080e7          	jalr	180(ra) # 5ec8 <printf>
          exit(1);
    1e1c:	4505                	li	a0,1
    1e1e:	00004097          	auipc	ra,0x4
    1e22:	d12080e7          	jalr	-750(ra) # 5b30 <exit>
      for (i = 0; i < N; i++)
    1e26:	2485                	addiw	s1,s1,1
    1e28:	07248863          	beq	s1,s2,1e98 <createdelete+0x122>
        name[1] = '0' + i;
    1e2c:	0304879b          	addiw	a5,s1,48
    1e30:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e34:	20200593          	li	a1,514
    1e38:	f8040513          	addi	a0,s0,-128
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	d34080e7          	jalr	-716(ra) # 5b70 <open>
        if (fd < 0)
    1e44:	fc0543e3          	bltz	a0,1e0a <createdelete+0x94>
        close(fd);
    1e48:	00004097          	auipc	ra,0x4
    1e4c:	d10080e7          	jalr	-752(ra) # 5b58 <close>
        if (i > 0 && (i % 2) == 0)
    1e50:	fc905be3          	blez	s1,1e26 <createdelete+0xb0>
    1e54:	0014f793          	andi	a5,s1,1
    1e58:	f7f9                	bnez	a5,1e26 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e5a:	01f4d79b          	srliw	a5,s1,0x1f
    1e5e:	9fa5                	addw	a5,a5,s1
    1e60:	4017d79b          	sraiw	a5,a5,0x1
    1e64:	0307879b          	addiw	a5,a5,48
    1e68:	f8f400a3          	sb	a5,-127(s0)
          if (unlink(name) < 0)
    1e6c:	f8040513          	addi	a0,s0,-128
    1e70:	00004097          	auipc	ra,0x4
    1e74:	d10080e7          	jalr	-752(ra) # 5b80 <unlink>
    1e78:	fa0557e3          	bgez	a0,1e26 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1e7c:	85e6                	mv	a1,s9
    1e7e:	00005517          	auipc	a0,0x5
    1e82:	cc250513          	addi	a0,a0,-830 # 6b40 <malloc+0xbba>
    1e86:	00004097          	auipc	ra,0x4
    1e8a:	042080e7          	jalr	66(ra) # 5ec8 <printf>
            exit(1);
    1e8e:	4505                	li	a0,1
    1e90:	00004097          	auipc	ra,0x4
    1e94:	ca0080e7          	jalr	-864(ra) # 5b30 <exit>
      exit(0);
    1e98:	4501                	li	a0,0
    1e9a:	00004097          	auipc	ra,0x4
    1e9e:	c96080e7          	jalr	-874(ra) # 5b30 <exit>
      exit(1);
    1ea2:	4505                	li	a0,1
    1ea4:	00004097          	auipc	ra,0x4
    1ea8:	c8c080e7          	jalr	-884(ra) # 5b30 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1eac:	f8040613          	addi	a2,s0,-128
    1eb0:	85e6                	mv	a1,s9
    1eb2:	00005517          	auipc	a0,0x5
    1eb6:	ca650513          	addi	a0,a0,-858 # 6b58 <malloc+0xbd2>
    1eba:	00004097          	auipc	ra,0x4
    1ebe:	00e080e7          	jalr	14(ra) # 5ec8 <printf>
        exit(1);
    1ec2:	4505                	li	a0,1
    1ec4:	00004097          	auipc	ra,0x4
    1ec8:	c6c080e7          	jalr	-916(ra) # 5b30 <exit>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1ecc:	054b7163          	bgeu	s6,s4,1f0e <createdelete+0x198>
      if (fd >= 0)
    1ed0:	02055a63          	bgez	a0,1f04 <createdelete+0x18e>
    for (pi = 0; pi < NCHILD; pi++)
    1ed4:	2485                	addiw	s1,s1,1
    1ed6:	0ff4f493          	andi	s1,s1,255
    1eda:	05548c63          	beq	s1,s5,1f32 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1ede:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1ee2:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1ee6:	4581                	li	a1,0
    1ee8:	f8040513          	addi	a0,s0,-128
    1eec:	00004097          	auipc	ra,0x4
    1ef0:	c84080e7          	jalr	-892(ra) # 5b70 <open>
      if ((i == 0 || i >= N / 2) && fd < 0)
    1ef4:	00090463          	beqz	s2,1efc <createdelete+0x186>
    1ef8:	fd2bdae3          	bge	s7,s2,1ecc <createdelete+0x156>
    1efc:	fa0548e3          	bltz	a0,1eac <createdelete+0x136>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1f00:	014b7963          	bgeu	s6,s4,1f12 <createdelete+0x19c>
        close(fd);
    1f04:	00004097          	auipc	ra,0x4
    1f08:	c54080e7          	jalr	-940(ra) # 5b58 <close>
    1f0c:	b7e1                	j	1ed4 <createdelete+0x15e>
      else if ((i >= 1 && i < N / 2) && fd >= 0)
    1f0e:	fc0543e3          	bltz	a0,1ed4 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f12:	f8040613          	addi	a2,s0,-128
    1f16:	85e6                	mv	a1,s9
    1f18:	00005517          	auipc	a0,0x5
    1f1c:	c6850513          	addi	a0,a0,-920 # 6b80 <malloc+0xbfa>
    1f20:	00004097          	auipc	ra,0x4
    1f24:	fa8080e7          	jalr	-88(ra) # 5ec8 <printf>
        exit(1);
    1f28:	4505                	li	a0,1
    1f2a:	00004097          	auipc	ra,0x4
    1f2e:	c06080e7          	jalr	-1018(ra) # 5b30 <exit>
  for (i = 0; i < N; i++)
    1f32:	2905                	addiw	s2,s2,1
    1f34:	2a05                	addiw	s4,s4,1
    1f36:	2985                	addiw	s3,s3,1
    1f38:	0ff9f993          	andi	s3,s3,255
    1f3c:	47d1                	li	a5,20
    1f3e:	02f90a63          	beq	s2,a5,1f72 <createdelete+0x1fc>
    for (pi = 0; pi < NCHILD; pi++)
    1f42:	84e2                	mv	s1,s8
    1f44:	bf69                	j	1ede <createdelete+0x168>
  for (i = 0; i < N; i++)
    1f46:	2905                	addiw	s2,s2,1
    1f48:	0ff97913          	andi	s2,s2,255
    1f4c:	2985                	addiw	s3,s3,1
    1f4e:	0ff9f993          	andi	s3,s3,255
    1f52:	03490863          	beq	s2,s4,1f82 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f56:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f58:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f5c:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f60:	f8040513          	addi	a0,s0,-128
    1f64:	00004097          	auipc	ra,0x4
    1f68:	c1c080e7          	jalr	-996(ra) # 5b80 <unlink>
    for (pi = 0; pi < NCHILD; pi++)
    1f6c:	34fd                	addiw	s1,s1,-1
    1f6e:	f4ed                	bnez	s1,1f58 <createdelete+0x1e2>
    1f70:	bfd9                	j	1f46 <createdelete+0x1d0>
    1f72:	03000993          	li	s3,48
    1f76:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f7a:	4a91                	li	s5,4
  for (i = 0; i < N; i++)
    1f7c:	08400a13          	li	s4,132
    1f80:	bfd9                	j	1f56 <createdelete+0x1e0>
}
    1f82:	60aa                	ld	ra,136(sp)
    1f84:	640a                	ld	s0,128(sp)
    1f86:	74e6                	ld	s1,120(sp)
    1f88:	7946                	ld	s2,112(sp)
    1f8a:	79a6                	ld	s3,104(sp)
    1f8c:	7a06                	ld	s4,96(sp)
    1f8e:	6ae6                	ld	s5,88(sp)
    1f90:	6b46                	ld	s6,80(sp)
    1f92:	6ba6                	ld	s7,72(sp)
    1f94:	6c06                	ld	s8,64(sp)
    1f96:	7ce2                	ld	s9,56(sp)
    1f98:	6149                	addi	sp,sp,144
    1f9a:	8082                	ret

0000000000001f9c <linkunlink>:
{
    1f9c:	711d                	addi	sp,sp,-96
    1f9e:	ec86                	sd	ra,88(sp)
    1fa0:	e8a2                	sd	s0,80(sp)
    1fa2:	e4a6                	sd	s1,72(sp)
    1fa4:	e0ca                	sd	s2,64(sp)
    1fa6:	fc4e                	sd	s3,56(sp)
    1fa8:	f852                	sd	s4,48(sp)
    1faa:	f456                	sd	s5,40(sp)
    1fac:	f05a                	sd	s6,32(sp)
    1fae:	ec5e                	sd	s7,24(sp)
    1fb0:	e862                	sd	s8,16(sp)
    1fb2:	e466                	sd	s9,8(sp)
    1fb4:	1080                	addi	s0,sp,96
    1fb6:	84aa                	mv	s1,a0
  unlink("x");
    1fb8:	00004517          	auipc	a0,0x4
    1fbc:	18050513          	addi	a0,a0,384 # 6138 <malloc+0x1b2>
    1fc0:	00004097          	auipc	ra,0x4
    1fc4:	bc0080e7          	jalr	-1088(ra) # 5b80 <unlink>
  pid = fork();
    1fc8:	00004097          	auipc	ra,0x4
    1fcc:	b60080e7          	jalr	-1184(ra) # 5b28 <fork>
  if (pid < 0)
    1fd0:	02054b63          	bltz	a0,2006 <linkunlink+0x6a>
    1fd4:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1fd6:	4c85                	li	s9,1
    1fd8:	e119                	bnez	a0,1fde <linkunlink+0x42>
    1fda:	06100c93          	li	s9,97
    1fde:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1fe2:	41c659b7          	lui	s3,0x41c65
    1fe6:	e6d9899b          	addiw	s3,s3,-403
    1fea:	690d                	lui	s2,0x3
    1fec:	0399091b          	addiw	s2,s2,57
    if ((x % 3) == 0)
    1ff0:	4a0d                	li	s4,3
    else if ((x % 3) == 1)
    1ff2:	4b05                	li	s6,1
      unlink("x");
    1ff4:	00004a97          	auipc	s5,0x4
    1ff8:	144a8a93          	addi	s5,s5,324 # 6138 <malloc+0x1b2>
      link("cat", "x");
    1ffc:	00005b97          	auipc	s7,0x5
    2000:	bacb8b93          	addi	s7,s7,-1108 # 6ba8 <malloc+0xc22>
    2004:	a825                	j	203c <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    2006:	85a6                	mv	a1,s1
    2008:	00005517          	auipc	a0,0x5
    200c:	94850513          	addi	a0,a0,-1720 # 6950 <malloc+0x9ca>
    2010:	00004097          	auipc	ra,0x4
    2014:	eb8080e7          	jalr	-328(ra) # 5ec8 <printf>
    exit(1);
    2018:	4505                	li	a0,1
    201a:	00004097          	auipc	ra,0x4
    201e:	b16080e7          	jalr	-1258(ra) # 5b30 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2022:	20200593          	li	a1,514
    2026:	8556                	mv	a0,s5
    2028:	00004097          	auipc	ra,0x4
    202c:	b48080e7          	jalr	-1208(ra) # 5b70 <open>
    2030:	00004097          	auipc	ra,0x4
    2034:	b28080e7          	jalr	-1240(ra) # 5b58 <close>
  for (i = 0; i < 100; i++)
    2038:	34fd                	addiw	s1,s1,-1
    203a:	c88d                	beqz	s1,206c <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    203c:	033c87bb          	mulw	a5,s9,s3
    2040:	012787bb          	addw	a5,a5,s2
    2044:	00078c9b          	sext.w	s9,a5
    if ((x % 3) == 0)
    2048:	0347f7bb          	remuw	a5,a5,s4
    204c:	dbf9                	beqz	a5,2022 <linkunlink+0x86>
    else if ((x % 3) == 1)
    204e:	01678863          	beq	a5,s6,205e <linkunlink+0xc2>
      unlink("x");
    2052:	8556                	mv	a0,s5
    2054:	00004097          	auipc	ra,0x4
    2058:	b2c080e7          	jalr	-1236(ra) # 5b80 <unlink>
    205c:	bff1                	j	2038 <linkunlink+0x9c>
      link("cat", "x");
    205e:	85d6                	mv	a1,s5
    2060:	855e                	mv	a0,s7
    2062:	00004097          	auipc	ra,0x4
    2066:	b2e080e7          	jalr	-1234(ra) # 5b90 <link>
    206a:	b7f9                	j	2038 <linkunlink+0x9c>
  if (pid)
    206c:	020c0463          	beqz	s8,2094 <linkunlink+0xf8>
    wait(0);
    2070:	4501                	li	a0,0
    2072:	00004097          	auipc	ra,0x4
    2076:	ac6080e7          	jalr	-1338(ra) # 5b38 <wait>
}
    207a:	60e6                	ld	ra,88(sp)
    207c:	6446                	ld	s0,80(sp)
    207e:	64a6                	ld	s1,72(sp)
    2080:	6906                	ld	s2,64(sp)
    2082:	79e2                	ld	s3,56(sp)
    2084:	7a42                	ld	s4,48(sp)
    2086:	7aa2                	ld	s5,40(sp)
    2088:	7b02                	ld	s6,32(sp)
    208a:	6be2                	ld	s7,24(sp)
    208c:	6c42                	ld	s8,16(sp)
    208e:	6ca2                	ld	s9,8(sp)
    2090:	6125                	addi	sp,sp,96
    2092:	8082                	ret
    exit(0);
    2094:	4501                	li	a0,0
    2096:	00004097          	auipc	ra,0x4
    209a:	a9a080e7          	jalr	-1382(ra) # 5b30 <exit>

000000000000209e <forktest>:
{
    209e:	7179                	addi	sp,sp,-48
    20a0:	f406                	sd	ra,40(sp)
    20a2:	f022                	sd	s0,32(sp)
    20a4:	ec26                	sd	s1,24(sp)
    20a6:	e84a                	sd	s2,16(sp)
    20a8:	e44e                	sd	s3,8(sp)
    20aa:	1800                	addi	s0,sp,48
    20ac:	89aa                	mv	s3,a0
  for (n = 0; n < N; n++)
    20ae:	4481                	li	s1,0
    20b0:	3e800913          	li	s2,1000
    pid = fork();
    20b4:	00004097          	auipc	ra,0x4
    20b8:	a74080e7          	jalr	-1420(ra) # 5b28 <fork>
    if (pid < 0)
    20bc:	02054863          	bltz	a0,20ec <forktest+0x4e>
    if (pid == 0)
    20c0:	c115                	beqz	a0,20e4 <forktest+0x46>
  for (n = 0; n < N; n++)
    20c2:	2485                	addiw	s1,s1,1
    20c4:	ff2498e3          	bne	s1,s2,20b4 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    20c8:	85ce                	mv	a1,s3
    20ca:	00005517          	auipc	a0,0x5
    20ce:	afe50513          	addi	a0,a0,-1282 # 6bc8 <malloc+0xc42>
    20d2:	00004097          	auipc	ra,0x4
    20d6:	df6080e7          	jalr	-522(ra) # 5ec8 <printf>
    exit(1);
    20da:	4505                	li	a0,1
    20dc:	00004097          	auipc	ra,0x4
    20e0:	a54080e7          	jalr	-1452(ra) # 5b30 <exit>
      exit(0);
    20e4:	00004097          	auipc	ra,0x4
    20e8:	a4c080e7          	jalr	-1460(ra) # 5b30 <exit>
  if (n == 0)
    20ec:	cc9d                	beqz	s1,212a <forktest+0x8c>
  if (n == N)
    20ee:	3e800793          	li	a5,1000
    20f2:	fcf48be3          	beq	s1,a5,20c8 <forktest+0x2a>
  for (; n > 0; n--)
    20f6:	00905b63          	blez	s1,210c <forktest+0x6e>
    if (wait(0) < 0)
    20fa:	4501                	li	a0,0
    20fc:	00004097          	auipc	ra,0x4
    2100:	a3c080e7          	jalr	-1476(ra) # 5b38 <wait>
    2104:	04054163          	bltz	a0,2146 <forktest+0xa8>
  for (; n > 0; n--)
    2108:	34fd                	addiw	s1,s1,-1
    210a:	f8e5                	bnez	s1,20fa <forktest+0x5c>
  if (wait(0) != -1)
    210c:	4501                	li	a0,0
    210e:	00004097          	auipc	ra,0x4
    2112:	a2a080e7          	jalr	-1494(ra) # 5b38 <wait>
    2116:	57fd                	li	a5,-1
    2118:	04f51563          	bne	a0,a5,2162 <forktest+0xc4>
}
    211c:	70a2                	ld	ra,40(sp)
    211e:	7402                	ld	s0,32(sp)
    2120:	64e2                	ld	s1,24(sp)
    2122:	6942                	ld	s2,16(sp)
    2124:	69a2                	ld	s3,8(sp)
    2126:	6145                	addi	sp,sp,48
    2128:	8082                	ret
    printf("%s: no fork at all!\n", s);
    212a:	85ce                	mv	a1,s3
    212c:	00005517          	auipc	a0,0x5
    2130:	a8450513          	addi	a0,a0,-1404 # 6bb0 <malloc+0xc2a>
    2134:	00004097          	auipc	ra,0x4
    2138:	d94080e7          	jalr	-620(ra) # 5ec8 <printf>
    exit(1);
    213c:	4505                	li	a0,1
    213e:	00004097          	auipc	ra,0x4
    2142:	9f2080e7          	jalr	-1550(ra) # 5b30 <exit>
      printf("%s: wait stopped early\n", s);
    2146:	85ce                	mv	a1,s3
    2148:	00005517          	auipc	a0,0x5
    214c:	aa850513          	addi	a0,a0,-1368 # 6bf0 <malloc+0xc6a>
    2150:	00004097          	auipc	ra,0x4
    2154:	d78080e7          	jalr	-648(ra) # 5ec8 <printf>
      exit(1);
    2158:	4505                	li	a0,1
    215a:	00004097          	auipc	ra,0x4
    215e:	9d6080e7          	jalr	-1578(ra) # 5b30 <exit>
    printf("%s: wait got too many\n", s);
    2162:	85ce                	mv	a1,s3
    2164:	00005517          	auipc	a0,0x5
    2168:	aa450513          	addi	a0,a0,-1372 # 6c08 <malloc+0xc82>
    216c:	00004097          	auipc	ra,0x4
    2170:	d5c080e7          	jalr	-676(ra) # 5ec8 <printf>
    exit(1);
    2174:	4505                	li	a0,1
    2176:	00004097          	auipc	ra,0x4
    217a:	9ba080e7          	jalr	-1606(ra) # 5b30 <exit>

000000000000217e <kernmem>:
{
    217e:	715d                	addi	sp,sp,-80
    2180:	e486                	sd	ra,72(sp)
    2182:	e0a2                	sd	s0,64(sp)
    2184:	fc26                	sd	s1,56(sp)
    2186:	f84a                	sd	s2,48(sp)
    2188:	f44e                	sd	s3,40(sp)
    218a:	f052                	sd	s4,32(sp)
    218c:	ec56                	sd	s5,24(sp)
    218e:	0880                	addi	s0,sp,80
    2190:	8a2a                	mv	s4,a0
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    2192:	4485                	li	s1,1
    2194:	04fe                	slli	s1,s1,0x1f
    if (xstatus != -1) // did kernel kill child?
    2196:	5afd                	li	s5,-1
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    2198:	69b1                	lui	s3,0xc
    219a:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    219e:	1003d937          	lui	s2,0x1003d
    21a2:	090e                	slli	s2,s2,0x3
    21a4:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    21a8:	00004097          	auipc	ra,0x4
    21ac:	980080e7          	jalr	-1664(ra) # 5b28 <fork>
    if (pid < 0)
    21b0:	02054963          	bltz	a0,21e2 <kernmem+0x64>
    if (pid == 0)
    21b4:	c529                	beqz	a0,21fe <kernmem+0x80>
    wait(&xstatus);
    21b6:	fbc40513          	addi	a0,s0,-68
    21ba:	00004097          	auipc	ra,0x4
    21be:	97e080e7          	jalr	-1666(ra) # 5b38 <wait>
    if (xstatus != -1) // did kernel kill child?
    21c2:	fbc42783          	lw	a5,-68(s0)
    21c6:	05579d63          	bne	a5,s5,2220 <kernmem+0xa2>
  for (a = (char *)(KERNBASE); a < (char *)(KERNBASE + 2000000); a += 50000)
    21ca:	94ce                	add	s1,s1,s3
    21cc:	fd249ee3          	bne	s1,s2,21a8 <kernmem+0x2a>
}
    21d0:	60a6                	ld	ra,72(sp)
    21d2:	6406                	ld	s0,64(sp)
    21d4:	74e2                	ld	s1,56(sp)
    21d6:	7942                	ld	s2,48(sp)
    21d8:	79a2                	ld	s3,40(sp)
    21da:	7a02                	ld	s4,32(sp)
    21dc:	6ae2                	ld	s5,24(sp)
    21de:	6161                	addi	sp,sp,80
    21e0:	8082                	ret
      printf("%s: fork failed\n", s);
    21e2:	85d2                	mv	a1,s4
    21e4:	00004517          	auipc	a0,0x4
    21e8:	76c50513          	addi	a0,a0,1900 # 6950 <malloc+0x9ca>
    21ec:	00004097          	auipc	ra,0x4
    21f0:	cdc080e7          	jalr	-804(ra) # 5ec8 <printf>
      exit(1);
    21f4:	4505                	li	a0,1
    21f6:	00004097          	auipc	ra,0x4
    21fa:	93a080e7          	jalr	-1734(ra) # 5b30 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    21fe:	0004c683          	lbu	a3,0(s1)
    2202:	8626                	mv	a2,s1
    2204:	85d2                	mv	a1,s4
    2206:	00005517          	auipc	a0,0x5
    220a:	a1a50513          	addi	a0,a0,-1510 # 6c20 <malloc+0xc9a>
    220e:	00004097          	auipc	ra,0x4
    2212:	cba080e7          	jalr	-838(ra) # 5ec8 <printf>
      exit(1);
    2216:	4505                	li	a0,1
    2218:	00004097          	auipc	ra,0x4
    221c:	918080e7          	jalr	-1768(ra) # 5b30 <exit>
      exit(1);
    2220:	4505                	li	a0,1
    2222:	00004097          	auipc	ra,0x4
    2226:	90e080e7          	jalr	-1778(ra) # 5b30 <exit>

000000000000222a <MAXVAplus>:
{
    222a:	7179                	addi	sp,sp,-48
    222c:	f406                	sd	ra,40(sp)
    222e:	f022                	sd	s0,32(sp)
    2230:	ec26                	sd	s1,24(sp)
    2232:	e84a                	sd	s2,16(sp)
    2234:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    2236:	4785                	li	a5,1
    2238:	179a                	slli	a5,a5,0x26
    223a:	fcf43c23          	sd	a5,-40(s0)
  for (; a != 0; a <<= 1)
    223e:	fd843783          	ld	a5,-40(s0)
    2242:	cf85                	beqz	a5,227a <MAXVAplus+0x50>
    2244:	892a                	mv	s2,a0
    if (xstatus != -1) // did kernel kill child?
    2246:	54fd                	li	s1,-1
    pid = fork();
    2248:	00004097          	auipc	ra,0x4
    224c:	8e0080e7          	jalr	-1824(ra) # 5b28 <fork>
    if (pid < 0)
    2250:	02054b63          	bltz	a0,2286 <MAXVAplus+0x5c>
    if (pid == 0)
    2254:	c539                	beqz	a0,22a2 <MAXVAplus+0x78>
    wait(&xstatus);
    2256:	fd440513          	addi	a0,s0,-44
    225a:	00004097          	auipc	ra,0x4
    225e:	8de080e7          	jalr	-1826(ra) # 5b38 <wait>
    if (xstatus != -1) // did kernel kill child?
    2262:	fd442783          	lw	a5,-44(s0)
    2266:	06979463          	bne	a5,s1,22ce <MAXVAplus+0xa4>
  for (; a != 0; a <<= 1)
    226a:	fd843783          	ld	a5,-40(s0)
    226e:	0786                	slli	a5,a5,0x1
    2270:	fcf43c23          	sd	a5,-40(s0)
    2274:	fd843783          	ld	a5,-40(s0)
    2278:	fbe1                	bnez	a5,2248 <MAXVAplus+0x1e>
}
    227a:	70a2                	ld	ra,40(sp)
    227c:	7402                	ld	s0,32(sp)
    227e:	64e2                	ld	s1,24(sp)
    2280:	6942                	ld	s2,16(sp)
    2282:	6145                	addi	sp,sp,48
    2284:	8082                	ret
      printf("%s: fork failed\n", s);
    2286:	85ca                	mv	a1,s2
    2288:	00004517          	auipc	a0,0x4
    228c:	6c850513          	addi	a0,a0,1736 # 6950 <malloc+0x9ca>
    2290:	00004097          	auipc	ra,0x4
    2294:	c38080e7          	jalr	-968(ra) # 5ec8 <printf>
      exit(1);
    2298:	4505                	li	a0,1
    229a:	00004097          	auipc	ra,0x4
    229e:	896080e7          	jalr	-1898(ra) # 5b30 <exit>
      *(char *)a = 99;
    22a2:	fd843783          	ld	a5,-40(s0)
    22a6:	06300713          	li	a4,99
    22aa:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    22ae:	fd843603          	ld	a2,-40(s0)
    22b2:	85ca                	mv	a1,s2
    22b4:	00005517          	auipc	a0,0x5
    22b8:	98c50513          	addi	a0,a0,-1652 # 6c40 <malloc+0xcba>
    22bc:	00004097          	auipc	ra,0x4
    22c0:	c0c080e7          	jalr	-1012(ra) # 5ec8 <printf>
      exit(1);
    22c4:	4505                	li	a0,1
    22c6:	00004097          	auipc	ra,0x4
    22ca:	86a080e7          	jalr	-1942(ra) # 5b30 <exit>
      exit(1);
    22ce:	4505                	li	a0,1
    22d0:	00004097          	auipc	ra,0x4
    22d4:	860080e7          	jalr	-1952(ra) # 5b30 <exit>

00000000000022d8 <bigargtest>:
{
    22d8:	7179                	addi	sp,sp,-48
    22da:	f406                	sd	ra,40(sp)
    22dc:	f022                	sd	s0,32(sp)
    22de:	ec26                	sd	s1,24(sp)
    22e0:	1800                	addi	s0,sp,48
    22e2:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    22e4:	00005517          	auipc	a0,0x5
    22e8:	97450513          	addi	a0,a0,-1676 # 6c58 <malloc+0xcd2>
    22ec:	00004097          	auipc	ra,0x4
    22f0:	894080e7          	jalr	-1900(ra) # 5b80 <unlink>
  pid = fork();
    22f4:	00004097          	auipc	ra,0x4
    22f8:	834080e7          	jalr	-1996(ra) # 5b28 <fork>
  if (pid == 0)
    22fc:	c121                	beqz	a0,233c <bigargtest+0x64>
  else if (pid < 0)
    22fe:	0a054063          	bltz	a0,239e <bigargtest+0xc6>
  wait(&xstatus);
    2302:	fdc40513          	addi	a0,s0,-36
    2306:	00004097          	auipc	ra,0x4
    230a:	832080e7          	jalr	-1998(ra) # 5b38 <wait>
  if (xstatus != 0)
    230e:	fdc42503          	lw	a0,-36(s0)
    2312:	e545                	bnez	a0,23ba <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2314:	4581                	li	a1,0
    2316:	00005517          	auipc	a0,0x5
    231a:	94250513          	addi	a0,a0,-1726 # 6c58 <malloc+0xcd2>
    231e:	00004097          	auipc	ra,0x4
    2322:	852080e7          	jalr	-1966(ra) # 5b70 <open>
  if (fd < 0)
    2326:	08054e63          	bltz	a0,23c2 <bigargtest+0xea>
  close(fd);
    232a:	00004097          	auipc	ra,0x4
    232e:	82e080e7          	jalr	-2002(ra) # 5b58 <close>
}
    2332:	70a2                	ld	ra,40(sp)
    2334:	7402                	ld	s0,32(sp)
    2336:	64e2                	ld	s1,24(sp)
    2338:	6145                	addi	sp,sp,48
    233a:	8082                	ret
    233c:	00007797          	auipc	a5,0x7
    2340:	12478793          	addi	a5,a5,292 # 9460 <args.1>
    2344:	00007697          	auipc	a3,0x7
    2348:	21468693          	addi	a3,a3,532 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    234c:	00005717          	auipc	a4,0x5
    2350:	91c70713          	addi	a4,a4,-1764 # 6c68 <malloc+0xce2>
    2354:	e398                	sd	a4,0(a5)
    for (i = 0; i < MAXARG - 1; i++)
    2356:	07a1                	addi	a5,a5,8
    2358:	fed79ee3          	bne	a5,a3,2354 <bigargtest+0x7c>
    args[MAXARG - 1] = 0;
    235c:	00007597          	auipc	a1,0x7
    2360:	10458593          	addi	a1,a1,260 # 9460 <args.1>
    2364:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2368:	00004517          	auipc	a0,0x4
    236c:	d6050513          	addi	a0,a0,-672 # 60c8 <malloc+0x142>
    2370:	00003097          	auipc	ra,0x3
    2374:	7f8080e7          	jalr	2040(ra) # 5b68 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2378:	20000593          	li	a1,512
    237c:	00005517          	auipc	a0,0x5
    2380:	8dc50513          	addi	a0,a0,-1828 # 6c58 <malloc+0xcd2>
    2384:	00003097          	auipc	ra,0x3
    2388:	7ec080e7          	jalr	2028(ra) # 5b70 <open>
    close(fd);
    238c:	00003097          	auipc	ra,0x3
    2390:	7cc080e7          	jalr	1996(ra) # 5b58 <close>
    exit(0);
    2394:	4501                	li	a0,0
    2396:	00003097          	auipc	ra,0x3
    239a:	79a080e7          	jalr	1946(ra) # 5b30 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    239e:	85a6                	mv	a1,s1
    23a0:	00005517          	auipc	a0,0x5
    23a4:	9a850513          	addi	a0,a0,-1624 # 6d48 <malloc+0xdc2>
    23a8:	00004097          	auipc	ra,0x4
    23ac:	b20080e7          	jalr	-1248(ra) # 5ec8 <printf>
    exit(1);
    23b0:	4505                	li	a0,1
    23b2:	00003097          	auipc	ra,0x3
    23b6:	77e080e7          	jalr	1918(ra) # 5b30 <exit>
    exit(xstatus);
    23ba:	00003097          	auipc	ra,0x3
    23be:	776080e7          	jalr	1910(ra) # 5b30 <exit>
    printf("%s: bigarg test failed!\n", s);
    23c2:	85a6                	mv	a1,s1
    23c4:	00005517          	auipc	a0,0x5
    23c8:	9a450513          	addi	a0,a0,-1628 # 6d68 <malloc+0xde2>
    23cc:	00004097          	auipc	ra,0x4
    23d0:	afc080e7          	jalr	-1284(ra) # 5ec8 <printf>
    exit(1);
    23d4:	4505                	li	a0,1
    23d6:	00003097          	auipc	ra,0x3
    23da:	75a080e7          	jalr	1882(ra) # 5b30 <exit>

00000000000023de <stacktest>:
{
    23de:	7179                	addi	sp,sp,-48
    23e0:	f406                	sd	ra,40(sp)
    23e2:	f022                	sd	s0,32(sp)
    23e4:	ec26                	sd	s1,24(sp)
    23e6:	1800                	addi	s0,sp,48
    23e8:	84aa                	mv	s1,a0
  pid = fork();
    23ea:	00003097          	auipc	ra,0x3
    23ee:	73e080e7          	jalr	1854(ra) # 5b28 <fork>
  if (pid == 0)
    23f2:	c115                	beqz	a0,2416 <stacktest+0x38>
  else if (pid < 0)
    23f4:	04054463          	bltz	a0,243c <stacktest+0x5e>
  wait(&xstatus);
    23f8:	fdc40513          	addi	a0,s0,-36
    23fc:	00003097          	auipc	ra,0x3
    2400:	73c080e7          	jalr	1852(ra) # 5b38 <wait>
  if (xstatus == -1) // kernel killed child?
    2404:	fdc42503          	lw	a0,-36(s0)
    2408:	57fd                	li	a5,-1
    240a:	04f50763          	beq	a0,a5,2458 <stacktest+0x7a>
    exit(xstatus);
    240e:	00003097          	auipc	ra,0x3
    2412:	722080e7          	jalr	1826(ra) # 5b30 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2416:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    2418:	77fd                	lui	a5,0xfffff
    241a:	97ba                	add	a5,a5,a4
    241c:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    2420:	85a6                	mv	a1,s1
    2422:	00005517          	auipc	a0,0x5
    2426:	96650513          	addi	a0,a0,-1690 # 6d88 <malloc+0xe02>
    242a:	00004097          	auipc	ra,0x4
    242e:	a9e080e7          	jalr	-1378(ra) # 5ec8 <printf>
    exit(1);
    2432:	4505                	li	a0,1
    2434:	00003097          	auipc	ra,0x3
    2438:	6fc080e7          	jalr	1788(ra) # 5b30 <exit>
    printf("%s: fork failed\n", s);
    243c:	85a6                	mv	a1,s1
    243e:	00004517          	auipc	a0,0x4
    2442:	51250513          	addi	a0,a0,1298 # 6950 <malloc+0x9ca>
    2446:	00004097          	auipc	ra,0x4
    244a:	a82080e7          	jalr	-1406(ra) # 5ec8 <printf>
    exit(1);
    244e:	4505                	li	a0,1
    2450:	00003097          	auipc	ra,0x3
    2454:	6e0080e7          	jalr	1760(ra) # 5b30 <exit>
    exit(0);
    2458:	4501                	li	a0,0
    245a:	00003097          	auipc	ra,0x3
    245e:	6d6080e7          	jalr	1750(ra) # 5b30 <exit>

0000000000002462 <textwrite>:
{
    2462:	7179                	addi	sp,sp,-48
    2464:	f406                	sd	ra,40(sp)
    2466:	f022                	sd	s0,32(sp)
    2468:	ec26                	sd	s1,24(sp)
    246a:	1800                	addi	s0,sp,48
    246c:	84aa                	mv	s1,a0
  pid = fork();
    246e:	00003097          	auipc	ra,0x3
    2472:	6ba080e7          	jalr	1722(ra) # 5b28 <fork>
  if (pid == 0)
    2476:	c115                	beqz	a0,249a <textwrite+0x38>
  else if (pid < 0)
    2478:	02054963          	bltz	a0,24aa <textwrite+0x48>
  wait(&xstatus);
    247c:	fdc40513          	addi	a0,s0,-36
    2480:	00003097          	auipc	ra,0x3
    2484:	6b8080e7          	jalr	1720(ra) # 5b38 <wait>
  if (xstatus == -1) // kernel killed child?
    2488:	fdc42503          	lw	a0,-36(s0)
    248c:	57fd                	li	a5,-1
    248e:	02f50c63          	beq	a0,a5,24c6 <textwrite+0x64>
    exit(xstatus);
    2492:	00003097          	auipc	ra,0x3
    2496:	69e080e7          	jalr	1694(ra) # 5b30 <exit>
    *addr = 10;
    249a:	47a9                	li	a5,10
    249c:	00f02023          	sw	a5,0(zero) # 0 <killstatus>
    exit(1);
    24a0:	4505                	li	a0,1
    24a2:	00003097          	auipc	ra,0x3
    24a6:	68e080e7          	jalr	1678(ra) # 5b30 <exit>
    printf("%s: fork failed\n", s);
    24aa:	85a6                	mv	a1,s1
    24ac:	00004517          	auipc	a0,0x4
    24b0:	4a450513          	addi	a0,a0,1188 # 6950 <malloc+0x9ca>
    24b4:	00004097          	auipc	ra,0x4
    24b8:	a14080e7          	jalr	-1516(ra) # 5ec8 <printf>
    exit(1);
    24bc:	4505                	li	a0,1
    24be:	00003097          	auipc	ra,0x3
    24c2:	672080e7          	jalr	1650(ra) # 5b30 <exit>
    exit(0);
    24c6:	4501                	li	a0,0
    24c8:	00003097          	auipc	ra,0x3
    24cc:	668080e7          	jalr	1640(ra) # 5b30 <exit>

00000000000024d0 <manywrites>:
{
    24d0:	711d                	addi	sp,sp,-96
    24d2:	ec86                	sd	ra,88(sp)
    24d4:	e8a2                	sd	s0,80(sp)
    24d6:	e4a6                	sd	s1,72(sp)
    24d8:	e0ca                	sd	s2,64(sp)
    24da:	fc4e                	sd	s3,56(sp)
    24dc:	f852                	sd	s4,48(sp)
    24de:	f456                	sd	s5,40(sp)
    24e0:	f05a                	sd	s6,32(sp)
    24e2:	ec5e                	sd	s7,24(sp)
    24e4:	1080                	addi	s0,sp,96
    24e6:	8aaa                	mv	s5,a0
  for (int ci = 0; ci < nchildren; ci++)
    24e8:	4981                	li	s3,0
    24ea:	4911                	li	s2,4
    int pid = fork();
    24ec:	00003097          	auipc	ra,0x3
    24f0:	63c080e7          	jalr	1596(ra) # 5b28 <fork>
    24f4:	84aa                	mv	s1,a0
    if (pid < 0)
    24f6:	02054963          	bltz	a0,2528 <manywrites+0x58>
    if (pid == 0)
    24fa:	c521                	beqz	a0,2542 <manywrites+0x72>
  for (int ci = 0; ci < nchildren; ci++)
    24fc:	2985                	addiw	s3,s3,1
    24fe:	ff2997e3          	bne	s3,s2,24ec <manywrites+0x1c>
    2502:	4491                	li	s1,4
    int st = 0;
    2504:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    2508:	fa840513          	addi	a0,s0,-88
    250c:	00003097          	auipc	ra,0x3
    2510:	62c080e7          	jalr	1580(ra) # 5b38 <wait>
    if (st != 0)
    2514:	fa842503          	lw	a0,-88(s0)
    2518:	ed6d                	bnez	a0,2612 <manywrites+0x142>
  for (int ci = 0; ci < nchildren; ci++)
    251a:	34fd                	addiw	s1,s1,-1
    251c:	f4e5                	bnez	s1,2504 <manywrites+0x34>
  exit(0);
    251e:	4501                	li	a0,0
    2520:	00003097          	auipc	ra,0x3
    2524:	610080e7          	jalr	1552(ra) # 5b30 <exit>
      printf("fork failed\n");
    2528:	00005517          	auipc	a0,0x5
    252c:	83050513          	addi	a0,a0,-2000 # 6d58 <malloc+0xdd2>
    2530:	00004097          	auipc	ra,0x4
    2534:	998080e7          	jalr	-1640(ra) # 5ec8 <printf>
      exit(1);
    2538:	4505                	li	a0,1
    253a:	00003097          	auipc	ra,0x3
    253e:	5f6080e7          	jalr	1526(ra) # 5b30 <exit>
      name[0] = 'b';
    2542:	06200793          	li	a5,98
    2546:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    254a:	0619879b          	addiw	a5,s3,97
    254e:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    2552:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    2556:	fa840513          	addi	a0,s0,-88
    255a:	00003097          	auipc	ra,0x3
    255e:	626080e7          	jalr	1574(ra) # 5b80 <unlink>
    2562:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    2564:	0000ab17          	auipc	s6,0xa
    2568:	714b0b13          	addi	s6,s6,1812 # cc78 <buf>
        for (int i = 0; i < ci + 1; i++)
    256c:	8a26                	mv	s4,s1
    256e:	0209ce63          	bltz	s3,25aa <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    2572:	20200593          	li	a1,514
    2576:	fa840513          	addi	a0,s0,-88
    257a:	00003097          	auipc	ra,0x3
    257e:	5f6080e7          	jalr	1526(ra) # 5b70 <open>
    2582:	892a                	mv	s2,a0
          if (fd < 0)
    2584:	04054763          	bltz	a0,25d2 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    2588:	660d                	lui	a2,0x3
    258a:	85da                	mv	a1,s6
    258c:	00003097          	auipc	ra,0x3
    2590:	5c4080e7          	jalr	1476(ra) # 5b50 <write>
          if (cc != sz)
    2594:	678d                	lui	a5,0x3
    2596:	04f51e63          	bne	a0,a5,25f2 <manywrites+0x122>
          close(fd);
    259a:	854a                	mv	a0,s2
    259c:	00003097          	auipc	ra,0x3
    25a0:	5bc080e7          	jalr	1468(ra) # 5b58 <close>
        for (int i = 0; i < ci + 1; i++)
    25a4:	2a05                	addiw	s4,s4,1
    25a6:	fd49d6e3          	bge	s3,s4,2572 <manywrites+0xa2>
        unlink(name);
    25aa:	fa840513          	addi	a0,s0,-88
    25ae:	00003097          	auipc	ra,0x3
    25b2:	5d2080e7          	jalr	1490(ra) # 5b80 <unlink>
      for (int iters = 0; iters < howmany; iters++)
    25b6:	3bfd                	addiw	s7,s7,-1
    25b8:	fa0b9ae3          	bnez	s7,256c <manywrites+0x9c>
      unlink(name);
    25bc:	fa840513          	addi	a0,s0,-88
    25c0:	00003097          	auipc	ra,0x3
    25c4:	5c0080e7          	jalr	1472(ra) # 5b80 <unlink>
      exit(0);
    25c8:	4501                	li	a0,0
    25ca:	00003097          	auipc	ra,0x3
    25ce:	566080e7          	jalr	1382(ra) # 5b30 <exit>
            printf("%s: cannot create %s\n", s, name);
    25d2:	fa840613          	addi	a2,s0,-88
    25d6:	85d6                	mv	a1,s5
    25d8:	00004517          	auipc	a0,0x4
    25dc:	7d850513          	addi	a0,a0,2008 # 6db0 <malloc+0xe2a>
    25e0:	00004097          	auipc	ra,0x4
    25e4:	8e8080e7          	jalr	-1816(ra) # 5ec8 <printf>
            exit(1);
    25e8:	4505                	li	a0,1
    25ea:	00003097          	auipc	ra,0x3
    25ee:	546080e7          	jalr	1350(ra) # 5b30 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    25f2:	86aa                	mv	a3,a0
    25f4:	660d                	lui	a2,0x3
    25f6:	85d6                	mv	a1,s5
    25f8:	00004517          	auipc	a0,0x4
    25fc:	ba050513          	addi	a0,a0,-1120 # 6198 <malloc+0x212>
    2600:	00004097          	auipc	ra,0x4
    2604:	8c8080e7          	jalr	-1848(ra) # 5ec8 <printf>
            exit(1);
    2608:	4505                	li	a0,1
    260a:	00003097          	auipc	ra,0x3
    260e:	526080e7          	jalr	1318(ra) # 5b30 <exit>
      exit(st);
    2612:	00003097          	auipc	ra,0x3
    2616:	51e080e7          	jalr	1310(ra) # 5b30 <exit>

000000000000261a <copyinstr3>:
{
    261a:	7179                	addi	sp,sp,-48
    261c:	f406                	sd	ra,40(sp)
    261e:	f022                	sd	s0,32(sp)
    2620:	ec26                	sd	s1,24(sp)
    2622:	1800                	addi	s0,sp,48
  sbrk(8192);
    2624:	6509                	lui	a0,0x2
    2626:	00003097          	auipc	ra,0x3
    262a:	592080e7          	jalr	1426(ra) # 5bb8 <sbrk>
  uint64 top = (uint64)sbrk(0);
    262e:	4501                	li	a0,0
    2630:	00003097          	auipc	ra,0x3
    2634:	588080e7          	jalr	1416(ra) # 5bb8 <sbrk>
  if ((top % PGSIZE) != 0)
    2638:	03451793          	slli	a5,a0,0x34
    263c:	e3c9                	bnez	a5,26be <copyinstr3+0xa4>
  top = (uint64)sbrk(0);
    263e:	4501                	li	a0,0
    2640:	00003097          	auipc	ra,0x3
    2644:	578080e7          	jalr	1400(ra) # 5bb8 <sbrk>
  if (top % PGSIZE)
    2648:	03451793          	slli	a5,a0,0x34
    264c:	e3d9                	bnez	a5,26d2 <copyinstr3+0xb8>
  char *b = (char *)(top - 1);
    264e:	fff50493          	addi	s1,a0,-1 # 1fff <linkunlink+0x63>
  *b = 'x';
    2652:	07800793          	li	a5,120
    2656:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    265a:	8526                	mv	a0,s1
    265c:	00003097          	auipc	ra,0x3
    2660:	524080e7          	jalr	1316(ra) # 5b80 <unlink>
  if (ret != -1)
    2664:	57fd                	li	a5,-1
    2666:	08f51363          	bne	a0,a5,26ec <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    266a:	20100593          	li	a1,513
    266e:	8526                	mv	a0,s1
    2670:	00003097          	auipc	ra,0x3
    2674:	500080e7          	jalr	1280(ra) # 5b70 <open>
  if (fd != -1)
    2678:	57fd                	li	a5,-1
    267a:	08f51863          	bne	a0,a5,270a <copyinstr3+0xf0>
  ret = link(b, b);
    267e:	85a6                	mv	a1,s1
    2680:	8526                	mv	a0,s1
    2682:	00003097          	auipc	ra,0x3
    2686:	50e080e7          	jalr	1294(ra) # 5b90 <link>
  if (ret != -1)
    268a:	57fd                	li	a5,-1
    268c:	08f51e63          	bne	a0,a5,2728 <copyinstr3+0x10e>
  char *args[] = {"xx", 0};
    2690:	00005797          	auipc	a5,0x5
    2694:	41878793          	addi	a5,a5,1048 # 7aa8 <malloc+0x1b22>
    2698:	fcf43823          	sd	a5,-48(s0)
    269c:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    26a0:	fd040593          	addi	a1,s0,-48
    26a4:	8526                	mv	a0,s1
    26a6:	00003097          	auipc	ra,0x3
    26aa:	4c2080e7          	jalr	1218(ra) # 5b68 <exec>
  if (ret != -1)
    26ae:	57fd                	li	a5,-1
    26b0:	08f51c63          	bne	a0,a5,2748 <copyinstr3+0x12e>
}
    26b4:	70a2                	ld	ra,40(sp)
    26b6:	7402                	ld	s0,32(sp)
    26b8:	64e2                	ld	s1,24(sp)
    26ba:	6145                	addi	sp,sp,48
    26bc:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    26be:	0347d513          	srli	a0,a5,0x34
    26c2:	6785                	lui	a5,0x1
    26c4:	40a7853b          	subw	a0,a5,a0
    26c8:	00003097          	auipc	ra,0x3
    26cc:	4f0080e7          	jalr	1264(ra) # 5bb8 <sbrk>
    26d0:	b7bd                	j	263e <copyinstr3+0x24>
    printf("oops\n");
    26d2:	00004517          	auipc	a0,0x4
    26d6:	6f650513          	addi	a0,a0,1782 # 6dc8 <malloc+0xe42>
    26da:	00003097          	auipc	ra,0x3
    26de:	7ee080e7          	jalr	2030(ra) # 5ec8 <printf>
    exit(1);
    26e2:	4505                	li	a0,1
    26e4:	00003097          	auipc	ra,0x3
    26e8:	44c080e7          	jalr	1100(ra) # 5b30 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    26ec:	862a                	mv	a2,a0
    26ee:	85a6                	mv	a1,s1
    26f0:	00004517          	auipc	a0,0x4
    26f4:	18050513          	addi	a0,a0,384 # 6870 <malloc+0x8ea>
    26f8:	00003097          	auipc	ra,0x3
    26fc:	7d0080e7          	jalr	2000(ra) # 5ec8 <printf>
    exit(1);
    2700:	4505                	li	a0,1
    2702:	00003097          	auipc	ra,0x3
    2706:	42e080e7          	jalr	1070(ra) # 5b30 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    270a:	862a                	mv	a2,a0
    270c:	85a6                	mv	a1,s1
    270e:	00004517          	auipc	a0,0x4
    2712:	18250513          	addi	a0,a0,386 # 6890 <malloc+0x90a>
    2716:	00003097          	auipc	ra,0x3
    271a:	7b2080e7          	jalr	1970(ra) # 5ec8 <printf>
    exit(1);
    271e:	4505                	li	a0,1
    2720:	00003097          	auipc	ra,0x3
    2724:	410080e7          	jalr	1040(ra) # 5b30 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2728:	86aa                	mv	a3,a0
    272a:	8626                	mv	a2,s1
    272c:	85a6                	mv	a1,s1
    272e:	00004517          	auipc	a0,0x4
    2732:	18250513          	addi	a0,a0,386 # 68b0 <malloc+0x92a>
    2736:	00003097          	auipc	ra,0x3
    273a:	792080e7          	jalr	1938(ra) # 5ec8 <printf>
    exit(1);
    273e:	4505                	li	a0,1
    2740:	00003097          	auipc	ra,0x3
    2744:	3f0080e7          	jalr	1008(ra) # 5b30 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2748:	567d                	li	a2,-1
    274a:	85a6                	mv	a1,s1
    274c:	00004517          	auipc	a0,0x4
    2750:	18c50513          	addi	a0,a0,396 # 68d8 <malloc+0x952>
    2754:	00003097          	auipc	ra,0x3
    2758:	774080e7          	jalr	1908(ra) # 5ec8 <printf>
    exit(1);
    275c:	4505                	li	a0,1
    275e:	00003097          	auipc	ra,0x3
    2762:	3d2080e7          	jalr	978(ra) # 5b30 <exit>

0000000000002766 <rwsbrk>:
{
    2766:	1101                	addi	sp,sp,-32
    2768:	ec06                	sd	ra,24(sp)
    276a:	e822                	sd	s0,16(sp)
    276c:	e426                	sd	s1,8(sp)
    276e:	e04a                	sd	s2,0(sp)
    2770:	1000                	addi	s0,sp,32
  uint64 a = (uint64)sbrk(8192);
    2772:	6509                	lui	a0,0x2
    2774:	00003097          	auipc	ra,0x3
    2778:	444080e7          	jalr	1092(ra) # 5bb8 <sbrk>
  if (a == 0xffffffffffffffffLL)
    277c:	57fd                	li	a5,-1
    277e:	06f50363          	beq	a0,a5,27e4 <rwsbrk+0x7e>
    2782:	84aa                	mv	s1,a0
  if ((uint64)sbrk(-8192) == 0xffffffffffffffffLL)
    2784:	7579                	lui	a0,0xffffe
    2786:	00003097          	auipc	ra,0x3
    278a:	432080e7          	jalr	1074(ra) # 5bb8 <sbrk>
    278e:	57fd                	li	a5,-1
    2790:	06f50763          	beq	a0,a5,27fe <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE | O_WRONLY);
    2794:	20100593          	li	a1,513
    2798:	00004517          	auipc	a0,0x4
    279c:	67050513          	addi	a0,a0,1648 # 6e08 <malloc+0xe82>
    27a0:	00003097          	auipc	ra,0x3
    27a4:	3d0080e7          	jalr	976(ra) # 5b70 <open>
    27a8:	892a                	mv	s2,a0
  if (fd < 0)
    27aa:	06054763          	bltz	a0,2818 <rwsbrk+0xb2>
  n = write(fd, (void *)(a + 4096), 1024);
    27ae:	6505                	lui	a0,0x1
    27b0:	94aa                	add	s1,s1,a0
    27b2:	40000613          	li	a2,1024
    27b6:	85a6                	mv	a1,s1
    27b8:	854a                	mv	a0,s2
    27ba:	00003097          	auipc	ra,0x3
    27be:	396080e7          	jalr	918(ra) # 5b50 <write>
    27c2:	862a                	mv	a2,a0
  if (n >= 0)
    27c4:	06054763          	bltz	a0,2832 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a + 4096, n);
    27c8:	85a6                	mv	a1,s1
    27ca:	00004517          	auipc	a0,0x4
    27ce:	65e50513          	addi	a0,a0,1630 # 6e28 <malloc+0xea2>
    27d2:	00003097          	auipc	ra,0x3
    27d6:	6f6080e7          	jalr	1782(ra) # 5ec8 <printf>
    exit(1);
    27da:	4505                	li	a0,1
    27dc:	00003097          	auipc	ra,0x3
    27e0:	354080e7          	jalr	852(ra) # 5b30 <exit>
    printf("sbrk(rwsbrk) failed\n");
    27e4:	00004517          	auipc	a0,0x4
    27e8:	5ec50513          	addi	a0,a0,1516 # 6dd0 <malloc+0xe4a>
    27ec:	00003097          	auipc	ra,0x3
    27f0:	6dc080e7          	jalr	1756(ra) # 5ec8 <printf>
    exit(1);
    27f4:	4505                	li	a0,1
    27f6:	00003097          	auipc	ra,0x3
    27fa:	33a080e7          	jalr	826(ra) # 5b30 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    27fe:	00004517          	auipc	a0,0x4
    2802:	5ea50513          	addi	a0,a0,1514 # 6de8 <malloc+0xe62>
    2806:	00003097          	auipc	ra,0x3
    280a:	6c2080e7          	jalr	1730(ra) # 5ec8 <printf>
    exit(1);
    280e:	4505                	li	a0,1
    2810:	00003097          	auipc	ra,0x3
    2814:	320080e7          	jalr	800(ra) # 5b30 <exit>
    printf("open(rwsbrk) failed\n");
    2818:	00004517          	auipc	a0,0x4
    281c:	5f850513          	addi	a0,a0,1528 # 6e10 <malloc+0xe8a>
    2820:	00003097          	auipc	ra,0x3
    2824:	6a8080e7          	jalr	1704(ra) # 5ec8 <printf>
    exit(1);
    2828:	4505                	li	a0,1
    282a:	00003097          	auipc	ra,0x3
    282e:	306080e7          	jalr	774(ra) # 5b30 <exit>
  close(fd);
    2832:	854a                	mv	a0,s2
    2834:	00003097          	auipc	ra,0x3
    2838:	324080e7          	jalr	804(ra) # 5b58 <close>
  unlink("rwsbrk");
    283c:	00004517          	auipc	a0,0x4
    2840:	5cc50513          	addi	a0,a0,1484 # 6e08 <malloc+0xe82>
    2844:	00003097          	auipc	ra,0x3
    2848:	33c080e7          	jalr	828(ra) # 5b80 <unlink>
  fd = open("README", O_RDONLY);
    284c:	4581                	li	a1,0
    284e:	00004517          	auipc	a0,0x4
    2852:	a5250513          	addi	a0,a0,-1454 # 62a0 <malloc+0x31a>
    2856:	00003097          	auipc	ra,0x3
    285a:	31a080e7          	jalr	794(ra) # 5b70 <open>
    285e:	892a                	mv	s2,a0
  if (fd < 0)
    2860:	02054963          	bltz	a0,2892 <rwsbrk+0x12c>
  n = read(fd, (void *)(a + 4096), 10);
    2864:	4629                	li	a2,10
    2866:	85a6                	mv	a1,s1
    2868:	00003097          	auipc	ra,0x3
    286c:	2e0080e7          	jalr	736(ra) # 5b48 <read>
    2870:	862a                	mv	a2,a0
  if (n >= 0)
    2872:	02054d63          	bltz	a0,28ac <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a + 4096, n);
    2876:	85a6                	mv	a1,s1
    2878:	00004517          	auipc	a0,0x4
    287c:	5e050513          	addi	a0,a0,1504 # 6e58 <malloc+0xed2>
    2880:	00003097          	auipc	ra,0x3
    2884:	648080e7          	jalr	1608(ra) # 5ec8 <printf>
    exit(1);
    2888:	4505                	li	a0,1
    288a:	00003097          	auipc	ra,0x3
    288e:	2a6080e7          	jalr	678(ra) # 5b30 <exit>
    printf("open(rwsbrk) failed\n");
    2892:	00004517          	auipc	a0,0x4
    2896:	57e50513          	addi	a0,a0,1406 # 6e10 <malloc+0xe8a>
    289a:	00003097          	auipc	ra,0x3
    289e:	62e080e7          	jalr	1582(ra) # 5ec8 <printf>
    exit(1);
    28a2:	4505                	li	a0,1
    28a4:	00003097          	auipc	ra,0x3
    28a8:	28c080e7          	jalr	652(ra) # 5b30 <exit>
  close(fd);
    28ac:	854a                	mv	a0,s2
    28ae:	00003097          	auipc	ra,0x3
    28b2:	2aa080e7          	jalr	682(ra) # 5b58 <close>
  exit(0);
    28b6:	4501                	li	a0,0
    28b8:	00003097          	auipc	ra,0x3
    28bc:	278080e7          	jalr	632(ra) # 5b30 <exit>

00000000000028c0 <sbrkbasic>:
{
    28c0:	7139                	addi	sp,sp,-64
    28c2:	fc06                	sd	ra,56(sp)
    28c4:	f822                	sd	s0,48(sp)
    28c6:	f426                	sd	s1,40(sp)
    28c8:	f04a                	sd	s2,32(sp)
    28ca:	ec4e                	sd	s3,24(sp)
    28cc:	e852                	sd	s4,16(sp)
    28ce:	0080                	addi	s0,sp,64
    28d0:	8a2a                	mv	s4,a0
  pid = fork();
    28d2:	00003097          	auipc	ra,0x3
    28d6:	256080e7          	jalr	598(ra) # 5b28 <fork>
  if (pid < 0)
    28da:	02054c63          	bltz	a0,2912 <sbrkbasic+0x52>
  if (pid == 0)
    28de:	ed21                	bnez	a0,2936 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    28e0:	40000537          	lui	a0,0x40000
    28e4:	00003097          	auipc	ra,0x3
    28e8:	2d4080e7          	jalr	724(ra) # 5bb8 <sbrk>
    if (a == (char *)0xffffffffffffffffL)
    28ec:	57fd                	li	a5,-1
    28ee:	02f50f63          	beq	a0,a5,292c <sbrkbasic+0x6c>
    for (b = a; b < a + TOOMUCH; b += 4096)
    28f2:	400007b7          	lui	a5,0x40000
    28f6:	97aa                	add	a5,a5,a0
      *b = 99;
    28f8:	06300693          	li	a3,99
    for (b = a; b < a + TOOMUCH; b += 4096)
    28fc:	6705                	lui	a4,0x1
      *b = 99;
    28fe:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for (b = a; b < a + TOOMUCH; b += 4096)
    2902:	953a                	add	a0,a0,a4
    2904:	fef51de3          	bne	a0,a5,28fe <sbrkbasic+0x3e>
    exit(1);
    2908:	4505                	li	a0,1
    290a:	00003097          	auipc	ra,0x3
    290e:	226080e7          	jalr	550(ra) # 5b30 <exit>
    printf("fork failed in sbrkbasic\n");
    2912:	00004517          	auipc	a0,0x4
    2916:	56e50513          	addi	a0,a0,1390 # 6e80 <malloc+0xefa>
    291a:	00003097          	auipc	ra,0x3
    291e:	5ae080e7          	jalr	1454(ra) # 5ec8 <printf>
    exit(1);
    2922:	4505                	li	a0,1
    2924:	00003097          	auipc	ra,0x3
    2928:	20c080e7          	jalr	524(ra) # 5b30 <exit>
      exit(0);
    292c:	4501                	li	a0,0
    292e:	00003097          	auipc	ra,0x3
    2932:	202080e7          	jalr	514(ra) # 5b30 <exit>
  wait(&xstatus);
    2936:	fcc40513          	addi	a0,s0,-52
    293a:	00003097          	auipc	ra,0x3
    293e:	1fe080e7          	jalr	510(ra) # 5b38 <wait>
  if (xstatus == 1)
    2942:	fcc42703          	lw	a4,-52(s0)
    2946:	4785                	li	a5,1
    2948:	00f70d63          	beq	a4,a5,2962 <sbrkbasic+0xa2>
  a = sbrk(0);
    294c:	4501                	li	a0,0
    294e:	00003097          	auipc	ra,0x3
    2952:	26a080e7          	jalr	618(ra) # 5bb8 <sbrk>
    2956:	84aa                	mv	s1,a0
  for (i = 0; i < 5000; i++)
    2958:	4901                	li	s2,0
    295a:	6985                	lui	s3,0x1
    295c:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x30>
    2960:	a005                	j	2980 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    2962:	85d2                	mv	a1,s4
    2964:	00004517          	auipc	a0,0x4
    2968:	53c50513          	addi	a0,a0,1340 # 6ea0 <malloc+0xf1a>
    296c:	00003097          	auipc	ra,0x3
    2970:	55c080e7          	jalr	1372(ra) # 5ec8 <printf>
    exit(1);
    2974:	4505                	li	a0,1
    2976:	00003097          	auipc	ra,0x3
    297a:	1ba080e7          	jalr	442(ra) # 5b30 <exit>
    a = b + 1;
    297e:	84be                	mv	s1,a5
    b = sbrk(1);
    2980:	4505                	li	a0,1
    2982:	00003097          	auipc	ra,0x3
    2986:	236080e7          	jalr	566(ra) # 5bb8 <sbrk>
    if (b != a)
    298a:	04951c63          	bne	a0,s1,29e2 <sbrkbasic+0x122>
    *b = 1;
    298e:	4785                	li	a5,1
    2990:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2994:	00148793          	addi	a5,s1,1
  for (i = 0; i < 5000; i++)
    2998:	2905                	addiw	s2,s2,1
    299a:	ff3912e3          	bne	s2,s3,297e <sbrkbasic+0xbe>
  pid = fork();
    299e:	00003097          	auipc	ra,0x3
    29a2:	18a080e7          	jalr	394(ra) # 5b28 <fork>
    29a6:	892a                	mv	s2,a0
  if (pid < 0)
    29a8:	04054e63          	bltz	a0,2a04 <sbrkbasic+0x144>
  c = sbrk(1);
    29ac:	4505                	li	a0,1
    29ae:	00003097          	auipc	ra,0x3
    29b2:	20a080e7          	jalr	522(ra) # 5bb8 <sbrk>
  c = sbrk(1);
    29b6:	4505                	li	a0,1
    29b8:	00003097          	auipc	ra,0x3
    29bc:	200080e7          	jalr	512(ra) # 5bb8 <sbrk>
  if (c != a + 1)
    29c0:	0489                	addi	s1,s1,2
    29c2:	04a48f63          	beq	s1,a0,2a20 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    29c6:	85d2                	mv	a1,s4
    29c8:	00004517          	auipc	a0,0x4
    29cc:	53850513          	addi	a0,a0,1336 # 6f00 <malloc+0xf7a>
    29d0:	00003097          	auipc	ra,0x3
    29d4:	4f8080e7          	jalr	1272(ra) # 5ec8 <printf>
    exit(1);
    29d8:	4505                	li	a0,1
    29da:	00003097          	auipc	ra,0x3
    29de:	156080e7          	jalr	342(ra) # 5b30 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    29e2:	872a                	mv	a4,a0
    29e4:	86a6                	mv	a3,s1
    29e6:	864a                	mv	a2,s2
    29e8:	85d2                	mv	a1,s4
    29ea:	00004517          	auipc	a0,0x4
    29ee:	4d650513          	addi	a0,a0,1238 # 6ec0 <malloc+0xf3a>
    29f2:	00003097          	auipc	ra,0x3
    29f6:	4d6080e7          	jalr	1238(ra) # 5ec8 <printf>
      exit(1);
    29fa:	4505                	li	a0,1
    29fc:	00003097          	auipc	ra,0x3
    2a00:	134080e7          	jalr	308(ra) # 5b30 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2a04:	85d2                	mv	a1,s4
    2a06:	00004517          	auipc	a0,0x4
    2a0a:	4da50513          	addi	a0,a0,1242 # 6ee0 <malloc+0xf5a>
    2a0e:	00003097          	auipc	ra,0x3
    2a12:	4ba080e7          	jalr	1210(ra) # 5ec8 <printf>
    exit(1);
    2a16:	4505                	li	a0,1
    2a18:	00003097          	auipc	ra,0x3
    2a1c:	118080e7          	jalr	280(ra) # 5b30 <exit>
  if (pid == 0)
    2a20:	00091763          	bnez	s2,2a2e <sbrkbasic+0x16e>
    exit(0);
    2a24:	4501                	li	a0,0
    2a26:	00003097          	auipc	ra,0x3
    2a2a:	10a080e7          	jalr	266(ra) # 5b30 <exit>
  wait(&xstatus);
    2a2e:	fcc40513          	addi	a0,s0,-52
    2a32:	00003097          	auipc	ra,0x3
    2a36:	106080e7          	jalr	262(ra) # 5b38 <wait>
  exit(xstatus);
    2a3a:	fcc42503          	lw	a0,-52(s0)
    2a3e:	00003097          	auipc	ra,0x3
    2a42:	0f2080e7          	jalr	242(ra) # 5b30 <exit>

0000000000002a46 <sbrkmuch>:
{
    2a46:	7179                	addi	sp,sp,-48
    2a48:	f406                	sd	ra,40(sp)
    2a4a:	f022                	sd	s0,32(sp)
    2a4c:	ec26                	sd	s1,24(sp)
    2a4e:	e84a                	sd	s2,16(sp)
    2a50:	e44e                	sd	s3,8(sp)
    2a52:	e052                	sd	s4,0(sp)
    2a54:	1800                	addi	s0,sp,48
    2a56:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2a58:	4501                	li	a0,0
    2a5a:	00003097          	auipc	ra,0x3
    2a5e:	15e080e7          	jalr	350(ra) # 5bb8 <sbrk>
    2a62:	892a                	mv	s2,a0
  a = sbrk(0);
    2a64:	4501                	li	a0,0
    2a66:	00003097          	auipc	ra,0x3
    2a6a:	152080e7          	jalr	338(ra) # 5bb8 <sbrk>
    2a6e:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2a70:	06400537          	lui	a0,0x6400
    2a74:	9d05                	subw	a0,a0,s1
    2a76:	00003097          	auipc	ra,0x3
    2a7a:	142080e7          	jalr	322(ra) # 5bb8 <sbrk>
  if (p != a)
    2a7e:	0ca49863          	bne	s1,a0,2b4e <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2a82:	4501                	li	a0,0
    2a84:	00003097          	auipc	ra,0x3
    2a88:	134080e7          	jalr	308(ra) # 5bb8 <sbrk>
    2a8c:	87aa                	mv	a5,a0
  for (char *pp = a; pp < eee; pp += 4096)
    2a8e:	00a4f963          	bgeu	s1,a0,2aa0 <sbrkmuch+0x5a>
    *pp = 1;
    2a92:	4685                	li	a3,1
  for (char *pp = a; pp < eee; pp += 4096)
    2a94:	6705                	lui	a4,0x1
    *pp = 1;
    2a96:	00d48023          	sb	a3,0(s1)
  for (char *pp = a; pp < eee; pp += 4096)
    2a9a:	94ba                	add	s1,s1,a4
    2a9c:	fef4ede3          	bltu	s1,a5,2a96 <sbrkmuch+0x50>
  *lastaddr = 99;
    2aa0:	064007b7          	lui	a5,0x6400
    2aa4:	06300713          	li	a4,99
    2aa8:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2aac:	4501                	li	a0,0
    2aae:	00003097          	auipc	ra,0x3
    2ab2:	10a080e7          	jalr	266(ra) # 5bb8 <sbrk>
    2ab6:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2ab8:	757d                	lui	a0,0xfffff
    2aba:	00003097          	auipc	ra,0x3
    2abe:	0fe080e7          	jalr	254(ra) # 5bb8 <sbrk>
  if (c == (char *)0xffffffffffffffffL)
    2ac2:	57fd                	li	a5,-1
    2ac4:	0af50363          	beq	a0,a5,2b6a <sbrkmuch+0x124>
  c = sbrk(0);
    2ac8:	4501                	li	a0,0
    2aca:	00003097          	auipc	ra,0x3
    2ace:	0ee080e7          	jalr	238(ra) # 5bb8 <sbrk>
  if (c != a - PGSIZE)
    2ad2:	77fd                	lui	a5,0xfffff
    2ad4:	97a6                	add	a5,a5,s1
    2ad6:	0af51863          	bne	a0,a5,2b86 <sbrkmuch+0x140>
  a = sbrk(0);
    2ada:	4501                	li	a0,0
    2adc:	00003097          	auipc	ra,0x3
    2ae0:	0dc080e7          	jalr	220(ra) # 5bb8 <sbrk>
    2ae4:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2ae6:	6505                	lui	a0,0x1
    2ae8:	00003097          	auipc	ra,0x3
    2aec:	0d0080e7          	jalr	208(ra) # 5bb8 <sbrk>
    2af0:	8a2a                	mv	s4,a0
  if (c != a || sbrk(0) != a + PGSIZE)
    2af2:	0aa49a63          	bne	s1,a0,2ba6 <sbrkmuch+0x160>
    2af6:	4501                	li	a0,0
    2af8:	00003097          	auipc	ra,0x3
    2afc:	0c0080e7          	jalr	192(ra) # 5bb8 <sbrk>
    2b00:	6785                	lui	a5,0x1
    2b02:	97a6                	add	a5,a5,s1
    2b04:	0af51163          	bne	a0,a5,2ba6 <sbrkmuch+0x160>
  if (*lastaddr == 99)
    2b08:	064007b7          	lui	a5,0x6400
    2b0c:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2b10:	06300793          	li	a5,99
    2b14:	0af70963          	beq	a4,a5,2bc6 <sbrkmuch+0x180>
  a = sbrk(0);
    2b18:	4501                	li	a0,0
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	09e080e7          	jalr	158(ra) # 5bb8 <sbrk>
    2b22:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2b24:	4501                	li	a0,0
    2b26:	00003097          	auipc	ra,0x3
    2b2a:	092080e7          	jalr	146(ra) # 5bb8 <sbrk>
    2b2e:	40a9053b          	subw	a0,s2,a0
    2b32:	00003097          	auipc	ra,0x3
    2b36:	086080e7          	jalr	134(ra) # 5bb8 <sbrk>
  if (c != a)
    2b3a:	0aa49463          	bne	s1,a0,2be2 <sbrkmuch+0x19c>
}
    2b3e:	70a2                	ld	ra,40(sp)
    2b40:	7402                	ld	s0,32(sp)
    2b42:	64e2                	ld	s1,24(sp)
    2b44:	6942                	ld	s2,16(sp)
    2b46:	69a2                	ld	s3,8(sp)
    2b48:	6a02                	ld	s4,0(sp)
    2b4a:	6145                	addi	sp,sp,48
    2b4c:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2b4e:	85ce                	mv	a1,s3
    2b50:	00004517          	auipc	a0,0x4
    2b54:	3d050513          	addi	a0,a0,976 # 6f20 <malloc+0xf9a>
    2b58:	00003097          	auipc	ra,0x3
    2b5c:	370080e7          	jalr	880(ra) # 5ec8 <printf>
    exit(1);
    2b60:	4505                	li	a0,1
    2b62:	00003097          	auipc	ra,0x3
    2b66:	fce080e7          	jalr	-50(ra) # 5b30 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2b6a:	85ce                	mv	a1,s3
    2b6c:	00004517          	auipc	a0,0x4
    2b70:	3fc50513          	addi	a0,a0,1020 # 6f68 <malloc+0xfe2>
    2b74:	00003097          	auipc	ra,0x3
    2b78:	354080e7          	jalr	852(ra) # 5ec8 <printf>
    exit(1);
    2b7c:	4505                	li	a0,1
    2b7e:	00003097          	auipc	ra,0x3
    2b82:	fb2080e7          	jalr	-78(ra) # 5b30 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2b86:	86aa                	mv	a3,a0
    2b88:	8626                	mv	a2,s1
    2b8a:	85ce                	mv	a1,s3
    2b8c:	00004517          	auipc	a0,0x4
    2b90:	3fc50513          	addi	a0,a0,1020 # 6f88 <malloc+0x1002>
    2b94:	00003097          	auipc	ra,0x3
    2b98:	334080e7          	jalr	820(ra) # 5ec8 <printf>
    exit(1);
    2b9c:	4505                	li	a0,1
    2b9e:	00003097          	auipc	ra,0x3
    2ba2:	f92080e7          	jalr	-110(ra) # 5b30 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2ba6:	86d2                	mv	a3,s4
    2ba8:	8626                	mv	a2,s1
    2baa:	85ce                	mv	a1,s3
    2bac:	00004517          	auipc	a0,0x4
    2bb0:	41c50513          	addi	a0,a0,1052 # 6fc8 <malloc+0x1042>
    2bb4:	00003097          	auipc	ra,0x3
    2bb8:	314080e7          	jalr	788(ra) # 5ec8 <printf>
    exit(1);
    2bbc:	4505                	li	a0,1
    2bbe:	00003097          	auipc	ra,0x3
    2bc2:	f72080e7          	jalr	-142(ra) # 5b30 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2bc6:	85ce                	mv	a1,s3
    2bc8:	00004517          	auipc	a0,0x4
    2bcc:	43050513          	addi	a0,a0,1072 # 6ff8 <malloc+0x1072>
    2bd0:	00003097          	auipc	ra,0x3
    2bd4:	2f8080e7          	jalr	760(ra) # 5ec8 <printf>
    exit(1);
    2bd8:	4505                	li	a0,1
    2bda:	00003097          	auipc	ra,0x3
    2bde:	f56080e7          	jalr	-170(ra) # 5b30 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2be2:	86aa                	mv	a3,a0
    2be4:	8626                	mv	a2,s1
    2be6:	85ce                	mv	a1,s3
    2be8:	00004517          	auipc	a0,0x4
    2bec:	44850513          	addi	a0,a0,1096 # 7030 <malloc+0x10aa>
    2bf0:	00003097          	auipc	ra,0x3
    2bf4:	2d8080e7          	jalr	728(ra) # 5ec8 <printf>
    exit(1);
    2bf8:	4505                	li	a0,1
    2bfa:	00003097          	auipc	ra,0x3
    2bfe:	f36080e7          	jalr	-202(ra) # 5b30 <exit>

0000000000002c02 <sbrkarg>:
{
    2c02:	7179                	addi	sp,sp,-48
    2c04:	f406                	sd	ra,40(sp)
    2c06:	f022                	sd	s0,32(sp)
    2c08:	ec26                	sd	s1,24(sp)
    2c0a:	e84a                	sd	s2,16(sp)
    2c0c:	e44e                	sd	s3,8(sp)
    2c0e:	1800                	addi	s0,sp,48
    2c10:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2c12:	6505                	lui	a0,0x1
    2c14:	00003097          	auipc	ra,0x3
    2c18:	fa4080e7          	jalr	-92(ra) # 5bb8 <sbrk>
    2c1c:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE | O_WRONLY);
    2c1e:	20100593          	li	a1,513
    2c22:	00004517          	auipc	a0,0x4
    2c26:	43650513          	addi	a0,a0,1078 # 7058 <malloc+0x10d2>
    2c2a:	00003097          	auipc	ra,0x3
    2c2e:	f46080e7          	jalr	-186(ra) # 5b70 <open>
    2c32:	84aa                	mv	s1,a0
  unlink("sbrk");
    2c34:	00004517          	auipc	a0,0x4
    2c38:	42450513          	addi	a0,a0,1060 # 7058 <malloc+0x10d2>
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	f44080e7          	jalr	-188(ra) # 5b80 <unlink>
  if (fd < 0)
    2c44:	0404c163          	bltz	s1,2c86 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0)
    2c48:	6605                	lui	a2,0x1
    2c4a:	85ca                	mv	a1,s2
    2c4c:	8526                	mv	a0,s1
    2c4e:	00003097          	auipc	ra,0x3
    2c52:	f02080e7          	jalr	-254(ra) # 5b50 <write>
    2c56:	04054663          	bltz	a0,2ca2 <sbrkarg+0xa0>
  close(fd);
    2c5a:	8526                	mv	a0,s1
    2c5c:	00003097          	auipc	ra,0x3
    2c60:	efc080e7          	jalr	-260(ra) # 5b58 <close>
  a = sbrk(PGSIZE);
    2c64:	6505                	lui	a0,0x1
    2c66:	00003097          	auipc	ra,0x3
    2c6a:	f52080e7          	jalr	-174(ra) # 5bb8 <sbrk>
  if (pipe((int *)a) != 0)
    2c6e:	00003097          	auipc	ra,0x3
    2c72:	ed2080e7          	jalr	-302(ra) # 5b40 <pipe>
    2c76:	e521                	bnez	a0,2cbe <sbrkarg+0xbc>
}
    2c78:	70a2                	ld	ra,40(sp)
    2c7a:	7402                	ld	s0,32(sp)
    2c7c:	64e2                	ld	s1,24(sp)
    2c7e:	6942                	ld	s2,16(sp)
    2c80:	69a2                	ld	s3,8(sp)
    2c82:	6145                	addi	sp,sp,48
    2c84:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2c86:	85ce                	mv	a1,s3
    2c88:	00004517          	auipc	a0,0x4
    2c8c:	3d850513          	addi	a0,a0,984 # 7060 <malloc+0x10da>
    2c90:	00003097          	auipc	ra,0x3
    2c94:	238080e7          	jalr	568(ra) # 5ec8 <printf>
    exit(1);
    2c98:	4505                	li	a0,1
    2c9a:	00003097          	auipc	ra,0x3
    2c9e:	e96080e7          	jalr	-362(ra) # 5b30 <exit>
    printf("%s: write sbrk failed\n", s);
    2ca2:	85ce                	mv	a1,s3
    2ca4:	00004517          	auipc	a0,0x4
    2ca8:	3d450513          	addi	a0,a0,980 # 7078 <malloc+0x10f2>
    2cac:	00003097          	auipc	ra,0x3
    2cb0:	21c080e7          	jalr	540(ra) # 5ec8 <printf>
    exit(1);
    2cb4:	4505                	li	a0,1
    2cb6:	00003097          	auipc	ra,0x3
    2cba:	e7a080e7          	jalr	-390(ra) # 5b30 <exit>
    printf("%s: pipe() failed\n", s);
    2cbe:	85ce                	mv	a1,s3
    2cc0:	00004517          	auipc	a0,0x4
    2cc4:	d9850513          	addi	a0,a0,-616 # 6a58 <malloc+0xad2>
    2cc8:	00003097          	auipc	ra,0x3
    2ccc:	200080e7          	jalr	512(ra) # 5ec8 <printf>
    exit(1);
    2cd0:	4505                	li	a0,1
    2cd2:	00003097          	auipc	ra,0x3
    2cd6:	e5e080e7          	jalr	-418(ra) # 5b30 <exit>

0000000000002cda <argptest>:
{
    2cda:	1101                	addi	sp,sp,-32
    2cdc:	ec06                	sd	ra,24(sp)
    2cde:	e822                	sd	s0,16(sp)
    2ce0:	e426                	sd	s1,8(sp)
    2ce2:	e04a                	sd	s2,0(sp)
    2ce4:	1000                	addi	s0,sp,32
    2ce6:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2ce8:	4581                	li	a1,0
    2cea:	00004517          	auipc	a0,0x4
    2cee:	3a650513          	addi	a0,a0,934 # 7090 <malloc+0x110a>
    2cf2:	00003097          	auipc	ra,0x3
    2cf6:	e7e080e7          	jalr	-386(ra) # 5b70 <open>
  if (fd < 0)
    2cfa:	02054b63          	bltz	a0,2d30 <argptest+0x56>
    2cfe:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2d00:	4501                	li	a0,0
    2d02:	00003097          	auipc	ra,0x3
    2d06:	eb6080e7          	jalr	-330(ra) # 5bb8 <sbrk>
    2d0a:	567d                	li	a2,-1
    2d0c:	fff50593          	addi	a1,a0,-1
    2d10:	8526                	mv	a0,s1
    2d12:	00003097          	auipc	ra,0x3
    2d16:	e36080e7          	jalr	-458(ra) # 5b48 <read>
  close(fd);
    2d1a:	8526                	mv	a0,s1
    2d1c:	00003097          	auipc	ra,0x3
    2d20:	e3c080e7          	jalr	-452(ra) # 5b58 <close>
}
    2d24:	60e2                	ld	ra,24(sp)
    2d26:	6442                	ld	s0,16(sp)
    2d28:	64a2                	ld	s1,8(sp)
    2d2a:	6902                	ld	s2,0(sp)
    2d2c:	6105                	addi	sp,sp,32
    2d2e:	8082                	ret
    printf("%s: open failed\n", s);
    2d30:	85ca                	mv	a1,s2
    2d32:	00004517          	auipc	a0,0x4
    2d36:	c3650513          	addi	a0,a0,-970 # 6968 <malloc+0x9e2>
    2d3a:	00003097          	auipc	ra,0x3
    2d3e:	18e080e7          	jalr	398(ra) # 5ec8 <printf>
    exit(1);
    2d42:	4505                	li	a0,1
    2d44:	00003097          	auipc	ra,0x3
    2d48:	dec080e7          	jalr	-532(ra) # 5b30 <exit>

0000000000002d4c <sbrkbugs>:
{
    2d4c:	1141                	addi	sp,sp,-16
    2d4e:	e406                	sd	ra,8(sp)
    2d50:	e022                	sd	s0,0(sp)
    2d52:	0800                	addi	s0,sp,16
  int pid = fork();
    2d54:	00003097          	auipc	ra,0x3
    2d58:	dd4080e7          	jalr	-556(ra) # 5b28 <fork>
  if (pid < 0)
    2d5c:	02054263          	bltz	a0,2d80 <sbrkbugs+0x34>
  if (pid == 0)
    2d60:	ed0d                	bnez	a0,2d9a <sbrkbugs+0x4e>
    int sz = (uint64)sbrk(0);
    2d62:	00003097          	auipc	ra,0x3
    2d66:	e56080e7          	jalr	-426(ra) # 5bb8 <sbrk>
    sbrk(-sz);
    2d6a:	40a0053b          	negw	a0,a0
    2d6e:	00003097          	auipc	ra,0x3
    2d72:	e4a080e7          	jalr	-438(ra) # 5bb8 <sbrk>
    exit(0);
    2d76:	4501                	li	a0,0
    2d78:	00003097          	auipc	ra,0x3
    2d7c:	db8080e7          	jalr	-584(ra) # 5b30 <exit>
    printf("fork failed\n");
    2d80:	00004517          	auipc	a0,0x4
    2d84:	fd850513          	addi	a0,a0,-40 # 6d58 <malloc+0xdd2>
    2d88:	00003097          	auipc	ra,0x3
    2d8c:	140080e7          	jalr	320(ra) # 5ec8 <printf>
    exit(1);
    2d90:	4505                	li	a0,1
    2d92:	00003097          	auipc	ra,0x3
    2d96:	d9e080e7          	jalr	-610(ra) # 5b30 <exit>
  wait(0);
    2d9a:	4501                	li	a0,0
    2d9c:	00003097          	auipc	ra,0x3
    2da0:	d9c080e7          	jalr	-612(ra) # 5b38 <wait>
  pid = fork();
    2da4:	00003097          	auipc	ra,0x3
    2da8:	d84080e7          	jalr	-636(ra) # 5b28 <fork>
  if (pid < 0)
    2dac:	02054563          	bltz	a0,2dd6 <sbrkbugs+0x8a>
  if (pid == 0)
    2db0:	e121                	bnez	a0,2df0 <sbrkbugs+0xa4>
    int sz = (uint64)sbrk(0);
    2db2:	00003097          	auipc	ra,0x3
    2db6:	e06080e7          	jalr	-506(ra) # 5bb8 <sbrk>
    sbrk(-(sz - 3500));
    2dba:	6785                	lui	a5,0x1
    2dbc:	dac7879b          	addiw	a5,a5,-596
    2dc0:	40a7853b          	subw	a0,a5,a0
    2dc4:	00003097          	auipc	ra,0x3
    2dc8:	df4080e7          	jalr	-524(ra) # 5bb8 <sbrk>
    exit(0);
    2dcc:	4501                	li	a0,0
    2dce:	00003097          	auipc	ra,0x3
    2dd2:	d62080e7          	jalr	-670(ra) # 5b30 <exit>
    printf("fork failed\n");
    2dd6:	00004517          	auipc	a0,0x4
    2dda:	f8250513          	addi	a0,a0,-126 # 6d58 <malloc+0xdd2>
    2dde:	00003097          	auipc	ra,0x3
    2de2:	0ea080e7          	jalr	234(ra) # 5ec8 <printf>
    exit(1);
    2de6:	4505                	li	a0,1
    2de8:	00003097          	auipc	ra,0x3
    2dec:	d48080e7          	jalr	-696(ra) # 5b30 <exit>
  wait(0);
    2df0:	4501                	li	a0,0
    2df2:	00003097          	auipc	ra,0x3
    2df6:	d46080e7          	jalr	-698(ra) # 5b38 <wait>
  pid = fork();
    2dfa:	00003097          	auipc	ra,0x3
    2dfe:	d2e080e7          	jalr	-722(ra) # 5b28 <fork>
  if (pid < 0)
    2e02:	02054a63          	bltz	a0,2e36 <sbrkbugs+0xea>
  if (pid == 0)
    2e06:	e529                	bnez	a0,2e50 <sbrkbugs+0x104>
    sbrk((10 * 4096 + 2048) - (uint64)sbrk(0));
    2e08:	00003097          	auipc	ra,0x3
    2e0c:	db0080e7          	jalr	-592(ra) # 5bb8 <sbrk>
    2e10:	67ad                	lui	a5,0xb
    2e12:	8007879b          	addiw	a5,a5,-2048
    2e16:	40a7853b          	subw	a0,a5,a0
    2e1a:	00003097          	auipc	ra,0x3
    2e1e:	d9e080e7          	jalr	-610(ra) # 5bb8 <sbrk>
    sbrk(-10);
    2e22:	5559                	li	a0,-10
    2e24:	00003097          	auipc	ra,0x3
    2e28:	d94080e7          	jalr	-620(ra) # 5bb8 <sbrk>
    exit(0);
    2e2c:	4501                	li	a0,0
    2e2e:	00003097          	auipc	ra,0x3
    2e32:	d02080e7          	jalr	-766(ra) # 5b30 <exit>
    printf("fork failed\n");
    2e36:	00004517          	auipc	a0,0x4
    2e3a:	f2250513          	addi	a0,a0,-222 # 6d58 <malloc+0xdd2>
    2e3e:	00003097          	auipc	ra,0x3
    2e42:	08a080e7          	jalr	138(ra) # 5ec8 <printf>
    exit(1);
    2e46:	4505                	li	a0,1
    2e48:	00003097          	auipc	ra,0x3
    2e4c:	ce8080e7          	jalr	-792(ra) # 5b30 <exit>
  wait(0);
    2e50:	4501                	li	a0,0
    2e52:	00003097          	auipc	ra,0x3
    2e56:	ce6080e7          	jalr	-794(ra) # 5b38 <wait>
  exit(0);
    2e5a:	4501                	li	a0,0
    2e5c:	00003097          	auipc	ra,0x3
    2e60:	cd4080e7          	jalr	-812(ra) # 5b30 <exit>

0000000000002e64 <sbrklast>:
{
    2e64:	7179                	addi	sp,sp,-48
    2e66:	f406                	sd	ra,40(sp)
    2e68:	f022                	sd	s0,32(sp)
    2e6a:	ec26                	sd	s1,24(sp)
    2e6c:	e84a                	sd	s2,16(sp)
    2e6e:	e44e                	sd	s3,8(sp)
    2e70:	e052                	sd	s4,0(sp)
    2e72:	1800                	addi	s0,sp,48
  uint64 top = (uint64)sbrk(0);
    2e74:	4501                	li	a0,0
    2e76:	00003097          	auipc	ra,0x3
    2e7a:	d42080e7          	jalr	-702(ra) # 5bb8 <sbrk>
  if ((top % 4096) != 0)
    2e7e:	03451793          	slli	a5,a0,0x34
    2e82:	ebd9                	bnez	a5,2f18 <sbrklast+0xb4>
  sbrk(4096);
    2e84:	6505                	lui	a0,0x1
    2e86:	00003097          	auipc	ra,0x3
    2e8a:	d32080e7          	jalr	-718(ra) # 5bb8 <sbrk>
  sbrk(10);
    2e8e:	4529                	li	a0,10
    2e90:	00003097          	auipc	ra,0x3
    2e94:	d28080e7          	jalr	-728(ra) # 5bb8 <sbrk>
  sbrk(-20);
    2e98:	5531                	li	a0,-20
    2e9a:	00003097          	auipc	ra,0x3
    2e9e:	d1e080e7          	jalr	-738(ra) # 5bb8 <sbrk>
  top = (uint64)sbrk(0);
    2ea2:	4501                	li	a0,0
    2ea4:	00003097          	auipc	ra,0x3
    2ea8:	d14080e7          	jalr	-748(ra) # 5bb8 <sbrk>
    2eac:	84aa                	mv	s1,a0
  char *p = (char *)(top - 64);
    2eae:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xbe>
  p[0] = 'x';
    2eb2:	07800a13          	li	s4,120
    2eb6:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2eba:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR | O_CREATE);
    2ebe:	20200593          	li	a1,514
    2ec2:	854a                	mv	a0,s2
    2ec4:	00003097          	auipc	ra,0x3
    2ec8:	cac080e7          	jalr	-852(ra) # 5b70 <open>
    2ecc:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2ece:	4605                	li	a2,1
    2ed0:	85ca                	mv	a1,s2
    2ed2:	00003097          	auipc	ra,0x3
    2ed6:	c7e080e7          	jalr	-898(ra) # 5b50 <write>
  close(fd);
    2eda:	854e                	mv	a0,s3
    2edc:	00003097          	auipc	ra,0x3
    2ee0:	c7c080e7          	jalr	-900(ra) # 5b58 <close>
  fd = open(p, O_RDWR);
    2ee4:	4589                	li	a1,2
    2ee6:	854a                	mv	a0,s2
    2ee8:	00003097          	auipc	ra,0x3
    2eec:	c88080e7          	jalr	-888(ra) # 5b70 <open>
  p[0] = '\0';
    2ef0:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2ef4:	4605                	li	a2,1
    2ef6:	85ca                	mv	a1,s2
    2ef8:	00003097          	auipc	ra,0x3
    2efc:	c50080e7          	jalr	-944(ra) # 5b48 <read>
  if (p[0] != 'x')
    2f00:	fc04c783          	lbu	a5,-64(s1)
    2f04:	03479463          	bne	a5,s4,2f2c <sbrklast+0xc8>
}
    2f08:	70a2                	ld	ra,40(sp)
    2f0a:	7402                	ld	s0,32(sp)
    2f0c:	64e2                	ld	s1,24(sp)
    2f0e:	6942                	ld	s2,16(sp)
    2f10:	69a2                	ld	s3,8(sp)
    2f12:	6a02                	ld	s4,0(sp)
    2f14:	6145                	addi	sp,sp,48
    2f16:	8082                	ret
    sbrk(4096 - (top % 4096));
    2f18:	0347d513          	srli	a0,a5,0x34
    2f1c:	6785                	lui	a5,0x1
    2f1e:	40a7853b          	subw	a0,a5,a0
    2f22:	00003097          	auipc	ra,0x3
    2f26:	c96080e7          	jalr	-874(ra) # 5bb8 <sbrk>
    2f2a:	bfa9                	j	2e84 <sbrklast+0x20>
    exit(1);
    2f2c:	4505                	li	a0,1
    2f2e:	00003097          	auipc	ra,0x3
    2f32:	c02080e7          	jalr	-1022(ra) # 5b30 <exit>

0000000000002f36 <sbrk8000>:
{
    2f36:	1141                	addi	sp,sp,-16
    2f38:	e406                	sd	ra,8(sp)
    2f3a:	e022                	sd	s0,0(sp)
    2f3c:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2f3e:	80000537          	lui	a0,0x80000
    2f42:	0511                	addi	a0,a0,4
    2f44:	00003097          	auipc	ra,0x3
    2f48:	c74080e7          	jalr	-908(ra) # 5bb8 <sbrk>
  volatile char *top = sbrk(0);
    2f4c:	4501                	li	a0,0
    2f4e:	00003097          	auipc	ra,0x3
    2f52:	c6a080e7          	jalr	-918(ra) # 5bb8 <sbrk>
  *(top - 1) = *(top - 1) + 1;
    2f56:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <base+0xffffffff7fff0387>
    2f5a:	0785                	addi	a5,a5,1
    2f5c:	0ff7f793          	andi	a5,a5,255
    2f60:	fef50fa3          	sb	a5,-1(a0)
}
    2f64:	60a2                	ld	ra,8(sp)
    2f66:	6402                	ld	s0,0(sp)
    2f68:	0141                	addi	sp,sp,16
    2f6a:	8082                	ret

0000000000002f6c <execout>:
{
    2f6c:	715d                	addi	sp,sp,-80
    2f6e:	e486                	sd	ra,72(sp)
    2f70:	e0a2                	sd	s0,64(sp)
    2f72:	fc26                	sd	s1,56(sp)
    2f74:	f84a                	sd	s2,48(sp)
    2f76:	f44e                	sd	s3,40(sp)
    2f78:	f052                	sd	s4,32(sp)
    2f7a:	0880                	addi	s0,sp,80
  for (int avail = 0; avail < 15; avail++)
    2f7c:	4901                	li	s2,0
    2f7e:	49bd                	li	s3,15
    int pid = fork();
    2f80:	00003097          	auipc	ra,0x3
    2f84:	ba8080e7          	jalr	-1112(ra) # 5b28 <fork>
    2f88:	84aa                	mv	s1,a0
    if (pid < 0)
    2f8a:	02054063          	bltz	a0,2faa <execout+0x3e>
    else if (pid == 0)
    2f8e:	c91d                	beqz	a0,2fc4 <execout+0x58>
      wait((int *)0);
    2f90:	4501                	li	a0,0
    2f92:	00003097          	auipc	ra,0x3
    2f96:	ba6080e7          	jalr	-1114(ra) # 5b38 <wait>
  for (int avail = 0; avail < 15; avail++)
    2f9a:	2905                	addiw	s2,s2,1
    2f9c:	ff3912e3          	bne	s2,s3,2f80 <execout+0x14>
  exit(0);
    2fa0:	4501                	li	a0,0
    2fa2:	00003097          	auipc	ra,0x3
    2fa6:	b8e080e7          	jalr	-1138(ra) # 5b30 <exit>
      printf("fork failed\n");
    2faa:	00004517          	auipc	a0,0x4
    2fae:	dae50513          	addi	a0,a0,-594 # 6d58 <malloc+0xdd2>
    2fb2:	00003097          	auipc	ra,0x3
    2fb6:	f16080e7          	jalr	-234(ra) # 5ec8 <printf>
      exit(1);
    2fba:	4505                	li	a0,1
    2fbc:	00003097          	auipc	ra,0x3
    2fc0:	b74080e7          	jalr	-1164(ra) # 5b30 <exit>
        if (a == 0xffffffffffffffffLL)
    2fc4:	59fd                	li	s3,-1
        *(char *)(a + 4096 - 1) = 1;
    2fc6:	4a05                	li	s4,1
        uint64 a = (uint64)sbrk(4096);
    2fc8:	6505                	lui	a0,0x1
    2fca:	00003097          	auipc	ra,0x3
    2fce:	bee080e7          	jalr	-1042(ra) # 5bb8 <sbrk>
        if (a == 0xffffffffffffffffLL)
    2fd2:	01350763          	beq	a0,s3,2fe0 <execout+0x74>
        *(char *)(a + 4096 - 1) = 1;
    2fd6:	6785                	lui	a5,0x1
    2fd8:	953e                	add	a0,a0,a5
    2fda:	ff450fa3          	sb	s4,-1(a0) # fff <linktest+0xfd>
      {
    2fde:	b7ed                	j	2fc8 <execout+0x5c>
      for (int i = 0; i < avail; i++)
    2fe0:	01205a63          	blez	s2,2ff4 <execout+0x88>
        sbrk(-4096);
    2fe4:	757d                	lui	a0,0xfffff
    2fe6:	00003097          	auipc	ra,0x3
    2fea:	bd2080e7          	jalr	-1070(ra) # 5bb8 <sbrk>
      for (int i = 0; i < avail; i++)
    2fee:	2485                	addiw	s1,s1,1
    2ff0:	ff249ae3          	bne	s1,s2,2fe4 <execout+0x78>
      close(1);
    2ff4:	4505                	li	a0,1
    2ff6:	00003097          	auipc	ra,0x3
    2ffa:	b62080e7          	jalr	-1182(ra) # 5b58 <close>
      char *args[] = {"echo", "x", 0};
    2ffe:	00003517          	auipc	a0,0x3
    3002:	0ca50513          	addi	a0,a0,202 # 60c8 <malloc+0x142>
    3006:	faa43c23          	sd	a0,-72(s0)
    300a:	00003797          	auipc	a5,0x3
    300e:	12e78793          	addi	a5,a5,302 # 6138 <malloc+0x1b2>
    3012:	fcf43023          	sd	a5,-64(s0)
    3016:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    301a:	fb840593          	addi	a1,s0,-72
    301e:	00003097          	auipc	ra,0x3
    3022:	b4a080e7          	jalr	-1206(ra) # 5b68 <exec>
      exit(0);
    3026:	4501                	li	a0,0
    3028:	00003097          	auipc	ra,0x3
    302c:	b08080e7          	jalr	-1272(ra) # 5b30 <exit>

0000000000003030 <fourteen>:
{
    3030:	1101                	addi	sp,sp,-32
    3032:	ec06                	sd	ra,24(sp)
    3034:	e822                	sd	s0,16(sp)
    3036:	e426                	sd	s1,8(sp)
    3038:	1000                	addi	s0,sp,32
    303a:	84aa                	mv	s1,a0
  if (mkdir("12345678901234") != 0)
    303c:	00004517          	auipc	a0,0x4
    3040:	22c50513          	addi	a0,a0,556 # 7268 <malloc+0x12e2>
    3044:	00003097          	auipc	ra,0x3
    3048:	b54080e7          	jalr	-1196(ra) # 5b98 <mkdir>
    304c:	e165                	bnez	a0,312c <fourteen+0xfc>
  if (mkdir("12345678901234/123456789012345") != 0)
    304e:	00004517          	auipc	a0,0x4
    3052:	07250513          	addi	a0,a0,114 # 70c0 <malloc+0x113a>
    3056:	00003097          	auipc	ra,0x3
    305a:	b42080e7          	jalr	-1214(ra) # 5b98 <mkdir>
    305e:	e56d                	bnez	a0,3148 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3060:	20000593          	li	a1,512
    3064:	00004517          	auipc	a0,0x4
    3068:	0b450513          	addi	a0,a0,180 # 7118 <malloc+0x1192>
    306c:	00003097          	auipc	ra,0x3
    3070:	b04080e7          	jalr	-1276(ra) # 5b70 <open>
  if (fd < 0)
    3074:	0e054863          	bltz	a0,3164 <fourteen+0x134>
  close(fd);
    3078:	00003097          	auipc	ra,0x3
    307c:	ae0080e7          	jalr	-1312(ra) # 5b58 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3080:	4581                	li	a1,0
    3082:	00004517          	auipc	a0,0x4
    3086:	10e50513          	addi	a0,a0,270 # 7190 <malloc+0x120a>
    308a:	00003097          	auipc	ra,0x3
    308e:	ae6080e7          	jalr	-1306(ra) # 5b70 <open>
  if (fd < 0)
    3092:	0e054763          	bltz	a0,3180 <fourteen+0x150>
  close(fd);
    3096:	00003097          	auipc	ra,0x3
    309a:	ac2080e7          	jalr	-1342(ra) # 5b58 <close>
  if (mkdir("12345678901234/12345678901234") == 0)
    309e:	00004517          	auipc	a0,0x4
    30a2:	16250513          	addi	a0,a0,354 # 7200 <malloc+0x127a>
    30a6:	00003097          	auipc	ra,0x3
    30aa:	af2080e7          	jalr	-1294(ra) # 5b98 <mkdir>
    30ae:	c57d                	beqz	a0,319c <fourteen+0x16c>
  if (mkdir("123456789012345/12345678901234") == 0)
    30b0:	00004517          	auipc	a0,0x4
    30b4:	1a850513          	addi	a0,a0,424 # 7258 <malloc+0x12d2>
    30b8:	00003097          	auipc	ra,0x3
    30bc:	ae0080e7          	jalr	-1312(ra) # 5b98 <mkdir>
    30c0:	cd65                	beqz	a0,31b8 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    30c2:	00004517          	auipc	a0,0x4
    30c6:	19650513          	addi	a0,a0,406 # 7258 <malloc+0x12d2>
    30ca:	00003097          	auipc	ra,0x3
    30ce:	ab6080e7          	jalr	-1354(ra) # 5b80 <unlink>
  unlink("12345678901234/12345678901234");
    30d2:	00004517          	auipc	a0,0x4
    30d6:	12e50513          	addi	a0,a0,302 # 7200 <malloc+0x127a>
    30da:	00003097          	auipc	ra,0x3
    30de:	aa6080e7          	jalr	-1370(ra) # 5b80 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    30e2:	00004517          	auipc	a0,0x4
    30e6:	0ae50513          	addi	a0,a0,174 # 7190 <malloc+0x120a>
    30ea:	00003097          	auipc	ra,0x3
    30ee:	a96080e7          	jalr	-1386(ra) # 5b80 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    30f2:	00004517          	auipc	a0,0x4
    30f6:	02650513          	addi	a0,a0,38 # 7118 <malloc+0x1192>
    30fa:	00003097          	auipc	ra,0x3
    30fe:	a86080e7          	jalr	-1402(ra) # 5b80 <unlink>
  unlink("12345678901234/123456789012345");
    3102:	00004517          	auipc	a0,0x4
    3106:	fbe50513          	addi	a0,a0,-66 # 70c0 <malloc+0x113a>
    310a:	00003097          	auipc	ra,0x3
    310e:	a76080e7          	jalr	-1418(ra) # 5b80 <unlink>
  unlink("12345678901234");
    3112:	00004517          	auipc	a0,0x4
    3116:	15650513          	addi	a0,a0,342 # 7268 <malloc+0x12e2>
    311a:	00003097          	auipc	ra,0x3
    311e:	a66080e7          	jalr	-1434(ra) # 5b80 <unlink>
}
    3122:	60e2                	ld	ra,24(sp)
    3124:	6442                	ld	s0,16(sp)
    3126:	64a2                	ld	s1,8(sp)
    3128:	6105                	addi	sp,sp,32
    312a:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    312c:	85a6                	mv	a1,s1
    312e:	00004517          	auipc	a0,0x4
    3132:	f6a50513          	addi	a0,a0,-150 # 7098 <malloc+0x1112>
    3136:	00003097          	auipc	ra,0x3
    313a:	d92080e7          	jalr	-622(ra) # 5ec8 <printf>
    exit(1);
    313e:	4505                	li	a0,1
    3140:	00003097          	auipc	ra,0x3
    3144:	9f0080e7          	jalr	-1552(ra) # 5b30 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    3148:	85a6                	mv	a1,s1
    314a:	00004517          	auipc	a0,0x4
    314e:	f9650513          	addi	a0,a0,-106 # 70e0 <malloc+0x115a>
    3152:	00003097          	auipc	ra,0x3
    3156:	d76080e7          	jalr	-650(ra) # 5ec8 <printf>
    exit(1);
    315a:	4505                	li	a0,1
    315c:	00003097          	auipc	ra,0x3
    3160:	9d4080e7          	jalr	-1580(ra) # 5b30 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    3164:	85a6                	mv	a1,s1
    3166:	00004517          	auipc	a0,0x4
    316a:	fe250513          	addi	a0,a0,-30 # 7148 <malloc+0x11c2>
    316e:	00003097          	auipc	ra,0x3
    3172:	d5a080e7          	jalr	-678(ra) # 5ec8 <printf>
    exit(1);
    3176:	4505                	li	a0,1
    3178:	00003097          	auipc	ra,0x3
    317c:	9b8080e7          	jalr	-1608(ra) # 5b30 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    3180:	85a6                	mv	a1,s1
    3182:	00004517          	auipc	a0,0x4
    3186:	03e50513          	addi	a0,a0,62 # 71c0 <malloc+0x123a>
    318a:	00003097          	auipc	ra,0x3
    318e:	d3e080e7          	jalr	-706(ra) # 5ec8 <printf>
    exit(1);
    3192:	4505                	li	a0,1
    3194:	00003097          	auipc	ra,0x3
    3198:	99c080e7          	jalr	-1636(ra) # 5b30 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    319c:	85a6                	mv	a1,s1
    319e:	00004517          	auipc	a0,0x4
    31a2:	08250513          	addi	a0,a0,130 # 7220 <malloc+0x129a>
    31a6:	00003097          	auipc	ra,0x3
    31aa:	d22080e7          	jalr	-734(ra) # 5ec8 <printf>
    exit(1);
    31ae:	4505                	li	a0,1
    31b0:	00003097          	auipc	ra,0x3
    31b4:	980080e7          	jalr	-1664(ra) # 5b30 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    31b8:	85a6                	mv	a1,s1
    31ba:	00004517          	auipc	a0,0x4
    31be:	0be50513          	addi	a0,a0,190 # 7278 <malloc+0x12f2>
    31c2:	00003097          	auipc	ra,0x3
    31c6:	d06080e7          	jalr	-762(ra) # 5ec8 <printf>
    exit(1);
    31ca:	4505                	li	a0,1
    31cc:	00003097          	auipc	ra,0x3
    31d0:	964080e7          	jalr	-1692(ra) # 5b30 <exit>

00000000000031d4 <diskfull>:
{
    31d4:	b9010113          	addi	sp,sp,-1136
    31d8:	46113423          	sd	ra,1128(sp)
    31dc:	46813023          	sd	s0,1120(sp)
    31e0:	44913c23          	sd	s1,1112(sp)
    31e4:	45213823          	sd	s2,1104(sp)
    31e8:	45313423          	sd	s3,1096(sp)
    31ec:	45413023          	sd	s4,1088(sp)
    31f0:	43513c23          	sd	s5,1080(sp)
    31f4:	43613823          	sd	s6,1072(sp)
    31f8:	43713423          	sd	s7,1064(sp)
    31fc:	43813023          	sd	s8,1056(sp)
    3200:	47010413          	addi	s0,sp,1136
    3204:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    3206:	00004517          	auipc	a0,0x4
    320a:	0aa50513          	addi	a0,a0,170 # 72b0 <malloc+0x132a>
    320e:	00003097          	auipc	ra,0x3
    3212:	972080e7          	jalr	-1678(ra) # 5b80 <unlink>
  for (fi = 0; done == 0; fi++)
    3216:	4a01                	li	s4,0
    name[0] = 'b';
    3218:	06200b13          	li	s6,98
    name[1] = 'i';
    321c:	06900a93          	li	s5,105
    name[2] = 'g';
    3220:	06700993          	li	s3,103
    3224:	10c00b93          	li	s7,268
    3228:	aabd                	j	33a6 <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    322a:	b9040613          	addi	a2,s0,-1136
    322e:	85e2                	mv	a1,s8
    3230:	00004517          	auipc	a0,0x4
    3234:	09050513          	addi	a0,a0,144 # 72c0 <malloc+0x133a>
    3238:	00003097          	auipc	ra,0x3
    323c:	c90080e7          	jalr	-880(ra) # 5ec8 <printf>
      break;
    3240:	a821                	j	3258 <diskfull+0x84>
        close(fd);
    3242:	854a                	mv	a0,s2
    3244:	00003097          	auipc	ra,0x3
    3248:	914080e7          	jalr	-1772(ra) # 5b58 <close>
    close(fd);
    324c:	854a                	mv	a0,s2
    324e:	00003097          	auipc	ra,0x3
    3252:	90a080e7          	jalr	-1782(ra) # 5b58 <close>
  for (fi = 0; done == 0; fi++)
    3256:	2a05                	addiw	s4,s4,1
  for (int i = 0; i < nzz; i++)
    3258:	4481                	li	s1,0
    name[0] = 'z';
    325a:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
    325e:	08000993          	li	s3,128
    name[0] = 'z';
    3262:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3266:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    326a:	41f4d79b          	sraiw	a5,s1,0x1f
    326e:	01b7d71b          	srliw	a4,a5,0x1b
    3272:	009707bb          	addw	a5,a4,s1
    3276:	4057d69b          	sraiw	a3,a5,0x5
    327a:	0306869b          	addiw	a3,a3,48
    327e:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3282:	8bfd                	andi	a5,a5,31
    3284:	9f99                	subw	a5,a5,a4
    3286:	0307879b          	addiw	a5,a5,48
    328a:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    328e:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3292:	bb040513          	addi	a0,s0,-1104
    3296:	00003097          	auipc	ra,0x3
    329a:	8ea080e7          	jalr	-1814(ra) # 5b80 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    329e:	60200593          	li	a1,1538
    32a2:	bb040513          	addi	a0,s0,-1104
    32a6:	00003097          	auipc	ra,0x3
    32aa:	8ca080e7          	jalr	-1846(ra) # 5b70 <open>
    if (fd < 0)
    32ae:	00054963          	bltz	a0,32c0 <diskfull+0xec>
    close(fd);
    32b2:	00003097          	auipc	ra,0x3
    32b6:	8a6080e7          	jalr	-1882(ra) # 5b58 <close>
  for (int i = 0; i < nzz; i++)
    32ba:	2485                	addiw	s1,s1,1
    32bc:	fb3493e3          	bne	s1,s3,3262 <diskfull+0x8e>
  if (mkdir("diskfulldir") == 0)
    32c0:	00004517          	auipc	a0,0x4
    32c4:	ff050513          	addi	a0,a0,-16 # 72b0 <malloc+0x132a>
    32c8:	00003097          	auipc	ra,0x3
    32cc:	8d0080e7          	jalr	-1840(ra) # 5b98 <mkdir>
    32d0:	12050963          	beqz	a0,3402 <diskfull+0x22e>
  unlink("diskfulldir");
    32d4:	00004517          	auipc	a0,0x4
    32d8:	fdc50513          	addi	a0,a0,-36 # 72b0 <malloc+0x132a>
    32dc:	00003097          	auipc	ra,0x3
    32e0:	8a4080e7          	jalr	-1884(ra) # 5b80 <unlink>
  for (int i = 0; i < nzz; i++)
    32e4:	4481                	li	s1,0
    name[0] = 'z';
    32e6:	07a00913          	li	s2,122
  for (int i = 0; i < nzz; i++)
    32ea:	08000993          	li	s3,128
    name[0] = 'z';
    32ee:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    32f2:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    32f6:	41f4d79b          	sraiw	a5,s1,0x1f
    32fa:	01b7d71b          	srliw	a4,a5,0x1b
    32fe:	009707bb          	addw	a5,a4,s1
    3302:	4057d69b          	sraiw	a3,a5,0x5
    3306:	0306869b          	addiw	a3,a3,48
    330a:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    330e:	8bfd                	andi	a5,a5,31
    3310:	9f99                	subw	a5,a5,a4
    3312:	0307879b          	addiw	a5,a5,48
    3316:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    331a:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    331e:	bb040513          	addi	a0,s0,-1104
    3322:	00003097          	auipc	ra,0x3
    3326:	85e080e7          	jalr	-1954(ra) # 5b80 <unlink>
  for (int i = 0; i < nzz; i++)
    332a:	2485                	addiw	s1,s1,1
    332c:	fd3491e3          	bne	s1,s3,32ee <diskfull+0x11a>
  for (int i = 0; i < fi; i++)
    3330:	03405e63          	blez	s4,336c <diskfull+0x198>
    3334:	4481                	li	s1,0
    name[0] = 'b';
    3336:	06200a93          	li	s5,98
    name[1] = 'i';
    333a:	06900993          	li	s3,105
    name[2] = 'g';
    333e:	06700913          	li	s2,103
    name[0] = 'b';
    3342:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    3346:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    334a:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    334e:	0304879b          	addiw	a5,s1,48
    3352:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3356:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    335a:	bb040513          	addi	a0,s0,-1104
    335e:	00003097          	auipc	ra,0x3
    3362:	822080e7          	jalr	-2014(ra) # 5b80 <unlink>
  for (int i = 0; i < fi; i++)
    3366:	2485                	addiw	s1,s1,1
    3368:	fd449de3          	bne	s1,s4,3342 <diskfull+0x16e>
}
    336c:	46813083          	ld	ra,1128(sp)
    3370:	46013403          	ld	s0,1120(sp)
    3374:	45813483          	ld	s1,1112(sp)
    3378:	45013903          	ld	s2,1104(sp)
    337c:	44813983          	ld	s3,1096(sp)
    3380:	44013a03          	ld	s4,1088(sp)
    3384:	43813a83          	ld	s5,1080(sp)
    3388:	43013b03          	ld	s6,1072(sp)
    338c:	42813b83          	ld	s7,1064(sp)
    3390:	42013c03          	ld	s8,1056(sp)
    3394:	47010113          	addi	sp,sp,1136
    3398:	8082                	ret
    close(fd);
    339a:	854a                	mv	a0,s2
    339c:	00002097          	auipc	ra,0x2
    33a0:	7bc080e7          	jalr	1980(ra) # 5b58 <close>
  for (fi = 0; done == 0; fi++)
    33a4:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    33a6:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    33aa:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    33ae:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    33b2:	030a079b          	addiw	a5,s4,48
    33b6:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    33ba:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    33be:	b9040513          	addi	a0,s0,-1136
    33c2:	00002097          	auipc	ra,0x2
    33c6:	7be080e7          	jalr	1982(ra) # 5b80 <unlink>
    int fd = open(name, O_CREATE | O_RDWR | O_TRUNC);
    33ca:	60200593          	li	a1,1538
    33ce:	b9040513          	addi	a0,s0,-1136
    33d2:	00002097          	auipc	ra,0x2
    33d6:	79e080e7          	jalr	1950(ra) # 5b70 <open>
    33da:	892a                	mv	s2,a0
    if (fd < 0)
    33dc:	e40547e3          	bltz	a0,322a <diskfull+0x56>
    33e0:	84de                	mv	s1,s7
      if (write(fd, buf, BSIZE) != BSIZE)
    33e2:	40000613          	li	a2,1024
    33e6:	bb040593          	addi	a1,s0,-1104
    33ea:	854a                	mv	a0,s2
    33ec:	00002097          	auipc	ra,0x2
    33f0:	764080e7          	jalr	1892(ra) # 5b50 <write>
    33f4:	40000793          	li	a5,1024
    33f8:	e4f515e3          	bne	a0,a5,3242 <diskfull+0x6e>
    for (int i = 0; i < MAXFILE; i++)
    33fc:	34fd                	addiw	s1,s1,-1
    33fe:	f0f5                	bnez	s1,33e2 <diskfull+0x20e>
    3400:	bf69                	j	339a <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    3402:	00004517          	auipc	a0,0x4
    3406:	ede50513          	addi	a0,a0,-290 # 72e0 <malloc+0x135a>
    340a:	00003097          	auipc	ra,0x3
    340e:	abe080e7          	jalr	-1346(ra) # 5ec8 <printf>
    3412:	b5c9                	j	32d4 <diskfull+0x100>

0000000000003414 <iputtest>:
{
    3414:	1101                	addi	sp,sp,-32
    3416:	ec06                	sd	ra,24(sp)
    3418:	e822                	sd	s0,16(sp)
    341a:	e426                	sd	s1,8(sp)
    341c:	1000                	addi	s0,sp,32
    341e:	84aa                	mv	s1,a0
  if (mkdir("iputdir") < 0)
    3420:	00004517          	auipc	a0,0x4
    3424:	ef050513          	addi	a0,a0,-272 # 7310 <malloc+0x138a>
    3428:	00002097          	auipc	ra,0x2
    342c:	770080e7          	jalr	1904(ra) # 5b98 <mkdir>
    3430:	04054563          	bltz	a0,347a <iputtest+0x66>
  if (chdir("iputdir") < 0)
    3434:	00004517          	auipc	a0,0x4
    3438:	edc50513          	addi	a0,a0,-292 # 7310 <malloc+0x138a>
    343c:	00002097          	auipc	ra,0x2
    3440:	764080e7          	jalr	1892(ra) # 5ba0 <chdir>
    3444:	04054963          	bltz	a0,3496 <iputtest+0x82>
  if (unlink("../iputdir") < 0)
    3448:	00004517          	auipc	a0,0x4
    344c:	f0850513          	addi	a0,a0,-248 # 7350 <malloc+0x13ca>
    3450:	00002097          	auipc	ra,0x2
    3454:	730080e7          	jalr	1840(ra) # 5b80 <unlink>
    3458:	04054d63          	bltz	a0,34b2 <iputtest+0x9e>
  if (chdir("/") < 0)
    345c:	00004517          	auipc	a0,0x4
    3460:	f2450513          	addi	a0,a0,-220 # 7380 <malloc+0x13fa>
    3464:	00002097          	auipc	ra,0x2
    3468:	73c080e7          	jalr	1852(ra) # 5ba0 <chdir>
    346c:	06054163          	bltz	a0,34ce <iputtest+0xba>
}
    3470:	60e2                	ld	ra,24(sp)
    3472:	6442                	ld	s0,16(sp)
    3474:	64a2                	ld	s1,8(sp)
    3476:	6105                	addi	sp,sp,32
    3478:	8082                	ret
    printf("%s: mkdir failed\n", s);
    347a:	85a6                	mv	a1,s1
    347c:	00004517          	auipc	a0,0x4
    3480:	e9c50513          	addi	a0,a0,-356 # 7318 <malloc+0x1392>
    3484:	00003097          	auipc	ra,0x3
    3488:	a44080e7          	jalr	-1468(ra) # 5ec8 <printf>
    exit(1);
    348c:	4505                	li	a0,1
    348e:	00002097          	auipc	ra,0x2
    3492:	6a2080e7          	jalr	1698(ra) # 5b30 <exit>
    printf("%s: chdir iputdir failed\n", s);
    3496:	85a6                	mv	a1,s1
    3498:	00004517          	auipc	a0,0x4
    349c:	e9850513          	addi	a0,a0,-360 # 7330 <malloc+0x13aa>
    34a0:	00003097          	auipc	ra,0x3
    34a4:	a28080e7          	jalr	-1496(ra) # 5ec8 <printf>
    exit(1);
    34a8:	4505                	li	a0,1
    34aa:	00002097          	auipc	ra,0x2
    34ae:	686080e7          	jalr	1670(ra) # 5b30 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    34b2:	85a6                	mv	a1,s1
    34b4:	00004517          	auipc	a0,0x4
    34b8:	eac50513          	addi	a0,a0,-340 # 7360 <malloc+0x13da>
    34bc:	00003097          	auipc	ra,0x3
    34c0:	a0c080e7          	jalr	-1524(ra) # 5ec8 <printf>
    exit(1);
    34c4:	4505                	li	a0,1
    34c6:	00002097          	auipc	ra,0x2
    34ca:	66a080e7          	jalr	1642(ra) # 5b30 <exit>
    printf("%s: chdir / failed\n", s);
    34ce:	85a6                	mv	a1,s1
    34d0:	00004517          	auipc	a0,0x4
    34d4:	eb850513          	addi	a0,a0,-328 # 7388 <malloc+0x1402>
    34d8:	00003097          	auipc	ra,0x3
    34dc:	9f0080e7          	jalr	-1552(ra) # 5ec8 <printf>
    exit(1);
    34e0:	4505                	li	a0,1
    34e2:	00002097          	auipc	ra,0x2
    34e6:	64e080e7          	jalr	1614(ra) # 5b30 <exit>

00000000000034ea <exitiputtest>:
{
    34ea:	7179                	addi	sp,sp,-48
    34ec:	f406                	sd	ra,40(sp)
    34ee:	f022                	sd	s0,32(sp)
    34f0:	ec26                	sd	s1,24(sp)
    34f2:	1800                	addi	s0,sp,48
    34f4:	84aa                	mv	s1,a0
  pid = fork();
    34f6:	00002097          	auipc	ra,0x2
    34fa:	632080e7          	jalr	1586(ra) # 5b28 <fork>
  if (pid < 0)
    34fe:	04054663          	bltz	a0,354a <exitiputtest+0x60>
  if (pid == 0)
    3502:	ed45                	bnez	a0,35ba <exitiputtest+0xd0>
    if (mkdir("iputdir") < 0)
    3504:	00004517          	auipc	a0,0x4
    3508:	e0c50513          	addi	a0,a0,-500 # 7310 <malloc+0x138a>
    350c:	00002097          	auipc	ra,0x2
    3510:	68c080e7          	jalr	1676(ra) # 5b98 <mkdir>
    3514:	04054963          	bltz	a0,3566 <exitiputtest+0x7c>
    if (chdir("iputdir") < 0)
    3518:	00004517          	auipc	a0,0x4
    351c:	df850513          	addi	a0,a0,-520 # 7310 <malloc+0x138a>
    3520:	00002097          	auipc	ra,0x2
    3524:	680080e7          	jalr	1664(ra) # 5ba0 <chdir>
    3528:	04054d63          	bltz	a0,3582 <exitiputtest+0x98>
    if (unlink("../iputdir") < 0)
    352c:	00004517          	auipc	a0,0x4
    3530:	e2450513          	addi	a0,a0,-476 # 7350 <malloc+0x13ca>
    3534:	00002097          	auipc	ra,0x2
    3538:	64c080e7          	jalr	1612(ra) # 5b80 <unlink>
    353c:	06054163          	bltz	a0,359e <exitiputtest+0xb4>
    exit(0);
    3540:	4501                	li	a0,0
    3542:	00002097          	auipc	ra,0x2
    3546:	5ee080e7          	jalr	1518(ra) # 5b30 <exit>
    printf("%s: fork failed\n", s);
    354a:	85a6                	mv	a1,s1
    354c:	00003517          	auipc	a0,0x3
    3550:	40450513          	addi	a0,a0,1028 # 6950 <malloc+0x9ca>
    3554:	00003097          	auipc	ra,0x3
    3558:	974080e7          	jalr	-1676(ra) # 5ec8 <printf>
    exit(1);
    355c:	4505                	li	a0,1
    355e:	00002097          	auipc	ra,0x2
    3562:	5d2080e7          	jalr	1490(ra) # 5b30 <exit>
      printf("%s: mkdir failed\n", s);
    3566:	85a6                	mv	a1,s1
    3568:	00004517          	auipc	a0,0x4
    356c:	db050513          	addi	a0,a0,-592 # 7318 <malloc+0x1392>
    3570:	00003097          	auipc	ra,0x3
    3574:	958080e7          	jalr	-1704(ra) # 5ec8 <printf>
      exit(1);
    3578:	4505                	li	a0,1
    357a:	00002097          	auipc	ra,0x2
    357e:	5b6080e7          	jalr	1462(ra) # 5b30 <exit>
      printf("%s: child chdir failed\n", s);
    3582:	85a6                	mv	a1,s1
    3584:	00004517          	auipc	a0,0x4
    3588:	e1c50513          	addi	a0,a0,-484 # 73a0 <malloc+0x141a>
    358c:	00003097          	auipc	ra,0x3
    3590:	93c080e7          	jalr	-1732(ra) # 5ec8 <printf>
      exit(1);
    3594:	4505                	li	a0,1
    3596:	00002097          	auipc	ra,0x2
    359a:	59a080e7          	jalr	1434(ra) # 5b30 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    359e:	85a6                	mv	a1,s1
    35a0:	00004517          	auipc	a0,0x4
    35a4:	dc050513          	addi	a0,a0,-576 # 7360 <malloc+0x13da>
    35a8:	00003097          	auipc	ra,0x3
    35ac:	920080e7          	jalr	-1760(ra) # 5ec8 <printf>
      exit(1);
    35b0:	4505                	li	a0,1
    35b2:	00002097          	auipc	ra,0x2
    35b6:	57e080e7          	jalr	1406(ra) # 5b30 <exit>
  wait(&xstatus);
    35ba:	fdc40513          	addi	a0,s0,-36
    35be:	00002097          	auipc	ra,0x2
    35c2:	57a080e7          	jalr	1402(ra) # 5b38 <wait>
  exit(xstatus);
    35c6:	fdc42503          	lw	a0,-36(s0)
    35ca:	00002097          	auipc	ra,0x2
    35ce:	566080e7          	jalr	1382(ra) # 5b30 <exit>

00000000000035d2 <dirtest>:
{
    35d2:	1101                	addi	sp,sp,-32
    35d4:	ec06                	sd	ra,24(sp)
    35d6:	e822                	sd	s0,16(sp)
    35d8:	e426                	sd	s1,8(sp)
    35da:	1000                	addi	s0,sp,32
    35dc:	84aa                	mv	s1,a0
  if (mkdir("dir0") < 0)
    35de:	00004517          	auipc	a0,0x4
    35e2:	dda50513          	addi	a0,a0,-550 # 73b8 <malloc+0x1432>
    35e6:	00002097          	auipc	ra,0x2
    35ea:	5b2080e7          	jalr	1458(ra) # 5b98 <mkdir>
    35ee:	04054563          	bltz	a0,3638 <dirtest+0x66>
  if (chdir("dir0") < 0)
    35f2:	00004517          	auipc	a0,0x4
    35f6:	dc650513          	addi	a0,a0,-570 # 73b8 <malloc+0x1432>
    35fa:	00002097          	auipc	ra,0x2
    35fe:	5a6080e7          	jalr	1446(ra) # 5ba0 <chdir>
    3602:	04054963          	bltz	a0,3654 <dirtest+0x82>
  if (chdir("..") < 0)
    3606:	00004517          	auipc	a0,0x4
    360a:	dd250513          	addi	a0,a0,-558 # 73d8 <malloc+0x1452>
    360e:	00002097          	auipc	ra,0x2
    3612:	592080e7          	jalr	1426(ra) # 5ba0 <chdir>
    3616:	04054d63          	bltz	a0,3670 <dirtest+0x9e>
  if (unlink("dir0") < 0)
    361a:	00004517          	auipc	a0,0x4
    361e:	d9e50513          	addi	a0,a0,-610 # 73b8 <malloc+0x1432>
    3622:	00002097          	auipc	ra,0x2
    3626:	55e080e7          	jalr	1374(ra) # 5b80 <unlink>
    362a:	06054163          	bltz	a0,368c <dirtest+0xba>
}
    362e:	60e2                	ld	ra,24(sp)
    3630:	6442                	ld	s0,16(sp)
    3632:	64a2                	ld	s1,8(sp)
    3634:	6105                	addi	sp,sp,32
    3636:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3638:	85a6                	mv	a1,s1
    363a:	00004517          	auipc	a0,0x4
    363e:	cde50513          	addi	a0,a0,-802 # 7318 <malloc+0x1392>
    3642:	00003097          	auipc	ra,0x3
    3646:	886080e7          	jalr	-1914(ra) # 5ec8 <printf>
    exit(1);
    364a:	4505                	li	a0,1
    364c:	00002097          	auipc	ra,0x2
    3650:	4e4080e7          	jalr	1252(ra) # 5b30 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3654:	85a6                	mv	a1,s1
    3656:	00004517          	auipc	a0,0x4
    365a:	d6a50513          	addi	a0,a0,-662 # 73c0 <malloc+0x143a>
    365e:	00003097          	auipc	ra,0x3
    3662:	86a080e7          	jalr	-1942(ra) # 5ec8 <printf>
    exit(1);
    3666:	4505                	li	a0,1
    3668:	00002097          	auipc	ra,0x2
    366c:	4c8080e7          	jalr	1224(ra) # 5b30 <exit>
    printf("%s: chdir .. failed\n", s);
    3670:	85a6                	mv	a1,s1
    3672:	00004517          	auipc	a0,0x4
    3676:	d6e50513          	addi	a0,a0,-658 # 73e0 <malloc+0x145a>
    367a:	00003097          	auipc	ra,0x3
    367e:	84e080e7          	jalr	-1970(ra) # 5ec8 <printf>
    exit(1);
    3682:	4505                	li	a0,1
    3684:	00002097          	auipc	ra,0x2
    3688:	4ac080e7          	jalr	1196(ra) # 5b30 <exit>
    printf("%s: unlink dir0 failed\n", s);
    368c:	85a6                	mv	a1,s1
    368e:	00004517          	auipc	a0,0x4
    3692:	d6a50513          	addi	a0,a0,-662 # 73f8 <malloc+0x1472>
    3696:	00003097          	auipc	ra,0x3
    369a:	832080e7          	jalr	-1998(ra) # 5ec8 <printf>
    exit(1);
    369e:	4505                	li	a0,1
    36a0:	00002097          	auipc	ra,0x2
    36a4:	490080e7          	jalr	1168(ra) # 5b30 <exit>

00000000000036a8 <subdir>:
{
    36a8:	1101                	addi	sp,sp,-32
    36aa:	ec06                	sd	ra,24(sp)
    36ac:	e822                	sd	s0,16(sp)
    36ae:	e426                	sd	s1,8(sp)
    36b0:	e04a                	sd	s2,0(sp)
    36b2:	1000                	addi	s0,sp,32
    36b4:	892a                	mv	s2,a0
  unlink("ff");
    36b6:	00004517          	auipc	a0,0x4
    36ba:	e8a50513          	addi	a0,a0,-374 # 7540 <malloc+0x15ba>
    36be:	00002097          	auipc	ra,0x2
    36c2:	4c2080e7          	jalr	1218(ra) # 5b80 <unlink>
  if (mkdir("dd") != 0)
    36c6:	00004517          	auipc	a0,0x4
    36ca:	d4a50513          	addi	a0,a0,-694 # 7410 <malloc+0x148a>
    36ce:	00002097          	auipc	ra,0x2
    36d2:	4ca080e7          	jalr	1226(ra) # 5b98 <mkdir>
    36d6:	38051663          	bnez	a0,3a62 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    36da:	20200593          	li	a1,514
    36de:	00004517          	auipc	a0,0x4
    36e2:	d5250513          	addi	a0,a0,-686 # 7430 <malloc+0x14aa>
    36e6:	00002097          	auipc	ra,0x2
    36ea:	48a080e7          	jalr	1162(ra) # 5b70 <open>
    36ee:	84aa                	mv	s1,a0
  if (fd < 0)
    36f0:	38054763          	bltz	a0,3a7e <subdir+0x3d6>
  write(fd, "ff", 2);
    36f4:	4609                	li	a2,2
    36f6:	00004597          	auipc	a1,0x4
    36fa:	e4a58593          	addi	a1,a1,-438 # 7540 <malloc+0x15ba>
    36fe:	00002097          	auipc	ra,0x2
    3702:	452080e7          	jalr	1106(ra) # 5b50 <write>
  close(fd);
    3706:	8526                	mv	a0,s1
    3708:	00002097          	auipc	ra,0x2
    370c:	450080e7          	jalr	1104(ra) # 5b58 <close>
  if (unlink("dd") >= 0)
    3710:	00004517          	auipc	a0,0x4
    3714:	d0050513          	addi	a0,a0,-768 # 7410 <malloc+0x148a>
    3718:	00002097          	auipc	ra,0x2
    371c:	468080e7          	jalr	1128(ra) # 5b80 <unlink>
    3720:	36055d63          	bgez	a0,3a9a <subdir+0x3f2>
  if (mkdir("/dd/dd") != 0)
    3724:	00004517          	auipc	a0,0x4
    3728:	d6450513          	addi	a0,a0,-668 # 7488 <malloc+0x1502>
    372c:	00002097          	auipc	ra,0x2
    3730:	46c080e7          	jalr	1132(ra) # 5b98 <mkdir>
    3734:	38051163          	bnez	a0,3ab6 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3738:	20200593          	li	a1,514
    373c:	00004517          	auipc	a0,0x4
    3740:	d7450513          	addi	a0,a0,-652 # 74b0 <malloc+0x152a>
    3744:	00002097          	auipc	ra,0x2
    3748:	42c080e7          	jalr	1068(ra) # 5b70 <open>
    374c:	84aa                	mv	s1,a0
  if (fd < 0)
    374e:	38054263          	bltz	a0,3ad2 <subdir+0x42a>
  write(fd, "FF", 2);
    3752:	4609                	li	a2,2
    3754:	00004597          	auipc	a1,0x4
    3758:	d8c58593          	addi	a1,a1,-628 # 74e0 <malloc+0x155a>
    375c:	00002097          	auipc	ra,0x2
    3760:	3f4080e7          	jalr	1012(ra) # 5b50 <write>
  close(fd);
    3764:	8526                	mv	a0,s1
    3766:	00002097          	auipc	ra,0x2
    376a:	3f2080e7          	jalr	1010(ra) # 5b58 <close>
  fd = open("dd/dd/../ff", 0);
    376e:	4581                	li	a1,0
    3770:	00004517          	auipc	a0,0x4
    3774:	d7850513          	addi	a0,a0,-648 # 74e8 <malloc+0x1562>
    3778:	00002097          	auipc	ra,0x2
    377c:	3f8080e7          	jalr	1016(ra) # 5b70 <open>
    3780:	84aa                	mv	s1,a0
  if (fd < 0)
    3782:	36054663          	bltz	a0,3aee <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3786:	660d                	lui	a2,0x3
    3788:	00009597          	auipc	a1,0x9
    378c:	4f058593          	addi	a1,a1,1264 # cc78 <buf>
    3790:	00002097          	auipc	ra,0x2
    3794:	3b8080e7          	jalr	952(ra) # 5b48 <read>
  if (cc != 2 || buf[0] != 'f')
    3798:	4789                	li	a5,2
    379a:	36f51863          	bne	a0,a5,3b0a <subdir+0x462>
    379e:	00009717          	auipc	a4,0x9
    37a2:	4da74703          	lbu	a4,1242(a4) # cc78 <buf>
    37a6:	06600793          	li	a5,102
    37aa:	36f71063          	bne	a4,a5,3b0a <subdir+0x462>
  close(fd);
    37ae:	8526                	mv	a0,s1
    37b0:	00002097          	auipc	ra,0x2
    37b4:	3a8080e7          	jalr	936(ra) # 5b58 <close>
  if (link("dd/dd/ff", "dd/dd/ffff") != 0)
    37b8:	00004597          	auipc	a1,0x4
    37bc:	d8058593          	addi	a1,a1,-640 # 7538 <malloc+0x15b2>
    37c0:	00004517          	auipc	a0,0x4
    37c4:	cf050513          	addi	a0,a0,-784 # 74b0 <malloc+0x152a>
    37c8:	00002097          	auipc	ra,0x2
    37cc:	3c8080e7          	jalr	968(ra) # 5b90 <link>
    37d0:	34051b63          	bnez	a0,3b26 <subdir+0x47e>
  if (unlink("dd/dd/ff") != 0)
    37d4:	00004517          	auipc	a0,0x4
    37d8:	cdc50513          	addi	a0,a0,-804 # 74b0 <malloc+0x152a>
    37dc:	00002097          	auipc	ra,0x2
    37e0:	3a4080e7          	jalr	932(ra) # 5b80 <unlink>
    37e4:	34051f63          	bnez	a0,3b42 <subdir+0x49a>
  if (open("dd/dd/ff", O_RDONLY) >= 0)
    37e8:	4581                	li	a1,0
    37ea:	00004517          	auipc	a0,0x4
    37ee:	cc650513          	addi	a0,a0,-826 # 74b0 <malloc+0x152a>
    37f2:	00002097          	auipc	ra,0x2
    37f6:	37e080e7          	jalr	894(ra) # 5b70 <open>
    37fa:	36055263          	bgez	a0,3b5e <subdir+0x4b6>
  if (chdir("dd") != 0)
    37fe:	00004517          	auipc	a0,0x4
    3802:	c1250513          	addi	a0,a0,-1006 # 7410 <malloc+0x148a>
    3806:	00002097          	auipc	ra,0x2
    380a:	39a080e7          	jalr	922(ra) # 5ba0 <chdir>
    380e:	36051663          	bnez	a0,3b7a <subdir+0x4d2>
  if (chdir("dd/../../dd") != 0)
    3812:	00004517          	auipc	a0,0x4
    3816:	dbe50513          	addi	a0,a0,-578 # 75d0 <malloc+0x164a>
    381a:	00002097          	auipc	ra,0x2
    381e:	386080e7          	jalr	902(ra) # 5ba0 <chdir>
    3822:	36051a63          	bnez	a0,3b96 <subdir+0x4ee>
  if (chdir("dd/../../../dd") != 0)
    3826:	00004517          	auipc	a0,0x4
    382a:	dda50513          	addi	a0,a0,-550 # 7600 <malloc+0x167a>
    382e:	00002097          	auipc	ra,0x2
    3832:	372080e7          	jalr	882(ra) # 5ba0 <chdir>
    3836:	36051e63          	bnez	a0,3bb2 <subdir+0x50a>
  if (chdir("./..") != 0)
    383a:	00004517          	auipc	a0,0x4
    383e:	df650513          	addi	a0,a0,-522 # 7630 <malloc+0x16aa>
    3842:	00002097          	auipc	ra,0x2
    3846:	35e080e7          	jalr	862(ra) # 5ba0 <chdir>
    384a:	38051263          	bnez	a0,3bce <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    384e:	4581                	li	a1,0
    3850:	00004517          	auipc	a0,0x4
    3854:	ce850513          	addi	a0,a0,-792 # 7538 <malloc+0x15b2>
    3858:	00002097          	auipc	ra,0x2
    385c:	318080e7          	jalr	792(ra) # 5b70 <open>
    3860:	84aa                	mv	s1,a0
  if (fd < 0)
    3862:	38054463          	bltz	a0,3bea <subdir+0x542>
  if (read(fd, buf, sizeof(buf)) != 2)
    3866:	660d                	lui	a2,0x3
    3868:	00009597          	auipc	a1,0x9
    386c:	41058593          	addi	a1,a1,1040 # cc78 <buf>
    3870:	00002097          	auipc	ra,0x2
    3874:	2d8080e7          	jalr	728(ra) # 5b48 <read>
    3878:	4789                	li	a5,2
    387a:	38f51663          	bne	a0,a5,3c06 <subdir+0x55e>
  close(fd);
    387e:	8526                	mv	a0,s1
    3880:	00002097          	auipc	ra,0x2
    3884:	2d8080e7          	jalr	728(ra) # 5b58 <close>
  if (open("dd/dd/ff", O_RDONLY) >= 0)
    3888:	4581                	li	a1,0
    388a:	00004517          	auipc	a0,0x4
    388e:	c2650513          	addi	a0,a0,-986 # 74b0 <malloc+0x152a>
    3892:	00002097          	auipc	ra,0x2
    3896:	2de080e7          	jalr	734(ra) # 5b70 <open>
    389a:	38055463          	bgez	a0,3c22 <subdir+0x57a>
  if (open("dd/ff/ff", O_CREATE | O_RDWR) >= 0)
    389e:	20200593          	li	a1,514
    38a2:	00004517          	auipc	a0,0x4
    38a6:	e1e50513          	addi	a0,a0,-482 # 76c0 <malloc+0x173a>
    38aa:	00002097          	auipc	ra,0x2
    38ae:	2c6080e7          	jalr	710(ra) # 5b70 <open>
    38b2:	38055663          	bgez	a0,3c3e <subdir+0x596>
  if (open("dd/xx/ff", O_CREATE | O_RDWR) >= 0)
    38b6:	20200593          	li	a1,514
    38ba:	00004517          	auipc	a0,0x4
    38be:	e3650513          	addi	a0,a0,-458 # 76f0 <malloc+0x176a>
    38c2:	00002097          	auipc	ra,0x2
    38c6:	2ae080e7          	jalr	686(ra) # 5b70 <open>
    38ca:	38055863          	bgez	a0,3c5a <subdir+0x5b2>
  if (open("dd", O_CREATE) >= 0)
    38ce:	20000593          	li	a1,512
    38d2:	00004517          	auipc	a0,0x4
    38d6:	b3e50513          	addi	a0,a0,-1218 # 7410 <malloc+0x148a>
    38da:	00002097          	auipc	ra,0x2
    38de:	296080e7          	jalr	662(ra) # 5b70 <open>
    38e2:	38055a63          	bgez	a0,3c76 <subdir+0x5ce>
  if (open("dd", O_RDWR) >= 0)
    38e6:	4589                	li	a1,2
    38e8:	00004517          	auipc	a0,0x4
    38ec:	b2850513          	addi	a0,a0,-1240 # 7410 <malloc+0x148a>
    38f0:	00002097          	auipc	ra,0x2
    38f4:	280080e7          	jalr	640(ra) # 5b70 <open>
    38f8:	38055d63          	bgez	a0,3c92 <subdir+0x5ea>
  if (open("dd", O_WRONLY) >= 0)
    38fc:	4585                	li	a1,1
    38fe:	00004517          	auipc	a0,0x4
    3902:	b1250513          	addi	a0,a0,-1262 # 7410 <malloc+0x148a>
    3906:	00002097          	auipc	ra,0x2
    390a:	26a080e7          	jalr	618(ra) # 5b70 <open>
    390e:	3a055063          	bgez	a0,3cae <subdir+0x606>
  if (link("dd/ff/ff", "dd/dd/xx") == 0)
    3912:	00004597          	auipc	a1,0x4
    3916:	e6e58593          	addi	a1,a1,-402 # 7780 <malloc+0x17fa>
    391a:	00004517          	auipc	a0,0x4
    391e:	da650513          	addi	a0,a0,-602 # 76c0 <malloc+0x173a>
    3922:	00002097          	auipc	ra,0x2
    3926:	26e080e7          	jalr	622(ra) # 5b90 <link>
    392a:	3a050063          	beqz	a0,3cca <subdir+0x622>
  if (link("dd/xx/ff", "dd/dd/xx") == 0)
    392e:	00004597          	auipc	a1,0x4
    3932:	e5258593          	addi	a1,a1,-430 # 7780 <malloc+0x17fa>
    3936:	00004517          	auipc	a0,0x4
    393a:	dba50513          	addi	a0,a0,-582 # 76f0 <malloc+0x176a>
    393e:	00002097          	auipc	ra,0x2
    3942:	252080e7          	jalr	594(ra) # 5b90 <link>
    3946:	3a050063          	beqz	a0,3ce6 <subdir+0x63e>
  if (link("dd/ff", "dd/dd/ffff") == 0)
    394a:	00004597          	auipc	a1,0x4
    394e:	bee58593          	addi	a1,a1,-1042 # 7538 <malloc+0x15b2>
    3952:	00004517          	auipc	a0,0x4
    3956:	ade50513          	addi	a0,a0,-1314 # 7430 <malloc+0x14aa>
    395a:	00002097          	auipc	ra,0x2
    395e:	236080e7          	jalr	566(ra) # 5b90 <link>
    3962:	3a050063          	beqz	a0,3d02 <subdir+0x65a>
  if (mkdir("dd/ff/ff") == 0)
    3966:	00004517          	auipc	a0,0x4
    396a:	d5a50513          	addi	a0,a0,-678 # 76c0 <malloc+0x173a>
    396e:	00002097          	auipc	ra,0x2
    3972:	22a080e7          	jalr	554(ra) # 5b98 <mkdir>
    3976:	3a050463          	beqz	a0,3d1e <subdir+0x676>
  if (mkdir("dd/xx/ff") == 0)
    397a:	00004517          	auipc	a0,0x4
    397e:	d7650513          	addi	a0,a0,-650 # 76f0 <malloc+0x176a>
    3982:	00002097          	auipc	ra,0x2
    3986:	216080e7          	jalr	534(ra) # 5b98 <mkdir>
    398a:	3a050863          	beqz	a0,3d3a <subdir+0x692>
  if (mkdir("dd/dd/ffff") == 0)
    398e:	00004517          	auipc	a0,0x4
    3992:	baa50513          	addi	a0,a0,-1110 # 7538 <malloc+0x15b2>
    3996:	00002097          	auipc	ra,0x2
    399a:	202080e7          	jalr	514(ra) # 5b98 <mkdir>
    399e:	3a050c63          	beqz	a0,3d56 <subdir+0x6ae>
  if (unlink("dd/xx/ff") == 0)
    39a2:	00004517          	auipc	a0,0x4
    39a6:	d4e50513          	addi	a0,a0,-690 # 76f0 <malloc+0x176a>
    39aa:	00002097          	auipc	ra,0x2
    39ae:	1d6080e7          	jalr	470(ra) # 5b80 <unlink>
    39b2:	3c050063          	beqz	a0,3d72 <subdir+0x6ca>
  if (unlink("dd/ff/ff") == 0)
    39b6:	00004517          	auipc	a0,0x4
    39ba:	d0a50513          	addi	a0,a0,-758 # 76c0 <malloc+0x173a>
    39be:	00002097          	auipc	ra,0x2
    39c2:	1c2080e7          	jalr	450(ra) # 5b80 <unlink>
    39c6:	3c050463          	beqz	a0,3d8e <subdir+0x6e6>
  if (chdir("dd/ff") == 0)
    39ca:	00004517          	auipc	a0,0x4
    39ce:	a6650513          	addi	a0,a0,-1434 # 7430 <malloc+0x14aa>
    39d2:	00002097          	auipc	ra,0x2
    39d6:	1ce080e7          	jalr	462(ra) # 5ba0 <chdir>
    39da:	3c050863          	beqz	a0,3daa <subdir+0x702>
  if (chdir("dd/xx") == 0)
    39de:	00004517          	auipc	a0,0x4
    39e2:	ef250513          	addi	a0,a0,-270 # 78d0 <malloc+0x194a>
    39e6:	00002097          	auipc	ra,0x2
    39ea:	1ba080e7          	jalr	442(ra) # 5ba0 <chdir>
    39ee:	3c050c63          	beqz	a0,3dc6 <subdir+0x71e>
  if (unlink("dd/dd/ffff") != 0)
    39f2:	00004517          	auipc	a0,0x4
    39f6:	b4650513          	addi	a0,a0,-1210 # 7538 <malloc+0x15b2>
    39fa:	00002097          	auipc	ra,0x2
    39fe:	186080e7          	jalr	390(ra) # 5b80 <unlink>
    3a02:	3e051063          	bnez	a0,3de2 <subdir+0x73a>
  if (unlink("dd/ff") != 0)
    3a06:	00004517          	auipc	a0,0x4
    3a0a:	a2a50513          	addi	a0,a0,-1494 # 7430 <malloc+0x14aa>
    3a0e:	00002097          	auipc	ra,0x2
    3a12:	172080e7          	jalr	370(ra) # 5b80 <unlink>
    3a16:	3e051463          	bnez	a0,3dfe <subdir+0x756>
  if (unlink("dd") == 0)
    3a1a:	00004517          	auipc	a0,0x4
    3a1e:	9f650513          	addi	a0,a0,-1546 # 7410 <malloc+0x148a>
    3a22:	00002097          	auipc	ra,0x2
    3a26:	15e080e7          	jalr	350(ra) # 5b80 <unlink>
    3a2a:	3e050863          	beqz	a0,3e1a <subdir+0x772>
  if (unlink("dd/dd") < 0)
    3a2e:	00004517          	auipc	a0,0x4
    3a32:	f1250513          	addi	a0,a0,-238 # 7940 <malloc+0x19ba>
    3a36:	00002097          	auipc	ra,0x2
    3a3a:	14a080e7          	jalr	330(ra) # 5b80 <unlink>
    3a3e:	3e054c63          	bltz	a0,3e36 <subdir+0x78e>
  if (unlink("dd") < 0)
    3a42:	00004517          	auipc	a0,0x4
    3a46:	9ce50513          	addi	a0,a0,-1586 # 7410 <malloc+0x148a>
    3a4a:	00002097          	auipc	ra,0x2
    3a4e:	136080e7          	jalr	310(ra) # 5b80 <unlink>
    3a52:	40054063          	bltz	a0,3e52 <subdir+0x7aa>
}
    3a56:	60e2                	ld	ra,24(sp)
    3a58:	6442                	ld	s0,16(sp)
    3a5a:	64a2                	ld	s1,8(sp)
    3a5c:	6902                	ld	s2,0(sp)
    3a5e:	6105                	addi	sp,sp,32
    3a60:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3a62:	85ca                	mv	a1,s2
    3a64:	00004517          	auipc	a0,0x4
    3a68:	9b450513          	addi	a0,a0,-1612 # 7418 <malloc+0x1492>
    3a6c:	00002097          	auipc	ra,0x2
    3a70:	45c080e7          	jalr	1116(ra) # 5ec8 <printf>
    exit(1);
    3a74:	4505                	li	a0,1
    3a76:	00002097          	auipc	ra,0x2
    3a7a:	0ba080e7          	jalr	186(ra) # 5b30 <exit>
    printf("%s: create dd/ff failed\n", s);
    3a7e:	85ca                	mv	a1,s2
    3a80:	00004517          	auipc	a0,0x4
    3a84:	9b850513          	addi	a0,a0,-1608 # 7438 <malloc+0x14b2>
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	440080e7          	jalr	1088(ra) # 5ec8 <printf>
    exit(1);
    3a90:	4505                	li	a0,1
    3a92:	00002097          	auipc	ra,0x2
    3a96:	09e080e7          	jalr	158(ra) # 5b30 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3a9a:	85ca                	mv	a1,s2
    3a9c:	00004517          	auipc	a0,0x4
    3aa0:	9bc50513          	addi	a0,a0,-1604 # 7458 <malloc+0x14d2>
    3aa4:	00002097          	auipc	ra,0x2
    3aa8:	424080e7          	jalr	1060(ra) # 5ec8 <printf>
    exit(1);
    3aac:	4505                	li	a0,1
    3aae:	00002097          	auipc	ra,0x2
    3ab2:	082080e7          	jalr	130(ra) # 5b30 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3ab6:	85ca                	mv	a1,s2
    3ab8:	00004517          	auipc	a0,0x4
    3abc:	9d850513          	addi	a0,a0,-1576 # 7490 <malloc+0x150a>
    3ac0:	00002097          	auipc	ra,0x2
    3ac4:	408080e7          	jalr	1032(ra) # 5ec8 <printf>
    exit(1);
    3ac8:	4505                	li	a0,1
    3aca:	00002097          	auipc	ra,0x2
    3ace:	066080e7          	jalr	102(ra) # 5b30 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3ad2:	85ca                	mv	a1,s2
    3ad4:	00004517          	auipc	a0,0x4
    3ad8:	9ec50513          	addi	a0,a0,-1556 # 74c0 <malloc+0x153a>
    3adc:	00002097          	auipc	ra,0x2
    3ae0:	3ec080e7          	jalr	1004(ra) # 5ec8 <printf>
    exit(1);
    3ae4:	4505                	li	a0,1
    3ae6:	00002097          	auipc	ra,0x2
    3aea:	04a080e7          	jalr	74(ra) # 5b30 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3aee:	85ca                	mv	a1,s2
    3af0:	00004517          	auipc	a0,0x4
    3af4:	a0850513          	addi	a0,a0,-1528 # 74f8 <malloc+0x1572>
    3af8:	00002097          	auipc	ra,0x2
    3afc:	3d0080e7          	jalr	976(ra) # 5ec8 <printf>
    exit(1);
    3b00:	4505                	li	a0,1
    3b02:	00002097          	auipc	ra,0x2
    3b06:	02e080e7          	jalr	46(ra) # 5b30 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3b0a:	85ca                	mv	a1,s2
    3b0c:	00004517          	auipc	a0,0x4
    3b10:	a0c50513          	addi	a0,a0,-1524 # 7518 <malloc+0x1592>
    3b14:	00002097          	auipc	ra,0x2
    3b18:	3b4080e7          	jalr	948(ra) # 5ec8 <printf>
    exit(1);
    3b1c:	4505                	li	a0,1
    3b1e:	00002097          	auipc	ra,0x2
    3b22:	012080e7          	jalr	18(ra) # 5b30 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3b26:	85ca                	mv	a1,s2
    3b28:	00004517          	auipc	a0,0x4
    3b2c:	a2050513          	addi	a0,a0,-1504 # 7548 <malloc+0x15c2>
    3b30:	00002097          	auipc	ra,0x2
    3b34:	398080e7          	jalr	920(ra) # 5ec8 <printf>
    exit(1);
    3b38:	4505                	li	a0,1
    3b3a:	00002097          	auipc	ra,0x2
    3b3e:	ff6080e7          	jalr	-10(ra) # 5b30 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3b42:	85ca                	mv	a1,s2
    3b44:	00004517          	auipc	a0,0x4
    3b48:	a2c50513          	addi	a0,a0,-1492 # 7570 <malloc+0x15ea>
    3b4c:	00002097          	auipc	ra,0x2
    3b50:	37c080e7          	jalr	892(ra) # 5ec8 <printf>
    exit(1);
    3b54:	4505                	li	a0,1
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	fda080e7          	jalr	-38(ra) # 5b30 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3b5e:	85ca                	mv	a1,s2
    3b60:	00004517          	auipc	a0,0x4
    3b64:	a3050513          	addi	a0,a0,-1488 # 7590 <malloc+0x160a>
    3b68:	00002097          	auipc	ra,0x2
    3b6c:	360080e7          	jalr	864(ra) # 5ec8 <printf>
    exit(1);
    3b70:	4505                	li	a0,1
    3b72:	00002097          	auipc	ra,0x2
    3b76:	fbe080e7          	jalr	-66(ra) # 5b30 <exit>
    printf("%s: chdir dd failed\n", s);
    3b7a:	85ca                	mv	a1,s2
    3b7c:	00004517          	auipc	a0,0x4
    3b80:	a3c50513          	addi	a0,a0,-1476 # 75b8 <malloc+0x1632>
    3b84:	00002097          	auipc	ra,0x2
    3b88:	344080e7          	jalr	836(ra) # 5ec8 <printf>
    exit(1);
    3b8c:	4505                	li	a0,1
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	fa2080e7          	jalr	-94(ra) # 5b30 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3b96:	85ca                	mv	a1,s2
    3b98:	00004517          	auipc	a0,0x4
    3b9c:	a4850513          	addi	a0,a0,-1464 # 75e0 <malloc+0x165a>
    3ba0:	00002097          	auipc	ra,0x2
    3ba4:	328080e7          	jalr	808(ra) # 5ec8 <printf>
    exit(1);
    3ba8:	4505                	li	a0,1
    3baa:	00002097          	auipc	ra,0x2
    3bae:	f86080e7          	jalr	-122(ra) # 5b30 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3bb2:	85ca                	mv	a1,s2
    3bb4:	00004517          	auipc	a0,0x4
    3bb8:	a5c50513          	addi	a0,a0,-1444 # 7610 <malloc+0x168a>
    3bbc:	00002097          	auipc	ra,0x2
    3bc0:	30c080e7          	jalr	780(ra) # 5ec8 <printf>
    exit(1);
    3bc4:	4505                	li	a0,1
    3bc6:	00002097          	auipc	ra,0x2
    3bca:	f6a080e7          	jalr	-150(ra) # 5b30 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3bce:	85ca                	mv	a1,s2
    3bd0:	00004517          	auipc	a0,0x4
    3bd4:	a6850513          	addi	a0,a0,-1432 # 7638 <malloc+0x16b2>
    3bd8:	00002097          	auipc	ra,0x2
    3bdc:	2f0080e7          	jalr	752(ra) # 5ec8 <printf>
    exit(1);
    3be0:	4505                	li	a0,1
    3be2:	00002097          	auipc	ra,0x2
    3be6:	f4e080e7          	jalr	-178(ra) # 5b30 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3bea:	85ca                	mv	a1,s2
    3bec:	00004517          	auipc	a0,0x4
    3bf0:	a6450513          	addi	a0,a0,-1436 # 7650 <malloc+0x16ca>
    3bf4:	00002097          	auipc	ra,0x2
    3bf8:	2d4080e7          	jalr	724(ra) # 5ec8 <printf>
    exit(1);
    3bfc:	4505                	li	a0,1
    3bfe:	00002097          	auipc	ra,0x2
    3c02:	f32080e7          	jalr	-206(ra) # 5b30 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3c06:	85ca                	mv	a1,s2
    3c08:	00004517          	auipc	a0,0x4
    3c0c:	a6850513          	addi	a0,a0,-1432 # 7670 <malloc+0x16ea>
    3c10:	00002097          	auipc	ra,0x2
    3c14:	2b8080e7          	jalr	696(ra) # 5ec8 <printf>
    exit(1);
    3c18:	4505                	li	a0,1
    3c1a:	00002097          	auipc	ra,0x2
    3c1e:	f16080e7          	jalr	-234(ra) # 5b30 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3c22:	85ca                	mv	a1,s2
    3c24:	00004517          	auipc	a0,0x4
    3c28:	a6c50513          	addi	a0,a0,-1428 # 7690 <malloc+0x170a>
    3c2c:	00002097          	auipc	ra,0x2
    3c30:	29c080e7          	jalr	668(ra) # 5ec8 <printf>
    exit(1);
    3c34:	4505                	li	a0,1
    3c36:	00002097          	auipc	ra,0x2
    3c3a:	efa080e7          	jalr	-262(ra) # 5b30 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3c3e:	85ca                	mv	a1,s2
    3c40:	00004517          	auipc	a0,0x4
    3c44:	a9050513          	addi	a0,a0,-1392 # 76d0 <malloc+0x174a>
    3c48:	00002097          	auipc	ra,0x2
    3c4c:	280080e7          	jalr	640(ra) # 5ec8 <printf>
    exit(1);
    3c50:	4505                	li	a0,1
    3c52:	00002097          	auipc	ra,0x2
    3c56:	ede080e7          	jalr	-290(ra) # 5b30 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3c5a:	85ca                	mv	a1,s2
    3c5c:	00004517          	auipc	a0,0x4
    3c60:	aa450513          	addi	a0,a0,-1372 # 7700 <malloc+0x177a>
    3c64:	00002097          	auipc	ra,0x2
    3c68:	264080e7          	jalr	612(ra) # 5ec8 <printf>
    exit(1);
    3c6c:	4505                	li	a0,1
    3c6e:	00002097          	auipc	ra,0x2
    3c72:	ec2080e7          	jalr	-318(ra) # 5b30 <exit>
    printf("%s: create dd succeeded!\n", s);
    3c76:	85ca                	mv	a1,s2
    3c78:	00004517          	auipc	a0,0x4
    3c7c:	aa850513          	addi	a0,a0,-1368 # 7720 <malloc+0x179a>
    3c80:	00002097          	auipc	ra,0x2
    3c84:	248080e7          	jalr	584(ra) # 5ec8 <printf>
    exit(1);
    3c88:	4505                	li	a0,1
    3c8a:	00002097          	auipc	ra,0x2
    3c8e:	ea6080e7          	jalr	-346(ra) # 5b30 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3c92:	85ca                	mv	a1,s2
    3c94:	00004517          	auipc	a0,0x4
    3c98:	aac50513          	addi	a0,a0,-1364 # 7740 <malloc+0x17ba>
    3c9c:	00002097          	auipc	ra,0x2
    3ca0:	22c080e7          	jalr	556(ra) # 5ec8 <printf>
    exit(1);
    3ca4:	4505                	li	a0,1
    3ca6:	00002097          	auipc	ra,0x2
    3caa:	e8a080e7          	jalr	-374(ra) # 5b30 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3cae:	85ca                	mv	a1,s2
    3cb0:	00004517          	auipc	a0,0x4
    3cb4:	ab050513          	addi	a0,a0,-1360 # 7760 <malloc+0x17da>
    3cb8:	00002097          	auipc	ra,0x2
    3cbc:	210080e7          	jalr	528(ra) # 5ec8 <printf>
    exit(1);
    3cc0:	4505                	li	a0,1
    3cc2:	00002097          	auipc	ra,0x2
    3cc6:	e6e080e7          	jalr	-402(ra) # 5b30 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3cca:	85ca                	mv	a1,s2
    3ccc:	00004517          	auipc	a0,0x4
    3cd0:	ac450513          	addi	a0,a0,-1340 # 7790 <malloc+0x180a>
    3cd4:	00002097          	auipc	ra,0x2
    3cd8:	1f4080e7          	jalr	500(ra) # 5ec8 <printf>
    exit(1);
    3cdc:	4505                	li	a0,1
    3cde:	00002097          	auipc	ra,0x2
    3ce2:	e52080e7          	jalr	-430(ra) # 5b30 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3ce6:	85ca                	mv	a1,s2
    3ce8:	00004517          	auipc	a0,0x4
    3cec:	ad050513          	addi	a0,a0,-1328 # 77b8 <malloc+0x1832>
    3cf0:	00002097          	auipc	ra,0x2
    3cf4:	1d8080e7          	jalr	472(ra) # 5ec8 <printf>
    exit(1);
    3cf8:	4505                	li	a0,1
    3cfa:	00002097          	auipc	ra,0x2
    3cfe:	e36080e7          	jalr	-458(ra) # 5b30 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3d02:	85ca                	mv	a1,s2
    3d04:	00004517          	auipc	a0,0x4
    3d08:	adc50513          	addi	a0,a0,-1316 # 77e0 <malloc+0x185a>
    3d0c:	00002097          	auipc	ra,0x2
    3d10:	1bc080e7          	jalr	444(ra) # 5ec8 <printf>
    exit(1);
    3d14:	4505                	li	a0,1
    3d16:	00002097          	auipc	ra,0x2
    3d1a:	e1a080e7          	jalr	-486(ra) # 5b30 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3d1e:	85ca                	mv	a1,s2
    3d20:	00004517          	auipc	a0,0x4
    3d24:	ae850513          	addi	a0,a0,-1304 # 7808 <malloc+0x1882>
    3d28:	00002097          	auipc	ra,0x2
    3d2c:	1a0080e7          	jalr	416(ra) # 5ec8 <printf>
    exit(1);
    3d30:	4505                	li	a0,1
    3d32:	00002097          	auipc	ra,0x2
    3d36:	dfe080e7          	jalr	-514(ra) # 5b30 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3d3a:	85ca                	mv	a1,s2
    3d3c:	00004517          	auipc	a0,0x4
    3d40:	aec50513          	addi	a0,a0,-1300 # 7828 <malloc+0x18a2>
    3d44:	00002097          	auipc	ra,0x2
    3d48:	184080e7          	jalr	388(ra) # 5ec8 <printf>
    exit(1);
    3d4c:	4505                	li	a0,1
    3d4e:	00002097          	auipc	ra,0x2
    3d52:	de2080e7          	jalr	-542(ra) # 5b30 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3d56:	85ca                	mv	a1,s2
    3d58:	00004517          	auipc	a0,0x4
    3d5c:	af050513          	addi	a0,a0,-1296 # 7848 <malloc+0x18c2>
    3d60:	00002097          	auipc	ra,0x2
    3d64:	168080e7          	jalr	360(ra) # 5ec8 <printf>
    exit(1);
    3d68:	4505                	li	a0,1
    3d6a:	00002097          	auipc	ra,0x2
    3d6e:	dc6080e7          	jalr	-570(ra) # 5b30 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3d72:	85ca                	mv	a1,s2
    3d74:	00004517          	auipc	a0,0x4
    3d78:	afc50513          	addi	a0,a0,-1284 # 7870 <malloc+0x18ea>
    3d7c:	00002097          	auipc	ra,0x2
    3d80:	14c080e7          	jalr	332(ra) # 5ec8 <printf>
    exit(1);
    3d84:	4505                	li	a0,1
    3d86:	00002097          	auipc	ra,0x2
    3d8a:	daa080e7          	jalr	-598(ra) # 5b30 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3d8e:	85ca                	mv	a1,s2
    3d90:	00004517          	auipc	a0,0x4
    3d94:	b0050513          	addi	a0,a0,-1280 # 7890 <malloc+0x190a>
    3d98:	00002097          	auipc	ra,0x2
    3d9c:	130080e7          	jalr	304(ra) # 5ec8 <printf>
    exit(1);
    3da0:	4505                	li	a0,1
    3da2:	00002097          	auipc	ra,0x2
    3da6:	d8e080e7          	jalr	-626(ra) # 5b30 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3daa:	85ca                	mv	a1,s2
    3dac:	00004517          	auipc	a0,0x4
    3db0:	b0450513          	addi	a0,a0,-1276 # 78b0 <malloc+0x192a>
    3db4:	00002097          	auipc	ra,0x2
    3db8:	114080e7          	jalr	276(ra) # 5ec8 <printf>
    exit(1);
    3dbc:	4505                	li	a0,1
    3dbe:	00002097          	auipc	ra,0x2
    3dc2:	d72080e7          	jalr	-654(ra) # 5b30 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3dc6:	85ca                	mv	a1,s2
    3dc8:	00004517          	auipc	a0,0x4
    3dcc:	b1050513          	addi	a0,a0,-1264 # 78d8 <malloc+0x1952>
    3dd0:	00002097          	auipc	ra,0x2
    3dd4:	0f8080e7          	jalr	248(ra) # 5ec8 <printf>
    exit(1);
    3dd8:	4505                	li	a0,1
    3dda:	00002097          	auipc	ra,0x2
    3dde:	d56080e7          	jalr	-682(ra) # 5b30 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3de2:	85ca                	mv	a1,s2
    3de4:	00003517          	auipc	a0,0x3
    3de8:	78c50513          	addi	a0,a0,1932 # 7570 <malloc+0x15ea>
    3dec:	00002097          	auipc	ra,0x2
    3df0:	0dc080e7          	jalr	220(ra) # 5ec8 <printf>
    exit(1);
    3df4:	4505                	li	a0,1
    3df6:	00002097          	auipc	ra,0x2
    3dfa:	d3a080e7          	jalr	-710(ra) # 5b30 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3dfe:	85ca                	mv	a1,s2
    3e00:	00004517          	auipc	a0,0x4
    3e04:	af850513          	addi	a0,a0,-1288 # 78f8 <malloc+0x1972>
    3e08:	00002097          	auipc	ra,0x2
    3e0c:	0c0080e7          	jalr	192(ra) # 5ec8 <printf>
    exit(1);
    3e10:	4505                	li	a0,1
    3e12:	00002097          	auipc	ra,0x2
    3e16:	d1e080e7          	jalr	-738(ra) # 5b30 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3e1a:	85ca                	mv	a1,s2
    3e1c:	00004517          	auipc	a0,0x4
    3e20:	afc50513          	addi	a0,a0,-1284 # 7918 <malloc+0x1992>
    3e24:	00002097          	auipc	ra,0x2
    3e28:	0a4080e7          	jalr	164(ra) # 5ec8 <printf>
    exit(1);
    3e2c:	4505                	li	a0,1
    3e2e:	00002097          	auipc	ra,0x2
    3e32:	d02080e7          	jalr	-766(ra) # 5b30 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3e36:	85ca                	mv	a1,s2
    3e38:	00004517          	auipc	a0,0x4
    3e3c:	b1050513          	addi	a0,a0,-1264 # 7948 <malloc+0x19c2>
    3e40:	00002097          	auipc	ra,0x2
    3e44:	088080e7          	jalr	136(ra) # 5ec8 <printf>
    exit(1);
    3e48:	4505                	li	a0,1
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	ce6080e7          	jalr	-794(ra) # 5b30 <exit>
    printf("%s: unlink dd failed\n", s);
    3e52:	85ca                	mv	a1,s2
    3e54:	00004517          	auipc	a0,0x4
    3e58:	b1450513          	addi	a0,a0,-1260 # 7968 <malloc+0x19e2>
    3e5c:	00002097          	auipc	ra,0x2
    3e60:	06c080e7          	jalr	108(ra) # 5ec8 <printf>
    exit(1);
    3e64:	4505                	li	a0,1
    3e66:	00002097          	auipc	ra,0x2
    3e6a:	cca080e7          	jalr	-822(ra) # 5b30 <exit>

0000000000003e6e <rmdot>:
{
    3e6e:	1101                	addi	sp,sp,-32
    3e70:	ec06                	sd	ra,24(sp)
    3e72:	e822                	sd	s0,16(sp)
    3e74:	e426                	sd	s1,8(sp)
    3e76:	1000                	addi	s0,sp,32
    3e78:	84aa                	mv	s1,a0
  if (mkdir("dots") != 0)
    3e7a:	00004517          	auipc	a0,0x4
    3e7e:	b0650513          	addi	a0,a0,-1274 # 7980 <malloc+0x19fa>
    3e82:	00002097          	auipc	ra,0x2
    3e86:	d16080e7          	jalr	-746(ra) # 5b98 <mkdir>
    3e8a:	e549                	bnez	a0,3f14 <rmdot+0xa6>
  if (chdir("dots") != 0)
    3e8c:	00004517          	auipc	a0,0x4
    3e90:	af450513          	addi	a0,a0,-1292 # 7980 <malloc+0x19fa>
    3e94:	00002097          	auipc	ra,0x2
    3e98:	d0c080e7          	jalr	-756(ra) # 5ba0 <chdir>
    3e9c:	e951                	bnez	a0,3f30 <rmdot+0xc2>
  if (unlink(".") == 0)
    3e9e:	00003517          	auipc	a0,0x3
    3ea2:	91250513          	addi	a0,a0,-1774 # 67b0 <malloc+0x82a>
    3ea6:	00002097          	auipc	ra,0x2
    3eaa:	cda080e7          	jalr	-806(ra) # 5b80 <unlink>
    3eae:	cd59                	beqz	a0,3f4c <rmdot+0xde>
  if (unlink("..") == 0)
    3eb0:	00003517          	auipc	a0,0x3
    3eb4:	52850513          	addi	a0,a0,1320 # 73d8 <malloc+0x1452>
    3eb8:	00002097          	auipc	ra,0x2
    3ebc:	cc8080e7          	jalr	-824(ra) # 5b80 <unlink>
    3ec0:	c545                	beqz	a0,3f68 <rmdot+0xfa>
  if (chdir("/") != 0)
    3ec2:	00003517          	auipc	a0,0x3
    3ec6:	4be50513          	addi	a0,a0,1214 # 7380 <malloc+0x13fa>
    3eca:	00002097          	auipc	ra,0x2
    3ece:	cd6080e7          	jalr	-810(ra) # 5ba0 <chdir>
    3ed2:	e94d                	bnez	a0,3f84 <rmdot+0x116>
  if (unlink("dots/.") == 0)
    3ed4:	00004517          	auipc	a0,0x4
    3ed8:	b1450513          	addi	a0,a0,-1260 # 79e8 <malloc+0x1a62>
    3edc:	00002097          	auipc	ra,0x2
    3ee0:	ca4080e7          	jalr	-860(ra) # 5b80 <unlink>
    3ee4:	cd55                	beqz	a0,3fa0 <rmdot+0x132>
  if (unlink("dots/..") == 0)
    3ee6:	00004517          	auipc	a0,0x4
    3eea:	b2a50513          	addi	a0,a0,-1238 # 7a10 <malloc+0x1a8a>
    3eee:	00002097          	auipc	ra,0x2
    3ef2:	c92080e7          	jalr	-878(ra) # 5b80 <unlink>
    3ef6:	c179                	beqz	a0,3fbc <rmdot+0x14e>
  if (unlink("dots") != 0)
    3ef8:	00004517          	auipc	a0,0x4
    3efc:	a8850513          	addi	a0,a0,-1400 # 7980 <malloc+0x19fa>
    3f00:	00002097          	auipc	ra,0x2
    3f04:	c80080e7          	jalr	-896(ra) # 5b80 <unlink>
    3f08:	e961                	bnez	a0,3fd8 <rmdot+0x16a>
}
    3f0a:	60e2                	ld	ra,24(sp)
    3f0c:	6442                	ld	s0,16(sp)
    3f0e:	64a2                	ld	s1,8(sp)
    3f10:	6105                	addi	sp,sp,32
    3f12:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3f14:	85a6                	mv	a1,s1
    3f16:	00004517          	auipc	a0,0x4
    3f1a:	a7250513          	addi	a0,a0,-1422 # 7988 <malloc+0x1a02>
    3f1e:	00002097          	auipc	ra,0x2
    3f22:	faa080e7          	jalr	-86(ra) # 5ec8 <printf>
    exit(1);
    3f26:	4505                	li	a0,1
    3f28:	00002097          	auipc	ra,0x2
    3f2c:	c08080e7          	jalr	-1016(ra) # 5b30 <exit>
    printf("%s: chdir dots failed\n", s);
    3f30:	85a6                	mv	a1,s1
    3f32:	00004517          	auipc	a0,0x4
    3f36:	a6e50513          	addi	a0,a0,-1426 # 79a0 <malloc+0x1a1a>
    3f3a:	00002097          	auipc	ra,0x2
    3f3e:	f8e080e7          	jalr	-114(ra) # 5ec8 <printf>
    exit(1);
    3f42:	4505                	li	a0,1
    3f44:	00002097          	auipc	ra,0x2
    3f48:	bec080e7          	jalr	-1044(ra) # 5b30 <exit>
    printf("%s: rm . worked!\n", s);
    3f4c:	85a6                	mv	a1,s1
    3f4e:	00004517          	auipc	a0,0x4
    3f52:	a6a50513          	addi	a0,a0,-1430 # 79b8 <malloc+0x1a32>
    3f56:	00002097          	auipc	ra,0x2
    3f5a:	f72080e7          	jalr	-142(ra) # 5ec8 <printf>
    exit(1);
    3f5e:	4505                	li	a0,1
    3f60:	00002097          	auipc	ra,0x2
    3f64:	bd0080e7          	jalr	-1072(ra) # 5b30 <exit>
    printf("%s: rm .. worked!\n", s);
    3f68:	85a6                	mv	a1,s1
    3f6a:	00004517          	auipc	a0,0x4
    3f6e:	a6650513          	addi	a0,a0,-1434 # 79d0 <malloc+0x1a4a>
    3f72:	00002097          	auipc	ra,0x2
    3f76:	f56080e7          	jalr	-170(ra) # 5ec8 <printf>
    exit(1);
    3f7a:	4505                	li	a0,1
    3f7c:	00002097          	auipc	ra,0x2
    3f80:	bb4080e7          	jalr	-1100(ra) # 5b30 <exit>
    printf("%s: chdir / failed\n", s);
    3f84:	85a6                	mv	a1,s1
    3f86:	00003517          	auipc	a0,0x3
    3f8a:	40250513          	addi	a0,a0,1026 # 7388 <malloc+0x1402>
    3f8e:	00002097          	auipc	ra,0x2
    3f92:	f3a080e7          	jalr	-198(ra) # 5ec8 <printf>
    exit(1);
    3f96:	4505                	li	a0,1
    3f98:	00002097          	auipc	ra,0x2
    3f9c:	b98080e7          	jalr	-1128(ra) # 5b30 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3fa0:	85a6                	mv	a1,s1
    3fa2:	00004517          	auipc	a0,0x4
    3fa6:	a4e50513          	addi	a0,a0,-1458 # 79f0 <malloc+0x1a6a>
    3faa:	00002097          	auipc	ra,0x2
    3fae:	f1e080e7          	jalr	-226(ra) # 5ec8 <printf>
    exit(1);
    3fb2:	4505                	li	a0,1
    3fb4:	00002097          	auipc	ra,0x2
    3fb8:	b7c080e7          	jalr	-1156(ra) # 5b30 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3fbc:	85a6                	mv	a1,s1
    3fbe:	00004517          	auipc	a0,0x4
    3fc2:	a5a50513          	addi	a0,a0,-1446 # 7a18 <malloc+0x1a92>
    3fc6:	00002097          	auipc	ra,0x2
    3fca:	f02080e7          	jalr	-254(ra) # 5ec8 <printf>
    exit(1);
    3fce:	4505                	li	a0,1
    3fd0:	00002097          	auipc	ra,0x2
    3fd4:	b60080e7          	jalr	-1184(ra) # 5b30 <exit>
    printf("%s: unlink dots failed!\n", s);
    3fd8:	85a6                	mv	a1,s1
    3fda:	00004517          	auipc	a0,0x4
    3fde:	a5e50513          	addi	a0,a0,-1442 # 7a38 <malloc+0x1ab2>
    3fe2:	00002097          	auipc	ra,0x2
    3fe6:	ee6080e7          	jalr	-282(ra) # 5ec8 <printf>
    exit(1);
    3fea:	4505                	li	a0,1
    3fec:	00002097          	auipc	ra,0x2
    3ff0:	b44080e7          	jalr	-1212(ra) # 5b30 <exit>

0000000000003ff4 <dirfile>:
{
    3ff4:	1101                	addi	sp,sp,-32
    3ff6:	ec06                	sd	ra,24(sp)
    3ff8:	e822                	sd	s0,16(sp)
    3ffa:	e426                	sd	s1,8(sp)
    3ffc:	e04a                	sd	s2,0(sp)
    3ffe:	1000                	addi	s0,sp,32
    4000:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    4002:	20000593          	li	a1,512
    4006:	00004517          	auipc	a0,0x4
    400a:	a5250513          	addi	a0,a0,-1454 # 7a58 <malloc+0x1ad2>
    400e:	00002097          	auipc	ra,0x2
    4012:	b62080e7          	jalr	-1182(ra) # 5b70 <open>
  if (fd < 0)
    4016:	0e054d63          	bltz	a0,4110 <dirfile+0x11c>
  close(fd);
    401a:	00002097          	auipc	ra,0x2
    401e:	b3e080e7          	jalr	-1218(ra) # 5b58 <close>
  if (chdir("dirfile") == 0)
    4022:	00004517          	auipc	a0,0x4
    4026:	a3650513          	addi	a0,a0,-1482 # 7a58 <malloc+0x1ad2>
    402a:	00002097          	auipc	ra,0x2
    402e:	b76080e7          	jalr	-1162(ra) # 5ba0 <chdir>
    4032:	cd6d                	beqz	a0,412c <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    4034:	4581                	li	a1,0
    4036:	00004517          	auipc	a0,0x4
    403a:	a6a50513          	addi	a0,a0,-1430 # 7aa0 <malloc+0x1b1a>
    403e:	00002097          	auipc	ra,0x2
    4042:	b32080e7          	jalr	-1230(ra) # 5b70 <open>
  if (fd >= 0)
    4046:	10055163          	bgez	a0,4148 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    404a:	20000593          	li	a1,512
    404e:	00004517          	auipc	a0,0x4
    4052:	a5250513          	addi	a0,a0,-1454 # 7aa0 <malloc+0x1b1a>
    4056:	00002097          	auipc	ra,0x2
    405a:	b1a080e7          	jalr	-1254(ra) # 5b70 <open>
  if (fd >= 0)
    405e:	10055363          	bgez	a0,4164 <dirfile+0x170>
  if (mkdir("dirfile/xx") == 0)
    4062:	00004517          	auipc	a0,0x4
    4066:	a3e50513          	addi	a0,a0,-1474 # 7aa0 <malloc+0x1b1a>
    406a:	00002097          	auipc	ra,0x2
    406e:	b2e080e7          	jalr	-1234(ra) # 5b98 <mkdir>
    4072:	10050763          	beqz	a0,4180 <dirfile+0x18c>
  if (unlink("dirfile/xx") == 0)
    4076:	00004517          	auipc	a0,0x4
    407a:	a2a50513          	addi	a0,a0,-1494 # 7aa0 <malloc+0x1b1a>
    407e:	00002097          	auipc	ra,0x2
    4082:	b02080e7          	jalr	-1278(ra) # 5b80 <unlink>
    4086:	10050b63          	beqz	a0,419c <dirfile+0x1a8>
  if (link("README", "dirfile/xx") == 0)
    408a:	00004597          	auipc	a1,0x4
    408e:	a1658593          	addi	a1,a1,-1514 # 7aa0 <malloc+0x1b1a>
    4092:	00002517          	auipc	a0,0x2
    4096:	20e50513          	addi	a0,a0,526 # 62a0 <malloc+0x31a>
    409a:	00002097          	auipc	ra,0x2
    409e:	af6080e7          	jalr	-1290(ra) # 5b90 <link>
    40a2:	10050b63          	beqz	a0,41b8 <dirfile+0x1c4>
  if (unlink("dirfile") != 0)
    40a6:	00004517          	auipc	a0,0x4
    40aa:	9b250513          	addi	a0,a0,-1614 # 7a58 <malloc+0x1ad2>
    40ae:	00002097          	auipc	ra,0x2
    40b2:	ad2080e7          	jalr	-1326(ra) # 5b80 <unlink>
    40b6:	10051f63          	bnez	a0,41d4 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    40ba:	4589                	li	a1,2
    40bc:	00002517          	auipc	a0,0x2
    40c0:	6f450513          	addi	a0,a0,1780 # 67b0 <malloc+0x82a>
    40c4:	00002097          	auipc	ra,0x2
    40c8:	aac080e7          	jalr	-1364(ra) # 5b70 <open>
  if (fd >= 0)
    40cc:	12055263          	bgez	a0,41f0 <dirfile+0x1fc>
  fd = open(".", 0);
    40d0:	4581                	li	a1,0
    40d2:	00002517          	auipc	a0,0x2
    40d6:	6de50513          	addi	a0,a0,1758 # 67b0 <malloc+0x82a>
    40da:	00002097          	auipc	ra,0x2
    40de:	a96080e7          	jalr	-1386(ra) # 5b70 <open>
    40e2:	84aa                	mv	s1,a0
  if (write(fd, "x", 1) > 0)
    40e4:	4605                	li	a2,1
    40e6:	00002597          	auipc	a1,0x2
    40ea:	05258593          	addi	a1,a1,82 # 6138 <malloc+0x1b2>
    40ee:	00002097          	auipc	ra,0x2
    40f2:	a62080e7          	jalr	-1438(ra) # 5b50 <write>
    40f6:	10a04b63          	bgtz	a0,420c <dirfile+0x218>
  close(fd);
    40fa:	8526                	mv	a0,s1
    40fc:	00002097          	auipc	ra,0x2
    4100:	a5c080e7          	jalr	-1444(ra) # 5b58 <close>
}
    4104:	60e2                	ld	ra,24(sp)
    4106:	6442                	ld	s0,16(sp)
    4108:	64a2                	ld	s1,8(sp)
    410a:	6902                	ld	s2,0(sp)
    410c:	6105                	addi	sp,sp,32
    410e:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    4110:	85ca                	mv	a1,s2
    4112:	00004517          	auipc	a0,0x4
    4116:	94e50513          	addi	a0,a0,-1714 # 7a60 <malloc+0x1ada>
    411a:	00002097          	auipc	ra,0x2
    411e:	dae080e7          	jalr	-594(ra) # 5ec8 <printf>
    exit(1);
    4122:	4505                	li	a0,1
    4124:	00002097          	auipc	ra,0x2
    4128:	a0c080e7          	jalr	-1524(ra) # 5b30 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    412c:	85ca                	mv	a1,s2
    412e:	00004517          	auipc	a0,0x4
    4132:	95250513          	addi	a0,a0,-1710 # 7a80 <malloc+0x1afa>
    4136:	00002097          	auipc	ra,0x2
    413a:	d92080e7          	jalr	-622(ra) # 5ec8 <printf>
    exit(1);
    413e:	4505                	li	a0,1
    4140:	00002097          	auipc	ra,0x2
    4144:	9f0080e7          	jalr	-1552(ra) # 5b30 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4148:	85ca                	mv	a1,s2
    414a:	00004517          	auipc	a0,0x4
    414e:	96650513          	addi	a0,a0,-1690 # 7ab0 <malloc+0x1b2a>
    4152:	00002097          	auipc	ra,0x2
    4156:	d76080e7          	jalr	-650(ra) # 5ec8 <printf>
    exit(1);
    415a:	4505                	li	a0,1
    415c:	00002097          	auipc	ra,0x2
    4160:	9d4080e7          	jalr	-1580(ra) # 5b30 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4164:	85ca                	mv	a1,s2
    4166:	00004517          	auipc	a0,0x4
    416a:	94a50513          	addi	a0,a0,-1718 # 7ab0 <malloc+0x1b2a>
    416e:	00002097          	auipc	ra,0x2
    4172:	d5a080e7          	jalr	-678(ra) # 5ec8 <printf>
    exit(1);
    4176:	4505                	li	a0,1
    4178:	00002097          	auipc	ra,0x2
    417c:	9b8080e7          	jalr	-1608(ra) # 5b30 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    4180:	85ca                	mv	a1,s2
    4182:	00004517          	auipc	a0,0x4
    4186:	95650513          	addi	a0,a0,-1706 # 7ad8 <malloc+0x1b52>
    418a:	00002097          	auipc	ra,0x2
    418e:	d3e080e7          	jalr	-706(ra) # 5ec8 <printf>
    exit(1);
    4192:	4505                	li	a0,1
    4194:	00002097          	auipc	ra,0x2
    4198:	99c080e7          	jalr	-1636(ra) # 5b30 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    419c:	85ca                	mv	a1,s2
    419e:	00004517          	auipc	a0,0x4
    41a2:	96250513          	addi	a0,a0,-1694 # 7b00 <malloc+0x1b7a>
    41a6:	00002097          	auipc	ra,0x2
    41aa:	d22080e7          	jalr	-734(ra) # 5ec8 <printf>
    exit(1);
    41ae:	4505                	li	a0,1
    41b0:	00002097          	auipc	ra,0x2
    41b4:	980080e7          	jalr	-1664(ra) # 5b30 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    41b8:	85ca                	mv	a1,s2
    41ba:	00004517          	auipc	a0,0x4
    41be:	96e50513          	addi	a0,a0,-1682 # 7b28 <malloc+0x1ba2>
    41c2:	00002097          	auipc	ra,0x2
    41c6:	d06080e7          	jalr	-762(ra) # 5ec8 <printf>
    exit(1);
    41ca:	4505                	li	a0,1
    41cc:	00002097          	auipc	ra,0x2
    41d0:	964080e7          	jalr	-1692(ra) # 5b30 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    41d4:	85ca                	mv	a1,s2
    41d6:	00004517          	auipc	a0,0x4
    41da:	97a50513          	addi	a0,a0,-1670 # 7b50 <malloc+0x1bca>
    41de:	00002097          	auipc	ra,0x2
    41e2:	cea080e7          	jalr	-790(ra) # 5ec8 <printf>
    exit(1);
    41e6:	4505                	li	a0,1
    41e8:	00002097          	auipc	ra,0x2
    41ec:	948080e7          	jalr	-1720(ra) # 5b30 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    41f0:	85ca                	mv	a1,s2
    41f2:	00004517          	auipc	a0,0x4
    41f6:	97e50513          	addi	a0,a0,-1666 # 7b70 <malloc+0x1bea>
    41fa:	00002097          	auipc	ra,0x2
    41fe:	cce080e7          	jalr	-818(ra) # 5ec8 <printf>
    exit(1);
    4202:	4505                	li	a0,1
    4204:	00002097          	auipc	ra,0x2
    4208:	92c080e7          	jalr	-1748(ra) # 5b30 <exit>
    printf("%s: write . succeeded!\n", s);
    420c:	85ca                	mv	a1,s2
    420e:	00004517          	auipc	a0,0x4
    4212:	98a50513          	addi	a0,a0,-1654 # 7b98 <malloc+0x1c12>
    4216:	00002097          	auipc	ra,0x2
    421a:	cb2080e7          	jalr	-846(ra) # 5ec8 <printf>
    exit(1);
    421e:	4505                	li	a0,1
    4220:	00002097          	auipc	ra,0x2
    4224:	910080e7          	jalr	-1776(ra) # 5b30 <exit>

0000000000004228 <iref>:
{
    4228:	7139                	addi	sp,sp,-64
    422a:	fc06                	sd	ra,56(sp)
    422c:	f822                	sd	s0,48(sp)
    422e:	f426                	sd	s1,40(sp)
    4230:	f04a                	sd	s2,32(sp)
    4232:	ec4e                	sd	s3,24(sp)
    4234:	e852                	sd	s4,16(sp)
    4236:	e456                	sd	s5,8(sp)
    4238:	e05a                	sd	s6,0(sp)
    423a:	0080                	addi	s0,sp,64
    423c:	8b2a                	mv	s6,a0
    423e:	03300913          	li	s2,51
    if (mkdir("irefd") != 0)
    4242:	00004a17          	auipc	s4,0x4
    4246:	96ea0a13          	addi	s4,s4,-1682 # 7bb0 <malloc+0x1c2a>
    mkdir("");
    424a:	00003497          	auipc	s1,0x3
    424e:	46e48493          	addi	s1,s1,1134 # 76b8 <malloc+0x1732>
    link("README", "");
    4252:	00002a97          	auipc	s5,0x2
    4256:	04ea8a93          	addi	s5,s5,78 # 62a0 <malloc+0x31a>
    fd = open("xx", O_CREATE);
    425a:	00004997          	auipc	s3,0x4
    425e:	84e98993          	addi	s3,s3,-1970 # 7aa8 <malloc+0x1b22>
    4262:	a891                	j	42b6 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    4264:	85da                	mv	a1,s6
    4266:	00004517          	auipc	a0,0x4
    426a:	95250513          	addi	a0,a0,-1710 # 7bb8 <malloc+0x1c32>
    426e:	00002097          	auipc	ra,0x2
    4272:	c5a080e7          	jalr	-934(ra) # 5ec8 <printf>
      exit(1);
    4276:	4505                	li	a0,1
    4278:	00002097          	auipc	ra,0x2
    427c:	8b8080e7          	jalr	-1864(ra) # 5b30 <exit>
      printf("%s: chdir irefd failed\n", s);
    4280:	85da                	mv	a1,s6
    4282:	00004517          	auipc	a0,0x4
    4286:	94e50513          	addi	a0,a0,-1714 # 7bd0 <malloc+0x1c4a>
    428a:	00002097          	auipc	ra,0x2
    428e:	c3e080e7          	jalr	-962(ra) # 5ec8 <printf>
      exit(1);
    4292:	4505                	li	a0,1
    4294:	00002097          	auipc	ra,0x2
    4298:	89c080e7          	jalr	-1892(ra) # 5b30 <exit>
      close(fd);
    429c:	00002097          	auipc	ra,0x2
    42a0:	8bc080e7          	jalr	-1860(ra) # 5b58 <close>
    42a4:	a889                	j	42f6 <iref+0xce>
    unlink("xx");
    42a6:	854e                	mv	a0,s3
    42a8:	00002097          	auipc	ra,0x2
    42ac:	8d8080e7          	jalr	-1832(ra) # 5b80 <unlink>
  for (i = 0; i < NINODE + 1; i++)
    42b0:	397d                	addiw	s2,s2,-1
    42b2:	06090063          	beqz	s2,4312 <iref+0xea>
    if (mkdir("irefd") != 0)
    42b6:	8552                	mv	a0,s4
    42b8:	00002097          	auipc	ra,0x2
    42bc:	8e0080e7          	jalr	-1824(ra) # 5b98 <mkdir>
    42c0:	f155                	bnez	a0,4264 <iref+0x3c>
    if (chdir("irefd") != 0)
    42c2:	8552                	mv	a0,s4
    42c4:	00002097          	auipc	ra,0x2
    42c8:	8dc080e7          	jalr	-1828(ra) # 5ba0 <chdir>
    42cc:	f955                	bnez	a0,4280 <iref+0x58>
    mkdir("");
    42ce:	8526                	mv	a0,s1
    42d0:	00002097          	auipc	ra,0x2
    42d4:	8c8080e7          	jalr	-1848(ra) # 5b98 <mkdir>
    link("README", "");
    42d8:	85a6                	mv	a1,s1
    42da:	8556                	mv	a0,s5
    42dc:	00002097          	auipc	ra,0x2
    42e0:	8b4080e7          	jalr	-1868(ra) # 5b90 <link>
    fd = open("", O_CREATE);
    42e4:	20000593          	li	a1,512
    42e8:	8526                	mv	a0,s1
    42ea:	00002097          	auipc	ra,0x2
    42ee:	886080e7          	jalr	-1914(ra) # 5b70 <open>
    if (fd >= 0)
    42f2:	fa0555e3          	bgez	a0,429c <iref+0x74>
    fd = open("xx", O_CREATE);
    42f6:	20000593          	li	a1,512
    42fa:	854e                	mv	a0,s3
    42fc:	00002097          	auipc	ra,0x2
    4300:	874080e7          	jalr	-1932(ra) # 5b70 <open>
    if (fd >= 0)
    4304:	fa0541e3          	bltz	a0,42a6 <iref+0x7e>
      close(fd);
    4308:	00002097          	auipc	ra,0x2
    430c:	850080e7          	jalr	-1968(ra) # 5b58 <close>
    4310:	bf59                	j	42a6 <iref+0x7e>
    4312:	03300493          	li	s1,51
    chdir("..");
    4316:	00003997          	auipc	s3,0x3
    431a:	0c298993          	addi	s3,s3,194 # 73d8 <malloc+0x1452>
    unlink("irefd");
    431e:	00004917          	auipc	s2,0x4
    4322:	89290913          	addi	s2,s2,-1902 # 7bb0 <malloc+0x1c2a>
    chdir("..");
    4326:	854e                	mv	a0,s3
    4328:	00002097          	auipc	ra,0x2
    432c:	878080e7          	jalr	-1928(ra) # 5ba0 <chdir>
    unlink("irefd");
    4330:	854a                	mv	a0,s2
    4332:	00002097          	auipc	ra,0x2
    4336:	84e080e7          	jalr	-1970(ra) # 5b80 <unlink>
  for (i = 0; i < NINODE + 1; i++)
    433a:	34fd                	addiw	s1,s1,-1
    433c:	f4ed                	bnez	s1,4326 <iref+0xfe>
  chdir("/");
    433e:	00003517          	auipc	a0,0x3
    4342:	04250513          	addi	a0,a0,66 # 7380 <malloc+0x13fa>
    4346:	00002097          	auipc	ra,0x2
    434a:	85a080e7          	jalr	-1958(ra) # 5ba0 <chdir>
}
    434e:	70e2                	ld	ra,56(sp)
    4350:	7442                	ld	s0,48(sp)
    4352:	74a2                	ld	s1,40(sp)
    4354:	7902                	ld	s2,32(sp)
    4356:	69e2                	ld	s3,24(sp)
    4358:	6a42                	ld	s4,16(sp)
    435a:	6aa2                	ld	s5,8(sp)
    435c:	6b02                	ld	s6,0(sp)
    435e:	6121                	addi	sp,sp,64
    4360:	8082                	ret

0000000000004362 <openiputtest>:
{
    4362:	7179                	addi	sp,sp,-48
    4364:	f406                	sd	ra,40(sp)
    4366:	f022                	sd	s0,32(sp)
    4368:	ec26                	sd	s1,24(sp)
    436a:	1800                	addi	s0,sp,48
    436c:	84aa                	mv	s1,a0
  if (mkdir("oidir") < 0)
    436e:	00004517          	auipc	a0,0x4
    4372:	87a50513          	addi	a0,a0,-1926 # 7be8 <malloc+0x1c62>
    4376:	00002097          	auipc	ra,0x2
    437a:	822080e7          	jalr	-2014(ra) # 5b98 <mkdir>
    437e:	04054263          	bltz	a0,43c2 <openiputtest+0x60>
  pid = fork();
    4382:	00001097          	auipc	ra,0x1
    4386:	7a6080e7          	jalr	1958(ra) # 5b28 <fork>
  if (pid < 0)
    438a:	04054a63          	bltz	a0,43de <openiputtest+0x7c>
  if (pid == 0)
    438e:	e93d                	bnez	a0,4404 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    4390:	4589                	li	a1,2
    4392:	00004517          	auipc	a0,0x4
    4396:	85650513          	addi	a0,a0,-1962 # 7be8 <malloc+0x1c62>
    439a:	00001097          	auipc	ra,0x1
    439e:	7d6080e7          	jalr	2006(ra) # 5b70 <open>
    if (fd >= 0)
    43a2:	04054c63          	bltz	a0,43fa <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    43a6:	85a6                	mv	a1,s1
    43a8:	00004517          	auipc	a0,0x4
    43ac:	86050513          	addi	a0,a0,-1952 # 7c08 <malloc+0x1c82>
    43b0:	00002097          	auipc	ra,0x2
    43b4:	b18080e7          	jalr	-1256(ra) # 5ec8 <printf>
      exit(1);
    43b8:	4505                	li	a0,1
    43ba:	00001097          	auipc	ra,0x1
    43be:	776080e7          	jalr	1910(ra) # 5b30 <exit>
    printf("%s: mkdir oidir failed\n", s);
    43c2:	85a6                	mv	a1,s1
    43c4:	00004517          	auipc	a0,0x4
    43c8:	82c50513          	addi	a0,a0,-2004 # 7bf0 <malloc+0x1c6a>
    43cc:	00002097          	auipc	ra,0x2
    43d0:	afc080e7          	jalr	-1284(ra) # 5ec8 <printf>
    exit(1);
    43d4:	4505                	li	a0,1
    43d6:	00001097          	auipc	ra,0x1
    43da:	75a080e7          	jalr	1882(ra) # 5b30 <exit>
    printf("%s: fork failed\n", s);
    43de:	85a6                	mv	a1,s1
    43e0:	00002517          	auipc	a0,0x2
    43e4:	57050513          	addi	a0,a0,1392 # 6950 <malloc+0x9ca>
    43e8:	00002097          	auipc	ra,0x2
    43ec:	ae0080e7          	jalr	-1312(ra) # 5ec8 <printf>
    exit(1);
    43f0:	4505                	li	a0,1
    43f2:	00001097          	auipc	ra,0x1
    43f6:	73e080e7          	jalr	1854(ra) # 5b30 <exit>
    exit(0);
    43fa:	4501                	li	a0,0
    43fc:	00001097          	auipc	ra,0x1
    4400:	734080e7          	jalr	1844(ra) # 5b30 <exit>
  sleep(1);
    4404:	4505                	li	a0,1
    4406:	00001097          	auipc	ra,0x1
    440a:	7ba080e7          	jalr	1978(ra) # 5bc0 <sleep>
  if (unlink("oidir") != 0)
    440e:	00003517          	auipc	a0,0x3
    4412:	7da50513          	addi	a0,a0,2010 # 7be8 <malloc+0x1c62>
    4416:	00001097          	auipc	ra,0x1
    441a:	76a080e7          	jalr	1898(ra) # 5b80 <unlink>
    441e:	cd19                	beqz	a0,443c <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    4420:	85a6                	mv	a1,s1
    4422:	00002517          	auipc	a0,0x2
    4426:	71e50513          	addi	a0,a0,1822 # 6b40 <malloc+0xbba>
    442a:	00002097          	auipc	ra,0x2
    442e:	a9e080e7          	jalr	-1378(ra) # 5ec8 <printf>
    exit(1);
    4432:	4505                	li	a0,1
    4434:	00001097          	auipc	ra,0x1
    4438:	6fc080e7          	jalr	1788(ra) # 5b30 <exit>
  wait(&xstatus);
    443c:	fdc40513          	addi	a0,s0,-36
    4440:	00001097          	auipc	ra,0x1
    4444:	6f8080e7          	jalr	1784(ra) # 5b38 <wait>
  exit(xstatus);
    4448:	fdc42503          	lw	a0,-36(s0)
    444c:	00001097          	auipc	ra,0x1
    4450:	6e4080e7          	jalr	1764(ra) # 5b30 <exit>

0000000000004454 <forkforkfork>:
{
    4454:	1101                	addi	sp,sp,-32
    4456:	ec06                	sd	ra,24(sp)
    4458:	e822                	sd	s0,16(sp)
    445a:	e426                	sd	s1,8(sp)
    445c:	1000                	addi	s0,sp,32
    445e:	84aa                	mv	s1,a0
  unlink("stopforking");
    4460:	00003517          	auipc	a0,0x3
    4464:	7d050513          	addi	a0,a0,2000 # 7c30 <malloc+0x1caa>
    4468:	00001097          	auipc	ra,0x1
    446c:	718080e7          	jalr	1816(ra) # 5b80 <unlink>
  int pid = fork();
    4470:	00001097          	auipc	ra,0x1
    4474:	6b8080e7          	jalr	1720(ra) # 5b28 <fork>
  if (pid < 0)
    4478:	04054563          	bltz	a0,44c2 <forkforkfork+0x6e>
  if (pid == 0)
    447c:	c12d                	beqz	a0,44de <forkforkfork+0x8a>
  sleep(20); // two seconds
    447e:	4551                	li	a0,20
    4480:	00001097          	auipc	ra,0x1
    4484:	740080e7          	jalr	1856(ra) # 5bc0 <sleep>
  close(open("stopforking", O_CREATE | O_RDWR));
    4488:	20200593          	li	a1,514
    448c:	00003517          	auipc	a0,0x3
    4490:	7a450513          	addi	a0,a0,1956 # 7c30 <malloc+0x1caa>
    4494:	00001097          	auipc	ra,0x1
    4498:	6dc080e7          	jalr	1756(ra) # 5b70 <open>
    449c:	00001097          	auipc	ra,0x1
    44a0:	6bc080e7          	jalr	1724(ra) # 5b58 <close>
  wait(0);
    44a4:	4501                	li	a0,0
    44a6:	00001097          	auipc	ra,0x1
    44aa:	692080e7          	jalr	1682(ra) # 5b38 <wait>
  sleep(10); // one second
    44ae:	4529                	li	a0,10
    44b0:	00001097          	auipc	ra,0x1
    44b4:	710080e7          	jalr	1808(ra) # 5bc0 <sleep>
}
    44b8:	60e2                	ld	ra,24(sp)
    44ba:	6442                	ld	s0,16(sp)
    44bc:	64a2                	ld	s1,8(sp)
    44be:	6105                	addi	sp,sp,32
    44c0:	8082                	ret
    printf("%s: fork failed", s);
    44c2:	85a6                	mv	a1,s1
    44c4:	00002517          	auipc	a0,0x2
    44c8:	64c50513          	addi	a0,a0,1612 # 6b10 <malloc+0xb8a>
    44cc:	00002097          	auipc	ra,0x2
    44d0:	9fc080e7          	jalr	-1540(ra) # 5ec8 <printf>
    exit(1);
    44d4:	4505                	li	a0,1
    44d6:	00001097          	auipc	ra,0x1
    44da:	65a080e7          	jalr	1626(ra) # 5b30 <exit>
      int fd = open("stopforking", 0);
    44de:	00003497          	auipc	s1,0x3
    44e2:	75248493          	addi	s1,s1,1874 # 7c30 <malloc+0x1caa>
    44e6:	4581                	li	a1,0
    44e8:	8526                	mv	a0,s1
    44ea:	00001097          	auipc	ra,0x1
    44ee:	686080e7          	jalr	1670(ra) # 5b70 <open>
      if (fd >= 0)
    44f2:	02055463          	bgez	a0,451a <forkforkfork+0xc6>
      if (fork() < 0)
    44f6:	00001097          	auipc	ra,0x1
    44fa:	632080e7          	jalr	1586(ra) # 5b28 <fork>
    44fe:	fe0554e3          	bgez	a0,44e6 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE | O_RDWR));
    4502:	20200593          	li	a1,514
    4506:	8526                	mv	a0,s1
    4508:	00001097          	auipc	ra,0x1
    450c:	668080e7          	jalr	1640(ra) # 5b70 <open>
    4510:	00001097          	auipc	ra,0x1
    4514:	648080e7          	jalr	1608(ra) # 5b58 <close>
    4518:	b7f9                	j	44e6 <forkforkfork+0x92>
        exit(0);
    451a:	4501                	li	a0,0
    451c:	00001097          	auipc	ra,0x1
    4520:	614080e7          	jalr	1556(ra) # 5b30 <exit>

0000000000004524 <preempt>:
{
    4524:	7139                	addi	sp,sp,-64
    4526:	fc06                	sd	ra,56(sp)
    4528:	f822                	sd	s0,48(sp)
    452a:	f426                	sd	s1,40(sp)
    452c:	f04a                	sd	s2,32(sp)
    452e:	ec4e                	sd	s3,24(sp)
    4530:	e852                	sd	s4,16(sp)
    4532:	0080                	addi	s0,sp,64
    4534:	892a                	mv	s2,a0
  pid1 = fork();
    4536:	00001097          	auipc	ra,0x1
    453a:	5f2080e7          	jalr	1522(ra) # 5b28 <fork>
  if (pid1 < 0)
    453e:	00054563          	bltz	a0,4548 <preempt+0x24>
    4542:	84aa                	mv	s1,a0
  if (pid1 == 0)
    4544:	e105                	bnez	a0,4564 <preempt+0x40>
    for (;;)
    4546:	a001                	j	4546 <preempt+0x22>
    printf("%s: fork failed", s);
    4548:	85ca                	mv	a1,s2
    454a:	00002517          	auipc	a0,0x2
    454e:	5c650513          	addi	a0,a0,1478 # 6b10 <malloc+0xb8a>
    4552:	00002097          	auipc	ra,0x2
    4556:	976080e7          	jalr	-1674(ra) # 5ec8 <printf>
    exit(1);
    455a:	4505                	li	a0,1
    455c:	00001097          	auipc	ra,0x1
    4560:	5d4080e7          	jalr	1492(ra) # 5b30 <exit>
  pid2 = fork();
    4564:	00001097          	auipc	ra,0x1
    4568:	5c4080e7          	jalr	1476(ra) # 5b28 <fork>
    456c:	89aa                	mv	s3,a0
  if (pid2 < 0)
    456e:	00054463          	bltz	a0,4576 <preempt+0x52>
  if (pid2 == 0)
    4572:	e105                	bnez	a0,4592 <preempt+0x6e>
    for (;;)
    4574:	a001                	j	4574 <preempt+0x50>
    printf("%s: fork failed\n", s);
    4576:	85ca                	mv	a1,s2
    4578:	00002517          	auipc	a0,0x2
    457c:	3d850513          	addi	a0,a0,984 # 6950 <malloc+0x9ca>
    4580:	00002097          	auipc	ra,0x2
    4584:	948080e7          	jalr	-1720(ra) # 5ec8 <printf>
    exit(1);
    4588:	4505                	li	a0,1
    458a:	00001097          	auipc	ra,0x1
    458e:	5a6080e7          	jalr	1446(ra) # 5b30 <exit>
  pipe(pfds);
    4592:	fc840513          	addi	a0,s0,-56
    4596:	00001097          	auipc	ra,0x1
    459a:	5aa080e7          	jalr	1450(ra) # 5b40 <pipe>
  pid3 = fork();
    459e:	00001097          	auipc	ra,0x1
    45a2:	58a080e7          	jalr	1418(ra) # 5b28 <fork>
    45a6:	8a2a                	mv	s4,a0
  if (pid3 < 0)
    45a8:	02054e63          	bltz	a0,45e4 <preempt+0xc0>
  if (pid3 == 0)
    45ac:	e525                	bnez	a0,4614 <preempt+0xf0>
    close(pfds[0]);
    45ae:	fc842503          	lw	a0,-56(s0)
    45b2:	00001097          	auipc	ra,0x1
    45b6:	5a6080e7          	jalr	1446(ra) # 5b58 <close>
    if (write(pfds[1], "x", 1) != 1)
    45ba:	4605                	li	a2,1
    45bc:	00002597          	auipc	a1,0x2
    45c0:	b7c58593          	addi	a1,a1,-1156 # 6138 <malloc+0x1b2>
    45c4:	fcc42503          	lw	a0,-52(s0)
    45c8:	00001097          	auipc	ra,0x1
    45cc:	588080e7          	jalr	1416(ra) # 5b50 <write>
    45d0:	4785                	li	a5,1
    45d2:	02f51763          	bne	a0,a5,4600 <preempt+0xdc>
    close(pfds[1]);
    45d6:	fcc42503          	lw	a0,-52(s0)
    45da:	00001097          	auipc	ra,0x1
    45de:	57e080e7          	jalr	1406(ra) # 5b58 <close>
    for (;;)
    45e2:	a001                	j	45e2 <preempt+0xbe>
    printf("%s: fork failed\n", s);
    45e4:	85ca                	mv	a1,s2
    45e6:	00002517          	auipc	a0,0x2
    45ea:	36a50513          	addi	a0,a0,874 # 6950 <malloc+0x9ca>
    45ee:	00002097          	auipc	ra,0x2
    45f2:	8da080e7          	jalr	-1830(ra) # 5ec8 <printf>
    exit(1);
    45f6:	4505                	li	a0,1
    45f8:	00001097          	auipc	ra,0x1
    45fc:	538080e7          	jalr	1336(ra) # 5b30 <exit>
      printf("%s: preempt write error", s);
    4600:	85ca                	mv	a1,s2
    4602:	00003517          	auipc	a0,0x3
    4606:	63e50513          	addi	a0,a0,1598 # 7c40 <malloc+0x1cba>
    460a:	00002097          	auipc	ra,0x2
    460e:	8be080e7          	jalr	-1858(ra) # 5ec8 <printf>
    4612:	b7d1                	j	45d6 <preempt+0xb2>
  close(pfds[1]);
    4614:	fcc42503          	lw	a0,-52(s0)
    4618:	00001097          	auipc	ra,0x1
    461c:	540080e7          	jalr	1344(ra) # 5b58 <close>
  if (read(pfds[0], buf, sizeof(buf)) != 1)
    4620:	660d                	lui	a2,0x3
    4622:	00008597          	auipc	a1,0x8
    4626:	65658593          	addi	a1,a1,1622 # cc78 <buf>
    462a:	fc842503          	lw	a0,-56(s0)
    462e:	00001097          	auipc	ra,0x1
    4632:	51a080e7          	jalr	1306(ra) # 5b48 <read>
    4636:	4785                	li	a5,1
    4638:	02f50363          	beq	a0,a5,465e <preempt+0x13a>
    printf("%s: preempt read error", s);
    463c:	85ca                	mv	a1,s2
    463e:	00003517          	auipc	a0,0x3
    4642:	61a50513          	addi	a0,a0,1562 # 7c58 <malloc+0x1cd2>
    4646:	00002097          	auipc	ra,0x2
    464a:	882080e7          	jalr	-1918(ra) # 5ec8 <printf>
}
    464e:	70e2                	ld	ra,56(sp)
    4650:	7442                	ld	s0,48(sp)
    4652:	74a2                	ld	s1,40(sp)
    4654:	7902                	ld	s2,32(sp)
    4656:	69e2                	ld	s3,24(sp)
    4658:	6a42                	ld	s4,16(sp)
    465a:	6121                	addi	sp,sp,64
    465c:	8082                	ret
  close(pfds[0]);
    465e:	fc842503          	lw	a0,-56(s0)
    4662:	00001097          	auipc	ra,0x1
    4666:	4f6080e7          	jalr	1270(ra) # 5b58 <close>
  printf("kill... ");
    466a:	00003517          	auipc	a0,0x3
    466e:	60650513          	addi	a0,a0,1542 # 7c70 <malloc+0x1cea>
    4672:	00002097          	auipc	ra,0x2
    4676:	856080e7          	jalr	-1962(ra) # 5ec8 <printf>
  kill(pid1);
    467a:	8526                	mv	a0,s1
    467c:	00001097          	auipc	ra,0x1
    4680:	4e4080e7          	jalr	1252(ra) # 5b60 <kill>
  kill(pid2);
    4684:	854e                	mv	a0,s3
    4686:	00001097          	auipc	ra,0x1
    468a:	4da080e7          	jalr	1242(ra) # 5b60 <kill>
  kill(pid3);
    468e:	8552                	mv	a0,s4
    4690:	00001097          	auipc	ra,0x1
    4694:	4d0080e7          	jalr	1232(ra) # 5b60 <kill>
  printf("wait... ");
    4698:	00003517          	auipc	a0,0x3
    469c:	5e850513          	addi	a0,a0,1512 # 7c80 <malloc+0x1cfa>
    46a0:	00002097          	auipc	ra,0x2
    46a4:	828080e7          	jalr	-2008(ra) # 5ec8 <printf>
  wait(0);
    46a8:	4501                	li	a0,0
    46aa:	00001097          	auipc	ra,0x1
    46ae:	48e080e7          	jalr	1166(ra) # 5b38 <wait>
  wait(0);
    46b2:	4501                	li	a0,0
    46b4:	00001097          	auipc	ra,0x1
    46b8:	484080e7          	jalr	1156(ra) # 5b38 <wait>
  wait(0);
    46bc:	4501                	li	a0,0
    46be:	00001097          	auipc	ra,0x1
    46c2:	47a080e7          	jalr	1146(ra) # 5b38 <wait>
    46c6:	b761                	j	464e <preempt+0x12a>

00000000000046c8 <sbrkfail>:
{
    46c8:	7119                	addi	sp,sp,-128
    46ca:	fc86                	sd	ra,120(sp)
    46cc:	f8a2                	sd	s0,112(sp)
    46ce:	f4a6                	sd	s1,104(sp)
    46d0:	f0ca                	sd	s2,96(sp)
    46d2:	ecce                	sd	s3,88(sp)
    46d4:	e8d2                	sd	s4,80(sp)
    46d6:	e4d6                	sd	s5,72(sp)
    46d8:	0100                	addi	s0,sp,128
    46da:	8aaa                	mv	s5,a0
  if (pipe(fds) != 0)
    46dc:	fb040513          	addi	a0,s0,-80
    46e0:	00001097          	auipc	ra,0x1
    46e4:	460080e7          	jalr	1120(ra) # 5b40 <pipe>
    46e8:	e901                	bnez	a0,46f8 <sbrkfail+0x30>
    46ea:	f8040493          	addi	s1,s0,-128
    46ee:	fa840993          	addi	s3,s0,-88
    46f2:	8926                	mv	s2,s1
    if (pids[i] != -1)
    46f4:	5a7d                	li	s4,-1
    46f6:	a085                	j	4756 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    46f8:	85d6                	mv	a1,s5
    46fa:	00002517          	auipc	a0,0x2
    46fe:	35e50513          	addi	a0,a0,862 # 6a58 <malloc+0xad2>
    4702:	00001097          	auipc	ra,0x1
    4706:	7c6080e7          	jalr	1990(ra) # 5ec8 <printf>
    exit(1);
    470a:	4505                	li	a0,1
    470c:	00001097          	auipc	ra,0x1
    4710:	424080e7          	jalr	1060(ra) # 5b30 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4714:	00001097          	auipc	ra,0x1
    4718:	4a4080e7          	jalr	1188(ra) # 5bb8 <sbrk>
    471c:	064007b7          	lui	a5,0x6400
    4720:	40a7853b          	subw	a0,a5,a0
    4724:	00001097          	auipc	ra,0x1
    4728:	494080e7          	jalr	1172(ra) # 5bb8 <sbrk>
      write(fds[1], "x", 1);
    472c:	4605                	li	a2,1
    472e:	00002597          	auipc	a1,0x2
    4732:	a0a58593          	addi	a1,a1,-1526 # 6138 <malloc+0x1b2>
    4736:	fb442503          	lw	a0,-76(s0)
    473a:	00001097          	auipc	ra,0x1
    473e:	416080e7          	jalr	1046(ra) # 5b50 <write>
        sleep(1000);
    4742:	3e800513          	li	a0,1000
    4746:	00001097          	auipc	ra,0x1
    474a:	47a080e7          	jalr	1146(ra) # 5bc0 <sleep>
      for (;;)
    474e:	bfd5                	j	4742 <sbrkfail+0x7a>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++)
    4750:	0911                	addi	s2,s2,4
    4752:	03390563          	beq	s2,s3,477c <sbrkfail+0xb4>
    if ((pids[i] = fork()) == 0)
    4756:	00001097          	auipc	ra,0x1
    475a:	3d2080e7          	jalr	978(ra) # 5b28 <fork>
    475e:	00a92023          	sw	a0,0(s2)
    4762:	d94d                	beqz	a0,4714 <sbrkfail+0x4c>
    if (pids[i] != -1)
    4764:	ff4506e3          	beq	a0,s4,4750 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4768:	4605                	li	a2,1
    476a:	faf40593          	addi	a1,s0,-81
    476e:	fb042503          	lw	a0,-80(s0)
    4772:	00001097          	auipc	ra,0x1
    4776:	3d6080e7          	jalr	982(ra) # 5b48 <read>
    477a:	bfd9                	j	4750 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    477c:	6505                	lui	a0,0x1
    477e:	00001097          	auipc	ra,0x1
    4782:	43a080e7          	jalr	1082(ra) # 5bb8 <sbrk>
    4786:	8a2a                	mv	s4,a0
    if (pids[i] == -1)
    4788:	597d                	li	s2,-1
    478a:	a021                	j	4792 <sbrkfail+0xca>
  for (i = 0; i < sizeof(pids) / sizeof(pids[0]); i++)
    478c:	0491                	addi	s1,s1,4
    478e:	01348f63          	beq	s1,s3,47ac <sbrkfail+0xe4>
    if (pids[i] == -1)
    4792:	4088                	lw	a0,0(s1)
    4794:	ff250ce3          	beq	a0,s2,478c <sbrkfail+0xc4>
    kill(pids[i]);
    4798:	00001097          	auipc	ra,0x1
    479c:	3c8080e7          	jalr	968(ra) # 5b60 <kill>
    wait(0);
    47a0:	4501                	li	a0,0
    47a2:	00001097          	auipc	ra,0x1
    47a6:	396080e7          	jalr	918(ra) # 5b38 <wait>
    47aa:	b7cd                	j	478c <sbrkfail+0xc4>
  if (c == (char *)0xffffffffffffffffL)
    47ac:	57fd                	li	a5,-1
    47ae:	04fa0163          	beq	s4,a5,47f0 <sbrkfail+0x128>
  pid = fork();
    47b2:	00001097          	auipc	ra,0x1
    47b6:	376080e7          	jalr	886(ra) # 5b28 <fork>
    47ba:	84aa                	mv	s1,a0
  if (pid < 0)
    47bc:	04054863          	bltz	a0,480c <sbrkfail+0x144>
  if (pid == 0)
    47c0:	c525                	beqz	a0,4828 <sbrkfail+0x160>
  wait(&xstatus);
    47c2:	fbc40513          	addi	a0,s0,-68
    47c6:	00001097          	auipc	ra,0x1
    47ca:	372080e7          	jalr	882(ra) # 5b38 <wait>
  if (xstatus != -1 && xstatus != 2)
    47ce:	fbc42783          	lw	a5,-68(s0)
    47d2:	577d                	li	a4,-1
    47d4:	00e78563          	beq	a5,a4,47de <sbrkfail+0x116>
    47d8:	4709                	li	a4,2
    47da:	08e79d63          	bne	a5,a4,4874 <sbrkfail+0x1ac>
}
    47de:	70e6                	ld	ra,120(sp)
    47e0:	7446                	ld	s0,112(sp)
    47e2:	74a6                	ld	s1,104(sp)
    47e4:	7906                	ld	s2,96(sp)
    47e6:	69e6                	ld	s3,88(sp)
    47e8:	6a46                	ld	s4,80(sp)
    47ea:	6aa6                	ld	s5,72(sp)
    47ec:	6109                	addi	sp,sp,128
    47ee:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    47f0:	85d6                	mv	a1,s5
    47f2:	00003517          	auipc	a0,0x3
    47f6:	49e50513          	addi	a0,a0,1182 # 7c90 <malloc+0x1d0a>
    47fa:	00001097          	auipc	ra,0x1
    47fe:	6ce080e7          	jalr	1742(ra) # 5ec8 <printf>
    exit(1);
    4802:	4505                	li	a0,1
    4804:	00001097          	auipc	ra,0x1
    4808:	32c080e7          	jalr	812(ra) # 5b30 <exit>
    printf("%s: fork failed\n", s);
    480c:	85d6                	mv	a1,s5
    480e:	00002517          	auipc	a0,0x2
    4812:	14250513          	addi	a0,a0,322 # 6950 <malloc+0x9ca>
    4816:	00001097          	auipc	ra,0x1
    481a:	6b2080e7          	jalr	1714(ra) # 5ec8 <printf>
    exit(1);
    481e:	4505                	li	a0,1
    4820:	00001097          	auipc	ra,0x1
    4824:	310080e7          	jalr	784(ra) # 5b30 <exit>
    a = sbrk(0);
    4828:	4501                	li	a0,0
    482a:	00001097          	auipc	ra,0x1
    482e:	38e080e7          	jalr	910(ra) # 5bb8 <sbrk>
    4832:	892a                	mv	s2,a0
    sbrk(10 * BIG);
    4834:	3e800537          	lui	a0,0x3e800
    4838:	00001097          	auipc	ra,0x1
    483c:	380080e7          	jalr	896(ra) # 5bb8 <sbrk>
    for (i = 0; i < 10 * BIG; i += PGSIZE)
    4840:	87ca                	mv	a5,s2
    4842:	3e800737          	lui	a4,0x3e800
    4846:	993a                	add	s2,s2,a4
    4848:	6705                	lui	a4,0x1
      n += *(a + i);
    484a:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63f0388>
    484e:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10 * BIG; i += PGSIZE)
    4850:	97ba                	add	a5,a5,a4
    4852:	ff279ce3          	bne	a5,s2,484a <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4856:	8626                	mv	a2,s1
    4858:	85d6                	mv	a1,s5
    485a:	00003517          	auipc	a0,0x3
    485e:	45650513          	addi	a0,a0,1110 # 7cb0 <malloc+0x1d2a>
    4862:	00001097          	auipc	ra,0x1
    4866:	666080e7          	jalr	1638(ra) # 5ec8 <printf>
    exit(1);
    486a:	4505                	li	a0,1
    486c:	00001097          	auipc	ra,0x1
    4870:	2c4080e7          	jalr	708(ra) # 5b30 <exit>
    exit(1);
    4874:	4505                	li	a0,1
    4876:	00001097          	auipc	ra,0x1
    487a:	2ba080e7          	jalr	698(ra) # 5b30 <exit>

000000000000487e <reparent>:
{
    487e:	7179                	addi	sp,sp,-48
    4880:	f406                	sd	ra,40(sp)
    4882:	f022                	sd	s0,32(sp)
    4884:	ec26                	sd	s1,24(sp)
    4886:	e84a                	sd	s2,16(sp)
    4888:	e44e                	sd	s3,8(sp)
    488a:	e052                	sd	s4,0(sp)
    488c:	1800                	addi	s0,sp,48
    488e:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4890:	00001097          	auipc	ra,0x1
    4894:	320080e7          	jalr	800(ra) # 5bb0 <getpid>
    4898:	8a2a                	mv	s4,a0
    489a:	0c800913          	li	s2,200
    int pid = fork();
    489e:	00001097          	auipc	ra,0x1
    48a2:	28a080e7          	jalr	650(ra) # 5b28 <fork>
    48a6:	84aa                	mv	s1,a0
    if (pid < 0)
    48a8:	02054263          	bltz	a0,48cc <reparent+0x4e>
    if (pid)
    48ac:	cd21                	beqz	a0,4904 <reparent+0x86>
      if (wait(0) != pid)
    48ae:	4501                	li	a0,0
    48b0:	00001097          	auipc	ra,0x1
    48b4:	288080e7          	jalr	648(ra) # 5b38 <wait>
    48b8:	02951863          	bne	a0,s1,48e8 <reparent+0x6a>
  for (int i = 0; i < 200; i++)
    48bc:	397d                	addiw	s2,s2,-1
    48be:	fe0910e3          	bnez	s2,489e <reparent+0x20>
  exit(0);
    48c2:	4501                	li	a0,0
    48c4:	00001097          	auipc	ra,0x1
    48c8:	26c080e7          	jalr	620(ra) # 5b30 <exit>
      printf("%s: fork failed\n", s);
    48cc:	85ce                	mv	a1,s3
    48ce:	00002517          	auipc	a0,0x2
    48d2:	08250513          	addi	a0,a0,130 # 6950 <malloc+0x9ca>
    48d6:	00001097          	auipc	ra,0x1
    48da:	5f2080e7          	jalr	1522(ra) # 5ec8 <printf>
      exit(1);
    48de:	4505                	li	a0,1
    48e0:	00001097          	auipc	ra,0x1
    48e4:	250080e7          	jalr	592(ra) # 5b30 <exit>
        printf("%s: wait wrong pid\n", s);
    48e8:	85ce                	mv	a1,s3
    48ea:	00002517          	auipc	a0,0x2
    48ee:	1ee50513          	addi	a0,a0,494 # 6ad8 <malloc+0xb52>
    48f2:	00001097          	auipc	ra,0x1
    48f6:	5d6080e7          	jalr	1494(ra) # 5ec8 <printf>
        exit(1);
    48fa:	4505                	li	a0,1
    48fc:	00001097          	auipc	ra,0x1
    4900:	234080e7          	jalr	564(ra) # 5b30 <exit>
      int pid2 = fork();
    4904:	00001097          	auipc	ra,0x1
    4908:	224080e7          	jalr	548(ra) # 5b28 <fork>
      if (pid2 < 0)
    490c:	00054763          	bltz	a0,491a <reparent+0x9c>
      exit(0);
    4910:	4501                	li	a0,0
    4912:	00001097          	auipc	ra,0x1
    4916:	21e080e7          	jalr	542(ra) # 5b30 <exit>
        kill(master_pid);
    491a:	8552                	mv	a0,s4
    491c:	00001097          	auipc	ra,0x1
    4920:	244080e7          	jalr	580(ra) # 5b60 <kill>
        exit(1);
    4924:	4505                	li	a0,1
    4926:	00001097          	auipc	ra,0x1
    492a:	20a080e7          	jalr	522(ra) # 5b30 <exit>

000000000000492e <mem>:
{
    492e:	7139                	addi	sp,sp,-64
    4930:	fc06                	sd	ra,56(sp)
    4932:	f822                	sd	s0,48(sp)
    4934:	f426                	sd	s1,40(sp)
    4936:	f04a                	sd	s2,32(sp)
    4938:	ec4e                	sd	s3,24(sp)
    493a:	0080                	addi	s0,sp,64
    493c:	89aa                	mv	s3,a0
  if ((pid = fork()) == 0)
    493e:	00001097          	auipc	ra,0x1
    4942:	1ea080e7          	jalr	490(ra) # 5b28 <fork>
    m1 = 0;
    4946:	4481                	li	s1,0
    while ((m2 = malloc(10001)) != 0)
    4948:	6909                	lui	s2,0x2
    494a:	71190913          	addi	s2,s2,1809 # 2711 <copyinstr3+0xf7>
  if ((pid = fork()) == 0)
    494e:	c115                	beqz	a0,4972 <mem+0x44>
    wait(&xstatus);
    4950:	fcc40513          	addi	a0,s0,-52
    4954:	00001097          	auipc	ra,0x1
    4958:	1e4080e7          	jalr	484(ra) # 5b38 <wait>
    if (xstatus == -1)
    495c:	fcc42503          	lw	a0,-52(s0)
    4960:	57fd                	li	a5,-1
    4962:	06f50363          	beq	a0,a5,49c8 <mem+0x9a>
    exit(xstatus);
    4966:	00001097          	auipc	ra,0x1
    496a:	1ca080e7          	jalr	458(ra) # 5b30 <exit>
      *(char **)m2 = m1;
    496e:	e104                	sd	s1,0(a0)
      m1 = m2;
    4970:	84aa                	mv	s1,a0
    while ((m2 = malloc(10001)) != 0)
    4972:	854a                	mv	a0,s2
    4974:	00001097          	auipc	ra,0x1
    4978:	612080e7          	jalr	1554(ra) # 5f86 <malloc>
    497c:	f96d                	bnez	a0,496e <mem+0x40>
    while (m1)
    497e:	c881                	beqz	s1,498e <mem+0x60>
      m2 = *(char **)m1;
    4980:	8526                	mv	a0,s1
    4982:	6084                	ld	s1,0(s1)
      free(m1);
    4984:	00001097          	auipc	ra,0x1
    4988:	57a080e7          	jalr	1402(ra) # 5efe <free>
    while (m1)
    498c:	f8f5                	bnez	s1,4980 <mem+0x52>
    m1 = malloc(1024 * 20);
    498e:	6515                	lui	a0,0x5
    4990:	00001097          	auipc	ra,0x1
    4994:	5f6080e7          	jalr	1526(ra) # 5f86 <malloc>
    if (m1 == 0)
    4998:	c911                	beqz	a0,49ac <mem+0x7e>
    free(m1);
    499a:	00001097          	auipc	ra,0x1
    499e:	564080e7          	jalr	1380(ra) # 5efe <free>
    exit(0);
    49a2:	4501                	li	a0,0
    49a4:	00001097          	auipc	ra,0x1
    49a8:	18c080e7          	jalr	396(ra) # 5b30 <exit>
      printf("couldn't allocate mem?!!\n", s);
    49ac:	85ce                	mv	a1,s3
    49ae:	00003517          	auipc	a0,0x3
    49b2:	33250513          	addi	a0,a0,818 # 7ce0 <malloc+0x1d5a>
    49b6:	00001097          	auipc	ra,0x1
    49ba:	512080e7          	jalr	1298(ra) # 5ec8 <printf>
      exit(1);
    49be:	4505                	li	a0,1
    49c0:	00001097          	auipc	ra,0x1
    49c4:	170080e7          	jalr	368(ra) # 5b30 <exit>
      exit(0);
    49c8:	4501                	li	a0,0
    49ca:	00001097          	auipc	ra,0x1
    49ce:	166080e7          	jalr	358(ra) # 5b30 <exit>

00000000000049d2 <sharedfd>:
{
    49d2:	7159                	addi	sp,sp,-112
    49d4:	f486                	sd	ra,104(sp)
    49d6:	f0a2                	sd	s0,96(sp)
    49d8:	eca6                	sd	s1,88(sp)
    49da:	e8ca                	sd	s2,80(sp)
    49dc:	e4ce                	sd	s3,72(sp)
    49de:	e0d2                	sd	s4,64(sp)
    49e0:	fc56                	sd	s5,56(sp)
    49e2:	f85a                	sd	s6,48(sp)
    49e4:	f45e                	sd	s7,40(sp)
    49e6:	1880                	addi	s0,sp,112
    49e8:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    49ea:	00003517          	auipc	a0,0x3
    49ee:	31650513          	addi	a0,a0,790 # 7d00 <malloc+0x1d7a>
    49f2:	00001097          	auipc	ra,0x1
    49f6:	18e080e7          	jalr	398(ra) # 5b80 <unlink>
  fd = open("sharedfd", O_CREATE | O_RDWR);
    49fa:	20200593          	li	a1,514
    49fe:	00003517          	auipc	a0,0x3
    4a02:	30250513          	addi	a0,a0,770 # 7d00 <malloc+0x1d7a>
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	16a080e7          	jalr	362(ra) # 5b70 <open>
  if (fd < 0)
    4a0e:	04054a63          	bltz	a0,4a62 <sharedfd+0x90>
    4a12:	892a                	mv	s2,a0
  pid = fork();
    4a14:	00001097          	auipc	ra,0x1
    4a18:	114080e7          	jalr	276(ra) # 5b28 <fork>
    4a1c:	89aa                	mv	s3,a0
  memset(buf, pid == 0 ? 'c' : 'p', sizeof(buf));
    4a1e:	06300593          	li	a1,99
    4a22:	c119                	beqz	a0,4a28 <sharedfd+0x56>
    4a24:	07000593          	li	a1,112
    4a28:	4629                	li	a2,10
    4a2a:	fa040513          	addi	a0,s0,-96
    4a2e:	00001097          	auipc	ra,0x1
    4a32:	f06080e7          	jalr	-250(ra) # 5934 <memset>
    4a36:	3e800493          	li	s1,1000
    if (write(fd, buf, sizeof(buf)) != sizeof(buf))
    4a3a:	4629                	li	a2,10
    4a3c:	fa040593          	addi	a1,s0,-96
    4a40:	854a                	mv	a0,s2
    4a42:	00001097          	auipc	ra,0x1
    4a46:	10e080e7          	jalr	270(ra) # 5b50 <write>
    4a4a:	47a9                	li	a5,10
    4a4c:	02f51963          	bne	a0,a5,4a7e <sharedfd+0xac>
  for (i = 0; i < N; i++)
    4a50:	34fd                	addiw	s1,s1,-1
    4a52:	f4e5                	bnez	s1,4a3a <sharedfd+0x68>
  if (pid == 0)
    4a54:	04099363          	bnez	s3,4a9a <sharedfd+0xc8>
    exit(0);
    4a58:	4501                	li	a0,0
    4a5a:	00001097          	auipc	ra,0x1
    4a5e:	0d6080e7          	jalr	214(ra) # 5b30 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4a62:	85d2                	mv	a1,s4
    4a64:	00003517          	auipc	a0,0x3
    4a68:	2ac50513          	addi	a0,a0,684 # 7d10 <malloc+0x1d8a>
    4a6c:	00001097          	auipc	ra,0x1
    4a70:	45c080e7          	jalr	1116(ra) # 5ec8 <printf>
    exit(1);
    4a74:	4505                	li	a0,1
    4a76:	00001097          	auipc	ra,0x1
    4a7a:	0ba080e7          	jalr	186(ra) # 5b30 <exit>
      printf("%s: write sharedfd failed\n", s);
    4a7e:	85d2                	mv	a1,s4
    4a80:	00003517          	auipc	a0,0x3
    4a84:	2b850513          	addi	a0,a0,696 # 7d38 <malloc+0x1db2>
    4a88:	00001097          	auipc	ra,0x1
    4a8c:	440080e7          	jalr	1088(ra) # 5ec8 <printf>
      exit(1);
    4a90:	4505                	li	a0,1
    4a92:	00001097          	auipc	ra,0x1
    4a96:	09e080e7          	jalr	158(ra) # 5b30 <exit>
    wait(&xstatus);
    4a9a:	f9c40513          	addi	a0,s0,-100
    4a9e:	00001097          	auipc	ra,0x1
    4aa2:	09a080e7          	jalr	154(ra) # 5b38 <wait>
    if (xstatus != 0)
    4aa6:	f9c42983          	lw	s3,-100(s0)
    4aaa:	00098763          	beqz	s3,4ab8 <sharedfd+0xe6>
      exit(xstatus);
    4aae:	854e                	mv	a0,s3
    4ab0:	00001097          	auipc	ra,0x1
    4ab4:	080080e7          	jalr	128(ra) # 5b30 <exit>
  close(fd);
    4ab8:	854a                	mv	a0,s2
    4aba:	00001097          	auipc	ra,0x1
    4abe:	09e080e7          	jalr	158(ra) # 5b58 <close>
  fd = open("sharedfd", 0);
    4ac2:	4581                	li	a1,0
    4ac4:	00003517          	auipc	a0,0x3
    4ac8:	23c50513          	addi	a0,a0,572 # 7d00 <malloc+0x1d7a>
    4acc:	00001097          	auipc	ra,0x1
    4ad0:	0a4080e7          	jalr	164(ra) # 5b70 <open>
    4ad4:	8baa                	mv	s7,a0
  nc = np = 0;
    4ad6:	8ace                	mv	s5,s3
  if (fd < 0)
    4ad8:	02054563          	bltz	a0,4b02 <sharedfd+0x130>
    4adc:	faa40913          	addi	s2,s0,-86
      if (buf[i] == 'c')
    4ae0:	06300493          	li	s1,99
      if (buf[i] == 'p')
    4ae4:	07000b13          	li	s6,112
  while ((n = read(fd, buf, sizeof(buf))) > 0)
    4ae8:	4629                	li	a2,10
    4aea:	fa040593          	addi	a1,s0,-96
    4aee:	855e                	mv	a0,s7
    4af0:	00001097          	auipc	ra,0x1
    4af4:	058080e7          	jalr	88(ra) # 5b48 <read>
    4af8:	02a05f63          	blez	a0,4b36 <sharedfd+0x164>
    4afc:	fa040793          	addi	a5,s0,-96
    4b00:	a01d                	j	4b26 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4b02:	85d2                	mv	a1,s4
    4b04:	00003517          	auipc	a0,0x3
    4b08:	25450513          	addi	a0,a0,596 # 7d58 <malloc+0x1dd2>
    4b0c:	00001097          	auipc	ra,0x1
    4b10:	3bc080e7          	jalr	956(ra) # 5ec8 <printf>
    exit(1);
    4b14:	4505                	li	a0,1
    4b16:	00001097          	auipc	ra,0x1
    4b1a:	01a080e7          	jalr	26(ra) # 5b30 <exit>
        nc++;
    4b1e:	2985                	addiw	s3,s3,1
    for (i = 0; i < sizeof(buf); i++)
    4b20:	0785                	addi	a5,a5,1
    4b22:	fd2783e3          	beq	a5,s2,4ae8 <sharedfd+0x116>
      if (buf[i] == 'c')
    4b26:	0007c703          	lbu	a4,0(a5)
    4b2a:	fe970ae3          	beq	a4,s1,4b1e <sharedfd+0x14c>
      if (buf[i] == 'p')
    4b2e:	ff6719e3          	bne	a4,s6,4b20 <sharedfd+0x14e>
        np++;
    4b32:	2a85                	addiw	s5,s5,1
    4b34:	b7f5                	j	4b20 <sharedfd+0x14e>
  close(fd);
    4b36:	855e                	mv	a0,s7
    4b38:	00001097          	auipc	ra,0x1
    4b3c:	020080e7          	jalr	32(ra) # 5b58 <close>
  unlink("sharedfd");
    4b40:	00003517          	auipc	a0,0x3
    4b44:	1c050513          	addi	a0,a0,448 # 7d00 <malloc+0x1d7a>
    4b48:	00001097          	auipc	ra,0x1
    4b4c:	038080e7          	jalr	56(ra) # 5b80 <unlink>
  if (nc == N * SZ && np == N * SZ)
    4b50:	6789                	lui	a5,0x2
    4b52:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0xf6>
    4b56:	00f99763          	bne	s3,a5,4b64 <sharedfd+0x192>
    4b5a:	6789                	lui	a5,0x2
    4b5c:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0xf6>
    4b60:	02fa8063          	beq	s5,a5,4b80 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4b64:	85d2                	mv	a1,s4
    4b66:	00003517          	auipc	a0,0x3
    4b6a:	21a50513          	addi	a0,a0,538 # 7d80 <malloc+0x1dfa>
    4b6e:	00001097          	auipc	ra,0x1
    4b72:	35a080e7          	jalr	858(ra) # 5ec8 <printf>
    exit(1);
    4b76:	4505                	li	a0,1
    4b78:	00001097          	auipc	ra,0x1
    4b7c:	fb8080e7          	jalr	-72(ra) # 5b30 <exit>
    exit(0);
    4b80:	4501                	li	a0,0
    4b82:	00001097          	auipc	ra,0x1
    4b86:	fae080e7          	jalr	-82(ra) # 5b30 <exit>

0000000000004b8a <fourfiles>:
{
    4b8a:	7171                	addi	sp,sp,-176
    4b8c:	f506                	sd	ra,168(sp)
    4b8e:	f122                	sd	s0,160(sp)
    4b90:	ed26                	sd	s1,152(sp)
    4b92:	e94a                	sd	s2,144(sp)
    4b94:	e54e                	sd	s3,136(sp)
    4b96:	e152                	sd	s4,128(sp)
    4b98:	fcd6                	sd	s5,120(sp)
    4b9a:	f8da                	sd	s6,112(sp)
    4b9c:	f4de                	sd	s7,104(sp)
    4b9e:	f0e2                	sd	s8,96(sp)
    4ba0:	ece6                	sd	s9,88(sp)
    4ba2:	e8ea                	sd	s10,80(sp)
    4ba4:	e4ee                	sd	s11,72(sp)
    4ba6:	1900                	addi	s0,sp,176
    4ba8:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = {"f0", "f1", "f2", "f3"};
    4bac:	00001797          	auipc	a5,0x1
    4bb0:	4c478793          	addi	a5,a5,1220 # 6070 <malloc+0xea>
    4bb4:	f6f43823          	sd	a5,-144(s0)
    4bb8:	00001797          	auipc	a5,0x1
    4bbc:	4c078793          	addi	a5,a5,1216 # 6078 <malloc+0xf2>
    4bc0:	f6f43c23          	sd	a5,-136(s0)
    4bc4:	00001797          	auipc	a5,0x1
    4bc8:	4bc78793          	addi	a5,a5,1212 # 6080 <malloc+0xfa>
    4bcc:	f8f43023          	sd	a5,-128(s0)
    4bd0:	00001797          	auipc	a5,0x1
    4bd4:	4b878793          	addi	a5,a5,1208 # 6088 <malloc+0x102>
    4bd8:	f8f43423          	sd	a5,-120(s0)
  for (pi = 0; pi < NCHILD; pi++)
    4bdc:	f7040c13          	addi	s8,s0,-144
  char *names[] = {"f0", "f1", "f2", "f3"};
    4be0:	8962                	mv	s2,s8
  for (pi = 0; pi < NCHILD; pi++)
    4be2:	4481                	li	s1,0
    4be4:	4a11                	li	s4,4
    fname = names[pi];
    4be6:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4bea:	854e                	mv	a0,s3
    4bec:	00001097          	auipc	ra,0x1
    4bf0:	f94080e7          	jalr	-108(ra) # 5b80 <unlink>
    pid = fork();
    4bf4:	00001097          	auipc	ra,0x1
    4bf8:	f34080e7          	jalr	-204(ra) # 5b28 <fork>
    if (pid < 0)
    4bfc:	04054463          	bltz	a0,4c44 <fourfiles+0xba>
    if (pid == 0)
    4c00:	c12d                	beqz	a0,4c62 <fourfiles+0xd8>
  for (pi = 0; pi < NCHILD; pi++)
    4c02:	2485                	addiw	s1,s1,1
    4c04:	0921                	addi	s2,s2,8
    4c06:	ff4490e3          	bne	s1,s4,4be6 <fourfiles+0x5c>
    4c0a:	4491                	li	s1,4
    wait(&xstatus);
    4c0c:	f6c40513          	addi	a0,s0,-148
    4c10:	00001097          	auipc	ra,0x1
    4c14:	f28080e7          	jalr	-216(ra) # 5b38 <wait>
    if (xstatus != 0)
    4c18:	f6c42b03          	lw	s6,-148(s0)
    4c1c:	0c0b1e63          	bnez	s6,4cf8 <fourfiles+0x16e>
  for (pi = 0; pi < NCHILD; pi++)
    4c20:	34fd                	addiw	s1,s1,-1
    4c22:	f4ed                	bnez	s1,4c0c <fourfiles+0x82>
    4c24:	03000b93          	li	s7,48
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4c28:	00008a17          	auipc	s4,0x8
    4c2c:	050a0a13          	addi	s4,s4,80 # cc78 <buf>
    4c30:	00008a97          	auipc	s5,0x8
    4c34:	049a8a93          	addi	s5,s5,73 # cc79 <buf+0x1>
    if (total != N * SZ)
    4c38:	6d85                	lui	s11,0x1
    4c3a:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0x22>
  for (i = 0; i < NCHILD; i++)
    4c3e:	03400d13          	li	s10,52
    4c42:	aa1d                	j	4d78 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4c44:	f5843583          	ld	a1,-168(s0)
    4c48:	00002517          	auipc	a0,0x2
    4c4c:	11050513          	addi	a0,a0,272 # 6d58 <malloc+0xdd2>
    4c50:	00001097          	auipc	ra,0x1
    4c54:	278080e7          	jalr	632(ra) # 5ec8 <printf>
      exit(1);
    4c58:	4505                	li	a0,1
    4c5a:	00001097          	auipc	ra,0x1
    4c5e:	ed6080e7          	jalr	-298(ra) # 5b30 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4c62:	20200593          	li	a1,514
    4c66:	854e                	mv	a0,s3
    4c68:	00001097          	auipc	ra,0x1
    4c6c:	f08080e7          	jalr	-248(ra) # 5b70 <open>
    4c70:	892a                	mv	s2,a0
      if (fd < 0)
    4c72:	04054763          	bltz	a0,4cc0 <fourfiles+0x136>
      memset(buf, '0' + pi, SZ);
    4c76:	1f400613          	li	a2,500
    4c7a:	0304859b          	addiw	a1,s1,48
    4c7e:	00008517          	auipc	a0,0x8
    4c82:	ffa50513          	addi	a0,a0,-6 # cc78 <buf>
    4c86:	00001097          	auipc	ra,0x1
    4c8a:	cae080e7          	jalr	-850(ra) # 5934 <memset>
    4c8e:	44b1                	li	s1,12
        if ((n = write(fd, buf, SZ)) != SZ)
    4c90:	00008997          	auipc	s3,0x8
    4c94:	fe898993          	addi	s3,s3,-24 # cc78 <buf>
    4c98:	1f400613          	li	a2,500
    4c9c:	85ce                	mv	a1,s3
    4c9e:	854a                	mv	a0,s2
    4ca0:	00001097          	auipc	ra,0x1
    4ca4:	eb0080e7          	jalr	-336(ra) # 5b50 <write>
    4ca8:	85aa                	mv	a1,a0
    4caa:	1f400793          	li	a5,500
    4cae:	02f51863          	bne	a0,a5,4cde <fourfiles+0x154>
      for (i = 0; i < N; i++)
    4cb2:	34fd                	addiw	s1,s1,-1
    4cb4:	f0f5                	bnez	s1,4c98 <fourfiles+0x10e>
      exit(0);
    4cb6:	4501                	li	a0,0
    4cb8:	00001097          	auipc	ra,0x1
    4cbc:	e78080e7          	jalr	-392(ra) # 5b30 <exit>
        printf("create failed\n", s);
    4cc0:	f5843583          	ld	a1,-168(s0)
    4cc4:	00003517          	auipc	a0,0x3
    4cc8:	0d450513          	addi	a0,a0,212 # 7d98 <malloc+0x1e12>
    4ccc:	00001097          	auipc	ra,0x1
    4cd0:	1fc080e7          	jalr	508(ra) # 5ec8 <printf>
        exit(1);
    4cd4:	4505                	li	a0,1
    4cd6:	00001097          	auipc	ra,0x1
    4cda:	e5a080e7          	jalr	-422(ra) # 5b30 <exit>
          printf("write failed %d\n", n);
    4cde:	00003517          	auipc	a0,0x3
    4ce2:	0ca50513          	addi	a0,a0,202 # 7da8 <malloc+0x1e22>
    4ce6:	00001097          	auipc	ra,0x1
    4cea:	1e2080e7          	jalr	482(ra) # 5ec8 <printf>
          exit(1);
    4cee:	4505                	li	a0,1
    4cf0:	00001097          	auipc	ra,0x1
    4cf4:	e40080e7          	jalr	-448(ra) # 5b30 <exit>
      exit(xstatus);
    4cf8:	855a                	mv	a0,s6
    4cfa:	00001097          	auipc	ra,0x1
    4cfe:	e36080e7          	jalr	-458(ra) # 5b30 <exit>
          printf("wrong char\n", s);
    4d02:	f5843583          	ld	a1,-168(s0)
    4d06:	00003517          	auipc	a0,0x3
    4d0a:	0ba50513          	addi	a0,a0,186 # 7dc0 <malloc+0x1e3a>
    4d0e:	00001097          	auipc	ra,0x1
    4d12:	1ba080e7          	jalr	442(ra) # 5ec8 <printf>
          exit(1);
    4d16:	4505                	li	a0,1
    4d18:	00001097          	auipc	ra,0x1
    4d1c:	e18080e7          	jalr	-488(ra) # 5b30 <exit>
      total += n;
    4d20:	00a9093b          	addw	s2,s2,a0
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4d24:	660d                	lui	a2,0x3
    4d26:	85d2                	mv	a1,s4
    4d28:	854e                	mv	a0,s3
    4d2a:	00001097          	auipc	ra,0x1
    4d2e:	e1e080e7          	jalr	-482(ra) # 5b48 <read>
    4d32:	02a05363          	blez	a0,4d58 <fourfiles+0x1ce>
    4d36:	00008797          	auipc	a5,0x8
    4d3a:	f4278793          	addi	a5,a5,-190 # cc78 <buf>
    4d3e:	fff5069b          	addiw	a3,a0,-1
    4d42:	1682                	slli	a3,a3,0x20
    4d44:	9281                	srli	a3,a3,0x20
    4d46:	96d6                	add	a3,a3,s5
        if (buf[j] != '0' + i)
    4d48:	0007c703          	lbu	a4,0(a5)
    4d4c:	fa971be3          	bne	a4,s1,4d02 <fourfiles+0x178>
      for (j = 0; j < n; j++)
    4d50:	0785                	addi	a5,a5,1
    4d52:	fed79be3          	bne	a5,a3,4d48 <fourfiles+0x1be>
    4d56:	b7e9                	j	4d20 <fourfiles+0x196>
    close(fd);
    4d58:	854e                	mv	a0,s3
    4d5a:	00001097          	auipc	ra,0x1
    4d5e:	dfe080e7          	jalr	-514(ra) # 5b58 <close>
    if (total != N * SZ)
    4d62:	03b91863          	bne	s2,s11,4d92 <fourfiles+0x208>
    unlink(fname);
    4d66:	8566                	mv	a0,s9
    4d68:	00001097          	auipc	ra,0x1
    4d6c:	e18080e7          	jalr	-488(ra) # 5b80 <unlink>
  for (i = 0; i < NCHILD; i++)
    4d70:	0c21                	addi	s8,s8,8
    4d72:	2b85                	addiw	s7,s7,1
    4d74:	03ab8d63          	beq	s7,s10,4dae <fourfiles+0x224>
    fname = names[i];
    4d78:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4d7c:	4581                	li	a1,0
    4d7e:	8566                	mv	a0,s9
    4d80:	00001097          	auipc	ra,0x1
    4d84:	df0080e7          	jalr	-528(ra) # 5b70 <open>
    4d88:	89aa                	mv	s3,a0
    total = 0;
    4d8a:	895a                	mv	s2,s6
        if (buf[j] != '0' + i)
    4d8c:	000b849b          	sext.w	s1,s7
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    4d90:	bf51                	j	4d24 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4d92:	85ca                	mv	a1,s2
    4d94:	00003517          	auipc	a0,0x3
    4d98:	03c50513          	addi	a0,a0,60 # 7dd0 <malloc+0x1e4a>
    4d9c:	00001097          	auipc	ra,0x1
    4da0:	12c080e7          	jalr	300(ra) # 5ec8 <printf>
      exit(1);
    4da4:	4505                	li	a0,1
    4da6:	00001097          	auipc	ra,0x1
    4daa:	d8a080e7          	jalr	-630(ra) # 5b30 <exit>
}
    4dae:	70aa                	ld	ra,168(sp)
    4db0:	740a                	ld	s0,160(sp)
    4db2:	64ea                	ld	s1,152(sp)
    4db4:	694a                	ld	s2,144(sp)
    4db6:	69aa                	ld	s3,136(sp)
    4db8:	6a0a                	ld	s4,128(sp)
    4dba:	7ae6                	ld	s5,120(sp)
    4dbc:	7b46                	ld	s6,112(sp)
    4dbe:	7ba6                	ld	s7,104(sp)
    4dc0:	7c06                	ld	s8,96(sp)
    4dc2:	6ce6                	ld	s9,88(sp)
    4dc4:	6d46                	ld	s10,80(sp)
    4dc6:	6da6                	ld	s11,72(sp)
    4dc8:	614d                	addi	sp,sp,176
    4dca:	8082                	ret

0000000000004dcc <concreate>:
{
    4dcc:	7135                	addi	sp,sp,-160
    4dce:	ed06                	sd	ra,152(sp)
    4dd0:	e922                	sd	s0,144(sp)
    4dd2:	e526                	sd	s1,136(sp)
    4dd4:	e14a                	sd	s2,128(sp)
    4dd6:	fcce                	sd	s3,120(sp)
    4dd8:	f8d2                	sd	s4,112(sp)
    4dda:	f4d6                	sd	s5,104(sp)
    4ddc:	f0da                	sd	s6,96(sp)
    4dde:	ecde                	sd	s7,88(sp)
    4de0:	1100                	addi	s0,sp,160
    4de2:	89aa                	mv	s3,a0
  file[0] = 'C';
    4de4:	04300793          	li	a5,67
    4de8:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4dec:	fa040523          	sb	zero,-86(s0)
  for (i = 0; i < N; i++)
    4df0:	4901                	li	s2,0
    if (pid && (i % 3) == 1)
    4df2:	4b0d                	li	s6,3
    4df4:	4a85                	li	s5,1
      link("C0", file);
    4df6:	00003b97          	auipc	s7,0x3
    4dfa:	ff2b8b93          	addi	s7,s7,-14 # 7de8 <malloc+0x1e62>
  for (i = 0; i < N; i++)
    4dfe:	02800a13          	li	s4,40
    4e02:	acc1                	j	50d2 <concreate+0x306>
      link("C0", file);
    4e04:	fa840593          	addi	a1,s0,-88
    4e08:	855e                	mv	a0,s7
    4e0a:	00001097          	auipc	ra,0x1
    4e0e:	d86080e7          	jalr	-634(ra) # 5b90 <link>
    if (pid == 0)
    4e12:	a45d                	j	50b8 <concreate+0x2ec>
    else if (pid == 0 && (i % 5) == 1)
    4e14:	4795                	li	a5,5
    4e16:	02f9693b          	remw	s2,s2,a5
    4e1a:	4785                	li	a5,1
    4e1c:	02f90b63          	beq	s2,a5,4e52 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4e20:	20200593          	li	a1,514
    4e24:	fa840513          	addi	a0,s0,-88
    4e28:	00001097          	auipc	ra,0x1
    4e2c:	d48080e7          	jalr	-696(ra) # 5b70 <open>
      if (fd < 0)
    4e30:	26055b63          	bgez	a0,50a6 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    4e34:	fa840593          	addi	a1,s0,-88
    4e38:	00003517          	auipc	a0,0x3
    4e3c:	fb850513          	addi	a0,a0,-72 # 7df0 <malloc+0x1e6a>
    4e40:	00001097          	auipc	ra,0x1
    4e44:	088080e7          	jalr	136(ra) # 5ec8 <printf>
        exit(1);
    4e48:	4505                	li	a0,1
    4e4a:	00001097          	auipc	ra,0x1
    4e4e:	ce6080e7          	jalr	-794(ra) # 5b30 <exit>
      link("C0", file);
    4e52:	fa840593          	addi	a1,s0,-88
    4e56:	00003517          	auipc	a0,0x3
    4e5a:	f9250513          	addi	a0,a0,-110 # 7de8 <malloc+0x1e62>
    4e5e:	00001097          	auipc	ra,0x1
    4e62:	d32080e7          	jalr	-718(ra) # 5b90 <link>
      exit(0);
    4e66:	4501                	li	a0,0
    4e68:	00001097          	auipc	ra,0x1
    4e6c:	cc8080e7          	jalr	-824(ra) # 5b30 <exit>
        exit(1);
    4e70:	4505                	li	a0,1
    4e72:	00001097          	auipc	ra,0x1
    4e76:	cbe080e7          	jalr	-834(ra) # 5b30 <exit>
  memset(fa, 0, sizeof(fa));
    4e7a:	02800613          	li	a2,40
    4e7e:	4581                	li	a1,0
    4e80:	f8040513          	addi	a0,s0,-128
    4e84:	00001097          	auipc	ra,0x1
    4e88:	ab0080e7          	jalr	-1360(ra) # 5934 <memset>
  fd = open(".", 0);
    4e8c:	4581                	li	a1,0
    4e8e:	00002517          	auipc	a0,0x2
    4e92:	92250513          	addi	a0,a0,-1758 # 67b0 <malloc+0x82a>
    4e96:	00001097          	auipc	ra,0x1
    4e9a:	cda080e7          	jalr	-806(ra) # 5b70 <open>
    4e9e:	892a                	mv	s2,a0
  n = 0;
    4ea0:	8aa6                	mv	s5,s1
    if (de.name[0] == 'C' && de.name[2] == '\0')
    4ea2:	04300a13          	li	s4,67
      if (i < 0 || i >= sizeof(fa))
    4ea6:	02700b13          	li	s6,39
      fa[i] = 1;
    4eaa:	4b85                	li	s7,1
  while (read(fd, &de, sizeof(de)) > 0)
    4eac:	4641                	li	a2,16
    4eae:	f7040593          	addi	a1,s0,-144
    4eb2:	854a                	mv	a0,s2
    4eb4:	00001097          	auipc	ra,0x1
    4eb8:	c94080e7          	jalr	-876(ra) # 5b48 <read>
    4ebc:	08a05163          	blez	a0,4f3e <concreate+0x172>
    if (de.inum == 0)
    4ec0:	f7045783          	lhu	a5,-144(s0)
    4ec4:	d7e5                	beqz	a5,4eac <concreate+0xe0>
    if (de.name[0] == 'C' && de.name[2] == '\0')
    4ec6:	f7244783          	lbu	a5,-142(s0)
    4eca:	ff4791e3          	bne	a5,s4,4eac <concreate+0xe0>
    4ece:	f7444783          	lbu	a5,-140(s0)
    4ed2:	ffe9                	bnez	a5,4eac <concreate+0xe0>
      i = de.name[1] - '0';
    4ed4:	f7344783          	lbu	a5,-141(s0)
    4ed8:	fd07879b          	addiw	a5,a5,-48
    4edc:	0007871b          	sext.w	a4,a5
      if (i < 0 || i >= sizeof(fa))
    4ee0:	00eb6f63          	bltu	s6,a4,4efe <concreate+0x132>
      if (fa[i])
    4ee4:	fb040793          	addi	a5,s0,-80
    4ee8:	97ba                	add	a5,a5,a4
    4eea:	fd07c783          	lbu	a5,-48(a5)
    4eee:	eb85                	bnez	a5,4f1e <concreate+0x152>
      fa[i] = 1;
    4ef0:	fb040793          	addi	a5,s0,-80
    4ef4:	973e                	add	a4,a4,a5
    4ef6:	fd770823          	sb	s7,-48(a4) # fd0 <linktest+0xce>
      n++;
    4efa:	2a85                	addiw	s5,s5,1
    4efc:	bf45                	j	4eac <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4efe:	f7240613          	addi	a2,s0,-142
    4f02:	85ce                	mv	a1,s3
    4f04:	00003517          	auipc	a0,0x3
    4f08:	f0c50513          	addi	a0,a0,-244 # 7e10 <malloc+0x1e8a>
    4f0c:	00001097          	auipc	ra,0x1
    4f10:	fbc080e7          	jalr	-68(ra) # 5ec8 <printf>
        exit(1);
    4f14:	4505                	li	a0,1
    4f16:	00001097          	auipc	ra,0x1
    4f1a:	c1a080e7          	jalr	-998(ra) # 5b30 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4f1e:	f7240613          	addi	a2,s0,-142
    4f22:	85ce                	mv	a1,s3
    4f24:	00003517          	auipc	a0,0x3
    4f28:	f0c50513          	addi	a0,a0,-244 # 7e30 <malloc+0x1eaa>
    4f2c:	00001097          	auipc	ra,0x1
    4f30:	f9c080e7          	jalr	-100(ra) # 5ec8 <printf>
        exit(1);
    4f34:	4505                	li	a0,1
    4f36:	00001097          	auipc	ra,0x1
    4f3a:	bfa080e7          	jalr	-1030(ra) # 5b30 <exit>
  close(fd);
    4f3e:	854a                	mv	a0,s2
    4f40:	00001097          	auipc	ra,0x1
    4f44:	c18080e7          	jalr	-1000(ra) # 5b58 <close>
  if (n != N)
    4f48:	02800793          	li	a5,40
    4f4c:	00fa9763          	bne	s5,a5,4f5a <concreate+0x18e>
    if (((i % 3) == 0 && pid == 0) ||
    4f50:	4a8d                	li	s5,3
    4f52:	4b05                	li	s6,1
  for (i = 0; i < N; i++)
    4f54:	02800a13          	li	s4,40
    4f58:	a8c9                	j	502a <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4f5a:	85ce                	mv	a1,s3
    4f5c:	00003517          	auipc	a0,0x3
    4f60:	efc50513          	addi	a0,a0,-260 # 7e58 <malloc+0x1ed2>
    4f64:	00001097          	auipc	ra,0x1
    4f68:	f64080e7          	jalr	-156(ra) # 5ec8 <printf>
    exit(1);
    4f6c:	4505                	li	a0,1
    4f6e:	00001097          	auipc	ra,0x1
    4f72:	bc2080e7          	jalr	-1086(ra) # 5b30 <exit>
      printf("%s: fork failed\n", s);
    4f76:	85ce                	mv	a1,s3
    4f78:	00002517          	auipc	a0,0x2
    4f7c:	9d850513          	addi	a0,a0,-1576 # 6950 <malloc+0x9ca>
    4f80:	00001097          	auipc	ra,0x1
    4f84:	f48080e7          	jalr	-184(ra) # 5ec8 <printf>
      exit(1);
    4f88:	4505                	li	a0,1
    4f8a:	00001097          	auipc	ra,0x1
    4f8e:	ba6080e7          	jalr	-1114(ra) # 5b30 <exit>
      close(open(file, 0));
    4f92:	4581                	li	a1,0
    4f94:	fa840513          	addi	a0,s0,-88
    4f98:	00001097          	auipc	ra,0x1
    4f9c:	bd8080e7          	jalr	-1064(ra) # 5b70 <open>
    4fa0:	00001097          	auipc	ra,0x1
    4fa4:	bb8080e7          	jalr	-1096(ra) # 5b58 <close>
      close(open(file, 0));
    4fa8:	4581                	li	a1,0
    4faa:	fa840513          	addi	a0,s0,-88
    4fae:	00001097          	auipc	ra,0x1
    4fb2:	bc2080e7          	jalr	-1086(ra) # 5b70 <open>
    4fb6:	00001097          	auipc	ra,0x1
    4fba:	ba2080e7          	jalr	-1118(ra) # 5b58 <close>
      close(open(file, 0));
    4fbe:	4581                	li	a1,0
    4fc0:	fa840513          	addi	a0,s0,-88
    4fc4:	00001097          	auipc	ra,0x1
    4fc8:	bac080e7          	jalr	-1108(ra) # 5b70 <open>
    4fcc:	00001097          	auipc	ra,0x1
    4fd0:	b8c080e7          	jalr	-1140(ra) # 5b58 <close>
      close(open(file, 0));
    4fd4:	4581                	li	a1,0
    4fd6:	fa840513          	addi	a0,s0,-88
    4fda:	00001097          	auipc	ra,0x1
    4fde:	b96080e7          	jalr	-1130(ra) # 5b70 <open>
    4fe2:	00001097          	auipc	ra,0x1
    4fe6:	b76080e7          	jalr	-1162(ra) # 5b58 <close>
      close(open(file, 0));
    4fea:	4581                	li	a1,0
    4fec:	fa840513          	addi	a0,s0,-88
    4ff0:	00001097          	auipc	ra,0x1
    4ff4:	b80080e7          	jalr	-1152(ra) # 5b70 <open>
    4ff8:	00001097          	auipc	ra,0x1
    4ffc:	b60080e7          	jalr	-1184(ra) # 5b58 <close>
      close(open(file, 0));
    5000:	4581                	li	a1,0
    5002:	fa840513          	addi	a0,s0,-88
    5006:	00001097          	auipc	ra,0x1
    500a:	b6a080e7          	jalr	-1174(ra) # 5b70 <open>
    500e:	00001097          	auipc	ra,0x1
    5012:	b4a080e7          	jalr	-1206(ra) # 5b58 <close>
    if (pid == 0)
    5016:	08090363          	beqz	s2,509c <concreate+0x2d0>
      wait(0);
    501a:	4501                	li	a0,0
    501c:	00001097          	auipc	ra,0x1
    5020:	b1c080e7          	jalr	-1252(ra) # 5b38 <wait>
  for (i = 0; i < N; i++)
    5024:	2485                	addiw	s1,s1,1
    5026:	0f448563          	beq	s1,s4,5110 <concreate+0x344>
    file[1] = '0' + i;
    502a:	0304879b          	addiw	a5,s1,48
    502e:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    5032:	00001097          	auipc	ra,0x1
    5036:	af6080e7          	jalr	-1290(ra) # 5b28 <fork>
    503a:	892a                	mv	s2,a0
    if (pid < 0)
    503c:	f2054de3          	bltz	a0,4f76 <concreate+0x1aa>
    if (((i % 3) == 0 && pid == 0) ||
    5040:	0354e73b          	remw	a4,s1,s5
    5044:	00a767b3          	or	a5,a4,a0
    5048:	2781                	sext.w	a5,a5
    504a:	d7a1                	beqz	a5,4f92 <concreate+0x1c6>
    504c:	01671363          	bne	a4,s6,5052 <concreate+0x286>
        ((i % 3) == 1 && pid != 0))
    5050:	f129                	bnez	a0,4f92 <concreate+0x1c6>
      unlink(file);
    5052:	fa840513          	addi	a0,s0,-88
    5056:	00001097          	auipc	ra,0x1
    505a:	b2a080e7          	jalr	-1238(ra) # 5b80 <unlink>
      unlink(file);
    505e:	fa840513          	addi	a0,s0,-88
    5062:	00001097          	auipc	ra,0x1
    5066:	b1e080e7          	jalr	-1250(ra) # 5b80 <unlink>
      unlink(file);
    506a:	fa840513          	addi	a0,s0,-88
    506e:	00001097          	auipc	ra,0x1
    5072:	b12080e7          	jalr	-1262(ra) # 5b80 <unlink>
      unlink(file);
    5076:	fa840513          	addi	a0,s0,-88
    507a:	00001097          	auipc	ra,0x1
    507e:	b06080e7          	jalr	-1274(ra) # 5b80 <unlink>
      unlink(file);
    5082:	fa840513          	addi	a0,s0,-88
    5086:	00001097          	auipc	ra,0x1
    508a:	afa080e7          	jalr	-1286(ra) # 5b80 <unlink>
      unlink(file);
    508e:	fa840513          	addi	a0,s0,-88
    5092:	00001097          	auipc	ra,0x1
    5096:	aee080e7          	jalr	-1298(ra) # 5b80 <unlink>
    509a:	bfb5                	j	5016 <concreate+0x24a>
      exit(0);
    509c:	4501                	li	a0,0
    509e:	00001097          	auipc	ra,0x1
    50a2:	a92080e7          	jalr	-1390(ra) # 5b30 <exit>
      close(fd);
    50a6:	00001097          	auipc	ra,0x1
    50aa:	ab2080e7          	jalr	-1358(ra) # 5b58 <close>
    if (pid == 0)
    50ae:	bb65                	j	4e66 <concreate+0x9a>
      close(fd);
    50b0:	00001097          	auipc	ra,0x1
    50b4:	aa8080e7          	jalr	-1368(ra) # 5b58 <close>
      wait(&xstatus);
    50b8:	f6c40513          	addi	a0,s0,-148
    50bc:	00001097          	auipc	ra,0x1
    50c0:	a7c080e7          	jalr	-1412(ra) # 5b38 <wait>
      if (xstatus != 0)
    50c4:	f6c42483          	lw	s1,-148(s0)
    50c8:	da0494e3          	bnez	s1,4e70 <concreate+0xa4>
  for (i = 0; i < N; i++)
    50cc:	2905                	addiw	s2,s2,1
    50ce:	db4906e3          	beq	s2,s4,4e7a <concreate+0xae>
    file[1] = '0' + i;
    50d2:	0309079b          	addiw	a5,s2,48
    50d6:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    50da:	fa840513          	addi	a0,s0,-88
    50de:	00001097          	auipc	ra,0x1
    50e2:	aa2080e7          	jalr	-1374(ra) # 5b80 <unlink>
    pid = fork();
    50e6:	00001097          	auipc	ra,0x1
    50ea:	a42080e7          	jalr	-1470(ra) # 5b28 <fork>
    if (pid && (i % 3) == 1)
    50ee:	d20503e3          	beqz	a0,4e14 <concreate+0x48>
    50f2:	036967bb          	remw	a5,s2,s6
    50f6:	d15787e3          	beq	a5,s5,4e04 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    50fa:	20200593          	li	a1,514
    50fe:	fa840513          	addi	a0,s0,-88
    5102:	00001097          	auipc	ra,0x1
    5106:	a6e080e7          	jalr	-1426(ra) # 5b70 <open>
      if (fd < 0)
    510a:	fa0553e3          	bgez	a0,50b0 <concreate+0x2e4>
    510e:	b31d                	j	4e34 <concreate+0x68>
}
    5110:	60ea                	ld	ra,152(sp)
    5112:	644a                	ld	s0,144(sp)
    5114:	64aa                	ld	s1,136(sp)
    5116:	690a                	ld	s2,128(sp)
    5118:	79e6                	ld	s3,120(sp)
    511a:	7a46                	ld	s4,112(sp)
    511c:	7aa6                	ld	s5,104(sp)
    511e:	7b06                	ld	s6,96(sp)
    5120:	6be6                	ld	s7,88(sp)
    5122:	610d                	addi	sp,sp,160
    5124:	8082                	ret

0000000000005126 <bigfile>:
{
    5126:	7139                	addi	sp,sp,-64
    5128:	fc06                	sd	ra,56(sp)
    512a:	f822                	sd	s0,48(sp)
    512c:	f426                	sd	s1,40(sp)
    512e:	f04a                	sd	s2,32(sp)
    5130:	ec4e                	sd	s3,24(sp)
    5132:	e852                	sd	s4,16(sp)
    5134:	e456                	sd	s5,8(sp)
    5136:	0080                	addi	s0,sp,64
    5138:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    513a:	00003517          	auipc	a0,0x3
    513e:	d5650513          	addi	a0,a0,-682 # 7e90 <malloc+0x1f0a>
    5142:	00001097          	auipc	ra,0x1
    5146:	a3e080e7          	jalr	-1474(ra) # 5b80 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    514a:	20200593          	li	a1,514
    514e:	00003517          	auipc	a0,0x3
    5152:	d4250513          	addi	a0,a0,-702 # 7e90 <malloc+0x1f0a>
    5156:	00001097          	auipc	ra,0x1
    515a:	a1a080e7          	jalr	-1510(ra) # 5b70 <open>
    515e:	89aa                	mv	s3,a0
  for (i = 0; i < N; i++)
    5160:	4481                	li	s1,0
    memset(buf, i, SZ);
    5162:	00008917          	auipc	s2,0x8
    5166:	b1690913          	addi	s2,s2,-1258 # cc78 <buf>
  for (i = 0; i < N; i++)
    516a:	4a51                	li	s4,20
  if (fd < 0)
    516c:	0a054063          	bltz	a0,520c <bigfile+0xe6>
    memset(buf, i, SZ);
    5170:	25800613          	li	a2,600
    5174:	85a6                	mv	a1,s1
    5176:	854a                	mv	a0,s2
    5178:	00000097          	auipc	ra,0x0
    517c:	7bc080e7          	jalr	1980(ra) # 5934 <memset>
    if (write(fd, buf, SZ) != SZ)
    5180:	25800613          	li	a2,600
    5184:	85ca                	mv	a1,s2
    5186:	854e                	mv	a0,s3
    5188:	00001097          	auipc	ra,0x1
    518c:	9c8080e7          	jalr	-1592(ra) # 5b50 <write>
    5190:	25800793          	li	a5,600
    5194:	08f51a63          	bne	a0,a5,5228 <bigfile+0x102>
  for (i = 0; i < N; i++)
    5198:	2485                	addiw	s1,s1,1
    519a:	fd449be3          	bne	s1,s4,5170 <bigfile+0x4a>
  close(fd);
    519e:	854e                	mv	a0,s3
    51a0:	00001097          	auipc	ra,0x1
    51a4:	9b8080e7          	jalr	-1608(ra) # 5b58 <close>
  fd = open("bigfile.dat", 0);
    51a8:	4581                	li	a1,0
    51aa:	00003517          	auipc	a0,0x3
    51ae:	ce650513          	addi	a0,a0,-794 # 7e90 <malloc+0x1f0a>
    51b2:	00001097          	auipc	ra,0x1
    51b6:	9be080e7          	jalr	-1602(ra) # 5b70 <open>
    51ba:	8a2a                	mv	s4,a0
  total = 0;
    51bc:	4981                	li	s3,0
  for (i = 0;; i++)
    51be:	4481                	li	s1,0
    cc = read(fd, buf, SZ / 2);
    51c0:	00008917          	auipc	s2,0x8
    51c4:	ab890913          	addi	s2,s2,-1352 # cc78 <buf>
  if (fd < 0)
    51c8:	06054e63          	bltz	a0,5244 <bigfile+0x11e>
    cc = read(fd, buf, SZ / 2);
    51cc:	12c00613          	li	a2,300
    51d0:	85ca                	mv	a1,s2
    51d2:	8552                	mv	a0,s4
    51d4:	00001097          	auipc	ra,0x1
    51d8:	974080e7          	jalr	-1676(ra) # 5b48 <read>
    if (cc < 0)
    51dc:	08054263          	bltz	a0,5260 <bigfile+0x13a>
    if (cc == 0)
    51e0:	c971                	beqz	a0,52b4 <bigfile+0x18e>
    if (cc != SZ / 2)
    51e2:	12c00793          	li	a5,300
    51e6:	08f51b63          	bne	a0,a5,527c <bigfile+0x156>
    if (buf[0] != i / 2 || buf[SZ / 2 - 1] != i / 2)
    51ea:	01f4d79b          	srliw	a5,s1,0x1f
    51ee:	9fa5                	addw	a5,a5,s1
    51f0:	4017d79b          	sraiw	a5,a5,0x1
    51f4:	00094703          	lbu	a4,0(s2)
    51f8:	0af71063          	bne	a4,a5,5298 <bigfile+0x172>
    51fc:	12b94703          	lbu	a4,299(s2)
    5200:	08f71c63          	bne	a4,a5,5298 <bigfile+0x172>
    total += cc;
    5204:	12c9899b          	addiw	s3,s3,300
  for (i = 0;; i++)
    5208:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ / 2);
    520a:	b7c9                	j	51cc <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    520c:	85d6                	mv	a1,s5
    520e:	00003517          	auipc	a0,0x3
    5212:	c9250513          	addi	a0,a0,-878 # 7ea0 <malloc+0x1f1a>
    5216:	00001097          	auipc	ra,0x1
    521a:	cb2080e7          	jalr	-846(ra) # 5ec8 <printf>
    exit(1);
    521e:	4505                	li	a0,1
    5220:	00001097          	auipc	ra,0x1
    5224:	910080e7          	jalr	-1776(ra) # 5b30 <exit>
      printf("%s: write bigfile failed\n", s);
    5228:	85d6                	mv	a1,s5
    522a:	00003517          	auipc	a0,0x3
    522e:	c9650513          	addi	a0,a0,-874 # 7ec0 <malloc+0x1f3a>
    5232:	00001097          	auipc	ra,0x1
    5236:	c96080e7          	jalr	-874(ra) # 5ec8 <printf>
      exit(1);
    523a:	4505                	li	a0,1
    523c:	00001097          	auipc	ra,0x1
    5240:	8f4080e7          	jalr	-1804(ra) # 5b30 <exit>
    printf("%s: cannot open bigfile\n", s);
    5244:	85d6                	mv	a1,s5
    5246:	00003517          	auipc	a0,0x3
    524a:	c9a50513          	addi	a0,a0,-870 # 7ee0 <malloc+0x1f5a>
    524e:	00001097          	auipc	ra,0x1
    5252:	c7a080e7          	jalr	-902(ra) # 5ec8 <printf>
    exit(1);
    5256:	4505                	li	a0,1
    5258:	00001097          	auipc	ra,0x1
    525c:	8d8080e7          	jalr	-1832(ra) # 5b30 <exit>
      printf("%s: read bigfile failed\n", s);
    5260:	85d6                	mv	a1,s5
    5262:	00003517          	auipc	a0,0x3
    5266:	c9e50513          	addi	a0,a0,-866 # 7f00 <malloc+0x1f7a>
    526a:	00001097          	auipc	ra,0x1
    526e:	c5e080e7          	jalr	-930(ra) # 5ec8 <printf>
      exit(1);
    5272:	4505                	li	a0,1
    5274:	00001097          	auipc	ra,0x1
    5278:	8bc080e7          	jalr	-1860(ra) # 5b30 <exit>
      printf("%s: short read bigfile\n", s);
    527c:	85d6                	mv	a1,s5
    527e:	00003517          	auipc	a0,0x3
    5282:	ca250513          	addi	a0,a0,-862 # 7f20 <malloc+0x1f9a>
    5286:	00001097          	auipc	ra,0x1
    528a:	c42080e7          	jalr	-958(ra) # 5ec8 <printf>
      exit(1);
    528e:	4505                	li	a0,1
    5290:	00001097          	auipc	ra,0x1
    5294:	8a0080e7          	jalr	-1888(ra) # 5b30 <exit>
      printf("%s: read bigfile wrong data\n", s);
    5298:	85d6                	mv	a1,s5
    529a:	00003517          	auipc	a0,0x3
    529e:	c9e50513          	addi	a0,a0,-866 # 7f38 <malloc+0x1fb2>
    52a2:	00001097          	auipc	ra,0x1
    52a6:	c26080e7          	jalr	-986(ra) # 5ec8 <printf>
      exit(1);
    52aa:	4505                	li	a0,1
    52ac:	00001097          	auipc	ra,0x1
    52b0:	884080e7          	jalr	-1916(ra) # 5b30 <exit>
  close(fd);
    52b4:	8552                	mv	a0,s4
    52b6:	00001097          	auipc	ra,0x1
    52ba:	8a2080e7          	jalr	-1886(ra) # 5b58 <close>
  if (total != N * SZ)
    52be:	678d                	lui	a5,0x3
    52c0:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrklast+0x7c>
    52c4:	02f99363          	bne	s3,a5,52ea <bigfile+0x1c4>
  unlink("bigfile.dat");
    52c8:	00003517          	auipc	a0,0x3
    52cc:	bc850513          	addi	a0,a0,-1080 # 7e90 <malloc+0x1f0a>
    52d0:	00001097          	auipc	ra,0x1
    52d4:	8b0080e7          	jalr	-1872(ra) # 5b80 <unlink>
}
    52d8:	70e2                	ld	ra,56(sp)
    52da:	7442                	ld	s0,48(sp)
    52dc:	74a2                	ld	s1,40(sp)
    52de:	7902                	ld	s2,32(sp)
    52e0:	69e2                	ld	s3,24(sp)
    52e2:	6a42                	ld	s4,16(sp)
    52e4:	6aa2                	ld	s5,8(sp)
    52e6:	6121                	addi	sp,sp,64
    52e8:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    52ea:	85d6                	mv	a1,s5
    52ec:	00003517          	auipc	a0,0x3
    52f0:	c6c50513          	addi	a0,a0,-916 # 7f58 <malloc+0x1fd2>
    52f4:	00001097          	auipc	ra,0x1
    52f8:	bd4080e7          	jalr	-1068(ra) # 5ec8 <printf>
    exit(1);
    52fc:	4505                	li	a0,1
    52fe:	00001097          	auipc	ra,0x1
    5302:	832080e7          	jalr	-1998(ra) # 5b30 <exit>

0000000000005306 <fsfull>:
{
    5306:	7171                	addi	sp,sp,-176
    5308:	f506                	sd	ra,168(sp)
    530a:	f122                	sd	s0,160(sp)
    530c:	ed26                	sd	s1,152(sp)
    530e:	e94a                	sd	s2,144(sp)
    5310:	e54e                	sd	s3,136(sp)
    5312:	e152                	sd	s4,128(sp)
    5314:	fcd6                	sd	s5,120(sp)
    5316:	f8da                	sd	s6,112(sp)
    5318:	f4de                	sd	s7,104(sp)
    531a:	f0e2                	sd	s8,96(sp)
    531c:	ece6                	sd	s9,88(sp)
    531e:	e8ea                	sd	s10,80(sp)
    5320:	e4ee                	sd	s11,72(sp)
    5322:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    5324:	00003517          	auipc	a0,0x3
    5328:	c5450513          	addi	a0,a0,-940 # 7f78 <malloc+0x1ff2>
    532c:	00001097          	auipc	ra,0x1
    5330:	b9c080e7          	jalr	-1124(ra) # 5ec8 <printf>
  for (nfiles = 0;; nfiles++)
    5334:	4481                	li	s1,0
    name[0] = 'f';
    5336:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    533a:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    533e:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    5342:	4b29                	li	s6,10
    printf("writing %s\n", name);
    5344:	00003c97          	auipc	s9,0x3
    5348:	c44c8c93          	addi	s9,s9,-956 # 7f88 <malloc+0x2002>
    int total = 0;
    534c:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    534e:	00008a17          	auipc	s4,0x8
    5352:	92aa0a13          	addi	s4,s4,-1750 # cc78 <buf>
    name[0] = 'f';
    5356:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    535a:	0384c7bb          	divw	a5,s1,s8
    535e:	0307879b          	addiw	a5,a5,48
    5362:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5366:	0384e7bb          	remw	a5,s1,s8
    536a:	0377c7bb          	divw	a5,a5,s7
    536e:	0307879b          	addiw	a5,a5,48
    5372:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5376:	0374e7bb          	remw	a5,s1,s7
    537a:	0367c7bb          	divw	a5,a5,s6
    537e:	0307879b          	addiw	a5,a5,48
    5382:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    5386:	0364e7bb          	remw	a5,s1,s6
    538a:	0307879b          	addiw	a5,a5,48
    538e:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5392:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    5396:	f5040593          	addi	a1,s0,-176
    539a:	8566                	mv	a0,s9
    539c:	00001097          	auipc	ra,0x1
    53a0:	b2c080e7          	jalr	-1236(ra) # 5ec8 <printf>
    int fd = open(name, O_CREATE | O_RDWR);
    53a4:	20200593          	li	a1,514
    53a8:	f5040513          	addi	a0,s0,-176
    53ac:	00000097          	auipc	ra,0x0
    53b0:	7c4080e7          	jalr	1988(ra) # 5b70 <open>
    53b4:	892a                	mv	s2,a0
    if (fd < 0)
    53b6:	0a055663          	bgez	a0,5462 <fsfull+0x15c>
      printf("open %s failed\n", name);
    53ba:	f5040593          	addi	a1,s0,-176
    53be:	00003517          	auipc	a0,0x3
    53c2:	bda50513          	addi	a0,a0,-1062 # 7f98 <malloc+0x2012>
    53c6:	00001097          	auipc	ra,0x1
    53ca:	b02080e7          	jalr	-1278(ra) # 5ec8 <printf>
  while (nfiles >= 0)
    53ce:	0604c363          	bltz	s1,5434 <fsfull+0x12e>
    name[0] = 'f';
    53d2:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    53d6:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    53da:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    53de:	4929                	li	s2,10
  while (nfiles >= 0)
    53e0:	5afd                	li	s5,-1
    name[0] = 'f';
    53e2:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    53e6:	0344c7bb          	divw	a5,s1,s4
    53ea:	0307879b          	addiw	a5,a5,48
    53ee:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    53f2:	0344e7bb          	remw	a5,s1,s4
    53f6:	0337c7bb          	divw	a5,a5,s3
    53fa:	0307879b          	addiw	a5,a5,48
    53fe:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5402:	0334e7bb          	remw	a5,s1,s3
    5406:	0327c7bb          	divw	a5,a5,s2
    540a:	0307879b          	addiw	a5,a5,48
    540e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    5412:	0324e7bb          	remw	a5,s1,s2
    5416:	0307879b          	addiw	a5,a5,48
    541a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    541e:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    5422:	f5040513          	addi	a0,s0,-176
    5426:	00000097          	auipc	ra,0x0
    542a:	75a080e7          	jalr	1882(ra) # 5b80 <unlink>
    nfiles--;
    542e:	34fd                	addiw	s1,s1,-1
  while (nfiles >= 0)
    5430:	fb5499e3          	bne	s1,s5,53e2 <fsfull+0xdc>
  printf("fsfull test finished\n");
    5434:	00003517          	auipc	a0,0x3
    5438:	b8450513          	addi	a0,a0,-1148 # 7fb8 <malloc+0x2032>
    543c:	00001097          	auipc	ra,0x1
    5440:	a8c080e7          	jalr	-1396(ra) # 5ec8 <printf>
}
    5444:	70aa                	ld	ra,168(sp)
    5446:	740a                	ld	s0,160(sp)
    5448:	64ea                	ld	s1,152(sp)
    544a:	694a                	ld	s2,144(sp)
    544c:	69aa                	ld	s3,136(sp)
    544e:	6a0a                	ld	s4,128(sp)
    5450:	7ae6                	ld	s5,120(sp)
    5452:	7b46                	ld	s6,112(sp)
    5454:	7ba6                	ld	s7,104(sp)
    5456:	7c06                	ld	s8,96(sp)
    5458:	6ce6                	ld	s9,88(sp)
    545a:	6d46                	ld	s10,80(sp)
    545c:	6da6                	ld	s11,72(sp)
    545e:	614d                	addi	sp,sp,176
    5460:	8082                	ret
    int total = 0;
    5462:	89ee                	mv	s3,s11
      if (cc < BSIZE)
    5464:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    5468:	40000613          	li	a2,1024
    546c:	85d2                	mv	a1,s4
    546e:	854a                	mv	a0,s2
    5470:	00000097          	auipc	ra,0x0
    5474:	6e0080e7          	jalr	1760(ra) # 5b50 <write>
      if (cc < BSIZE)
    5478:	00aad563          	bge	s5,a0,5482 <fsfull+0x17c>
      total += cc;
    547c:	00a989bb          	addw	s3,s3,a0
    {
    5480:	b7e5                	j	5468 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    5482:	85ce                	mv	a1,s3
    5484:	00003517          	auipc	a0,0x3
    5488:	b2450513          	addi	a0,a0,-1244 # 7fa8 <malloc+0x2022>
    548c:	00001097          	auipc	ra,0x1
    5490:	a3c080e7          	jalr	-1476(ra) # 5ec8 <printf>
    close(fd);
    5494:	854a                	mv	a0,s2
    5496:	00000097          	auipc	ra,0x0
    549a:	6c2080e7          	jalr	1730(ra) # 5b58 <close>
    if (total == 0)
    549e:	f20988e3          	beqz	s3,53ce <fsfull+0xc8>
  for (nfiles = 0;; nfiles++)
    54a2:	2485                	addiw	s1,s1,1
  {
    54a4:	bd4d                	j	5356 <fsfull+0x50>

00000000000054a6 <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int run(void f(char *), char *s)
{
    54a6:	7179                	addi	sp,sp,-48
    54a8:	f406                	sd	ra,40(sp)
    54aa:	f022                	sd	s0,32(sp)
    54ac:	ec26                	sd	s1,24(sp)
    54ae:	e84a                	sd	s2,16(sp)
    54b0:	1800                	addi	s0,sp,48
    54b2:	84aa                	mv	s1,a0
    54b4:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    54b6:	00003517          	auipc	a0,0x3
    54ba:	b1a50513          	addi	a0,a0,-1254 # 7fd0 <malloc+0x204a>
    54be:	00001097          	auipc	ra,0x1
    54c2:	a0a080e7          	jalr	-1526(ra) # 5ec8 <printf>
  if ((pid = fork()) < 0)
    54c6:	00000097          	auipc	ra,0x0
    54ca:	662080e7          	jalr	1634(ra) # 5b28 <fork>
    54ce:	02054e63          	bltz	a0,550a <run+0x64>
  {
    printf("runtest: fork error\n");
    exit(1);
  }
  if (pid == 0)
    54d2:	c929                	beqz	a0,5524 <run+0x7e>
    f(s);
    exit(0);
  }
  else
  {
    wait(&xstatus);
    54d4:	fdc40513          	addi	a0,s0,-36
    54d8:	00000097          	auipc	ra,0x0
    54dc:	660080e7          	jalr	1632(ra) # 5b38 <wait>
    if (xstatus != 0)
    54e0:	fdc42783          	lw	a5,-36(s0)
    54e4:	c7b9                	beqz	a5,5532 <run+0x8c>
      printf("FAILED\n");
    54e6:	00003517          	auipc	a0,0x3
    54ea:	b1250513          	addi	a0,a0,-1262 # 7ff8 <malloc+0x2072>
    54ee:	00001097          	auipc	ra,0x1
    54f2:	9da080e7          	jalr	-1574(ra) # 5ec8 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    54f6:	fdc42503          	lw	a0,-36(s0)
  }
}
    54fa:	00153513          	seqz	a0,a0
    54fe:	70a2                	ld	ra,40(sp)
    5500:	7402                	ld	s0,32(sp)
    5502:	64e2                	ld	s1,24(sp)
    5504:	6942                	ld	s2,16(sp)
    5506:	6145                	addi	sp,sp,48
    5508:	8082                	ret
    printf("runtest: fork error\n");
    550a:	00003517          	auipc	a0,0x3
    550e:	ad650513          	addi	a0,a0,-1322 # 7fe0 <malloc+0x205a>
    5512:	00001097          	auipc	ra,0x1
    5516:	9b6080e7          	jalr	-1610(ra) # 5ec8 <printf>
    exit(1);
    551a:	4505                	li	a0,1
    551c:	00000097          	auipc	ra,0x0
    5520:	614080e7          	jalr	1556(ra) # 5b30 <exit>
    f(s);
    5524:	854a                	mv	a0,s2
    5526:	9482                	jalr	s1
    exit(0);
    5528:	4501                	li	a0,0
    552a:	00000097          	auipc	ra,0x0
    552e:	606080e7          	jalr	1542(ra) # 5b30 <exit>
      printf("OK\n");
    5532:	00003517          	auipc	a0,0x3
    5536:	ace50513          	addi	a0,a0,-1330 # 8000 <malloc+0x207a>
    553a:	00001097          	auipc	ra,0x1
    553e:	98e080e7          	jalr	-1650(ra) # 5ec8 <printf>
    5542:	bf55                	j	54f6 <run+0x50>

0000000000005544 <runtests>:

int runtests(struct test *tests, char *justone)
{
    5544:	1101                	addi	sp,sp,-32
    5546:	ec06                	sd	ra,24(sp)
    5548:	e822                	sd	s0,16(sp)
    554a:	e426                	sd	s1,8(sp)
    554c:	e04a                	sd	s2,0(sp)
    554e:	1000                	addi	s0,sp,32
    5550:	84aa                	mv	s1,a0
    5552:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++)
    5554:	6508                	ld	a0,8(a0)
    5556:	ed09                	bnez	a0,5570 <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    5558:	4501                	li	a0,0
    555a:	a82d                	j	5594 <runtests+0x50>
      if (!run(t->f, t->s))
    555c:	648c                	ld	a1,8(s1)
    555e:	6088                	ld	a0,0(s1)
    5560:	00000097          	auipc	ra,0x0
    5564:	f46080e7          	jalr	-186(ra) # 54a6 <run>
    5568:	cd09                	beqz	a0,5582 <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++)
    556a:	04c1                	addi	s1,s1,16
    556c:	6488                	ld	a0,8(s1)
    556e:	c11d                	beqz	a0,5594 <runtests+0x50>
    if ((justone == 0) || strcmp(t->s, justone) == 0)
    5570:	fe0906e3          	beqz	s2,555c <runtests+0x18>
    5574:	85ca                	mv	a1,s2
    5576:	00000097          	auipc	ra,0x0
    557a:	368080e7          	jalr	872(ra) # 58de <strcmp>
    557e:	f575                	bnez	a0,556a <runtests+0x26>
    5580:	bff1                	j	555c <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    5582:	00003517          	auipc	a0,0x3
    5586:	a8650513          	addi	a0,a0,-1402 # 8008 <malloc+0x2082>
    558a:	00001097          	auipc	ra,0x1
    558e:	93e080e7          	jalr	-1730(ra) # 5ec8 <printf>
        return 1;
    5592:	4505                	li	a0,1
}
    5594:	60e2                	ld	ra,24(sp)
    5596:	6442                	ld	s0,16(sp)
    5598:	64a2                	ld	s1,8(sp)
    559a:	6902                	ld	s2,0(sp)
    559c:	6105                	addi	sp,sp,32
    559e:	8082                	ret

00000000000055a0 <countfree>:
// touches the pages to force allocation.
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int countfree()
{
    55a0:	7139                	addi	sp,sp,-64
    55a2:	fc06                	sd	ra,56(sp)
    55a4:	f822                	sd	s0,48(sp)
    55a6:	f426                	sd	s1,40(sp)
    55a8:	f04a                	sd	s2,32(sp)
    55aa:	ec4e                	sd	s3,24(sp)
    55ac:	0080                	addi	s0,sp,64
  int fds[2];

  if (pipe(fds) < 0)
    55ae:	fc840513          	addi	a0,s0,-56
    55b2:	00000097          	auipc	ra,0x0
    55b6:	58e080e7          	jalr	1422(ra) # 5b40 <pipe>
    55ba:	06054763          	bltz	a0,5628 <countfree+0x88>
  {
    printf("pipe() failed in countfree()\n");
    exit(1);
  }

  int pid = fork();
    55be:	00000097          	auipc	ra,0x0
    55c2:	56a080e7          	jalr	1386(ra) # 5b28 <fork>

  if (pid < 0)
    55c6:	06054e63          	bltz	a0,5642 <countfree+0xa2>
  {
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if (pid == 0)
    55ca:	ed51                	bnez	a0,5666 <countfree+0xc6>
  {
    close(fds[0]);
    55cc:	fc842503          	lw	a0,-56(s0)
    55d0:	00000097          	auipc	ra,0x0
    55d4:	588080e7          	jalr	1416(ra) # 5b58 <close>

    while (1)
    {
      uint64 a = (uint64)sbrk(4096);
      if (a == 0xffffffffffffffff)
    55d8:	597d                	li	s2,-1
      {
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    55da:	4485                	li	s1,1

      // report back one more page.
      if (write(fds[1], "x", 1) != 1)
    55dc:	00001997          	auipc	s3,0x1
    55e0:	b5c98993          	addi	s3,s3,-1188 # 6138 <malloc+0x1b2>
      uint64 a = (uint64)sbrk(4096);
    55e4:	6505                	lui	a0,0x1
    55e6:	00000097          	auipc	ra,0x0
    55ea:	5d2080e7          	jalr	1490(ra) # 5bb8 <sbrk>
      if (a == 0xffffffffffffffff)
    55ee:	07250763          	beq	a0,s2,565c <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    55f2:	6785                	lui	a5,0x1
    55f4:	953e                	add	a0,a0,a5
    55f6:	fe950fa3          	sb	s1,-1(a0) # fff <linktest+0xfd>
      if (write(fds[1], "x", 1) != 1)
    55fa:	8626                	mv	a2,s1
    55fc:	85ce                	mv	a1,s3
    55fe:	fcc42503          	lw	a0,-52(s0)
    5602:	00000097          	auipc	ra,0x0
    5606:	54e080e7          	jalr	1358(ra) # 5b50 <write>
    560a:	fc950de3          	beq	a0,s1,55e4 <countfree+0x44>
      {
        printf("write() failed in countfree()\n");
    560e:	00003517          	auipc	a0,0x3
    5612:	a5250513          	addi	a0,a0,-1454 # 8060 <malloc+0x20da>
    5616:	00001097          	auipc	ra,0x1
    561a:	8b2080e7          	jalr	-1870(ra) # 5ec8 <printf>
        exit(1);
    561e:	4505                	li	a0,1
    5620:	00000097          	auipc	ra,0x0
    5624:	510080e7          	jalr	1296(ra) # 5b30 <exit>
    printf("pipe() failed in countfree()\n");
    5628:	00003517          	auipc	a0,0x3
    562c:	9f850513          	addi	a0,a0,-1544 # 8020 <malloc+0x209a>
    5630:	00001097          	auipc	ra,0x1
    5634:	898080e7          	jalr	-1896(ra) # 5ec8 <printf>
    exit(1);
    5638:	4505                	li	a0,1
    563a:	00000097          	auipc	ra,0x0
    563e:	4f6080e7          	jalr	1270(ra) # 5b30 <exit>
    printf("fork failed in countfree()\n");
    5642:	00003517          	auipc	a0,0x3
    5646:	9fe50513          	addi	a0,a0,-1538 # 8040 <malloc+0x20ba>
    564a:	00001097          	auipc	ra,0x1
    564e:	87e080e7          	jalr	-1922(ra) # 5ec8 <printf>
    exit(1);
    5652:	4505                	li	a0,1
    5654:	00000097          	auipc	ra,0x0
    5658:	4dc080e7          	jalr	1244(ra) # 5b30 <exit>
      }
    }

    exit(0);
    565c:	4501                	li	a0,0
    565e:	00000097          	auipc	ra,0x0
    5662:	4d2080e7          	jalr	1234(ra) # 5b30 <exit>
  }

  close(fds[1]);
    5666:	fcc42503          	lw	a0,-52(s0)
    566a:	00000097          	auipc	ra,0x0
    566e:	4ee080e7          	jalr	1262(ra) # 5b58 <close>

  int n = 0;
    5672:	4481                	li	s1,0
  while (1)
  {
    char c;
    int cc = read(fds[0], &c, 1);
    5674:	4605                	li	a2,1
    5676:	fc740593          	addi	a1,s0,-57
    567a:	fc842503          	lw	a0,-56(s0)
    567e:	00000097          	auipc	ra,0x0
    5682:	4ca080e7          	jalr	1226(ra) # 5b48 <read>
    if (cc < 0)
    5686:	00054563          	bltz	a0,5690 <countfree+0xf0>
    {
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if (cc == 0)
    568a:	c105                	beqz	a0,56aa <countfree+0x10a>
      break;
    n += 1;
    568c:	2485                	addiw	s1,s1,1
  {
    568e:	b7dd                	j	5674 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5690:	00003517          	auipc	a0,0x3
    5694:	9f050513          	addi	a0,a0,-1552 # 8080 <malloc+0x20fa>
    5698:	00001097          	auipc	ra,0x1
    569c:	830080e7          	jalr	-2000(ra) # 5ec8 <printf>
      exit(1);
    56a0:	4505                	li	a0,1
    56a2:	00000097          	auipc	ra,0x0
    56a6:	48e080e7          	jalr	1166(ra) # 5b30 <exit>
  }

  close(fds[0]);
    56aa:	fc842503          	lw	a0,-56(s0)
    56ae:	00000097          	auipc	ra,0x0
    56b2:	4aa080e7          	jalr	1194(ra) # 5b58 <close>
  wait((int *)0);
    56b6:	4501                	li	a0,0
    56b8:	00000097          	auipc	ra,0x0
    56bc:	480080e7          	jalr	1152(ra) # 5b38 <wait>

  return n;
}
    56c0:	8526                	mv	a0,s1
    56c2:	70e2                	ld	ra,56(sp)
    56c4:	7442                	ld	s0,48(sp)
    56c6:	74a2                	ld	s1,40(sp)
    56c8:	7902                	ld	s2,32(sp)
    56ca:	69e2                	ld	s3,24(sp)
    56cc:	6121                	addi	sp,sp,64
    56ce:	8082                	ret

00000000000056d0 <drivetests>:

int drivetests(int quick, int continuous, char *justone)
{
    56d0:	711d                	addi	sp,sp,-96
    56d2:	ec86                	sd	ra,88(sp)
    56d4:	e8a2                	sd	s0,80(sp)
    56d6:	e4a6                	sd	s1,72(sp)
    56d8:	e0ca                	sd	s2,64(sp)
    56da:	fc4e                	sd	s3,56(sp)
    56dc:	f852                	sd	s4,48(sp)
    56de:	f456                	sd	s5,40(sp)
    56e0:	f05a                	sd	s6,32(sp)
    56e2:	ec5e                	sd	s7,24(sp)
    56e4:	e862                	sd	s8,16(sp)
    56e6:	e466                	sd	s9,8(sp)
    56e8:	e06a                	sd	s10,0(sp)
    56ea:	1080                	addi	s0,sp,96
    56ec:	8a2a                	mv	s4,a0
    56ee:	89ae                	mv	s3,a1
    56f0:	8932                	mv	s2,a2
  do
  {
    printf("usertests starting\n");
    56f2:	00003b97          	auipc	s7,0x3
    56f6:	9aeb8b93          	addi	s7,s7,-1618 # 80a0 <malloc+0x211a>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone))
    56fa:	00004b17          	auipc	s6,0x4
    56fe:	916b0b13          	addi	s6,s6,-1770 # 9010 <quicktests>
    {
      if (continuous != 2)
    5702:	4a89                	li	s5,2
        }
      }
    }
    if ((free1 = countfree()) < free0)
    {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5704:	00003c97          	auipc	s9,0x3
    5708:	9d4c8c93          	addi	s9,s9,-1580 # 80d8 <malloc+0x2152>
      if (runtests(slowtests, justone))
    570c:	00004c17          	auipc	s8,0x4
    5710:	cd4c0c13          	addi	s8,s8,-812 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    5714:	00003d17          	auipc	s10,0x3
    5718:	9a4d0d13          	addi	s10,s10,-1628 # 80b8 <malloc+0x2132>
    571c:	a839                	j	573a <drivetests+0x6a>
    571e:	856a                	mv	a0,s10
    5720:	00000097          	auipc	ra,0x0
    5724:	7a8080e7          	jalr	1960(ra) # 5ec8 <printf>
    5728:	a081                	j	5768 <drivetests+0x98>
    if ((free1 = countfree()) < free0)
    572a:	00000097          	auipc	ra,0x0
    572e:	e76080e7          	jalr	-394(ra) # 55a0 <countfree>
    5732:	06954263          	blt	a0,s1,5796 <drivetests+0xc6>
      if (continuous != 2)
      {
        return 1;
      }
    }
  } while (continuous);
    5736:	06098f63          	beqz	s3,57b4 <drivetests+0xe4>
    printf("usertests starting\n");
    573a:	855e                	mv	a0,s7
    573c:	00000097          	auipc	ra,0x0
    5740:	78c080e7          	jalr	1932(ra) # 5ec8 <printf>
    int free0 = countfree();
    5744:	00000097          	auipc	ra,0x0
    5748:	e5c080e7          	jalr	-420(ra) # 55a0 <countfree>
    574c:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone))
    574e:	85ca                	mv	a1,s2
    5750:	855a                	mv	a0,s6
    5752:	00000097          	auipc	ra,0x0
    5756:	df2080e7          	jalr	-526(ra) # 5544 <runtests>
    575a:	c119                	beqz	a0,5760 <drivetests+0x90>
      if (continuous != 2)
    575c:	05599863          	bne	s3,s5,57ac <drivetests+0xdc>
    if (!quick)
    5760:	fc0a15e3          	bnez	s4,572a <drivetests+0x5a>
      if (justone == 0)
    5764:	fa090de3          	beqz	s2,571e <drivetests+0x4e>
      if (runtests(slowtests, justone))
    5768:	85ca                	mv	a1,s2
    576a:	8562                	mv	a0,s8
    576c:	00000097          	auipc	ra,0x0
    5770:	dd8080e7          	jalr	-552(ra) # 5544 <runtests>
    5774:	d95d                	beqz	a0,572a <drivetests+0x5a>
        if (continuous != 2)
    5776:	03599d63          	bne	s3,s5,57b0 <drivetests+0xe0>
    if ((free1 = countfree()) < free0)
    577a:	00000097          	auipc	ra,0x0
    577e:	e26080e7          	jalr	-474(ra) # 55a0 <countfree>
    5782:	fa955ae3          	bge	a0,s1,5736 <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5786:	8626                	mv	a2,s1
    5788:	85aa                	mv	a1,a0
    578a:	8566                	mv	a0,s9
    578c:	00000097          	auipc	ra,0x0
    5790:	73c080e7          	jalr	1852(ra) # 5ec8 <printf>
      if (continuous != 2)
    5794:	b75d                	j	573a <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5796:	8626                	mv	a2,s1
    5798:	85aa                	mv	a1,a0
    579a:	8566                	mv	a0,s9
    579c:	00000097          	auipc	ra,0x0
    57a0:	72c080e7          	jalr	1836(ra) # 5ec8 <printf>
      if (continuous != 2)
    57a4:	f9598be3          	beq	s3,s5,573a <drivetests+0x6a>
        return 1;
    57a8:	4505                	li	a0,1
    57aa:	a031                	j	57b6 <drivetests+0xe6>
        return 1;
    57ac:	4505                	li	a0,1
    57ae:	a021                	j	57b6 <drivetests+0xe6>
          return 1;
    57b0:	4505                	li	a0,1
    57b2:	a011                	j	57b6 <drivetests+0xe6>
  return 0;
    57b4:	854e                	mv	a0,s3
}
    57b6:	60e6                	ld	ra,88(sp)
    57b8:	6446                	ld	s0,80(sp)
    57ba:	64a6                	ld	s1,72(sp)
    57bc:	6906                	ld	s2,64(sp)
    57be:	79e2                	ld	s3,56(sp)
    57c0:	7a42                	ld	s4,48(sp)
    57c2:	7aa2                	ld	s5,40(sp)
    57c4:	7b02                	ld	s6,32(sp)
    57c6:	6be2                	ld	s7,24(sp)
    57c8:	6c42                	ld	s8,16(sp)
    57ca:	6ca2                	ld	s9,8(sp)
    57cc:	6d02                	ld	s10,0(sp)
    57ce:	6125                	addi	sp,sp,96
    57d0:	8082                	ret

00000000000057d2 <main>:

int main(int argc, char *argv[])
{
    57d2:	1101                	addi	sp,sp,-32
    57d4:	ec06                	sd	ra,24(sp)
    57d6:	e822                	sd	s0,16(sp)
    57d8:	e426                	sd	s1,8(sp)
    57da:	e04a                	sd	s2,0(sp)
    57dc:	1000                	addi	s0,sp,32
    57de:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if (argc == 2 && strcmp(argv[1], "-q") == 0)
    57e0:	4789                	li	a5,2
    57e2:	02f50363          	beq	a0,a5,5808 <main+0x36>
  }
  else if (argc == 2 && argv[1][0] != '-')
  {
    justone = argv[1];
  }
  else if (argc > 1)
    57e6:	4785                	li	a5,1
    57e8:	06a7cd63          	blt	a5,a0,5862 <main+0x90>
  char *justone = 0;
    57ec:	4601                	li	a2,0
  int quick = 0;
    57ee:	4501                	li	a0,0
  int continuous = 0;
    57f0:	4481                	li	s1,0
  {
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone))
    57f2:	85a6                	mv	a1,s1
    57f4:	00000097          	auipc	ra,0x0
    57f8:	edc080e7          	jalr	-292(ra) # 56d0 <drivetests>
    57fc:	c949                	beqz	a0,588e <main+0xbc>
  {
    exit(1);
    57fe:	4505                	li	a0,1
    5800:	00000097          	auipc	ra,0x0
    5804:	330080e7          	jalr	816(ra) # 5b30 <exit>
    5808:	892e                	mv	s2,a1
  if (argc == 2 && strcmp(argv[1], "-q") == 0)
    580a:	00003597          	auipc	a1,0x3
    580e:	8fe58593          	addi	a1,a1,-1794 # 8108 <malloc+0x2182>
    5812:	00893503          	ld	a0,8(s2)
    5816:	00000097          	auipc	ra,0x0
    581a:	0c8080e7          	jalr	200(ra) # 58de <strcmp>
    581e:	cd39                	beqz	a0,587c <main+0xaa>
  else if (argc == 2 && strcmp(argv[1], "-c") == 0)
    5820:	00003597          	auipc	a1,0x3
    5824:	94058593          	addi	a1,a1,-1728 # 8160 <malloc+0x21da>
    5828:	00893503          	ld	a0,8(s2)
    582c:	00000097          	auipc	ra,0x0
    5830:	0b2080e7          	jalr	178(ra) # 58de <strcmp>
    5834:	c931                	beqz	a0,5888 <main+0xb6>
  else if (argc == 2 && strcmp(argv[1], "-C") == 0)
    5836:	00003597          	auipc	a1,0x3
    583a:	92258593          	addi	a1,a1,-1758 # 8158 <malloc+0x21d2>
    583e:	00893503          	ld	a0,8(s2)
    5842:	00000097          	auipc	ra,0x0
    5846:	09c080e7          	jalr	156(ra) # 58de <strcmp>
    584a:	cd0d                	beqz	a0,5884 <main+0xb2>
  else if (argc == 2 && argv[1][0] != '-')
    584c:	00893603          	ld	a2,8(s2)
    5850:	00064703          	lbu	a4,0(a2) # 3000 <execout+0x94>
    5854:	02d00793          	li	a5,45
    5858:	00f70563          	beq	a4,a5,5862 <main+0x90>
  int quick = 0;
    585c:	4501                	li	a0,0
  int continuous = 0;
    585e:	4481                	li	s1,0
    5860:	bf49                	j	57f2 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5862:	00003517          	auipc	a0,0x3
    5866:	8ae50513          	addi	a0,a0,-1874 # 8110 <malloc+0x218a>
    586a:	00000097          	auipc	ra,0x0
    586e:	65e080e7          	jalr	1630(ra) # 5ec8 <printf>
    exit(1);
    5872:	4505                	li	a0,1
    5874:	00000097          	auipc	ra,0x0
    5878:	2bc080e7          	jalr	700(ra) # 5b30 <exit>
  int continuous = 0;
    587c:	84aa                	mv	s1,a0
  char *justone = 0;
    587e:	4601                	li	a2,0
    quick = 1;
    5880:	4505                	li	a0,1
    5882:	bf85                	j	57f2 <main+0x20>
  char *justone = 0;
    5884:	4601                	li	a2,0
    5886:	b7b5                	j	57f2 <main+0x20>
    5888:	4601                	li	a2,0
    continuous = 1;
    588a:	4485                	li	s1,1
    588c:	b79d                	j	57f2 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    588e:	00003517          	auipc	a0,0x3
    5892:	8b250513          	addi	a0,a0,-1870 # 8140 <malloc+0x21ba>
    5896:	00000097          	auipc	ra,0x0
    589a:	632080e7          	jalr	1586(ra) # 5ec8 <printf>
  exit(0);
    589e:	4501                	li	a0,0
    58a0:	00000097          	auipc	ra,0x0
    58a4:	290080e7          	jalr	656(ra) # 5b30 <exit>

00000000000058a8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    58a8:	1141                	addi	sp,sp,-16
    58aa:	e406                	sd	ra,8(sp)
    58ac:	e022                	sd	s0,0(sp)
    58ae:	0800                	addi	s0,sp,16
  extern int main();
  main();
    58b0:	00000097          	auipc	ra,0x0
    58b4:	f22080e7          	jalr	-222(ra) # 57d2 <main>
  exit(0);
    58b8:	4501                	li	a0,0
    58ba:	00000097          	auipc	ra,0x0
    58be:	276080e7          	jalr	630(ra) # 5b30 <exit>

00000000000058c2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    58c2:	1141                	addi	sp,sp,-16
    58c4:	e422                	sd	s0,8(sp)
    58c6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    58c8:	87aa                	mv	a5,a0
    58ca:	0585                	addi	a1,a1,1
    58cc:	0785                	addi	a5,a5,1
    58ce:	fff5c703          	lbu	a4,-1(a1)
    58d2:	fee78fa3          	sb	a4,-1(a5) # fff <linktest+0xfd>
    58d6:	fb75                	bnez	a4,58ca <strcpy+0x8>
    ;
  return os;
}
    58d8:	6422                	ld	s0,8(sp)
    58da:	0141                	addi	sp,sp,16
    58dc:	8082                	ret

00000000000058de <strcmp>:

int
strcmp(const char *p, const char *q)
{
    58de:	1141                	addi	sp,sp,-16
    58e0:	e422                	sd	s0,8(sp)
    58e2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    58e4:	00054783          	lbu	a5,0(a0)
    58e8:	cb91                	beqz	a5,58fc <strcmp+0x1e>
    58ea:	0005c703          	lbu	a4,0(a1)
    58ee:	00f71763          	bne	a4,a5,58fc <strcmp+0x1e>
    p++, q++;
    58f2:	0505                	addi	a0,a0,1
    58f4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    58f6:	00054783          	lbu	a5,0(a0)
    58fa:	fbe5                	bnez	a5,58ea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    58fc:	0005c503          	lbu	a0,0(a1)
}
    5900:	40a7853b          	subw	a0,a5,a0
    5904:	6422                	ld	s0,8(sp)
    5906:	0141                	addi	sp,sp,16
    5908:	8082                	ret

000000000000590a <strlen>:

uint
strlen(const char *s)
{
    590a:	1141                	addi	sp,sp,-16
    590c:	e422                	sd	s0,8(sp)
    590e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5910:	00054783          	lbu	a5,0(a0)
    5914:	cf91                	beqz	a5,5930 <strlen+0x26>
    5916:	0505                	addi	a0,a0,1
    5918:	87aa                	mv	a5,a0
    591a:	4685                	li	a3,1
    591c:	9e89                	subw	a3,a3,a0
    591e:	00f6853b          	addw	a0,a3,a5
    5922:	0785                	addi	a5,a5,1
    5924:	fff7c703          	lbu	a4,-1(a5)
    5928:	fb7d                	bnez	a4,591e <strlen+0x14>
    ;
  return n;
}
    592a:	6422                	ld	s0,8(sp)
    592c:	0141                	addi	sp,sp,16
    592e:	8082                	ret
  for(n = 0; s[n]; n++)
    5930:	4501                	li	a0,0
    5932:	bfe5                	j	592a <strlen+0x20>

0000000000005934 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5934:	1141                	addi	sp,sp,-16
    5936:	e422                	sd	s0,8(sp)
    5938:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    593a:	ca19                	beqz	a2,5950 <memset+0x1c>
    593c:	87aa                	mv	a5,a0
    593e:	1602                	slli	a2,a2,0x20
    5940:	9201                	srli	a2,a2,0x20
    5942:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    5946:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    594a:	0785                	addi	a5,a5,1
    594c:	fee79de3          	bne	a5,a4,5946 <memset+0x12>
  }
  return dst;
}
    5950:	6422                	ld	s0,8(sp)
    5952:	0141                	addi	sp,sp,16
    5954:	8082                	ret

0000000000005956 <strchr>:

char*
strchr(const char *s, char c)
{
    5956:	1141                	addi	sp,sp,-16
    5958:	e422                	sd	s0,8(sp)
    595a:	0800                	addi	s0,sp,16
  for(; *s; s++)
    595c:	00054783          	lbu	a5,0(a0)
    5960:	cb99                	beqz	a5,5976 <strchr+0x20>
    if(*s == c)
    5962:	00f58763          	beq	a1,a5,5970 <strchr+0x1a>
  for(; *s; s++)
    5966:	0505                	addi	a0,a0,1
    5968:	00054783          	lbu	a5,0(a0)
    596c:	fbfd                	bnez	a5,5962 <strchr+0xc>
      return (char*)s;
  return 0;
    596e:	4501                	li	a0,0
}
    5970:	6422                	ld	s0,8(sp)
    5972:	0141                	addi	sp,sp,16
    5974:	8082                	ret
  return 0;
    5976:	4501                	li	a0,0
    5978:	bfe5                	j	5970 <strchr+0x1a>

000000000000597a <gets>:

char*
gets(char *buf, int max)
{
    597a:	711d                	addi	sp,sp,-96
    597c:	ec86                	sd	ra,88(sp)
    597e:	e8a2                	sd	s0,80(sp)
    5980:	e4a6                	sd	s1,72(sp)
    5982:	e0ca                	sd	s2,64(sp)
    5984:	fc4e                	sd	s3,56(sp)
    5986:	f852                	sd	s4,48(sp)
    5988:	f456                	sd	s5,40(sp)
    598a:	f05a                	sd	s6,32(sp)
    598c:	ec5e                	sd	s7,24(sp)
    598e:	1080                	addi	s0,sp,96
    5990:	8baa                	mv	s7,a0
    5992:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5994:	892a                	mv	s2,a0
    5996:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5998:	4aa9                	li	s5,10
    599a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    599c:	89a6                	mv	s3,s1
    599e:	2485                	addiw	s1,s1,1
    59a0:	0344d863          	bge	s1,s4,59d0 <gets+0x56>
    cc = read(0, &c, 1);
    59a4:	4605                	li	a2,1
    59a6:	faf40593          	addi	a1,s0,-81
    59aa:	4501                	li	a0,0
    59ac:	00000097          	auipc	ra,0x0
    59b0:	19c080e7          	jalr	412(ra) # 5b48 <read>
    if(cc < 1)
    59b4:	00a05e63          	blez	a0,59d0 <gets+0x56>
    buf[i++] = c;
    59b8:	faf44783          	lbu	a5,-81(s0)
    59bc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    59c0:	01578763          	beq	a5,s5,59ce <gets+0x54>
    59c4:	0905                	addi	s2,s2,1
    59c6:	fd679be3          	bne	a5,s6,599c <gets+0x22>
  for(i=0; i+1 < max; ){
    59ca:	89a6                	mv	s3,s1
    59cc:	a011                	j	59d0 <gets+0x56>
    59ce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    59d0:	99de                	add	s3,s3,s7
    59d2:	00098023          	sb	zero,0(s3)
  return buf;
}
    59d6:	855e                	mv	a0,s7
    59d8:	60e6                	ld	ra,88(sp)
    59da:	6446                	ld	s0,80(sp)
    59dc:	64a6                	ld	s1,72(sp)
    59de:	6906                	ld	s2,64(sp)
    59e0:	79e2                	ld	s3,56(sp)
    59e2:	7a42                	ld	s4,48(sp)
    59e4:	7aa2                	ld	s5,40(sp)
    59e6:	7b02                	ld	s6,32(sp)
    59e8:	6be2                	ld	s7,24(sp)
    59ea:	6125                	addi	sp,sp,96
    59ec:	8082                	ret

00000000000059ee <stat>:

int
stat(const char *n, struct stat *st)
{
    59ee:	1101                	addi	sp,sp,-32
    59f0:	ec06                	sd	ra,24(sp)
    59f2:	e822                	sd	s0,16(sp)
    59f4:	e426                	sd	s1,8(sp)
    59f6:	e04a                	sd	s2,0(sp)
    59f8:	1000                	addi	s0,sp,32
    59fa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    59fc:	4581                	li	a1,0
    59fe:	00000097          	auipc	ra,0x0
    5a02:	172080e7          	jalr	370(ra) # 5b70 <open>
  if(fd < 0)
    5a06:	02054563          	bltz	a0,5a30 <stat+0x42>
    5a0a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5a0c:	85ca                	mv	a1,s2
    5a0e:	00000097          	auipc	ra,0x0
    5a12:	17a080e7          	jalr	378(ra) # 5b88 <fstat>
    5a16:	892a                	mv	s2,a0
  close(fd);
    5a18:	8526                	mv	a0,s1
    5a1a:	00000097          	auipc	ra,0x0
    5a1e:	13e080e7          	jalr	318(ra) # 5b58 <close>
  return r;
}
    5a22:	854a                	mv	a0,s2
    5a24:	60e2                	ld	ra,24(sp)
    5a26:	6442                	ld	s0,16(sp)
    5a28:	64a2                	ld	s1,8(sp)
    5a2a:	6902                	ld	s2,0(sp)
    5a2c:	6105                	addi	sp,sp,32
    5a2e:	8082                	ret
    return -1;
    5a30:	597d                	li	s2,-1
    5a32:	bfc5                	j	5a22 <stat+0x34>

0000000000005a34 <atoi>:

int
atoi(const char *s)
{
    5a34:	1141                	addi	sp,sp,-16
    5a36:	e422                	sd	s0,8(sp)
    5a38:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5a3a:	00054603          	lbu	a2,0(a0)
    5a3e:	fd06079b          	addiw	a5,a2,-48
    5a42:	0ff7f793          	andi	a5,a5,255
    5a46:	4725                	li	a4,9
    5a48:	02f76963          	bltu	a4,a5,5a7a <atoi+0x46>
    5a4c:	86aa                	mv	a3,a0
  n = 0;
    5a4e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5a50:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5a52:	0685                	addi	a3,a3,1
    5a54:	0025179b          	slliw	a5,a0,0x2
    5a58:	9fa9                	addw	a5,a5,a0
    5a5a:	0017979b          	slliw	a5,a5,0x1
    5a5e:	9fb1                	addw	a5,a5,a2
    5a60:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5a64:	0006c603          	lbu	a2,0(a3)
    5a68:	fd06071b          	addiw	a4,a2,-48
    5a6c:	0ff77713          	andi	a4,a4,255
    5a70:	fee5f1e3          	bgeu	a1,a4,5a52 <atoi+0x1e>
  return n;
}
    5a74:	6422                	ld	s0,8(sp)
    5a76:	0141                	addi	sp,sp,16
    5a78:	8082                	ret
  n = 0;
    5a7a:	4501                	li	a0,0
    5a7c:	bfe5                	j	5a74 <atoi+0x40>

0000000000005a7e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5a7e:	1141                	addi	sp,sp,-16
    5a80:	e422                	sd	s0,8(sp)
    5a82:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5a84:	02b57463          	bgeu	a0,a1,5aac <memmove+0x2e>
    while(n-- > 0)
    5a88:	00c05f63          	blez	a2,5aa6 <memmove+0x28>
    5a8c:	1602                	slli	a2,a2,0x20
    5a8e:	9201                	srli	a2,a2,0x20
    5a90:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5a94:	872a                	mv	a4,a0
      *dst++ = *src++;
    5a96:	0585                	addi	a1,a1,1
    5a98:	0705                	addi	a4,a4,1
    5a9a:	fff5c683          	lbu	a3,-1(a1)
    5a9e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5aa2:	fee79ae3          	bne	a5,a4,5a96 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5aa6:	6422                	ld	s0,8(sp)
    5aa8:	0141                	addi	sp,sp,16
    5aaa:	8082                	ret
    dst += n;
    5aac:	00c50733          	add	a4,a0,a2
    src += n;
    5ab0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5ab2:	fec05ae3          	blez	a2,5aa6 <memmove+0x28>
    5ab6:	fff6079b          	addiw	a5,a2,-1
    5aba:	1782                	slli	a5,a5,0x20
    5abc:	9381                	srli	a5,a5,0x20
    5abe:	fff7c793          	not	a5,a5
    5ac2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5ac4:	15fd                	addi	a1,a1,-1
    5ac6:	177d                	addi	a4,a4,-1
    5ac8:	0005c683          	lbu	a3,0(a1)
    5acc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5ad0:	fee79ae3          	bne	a5,a4,5ac4 <memmove+0x46>
    5ad4:	bfc9                	j	5aa6 <memmove+0x28>

0000000000005ad6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5ad6:	1141                	addi	sp,sp,-16
    5ad8:	e422                	sd	s0,8(sp)
    5ada:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5adc:	ca05                	beqz	a2,5b0c <memcmp+0x36>
    5ade:	fff6069b          	addiw	a3,a2,-1
    5ae2:	1682                	slli	a3,a3,0x20
    5ae4:	9281                	srli	a3,a3,0x20
    5ae6:	0685                	addi	a3,a3,1
    5ae8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5aea:	00054783          	lbu	a5,0(a0)
    5aee:	0005c703          	lbu	a4,0(a1)
    5af2:	00e79863          	bne	a5,a4,5b02 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5af6:	0505                	addi	a0,a0,1
    p2++;
    5af8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5afa:	fed518e3          	bne	a0,a3,5aea <memcmp+0x14>
  }
  return 0;
    5afe:	4501                	li	a0,0
    5b00:	a019                	j	5b06 <memcmp+0x30>
      return *p1 - *p2;
    5b02:	40e7853b          	subw	a0,a5,a4
}
    5b06:	6422                	ld	s0,8(sp)
    5b08:	0141                	addi	sp,sp,16
    5b0a:	8082                	ret
  return 0;
    5b0c:	4501                	li	a0,0
    5b0e:	bfe5                	j	5b06 <memcmp+0x30>

0000000000005b10 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5b10:	1141                	addi	sp,sp,-16
    5b12:	e406                	sd	ra,8(sp)
    5b14:	e022                	sd	s0,0(sp)
    5b16:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5b18:	00000097          	auipc	ra,0x0
    5b1c:	f66080e7          	jalr	-154(ra) # 5a7e <memmove>
}
    5b20:	60a2                	ld	ra,8(sp)
    5b22:	6402                	ld	s0,0(sp)
    5b24:	0141                	addi	sp,sp,16
    5b26:	8082                	ret

0000000000005b28 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5b28:	4885                	li	a7,1
 ecall
    5b2a:	00000073          	ecall
 ret
    5b2e:	8082                	ret

0000000000005b30 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5b30:	4889                	li	a7,2
 ecall
    5b32:	00000073          	ecall
 ret
    5b36:	8082                	ret

0000000000005b38 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5b38:	488d                	li	a7,3
 ecall
    5b3a:	00000073          	ecall
 ret
    5b3e:	8082                	ret

0000000000005b40 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5b40:	4891                	li	a7,4
 ecall
    5b42:	00000073          	ecall
 ret
    5b46:	8082                	ret

0000000000005b48 <read>:
.global read
read:
 li a7, SYS_read
    5b48:	4895                	li	a7,5
 ecall
    5b4a:	00000073          	ecall
 ret
    5b4e:	8082                	ret

0000000000005b50 <write>:
.global write
write:
 li a7, SYS_write
    5b50:	48c1                	li	a7,16
 ecall
    5b52:	00000073          	ecall
 ret
    5b56:	8082                	ret

0000000000005b58 <close>:
.global close
close:
 li a7, SYS_close
    5b58:	48d5                	li	a7,21
 ecall
    5b5a:	00000073          	ecall
 ret
    5b5e:	8082                	ret

0000000000005b60 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5b60:	4899                	li	a7,6
 ecall
    5b62:	00000073          	ecall
 ret
    5b66:	8082                	ret

0000000000005b68 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5b68:	489d                	li	a7,7
 ecall
    5b6a:	00000073          	ecall
 ret
    5b6e:	8082                	ret

0000000000005b70 <open>:
.global open
open:
 li a7, SYS_open
    5b70:	48bd                	li	a7,15
 ecall
    5b72:	00000073          	ecall
 ret
    5b76:	8082                	ret

0000000000005b78 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5b78:	48c5                	li	a7,17
 ecall
    5b7a:	00000073          	ecall
 ret
    5b7e:	8082                	ret

0000000000005b80 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5b80:	48c9                	li	a7,18
 ecall
    5b82:	00000073          	ecall
 ret
    5b86:	8082                	ret

0000000000005b88 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5b88:	48a1                	li	a7,8
 ecall
    5b8a:	00000073          	ecall
 ret
    5b8e:	8082                	ret

0000000000005b90 <link>:
.global link
link:
 li a7, SYS_link
    5b90:	48cd                	li	a7,19
 ecall
    5b92:	00000073          	ecall
 ret
    5b96:	8082                	ret

0000000000005b98 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5b98:	48d1                	li	a7,20
 ecall
    5b9a:	00000073          	ecall
 ret
    5b9e:	8082                	ret

0000000000005ba0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5ba0:	48a5                	li	a7,9
 ecall
    5ba2:	00000073          	ecall
 ret
    5ba6:	8082                	ret

0000000000005ba8 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5ba8:	48a9                	li	a7,10
 ecall
    5baa:	00000073          	ecall
 ret
    5bae:	8082                	ret

0000000000005bb0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5bb0:	48ad                	li	a7,11
 ecall
    5bb2:	00000073          	ecall
 ret
    5bb6:	8082                	ret

0000000000005bb8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5bb8:	48b1                	li	a7,12
 ecall
    5bba:	00000073          	ecall
 ret
    5bbe:	8082                	ret

0000000000005bc0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5bc0:	48b5                	li	a7,13
 ecall
    5bc2:	00000073          	ecall
 ret
    5bc6:	8082                	ret

0000000000005bc8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5bc8:	48b9                	li	a7,14
 ecall
    5bca:	00000073          	ecall
 ret
    5bce:	8082                	ret

0000000000005bd0 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
    5bd0:	48d9                	li	a7,22
 ecall
    5bd2:	00000073          	ecall
 ret
    5bd6:	8082                	ret

0000000000005bd8 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
    5bd8:	48dd                	li	a7,23
 ecall
    5bda:	00000073          	ecall
 ret
    5bde:	8082                	ret

0000000000005be0 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
    5be0:	48e1                	li	a7,24
 ecall
    5be2:	00000073          	ecall
 ret
    5be6:	8082                	ret

0000000000005be8 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
    5be8:	48e5                	li	a7,25
 ecall
    5bea:	00000073          	ecall
 ret
    5bee:	8082                	ret

0000000000005bf0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5bf0:	1101                	addi	sp,sp,-32
    5bf2:	ec06                	sd	ra,24(sp)
    5bf4:	e822                	sd	s0,16(sp)
    5bf6:	1000                	addi	s0,sp,32
    5bf8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5bfc:	4605                	li	a2,1
    5bfe:	fef40593          	addi	a1,s0,-17
    5c02:	00000097          	auipc	ra,0x0
    5c06:	f4e080e7          	jalr	-178(ra) # 5b50 <write>
}
    5c0a:	60e2                	ld	ra,24(sp)
    5c0c:	6442                	ld	s0,16(sp)
    5c0e:	6105                	addi	sp,sp,32
    5c10:	8082                	ret

0000000000005c12 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5c12:	7139                	addi	sp,sp,-64
    5c14:	fc06                	sd	ra,56(sp)
    5c16:	f822                	sd	s0,48(sp)
    5c18:	f426                	sd	s1,40(sp)
    5c1a:	f04a                	sd	s2,32(sp)
    5c1c:	ec4e                	sd	s3,24(sp)
    5c1e:	0080                	addi	s0,sp,64
    5c20:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5c22:	c299                	beqz	a3,5c28 <printint+0x16>
    5c24:	0805c863          	bltz	a1,5cb4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5c28:	2581                	sext.w	a1,a1
  neg = 0;
    5c2a:	4881                	li	a7,0
    5c2c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5c30:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5c32:	2601                	sext.w	a2,a2
    5c34:	00003517          	auipc	a0,0x3
    5c38:	89c50513          	addi	a0,a0,-1892 # 84d0 <digits>
    5c3c:	883a                	mv	a6,a4
    5c3e:	2705                	addiw	a4,a4,1
    5c40:	02c5f7bb          	remuw	a5,a1,a2
    5c44:	1782                	slli	a5,a5,0x20
    5c46:	9381                	srli	a5,a5,0x20
    5c48:	97aa                	add	a5,a5,a0
    5c4a:	0007c783          	lbu	a5,0(a5)
    5c4e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5c52:	0005879b          	sext.w	a5,a1
    5c56:	02c5d5bb          	divuw	a1,a1,a2
    5c5a:	0685                	addi	a3,a3,1
    5c5c:	fec7f0e3          	bgeu	a5,a2,5c3c <printint+0x2a>
  if(neg)
    5c60:	00088b63          	beqz	a7,5c76 <printint+0x64>
    buf[i++] = '-';
    5c64:	fd040793          	addi	a5,s0,-48
    5c68:	973e                	add	a4,a4,a5
    5c6a:	02d00793          	li	a5,45
    5c6e:	fef70823          	sb	a5,-16(a4)
    5c72:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5c76:	02e05863          	blez	a4,5ca6 <printint+0x94>
    5c7a:	fc040793          	addi	a5,s0,-64
    5c7e:	00e78933          	add	s2,a5,a4
    5c82:	fff78993          	addi	s3,a5,-1
    5c86:	99ba                	add	s3,s3,a4
    5c88:	377d                	addiw	a4,a4,-1
    5c8a:	1702                	slli	a4,a4,0x20
    5c8c:	9301                	srli	a4,a4,0x20
    5c8e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5c92:	fff94583          	lbu	a1,-1(s2)
    5c96:	8526                	mv	a0,s1
    5c98:	00000097          	auipc	ra,0x0
    5c9c:	f58080e7          	jalr	-168(ra) # 5bf0 <putc>
  while(--i >= 0)
    5ca0:	197d                	addi	s2,s2,-1
    5ca2:	ff3918e3          	bne	s2,s3,5c92 <printint+0x80>
}
    5ca6:	70e2                	ld	ra,56(sp)
    5ca8:	7442                	ld	s0,48(sp)
    5caa:	74a2                	ld	s1,40(sp)
    5cac:	7902                	ld	s2,32(sp)
    5cae:	69e2                	ld	s3,24(sp)
    5cb0:	6121                	addi	sp,sp,64
    5cb2:	8082                	ret
    x = -xx;
    5cb4:	40b005bb          	negw	a1,a1
    neg = 1;
    5cb8:	4885                	li	a7,1
    x = -xx;
    5cba:	bf8d                	j	5c2c <printint+0x1a>

0000000000005cbc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5cbc:	7119                	addi	sp,sp,-128
    5cbe:	fc86                	sd	ra,120(sp)
    5cc0:	f8a2                	sd	s0,112(sp)
    5cc2:	f4a6                	sd	s1,104(sp)
    5cc4:	f0ca                	sd	s2,96(sp)
    5cc6:	ecce                	sd	s3,88(sp)
    5cc8:	e8d2                	sd	s4,80(sp)
    5cca:	e4d6                	sd	s5,72(sp)
    5ccc:	e0da                	sd	s6,64(sp)
    5cce:	fc5e                	sd	s7,56(sp)
    5cd0:	f862                	sd	s8,48(sp)
    5cd2:	f466                	sd	s9,40(sp)
    5cd4:	f06a                	sd	s10,32(sp)
    5cd6:	ec6e                	sd	s11,24(sp)
    5cd8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5cda:	0005c903          	lbu	s2,0(a1)
    5cde:	18090f63          	beqz	s2,5e7c <vprintf+0x1c0>
    5ce2:	8aaa                	mv	s5,a0
    5ce4:	8b32                	mv	s6,a2
    5ce6:	00158493          	addi	s1,a1,1
  state = 0;
    5cea:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5cec:	02500a13          	li	s4,37
      if(c == 'd'){
    5cf0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5cf4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5cf8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5cfc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5d00:	00002b97          	auipc	s7,0x2
    5d04:	7d0b8b93          	addi	s7,s7,2000 # 84d0 <digits>
    5d08:	a839                	j	5d26 <vprintf+0x6a>
        putc(fd, c);
    5d0a:	85ca                	mv	a1,s2
    5d0c:	8556                	mv	a0,s5
    5d0e:	00000097          	auipc	ra,0x0
    5d12:	ee2080e7          	jalr	-286(ra) # 5bf0 <putc>
    5d16:	a019                	j	5d1c <vprintf+0x60>
    } else if(state == '%'){
    5d18:	01498f63          	beq	s3,s4,5d36 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5d1c:	0485                	addi	s1,s1,1
    5d1e:	fff4c903          	lbu	s2,-1(s1)
    5d22:	14090d63          	beqz	s2,5e7c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5d26:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5d2a:	fe0997e3          	bnez	s3,5d18 <vprintf+0x5c>
      if(c == '%'){
    5d2e:	fd479ee3          	bne	a5,s4,5d0a <vprintf+0x4e>
        state = '%';
    5d32:	89be                	mv	s3,a5
    5d34:	b7e5                	j	5d1c <vprintf+0x60>
      if(c == 'd'){
    5d36:	05878063          	beq	a5,s8,5d76 <vprintf+0xba>
      } else if(c == 'l') {
    5d3a:	05978c63          	beq	a5,s9,5d92 <vprintf+0xd6>
      } else if(c == 'x') {
    5d3e:	07a78863          	beq	a5,s10,5dae <vprintf+0xf2>
      } else if(c == 'p') {
    5d42:	09b78463          	beq	a5,s11,5dca <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5d46:	07300713          	li	a4,115
    5d4a:	0ce78663          	beq	a5,a4,5e16 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5d4e:	06300713          	li	a4,99
    5d52:	0ee78e63          	beq	a5,a4,5e4e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5d56:	11478863          	beq	a5,s4,5e66 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5d5a:	85d2                	mv	a1,s4
    5d5c:	8556                	mv	a0,s5
    5d5e:	00000097          	auipc	ra,0x0
    5d62:	e92080e7          	jalr	-366(ra) # 5bf0 <putc>
        putc(fd, c);
    5d66:	85ca                	mv	a1,s2
    5d68:	8556                	mv	a0,s5
    5d6a:	00000097          	auipc	ra,0x0
    5d6e:	e86080e7          	jalr	-378(ra) # 5bf0 <putc>
      }
      state = 0;
    5d72:	4981                	li	s3,0
    5d74:	b765                	j	5d1c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5d76:	008b0913          	addi	s2,s6,8
    5d7a:	4685                	li	a3,1
    5d7c:	4629                	li	a2,10
    5d7e:	000b2583          	lw	a1,0(s6)
    5d82:	8556                	mv	a0,s5
    5d84:	00000097          	auipc	ra,0x0
    5d88:	e8e080e7          	jalr	-370(ra) # 5c12 <printint>
    5d8c:	8b4a                	mv	s6,s2
      state = 0;
    5d8e:	4981                	li	s3,0
    5d90:	b771                	j	5d1c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5d92:	008b0913          	addi	s2,s6,8
    5d96:	4681                	li	a3,0
    5d98:	4629                	li	a2,10
    5d9a:	000b2583          	lw	a1,0(s6)
    5d9e:	8556                	mv	a0,s5
    5da0:	00000097          	auipc	ra,0x0
    5da4:	e72080e7          	jalr	-398(ra) # 5c12 <printint>
    5da8:	8b4a                	mv	s6,s2
      state = 0;
    5daa:	4981                	li	s3,0
    5dac:	bf85                	j	5d1c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5dae:	008b0913          	addi	s2,s6,8
    5db2:	4681                	li	a3,0
    5db4:	4641                	li	a2,16
    5db6:	000b2583          	lw	a1,0(s6)
    5dba:	8556                	mv	a0,s5
    5dbc:	00000097          	auipc	ra,0x0
    5dc0:	e56080e7          	jalr	-426(ra) # 5c12 <printint>
    5dc4:	8b4a                	mv	s6,s2
      state = 0;
    5dc6:	4981                	li	s3,0
    5dc8:	bf91                	j	5d1c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5dca:	008b0793          	addi	a5,s6,8
    5dce:	f8f43423          	sd	a5,-120(s0)
    5dd2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5dd6:	03000593          	li	a1,48
    5dda:	8556                	mv	a0,s5
    5ddc:	00000097          	auipc	ra,0x0
    5de0:	e14080e7          	jalr	-492(ra) # 5bf0 <putc>
  putc(fd, 'x');
    5de4:	85ea                	mv	a1,s10
    5de6:	8556                	mv	a0,s5
    5de8:	00000097          	auipc	ra,0x0
    5dec:	e08080e7          	jalr	-504(ra) # 5bf0 <putc>
    5df0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5df2:	03c9d793          	srli	a5,s3,0x3c
    5df6:	97de                	add	a5,a5,s7
    5df8:	0007c583          	lbu	a1,0(a5)
    5dfc:	8556                	mv	a0,s5
    5dfe:	00000097          	auipc	ra,0x0
    5e02:	df2080e7          	jalr	-526(ra) # 5bf0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5e06:	0992                	slli	s3,s3,0x4
    5e08:	397d                	addiw	s2,s2,-1
    5e0a:	fe0914e3          	bnez	s2,5df2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5e0e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5e12:	4981                	li	s3,0
    5e14:	b721                	j	5d1c <vprintf+0x60>
        s = va_arg(ap, char*);
    5e16:	008b0993          	addi	s3,s6,8
    5e1a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5e1e:	02090163          	beqz	s2,5e40 <vprintf+0x184>
        while(*s != 0){
    5e22:	00094583          	lbu	a1,0(s2)
    5e26:	c9a1                	beqz	a1,5e76 <vprintf+0x1ba>
          putc(fd, *s);
    5e28:	8556                	mv	a0,s5
    5e2a:	00000097          	auipc	ra,0x0
    5e2e:	dc6080e7          	jalr	-570(ra) # 5bf0 <putc>
          s++;
    5e32:	0905                	addi	s2,s2,1
        while(*s != 0){
    5e34:	00094583          	lbu	a1,0(s2)
    5e38:	f9e5                	bnez	a1,5e28 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5e3a:	8b4e                	mv	s6,s3
      state = 0;
    5e3c:	4981                	li	s3,0
    5e3e:	bdf9                	j	5d1c <vprintf+0x60>
          s = "(null)";
    5e40:	00002917          	auipc	s2,0x2
    5e44:	68890913          	addi	s2,s2,1672 # 84c8 <malloc+0x2542>
        while(*s != 0){
    5e48:	02800593          	li	a1,40
    5e4c:	bff1                	j	5e28 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5e4e:	008b0913          	addi	s2,s6,8
    5e52:	000b4583          	lbu	a1,0(s6)
    5e56:	8556                	mv	a0,s5
    5e58:	00000097          	auipc	ra,0x0
    5e5c:	d98080e7          	jalr	-616(ra) # 5bf0 <putc>
    5e60:	8b4a                	mv	s6,s2
      state = 0;
    5e62:	4981                	li	s3,0
    5e64:	bd65                	j	5d1c <vprintf+0x60>
        putc(fd, c);
    5e66:	85d2                	mv	a1,s4
    5e68:	8556                	mv	a0,s5
    5e6a:	00000097          	auipc	ra,0x0
    5e6e:	d86080e7          	jalr	-634(ra) # 5bf0 <putc>
      state = 0;
    5e72:	4981                	li	s3,0
    5e74:	b565                	j	5d1c <vprintf+0x60>
        s = va_arg(ap, char*);
    5e76:	8b4e                	mv	s6,s3
      state = 0;
    5e78:	4981                	li	s3,0
    5e7a:	b54d                	j	5d1c <vprintf+0x60>
    }
  }
}
    5e7c:	70e6                	ld	ra,120(sp)
    5e7e:	7446                	ld	s0,112(sp)
    5e80:	74a6                	ld	s1,104(sp)
    5e82:	7906                	ld	s2,96(sp)
    5e84:	69e6                	ld	s3,88(sp)
    5e86:	6a46                	ld	s4,80(sp)
    5e88:	6aa6                	ld	s5,72(sp)
    5e8a:	6b06                	ld	s6,64(sp)
    5e8c:	7be2                	ld	s7,56(sp)
    5e8e:	7c42                	ld	s8,48(sp)
    5e90:	7ca2                	ld	s9,40(sp)
    5e92:	7d02                	ld	s10,32(sp)
    5e94:	6de2                	ld	s11,24(sp)
    5e96:	6109                	addi	sp,sp,128
    5e98:	8082                	ret

0000000000005e9a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5e9a:	715d                	addi	sp,sp,-80
    5e9c:	ec06                	sd	ra,24(sp)
    5e9e:	e822                	sd	s0,16(sp)
    5ea0:	1000                	addi	s0,sp,32
    5ea2:	e010                	sd	a2,0(s0)
    5ea4:	e414                	sd	a3,8(s0)
    5ea6:	e818                	sd	a4,16(s0)
    5ea8:	ec1c                	sd	a5,24(s0)
    5eaa:	03043023          	sd	a6,32(s0)
    5eae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5eb2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5eb6:	8622                	mv	a2,s0
    5eb8:	00000097          	auipc	ra,0x0
    5ebc:	e04080e7          	jalr	-508(ra) # 5cbc <vprintf>
}
    5ec0:	60e2                	ld	ra,24(sp)
    5ec2:	6442                	ld	s0,16(sp)
    5ec4:	6161                	addi	sp,sp,80
    5ec6:	8082                	ret

0000000000005ec8 <printf>:

void
printf(const char *fmt, ...)
{
    5ec8:	711d                	addi	sp,sp,-96
    5eca:	ec06                	sd	ra,24(sp)
    5ecc:	e822                	sd	s0,16(sp)
    5ece:	1000                	addi	s0,sp,32
    5ed0:	e40c                	sd	a1,8(s0)
    5ed2:	e810                	sd	a2,16(s0)
    5ed4:	ec14                	sd	a3,24(s0)
    5ed6:	f018                	sd	a4,32(s0)
    5ed8:	f41c                	sd	a5,40(s0)
    5eda:	03043823          	sd	a6,48(s0)
    5ede:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5ee2:	00840613          	addi	a2,s0,8
    5ee6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5eea:	85aa                	mv	a1,a0
    5eec:	4505                	li	a0,1
    5eee:	00000097          	auipc	ra,0x0
    5ef2:	dce080e7          	jalr	-562(ra) # 5cbc <vprintf>
}
    5ef6:	60e2                	ld	ra,24(sp)
    5ef8:	6442                	ld	s0,16(sp)
    5efa:	6125                	addi	sp,sp,96
    5efc:	8082                	ret

0000000000005efe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5efe:	1141                	addi	sp,sp,-16
    5f00:	e422                	sd	s0,8(sp)
    5f02:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5f04:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f08:	00003797          	auipc	a5,0x3
    5f0c:	5487b783          	ld	a5,1352(a5) # 9450 <freep>
    5f10:	a805                	j	5f40 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5f12:	4618                	lw	a4,8(a2)
    5f14:	9db9                	addw	a1,a1,a4
    5f16:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5f1a:	6398                	ld	a4,0(a5)
    5f1c:	6318                	ld	a4,0(a4)
    5f1e:	fee53823          	sd	a4,-16(a0)
    5f22:	a091                	j	5f66 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5f24:	ff852703          	lw	a4,-8(a0)
    5f28:	9e39                	addw	a2,a2,a4
    5f2a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5f2c:	ff053703          	ld	a4,-16(a0)
    5f30:	e398                	sd	a4,0(a5)
    5f32:	a099                	j	5f78 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5f34:	6398                	ld	a4,0(a5)
    5f36:	00e7e463          	bltu	a5,a4,5f3e <free+0x40>
    5f3a:	00e6ea63          	bltu	a3,a4,5f4e <free+0x50>
{
    5f3e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f40:	fed7fae3          	bgeu	a5,a3,5f34 <free+0x36>
    5f44:	6398                	ld	a4,0(a5)
    5f46:	00e6e463          	bltu	a3,a4,5f4e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5f4a:	fee7eae3          	bltu	a5,a4,5f3e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5f4e:	ff852583          	lw	a1,-8(a0)
    5f52:	6390                	ld	a2,0(a5)
    5f54:	02059713          	slli	a4,a1,0x20
    5f58:	9301                	srli	a4,a4,0x20
    5f5a:	0712                	slli	a4,a4,0x4
    5f5c:	9736                	add	a4,a4,a3
    5f5e:	fae60ae3          	beq	a2,a4,5f12 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5f62:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5f66:	4790                	lw	a2,8(a5)
    5f68:	02061713          	slli	a4,a2,0x20
    5f6c:	9301                	srli	a4,a4,0x20
    5f6e:	0712                	slli	a4,a4,0x4
    5f70:	973e                	add	a4,a4,a5
    5f72:	fae689e3          	beq	a3,a4,5f24 <free+0x26>
  } else
    p->s.ptr = bp;
    5f76:	e394                	sd	a3,0(a5)
  freep = p;
    5f78:	00003717          	auipc	a4,0x3
    5f7c:	4cf73c23          	sd	a5,1240(a4) # 9450 <freep>
}
    5f80:	6422                	ld	s0,8(sp)
    5f82:	0141                	addi	sp,sp,16
    5f84:	8082                	ret

0000000000005f86 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5f86:	7139                	addi	sp,sp,-64
    5f88:	fc06                	sd	ra,56(sp)
    5f8a:	f822                	sd	s0,48(sp)
    5f8c:	f426                	sd	s1,40(sp)
    5f8e:	f04a                	sd	s2,32(sp)
    5f90:	ec4e                	sd	s3,24(sp)
    5f92:	e852                	sd	s4,16(sp)
    5f94:	e456                	sd	s5,8(sp)
    5f96:	e05a                	sd	s6,0(sp)
    5f98:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5f9a:	02051493          	slli	s1,a0,0x20
    5f9e:	9081                	srli	s1,s1,0x20
    5fa0:	04bd                	addi	s1,s1,15
    5fa2:	8091                	srli	s1,s1,0x4
    5fa4:	0014899b          	addiw	s3,s1,1
    5fa8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5faa:	00003517          	auipc	a0,0x3
    5fae:	4a653503          	ld	a0,1190(a0) # 9450 <freep>
    5fb2:	c515                	beqz	a0,5fde <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5fb4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5fb6:	4798                	lw	a4,8(a5)
    5fb8:	02977f63          	bgeu	a4,s1,5ff6 <malloc+0x70>
    5fbc:	8a4e                	mv	s4,s3
    5fbe:	0009871b          	sext.w	a4,s3
    5fc2:	6685                	lui	a3,0x1
    5fc4:	00d77363          	bgeu	a4,a3,5fca <malloc+0x44>
    5fc8:	6a05                	lui	s4,0x1
    5fca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5fce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5fd2:	00003917          	auipc	s2,0x3
    5fd6:	47e90913          	addi	s2,s2,1150 # 9450 <freep>
  if(p == (char*)-1)
    5fda:	5afd                	li	s5,-1
    5fdc:	a88d                	j	604e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5fde:	0000a797          	auipc	a5,0xa
    5fe2:	c9a78793          	addi	a5,a5,-870 # fc78 <base>
    5fe6:	00003717          	auipc	a4,0x3
    5fea:	46f73523          	sd	a5,1130(a4) # 9450 <freep>
    5fee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5ff0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5ff4:	b7e1                	j	5fbc <malloc+0x36>
      if(p->s.size == nunits)
    5ff6:	02e48b63          	beq	s1,a4,602c <malloc+0xa6>
        p->s.size -= nunits;
    5ffa:	4137073b          	subw	a4,a4,s3
    5ffe:	c798                	sw	a4,8(a5)
        p += p->s.size;
    6000:	1702                	slli	a4,a4,0x20
    6002:	9301                	srli	a4,a4,0x20
    6004:	0712                	slli	a4,a4,0x4
    6006:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    6008:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    600c:	00003717          	auipc	a4,0x3
    6010:	44a73223          	sd	a0,1092(a4) # 9450 <freep>
      return (void*)(p + 1);
    6014:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    6018:	70e2                	ld	ra,56(sp)
    601a:	7442                	ld	s0,48(sp)
    601c:	74a2                	ld	s1,40(sp)
    601e:	7902                	ld	s2,32(sp)
    6020:	69e2                	ld	s3,24(sp)
    6022:	6a42                	ld	s4,16(sp)
    6024:	6aa2                	ld	s5,8(sp)
    6026:	6b02                	ld	s6,0(sp)
    6028:	6121                	addi	sp,sp,64
    602a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    602c:	6398                	ld	a4,0(a5)
    602e:	e118                	sd	a4,0(a0)
    6030:	bff1                	j	600c <malloc+0x86>
  hp->s.size = nu;
    6032:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    6036:	0541                	addi	a0,a0,16
    6038:	00000097          	auipc	ra,0x0
    603c:	ec6080e7          	jalr	-314(ra) # 5efe <free>
  return freep;
    6040:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    6044:	d971                	beqz	a0,6018 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6046:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    6048:	4798                	lw	a4,8(a5)
    604a:	fa9776e3          	bgeu	a4,s1,5ff6 <malloc+0x70>
    if(p == freep)
    604e:	00093703          	ld	a4,0(s2)
    6052:	853e                	mv	a0,a5
    6054:	fef719e3          	bne	a4,a5,6046 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    6058:	8552                	mv	a0,s4
    605a:	00000097          	auipc	ra,0x0
    605e:	b5e080e7          	jalr	-1186(ra) # 5bb8 <sbrk>
  if(p == (char*)-1)
    6062:	fd5518e3          	bne	a0,s5,6032 <malloc+0xac>
        return 0;
    6066:	4501                	li	a0,0
    6068:	bf45                	j	6018 <malloc+0x92>
