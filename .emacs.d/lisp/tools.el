(use-package magit
  :bind (("C-x g" . magit-status)))

(use-package treemacs
  :bind (("C-x t t" . treemacs)
         ("C-x t 1" . treemacs-select-window)))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package which-key
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.3))

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :hook (markdown-mode . visual-line-mode))

(use-package devdocs
  :bind (("C-c d d" . devdocs-lookup)
         ("C-c d i" . devdocs-install)
         ("C-c d u" . devdocs-update-all)
         ("C-c d s" . devdocs-search)))

(provide 'tools)
