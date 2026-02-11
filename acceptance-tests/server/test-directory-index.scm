;;; Acceptance Test: Directory Index Handling
;;; Black-box tests for directory index file serving

(define-module (acceptance-tests directory-index)
  #:use-module (srfi srfi-64)
  ;; Note: socket functions available as built-ins
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports))

;;; Test configuration  
(define test-host "localhost")
(define test-port 1965)

;;; Helper to make Gemini request (reused from basic tests)
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
(test-begin "directory-index")

(test-equal "root directory serves index.gmi"
  20
  (call-with-values 
    (lambda () (gemini-request (format #f "gemini://~a:~a/" test-host test-port)))
    (lambda (status meta body)
      (test-equal "index content type" "text/gemini; charset=utf-8" meta)
      (test-assert "index body contains welcome" 
                   (string-contains body "Welcome"))
      status)))

(test-equal "root without trailing slash serves index.gmi"
  20
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a" test-host test-port)))
    (lambda (status meta body)
      (test-equal "no-slash index content type" "text/gemini; charset=utf-8" meta)
      (test-assert "no-slash index body contains welcome"
                   (string-contains body "Welcome"))
      status)))

(test-equal "subdirectory with index.gmi"
  20
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/subdir/" test-host test-port)))
    (lambda (status meta body)
      (test-equal "subdir index content type" "text/gemini; charset=utf-8" meta)
      status)))

(test-equal "subdirectory without index file returns 51 (Not Found)"
  51
  (call-with-values
    (lambda () (gemini-request (format #f "gemini://~a:~a/empty-dir/" test-host test-port)))
    (lambda (status meta body)
      (test-assert "not found meta contains error" 
                   (string-contains (string-downcase meta) "not found"))
      status)))

(test-end "directory-index")

;;; Export for test runner
(define (run-directory-index-tests)
  (display "Running directory index tests...\n"))