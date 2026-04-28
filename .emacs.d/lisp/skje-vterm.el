;;; skje-vterm.el --- terminal integration -*- lexical-binding: t; -*-

(use-package vterm
  :ensure t
  :commands (vterm vterm-other-window)
  :config
  ;; Better scrolling behavior
  (setq vterm-max-scrollback 10000)

  ;; Kill buffer when process exits
  (setq vterm-kill-buffer-on-exit t)

  ;; Optional: use a dedicated shell
  ;; (setq vterm-shell "/bin/zsh")
  )

(defun skje/vterm-toggle ()
  "Toggle a vterm buffer."
  (interactive)
  (if (get-buffer "*vterm*")
      (if (equal (current-buffer) (get-buffer "*vterm*"))
          (previous-buffer)
        (switch-to-buffer "*vterm*"))
    (vterm)))

(defun skje/vterm-here ()
  "Open vterm in current buffer's directory."
  (interactive)
  (let ((default-directory
          (or (and (buffer-file-name)
                   (file-name-directory (buffer-file-name)))
              default-directory)))
    (vterm)))

(with-eval-after-load 'evil
  ;; terminal shortcuts
  (define-key evil-normal-state-map (kbd "SPC o t") #'vterm)
  (define-key evil-normal-state-map (kbd "SPC o T") #'vterm-other-window)
  (define-key evil-normal-state-map (kbd "SPC t t") #'skje/vterm-toggle)
  (define-key evil-normal-state-map (kbd "SPC t h") #'skje/vterm-here))

(provide 'skje-vterm)
