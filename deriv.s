#.file	#deriv.s"
#.line 2
#NOTE: DOESN'T KNOW ABOUT THE RULE OF FLOATING POINT NUMBERS ONLY IN r10/r11
# lisp compiler v4

deriv:	cmpl	(ap),r0
	jneq	g1
	movl	$fone,r0
	movl	(sp)+,ap
	rsb

g1:	movl	(ap),r2
	tstl	4(r2)
	jgeq	g2
	movl	$fzero,r0
	movl	(sp)+,ap
	rsb

g2:	cmpl	4(r2),$_plus
	jneq	g3
	movl	(r2),r4
	movl	4(r4),8(ap)
	movl	r0,4(ap)
	pushl	$g4
	pushl	ap
	addl2	$8,ap
	jbr	deriv

g4:	movl	*(ap),r5
	movl	(r5),r6
	movl	4(r6),12(ap)
	movl	r0,8(ap)
	movl	4(ap),r0
	pushl	$g5
	pushl	ap
	addl2	$12,ap
	jbr	deriv

g5:	movl	fp,r7
	clrl	(fp)+
	movl	r0,(fp)+
	movl	fp,r8
	movl	r7,(fp)+
	movl	8(ap),(fp)+
	movl	fp,r0
	movl	r8,(fp)+
	movl	$_plus,(fp)+
	movl	(sp)+,ap
	rsb

g3:	cmpl	4(r2),$_diff
	jneq	g6
	movl	(r2),r11
	movl	r0,4(ap)
	movl	4(r11),8(ap)
	pushl	$g7
	pushl	ap
	addl2	$8,ap
	jbr	deriv

g7:	movl	*(ap),r1
	movl	(r1),r2
	movl	4(r2),12(ap)
	movl	r0,8(ap)
	movl	4(ap),r0
	pushl	$g8
	pushl	ap
	addl2	$12,ap
	jbr	deriv

g8:	movl	fp,r3
	clrl	(fp)+
	movl	r0,(fp)+
	movl	fp,r4
	movl	r3,(fp)+
	movl	8(ap),(fp)+
	movl	fp,r0
	movl	r4,(fp)+
	movl	$_diff,(fp)+
	movl	(sp)+,ap
	rsb

g6:	cmpl	4(r2),$_minus
	jneq	g9
	movl	(r2),r7
	movl	4(r7),8(ap)
	movl	r0,4(ap)
	pushl	$g01
	pushl	ap
	addl2	$8,ap
	jbr	deriv

g01:	movl	fp,r8
	clrl	(fp)+
	movl	r0,(fp)+
	movl	fp,r0
	movl	r8,(fp)+
	movl	$_minus,(fp)+
	movl	(sp)+,ap
	rsb
# fixed up to here

g9:	cmpl	4(r2),$_times
	jneq	g11
	movl	(r2),r11
	movl	4(r11),8(ap)
	movl	r0,4(ap)
	pushl	$g21
	pushl	ap
	addl2	$8,ap
	jbr	deriv

g21:	movl	*(ap),r1
	movl	(r1),r2
	movl	fp,r3
	clrl	(fp)+
	movl	4(r2),(fp)+
	movl	fp,r4
	movl	r3,(fp)+
	movl	r0,(fp)+
	movl	fp,8(ap)
	movl	r4,(fp)+
	movl	$_times,(fp)+
	movl	*(ap),r7
	movl	(r7),r8
	movl	4(r8),12(ap)
	movl	4(ap),r0
	pushl	$g31
	pushl	ap
	addl2	$12,ap
	jbr	deriv

g31:	movl	fp,r9
	clrl	(fp)+
	movl	r0,(fp)+
	movl	fp,r10
	movl	r9,(fp)+
	movl	*(ap),r6
	movl	4(r6),(fp)+
	movl	fp,r11
	movl	r10,(fp)+
	movl	$_times,(fp)+
# fixed to here
	movl	fp,r0
	clrl	(fp)+
	movl	r11,(fp)+
	movl	fp,r1
	movl	r0,(fp)+
	movl	8(ap),(fp)+
	movl	fp,r0
	movl	r1,(fp)+
	movl	$_plus,(fp)+
	movl	(sp)+,ap
	rsb

