;;; File System Operations
;;; Secure path resolution and file serving for Gemini protocol

(define-module (gemini file-handler)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)  ; for find
  #:use-module (srfi srfi-2)  ; for and-let*
  #:use-module (gemini utils)
  #:export (resolve-file-path
            read-file-content
            find-index-file))

;;; Resolve URI path to filesystem path with security boundary enforcement
(define (resolve-file-path static-root uri-path)
  (and-let* ((clean-path (normalize-uri-path uri-path))
             (normalized-path (normalize-slashes clean-path))
             (full-path (string-append static-root normalized-path))
             (canonical-root (canonicalize-path static-root))
             (canonical-path (safe-canonicalize-path full-path))
             (within-bounds? (and canonical-path 
                                  (within-static-boundary? canonical-root canonical-path))))
    canonical-path))

;;; Helper functions for path processing
(define (normalize-uri-path uri-path)
  (if (string-null? uri-path) "/" uri-path))

(define (normalize-slashes path)
  (regexp-substitute/global #f "/+" path 'pre "/" 'post))

(define (safe-canonicalize-path path)
  (safe-operation (canonicalize-path path)))

(define (within-static-boundary? root target)
  (string-prefix? root target))

;;; Read file content with error handling
(define (read-file-content file-path)
  (safe-operation
    (and (file-exists? file-path)
         (call-with-input-file file-path get-string-all))))

;;; Standard Gemini index file names in priority order
(define index-file-names '("index.gmi" "index.gemini"))

;;; Find index file in directory according to Gemini conventions
(define (find-index-file dir-path)
  (and (file-exists? dir-path) 
       (file-is-directory? dir-path)
       (find file-exists? 
             (map (lambda (name) (string-append dir-path "/" name)) 
                  index-file-names))))