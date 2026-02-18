;;; Acceptance Test: MIME Type Detection
;;; Black-box tests for correct MIME type responses

(define-module (mime-types)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

(test-begin "mime-types")

(test-begin ".gmi -> text/gemini")
(with-gemini-request "/test.gmi"
  (lambda (response)
    (assert-status response 20 "test.gmi status")
    (assert-mime-type response "text/gemini; charset=utf-8" "test.gmi MIME type")))
(test-end)

(test-begin ".gemini -> text/gemini")
(with-gemini-request "/test.gemini"
  (lambda (response)
    (assert-status response 20 "test.gemini status")
    (assert-mime-type response "text/gemini; charset=utf-8" "test.gemini MIME type")))
(test-end)

(test-begin ".txt -> text/plain")
(with-gemini-request "/test.txt"
  (lambda (response)
    (assert-status response 20 "test.txt status")
    (assert-mime-type response "text/plain; charset=utf-8" "test.txt MIME type")))
(test-end)

(test-begin ".html -> text/html")
(with-gemini-request "/test.html"
  (lambda (response)
    (assert-status response 20 "test.html status")
    (assert-mime-type response "text/html; charset=utf-8" "test.html MIME type")))
(test-end)

(test-begin ".png -> image/png")
(with-gemini-request "/test.png"
  (lambda (response)
    (assert-status response 20 "test.png status")
    (assert-mime-type response "image/png" "test.png MIME type")))
(test-end)

(test-begin ".jpg -> image/jpeg")
(with-gemini-request "/test.jpg"
  (lambda (response)
    (assert-status response 20 "test.jpg status")
    (assert-mime-type response "image/jpeg" "test.jpg MIME type")))
(test-end)

(test-begin ".unknown -> application/octet-stream")
(with-gemini-request "/test.unknown"
  (lambda (response)
    (assert-status response 20 "test.unknown status")
    (assert-mime-type response "application/octet-stream" "test.unknown MIME type")))
(test-end)

(test-begin "(no extension) -> application/octet-stream")
(with-gemini-request "/no-extension"
  (lambda (response)
    (assert-status response 20 "no extension file status")
    (assert-mime-type response "application/octet-stream" "no extension has fallback MIME type")))
(test-end)

(test-end "mime-types")
