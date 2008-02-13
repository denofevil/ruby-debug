;;; rdebug-breaks.el --- Ruby debugger info buffer.

;; Copyright (C) 2008 Rocky Bernstein (rocky@gnu.org)
;; Copyright (C) 2008 Anders Lindgren

;; $Id: rdebug-breaks.el 670 2008-02-06 18:15:28Z rockyb $

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; See the manual and the file `rdebug.el' for more information.

;; This file contains code dealing with the info secondary buffer.

;;; Code:

(require 'rdebug-dbg)
(require 'rdebug-gud)
(require 'rdebug-regexp)
(require 'rdebug-secondary)
(require 'rdebug-source)
(require 'rdebug-vars)

(defun rdebug-display-info-buffer ()
  "Display the rdebug breakpoints buffer."
  (interactive)
  (rdebug-display-secondary-buffer "info"))

(defvar rdebug-info-mode-map
  (let ((map (make-sparse-keymap)))
    (rdebug-populate-secondary-buffer-map map)
    map)
  "Keymap for the Rdebug info secondary buffer.")

(defun rdebug-info-mode ()
  "Major mode for Ruby debugger info buffer.

\\{rdebug-info-mode-map}"
  (kill-all-local-variables)
  (setq major-mode 'rdebug-info-mode)
  (setq mode-name "RDEBUG Info")
  (use-local-map rdebug-info-mode-map)
  (setq buffer-read-only t)
  (set (make-local-variable 'rdebug-secondary-buffer) t)
  (set (make-local-variable 'rdebug-accumulative-buffer) t)
  (run-mode-hooks 'rdebug-info-mode-hook))

(defun rdebug--setup-info-buffer (buf comint-buffer)
  "Setup the Rdebug debugger info buffer."
  (rdebug-debug-enter "rdebug--setup-info-buffer"
    (with-current-buffer buf
      (let ((inhibit-read-only t)
	    (old-line-number (buffer-local-value 'rdebug-current-line-number
						 buf)))
        (rdebug-info-mode)
	(goto-line old-line-number)))))

(defvar rdebug-info-cmd-acc "")
(defvar rdebug-info-cmd-state :wait
  ":wait, :accept, or :reject")

(defun rdebug-info-cmd-clear ()
  (rdebug-debug-enter "rdebug-info-cmd-clear"
    (setq rdebug-info-cmd-acc "")
    (setq rdebug-info-cmd-state :wait)))

(defun rdebug-info-cmd-process (s)
  "Process a shell command and its output and maybe send it to the info buffer."
  (rdebug-debug-enter (format "rdebug-info-cmd-process %S" s)
    (when (eq rdebug-info-cmd-state :wait)
      (setq rdebug-info-cmd-acc (concat rdebug-info-cmd-acc s))
      (rdebug-debug-message "ACC: %S" rdebug-info-cmd-acc)
      (when (string-match "^\\([a-z]+\\) .*\n" rdebug-info-cmd-acc)
        (rdebug-debug-message (match-string 1 rdebug-info-cmd-acc))
        (if (member (match-string 1 rdebug-info-cmd-acc)
                    '("p" "e" "eval" "pp" "pl" "ps" "info"))
            (progn
              (setq rdebug-info-cmd-state :accept)
              (setq s (substring rdebug-info-cmd-acc (match-end 0)))
              (let ((buf (rdebug-get-existing-buffer "info" gud-target-name)))
                (if buf
                    (with-current-buffer buf
                      (let ((inhibit-read-only t))
                        (erase-buffer))))))
          (setq rdebug-info-cmd-state :reject))))
    (when (eq rdebug-info-cmd-state :accept)
      (with-no-warnings
        (rdebug-process-annotation "info" s)))))


;; -------------------------------------------------------------------
;; The end.
;;

(provide 'rdebug-info)

;;; Local variables:
;;; eval:(put 'rdebug-debug-enter 'lisp-indent-hook 1)
;;; End:

;;; rdebug-info.el ends here