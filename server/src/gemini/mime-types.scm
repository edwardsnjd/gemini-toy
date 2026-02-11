;;; MIME Type Detection and Content Classification
;;; File extension to MIME type mapping for Gemini protocol
;;;
;;; MIME type importance in Gemini:
;;; - Gemini requires MIME type in successful (20) responses
;;; - text/gemini is the canonical MIME type for Gemini documents
;;; - Charset specification is important for international content
;;; - Clients use MIME types to determine rendering behavior
;;;
;;; Content type strategy:
;;; - Extension-based mapping (simple and predictable)
;;; - UTF-8 charset specified for all text content
;;; - Conservative mappings (prefer well-known types)
;;; - Fallback to application/octet-stream for unknown types
;;;
;;; Character encoding considerations:
;;; - UTF-8 is strongly recommended for Gemini content
;;; - All text MIME types include charset=utf-8 parameter
;;; - Binary types don't specify charset (not applicable)
;;; - Consistent encoding prevents client confusion
;;;
;;; Gemini-specific choices:
;;; - text/gemini is the primary document format
;;; - Both .gmi and .gemini extensions map to text/gemini
;;; - Limited set of supported types (following Gemini minimalism)
;;; - No complex content negotiation or multiple encodings

(define-module (gemini mime-types)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 string-fun)
  #:export (get-mime-type
            get-file-extension))

;;; MIME type mapping table with Gemini-focused content types
;;; 
;;; Mapping strategy:
;;; - Gemini documents (.gmi, .gemini) get text/gemini MIME type
;;; - All text formats include charset=utf-8 for international content
;;; - Binary formats don't specify charset (not applicable)
;;; - Conservative set of common web content types
;;; - Extension matching is case-insensitive
;;; 
;;; Gemini protocol considerations:
;;; - text/gemini is the native document format
;;; - UTF-8 encoding is strongly recommended for all text
;;; - Clients may render different MIME types differently
;;; - Unknown types fallback to application/octet-stream
;;; 
;;; Content type choices explained:
;;; - text/gemini: native Gemini markup format
;;; - text/plain: fallback for simple text files
;;; - image/*: common web image formats
;;; - application/pdf: document sharing
;;; - archive types: software distribution
(define mime-type-table
  '(;; Gemini native formats (primary content type)
    ("gmi"    . "text/gemini; charset=utf-8")
    ("gemini" . "text/gemini; charset=utf-8")
    
    ;; Text formats (include UTF-8 charset specification)
    ("txt"    . "text/plain; charset=utf-8")
    ("html"   . "text/html; charset=utf-8")
    ("htm"    . "text/html; charset=utf-8")
    ("css"    . "text/css; charset=utf-8")
    ("js"     . "application/javascript; charset=utf-8")
    ("json"   . "application/json; charset=utf-8")
    ("xml"    . "application/xml; charset=utf-8")
    
    ;; Image formats (binary, no charset needed)
    ("png"    . "image/png")
    ("jpg"    . "image/jpeg")
    ("jpeg"   . "image/jpeg")
    ("gif"    . "image/gif")
    ("svg"    . "image/svg+xml")  ; SVG is XML-based
    
    ;; Document and archive formats
    ("pdf"    . "application/pdf")
    ("zip"    . "application/zip")
    ("tar"    . "application/x-tar")
    ("gz"     . "application/gzip")))

;;; Get MIME type for a file path using extension mapping
;;; 
;;; MIME type resolution strategy:
;;; 1. Extract file extension from path
;;; 2. Convert to lowercase for case-insensitive matching
;;; 3. Look up extension in mapping table
;;; 4. Return specific MIME type or generic fallback
;;; 
;;; Fallback behavior:
;;; - Unknown extensions get "application/octet-stream"
;;; - This tells clients to treat content as binary data
;;; - Prevents misinterpretation of unknown file types
;;; - Consistent with HTTP server behavior
;;; 
;;; Character encoding strategy:
;;; - Text MIME types include "charset=utf-8" parameter
;;; - This eliminates encoding guesswork for clients
;;; - UTF-8 is the recommended encoding for Gemini content
;;; - Binary types don't specify charset (meaningless for binary data)
(define (get-mime-type file-path)
  (let* ((extension (string-downcase (get-file-extension file-path)))
         (mime-entry (assoc extension mime-type-table)))
    (if mime-entry
        (cdr mime-entry)  ; Return mapped MIME type
        "application/octet-stream")))  ; Generic binary fallback

;;; Extract file extension from path with proper edge case handling
;;; 
;;; Extension extraction rules:
;;; - Use only the final path component (basename)
;;; - Find the last dot in the filename
;;; - Extract everything after the dot as extension
;;; - Handle edge cases (no extension, dot at end, hidden files)
;;; 
;;; Edge case handling:
;;; - Files without extensions return empty string
;;; - Files ending with dot (filename.) return empty string
;;; - Hidden files (.bashrc) are handled correctly
;;; - Multiple dots (file.tar.gz) only consider the last extension
;;; 
;;; Limitations:
;;; - Only considers the last extension (gz, not tar.gz)
;;; - Case sensitivity is handled at MIME type lookup level
;;; - No special handling for compound extensions
(define (get-file-extension file-path)
  (let ((basename (basename file-path)))
    (let ((dot-pos (string-rindex basename #\.)))
      (if (and dot-pos 
               ;; Ensure dot is not at the end of filename
               (< dot-pos (- (string-length basename) 1)))
          ;; Extract extension after the dot
          (substring basename (+ dot-pos 1))
          ;; No extension found
          ""))))