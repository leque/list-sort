(use srfi-11)

(define (default-less? x y)
  (< (compare x y) 0))

(define (list-stable-sort! lis :optional (less? default-less?))
  (define (step! n)
    (case n
      ((1)
       (let ((res lis))
         (set! lis (cdr lis))
         (set-cdr! res '())
         (values res res)))
      ((2)
       (let ((res lis)
             (a (car lis))
             (b (cadr lis)))
         (when (less? b a)
           (set-car! lis b)
           (set-car! (cdr lis) a))
         (set! lis (cddr lis))
         (set-cdr! (cdr res) '())
         (values res (cdr res))))
      (else
       (let*-values ([(i) (ash n -1)]
                     [(xs xl) (step! i)]
                     [(j) (- n i)]
                     [(ys yl) (step! j)])
         (fast-merge! xs xl ys yl)))))
  ;; xs = (x0 ... . xs-last) or xs = (), xs-last = #f
  ;; ys = (y0 ... . ys-last) or ys = (), ys-last = #f
  (define (fast-merge! xs xs-last ys ys-last)
    (cond ((null? xs)
           (values ys ys-last))
          ((null? ys)
           (values xs xs-last))
          ((less? (car xs-last) (car ys))
           (set-cdr! xs-last ys)
           (values xs ys-last))
          ((less? (car ys-last) (car xs))
           (set-cdr! ys-last xs)
           (values ys xs-last))
          (else
           (merge! xs xs-last ys ys-last))))
  (define (merge! xs xs-last ys ys-last)
    (if (less? (car ys) (car xs))
        (%merge! ys xs xs-last (cdr ys) ys-last)
        (%merge! xs (cdr xs) xs-last ys ys-last)))
  (define (%merge! head xs xs-last ys ys-last)
    (let loop ((tl head)
               (xs xs)
               (ys ys))
      (cond ((null? xs)
             (set-cdr! tl ys)
             (values head ys-last))
            ((null? ys)
             (set-cdr! tl xs)
             (values head xs-last))
            ((less? (car ys) (car xs))
             (set-cdr! tl ys)
             (loop ys xs (cdr ys)))
            (else
             (set-cdr! tl xs)
             (loop xs (cdr xs) ys)))))
  (if (null? lis)
      '()
      (values-ref (step! (length lis)) 0)))
