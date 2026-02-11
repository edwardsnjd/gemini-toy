;;; Acceptance Test: Basic File Serving
;;; Black-box tests for file serving over TLS

(define-module (acceptance-tests basic-file-serving)
  #:use-module (srfi srfi-64)
  ;; Note: socket functions available as built-ins
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 binary-ports))

;;; Test configuration
(define test-host "localhost")
(define test-port 1965)

;;; Helper to make TLS connection to server
(define (connect-to-gemini-server)
  "Connect to Gemini server with TLS, return session"
  (let* ((socket (socket AF_INET SOCK_STREAM 0))
         (addr (make-socket-address AF_INET 
                                   (inet-pton AF_INET test-host) 
                                   test-port)))
    (connect socket addr)
    ;; Set up TLS
    (let ((session (make-session connection-end/client)))
      (set-session-transport-fd! session (port->fdes socket))
      (set-session-default-priority! session)
      (handshake session)
      session)))

;;; Helper to send request and read response
(define (gemini-request uri-string)
  "Send Gemini request, return status-code, meta, and body"
  (let ((session (connect-to-gemini-server)))
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
          
          ;; Read body if success status
          (let ((body (if (= status-code 20)
                         (session-record-recv session 65536)
                         "")))
            (bye session close-request/rdwr)
            (values status-code meta body))))
      (lambda (key . args)
        (format #t "Connection error: ~a ~a\n" key args)
        (values #f "Connection failed" "")))))

;;; Test suite
(test-begin "basic-file-serving")

(test-equal "basic text file serving"
  20  ; Expected status code
  (call-with-values 
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.txt" test-host test-port)))
    (lambda (status meta body)
      (test-equal "content type for text file" "text/plain; charset=utf-8" meta)
      (test-assert "body contains content" (> (string-length body) 0))
      status)))

(test-equal "gemini file serving" 
  20  ; Expected status code
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.gmi" test-host test-port)))
    (lambda (status meta body)
      (test-equal "content type for gmi file" "text/gemini; charset=utf-8" meta)
      (test-assert "gmi body contains content" (> (string-length body) 0))
      status)))

(test-equal "root path handling"
  20  ; Expected status code  
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/" test-host test-port)))
    (lambda (status meta body)
      ;; Should serve index file
      status)))

(test-end "basic-file-serving")

;;; Export for test runner
(define (run-basic-file-serving-tests)
  (display "Running basic file serving tests...\n")
  ;; Tests run when module is loaded
  )