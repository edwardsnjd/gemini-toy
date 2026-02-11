;;; Gemini Protocol Implementation
;;; Request parsing and response formatting

(define-module (gemini protocol)
  #:use-module (ice-9 regex)
  #:use-module (web uri)
  #:export (parse-gemini-request
            format-gemini-response
            validate-request))

;;; Parse a Gemini request line
;;; Returns URI object or #f for invalid requests
(define (parse-gemini-request request-line)
  (catch #t
    (lambda ()
      (let ((cleaned-request (string-trim-right request-line #\newline #\return)))
        (if (string-null? cleaned-request)
            #f
            (let ((uri (string->uri cleaned-request)))
              (if (and uri
                       (equal? (uri-scheme uri) "gemini")
                       (not (uri-userinfo uri))
                       (not (uri-fragment uri)))
                  ;; Normalize empty path to "/"
                  (if (string-null? (uri-path uri))
                      (uri (uri-scheme uri) (uri-userinfo uri) (uri-host uri) 
                           (uri-port uri) "/" (uri-query uri) (uri-fragment uri))
                      uri)
                  #f)))))
    (lambda (key . args)
      #f)))

;;; Format a Gemini response
;;; Returns formatted response string
(define (format-gemini-response status-code meta body)
  (let ((header (string-append (number->string status-code) 
                              " " 
                              meta 
                              "\r\n")))
    (if body
        (string-append header body)
        header)))

;;; Validate request format and constraints
(define (validate-request request-line)
  (and 
    ;; Check length limit (1024 bytes as per spec)
    (<= (string-length request-line) 1024)
    ;; Check that request is not empty or whitespace-only
    (not (string-null? (string-trim request-line)))
    ;; Check that it ends with CRLF or LF
    (or (string-suffix? "\r\n" request-line)
        (string-suffix? "\n" request-line))
    ;; Check that URI can be parsed successfully
    (let ((uri (parse-gemini-request request-line)))
      (and uri #t))))