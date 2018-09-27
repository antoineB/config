;; My extra stuff for php files  -*- lexical-binding: t; -*-

;; Copyright (C) 2014

;; Author:  <antoineB>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Originaly intented to insert "->" when a space is pressed and the
;; imediate context is expecting "->".


;;; Code:

;; TODO: Maybe better as an input method ?

(provide 'php-extra)
;;; php-extra.el ends here

(require 'auto-complete)
(require 's)
(require 'cl)

(defun array-to-string (a)
  (let ((len (length a))
        (i 0)
        (str ""))
    (while (< i len)
      (setq str
            (concat str (string (aref a i))))
      (setq i (+ i 1)))
    str))

(defun php-variable-before-point ()
  (save-excursion
    (let ((p (point)))
      (and
       (re-search-backward "$[a-z_0-9A-Z]+" (- (point) 30) 'noerror)
       (= p (match-end 0))))))

(defun php-property-before-point ()
  (save-excursion
    (let ((p (point)))
      (and
       (re-search-backward "->[ \t\n]*[a-z_0-9A-Z]+" (- (point) 30) 'noerror)
       (= p (match-end 0))))))

(defun php-str-before-point (str)
  (save-excursion
    (let ((p (point)))
      (and
       (re-search-backward str (- (point) (length str)) 'noerror)
       (= p (match-end 0))))))

(defun php-inside-commentp ()
  (case (get-text-property (point) 'face)
    ((font-lock-doc-face font-lock-comment-face) 't)))

(defun php-inside-stringp ()
  (eq
   'php-string
   (get-text-property (point) 'face)))

(defun php-inside-arrayp ()
  (when (not (or (php-inside-stringp)
                 (php-inside-commentp)))
    (let ((p (point))
          (result nil))
      (save-excursion
        (while (and (re-search-backward "\\[\\|\\(array[ \t\n]*(\\)" (point-min) 'noerror)
                    (not result))
          (save-excursion
            (let* ((mp (- (match-end 0) 1))
                   (pp (parse-partial-sexp mp p)))
              (when (and (nth 9 pp)
                         (-any? (lambda (x) (= mp x)) (nth 9 pp)))
                (setq result 't)))))
        result))))


;; (defun php-statement-end ()
;;   "check if point is at end of a paren that terminate if,elseif, while, foreach, function, for"
;;   (let ((pos (caddr (parse-partial-sexp (- (point) 100) (point))))

(defun php-current-variable-inside-function ()
  (save-excursion
    (let ((region-end (save-excursion (php-end-of-defun) (point)))
          (h (make-hash-table :test 'equal))
          (l '()))
      (php-beginning-of-defun)
      (while (re-search-forward "$[a-z_0-9A-Z]+" region-end 'noerror)
        (let ((str (array-to-string (match-string 0))))
          (when (not (gethash str h nil))
            (puthash str 't h)
            (setq l (cons str l)))))
      l)))

(defun php-after-close-paren ()
  (save-excursion
    (while (or (= 32 (char-before))
               (= 10 (char-before)))
      (backward-char))
    (= 41 (char-before))))

(defun php-after-else ()
  (save-excursion
    (while (or (= 32 (char-before))
               (= 10 (char-before)))
      (backward-char))
    (and (= 101 (char-before))
         (progn
           (backward-char)
           (= 115 (char-before)))
         (progn
           (backward-char)
           (= 108 (char-before)))
         (progn
           (backward-char)
           (= 101 (char-before))))))

(defun php-magic-paren ()
  (interactive)
  (if (or (not (or (php-after-close-paren) (php-after-else)))
          (save-excursion
            (backward-char)
            (or (php-inside-stringp)
                (php-inside-commentp))))
      (self-insert-command 1)
    (when (not (= 32 (char-before)))
      (insert " "))
    (insert "{\n\n}")
    (backward-char) (c-indent-line-or-region)
    (previous-line) (c-indent-line-or-region)))

(defun php-magic-space ()
  (interactive)
  (if (and
       (not (or (php-inside-stringp)
                (php-inside-commentp)))
       (or (php-variable-before-point)
           (= 93 (char-before))
           (save-excursion
             (let ((p (point)))
               (and
                (re-search-backward "->[a-z_0-9A-Z]+" (- (point) 25) 'noerror)
                (= p (match-end 0)))))
           (and (= 41 (char-before))
                (not
                 (or
                  (let ((p (point)))
                    (save-excursion
                      (re-search-backward "\n" (point-min) 'noerror)
                      (re-search-forward "\\(function\\|catch\\|switch\\|foreach\\|if\\)[^a-zA-Z_0-9]" p 'noerror)))
                  (save-excursion
                    (re-search-backward "(int)\\|(bool)\\|(string)\\|(array)\\|(float)\\|(double)" (- (point) 8) 'noerror)))))))
      (insert "->")
    (when (save-excursion
            (re-search-backward "->" (- (point) 2) 'noerror))
      (delete-region (- (point) 2) (point)))
    (self-insert-command 1)))

(defun php-magic-equal ()
  (interactive)
  (cond
   ((or (php-inside-stringp) (php-inside-commentp))
    (self-insert-command 1))
   ((save-excursion
            (re-search-backward "->" (- (point) 2) 'noerror))
    (delete-region (- (point) 2) (point))
    (insert " = "))
   ((or (php-variable-before-point)
        (php-property-before-point)
        (= 41 (char-before))
        (= 93 (char-before)))
    (insert " = "))
   ((save-excursion
      (re-search-backward "= " (- (point) 2) 'noerror))
    (delete-region (- (point) 1) (point))
    (insert "= "))
   (t (self-insert-command 1))))

(defun php-magic-ampersand ()
  (interactive)
  (if (or
       (php-str-before-point " ")
       (php-str-before-point "&")
       (php-str-before-point "(")
       (php-str-before-point ",")
       (php-inside-stringp)
       (php-inside-commentp))
      (self-insert-command 1)
    (insert " && ")))

(defun php-magic-pipe ()
  (interactive)
  (if (or
       (php-str-before-point " ")
       (php-str-before-point "|")
       (php-str-before-point "(")
       (php-str-before-point ",")
       (php-inside-stringp)
       (php-inside-commentp))
      (self-insert-command 1)
    (insert " || ")))

(defun php-magic-question ()
  (interactive)
  (if (or (php-str-before-point " ")
          (php-inside-stringp)
          (php-inside-commentp))
      (self-insert-command 1)
    (insert " ? ")))

(defun php-magic-ddot ()
  (interactive)
  (cond
   ((or (php-str-before-point " ")
        (php-str-before-point ":")
        (php-inside-stringp)
        (php-inside-commentp)
        (save-excursion
          (let ((p (point)))
            (move-beginning-of-line 1)
            (re-search-forward "^[ \t]*case[ \t]" p 'noerror))))
    (self-insert-command 1))
   ((or (php-str-before-point "self")
        (save-excursion
          (let ((p (point)))
            (re-search-backward "[^a-zA-Z0-9_\\]" 1 'noerror)
            (let ((r (re-search-forward "\\(\\(?:\\sw\\|\\\\\\|\\s_\\)+\\)" p 'noerror)))
              (and r (= p r))))))
        (insert "::"))
   (t (insert " : "))))

(defun php-magic-dot ()
  (interactive)
  (if (or
       (save-excursion
         (re-search-backward "[0-9]" (- (point) 1) 'noerror))
       (php-str-before-point " ")
       (php-inside-stringp)
       (php-inside-commentp))
      (self-insert-command 1)
    (insert " . ")))


(defun php-generate-doc-comment-method ()
  "generate doc comment for a method"
  (interactive)
  (php-beginning-of-defun)
  (re-search-forward "function[ \n\t]+[a-zA-Z0-9_]+[ \n\t]*(")
  (let ((beg (point))
        (end (save-excursion
               (re-search-forward ")[ \n\t]*{")
               (point)))
        (elems '())
        (return nil))
    (while (re-search-forward "\\([a-zA-Z0-9_]*\\) *\\($[a-zA-Z0-9_]+\\)[^,)]*[,)]" end 'noerror)
      (setq elems (cons (list (array-to-string (match-string 1))
                              (array-to-string (match-string 2)))
                        elems)))
    (setq return (re-search-forward "return[ \t\n]" (save-excursion (php-end-of-defun) (point)) 'noerror))
    (php-beginning-of-defun)
    (insert "    /**\n"
            (apply 'concat
                   (mapcar
                    (lambda (elem)
                      (concat
                       "     * @param "
                       (if (= 0 (length (car elem))) "mixed" (car elem))
                       " "
                       (cadr elem)
                       "\n"))
                    (reverse elems)))
            (if return
                "     *\n     * @return mixed\n"
              "")
            "     */\n")))


;; (defun php-parse-doc-comment (end-comment)
;;   (let ((elems '()))
;;     (while (re-search-forward "@param " end-comment 'noerror)
;;       (re-search-forward "\\($[a-zA-Z_0-9]+\\)" (save-excursion (end-of-line) (point)) 'noerror)

(defun php-beginning-of-doccomment (&optional arg)
  (interactive "p")
  (let ((arg (or arg 1)))
    (while (> arg 0)
      (re-search-backward "/\\*\\*" nil 'noerror)
      (setq arg (1- arg)))
    (while (< arg 0)
      (end-of-line 1)
      (let ((opoint (point)))
        (php-beginning-of-doccomment 1)
        (forward-list 2)
        (forward-line 1)
        (if (eq opoint (point))
            (re-search-forward "/\\*\\*"
                               nil 'noerror))
        (setq arg (1+ arg))))))



;;(setq selective-display 8) to mask function definition in php

(defun comment-facep (face)
  (or (eq face 'php-annotations-annotation-face)
      (eq face 'font-lock-comment-delimiter-face)
      (eq face 'font-lock-comment-face)))

(defun next-comment-begin (pos)
  (let ((prop-pos (next-single-property-change pos 'face (current-buffer)))
        (old-pos pos))
    (while (and (not (comment-facep (get-text-property prop-pos 'face)))
                (not (= old-pos prop-pos)))
      (setq old-pos prop-pos)
      (setq prop-pos (next-single-property-change prop-pos 'face (current-buffer))))
    (when (not (= old-pos prop-pos)) prop-pos)))

(defun next-comment-end (pos)
  (let ((prop-pos (next-single-property-change pos 'face (current-buffer)))
        (old-pos pos))
    (while (and (comment-facep (get-text-property prop-pos 'face))
                (not (= old-pos prop-pos)))
      (setq old-pos prop-pos)
      (setq prop-pos (next-single-property-change prop-pos 'face (current-buffer))))
    prop-pos))

(defun next-comment-range (pos)
  (let ((beg (next-comment-begin pos)))
    (when beg
      (list
       beg
       (next-comment-end beg)))))

(defun php-hl-variable-inside-defun (name)
  (interactive "sname: ")
  (save-excursion
    (php-beginning-of-defun)
    (let ((start (search-forward "{"))
          (end (scan-sexps (1- (point)) 1))
          (name-length (length name)))
      (while (re-search-forward name end 't)
        (when (equalp 'font-lock-variable-name-face (get-text-property (match-beginning 0) 'face))
          (let ((o (make-overlay (match-beginning 0)
                                 (match-end 0))))
            (overlay-put o 'face 'highlight)))))))

;; ;; (defun eval-and-replace-last-sexp ()
;; ;;   (interactive)
;; ;;   (eval-last-sexp)

(defun php--use-to-name ()
  (when (re-search-forward "use \\(\\([a-zA-Z_0-9-]+[\\\\]\\)*\\)\\([a-zA-Z_0-9-]+\\)\\([ ]+as[ ]+\\([a-zA-Z_0-9-]+\\)\\)?;\n"
                         (point-max)
                         'noerror))
      (list (match-beginning 0) (match-end 0)
            (if (match-string 5)
                (array-to-string (match-string 5))
              (array-to-string (match-string 3)))
            (concat
             (array-to-string (match-string 1))
             (array-to-string (match-string 3)))))

(defun php--use-names ()
  (save-excursion
    (goto-char (point-min))
    (let ((names '())
          (tmp (php--use-to-name)))
      (while tmp
        (setq names (cons tmp names))
        (setq tmp (php--use-to-name)))
      names)))

(defun php--namespace-names ()
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward
           "namespace \\(\\([a-zA-Z_0-9-]+[\\\\]\\)*\\)\\([a-zA-Z_0-9-]+\\);\n"
           (point-max)
           'noerror)
      (let ((namespace (concat (array-to-string (match-string 1))
                               (array-to-string (match-string 3)) "\\"))
            (files (f-files (file-name-directory (buffer-file-name (current-buffer))) nil))
            (r '()))
        (while files
          (when (s-ends-with? ".php" (car files))
            (setq
             r
             (cons
              (let ((name (car
                           (s-split "\\." (car (reverse (s-split "/" (car files))))))))
                (list nil nil
                      name
                      (concat namespace name)))
              r)))
          (setq files (cdr files)))
        r))))


(defun list-uniq (lst)
  (let ((h (make-hash-table :test 'equal))
        (l lst)
        (keys '()))
    (while l
      (when (not (gethash (car l) h))
        (puthash (car l) 't h)
        (cons (car l) keys))
      (setq l (cdr l)))
    keys))

;; Publication.php est un bon choix de test car rien ne marche
(defun php--namespace-uses ()
  (save-excursion
    (goto-char (point-min))
    (let ((uses (make-hash-table :test 'equal)))
      (while (re-search-forward
              (concat
               ;; not in string and comment
               "\\(new[ \t\n]+\\([a-zA-Z_0-9]+\\)\\)\\|" ;; 2
               "\\([^\\a-zA-Z_0-9]\\([a-zA-Z_0-9]+\\)::\\)\\|" ;; 4
               "\\([^\\a-zA-Z_0-9]\\([a-zA-Z_0-9]+\\)[ \t\n]+[$]\\)\\|" ;; 6
               "\\(use\\|namespace[ \n\t]+[a-zA-Z_0-9]+\\)\\|" ;; 7
               ;; use, namespace is take into account and 'as'
               "\\([^\\a-zA-Z_0-9]\\([a-zA-Z_0-9]+\\)[\\]\\)") ;; 9
              (point-max)
              'noerror)
        (let ((face (get-text-property (match-beginning 0) 'face)))
          (when (not (or (equalp 'php-string face)
                         (equalp 'font-lock-comment-face face)
                         (equalp 'font-lock-keyword-face face)))
            (setq uses (cons (cond
                              ((match-beginning 2) (array-to-string (match-string 2)))
                              ((match-beginning 4) (array-to-string (match-string 4)))
                              ((match-beginning 6) (array-to-string (match-string 6)))
                              ((match-beginning 7) (end-of-line) nil)
                              ((match-beginning 9)
                               (let ((str (array-to-string (match-string 9))))
                                 (when (not (or (equalp str "instanceof")
                                                (equalp str "as")))
                                   str))))
                             uses)))))
      uses)))


;; in comment
;;"@param[ \n\t]+\\([a-zA-Z_0-9]+\\)[^\\]"





(defun lst-string-to-re-inner (lst str)
  (if (not lst)
      str
    (lst-string-to-re-inner
     (cdr lst)
     (concat str "\\|" (car lst)))))

(defun lst-string-to-re (lst)
  (if (not lst)
      ""
    (concat "\\("
            (car lst)
            (lst-string-to-re-inner (cdr lst) "")
            "\\)")))

(defun php--unused-names ()
  (let ((names (php--use-names)))
    (save-excursion
      (goto-char (point-min))
      (when (search-forward "class " (point-max) (lambda () nil))
        (while (and
                (re-search-forward
                 ;;new[ \n]+Class
                 ;;Class::
                 ;;Class\
                 ;;(|,[ \n]*Class $var
                 (lst-string-to-re (mapcar 'caddr names))
                 (point-max) (lambda () nil))
                names)
          (let ((tmp names)
                (str (array-to-string (match-string 2))))
            (setq names '())
            (while tmp
              (when (not (equalp str (caddar tmp)))
                (setq names (cons (car tmp) names)))
              (setq tmp (cdr tmp)))))
        names))))

(defun php--search-use-class ()
  (let ((names '()))
    (save-excursion
      (goto-char (point-min))
      (when (search-forward "class " (point-max) (lambda () nil))
        (while (re-search-forward
                (concat
                 "\\(new[ \n]+\\(HttpException\\)\\)\\|"
                 "\\(\\(HttpException\\)::\\)\\|"
                 "\\(\\(HttpException\\)[\\]\\)\\|"
                 "\\([(,][ \n]*\\(HttpException\\)[ \n]+[$]\\)")
                (point-max)
                (lambda () nil))
          (setq names
                (cons
                 (cond ((match-string 2) (array-to-string (match-string 2)))
                       ((match-string 4) (array-to-string (match-string 4)))
                       ((match-string 6) (array-to-string (match-string 6)))
                       ((match-string 8) (array-to-string (match-string 8))))
                 names)))
        (list-uniq names)))))
