;;; Unit Tests: File Handler
;;; Tests for file system operations and security

(define-module (tests file-handler)
  #:use-module (srfi srfi-64)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 ftw)          ; For scandir
  #:use-module (rnrs bytevectors)  ; For bytevector?
  #:use-module (gemini file-handler))

;;; Helper: create a file with given content
(define (create-test-file path content)
  (call-with-output-file path
    (lambda (port) (display content port))))

;;; Helper: recursively remove a directory tree
(define (rm-rf path)
  (when (file-exists? path)
    (if (file-is-directory? path)
        (begin
          (let ((entries (scandir path (lambda (f) (not (member f '("." "..")))))))
            (when entries
              (for-each (lambda (entry)
                          (rm-rf (string-append path "/" entry)))
                        entries)))
          (rmdir path))
        (delete-file path))))

;;; Set up test fixtures for path-resolution and index-file tests
(define test-root "/tmp/gemini-test-static")

(define (setup-test-fixtures)
  (rm-rf test-root)
  (mkdir test-root)
  ;; Create files for path resolution tests
  (create-test-file (string-append test-root "/test.txt") "test content")
  (mkdir (string-append test-root "/docs"))
  (create-test-file (string-append test-root "/docs/page.gmi") "# Page")
  (create-test-file (string-append test-root "/file..txt") "dots in name")
  ;; Create dirs/files for index file tests
  (create-test-file (string-append test-root "/docs/index.gmi") "docs index")
  (mkdir (string-append test-root "/other"))
  (create-test-file (string-append test-root "/other/index.gemini") "other index")
  (mkdir (string-append test-root "/both"))
  (create-test-file (string-append test-root "/both/index.gmi") "both gmi")
  (create-test-file (string-append test-root "/both/index.gemini") "both gemini")
  (mkdir (string-append test-root "/empty")))

(define (teardown-test-fixtures)
  (rm-rf test-root))

;; Set up before tests
(setup-test-fixtures)

;;; Test suite for path resolution
(test-begin "path-resolution")

(test-equal "basic file path resolution"
  (string-append test-root "/test.txt")
  (resolve-file-path test-root "/test.txt"))

(test-equal "root path resolution"
  test-root
  (resolve-file-path test-root "/"))

(test-equal "subdirectory path resolution"
  (string-append test-root "/docs/page.gmi")
  (resolve-file-path test-root "/docs/page.gmi"))

(test-equal "empty path becomes root"
  test-root
  (resolve-file-path test-root ""))

;;; Security tests - these should all return #f or safe paths
(test-equal "directory traversal blocked"
  #f
  (resolve-file-path test-root "/../etc/passwd"))

(test-equal "complex directory traversal blocked"
  #f  
  (resolve-file-path test-root "/docs/../../etc/passwd"))

(test-equal "hidden directory traversal blocked"
  #f
  (resolve-file-path test-root "/docs/../../../etc/passwd"))

(test-equal "current directory reference is safe"
  (string-append test-root "/docs")
  (resolve-file-path test-root "/docs/."))

(test-equal "safe relative path with dots"
  (string-append test-root "/file..txt")
  (resolve-file-path test-root "/file..txt"))

(test-equal "multiple slashes normalized"
  (string-append test-root "/docs/page.gmi")
  (resolve-file-path test-root "///docs///page.gmi"))

(test-end "path-resolution")

;;; Test suite for index file detection
(test-begin "index-file-detection")

(test-equal "find index.gmi in directory"
  (string-append test-root "/docs/index.gmi")
  (find-index-file (string-append test-root "/docs")))

(test-equal "find index.gemini in directory"
  (string-append test-root "/other/index.gemini")
  (find-index-file (string-append test-root "/other")))

(test-equal "prefer index.gmi over index.gemini"
  (string-append test-root "/both/index.gmi")
  (find-index-file (string-append test-root "/both")))

(test-equal "no index file returns #f"
  #f
  (find-index-file (string-append test-root "/empty")))

(test-equal "nonexistent directory returns #f"
  #f
  (find-index-file (string-append test-root "/nonexistent")))

(test-end "index-file-detection")

;;; Test suite for file reading
(test-begin "file-reading")

(test-assert "read existing file returns string"
  (string? (read-file-content (string-append test-root "/test.txt"))))

(test-equal "read nonexistent file returns #f"
  #f
  (read-file-content "/tmp/nonexistent-file.txt"))

(test-assert "read binary file returns string or bytevector"
  (let ((binary-file (string-append test-root "/test-binary.png")))
    ;; Create a small binary-like file for testing
    (call-with-output-file binary-file
      (lambda (port) (display "\x89PNG\r\n" port)))
    (let ((result (read-file-content binary-file)))
      (or (string? result) (bytevector? result)))))

(test-end "file-reading")

;; Clean up after tests
(teardown-test-fixtures)

;;; Export for test runner
(define (run-file-handler-tests)
  (display "Running file handler tests...\n"))
