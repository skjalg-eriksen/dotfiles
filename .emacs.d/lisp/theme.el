(use-package gruber-darker-theme
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'gruber-darker t))

(set-face-attribute 'default nil
                    :font "JetBrains Mono"
                    :height 110)

(use-package doom-modeline
  :init (doom-modeline-mode 1))

(provide 'theme)
