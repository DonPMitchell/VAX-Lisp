#.file	#read.s"
#.line 2
#
#	read - read lisp expression
#	D.P.Mitchell,R.C.Pike  80/03/24.
#
mread:	movq	input,(ap)+	# swap input pointers
	movq	input+8,(ap)+
	movq	8(r0),input
	movq	16(r0),input+8
	movl	r0,(ap)+
	pushl	$mread1
	pushl	ap
	jbr	read

mread1:	movl	-(ap),r1
	movq	input,8(r1)
	movq	input,16(r1)
	movq	-(ap),input+8
	movq	-(ap),input
	movl	(sp)+,ap
	rsb

read:	pushl	$read8
	pushl	ap
	jbr	ratom

read8:	cmpl	r0,$rpar
	jeql	read10
	cmpl	r0,$eof
	jneq	read1
	movl	(sp)+,ap
	rsb

ratom:	jsb	flush
	jbr	ratom0

read9:	movl	$lparer,r0
	jbr	error

read10:	movl	$rparer,r0
	jbr	error

read1:	cmpl	r0,$lpar	# (cond ((eq token lpar) (cons (read) (read2))))
	jeql	read2
	cmpl	r0,$squote	# (cond ((eq token squote)(list 'quote (read))))
	jeql	read4
	cmpl	r0,$eof		# unmatched lpar
	jeql	read9
	movl	(sp)+,ap	# (return token)
	rsb

read3:	clrl	r0
	movl	(sp)+,ap
	rsb

read4:	pushl	$read6
	subl2	$4,sp		# pushl ap
	jbr	read0

read6:	movl	r0,(ap)
	clrl	r0
	pushl	$read7
	subl2	$4,sp		# pushl ap
	jbr	cons

read7:	movl	$quote,(ap)
	jbr	cons

read5:	cmpl	r0,$rpar
	jeql	read3
	pushl	$cons
	subl2	$4,sp		# pushl ap
	movl	r0,(ap)+

read2:	pushl	$read5
	pushl	ap

read0:	pushl	$read1		# (setq token (ratom))
	pushl	ap
	jsb	flush
#
#	ratom - read atom
#
ratom0:	jsb	getc
	cmpb	r0,$0x20
	jleq	ratom0		# skip over seperators
	cmpb	r0,$0x28
	jneq	ratom1
	movl	$lpar,r0
	movl	(sp)+,ap
	rsb

ratom1:	cmpb	r0,$0x29
	jneq	ratom2
	movl	$rpar,r0
	movl	(sp)+,ap
	rsb

ratom2:	cmpb	r0,$0x27
	jneq	ratom3
	movl	$squote,r0
	movl	(sp)+,ap
	rsb

ratom3:	cmpb	r0,$0x7f
	jneq	ratom8
	movl	$eof,r0
	movl	(sp)+,ap
	rsb

ratom8:	cmpb	r0,$'9
	jgtr	ratom4
	cmpb	r0,$'-
	jeql	rnumb0		# try to read negative number
	cmpb	r0,$'0
	jgeq	rnumb2

ratom4:	movl	fp,r8		# save free space pointer
	movq	blank,(fp)+	# start building atom on free stack
	clrl	(fp)+
	movb	r0,(fp)+

ratom5:	jsb	getc
	cmpb	r0,$0x20
	jleq	ratom6		# atom ends with seperator
	cmpb	r0,$0x28
	jeql	ratom7		# atom ends with terminator
	cmpb	r0,$0x29
	jeql	ratom7
	movb	r0,(fp)+
	addl2	$0x100,4(r8)	# increment atom length
	jbr	ratom5

ratom7:	incl	(input+12)	# push terminator back into buffer
	decl	(input+8)

ratom6:	addl2	$7,fp		# move fp to next quadword boundary
	bicl2	$7,fp
	movl	r8,r0
#
#	intern - enter atom in object list
#
intern:	extv	$8,$23,4(r0),r5
	subl2	$12,r5		# length of pname
	addl3	$12,r0,r4	# pointer to pname
	movl	r4,r2		# hash pname
	movl	r5,r3
	clrl	r6

inter1:	addb2	(r2)+,r6
	sobgtr	r3,inter1
	bicl2	$0xffffff80,r6
	ashl	$3,r6,r6
	addl2	$oblist,r6	# pointer into oblist
	addl3	$8,r6,r9	# next oblist entry (end of bucket)
	movl	r6,tmp1		# run out of registers; can't use r10/r11
	cmpl	r9,$fstart
	jneq	inter3
	clrl	r9

inter3:	movq	(r6),r6
	extzv	$8,$23,4(r7),r0
	subl2	$12,r0
	cmpl	r0,r5		# compare lengths of pnames first
	jneq	inter2
	cmpc3	r5,(r4),12(r7)	# then compare pnames
	jeql	inter4

inter2:	cmpl	r6,r9		# check next entry unless end of bucket
	jneq	inter3
	movl	r8,r0		# return new atom
	movl	fp,r7
	movl	tmp1,r1
	movq	(r1),(fp)+	# enter in oblist
	movq	r7,(r1)
	movl	(sp)+,ap
	rsb

inter4:	movl	r7,r0		# return old atom
	movl	r8,fp		# put new atom back in free storage
	movl	(sp)+,ap
	rsb
#
#	getc - get one character
#
getc:	decl	(input+12)
	jgeq	getc1
	movl	$512,(input+12)	# fill input buffer
	movl	ap,tmp1
	movl	$input,ap
	movl	$(input+16),(input+8)
	chmk	$READ
	jcs	getc2		#read error looks like eof
	movl	r0,(input+12)
	jeql	getc2		#end of file
	movl	tmp1,ap
	decl	(input+12)

