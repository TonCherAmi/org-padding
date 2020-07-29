;;; org-padded-headings.el --- Pad headings in org-mode
;;; Version: 0.0.1
;;; Author: TonCherAmi
;;; URL: https://github.com/TonCherAmi/org-padded-headings

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

(defvar org-padded-headings-padding-alist
  '((nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil) (nil . nil)))

(define-minor-mode org-padded-headings-mode
  "Padded headings for org-mode"
  nil nil nil
  (let* ((keyword
          `((".*\\($\\)"
             (1 (progn
                  (unless (= (match-end 1) (point-max))
                    (remove-text-properties (match-beginning 1) (1+ (match-end 1)) '(line-height nil line-spacing nil)))
                  nil)))
            ("^\\(\\*+\\) .+\\($\\)"
             (2 (let* ((level (- (match-end 1) (match-beginning 1)))
                       (start (match-beginning 2))
                       (end (1+ (match-end 2)))
                       (pair (nth (1- level) org-padded-headings-padding-alist)))
                  (put-text-property start end 'rear-nonsticky t)
                  (put-text-property start end 'line-height (car pair))
                  (put-text-property start end 'line-spacing (cdr pair))
                  nil))))))
    (if org-padded-headings-mode
      (progn
        (font-lock-add-keywords nil keyword)
        (font-lock-fontify-buffer))
      (save-excursion
        (goto-char (point-min))
        (font-lock-remove-keywords nil keyword)
        (font-lock-fontify-buffer)))))

;;; org-padded-headings.el ends here
