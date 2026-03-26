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


;; completion UI
(use-package corfu
  :init
  (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 1))

;; extra completion sources
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; eglot (LSP)
(use-package eglot
  :hook ((python-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (zig-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (asm-mode . eglot-ensure)
         (sh-mode . eglot-ensure)))
(use-package rust-mode)
(use-package zig-mode)
(use-package nasm-mode) ;; better than asm-mode for x86

(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))
(setq python-shell-interpreter "python")
(setq eglot-autoshutdown t) ;; auto shutdown lsp when buffer closes

(use-package which-key
  :ensure t
  :init
  (which-key-mode)
  :config
  ;; optional: make it show faster
  (setq which-key-idle-delay 0.3))

;; lets exist at more than one place at once!
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))
