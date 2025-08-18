;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Personal configuration for Doom Emacs
;; See https://github.com/doomemacs/doomemacs for documentation

;;;; Core Configuration

(setq doom-user-dir "~/nix/dotfiles/doom/"
      ;; Spell checker settings
      ispell-program-name "aspell"
      ispell-dictionary "en")

;;;; UI Configuration

;; Window and Frame Settings
(add-to-list 'default-frame-alist '(undecorated . t))
(add-to-list 'default-frame-alist '(alpha-background . 95))  ; Match alacritty's 95% opacity

;; Font Configuration
(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 12)
      doom-variable-pitch-font doom-font  ; Use same font for consistency
      doom-big-font (font-spec :family "FiraCode Nerd Font" :size 24)
      ;; Nerd Icons
      nerd-icons-font-family "Symbols Nerd Font Mono")

;; Theme and Display Settings
(setq doom-theme 'modus-vivendi-tinted
      display-line-numbers-type 'relative)

;; Theme Toggle - Simplified
(defun my/toggle-theme ()
  "Toggle between dark and light Modus themes."
  (interactive)
  (let ((new-theme (if (eq doom-theme 'modus-vivendi-tinted)
                       'modus-operandi-tinted
                     'modus-vivendi-tinted)))
    (setq doom-theme new-theme)
    (load-theme new-theme t)
    (message "Switched to %s" new-theme)))

;; Dashboard customization - removed redundant face settings


;;;; Org Configuration
;; Base Directory Setup
(setq org-directory "~/Documents")

;; Areas Directory for Main Org Files
(setq org-main-dir (expand-file-name "Areas" org-directory))

;; Recursive Agenda File Discovery
(setq org-agenda-files
      (directory-files-recursively org-directory "\\.org$"))

;; Org Modern - Minimal UI enhancements
(use-package! org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-star '("◉" "○" "●" "○" "●" "○" "●")
        org-modern-hide-stars nil
        org-modern-tag t
        org-modern-priority t
        org-modern-todo t
        ;; Disable table/list/block modifications for simplicity
        org-modern-table nil
        org-modern-list nil
        org-modern-checkbox nil
        org-modern-block-fringe nil
        org-modern-block-name nil
        org-modern-keyword nil))

(after! org
  ;; Org edit settings
  (setq org-auto-align-tags nil
        org-tags-column 0
        org-fold-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t)
  
  ;; Default Capture Files - now pointing to Areas directory
  (setq +org-capture-todo-file (expand-file-name "Todo.org" org-main-dir)
        +org-capture-notes-file (expand-file-name "Inbox.org" org-main-dir)
        +org-capture-journal-file (expand-file-name "Journal.org" org-main-dir)
        +org-capture-project-todo-file "todo.org"
        +org-capture-project-notes-file "notes.org"
        +org-capture-project-changelog-file "changelog.org")

  ;; Helper function for project captures
  (defun my/project-capture-file (filename)
    "Get project-specific capture file path."
    (let* ((root (or (project-root (project-current)) default-directory))
           (name (file-name-nondirectory (directory-file-name root))))
      (expand-file-name (format "%s-%s" name filename) root)))

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
            (lambda () (my/project-capture-file +org-capture-project-todo-file))
            "Todos")
           "* TODO %?\n%i\n%a" :prepend t)
          ("pn" "Project note" entry
           (file+headline
            (lambda () (my/project-capture-file +org-capture-project-notes-file))
            "Notes")
           "* %U %?\n%i\n%a" :prepend t)
          ("pc" "Project changelog" entry
           (file+headline
            (lambda () (my/project-capture-file +org-capture-project-changelog-file))
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
                          (blog-dir (expand-file-name "Areas/Blog/posts" org-directory))
                          (filename (format "%s/%s.org" blog-dir slug)))
                     (unless (file-exists-p blog-dir)
                       (make-directory blog-dir t))
                     (set-register ?t title)
                     filename)))
           ,(concat "#+TITLE: %(get-register ?t)\n"
                    "#+DATE: %<%Y-%m-%d %H:%M:%S %z>>\n"
                    "#+HUGO_DRAFT: true\n"
                    "#+HUGO_CATEGORIES: %^{Categories}\n"
                    "#+HUGO_TAGS: %^{Tags}\n"
                    "\n"
                    "%?")
           :immediate-finish nil
           :unnarrowed t))))

