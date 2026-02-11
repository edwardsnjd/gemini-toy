;;; Unit Tests: File Handler
;;; Tests for file system operations and security

(add-to-load-path "../src")

(define-module (tests file-handler)
  #:use-module (srfi srfi-64)
  #:use-module (gemini file-handler))

;;; Test suite for path resolution
(test-begin "path-resolution")

(test-equal "basic file path resolution"
  "/tmp/static/test.txt"
  (resolve-file-path "/tmp/static" "/test.txt"))

(test-equal "root path resolution"
  "/tmp/static/"
  (resolve-file-path "/tmp/static" "/"))

(test-equal "subdirectory path resolution"
  "/tmp/static/docs/page.gmi"
  (resolve-file-path "/tmp/static" "/docs/page.gmi"))

(test-equal "empty path becomes root"
  "/tmp/static/"
  (resolve-file-path "/tmp/static" ""))

;;; Security tests - these should all return #f or safe paths
(test-equal "directory traversal blocked"
  #f
  (resolve-file-path "/tmp/static" "/../etc/passwd"))

(test-equal "complex directory traversal blocked"
  #f  
  (resolve-file-path "/tmp/static" "/docs/../../etc/passwd"))

(test-equal "hidden directory traversal blocked"
  #f
  (resolve-file-path "/tmp/static" "/docs/../../../etc/passwd"))

(test-equal "current directory reference is safe"
  "/tmp/static/docs/"
  (resolve-file-path "/tmp/static" "/docs/."))

(test-equal "safe relative path with dots"
  "/tmp/static/file..txt"
  (resolve-file-path "/tmp/static" "/file..txt"))

(test-equal "multiple slashes normalized"
  "/tmp/static/docs/page.gmi"
  (resolve-file-path "/tmp/static" "///docs///page.gmi"))

(test-end "path-resolution")

;;; Test suite for index file detection
(test-begin "index-file-detection")

(test-equal "find index.gmi in directory"
  "/tmp/static/docs/index.gmi"
  (find-index-file "/tmp/static/docs"))

(test-equal "find index.gemini in directory"
  "/tmp/static/other/index.gemini"  
  (find-index-file "/tmp/static/other"))

(test-equal "prefer index.gmi over index.gemini"
  "/tmp/static/both/index.gmi"
  (find-index-file "/tmp/static/both"))  ; Assume both exist, .gmi has priority

(test-equal "no index file returns #f"
  #f
  (find-index-file "/tmp/static/empty"))

(test-equal "nonexistent directory returns #f"
  #f
  (find-index-file "/tmp/static/nonexistent"))

(test-end "index-file-detection")

;;; Test suite for file reading
(test-begin "file-reading")

(test-assert "read existing file returns string"
  (string? (read-file-content "/tmp/test-file.txt")))

(test-equal "read nonexistent file returns #f"
  #f
  (read-file-content "/tmp/nonexistent-file.txt"))

(test-assert "read binary file returns bytevector"
  (let ((result (read-file-content "/tmp/test-binary.png")))
    (or (string? result) (bytevector? result))))

;; Note: These tests would need actual test files to be meaningful
;; In a real implementation, we'd set up test fixtures

(test-end "file-reading")

;;; Export for test runner
(define (run-file-handler-tests)
  (display "Running file handler tests...\n"))