;;; dot-zen.el --- distraction-free editing -*- lexical-binding: t; -*-

(use-package olivetti
  :ensure t
  :hook (olivetti-mode . visual-line-mode)
  :config
  (setq olivetti-body-width 90))

(defvar dot/zen-level nil
  "Current zen mode level. nil, 'soft, or 'hard.")

(defvar dot/zen--excluded-modes
  '(term-mode
    vterm-mode
    treemacs-mode
    eshell-mode
    shell-mode
    minibuffer-mode)
  "Major modes where zen mode should not be enabled.")

(defun dot/zen--eligible-buffer-p ()
  (and (not (minibufferp))
       (not (member major-mode dot/zen--excluded-modes))
       (not (string-prefix-p " " (buffer-name)))))

(defun dot/zen--apply-soft ()
  "Soft zen: light focus, good for coding."
  (when (dot/zen--eligible-buffer-p)
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

(defun dot/zen--apply-hard ()
  "Hard zen: maximum focus, good for writing."
  (when (dot/zen--eligible-buffer-p)
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

(defun dot/zen--disable ()
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

(defun dot/zen--apply-current ()
  "Apply current zen level to this buffer."
  (pcase dot/zen-level
    ('soft (dot/zen--apply-soft))
    ('hard (dot/zen--apply-hard))
    (_ (dot/zen--disable))))

(defun dot/zen--apply-to-all-buffers ()
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (dot/zen--apply-current))))

(defun dot/zen--maybe-apply ()
  (when dot/zen-level
    (dot/zen--apply-current)))

(defun dot/toggle-zen-soft ()
  "Toggle soft zen mode."
  (interactive)
  (setq dot/zen-level (if (eq dot/zen-level 'soft) nil 'soft))
  (dot/zen--apply-to-all-buffers)
  (message "Zen mode: %s"
           (if dot/zen-level "soft enabled" "disabled")))

(defun dot/toggle-zen-hard ()
  "Toggle hard zen mode."
  (interactive)
  (setq dot/zen-level (if (eq dot/zen-level 'hard) nil 'hard))
  (dot/zen--apply-to-all-buffers)
  (message "Zen mode: %s"
           (if dot/zen-level "hard enabled" "disabled")))

;; apply to new buffers
(add-hook 'after-change-major-mode-hook #'dot/zen--maybe-apply)

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "SPC u z") #'dot/toggle-zen-soft)
  (define-key evil-normal-state-map (kbd "SPC u Z") #'dot/toggle-zen-hard))

(provide 'dot-zen)
