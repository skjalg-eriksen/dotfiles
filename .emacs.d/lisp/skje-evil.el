;;; skje-evil.el --- evil configuration -*- lexical-binding: t -*-

(use-package evil
  :init
  (setq evil-want-C-u-scroll t
        evil-want-keybinding nil
	evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-commentary
  :after evil
  :hook (prog-mode . evil-commentary-mode)  :config
  (evil-commentary-mode))

(use-package evil-mc
  :after evil
  :config
  (global-evil-mc-mode 1))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "U") 'evil-redo))

;; multi cursor setup
(with-eval-after-load 'evil-mc
  ;; like C-> (next match)
  (define-key evil-normal-state-map (kbd "C->") 'evil-mc-make-and-goto-next-match)
  
  ;; like C-< (prev match)
  (define-key evil-normal-state-map (kbd "C-<") 'evil-mc-make-and-goto-prev-match)

  ;; like mark all
  (define-key evil-normal-state-map (kbd "C-c C-<") 'evil-mc-make-all-cursors)

  ;; edit lines (closest equivalent)
  (define-key evil-visual-state-map (kbd "C-S-c C-S-c") 'evil-mc-make-cursor-in-visual-selection-beg)
)

(provide 'skje-evil)
