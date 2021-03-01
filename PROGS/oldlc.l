(progn
(setq allregs '(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 ap fp sp pc))
(setq regcycle '(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11))
(setq reglist (copy regcycle))
(setq dummy (setq lastins (list nil nil nil nil)))
(setq void '(* * * * * * * * * * * *))
(nconc regcycle regcycle)
(define '(
(compile (lambda (e bl off lev) (cond
	((atom e) (cond
		((null e) (list 0 dollar 0))
		((and (eq (getpl 'r0) 'initial)
			(eq e (last bl)))
				(list 'r0 dollar 0) )
		((memq e bl) (past (list 'ap nil 0) (ord e bl)))
		(t (list e dollar 0)) ))
	((eq (car e) 'lambda)
		(complambda e lev (genlab)) )
	((eq (car e) 'quote) (compile (cadr e) bl off lev))
	((eq (car e) 'cdr)
		(indirect (compile (cadr e) bl off (add1 lev))) )
	((eq (car e) 'car)
		(past (indirect (compile (cadr e) bl off (add1 lev))) 4) )
	((eq (car e) 'cadr )
		(past (indirect (indirect (compile (cadr e) bl off (add1 lev)))) 4) )
	((eq (car e) 'caddr )
		(past (indirect (indirect (indirect (compile (cadr e) bl off (add1 lev))))) 4) )
	((eq (car e) 'getpl)
		(past (indirect (compile (cadr e) bl off (add1 lev))) 8) )
	((eq (car e) 'atom)
		(comptest (past (indirect (compile (cadr e) bl off (add1 lev))) 4)
			  jumpgeq (genlab) (clear (allocreg))) )
	((memq (car e) '(null not))
		(comptest (compile (cadr e) bl off (add1 lev))
			  jumpneq (genlab) (clear (allocreg))) )
	((eq (car e) 'cond) (compcond (cdr e) (genlab) (genlab)
				(allocreg) bl off lev))
	((eq (car e) 'eq) (compcompare (reserve (compile (cadr e) bl off (add1 lev)))
		(compile (caddr e) bl off (add1 lev)) jumpneq (genlab)
		(clear (allocreg))) )
	((eq (car e) 'cons) (construct (reserve (compile (cadr e) bl off (add1 lev)))
		(compile (caddr e) bl off (add1 lev)) (allocreg) ))
	((eq (car e) 'list) (complist (cdr e) bl off (add1 lev)))
	(t (compfunction (cdr e) (car e) bl off lev)) )))
(comptest (lambda (e j label reg) (progn
	(test e j label)
	(move (list t dollar 0) reg)
	(putlab label)
	reg )))
(compcompare (lambda (e1 e2 j label reg) (progn
	(compare e1 e2 j label)
	(move (list t dollar 0) reg)
	(putlab label)
	reg )))
(compcond (lambda (l endlab nextlab reg bl off lev) (cond
	((null l)
		(putlab endlab)
		reg )
	(t
		(compredicate (caar l) nextlab nil bl off (add1 lev))
		(cond
			((zerop lev)
				(ret (move (compile (cadar l) bl off lev)
					(list 'r0 dollar o) )) )
			(t
				(move (compile (cadar l) bl off lev) reg)
				(jump endlab) ) ) 
		(putlab nextlab)
		(compcond (cdr l) endlab (genlab) reg bl off lev) ) )))
(compredicate (lambda (e nextlab invert bl off lev) (cond
	((eq e t) nil)
	((atom e) (cond
		(invert (test (compile e bl off lev) jumpneq nextlab))
		(t (test (compile e bl off lev) jumpeql nextlab)) ))
	((memq (car e) '(null not))
		(compredicate (cadr e) nextlab (not invert) bl off lev) )
	((eq (car e) 'atom) (cond
		(invert (test (past (indirect (compile (cadr e) bl off lev)) 4)
			jumplss nextlab) )
		(t (test (past (indirect (compile (cadr e) bl off lev)) 4)
			jumpgeq nextlab) ) ))
	((eq (car e) 'eq) (cond
		(invert (compare (compile (cadr e) bl off lev)
			(compile (caddr e) bl off lev) jumpeql nextlab))
		(t (compare (compile (cadr e) bl off lev)
			(compile (caddr e) bl off lev) jumpneq nextlab)) ))
	((eq (car e) 'and) (mapc
		(lambda (e) (compredicate e nextlab invert bl off lev))
		(cdr e) ))
	(t (cond
		(invert (test (compile e bl off lev) jumpneq nextlab))
		(t (test (compile e bl off lev) jumpeql nextlab)) )) )))
(complist (lambda (l bl off lev) (cond
	((null l) (list 0 dollar 0))
	(t
		(construct
			(reserve (compile (car l) bl off lev))
			(complist (cdr l) bl off lev) (allocreg) ) ) )))
(compfunction (lambda (args fun bl off lev) (cond
	((null args) (call (compile fun bl off (add1 lev)) (genlab) off lev))
	((null (cdr args))
		(move (compile (car args) bl off (add1 lev)) (list 'r0 dollar 0))
		(call (compile fun bl off (add1 lev)) (genlab) (saveregs reglist off) lev) )
	(t
		(move (compile (car args) bl off (add1 lev)) (list 'ap nil off))
		(compfunction (cdr args) fun bl (plus 4 off) lev) ) )))
(complambda (lambda (e lev startlab) (progn
	(putlab startlab)
	(setpl 'r0 'initial)
	(setq r0 (list 'r0 dollar 0))
	(ret (move (compile (caddr e) (cadr e)
		(times 4 (length (cadr e))) lev) (list 'r0 dollar 0))) startlab)))
(saveregs (lambda (rl off) (cond
	((null rl) off)
	((eq (getpl (car rl)) 'initial)
		(setpl (car rl) 'reserved)
		(move (list 'r0 dollar 0) nil (list 'ap nil
			(times 4 (sub1 (length bl))) ))
		(savereg (cdr rl) off) )
	((getpl (car rl))
		(move (eval (car rl)) (list 'ap nil off))
		(replace (eval (car rl)) (list 'ap nil off))
		(release (eval (car rl)))
		(set (cdr rl) nil)
		(saveregs (cdr rl) (plus 4 off)) )
	(t
		(set (car rl) nil)
		(saveregs (cdr rl) off) ) )))
(replace (lambda (l1 l2) (progn
	(rplaca l1 (car l2))
	(rplaca (cdr l1) (cadr l2))
	(rplaca (cddr l1) (caddr l2)) )))
(lc (lambda (fun) (progn
	(mapc '(lambda (e) (set e nil)) reglist)
	(mapc '(lambda (e) (setpl e nil)) reglist)
	(complambda (eval fun) 0 (list fun dollar 0)) )))
(ret (lambda (pass) (progn
	(move (list 'sp nil pluss) (list 'ap dollar 0))
	(code 'rsb nil nil nil) 
	pass)))
(allocreg (lambda () (cond
	((getpl (cadr regcycle))
		(setq regcycle (cdr regcycle))
		(allocreg) )
	(t (list (car (setq regcycle (cdr regcycle))) dollar 0)) )))
(release (lambda (op) (cond
	((not (print (list 'release op))) nil)
	((memq (car op) reglist)
		(setpl (car op) nil)
		(set (car op) nil)
		op)
	(t op) )))
(reserve (lambda (op) (cond
	((not (print (list 'reserve op))) nil)
	((memq (car op) reglist)
		(setpl (car op) 'reserved)
		(set (car op) op)
		op)
	(t op) )))
(regvalues (lambda () (mapcar eval reglist)))
(genlab (lambda () (list (gensym) dollar 0)))
(putlab (lambda (label) (progn
	(terpri) (princ (car label)) (princ colon) (setq lastins dummy) )))
(move (lambda (src dst) (cond
	((equal src dst) dst)
	((zeroop src) (clear dst))
	(t
		(code 'movl src nil dst)
		dst) )))
(clear (lambda (dst) (progn (code 'clrl nil nil dst) dst)))
(pushap (lambda (n lev) (cond
	((zerop n) nil)
	(t (code 'addl2 (list n dollar 0) nil (list 'ap dollar 0))) )))
(test (lambda (op j lab) (cond
	((equal op (car (cdddr lastins))) (j lab))
	((and (eq (car lastins 'movl)) (equal op (cadr lastins))) (j lab))
	((zeroop op) (cond
		((eq j jumpeql) (jump lab))
		((eq j jumpneq) nil)
		(t (code 'tstl nil nil op) (j lab)) ))
	(t (code 'tstl nil nil op)
		(j lab) ) )))
(compare (lambda (op1 op2 j lab) (cond
	((equal (release op1) op2) (cond
		((eq j jumpeql) (jump lab))
		((eq j jumpneq) nil)
		(t (code 'cmpl op1 nil op2) (j lab)) ))
	(t (code 'cmpl op1 nil op2)
		(j lab) ) )))
(construct (lambda (a d reg) (progn
	(move (list 'fp dollar 0) reg)
	(move d (list 'fp nil pluss))
	(move (release a) (list 'fp nil pluss))
	reg)))
(jumpeql (lambda (dst) (code 'jeql nil nil dst)))
(jumpneq (lambda (dst) (code 'jneq nil nil dst)))
(jumplss (lambda (dst) (code 'jlss nil nil dst)))
(jumpgeq (lambda (dst) (code 'jgeq nil nil dst)))
(indirect (lambda (op) (cond
	((eq (cadr op) dollar) (list (car op) nil (caddr op)))
	((null (cadr op)) (list (car op) star (caddr op)))
	(t (indirect (move op (allocreg)))) )))
(past (lambda (op n) (cond
	((null (cadr op)) (list (car op) nil (plus n (caddr op))))
	(t (past (indirect (move (list (car op) nil (caddr op)) (allocreg))) n)) )))
(jump (lambda (dst) (cond
	((and (not (memq (car dst) allregs)) (eq (cadr dst) dollar))
		(code 'jbr nil nil (indirect dst)) )
	(t (code 'jmp nil nil (indirect dst))) )))
(call (lambda (dst retlab off lev) (cond
	((zerop lev)
		(pushap off lev)
		(jump dst)
		(putlab retlab)
		(list 'r0 dollar 0) )
	(t
		(code 'pushl nil nil retlab)
		(code 'pushl nil nil (list 'ap dollar 0))
		(call dst retlab off 0) ) )))
(zeroop (lambda (op) (and (numberp (car op)) (zerop (car op)))))
(registerp (lambda (reg) (and (memq (car reg) allregs) (eq (cadr reg) dollar))))
(ord (lambda (a l) (cond
	((eq (car l) a) 0)
	(t (plus 4 (ord a (cdr l)))) )))
(code (lambda (op src1 src2 dst) (cond
	((eq (car lastins) 'jmp) nil)
	((eq (car lastins) 'jbr) nil)
	(t
		(princ tab) (princ op)
		(cond (dst (princ tab)))
		(cond (src1 (printoperand src1) (princ comma)))
		(cond (src2 (printoperand src2) (princ comma)))
		(cond (dst (printoperand dst)))
		(setq lastins (list op src1 src2 dst))
		(terpri) ) )))
(printoperand (lambda (op) (cond
	((eq (cadr op) star)
		(princ star)
		(printoperand (list (car op) nil (caddr op))) )
	((memq (car op) allregs) (cond
		((eq (cadr op) dollar) (princ (car op)))
		(t (cond
			((eq (caddr op) pluss)
				(princ (list (car op)))
				(princ pluss) )
			((zerop (caddr op)) (princ (list (car op))))
			(t (princ (caddr op)) (princ (list (car op)))) )) ))
	(t
		(cond ((cadr op) (princ (cadr op))))
		(princ (car op))
		(cond
			((zerop (caddr op)) nil)
			(t (princ pluss) (princ (caddr op))) ) ) )))
))
(implode (list '# blank 'lisp blank 'compiler blank 'v4))
)


