;; $DOOMDIR/lisp/keybinds.el -*- lexical-binding: t; -*-
;; remove global C-b binding as it's used for tmux
(global-unset-key (kbd "C-b"))

(map! :m "s-]" #'evil-shift-right
      :m "s-[" #'evil-shift-left

      :v "s-]" #'my/evil-shift-right-keep-visual
      :v "s-[" #'my/evil-shift-left-keep-visual

      :i "s-]" #'evil-shift-right
      :i "s-[" #'evil-shift-left

      :n "s-/" #'comment-line
      :v "s-/" #'comment-line

      ;; rebind from todo to tabs
      ;; :n "] t" #'centaur-tabs-forward
      ;; :n "[ t" #'centaur-tabs-backward

      ;; rebind from buffer to tabs
      :n "] b" #'centaur-tabs-forward
      :n "[ b" #'centaur-tabs-backward
      )


(after! evil
  ;; Move to first non-blank (like ^) and last non-blank (like $) with H/L in Evil
  (define-key evil-normal-state-map (kbd "H") #'evil-first-non-blank)
  (define-key evil-visual-state-map  (kbd "H") #'evil-first-non-blank)
  (define-key evil-operator-state-map (kbd "H") #'evil-first-non-blank)

  (define-key evil-normal-state-map (kbd "L") #'evil-end-of-line)
  (define-key evil-visual-state-map  (kbd "L") #'evil-end-of-line)
  (define-key evil-operator-state-map (kbd "L") #'evil-end-of-line)
  )


(defun my/evil-shift-right-keep-visual ()
  "Indent right and reselect visual region."
  (interactive)
  (evil-shift-right (region-beginning) (region-end))
  (evil-normal-state)
  (evil-visual-restore))

(defun my/evil-shift-left-keep-visual ()
  "Indent left and reselect visual region."
  (interactive)
  (evil-shift-left (region-beginning) (region-end))
  (evil-normal-state)
  (evil-visual-restore))
