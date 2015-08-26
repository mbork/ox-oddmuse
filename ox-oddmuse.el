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

;;; Code:

(defcustom ox-oddmuse-menu-key ?a
  "The dispatch key for the Oddmuse exporter in the exporter menu.")

(org-export-define-backend 'oddmuse
  '((plain-text . org-oddmuse-plain-text)
    (paragraph . org-oddmuse-paragraph)
    (headline . org-oddmuse-headline)
    (section . org-oddmuse-section)
    (template . org-oddmuse-template))
  :export-block "ODDMUSE"
  :menu-entry `(,ox-oddmuse-menu-key "Export to Oddmuse"
				     ((,(upcase ox-oddmuse-menu-key)
				       "As buffer" org-oddmuse-export-as-oddmuse)
				      (,(downcase ox-oddmuse-menu-key)
				       "As file" org-oddmuse-export-to-oddmuse))))

(defun org-oddmuse-plain-text (text info)
  "Transcode a TEXT string from Org to Oddmuse.
TEXT is the string to transcode.  INFO is a plist holding
contextual information."
  text)

(defun org-oddmuse-paragraph (paragraph contents info)
  "Transcode PARAGRAPH element into Oddmuse format.
CONTENTS is the paragraph contents.  INFO is a plist used as
a communication channel."
  contents)

(defun org-oddmuse-headline (headline contents info)
  "Transcode HEADLINE from Org to Oddmuse.
CONTENTS is the actual text, INFO is the communication channel."
  (concat (make-string (org-export-get-relative-level headline info) ?=)
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

(provide 'ox-oddmuse)

;;; ox-oddmuse.el ends here
