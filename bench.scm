(add-load-path "." :relative #t)
(load "sort")

(use srfi-1)
(use srfi-27)
(use srfi-42)

(define-syntax bench
  (syntax-rules ()
    ((_ v)
     (let* ((v* v)
            (l1 (list-copy v*))
            (l2 (list-copy v*)))
       (print 'v)
       (print
        (equal? (time (stable-sort! l1 <))
                (time (list-stable-sort! l2 <))))))))

(define (main args)
  (let* ((n (if (null? (cdr args))
                40000
                (string->number (cadr args))))
         (sorted (iota n))
         (rev-sorted (reverse sorted))
         (nearly-sorted (list-ec (: i n)
                                 (if (zero? (random-integer 1000))
                                     (random-integer (greatest-fixnum))
                                     i)))
         (nearly-sorted-2 (concatenate
                           (list-tabulate 4 (^_ (iota (quotient n 4))))))
         (random-list (list-ec (: i n)
                               (random-integer (greatest-fixnum)))))
    (bench sorted)
    (bench rev-sorted)
    (bench nearly-sorted)
    (bench nearly-sorted-2)
    (bench random-list)
    ))
