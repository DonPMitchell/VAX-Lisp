(define '(

(deriv (lambda (y x) (cond
	((eq y x) 1)
	((atom y) 0)
	((eq (car y) 'plus)
		(list 'plus (deriv (cadr y) x) (deriv (caddr y) x)) )
	((eq (car y) 'times)
		(list 'plus
			(list 'times (cadr y) (deriv (caddr y) x))
			(list 'times (deriv (cadr y) x) (caddr y)) ) )
	((eq (car y) 'expt)
		(list 'times (list 'times (caddr y)
			(list 'expt (cadr y) (sub1 (caddr y))) )
			(deriv (cadr y) x) ) )
	((eq (car y) 'log)
		(list 'times (list 'expt (cadr y) -1) (deriv (cadr y) x)) ) )))

(ddx (lambda (y) (deriv y 'x)))

(nest (lambda (x n) (cond
	((zerop n) 1)
	((onep n) (ddx x))
	(t (ddx (nest x (sub1 n)))) )))

))
