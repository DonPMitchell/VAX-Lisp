#.file	#functions.s"
#.line 2
#
#	standard functions for lisp
#	D.P.Mitchell  80/03/27.
#
equalt:	movl	$t,r0
member1:movl	(sp)+,ap
	rsb

member2:tstl	r0
	jneq	member1
	movl	tmp1,r0

member:	tstl	r0
	jeql	member1
	movq	(r0),r0
	movl	r0,tmp1
	movl	r1,r0
	pushl	$member2
	pushl	ap
	cmpl	ap,sp
	jgequ	crash

#
#	Equal unwinds into registers. Uses r10/r11, but that's ok
#	because equal can't cause a garbage collect: it doesn't
#	generate new storage
#
equal:	movl	(ap),r6
	movl	sp,(fp)

equal1:	cmpl	r0,r6		# (eq a b)
	jeql	equalt
	movq	(r0),r0		# (setq r0 (cdr a) r1 (car a))
	jlss	equaln1		# ((atom a) f)
	movq	(r6),r6		# (setq r6 (cdr b) r7 (car b))
	jlss	equalf		# ((atom b) f)

equal2: cmpl	r1,r7		# ((eq (car a)(car b)) (equal (cdr a) (cdr b)))
	jeql	equal1
	movq	(r1),r1
	jlss	equaln2		# ((atom (car a)) f)
	movq	(r7),r7
	jlss	equalf		# ((atom (car b)) f)

equal3:	cmpl	r2,r8		# ((eq(caar a)(caar b))(equal(cadr a)(cadr b)))
	jeql	equal2
	movq	(r2),r2		# ((atom (caaar a) f)
	jlss	equaln3
	movq	(r8),r8		# ((atom (caaar b) f)
	jlss	equalf

equal4:	cmpl	r3,r9		# I hope you get the idea.
	jeql	equal3
	movq	(r3),r3
	jlss	equaln4
	movq	(r9),r9
	jlss	equalf

equal5:	cmpl	r4,r10
	jeql	equal4
	movq	(r4),r4
	jlss	equaln5
	movq	(r10),r10
	jlss	equalf

equal6:	pushl	$equal5
	pushl	ap

equal10:cmpl	ap,sp
	jgequ	crash

equal7:	cmpl	r5,r11
	jneq	equal8
	movl	(sp)+,ap
	rsb

equal8:	movl	(r5)+,(ap)+
	movl	(r11)+,(ap)+
	movl	(r5),r5
	jlss	leveln0
	movl	(r11),r11
	jlss	level0
	pushl	$equal9
	pushl	ap
	jbr	equal10

equal9:	movl	-(ap),r11
	movl	-(ap),r5
	jbr	equal7

level0:	movl	(fp),sp

equalf:	clrl	r0
	movl	(sp)+,ap
	rsb

equaln1:tstb	r1
	jgeq	equalf		# not a number
	movl	4(r6),r7
	jgeq	equalf		# second arg not atom
	tstb	r7
	jgeq	equalf		# second arg not number
	cmpd	8(r6),8(r0)	# (eqn a b)
	jeql	equalt
	jbr	equalf

equaln2:tstb	r2
	jgeq	equalf		# not a number
	movl	4(r7),r8
	jgeq	equalf		# second arg not atom
	tstb	r8
	jgeq	equalf		# second arg not number
	cmpd	8(r7),8(r1)	# (eqn a b)
	jeql	equal1
	jbr	equalf

equaln3:tstb	r3
	jgeq	equalf		# not a number
	movl	4(r8),r9
	jgeq	equalf		# second arg not atom
	tstb	r9
	jgeq	equalf		# second arg not number
	cmpd	8(r8),8(r2)	# (eqn a b)
	jeql	equal2
	jbr	equalf

equaln4:tstb	r4
	jgeq	equalf		# not a number
	movl	4(r9),r10
	jgeq	equalf		# second arg not atom
	tstb	r10
	jgeq	equalf		# second arg not number
	cmpd	8(r9),8(r3)	# (eqn a b)
	jeql	equal3
	jbr	equalf

