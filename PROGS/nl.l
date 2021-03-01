(define '(

(type (lambda (word) (car (getpl word))))

(alias (lambda (word) (cdr (getpl word))))

(trim (lambda (input) (cond
	((null input) nil)
	((memq (car input) (alias 'words)) (cons (car input) (trim (cdr input))))
	(t (trim (cdr input))) )))

(sense (lambda () (expand (read))))

(expand (lambda (x) (cond
	((null x) nil)
	((atom x) (explode x))
	(t (cons (expand (car x)) (expand (cdr x)))) )))
(metric (lambda (a b) (progn
	(setq succeed 0)
	(setq try 0)
	(match a b)
	(cond ((zerop try) 0) (t (quotient succeed try))) )))

(match (lambda (a b) (progn
	(setq try (add1 try))
	(cond
		((eq a b) (setq succeed (add1 succeed))) )
	(cond
		((not (or (atom a) (atom b)))
			(match (car a) (car b))
			(match (cdr a) (cdr b)) ) ) )))

(zero (lambda () (nsub1 (add1 0))))

(memlist (lambda (a l) (cond
	((null l) nil)
	((anchor a l) t)
	(t (memlist a (cdr l))) )))

(anchor (lambda (a l) (cond
	((null a) t)
	((null l) nil)
	((eq (car a) (car l)) (anchor (cdr a) (cdr l)))
	(t nil) )))

))
