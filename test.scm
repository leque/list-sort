(add-load-path "." :relative #t)
(load "sort")

(use gauche.test)


(define (list-sorted? xs less?)
  (or (null? xs)
      (null? (cdr xs))
      (and (not (less? (cadr xs)
                       (car xs)))
           (list-sorted? (cdr xs) less?))))

(define (test-sort expected xs)
  (let ((v (list-copy xs)))
    (test* (x->string xs) expected (list-stable-sort! v))))

(test-start "sort")

(test-sort '() '())
(test-sort '(1) '(1))
(test-sort '(1 2) '(1 2))
(test-sort '(1 2) '(2 1))
(test-sort '(1 2 3) '(1 2 3))
(test-sort '(1 2 3) '(1 3 2))
(test-sort '(1 2 3) '(2 1 3))
(test-sort '(1 2 3) '(2 3 1))
(test-sort '(1 2 3) '(3 1 2))
(test-sort '(1 2 3) '(3 2 1))

(use srfi-1)
(use srfi-27)

(dotimes (n 10)
  (let ((i (+ n 4)))
    (test* (format "sorted? - length = ~A" i)
           #t
           (list-sorted?
            (list-stable-sort!
             (list-tabulate i (^_ (random-integer
                                   (ceiling->exact (/ i 2)))))
             <)
            <))))

(dotimes (i 10)
  (let* ((i (+ i 10))
         (n (ceiling->exact (/ i 3))))
    (test* (format "stable? - length = ~A" i)
           #t
           (list-sorted?
            (list-stable-sort!
             (map cons
                  (list-tabulate i (^_ (random-integer n)))
                  (iota i))
             (lambda (a b)
               (< (car a) (car b))))
            (lambda (a b)
              (or (< (car a) (car b))
                  (and (eqv? (car a) (car b))
                       (< (cdr a) (cdr b)))))))))

(test-end)
