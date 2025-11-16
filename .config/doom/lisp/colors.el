;;; $DOOMDIR/lisp/colors.el -*- lexical-binding: t; -*-

;; (setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-vibrant)
;; (setq doom-theme 'doom-tomorrow-night)
;; (setq doom-theme 'challanger-deep)
;; (setq doom-theme 'doom-zenburn)
;; (setq doom-theme 'doom-ayu-mirage)
(setq doom-theme 'doom-spacegrey)


(add-hook 'after-make-frame-functions
          (lambda (frame)
            (when (not (display-graphic-p frame))
              (with-selected-frame frame
                (set-face-attribute 'default nil :background "unspecified-bg")))))
