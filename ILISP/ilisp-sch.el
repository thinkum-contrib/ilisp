;;; -*- Mode: Emacs-Lisp -*-

;;; ilisp-sch.el --

;;; This file is part of ILISP.
;;; Version: 5.10.1
;;;
;;; Copyright (C) 1990, 1991, 1992, 1993 Chris McConnell
;;;               1993, 1994 Ivan Vasquez
;;;               1994, 1995, 1996 Marco Antoniotti and Rick Busdiecker
;;;               1996-2000 Marco Antoniotti and Rick Campbell
;;;
;;; Other authors' names for which this Copyright notice also holds
;;; may appear later in this file.
;;;
;;; Send mail to 'majordomo@cons.org' to be included in the
;;; ILISP mailing list. 'ilisp@cons.org' is the general ILISP
;;; mailing list were bugs and improvements are discussed.
;;;
;;; ILISP is freely redistributable under the terms found in the file
;;; COPYING.

(require 'cl)				; Sorry. I couldn't resist
					; 19990818 Marco Antoniotti

;;; Scheme

(defdialect scheme "Scheme" ilisp
  (setq ilisp-block-command "(begin \n%s)")
  (setq ilisp-load-command "(load \"%s\")")
  )

(unless scheme-program
  (setq scheme-program "scheme"))

;;;Cscheme
;;; This has a problem since interrupts cause things to crash
;(defdialect cscheme "C Scheme"
;  scheme
;  (setq comint-prompt-regexp
;   "^[0-9]+ \\([\\]=]=>\\|Error->\\|Bkpt->\\|Debug->\\|Where->\\) ")
;  (setq ilisp-program "cscheme")
;  (setq ilisp-binary-extension "bin")
;  )


;;; Oaklisp

(defdialect oaklisp "Oaklisp Scheme"
  scheme
  (setq comint-prompt-regexp ">+ ")
  (setq comint-fix-error "(ret 0)")
  (setq ilisp-last-command "*")
  (setq ilisp-describe-command "(describe %s)"))


;;; 19990818 Marco Antoniotti
;;; Many thanks to Christian Lynchbeck for providing so many new
;;; dialects of Scheme.

;;; Additional dialects by <lynbech@daimi.aau.dk> (now <chl@tbit.dk>)

;;;Scm
;; hacked by <lynbech@daimi.aau.dk>

(defdialect scm "Scm Scheme"
  scheme
  (setq ilisp-program "scm -i")		; assume scm is in path.
  (setq comint-prompt-regexp "^> ")
  ;;inspired by the qsci dialect
  (setq ilisp-eval-command
	"(begin (require 'string-port) ; slib specific
                (car (list (call-with-input-string \"%s\"
                              (lambda (input) (eval (read input))))
                            \"%s\" \"%s\")))"
	ilisp-package-command "%s")
  ;; (setq comint-fix-error "(ret 0)")
  ;; (setq ilisp-last-command "*")
  ;; (setq ilisp-describe-command "(describe %s)")
  )


;;;Chez Scheme
;; hacked by <lynbech@daimi.aau.dk>

(defdialect chez "Chez Scheme"
  scheme
  (setq ilisp-program "scheme")		; assume scheme is in path.
  (setq comint-prompt-regexp "^\\(debug>\\|>+\\) ")
  ;;inspired by the qsci dialect
  (setq ilisp-eval-command
	"(car (list (eval (read (open-input-string \"%s\"))) \"%s\" \"%s\"))"
	ilisp-package-command "%s"
	ilisp-macroexpand-command "(expand '%s);%s"
	ilisp-trace-command "(trace %s);%s"
	ilisp-untrace-command "(untrace %s);%s"
	ilisp-directory-command  "(current-directory);%s"
	ilisp-set-directory-command "(current-directory \"%s\")"
	ilisp-binary-extension "so"
	ilisp-compile-file-command
	"(begin (compile-file \"%s\") (pp \"%s,%s\"))")
  (setq comint-fix-error "(debug)")
  )

;;;STk Scheme
;; hacked by <lynbech@daimi.aau.dk>

(defdialect stk "STk - Scheme Tk"
  scheme
  (setq ilisp-program "stk -interactive") ; assume scheme is in path.
  (setq comint-prompt-regexp "^STk> ")
  ;;inspired by the qsci dialect
  (setq ilisp-eval-command
	"(car (list (eval (read (open-input-string \"%s\"))) \"%s\" \"%s\"))"
	ilisp-package-command ";%s"
	ilisp-macroexpand-command "(macro-expand '%s);%s"
	ilisp-trace-command "(trace-var %s);%s"
	ilisp-untrace-command "(untrace-var %s);%s"
	ilisp-directory-command  "(getcwd);%s"
	ilisp-set-directory-command "(chdir \"%s\")"
	ilisp-describe-command "(describe %s)"
	comint-ptyp t
	comint-always-scroll t
	ilisp-last-command "*"
	)
  )

(defdialect snow "Snow - Scheme Tk without Tk"
  stk
  (setq ilisp-program "snow -interactive") ;assume scheme is in path.
  )

;;; Guile
;;; with hacks from Istvan Marko <imarko@pacificnet.net>
;;; and Matthias Koeppe <mkoeppe@mail.math.uni-magdeburg.de>

(defvar ilisp-guile-init-file "guile-ilisp.scm")

(defdialect guile "Guile - the GNU extension language"
    scheme
    (setq ilisp-program "guile")
    (setq comint-prompt-regexp "^guile[^>]*> ")
    (setq ilisp-load-or-send-command
          "(begin \"%s\" (load \"%s\"))")
    (ilisp-load-init 'guile ilisp-guile-init-file)
    (setq ilisp-symbol-delimiters "^ \t\n\('\"#\)"
          ilisp-package-regexp "^[ \t]*\\s(define-module \\((.*)\\))"
          ilisp-error-regexp "\\(ERROR\\|ABORT\\): "
          ilisp-package-command 
          ;; This will only get us the last component of the module name
          ;"(save-module-excursion (lambda () %s (module-name (current-module))))"
          "(ilisp-get-package '%s)"

          ilisp-hash-form-regexp
          "^[ \t]*(define-module[ \t\n]"

          ilisp-block-command "(begin #f %s)" ;; Guile doesn't grok empty blocks
          ilisp-in-package-command "(ilisp-in-package \"%s\")"
          ilisp-in-package-command-string "in-package" ;;; FIXME
          ilisp-defpackage-command-string "define-module"
          ilisp-package-name-command "(module-name (current-module))"
          ilisp-eval-command "(ilisp-eval \"%s\" \"%s\" \"%s\")"
          ilisp-directory-command "(getcwd)"
          ilisp-set-directory-command "(chdir \"%s\")"
          ilisp-complete-command "(ilisp-matching-symbols \"%s\" \"%s\" '%s '%s '%s)"
          ilisp-documentation-command "(help %s)"
          ilisp-print-info-message-command "(ilisp-print-info-message '%s \"%s\")"
          ilisp-arglist-command "(ilisp-arglist '%s \"%s\")"
          ilisp-macroexpand-command "(ilisp-macroexpand \"%s\" \"%s\")"
          ilisp-macroexpand-1-command "(ilisp-macroexpand-1 \"%s\" \"%s\")"
          ilisp-trace-command "(ilisp-trace '%s \"%s\" 'nil)"
          ilisp-untrace-command "(ilisp-untrace '%s \"%s\")"))

(unless guile-program (setq guile-program "guile"))


;;; Mixins

;;; mixins is a stab at providing a new concept for ILISP. Mixins is a
;;; sort of hook allowing specification of thing which behaves like a
;;; dialect without being tied to any specific such. The SLIB library is
;;; an example of a candidate for a mixin specification.


(defun ilisp-slib-mixin ()
  "Set up ilisp for Slib.
Many ilisp features also supplies package specifications. Rather than ignoring
these alltogether, I will define it to the variable `*ilisp-package*'."
  (interactive)
  (setq
   ;;Can't easily use the non-macro version of tracing.
   ilisp-trace-command
   "(begin (require 'trace) (trace %s) (define *ilisp-package* %s))"

   ilisp-untrace-command
   "(begin (require 'trace) (untrace %s) (define *ilisp-package* %s))"
   ))

;;; end of file -- ilisp-sch.el --
