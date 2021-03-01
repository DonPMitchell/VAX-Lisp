#.file	#reclaim.s"
#.line 2
#
#	reclaim - garbage collector(triggered by memory fault)
#	D.P.Mitchell  80/04/08.
#
markr:	rsb

mark:
mark0:	cmpl	r0,$apval		# nil must be marked now
	jlssu	markr		# in subr space
	jbss	$31,(r0),markr	# already marked
	movl	4(r0),r1
	jgeq	mark1		# not atom
	jbs	$7,r1,markr	# number, don't mark further
	movl	8(r0),r1	# pretend value is cdr and plist is car

mark1:	bicl3	$0x80000000,(r0),r0		# x marked, r0=(cdr x), r1=(car x)
mark1a:	cmpl	r1,$apval
	jlssu	mark0
	jbss	$31,(r1),mark0
	movl	4(r1),r2
	jgeq	mark2
	jbs	$7,r2,mark0
	movl	8(r1),r2

mark2:	bicl3	$0x80000000,(r1),r1
mark2a:	cmpl	r2,$apval
	jlssu	mark1a
	jbss	$31,(r2),mark1a
	movl	4(r2),r3
	jgeq	mark3
	jbs	$7,r3,mark1a
	movl	8(r2),r3

mark3:	bicl3	$0x80000000,(r2),r2
mark3a:	cmpl	r3,$apval
	jlssu	mark2a
	jbss	$31,(r3),mark2a
	movl	4(r3),r4
	jgeq	mark4
	jbs	$7,r4,mark2a
	movl	8(r3),r4

mark4:	bicl3	$0x80000000,(r3),r3
mark4a:	cmpl	r4,$apval
	jlssu	mark3a
	jbss	$31,(r4),mark3a
	movl	4(r4),r5
	jgeq	mark5
	jbs	$7,r5,mark3a
	movl	8(r4),r5

mark5:	bicl3	$0x80000000,(r4),r4
mark5a:	cmpl	r5,$apval
	jlssu	mark4a
	jbss	$31,(r5),mark4a
	movl	4(r5),r6
	jgeq	mark6
	jbs	$7,r6,mark4a
	movl	8(r5),r6

mark6:	bicl3	$0x80000000,(r5),r5
mark6a:	cmpl	r6,$apval
	jlssu	mark5a
	jbss	$31,(r6),mark5a
	movl	4(r6),r7
	jgeq	mark7
	jbs	$7,r7,mark5a
	movl	8(r6),r7

mark7:	bicl3	$0x80000000,(r6),r6
mark7a:	cmpl	r7,$apval
	jlssu	mark6a
	jbss	$31,(r7),mark6a
	movl	4(r7),r8
	jgeq	mark8
	jbs	$7,r8,mark6a
	movl	8(r7),r8

mark8:	bicl3	$0x80000000,(r7),r7
mark8a:	cmpl	r8,$apval
	jlssu	mark7a
	jbss	$31,(r8),mark7a
	movl	4(r8),r9
	jgeq	mark9
	jbs	$7,r9,mark7a
	movl	8(r8),r9

mark9:	bicl3	$0x80000000,(r8),r8
mark9a:	cmpl	r9,$apval
	jlssu	mark8a
	jbss	$31,(r9),mark8a
	movl	4(r9),r10
	jgeq	mark10
	jbs	$7,r10,mark8a
	movl	8(r9),r10

mark10:	bicl3	$0x80000000,(r9),r9
	movl	r10,(ap)+
	jsb	markten
	jbr	mark9a

markten:movl	-(ap),r10
	cmpl	r10,$apval
	jlssu	markret
	jbss	$31,(r10),markret
	movl	4(r10),r11
	jgeq	markcal
	jbs	$7,r11,markret
	movl	8(r10),r11

markcal:movl	r11,(ap)+
	bicl3	$0x80000000,(r10),(ap)+
	jsb	markten
	jbr	markten

markret:rsb
#
# reclaim - reclaim storage
#
reclaim:movl	toplev,r1	# base of argument stack
	movl	-8(r1),tmp1
	movl	ap,tmp2
	movl	$oblist,r0

recl1:	jsb	mark
	subl3	$4,tmp2,r2
	movl	r2,tmp2
	cmpl	r2,tmp1
	jlssu	recl2
	movl	(r2),r0
	jbr	recl1

recl2:	movl	$apval,r0

recl3:	cmpl	r0,fp
	jgtru	recl5
	jbsc	$31,(r0),recl4
	movl	$0xffffffff,(r0)
recl4:	addl2	$4,r0
	tstl	(r0)+		# atom?
	jgeq	recl3
	extzv	$8,$23,-4(r0),r1
	decl	r1
	addl2	r1,r0
	bicl2	$7,r0
	jbr	recl3

recl5:	clrl	r0
	movl	(sp)+,ap
	rsb
