;;; Acceptance Test: Directory Index Handling
;;; Black-box tests for directory index file serving

(define-module (acceptance-tests directory-index)
  #:use-module (srfi srfi-64)
  #:use-module (gemini-test-utils))

;;; Test suite using elegant abstractions
(test-begin "directory-index")

(test-equal "root directory serves index.gmi"
  20
  (with-gemini-request "/"
    (lambda (response)
      (test-equal "index content type" 
                  "text/gemini; charset=utf-8" 
                  (gemini-response-meta response))
      (test-assert "index body contains welcome" 
                   (string-contains (gemini-response-body response) "Welcome"))
      (gemini-response-status response))))

(test-equal "root without trailing slash serves index.gmi"
  20
  (with-gemini-request ""
    (lambda (response)
      (test-equal "no-slash index content type" 
                  "text/gemini; charset=utf-8" 
                  (gemini-response-meta response))
      (test-assert "no-slash index body contains welcome"
                   (string-contains (gemini-response-body response) "Welcome"))
      (gemini-response-status response))))

(test-equal "subdirectory with index.gmi"
  20
  (with-gemini-request "/subdir/"
    (lambda (response)
      (test-equal "subdir index content type" 
                  "text/gemini; charset=utf-8" 
                  (gemini-response-meta response))
      (gemini-response-status response))))

(test-equal "subdirectory without index file returns 51 (Not Found)"
  51
  (with-gemini-request "/empty-dir/"
    (lambda (response)
      (test-assert "not found meta contains error" 
                   (string-contains (string-downcase (gemini-response-meta response)) "not found"))
      (gemini-response-status response))))

(test-end "directory-index")

;;; Export for test runner
(define (run-directory-index-tests)
  (display "Running directory index tests...\n"))