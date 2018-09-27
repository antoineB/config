;; You should define "app/console" command binary.

(require 'flycheck)
(flycheck-define-checker web-mode-twig-lint
  "A twig syntax linter using the symfony lint:twig utility."
  :command ("app/console" "lint:twig" "--no-ansi")
  :standard-input t
  :error-patterns
  ((error line-start (* " ") ">>" (* " ") line (* any) "\n" (* " ") ">>" (* " ") (message) line-end))
  :modes (web-mode))
