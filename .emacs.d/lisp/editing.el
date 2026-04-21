(use-package avy
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)))

(use-package expand-region
  :bind (("C-=" . er/expand-region)))

(defun sk/macos-terminal-copy-to-clipboard (text &optional push)
  (when (and (not push) (executable-find "pbcopy"))
    (with-temp-buffer
      (insert text)
      (let ((exit-code (call-process-region (point-min) (point-max) "pbcopy")))
        (unless (zerop exit-code)
          (error "pbcopy failed with exit code %s" exit-code))))))

(defun sk/macos-terminal-paste-from-clipboard ()
  (when (executable-find "pbpaste")
    (with-temp-buffer
      (let ((exit-code (call-process "pbpaste" nil t nil)))
        (unless (zerop exit-code)
          (error "pbpaste failed with exit code %s" exit-code))
        (unless (= (buffer-size) 0)
          (buffer-string))))))

(when (and (eq system-type 'darwin) (not (display-graphic-p)))
  (setq select-enable-clipboard t
        save-interprogram-paste-before-kill t
        interprogram-cut-function #'sk/macos-terminal-copy-to-clipboard
        interprogram-paste-function #'sk/macos-terminal-paste-from-clipboard))

(provide 'editing)
