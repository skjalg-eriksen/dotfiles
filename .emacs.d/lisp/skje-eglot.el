;;; skje-eglot.el --- eglot setup -*- lexical-binding: t -*-

(use-package eglot
  :ensure nil
  :hook ((python-mode . eglot-ensure)
         (rust-mode   . eglot-ensure)
         (zig-mode    . eglot-ensure)
         (c-mode      . eglot-ensure)
         (c++-mode    . eglot-ensure)
         (asm-mode    . eglot-ensure)
         (sh-mode     . eglot-ensure)
	 (haskell-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t))

(use-package rust-mode)
(use-package zig-mode)
(use-package nasm-mode)
(use-package haskell-mode)

(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(setq python-shell-interpreter "python")

(provide 'skje-eglot)
