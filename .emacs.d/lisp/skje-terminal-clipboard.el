;; Terminal clipboard integration with OSC52-first copy behavior.

(defun skje-terminal-clipboard--call-process-to-string (program &rest args)
  (with-temp-buffer
    (let ((exit-code (apply #'call-process program nil t nil args)))
      (unless (zerop exit-code)
        (error "%s failed with exit code %s" program exit-code))
      (unless (= (buffer-size) 0)
        (buffer-string)))))

(defun skje-terminal-clipboard--call-process-region (program text &rest args)
  (with-temp-buffer
    (insert text)
    (let ((exit-code
           (apply #'call-process-region
                  (point-min) (point-max) program nil nil nil args)))
      (unless (zerop exit-code)
        (error "%s failed with exit code %s" program exit-code)))))

(defun skje-terminal-clipboard--osc52-sequence (text)
  (let* ((payload (base64-encode-string text t))
         (sequence (format "\e]52;c;%s\e\\" payload)))
    (if (getenv "TMUX")
        (format "\ePtmux;\e%s\e\\"
                (replace-regexp-in-string "\e" "\e\e" sequence t t))
      sequence)))

(defun skje-terminal-clipboard--osc52-copy (text &optional push)
  (when (not push)
    (send-string-to-terminal (skje-terminal-clipboard--osc52-sequence text))
    text))

(defun skje-terminal-clipboard--linux-copy (text &optional push)
  (when (not push)
    (cond
     ((and (getenv "WAYLAND_DISPLAY") (executable-find "wl-copy"))
      (skje-terminal-clipboard--call-process-region "wl-copy" text))
     ((and (getenv "DISPLAY") (executable-find "xclip"))
      (skje-terminal-clipboard--call-process-region
       "xclip" text "-selection" "clipboard"))
     ((and (getenv "DISPLAY") (executable-find "xsel"))
      (skje-terminal-clipboard--call-process-region
       "xsel" text "--clipboard" "--input")))))

(defun skje-terminal-clipboard--linux-paste ()
  (cond
   ((and (getenv "WAYLAND_DISPLAY") (executable-find "wl-paste"))
    (skje-terminal-clipboard--call-process-to-string "wl-paste" "--no-newline"))
   ((and (getenv "DISPLAY") (executable-find "xclip"))
    (skje-terminal-clipboard--call-process-to-string
     "xclip" "-selection" "clipboard" "-o"))
   ((and (getenv "DISPLAY") (executable-find "xsel"))
    (skje-terminal-clipboard--call-process-to-string
     "xsel" "--clipboard" "--output"))))

(defun skje-terminal-clipboard--macos-copy (text &optional push)
  (when (and (not push) (executable-find "pbcopy"))
    (skje-terminal-clipboard--call-process-region "pbcopy" text)))

(defun skje-terminal-clipboard--macos-paste ()
  (when (executable-find "pbpaste")
    (skje-terminal-clipboard--call-process-to-string "pbpaste")))

(defun skje-terminal-clipboard-copy (text &optional push)
  (unless push
    (cond
     ((not (display-graphic-p))
      (condition-case nil
          (skje-terminal-clipboard--osc52-copy text)
        (error
         (pcase system-type
           ('darwin (skje-terminal-clipboard--macos-copy text))
           ('gnu/linux (skje-terminal-clipboard--linux-copy text))))))
     ((eq system-type 'darwin)
      (skje-terminal-clipboard--macos-copy text))
     ((eq system-type 'gnu/linux)
      (skje-terminal-clipboard--linux-copy text)))))

(defun skje-terminal-clipboard-paste ()
  (pcase system-type
    ('darwin (skje-terminal-clipboard--macos-paste))
    ('gnu/linux (skje-terminal-clipboard--linux-paste))))

(when (and (not noninteractive) (not (display-graphic-p)))
  (setq select-enable-clipboard t
        save-interprogram-paste-before-kill t
        interprogram-cut-function #'skje-terminal-clipboard-copy
        interprogram-paste-function #'skje-terminal-clipboard-paste))

(provide 'skje-terminal-clipboard)