g11:	cmpl	4(r2),$_quoti
	jneq	g41
	movl	(r2),r4
	movl	4(r4),8(ap)
	movl	r0,4(ap)
	pushl	$g51
	pushl	ap
	addl2	$8,ap
	jbr	deriv

g51:	movl	*(ap),r5
	movl	(r5),r6
	movl	fp,r7
	clrl	(fp)+
	movl	4(r6),(fp)+
	movl	fp,r8
	movl	r7,(fp)+
	movl	r0,(fp)+
	movl	fp,8(ap)
	movl	r8,(fp)+
	movl	$_times,(fp)+
	movl	(r5),r0
	movl	4(r0),12(ap)
	movl	4(ap),r0
	pushl	$g61
	pushl	ap
	addl2	$12,ap
	jbr	deriv

g61:	movl	fp,r1
	clrl	(fp)+
	movl	r0,(fp)+
	movl	fp,r2
	movl	r1,(fp)+
	movl	*(ap),r10
	movl	4(r10),(fp)+
	movl	fp,r3
	movl	r2,(fp)+
	movl	$_times,(fp)+
	movl	fp,r4
	clrl	(fp)+
	movl	r3,(fp)+
	movl	fp,r5
	movl	r4,(fp)+
	movl	8(ap),(fp)+
	movl	fp,r6
	movl	r5,(fp)+
	movl	$_diff,(fp)+
	movl	(r10),r8
	movl	fp,r9
	clrl	(fp)+
	movl	$ftwo,(fp)+
	movl	fp,r10
	movl	r9,(fp)+
	movl	4(r8),(fp)+
	movl	fp,r11
	movl	r10,(fp)+
	movl	$_expt,(fp)+
	movl	fp,r0
	clrl	(fp)+
	movl	r11,(fp)+
	movl	fp,r1
	movl	r0,(fp)+
	movl	r6,(fp)+
	movl	fp,r0
	movl	r1,(fp)+
	movl	$_quoti,(fp)+
	movl	(sp)+,ap
	rsb

#fixe to here
g41:	cmpl	4(r2),$_expt
	jneq	g71
	movl	(r2),r4
	movl	(r4),r5
	movl	fp,r7
	clrl	(fp)+
	movl	4(r4),(fp)+
	movl	fp,r8
	movl	r7,(fp)+
	movl	$_log,(fp)+
	movl	fp,r9
	clrl	(fp)+
	movl	r8,(fp)+
	movl	fp,r10
	movl	r9,(fp)+
	movl	4(r5),(fp)+
	movl	fp,8(ap)
	movl	r10,(fp)+
	movl	$_times,(fp)+
	movl	r0,4(ap)
	pushl	$g81
	pushl	ap
	addl2	$8,ap
	jbr	deriv

g81:	movl	fp,r1
	clrl	(fp)+
	movl	r0,(fp)+
	movl	fp,r2
	movl	r1,(fp)+
	movl	(ap),(fp)+
	movl	fp,r0
	movl	r2,(fp)+
	movl	$_times,(fp)+
	movl	(sp)+,ap
	rsb

g71:	cmpl	4(r2),$_log
	jneq	g91
	movl	(r2),r5
	movl	4(r5),8(ap)
	movl	r0,4(ap)
	pushl	$g02
	pushl	ap
	addl2	$8,ap
	jbr	deriv

g02:	movl	*(ap),r6
	movl	fp,r7
	clrl	(fp)+
	movl	4(r6),(fp)+
	movl	fp,r8
	movl	r7,(fp)+
	movl	r0,(fp)+
	movl	fp,r0
	movl	r8,(fp)+
	movl	$_quoti,(fp)+
	movl	(sp)+,ap
	rsb

g91:	movl	fp,r10
	clrl	(fp)+
	movl	r0,(fp)+
	movl	fp,r11
	movl	r10,(fp)+
	movl	(ap),(fp)+
	movl	fp,r0
	movl	r11,(fp)+
	movl	$deriv,(fp)+
	movl	(sp)+,ap
	rsb

g12:
g0:	movl	r1,r0
	movl	(sp)+,ap
	rsb
