(define false (cond))

  (define (string? x)
    (;foo
     cond ((null? x) 't)
          ((char? x) false)
          ((char? (car x)) (string? (cdr x)))
     ; hurray this is a comment
          ('t false)))

  (define (memq? x xs)
    (cond ((null? xs) false)
          ((eq? x (car xs)) 't)
          ('t (memq? x (cdr xs)))))

  (define symbols
    '((t f eof-object define quote cond
       eq? null? pair? char? cons car cdr
       set-car! read-char peek-char write-char 
       abort)))

  (define (symbol? x)
    (memq? x (car symbols)))

  (define (newline)
    (write-char \
))

  (define (write-string chars)
    (cond ((null? chars) false)
          ('t (write-char (car chars))
              (write-string (cdr chars)))))


(define (error plaint)
  (write-string plaint)
  (newline)
  (abort))          


(define definitions '(()))
(define global-vars '(()))
(define global-vals '(()))

(define (eval-form form)
  (eval form '() '()))

(define (eval e vars vals)
  (cond ((pair? e) 
	 (cond ((symbol? e) (lookup e vars vals))
	       ('t (eval-pair (car e) (cdr e) vars vals))))
	('t e)))

(define (eval-pair rator rands vars vals)
  (cond ((eq? rator 'quote) (car rands))
	((eq? rator 'cond) (evcond rands vars vals))
	('t (apply rator (evlis rands vars vals)))))

(define (evlis es vars vals)
  (cond ((null? es) '())
	('t (cons (eval (car es) vars vals)
		  (evlis (cdr es) vars vals)))))

(define (evcond clauses vars vals)
  (cond ((null? clauses) '"No matching cond clause yo")
	((eval (car (car clauses)) vars vals)
	 (evseq (cdr (car clauses)) vars vals))
	('t (evcond (cdr clauses) vars vals))))

(define (evseq es vars vals)
  (cond ((null? (cdr es)) (eval (car es) vars vals))
	('t (eval (car es) vars vals)
	    (evseq (cdr es) vars vals))))

(define (lookup var vars vals)
  (cond ((null? vars) (lookup1 var (car global-vars) (car global-vals)))
	((eq? var (car vars)) (car vals))
	('t (lookup var (cdr vars) (cdr vals)))))

(define (lookup1 var vars vals)
  (cond ((null? vars) (error '"Unbound variable yo"))
	((eq? var (car vars)) (car vals))
	('t (lookup1 var (cdr vars) (cdr vals)))))

(define (apply rator args)
  (cond ((eq? rator 'eq?)          (eq? (car args) (car (cdr args))))
	((eq? rator 'null?)        (null? (car args)))
	((eq? rator 'pair?)        (pair? (car args)))
	((eq? rator 'char?)        (char? (car args)))
	((eq? rator 'cons)         (cons (car args) (car (cdr args))))
	((eq? rator 'car)          (car (car args)))
	((eq? rator 'cdr)          (cdr (car args)))
	((eq? rator 'set-car!)     (set-car! (car args) (car (cdr args))))
	((eq? rator 'read-char)    (read-char))
	((eq? rator 'peek-char)    (peek-char))
	((eq? rator 'write-char)   (write-char (car args)))
	((eq? rator 'error)        (error (car args)))
	('t (call rator args (car definitions)))))

(define (call rator args defs)
  (cond ((null? defs) (error '"Unknown rator"))
	((eq? rator (car (car (car defs))))
	 (evseq (cdr (car defs)) (cdr (car (car defs))) args))
	('t (call rator args (cdr defs)))))


(eval-form '(write-char \a))
