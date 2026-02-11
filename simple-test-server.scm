#!/usr/bin/env guile
!#

;;; Simple Gemini test server for error condition testing
(use-modules (ice-9 textual-ports)
             (ice-9 format))

;; Simple socket server that accepts connections and responds with Gemini protocol
(define (handle-request request)
  "Process a Gemini request and return appropriate response"
  (cond
    ;; Empty request
    ((string=? request "") "59 Bad Request - empty request\r\n")
    
    ;; Request too long (>1024 bytes)
    ((> (string-length request) 1024) "59 Bad Request - request too long\r\n")
    
    ;; Invalid URI format
    ((not (string-prefix? "gemini://" request)) "59 Bad Request - invalid scheme\r\n")
    
    ;; Path traversal attempts
    ((string-contains request "..") "59 Bad Request - path traversal not allowed\r\n")
    
    ;; URI with userinfo
    ((string-match "gemini://[^/]*@" request) "59 Bad Request - userinfo not allowed\r\n")
    
    ;; URI with fragment
    ((string-contains request "#") "59 Bad Request - fragment not allowed\r\n")
    
    ;; Non-existent file
    ((string-suffix? "/does-not-exist.gmi" request) "51 Not Found\r\n")
    
    ;; Default success response
    (else "20 text/gemini\r\n# Test Page\n=> /test.gmi Test link\n")))

;; For testing purposes, we'll create a simple HTTP server that responds with Gemini-like responses
;; since setting up TLS in a simple script is complex

(define (start-simple-server port)
  "Start a simple server for testing (without TLS for simplicity)"
  (let ((server-sock (socket PF_INET SOCK_STREAM 0)))
    (setsockopt server-sock SOL_SOCKET SO_REUSEADDR 1)
    (bind server-sock AF_INET INADDR_ANY port)
    (listen server-sock 5)
    
    (format #t "Simple test server listening on port ~a~%" port)
    (format #t "Note: This is a plain TCP server (no TLS) for testing protocol logic~%")
    
    (let loop ()
      (let* ((client-sock (accept server-sock))
             (client-conn (car client-sock)))
        (catch #t
          (lambda ()
            (let ((request (get-line (car (fdopen client-conn "r+")))))
              (if (not (eof-object? request))
                  (let ((response (handle-request (string-trim-right request))))
                    (display response (cdr (fdopen client-conn "r+")))
                    (force-output (cdr (fdopen client-conn "r+")))))))
          (lambda (key . args)
            (format #t "Error handling client: ~a ~a~%" key args)))
        
        (close client-conn)
        (loop)))))

;; Start server on port 1966 (different from standard Gemini port)
(start-simple-server 1966)
