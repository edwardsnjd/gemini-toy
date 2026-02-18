;;; Acceptance Test: Malformed Request Handling
;;; Black-box tests for bad request responses (status 59)

(define-module (malformed-requests)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

;; Note: Tests for "request without CRLF" and "empty request" are omitted
;; because they cause the server to hang waiting for input (expected behavior)
;; and would require timeout support in the test client

(test-begin "malformed-requests")

(test-begin "request too long (over 1024 bytes)")
(with-raw-gemini-request (string-append "gemini://localhost:1965/" (make-string 1000 #\x) "\r\n")
  (lambda (response)
    (assert-status response 59 "request too long returns 59")
    (assert-meta-contains response "too long" "request too long meta contains 'too long'")))
(test-end)

(test-begin "malformed URI (no scheme)")
(with-raw-gemini-request "/just/a/path\r\n"
  (lambda (response)
    (assert-status response 59 "malformed URI (no scheme) returns 59")
    (assert-meta-contains response "bad request" "malformed URI meta contains 'bad request'")))
(test-end)

(test-begin "wrong scheme (http)")
(with-raw-gemini-request "http://localhost:1965/test.txt\r\n"
  (lambda (response)
    (assert-status response 59 "wrong scheme (http) returns 59")
    (assert-meta-contains response "gemini" "wrong scheme meta contains 'gemini'")))
(test-end)

(test-begin "URI with userinfo")
(with-raw-gemini-request "gemini://user:pass@localhost:1965/test.txt\r\n"
  (lambda (response)
    (assert-status response 59 "URI with userinfo returns 59")
    (assert-meta-contains response "bad request" "URI with userinfo meta contains 'bad request'")))
(test-end)

(test-begin "URI with fragment")
(with-raw-gemini-request "gemini://localhost:1965/test.txt#fragment\r\n"
  (lambda (response)
    (assert-status response 59 "URI with fragment returns 59")
    (assert-meta-contains response "bad request" "URI with fragment meta contains 'bad request'")))
(test-end)

(test-end "malformed-requests")
