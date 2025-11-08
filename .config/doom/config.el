;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-vibrant)
;; (setq doom-theme 'doom-tomorrow-night)
;; (setq doom-theme 'challanger-deep)
;; (setq doom-theme 'doom-zenburn)
;; (setq doom-theme 'doom-ayu-mirage)
(setq doom-theme 'doom-spacegrey)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(projectile-discover-projects-in-directory "~/Source/Repos" 1)

;; automatically set ts or tsx mode when opening typescript files
;; (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
;; (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
;; (add-to-list 'auto-mode-alist '("\\.puml\\'". plantuml-mode))
;; (add-to-list 'auto-mode-alist '("\\.cs\\'". csharp-mode))

;; Start lsp-mode automatically for prog-mode derivatives
(add-hook 'prog-mode-hook #'lsp-deferred)


;; Load package bicep-mode.
;; (use-package! bicep-mode
;;   :load-path "~/.config/doom/bicep-mode")

;; ;; Start LSP automatically when bicep files are opened.
;; (add-hook 'bicep-mode-hook #'lsp);; Load package bicep-mode.
;;

;; ;; disable background color in terminal
;; (defun on-after-init ()
;;   (unless (display-graphic-p (selected-frame))
;;     (set-face-background 'default "unspecified-bg" (selected-frame))))
;; (add-hook 'window-setup-hook 'on-after-init)

;; remove menu bar from emacs client terminal frames
(add-hook 'after-make-frame-functions
          (lambda(frame)
            (with-selected-frame frame
              (if (display-graphic-p frame)
                  (menu-bar-mode 1)
                (menu-bar-mode -1)))))

(with-venv
 (executable-find "python"))

;; ;; Disable background color in terminal and toggle menu bar for client frames
;; (defun my/on-after-init ()
;;   "Adjust frame settings after init and when new frames are created."
;;   ;; For initial frame(s) created at startup
;;   (dolist (frame (frame-list))
;;     (when (not (display-graphic-p frame))
;;       (set-face-background 'default "unspecified-bg" frame)))
;;   ;; Ensure menu-bar is enabled for GUI frames and disabled for terminal frames
;;   (dolist (frame (frame-list))
;;     (with-selected-frame frame
;;       (if (display-graphic-p frame) (menu-bar-mode 1) (menu-bar-mode -1)))))

;; (add-hook 'window-setup-hook #'my/on-after-init)


;; ;; Also handle frames created after startup (client frames, new frames, etc.)
;; (defun my/on-after-make-frame (frame)
;;   "Adjust face background and menu-bar for FRAME when it's created."
;;   (with-selected-frame frame
;;     (if (display-graphic-p frame)
;;         (menu-bar-mode 1)
;;       (menu-bar-mode -1)
;;       (set-face-background 'default "unspecified-bg" frame))))

;; (add-hook 'after-make-frame-functions #'my/on-after-make-frame)
;; Disable company-mode and completion-at-point (capf) in plantuml-mode
;; (add-hook 'plantuml-mode-hook
;;           (lambda ()
;;             (when (bound-and-true-p company-mode) (company-mode -1))
;;             (setq-local completion-at-point-functions nil)
;;             (setq-local company-idle-delay nil) ;; safe-guard if company still active
;;             (setq-local ivy-auto-select-single-candidate nil) ;; if using Ivy
;;             (setq-local corfu-auto nil))) ;; if using Corfu

                                        ;(setq mac-command-modifier 'super)  ; Set Command key as Super
                                        ;(setq mac-option-modifier 'meta)     ; Set Option key as Meta

                                        ; cmd + / to comment lines
;; (global-set-key (kbd "s-/") 'comment-line)
                                        ;(map! "s-/" #'comment-line)

                                        ; cmd ] to indent
(map! :m "s-]" #'evil-shift-right)
(map! :m "s-[" #'evil-shift-left)
(map! :v "s-]" #'evil-shift-right)
(map! :v "s-[" #'evil-shift-left)
(map! :i "s-]" #'evil-shift-right)
(map! :i "s-[" #'evil-shift-left)

;; remove global C-b binding
(global-unset-key (kbd "C-b"))

;; Move to first non-blank (like ^) and last non-blank (like $) with H/L in Evil
(after! evil
  (define-key evil-normal-state-map (kbd "H") #'evil-first-non-blank)
  (define-key evil-visual-state-map  (kbd "H") #'evil-first-non-blank)
  (define-key evil-operator-state-map (kbd "H") #'evil-first-non-blank)

  (define-key evil-normal-state-map (kbd "L") #'evil-end-of-line)
  (define-key evil-visual-state-map  (kbd "L") #'evil-end-of-line)
  (define-key evil-operator-state-map (kbd "L") #'evil-end-of-line))

;; Move line/visual block down and up with J/K, preserving selection
;; (defun my/evil-move-text-down (count)
;;   "Move current line or visual region DOWN by COUNT lines, keeping selection."
;;   (interactive "p")
;;   (if (use-region-p)
;;       (let ((col (current-column)))
;;         (evil-exit-visual-state)
;;         (transpose-regions (region-beginning) (region-end)
;;                            (save-excursion (goto-char (region-end)) (line-beginning-position 2)))
;;         ;; restore visual selection one line down
;;         (let ((rb (save-excursion (goto-char (region-end)) (forward-line 1) (point)))
;;               (ra (save-excursion (goto-char (region-beginning)) (forward-line 1) (point))))
;;           (goto-char ra)
;;           (set-mark (point))
;;           (goto-char rb)
;;           (evil-visual-restore))
;;         (goto-char (line-beginning-position))
;;         (move-to-column col))
;;     (progn
;;       (save-excursion
;;         (transpose-lines count))
;;       ;; keep cursor on moved line
;;       (forward-line 1))))


;; (defun my/evil-move-text-up (count)
;;   "Move current line or visual region UP by COUNT lines, keeping selection."
;;   (interactive "p")
;;   (if (use-region-p)
;;       (let ((col (current-column)))
;;         (evil-exit-visual-state)
;;         (transpose-regions (save-excursion (goto-char (region-beginning)) (line-beginning-position))
;;                            (save-excursion (goto-char (region-end)) (line-end-position))
;;                            (save-excursion (goto-char (region-beginning)) (forward-line -1) (point)))
;;         ;; restore visual selection one line up
;;         (let ((rb (save-excursion (goto-char (region-end)) (forward-line -1) (point)))
;;               (ra (save-excursion (goto-char (region-beginning)) (forward-line -1) (point))))
;;           (goto-char ra)
;;           (set-mark (point))
;;           (goto-char rb)
;;           (evil-visual-restore))
;;         (goto-char (line-beginning-position))
;;         (move-to-column col))
;;     (progn
;;       (transpose-lines 1)
;;       (forward-line -2)
;;       (forward-line 1))))
;; )


;; Simpler, more reliable approach using `drag-stuff` if available:
;; (when (require 'drag-stuff nil t)
;;   (drag-stuff-mode 1)
;;   (after! evil
;;     (define-key evil-normal-state-map (kbd "J") #'drag-stuff-down)
;;     (define-key evil-visual-state-map (kbd "J") #'drag-stuff-down)
;;     (define-key evil-normal-state-map (kbd "K") #'drag-stuff-up)
;;     (define-key evil-visual-state-map (kbd "K") #'drag-stuff-up)))

;; If you prefer the built-in approach, bind the commands:
;; (after! evil

;;   (define-key evil-normal-state-map (kbd "J") 'my/evil-move-text-down)
;;   (define-key evil-visual-state-map (kbd "J") 'my/evil-move-text-down)
;;   (define-key evil-normal-state-map (kbd "K") 'my/evil-move-text-up)
;;   (define-key evil-visual-state-map (kbd "K") 'my/evil-move-text-up)

;;   )

;; Enable dap-mode and dap-netcore
;; (use-package! dap-mode
;;   :after lsp-mode
;;   :config
;;   (dap-mode 1)
;;   (dap-ui-mode 1)
;;   (require 'dap-netcore))

;; (after! dap-mode
;;   (defun my/dap-netcore-get-framework ()
;;     "Get the target framework version from the .csproj file."
;;     (let* ((project-root (or (projectile-project-root) default-directory))
;;            (csproj-file (car (directory-files project-root t "\\.csproj$"))))
;;       (if csproj-file
;;           (with-temp-buffer
;;             (insert-file-contents csproj-file)
;;             (if (re-search-forward "<TargetFramework>\\(.*?\\)</TargetFramework>" nil t)
;;                 (match-string 1)
;;               (error "TargetFramework not found in %s" csproj-file)))
;;         (error "No .csproj file found in %s" project-root))))

;;   (defun my/dap-netcore-find-dll ()
;;     "Find the .dll file for the current .NET project."
;;     (let* ((project-root (or (projectile-project-root) default-directory))
;;            (framework (my/dap-netcore-get-framework))
;;            (bin-dir (expand-file-name (format "bin/Debug/%s" framework) project-root))
;;            (dll-file (car (directory-files-recursively bin-dir "\\.dll$"))))
;;       (if dll-file
;;           dll-file
;;         (error "No .dll file found in %s" bin-dir))))

;;   (dap-register-debug-template
;;    ".Net Core Launch (Console)"
;;    (list :type "coreclr"
;;          :request "launch"
;;          :name ".Net Core Launch (Console)"
;;          :program (lambda () (my/dap-netcore-find-dll))
;;          :cwd (lambda () (projectile-project-root))))

;;   (dap-register-debug-template
;;    ".Net Core Attach (Console)"
;;    (list :type "coreclr"
;;          :request "attach"
;;          :name ".Net Core Attach (Console)"
;;          :processId nil)))
