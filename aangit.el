;;; aangit.el --- Quickly scaffold new Angular apps with Aangit

;; Author: Steven Edwards <steven@stephenwithav.io>
;; URL: https://github.com/stephenwithav/aangit
;; Keywords: angular tools
;; Version: 0.1
;; Package-Requires: ((emacs "29.1") (transient "0.4"))
;; SPDX-License-Identifier: MIT
;
;;; Commentary:
;;
;; Switching back and forth between the cli (e.g., for ng generate commands) and
;; Emacs is annoying.  This package hopes to alleviate that.

;;; Code:

(require 'transient)
(require 'dired)

(transient-define-suffix aangit-menu--ng-new (&optional args)
  "Quickly scaffolds new Angular app in cwd."
  :description "ng new"
  (interactive (list (transient-args transient-current-command)))
  (let ((dir (car (last (string-split (car (dired-read-dir-and-switches "")) "/"))))
        (cliargs (string-join args " ")))
    (if (string-empty-p dir)
        (message "missing project name")
      (progn
        (shell-command (format "ng new --defaults %s %s" dir cliargs))
        (dired dir)
        (delete-other-windows)
        (aangit-menu--generate-submenu)))))

(defun aangit--ng-add-single-schematic (pkg)
  (shell-command (format "ng add --defaults --skip-confirmation %s" pkg)))


(transient-define-suffix aangit-menu--ng-add-known-schematic-command (&optional args)
  "Quickly adds schematic to Angular app in cwd."
  :description "ng add"
  (interactive (list (transient-args transient-current-command)))
  (if (seq-empty-p args)
      (message "missing schematic name")
    (mapc #'aangit--ng-add-single-schematic args)))


(transient-define-argument aangit-menu--new-project-style ()
  :description "Style"
  :class transient-option
  :key "-y"
  :argument "--style="
  :always-read t
  :choices '("css" "scss" "sass" "less"))

(transient-define-argument aangit-menu--new-component-style ()
  :description "Style"
  :class transient-option
  :key "-y"
  :argument "--style="
  :always-read t
  :choices '("css" "scss" "sass" "less" "none"))

(transient-define-prefix aangit-menu--new-project ()
  :value '("--standalone" "--routing" "--style=css")
  ["Switches"
   ("-s" "Standalone" "--standalone" :class transient-switch)
   ("-r" "Routing" "--routing" :class transient-switch)
   ("-i" "Inline Style" "--inline-style" :class transient-switch)
   ("-t" "Inline Template" "--inline-template" :class transient-switch)
   (aangit-menu--new-project-style)
   ""
   ("-S" "Skip Tests" "--skip-tests" :class transient-switch)
   ]
  ["Commands"
   ("n" "new" aangit-menu--ng-new)])

(defun aangit-menu--unimplemented ()
  "Placeholder for future defuns."
  (interactive)
  (message "not yet implemented"))

(transient-define-suffix aangit-menu--ng-generate-component-command (&optional args)
  :description "ng generate component"
  (interactive (list (transient-args transient-current-command)))
  (let ((component (read-string "component name: ")))
   (if (string-empty-p component)
      (message "missing component name")
    (shell-command (format "ng generate component %s --defaults %s" component (string-join args " "))))))

(transient-define-prefix aangit-menu--generate-component-submenu ()
  ["generate component"
   ("-s" "Standalone" "--standalone" :class transient-switch)
   ("-i" "Inline Style" "--inline-style" :class transient-switch)
   ("-t" "Inline Template" "--inline-template" :class transient-switch)
   ("-p" "Path" "--path=" :class transient-switch)
   (aangit-menu--new-component-style)
   ""
   ("-S" "Skip Tests" "--skip-tests" :class transient-switch)
   ]
  ["Commands"
   ("n" "new" aangit-menu--ng-generate-component-command)])

(transient-define-suffix aangit-menu--ng-generate-service-command (&optional args)
  :description "ng generate service"
  (interactive (list (transient-args transient-current-command)))
  (let ((service (read-string "service name: ")))
   (if (string-empty-p service)
      (message "missing service name")
    (shell-command (format "ng generate service %s" service)))))

(transient-define-suffix aangit-menu--ng-generate-interface-command (&optional args)
  :description "ng generate interface"
  (interactive (list (transient-args transient-current-command)))
  (let ((interface (read-string "interface name: ")))
   (if (string-empty-p interface)
      (message "missing interface name")
    (shell-command (format "ng generate interface %s" interface)))))

(transient-define-suffix aangit-menu--ng-generate-module-command (&optional args)
  :description "ng generate module"
  (interactive (list (transient-args transient-current-command)))
  (let ((module (read-string "module name: ")))
   (if (string-empty-p module)
      (message "missing module name")
    (shell-command (format "ng generate module %s --defaults %s" module (string-join args " "))))))

(transient-define-prefix aangit-menu--generate-interface-submenu ()
  ["Interfaces"
   ("n" "new" aangit-menu--ng-generate-interface-command)])

(transient-define-prefix aangit-menu--generate-service-submenu ()
  ["Service"
   ("-S" "Skip Tests" "--skip-tests" :class transient-switch)]
  ["Commands"
   ("n" "new" aangit-menu--ng-generate-service-command)])

(transient-define-prefix aangit-menu--generate-module-submenu ()
  ["Module"
   ("-f" "Force" "--force" :class transient-switch)
   ("-F" "Flat" "--flat" :class transient-switch)
   ("-r" "Routing" "--routig" :class transient-switch)
   ]
  ["Commands"
   ("n" "new" aangit-menu--ng-generate-module-command)])

(transient-define-prefix aangit-menu--generate-submenu ()
  :value '("--defaults")
  ["Generate what?"
   ;; ("a" "Application shell" aangit-menu--unimplemented)
   ;; ("A" "application in projects" aangit-menu--unimplemented)
   ;; ("C" "Class" aangit-menu--unimplemented)
   ("c" "Component" aangit-menu--generate-component-submenu)
   ;; ("o" "Configuration file" aangit-menu--unimplemented)
   ;; ("d" "Directive" aangit-menu--unimplemented)
   ;; ("e" "Enums" aangit-menu--unimplemented)
   ;; ("g" "Guard" aangit-menu--unimplemented)
   ;; ("I" "Interceptor" aangit-menu--unimplemented)
   ("i" "Interface" aangit-menu--generate-interface-submenu)
   ;; ("l" "Library" aangit-menu--unimplemented)
   ("m" "Module" aangit-menu--generate-module-submenu)
   ;; ("p" "Pipe" aangit-menu--unimplemented)
   ;; ("r" "Resolver" aangit-menu--unimplemented)
   ("s" "Service" aangit-menu--generate-service-submenu)
   ;; ("S" "Service Worker" aangit-menu--unimplemented)
   ;; ("w" "Web Worker" aangit-menu--unimplemented)
   ])

(transient-define-prefix aangit-menu--add-external-library-or-schematic-submenu ()
  ["Schematics"
   ("l" "@angular-eslint/schematics" "@angular-eslint/schematics" :class transient-switch)
   ("m" "@angular/material" "@angular/material" :class transient-switch)
   ("c" "@angular/cdk/schematics" "@angular/cdk/schematics" :class transient-switch)
   ("s" "@ngrx/store" "@ngrx/store" :class transient-switch)]
  ["Commands"
   ("a" "add" aangit-menu--ng-add-known-schematic-command)])

(transient-define-prefix aangit-menu ()
  [["ng"
    ("n" "new" aangit-menu--new-project)
    ("a" "Add external library" aangit-menu--add-external-library-or-schematic-submenu)
    ("g" "generate" aangit-menu--generate-submenu)
    ]])


(provide 'aangit)

;;; aangit.el ends here
