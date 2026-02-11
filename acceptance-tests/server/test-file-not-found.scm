;;; Acceptance Test: File Not Found Handling
;;; Black-box tests for 404-equivalent responses (status 51)

(define-module (acceptance-tests file-not-found)
  #:use-module (srfi srfi-64)
  ;; Note: socket functions available as built-ins
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports))

;;; Test configuration
(define test-host "localhost")
(define test-port 1965)

;;; Helper to make Gemini request
(define (gemini-request uri-string)
  "Send Gemini request, return status-code, meta, and body"
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
          ;; Send request
          (let ((request (string-append uri-string "\r\n")))
            (session-record-send session request))
          
          ;; Read response header
          (let* ((header-line (session-record-recv session 1024))
                 (header-parts (string-split header-line #\space))
                 (status-code (string->number (car header-parts)))
                 (meta (string-join (cdr header-parts) " ")))
            
            ;; For error responses, no body should be sent
            (let ((body (if (= status-code 20)
                           (session-record-recv session 65536)
                           "")))
              (bye session close-request/rdwr)
              (values status-code meta body))))
        (lambda (key . args)
          (format #t "Connection error: ~a ~a\n" key args)
          (values #f "Connection failed" ""))))))

;;; Test suite
(test-begin "file-not-found")

(test-equal "nonexistent file returns 51"
  51
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/does-not-exist.txt" test-host test-port)))
    (lambda (status meta body)
      (test-assert "not found meta message" 
                   (string-contains (string-downcase meta) "not found"))
      (test-equal "no body for error response" "" body)
      status)))

(test-equal "nonexistent gemini file returns 51"
  51
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/missing.gmi" test-host test-port)))
    (lambda (status meta body)
      (test-assert "gmi not found meta message"
                   (string-contains (string-downcase meta) "not found"))
      status)))

(test-equal "nonexistent path in subdirectory returns 51"
  51
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/subdir/missing.txt" test-host test-port)))
    (lambda (status meta body)
      (test-assert "subdir not found meta message"
                   (string-contains (string-downcase meta) "not found"))
      status)))

(test-equal "path traversal attempt returns 51 or 59"
  #t  ; Should be either 51 (not found) or 59 (bad request)
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/../etc/passwd" test-host test-port)))
    (lambda (status meta body)
      (test-assert "path traversal blocked"
                   (or (= status 51) (= status 59)))
      (test-equal "no body for path traversal" "" body)
      (or (= status 51) (= status 59)))))

(test-equal "double dot path traversal returns 51 or 59"
  #t
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/subdir/../../etc/passwd" test-host test-port)))
    (lambda (status meta body)
      (or (= status 51) (= status 59)))))

(test-end "file-not-found")

;;; Export for test runner  
(define (run-file-not-found-tests)
  (display "Running file not found tests...\n"))