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
            proxy-scheme-uri?
            normalize-empty-path
            response/success
            response/temporary-failure
            response/permanent-failure
            response/redirect
            response/client-cert-required
            response/cert-not-authorized
            response/cert-not-valid
            response/request-too-long
            response/bad-request
            response/not-found
            response/non-gemini-scheme
            response/proxy-request-refused))

;;; =====================================================================
;;; Request Parsing
;;; =====================================================================

;;; Check if URI meets Gemini protocol requirements
(define (valid-gemini-uri? uri)
  (and uri
       (eq? (uri-scheme uri) 'gemini)
       (not (uri-userinfo uri))
       (not (uri-fragment uri))))

;;; Check if URI has a proxy scheme
(define (proxy-scheme-uri? uri)
  (and uri
       (let ((scheme (uri-scheme uri)))
         (eq? scheme 'proxy))))

;;; Parse and validate a Gemini request line
(define (parse-gemini-request request-line)
  (safe-operation
    (let ((cleaned (trim-crlf request-line)))
      (and-let* ((uri (and (not (string-null? cleaned)) (string->uri cleaned))))
        (cond
         ((proxy-scheme-uri? uri) 'proxy-scheme)
         ((valid-gemini-uri? uri) (normalize-empty-path uri))
         (else #f))))))

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

;;; =====================================================================
;;; Response Formatting
;;; =====================================================================

;;; Format a Gemini response according to protocol specification
;;;
;;; Uses rest parameter syntax (. body) to accept optional body argument.
;;; When body is not provided or #f, only the header line is returned.
(define (format-gemini-response status-code meta . body)
  (string-append (number->string status-code) " " meta "\r\n"
                 (let ((b (and (not (null? body)) (car body))))
                   (or b ""))))

;;; =====================================================================
;;; Gemini protocol responses
;;; =====================================================================

;; Success (2x) - accepts MIME type as parameter
(define (response/success mime-type . body)
  (apply format-gemini-response 20 mime-type body))

;; Redirect (3x)
(define (response/redirect target)
  (format-gemini-response 30 target))

;; Temporary Failure (4x)
(define response/temporary-failure (format-gemini-response 40 "Temporary Failure"))

;; Permanent Failure (5x)
(define response/permanent-failure (format-gemini-response 50 "Permanent Failure"))
(define response/not-found (format-gemini-response 51 "Not Found"))
(define response/proxy-request-refused (format-gemini-response 52 "Proxy Request Refused"))

;; Request errors (5x) - Request too long is 59
(define response/request-too-long (format-gemini-response 59 "Request too long"))
(define response/bad-request (format-gemini-response 59 "Bad Request"))
(define response/non-gemini-scheme (format-gemini-response 59 "Only gemini:// URIs supported"))

;; Client Certificate Required (6x)
(define response/client-cert-required (format-gemini-response 60 "Client Certificate Required"))
(define response/cert-not-authorized (format-gemini-response 61 "Certificate Not Authorized"))
(define response/cert-not-valid (format-gemini-response 62 "Certificate Not Valid"))

;;; =====================================================================
;;; Request Validation
;;; =====================================================================

;;; Validate request format and constraints according to Gemini specification
(define (validate-request request-line)
  (cond
    ((> (string-length request-line) 1024) #f)
    ((string-null? (string-trim request-line)) #f)
    ((not (or (string-suffix? "\r\n" request-line)
              (string-suffix? "\n" request-line))) #f)
    (else
     (let ((parsed (parse-gemini-request request-line)))
       (cond
        ((eq? parsed 'proxy-scheme) 'proxy-scheme)
        (parsed #t)
        (else #f))))))
