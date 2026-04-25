;; Install themes
(use-package gruber-darker-theme)
(use-package catppuccin-theme)

;; Font
(set-face-attribute 'default nil
                    :font "JetBrains Mono"
                    :height 110)

;; Modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Helper: disable all themes
(defun my/disable-all-themes ()
  (interactive)
  (mapc #'disable-theme custom-enabled-themes))

;; Theme switchers
(defun my/theme-gruber ()
  (interactive)
  (my/disable-all-themes)
  (load-theme 'gruber-darker t))

(defun my/theme-catppuccin ()
  (interactive)
  (my/disable-all-themes)
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin :no-confirm))

(defun my/theme-none ()
  (interactive)
  (my/disable-all-themes))

;; keybindings (quick toggle)
(global-set-key (kbd "<f5>") #'my/theme-gruber)
(global-set-key (kbd "<f6>") #'my/theme-catppuccin)
(global-set-key (kbd "<f7>") #'my/theme-none)

;; default theme
(my/theme-catppuccin)

(provide 'skje-theme)
