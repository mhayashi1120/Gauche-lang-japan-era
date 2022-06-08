(define-module l10n.japan.era
  (use srfi-19)
  (use util.match)
  (export
   date->locale-era date->japan-era!
   time->locale-era time->japan-era!
   time->era time->era!
   date->era* current-era date->era))
(select-module l10n.japan.era)

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

;; 南北朝時代以降
(define-constant *japanese-eras*
  '(
    ;; START(yyyyMMdd) 名称 Initial? RomaHebon?
    ("20190501" "令和" "R" "Reiwa")
    ("19890107" "平成" "H" "Heisei")
    ("19261225" "昭和" "S" "Shouwa")
    ("19120730" "大正" "T" "Taishou")
    ("18680125" "明治" "M" "Meiji")

    ("18650127" "慶応" #f #f)
    ("18640208" "元治" #f #f)
    ("18610210" "文久" #f #f)
    ("18600123" "万延" #f #f)
    ("18540129" "安政" #f #f)
    ("18480205" "嘉永" #f #f)
    ("18440218" "弘化" #f #f)
    ("18300125" "天保" #f #f)
    ("18180205" "文政" #f #f)
    ("18040211" "文化" #f #f)
    ("18010213" "享和" #f #f)
    ("17890126" "寛政" #f #f)
    ("17810124" "天明" #f #f)
    ("17720204" "安永" #f #f)
    ("17640202" "明和" #f #f)
    ("17510127" "宝暦" #f #f)
    ("17480130" "寛延" #f #f)
    ("17440214" "延享" #f #f)
    ("17410216" "寛保" #f #f)
    ("17360212" "元文" #f #f)
    ("17160125" "享保" #f #f)
    ("17110217" "正徳" #f #f)
    ("17040205" "宝永" #f #f)
    ("16880202" "元禄" #f #f)
    ("16840215" "貞享" #f #f)
    ("16810218" "天和" #f #f)
    ("16730217" "延宝" #f #f)
    ("16610130" "寛文" #f #f)
    ("16580202" "万治" #f #f)
    ("16550206" "明暦" #f #f)
    ("16520210" "承応" #f #f)
    ("16480125" "慶安" #f #f)
    ("16440208" "正保" #f #f)
    ("16240219" "寛永" #f #f)
    ("16150129" "元和" #f #f)
    ("15960129" "慶長" #f #f)
    ("15920213" "文禄" #f #f)
    ("15730212" "天正" #f #f)
    ("15700215" "元亀" #f #f)
    ("15580130" "永禄" #f #f)
    ("15550202" "弘治" #f #f)
    ("15320216" "天文" #f #f)
    ("15280201" "享禄" #f #f)
    ("15210217" "大永" #f #f)
    ("15040127" "永正" #f #f)
    ("15010129" "文亀" #f #f)
    ("14920207" "明応" #f #f)
    ("14890210" "延徳" #f #f)
    ("14870203" "長享" #f #f)
    ("14690122" "文明" #f #f)
    ("14670214" "応仁" #f #f)
    ("14660126" "文正" #f #f)
    ("14600202" "寛正" #f #f)
    ("14570204" "長禄" #f #f)
    ("14550127" "康正" #f #f)
    ("14520131" "享徳" #f #f)
    ("14490202" "宝徳" #f #f)
    ("14440129" "文安" #f #f)
    ("14410201" "嘉吉" #f #f)
    ("14290213" "永享" #f #f)
    ("14280126" "正長" #f #f)
    ("13940209" "応永" #f #f)
    ))

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
