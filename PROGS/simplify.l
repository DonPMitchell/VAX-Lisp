(progn (setq simpfuns (define '(
(simplify (lambda (e) (cond
	((atom e) e)
	(t
		(sargs (cdr e))
		((getpl (car e)) e) ) )))
(sargs (lambda (l) (cond
	((null l) nil)
	(t (sargs (cdr (rplaca l (simplify (car l)))))) )))
(slog (lambda (e) e))
(sexp (lambda (e) e))
(sdot (lambda (e) (cond
	((alphalessp (cadr e) (caddr e)) e)
	(t (rplaca (cdr e) (exchanga (cddr e) (cadr e))) e) )))
(sdifference (lambda (e) (progn
	(rplacd (cdr e) (ncons (stimes (list 'times -1 (caddr e)))))
	(splus (rplaca e 'plus)) )))
(squotient (lambda (e) (progn
	(rplacd (cdr e) (ncons (sexpt (list 'expt (caddr e) -1))))
	(stimes (rplaca e 'times)) )))
(sminus (lambda (e) (progn
	(rplacd e (cons -1 (cdr e)))
	(stimes (rplaca e 'times)) )))
(touchup (lambda (e op) (cond
	((null e) (cond
		((eq op 'plus) 0)
		(t 1) ))
	((atom e) e)
	((null (cdr e)) (car e))
	(t (cons op e)) )))
(splus (lambda (e) (touchup (addlist (cdr e) nil) 'plus)))
(addlist (lambda (terms sum) (cond
	((null terms) sum)
	(t (addlist (cdr terms) (add (car terms) sum))) )))
(add (lambda (term sum) (cond
	((numberp term) (cond
		((zerop term) sum)
		((null sum) (ncons term))
		((numberp (car sum))
			(addnum (plus term (car sum)) (cdr sum)) )
		(t (cons term sum)) ))
	((atom term) (add3 term 1 sum))
	((eq (car term) 'plus) (addlist (cdr term) sum))
	((and (eq (car term) 'times) (numberp (cadr term)))
		(add3 (cond
			((null (cdddr term)) (caddr term))
			(t (cons 'times (cddr term))) ) (cadr term) sum))
	(t (add3 term 1 sum)) )))
(addnum (lambda (n l) (cond
	((zerop n) l)
	(t (cons n l)) )))
(add3 (lambda (term coeff sum) (cond
	((null sum) (makesum term coeff nil))
	((equal term (car sum))
		(makesum term (add1 coeff) (cdr sum)) )
	((and
		(not (atom (car sum)))
		(eq (caar sum) 'times)
		(numberp (cadar sum)) ) (cond
			((or
				(and
					(or
						(atom term)
						(not (eq (car term) 'times)) )
					(null (cdddar sum))
					(equal (caddar sum) term) )
				(and
					(not (atom term))
					(eq (car term) 'times)
					(equal (cdr term) (cddar sum)) ) )
						(makesum term
							(plus coeff (cadar sum))
							(cdr sum) ) )
			((comesfirst term (car sum)) (makesum term coeff sum))
			(t (rplacd sum (add3 term coeff (cdr sum)))) ))
	((comesfirst term (car sum)) (makesum term coeff sum))
	(t (rplacd sum (add3 term coeff (cdr sum)))) )))
(makesum (lambda (term coeff sum) (cond
	((zerop coeff) sum)
	((onep coeff) (cons term sum))
	((atom term) (cons (list 'times coeff term) sum))
	((eq (car term) 'times) (cons (cons 'times (cons coeff (cdr term))) sum))
	(t (cons (list 'times coeff term) sum)) )))
(stimes (lambda (e) (touchup (multlist (cdr e) nil) 'times)))
(multlist (lambda (factors prod) (cond
	((null factors) prod)
	((numberp prod) prod)
	(t (multlist (cdr factors) (mult (car factors) prod))) )))
(mult (lambda (factor prod) (cond
	((numberp factor) (cond
		((zerop factor) 0)
		((onep factor) prod)
		((null prod) (ncons factor))
		((numberp (car prod))
			(multnum (times factor (car prod)) (cdr prod)) )
		(t (cons factor prod)) ))
	((atom factor) (mult3 factor 1 prod))
	((eq (car factor) 'times) (multlist (cdr factor) prod))
	((and (eq (car factor) 'expt) (numberp (caddr factor)))
		(mult3 (cadr factor) (caddr factor) prod))
	(t (mult3 factor 1 prod)) )))
(multnum (lambda (n l) (cond
	((onep n) l)
	(t (cons n l)) )))
(mult3 (lambda (factor power prod) (cond
	((null prod) (makeprod factor power nil))
	((equal factor (car prod))
		(makeprod factor (add1 power) (cdr prod)) )
	((and
		(not (atom (car prod)))
		(eq (caar prod) 'expt)
		(numberp (caddar prod)) ) (cond
			((and
				(or
					(atom factor)
					(not (eq (car factor) 'expt)) )
				(equal (cadar prod) factor) )
					(makeprod factor
						(plus power (caddar prod))
						(cdr prod) ) )
			((comesfirst factor (car prod)) (makeprod factor power prod))
			(t (rplacd prod (mult3 factor power (cdr prod)))) ))
	((comesfirst factor (car prod)) (makeprod factor power prod))
	(t (rplacd prod (mult3 factor power (cdr prod)))) )))
(makeprod (lambda (factor power prod) (cond
	((zerop power) prod)
	((onep power) (cons factor prod))
	(t (cons (list 'expt factor power) prod)) )))
(sexpt (lambda (e) (cond
	((numberp (cadr e)) (cond
		((zerop (cadr e)) 0)
		((onep (cadr e)) 1)
		((numberp (caddr e)) (eval e))
		(t e) ))
	((numberp (caddr e)) (cond
		((zerop (caddr e)) 1)
		((onep (caddr e)) (cadr e))
		((atom (cadr e)) e)
		((eq (caadr e) 'times) (cond
			((numberp (cadadr e)) (stimes (list 'times
				(sexpt (list 'expt (cadadr e) (caddr e)))
				(sexpt (list 'expt (cond
					((null (cdr (cddadr e))) (car (cddadr e)))
					(t (cons 'times (cddadr e))) )
					(caddr e) )) )))
			(t e) ))
		((and (eq (caadr e) 'expt) (numberp (car (cddadr e))))
			(sexpt (list 'expt (cadr e)
				(times (caddr e) (car (cddadr e))) )) )
		(t e) ))
	(t e) )))
(comesfirst (lambda (a b) (cond
	((numberp b) nil)
	((atom a) (cond
		((atom b) (alphalessp b a))
		((and (eq (car b) 'times) (numberp (cadr b)) (atom (caddr b))
			(null (cdddr b)))
				(alphalessp (caddr b) a) )
		((and (eq (car b) 'expt) (atom (cadr b)) (numberp (caddr b)))
			(alphalessp (cadr b) a) )
		(t nil) ))
	((atom b) (cond
		((and (eq (car a) 'times) (numberp (cadr a)) (atom (caddr a))
			(null (cdddr a)) )
				(or (eq b (caddr a)) (alphalessp b (caddr a))) )
		((and (eq (car a) 'expt) (numberp (caddr a)) (atom (cadr a)))
			(or (eq b (cadr a)) (alphalessp b (cadr a))) )
		(t t) ))
	(t nil)
	((eq (car a) 'times) (cond
		((not (eq (car b) 'times)) t)
		((firstlis (cdr a) (cdr b)) t)
		(t nil) ))
	((eq (car a) 'expt) (cond
		((eq (car b) 'times) nil)
		((not (eq (car b) 'expt)) t)
		((comesfirst (caddr a) (caddr b)) t)
		((equal (caddr a) (caddr b)) (comesfirst (cadr a) (cadr b)))
		(t nil) ))
	((eq (car a) 'plus) (cond
		((or (eq (car b) 'times) (eq (car b) 'expt)) nil)
		((not (eq (car b) 'plus)) t)
		((firstlis (cdr a) (cdr b)) t)
		(t nil) ))
	(t (firstlis la lb)) )))
(firstlis (lambda (la lb) (cond
	((null la) nil)
	((null lb) t)
	((comesfirst (car la) (car lb)) t)
	((equal (car la) (car lb)) (firstlis (cdr la) (cdr lb)))
	(t nil) )))
(expt (lambda (a b) (cond
	((zerop b) (add1 0))
	((minusp b) (quotient (expt a (add1 b)) a))
	(t (times (expt a (sub1 b)) a)) )))
)))
	(setpl 'plus splus)
	(setpl 'times stimes)
	(setpl 'expt sexpt)
	(setpl 'minus sminus)
	(setpl 'difference sdifference)
	(setpl 'quotient squotient)
	(setpl 'log slog)
	(setpl 'exp sexp)
	(setpl 'dot sdot)
	simpfuns
)

