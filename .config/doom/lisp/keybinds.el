;; $DOOMDIR/lisp/keybinds.el -*- lexical-binding: t; -*-

;; Prefix rules for keybindings:
;; - "s-"   (Super) works only in GUI Emacs; terminals don't send Super.
;; - "C-"   cannot be used with "[" because C-[ = ESC in all terminals.
;; - "M-"   also cannot reliably be used with "[" because ESC-[ starts
;;          arrow-key escape sequences (ESC-[A, ESC-[B, etc).
(defvar my/leader-key "C-"  ; change to "C-" or "M-" for TTY if needed
  "Modifier prefix used for my custom directional keybinds.")

(global-unset-key (kbd "C-b"))  ;; reserve for tmux

;; Helper to build key strings like: "s-]" or "C-]"
(defun my/k (key)
  "Return a full keybind string using `my/leader-key` as prefix."
  (kbd (concat my/leader-key key)))

(map!
 ;; ---- Commenting
 :n (my/k "/") #'comment-line
 :v (my/k "/") #'comment-line

 ;; ---- Tabs, rebinding ] b and [ b
 :n "] b" #'centaur-tabs-forward
 :n "[ b" #'centaur-tabs-backward
 )

(after! evil
  ;; NORMAL MODE
  (define-key evil-normal-state-map (kbd "H") #'evil-first-non-blank)
  (define-key evil-normal-state-map (kbd "L") #'evil-end-of-line)
  (define-key evil-normal-state-map (kbd "U") #'evil-redo)

  ;; VISUAL MODE
  (define-key evil-visual-state-map (kbd "H") #'evil-first-non-blank)
  (define-key evil-visual-state-map (kbd "L") #'evil-end-of-line)
  (define-key evil-visual-state-map (kbd "U") #'evil-redo)

  ;; INSERT MODE

  )
