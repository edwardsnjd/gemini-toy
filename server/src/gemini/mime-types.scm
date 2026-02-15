;;; MIME Type Detection for Gemini Protocol
;;; Extension-based MIME type mapping with UTF-8 charset for text content

(define-module (gemini mime-types)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 string-fun)
  #:export (get-mime-type
            get-file-extension))

;;; MIME type mapping table for common file extensions
(define mime-type-table
  '(;; Gemini native formats
    ("gmi"    . "text/gemini; charset=utf-8")
    ("gemini" . "text/gemini; charset=utf-8")
    
    ;; Text formats with UTF-8 charset
    ("txt"    . "text/plain; charset=utf-8")
    ("html"   . "text/html; charset=utf-8")
    ("htm"    . "text/html; charset=utf-8")
    ("css"    . "text/css; charset=utf-8")
    ("js"     . "application/javascript; charset=utf-8")
    ("json"   . "application/json; charset=utf-8")
    ("xml"    . "application/xml; charset=utf-8")
    
    ;; Image formats
    ("png"    . "image/png")
    ("jpg"    . "image/jpeg")
    ("jpeg"   . "image/jpeg")
    ("gif"    . "image/gif")
    ("svg"    . "image/svg+xml")
    
    ;; Document and archive formats
    ("pdf"    . "application/pdf")
    ("zip"    . "application/zip")
    ("tar"    . "application/x-tar")
    ("gz"     . "application/gzip")))

;;; Get MIME type for a file path using extension mapping
(define (get-mime-type file-path)
  (let* ((extension (string-downcase (get-file-extension file-path)))
         (mime-entry (assoc extension mime-type-table)))
    (if mime-entry
        (cdr mime-entry)
        "application/octet-stream")))

;;; Extract file extension from path
(define (get-file-extension file-path)
  (let* ((basename (basename file-path))
         (dot-pos (string-rindex basename #\.)))
    (if (and dot-pos 
             (> dot-pos 0)
             (< dot-pos (- (string-length basename) 1)))
        (substring basename (+ dot-pos 1))
        "")))