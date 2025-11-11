;;; $DOOMDIR/lisp/colors.el -*- lexical-binding: t; -*-

;; (setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-vibrant)
;; (setq doom-theme 'doom-tomorrow-night)
;; (setq doom-theme 'challanger-deep)
;; (setq doom-theme 'doom-zenburn)
;; (setq doom-theme 'doom-ayu-mirage)
(setq doom-theme 'doom-spacegrey)

(defvar my/bg "#181a1f"  "My preferred dark background color.")

(custom-set-faces!
  ;; General background
  `(default :background ,my/bg)

  ;; Treemacs
  ;; `(treemacs-root-face :background ,my/bg)
  ;; `(treemacs-directory-face :background ,my/bg)
  ;; `(treemacs-file-face :background ,my/bg)
  ;; `(treemacs-git-untracked-face :background ,my/bg)
  ;; `(treemacs-directory-collapsed-face :background-mode, my/bg)
  `(treemacs-window-background-color, my/bg)

  ;; Line numbers
  ;; `(line-number :background ,my/bg :foreground "#4b5263")
  ;; `(line-number-current-line :background ,my/bg :foreground "#abb2bf")

  ;; ;; Mode line
  ;; `(mode-line :background "#20232a" :foreground "#dcdcdc")
  ;; `(mode-line-inactive :background "#1c1e24" :foreground "#7f848e")

  ;; ;; Tab bar / centaur-tabs / doom-modeline segments
  ;; `(tab-bar :background ,my/bg :foreground "#c0c5ce")
  ;; `(tab-bar-tab :background "#20232a" :foreground "#ffffff")
  ;; `(tab-bar-tab-inactive :background ,my/bg :foreground "#7f848e" :box nil)

  ;; Vertical border
  ;; `(vertical-border :foreground "#20232a")
  ;;
  )

;; (custom-set-faces
;;  '(treemacs-window-background-face ((t (:background my/bg)))))
