#!/usr/bin/env guile
!#

;; Ensure repository root is on load path for custom modules
(eval-when (compile load eval)
  (define (script-dir)
    (let* ((path (car (command-line)))
           (parts (string-split path #\/))
           (dir-parts (reverse (cdr (reverse parts))))
           (dir (string-join dir-parts "/")))
      dir))
  (add-to-load-path (string-append (script-dir) "/..")))

;;; Gemini Client
;;; A command-line client for browsing Gemini sites

(define-module (gemini client)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (client url)
  #:use-module (fibers)
  #:use-module (fibers channels)

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
     (list 'help))
    ((option-ref options 'version #f)
     (display-version (current-output-port))
     (list 'version))
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

;;; Run echo fiber demo
(define (run-echo-fiber url)
  (run-fibers
    (lambda ()
      (let* ((request-ch (make-channel))
             (response-ch (make-channel)))
        (spawn-fiber (lambda ()
                 (let ((msg (get-message request-ch)))
                   (put-message response-ch msg))))
        (put-message request-ch url)
        (let ((echo (get-message response-ch)))
          (format #t "Echoed back: ~a~%" echo))))))

;;; Main entry point
(define (main args)
  (let ((result (parse-cli-args args)))
    (cond
      ((eq? (car result) 'help) (exit 0))
      ((eq? (car result) 'version) (exit 0))
      (else
       (let* ((url (car result))
              (insecure? (cadr result))
              (parsed (parse-url url)))
         (format #t "URL: ~a~%" url)
         (format #t "Insecure: ~a~%" insecure?)
         (format #t "Parsed URL - host: ~a, port: ~a, path: ~a~%"
                 (list-ref parsed 0)
                 (list-ref parsed 1)
                 (list-ref parsed 2))
         (run-echo-fiber url))))))

;;; When run as script
(when (and (batch-mode?)
           (let ((script (car (command-line))))
             (string-suffix? "gemini-client.scm" script)))
  (main (command-line)))
