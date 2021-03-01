(progn
(setq S '(
	(s# sname status city)
	(s1 Smith 20 london)
	(s2 Jones 10 paris)
	(s3 Blake 30 paris)
	(s4 Clark 20 london)
	(s5 Adams 30 athens) ))
(setq P '(
	(p# pname color weight city)
	(p1 nut red 12 london)
	(p2 bolt green 17 paris)
	(p3 screw blue 17 rome)
	(p4 screw red 14 london)
	(p5 cam blue 12 paris)
	(p6 cog red 19 london) ))
(setq SP '(
	(s# p# qty)
	(s1 p1 300)
	(s1 p2 200)
	(s1 p3 400)
	(s1 p4 200)
	(s1 p5 100)
	(s1 p6 100)
	(s2 p1 300)
	(s2 p2 400)
	(s3 p2 200)
	(s4 p2 200)
	(s4 p4 300)
	(s4 p5 400) ))
(define '(
(sh (lambda () (progn (setq % (print (eval (read)))) (sh))))
(ssh (lambda () (progn (show (setq % (eval (read)))) (ssh))))
(project (lambda (tuples names)
	(cons names (makeset (mapcar
		'(lambda (x) (fetch names (car tuples) x))
		(cdr tuples) ))) ))
(select (lambda (tuples rule)
	(cons (car tuples) (gather (list
		'lambda
		(car tuples)
		rule) (cdr tuples))) ))
(join (lambda (r1 r2 where) (select (product r1 r2) where)))
(ejoin (lambda (r1 r2 over)
	(join r1 r2 (list 'equal (implode (list 'X over)) over))))
(in (lambda (a b) (cond
	((atom (car a)) (member a (cdr b)))
	((not (equal (car a) (car b))) nil)
	(t (subrel (cdr a) (cdr b))) )))
(subrel (lambda (a b) (cond
	((null a) t)
	((member (car a) b) (subrel (cdr a) b))
	(t nil) )))
(product (lambda (r1 r2) (cons
	(joinnames (car r1) (car r2))
	(xcart (cdr r1) (cdr r2)) )))
(joinnames (lambda (n1 n2) (cond
	((null n1) n2)
	((member (car n1) n2) (cons (implode (cons 'X (explode (car n1))))
		(joinnames (cdr n1) n2) ))
	(t (cons (car n1) (joinnames (cdr n1) n2))) )))
(xcart (lambda (r1 r2) (mapcon
	'(lambda (x) (mapcar '(lambda (y) (append x y)) r2)) r1)))
(gather (lambda (p tuples) (cond
	((null tuples) nil)
	((apply p (car tuples)) (cons (car tuples) (gather p (cdr tuples))))
	(t (gather p (cdr tuples))) )))
(mapcar (lambda (f l) (cond
	((null l) nil)
	(t (cons (f (car l)) (mapcar f (cdr l)))) )))
(mapcon (lambda (f l) (cond
	((null l) nil)
	(t (append (f (car l)) (mapcon f (cdr l)))) )))
(makeset (lambda (l) (cond
	((null l) nil)
	((member (car l) (cdr l)) (makeset (cdr l)))
	(t (cons (car l) (makeset (cdr l)))) )))
(fetch (lambda (names namlist tuple) (mapcar 
	'(lambda (x) (fetch2 x namlist tuple)) names)))
(fetch2 (lambda (name namlist tuple) (cond
	((null namlist) nil)
	((eq name (car namlist)) (car tuple))
	(t (fetch2 name (cdr namlist) (cdr tuple))) )))
(show (lambda (r) (progn (underline (showone (car r))) (showall (cdr r)))))
(showone (lambda (l) (cond
	((null l) (progn (terpri) 0))
	(t (progn (princ (car l)) (princ tab) (add1 (showone (cdr l))))) )))
(underline (lambda (n) (cond
	((zerop n) (terpri))
	(t (progn (princ '========) (underline (sub1 n)))) )))
(showall (lambda (r) (cond
	((null r) nil)
	((null (cdr r)) (showone (car r)))
	(t (progn (showone (car r)) (showall (cdr r)))) )))
))
(ssh) )
