;;; Gemini Protocol Implementation
;;; Request parsing and response formatting according to RFC specification
;;; 
;;; This module implements the core Gemini protocol parsing and response formatting
;;; as specified in the Gemini protocol specification (gemini://gemini.circumlunar.space/docs/specification.gmi)

(define-module (gemini protocol)
  #:use-module (ice-9 regex)
  #:use-module (web uri)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)  ; for and-let*
  #:use-module (srfi srfi-14)
  #:use-module (gemini utils)
  #:export (parse-gemini-request
            format-gemini-response
            validate-request
            trim-crlf
            valid-gemini-uri?
            normalize-empty-path))

;;; Check if URI meets Gemini protocol requirements
(define (valid-gemini-uri? uri)
  (and uri
       (eq? (uri-scheme uri) 'gemini)
       (not (uri-userinfo uri))
       (not (uri-fragment uri))))

;;; Parse and validate a Gemini request line
(define (parse-gemini-request request-line)
  (safe-operation
    (let ((cleaned (trim-crlf request-line)))
      (and-let* ((uri (and (not (string-null? cleaned)) (string->uri cleaned)))
                 (_ (valid-gemini-uri? uri)))
        (normalize-empty-path uri)))))

;;; Normalize empty path to root path "/"
(define (normalize-empty-path uri)
  (if (string-null? (uri-path uri))
      (build-uri (uri-scheme uri) 
                 #:userinfo (uri-userinfo uri)
                 #:host (uri-host uri)
                 #:port (uri-port uri) 
                 #:path "/"
                 #:query (uri-query uri)
                 #:fragment (uri-fragment uri))
      uri))

;;; Helper to trim CRLF line endings
(define (trim-crlf request-line)
  (string-trim-right request-line (char-set #\newline #\return)))

;;; Format a Gemini response according to protocol specification  
(define (format-gemini-response status-code meta body)
  (string-append (number->string status-code) " " meta "\r\n"
                 (or body "")))

;;; Validate request format and constraints according to Gemini specification
(define (validate-request request-line)
  (and (<= (string-length request-line) 1024)
       (not (string-null? (string-trim request-line)))
       (or (string-suffix? "\r\n" request-line)
           (string-suffix? "\n" request-line))
       (parse-gemini-request request-line)
       #t))