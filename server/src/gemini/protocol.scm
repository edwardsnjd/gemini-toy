;;; Gemini Protocol Implementation
;;; Request parsing and response formatting according to RFC specification
;;; 
;;; This module implements the core Gemini protocol parsing and response formatting
;;; as specified in the Gemini protocol specification (gemini://gemini.circumlunar.space/docs/specification.gmi)

(define-module (gemini protocol)
  #:use-module (ice-9 regex)
  #:use-module (web uri)
  #:use-module (srfi srfi-14)
  #:export (parse-gemini-request
            format-gemini-response
            validate-request))

;;; Parse a Gemini request line according to protocol specification
;;; 
;;; Gemini requests are simple: a single line containing a URI followed by CRLF
;;; The URI must be absolute and use the gemini:// scheme
;;; 
;;; Security considerations:
;;; - Rejects URIs with userinfo (user:pass@host) as they're deprecated and risky
;;; - Rejects URIs with fragments (#anchor) as per Gemini spec - fragments are client-side only
;;; - Normalizes empty paths to "/" to prevent ambiguous resource requests
;;; 
;;; Error handling strategy:
;;; - Returns #f for any malformed request rather than throwing exceptions
;;; - Graceful degradation allows server to send proper Gemini error responses
;;; 
;;; Returns: URI object or #f for invalid requests
(define (parse-gemini-request request-line)
  (catch #t
    (lambda ()
        ;; Strip line endings first - Gemini allows both CRLF and LF
        ;; This handles clients that send either terminator correctly
        (let ((cleaned-request (string-trim-right request-line (char-set #\newline #\return))))
        (if (string-null? cleaned-request)
            #f
            (let ((uri (string->uri cleaned-request)))
              (if (and uri
                        ;; Gemini spec: URI must use gemini scheme
                        (equal? (uri-scheme uri) 'gemini)
                        ;; Security: reject userinfo (user:pass@host) - deprecated and risky
                        (not (uri-userinfo uri))
                        ;; Gemini spec: fragments are forbidden in requests (client-side only)
                        (not (uri-fragment uri)))
                   ;; Path normalization: empty path becomes "/" 
                   ;; This prevents ambiguous requests and ensures consistent resource addressing
                   (if (string-null? (uri-path uri))
                       (build-uri (uri-scheme uri) 
                                  #:userinfo (uri-userinfo uri)
                                  #:host (uri-host uri)
                                  #:port (uri-port uri) 
                                  #:path "/"
                                  #:query (uri-query uri)
                                  #:fragment (uri-fragment uri))
                       uri)
                  #f)))))
    (lambda (key . args)
      ;; Error handling: any parsing exception returns #f
      ;; This allows the server to respond with appropriate Gemini error codes
      ;; rather than crashing on malformed input
      #f)))

;;; Format a Gemini response according to protocol specification
;;; 
;;; Gemini responses have a strict format: STATUS_CODE SPACE META CRLF [BODY]
;;; Status codes are two-digit numbers with specific meanings:
;;; - 1x: INPUT - server needs more information from client
;;; - 2x: SUCCESS - request fulfilled, body follows
;;; - 3x: REDIRECT - resource moved, meta contains new URL
;;; - 4x: TEMPORARY FAILURE - try again later  
;;; - 5x: PERMANENT FAILURE - don't retry
;;; - 6x: CLIENT CERTIFICATE REQUIRED - authentication needed
;;; 
;;; Meta field usage:
;;; - For 2x responses: MIME type (e.g., "text/gemini; charset=utf-8")
;;; - For 3x responses: redirect URL
;;; - For error responses: human-readable error message
;;; - Maximum 1024 bytes for the entire response header
;;; 
;;; Returns: properly formatted Gemini response string
(define (format-gemini-response status-code meta body)
  (let ((header (string-append (number->string status-code) 
                              " " 
                              meta 
                              "\r\n")))  ; Always use CRLF as per Gemini spec
    (if body
        (string-append header body)
        header)))

;;; Validate request format and constraints according to Gemini specification
;;; 
;;; Gemini request validation rules:
;;; 1. Maximum 1024 bytes total length (prevents DoS attacks)
;;; 2. Must not be empty or whitespace-only
;;; 3. Must end with line terminator (CRLF or LF for compatibility)
;;; 4. Must parse as valid URI
;;; 
;;; Security rationale:
;;; - Length limit prevents memory exhaustion attacks
;;; - Non-empty check prevents ambiguous requests
;;; - Line terminator ensures proper protocol framing
;;; - URI parsing validates request structure before processing
;;; 
;;; Returns: #t if request is valid, #f otherwise
(define (validate-request request-line)
  (and 
    ;; Gemini spec: requests must not exceed 1024 bytes
    ;; This prevents DoS attacks via oversized requests
    (<= (string-length request-line) 1024)
    ;; Reject empty or whitespace-only requests - they're meaningless
    (not (string-null? (string-trim request-line)))
    ;; Gemini spec: requests end with CRLF, but accept LF for compatibility
    ;; This ensures proper protocol message framing
    (or (string-suffix? "\r\n" request-line)
        (string-suffix? "\n" request-line))
    ;; Final validation: ensure the URI can be successfully parsed
    ;; This catches malformed URIs before they cause parsing errors
    (let ((uri (parse-gemini-request request-line)))
      (and uri #t))))