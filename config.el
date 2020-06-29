;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Shanky Surana"
      user-mail-address "shanky.surana@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font (font-spec :family "Monaco" :size 13)
      doom-big-font (font-spec :family "Monaco" :size 18))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-vibrant)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;
;; CUSTOM FUNCTIONS
;;

(defun save-framegeometry ()
  "Gets the current frame's geometry and saves to ~/.emacs.d/framegeometry."
  (let ((framegeometry-left (frame-parameter (selected-frame) 'left))
        (framegeometry-top (frame-parameter (selected-frame) 'top))
        (framegeometry-width (- (frame-parameter (selected-frame) 'width) 1))
        (framegeometry-height (frame-parameter (selected-frame) 'height))
        (framegeometry-file (expand-file-name "~/.emacs.d/framegeometry")))
    (when (not (number-or-marker-p framegeometry-left))
      (setq framegeometry-left 0))
    (when (not (number-or-marker-p framegeometry-top))
      (setq framegeometry-top 0))
    (when (not (number-or-marker-p framegeometry-width))
      (setq framegeometry-width 0))
    (when (not (number-or-marker-p framegeometry-height))
      (setq framegeometry-height 0))
    (with-temp-buffer
      (insert
       ";;; This is the previous emacs frame's geometry.\n"
       ";;; Last generated " (current-time-string) ".\n"
       "(setq initial-frame-alist\n"         "      '(\n"
       (format "        (top . %d)\n" (max framegeometry-top 0))
       (format "        (left . %d)\n" (max framegeometry-left 0))
       (format "        (width . %d)\n" (max framegeometry-width 0))
       (format "        (height . %d)))\n" (max framegeometry-height 0)))
      (when (file-writable-p framegeometry-file)
        (write-file framegeometry-file)))))

(defun load-framegeometry ()
  "Loads ~/.emacs.d/framegeometry which should load the previous frame's geometry."
  (let ((framegeometry-file (expand-file-name "~/.emacs.d/framegeometry")))
    (when (file-readable-p framegeometry-file)
      (load-file framegeometry-file))))

;;
;; PACKAGE SPECIFIC CODE
;;

(use-package! treemacs
  :config
  ;; Set default window width to 26
  (setq treemacs-width 26)
  ;; Make icons better and colorful
  (setq doom-themes-treemacs-theme "doom-colors"))

(use-package! company
  :config
  ;; Start autocomplete after single character is typed
  (setq company-minimum-prefix-length 1)
  ;; Make autocomplete start with 0.1 second delay
  (setq company-idle-delay 0.1))

(use-package! tide
  :preface
  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    (company-mode +1))
  :hook (js2-mode . setup-tide-mode)
  :config
  (setq company-tooltip-align-annotations t)
  (map! :leader
        (:prefix ("m" . "tide")
         ;; Server
         "s" #'tide-restart-server
         ;; Organize imports
         "o" #'tide-organize-imports
         ;; Code refactor
         "r" #'tide-refactor
         ;; Code fixes
         "x" #'tide-fix
         ;; Documentation
         "d" #'tide-jsdoc-template
         ;; Rename
         (:prefix ("n" . "rename")
          "s" #'tide-rename-symbol
          "f" #'tide-rename-file)
         ;; Jump to definition
         (:prefix ("j" . "jump")
          "d" #'tide-jump-to-definition
          "i" #'tide-jump-to-implementation
          "b" #'tide-jump-back)
         ;; Find occurrences
         (:prefix ("f" . "find")
          "r" #'tide-references
          "g" #'tide-goto-reference
          "j" #'tide-cycle-next-reference
          "k" #'tide-cycle-previous-reference)
        ;; Errors
         (:prefix ("e" . "errors")
          "j" #'tide-find-next-error
          "k" #'tide-find-previous-error
          "g" #'tide-goto-error
          "t" #'tide-error-at-point
          "p" #'tide-project-errors))))

;;
;; GLOBAL CODE
;;

;; Special work to do ONLY when there is a window system being used
;; Opens frame to same position and same size on startup as was previously saved
;; Saves frame position and size on exit
(if window-system
    (progn
      (add-hook 'after-init-hook 'load-framegeometry)
      (add-hook 'kill-emacs-hook 'save-framegeometry)))

;; Mouse & Smooth Scroll
;; Scroll one line at a time (less "jumpy" than defaults)
(when (display-graphic-p)
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))
        mouse-wheel-progressive-speed nil))
(setq scroll-step 1
      scroll-margin 0
      scroll-conservatively 100000)
