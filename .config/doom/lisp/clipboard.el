;;; --- Cross-platform terminal clipboard integration ---

(setq select-enable-clipboard t)

(cond
 ;; --- macOS ---
 ((eq system-type 'darwin)
  (setq interprogram-cut-function
        (lambda (text)
          (let ((process-connection-type nil))
            (start-process "pbcopy" nil "pbcopy" text))))
  (setq interprogram-paste-function
        (lambda ()
          (shell-command-to-string "pbpaste"))))

 ;; --- Linux Wayland ---
 ((and (eq system-type 'gnu/linux)
       (executable-find "wl-copy")
       (executable-find "wl-paste"))
  (setq interprogram-cut-function
        (lambda (text)
          (let ((process-connection-type nil))
            (start-process "wl-copy" nil "wl-copy" text))))
  (setq interprogram-paste-function
        (lambda ()
          (shell-command-to-string "wl-paste --no-newline"))))

 ;; --- Linux X11 fallback (xclip/xsel) ---
 ((and (eq system-type 'gnu/linux)
       (executable-find "xclip"))
  (xclip-mode 1))
 ((and (eq system-type 'gnu/linux)
       (executable-find "xsel"))
  (xclip-mode 1)))
