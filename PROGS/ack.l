(define '(
(ack (lambda (x y) (cond
	((zerop x) (add1 y))
	((zerop y) (ack (sub1 x) 1))
	(t (ack (sub1 x) (ack x (sub1 y)))) ))) ))
