;;; Acceptance Test: Malformed Request Handling  
;;; Black-box tests for bad request responses (status 59)

(define-module (acceptance-tests malformed-requests)
  #:use-module (srfi srfi-64)
  #:use-module (ice-9 networking)
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports))

;;; Test configuration
(define test-host "localhost")
(define test-port 1965)

;;; Helper to send raw data to server
(define (send-raw-request raw-data)
  "Send raw data to server, return status-code, meta, and body"
  (let* ((socket (socket AF_INET SOCK_STREAM 0))
         (addr (make-socket-address AF_INET 
                                   (inet-pton AF_INET test-host) 
                                   test-port)))
    (connect socket addr)
    (let ((session (make-session connection-end/client)))
      (set-session-transport-fd! session (port->fdes socket))
      (set-session-default-priority! session)
      (handshake session)
      
      (catch #t
        (lambda ()
          ;; Send raw request data
          (session-record-send session raw-data)
          
          ;; Read response header
          (let* ((header-line (session-record-recv session 1024))
                 (header-parts (string-split header-line #\space))
                 (status-code (string->number (car header-parts)))
                 (meta (string-join (cdr header-parts) " ")))
            
            ;; Error responses should have no body
            (bye session close-request/rdwr)
            (values status-code meta "")))
        (lambda (key . args)
          (format #t "Connection error: ~a ~a\n" key args)
          (values #f "Connection failed" ""))))))

;;; Test suite  
(test-begin "malformed-requests")

(test-equal "request too long (over 1024 bytes) returns 59"
  59
  (call-with-values
    (lambda () 
      (let ((long-uri (string-append "gemini://" test-host ":" (number->string test-port) "/"
                                    (make-string 1000 #\x) ; Make it over 1024 bytes total
                                    "\r\n")))
        (send-raw-request long-uri)))
    (lambda (status meta body)
      (test-assert "request too long meta"
                   (string-contains (string-downcase meta) "too long"))
      status)))

(test-equal "malformed URI (no scheme) returns 59"
  59
  (call-with-values
    (lambda () (send-raw-request (string-append "/just/a/path\r\n")))
    (lambda (status meta body)
      (test-assert "malformed URI meta"
                   (string-contains (string-downcase meta) "invalid"))
      status)))

(test-equal "wrong scheme (http) returns 59"  
  59
  (call-with-values
    (lambda () (send-raw-request (format #f "http://~a:~a/test.txt\r\n" test-host test-port)))
    (lambda (status meta body)
      (test-assert "wrong scheme meta"
                   (or (string-contains (string-downcase meta) "gemini")
                       (string-contains (string-downcase meta) "scheme")))
      status)))

(test-equal "URI with userinfo returns 59"
  59
  (call-with-values  
    (lambda () (send-raw-request (format #f "gemini://user:pass@~a:~a/test.txt\r\n" test-host test-port)))
    (lambda (status meta body)
      (test-assert "userinfo rejected meta"
                   (string-contains (string-downcase meta) "invalid"))
      status)))

(test-equal "URI with fragment returns 59"
  59
  (call-with-values
    (lambda () (send-raw-request (format #f "gemini://~a:~a/test.txt#fragment\r\n" test-host test-port)))
    (lambda (status meta body)
      (test-assert "fragment rejected meta"
                   (string-contains (string-downcase meta) "invalid"))
      status)))

(test-equal "request without CRLF returns 59"
  59
  (call-with-values
    (lambda () (send-raw-request (format #f "gemini://~a:~a/test.txt" test-host test-port))) ; No \r\n
    (lambda (status meta body)
      status)))

(test-equal "empty request returns 59"
  59
  (call-with-values
    (lambda () (send-raw-request "\r\n"))
    (lambda (status meta body)
      status)))

(test-end "malformed-requests")

;;; Export for test runner
(define (run-malformed-requests-tests)
  (display "Running malformed requests tests...\n"))