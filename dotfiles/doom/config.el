;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;; System Configuration

;; Set the basic doom dotfiles command
(setq doom-user-dir "~/nix/dotfiles/doom/")

;; Add minor outline mode for emacs
(add-hook! 'emacs-lisp-mode-hook #'outline-minor-mode)

;; Set the outline regexp for elisp files
(setq outline-regexp ";;;\\(;*\\)[[:space:]]*")

;; Set spell checker
(setq ispell-program-name "aspell")
(setq ispell-dictionary "en")

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

;; Areas Directory for Main Org Files
(setq org-main-dir (expand-file-name "Areas" org-directory))

;; Recursive Agenda File Discovery
(setq org-agenda-files
      (directory-files-recursively org-directory "\\.org$"))

;; Org Modern Setup
(use-package! org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  (setq
   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-fold-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; Org Modern UI tweaks
   org-modern-star '("◉" "○" "●" "○" "●" "○" "●")
   org-modern-hide-stars nil              ; Show the leading stars
   org-modern-checkbox nil                ; Don't use custom checkboxes
   org-modern-tag t                       ; Use modern tags
   org-modern-priority t                  ; Use modern priorities
   org-modern-todo t                      ; Use modern todo keywords
   org-modern-table nil                   ; Don't modify tables
   org-modern-list nil                    ; Don't modify lists

   ;; Margin settings
   org-modern-block-fringe nil
   org-modern-block-name nil
   org-modern-keyword nil))

(after! org
  ;; Default Capture Files - now pointing to Areas directory
  (setq +org-capture-todo-file (expand-file-name "Todo.org" org-main-dir)
        +org-capture-notes-file (expand-file-name "Inbox.org" org-main-dir)
        +org-capture-journal-file (expand-file-name "Journal.org" org-main-dir)
        +org-capture-project-todo-file "todo.org"
        +org-capture-project-notes-file "notes.org"
        +org-capture-project-changelog-file "changelog.org")

  ;; Project Root Helper Function
  (defun my/project-root-or-default ()
    "Get project root or default to current directory."
    (or (project-root (project-current)) default-directory))

  ;; Capture Templates - Combined into one list
  (setq org-capture-templates
        `(;; Personal Capture Templates
          ("t" "Personal")
          ("tt" "Todo" entry
           (file+headline +org-capture-todo-file "Todos")
           "* TODO %?\n%i\n%a" :prepend t)
          ("tn" "Note" entry
           (file+headline +org-capture-notes-file "Notes")
           "* %u %?\n%i\n%a" :prepend t)
          ("tj" "Journal" entry
           (file+olp+datetree +org-capture-journal-file)
           "* %U %?\n%i\n%a" :prepend t)

          ;; Project Capture Templates
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
           "* %U %?\n%i\n%a" :prepend t)

          ;; Blog Capture Template
          ("b" "Blog post" plain
           (file (lambda ()
                   (let* ((title (read-string "Post title: "))
                          (slug (replace-regexp-in-string
                                 " " "-"
                                 (downcase (replace-regexp-in-string
                                            "[^a-zA-Z0-9 ]" ""
                                            title))))
                          (filename (format "~/Documents/Areas/Blog/posts/%s.org"
                                            slug)))
                     (set-register ?t title)  ; Store the title in register t
                     filename)))
           ,(concat "#+TITLE: %(get-register ?t)\n"  ; Use Lisp evaluation to get the title
                    "#+DATE: %<%Y-%m-%d %H:%M:%S %z>>\n"
                    "#+HUGO_DRAFT: true\n"
                    "#+HUGO_CATEGORIES: %^{Categories}\n"
                    "#+HUGO_TAGS: %^{Tags}\n"
                    "\n"
                    "%?")
           :immediate-finish nil
           :unnarrowed t))))

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


;;;; Blog Configuration
(after! ox
  (require 'ox-hugo))
(setq org-hugo-base-dir "~/Documents/Projects/tgcg-blog/")
;; Add this line to change default image directory
(setq org-hugo-default-static-subdirectory "images")
;; Also enable automatic image copying
(setq org-hugo-export-with-images t)

(defun my/publish-blog ()
  "Export org blog posts and push changes to Hugo site repository."
  (interactive)
  (let* ((default-directory "~/Documents/Areas/Blog/")
         (commit-msg (read-string "Commit message: " "Update blog content")))
    ;; First export all blog posts
    (org-hugo-export-wim-to-md t)
    ;; Then handle the Hugo site repository
    (let ((default-directory org-hugo-base-dir))
      (magit-status)  ; Show magit status buffer
      (when (y-or-n-p "Proceed with git push? ")
        (shell-command "git add content/ static/")  ;; Note the addition of static/ here
        (shell-command (format "git commit -m \"%s\"" commit-msg))
        (shell-command "git push origin main")))))

;; Key binding should be outside the function definition
(map! :leader
      (:prefix ("P" . "publishing")  ; Capital P is usually free
       :desc "Publish blog" "b" #'my/publish-blog))
