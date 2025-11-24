;;; --- Safe cross-platform clipboard integration for TTY Emacs ---

(setq select-enable-clipboard t)

(defun my/tty-clipboard-copy (text)
  "Copy TEXT to system clipboard safely, without breaking Evil registers."
  (let ((process-connection-type nil))
    (cond
     ;; macOS
     ((eq system-type 'darwin)
      (start-process "pbcopy" nil "pbcopy" text))

     ;; Linux Wayland
     ((and (executable-find "wl-copy")
           (getenv "WAYLAND_DISPLAY"))
      (start-process "wl-copy" nil "wl-copy" text))

     ;; Linux X11 (xclip)
     ((and (executable-find "xclip")
           (getenv "DISPLAY"))
      (start-process "xclip" nil "xclip" "-selection" "clipboard")
      (process-send-string "xclip" text)
      (process-send-eof "xclip"))

     ;; Linux X11 (xsel)
     ((and (executable-find "xsel")
           (getenv "DISPLAY"))
      (start-process "xsel" nil "xsel" "--clipboard" "--input")
      (process-send-string "xsel" text)
      (process-send-eof "xsel")))))

(defun my/tty-clipboard-paste ()
  "Paste from system clipboard safely, without upsetting kill ring."
  (cond
   ;; macOS
   ((eq system-type 'darwin)
    (shell-command-to-string "pbpaste"))

   ;; Linux Wayland
   ((and (executable-find "wl-paste")
         (getenv "WAYLAND_DISPLAY"))
    (shell-command-to-string "wl-paste --no-newline"))

   ;; Linux X11
   ((executable-find "xclip")
    (shell-command-to-string "xclip -o -selection clipboard"))

   ((executable-find "xsel")
    (shell-command-to-string "xsel --clipboard --output"))

   (t nil)))

;; --- Do NOT override evil registers. Only sync explicit kills. ---

(setq interprogram-cut-function #'my/tty-clipboard-copy)
(setq interprogram-paste-function #'my/tty-clipboard-paste)
