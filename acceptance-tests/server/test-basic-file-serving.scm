;;; Acceptance Test: Basic File Serving
;;; Black-box tests for file serving over TLS

(define-module (acceptance-tests basic-file-serving)
  #:use-module (srfi srfi-64)
  #:use-module (gemini-test-utils))

;;; Test suite using elegant abstractions
(test-begin "basic-file-serving")

(test-equal "basic text file serving"
  20
  (with-gemini-request "/test.txt"
    (lambda (response)
      (test-equal "content type for text file" 
                  "text/plain; charset=utf-8" 
                  (gemini-response-meta response))
      (test-assert "body contains content" 
                   (> (string-length (gemini-response-body response)) 0))
      (gemini-response-status response))))

(test-equal "gemini file serving" 
  20
  (with-gemini-request "/test.gmi"
    (lambda (response)
      (test-equal "content type for gmi file" 
                  "text/gemini; charset=utf-8" 
                  (gemini-response-meta response))
      (test-assert "gmi body contains content" 
                   (> (string-length (gemini-response-body response)) 0))
      (gemini-response-status response))))

(test-equal "root path handling"
  20
  (with-gemini-request "/"
    (lambda (response)
      (gemini-response-status response))))

(test-end "basic-file-serving")

;;; Export for test runner
(define (run-basic-file-serving-tests)
  (display "Running basic file serving tests...\n"))