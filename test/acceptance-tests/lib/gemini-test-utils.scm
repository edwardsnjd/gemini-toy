;;; Gemini Test Utilities
;;; Shared abstractions for elegant acceptance testing

(define-module (gemini-test-utils)
  #:use-module (srfi srfi-64)    ; Testing framework
  #:use-module (srfi srfi-9)     ; Records
  #:use-module (gnutls)          ; TLS connections
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 format)
  #:export (with-gemini-request
            with-raw-gemini-request
            test-mime-types
            test-malformed-requests
            gemini-response?
            gemini-response-status
            gemini-response-meta
            gemini-response-body))

;;; Configuration
(define *test-host* "localhost")
(define *test-port* 1965)

;;; Response record for clean data modeling
(define-record-type <gemini-response>
  (make-gemini-response status meta body)
  gemini-response?
  (status gemini-response-status)
  (meta gemini-response-meta)
  (body gemini-response-body))

;;; Parse response header into structured data
(define (parse-gemini-response header-line)
  (let* ((header-parts (string-split header-line #\space))
         (status-code (string->number (car header-parts)))
         (meta (string-join (cdr header-parts) " ")))
    (values status-code meta)))

;;; Core connection abstraction - handles all TLS setup/teardown
(define (connect-and-request request-data handler)
  "Create TLS connection, send request, parse response, call handler with results"
  (let* ((socket (socket AF_INET SOCK_STREAM 0))
         ;; Resolve localhost to 127.0.0.1
         (host-addr (if (string=? *test-host* "localhost") "127.0.0.1" *test-host*))
         (addr (make-socket-address AF_INET 
                                   (inet-pton AF_INET host-addr) 
                                   *test-port*)))
    (connect socket addr)
    (let ((session (make-session connection-end/client)))
      (set-session-transport-fd! session (port->fdes socket))
      (set-session-default-priority! session)
      
      (catch #t
        (lambda ()
          ;; TLS handshake
          (handshake session)
          
          ;; Send request
          (put-string session request-data)
          (force-output session)
          
          ;; Read response header
          (let* ((header-line (get-line session))
                 (body (if (string-prefix? "2" header-line)
                          (get-string-all session)
                          "")))
            (call-with-values
              (lambda () (parse-gemini-response header-line))
              (lambda (status meta)
                ;; Clean up connection
                (bye session close-request/rdwr)
                (close-port session)
                ;; Call user handler with parsed results
                (handler (make-gemini-response status meta body))))))
        (lambda (key . args)
          (format #t "Connection error: ~a ~a\n" key args)
          ;; Clean up on error
          (catch #t (lambda () (bye session close-request/rdwr)) (lambda args #f))
          (catch #t (lambda () (close-port session)) (lambda args #f))
          ;; Return error response
          (handler (make-gemini-response #f "Connection failed" "")))))))

;;; High-level request abstraction for typical use cases
(define* (with-gemini-request uri-path handler #:optional (host *test-host*) (port *test-port*))
  "Make a gemini request and call handler with response"
  (let ((request (format #f "gemini://~a:~a~a\r\n" host port uri-path)))
    (connect-and-request request handler)))

;;; Raw request abstraction for testing malformed requests  
(define (with-raw-gemini-request raw-data handler)
  "Send raw data and call handler with response - for testing protocol edge cases"
  (connect-and-request raw-data handler))

;;; Declarative MIME type testing
(define (test-mime-types test-specs)
  "Test MIME types using declarative specifications"
  (for-each
    (lambda (spec)
      (let ((file-path (car spec))
            (expected-mime (cadr spec)))
        (with-gemini-request (string-append "/" file-path)
          (lambda (response)
            (test-equal (format #f "~a status" file-path) 
                       20 
                       (gemini-response-status response))
            (test-equal (format #f "~a MIME type" file-path)
                       expected-mime
                       (gemini-response-meta response))))))
    test-specs))

;;; Declarative malformed request testing
(define (test-malformed-requests test-specs)
  "Test malformed requests using declarative specifications"
  (for-each
    (lambda (spec)
      (let ((test-name (car spec))
            (raw-request (cadr spec))
            (expected-status (caddr spec))
            (meta-contains (if (> (length spec) 3) (cadddr spec) #f)))
        (with-raw-gemini-request raw-request
          (lambda (response)
            (test-equal (format #f "~a returns ~a" test-name expected-status)
                       expected-status
                       (gemini-response-status response))
            (when meta-contains
              (test-assert (format #f "~a meta contains ~a" test-name meta-contains)
                         (string-contains 
                           (string-downcase (gemini-response-meta response)) 
                           meta-contains)))))))
    test-specs))