getc1:	movzbl	*(input+8),r0	# extract character
	incl	(input+8)
	rsb

getc2:	tstl	(input+4)	# if standard input, exit
	jeql	getc3
	tstl	argc		# otherwise switch input file to next argument
	jneq	getc4
	clrl	(input+4)	# if no more args, switch to standard input
	jbr	getc

getc3:	movl	$0x7f,r0
	movl	tmp1,ap
	rsb

getc4:	movl	*argv,Open+4
	movl	ap,tmp1
	movl	$Open,ap
	chmk	$OPEN
	jcs	getc5
	movl	r0,input+4
	jbr	getc6

getc5:	clrl	input+4		# go to standard input
	clrl	input+12
	movl	$input+16,input+8
	movl	$fileerr,r0
	jbr	error

getc6:	decl	argc
	addl2	$4,argv
	movl	tmp1,ap
	jbr	getc
#
#	readch - read one character atom
#
readch:	jsb	getc
readch1:mull2	$16,r0		# much faster than ashl !!!
	addl2	$apval,r0
	movl	(sp)+,ap
	rsb
#
#	peekch - look at next character in input without advancing
#
peekch:	jsb	getc
	incl	input+12
	decl	input+8
	jbr	readch1
#
#	read numeric atom
#
rnumb0:	movb	r0,r6		# got a '-'; see if atom is a negative number
	jsb	getc
	cmpl	r0,$'9
	jgtr	rnumb1		# not a number
	cmpl	r0,$'0
	jgeq	rnumb3

rnumb1:	incl	(input+12)	# put char back in buffer and restart ratom
	decl	(input+8)
	movb	r6,r0
	jbr	readch1

rnumb2:	clrl	r6

rnumb3:	clrd	r10		# mantissa
	clrl	r7		# sign of exponent
	clrl	r4		# exponent

rnumb4:	subb2	$'0,r0		# read in integer part
	cvtbd	r0,r0
	muld2	$0d10.0,r10
	addd2	r0,r10
	jsb	getc
	cmpb	r0,$'0
	jlss	rnumb5
	cmpb	r0,$'9
	jleq	rnumb4

rnumb5:	cmpb	r0,$'.
	jneq	rnumb6		# no fraction, look for exponent
	movd	$0d1.0,r8

rnumb7:	jsb	getc
	cmpb	r0,$'9
	jgtr	rnumb6
	cmpb	r0,$'0
	jlss	rnumb6
	cmpd	r8,$0d1e-36
	jlss	rnumb7		# ignore digits on underflow
	divd2	$0d10.0,r8
	subl2	$'0,r0
	cvtbd	r0,r0
	muld2	r8,r0
	addd2	r0,r10
	jbr	rnumb7

rnumb6:	bicb3	$' ,r0,r1
	cmpb	r1,$'E
	jneq	rnumb8		# end of number
	jsb	getc
	cmpb	r0,$'-
	jneq	rnumb9
	movl	r0,r7		# remember sign of exponent
	jbr	rnumb14

rnumb9:	cmpb	r0,$'+
	jneq	rnumb10

rnumb14:jsb	getc

rnumb10:cmpb	r0,$'9
	jgtr	rnumb8
	cmpb	r0,$'0
	jlss	rnumb8
	mull2	$10,r4
	subl2	$'0,r0
	addl2	r0,r4
	jbr	rnumb14

rnumb8:	tstl	r4
	jeql	rnumb11		# don't call ten if no exponent
	jsb	ten
	tstl	r7
	jneq	rnumb13
	muld2	r2,r10		# scale by 10^r4

#
#	At this point, we are almost ready; the number is in (r10,r11)
#	and the sign is in r6.  Before touching (fp), must clear all
#	floating point registers; therefore build the number up in
#	the global location "number"
#
rnumb11:incl	(input+12)	# put last char back in buffer
	decl	(input+8)
	clrq	r2		# returned exponent from "ten"
	clrl	r4		# exponent; possibly confusing
	clrq	r8		# used as a temporary and by "ten"
	clrl	r1		# old part of double prec r0
	tstd	r10
	jeql	rnumb12		# no such thing as -0
	tstl	r6
	jeql	rnumb12
	bisl2	$0x00008000,r10	# negd number+8

rnumb12:movl	fp,r0
	movl	fp,(fp)+
	movl	$0x80001080,(fp)+
	movq	r10,(fp)+	# the number itself
	movl	(sp)+,ap
	rsb

rnumb13:divd2	r2,r10		# scale by 10^(-r4)
	jbr	rnumb11

startre:jsb	flush
	clrl	r0
	movl	(sp)+,ap
	rsb

open:	extzv	$8,$23,4(r0),r2
	subl2	$12,r2		# length of pname
	movc3	r2,12(r0),(fp)
	clrb	(r3)		# move string to free space
	movl	fp,Open+4
	movl	ap,r8
	movl	$Open,ap
	chmk	$OPEN
	jcs	open1		# error in opening file
	movl	r8,ap
	movl	fp,r8
	movl	fp,(fp)+
	movl	fhead,(fp)+	# file header (array)
	movl	$3,(fp)+	# arg count for reads
	movl	r0,(fp)+	# file descriptor
	addl3	$24,r8,(fp)+	# pointer to begining of buffer
	clrl	(fp)		# room in buffer
	addl2	$512,fp		# actual buffer
	tstl	(fp)
	movl	r8,r0
	movl	(sp)+,ap
	rsb

open1:	movl	$fileerr,r0
	movl	r8,ap
	jbr	error
