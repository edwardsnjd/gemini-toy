;;; Acceptance Test: Basic File Serving
;;; Black-box tests for file serving over TLS

(define-module (basic-file-serving)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

(test-begin "basic-file-serving")

(test-begin "basic text file serving")
(with-gemini-request "/test.txt"
  (lambda (response)
    (assert-successful-status response "text file")
    (assert-body-not-empty response "text file")))
(test-end)

(test-begin "gemini file serving")
(with-gemini-request "/test.gmi"
  (lambda (response)
    (assert-successful-status response "gmi file")
    (assert-body-not-empty response "gmi file")))
(test-end)

(test-begin "root path handling")
(with-gemini-request "/"
  (lambda (response)
    (assert-successful-status response "root path")))
(test-end)

(test-end "basic-file-serving")
