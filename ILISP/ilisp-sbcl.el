;;; -*- Mode: Emacs-Lisp -*-

;;; ilisp-sbcl.el --
;;; ILISP SB Common Lisp dialect definition
;;;
;;; This file is part of ILISP.
;;; Please refer to the file COPYING for copyrights and licensing
;;; information.
;;; Please refer to the file ACKNOWLEGDEMENTS for an (incomplete) list
;;; of present and past contributors.
;;;
;;; $Id: ilisp-sbcl.el,v 1.12 2001/10/19 19:00:43 mna Exp $

;;;%%%Steel Bank Common Lisp

(defvar ilisp-sbcl-init-file
  ;; Note: The init file source extension (".lisp") needs to be
  ;; present in the filename, otherwise ILISP-LOAD-OR-SEND gets
  ;; confused trying to add compiled-file extensions (e.g. ".x86f"),
  ;; because it's hard-wired to look for a period (".") in order to
  ;; decide where to append the compiled-file extension.
  "sbcl")

;;; WHN threatens to change the format of the break prompt one day soon, 
;;; but as of 0.6.12.21 this hasn't happened yet
(defun sbcl-check-prompt (old new)
  "Compare the break level printed at the beginning of the prompt."
  (let* ((was-in-break (and old (string-match "]+" old)))
 	 (old-level (if was-in-break
 			(- (match-end 0) (match-beginning 0))
 			0))
 	 (is-in-break (string-match "]+" new))
 	 (new-level (if is-in-break
 			(- (match-end 0) (match-beginning 0))
 			0)))
    (<= new-level old-level)))

;;;
(defdialect sbcl "Steel Bank Common LISP"
  common-lisp
  (ilisp-load-init 'sbcl ilisp-sbcl-init-file)

  (setq comint-prompt-regexp "^\\([0-9]+\\]+\\|\\*\\) "
	ilisp-trace-command "(ILISP:sbcl-trace \"%s\" \"%s\" \"%s\")"
	comint-prompt-status 
	(function (lambda (old line)
		    (comint-prompt-status old line 'sbcl-check-prompt)))

	ilisp-error-regexp "\\(ILISP:[^\"]*\\)\\|\\(error [^\n]*\n\n\\)\\|\\(debugger invoked on [^:]*:\\)"
	;; The above regexp has been suggested by
	;; hunter@work.nlm.nih.gov (Larry Hunter), for CMUCL.  It's
	;; probably wrong for SBCL, but I'd have to know what it was
	;; for before commenting.
        
	ilisp-arglist-command "(ILISP:ilisp-arglist \"%s\" \"%s\")"
	ilisp-find-source-command "(ILISP:source-file \"%s\" \"%s\" \"%s\")"

        comint-fix-error ":r abort"
	comint-continue ":go"
	ilisp-reset ":r toplevel"
	comint-interrupt-regexp "interrupted at"

        ;; Hardcoded binary extensions are undesirable.
        ;; Since ilisp-cl.el takes care of ilisp-binary-command and
        ;; ilisp-init-binary-command we don't need to take care of that here.
        ;; Even it is was hardcoded, problems would arise, because sbcl-0.7.x
        ;; uses ".fasl" as an extension, whereas sbcl-0.6.x uses specific
        ;; extensions (like ".x86f").
        ;; So go for the general mechanism.
        ;; instead of the following:
	;; ilisp-init-binary-command "\"x86f\""
	;; ilisp-binary-command "\"x86f\""
	)

  ;; ILD Support, largely untested

  (setq ild-abort-string ":abort"
	ild-continue-string ":go"
	ild-next-string ":down"
	ild-next-string-arg nil		;needs work
	ild-previous-string ":up"
	ild-previous-string-arg nil	;needs work
	ild-top-string ":bottom"
	ild-bottom-string ":top"
	ild-backtrace-string ":backtrace"
	ild-locals-string ":l"
	ild-local-string-arg "(debug:arg %s)"
	ild-return-string nil		; needs work (debug:debug-return x)
	ild-retry-string nil		; needs work
	ild-trap-on-exit-string nil	; needs work
	)
  )

(unless sbcl-program (setq sbcl-program "sbcl --noinform"))

;;; end of file -- ilisp-sbcl.el --

