(require 'flycheck)

(flycheck-define-checker xliff-xmllint
  "A xliff syntax checker and validator using the xmllint utility."
  :command ("xmllint" "--noout" "--schema" (concat (file-name-directory (buffer-file-name)) "xliff.xsd") "-")
  :standard-input t
  :error-patterns
  ((error line-start "-:" line ": " (message) line-end))
  :modes (nxml-mode))


(add-hook 'nxml-mode-hook
          (lambda ()
            (when (string-match-p ".xlf$" (buffer-file-name))
              (flycheck-mode t)
              (flycheck-select-checker 'xliff-xmllint))))

