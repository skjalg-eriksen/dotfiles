;;; skje-ibuffer.el --- buffer management -*- lexical-binding: t; -*-

(use-package ibuffer
  :ensure nil
  :hook (ibuffer-mode . ibuffer-auto-mode)
  :config
  (setq ibuffer-expert t
        ibuffer-show-empty-filter-groups nil
        ibuffer-saved-filter-groups
        '(("default"
           ("code" (derived-mode . prog-mode))
           ("org" (mode . org-mode))
           ("dired" (mode . dired-mode))
           ("emacs" (or
                     (name . "^\\*scratch\\*$")
                     (name . "^\\*Messages\\*$")))
           ("magit" (name . "^\\*magit")))))
  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "default"))))

(with-eval-after-load 'evil
  ;; buffer navigation
  (define-key evil-normal-state-map (kbd "SPC b i") #'ibuffer)
  (define-key evil-normal-state-map (kbd "[ b") #'previous-buffer)
  (define-key evil-normal-state-map (kbd "] b") #'next-buffer))

(provide 'skje-ibuffer)
