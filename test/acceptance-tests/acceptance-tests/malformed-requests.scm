;;; Acceptance Test: Malformed Request Handling  
;;; Black-box tests for bad request responses (status 59)

(define-module (acceptance-tests malformed-requests)
  #:use-module (srfi srfi-64)
  #:use-module (gemini-test-utils)
  #:use-module (ice-9 format))

;;; Declarative malformed request test specifications
;;; Format: (test-name raw-request expected-status [meta-contains])
(define malformed-request-specs
  (list
    (list "request too long (over 1024 bytes)" 
          (string-append "gemini://localhost:1965/" (make-string 1000 #\x) "\r\n")
          59 
          "too long")
    (list "malformed URI (no scheme)"
          "/just/a/path\r\n"
          59
          "bad request")
    (list "wrong scheme (http)"
          "http://localhost:1965/test.txt\r\n" 
          59
          "gemini")
    (list "URI with userinfo"
          "gemini://user:pass@localhost:1965/test.txt\r\n"
          59
          "bad request") 
    (list "URI with fragment"
          "gemini://localhost:1965/test.txt#fragment\r\n"
          59
          "bad request")))
    ;; Note: Tests for "request without CRLF" and "empty request" are omitted
    ;; because they cause the server to hang waiting for input (expected behavior)
    ;; and would require timeout support in the test client

;;; Test suite using declarative approach
(test-begin "malformed-requests")

;; Run all malformed request tests declaratively
(test-malformed-requests malformed-request-specs)

(test-end "malformed-requests")

;;; Export for test runner
(define (run-malformed-requests-tests)
  (display "Running malformed requests tests...\n"))