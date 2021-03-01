(setq registers '(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 ap fp sp pc))
(setq tab '\	)
(setq lastins '(nil nil nil))

(define '(

(lc (lambda (funname) (progn
	(putlabel funname)
	(complambda t (eval funname)) )))
(complambda (lambda (toplevel expr) (progn
	(compile toplevel (bind (cadr expr) 0) (caddr expr)) )))
(bind (lambda (boundvars n) (cond
	((null boundvars) nil)
	((null (cdr boundvars)) (list (cons (car boundvars) '($ 0 r0))))
	(t (cons (cons (car boundvars) (list '@ n 'fp)) (bind (cdr boundvars) (plus n 4)))) )))
(compile (lambda (toplevel blist expr) (cond
	((null expr) '($ 0 1))
	((setq x (assoc expr blist)) (cdr x))
	((atom expr) (list '$ 0 expr))
	(t (compfunction (genlab) toplevel blist (car expr) (cdr expr))) )))
(compfunction (lambda (label toplevel blist fun args) (cond
	((null args) (progn
		(code 'pushab nil label)
		(code 'movq '($ 0 ap) '(@ - sp))
		(jump (compile nil blist fun))
		(putlabel (caddr label))
		'($ 0 r0) ))
	((null (cdr args)) (progn
		(move (compile nil blist (car args)) '($ 0 r0))
		(compfunction label toplevel blist fun nil) ))
	(t (progn
		(move (compile nil blist (car args)) '(@ + ap))
		(compfunction label toplevel blist fun (cdr args)) )) )))
(jump (lambda (dst) (code 'jbr nil dst)))
(move (lambda (src dst) (cond
	((equal src dst) nil)
	(t (code 'movl src dst)) )))
(genlab (lambda () (list '@ 0 (gensym))))
(putlabel (lambda (label) (progn
	(princ label)
	(princ ':)
	(terpri) )))
(code (lambda (op src1 dst) (cond
	((eq (car lastins) 'jmp) ())
	((eq (car lastins) 'jbr) ())
	(t
		(princ tab) (princ op)
		(cond (dst (princ tab)))
		(cond (src1 (printoperand src1) (princ '\,)))
		(cond (dst (printoperand dst)))
		(setq lastins (list op src1 dst))
		(terpri) ) )))
(printoperand (lambda (op) (cond
	((eq (car op) '*)
		(princ '*)
		(printoperand (cons '@ (cdr op))) )
	((memq (caddr op) registers) (cond
		((eq (car op) '$) (princ (caddr op)))
		(t (cond
			((eq (cadr op) '+)
				(princ (cddr op))
				(princ '+) )
			((eq (cadr op) '-)
				(princ '-)
				(princ (cddr op)) )
			((zerop (cadr op)) (princ (cddr op)))
			(t (princ (cadr op)) (princ (cddr op))) )) ))
	(t
		(cond ((not (eq (car op) '@)) (princ (car op))))
		(princ (caddr op))
		(cond
			((zerop (cadr op)) ())
			(t (princ '+) (princ (cadr op))) ) ) )))
(assoc (lambda (a l) (cond
	((null l) nil)
	((eq a (caar l)) (car l))
	(t (assoc a (cdr l))) )))

))
