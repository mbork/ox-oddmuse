;;; ox-oddmuse.el --- Org-mode exporter for Oddmuse

;; Copyright (C) 2015 Marcin 'mbork' Borkowski

;; Author: Marcin Borkowski <mbork@mbork.pl>
;; Keywords: outlines, hypermedia, calendar, wp

;; This file is NOT part of GNU Emacs.

;; ox-oddmuse.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ox-oddmuse.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ox-oddmuse.el.
;; If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; A simple Org-mode exporter for the Oddmuse wiki engine (i.e., more
;; or less the WikiCreole standard).  Written both as a (hopefully)
;; useful tool and as an example of exporters for the talk during
;; EmacsConf 2015.

(require 'cl-lib)
(require 'ox)

;;; Code:

(defcustom ox-oddmuse-menu-key ?a
  "The dispatch key for the Oddmuse exporter in the exporter menu.")

(org-export-define-backend 'oddmuse
  '((plain-text . org-oddmuse-plain-text)
    (italic . org-oddmuse-italic)
    (bold . org-oddmuse-bold)
    (verbatim . org-oddmuse-verbatim)
    (code . org-oddmuse-verbatim)	; this is on purpose!
    (plain-list . org-oddmuse-plain-list)
    (item . org-oddmuse-item)
    (link . org-oddmuse-link)
    (line-break . org-oddmuse-line-break)
    (horizontal-rule . org-oddmuse-horizontal-rule)
    (example-block . org-oddmuse-example-block)
    (src-block . org-oddmuse-src-block)
    (fixed-width . org-oddmuse-fixed-width)
    (paragraph . org-oddmuse-paragraph)
    (headline . org-oddmuse-headline)
    (section . org-oddmuse-section)
    (template . org-oddmuse-template))
   :menu-entry `(,ox-oddmuse-menu-key "Export to Oddmuse"
				     ((,(upcase ox-oddmuse-menu-key)
				       "As buffer" org-oddmuse-export-as-oddmuse)
				      (,(downcase ox-oddmuse-menu-key)
				       "As file" org-oddmuse-export-to-oddmuse))))

(defun org-oddmuse-plain-text (text info)
  "Transcode a TEXT string from Org to Oddmuse.
TEXT is the string to transcode.  INFO is a plist holding
contextual information."
  (with-temp-buffer
    (insert text)
    (goto-char (point-min))
    (while (search-forward "\n" nil t)
      (if (eq (char-after) ?\n)
	  (skip-chars-forward "\n")
	(delete-char -1)
	(insert ?\s)))
    (buffer-string)))

(defun org-oddmuse-italic (italic contents info)
  "Transcode ITALIC from Org-mode to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat "//" contents "//"))

(defun org-oddmuse-bold (bold contents info)
  "Transcode BOLD from Org-mode to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat "**" contents "**"))

(defun org-oddmuse-verbatim (verbatim contents info)
  "Transcode VERBATIM from Org to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat "{{{" (org-element-property :value verbatim) "}}}"))

(defun org-oddmuse-plain-list (plain-list contents info)
  "Transcode PLAIN-LIST to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel.  The
actual work is done by the `org-oddmuse-item' function."
  contents)

(defun org-item-get-level (item)
  "Get the level of ITEM, which should be an item in a plain list.
Levels are indexed from 0."
  (let ((pparent (org-element-property :parent (org-element-property :parent item))))
    (if (eq (org-element-type pparent)
	    'item)
	(1+ (org-item-get-level pparent))
      0)))

(defun org-oddmuse-item (item contents info)
  "Transcode ITEM to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat (make-string (1+ (org-item-get-level item))
		       (cl-case (org-element-property :type (org-element-property :parent item))
			 (ordered ?#)
			 (unordered ?*)
			 (descriptive
			  (error "Description-type lists are not supported -- org-oddmuse-item"))))
	  " "
	  contents))

(defun org-oddmuse-link (link contents info)
  "Transcode LINK from Org to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (cl-case (intern (org-element-property :type link))
    ((http https) (format "[[%s%s]]"
			  (org-element-property :raw-link link)
			  (if contents (concat "|" contents) "")))
    (fuzzy (format "[[%s%s]]"
		   (org-element-property :raw-link link)
		   (if contents (concat "|" contents) "")))
    (t (error "Link types other than http and internal ones are not supported -- org-oddmuse-link"))))

(defun org-oddmuse-line-break (line-break contents info)
  "Transcode LINE-BREAK object from Org to Oddmuse."
  "\\\\")

(defun org-oddmuse-horizontal-rule (horizontal-rule contents info)
  "Transcode HORIZONTAL-RULE from Org to Oddmuse."
  "\n----\n")

(defun org-oddmuse-example-block (example-block contents info)
  "Transcode EXAMPLE-BLOCK from Org to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat "{{{\n" (car (org-export-unravel-code example-block)) "}}}\n"))

(defun org-oddmuse-src-block (src-block contents info)
  "Transcode SRC-BLOCK from Org to Oddmuse.
Include caption (below the code, in italics) if present."
  (let ((caption (org-export-get-caption src-block)))
    (concat "{{{\n"
	    (car (org-export-unravel-code src-block))
	    "}}}\n"
	    (if caption
		(concat "//" (org-export-data caption info) "//\n")
	      ""))))

(defun org-oddmuse-fixed-width (fixed-width contents info)
  "Transcode a FIXED-WIDTH element from Org to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat "{{{\n" (org-remove-indentation (org-element-property :value fixed-width)) "}}}\n"))

(defun org-oddmuse-paragraph (paragraph contents info)
  "Transcode PARAGRAPH element into Oddmuse format.
CONTENTS is the paragraph contents.  INFO is a plist used as
a communication channel."
  contents)

(defun org-oddmuse-headline (headline contents info)
  "Transcode HEADLINE from Org to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat (make-string (1+ (org-export-get-relative-level headline info)) ?=)
	  " "
	  (org-export-data (org-element-property :title headline) info)
	  "\n"
	  contents))

(defun org-oddmuse-section (section contents info)
  "Transcode a SECTION element from Org to Oddmuse.
CONTENTS holds the contents of the section.  INFO is a plist
holding contextual information."
  contents)

(defun org-oddmuse-template (contents info)
  "Return complete document string after Oddmuse conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  contents)

(defun org-oddmuse-export-as-oddmuse
  (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer as an Oddmuse buffer."
  (interactive)
  (org-export-to-buffer 'oddmuse "*Org Oddmuse Export*"
    async subtreep visible-only body-only ext-plist (lambda ()
						      (when (fboundp #'oddmuse-mode) (oddmuse-mode)))))

(defun org-oddmuse-export-to-oddmuse
  (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to a Oddmuse file."
  (interactive)
  (let ((outfile (org-export-output-file-name ".oddmuse" subtreep)))
    (org-export-to-file 'oddmuse outfile
      async subtreep visible-only body-only ext-plist)))

(defun org-oddmuse-convert-region-to-oddmuse ()
  "Assume the region has Org-mode syntax, and convert it to Oddmuse."
  (interactive)
  (org-export-replace-region-by 'oddmuse))

(provide 'ox-oddmuse)

;;; ox-oddmuse.el ends here
