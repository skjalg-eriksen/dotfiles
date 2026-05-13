;;; skje-tools.el --- tool plugins -*- lexical-binding: t; -*-

;; emacs git integration
(use-package magit
  :bind (("C-x g" . magit-status)))

;; preview keybinds
(use-package which-key
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.3))

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :hook (markdown-mode . visual-line-mode))

;; view devdocs
(use-package devdocs
  :bind (("C-c d d" . devdocs-lookup)
         ("C-c d i" . devdocs-install)
         ("C-c d u" . devdocs-update-all)
         ("C-c d s" . devdocs-search)))

(provide 'skje-tools)
