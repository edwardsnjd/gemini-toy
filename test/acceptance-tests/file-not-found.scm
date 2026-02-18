;;; Acceptance Test: File Not Found Handling
;;; Black-box tests for 404-equivalent responses (status 51)

(define-module (file-not-found)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

;;; Test suite using elegant abstractions
(test-begin "file-not-found")

(test-begin "nonexistent file returns 51")
(with-gemini-request "/does-not-exist.txt"
  (lambda (response)
    (assert-status response 51 "nonexistent file")
    (assert-meta-contains response "not found" "nonexistent file")
    (assert-body-empty response "nonexistent file")))
(test-end)

(test-begin "nonexistent gemini file returns 51")
(with-gemini-request "/missing.gmi"
  (lambda (response)
    (assert-status response 51 "missing gmi file")
    (assert-meta-contains response "not found" "missing gmi file")))
(test-end)

(test-begin "nonexistent path in subdirectory returns 51")
(with-gemini-request "/subdir/missing.txt"
  (lambda (response)
    (assert-status response 51 "subdir missing file")
    (assert-meta-contains response "not found" "subdir missing file")))
(test-end)

(test-begin "path traversal attempt returns 51 or 59")
(with-gemini-request "/../etc/passwd"
  (lambda (response)
    (let ((status (gemini-response-status response)))
      (test-assert "path traversal blocked" (or (= status 51) (= status 59)))
      (assert-body-empty response "path traversal"))))
(test-end)

(test-begin "double dot path traversal returns 51 or 59")
(with-gemini-request "/subdir/../../etc/passwd"
  (lambda (response)
    (let ((status (gemini-response-status response)))
      (test-assert "double dot path traversal blocked" (or (= status 51) (= status 59))))))
(test-end)

(test-end "file-not-found")
