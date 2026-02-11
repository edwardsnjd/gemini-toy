;;; Acceptance Test: MIME Type Detection
;;; Black-box tests for correct MIME type responses

(define-module (acceptance-tests mime-types)
  #:use-module (srfi srfi-64)
  #:use-module (ice-9 networking)
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
          
          ;; Read response
          (let* ((header-line (session-record-recv session 1024))
                 (header-parts (string-split header-line #\space))
                 (status-code (string->number (car header-parts)))
                 (meta (string-join (cdr header-parts) " ")))
            
            (let ((body (if (= status-code 20)
                           (session-record-recv session 65536)
                           "")))
              (bye session close-request/rdwr)
              (values status-code meta body))))
        (lambda (key . args)
          (format #t "Connection error: ~a ~a\n" key args)
          (values #f "Connection failed" ""))))))

;;; Test suite
(test-begin "mime-types")

(test-equal ".gmi file has correct MIME type"
  "text/gemini; charset=utf-8"
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.gmi" test-host test-port)))
    (lambda (status meta body)
      (test-equal "gmi file status" 20 status)
      meta)))

(test-equal ".gemini file has correct MIME type"
  "text/gemini; charset=utf-8"
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.gemini" test-host test-port)))
    (lambda (status meta body)
      (test-equal "gemini file status" 20 status)
      meta)))

(test-equal ".txt file has correct MIME type"
  "text/plain; charset=utf-8"
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.txt" test-host test-port)))
    (lambda (status meta body)
      (test-equal "txt file status" 20 status)
      meta)))

(test-equal ".html file has correct MIME type"
  "text/html; charset=utf-8"
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.html" test-host test-port)))
    (lambda (status meta body)
      (test-equal "html file status" 20 status)
      meta)))

(test-equal ".png file has correct MIME type"  
  "image/png"
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.png" test-host test-port)))
    (lambda (status meta body)
      (test-equal "png file status" 20 status)
      meta)))

(test-equal ".jpg file has correct MIME type"
  "image/jpeg"  
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.jpg" test-host test-port)))
    (lambda (status meta body)
      (test-equal "jpg file status" 20 status)
      meta)))

(test-equal "unknown extension has fallback MIME type"
  "application/octet-stream"
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/test.unknown" test-host test-port)))
    (lambda (status meta body)
      (test-equal "unknown file status" 20 status)
      meta)))

(test-equal "no extension has fallback MIME type"
  "application/octet-stream"
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/no-extension" test-host test-port)))
    (lambda (status meta body)
      (test-equal "no extension file status" 20 status)
      meta)))

(test-end "mime-types")

;;; Export for test runner
(define (run-mime-types-tests)
  (display "Running MIME types tests...\n"))