;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;; System Configuration

;; Set the basic doom dotfiles command
(setq doom-user-dir "~/nix/dotfiles/doom/")

;; Add minor outline mode for emacs
(add-hook! 'emacs-lisp-mode-hook #'outline-minor-mode)

;; Set the outline regexp for elisp files
(setq outline-regexp ";;;\\(;*\\)[[:space:]]*")


;;;; UI Configuration

;; Window and Frame Settings
(add-to-list 'default-frame-alist '(undecorated . t))

;; Font Configuration
(setq doom-font (font-spec :family "AnonymicePro Nerd Font" :size 12)
      doom-variable-pitch-font (font-spec :family "AnonymicePro Nerd Font" :size 12)
      doom-big-font (font-spec :family "AnonymicePro Nerd Font" :size 24))

;; Nerd Icons Configuration
(setq nerd-icons-font-family "Symbols Nerd Font Mono"
      nerd-icons-font-names '("Symbols Nerd Font Mono"))

;; Theme and Display Settings
(setq doom-theme 'spacemacs-light
      display-line-numbers-type 'relative)

;; Toggle Spacemacs themes
(defun toggle-spacemacs-theme ()
  "Toggle between spacemacs-light and spacemacs-dark themes"
  (interactive)
  (message "Current theme before toggle: %s" doom-theme)
  (if (eq doom-theme 'spacemacs-light)
      (progn
        (setq doom-theme 'spacemacs-dark)
        (load-theme 'spacemacs-dark t))
    (progn
      (setq doom-theme 'spacemacs-light)
      (load-theme 'spacemacs-light t)))
  (message "New theme after toggle: %s" doom-theme))

(map! :leader
      :desc "Toggle Spacemacs theme"
      "t t" #'toggle-spacemacs-theme)

;; Dashboard customization
(custom-set-faces!
  '(doom-dashboard-banner :inherit default)
  '(doom-dashboard-footer :inherit default)
  '(doom-dashboard-footer-icon :inherit default)
  '(doom-dashboard-menu-title :inherit default)
  '(doom-dashboard-menu-desc :inherit default))


;;;; Org Configuration

;; Base Directory Setup
(setq org-directory "~/Documents")

;; Recursive Agenda File Discovery
(setq org-agenda-files
      (directory-files-recursively "~/Documents" "\\.org$"))

(after! org
  ;; Default Capture Files
  (setq +org-capture-todo-file "Todo.org"
        +org-capture-notes-file "Inbox.org"
        +org-capture-journal-file "Journal.org"
        +org-capture-project-todo-file "todo.org"
        +org-capture-project-notes-file "notes.org"
        +org-capture-project-changelog-file "changelog.org")

  ;; Project Root Helper Function
  (defun my/project-root-or-default ()
    "Get project root or default to current directory."
    (or (project-root (project-current)) default-directory))

  ;; Capture Templates
  (setq org-capture-templates
        `(("t" "Personal")
          ("tt" "Todo" entry
           (file+headline +org-capture-todo-file "Todos")
           "* TODO %?\n%i\n%a" :prepend t)
          ("tn" "Note" entry
           (file+headline +org-capture-notes-file "Notes")
           "* %u %?\n%i\n%a" :prepend t)
          ("tj" "Journal" entry
           (file+olp+datetree +org-capture-journal-file)
           "* %U %?\n%i\n%a" :prepend t)

          ("p" "Project")
          ("pt" "Project todo" entry
           (file+headline
            (lambda ()
              (let ((project-name (file-name-nondirectory (directory-file-name (my/project-root-or-default)))))
                (expand-file-name (format "%s-%s" project-name +org-capture-project-todo-file)
                                  (my/project-root-or-default))))
            "Todos")
           "* TODO %?\n%i\n%a" :prepend t)
          ("pn" "Project note" entry
           (file+headline
            (lambda ()
              (let ((project-name (file-name-nondirectory (directory-file-name (my/project-root-or-default)))))
                (expand-file-name (format "%s-%s" project-name +org-capture-project-notes-file)
                                  (my/project-root-or-default))))
            "Notes")
           "* %U %?\n%i\n%a" :prepend t)
          ("pc" "Project changelog" entry
           (file+headline
            (lambda ()
              (let ((project-name (file-name-nondirectory (directory-file-name (my/project-root-or-default)))))
                (expand-file-name (format "%s-%s" project-name +org-capture-project-changelog-file)
                                  (my/project-root-or-default))))
            "Changelog")
           "* %U %?\n%i\n%a" :prepend t))))


;;;; EWW Configuration

;; Set up EWW window behavior
(set-popup-rules! '(("^\\*eww" :side right :size 0.50 :select t :quit nil)))

(defun my-eww-padding ()
  "Add padding to EWW buffers."
  (setq left-margin-width 2
        right-margin-width 2)
  (set-window-buffer nil (current-buffer)))

(add-hook 'eww-mode-hook #'my-eww-padding)


;;;; DAPE Debugger Configuration
(use-package! dape
  :config

  ;; Optional: Global keybindings
  (map!
   :leader
   :desc "Debug start/continue" "d d" #'dape
   :desc "Debug stop" "d k" #'dape-stop
   :desc "Debug restart" "d r" #'dape-restart
   :desc "Debug next" "d n" #'dape-next
   :desc "Debug step in" "d i" #'dape-step-in
   :desc "Debug step out" "d o" #'dape-step-out
   :desc "Debug continue" "d c" #'dape-continue
   :desc "Toggle Breakpoint" "d b" #'dape-breakpoint-toggle))


;;;; GPT Configuration
(use-package! gptel
  :config
  (setq gptel-backend
        (gptel-make-anthropic "claude"
          :key (concat
                "sk-ant-api03-"
                "PUcLM41l9VdAxbDyGMs5ViaV-"
                "3NLTKqWTMpjQh8K9V4bKmniu9xCb-"
                "ho4Dx1Bfb_yQeu0mAGr3vvMHGyww-"
                "FCg-VG_N0QAA"))
        gptel-model 'claude-3-5-sonnet-20241022))


;;;; Writing Configuration
(after! ox
  (require 'ox-hugo))

(setq org-hugo-base-dir "~/Documents/Blog/")


(setq ispell-program-name "aspell")
(setq ispell-dictionary "en")
