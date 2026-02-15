;;; Gemini Server Utilities
;;; Shared abstractions for elegant error handling and data processing

(define-module (gemini utils)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)  ; and-let*
  #:use-module (srfi srfi-71)
  #:export (safe-operation
            error-or
            chain-operations
            or-map-handlers
            non-empty-string?
            valid-port?
            file-readable?))

;;; Safe operation wrapper - replaces repetitive catch patterns
(define-syntax-rule (safe-operation body ...)
  (catch #t (lambda () body ...) (const #f)))

;;; Error handling with default fallback
(define-syntax-rule (error-or default-value body ...)
  (or (safe-operation body ...) default-value))

;;; Monadic chaining for operations that might fail
(define-syntax-rule (chain-operations ((var expr) ...) body ...)
  (and-let* ((var expr) ...) body ...))

;;; Apply handlers until one succeeds (for pipeline processing)
(define (or-map-handlers handlers . args)
  (fold (lambda (handler acc)
          (or acc (apply handler args)))
        #f
        handlers))

;;; Predicate utilities for common validations
(define (non-empty-string? str)
  (and (string? str) (not (string-null? str))))

(define (valid-port? port)
  (and (number? port) (< 0 port 65536)))

(define (file-readable? filename)
  (safe-operation
    (and (file-exists? filename)
         (not (eq? 'directory (stat:type (stat filename))))
         (access? filename R_OK))))