;;; org-padding.el --- Pad headings in org-mode
;;; Version: 0.0.1
;;; Author: TonCherAmi
;;; URL: https://github.com/TonCherAmi/org-padding

;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program ; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Code:

(require 'cl)

(defvar org-padding-heading-padding-alist
  '((nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil))
  "An alist where CAR of an item represents top heading padding
and CDR of an item represents bottom heading padding")

(defvar org-padding-block-begin-line-padding '(nil . nil)
  "A pair where CAR represents top org-block-begin-line padding
and CDR represents bottom org-block-begin-line padding")

(defvar org-padding-block-end-line-padding '(nil . nil)
  "A pair where CAR represents top org-block-end-line padding
and CDR represents bottom org-block-end-line padding")

(defun org-padding--set-padding (point padding)
  (unless (= point (point-max))
    (let ((point* (1+ point)))
      (put-text-property point point* 'rear-nonsticky t)
      (put-text-property point point* 'line-height (car padding))
      (put-text-property point point* 'line-spacing (cdr padding)))))

(cl-defun org-padding--remove-padding (point &key (top t) (bottom t))
  (when top
    (remove-text-properties point (1+ point) '(line-height nil)))
  (when bottom
    (remove-text-properties point (1+ point) '(line-spacing nil)))
  (when (and top bottom)
    (remove-text-properties point (1+ point) '(rear-nonsticky nil))))

(define-minor-mode org-padding-mode
  "Padding for org-mode"
  nil nil nil
  (let* ((keyword
          `((".*\\($\\)"
             (1 (let ((point (match-beginning 1)))
                  (unless (= point (point-max))
                    (org-padding--remove-padding point))
                  nil)))
            ("^\\(\\*+\\) .+\\($\\)"
             (2 (let* ((level (- (match-end 1) (match-beginning 1)))
                       (point (match-beginning 2))
                       (padding (nth (1- level) org-padding-heading-padding-alist)))
                  (org-padding--set-padding point padding)
                  nil)))
            ("^\\*+ .+\\($\\)\n\\*+ "
             (1 (let ((point (match-beginning 1)))
                  (org-padding--remove-padding point :top nil :bottom t))))
            ("^[ \t]*#\\(\\+[a-zA-Z]+:?\\| \\|$\\)_[a-zA-Z]+[ \t]*[^ \t\n]*[ \t]*.*\\($\\)"
             (2 (let* ((line-type (downcase (match-string 1)))
                       (padding (if (string= "+begin" line-type)
                                  org-padding-block-begin-line-padding
                                  (if (string= "+end" line-type)
                                      org-padding-block-end-line-padding
                                    nil)
                                  )))
                  (org-padding--set-padding (match-beginning 2) padding)
                  nil))))))
    (if org-padding-mode
      (progn
        (font-lock-add-keywords nil keyword)
        (font-lock-fontify-buffer))
      (save-excursion
        (goto-char (point-min))
        (font-lock-remove-keywords nil keyword)
        (font-lock-fontify-buffer)))))

(provide 'org-padding)

;;; org-padding.el ends here
