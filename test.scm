;;;
;;; Test gauche_lang_japan_era
;;;

(use gauche.test)
(use srfi-19)

(test-start "lang.japan.era")
(use lang.japan.era)
(test-module 'lang.japan.era)

(define (->date s)
  (define (try fmt)
    (guard (e [else #f])
      (string->date s fmt)))

  (or (try "~Y-~m-~d ~H:~M:~S~z")
      (try "~Y-~m-~d")
      ))

(define (test-values title vals proc)
  (test title vals
        (^[] (call-with-values proc list))))

(test-values "" (list "令和" 1)  (^[] (date->era (->date "2019-05-01"))))
(test-values "" (list "平成" 31) (^[] (date->era (->date "2019-04-30"))))
(test-values "" (list "明治" 1)  (^[] (date->era (->date "1868-01-25"))))
(test-values "" (list "慶応" 4)  (^[] (date->era (->date "1868-01-24"))))
(test-values "" (list "応永" 1)  (^[] (date->era (->date "1394-02-09"))))
(test-values "" (list #f #f)     (^[] (date->era (->date "1394-02-08"))))
(test-values "" (list "令和" 1)  (^[] (date->japan-era!  (->date "2019-05-01"))))
(test-values "" (list "令和" 1) (^[] (date->japan-era! (->date "2019-05-01 00:00:00+0900"))))
(test-values "" (list "平成" 31) (^[] (date->japan-era! (->date "2019-04-30 23:59:59+0900"))))
(test-values "" (list "平成" 31) (^[] (date->japan-era! (->date "2019-04-30"))))
(test-values "" (list "昭和" 45) (^[] (date->japan-era! (->date "1970-01-01 09:00:00+0900"))))

(test* "just test pass" #t (boolean (date->japan-era! (current-date))))
(test* "" (test-error) (date->japan-era! (->date "1970-01-01 08:59:59+0900")))
(test* "" (test-error) (date->japan-era! (->date "1868-01-25")))
(test* "" (test-error) (date->japan-era! (->date "1868-01-24")))

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
