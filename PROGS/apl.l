(progn
(define '(
(doiota (lambda (n x) (cond
	((lessp n 1) nil)
	(t (cons x (doiota (sub1 n) (add1 x)))) )))
(iota0 (lambda (n)
	(cond
	    ((atom n) (doiota n 0))
	    (t (iota0 (car n))) )))
(iota (lambda (n)
	(cond
	    ((atom n) (doiota n 1))
	    (t (iota (car n))) )))
(reduce (lambda (op l ident) (cond
	((null l) ident)
	((atom (car l)) (op (car l) (reduce op (cdr l) ident)))
	((null (cdr l)) (list (reduce op (car l) ident)))
	(t (cons (reduce op (car l) ident) (reduce op (cdr l) ident))) )))
(binop (lambda (atomop op a b) (cond
	((or (null a) (null b)) nil)
	((atom b) (cond
	    ((atom a) (atomop a b))
	    (t (cons (op (car a) b) (binop atomop op (cdr a) b))) ))
	((atom a) (cons (op a (car b)) (binop atomop op a (cdr b))))
	(t (cons (op (car a) (car b)) (binop atomop op (cdr a) (cdr b)))) )))
(+ (lambda (a b)
	(binop plus + a b) ))
(- (lambda (a b)
	(binop difference - a b) ))
(* (lambda (a b)
	(binop times * a b) ))
(/ (lambda (a b)
	(binop quotient / a b) ))
(rem (lambda (a b)
	(difference a (times b (entier (quotient a b)))) ))
(% (lambda (a b)
	(binop rem % a b) ))
(hi (lambda (a b)
	(binop max hi a b) ))
(lo (lambda (a b)
	(binop min lo a b) ))
(eql01 (lambda (a b) (cond
	((eqn a b) 1)
	(t 0) )))
(gtr01 (lambda (a b) (cond
	((greaterp a b) 1)
	(t 0) )))
(less01 (lambda (a b) (cond
	((lessp a b) 1)
	(t 0) )))
(gtreq01 (lambda (a b) (cond
	((or (greaterp a b) (eqn a b)) 1)
	(t 0) )))
(lesseq01 (lambda (a b) (cond
	((or (lessp a b) (eqn a b)) 1)
	(t 0) )))
(noteq01 (lambda (a b) (cond
	((eqn a b) 0)
	(t 1) )))
(or01 (lambda (a b) (cond
	((and (zerop a) (zerop b)) 0)
	(t 1) )))
(and01 (lambda (a b) (cond
	((or (zerop a) (zerop b)) 0)
	(t 1) )))
(= (lambda (a b)
	(binop eql01 = a b) ))
(> (lambda (a b)
	(binop gtr01 > a b) ))
(< (lambda (a b)
	(binop less01 < a b) ))
(>= (lambda (a b)
	(binop gtreq01 >= a b) ))
(<= (lambda (a b)
	(binop lesseq01 <= a b) ))
(!= (lambda (a b)
	(binop noteq01 != a b) ))
(| (lambda (a b)
	(binop or01 | a b) ))
(& (lambda (a b)
	(binop and01 & a b) ))
(red+ (lambda (a)
	(reduce + a 0) ))
(red- (lambda (a)
	(reduce - a 0) ))
(red* (lambda (a)
	(reduce * a 1) ))
(red/ (lambda (a)
	(reduce / a 1) ))
(red% (lambda (a)
	(reduce % a 1e10) ))
(FIRST (lambda (a) (cond
	((atom a) a)
	(t (FIRST (car a))) )))
(red= (lambda (a)
	(reduce = a (FIRST a)) ))
(red> (lambda (a)
	(reduce > a -1e30) ))
(red< (lambda (a)
	(reduce < a 1e30) ))
(red>= (lambda (a)
	(reduce >= a -1e30) ))
(red<= (lambda (a)
	(reduce <= a 1e30) ))
(red| (lambda (a)
	(reduce | a 0) ))
(red& (lambda (a)
	(reduce & a 1) ))
(redlo (lambda (a)
	(reduce lo a 1e30) ))
(redhi (lambda (a)
	(reduce hi a 1e-30) ))
(ELEM01 (lambda (a b) (cond
	((null b) 0)
	((atom b) (eql01 a b))
	((eqn (ELEM01 a (car b)) 1) 1)
	(t (ELEM01 a (cdr b))) )))
(elem (lambda (a b) (cond
	((null a) nil)
	((atom a) (ELEM01 a b))
	(t (cons (elem (car a) b) (elem (cdr a) b))) )))
(unop (lambda (atomop op a) (cond
	((null a) nil)
	((atom a) (atomop a))
	(t (cons (op (car a)) (unop atomop op (cdr a)))) )))
(SIGNUM (lambda (a) (cond
	((zerop a) 0)
	((minusp a) -1)
	(t 1) )))
(:+ (lambda (a)
	(copy a) ))
(:- (lambda (a)
	(unop minus :- a) ))
(:* (lambda (a)
	(unop SIGNUM :* a) ))
(:/ (lambda (a)
	(unop recip :/ a) ))
(floor (lambda (a)
	(unop entier floor a) ))
(CEILING (lambda (a) (cond
	((eqn (entier a) a) a)
	(t (plus 1 (entier a))) )))
(ceil (lambda (a)
	(unop CEILING ceil a) ))
(ABS (lambda (a) (cond
	((minusp a) (minus a))
	(t a) )))
(abs (lambda (a)
	(unop ABS abs a) ))
(FACT (lambda (a)
	(DOFACT a 1) ))
(DOFACT (lambda (a f) (cond
	((lessp a 1) f)
	(t (DOFACT (sub1 a) (times a f))) )))
(fact (lambda (a)
	(unop FACT fact a) ))
(~ (lambda (a)
	(unop '(lambda (a) (eql01 a 0)) ~ a) ))
(compr (lambda (l vec) (cond
	((null l) nil)
	((numberp l) (cond
	    ((zerop l) nil)
	    (t vec) ))
	((atom vec) (cond
	    ((zerop (car l)) (compr (cdr l) vec))
	    (t (cons vec (compr (cdr l) vec))) ))
	((zerop (car l)) (compr (cdr l) (cdr vec)))
	(t (cons (car vec) (compr (cdr l) (cdr vec)))) )))
(expd (lambda (v1 v2) (cond
	((null v1) nil)
	(t (cond
	    ((zerop (car v1)) (cons 0 (expd (cdr v1) v2)))
	    (t (cond
		((atom v2) (cons v2 (expd (cdr v1) v2)))
		(t (cons (car v2) (expd (cdr v1) (cdr v2)))) )) )) )))
([ (lambda (n l) (cond
	((null n) nil)
	((atom n) (nth n l))
	(t (cons (nth (car n) l) ([ (cdr n) l))) )))
(nth (lambda (n l) (cond
	((lessp n 2) (car l))
	(t (nth (sub1 n) (cdr l))) )))
(:rho (lambda (l) (cond
	((null l) (list 0))
	((atom l) nil)
	((atom (car l)) (list (do:rho l 0)))
	(t (cons (do:rho l 0) (:rho (car l)))) )))
(do:rho (lambda (l n) (cond
	((null l) n)
	(t (do:rho (cdr l) (add1 n))) )))
(RE (lambda (a b) (cond
	((atom b) (RE a (list b)))
	((atom a) (cons a b))
	(t (nconc a b)) )))
(, (lambda (a)
	(RAVEL (copy a)) ))
(RAVEL (lambda (a) (cond
	((null a) nil)
	((atom a) (list a))
	((null (cdr a)) (RAVEL (car a)))
	(t (RE (RAVEL (car a)) (RAVEL (cdr a)))) )))
(FLATTEN (lambda (l) (progn
	(setq CIRCLIST (, l))
	(setq CIRCLIST (nconc CIRCLIST CIRCLIST)) )))
(next (lambda () (progn
	(setq TEMP (car CIRCLIST))
	(setq CIRCLIST (cdr CIRCLIST))
	TEMP )))
(rho (lambda (dim l) (progn
	(FLATTEN l)
	(cond
	    ((atom dim) (RESHAPE (list dim)))
	    (t (RESHAPE dim))) )))
(RESHAPE (lambda (dim) (cond
	((null dim) (next))
	(t (dorho (car dim) (cdr dim))) )))
(dorho (lambda (m n) (cond
	((zerop m) nil)
	(t (cons (RESHAPE n) (dorho (sub1 m) n))) )))
(conc (lambda (a b) (cond
	((null b) a)
	((atom a) (cond
	    ((atom b) (list a b))
	    (t (cons a b)) ))
	((atom (car a)) (cond
	    ((atom b) (nconc (copy a) (list b)))
	    (t (nconc (copy a) (copy b))) ))
	(t (cons (conc (car a) (car b)) (conc (cdr a) (cdr b)))) )))
(drop (lambda (n l) (cond
	((zerop n) l)
	(t (drop (sub1 n) (cdr l))) )))
(branch (lambda (e n) (cond
	((null (setq STEMP (eval e))) (add1 n))
	((atom STEMP) STEMP)
	(t (car STEMP)) )))
(STAT (lambda (p n) (cond
	((null p) 0)
	((eqn n (caar p)) (cond
			    ((eq (caadar p) 'go) (branch (car (cdadar p)) n))
			    (t (eval (cadar p))
			       (add1 n) ) ))
	(t (STAT (cdr p) n)) )))
(run (lambda (p)
	(RUN p 1) ))
(RUN (lambda (p n) (cond
	((zerop (setq n (STAT p n))) 'Done)
	(t (RUN p n)) )))
(PRINT (lambda (a)
	(PR a (difference (car (:rho (:rho a))) 2)) ))
(PR (lambda (a n) (progn
	(cond
	    ((null a) nil)
	    ((atom a) (print a))
	    ((atom (car a)) (PRVEC a))
	    ((atom (caar a))
		(PRVEC (car a))
		(PR (cdr a) n) )
	    (t  (PR (car a) (sub1 n))
		(cond
		    ((not (null (cdr a)))
			(PRNL n)
			(PR (cdr a) n)) ) ) )
	nil )))
(PRVEC (lambda (a) (cond
	((null a) (terpri))
	((numberp (car a)) (PRNUMVEC a))
	(t  (princ (car a))
	    (PRVEC (cdr a)) ) )))
(PRNUMVEC (lambda (a) (cond
	((null a) (terpri))
	(t  (princ (car a))
	    (princ blank)
	    (PRNUMVEC (cdr a)) ) )))
(PRNL (lambda (n) (cond
	((lessp n 1) nil)
	((onep n) (terpri))
	(t  (terpri)
	    (PRNL (sub1 n)) ) )))
(READ (lambda() (progn
	(princ '[]:)
	(read) )))
(apl (lambda () (progn
	(PRINT (eval (read)))
	(apl) )))
))
(setq A '((2 3 4) (5 6 7) (8 9 10)))
(setq B '((9 4 2) (1 7 4) (4 4 4)))
(setq V '(2 4 3 7 8 26 1))
(setq L '(0 1 1 0 0 1  0))
'APL
)
