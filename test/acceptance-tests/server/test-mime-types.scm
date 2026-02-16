;;; Acceptance Test: MIME Type Detection
;;; Black-box tests for correct MIME type responses

(define-module (acceptance-tests mime-types)
  #:use-module (srfi srfi-64)
  #:use-module (gemini-test-utils))

;;; Declarative MIME type test specifications
(define mime-type-test-specs
  '(("test.gmi"     "text/gemini; charset=utf-8")
    ("test.gemini"  "text/gemini; charset=utf-8") 
    ("test.txt"     "text/plain; charset=utf-8")
    ("test.html"    "text/html; charset=utf-8")
    ("test.png"     "image/png")
    ("test.jpg"     "image/jpeg")
    ("test.unknown" "application/octet-stream")))

;;; Test suite using declarative approach
(test-begin "mime-types")

;; Run all MIME type tests declaratively
(test-mime-types mime-type-test-specs)

;; Special case: file with no extension
(test-equal "no extension has fallback MIME type"
  "application/octet-stream"
  (with-gemini-request "/no-extension"
    (lambda (response)
      (test-equal "no extension file status" 20 (gemini-response-status response))
      (gemini-response-meta response))))

(test-end "mime-types")

;;; Export for test runner
(define (run-mime-types-tests)
  (display "Running MIME types tests...\n"))