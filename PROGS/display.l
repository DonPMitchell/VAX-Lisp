(define '(
(display (lambda (e) (cond
	((atom e) (princ e))
	((eq (car e) 'plus) (displus (cdr e)))
	((eq (car e) 'times) (distimes (cdr e) t))
	((eq (car e) 'expt) (disexpt (cadr e) (caddr e) t))
	((eq (car e) 'dot) (princ (cadr e)) (princ period) (princ (caddr e)))
	(t (disfun (car e) (cadr e) (sub1 1))) )))
(disfun (lambda (opr arg nesting) (cond
	((and (not (atom arg)) (eq (car arg) opr))
		(disfun opr (cadr arg) (nadd1 nesting)))
	(t
		(princ opr)
		(cond
			((zerop nesting) nil)
			(t (princ arrow) (princ (nadd1 nesting))) )
		(princ lpar) (display arg) (princ rpar)
		blank) )))
(displus (lambda (l) (cond
	((null (cdr l)) (display (car l)))
	(t
		(display (car l))
		(princ blank)
		(cond
			((negp (cadr l)) (displus (cdr l)))
			(t
				(princ pluss)
				(princ blank)
				(displus (cdr l)) ) ) ) )))
(negp (lambda (e) (cond
	((numberp e) (minusp e))
	((atom e) nil)
	(t (and (eq (car e) 'times) (numberp (cadr e)) (minusp (cadr e)))) )))
(distimes (lambda (l first) (cond
	((null l) nil)
	((numberp (car l)) (cond
		((minusp (car l))
			(princ dash)
			(princ blank)
			(cond
				((eqn (car l) -1) (distimes (cdr l) first))
				(t
					(princ (minus (car l)))
					(distimes (cdr l) nil) ) ) )
		(t
			(princ (car l))
			(distimes (cdr l) nil) ) ))
	((atom (car l))
		(display (car l))
		(distimes (cdr l) nil) )
	((eq (caar l) 'plus)
			(princ lpar) (display (car l)) (princ rpar)
			(distimes (cdr l) nil) )
	((eq (caar l) 'expt)
		(disexpt (cadar l) (caddar l) first)
		(distimes (cdr l) nil) )
	(t
		(display (car l))
		(distimes (cdr l) nil) ) )))
(disexpt (lambda (e power first) (cond
	((numberp power) (cond
		((minusp power)
			(cond (first (princ one)))
			(princ slash)
			(disexpt e (minus power) first) )
		((onep power) (display e))
		(t
			(cond
				((atom e) (princ e))
				(t
					(princ lpar) (display e) (princ rpar) ) )
			(princ arrow)
			(princ power) ) ))
	(t
		(cond
			((numberp e) (princ blank) (princ e))
			((atom e) (princ e))
			(t
				(princ lpar) (display e) (princ rpar) ) )
		(princ arrow)
		(display power) ) )))
))

