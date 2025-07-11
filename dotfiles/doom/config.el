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
(setq doom-theme 'modus-vivendi-tinted
      display-line-numbers-type 'relative)

;; Toggle Modus themes
(defun toggle-modus-theme ()
  "Toggle between modus-vivendi-tinted and modus-operandi-tinted themes"
  (interactive)
  (message "Current theme before toggle: %s" doom-theme)
  (if (eq doom-theme 'modus-vivendi-tinted)
      (progn
        (setq doom-theme 'modus-operandi-tinted)
        (load-theme 'modus-operandi-tinted t))
    (progn
      (setq doom-theme 'modus-vivendi-tinted)
      (load-theme 'modus-vivendi-tinted t)))
  (message "New theme after toggle: %s" doom-theme))

(map! :leader
      :desc "Toggle Modus theme"
      "t t" #'toggle-modus-theme)

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

;;;; Eat Terminal Configuration
(use-package! eat
  :config
  ;; Optional: Configure eat settings
  (setq eat-kill-buffer-on-exit t)  ; Kill buffer when process exits
  (setq eat-enable-yank-to-terminal t)  ; Enable yanking in terminal
  
  ;; Optional: Add keybindings for eat
  (map! :leader
        (:prefix ("e" . "eat terminal")
         :desc "Open eat terminal" "e" #'eat
         :desc "Open eat in project" "p" #'eat-project)))

;;;; Claude Code Configuration
(use-package! claude-code
  :config
  (setq claude-code-terminal-backend 'eat)  ; Use eat instead of vterm
  
  ;; Optional: Add leader key bindings for easier access
  (map! :leader
        (:prefix ("c" . "claude")
         :desc "Start Claude Code" "c" #'claude-code
         :desc "Send command" "s" #'claude-code-send-command
         :desc "Send region" "r" #'claude-code-send-region
         :desc "Fix error at point" "e" #'claude-code-fix-error-at-point
         :desc "Toggle window" "t" #'claude-code-toggle
         :desc "Kill session" "k" #'claude-code-kill
         :desc "Continue conversation" "C" #'claude-code-continue
         :desc "Claude transient menu" "m" #'claude-code-transient)))

;;;; Blog Configuration
(after! ox
  (require 'ox-hugo))

(setq org-hugo-base-dir "~/Documents/Projects/tgcg-blog/")

(defun my/publish-blog ()
  "Export the current Org blog post and push changes to Hugo site repository."
  (interactive)
  (let ((commit-msg (read-string "Commit message: " "Update blog content")))
    ;; Export the current post
    (org-hugo-export-wim-to-md t)

    ;; Handle the Hugo site repository
    (let ((default-directory org-hugo-base-dir))
      (magit-status)  ; Show magit status buffer
      (when (y-or-n-p "Proceed with git push? ")
        (shell-command "git add .")
        (shell-command (format "git commit -m \"%s\"" commit-msg))
        (shell-command "git push origin main")))))

;; Key binding should be outside the function definition
(map! :leader
      (:prefix ("P" . "publishing")  ; Capital P is usually free
       :desc "Publish blog" "b" #'my/publish-blog))
