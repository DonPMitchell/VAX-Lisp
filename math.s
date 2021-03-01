#.file	#math.s"
#.line 2
#
#	basic math functions
#	D.P.Mitchell  80/03/30.
#
zerop:	tstd	8(r0)
	jneq	false
	movl	$t,r0
	movl	(sp)+,ap
	rsb

onep:	cmpd	$0d1.0,8(r0)
	jneq	false
	movl	$t,r0
	movl	(sp)+,ap
	rsb

evenp:	cvtdl	8(r0),r0
	jlbs	r0,false
	movl	$t,r0
	movl	(sp)+,ap
	rsb

minus:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+
	movl	4(r1),(fp)+
	mnegd	8(r1),(fp)+
	movl	(sp)+,ap
	rsb

nminus:	mnegd	8(r0),8(r0)
	movl	(sp)+,ap
	rsb

recip:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+
	movl	4(r1),(fp)+
	divd3	8(r1),$0d1.0,(fp)+
	movl	(sp)+,ap
	rsb

nrecip:	divd3	8(r0),$0d1.0,8(r0)
	movl	(sp)+,ap
	rsb

entier:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+
	movl	4(r1),(fp)+
	cvtdl	8(r1),r1
	cvtld	r1,(fp)+
	movl	(sp)+,ap
	rsb

nentier:cvtdl	8(r0),r1
	cvtld	r1,8(r0)
	movl	(sp)+,ap
	rsb

numberp:movl	4(r0),r1
	jgeq	false		# not atom
	tstb	r1
	jgeq	false		# not number
	movl	$t,r0
	movl	(sp)+,ap
	rsb

false:	clrl	r0
	movl	(sp)+,ap
	rsb

minusp:	tstd	8(r0)
	jgeq	false
	movl	$t,r0
	movl	(sp)+,ap
	rsb

lessp:	movl	(ap),r1
	cmpd	8(r1),8(r0)
	jgeq	false
	movl	$t,r0
	movl	(sp)+,ap
	rsb

greater:movl	(ap),r1
	cmpd	8(r1),8(r0)
	jleq	false
	movl	$t,r0
	movl	(sp)+,ap
	rsb

add1:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+	# value of number is itself
	movl	4(r1),(fp)+
	addd3	$0d1.0,8(r1),(fp)+
	movl	(sp)+,ap
	rsb

sub1:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+
	movl	4(r1),(fp)+
	subd3	$0d1.0,8(r1),(fp)+
	movl	(sp)+,ap
	rsb

nadd1:	addd2	$0d1.0,8(r0)
	movl	(sp)+,ap
	rsb

nsub1:	subd2	$0d1.0,8(r0)
	movl	(sp)+,ap
	rsb

eqn:	movl	(ap),r1
	movq	8(r0),r2
	movq	8(r1),r4
	cmpd	r2,r4
	beql	eqn1
	clrl	r0		# return nil
	movl	(sp)+,ap
	rsb

eqn1:	movl	$t,r0
	movl	(sp)+,ap
	rsb

plus:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+	# put out numeric header
	movl	4(r1),(fp)+
	movl	(ap)+,r2
	movq	8(r2),r10	# really a movd, but quicker

plus1:	movl	(ap)+,r2
	jlss	plus2
	addd2	8(r2),r10
	jbr	plus1

plus2:	addd3	8(r1),r10,(fp)+
	movl	(sp)+,ap
	rsb

nplus:	movl	(ap)+,r2
	movq	8(r2),r10

nplus1:	movl	(ap)+,r2
	jlss	nplus2
	addd2	8(r2),r10
	jbr	nplus1

nplus2:	addd3	8(r0),r10,8(r0)
	movl	(sp)+,ap
	rsb

diff:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+	# put out numeric header
	movl	4(r1),(fp)+
	movl	(ap)+,r2
	movq	8(r2),r10	# really a movd, but quicker

diff1:	movl	(ap)+,r2
	jlss	diff2
	subd2	8(r2),r10
	jbr	diff1

diff2:	subd3	8(r1),r10,(fp)+
	movl	(sp)+,ap
	rsb

ndiff:	movl	(ap)+,r2
	movq	8(r2),r10

ndiff1:	movl	(ap)+,r2
	jlss	ndiff2
	subd2	8(r2),r10
	jbr	ndiff1

ndiff2:	subd3	8(r0),r10,8(r0)
	movl	(sp)+,ap
	rsb

times:	movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+	# put out numeric header
	movl	4(r1),(fp)+
	movl	(ap)+,r2
	movq	8(r2),r10

times1:	movl	(ap)+,r2
	jlss	times2
	muld2	8(r2),r10
	jbr	times1

times2:	muld3	8(r1),r10,(fp)+
	movl	(sp)+,ap
	rsb

ntimes:	movl	(ap)+,r2
	movq	8(r2),r10

ntimes1:movl	(ap)+,r2
	jlss	ntimes2
	muld2	8(r2),r10
	jbr	ntimes1

ntimes2:muld3	8(r0),r10,8(r0)
	movl	(sp)+,ap
	rsb

quotien:movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+	# put out numeric header
	movl	4(r1),(fp)+
	movl	(ap)+,r2
	movq	8(r2),r10

quoti1:	movl	(ap)+,r2
	jlss	quoti2
	divd2	8(r2),r10
	jbr	quoti1

quoti2:	divd3	8(r1),r10,(fp)+
	movl	(sp)+,ap
	rsb

nquoti:	movl	(ap)+,r2
	movq	8(r2),r10

nquoti1:movl	(ap)+,r2
	jlss	nquoti2
	divd2	8(r2),r10
	jbr	nquoti1

nquoti2:divd3	8(r0),r10,8(r0)
	movl	(sp)+,ap
	rsb

address:movl	r0,r1
	movl	fp,r0
	movl	fp,(fp)+
	movl	$0x80001080,(fp)+
	cvtld	r1,(fp)+
	movl	(sp)+,ap
	rsb

length:	clrl	r1

length1:tstl	r0
	jeql	length2
	movl	(r0),r0
	incl	r1
	jbr	length1

length2:movl	fp,r0
	movl	fp,(fp)+
	movl	$0x80001080,(fp)+
	cvtld	r1,(fp)+

length3:movl	(sp)+,ap
	rsb

max:	movl	(ap)+,r1
	jlss	length3
	cmpd	8(r1),8(r0)
	jlss	max
	movl	r1,r0
	jbr	max

min:	movl	(ap)+,r1
	jlss	length3
	cmpd	8(r1),8(r0)
	jgtr	min
	movl	r1,r0
	jbr	min
