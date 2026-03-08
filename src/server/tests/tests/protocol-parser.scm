;;; Unit Tests: Protocol Parser
;;; Tests for Gemini protocol request parsing and response formatting

(define-module (tests protocol-parser)
  #:use-module (srfi srfi-64)
  #:use-module (gemini protocol)
  #:use-module (web uri))

;;; Test suite for URI parsing
(test-begin "uri-parsing")

(test-equal "valid gemini URI parsing"
  "/test.txt"
  (let ((uri (parse-gemini-request "gemini://localhost:1965/test.txt")))
    (if uri (uri-path uri) #f)))

(test-equal "gemini URI with default port"
  "/index.gmi" 
  (let ((uri (parse-gemini-request "gemini://example.com/index.gmi")))
    (if uri (uri-path uri) #f)))

(test-equal "gemini URI with explicit port"
  "/docs/page.gmi"
  (let ((uri (parse-gemini-request "gemini://server.example.com:1965/docs/page.gmi")))
    (if uri (uri-path uri) #f)))

(test-equal "gemini URI with query string"
  "/search?query=test"
  (let ((uri (parse-gemini-request "gemini://localhost/search?query=test")))
    (if uri (string-append (uri-path uri) "?" (uri-query uri)) #f)))

(test-equal "root path handling"
  "/"
  (let ((uri (parse-gemini-request "gemini://localhost/")))
    (if uri (uri-path uri) #f)))

(test-equal "empty path becomes root"
  "/"
  (let ((uri (parse-gemini-request "gemini://localhost")))
    (if uri (uri-path uri) #f)))

;;; Invalid URI tests
(test-equal "non-gemini scheme rejected"
  #f
  (parse-gemini-request "http://localhost/test.txt"))

(test-equal "URI with userinfo rejected"
  #f  
  (parse-gemini-request "gemini://user:pass@localhost/test.txt"))

(test-equal "URI with fragment rejected"
  #f
  (parse-gemini-request "gemini://localhost/test.txt#fragment"))

(test-equal "malformed URI rejected"
  #f
  (parse-gemini-request "not-a-uri"))

(test-equal "empty string rejected"
  #f
  (parse-gemini-request ""))

(test-end "uri-parsing")

;;; Test suite for request validation  
(test-begin "request-validation")

(test-equal "valid request passes validation"
  #t
  (validate-request "gemini://localhost/test.txt\r\n"))

(test-equal "request too long rejected" 
  #f
  (let ((long-request (string-append "gemini://localhost/"
                                    (make-string 1010 #\x) "\r\n")))
    (validate-request long-request)))

(test-equal "request without CRLF rejected"
  #f
  (validate-request "gemini://localhost/test.txt"))  ; No \r\n

(test-equal "request with CRLF accepted"
  #t
  (validate-request "gemini://localhost/test.txt\r\n"))

(test-equal "request with just LF accepted"
  #t  
  (validate-request "gemini://localhost/test.txt\n"))

(test-equal "exactly 1024 bytes accepted"
  #t
  (let ((request (string-append "gemini://localhost/" (make-string 1003 #\a) "\r\n")))
    (validate-request request)))

(test-equal "1025 bytes rejected"
  #f
  (let ((request (string-append "gemini://localhost/" (make-string 1004 #\a) "\r\n")))
    (validate-request request)))

(test-equal "malformed URI fails validation"
  #f
  (validate-request "not-a-uri\r\n"))

(test-equal "non-gemini scheme fails validation"
  #f
  (validate-request "http://localhost/test.txt\r\n"))

(test-equal "URI with userinfo fails validation"
  #f
  (validate-request "gemini://user:pass@localhost/test.txt\r\n"))

(test-equal "URI with fragment fails validation"
  #f
  (validate-request "gemini://localhost/test.txt#fragment\r\n"))

(test-equal "empty request fails validation"
  #f
  (validate-request ""))

(test-equal "whitespace-only request fails validation"
  #f
  (validate-request "   \r\n"))

(test-end "request-validation")

;;; Test suite for response formatting
(test-begin "response-formatting")

(test-equal "success response format"
  "20 text/gemini; charset=utf-8\r\n"
  (format-gemini-response 20 "text/gemini; charset=utf-8" #f))

(test-equal "error response format"  
  "51 Not Found\r\n"
  (format-gemini-response 51 "Not Found" #f))

(test-equal "success response with body"
  "20 text/plain\r\nHello, world!"
  (format-gemini-response 20 "text/plain" "Hello, world!"))

(test-equal "redirect response format"
  "30 gemini://new-location/\r\n"
  (format-gemini-response 30 "gemini://new-location/" #f))

(test-equal "response/redirect function returns correct format with target"
  "30 gemini://example.com/docs/\r\n"
  (response/redirect "gemini://example.com/docs/"))

(test-equal "bad request response format"
  "59 Bad Request\r\n"
  (format-gemini-response 59 "Bad Request" #f))

(test-equal "bad request response format"
  "59 Bad Request\r\n"
  (format-gemini-response 59 "Bad Request" #f))

(test-equal "client-cert-required response format"
  "60 Client Certificate Required\r\n"
  response/client-cert-required)

(test-equal "cert-not-authorized response format"
  "61 Certificate Not Authorized\r\n"
  response/cert-not-authorized)

(test-equal "cert-not-valid response format"
  "62 Certificate Not Valid\r\n"
  response/cert-not-valid)

(test-equal "proxy-request-refused response format"
  "52 Proxy Request Refused\r\n"
  response/proxy-request-refused)

(test-end "response-formatting")

;;; Export for test runner
(define (run-protocol-parser-tests)
  (display "Running protocol parser tests...\n")
  ;; Tests run when module is loaded
  )