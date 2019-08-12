;;; .emacs --- Emacs configuration.
;;
;; Author: Evan Lecklider
;;
;;; Commentary:
;;
;; Lots of good stuff from here: https://github.com/bbatsov/prelude/blob/master/core/prelude-editor.el

;;; Code:

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; This is only needed once, near the top of the file
(eval-when-compile
  (require 'use-package))

;; Always ensure packages.
(setq use-package-always-ensure t)

;; Disable scroll bars because they're ugly.
;;   https://www.emacswiki.org/emacs/ScrollBar
(scroll-bar-mode -1)

;; Quick split navigation.
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-k") 'windmove-up)
(global-set-key (kbd "C-l") 'windmove-right)

;; Make command +/- adjust apparent font size.
(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "s--") 'text-scale-decrease)

;; Set up the command+arrowkey combinations.
(global-set-key (kbd "s-<right>") 'move-end-of-line)
(global-set-key (kbd "s-<left>") 'move-beginning-of-line)
(global-set-key (kbd "s-<up>") 'beginning-of-buffer)
(global-set-key (kbd "s-<down>") 'end-of-buffer)

;; Wrap at 80 characters rather than 70.
(setq fill-column 80)

;; Automatically wrap lines that get longer than 'fill-column.
(setq comment-auto-fill-only-comments t)

;; Wrap commits to 80 characters and wrap everything, not just comments.
(add-hook 'git-commit-mode-hook
  (lambda ()
    (setq comment-auto-fill-only-comments nil)))

;; Wrap markdown to 80 characters and wrap everything, not just comments.
(add-hook 'markdown-mode-hook
  (lambda ()
    (setq comment-auto-fill-only-comments nil)))

;; Turn on the above auto-fill behavior.
(auto-fill-mode 1)

;; Disable tabs unless specified.
(setq-default indent-tabs-mode nil)

;; Don't wrap lines, "truncate" them.
(setq-default truncate-lines t)

;; Set tab width to 2.
(setq tab-width 2)

;; Disable the tool bar.
(tool-bar-mode -1)

;; Line numbers all the time.
(global-display-line-numbers-mode)

;; Disable the startup screen.
(setq inhibit-startup-screen t)

;; Don't calculate this dynamically.
(setq-default display-line-numbers-width 3)

;; Like vim's magic relative line numbers.
(setq-default display-line-numbers-type 'relative)

;; Enable visual-line-mode.
;; (global-visual-line-mode)

;; Add hooks to different modes, adding _ as a word character.
(add-hook 'ruby-mode-hook '(lambda () (modify-syntax-entry ?_ "w")))

;; Set default font.
(set-face-attribute 'default nil
  :family "Fira Code"
  :height 110
  :weight 'normal
  :width 'normal)

;; Store all backups in a central spot.
(setq backup-directory-alist
  `((".*" . ,(concat user-emacs-directory "backups"))))
(setq auto-save-file-name-transforms
  `((".*" ,(concat user-emacs-directory "backups") t)))

(unless (file-exists-p (concat user-emacs-directory "backups"))
  (make-directory (concat user-emacs-directory "backups")))


;; General backup settings.
(setq make-backup-files t
  backup-by-copying t
  version-control t
  delete-old-versions t
  delete-by-moving-to-trash t
  kept-old-versions 6
  kept-new-versions 9
  auto-save-default t
  auto-save-timeout 20
  auto-save-interval 200)

;; Reload files from disk when changed.
(global-auto-revert-mode)

;; Turn the fucking bell off.
(setq ring-bell-function 'ignore)

;; http://ergoemacs.org/emacs/emacs_dired_tips.html
(defun dired-hide-details-mode-hook ()
  "Automatically hide details in dired."
  (dired-hide-details-mode 1))
(add-hook 'dired-mode-hook 'dired-hide-details-mode-hook)

;; Newline at end of file
(setq require-final-newline t)

;; hippie expand is dabbrev expand on steroids
(setq hippie-expand-try-functions-list
  '(try-expand-dabbrev
    try-expand-dabbrev-all-buffers
    try-expand-dabbrev-from-kill
    try-complete-file-name-partially
    try-complete-file-name
    try-expand-all-abbrevs
    try-expand-list
    try-expand-line
    try-complete-lisp-symbol-partially
    try-complete-lisp-symbol))

;; https://emacs.stackexchange.com/questions/32958/insert-line-above-below
(defun insert-line-below ()
  "Insert an empty line below the current line."
  (interactive)
  (save-excursion
    (end-of-line)
    (open-line 1)))

(defun insert-line-above ()
  "Insert an empty line above the current line."
  (interactive)
  (save-excursion
    (end-of-line 0)
    (open-line 1)))

(defun neotree-project-dir ()
  "Open NeoTree using the Projectile project root."
  (interactive)
  (let ((project-dir (projectile-project-root)) (file-name (buffer-file-name)))
  (neotree-toggle)
  (if project-dir
    (if (neo-global--window-exists-p)
      (progn
        (neotree-dir project-dir)
        (neotree-find file-name)))
    (message "Could not find git project root."))))

;; Make sure the local node_modules/.bin/ can be found (for eslint).
;;   https://github.com/codesuki/add-node-modules-path
(use-package add-node-modules-path
  :config
  ;; automatically run the function when web-mode or js-mode starts.
  (eval-after-load 'js-mode
    '(add-hook 'js-mode-hook 'add-node-modules-path))
  (eval-after-load 'web-mode
    '(add-hook 'web-mode-hook 'add-node-modules-path)))

;; https://github.com/rranelli/auto-package-update.el
(use-package auto-package-update
  :init
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (setq auto-package-update-interval 1)

  :config
  (auto-package-update-maybe))

(use-package base16-theme
  :config
  (load-theme 'base16-nord t))

;; diminish keeps the modeline tidy
(use-package diminish)

;; Dockerfile
(use-package dockerfile-mode
  :defer t)

;; https://github.com/preetpalS/emacs-dotenv-mode
(use-package dotenv-mode
  :mode "\\.env\\'")

(use-package editorconfig
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

(use-package evil-leader
  :config
  (global-evil-leader-mode)
  (evil-leader/set-key
    "a" 'projectile-ripgrep
    "bd" 'kill-this-buffer
    "c" 'projectile-run-term
    "gb" 'magit-blame
    "gc" 'magit-commit-create
    "gd" 'magit-diff-buffer-file
    "gs" 'magit-status
    "n" 'neotree-project-dir
    "p" 'helm-projectile-switch-project
    "q" 'delete-window
    "r" 'helm-etags-select
    "t" 'helm-projectile
    "v" 'split-window-horizontally
    "w" 'save-buffer
    "x" 'split-window-vertically))

(use-package evil-surround
  :config
  (global-evil-surround-mode))

(use-package evil
  :config
  (evil-mode 1)
  (setq-default evil-shift-width 2)

  ;; Quick buffer access.
  (evil-define-key 'normal 'global ";" 'helm-projectile-switch-to-buffer)

  ;; Quick code folding.
  (evil-define-key 'normal 'global " " 'evil-toggle-fold)

  ;; Insert new lines above and below.
  (evil-define-key 'normal 'global "[ " 'insert-line-above)
  (evil-define-key 'normal 'global "] " 'insert-line-below)

  ;; Start expand-region.
  (evil-define-key 'normal 'global "go" 'er/expand-region)

  ;; Toggle comments.
  (evil-define-key 'normal 'global "gcc" 'comment-line)
  (evil-define-key 'visual 'global "gc" 'comment-line)

  ;; Next and previous linting errors.
  (evil-define-key 'normal 'global "]l" 'flycheck-next-error)
  (evil-define-key 'normal 'global "[l" 'flycheck-previous-error))

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; https://github.com/magnars/expand-region.el
(use-package expand-region)

(use-package flycheck
  :init (global-flycheck-mode)
  :diminish flycheck-mode
  :config
  (flycheck-add-mode 'javascript-eslint 'web-mode))

;; https://github.com/nex3/haml-mode
(use-package haml-mode)

;; https://github.com/emacs-helm/helm
(use-package helm
  :bind (("M-x" . helm-M-x))
  :diminish helm-mode
  :init
  (setq helm-etags-tag-file-name "etags")
  (setq helm-mode-fuzzy-match t)
  (setq helm-completion-in-region-fuzzy-match t)

  :config
  (helm-mode 1))

;; https://github.com/bbatsov/helm-projectile
(use-package helm-projectile)

;; https://github.com/magit/magit
(use-package magit
  :config
  (setq magit-blame-styles
    '((margin
        (margin-format    . ("%.8H %a %A"))
        (margin-width     . 42)
        (margin-face      . magit-blame-margin)
        (margin-body-face . (magit-blame-dimmed)))
      (headings
        (heading-format   . "%-20a %C %s\n"))
      (highlight
        (highlight-face   . magit-blame-highlight))
      (lines
        (show-lines       . t)))))

;; https://github.com/emacs-evil/evil-magit
(use-package evil-magit)

(use-package markdown-mode)

;; https://github.com/jaypei/emacs-neotree
(use-package neotree
  :config
  (setq neo-theme 'ascii)
  (setq neo-window-fixed-size nil)
  (setq neo-window-width 40)

  ;; Make neotree work with evil.
  ;; https://www.emacswiki.org/emacs/NeoTree
  (evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
  (evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
  (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
  (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
  (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
  (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
  (evil-define-key 'normal neotree-mode-map (kbd "p") 'neotree-previous-line)
  (evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
  (evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle))

;; https://github.com/gregsexton/origami.el
(use-package origami
  :init
  (setq origami-show-fold-header t)
  :config
  (global-origami-mode))


;; https://github.com/TheBB/spaceline
(use-package spaceline
  :init
  (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state)

  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))

;; https://github.com/bbatsov/projectile
(use-package projectile
  :diminish projectile-mode
  :init
  (setq projectile-tags-file-name "etags")
  (setq projectile-generic-command "fd . -0 --type file")
  (setq projectile-git-command "fd . -0 --type file")

  :config
  (projectile-mode 1))

;; https://github.com/nlamirault/ripgrep.el
(use-package ripgrep)

;; Hitting tab to complete things feels so natural...
(use-package smart-tab
  :diminish smart-tab-mode
  :config
  (global-smart-tab-mode))

;; Gotta get those matching parens!
;;   https://github.com/Fuco1/smartparens
(use-package smartparens
  :diminish smartparens-mode
  :config
  (require 'smartparens-config)
  (smartparens-global-mode))

;; https://github.com/emacs-typescript/typescript.el
(use-package typescript-mode)

;; Saner undo?
(use-package undo-tree
  :diminish undo-tree-mode
  :init
  ;; Save the undo history.
  (setq undo-tree-auto-save-history t)
  (setq undo-tree-history-directory-alist
        `((".*" . ,(concat user-emacs-directory "undo"))))

  (unless (file-exists-p (concat user-emacs-directory "undo"))
    (make-directory (concat user-emacs-directory "undo")))

  :config
  (global-undo-tree-mode))

;; https://github.com/AdamNiederer/vue-mode
(use-package vue-mode
  :defer t
  :init
  (setq js-indent-level 2)

  :config
  ;; Disable the ugly background color.
  ;;   https://github.com/AdamNiederer/vue-mode#how-do-i-disable-that-ugly-background-color
  (add-hook 'mmm-mode-hook
    (lambda ()
      (set-face-background 'mmm-default-submode-face nil))))

(use-package web-mode
  :init
  (setq web-mode-enable-auto-pairing nil)

  :mode ("\\.erb\\'" "\\.html\\'" "\\.html\\.erb\\'"))

(use-package yaml-mode
  :mode "\\.yml\\'")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(css-indent-offset 2)
  '(custom-safe-themes
     (quote
       ("99c86852decaeb0c6f51ce8bd46e4906a4f28ab4c5b201bdc3fdf85b24f88518" "f6f5d5adce1f9a764855c9730e4c3ef3f90357313c1cae29e7c191ba1026bc15" "80930c775cef2a97f2305bae6737a1c736079fdcc62a6fdf7b55de669fbbcd13" "ea9e9f350c019474a5265c08f7441027b23c1da3f23b9c30517d60133bab679f" "196df8815910c1a3422b5f7c1f45a72edfa851f6a1d672b7b727d9551bb7c7ba" "446cc97923e30dec43f10573ac085e384975d8a0c55159464ea6ef001f4a16ba" "527df6ab42b54d2e5f4eec8b091bd79b2fa9a1da38f5addd297d1c91aa19b616" "6145e62774a589c074a31a05dfa5efdf8789cf869104e905956f0cbd7eda9d0e" "7559ac0083d1f08a46f65920303f970898a3d80f05905d01e81d49bb4c7f9e39" "5a7830712d709a4fc128a7998b7fa963f37e960fd2e8aa75c76f692b36e6cf3c" default)))
  '(package-selected-packages
     (quote
       (dotenv-mode expand-region haml-mode ripgrep smart-tab evil-magit typescript-mode yaml-mode editorconfig diminish markdown-mode add-node-modules-path magit flycheck exec-path-from-shell dockerfile-mode web-mode vue-mode evil-leader origami helm-projectile helm evil-surround auto-package-update use-package evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide '.emacs)
;;; .emacs ends here
