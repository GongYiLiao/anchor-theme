;;; theme-anchor.el --- Apply theme in current buffer only -*- lexical-binding: t -*-
 
;; Copyright (C) 2021 Liāu, Kiong-Gē

;; ------------------------------------------------------------------------------
;; Author: Liāu, Kiong-Gē <gongyi.liao@gmail.com>
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Package-Requires: ((emacs "26"))
;; Keywords: extensions, lisp, theme
;; Homepage: https://github.com/GongYiLiao/theme-anchor
;; ------------------------------------------------------------------------------

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.
 
;;; Commentary:

;; Using `face-remap's `face-remap-set-base function to set buffer-specific
;; custom theme
;; 

;;; Code:

(require 'cl-lib)  			;; for 'cl-remove-if'
(require 'faces) 			;; for 'face-spec-choose'
(require 'custom) 			;; for 'load-theme'
(require 'face-remap) 			;; for 'face-remap-set-base'

(defun theme-anchor-get-faces (theme)
  "Extract all the theme-face values from THEME."
  ;; take only theme-face specs
  (cl-remove-if (lambda (spec) (not (eq (car spec) 'theme-face)))
		;; the theme's all the face/value specs
		(get theme 'theme-settings)))

(defun theme-anchor-spec-choose (face-spec)
  "Choose applicable face settings.
It uses the condition specified in a face spec and use 'face-spec-choose'
function from face-remap.el
Argument FACE-SPEC: the specs to be tested"
  ;; a face's all applicable specs, along with their applicable conditions
  (let ((face-spec-content (nth 3 face-spec)))
    (list (nth 1 face-spec) ;; the face name
	  ;; the applicable face spec chosen by 'face-spec-choose'
	  (face-spec-choose face-spec-content))))

(defun theme-anchor-buffer-local (theme)
  "Extract applicable face settings from THEME.
It uses 'face-remap-set-base' to load that theme in a buffer local manner"
  ;; make sure the theme is available
  (interactive
   (list
    (intern (completing-read "Load custom theme: "
                             (mapcar #'symbol-name
				     (custom-available-themes))))))
  (unless (custom-theme-name-valid-p theme)
    (error "Invalid theme name `%s'" theme))
  ;; 
  (load-theme theme t t)
  ;; set buffer face with
  (mapc (lambda (spec) (apply #'face-remap-set-base spec))
	;; ignore faces without applicable specs
	(remove 'nil
		;; filter out non-applicable specs
		(mapcar #'theme-anchor-spec-choose
			;; get the theme-face specs from the theme
			(theme-anchor-get-faces theme)))))

(defmacro theme-anchor-hook-gen (theme &rest other-step)
  "Generate hook functions.
Argument THEME the theme to be applied in the mode hook .
Optional argument OTHER-STEP the additional steps to execute in the mode hook."
  `(lambda nil
     ;; face-remap current buffer with theme
     (theme-anchor-buffer-local ,theme)
     ;; other sides effect applicable to the current buffer
     ,@other-step))

(provide 'theme-anchor)

;;; theme-anchor.el ends here

