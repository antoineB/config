(require 'eshell)
(require 'em-term)

(add-to-list 'eshell-visual-commands "htop")
(add-to-list 'eshell-visual-commands "git")
;;(add-to-list 'eshell-visual-commands "less")
;;(setenv "PAGER" "cat")

(setq eshell-visual-subcommands
      '(("git" "log")))
