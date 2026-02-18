;;; Gemini Test Utilities
;;; Shared abstractions for elegant acceptance testing

(define-module (lib)
  #:use-module (srfi srfi-64)    ; Testing framework
  #:use-module (srfi srfi-9)     ; Records
  #:use-module (gnutls)          ; TLS connections
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 format)
  #:export (with-gemini-request
            with-raw-gemini-request
            assert-status
            assert-successful-status
            assert-error-status
            assert-mime-type
            assert-meta-contains
            assert-error-message
            assert-body-contains
            assert-body-length
            assert-body-empty
            assert-body-not-empty
            gemini-response?
            gemini-response-status
            gemini-response-meta
            gemini-response-body
            make-gemini-response))

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

;;; Request helpers

;;; Parse response header into structured data
(define (parse-gemini-response header-line)
  ;; Strip trailing \r from CRLF line endings (get-line only strips \n)
  (let* ((clean-line (string-trim-right header-line #\return))
         (header-parts (string-split clean-line #\space))
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
    (let ((session (make-session connection-end/client))
          (credentials (make-certificate-credentials)))
      ;; Set up TLS session - credentials must be set for handshake to work
      (set-session-credentials! session credentials)
      (set-session-transport-fd! session (fileno socket))
      (set-session-default-priority! session)
      
      (catch #t
        (lambda ()
          ;; TLS handshake
          (handshake session)
          
          ;; Get the session record port for I/O
          (let ((port (session-record-port session)))
            ;; Send request
            (put-string port request-data)
            (force-output port)
            
            ;; Read response header (just first line)
            (let ((header-line (get-line port)))
              (call-with-values
                (lambda () (parse-gemini-response header-line))
                (lambda (status meta)
                  ;; Read body only if status is 20
                  (let ((body (if (and status (= status 20))
                                 (get-string-all port)
                                 "")))
                    ;; Clean up connection
                    (catch #t (lambda () (close-port socket)) (lambda args #f))
                    ;; Call user handler with parsed results
                    (handler (make-gemini-response status meta body))))))))
        (lambda (key . args)
          (format #t "Connection error: ~a ~a\n" key args)
          ;; Clean up on error
          (catch #t (lambda () (close-port socket)) (lambda args #f))
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

;;; Assertion helpers

(define (assert-status response expected-status test-desc)
  "Verify response has expected status code"
  (test-equal (string-append test-desc " status") 
              expected-status 
              (gemini-response-status response)))

(define (assert-successful-status response test-desc)
  "Verify response has successful status (20)"
  (assert-status response 20 test-desc))

(define (assert-error-status response test-desc)
  "Verify response has error status (40-69 range)"
  (let ((status (gemini-response-status response)))
    (test-assert (string-append test-desc " error status")
                (and status (>= status 40) (<= status 69)))))

(define (assert-mime-type response expected-mime test-desc)
  "Verify response has expected MIME type"
  (test-equal (string-append test-desc " MIME type")
              expected-mime
              (gemini-response-meta response)))

(define (assert-meta-contains response expected-substring test-desc)
  "Verify response meta field contains expected substring"
  (test-assert (string-append test-desc " meta contains '" expected-substring "'")
               (string-contains 
                 (string-downcase (gemini-response-meta response))
                 (string-downcase expected-substring))))

(define (assert-error-message response expected-message test-desc)
  "Verify response error meta field contains expected message"
  (assert-meta-contains response expected-message test-desc))

(define (assert-body-contains response expected-substring test-desc)
  "Verify response body contains expected substring"
  (test-assert (string-append test-desc " body contains '" expected-substring "'")
               (string-contains (gemini-response-body response) expected-substring)))

(define (assert-body-length response expected-length test-desc)
  "Verify response body has expected length"
  (test-equal (string-append test-desc " body length")
              expected-length
              (string-length (gemini-response-body response))))

(define (assert-body-empty response test-desc)
  "Verify response body is empty"
  (test-equal (string-append test-desc " body is empty")
              0
              (string-length (gemini-response-body response))))

(define (assert-body-not-empty response test-desc)
  "Verify response body is not empty"
  (test-assert (string-append test-desc " body is not empty")
               (> (string-length (gemini-response-body response)) 0)))
