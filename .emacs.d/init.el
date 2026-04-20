;; Custom file — keep auto-generated settings separate
(setq custom-file "~/.emacs.custom")

;; Core UI settings (not in early-init)
(column-number-mode)
(global-display-line-numbers-mode)

;; Package archives
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Load config modules
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'theme)
(require 'modal-editing)
(require 'editing)
(require 'completion)
(require 'lang-eglot)
(require 'tools)
(require 'buffers)
