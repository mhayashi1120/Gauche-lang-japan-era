;;;
;;; Test gauche_l10n_japan_era
;;;

(use gauche.test)

(test-start "gauche_l10n_japan_era")
(use gauche_l10n_japan_era)
(test-module 'gauche_l10n_japan_era)

;; The following is a dummy test code.
;; Replace it for your tests.
(test* "test-gauche_l10n_japan_era" "gauche_l10n_japan_era is working"
       (test-gauche_l10n_japan_era))

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