equaln5:tstb	r5
	jgeq	equalf		# not a number
	movl	4(r10),r11
	jgeq	equalf		# second arg not atom
	tstb	r11
	jgeq	equalf		# second arg not number
	cmpd	8(r10),8(r4)	# (eqn a b)
	jeql	equal4
	jbr	equalf

leveln0:tstb	r5
	jgeq	level0
	movl	(r11),r5
	jgeq	level0
	tstb	r5
	jgeq	level0
	movl	-8(ap),r5
	cmpd	4(r11),8(r5)
	jneq	level0
	movl	(sp)+,ap
	rsb


explode:tstb	4(r0)
	jlss	explod2		# explode number
	extzv	$8,$23,4(r0),r1	# length of atom
	subl2	$13,r1
	addl3	$12,r0,r2	# pointer to chars
	movl	fp,r0

explod1:
	movzbl	(r2)+,r4
	mull2	$16,r4
	addl2	$apval,r4
	addl3	$8,fp,r3
	movq	r3,(fp)+
	sobgeq	r1,explod1
	clrl	-8(fp)
	movl	(sp)+,ap
	rsb

explod2:cmpl	room,21		# use print to convert number to chars
	jgtr	explod3
	jsb	flush

explod3:movq	output+8,tmp1	# save pointer and size
	pushl	$explod4
	pushl	ap
	jbr	prinn

explod4:subl3	output+12,tmp2,r1
	decl	r1
	movq	tmp1,output+8	# restore buffer pointers
	movl	output+8,r2	# pointer to numerals
	movl	fp,r0
	jbr	explod1

implode:
	movl	r0,r6
	movq	dummy,(fp)+	# make atomic head
	clrl	(fp)+
	clrl	r11		# length of pname
	movl	fp,r3

implod1:
	movq	(r6),r6
	jlss	implod2
	extzv	$8,$23,4(r7),r0
	subl2	$12,r0
	addl2	r0,r11
	movc3	r0,12(r7),(r3)	# concatinate pnames
	jbr	implod1

implod2:
	addl2	$12,r11
	insv	r11,$8,$23,-8(fp)
	subl3	$12,fp,r0
	addl2	$7,r3
	bicl3	$7,r3,fp
	movl	r0,r8
	jbr	intern		# enter on oblist

copy2:	movl	(ap),r1		# (cdr x)
	movq	(r1),r2
	jlss	copy3
	pushl	$copy4
	pushl	ap
	movl	r0,(ap)+
	movl	r1,r0

copy:	cmpl	ap,sp
	jgequ	crash
	movq	(r0),r1
	jlss	copy1		# ((atom x) x)
	pushl	$copy2		# (cons (copy (car x))(copy (cdr x)))
	pushl	ap
	movl	r1,(ap)+	# (cdr x)
	movl	r2,r0		# (car x)
	jbr	copy

copy4:	movl	(ap),r1
	movq	r0,(fp)+
	subl3	$8,fp,r0

copy1:	movl	(sp)+,ap
	rsb

copy3:	movl	r1,(fp)+
	movl	r0,(fp)+
	subl3	$8,fp,r0
	movl	(sp)+,ap
	rsb

gensym:	movl	fp,r0
	movq	dummy,(fp)+
	movl	$1,r1		# length
	clrl	(fp)+
	movb	$0x67,(fp)+
	movl	gencon,r2	# gensym number
	movl	$0x30,r5	# "0"

gensy1:	divl3	$10,r2,r3
	mull3	$10,r3,r4
	subl2	r4,r2
	addl2	r5,r2
	movb	r2,(fp)+
	incl	r1
	movl	r3,r2
	jneq	gensy1
	addl2	$12,r1
	insv	r1,$8,$23,4(r0)
	addl2	$7,fp
	bicl2	$7,fp
	incl	gencon
	movl	(sp)+,ap
	rsb

getpl:	movl	8(r0),r0
	movl	(sp)+,ap
	rsb

setpl:	movl	(ap),r1
	movl	r0,8(r1)
	movl	(sp)+,ap
	rsb

list:	movl	r0,r8
	movl	fp,r0
	addl3	$8,fp,r1
	movl	(ap)+,r2
	jlss	list2

list1:	movq	r1,(fp)+	# start cons'ing arguments
	addl2	$8,r1
	movl	(ap)+,r2
	jgeq	list1

