;;; File System Operations
;;; Path resolution and file serving

(define-module (gemini file-handler)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:export (resolve-file-path
            read-file-content
            find-index-file))

;;; Resolve URI path to filesystem path safely
(define (resolve-file-path static-root uri-path)
  (let* ((clean-path (if (string-null? uri-path) "/" uri-path))
         ;; Normalize multiple slashes
         (normalized (regexp-substitute/global #f "/+" clean-path 'pre "/" 'post))
         ;; Build full path  
         (full-path (string-append static-root normalized)))
    ;; Security check: ensure resolved path stays within static-root
    (let ((canonical-root (canonicalize-path static-root))
          (canonical-path (catch #t 
                            (lambda () (canonicalize-path full-path))
                            (lambda (key . args) #f))))
      (if (and canonical-path 
               (string-prefix? canonical-root canonical-path))
          canonical-path
          #f))))

;;; Read file content, handling both text and binary
(define (read-file-content file-path)
  (catch #t
    (lambda ()
      (if (file-exists? file-path)
          (call-with-input-file file-path get-string-all)
          #f))
    (lambda (key . args)
      #f)))

;;; Find index file in directory
(define (find-index-file dir-path)
  (if (and (file-exists? dir-path) (file-is-directory? dir-path))
      (let ((index-gmi (string-append dir-path "/index.gmi"))
            (index-gemini (string-append dir-path "/index.gemini")))
        (cond
          ((file-exists? index-gmi) index-gmi)
          ((file-exists? index-gemini) index-gemini)
          (else #f)))
      #f))