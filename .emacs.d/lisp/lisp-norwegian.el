;;; lisp-norwegian.el --- Norwegian macOS-like Meta bindings -*- lexical-binding: t -*-
;; Insert: M-a / M-A -> å / Å, M-q / M-Q -> œ / Œ, M-o / M-O -> ø / Ø
;; Save to your load-path and (require 'lisp-norwegian)

;;; Code:

(defgroup lisp-norwegian nil
  "Norwegian Meta bindings."
  :group 'convenience)

(defun lisp-norwegian--insert (s)
  "Insert string S at point, respecting read-only buffers where appropriate."
  (interactive (list (read-string "String: ")))
  (when (or (not buffer-read-only) (minibufferp))
    (insert s)))

(defmacro lisp-norwegian--make-inserter (str)
  "Return a lambda that inserts STR interactively."
  `(lambda () (interactive) (lisp-norwegian--insert ,str)))

(defvar lisp-norwegian-mode-map (let ((map (make-sparse-keymap)))
                                  ;; lowercase
                                  (define-key map (kbd "M-a") (lisp-norwegian--make-inserter "å"))
                                  (define-key map (kbd "M-q") (lisp-norwegian--make-inserter "œ"))
                                  (define-key map (kbd "M-o") (lisp-norwegian--make-inserter "ø"))
                                  ;; uppercase (Shift)
                                  (define-key map (kbd "M-A") (lisp-norwegian--make-inserter "Å"))
                                  (define-key map (kbd "M-Q") (lisp-norwegian--make-inserter "Œ"))
                                  (define-key map (kbd "M-O") (lisp-norwegian--make-inserter "Ø"))
                                  map)
  "Keymap for `lisp-norwegian-mode'.")

;;;###autoload
(define-minor-mode lisp-norwegian-mode
  "Global minor mode to provide Norwegian Meta bindings (å, œ, ø)."
  :global t
  :lighter ""
  :keymap lisp-norwegian-mode-map)

;;; Enable by default
;;;###autoload
(when (not (bound-and-true-p lisp-norwegian-mode))
  (lisp-norwegian-mode 1))

(provide 'lisp-norwegian)
