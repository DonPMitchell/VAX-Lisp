(define '(
(deriv (lambda (e x) (cond
	((atom e) (cond
		((eq e x) 1)
		(t 0) ))
	((eq (car e) 'plus) (cons 'plus (derivlis (cdr e) x)))
	((eq (car e) 'times) (cons 'plus (perm (cdr e) (derivlis (cdr e) x))))
	((eq (car e) 'expt) (cond
		((numberp (caddr e)) (list 'times (caddr e)
			(deriv (cadr e) x)
			(list 'expt (cadr e) (sub1 (caddr e))) ))
		(t (list 'times e (deriv (list 'times (caddr e)
				(list 'log (cadr e)) ) x))) ))
	((eq (car e) 'exp) (list 'times (deriv (cadr e) x) e))
	((eq (car e) 'log) (list 'times (deriv (cadr e) x)
			(list 'expt (cadr e) -1) )) )))
(derivlis (lambda (l x) (cond
	((null l) nil)
	(t (cons (deriv (car l) x) (derivlis (cdr l) x))) )))
(cycle (lambda (l) (exchangd (nconc l l) nil)))
(perm (lambda (l ld) (cond
	((null ld) nil)
	(t (cons (cons 'times (cp2 (cdr l) (ncons (car ld))))
		(perm (cycle l) (cdr ld)) )) )))
(cp2 (lambda (l end) (cond
	((null l) end)
	(t (cons (car l) (cp2 (cdr l) end))) )))
(integrate (lambda (e x) (cond
	((atom e) (cond
		((eq e x) (list 'times 0.5 (list 'expt x 2)))
		(t (list 'times e x)) ))
	((eq (car e) 'plus) (cons 'plus (integlis (cdr e) x)))
	((eq (car e) 'times) (cons 'times (integprod (cdr e) x)))
	((eq (car e) 'expt) (cond
		((eqn (caddr e) -1) (list 'log (cadr e)))
		(t (list 'times (recip (add1 (caddr e))) (list 'expt
			(cadr e) (add1 (caddr e)) ))) ))
	(t nil) )))
(integlis (lambda (l x) (cond
	((null l) (ncons (gensym)))
	(t (cons (integrate (car l) x) (integlis (cdr l) x))) )))
(integprod (lambda (l x) (cond
	((null l) nil)
	((zerop (simplify (deriv (car l) x))) (cons (car l)
				(integprod (cdr l) x) ))
	(t (cons (integrate (car l) x) (integprod (cdr l) x))) )))
))

