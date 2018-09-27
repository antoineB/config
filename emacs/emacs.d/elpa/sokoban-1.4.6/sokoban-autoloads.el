;;; sokoban-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "sokoban" "sokoban.el" (23469 2830 308689 121000))
;;; Generated autoloads from sokoban.el

(autoload 'sokoban "sokoban" "\
Sokoban.

Push the blocks onto the target squares.

sokoban-mode keybindings:
   \\<sokoban-mode-map>
\\[sokoban-start-game]	Starts a new game of Sokoban
\\[sokoban-restart-level]	Restarts the current level
\\[sokoban-goto-level]	Jumps to a specified level
\\[fit-frame-to-buffer]	Fit frame to buffer
\\[sokoban-move-left]	Move one square to the left
\\[sokoban-move-right]	Move one square to the right
\\[sokoban-move-up]	Move one square up
\\[sokoban-move-down]	Move one square down

\(fn)" t nil)

(define-key-after (lookup-key global-map [menu-bar tools games]) [sokoban] '(menu-item "Sokoban" sokoban) 'snake)

;;;***

;;;### (autoloads nil nil ("sokoban-pkg.el") (23469 2830 304688 922000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; sokoban-autoloads.el ends here
