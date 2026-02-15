;;; Acceptance Test: File Not Found Handling
;;; Black-box tests for 404-equivalent responses (status 51)

(define-module (acceptance-tests file-not-found)
  #:use-module (srfi srfi-64)
  #:use-module (gemini-test-utils))

;;; Test suite using elegant abstractions
(test-begin "file-not-found")

(test-equal "nonexistent file returns 51"
  51
  (with-gemini-request "/does-not-exist.txt"
    (lambda (response)
      (test-assert "not found meta message" 
                   (string-contains (string-downcase (gemini-response-meta response)) "not found"))
      (test-equal "no body for error response" "" (gemini-response-body response))
      (gemini-response-status response))))

(test-equal "nonexistent gemini file returns 51"
  51
  (with-gemini-request "/missing.gmi"
    (lambda (response)
      (test-assert "gmi not found meta message"
                   (string-contains (string-downcase (gemini-response-meta response)) "not found"))
      (gemini-response-status response))))

(test-equal "nonexistent path in subdirectory returns 51"
  51
  (with-gemini-request "/subdir/missing.txt"
    (lambda (response)
      (test-assert "subdir not found meta message"
                   (string-contains (string-downcase (gemini-response-meta response)) "not found"))
      (gemini-response-status response))))

(test-equal "path traversal attempt returns 51 or 59"
  #t  ; Should be either 51 (not found) or 59 (bad request)
  (with-gemini-request "/../etc/passwd"
    (lambda (response)
      (let ((status (gemini-response-status response)))
        (test-assert "path traversal blocked" (or (= status 51) (= status 59)))
        (test-equal "no body for path traversal" "" (gemini-response-body response))
        (or (= status 51) (= status 59))))))

(test-equal "double dot path traversal returns 51 or 59"
  #t
  (with-gemini-request "/subdir/../../etc/passwd"
    (lambda (response)
      (let ((status (gemini-response-status response)))
        (or (= status 51) (= status 59))))))

(test-end "file-not-found")

;;; Export for test runner  
(define (run-file-not-found-tests)
  (display "Running file not found tests...\n"))