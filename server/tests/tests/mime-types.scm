;;; Unit Tests: MIME Types
;;; Tests for file extension detection and MIME type mapping

(add-to-load-path "../src")

(define-module (tests mime-types)
  #:use-module (srfi srfi-64)
  #:use-module (gemini mime-types))

;;; Test suite for file extension extraction
(test-begin "file-extension")

(test-equal "extract .txt extension"
  "txt"
  (get-file-extension "test.txt"))

(test-equal "extract .gmi extension" 
  "gmi"
  (get-file-extension "document.gmi"))

(test-equal "extract .gemini extension"
  "gemini" 
  (get-file-extension "page.gemini"))

(test-equal "extract extension from path"
  "html"
  (get-file-extension "/path/to/file.html"))

(test-equal "extract extension with multiple dots"
  "gz"
  (get-file-extension "archive.tar.gz"))

(test-equal "no extension returns empty string"
  ""
  (get-file-extension "README"))

(test-equal "no extension with path returns empty string"
  ""
  (get-file-extension "/path/to/README"))

(test-equal "hidden file with extension"
  "conf"
  (get-file-extension ".gitignore.conf"))

(test-equal "hidden file without extension" 
  ""
  (get-file-extension ".gitignore"))

(test-end "file-extension")

;;; Test suite for MIME type mapping
(test-begin "mime-type-mapping")

(test-equal "Gemini files (.gmi) get text/gemini"
  "text/gemini; charset=utf-8"
  (get-mime-type "test.gmi"))

(test-equal "Gemini files (.gemini) get text/gemini"
  "text/gemini; charset=utf-8"
  (get-mime-type "document.gemini"))

(test-equal "Text files get text/plain"
  "text/plain; charset=utf-8"
  (get-mime-type "readme.txt"))

(test-equal "HTML files get text/html"
  "text/html; charset=utf-8"
  (get-mime-type "index.html"))

(test-equal "PNG files get image/png"
  "image/png"
  (get-mime-type "photo.png"))

(test-equal "JPEG files get image/jpeg"
  "image/jpeg"
  (get-mime-type "photo.jpg"))

(test-equal "CSS files get text/css"
  "text/css; charset=utf-8"
  (get-mime-type "styles.css"))

(test-equal "JavaScript files get application/javascript"
  "application/javascript; charset=utf-8"
  (get-mime-type "script.js"))

(test-equal "Unknown extension gets octet-stream"
  "application/octet-stream"
  (get-mime-type "file.unknown"))

(test-equal "No extension gets octet-stream"
  "application/octet-stream"
  (get-mime-type "README"))

(test-equal "Case insensitive extension matching"
  "text/html; charset=utf-8"
  (get-mime-type "FILE.HTML"))

(test-equal "Path handling preserves MIME type detection"
  "text/gemini; charset=utf-8"
  (get-mime-type "/path/to/document.gmi"))

(test-end "mime-type-mapping")

;;; Export for test runner
(define (run-mime-types-tests)
  (display "Running MIME types tests...\n"))