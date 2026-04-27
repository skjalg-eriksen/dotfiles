
;; (use-package treemacs
;;   :bind (("C-x t t" . treemacs)
;;          ("C-x t 1" . treemacs-select-window)))

;; (use-package treemacs-evil
;;   :after (treemacs evil))

;; (use-package treemacs-magit
;;   :after (treemacs magit))


(use-package neotree
  :config
  (defun skje-neotree--project-root ()
    "Return git root for current buffer, or fallback to its directory."
    (let* ((file (or (buffer-file-name) default-directory))
           (dir (if (file-directory-p file)
                    file
                  (file-name-directory file))))
      (or (locate-dominating-file dir ".git")
          dir))))

  (defun skje-neotree-root ()
    "Toggle NeoTree rooted at current buffer's project root."
    (interactive)
    (let ((root (skje-neotree--project-root))
          (file (buffer-file-name)))
      (if (neo-global--window-exists-p)
          (neotree-hide)
        (progn
          (neotree-dir root)
          (when file
            (neo-open-file file))))))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "SPC e")
    #'skje-neotree-root))

  
;; (with-eval-after-load 'evil
;;   (define-key evil-normal-state-map (kbd "SPC e") #'skje-neotree-root))

(provide 'skje-file-tree)
