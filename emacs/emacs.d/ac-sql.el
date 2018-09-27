;;; ac-sql.el --- auto complete for sql              -*- lexical-binding: t; -*-

;; Copyright (C) 2016

;; Author:  <antoine@isidore>
;; Keywords:

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

;; ac-sql

;;; Code:

;; (defun ac-sql--extract-tables ()
;;   (sql-beginning-of-statement (point))
;;   (let ((max
;;          (save-excursion
;;            (sql-end-of-statement (point))
;;            (if (= 0 (point))
;;                (point-max)
;;              (point)))))
;;     (re-search-forward "from\\|FROM" max)
;;     ;; TODO: limit to WHERE|ORDER|LIMIT|HAVING
;;   (re-search-forward "\\([a-zA-Z0-9_]+\\) +AS\\|as +\\([a-zA-Z0-9_]+\\)" max)
;;   (match-string

(defvar ac-sql-db-definitions nil)

(load-file "ac-sql-data.el")


(defun ac-sql--source-table-fn ()
  (let ((db (assoc sql-database ac-sql-db-definitions)))
    (if db
        (cdr db)
      '())))

(defvar ac-sql-source-table nil)
(setq ac-sql-source-table
  '((candidates . ac-sql--source-table-fn)
    (symbol . "𝕊")
    (requires . 2)
    (cache)
    (prefix . "\\(?:from\\|join\\|FROM\\|JOIN\\)\s+\\(.*\\)")))

(defvar ac-sql-source-keywords
  '((candidates . (list ;; "SELECT"
                        ;; "FROM"
                        ;; "JOIN"
                        ;; "LEFT"
                        ;; "INNER"
                        ;; "AS"
                        ;; "ORDER"
                        ;; "BY"
                        ;; "HAVING"
                        ;; "LIMIT"
                        ;; "DESC"
                        ;; "ASC"
                        ;; "WITH"
                        ;; "ON"
                        ;; "WHERE"
                        ;; "LIKE"
                        ;; "ILIKE"
                        ;; "OR"
                        ;; "AND"
                        "select"
                        "from"
                        "join"
                        "left"
                        "inner"
                        "as"
                        "order"
                        "by"
                        "having"
                        "limit"
                        "desc"
                        "asc"
                        "with"
                        "on"
                        "where"
                        "like"
                        "ilike"
                        "or"
                        "and"))
    (symbol . "𝕊")
    (requires . 0)
    (cache)
    (prefix . "[^a-zA-Z_-]\\([a-zA-Z]+\\)")))

(defvar ac-sql-source-types
  '((candidates . (list "int4range"
                        "int8range"
                        "numrange"
                        "tsrange"
                        "tstzrange"
                        "daterange"
                        "any"
                        "anyarray"
                        "anyelement"
                        "anyenum"
                        "anynonarray"
                        "cstring"
                        "internal"
                        "language_handler"
                        "fdw_handler"
                        "record"
                        "trigger"
                        "void"
                        "opaque"
                        "bit"
                        "bit()"
                        "bit varying"
                        "bit varying()"
                        "bigint"
                        "int8"
                        "bigserial"
                        "serial8"
                        "boolean"
                        "bool"
                        "box"
                        "bytea"
                        "character"
                        "character()"
                        "char"
                        "char()"
                        "character varying"
                        "character varying()"
                        "varchar()"
                        "varchar"
                        "cidr"
                        "circle"
                        "date"
                        "double precision"
                        "float8"
                        "inet"
                        "integer"
                        "int"
                        "int4"
                        ;; TODO interval [ fields ] [ (p) ]
                        "json"
                        "jsonb"
                        "line"
                        "lseg"
                        "macaddr"
                        "money"
                        "numeric"
                        "numeric(p,s)"
                        "decimal"
                        "decimal(p,s)"
                        "path"
                        "pg_lsn"
                        "point"
                        "polygon"
                        "real"
                        "float4"
                        "smallint"
                        "int2"
                        "smallserial"
                        "serial2"
                        "serial"
                        "serial4"
                        "text"
                        "time"
                        "time without time zone"
                        "time with time zone"
                        "time(0) without time zone"
                        "time(0) with time zone"
                        "timestamp without time zone"
                        "timestamp with time zone"
                        "timestamp(0) without time zone"
                        "timestamp(0) with time zone"
                        "timetz"
                        "timestamptz"
                        "tsquery"
                        "tsvector"
                        "txid_snapshot"
                        "uuid"
                        "xml"
                        ;; TODO rajouter "[]" a tous les types?
                        ))
    ;; TODO enum type
    ;; TODO composite type

    (symbol . "𝕊")
    (requires . 0)
    (cache)
    (prefix . "::\\([a-zA-Z]+\\)")))

