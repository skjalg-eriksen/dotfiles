
;; (use-package treemacs
;;   :bind (("C-x t t" . treemacs)
;;          ("C-x t 1" . treemacs-select-window)))

;; (use-package treemacs-evil
;;   :after (treemacs evil))

;; (use-package treemacs-magit
;;   :after (treemacs magit))


(use-package neotree)

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "SPC e")
    #'neotree-toggle))

(provide 'skje-file-tree)
