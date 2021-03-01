
(setq popstack '(register 1 sp +))
(setq pushstack '(register 1 sp -))
(setq heap '(register 1 fp +))
(setq fp '(register 0 fp 0))
(setq r0 '(register 0 r0 0))
(setq ap '(register 0 ap 0))
(setq reglist '(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11))

(define '(
(printop (lambda (op) (printop4 (car op) (cadr op) (caddr op) (cadddr op))))
(printop4 (lambda (type indirection name offset) (cond
	((greaterp indirection 1) (progn
		(princ star)
		(printop4 type 1 name offset) ))
	((eq type 'register) (cond
		((zerop indirection) (princ name))
		(t (progn
			(cond
				((not (and (numberp offset) (zerop offset))) (princ offset)) )
			(princ lpar)
			(princ name)
			(princ rpar) )) ))
	((zerop indirection) (progn
		(princ dollar)
		(printop4 type 1 name offset) ))
	(t (progn
		(princ name)
		(cond
			((not (and (numberp offset) (zerop offset))) (progn
				(princ pluss)
				(princ offset) )) ) )) )))
(move (lambda (src dst) (cond
	((equal src dst) src)
	(t (progn
		(princ tab)
		(princ 'movl)
		(princ tab)
		(printop src)
		(princ comma)
		(printop dst)
		(terpri)
		dst )) )))
(indirect (lambda (op) (cond
	((greaterp (cadr op) 1) (indirect (move op (allocreg nil))))
	(t (list (car op) (add1 (cadr op)) (caddr op) (cadddr op))) )))
(index (lambda (op off) (list (car op) (cadr op) (caddr op) (plus off (cadddr op)))))
(compile (lambda (expr) (cond
	((atom expr)
		(move (list 'const 1 expr 0) r0) )
	(t (compile_form expr)) )))
(compile_form (lambda (form) (cond
	(t
		(push_args (cdr form))
		(call_fun  (car form) (gensym)) ) )))

(push_args (lambda (args) (cond
	((null args) nil)
	((null (cdr args)) (compile (car args)))
	(t
		(move (compile (car args)) '(register 1 ap +))
		(push_args (cdr args)) ) )))

(call_fun (lambda (fun ret) (cond
	(t
		(princ tab)
		(princ 'pushab)
		(princ tab)
		(print ret)
		(princ tab)
		(princ 'movq)
		(princ tab)
		(printop ap)
		(princ ',)
		(printop pushstack)
		(terpri)
		(princ tab)
		(princ 'jmp)
		(princ tab)
		(print fun) ) )))
))
