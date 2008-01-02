;;; rdebug.el --- Ruby debugger user interface, startup file.

;; Copyright (C) 2006, 2007, 2008 Rocky Bernstein (rocky@gnu.org)
;; Copyright (C) 2007, 2008 Anders Lindgren

;; $Id: rdebug.el 409 2007-12-14 02:36:37Z rockyb $

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

;; This file contains the initialization needed for the Emacs user
;; interface to the `rdebug' Ruby debugger.
;;
;; To use this package, place the following line in an appropriate
;; init file (for example ~/.emacs):
;;
;;    (require 'rdebug)
;;

;;; Code:

(if (< emacs-major-version 22)
    (error
     "This version of rdebug.el needs at least Emacs 22 or greater - you have version %d."
     emacs-major-version))

(autoload 'rdebug "rdebug-core"
  "Run the rdebug Ruby debugger and start the Emacs user interface.

By default, the \"standard\" user window layout looks like the following:

+----------------------------------------------------------------------+
|                                Toolbar                               |
+-----------------------------------+----------------------------------+
| Debugger shell                    | Variables buffer                 |
+-----------------------------------+----------------------------------+
|                                   |                                  |
| Source buffer                     | Output buffer                    |
|                                   |                                  |
+-----------------------------------+----------------------------------+
| Stack buffer                      | Breakpoints buffer               |
+-----------------------------------+----------------------------------+

The variable `rdebug-many-windows-layout-function' can be
customized so that another layout is used. In addition to a
number of predefined layouts it's possible to define a function
to perform a custom layout.

If `rdebug-many-windows' is nil, only a traditional debugger
shell and source window is opened.

The directory containing the debugged script becomes the initial
working directory and source-file directory for your debugger.

The custom variable `gud-rdebug-command-name' sets the command
and options used to invoke rdebug." t)


(autoload 'rdebug-turn-on-debugger-support "rdebug-core"
  "Enable extra source buffer support for the `rdebug' Ruby debugger.

This includes a 'Debugger' menu and special key bindings when the
debugger is active."
  t)


(autoload 'rdebug-track-attach "rdebug-track"
  "Do things to make the current process buffer work like a
rdebug command buffer." t)

(autoload 'turn-on-rdebug-track-mode "rdebug-track"
  "Turn on rdebugtrack mode.

This function is designed to be added to hooks, for example:
  (add-hook 'comint-mode-hook 'turn-on-rdebugtrack-mode)"
  t)


(add-hook 'ruby-mode-hook 'rdebug-turn-on-debugger-support)


;; -------------------------------------------------------------------
;; user definable variables
;;

(defcustom gud-rdebug-command-name
  "rdebug --emacs"
  "File name for executing the Ruby debugger and command options.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'gud)

(defcustom rdebug-line-width 120
  "Length of line before truncation occurs.
This value limits output in secondary buffers."
  :type 'integer
  :group 'rdebug)

(defcustom rdebug-many-windows t
  "*If non-nil, use the full debugger user interface, see `rdebug'.

However only set to the multi-window display if the rdebug
command invocation has an annotate options (\"--annotate 3\")."
  :type 'boolean
  :group 'rdebug)

(defcustom rdebug-populate-common-keys-function
  'rdebug-populate-common-keys-standard
  "The function to call to populate key bindings common to all rdebug windows.
This includes the secondary windows, the debugger shell, and all
Ruby source buffers when the debugger is active.

This variable can be bound to the following:

* nil -- Don't bind any keys.

* `rdebug-populate-common-keys-standard' -- Bind according to a widely used
  debugger convention:

\\{rdebug-example-map-standard}

* `rdebug-populate-common-keys-eclipse' -- Bind according to Eclipse.

\\{rdebug-example-map-eclipse}

* `rdebug-populate-common-keys-netbeans' -- Bind according to NetBeans.

\\{rdebug-example-map-netbeans}

* Any other value is expected to be a callable function that takes one
  argument, the keymap, and populates it with suitable keys."
  :type 'function
  :group 'rdebug)

(defcustom rdebug-restore-original-window-configuration :many
  "*Control if the original window layout is restored when the debugger exits.
The value can be t, nil, or :many.

A value of t means that the original layout is always restored,
nil means that it's never restored.

:many means that the original layout is restored only when
`rdebug-many-windows' is used."
  :type '(choice (const :tag "Always restore" t)
		 (const :tag "Never restore" nil)
		 (const :tag "Restore in many windows mode" :many))
  :group 'rdebug)

(defcustom rdebug-use-separate-io-buffer t
  "Non-nil means display output from the debugged program in a separate buffer."
  :type 'boolean
  :group 'gud)


(defcustom rdebug-window-layout-function
  'rdebug-window-layout-standard
  "*A function that performs the window layout of `rdebug'.

This is only used in `rdebug-many-windows' mode. This should be
bound to a function that performs the actual window layout. The
function should takes two arguments, the first is the source
buffer and the second the name of the script to debug.

Rdebug provides the following predefined layout functions:

* `rdebug-window-layout-standard'         -- See `rdebug'

* `rdebug-window-layout-conservative'     -- Source + Shell + Output

* `rdebug-window-layout-stack-of-windows' -- Extra windows to the right

* `rdebug-window-layout-rocky'            -- Rocky's own layout"
  :type
  '(choice
    (function :tag "Standard"         rdebug-window-layout-standard)
    (function :tag "Conservative"     rdebug-window-layout-conservative)
    (function :tag "Stack of windows" rdebug-window-layout-stack-of-windows)
    (function :tag "Rocky's own"      rdebug-window-layout-rocky)
    (function :tag "Other"            function))
  :group 'rdebug)



(provide 'rdebug)

;;; rdebug.el ends here
