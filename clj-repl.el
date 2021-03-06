;;-------------------------
;; Configuration defaults
(setq default-clj-repl-command "clojure-repl") ; set clj-repl-command to override
(setq default-cljs-repl-command "lein figwheel") ; set cljs-repl-command to override

;; https://marmalade-repo.org/packages/clojure-mode-extra-font-locking
(require 'clojure-mode-extra-font-locking)

(defface clojure-special-chars
    '((t (:foreground "red")))
      "Used for clojure special characters `~@#'%")

(defface clojure-delimiter-chars
    '((t (:foreground "yellow")))
      "Used for clojure delimiters [](){}")

(defun supplement-clojure-font-lock ()
    "Add our extra clojure syntax highlighting"
    (font-lock-add-keywords nil '(("[`~@#'%]" . 'clojure-special-chars)
                                  ("[][(){}]" . 'clojure-delimiter-chars))))

;; Hijacked from
;; https://github.com/clojure-emacs/clojure-mode/blob/master/clojure-mode.el
;; because the original has a deal-breaking check for 'clojure-mode or
;; 'cider-repl-mode.
(defun clojure-space-for-delimiter-p (endp delim)
  "Prevent paredit from inserting useless spaces.
See `paredit-space-for-delimiter-predicates' for the meaning of
ENDP and DELIM."
  (save-excursion
    (backward-char)
    (if (and (or (char-equal delim ?\()
                 (char-equal delim ?\")
                 (char-equal delim ?{))
             (not endp))
        (if (char-equal (char-after) ?#)
            (and (not (bobp))
                 (or (char-equal ?w (char-syntax (char-before)))
                     (char-equal ?_ (char-syntax (char-before)))))
          t)
      t)))

(defun clj-repl-paredit-setup ()
  ;; Stolen from https://github.com/clojure-emacs/clojure-mode/blob/master/clojure-mode.el
  (when (>= paredit-version 21)
    (define-key inferior-lisp-mode-map "{" #'paredit-open-curly)
    (define-key inferior-list-mode-map "}" #'paredit-close-curly)
    (add-to-list 'paredit-space-for-delimiter-predicates
                 #'clojure-space-for-delimiter-p)
    (add-to-list 'paredit-space-for-delimiter-predicates
                 #'clojure-no-space-after-tag)))

(defun start-clj-repl (repl-prog)
  "Start a clojure repl using inferior-lisp mode"
  (inferior-lisp repl-prog)
  (set-syntax-table clojure-mode-syntax-table)
  (clojure-font-lock-setup)
  (supplement-clojure-font-lock)
  (clj-repl-paredit-setup))

(defun ensure-repl (repl-prog)
  "Switch to existing clojure repl or start a new one"
  (let ((repl-window (get-buffer-window "*inferior-lisp*")))
    (if repl-window
        (select-window repl-window)
      (split-window nil nil 'left)))
  (start-clj-repl repl-prog))

(defun clj-repl ()
  (interactive)
  (if (bound-and-true-p clj-repl-command)
      (ensure-repl clj-repl-command)
    (ensure-repl default-clj-repl-command)))

(defun cljs-repl ()
  (interactive)
  (if (bound-and-true-p cljs-repl-command)
      (ensure-repl cljs-repl-command)
    (ensure-repl default-cljs-repl-command)))

