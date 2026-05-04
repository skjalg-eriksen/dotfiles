;;; skje-zen.el --- distraction-free editing -*- lexical-binding: t; -*-

(use-package olivetti
  :ensure t
  :hook (olivetti-mode . visual-line-mode)
  :config
  (setq olivetti-body-width 90))

(defvar skje-zen-level nil
  "Current zen mode level. nil, 'soft, or 'hard.")

(defvar skje-zen--excluded-modes
  '(term-mode
    vterm-mode
    treemacs-mode
    eshell-mode
    shell-mode
    minibuffer-mode)
  "Major modes where zen mode should not be enabled.")

(defun skje-zen--eligible-buffer-p ()
  (and (not (minibufferp))
       (not (member major-mode skje-zen--excluded-modes))
       (not (string-prefix-p " " (buffer-name)))))

(defun skje-zen--apply-soft ()
  "Soft zen: light focus, good for coding."
  (when (skje-zen--eligible-buffer-p)
    ;; layout
    (olivetti-mode 1)

    ;; keep modeline (ensure it's ON)
    (when (fboundp 'doom-modeline-mode)
      (doom-modeline-mode 1))

    ;; ensure line numbers ON
    (when (fboundp 'display-line-numbers-mode)
      (display-line-numbers-mode 1))

    ;; mild scaling
    (text-scale-set 1)))

(defun skje-zen--apply-hard ()
  "Hard zen: maximum focus, good for writing."
  (when (skje-zen--eligible-buffer-p)
    ;; layout
    (olivetti-mode 1)

    ;; disable modeline safely (doom-friendly)
    (when (fboundp 'doom-modeline-mode)
      (doom-modeline-mode -1))

    ;; disable line numbers
    (when (fboundp 'display-line-numbers-mode)
      (display-line-numbers-mode -1))

    ;; stronger scaling
    (text-scale-set 2)))

(defun skje-zen--disable ()
  "Disable zen mode in current buffer."
  ;; restore modeline
  (when (fboundp 'doom-modeline-mode)
    (doom-modeline-mode 1))

  ;; restore line numbers
  (when (fboundp 'display-line-numbers-mode)
    (display-line-numbers-mode 1))

  ;; layout reset
  (olivetti-mode -1)
  (text-scale-set 0))

(defun skje-zen--apply-current ()
  "Apply current zen level to this buffer."
  (pcase skje-zen-level
    ('soft (skje-zen--apply-soft))
    ('hard (skje-zen--apply-hard))
    (_ (skje-zen--disable))))

(defun skje-zen--apply-to-all-buffers ()
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (skje-zen--apply-current))))

(defun skje-zen--maybe-apply ()
  (when skje-zen-level
    (skje-zen--apply-current)))

(defun skje-zen-toggle-soft ()
  "Toggle soft zen mode."
  (interactive)
  (setq skje-zen-level (if (eq skje-zen-level 'soft) nil 'soft))
  (skje-zen--apply-to-all-buffers)
  (message "Zen mode: %s"
           (if skje-zen-level "soft enabled" "disabled")))

(defun skje-zen-toggle-hard ()
  "Toggle hard zen mode."
  (interactive)
  (setq skje-zen-level (if (eq skje-zen-level 'hard) nil 'hard))
  (skje-zen--apply-to-all-buffers)
  (message "Zen mode: %s"
           (if skje-zen-level "hard enabled" "disabled")))

;; apply to new buffers
(add-hook 'after-change-major-mode-hook #'skje-zen--maybe-apply)

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "SPC u z") #'skje-zen-toggle-soft)
  (define-key evil-normal-state-map (kbd "SPC u Z") #'skje-zen-toggle-hard))

(provide 'skje-zen)
