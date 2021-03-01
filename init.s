#.file	#init.s"
#.line 2
#
#	init - initialize oblist and misc. other things
#	D.P.Mitchell,R.C.Pike  80/03/20.
#
#	lisp cannot function without writeable text space now, since the
#	atom, nil, must be copied to address 0. this should be fixed someday
#	so large compiled programs can have sharable text.
#
	.set	EXIT,1		# define executive request codes
	.set	READ,3
	.set	WRITE,4
	.set	OPEN,5
	.set	CLOSE,6
	.set	BREAK,17
	.set	SIGNAL,48
	.set	SIGINT,2
	.set	SIGFPE,8
	.set	SIGBUS,10
	.set	SIGSEGV,11
	.text

init:
	.word	0x0000
	movl	(sp),argc
	decl	argc
	addl3	$8,sp,r0	# skip argv[0]="lisp"
	movl	r0,argv

init1:	tstl	(r0)+		#  null args term ?
	bneq	init1
	movl	r0,envp
	movl	sp,r1		# allocate stack space
	subl2	$80000,sp
	tstl	(sp)
	movl	sp,r8		# argument stack pointer
	movl	r1,sp		# return stack pointer
	movl	$break,ap
	chmk	$BREAK
	movl	r8,ap
	movl	$fstart,fp	# free storage pointer
	pushl	$trap		# catch-all at top level
	pushl	ap
	pushl	$0x80000000
	movl	sp,toplev
	clrl	r0
	clrl	(r0)+		# create nil at address 0
	movl	(dot+4),(r0)+
	clrl	(r0)+
	movl	nilnam,(r0)
	clrl	r0		# put nil in oblist
	clrl	r8
	pushl	$init3
	pushl	ap
	jbr	intern

init3:	movl	$dot,r11	# put all predefined atoms on oblist

init4:	movl	r11,r8
	movl	r11,r0
	extzv	$8,$23,4(r11),r1
	addl2	$7,r1
	bicl2	$7,r1
	addl2	r1,r11		# advance to next atom
	pushl	$init5
	pushl	ap
	jbr	intern

init5:	tstl	(r11)
	jneq	init4		# still more atoms
	movl	ap,tmp1		# catch signals
	movl	$sigint,ap
	chmk	$SIGNAL
	jlbc	r0,init6
	movl	$1,sigint+8	# don't start to catch ignored SIGINT
	movl	$sigint,ap
	chmk	$SIGNAL

init6:	movl	$sigfpe,ap
	chmk	$SIGNAL
	movl	$sigbus,ap
	chmk	$SIGNAL
	movl	$sigsegv,ap
	chmk	$SIGNAL
	movl	tmp1,ap
#
#	lisp toplevel loop
#
top1:	pushl	$top2		# (setq r0 (read))
	pushl	ap
	jbr	read

top2:	cmpl	r0,$eof		# (cond ((eq r0 'eof)(go top4)))
	jeql	top4
	pushl	$top3		# (setq r0 (eval r0))
	pushl	ap
	jbr	eval

trap:	movl	toplev,sp	# return stack to top level & reenter main loop

top3:	pushl	$top1		# (print r0)
	pushl	ap
	jbr	print

top4:	chmk	$EXIT
	halt

error:	tstl	(sp)+
	jgeq	error
	movl	(sp)+,ap
	rsb


.align	1			# signal-callable routine mustn't
				# be at an odd address
sigcatch:
	.word	0xfff		# catch signals (save all registers)
	movl	4(ap),r2
	movl	r2,sigfpe+4	# reset signal; use sigfpe as vector
				# NOTE: If we're ignoring SIGINT,
				# we'll never come here so it's ok.
	movl	ap,r1
	movl	$sigfpe,ap
	chmk	$SIGNAL
	movl	r1,ap
	cmpl	r2,$SIGINT
	jneq	sigc1
	movl	$interr,r1
	jsb	sigfix
	ret

sigc1:	cmpl	r2,$SIGFPE
	jneq	sigc2
	movl	$fpeerr,r1
	jsb	sigfix
	ret

sigc2:	cmpl	r2,$SIGBUS
	jneq	sigc3
	movl	$buserr,r1
	jsb	sigfix
	ret

sigc3:	addl2	$200000,break+4
	movl	ap,-(sp)
	movl	$break,ap
	chmk	$BREAK
	movl	(sp)+,ap
	jcs	sigc4
	ret

sigc4:	movl	$segverr,r1
	jsb	sigfix
	ret

#
# sigfix - repair stack to effect error recovery
#
# in old 32V and TS systems:
#	replace first instruction by movl fp,r0
#
sigfix:	movl	12(fp),r0	# fp of rei frame (we're in the ret frame now)
	movl	r1,20(r0)	# where r0 is saved
	movl	$error,16(r0)	# where pc is saved
	movl	$(input+16),input+8	# reset read buffer pointer
	clrl	input+12		# and read count
	clrl	input+4			# and read from terminal
	ret
crash:	movl	$stkerr,r0
	jbr	error

free:	cvtdl	8(r0),break+4
	movl	ap,r8
	movl	$break,ap
	chmk	$BREAK
	jcs	free1
	movl	$t,r0
	movl	r8,ap
	movl	(sp)+,ap
	rsb

free1:	movl	r8,ap
	clrl	r0
	movl	(sp)+,ap
	rsb
