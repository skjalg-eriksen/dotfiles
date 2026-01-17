;;; $DOOMDIR/lisp/colors.el -*- lexical-binding: t; -*-

;; (setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-vibrant)
;; (setq doom-theme 'doom-tomorrow-night)
;; (setq doom-theme 'challanger-deep)
;; (setq doom-theme 'doom-zenburn)
;; (setq doom-theme 'doom-ayu-mirage)
;; (setq doom-theme 'doom-spacegrey)

;; (unless (display-graphic-p)
;;   (set-face-attribute 'default nil :background "unspecified-bg"))

;; (add-hook 'after-init-hook
;;           (lambda ()
;;             (unless (display-graphic-p)
;;               (set-face-attribute 'default nil :background "unspecified-bg"))))

;; (set-face-background 'default "undefined")
;; (set-face-attribute 'default nil :background "unspecified-bg")

(setq doom-theme 'catppuccin)

(set-frame-parameter nil 'alpha-background 80)
(add-to-list 'default-frame-alist '(alpha-background . 80))
