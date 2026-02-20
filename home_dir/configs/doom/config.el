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
(setq doom-font (font-spec :size 16))
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; (setq doom-theme 'vscode-dark-plus)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type `relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq treesit-language-source-alist
      '((rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.21.2")))
(setq treesit-extra-load-path '("~/.config/emacs/.local/etc/tree-sitter"))

(setq treesit-font-lock-level 4)
(after! lsp-rust
  (setq lsp-rust-analyzer-display-chaining-hints t
        lsp-rust-analyzer-display-parameter-hints t
        lsp-rust-analyzer-display-closure-return-type-hints t)
  ;; Use Clippy instead of Cargo Check for better "Quick Fix" suggestions
  (setq lsp-rust-analyzer-cargo-watch-command "clippy"))
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

;; (after! evil
;;   (map! :n "J" :desc "Join lines"           "mzJ`z"
;;         :n "n" :desc "Next search"          "nzzzv"
;;         :n "N" :desc "Prev search"          "Nzzzv"
;;         :i "C-c" :desc "Exit insert"        [escape] ; Fixed syntax
;; ;; 4. Map C-c to Escape in insert mode
;; (map! :i "C-c" :desc "Exit insert mode" <escape>)
;; (map! :leader :g )
(map! :after evil-mode
      :n "C-d" (cmd! (evil-scroll-down 0) (evil-scroll-line-to-center (line-number-at-pos)))
      :n "C-u" (cmd! (evil-scroll-up 0) (evil-scroll-line-to-center (line-number-at-pos))))

(map! :nvie "C-c" [escape])

(map! :leader
      :desc "Make file executable" "x" (cmd! (shell-command (format "chmod +x %s" (buffer-file-name)))))

(map! :n "J" (cmd! (evil-set-marker ?z)
                   (evil-join (line-end-position) (line-end-position 2))
                   (evil-goto-mark ?z)))

(map! :nvie "C-S-c" #'kill-ring-save    ; Global Copy
      :ni   "C-S-v" #'yank              ; Normal/Insert: Just Paste
      :v    "C-S-v" "\"_dP")            ; Visual: Replace without overwriting clipboard

(after! evil
  (define-key evil-normal-state-map (kbd "x") 'evil-delete-char-to-black-hole)
  (define-key evil-visual-state-map (kbd "x") 'evil-delete-char-to-black-hole)
  (define-key evil-normal-state-map (kbd "X") 'evil-delete-backward-char-to-black-hole))

(defun evil-delete-char-to-black-hole ()
  "Delete character without affecting clipboard."
  (interactive)
  (let ((evil-this-register ?_))
    (call-interactively 'evil-delete-char)))

(defun evil-delete-backward-char-to-black-hole ()
  "Delete character backward without affecting clipboard."
  (interactive)
  (let ((evil-this-register ?_))
    (call-interactively 'evil-delete-backward-char)))

(setq projectile-project-search-path '("~/Tmp/" 
                                       "~/vu/"
                                       "~/vu/cyberlab"
                                       "~/vu/data_visualization/"
                                       "~/vu/rust/"
                                       "~/vu/web_dev"
                                       "~/dotfiles-arch/"
                                       "~/dotfiles-arch/home_dir/"))

(after! corfu
  (setq corfu-popupinfo-delay '(0.5 . 0.2)
        corfu-popupinfo-max-width 120
        corfu-popupinfo-min-width 120
        corfu-popupinfo-max-height 80)
  (map! :map corfu-map
        "M-n" #'corfu-popupinfo-scroll-up
        "M-p" #'corfu-popupinfo-scroll-down))

(setq projectile-enable-caching t  ; Don't re-scan every single time
      projectile-indexing-method 'hybrid) ; Use native 'find' or 'fd' if available (much faster)

(setq projectile-globally-ignored-directories '(".git" "node_modules" "target" "dist")
      projectile-globally-ignored-files '(".DS_Store" "TAGS"))

(map! :n "n" (cmd! (evil-ex-search-next) (evil-scroll-line-to-center (line-number-at-pos)) (evil-open-fold))
      :n "N" (cmd! (evil-ex-search-previous) (evil-scroll-line-to-center (line-number-at-pos)) (evil-open-fold)))

(map! :v "C-b" (cmd! (execute-kbd-macro "S*")))
(setq confirm-kill-processes nil)

(setq scroll-margin 8)
(setq-default tab-width 4)
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
