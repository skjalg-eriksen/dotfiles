(use-package avy
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)))

(use-package expand-region
  :bind (("C-=" . er/expand-region)))

(provide 'skje-editing)