list2:	movl	r8,r2		# cons last argument
	clrl	r1		# list ends in nil
	movq	r1,(fp)+
	movl	(sp)+,ap
	rsb

digit:	cmpl	r0,$zero
	jlss	digit1		# false
	cmpl	r0,$nine
	jleq	append1

digit1:	clrl	r0
	movl	(sp)+,ap
	rsb

liter:	subl3	$apval,r0,r1
	bicl2	$0x200,r1
	cmpl	r1,$0x410
	jlss	digit1
	cmpl	r1,$0x5a0
	jgtr	digit1

append1:movl	(sp)+,ap
	rsb

append:	movl	(ap),r3
	tstl	r3
	jeql	append1
	movl	fp,r2

append2:movq	(r3),r3
	addl3	$8,fp,(fp)+
	movl	r4,(fp)+
	tstl	r3
	jneq	append2
	movl	r0,-8(fp)

revers1:movl	r2,r0
	movl	(sp)+,ap
	rsb

reverse:clrl	r2

revers2:tstl	r0
	jeql	revers1
	movq	(r0),r0
	movl	r1,r3
	movq	r2,(fp)+
	subl3	$8,fp,r2
	jbr	revers2

nconc:	movl	(ap),r1
	jeql	append1

nconc1:	movl	(r1),r2
	jeql	nconc2
	movl	r2,r1
	jbr	nconc1

nconc2:	movl	r0,(r1)
	movl	(ap),r0
	movl	(sp)+,ap
	rsb

last:	tstl	r0
	jeql	append1

last1:	movl	(r0)+,r1
	jeql	last2
	movl	r1,r0
	jbr	last1

last2:	movl	(r0),r0
	movl	(sp)+,ap
	rsb

define1:movq	(r0),r0
	movq	(r1),r1
	movl	4(r1),(r2)	# (setq (caar l) (cadar l))
	pushl	$cons
	pushl	ap
	movl	r2,(ap)+	# (cons (caar l) (define (cdr l)))
	cmpl	ap,sp
	jgequ	crash

define:	tstl	r0
	jneq	define1
	movl	(sp)+,ap	# (return nil)
	rsb

memq:	movl	(ap),r2

memq2:	tstl	r0
	jeql	memq1		# nil of empty list
	movq	(r0),r0
	cmpl	r2,r1
	jneq	memq2
	movl	$t,r0

memq1:	movl	(sp)+,ap
	rsb

alphale:movl	(ap),r1
	extzv	$8,$23,4(r0),r2
	extzv	$8,$23,4(r1),r3
	subl2	$12,r2
	subl2	$12,r3
	cmpl	r2,r3
	jleq	alphal1
	cmpc3	r3,12(r1),12(r0)
	jleq	alphal3		#  less or equal because first is shorter
	clrl	r0
	movl	(sp)+,ap
	rsb

alphal1:cmpc3	r2,12(r1),12(r0)
	jlss	alphal3		# true
	clrl	r0
	movl	(sp)+,ap
	rsb

alphal3:movl	$t,r0
	movl	(sp)+,ap
	rsb

#
#	setflag - set bit arg1 in flag word of each atom in list arg2
#		analogously for clrflag
#		flag tests bit arg1 in atom arg2
#
setflag:movl	(ap),r1
	cvtdl	8(r1),r2
	ashl	r2,$1,r2

setflg1:tstl	r0
	jeql	alphal3
	movl	4(r0),r1
	bisb2	r2,4(r1)
	movl	(r0),r0
	jbr	setflg1

clrflag:movl	(ap),r1
	cvtdl	8(r1),r2
	ashl	r2,$1,r2

clrflg1:tstl	r0
	jeql	alphal3
	movl	4(r0),r1
	bicb2	r2,4(r1)
	movl	(r0),r0
	jbr	clrflg1

flag:	movl	(ap),r1
	cvtdl	8(r1),r2
	ashl	r2,$1,r2
	bitb	r2,4(r0)
	jneq	alphal3
	clrl	r0
	movl	(sp)+,ap
	rsb

#
#	trace & untrace - set/unset trace bit on atom
#
trace:	movl	$ftwo,(ap)
	jbr	setflag

untrace:movl	$ftwo,(ap)
	jbr	clrflag
