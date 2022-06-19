(define-module lang.japan.era
  (use srfi-19)
  (use util.match)
  (use lang.japan.era-constants)
  (export
   date->locale-era date->japan-era!
   time->locale-era time->japan-era!
   time->era time->era!
   date->era* current-era date->era))
(select-module lang.japan.era)

;; # Parameter
;; Restore back locale as a string. This value used after forcibly change by `sys-setlocale` .
;; NOTE and FIXME: `sys-setlocale` seems have no restorable interface.
;;  empty string let default settings. `man setlocale(3)`
(define source-locale-ja
  (make-parameter ""))

;;;
;;; Internal
;;;

(autoload gauche.unicode string->utf8)
(autoload gauche.uvector u8vector-length)

;; Just check not ascii.
(define (string-japanese? s)
  (and-let* ([(string? s)]
             ;; FIXME: should improve to more elegant way
             [bytes (u8vector-length (string->utf8 s))]
             [len (string-length s)]
             [(not (= bytes len))])
    #t))

(define (date->sys-tm date)
  ($ sys-localtime
     $ floor->exact
     $ time->seconds
     $ date->time-utc date))

;;;
;;; API
;;;

;;
;; Low level api
;;

;; Return Era and Year. If not supported Era since too old return #f and #f
;; `:fallback-locale?`: If the DATE is the newest era then fallback to use `sys-strftime`
;; `:try-fallback-locale?`: Same as `:fallback-locale?` but re fallback to this module if failed. (Default)
;; `:force-japan-locale?`: Same as `:fallback-locale?` except forcibly `setlocale` to get era.
(define (date->era* date :key (try-fallback-locale? #t) (fallback-locale? #f) (force-japan-locale? #f))
  (define (yyyyMMdd d)
    (date->string d "~Y~m~d"))

  (define (yyyyMMdd->date s)
    (string->date s "~Y~m~d"))

  (define (compute-year date start)
    (let* ([d0 (yyyyMMdd->date start)]
           [y0 (date-year d0)])
      (+ (- (date-year date) y0) 1)))

  (let ([datestr (yyyyMMdd date)])
    (let loop ([eras *japanese-eras*]
               [i 0])
      (match eras
        [()
         (values #f #f)]
        [((start name . _)  . rest)
         (cond
          [(not (string<=? start datestr))
           (loop rest (+ i 1))]
          [(and (= i 0)
                (or force-japan-locale?
                    fallback-locale?
                    try-fallback-locale?))
           (cond
            [force-japan-locale?
             (date->japan-era! date)]
            [fallback-locale?
             (date->locale-era date)]
            [try-fallback-locale?
             (guard (e [else
                        (set! try-fallback-locale? #f)
                        (loop eras i)])
               (date->locale-era date))])]
          [else
           (values name (compute-year date start))])]))))

(define (current-era :optional (now (current-date)))
  (date->era now))

;; Wrapper `date->era*`
(define (date->era date)
  (date->era* date))

;; Wrapper `date->era*`
(define (date->era! date)
  (date->era* date :force-japan-locale? #t))

;; DATE -> ERA, ERA-YEAR
(define (date->locale-era date)
  (let1 tm (date->sys-tm date)
    (match ($ (cut string-split <> " ") $ sys-strftime "%EC %Ey" tm)
      [(era-string year-string)
       (unless (string-japanese? era-string)
         (error "Failed generate Japan era ~a" era-string))
       (values era-string (string->number year-string))])))

;; Forcibly change locale via `setlocale` be careful to use in i18n environment.
(define (date->japan-era! date)
  (let* ([ja-locale "ja_JP.utf8"]
         [new-locale (sys-setlocale LC_TIME ja-locale)])
    (unless (equal? ja-locale new-locale)
      (error "Failed to set new locale" ja-locale))
    (unwind-protect
     (date->locale-era date)
     (sys-setlocale LC_TIME (source-locale-ja)))))

;;
;; Utility for <time>
;;

;; Wrapper `date->era`
(define (time->era time)
  ($ date->era $ time-utc->date time))

;; Wrapper `date->era!`
(define (time->era! time)
  ($ date->era! $ time-utc->date time))

(define (time->japan-era! date)
  ($ date->japan-era! $ time-utc->date time))

(define (time->locale-era time)
  ($ date->locale-era $ time-utc->date time))
