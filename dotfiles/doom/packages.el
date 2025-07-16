;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el


;; Development Tools
(package! dape)         ; Debugger
(package! eat)          ; Terminal emulator

;; AI Integration
(package! gptel)        ; Claude/GPT interface
(package! claude-code
  :recipe (:host github :repo "stevemolitor/claude-code.el"))

;; Org Mode Enhancements
(package! org-modern)   ; Modern org UI
(package! ox-hugo)      ; Hugo export for blogging

;; Themes
(package! spacemacs-theme) ; Additional theme option
