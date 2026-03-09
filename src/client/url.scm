(define-module (client url)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 regex)
  #:export (parse-url))

;; Parses a Gemini URL and returns a list: (host port path)
;; Throws an error if the URL does not start with "gemini://".
;; Default port is 1965 if not specified.
;; Path includes the leading '/' and any query string.

(define (parse-url url)
  (unless (string-prefix? "gemini://" url)
    (error "Invalid scheme: URL must start with gemini://" url))
  (let* ((without-scheme (substring url (string-length "gemini://")))
         (host-port-path (string-split without-scheme #\/))
         (host-port (car host-port-path))
         (path (if (null? (cdr host-port-path))
                   "/"
                   (string-append "/" (string-join (cdr host-port-path) "/"))))
         (host (if (string-contains host-port ":")
                   (car (string-split host-port #\:))
                   host-port))
         (port (if (string-contains host-port ":")
                   (string->number (cadr (string-split host-port #\:)))
                   1965)))
    (list host port path)))