;; EWW configuration removed - module disabled in init.el


;;;; Development Tools

;; Debugger Configuration
(use-package! dape
  :defer t)


;; AI Integration
(use-package! gptel
  :defer t
  :config
  ;; Set API key from environment variable or auth-source
  ;; Export ANTHROPIC_API_KEY in your shell or add to ~/.authinfo.gpg:
  ;; machine api.anthropic.com login claude password YOUR_API_KEY
  (setq gptel-backend
        (gptel-make-anthropic "claude"
          :key (or (getenv "ANTHROPIC_API_KEY")
                   (auth-source-pick-first-password :host "api.anthropic.com")))
        gptel-model 'claude-3-5-sonnet-20241022))

;;;; Keybindings
;; All custom keybindings in one place for clarity

(map! :leader
      ;; Theme
      :desc "Toggle theme" "t t" #'my/toggle-theme
      
      ;; Claude
      (:prefix ("c" . "claude")
       :desc "Start Claude Code" "c" #'claude-code
       :desc "Send command" "s" #'claude-code-send-command
       :desc "Send region" "r" #'claude-code-send-region
       :desc "Fix error at point" "e" #'claude-code-fix-error-at-point
       :desc "Toggle window" "t" #'claude-code-toggle
       :desc "Kill session" "k" #'claude-code-kill
       :desc "Continue conversation" "C" #'claude-code-continue
       :desc "Claude transient menu" "m" #'claude-code-transient)
      
      ;; Debugging
      (:prefix ("d" . "debug")
       :desc "Start/continue" "d" #'dape
       :desc "Stop" "k" #'dape-stop
       :desc "Restart" "r" #'dape-restart
       :desc "Next" "n" #'dape-next
       :desc "Step in" "i" #'dape-step-in
       :desc "Step out" "o" #'dape-step-out
       :desc "Continue" "c" #'dape-continue
       :desc "Toggle breakpoint" "b" #'dape-breakpoint-toggle)
      
      ;; Terminal
      (:prefix ("e" . "eat terminal")
       :desc "Open terminal" "e" #'eat
       :desc "Open in project" "p" #'eat-project)
      
      ;; Publishing
      (:prefix ("P" . "publishing")
       :desc "Publish blog" "b" #'my/publish-blog))

;; Terminal Emulator
(use-package! eat
  :defer t
  :config
  (setq eat-kill-buffer-on-exit t
        eat-enable-yank-to-terminal t))

;; Claude Code Integration
(use-package! claude-code
  :defer t
  :config
  (setq claude-code-terminal-backend 'eat))

;;;; Blog & Publishing
(defcustom my/hugo-base-dir "~/Documents/Projects/tgcg-blog/"
  "Base directory for Hugo blog."
  :type 'directory
  :group 'my-config)

(use-package! ox-hugo
  :after ox
  :config
  (setq org-hugo-base-dir my/hugo-base-dir)
  
  (defun my/publish-blog ()
    "Export the current Org blog post and push changes to Hugo site repository."
    (interactive)
    (unless (file-exists-p org-hugo-base-dir)
      (error "Hugo base directory %s does not exist" org-hugo-base-dir))
    (let ((commit-msg (read-string "Commit message: " "Update blog content")))
      ;; Export the current post
      (org-hugo-export-wim-to-md t)
      ;; Handle the Hugo site repository
      (let ((default-directory org-hugo-base-dir))
        (magit-status)
        (when (y-or-n-p "Proceed with git push? ")
          (shell-command "git add .")
          (shell-command (format "git commit -m \"%s\"" commit-msg))
          (shell-command "git push origin main"))))))
