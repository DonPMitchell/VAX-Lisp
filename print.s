#.file	#print.s"
#.line 2
#
#	print - print lisp expression
#	D.P.Mitchell  80/03/13.
#
print:	pushl	$terpr1
	pushl	ap
	movl	r0,(ap)+
#
#	princ - print without terpri at end
#
princ0:	tstl	r0
	jlss	princ6		# illegal address
	jeql	prin1		# print nil
	cmpl	r0,$apval
	jlss	princ6		# pointer into subr space
	movq	(r0),r6
	jlss	prin1		# (cond ((atom x) (prin1 x)))
	movl	$lpar,r0	# (prin1 lpar)
	pushl	$princ1
	pushl	ap
	jbr	prin1

princ6:	movl	$garbage,r0
	jbr	princ0

princ:	pushl	$terpr2
	pushl	ap
	movl	r0,(ap)+
	jbr	princ0

princ1:	pushl	$princ2		# (princ (car x))
	pushl	ap
	movl	r6,(ap)+
	movl	r7,r0
	jbr	princ0

princ2:	movl	(ap),r0		# (setq x (cdr x))
	jeql	princ4		# (cond	((null x) (prin1 rpar))
	movq	(r0),r6		# 	((not (atom x)) (go again)))
	jgeq	princ5
	movl	$dot,r0		# (prin1 " . ")
	pushl	$princ3
	pushl	ap
	jbr	prin1

princ3:	movl	(ap),r0		# (prin1 x)
	pushl	$princ4
	pushl	ap
	jbr	prin1

princ4:	movl	$rpar,r0	# (prin1 rpar)
	jbr	prin1

princ5:	pushl	$princ1
	pushl	ap
	movl	$blank,r0
#
#	prin1 - print atom
#		(preserve r6 and r7)
#
prin1:	movl	4(r0),r3
	tstb	r3
	jlss	prinn		# (cond ((numberp x) (prinn x)))
	extzv	$8,$23,r3,r8	# get length of atom
	subl2	$12,r8		# length of pname
	cmpl	room,r8
	jlss	puts2

prin2:	addl3	$12,r0,r1
	movl	(sp)+,ap	# do part of lisp return so putstr is jsb'able
#
#	putstr - put string in output buffer
#		(r1 -> string, r8 == length)
#
putstr:	subl2	r8,room
	cmpl	r8,(output+12)
	jlss	puts1		# enough room in buffer
	movc3	(output+12),(r1),*(output+8)
	subl2	(output+12),r8
	clrl	(output+12)
	jsb	flush
	jbr	putstr

puts1:	movc3	r8,(r1),*(output+8)
	subl2	r8,(output+12)
	addl2	r8,(output+8)
	rsb

puts2:	movb	$012,r1
	jsb	putc
	movl	margin,room
	jbr	prin2
#
#	prinn - print number
#
#	Must clean up registers afterwards so GC doesn't get confused
#	by floating point numbers in registers
#
prinn:	cmpl	room,$20
	jgeq	prinn0
	movb	$012,r1
	jsb	putc
	movl	margin,room

prinn0:	movd	8(r0),r0
	jneq	prinn9
	clrl	r3			# easy case; just print a '0'
					# no need to clrq r0; it's 0!
	movl	(sp)+,ap		# do part of lisp return now;
	jbr	outint			# jump to outint and fall through putc to rsb
prinn9:	clrl	r4			# exponent
	extzv	$7,$8,r0,r2
	subl2	$127,r2			# convert exponent from excess 128
	cmpl	r2,$30
	jgtr	prinn7	
	cmpl	r2,$-8
	jgeq	prinn1
prinn7:	cvtlf	r2,r4			# floating point exponent
	mulf2	log2,r4
	cvtrfl	r4,r4
	jlss	prinn2
	jsb	ten			# get 10^r4, into r2
	divd2	r2,r0
	jbr	prinn1
prinn2:	mnegl	r4,r4			# negative exponent case
	incl	r4
	jsb	ten
	muld2	r2,r0
	mnegl	r4,r4
prinn1:	movd	$0d.000000005,r8
	bbc	$15,r0,prinn3
	bisl2	$0x00008000,r8		# r8=-.000000005
prinn3:	addd2	r8,r0			# for rounding
	cvtdl	r0,r3			# integer part
	cvtld	r3,r5
	subd2	r5,r0			# r0 is fractional part
	muld2	$0d1e8,r0
	bicl2	$0x00008000,r0		# abs(fract part)
	cvtdl	r0,r5			# r3=int,r4=exp,r5=frac all int's
	jsb	outint			# output r3 as integer
	movl	r5,r3
	jeql	prinn4			# skip fractional part if zero
	movb	$'.,r1
	jsb	putc			# output a period
prinn5:	divl3	$10000000,r5,r3		# output next char loop
	addl3	$'0,r3,r1
	jsb	putc
	mull2	$10000000,r3
	subl2	r3,r5
	mull2	$10,r5
	jneq	prinn5
prinn4:	tstl	r4
	jeql	prinn6
	movl	$'E,r1
	jsb	putc
	movl	r4,r3
	jlss	prinn8
	movl	$'+,r1			# output + for exponent
	jsb	putc
prinn8:	jsb	outint
#
#	Clean up the registers; all but r7 have been zapped and may
#	contain confusing quantities
#
prinn6:	clrq	r0
	clrq	r2
	clrq	r4
	clrl	r6
	clrq	r8	# don't need to clrq r10; GC ignores r10 & r11
	movl	(sp)+,ap
	rsb
#
#	ten - return in (r2,r3) double prec. 10^(int r4)
#
ten:	movd	$0d1.0,r2
	clrl	r5
ten1:	ffs	r5,$6,r4,r8
	jeql	ten2
	muld2	tentab[r8],r2
	addl3	$1,r8,r5
	jbr	ten1
ten2:	rsb

outint:	tstl	r3			# negative?
	jgeq	outint1			# no, normal algorithm
	movl	$'-,r1
	jsb	putc			# output sign
	mnegl	r3,r3
outint1:movl	r3,r10			# use r10 as ediv uses QUADWORD!
	clrl	r11
outint2:ediv	$10,r10,r10,-(sp)
	jeql	outint3			# quotient == 0 ==> done
	jsb	outint2
outint3:addl3	$'0,(sp)+,r1		# and fall through to putc
#
#	putc - put one character in output buffer
#
putc:	tstl	(output+12)
	jneq	putc2
	movl	r1,r2
	jsb	flush
	movl	r2,r1

putc2:	movb	r1,*(output+8)
	incl	(output+8)
	decl	(output+12)
	decl	room
	rsb
#
#	flush - flush output buffer
#
flush:	subl3	(output+12),$512,(output+12)
	jeql	flush1
	movl	ap,r9
	movl	$output,ap
	movl	$(output+16),(output+8)
	chmk	$WRITE
	movl	r9,ap

flush1:	movl	$512,(output+12)
	rsb
#
#	terpri - start new line
#
terpri:	clrl	(ap)

terpr1:	movb	$012,r1
	jsb	putc
	movl	margin,room

terpr2:	movl	(ap),r0
	movl	(sp)+,ap
	rsb
