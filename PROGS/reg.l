(define '(
(longerp (lambda (a b) (cond
	((null a) nil)
	((null b) a)
	(t (longerp (cdr a) (cdr b))) )))
(cost (lambda (op) (cond
	((eq (car op) '*) 1400)
	((and (eq (car op) '$) (memq (caddr op) registers)) 400)
	((and (eq (car op) '@) (not (memq (caddr op) registers))) 800)
	(t 1000) )))
(indirect (lambda (op) (cond
	((eq (car op) '$) (cons '@ (cdr op)))
	((eq (car op) '@) (cons '* (cdr op)))
	(t (indirect (move op (allocreg)))) )))
(past (lambda (op n) (cond
	((eq (car op) '@) (cons '@ (cons (plus n (cadr op)) (cddr op))))
	(t (past (indirect (move (cons '@ (cdr op)) (allocreg))) n)) )))
(assoc (lambda (item alist) (cond
	((null alist) nil)
	((eq item (caar alist)) (cdar alist))
	(t (assoc item (cdr alist))) )))
(insert (lambda (item data alist) (cond
	((null alist) (cons (cons item data) nil))
	((eq item (caar alist)) (rplacd (car alist) data))
	(t (rplacd alist (insert item data (cdr alist)))) )))
(delete (lambda (item alist) (cond
	((null alist) nil)
	((eq item (caar alist)) (cdr alist))
	(t (rplacd alist (delete item (cdr alist)))) )))
))
