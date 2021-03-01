(progn
(define '(
(ppl (lambda (l) (progn
	(princ lpar)
	(princ 'define)
	(PRINTWITHBLANK squote)
	(print lpar)
	(mapc 'pp l)
	(princ rpar)
	(print rpar)
	blank )))
(pp (lambda (l) (progn
	(princ lpar)
	(princ l)
	(PRINTWITHBLANK lpar)
	(princ 'lambda)
	(PRINTWITHBLANK (car (cdr (eval l))))
	(terpri)
	(PP (caddr (eval l)) 1)
	(princ rpar) (princ rpar)
	(terpri) )))
(PP (lambda (l n) (cond
	((atom l) (INDENT l n))
	((atom (car l)) (FUNCTION l n))
	(t
		(INDENT lpar n)
		(QPRINT (car l))
		(OUTLIST (cdr l) (add1 n))
		(QPRINC rpar) ) )))
(INDENT (lambda (l n) (cond
	((zerop n) (QPRINC l))
	(t
		(QPRINC tab)
		(INDENT l (sub1 n)) ) )))
(FUNCTION (lambda (l n) (cond
	((or (eq (car l) 'cond) (eq (car l) 'progn) (eq (car l) 't))
		(INDENT lpar n)
		(QPRINT (car l))
		(OUTLIST (cdr l) (add1 n))
		(QPRINC rpar) )
	(t
		(INDENT l n) ) )))
(OUTLIST (lambda (l n) (cond
	((null l) nil)
	(t
		(PP (car l) n)
		(cond
			((not (null (cdr l)))
				(terpri)
				(OUTLIST (cdr l) n) ) ) ) )))
(QPRINC (lambda (l)
	(QPR l princ) ))
(QPRINT (lambda (l)
	(QPR l print) ))
(QPR (lambda (l printer) (cond
	((atom l) (printer l))
	((eq (car l) 'quote)
		(princ squote)
		(QPR (cadr l) printer) )
	(t
		(princ lpar)
		(QPRINC (car l))
		(cond ((and (cdr l) (cadr l))
			(mapc 'PRINTWITHBLANK (cdr l)) ))
		(printer rpar) ) )))
(PRINTWITHBLANK (lambda (a) (progn
	(princ blank)
	(QPRINC a) )))
))
blank
)
