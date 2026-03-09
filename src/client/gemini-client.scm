#!/usr/bin/env guile
!#

;;; Gemini Client
;;; A command-line client for browsing Gemini sites

(define-module (gemini client)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:export (main parse-cli-args))

;;; Command line option specification
(define option-spec
  '((help (single-char #\h) (value #f))
    (insecure (single-char #\k) (value #f))
    (version (single-char #\v) (value #f))))

;;; Usage message
(define (display-usage port)
  (display "Usage: gemini-client [OPTIONS] URL\n" port)
  (display "\n" port)
  (display "Options:\n" port)
  (display "  -h, --help       Display this help message and exit\n" port)
  (display "  -k, --insecure   Skip TLS certificate verification\n" port)
  (display "  -v, --version    Display version information and exit\n" port)
  (display "\n" port)
  (display "Arguments:\n" port)
  (display "  URL              A gemini:// URL to fetch\n" port)
  (display "\n" port)
  (display "Examples:\n" port)
  (display "  gemini-client gemini://example.com/\n" port)
  (display "  gemini-client -k gemini://localhost:1965/test\n" port)
  (force-output port))

;;; Version information
(define (display-version port)
  (display "gemini-client version 0.1.0\n" port)
  (display "A Gemini protocol client\n" port)
  (force-output port))

;;; Handle parsed options - returns parsed result or exits
(define (handle-options options)
  (cond
    ((option-ref options 'help #f)
     (display-usage (current-output-port))
     (exit 0))
    ((option-ref options 'version #f)
     (display-version (current-output-port))
     (exit 0))
    (else
     (let ((positional (option-ref options '() '())))
       (if (null? positional)
           (begin
             (display "Error: URL is required\n" (current-error-port))
             (exit 1))
           (let ((url (car positional))
                 (insecure? (option-ref options 'insecure #f)))
             (if (string-prefix? "gemini://" url)
                 (list url insecure?)
                 (begin
                   (display "Error: URL must start with gemini://\n" (current-error-port))
                   (exit 1)))))))))

;;; Main parsing logic - the "thunk" for catch
(define (parse-cli-args-thunk args)
  (let ((options (getopt-long args option-spec #:stop-at-first-non-option #f)))
    (handle-options options)))

;;; Error handler for parse-cli-args
(define (parse-cli-args-handler key . rest)
  (display "Error: Invalid arguments\n" (current-error-port))
  (display-usage (current-error-port))
  (exit 1))

;;; Parse command line arguments
(define (parse-cli-args args)
  (catch #t
    (lambda () (parse-cli-args-thunk args))
    parse-cli-args-handler))

;;; Main entry point
(define (main args)
  (let ((result (parse-cli-args args)))
    (format #t "URL: ~a~%" (car result))
    (format #t "Insecure: ~a~%" (cadr result))))

;;; When run as script
(when (and (batch-mode?)
           (let ((script (car (command-line))))
             (string-suffix? "gemini-client.scm" script)))
  (main (command-line)))
