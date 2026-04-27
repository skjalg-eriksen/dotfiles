;;; skje-norwegian.el --- Norwegian macOS-like Meta bindings -*- lexical-binding: t -*-
;; Insert: M-a/M-A -> å/Å, M-q/M-Q -> æ/Æ, M-o/M-O -> ø/Ø
;; Save to your load-path and (require 'skje-norwegian)

(defgroup skje-norwegian nil
  "Norwegian Meta bindings."
  :group 'convenience)

(defun skje-norwegian--insert (s)
  "Insert string S at point, respecting read-only buffers where appropriate."
  (interactive (list (read-string "String: ")))
  (when (or (not buffer-read-only) (minibufferp))
    (insert s)))

(defmacro skje-norwegian--make-inserter (str)
  "Return a lambda that inserts STR interactively."
  `(lambda () (interactive) (skje-norwegian--insert ,str)))

(defvar skje-norwegian-mode-map
  (let ((map (make-sparse-keymap)))
    (if (display-graphic-p)
        ;; GUI Emacs (macOS/Linux)
        (progn
          (define-key map (kbd "M-a") (skje-norwegian--make-inserter "å"))
          (define-key map (kbd "M-q") (skje-norwegian--make-inserter "æ"))
          (define-key map (kbd "M-o") (skje-norwegian--make-inserter "ø"))
          (define-key map (kbd "M-A") (skje-norwegian--make-inserter "Å"))
          (define-key map (kbd "M-Q") (skje-norwegian--make-inserter "Æ"))
          (define-key map (kbd "M-O") (skje-norwegian--make-inserter "Ø")))
      ;; Terminal Emacs fallback
      (progn
        (define-key map (kbd "C-c n a") (skje-norwegian--make-inserter "å"))
        (define-key map (kbd "C-c n q") (skje-norwegian--make-inserter "æ"))
        (define-key map (kbd "C-c n o") (skje-norwegian--make-inserter "ø"))
        (define-key map (kbd "C-c n A") (skje-norwegian--make-inserter "Å"))
        (define-key map (kbd "C-c n Q") (skje-norwegian--make-inserter "Æ"))
        (define-key map (kbd "C-c n O") (skje-norwegian--make-inserter "Ø"))))
    map))

;;;###autoload
(define-minor-mode skje-norwegian-mode
  "Global minor mode to provide Norwegian Meta bindings (å, œ, ø)."
  :global t
  :lighter ""
  :keymap skje-norwegian-mode-map)

;;; Enable by default
;;;###autoload
(when (not (bound-and-true-p skje-norwegian-mode))
  (skje-norwegian-mode 1))

(provide 'skje-norwegian)