;; TODO: add standard function

(defun ac-sql-setup ()
  (interactive)
  (add-to-list 'ac-sources 'ac-sql-source-types)
  (add-to-list 'ac-sources 'ac-sql-source-keywords)
  (add-to-list 'ac-sources 'ac-sql-source-table))

(provide 'ac-sql)
;;; ac-sql.el ends here

(require 'cl)
;; LEXER idea, from point-min to point-max lex the buffer and update
;; the tokens as the user type.

;; Lex only the interesting things like :
;;
;; WHERE JOIN FROM SELECT WITH AS ORDER LIMIT identifier COMMA SEMICOLON DOT COMMENT string

(defvar sql--identifier-marker '("\"" . "\\\""))
(defvar sql--string-marker '("'" . "''"))

(defun sql--lex-next-token ()
  (cl-case (char-after)
    ((?\.) `(DOT ,(point) 1))
    ((?\;) `(SEMICOLON ,(point) 1))
    ((?\,) `(COMMA ,(point) 1))
    ((?\() `(OPAREN ,(point) 1))
    ((?\)) `(CPAREN ,(point) 1))
    (otherwise
     (cond
      ((looking-at "\[[:space:]\r\n\]+")
       (goto-char (match-end 0))
       (sql--lex-next-token))
      ((looking-at "\\(SELECT\\|select\\|Select\\)\\b")
       `(SELECT ,(point) 7))
      ((looking-at "\\(JOIN\\|join\\|Join\\)\\b")
        `(JOIN ,(point) 4))
      ((looking-at "\\(FROM\\|from\\|From\\)\\b")
       `(FROM ,(point) 4))
      ((looking-at "\\(WITH\\|with\\|With\\)\\b")
       `(WITH ,(point) 4))
      ((looking-at "\\(WHERE\\|where\\|Where\\)\\b")
       `(WHERE ,(point) 5))
      ((looking-at "\\(LIMIT\\|limit\\|Limit\\)\\b")
       `(LIMIT ,(point) 5))
      ((looking-at "\\(ORDER\\|order\\|Order\\)\\b")
       `(ORDER ,(point) 5))
      ((looking-at "\\(HAVING\\|having\\|Having\\)\\b")
       `(HAVING ,(point) 5))
      ((looking-at "\\(AS\\|as\\|As\\)\\b")
       `(AS ,(point) 5))
      ((looking-at "/[*]")
       (let ((start (point))
       `(COMMENT ,start
                 (- (or (re-search-forward "[*]/" (point-max) t) (point-max)) start)))))
      ((looking-at "--[^\n]*\n")
       `(COMMENT ,(point) ,(- (match-end 0) (point))))
      ((looking-at (concat (car sql--identifier-marker) "\\(" (cdr sql--identifier-marker) "\\|\[^" (car sql--identifier-marker) "\]\\)+" (car sql--identifier-marker)))
       `(IDENTIFIER ,(point) ,(- (match-end 0) (point))))
      ((looking-at (concat (car sql--string-marker) "\\(" (cdr sql--string-marker) "\\|\[^" (car sql--string-marker) "\]\\)+" (car sql--string-marker)))
       `(STRING ,(point) ,(- (match-end 0) (point))))
      ((looking-at "\[^.,;()[:space:]\r\n\]+")
       `(KEYWORD-OR-IDENTIFIER ,(point) ,(- (match-end 0) (point))))
      ((= (point) (point-max))
       nil)
      (t
       (right-char 1)
       (sql--lex-next-token))))))


(require 'cl)

;; TODO:
(defun sql--end-of-select-stmt (point)
  (point-max))

(defun sql--maybe-select-beginning-with (min)
  ;; From point which is expected to be before a SELECT, read char backward until ?\)
  (looking-back ")\[[:space:]\r\n\]*")

;; TODO: WITH is not take into account
(defun sql--beginning-of-select-stmt (point)
  (when (not (equalp nil (re-search-backward "SELECT\\|select\\|)" (point-min) t)))
    (if (= (char-after) ?\))
        (let ((parse-sexp-ignore-comments 't))
          (goto-char (scan-sexps (+ 1 (point)) -1))
          (sql--beginning-of-select-stmt (point)))
      (sql--maybe-beginning-with (point-min)))))



;; ' for mysql " for postgres
(defvar ac-sql--separator "\"")

      ;; exemple
      ;; select * from (select toto from maison) as toto


(defun ac-sql--extract-select (min max)
  (let ((ident-re (concat "\\(" ac-sql--separator "?\[a-zA-Z0-9 -_.\]+" ac-sql--separator "?\\)"))
        (space-re "\[[:space:]\r\n\]")
        (end (or (re-search-forward "FROM\\|from" max t) max)))
  (save-excursion
    (goto-char min)
    (when (re-search-forward "SELECT\\|select" end t)
      (let ((stop nil)
            (result '()))
        (cl-loop
         until stop
         do (cond
             ;; TODO: "[*]" "alias.*"
             ((re-search-forward (concat ident-re space-re "*,") end t)
              (setq result (cons (match-string-no-properties 1) result)))
             ((re-search-forward (concat ident-re space-re "*FROM\\|from") end t)
              (setq result (cons (match-string-no-properties 1) result)
                    stop t))
             ((and (re-search-forward (concat ident-re space-re "*") end t)
                   (= end (match-end 0)))
              (setq result (cons (match-string-no-properties 1) result)
                    stop t))
             (t (setq stop t))))
        result)))))




(defun ac-sql--parse ()
  (sql--beginning-of-select-stmt (point))
  (let (result '())
        (end-statement (sql--end-of-select-stmt))
        (ident-re (concat "\\(" ac-sql--separator "?\[a-zA-Z0-9 -_.\]+" ac-sql--separator "?\\)"))
        (space-re "\[[:space:]\r\n\]"))
    (cl-loop until (equalp nil (re-search-forward "\\((\\|FROM\\|JOIN\\|join\\|from\\)\[[:space:]\r\n\]"))
             do
             (if (= ?\( (char-before))
                 (goto-char (scan-sexps (- (point) 1) 1))
               (cond
                ;; FROM (SELECT ...)
                ((looking-at-p "(\[[:space:]\r\n\]*\\(SELECT\\|select\\)")
                 (ac-sql--extract-select (point) (scan-sexps (point) 1)))
                ;; FROM table_name [[AS] name]
                ((looking-at (concat space-re "*" ident-re "\\(" space-re "+\\(\\(AS\\|as\\)" space-re "+\\)?" indent-re "\\)?"))

                 )

            ;; just le nom d'une table
            ;; des truc AS nom
            ;; on doit regarder si il y a une virgule
            )

;; parse-partial-sexp
;;   ;; SELCET * FROM (SELECT *() ) AS toto;"
;;   (looking-at-p "(\[[:space:]\n\r\]*\\(SELECT\\|select\\)\[[:space:]\n\r\]*")

               ;; SELECT * FROM (SELECT * from ttutu) AS toto;


(setq ac-sql-db-table-definitions
      '(("db_name" .
         (("table_name" . ("col_1"
                        "col_2"
                        "col_3"))
          ("table_name_2" . ("col_1"
                        "col_2"))))))




(setq ac-sql-db-definitions
      '(("db_name_3" . ("table_name_1" "table_name_2"))
        ("db_name_2" . ("table_name_1"
                       "table_name_2"
                       "table_name_3"))))
