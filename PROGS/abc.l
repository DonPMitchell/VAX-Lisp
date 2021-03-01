(define '(
(search (lambda (state) (BEST (generate state 'x) (list -1000) (list 1000) 0)))
(BEST (lambda (states alpha beta level) (cond
	((null states) alpha)
	((greateq (setq T (pos WORST (car states) alpha beta level)) beta) beta)
	(t (BEST (cdr states) (better alpha T) beta level)) )))
(WORST (lambda (states alpha beta level) (cond
	((null states) beta)
	((lesseq (setq T (pos BEST (car states) alpha beta level)) alpha) alpha)
	(t (WORST (cdr states) alpha (worse beta T) level)) )))
(pos (lambda (select state alpha beta level) (cond
	((terminal state level) (better alpha (worse beta state)))
	(t (select (generate state (cond ((equal select WORST) 'o) (t 'x))) alpha beta (add1 level))) )))
(lesseq (lambda (a b) (not (greaterp a b))))
(greateq (lambda (a b) (not (lessp a b))))
(better (lambda (a b) (cond
	((greaterp (car a) (car b)) a)
	(t b) )))
(worse (lambda (a b) (cond
	((lessp (car a) (car b)) a)
	(t b) )))
))
(setq printss ())
(define '(
(init (lambda () (setq bord
	(cook (list (list blank blank blank) (list blank blank blank) (list blank blank blank)))
	)))
(generate (lambda (l c) (gen2 l 1 1 c)))
(gen2 (lambda (l n m c) (cond
	((eqn m 4) nil)
	((eqn n 4) (gen2 l 1 (add1 m) c))
	((legal (cdr l) n m) (merge greaterp (genmove l n m c) (gen2 l (add1 n) m c)))
	(t (gen2 l (add1 n) m c)) )))
(genmove (lambda (l n m c) (cook (insert (cdr l) c n m))))
(cook (lambda (raw) (cons (apply plus (nvalue raw)) raw)))
(merge (lambda (pred state states) (cond
	((null states) (cons state nil))
	((pred (car state) (caar states)) (cons state states))
	(t (cons (car states) (merge pred state (cdr states)))) )))
(legal (lambda (l n m) (cond
	((onep n) (legal2 (car l) m))
	(t (legal (cdr l) (sub1 n) m)) )))
(legal2 (lambda (l m) (cond
	((onep m) (eq (car l) blank))
	(t (legal2 (cdr l) (sub1 m))) )))
(terminal (lambda (l level) (cond
((progn (setq l (cdr l)) nil) nil)
	((equal (nvalue l) '(0 0 0 0 0 0 0 0)) 'DRAW)
	((member 100 (nvalue l)) 'WIN)
	((member -100 (nvalue l)) 'LOSS)
	((greateq level DEPTH) 'TRIMED)
	(t nil) )))
(nvalue (lambda (l) (list
	(rvalue (car l))
	(rvalue (cadr l))
	(rvalue (caddr l))
	(rvalue (mapcar car l))
	(rvalue (mapcar cadr l))
	(rvalue (mapcar caddr l))
	(rvalue (list (car (car l)) (cadr (cadr l)) (caddr (caddr l))))
	(rvalue (list (caddr (car l)) (cadr (cadr l)) (car (caddr l)))) )))
(rvalue (lambda (l) (cond
	((equal l '(x x x)) 100)
	((equal l '(o o o)) -100)
	((memq 'x l) (cond
		((memq 'o l) 0)
		((eqn (count 'x l) 2) 10)
		(t 1) ))
	((memq 'o l) (cond
		((eqn (count 'o l) 2) -10)
		(t -1) ))
	(t 1) )))
(count (lambda (c l) (cond
	((null l) 0)
	((eq c (car l)) (add1 (count c (cdr l))))
	(t (count c (cdr l))) )))
(insert (lambda (l c n m) (insert1 l c n m 1 1)))
(insert1 (lambda (l c n m N M) (cond
	((atom l) l)
	((eqn n N) (cons (insert2 (car l) c m M) (cdr l)))
	(t (cons (car l)
		(insert1 (cdr l) c n m (add1 N) M) )) )))
(insert2 (lambda (l c m M) (cond
	((atom l) l)
	((eqn m M) (cons c (cdr l)))
	(t (cons (car l) (insert2 (cdr l) c m (add1 M)))) )))
(play (lambda () (progn
	(mapc print bord)
	(setq bord (genmove bord (read) (read) 'x))
	(setq bord (last (generate bord 'o)))
	(play) )))
))
