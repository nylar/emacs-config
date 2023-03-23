;;; init.el -*- lexical-binding: t; -*-

;;; Code:

;; Send customize variables to separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;;; Package management
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

;; Always want packages to be fetched if not present
(setq straight-use-package-by-default t)

;; Compile packages natively
(setq package-native-compile t)

(use-package diminish)

;;; Theme
(load-theme 'fleetish t) ;; TODO: Add to Melpa

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file))

(global-set-key (kbd "C-c C-l") 'reload-init-file)

;;; Window manager
(use-package exwm
  :when (memq window-system '(x))
  :init
  (require 'exwm-config)
  (require 'exwm-randr)
  :config
  ;; TODO: Make own config
  (add-hook 'exwm-update-class-hook (lambda () (exwm-workspace-rename-buffer exwm-class-name)))
  (add-hook 'exwm-update-title-hook
            (lambda ()
              (when (or (not exwm-instance-name))
                (exwm-workspace-rename-buffer exwm-title))))

  (exwm-randr-enable)
  (exwm-config-example)
  (setq exwm-workspace-number 4)
  (setq exwm-manage-configurations
        '(((member exwm-class-name '("Nightly" "firefox"))
           char-mode t)))

  ;; Config example turns on ido, turn it off
  (ido-mode 0)
  ;; Map start workspaces to names
  (setq exwm-workspace-index-map
        (lambda (index)
          (let ((named-workspaces ["dev" "www" "k8s" "music"]))
            (if (< index (length named-workspaces))
                (elt named-workspaces index)
              (number-to-string (1+ index))))))
  (setq exwm-input-global-keys
        `(
          ;; 's-r': Reset (to line-mode).
          ([?\s-r] . exwm-reset)
          ;; 's-w': Switch workspace.
          ([?\s-w] . exwm-workspace-switch)
          ;; 's-&': Launch application.
          ([?\s-&] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))
          ;; 's-N': Switch to certain workspace.
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,(- i 1)))))
                    (number-sequence 0 9))))
  :bind (("C-c C-q" . exwm-input-send-next-key)))

;;; General

;; Remove the start screen, use dashboard instead
(setq inhibit-startup-screen t)

;; No bells
(setq ring-bell-function 'ignore)

;; Turn off auto-save
(setq auto-save-default nil)

;; Don't want backups
(setq make-backup-files nil)

;; Remove default comment in scratch buffers
(setq initial-scratch-message nil)

;; Update files if they change externally
(global-auto-revert-mode 1)

;; Line numbers
(add-hook 'prog-mode-hook (lambda () (display-line-numbers-mode 1)))
(add-hook 'text-mode-hook (lambda () (display-line-numbers-mode 1)))
(add-hook 'protobuf-mode-hook (lambda () (display-line-numbers-mode 1)))

;; Highlight current line
(add-hook 'prog-mode-hook (lambda () (hl-line-mode 1)))
(add-hook 'text-mode-hook (lambda () (hl-line-mode 1)))
(add-hook 'protobuf-mode-hook (lambda () (hl-line-mode 1)))

(defalias 'yes-or-no-p 'y-or-n-p)

;; UTF-8 always
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;; Make Emacs behave like every other app when overwriting text.
(delete-selection-mode 1)

;; Show left fringe only
(fringe-mode '(4 . 0))

;; Set GC to 100mb
(setq gc-cons-threshold 100000000)

;; Allow larger process payloads to be read
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; Never tabs
(setq-default indent-tabs-mode nil)

;; Prevent the creation of backup files
(setq make-backup-files nil)

  ;;; Env vars
(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(use-package multiple-cursors
  :config
  :bind (("C-S-c C-S-c" . mc/edit-lines)
	 ("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)))

;;; Which key
(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode))

(use-package string-inflection
  :bind (("C-c C-n" . string-inflection-java-style-cycle)))

;; Turn off scroll bars
(scroll-bar-mode -1)

;; Turn off tool bar
(tool-bar-mode -1)

;; Turn off the menu bar
(menu-bar-mode -1)

;; No blinking cursors
(blink-cursor-mode 0)

;; Show cursor coordinates
(column-number-mode 1)

;; Start maximised
(toggle-frame-maximized)

(use-package subword
  :diminish
  :init
  (global-subword-mode +1))

(use-package windmove
  :config
  (windmove-default-keybindings 'super)
  (setq windmove-wrap-around t))

;; Undo/redo layouts
(winner-mode 1)

;; Telephone line
(use-package telephone-line
  :config
  (setq telephone-line-primary-left-separator 'telephone-line-flat
        telephone-line-secondary-left-separator 'telephone-line-flat
        telephone-line-primary-right-separator 'telephone-line-flat
        telephone-line-secondary-right-separator 'telephone-line-flat

        telephone-line-height 36

        telephone-line-lhs '((evil   . (telephone-line-evil-tag-segment))
                             (accent . (telephone-line-vc-segment))
                             (nil    . (telephone-line-minor-mode-segment
                                        telephone-line-buffer-segment)))

        telephone-line-rhs '((nil    . (telephone-line-misc-info-segment))
                             (accent . (telephone-line-major-mode-segment))
                             (evil   . (telephone-line-airline-position-segment))))

  (telephone-line-mode 1))

(use-package minibuffer-line
  :when (memq window-system '(x))
  :custom-face
  (minibuffer-line ((t (:inherit font-lock-comment-face))))
  :config
  (setq minibuffer-line-refresh-interval 1)
  (setq minibuffer-line-format '((:eval
                                  (let ((time-info (format-time-string "%F %H:%M:%S"))
                                        (batt-info (battery-format "%b%p%%%% (%t)" (funcall battery-status-function))))
                                    (concat time-info " | " batt-info)))))
  (minibuffer-line-mode))

;; Ivy
(use-package ivy
  :diminish ivy-mode
  :config
  (ivy-mode t)
  (setq ivy-initial-inputs-alist nil))

;;; Counsel
(use-package counsel
  :after ivy
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :bind (("M-x" . counsel-M-x)
	 ("C-c r" . counsel-rg)
	 ("C-c e" . counsel-linux-app)))

;; Ivy rich
(use-package ivy-rich
  :config
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
  (ivy-rich-mode 1))

;;; Swiper
(use-package swiper
  :bind (("C-s" . swiper)))

;; Amx
(use-package amx
  :after (ivy counsel)
  :custom
  (amx-backend 'auto)
  (amx-save-file (concat user-emacs-directory "amx-items"))
  (amx-history-length 50)
  (amx-show-key-bindings nil)
  :config
  (amx-mode 1))

(use-package dashboard
  :config
  (setq dashboard-center-content t)
  (setq dashboard-set-footer nil)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-items '((projects . 5)
			  (recents . 5)))
  (dashboard-setup-startup-hook))

(set-face-attribute 'default nil :font "Iosevka-13")
(set-frame-font "Iosevka-13" nil t)

(use-package dired-single)

(use-package dired-collapse
  :init
  (dired-collapse-mode 1))

;;; Treemacs
(use-package treemacs
  :defer t
  :config
  (progn
    (setq treemacs-no-png-images t)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
		 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
	("M-0"       . treemacs-select-window)
	("C-x t 1"   . treemacs-delete-other-windows)
	("C-x t t"   . treemacs)
	("C-x t B"   . treemacs-bookmark)
	("C-x t C-t" . treemacs-find-file)
	("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after treemacs projectile)

(use-package treemacs-magit
  :after treemacs magit)

(use-package lsp-treemacs
  :after lsp treemacs
  :config
  (lsp-treemacs-sync-mode 1))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  (c-mode . lsp)
  (c++-mode . lsp)
  (elixir-mode . lsp)
  (go-mode . lsp)
  (java-mode . lsp)
  (nix-mode . lsp)
  (scala-mode . lsp)
  (terraform-mode . lsp)
  (tuareg-mode . lsp)
  (typescript-mode . lsp)
  (yaml-mode . lsp)
  (zig-mode . lsp)
  :config
  (setq lsp-rust-analyzer-server-display-inlay-hints t)
  (setq lsp-enable-snippet nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-rust-analyzer-cargo-watch-command "clippy")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]data$")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\].git$")
  (add-to-list 'lsp-file-watch-ignored "[/\\\\].submodules$")
  :bind (("C-c h" . lsp-describe-thing-at-point)))

(use-package lsp-dart)

(use-package lsp-java)

(use-package lsp-ui)

(use-package lsp-ivy)

(use-package eldoc
  :diminish eldoc-mode)

(use-package dap-mode
  :commands dap-debug
  :config
  (require 'dap-go)
  (dap-go-setup)
  (require 'dap-hydra)
  (require 'dap-gdb-lldb)
  (dap-gdb-lldb-setup))

;;; Languages

;; Flycheck
(use-package flycheck
  :diminish flycheck-mode
  :config
  (flycheck-mode 1))

(use-package rainbow-delimiters
  :config
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode))

;;; Whitespace
(setq require-final-newline t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; Parenthesis
(electric-pair-mode 1)
(show-paren-mode 1)

(use-package prettier
  :config
  :bind (("C-c C-p" . prettier-prettify)))

(use-package nasm-mode
  :config
  (add-hook 'asm-mode-hook 'nasm-mode))

(use-package dart-mode)

(use-package dockerfile-mode)

(use-package elixir-mode)

(add-hook 'elixir-mode-hook
	  (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))

(use-package go-mode
  :config
  (setq gofmt-command "goimports")
  :hook ((go-mode . flycheck-mode)
	 (before-save . gofmt-before-save)))

(use-package graphql-mode)

(use-package groovy-mode)

(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
	 (typescript-mode . tide-hl-identifier-mode)
	 (before-save . tide-format-before-save)
	 (before-save . global-prettier-mode)))

(use-package just-mode)

(use-package nix-mode)

(use-package tuareg)

(use-package dune)

(use-package ocamlformat)

(use-package plantuml-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
  (add-to-list 'display-buffer-alist '("*PLANTUML Preview*" display-buffer-same-window))
  (setq plantuml-default-exec-mode 'jar))

(use-package protobuf-mode)

(use-package rescript-mode)

(use-package ron-mode)

(use-package rustic
  :mode ("\\.rs$" . rustic-mode)
  :config
  (setq rustic-format-trigger 'on-save)
  (setq rustic-lsp-server 'rust-analyzer)
  (setq rustic-format-display-method 'ignore))

(push 'rustic-clippy flycheck-checkers)

(use-package scala-mode
  :interpreter
  ("scala" . scala-mode))

(use-package lsp-metals)

(use-package ejc-sql
  :hook (ejc-sql-minor-mode-hook . company-mode)
  :config (use-package ejc-company
	    :ensure nil
	    :after ejc-sql-mode
	    :config (add-to-list (make-local-variable 'company-backends) 'ejc-company-backend)))

(use-package terraform-mode
  :hook (terraform-mode . terraform-format-on-save-mode))

(use-package toml-mode
  :hook ((toml-mode . display-line-numbers-mode)))

(use-package yaml-mode
  :hook ((yaml-mode . flycheck-mode)
	 (yaml-mode . display-line-numbers-mode)))

(use-package zig-mode)

(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (setq yas-verbosity 1)
  (setq yas-wrap-around-region t)
  (yas-reload-all)
  (yas-global-mode))

(use-package yasnippet-snippets)

;; Always follow symlinks
(setq vc-follow-symlinks t)

;;; Git
(use-package magit
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  (global-set-key (kbd "C-x M-g") 'magit-dispatch))

(use-package forge
  :after magit
  :config
  (global-set-key (kbd "C-x M-f") 'forge-dispatch))

;; cargo install delta
(use-package magit-delta
  :after magit
  :config
  (add-hook 'magit-mode-hook (lambda () (magit-delta-mode +1))))

;; Syntax highlighting for various git related files
(use-package git-modes)

(use-package diff-hl
  :config
  (global-diff-hl-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

;;; Terminal
(use-package vterm
  :init
  (setq vterm-always-compile-module t)
  :config
  (setq vterm-shell (executable-find "zsh"))
  (setq vterm-max-scrollback 100000)
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-buffer-name-string "vterm %s"))

(use-package multi-vterm
  :bind (("C-c t" . multi-vterm-project)))

(use-package vterm-toggle
  :bind (("C-x w" . vterm-toggle-cd))
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (setq vterm-toggle-project-root t)
  (setq vterm-toggle-reset-window-configration-after-exit t)
  (add-to-list 'display-buffer-alist
	       '("^v?term.*"
		 (display-buffer-reuse-window display-buffer-at-bottom)
		 (reusable-frames . visible)
		 (window-height . 0.3))))

;; Copy/paste from the terminal
(use-package xclip
  :when (memq window-system '(x))
  :config
  (xclip-mode 1))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))

(use-package toc-org)

(use-package company
  :diminish company-mode
  :config
  ; No delay in showing suggestions.
  (setq company-idle-delay 0.01)
  ; Show suggestions after entering one character.
  (setq company-minimum-prefix-length 1)
  ; Wrap list around
  (setq company-selection-wrap-around t))

;;; Projectile
(use-package projectile
  :diminish
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  (setq projectile-completion-system 'ivy)
  (setq projectile-switch-project-action 'projectile-dired)
  (setq projectile-git-submodule-command nil)
  :bind (("C-c p f" . projectile-find-file)))

(server-start)

(provide 'init)
;;; init.el ends here
