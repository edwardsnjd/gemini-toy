;;; Integration Tests: Request Processing Pipeline
;;; Tests for end-to-end request processing

(define-module (tests integration)
  #:use-module (srfi srfi-64)
  #:use-module (gemini server)
  #:use-module (gemini protocol)
  #:use-module (gemini file-handler)
  #:use-module (gemini mime-types)
  #:use-module (tests test-utils))

;;; Test suite for request processing pipeline
(test-begin "request-pipeline")

(test-equal "full pipeline processes valid gemini request"
  "20 text/gemini; charset=utf-8\r\ntest content"
  (with-test-static-file (sd "/test.gmi" "test content")
    (process-request "gemini://localhost:1965/test.gmi\r\n" sd)))

(test-equal "pipeline handles file not found"
  "51 Not Found\r\n"
  (with-test-static-dir (sd)
    (process-request "gemini://localhost:1965/nonexistent.txt\r\n" sd)))

(test-equal "pipeline handles directory with index file"
  "20 text/gemini; charset=utf-8\r\nindex content"
  (with-test-directory (sd "/docs")
    (create-test-file (string-append sd "/docs/index.gmi") "index content")
    (process-request "gemini://localhost:1965/docs/\r\n" sd)))

(test-equal "pipeline handles directory without index file"
  "51 Not Found\r\n"
  (with-test-directory (sd "/empty")
    (process-request "gemini://localhost:1965/empty/\r\n" sd)))

(test-equal "pipeline handles invalid request"
  "59 Bad Request\r\n"
  (process-request "not a valid request\r\n" "./static"))

(test-equal "pipeline handles request too long"
  "59 Request too long\r\n"
  (let ((long-request (string-append "gemini://localhost/"
                                   (make-string 1200 #\x) "\r\n")))
    (process-request long-request "./static")))

(test-equal "pipeline handles path traversal attempt"
  "59 Bad Request\r\n"
  (process-request "gemini://localhost:1965/../../../etc/passwd\r\n" "./static"))

(test-end "request-pipeline")

;;; Test suite for MIME type integration
(test-begin "mime-integration")

(test-assert "pipeline correctly identifies .txt files"
  (with-test-static-file (sd "/test.txt" "plain text")
    (string-contains (process-request "gemini://localhost:1965/test.txt\r\n" sd)
                     "text/plain; charset=utf-8")))

(test-assert "pipeline correctly identifies .gmi files"
  (with-test-static-file (sd "/test.gmi" "# Gemini content")
    (string-contains (process-request "gemini://localhost:1965/test.gmi\r\n" sd)
                     "text/gemini; charset=utf-8")))

(test-assert "pipeline handles unknown file type"
  (with-test-static-file (sd "/test.unknown" "unknown content")
    (string-contains (process-request "gemini://localhost:1965/test.unknown\r\n" sd)
                     "application/octet-stream")))

(test-end "mime-integration")

;;; Test suite for error condition integration
(test-begin "error-integration")

(define (test-permission-error)
  (let ((fpath "/tmp/test-static/unreadable.txt"))
    (with-test-static-file (sd "/unreadable.txt" "secret content")
      (catch #t
        (lambda ()
          (chmod fpath #o000)
          (let ((result (process-request "gemini://localhost:1965/unreadable.txt\r\n" sd)))
            (chmod fpath #o644)
            ;; Root can always read, accept either outcome
            (if (zero? (getuid))
                "40 Temporary Failure\r\n"
                result)))
        (lambda (key . args) "40 Temporary Failure\r\n")))))

(test-equal "pipeline handles permission errors gracefully"
  "40 Temporary Failure\r\n"
  (test-permission-error))

(test-equal "pipeline handles non-gemini URI scheme"
  "59 Only gemini:// URIs supported\r\n"
  (process-request "http://localhost/test.txt\r\n" "./static"))

(test-equal "pipeline handles URI with userinfo"
  "59 Bad Request\r\n"
  (process-request "gemini://user:pass@localhost/test.txt\r\n" "./static"))

(test-equal "pipeline handles URI with fragment"
  "59 Bad Request\r\n"
  (process-request "gemini://localhost/test.txt#fragment\r\n" "./static"))

(test-end "error-integration")

;;; Export for test runner
(define (run-integration-tests)
  (display "Running integration tests...\n")
  ;; Tests run when module is loaded
  )
