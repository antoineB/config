;;; merlin-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "merlin" "merlin.el" (23469 2885 608179 529000))
;;; Generated autoloads from merlin.el

(autoload 'merlin-mode "merlin" "\
Minor mode for interacting with a merlin process.
Runs a merlin process in the background and perform queries on it.

Short cuts:
\\{merlin-mode-map}

\(fn &optional ARG)" t nil)

;;;***

;;;### (autoloads nil "merlin-company" "merlin-company.el" (23469
;;;;;;  2885 584179 841000))
;;; Generated autoloads from merlin-company.el

(autoload 'merlin-company-backend "merlin-company" "\


\(fn COMMAND &optional ARG &rest IGNORED)" t nil)

;;;***

;;;### (autoloads nil "merlin-xref" "merlin-xref.el" (23469 2885
;;;;;;  552180 260000))
;;; Generated autoloads from merlin-xref.el

(autoload 'merlin-xref-backend "merlin-xref" "\
Merlin backend for Xref.

\(fn)" nil nil)

;;;***

;;;### (autoloads nil nil ("merlin-ac.el" "merlin-cap.el" "merlin-iedit.el"
;;;;;;  "merlin-imenu.el" "merlin-pkg.el") (23469 2885 600179 633000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; merlin-autoloads.el ends here
