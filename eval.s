#.file	#eval.s"
#.line 2
#
#	eval - evaluate lisp exressions
#	D.P.Mitchell  80/03/13.
#
eval17:	mcoml	$0,(ap)+	# put mark at end of arglist
	cmpl	ap,sp		# check for stack collision
	jlssu	eval4
	jmp	crash

eval1:	movl	(sp)+,ap	# (return r0)
	rsb

mapush:	movl	(ap),r1
	movl	r0,(ap)+
	movq	(r1),r0
	tstl	r0
	jeql	eval17
	subl2	$4,sp		# pushl $mapush
	pushl	ap
	movl	r0,(ap)+
	jbr	eval4

eval2:	pushl	r1		# last return calls subr
	pushl	ap
	movq	(r0),r0
	tstl	r0
	jeql	eval17
	pushl	$mapush		# (mapush arglist)
	pushl	ap
	movl	r0,(ap)+

eval4:	movl	r1,r0

eval:	movq	(r0),r0		# (setq r0 (cdr x) r1 (car x))
	jlss	eval1		# (cond ((atom x) (return (cdr x))))

##IF TRACING
##
##	trace eval
##
#	movl	r0,(ap)+
#	movl	r1,r0
#	bitb	$4,4(r0)	# trace bit set?
#	jeql	teval		# no
#	pushl	$teval
#	pushl	ap
#	jbr	print
#
#teval:	movl	r0,r1
#	movl	-(ap),r0
#
##ENDIF TRACING

eval5:	movq	(r1),r1		# (setq r1 (cdr operator) r2 (car operator))
	jgeq	eval7		# (cond ((not (atom operator)) (go eval7))
	cmpl	r1,$etext
	jgtru	eval5		# (cond ((not (subrp operator)))(setq operator r1)(go eval5)))
	jlbs	r2,eval6	# (cond ((fsubrp operator) (funcall r1 r0)))
	tstl	r0
	jneq	eval2		# (cond ((not (null arglist))) (funcall r1 (mapush r0))))

eval6:	jmp	(r1)

eval7:	cmpl	r2,$lambda	# (cond (not (eq (car operator 'lambda)) (go eval12)))
	jneq	eval12
	movq	(r1),r1
	movl	4(r1),r1
	tstl	r0
	jeql	eval4		# (cond ((null arglist) (eval (caddr operator))))
	cmpl	*(sp),r2	# first condition for branch-on-last-call
	jneq	eval8
	cmpl	4(sp),$unbind	# second condition, just reset bindings and eval
	jeql	eval10

eval8:	pushl	$unbind		# use movq when global registers used.
	pushl	ap
	movl	r2,(ap)+	# save bound variable list
	movl	r2,r3

eval9:	movq	(r3),r3		# (setq r3 (cdr r3) r4 (car r3))
	movl	(r4),(ap)+	# save old bindings
	tstl	r3
	jneq	eval9

eval10:	movq	r1,(ap)+	# push body and bound variables of expr
	movl	$eval11,r1
	jbr	eval2		# evaluate arguments with mapush

eval11:	movl	ap,r4		# start of evaluated arguments
	movq	-(ap),r1	# restore body and blist
	movq	(r2),r2
	tstl	r2
	jeql	eval15		# last argument to set

eval16:	movl	(r4)+,(r3)
	movq	(r2),r2
	tstl	r2
	jneq	eval16

eval15:	movl	r0,(r3)
	jbr	eval4		# evaluate body

eval12:	movl	r0,(ap)+	# save arglist
	pushl	$eval13		# (eval (list (eval operator) arglist))
	pushl	ap
	movl	r1,r0
	movl	r2,r1
	jbr	eval5

eval13:	movl	r0,r1
	movl	-(ap),r0
	jbr	eval5

unbind:	movl	(ap)+,r1	# restore old bindings to boundlist

unbnd1:	movq	(r1),r1
	movl	(ap)+,(r2)
	tstl	r1
	jneq	unbnd1
unbnd2:	movl	(sp)+,ap
	rsb			# (return r0)
# from here on... copied from eval.s by RP 17 Oct 80
#
#	apply - apply function to argument list
#
apply:	movl	(ap),r4
	movl	ap,r3
	tstl	r0
	jeql	apply1		# no args
	movq	(r0),r0
	tstl	r0
	jeql	apply3

apply2:	movl	r1,(ap)+
	movq	(r0),r0
	tstl	r0
	jneq	apply2		# keep pushing args on stack

apply3:	mcoml	$0,(ap)+	# mark last arg
	movl	r1,r0

apply1:	cmpl	r4,$etext	# apply r4 to arguments on stack now
	jlssu	apply4		# apply subr
	movq	(r4),r4
	jlss	apply1		# keep searching values
	cmpl	r5,$lambda
	jeql	apply5		# apply expr
	movl	r3,(ap)+
	pushl	$apply6
	pushl	ap
	movq	r4,r0
	jbr	eval5

apply6:	movl	r0,r4
	movl	-(ap),r3
	jbr	apply1

apply4:	movl	r3,ap
	jmp	(r4)		# call subr

apply5:	movl	r3,ap		# call expr
	movq	(r4),r1
	movl	4(r1),r1
	tstl	r2
	jeql	eval4
	movq	(r2),r2
	tstl	r2
	jeql	eval15
	movl	ap,r4
	jbr	eval16

mapc:	addl2	$4,ap
	movl	r0,(ap)+
	jeql	unbnd2		# return nil of no args

mapc1:	movl	-(ap),r0
	movl	-4(ap),r4
	movq	(r0),r0
	movl	r0,(ap)+
	jeql	mapc2		# branch on last call
	pushl	$mapc1
	pushl	ap

mapc2:	movl	r1,r0
	mcoml	$0,(ap)
	movl	ap,r3
	jbr	apply1

map:	addl2	$4,ap
	movl	r0,(ap)+

map1:	movl	-8(ap),r4
	movl	-4(ap),r0
	jeql	map2		# end of args, branch on last call
	movl	(r0),-4(ap)
	pushl	$map1
	pushl	ap

map2:	mcoml	$0,(ap)
	movl	ap,r3
	jbr	apply1

mapcar:	movl	r0,r1
	jeql	unbnd2
	pushl	$list
	pushl	ap		# return to list to build result when finished
	movl	(ap),r4
	jbr	mapcar3

mapcar1:movl	-(ap),r4
	movl	-(ap),r1
	movl	r0,(ap)+	# stack (f (car l))

mapcar3:movl	4(r1),r0
	movl	(r1),(ap)+	# stack (cdr l)
	jeql	mapcar2		# branch on last call
	movl	r4,(ap)+
	pushl	$mapcar1
	pushl	ap
	mcoml	$0,(ap)
	movl	ap,r3
	jbr	apply1

mapcar2:mcoml	$0,-(ap)
	movl	ap,r3
	jbr	apply1
