;; auto-generated stuf
(setq custom-file "~/.emacs.custom")

;; UI-tweaks
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode -1)
(column-number-mode)
(global-display-line-numbers-mode)

;; Packaging 
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; lets be evil
(use-package evil
  :init
  (setq evil-want-C-u-scroll t
        evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; evil status line
(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Avy
(use-package avy
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)))

;; Expand region
(use-package expand-region
  :bind (("C-=" . er/expand-region)))

;; theme
(use-package gruber-darker-theme
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'gruber-darker t))

;; theme tweaks
(set-face-attribute 'default nil
                    :font "JetBrains Mono"
                    :height 110)
(set-face-attribute 'font-lock-keyword-face nil
                    :weight 'bold)
(set-face-attribute 'font-lock-function-name-face nil
                    :foreground "#ffd700")
(global-hl-line-mode 1)
(set-face-background 'hl-line "#2a2a2a")


(set-face-attribute 'mode-line nil
                    :background "#1c1c1c"
                    :foreground "#e4e4ef"
                    :box nil)

(set-face-attribute 'mode-line-inactive nil
                    :background "#101010"
                    :foreground "#5a5a5a"
                    :box nil)
(show-paren-mode 1)

(set-face-attribute 'show-paren-match nil
                    :foreground "#f4a020"
                    :background "#2a2a2a"
                    :weight 'bold)
